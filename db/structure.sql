--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: catalogs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE catalogs (
    id integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    comment character varying DEFAULT ''::character varying NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    ipaddress character varying DEFAULT ''::character varying NOT NULL,
    forwarded character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    sessionid character varying DEFAULT ''::character varying NOT NULL,
    length integer DEFAULT 0 NOT NULL,
    revision character varying DEFAULT ''::character varying NOT NULL,
    parent_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: catalogs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE catalogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE catalogs_id_seq OWNED BY catalogs.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    gid integer DEFAULT 0 NOT NULL,
    tid integer DEFAULT 0 NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    keyword character varying DEFAULT ''::character varying NOT NULL,
    comment character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE histories (
    id integer NOT NULL,
    playedtime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    track_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE histories_id_seq OWNED BY histories.id;


--
-- Name: image_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE image_comments (
    id integer NOT NULL,
    image_id integer DEFAULT 0 NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: image_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE image_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE image_comments_id_seq OWNED BY image_comments.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE images (
    id integer NOT NULL,
    track_id integer DEFAULT 0 NOT NULL,
    url character varying DEFAULT ''::character varying NOT NULL,
    source character varying DEFAULT ''::character varying NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    illustrator character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    image_comments_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_id_seq OWNED BY images.id;


--
-- Name: issue_replies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issue_replies (
    id integer NOT NULL,
    dateline timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    issue_id integer DEFAULT 0 NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: issue_replies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issue_replies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issue_replies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issue_replies_id_seq OWNED BY issue_replies.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issues (
    id integer NOT NULL,
    dateline timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    typeid character varying DEFAULT ''::character varying NOT NULL,
    subject character varying DEFAULT ''::character varying NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    issue_replies_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;


--
-- Name: lyrics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lyrics (
    id integer NOT NULL,
    track_id integer DEFAULT 0 NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lyrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lyrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lyrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lyrics_id_seq OWNED BY lyrics.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL,
    password character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    lastact timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: notices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    dateline character varying DEFAULT ''::character varying NOT NULL,
    subject character varying DEFAULT ''::character varying NOT NULL,
    message character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: playlist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE playlist (
    id integer NOT NULL,
    playedtime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    track_id integer DEFAULT 0 NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    aliasip character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: playlist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE playlist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: playlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE playlist_id_seq OWNED BY playlist.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: track_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE track_comments (
    id integer NOT NULL,
    track_id integer DEFAULT 0 NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: track_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE track_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: track_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE track_comments_id_seq OWNED BY track_comments.id;


--
-- Name: track_migration_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE track_migration_comments (
    id integer NOT NULL,
    track_migration_id integer DEFAULT 0 NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    nickname character varying DEFAULT ''::character varying NOT NULL,
    useragent character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    rate integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: track_migration_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE track_migration_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: track_migration_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE track_migration_comments_id_seq OWNED BY track_migration_comments.id;


--
-- Name: track_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE track_migrations (
    id integer NOT NULL,
    number integer DEFAULT 0 NOT NULL,
    szhash character varying DEFAULT ''::character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    tags character varying DEFAULT ''::character varying NOT NULL,
    artist character varying DEFAULT ''::character varying NOT NULL,
    album character varying DEFAULT ''::character varying NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    cooldown_time integer DEFAULT 0 NOT NULL,
    mtime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    nexttime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    label character varying DEFAULT ''::character varying NOT NULL,
    asin character varying DEFAULT ''::character varying NOT NULL,
    niconico character varying DEFAULT ''::character varying NOT NULL,
    album_cover character varying DEFAULT ''::character varying NOT NULL,
    release_date character varying DEFAULT ''::character varying NOT NULL,
    detail_page_url character varying DEFAULT ''::character varying NOT NULL,
    uploader character varying DEFAULT ''::character varying NOT NULL,
    source_format character varying DEFAULT ''::character varying NOT NULL,
    source_bitrate character varying DEFAULT ''::character varying NOT NULL,
    source_bitrate_type character varying DEFAULT ''::character varying NOT NULL,
    source_frequency character varying DEFAULT ''::character varying NOT NULL,
    source_channels character varying DEFAULT ''::character varying NOT NULL,
    action character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    committed boolean DEFAULT false NOT NULL,
    track_migration_comments_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: track_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE track_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: track_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE track_migrations_id_seq OWNED BY track_migrations.id;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tracks (
    id integer NOT NULL,
    number integer DEFAULT 0 NOT NULL,
    szhash character varying DEFAULT ''::character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    tags character varying DEFAULT ''::character varying NOT NULL,
    artist character varying DEFAULT ''::character varying NOT NULL,
    album character varying DEFAULT ''::character varying NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    cooldown_time integer DEFAULT 0 NOT NULL,
    mtime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    nexttime timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    label character varying DEFAULT ''::character varying NOT NULL,
    asin character varying DEFAULT ''::character varying NOT NULL,
    niconico character varying DEFAULT ''::character varying NOT NULL,
    album_cover character varying DEFAULT ''::character varying NOT NULL,
    release_date character varying DEFAULT ''::character varying NOT NULL,
    detail_page_url character varying DEFAULT ''::character varying NOT NULL,
    uploader character varying DEFAULT ''::character varying NOT NULL,
    source_format character varying DEFAULT ''::character varying NOT NULL,
    source_bitrate character varying DEFAULT ''::character varying NOT NULL,
    source_bitrate_type character varying DEFAULT ''::character varying NOT NULL,
    source_frequency character varying DEFAULT ''::character varying NOT NULL,
    source_channels character varying DEFAULT ''::character varying NOT NULL,
    userip character varying DEFAULT ''::character varying NOT NULL,
    status character varying DEFAULT ''::character varying NOT NULL,
    identity character varying DEFAULT ''::character varying NOT NULL,
    legacy boolean DEFAULT false NOT NULL,
    images_count integer DEFAULT 0 NOT NULL,
    track_comments_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tracks_id_seq OWNED BY tracks.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalogs ALTER COLUMN id SET DEFAULT nextval('catalogs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY histories ALTER COLUMN id SET DEFAULT nextval('histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY image_comments ALTER COLUMN id SET DEFAULT nextval('image_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_replies ALTER COLUMN id SET DEFAULT nextval('issue_replies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lyrics ALTER COLUMN id SET DEFAULT nextval('lyrics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY playlist ALTER COLUMN id SET DEFAULT nextval('playlist_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY track_comments ALTER COLUMN id SET DEFAULT nextval('track_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY track_migration_comments ALTER COLUMN id SET DEFAULT nextval('track_migration_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY track_migrations ALTER COLUMN id SET DEFAULT nextval('track_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracks ALTER COLUMN id SET DEFAULT nextval('tracks_id_seq'::regclass);


--
-- Name: catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY catalogs
    ADD CONSTRAINT catalogs_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY histories
    ADD CONSTRAINT histories_pkey PRIMARY KEY (id);


--
-- Name: image_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY image_comments
    ADD CONSTRAINT image_comments_pkey PRIMARY KEY (id);


--
-- Name: images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: issue_replies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issue_replies
    ADD CONSTRAINT issue_replies_pkey PRIMARY KEY (id);


--
-- Name: issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: lyrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lyrics
    ADD CONSTRAINT lyrics_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (id);


--
-- Name: track_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track_comments
    ADD CONSTRAINT track_comments_pkey PRIMARY KEY (id);


--
-- Name: track_migration_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track_migration_comments
    ADD CONSTRAINT track_migration_comments_pkey PRIMARY KEY (id);


--
-- Name: track_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track_migrations
    ADD CONSTRAINT track_migrations_pkey PRIMARY KEY (id);


--
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);


--
-- Name: index_histories_on_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_histories_on_track_id ON histories USING btree (track_id);


--
-- Name: index_image_comments_on_image_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_image_comments_on_image_id ON image_comments USING btree (image_id);


--
-- Name: index_images_on_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_images_on_track_id ON images USING btree (track_id);


--
-- Name: index_issue_replies_on_issue_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_issue_replies_on_issue_id ON issue_replies USING btree (issue_id);


--
-- Name: index_members_on_identity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_identity ON members USING btree (identity);


--
-- Name: index_playlist_on_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_playlist_on_track_id ON playlist USING btree (track_id);


--
-- Name: index_track_comments_on_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_track_comments_on_track_id ON track_comments USING btree (track_id);


--
-- Name: index_track_migration_comments_on_track_migration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_track_migration_comments_on_track_migration_id ON track_migration_comments USING btree (track_migration_id);


--
-- Name: index_track_migrations_on_szhash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_track_migrations_on_szhash ON track_migrations USING btree (szhash);


--
-- Name: index_tracks_on_szhash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tracks_on_szhash ON tracks USING btree (szhash);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20131027125613');

INSERT INTO schema_migrations (version) VALUES ('20131208195954');

INSERT INTO schema_migrations (version) VALUES ('20131208200419');

INSERT INTO schema_migrations (version) VALUES ('20131208200506');

INSERT INTO schema_migrations (version) VALUES ('20140107142605');

INSERT INTO schema_migrations (version) VALUES ('20140219125257');

INSERT INTO schema_migrations (version) VALUES ('20140221122846');

INSERT INTO schema_migrations (version) VALUES ('20140408124712');

INSERT INTO schema_migrations (version) VALUES ('20140507180226');

INSERT INTO schema_migrations (version) VALUES ('20140802135623');

INSERT INTO schema_migrations (version) VALUES ('20140912032244');

INSERT INTO schema_migrations (version) VALUES ('20141017143708');

INSERT INTO schema_migrations (version) VALUES ('20141017143741');

INSERT INTO schema_migrations (version) VALUES ('20141021150831');

INSERT INTO schema_migrations (version) VALUES ('20150810142823');

