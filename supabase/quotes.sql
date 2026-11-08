-- Blackbird Coffee Hub – tilbudsdatabase
-- Kør i Supabase → SQL Editor → New query → Run.
-- Alle sælgeres Hub kan KUN skrive tilbud ind. Ingen kan læse dem via API'et eller siden.
-- Du læser alt i Supabase → Table Editor (view: quotes_latest = seneste status pr. tilbud).

create table if not exists public.quotes (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  quote_id    text        not null,          -- samme id for ét tilbud, hver statusændring giver en ny række
  quoted_at   timestamptz,                   -- hvornår tilbuddet blev lavet
  seller      text,                          -- sælgerens svar-adresse
  firma       text,
  kontakt     text,
  maskine     text,
  aftale      boolean,                       -- true = kun kaffeaftale
  status      text        not null default 'afventer',
  udloeb      date,
  lang        text,
  opts        jsonb,                         -- priser og perioder pr. mulighed
  snap        jsonb,                         -- alle indstillinger (så tilbuddet kan genskabes)
  constraint quotes_status_chk check (status in ('afventer','accepteret','afslag')),
  constraint quotes_len_chk    check (coalesce(length(firma),0) < 200 and coalesce(length(kontakt),0) < 200
                                      and coalesce(length(maskine),0) < 300 and coalesce(length(seller),0) < 200
                                      and coalesce(length(quote_id),0) < 64),
  constraint quotes_size_chk   check (coalesce(pg_column_size(snap),0) < 300000 and coalesce(pg_column_size(opts),0) < 20000)
);

create index if not exists quotes_quote_idx on public.quotes (quote_id, created_at desc);
create index if not exists quotes_seller_idx on public.quotes (seller);

alter table public.quotes enable row level security;

drop policy if exists "alle maa indsaette" on public.quotes;
create policy "alle maa indsaette" on public.quotes for insert to anon, authenticated with check (true);
-- Ingen select-, update- eller delete-politik → intet kan læses eller ændres via API'et.

revoke all on public.quotes from anon, authenticated;
grant insert on public.quotes to anon, authenticated;

-- Seneste status pr. tilbud (til dig i Table Editor)
create or replace view public.quotes_latest with (security_invoker = true) as
  select distinct on (quote_id) *
  from public.quotes
  order by quote_id, created_at desc, id desc;

revoke all on public.quotes_latest from anon, authenticated;
