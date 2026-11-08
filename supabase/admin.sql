-- Admin-adgang: kun lb@blackbirdcoffee.dk kan LÆSE alle tilbud.
-- Kør i Supabase → SQL Editor. Brugeren skal findes under Authentication → Users (opret den med "Add user → Create new user", sæt adgangskode og vælg Auto Confirm).
drop policy if exists "admin laeser" on public.quotes;
create policy "admin laeser" on public.quotes for select to authenticated
  using ((auth.jwt() ->> 'email') = 'lb@blackbirdcoffee.dk');
grant select on public.quotes to authenticated;
grant select on public.quotes_latest to authenticated;
