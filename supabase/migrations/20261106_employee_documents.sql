-- Prime HR: Kuwait employee documents — Civil ID, nationality, residency and passport expiry.
-- Run once in the Supabase SQL editor for the Prime HR project. Safe to re-run.
-- Until it runs, the app hides the documents section and expiry alerts.

alter table public.employees add column if not exists civil_id text;
alter table public.employees add column if not exists nationality text;
alter table public.employees add column if not exists residency_expiry date;
alter table public.employees add column if not exists passport_expiry date;

-- Civil ID is 12 digits when present
do $$ begin
  alter table public.employees add constraint employees_civil_id_format check (civil_id is null or civil_id ~ '^[0-9]{12}$');
exception when duplicate_object then null; end $$;

comment on column public.employees.residency_expiry is 'Residency (iqama) expiry; dashboard warns 60 days ahead (not used for Kuwaiti staff)';
comment on column public.employees.passport_expiry is 'Passport expiry; dashboard warns 60 days ahead';
