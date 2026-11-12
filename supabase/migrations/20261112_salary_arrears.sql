-- Prime HR: salary owed by the company to employees (رواتب مؤجلة / دين على الشركة).
-- 'deferred' = part of a month's salary not transferred (company owes it);
-- 'repaid'   = later payment of that debt. Balance = deferred - repaid.
-- Safe to re-run.

create table if not exists public.salary_arrears (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  month text not null check (month ~ '^[0-9]{4}-[0-9]{2}$'),
  kind text not null check (kind in ('deferred','repaid')),
  amount numeric not null check (amount > 0),
  notes text,
  created_at timestamptz not null default now()
);
create index if not exists salary_arrears_user_idx on public.salary_arrears(user_id);
create index if not exists salary_arrears_employee_idx on public.salary_arrears(employee_id);

alter table public.salary_arrears enable row level security;
drop policy if exists isolated_by_user on public.salary_arrears;
create policy isolated_by_user on public.salary_arrears for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber())
    and exists (select 1 from public.employees e where e.id = employee_id and e.user_id = (select auth.uid())));

revoke all on public.salary_arrears from anon;
revoke truncate, references, trigger on public.salary_arrears from authenticated;
