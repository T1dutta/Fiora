-- InsForge: PostgreSQL tables aligned with Fiora domain models.
-- InsForge exposes CRUD via record APIs; wire Row Level Security to the authenticated user id from JWT.
-- Replace user_id columns with your project's user identifier type if it differs from uuid.

CREATE TABLE IF NOT EXISTS public.fiora_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL UNIQUE,
    name text,
    age int,
    cycle_length int,
    avg_period_length int,
    known_conditions jsonb DEFAULT '[]'::jsonb,
    emergency_contact text,
    bio text,
    partners jsonb NOT NULL DEFAULT '[]'::jsonb,
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.fiora_period_entries (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date,
    flow text,
    flow_intensity text,
    symptoms text[] DEFAULT '{}',
    pain_level int,
    notes text,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS fiora_period_user_start ON public.fiora_period_entries (user_id, start_date DESC);

CREATE TABLE IF NOT EXISTS public.fiora_cycle_predictions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    generated_at timestamptz DEFAULT now(),
    next_period_start date,
    estimated_cycle_length_days numeric,
    confidence numeric,
    method text,
    extra jsonb
);

CREATE TABLE IF NOT EXISTS public.fiora_wearable_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    source text NOT NULL,
    metric_type text NOT NULL,
    value double precision NOT NULL,
    unit text,
    recorded_at timestamptz NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    ingested_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS fiora_wearable_user_time ON public.fiora_wearable_events (user_id, recorded_at DESC);

CREATE TABLE IF NOT EXISTS public.fiora_health_analyses (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    created_at timestamptz DEFAULT now(),
    input_summary jsonb,
    result jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS public.fiora_education_generations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    topic text NOT NULL,
    difficulty text,
    question_count int,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.fiora_education_progress (
    user_id uuid NOT NULL,
    topic_id text NOT NULL,
    completed boolean DEFAULT false,
    updated_at timestamptz DEFAULT now(),
    PRIMARY KEY (user_id, topic_id)
);

CREATE TABLE IF NOT EXISTS public.fiora_points_ledger (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    delta int NOT NULL,
    reason text NOT NULL,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS fiora_points_user_time ON public.fiora_points_ledger (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.fiora_alerts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    type text NOT NULL,
    message text NOT NULL,
    detail_reason text,
    created_at timestamptz DEFAULT now(),
    status text NOT NULL DEFAULT 'unread'
);

CREATE INDEX IF NOT EXISTS fiora_alerts_user_time ON public.fiora_alerts (user_id, created_at DESC);
