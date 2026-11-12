-- Prime HR: approved payroll months (one per company per month) with a frozen copy of the sheet.
-- The unique (user_id, month) key makes approval idempotent across devices, so loan installments
-- and salary debts can never be recorded twice for the same month. Safe to re-run.

create table if not exists public.payroll_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  month text not null check (month ~ '^[0-9]{4}-[0-9]{2}$'),
  approved_at timestamptz not null default now(),
  totals jsonb not null default '{}'::jsonb,
  lines jsonb not null default '[]'::jsonb,
  unique (user_id, month)
);

alter table public.payroll_runs enable row level security;
drop policy if exists isolated_by_user on public.payroll_runs;
create policy isolated_by_user on public.payroll_runs for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_subscriber()))
  with check (user_id = (select auth.uid()) and (select public.is_active_subscriber()));

revoke all on public.payroll_runs from anon;
revoke truncate, references, trigger on public.payroll_runs from authenticated;
