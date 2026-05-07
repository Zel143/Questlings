-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.classes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  special_ability text,
  stat_buff text,
  CONSTRAINT classes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.community_challenges (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,
  description text,
  target_category character varying,
  reward_questling_id uuid,
  start_date timestamp with time zone DEFAULT now(),
  end_date timestamp with time zone,
  CONSTRAINT community_challenges_pkey PRIMARY KEY (id),
  CONSTRAINT community_challenges_reward_questling_id_fkey FOREIGN KEY (reward_questling_id) REFERENCES public.questling_dictionary(id)
);
CREATE TABLE public.habit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  habit_id uuid NOT NULL,
  completed_at timestamp with time zone DEFAULT now(),
  energy_generated integer DEFAULT 0,
  stardust_earned integer DEFAULT 0,
  xp_earned integer DEFAULT 0,
  equipped_bonus_applied boolean DEFAULT false,
  CONSTRAINT habit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT habit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT habit_logs_habit_id_fkey FOREIGN KEY (habit_id) REFERENCES public.habits(id)
);
CREATE TABLE public.habits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name character varying NOT NULL,
  category character varying NOT NULL,
  difficulty USER-DEFINED DEFAULT 'Medium'::habit_difficulty,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT habits_pkey PRIMARY KEY (id),
  CONSTRAINT habits_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  type USER-DEFINED NOT NULL,
  cost integer NOT NULL DEFAULT 0,
  description text,
  CONSTRAINT items_pkey PRIMARY KEY (id)
);
CREATE TABLE public.missions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  habit_id uuid NOT NULL,
  target_questling_id uuid,
  target_days integer NOT NULL DEFAULT 3,
  current_streak integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT missions_pkey PRIMARY KEY (id),
  CONSTRAINT missions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT missions_habit_id_fkey FOREIGN KEY (habit_id) REFERENCES public.habits(id),
  CONSTRAINT missions_target_questling_id_fkey FOREIGN KEY (target_questling_id) REFERENCES public.questling_dictionary(id)
);
CREATE TABLE public.parties (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT parties_pkey PRIMARY KEY (id)
);
CREATE TABLE public.party_goals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  party_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  name character varying NOT NULL,
  target_energy integer NOT NULL,
  current_energy integer DEFAULT 0,
  start_date timestamp with time zone DEFAULT now(),
  end_date timestamp with time zone NOT NULL,
  is_completed boolean DEFAULT false,
  CONSTRAINT party_goals_pkey PRIMARY KEY (id),
  CONSTRAINT party_goals_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id)
);
CREATE TABLE public.party_members (
  user_id uuid NOT NULL,
  party_id uuid NOT NULL,
  weekly_energy_contribution integer DEFAULT 0,
  CONSTRAINT party_members_pkey PRIMARY KEY (user_id, party_id),
  CONSTRAINT party_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT party_members_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id)
);
CREATE TABLE public.questling_dictionary (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  elemental_type character varying NOT NULL,
  description text,
  base_hatch_days integer DEFAULT 3,
  CONSTRAINT questling_dictionary_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  item_id uuid NOT NULL,
  is_equipped boolean DEFAULT false,
  quantity integer DEFAULT 1,
  CONSTRAINT user_items_pkey PRIMARY KEY (id),
  CONSTRAINT user_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id)
);
CREATE TABLE public.user_questlings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  questling_id uuid NOT NULL,
  status USER-DEFINED DEFAULT 'Healthy'::questling_status,
  level integer DEFAULT 1,
  habit_born_from uuid,
  obtained_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_questlings_pkey PRIMARY KEY (id),
  CONSTRAINT user_questlings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_questlings_questling_id_fkey FOREIGN KEY (questling_id) REFERENCES public.questling_dictionary(id),
  CONSTRAINT fk_habit_born_from FOREIGN KEY (habit_born_from) REFERENCES public.habits(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  username character varying NOT NULL UNIQUE,
  level integer DEFAULT 1,
  xp integer DEFAULT 0,
  stardust integer DEFAULT 0,
  class_id uuid,
  party_id uuid,
  equipped_questling_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT users_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id),
  CONSTRAINT users_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id),
  CONSTRAINT fk_equipped_questling FOREIGN KEY (equipped_questling_id) REFERENCES public.user_questlings(id)
);