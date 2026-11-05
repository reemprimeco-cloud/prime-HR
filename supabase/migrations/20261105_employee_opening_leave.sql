-- Prime HR: optional opening leave balance per employee, for subscribers moving from Excel or another system.
-- Run once in the Supabase SQL editor for the Prime HR project. Safe to re-run.
-- Until it runs, the app hides the opening-balance fields and accrues leave from the hire date.

alter table public.employees add column if not exists leave_opening_balance numeric;
alter table public.employees add column if not exists leave_opening_date date;

comment on column public.employees.leave_opening_balance is 'Remaining annual leave (working days) on leave_opening_date; accrual continues from it at 30 working days/year';
comment on column public.employees.leave_opening_date is 'Date the opening leave balance applies from; leave records before it are not deducted again';
