-- Initial schema for Beauty Closet (claude.md §4).
-- Every user-owned table is protected by RLS: user_id = auth.uid().

-- profiles ------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text,
  gender_expression text,
  body_shape text,
  preferred_fit text[] not null default '{}',
  style_prefs jsonb not null default '{}',
  default_weights jsonb not null default '{"style": 0.4, "fit": 0.3, "trend": 0.3}',
  region text,
  created_at timestamptz not null default now()
);

-- clothing_items ------------------------------------------------------------
create table public.clothing_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  image_path text not null,
  image_cutout_path text,
  category text not null check (category in ('top', 'bottom', 'outer', 'dress', 'shoes', 'bag', 'accessory')),
  subcategory text,
  color_primary text,
  color_secondary text,
  pattern text check (pattern in ('solid', 'stripe', 'check', 'dot', 'floral', 'graphic', 'other')),
  material text,
  seasons text[] not null default '{}',
  formality smallint check (formality between 1 and 5),
  fit text check (fit in ('slim', 'regular', 'oversized')),
  style_tags text[] not null default '{}',
  ai_confidence jsonb,
  user_verified boolean not null default false,
  wear_count integer not null default 0,
  last_worn_at timestamptz,
  archived boolean not null default false,
  created_at timestamptz not null default now()
);
create index clothing_items_user_id_idx on public.clothing_items (user_id);

-- outfits -------------------------------------------------------------------
create table public.outfits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  item_ids uuid[] not null,
  context jsonb not null default '{}',
  weights jsonb not null default '{}',
  score real,
  score_breakdown jsonb,
  explanation text,
  source text not null default 'ai' check (source in ('ai', 'manual')),
  saved boolean not null default false,
  created_at timestamptz not null default now()
);
create index outfits_user_id_idx on public.outfits (user_id, created_at desc);

-- outfit_feedback -----------------------------------------------------------
create table public.outfit_feedback (
  id uuid primary key default gen_random_uuid(),
  outfit_id uuid not null references public.outfits (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  rating smallint not null check (rating in (-1, 1)),
  reasons text[] not null default '{}',
  comment text,
  created_at timestamptz not null default now()
);
create index outfit_feedback_user_id_idx on public.outfit_feedback (user_id);

-- wear_logs -----------------------------------------------------------------
create table public.wear_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  outfit_id uuid references public.outfits (id) on delete set null,
  item_ids uuid[] not null,
  worn_on date not null default current_date
);
create index wear_logs_user_id_idx on public.wear_logs (user_id, worn_on desc);

-- events (user_id nulled on account deletion, §5 M8) ------------------------
create table public.events (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users (id) on delete set null,
  name text not null,
  props jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index events_name_created_at_idx on public.events (name, created_at);

-- RLS -----------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.clothing_items enable row level security;
alter table public.outfits enable row level security;
alter table public.outfit_feedback enable row level security;
alter table public.wear_logs enable row level security;
alter table public.events enable row level security;

create policy "own profile" on public.profiles
  for all to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "own clothing items" on public.clothing_items
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "own outfits" on public.outfits
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "own outfit feedback" on public.outfit_feedback
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "own wear logs" on public.wear_logs
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Events are write-only for users; reading is done server-side with the secret key.
create policy "insert own events" on public.events
  for insert to authenticated
  with check (user_id = (select auth.uid()));

-- Create a profile row when a user signs up -----------------------------------
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Storage: private bucket, path = {user_id}/{item_id}/... ---------------------
insert into storage.buckets (id, name, public)
values ('clothing-images', 'clothing-images', false);

create policy "own clothing images" on storage.objects
  for all to authenticated
  using (
    bucket_id = 'clothing-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'clothing-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
