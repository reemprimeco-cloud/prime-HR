-- Prime HR: security hardening (from the security audit of 2026-11-12).
-- Safe to re-run. Apply in the Supabase SQL editor for the Prime-HR project.

-- 1) CRITICAL: subscribers could approve themselves / extend their subscription.
--    The UPDATE policy on user_profiles allowed any signed-in user to set approved, approved_at and plan
--    on their own row. Approval, renewal and revocation are admin-only (admin_* functions below).
drop policy if exists user_updates_own_profile on public.user_profiles;
revoke all on public.user_profiles from anon;
revoke insert, update, delete, truncate, references, trigger on public.user_profiles from authenticated;
grant select on public.user_profiles to authenticated;

-- 2) HIGH: admin functions compared a possibly-NULL email with "!=", so a caller without an email
--    (e.g. an anonymous sign-in, if ever enabled) would pass the check. Use a NULL-safe comparison
--    and never expose these functions to anon.
create or replace function public.is_prime_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select email from auth.users where id = (select auth.uid())), '') = 'reem@primekw.net';
$$;

create or replace function public.admin_approve_user(target_user_id uuid, target_plan text default 'starter')
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_prime_admin() then raise exception 'Unauthorized'; end if;
  update public.user_profiles set approved = true, approved_at = now(), plan = target_plan where id = target_user_id;
end; $$;

create or replace function public.admin_revoke_user(target_user_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_prime_admin() then raise exception 'Unauthorized'; end if;
  update public.user_profiles set approved = false, approved_at = null where id = target_user_id;
end; $$;

create or replace function public.admin_list_users()
returns table(id uuid, email text, company_name text, plan text, approved boolean, approved_at timestamptz, created_at timestamptz, notes text)
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_prime_admin() then raise exception 'Unauthorized'; end if;
  return query select p.id, p.email, p.company_name, p.plan, p.approved, p.approved_at, p.created_at, p.notes
    from public.user_profiles p order by p.created_at desc;
end; $$;

-- 3) MEDIUM: the subscription was only enforced in the browser. Data is now readable/writable only by an
--    active subscriber (approved within the last year, same rule as the app) or the admin.
create or replace function public.is_active_subscriber() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.user_profiles p
    where p.id = (select auth.uid()) and p.approved and p.approved_at > now() - interval '1 year'
  ) or public.is_prime_admin();
$$;

revoke all on function public.is_prime_admin() from public, anon;
revoke all on function public.is_active_subscriber() from public, anon;
revoke all on function public.admin_approve_user(uuid, text) from public, anon;
revoke all on function public.admin_revoke_user(uuid) from public, anon;
revoke all on function public.admin_list_users() from public, anon;
grant execute on function public.is_prime_admin() to authenticated;
grant execute on function public.is_active_subscriber() to authenticated;
grant execute on function public.admin_approve_user(uuid, text) to authenticated;
grant execute on function public.admin_revoke_user(uuid) to authenticated;
grant execute on function public.admin_list_users() to authenticated;
-- Trigger function: never callable over the API
revoke all on function public.handle_new_user() from public, anon, authenticated;

drop policy if exists isolated_by_user on public.employees;
create policy isolated_by_user on public.employees for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber()));

-- 4) LOW: child records could reference another company's employee id. Require the employee to be yours.
drop policy if exists isolated_by_user on public.loans;
create policy isolated_by_user on public.loans for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber())
    and exists (select 1 from public.employees e where e.id = employee_id and e.user_id = (select auth.uid())));

drop policy if exists isolated_by_user on public.eos_payments;
create policy isolated_by_user on public.eos_payments for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber())
    and exists (select 1 from public.employees e where e.id = employee_id and e.user_id = (select auth.uid())));

drop policy if exists isolated_by_user on public.leave_records;
create policy isolated_by_user on public.leave_records for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber())
    and exists (select 1 from public.employees e where e.id = employee_id and e.user_id = (select auth.uid())));

-- 5) LOW (defence in depth): anon never needs these tables; nobody needs TRUNCATE/TRIGGER/REFERENCES.
revoke all on public.employees, public.loans, public.eos_payments, public.leave_records from anon;
revoke truncate, references, trigger on public.employees, public.loans, public.eos_payments, public.leave_records from authenticated;
do $$ begin
  if to_regclass('public.public_holidays') is not null then
    execute 'revoke all on public.public_holidays from anon';
    execute 'revoke truncate, references, trigger on public.public_holidays from authenticated';
  end if;
end $$;
