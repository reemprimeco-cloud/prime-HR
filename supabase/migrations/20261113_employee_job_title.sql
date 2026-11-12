-- Job title (المسمى الوظيفي): shown on salary certificates, payslips and statements.
alter table public.employees add column if not exists job_title text;
alter table public.employees drop constraint if exists employees_job_title_len;
alter table public.employees add constraint employees_job_title_len check (job_title is null or char_length(job_title) <= 80);
