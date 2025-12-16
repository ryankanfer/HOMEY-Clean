-- Create early_access_codes table
create table if not exists public.early_access_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  uses_count integer default 0,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.early_access_codes enable row level security;

-- Policy: Anyone can read active codes (for validation)
create policy "Anyone can read active codes"
  on public.early_access_codes
  for select
  using (is_active = true);

-- Policy: Only authenticated users can update (increment counter)
create policy "Authenticated users can update codes"
  on public.early_access_codes
  for update
  using (auth.role() = 'authenticated');

-- Insert the initial code
insert into public.early_access_codes (code, is_active)
values ('ONLYHOMEYS', true)
on conflict (code) do nothing;

-- Function to validate and increment code usage
create or replace function public.validate_early_access_code(access_code text)
returns json
language plpgsql
security definer
as $$
declare
  code_record record;
  result json;
begin
  -- Find the code (case insensitive)
  select * into code_record
  from public.early_access_codes
  where upper(code) = upper(access_code)
    and is_active = true;

  if code_record is null then
    return json_build_object(
      'valid', false,
      'message', 'Invalid access code'
    );
  end if;

  -- Increment usage count
  update public.early_access_codes
  set
    uses_count = uses_count + 1,
    updated_at = now()
  where id = code_record.id;

  return json_build_object(
    'valid', true,
    'code_id', code_record.id,
    'uses_count', code_record.uses_count + 1
  );
end;
$$;
