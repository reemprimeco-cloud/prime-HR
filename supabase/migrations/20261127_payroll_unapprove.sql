-- Approve / un-approve a payroll month atomically.
-- effects records exactly what approval changed (loan installments, debt entries) so it can be reversed.
alter table public.payroll_runs add column if not exists effects jsonb not null default '{}'::jsonb;

-- Approve: freeze the sheet, deduct loan installments, record debt entries - all or nothing.
-- p_loans:   [{id, amount}]                    installments per loan
-- p_arrears: [{employee_id, kind, amount}]     kind in ('deferred','repaid')
create or replace function public.approve_payroll_month(p_month text, p_totals jsonb, p_lines jsonb, p_loans jsonb, p_arrears jsonb)
returns public.payroll_runs
language plpgsql security invoker set search_path = public
as $$
declare
  r public.payroll_runs;
  x jsonb;
  amt numeric;
  aid uuid;
  loan_fx jsonb := '[]'::jsonb;
  arr_ids jsonb := '[]'::jsonb;
begin
  insert into public.payroll_runs (month, totals, lines) values (p_month, coalesce(p_totals,'{}'), coalesce(p_lines,'[]')) returning * into r;
  for x in select * from jsonb_array_elements(coalesce(p_loans,'[]')) loop
    amt := round((x->>'amount')::numeric, 3);
    if amt <= 0 then continue; end if;
    update public.loans set deducted = deducted + amt
      where id = (x->>'id')::uuid and user_id = auth.uid() and deducted + amt <= original + 0.0005;
    if not found then raise exception 'loan_not_applicable %', x->>'id' using errcode = 'P0001'; end if;
    loan_fx := loan_fx || jsonb_build_object('id', x->>'id', 'amount', amt);
  end loop;
  for x in select * from jsonb_array_elements(coalesce(p_arrears,'[]')) loop
    amt := round((x->>'amount')::numeric, 3);
    if amt <= 0 then continue; end if;
    insert into public.salary_arrears (employee_id, month, kind, amount, notes)
      values ((x->>'employee_id')::uuid, p_month, x->>'kind', amt, 'payroll') returning id into aid;
    arr_ids := arr_ids || to_jsonb(aid::text);
  end loop;
  update public.payroll_runs set effects = jsonb_build_object('loans', loan_fx, 'arrears', arr_ids) where id = r.id returning * into r;
  return r;
end $$;

-- Un-approve: give back the loan installments, remove the debt entries, unfreeze the month.
create or replace function public.unapprove_payroll_month(p_month text)
returns jsonb
language plpgsql security invoker set search_path = public
as $$
declare
  r public.payroll_runs;
  x jsonb;
begin
  select * into r from public.payroll_runs where user_id = auth.uid() and month = p_month for update;
  if not found then raise exception 'run_not_found' using errcode = 'P0002'; end if;
  if not (r.effects ? 'loans') then raise exception 'run_without_effects' using errcode = 'P0001'; end if;
  for x in select * from jsonb_array_elements(r.effects->'loans') loop
    update public.loans set deducted = greatest(0, deducted - (x->>'amount')::numeric)
      where id = (x->>'id')::uuid and user_id = auth.uid();
  end loop;
  delete from public.salary_arrears
    where user_id = auth.uid() and id in (select v::uuid from jsonb_array_elements_text(coalesce(r.effects->'arrears','[]')) v);
  delete from public.payroll_runs where id = r.id;
  return jsonb_build_object('lines', r.lines, 'effects', r.effects);
end $$;

revoke all on function public.approve_payroll_month(text, jsonb, jsonb, jsonb, jsonb) from public, anon;
revoke all on function public.unapprove_payroll_month(text) from public, anon;
grant execute on function public.approve_payroll_month(text, jsonb, jsonb, jsonb, jsonb) to authenticated;
grant execute on function public.unapprove_payroll_month(text) to authenticated;
