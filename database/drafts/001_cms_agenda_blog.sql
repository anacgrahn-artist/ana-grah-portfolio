-- Ana Grah: primeira estrutura do CMS (Supabase/PostgreSQL).
-- RASCUNHO: revisar e executar somente após confirmar o backend do site.
create extension if not exists pgcrypto;

create table if not exists public.site_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_site_admin()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.site_admins where user_id = (select auth.uid())); $$;

create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text not null,
  summary text,
  body text,
  cover_image_url text,
  media jsonb not null default '[]'::jsonb,
  project_year integer,
  featured boolean not null default false,
  published boolean not null default false,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.agenda_events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  kind text not null default 'evento',
  description text,
  location text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  capacity integer check (capacity is null or capacity >= 0),
  registration_open boolean not null default false,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.blog_posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  excerpt text,
  content text not null default '',
  cover_image_url text,
  tags text[] not null default '{}',
  published boolean not null default false,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.contact_requests (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  subject text not null,
  message text not null,
  status text not null default 'novo' check(status in ('novo','em_atendimento','concluido','arquivado')),
  privacy_accepted boolean not null default false check(privacy_accepted),
  created_at timestamptz not null default now()
);

create table if not exists public.event_registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.agenda_events(id) on delete cascade,
  name text not null,
  email text not null,
  phone text,
  privacy_accepted boolean not null default false check(privacy_accepted),
  status text not null default 'recebida',
  created_at timestamptz not null default now(),
  unique(event_id, email)
);

create index if not exists idx_portfolio_published on public.portfolio_projects(published, project_year desc);
create index if not exists idx_agenda_published_start on public.agenda_events(published, starts_at);
create index if not exists idx_blog_published_date on public.blog_posts(published, published_at desc);
create index if not exists idx_requests_status on public.contact_requests(status, created_at desc);

alter table public.site_admins enable row level security;
alter table public.portfolio_projects enable row level security;
alter table public.agenda_events enable row level security;
alter table public.blog_posts enable row level security;
alter table public.contact_requests enable row level security;
alter table public.event_registrations enable row level security;

create policy "admin list" on public.site_admins for select to authenticated using (public.is_site_admin());

create policy "public published portfolio" on public.portfolio_projects for select to anon, authenticated using (published or public.is_site_admin());
create policy "admins manage portfolio" on public.portfolio_projects for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create policy "public published agenda" on public.agenda_events for select to anon, authenticated using (published or public.is_site_admin());
create policy "admins manage agenda" on public.agenda_events for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create policy "public published blog" on public.blog_posts for select to anon, authenticated using (published or public.is_site_admin());
create policy "admins manage blog" on public.blog_posts for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create policy "public submit requests" on public.contact_requests for insert to anon, authenticated with check (status='novo' and privacy_accepted);
create policy "admins manage requests" on public.contact_requests for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create policy "public register events" on public.event_registrations for insert to anon, authenticated
with check (privacy_accepted and status='recebida' and exists
  (select 1 from public.agenda_events e where e.id=event_id and e.published and e.registration_open));
create policy "admins manage registrations" on public.event_registrations for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

-- A criação do primeiro administrador deve ser feita manualmente no SQL Editor
-- após autenticação e validação da identidade. Nunca exponha service_role no navegador.
-- Para uso em produção, proteger formulários com CAPTCHA, rate limiting e anti-spam
-- via endpoint validado; não depender apenas da política de INSERT.
