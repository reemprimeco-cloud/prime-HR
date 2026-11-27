-- Work permit (إذن العمل): number and expiry, alerted 60 days ahead like residency/passport.
alter table public.employees add column if not exists work_permit_no text;
alter table public.employees add column if not exists work_permit_expiry date;
alter table public.employees drop constraint if exists employees_work_permit_no_len;
alter table public.employees add constraint employees_work_permit_no_len check (work_permit_no is null or char_length(work_permit_no) <= 40);
