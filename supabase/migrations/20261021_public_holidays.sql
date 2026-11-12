-- Prime HR: official holidays used to exclude days from annual leave (Labour Law Art. 70).
-- Applied to the Prime-HR project on 2026-11-12 (after 20261112_security_hardening.sql). Safe to re-run.

create table if not exists public.public_holidays (
  id uuid primary key default gen_random_uuid(),
  date date not null unique,
  name_ar text not null,
  name_en text not null default '',
  approx boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.public_holidays enable row level security;

drop policy if exists "Holidays are readable by signed-in users" on public.public_holidays;
create policy "Holidays are readable by signed-in users"
  on public.public_holidays for select
  to authenticated
  using (true);

-- Only the Prime HR admin may add, change or remove holidays (is_prime_admin() from the security
-- hardening migration). Separate write policies so they do not overlap the read policy.
drop policy if exists "Holidays are managed by the admin" on public.public_holidays;
drop policy if exists "Admin inserts holidays" on public.public_holidays;
drop policy if exists "Admin updates holidays" on public.public_holidays;
drop policy if exists "Admin deletes holidays" on public.public_holidays;
create policy "Admin inserts holidays" on public.public_holidays for insert to authenticated
  with check ((select public.is_prime_admin()));
create policy "Admin updates holidays" on public.public_holidays for update to authenticated
  using ((select public.is_prime_admin())) with check ((select public.is_prime_admin()));
create policy "Admin deletes holidays" on public.public_holidays for delete to authenticated
  using ((select public.is_prime_admin()));

revoke all on public.public_holidays from anon;
revoke truncate, references, trigger on public.public_holidays from authenticated;

-- Seed: fixed holidays 2024-2028 and 2026 Islamic holidays (approx = pending official announcement)
insert into public.public_holidays (date, name_ar, name_en, approx) values
  ('2024-01-01', 'رأس السنة الميلادية', 'New Year''s Day', false),
  ('2024-02-25', 'العيد الوطني', 'National Day', false),
  ('2024-02-26', 'عيد التحرير', 'Liberation Day', false),
  ('2025-01-01', 'رأس السنة الميلادية', 'New Year''s Day', false),
  ('2025-02-25', 'العيد الوطني', 'National Day', false),
  ('2025-02-26', 'عيد التحرير', 'Liberation Day', false),
  ('2026-01-01', 'رأس السنة الميلادية', 'New Year''s Day', false),
  ('2026-01-18', 'الإسراء والمعراج', 'Isra & Mi''raj', false),
  ('2026-02-25', 'العيد الوطني', 'National Day', false),
  ('2026-02-26', 'عيد التحرير', 'Liberation Day', false),
  ('2026-03-20', 'عيد الفطر', 'Eid al-Fitr', true),
  ('2026-03-21', 'عيد الفطر', 'Eid al-Fitr', true),
  ('2026-03-22', 'عيد الفطر', 'Eid al-Fitr', true),
  ('2026-05-26', 'وقفة عرفة', 'Arafat Day', true),
  ('2026-05-27', 'عيد الأضحى', 'Eid al-Adha', true),
  ('2026-05-28', 'عيد الأضحى', 'Eid al-Adha', true),
  ('2026-05-29', 'عيد الأضحى', 'Eid al-Adha', true),
  ('2026-06-16', 'رأس السنة الهجرية', 'Islamic New Year', true),
  ('2026-08-27', 'المولد النبوي', 'Prophet''s Birthday', true),
  ('2027-01-01', 'رأس السنة الميلادية', 'New Year''s Day', false),
  ('2027-02-25', 'العيد الوطني', 'National Day', false),
  ('2027-02-26', 'عيد التحرير', 'Liberation Day', false),
  ('2028-01-01', 'رأس السنة الميلادية', 'New Year''s Day', false),
  ('2028-02-25', 'العيد الوطني', 'National Day', false),
  ('2028-02-26', 'عيد التحرير', 'Liberation Day', false)
on conflict (date) do nothing;
