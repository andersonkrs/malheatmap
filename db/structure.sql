SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: item_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.item_kind AS ENUM (
    'anime',
    'manga'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    item_id uuid NOT NULL,
    date date NOT NULL,
    amount integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    amount integer NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    item_id uuid NOT NULL
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    mal_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    kind public.item_kind NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    processed boolean DEFAULT false NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username character varying NOT NULL,
    avatar_url character varying,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_activities_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_item_id ON public.activities USING btree (item_id);


--
-- Name: index_activities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_user_id ON public.activities USING btree (user_id);


--
-- Name: index_activities_on_user_id_and_item_id_and_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_activities_on_user_id_and_item_id_and_date ON public.activities USING btree (user_id, item_id, date);


--
-- Name: index_entries_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_item_id ON public.entries USING btree (item_id);


--
-- Name: index_entries_on_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_timestamp ON public.entries USING btree ("timestamp");


--
-- Name: index_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_user_id ON public.entries USING btree (user_id);


--
-- Name: index_items_on_mal_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_on_mal_id_and_kind ON public.items USING btree (mal_id, kind);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: activities fk_rails_7e11bb717f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_7e11bb717f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: activities fk_rails_98c29480fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_98c29480fc FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: entries fk_rails_99dc12d4fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT fk_rails_99dc12d4fd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: entries fk_rails_dfa0a673ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT fk_rails_dfa0a673ee FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200201115222'),
('20200201115644'),
('20200201120036'),
('20200202023458'),
('20200229234332'),
('20200301000733'),
('20200306152120'),
('20200328040329'),
('20200328041327'),
('20200328162236'),
('20200328164202'),
('20200328164518'),
('20200329040026'),
('20200329145233'),
('20200404024047'),
('20200603022918');


