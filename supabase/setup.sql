-- Create a table for users
create table public.users (
  uid uuid references auth.users not null primary key,
  name text not null,
  email text not null,
  role text not null default 'patient',
  phone text,
  "photoUrl" text,
  "createdAt" timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Set up Row Level Security (RLS)
alter table public.users enable row level security;

-- Create policies
create policy "Users can view their own profile."
  on public.users for select
  using ( auth.uid() = uid );

create policy "Users can update their own profile."
  on public.users for update
  using ( auth.uid() = uid );

create policy "Users can insert their own profile."
  on public.users for insert
  with check ( auth.uid() = uid );
