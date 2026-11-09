-- Rode este script UMA VEZ no Supabase: menu "SQL Editor" > "New query" > colar > "Run".

create table if not exists public.checklist_lojas (
  nome   text primary key,
  criado timestamptz default now()
);

create table if not exists public.checklist_gestores (
  id         text primary key,          -- loja + semana
  loja       text not null,
  semana     text not null,             -- segunda-feira da semana (AAAA-MM-DD)
  dados      jsonb not null default '{}'::jsonb,
  atualizado timestamptz default now()
);
create index if not exists checklist_gestores_semana_idx on public.checklist_gestores (semana);
create index if not exists checklist_gestores_loja_idx   on public.checklist_gestores (loja);

alter table public.checklist_lojas    enable row level security;
alter table public.checklist_gestores enable row level security;

drop policy if exists "ler lojas" on public.checklist_lojas;
drop policy if exists "criar lojas" on public.checklist_lojas;
drop policy if exists "atualizar lojas" on public.checklist_lojas;
create policy "ler lojas"       on public.checklist_lojas for select using (true);
create policy "criar lojas"     on public.checklist_lojas for insert with check (true);
create policy "atualizar lojas" on public.checklist_lojas for update using (true) with check (true);

drop policy if exists "ler checklist" on public.checklist_gestores;
drop policy if exists "criar checklist" on public.checklist_gestores;
drop policy if exists "atualizar checklist" on public.checklist_gestores;
create policy "ler checklist"       on public.checklist_gestores for select using (true);
create policy "criar checklist"     on public.checklist_gestores for insert with check (true);
create policy "atualizar checklist" on public.checklist_gestores for update using (true) with check (true);

insert into public.checklist_lojas (nome) values
  ('Loja Duque de Caxias'), ('Loja Messejana'), ('Loja Montese'), ('Loja Sul')
on conflict do nothing;

-- Atualização automática na tela de todos (tempo real)
alter publication supabase_realtime add table public.checklist_gestores;
alter publication supabase_realtime add table public.checklist_lojas;
