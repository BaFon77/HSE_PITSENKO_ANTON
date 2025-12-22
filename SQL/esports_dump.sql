--
-- PostgreSQL database dump
--

\restrict 5LBGIYIWhBFGiauP8PbjfxxhrJOX0byFQZFXLXcr8R3g9daMgUcEigbZWS3WiAf

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: best_player_tournament(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.best_player_tournament(p_tournament_id integer) RETURNS TABLE(player_name text, nickname character varying, total_points bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.full_name, p.nickname, SUM(ps.points) AS total_points
    FROM player_game_stats ps
    JOIN player p ON p.player_id = ps.player_id
    JOIN match_game mg ON mg.game_id = ps.game_id
    JOIN match m ON m.match_id = mg.match_id
    WHERE m.tournament_id = p_tournament_id
    GROUP BY p.player_id
    ORDER BY total_points DESC
    LIMIT 1;
END;
$$;


ALTER FUNCTION public.best_player_tournament(p_tournament_id integer) OWNER TO postgres;

--
-- Name: get_player_stats(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_stats(p_player_id integer) RETURNS TABLE(total_points bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(points), 0)
    FROM player_game_stats
    WHERE player_id = p_player_id;
END;
$$;


ALTER FUNCTION public.get_player_stats(p_player_id integer) OWNER TO postgres;

--
-- Name: update_player_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_player_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO player_rating_history(player_id, previous_rating, new_rating)
    SELECT p.player_id, p.rating, p.rating + NEW.points
    FROM player p
    WHERE p.player_id = NEW.player_id;

    UPDATE player
    SET rating = rating + NEW.points
    WHERE player_id = NEW.player_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_player_rating() OWNER TO postgres;

--
-- Name: update_team_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_team_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.winner_team_id IS NOT NULL THEN
        INSERT INTO team_rating_history(team_id, previous_rating, new_rating)
        SELECT t.team_id, t.team_rating, t.team_rating + 10
        FROM team t
        WHERE t.team_id = NEW.winner_team_id;

        UPDATE team
        SET team_rating = team_rating + 10
        WHERE team_id = NEW.winner_team_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_team_rating() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: discipline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discipline (
    discipline_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.discipline OWNER TO postgres;

--
-- Name: discipline_discipline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.discipline_discipline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.discipline_discipline_id_seq OWNER TO postgres;

--
-- Name: discipline_discipline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.discipline_discipline_id_seq OWNED BY public.discipline.discipline_id;


--
-- Name: match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match (
    match_id integer NOT NULL,
    tournament_id integer,
    team1_id integer,
    team2_id integer,
    stage character varying(50),
    winner_team_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone
);


ALTER TABLE public.match OWNER TO postgres;

--
-- Name: match_game; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_game (
    game_id integer NOT NULL,
    match_id integer,
    game_number integer NOT NULL,
    map_name character varying(50) NOT NULL,
    team1_score integer,
    team2_score integer,
    winner_team_id integer
);


ALTER TABLE public.match_game OWNER TO postgres;

--
-- Name: match_game_game_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.match_game_game_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.match_game_game_id_seq OWNER TO postgres;

--
-- Name: match_game_game_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.match_game_game_id_seq OWNED BY public.match_game.game_id;


--
-- Name: match_match_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.match_match_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.match_match_id_seq OWNER TO postgres;

--
-- Name: match_match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.match_match_id_seq OWNED BY public.match.match_id;


--
-- Name: player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player (
    player_id integer NOT NULL,
    full_name text NOT NULL,
    nickname character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    game_account text,
    level integer,
    rating integer DEFAULT 1000,
    CONSTRAINT player_level_check CHECK ((level >= 0))
);


ALTER TABLE public.player OWNER TO postgres;

--
-- Name: player_game_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_game_stats (
    game_id integer NOT NULL,
    player_id integer NOT NULL,
    kills integer DEFAULT 0,
    assists integer DEFAULT 0,
    damage integer DEFAULT 0,
    points integer DEFAULT 0
);


ALTER TABLE public.player_game_stats OWNER TO postgres;

--
-- Name: player_player_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_player_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_player_id_seq OWNER TO postgres;

--
-- Name: player_player_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_player_id_seq OWNED BY public.player.player_id;


--
-- Name: player_rating_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_rating_history (
    history_id integer NOT NULL,
    player_id integer,
    previous_rating integer,
    new_rating integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.player_rating_history OWNER TO postgres;

--
-- Name: player_rating_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_rating_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_rating_history_history_id_seq OWNER TO postgres;

--
-- Name: player_rating_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_rating_history_history_id_seq OWNED BY public.player_rating_history.history_id;


--
-- Name: prize; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prize (
    prize_id integer NOT NULL,
    tournament_id integer,
    prize_type character varying(20),
    description text,
    amount integer,
    place integer
);


ALTER TABLE public.prize OWNER TO postgres;

--
-- Name: prize_prize_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prize_prize_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prize_prize_id_seq OWNER TO postgres;

--
-- Name: prize_prize_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prize_prize_id_seq OWNED BY public.prize.prize_id;


--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    team_id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at date NOT NULL,
    team_rating integer DEFAULT 1000
);


ALTER TABLE public.team OWNER TO postgres;

--
-- Name: team_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_member (
    team_id integer NOT NULL,
    player_id integer NOT NULL,
    role character varying(20),
    date_from date NOT NULL,
    date_to date,
    CONSTRAINT team_member_role_check CHECK (((role)::text = ANY ((ARRAY['капитан'::character varying, 'основной'::character varying, 'запасной'::character varying, 'тренер'::character varying])::text[])))
);


ALTER TABLE public.team_member OWNER TO postgres;

--
-- Name: team_rating_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_rating_history (
    history_id integer NOT NULL,
    team_id integer,
    previous_rating integer,
    new_rating integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.team_rating_history OWNER TO postgres;

--
-- Name: team_rating_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_rating_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_rating_history_history_id_seq OWNER TO postgres;

--
-- Name: team_rating_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_rating_history_history_id_seq OWNED BY public.team_rating_history.history_id;


--
-- Name: team_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_team_id_seq OWNER TO postgres;

--
-- Name: team_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_team_id_seq OWNED BY public.team.team_id;


--
-- Name: tournament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament (
    tournament_id integer NOT NULL,
    name character varying(100) NOT NULL,
    discipline_id integer,
    start_date date NOT NULL,
    end_date date NOT NULL,
    format character varying(20),
    max_participants integer,
    prize_pool integer
);


ALTER TABLE public.tournament OWNER TO postgres;

--
-- Name: tournament_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_registration (
    registration_id integer NOT NULL,
    tournament_id integer,
    team_id integer,
    registered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tournament_registration OWNER TO postgres;

--
-- Name: tournament_registration_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_registration_registration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_registration_registration_id_seq OWNER TO postgres;

--
-- Name: tournament_registration_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_registration_registration_id_seq OWNED BY public.tournament_registration.registration_id;


--
-- Name: tournament_tournament_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_tournament_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_tournament_id_seq OWNER TO postgres;

--
-- Name: tournament_tournament_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_tournament_id_seq OWNED BY public.tournament.tournament_id;


--
-- Name: discipline discipline_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline ALTER COLUMN discipline_id SET DEFAULT nextval('public.discipline_discipline_id_seq'::regclass);


--
-- Name: match match_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match ALTER COLUMN match_id SET DEFAULT nextval('public.match_match_id_seq'::regclass);


--
-- Name: match_game game_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_game ALTER COLUMN game_id SET DEFAULT nextval('public.match_game_game_id_seq'::regclass);


--
-- Name: player player_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player ALTER COLUMN player_id SET DEFAULT nextval('public.player_player_id_seq'::regclass);


--
-- Name: player_rating_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_rating_history ALTER COLUMN history_id SET DEFAULT nextval('public.player_rating_history_history_id_seq'::regclass);


--
-- Name: prize prize_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prize ALTER COLUMN prize_id SET DEFAULT nextval('public.prize_prize_id_seq'::regclass);


--
-- Name: team team_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team ALTER COLUMN team_id SET DEFAULT nextval('public.team_team_id_seq'::regclass);


--
-- Name: team_rating_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_rating_history ALTER COLUMN history_id SET DEFAULT nextval('public.team_rating_history_history_id_seq'::regclass);


--
-- Name: tournament tournament_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament ALTER COLUMN tournament_id SET DEFAULT nextval('public.tournament_tournament_id_seq'::regclass);


--
-- Name: tournament_registration registration_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_registration ALTER COLUMN registration_id SET DEFAULT nextval('public.tournament_registration_registration_id_seq'::regclass);


--
-- Data for Name: discipline; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline (discipline_id, name) FROM stdin;
1	CS2
2	Dota2
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match (match_id, tournament_id, team1_id, team2_id, stage, winner_team_id, start_time, end_time) FROM stdin;
1	1	1	2	Group	2	2025-12-01 18:00:00	2025-12-01 20:30:00
2	1	3	4	Group	3	2025-12-01 21:00:00	2025-12-01 23:30:00
3	1	1	3	Group	1	2025-12-02 18:00:00	2025-12-02 20:30:00
4	1	2	4	Group	2	2025-12-02 21:00:00	2025-12-02 23:30:00
5	1	1	2	Group	2	2025-12-01 18:00:00	2025-12-01 20:30:00
6	1	3	4	Group	3	2025-12-01 21:00:00	2025-12-01 23:30:00
7	1	1	3	Group	1	2025-12-02 18:00:00	2025-12-02 20:30:00
8	1	2	4	Group	2	2025-12-02 21:00:00	2025-12-02 23:30:00
\.


--
-- Data for Name: match_game; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match_game (game_id, match_id, game_number, map_name, team1_score, team2_score, winner_team_id) FROM stdin;
1	1	1	Dust2	8	13	2
2	2	1	Inferno	13	11	3
3	3	1	Mirage	13	10	1
4	4	1	Ancient	13	7	2
\.


--
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player (player_id, full_name, nickname, email, game_account, level, rating) FROM stdin;
11	Finn Andersen	karrigan	karrigan@cs2mail.com	karrigan_steam	9	1870
12	Havard Nygaard	rain	rain@cs2mail.com	rain_steam	8	1800
13	David Cernansky	frozen	frozen@cs2mail.com	frozen_steam	8	1770
14	Helvijs Saukants	broky	broky@cs2mail.com	broky_steam	9	1900
15	Jonathan Jablonowski	EliGE	elige@cs2mail.com	EliGE_steam	10	1930
16	Ludvig Brolin	Brollan	brollan@cs2mail.com	Brollan_steam	8	1800
17	Adam Torzsas	torzsi	torzsi@cs2mail.com	torzsi_steam	8	1750
18	Dorian Berman	xertioN	xertioN@cs2mail.com	xertioN_steam	8	1780
19	Jimi Salo	Jimpphat	jimpphat@cs2mail.com	Jimpphat_steam	7	1700
20	Lotan Giladi	Spinx	spinx@cs2mail.com	Spinx_steam	9	1850
1	Leonid Vishnyakov	chopper	chopper@cs2mail.com	chopper_steam	9	1820
3	Dmitriy Sokolov	sh1ro	sh1ro@cs2mail.com	sh1ro_steam	10	1918
4	Ivan Gogin	zweih	zweih@cs2mail.com	zweih_steam	8	1832
5	Andrey Tatarinovich	tN1R	tn1r@cs2mail.com	tn1r_steam	9	1942
6	Dan Madesclaire	apEX	apex@cs2mail.com	apEX_steam	9	1947
7	Mathieu Herbaut	ZywOo	zywoo@cs2mail.com	ZywOo_steam	10	2020
8	Robin Kool	ropz	ropz@cs2mail.com	ropz_steam	9	1895
9	Shahar Shushan	flameZ	flameZ@cs2mail.com	flameZ_steam	8	1810
10	William Merriman	mezii	mezii@cs2mail.com	mezii_steam	8	1802
2	Danil Kryshkovets	donk	donk@cs2mail.com	donk_steam	10	1995
\.


--
-- Data for Name: player_game_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_game_stats (game_id, player_id, kills, assists, damage, points) FROM stdin;
1	1	12	4	1800	20
1	2	15	3	2100	25
1	3	10	5	1600	18
1	4	8	2	1200	12
1	5	14	3	1500	22
1	6	16	4	2300	27
1	7	12	5	1900	20
1	8	10	2	1600	15
1	9	9	1	1300	10
1	10	14	3	1500	22
2	2	10	2	1500	20
\.


--
-- Data for Name: player_rating_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_rating_history (history_id, player_id, previous_rating, new_rating, changed_at) FROM stdin;
1	1	1800	1820	2025-12-21 21:29:43.900068
2	2	1950	1975	2025-12-21 21:29:43.900068
3	3	1900	1918	2025-12-21 21:29:43.900068
4	4	1820	1832	2025-12-21 21:29:43.900068
5	5	1920	1942	2025-12-21 21:29:43.900068
6	6	1920	1947	2025-12-21 21:29:43.900068
7	7	2000	2020	2025-12-21 21:29:43.900068
8	8	1880	1895	2025-12-21 21:29:43.900068
9	9	1800	1810	2025-12-21 21:29:43.900068
10	10	1780	1802	2025-12-21 21:29:43.900068
11	2	1975	1995	2025-12-21 21:36:13.263946
\.


--
-- Data for Name: prize; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prize (prize_id, tournament_id, prize_type, description, amount, place) FROM stdin;
1	1	money	\N	25000	1
2	1	money	\N	15000	2
3	1	money	\N	10000	3
\.


--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team (team_id, name, created_at, team_rating) FROM stdin;
4	MOUZ	2025-01-01	1750
3	FaZe	2025-01-01	1820
1	Spirit	2025-01-01	1870
2	Vitality	2025-01-01	1940
\.


--
-- Data for Name: team_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_member (team_id, player_id, role, date_from, date_to) FROM stdin;
1	1	капитан	2025-01-01	\N
1	2	основной	2025-01-01	\N
1	3	основной	2025-01-01	\N
1	4	основной	2025-01-01	\N
1	5	основной	2025-09-01	\N
2	6	капитан	2025-01-01	\N
2	7	основной	2025-01-01	\N
2	8	основной	2025-01-01	\N
2	9	основной	2025-01-01	\N
2	10	основной	2025-01-01	\N
3	11	капитан	2025-01-01	\N
3	12	основной	2025-01-01	\N
3	13	основной	2025-01-01	\N
3	14	основной	2025-01-01	\N
3	15	основной	2025-01-01	\N
4	16	капитан	2025-01-01	\N
4	17	основной	2025-01-01	\N
4	18	основной	2025-01-01	\N
4	19	основной	2025-01-01	\N
4	20	основной	2025-01-01	\N
\.


--
-- Data for Name: team_rating_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_rating_history (history_id, team_id, previous_rating, new_rating, changed_at) FROM stdin;
1	2	1900	1910	2025-12-21 21:24:10.249507
2	3	1800	1810	2025-12-21 21:24:10.249507
3	1	1850	1860	2025-12-21 21:24:10.249507
4	2	1910	1920	2025-12-21 21:24:10.249507
5	2	1920	1930	2025-12-21 21:26:58.320686
6	3	1810	1820	2025-12-21 21:26:58.320686
7	1	1860	1870	2025-12-21 21:26:58.320686
8	2	1930	1940	2025-12-21 21:26:58.320686
\.


--
-- Data for Name: tournament; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament (tournament_id, name, discipline_id, start_date, end_date, format, max_participants, prize_pool) FROM stdin;
1	Winter Showdown	1	2025-12-01	2025-12-21	BO13	4	50000
\.


--
-- Data for Name: tournament_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_registration (registration_id, tournament_id, team_id, registered_at) FROM stdin;
1	1	1	2025-12-21 21:24:10.244695
2	1	2	2025-12-21 21:24:10.244695
3	1	3	2025-12-21 21:24:10.244695
4	1	4	2025-12-21 21:24:10.244695
\.


--
-- Name: discipline_discipline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.discipline_discipline_id_seq', 2, true);


--
-- Name: match_game_game_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.match_game_game_id_seq', 6, true);


--
-- Name: match_match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.match_match_id_seq', 8, true);


--
-- Name: player_player_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_player_id_seq', 20, true);


--
-- Name: player_rating_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_rating_history_history_id_seq', 11, true);


--
-- Name: prize_prize_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prize_prize_id_seq', 3, true);


--
-- Name: team_rating_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_rating_history_history_id_seq', 8, true);


--
-- Name: team_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_team_id_seq', 4, true);


--
-- Name: tournament_registration_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_registration_registration_id_seq', 4, true);


--
-- Name: tournament_tournament_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_tournament_id_seq', 1, true);


--
-- Name: discipline discipline_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline
    ADD CONSTRAINT discipline_name_key UNIQUE (name);


--
-- Name: discipline discipline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline
    ADD CONSTRAINT discipline_pkey PRIMARY KEY (discipline_id);


--
-- Name: match_game match_game_match_id_game_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_game
    ADD CONSTRAINT match_game_match_id_game_number_key UNIQUE (match_id, game_number);


--
-- Name: match_game match_game_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_game
    ADD CONSTRAINT match_game_pkey PRIMARY KEY (game_id);


--
-- Name: match match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (match_id);


--
-- Name: player player_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_email_key UNIQUE (email);


--
-- Name: player_game_stats player_game_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_pkey PRIMARY KEY (game_id, player_id);


--
-- Name: player player_nickname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_nickname_key UNIQUE (nickname);


--
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (player_id);


--
-- Name: player_rating_history player_rating_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_rating_history
    ADD CONSTRAINT player_rating_history_pkey PRIMARY KEY (history_id);


--
-- Name: prize prize_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prize
    ADD CONSTRAINT prize_pkey PRIMARY KEY (prize_id);


--
-- Name: team_member team_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_member
    ADD CONSTRAINT team_member_pkey PRIMARY KEY (team_id, player_id, date_from);


--
-- Name: team team_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_name_key UNIQUE (name);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- Name: team_rating_history team_rating_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_rating_history
    ADD CONSTRAINT team_rating_history_pkey PRIMARY KEY (history_id);


--
-- Name: tournament tournament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament
    ADD CONSTRAINT tournament_pkey PRIMARY KEY (tournament_id);


--
-- Name: tournament_registration tournament_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_registration
    ADD CONSTRAINT tournament_registration_pkey PRIMARY KEY (registration_id);


--
-- Name: player_game_stats trg_update_player_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_player_rating AFTER INSERT ON public.player_game_stats FOR EACH ROW EXECUTE FUNCTION public.update_player_rating();


--
-- Name: match trg_update_team_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_team_rating AFTER INSERT ON public.match FOR EACH ROW EXECUTE FUNCTION public.update_team_rating();


--
-- Name: match_game match_game_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_game
    ADD CONSTRAINT match_game_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id);


--
-- Name: match_game match_game_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_game
    ADD CONSTRAINT match_game_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.team(team_id);


--
-- Name: match match_team1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_team1_id_fkey FOREIGN KEY (team1_id) REFERENCES public.team(team_id);


--
-- Name: match match_team2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_team2_id_fkey FOREIGN KEY (team2_id) REFERENCES public.team(team_id);


--
-- Name: match match_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id);


--
-- Name: match match_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.team(team_id);


--
-- Name: player_game_stats player_game_stats_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.match_game(game_id);


--
-- Name: player_game_stats player_game_stats_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id);


--
-- Name: player_rating_history player_rating_history_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_rating_history
    ADD CONSTRAINT player_rating_history_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id);


--
-- Name: prize prize_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prize
    ADD CONSTRAINT prize_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id);


--
-- Name: team_member team_member_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_member
    ADD CONSTRAINT team_member_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id);


--
-- Name: team_member team_member_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_member
    ADD CONSTRAINT team_member_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id);


--
-- Name: team_rating_history team_rating_history_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_rating_history
    ADD CONSTRAINT team_rating_history_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id);


--
-- Name: tournament tournament_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament
    ADD CONSTRAINT tournament_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.discipline(discipline_id);


--
-- Name: tournament_registration tournament_registration_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_registration
    ADD CONSTRAINT tournament_registration_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id);


--
-- Name: tournament_registration tournament_registration_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_registration
    ADD CONSTRAINT tournament_registration_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 5LBGIYIWhBFGiauP8PbjfxxhrJOX0byFQZFXLXcr8R3g9daMgUcEigbZWS3WiAf

