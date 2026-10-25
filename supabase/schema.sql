create extension if not exists pgcrypto with schema extensions;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique,
  full_name text not null,
  phone text not null default '',
  country text not null default '',
  city text not null default '',
  website text not null default '',
  bio text not null default '',
  role text not null default 'مشتري'
    check (role in ('مشتري', 'مورد', 'مصنع')),
  avatar_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.offers (
  id text primary key default gen_random_uuid()::text,
  owner_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  type text not null,
  price text not null,
  min_order text,
  category text not null,
  countries text[] not null default '{}',
  company_name text not null,
  description text,
  details text,
  features text[] not null default '{}',
  media_paths text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.purchase_requests (
  id text primary key default gen_random_uuid()::text,
  owner_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  status text not null default 'مفتوح'
    check (status in ('مفتوح', 'مغلق')),
  buyer_name text not null,
  contact_person text not null,
  quantity text not null,
  budget text not null,
  country text not null,
  city text not null,
  description text,
  deadline date,
  category text,
  media_paths text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  participant_one uuid not null references public.profiles (id) on delete cascade,
  participant_two uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint chats_distinct_participants check (participant_one <> participant_two),
  constraint chats_canonical_participants check (participant_one < participant_two),
  constraint chats_unique_participants unique (participant_one, participant_two)
);

create table if not exists public.messages (
  id text primary key default gen_random_uuid()::text,
  chat_id uuid not null references public.chats (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  body text not null default '',
  message_type text not null default 'text'
    check (message_type in ('text', 'image', 'video', 'audio')),
  attachment_path text,
  attachment_name text,
  attachment_mime_type text,
  sent_at timestamptz not null default now(),
  deleted_by uuid[] not null default '{}',
  deleted_for_everyone_at timestamptz,
  constraint messages_body_or_attachment
    check (length(body) > 0 or attachment_path is not null)
);

create index if not exists offers_owner_created_idx
  on public.offers (owner_id, created_at desc);
create index if not exists requests_owner_created_idx
  on public.purchase_requests (owner_id, created_at desc);
create index if not exists messages_chat_sent_idx
  on public.messages (chat_id, sent_at desc);
create index if not exists chats_participant_one_idx
  on public.chats (participant_one);
create index if not exists chats_participant_two_idx
  on public.chats (participant_two);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists offers_set_updated_at on public.offers;
create trigger offers_set_updated_at
before update on public.offers
for each row execute function public.set_updated_at();

drop trigger if exists purchase_requests_set_updated_at on public.purchase_requests;
create trigger purchase_requests_set_updated_at
before update on public.purchase_requests
for each row execute function public.set_updated_at();

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (
    id, username, full_name, phone, country, city, website, role
  )
  values (
    new.id,
    lower(trim(new.raw_user_meta_data ->> 'username')),
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), 'مستخدم'),
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    coalesce(new.raw_user_meta_data ->> 'country', ''),
    coalesce(new.raw_user_meta_data ->> 'city', ''),
    coalesce(new.raw_user_meta_data ->> 'website', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'مشتري')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
after insert on auth.users
for each row execute function public.create_profile_for_new_user();

create or replace function public.get_or_create_chat(other_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
  first_user_id uuid;
  second_user_id uuid;
  result_chat_id uuid;
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;
  if other_user_id is null or other_user_id = current_user_id then
    raise exception 'A different chat participant is required';
  end if;

  first_user_id := least(current_user_id, other_user_id);
  second_user_id := greatest(current_user_id, other_user_id);

  insert into public.chats (participant_one, participant_two)
  values (first_user_id, second_user_id)
  on conflict (participant_one, participant_two) do nothing;

  select id into result_chat_id
  from public.chats
  where participant_one = first_user_id and participant_two = second_user_id;

  return result_chat_id;
end;
$$;

revoke all on function public.get_or_create_chat(uuid) from public;
grant execute on function public.get_or_create_chat(uuid) to authenticated;

create or replace function public.set_messages_hidden(
  message_ids text[],
  should_hide boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;

  update public.messages m
  set deleted_by = case
    when should_hide then array_append(m.deleted_by, current_user_id)
    else array_remove(m.deleted_by, current_user_id)
  end
  where m.id = any(message_ids)
    and exists (
      select 1 from public.chats c
      where c.id = m.chat_id
        and (c.participant_one = current_user_id
          or c.participant_two = current_user_id)
    )
    and (
      (should_hide and not (current_user_id = any(m.deleted_by)))
      or (not should_hide and current_user_id = any(m.deleted_by))
    );
end;
$$;

revoke all on function public.set_messages_hidden(text[], boolean) from public;
grant execute on function public.set_messages_hidden(text[], boolean) to authenticated;

create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_current_user() from public;
grant execute on function public.delete_current_user() to authenticated;

create or replace function public.clean_user_storage_before_delete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from storage.objects
  where bucket_id in ('avatars', 'listing-media')
    and (storage.foldername(name))[1] = old.id::text;

  delete from storage.objects
  where bucket_id = 'chat-media'
    and (storage.foldername(name))[1] in (
      select c.id::text
      from public.chats c
      where c.participant_one = old.id or c.participant_two = old.id
    );
  return old;
end;
$$;

drop trigger if exists clean_user_storage_before_delete on auth.users;
create trigger clean_user_storage_before_delete
before delete on auth.users
for each row execute function public.clean_user_storage_before_delete();

alter table public.profiles enable row level security;
alter table public.offers enable row level security;
alter table public.purchase_requests enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;

drop policy if exists "Authenticated users can view profiles" on public.profiles;
create policy "Authenticated users can view profiles"
on public.profiles for select to authenticated using (true);
drop policy if exists "Users can create their profile" on public.profiles;
create policy "Users can create their profile"
on public.profiles for insert to authenticated with check (id = (select auth.uid()));
drop policy if exists "Users can update their profile" on public.profiles;
create policy "Users can update their profile"
on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));

drop policy if exists "Anyone can view offers" on public.offers;
create policy "Anyone can view offers"
on public.offers for select to anon, authenticated using (true);
drop policy if exists "Owners can create offers" on public.offers;
create policy "Owners can create offers"
on public.offers for insert to authenticated
with check (owner_id = (select auth.uid()));
drop policy if exists "Owners can update offers" on public.offers;
create policy "Owners can update offers"
on public.offers for update to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));
drop policy if exists "Owners can delete offers" on public.offers;
create policy "Owners can delete offers"
on public.offers for delete to authenticated
using (owner_id = (select auth.uid()));

drop policy if exists "Anyone can view purchase requests" on public.purchase_requests;
create policy "Anyone can view purchase requests"
on public.purchase_requests for select to anon, authenticated using (true);
drop policy if exists "Owners can create purchase requests" on public.purchase_requests;
create policy "Owners can create purchase requests"
on public.purchase_requests for insert to authenticated
with check (owner_id = (select auth.uid()));
drop policy if exists "Owners can update purchase requests" on public.purchase_requests;
create policy "Owners can update purchase requests"
on public.purchase_requests for update to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));
drop policy if exists "Owners can delete purchase requests" on public.purchase_requests;
create policy "Owners can delete purchase requests"
on public.purchase_requests for delete to authenticated
using (owner_id = (select auth.uid()));

drop policy if exists "Participants can view chats" on public.chats;
create policy "Participants can view chats"
on public.chats for select to authenticated
using (
  (select auth.uid()) = participant_one
  or (select auth.uid()) = participant_two
);
drop policy if exists "Participants can view messages" on public.messages;
create policy "Participants can view messages"
on public.messages for select to authenticated
using (
  exists (
    select 1 from public.chats c
    where c.id = chat_id
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);
drop policy if exists "Participants can send messages as themselves" on public.messages;
create policy "Participants can send messages as themselves"
on public.messages for insert to authenticated
with check (
  sender_id = (select auth.uid())
  and exists (
    select 1 from public.chats c
    where c.id = chat_id
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);
drop policy if exists "Senders can delete their own messages" on public.messages;
create policy "Senders can delete their own messages"
on public.messages for delete to authenticated
using (sender_id = (select auth.uid()));
drop policy if exists "Senders can edit their own messages" on public.messages;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('listing-media', 'listing-media', true, 20971520, array['image/jpeg', 'image/png', 'image/webp']),
  ('chat-media', 'chat-media', false, 20971520, array['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'audio/mp4', 'audio/webm'])
on conflict (id) do nothing;

drop policy if exists "Public avatars are readable" on storage.objects;
create policy "Public avatars are readable"
on storage.objects for select to anon, authenticated
using (bucket_id = 'avatars');
drop policy if exists "Users manage their own avatar files" on storage.objects;
create policy "Users manage their own avatar files"
on storage.objects for all to authenticated
using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Public listing media are readable" on storage.objects;
create policy "Public listing media are readable"
on storage.objects for select to anon, authenticated
using (bucket_id = 'listing-media');
drop policy if exists "Users manage their own listing media" on storage.objects;
create policy "Users manage their own listing media"
on storage.objects for all to authenticated
using (bucket_id = 'listing-media' and (storage.foldername(name))[1] = (select auth.uid())::text)
with check (bucket_id = 'listing-media' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "Chat participants read chat media" on storage.objects;
create policy "Chat participants read chat media"
on storage.objects for select to authenticated
using (
  bucket_id = 'chat-media'
  and exists (
    select 1 from public.chats c
    where c.id::text = (storage.foldername(name))[1]
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);
drop policy if exists "Chat participants upload chat media" on storage.objects;
create policy "Chat participants upload chat media"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'chat-media'
  and exists (
    select 1 from public.chats c
    where c.id::text = (storage.foldername(name))[1]
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);
drop policy if exists "Chat participants update chat media" on storage.objects;
create policy "Chat participants update chat media"
on storage.objects for update to authenticated
using (
  bucket_id = 'chat-media'
  and exists (
    select 1 from public.chats c
    where c.id::text = (storage.foldername(name))[1]
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
)
with check (
  bucket_id = 'chat-media'
  and exists (
    select 1 from public.chats c
    where c.id::text = (storage.foldername(name))[1]
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);
drop policy if exists "Chat participants delete chat media" on storage.objects;
create policy "Chat participants delete chat media"
on storage.objects for delete to authenticated
using (
  bucket_id = 'chat-media'
  and exists (
    select 1 from public.chats c
    where c.id::text = (storage.foldername(name))[1]
      and ((select auth.uid()) = c.participant_one
        or (select auth.uid()) = c.participant_two)
  )
);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end;
$$;
