-- Blackbird Coffee Hub – brugerdata (kør i Supabase → SQL Editor → New query → Run)
-- Én række pr. bruger og nøgle (tilbud, historik, to-dos, kategorier, TCO, fremgang, favoritter …).

create table if not exists public.user_data (
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  key        text        not null,
  value      jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table public.user_data enable row level security;

drop policy if exists "egen data: laes"    on public.user_data;
drop policy if exists "egen data: opret"   on public.user_data;
drop policy if exists "egen data: ret"     on public.user_data;
drop policy if exists "egen data: slet"    on public.user_data;

create policy "egen data: laes"  on public.user_data for select to authenticated using (auth.uid() = user_id);
create policy "egen data: opret" on public.user_data for insert to authenticated with check (auth.uid() = user_id);
create policy "egen data: ret"   on public.user_data for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "egen data: slet"  on public.user_data for delete to authenticated using (auth.uid() = user_id);

create or replace function public.touch_user_data() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;

drop trigger if exists trg_touch_user_data on public.user_data;
create trigger trg_touch_user_data before update on public.user_data
  for each row execute function public.touch_user_data();

-- Anonyme (ikke-loggede) brugere får ingen adgang
revoke all on public.user_data from anon;
grant select, insert, update, delete on public.user_data to authenticated;
