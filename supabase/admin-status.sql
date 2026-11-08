-- Admin: status pr. sag (kunde) – kun lb@blackbirdcoffee.dk kan læse og skrive.
-- Kør i Supabase → SQL Editor → New query → Run. Kan køres flere gange uden skade.
create table if not exists public.quote_admin (
  sag_key    text primary key,                 -- normaliseret firmanavn (samler flere versioner til én sag)
  status     text not null default 'sendt',
  updated_at timestamptz not null default now(),
  constraint quote_admin_status_chk check (status in ('sendt','fulgt_op','vundet','tabt')),
  constraint quote_admin_len_chk check (length(sag_key) < 200)
);

alter table public.quote_admin enable row level security;

drop policy if exists "admin laeser status" on public.quote_admin;
create policy "admin laeser status" on public.quote_admin for select to authenticated
  using ((auth.jwt() ->> 'email') = 'lb@blackbirdcoffee.dk');

drop policy if exists "admin indsaetter status" on public.quote_admin;
create policy "admin indsaetter status" on public.quote_admin for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'lb@blackbirdcoffee.dk');

drop policy if exists "admin opdaterer status" on public.quote_admin;
create policy "admin opdaterer status" on public.quote_admin for update to authenticated
  using ((auth.jwt() ->> 'email') = 'lb@blackbirdcoffee.dk')
  with check ((auth.jwt() ->> 'email') = 'lb@blackbirdcoffee.dk');

revoke all on public.quote_admin from anon, authenticated;
grant select, insert, update on public.quote_admin to authenticated;
