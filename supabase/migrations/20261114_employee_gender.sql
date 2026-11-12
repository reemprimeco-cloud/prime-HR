-- Gender (m/f): used only to word Arabic certificates correctly (يعمل/تعمل، خدمته/خدمتها).
alter table public.employees add column if not exists gender text;
alter table public.employees drop constraint if exists employees_gender_chk;
alter table public.employees add constraint employees_gender_chk check (gender is null or gender in ('m','f'));
