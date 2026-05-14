--
-- PostgreSQL database dump
--

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 17.0

-- Started on 2026-05-14 13:26:01

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 239 (class 1259 OID 16738)
-- Name: ai_recommendations; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.ai_recommendations (
    user_id bigint NOT NULL,
    pub_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    strategy character varying(30) DEFAULT 'TRENDING_FALLBACK'::character varying NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ai_recommendations OWNER TO library;

--
-- TOC entry 215 (class 1259 OID 16398)
-- Name: authors; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.authors (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    bio text,
    date_of_birth date,
    date_of_death date,
    name character varying(100) NOT NULL
);


ALTER TABLE public.authors OWNER TO library;

--
-- TOC entry 235 (class 1259 OID 16659)
-- Name: borrowing_transactions; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.borrowing_transactions (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    borrowed_date timestamp(6) with time zone,
    due_date date NOT NULL,
    item_id bigint NOT NULL,
    librarian_id_issue bigint,
    librarian_id_return bigint,
    picked_up_deadline timestamp(6) with time zone NOT NULL,
    renewal_count integer NOT NULL,
    returned_date timestamp(6) with time zone,
    status character varying(20) NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT borrowing_transactions_status_check CHECK (((status)::text = ANY ((ARRAY['WAITING_FOR_PICKUP'::character varying, 'BORROWING'::character varying, 'RETURNED'::character varying, 'OVERDUE'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.borrowing_transactions OWNER TO library;

--
-- TOC entry 216 (class 1259 OID 16405)
-- Name: categories; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    bio text,
    name character varying(100) NOT NULL,
    parent_category_id bigint
);


ALTER TABLE public.categories OWNER TO library;

--
-- TOC entry 237 (class 1259 OID 16714)
-- Name: fines; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.fines (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    fine_amount numeric(15,0) NOT NULL,
    paid_date timestamp(6) with time zone,
    payment_status character varying(20) NOT NULL,
    transaction_id bigint NOT NULL,
    type character varying(30),
    CONSTRAINT fines_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['UNPAID'::character varying, 'PAID'::character varying])::text[]))),
    CONSTRAINT fines_type_check CHECK (((type)::text = ANY ((ARRAY['DAMAGED_BOOK'::character varying, 'OVERDUE_RETURN'::character varying, 'LOST_BOOK'::character varying])::text[])))
);


ALTER TABLE public.fines OWNER TO library;

--
-- TOC entry 214 (class 1259 OID 16389)
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO library;

--
-- TOC entry 223 (class 1259 OID 16474)
-- Name: items; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    barcode character varying(50) NOT NULL,
    branch character varying(100),
    condition character varying(20),
    location character varying(100),
    publication_id bigint NOT NULL,
    status character varying(20) NOT NULL,
    CONSTRAINT items_condition_check CHECK (((condition)::text = ANY ((ARRAY['NEW'::character varying, 'OLD'::character varying])::text[]))),
    CONSTRAINT items_status_check CHECK (((status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'BORROWED'::character varying, 'RESERVED'::character varying, 'IN_MAINTENANCE'::character varying, 'LOST'::character varying])::text[])))
);


ALTER TABLE public.items OWNER TO library;

--
-- TOC entry 220 (class 1259 OID 16435)
-- Name: notifications; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    link character varying(255),
    reference_id bigint,
    type character varying(30) NOT NULL,
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['BOOK_RESERVED'::character varying, 'BOOK_AVAILABLE'::character varying, 'BORROW_SUCCESS'::character varying, 'BORROW_CANCELLED_EXPIRED'::character varying, 'OVERDUE_WARNING'::character varying, 'FINE_ISSUED'::character varying, 'SYSTEM_MAINTENANCE'::character varying, 'RETURN_REMINDER'::character varying, 'PICKUP_CONFIRMED'::character varying, 'RETURN_CONFIRMED'::character varying, 'FINE_PAID'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO library;

--
-- TOC entry 238 (class 1259 OID 16732)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.password_reset_tokens (
    token character varying(36) NOT NULL,
    user_id bigint NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO library;

--
-- TOC entry 224 (class 1259 OID 16489)
-- Name: publication_authors; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.publication_authors (
    id bigint NOT NULL,
    author_id bigint,
    publication_id bigint
);


ALTER TABLE public.publication_authors OWNER TO library;

--
-- TOC entry 225 (class 1259 OID 16504)
-- Name: publication_categories; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.publication_categories (
    id bigint NOT NULL,
    category_id bigint,
    publication_id bigint
);


ALTER TABLE public.publication_categories OWNER TO library;

--
-- TOC entry 226 (class 1259 OID 16519)
-- Name: publication_tags; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.publication_tags (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.publication_tags OWNER TO library;

--
-- TOC entry 222 (class 1259 OID 16457)
-- Name: publications; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.publications (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    ai_summary text,
    ai_target_audience text,
    call_number character varying(100),
    cover_image_url text,
    description text,
    edition integer,
    file_url text,
    isbn character varying(100),
    language character varying(50) NOT NULL,
    number_of_pages integer,
    publication_year integer,
    publisher_id bigint,
    size character varying(50),
    subtitle character varying(255),
    title character varying(255) NOT NULL,
    weight double precision,
    CONSTRAINT publications_ai_target_audience_check CHECK ((ai_target_audience = ANY (ARRAY['KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH'::text, 'KHOA_DIEN_DIEN_TU'::text, 'KHOA_CO_KHI'::text, 'KHOA_KY_THUAT_HOA_HOC'::text, 'KHOA_KY_THUAT_XAY_DUNG'::text, 'KHOA_KY_THUAT_GIAO_THONG'::text, 'KHOA_QUAN_LY_CONG_NGHIEP'::text, 'KHOA_MOI_TRUONG_VA_TAI_NGUYEN'::text, 'KHOA_CONG_NGHE_VAT_LIEU'::text, 'KHOA_KHOA_HOC_UNG_DUNG'::text, 'KHOA_KY_THUAT_DIA_CHAT_VA_DAU_KHI'::text])))
);


ALTER TABLE public.publications OWNER TO library;

--
-- TOC entry 217 (class 1259 OID 16415)
-- Name: publishers; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.publishers (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    address character varying(255),
    name character varying(100) NOT NULL
);


ALTER TABLE public.publishers OWNER TO library;

--
-- TOC entry 233 (class 1259 OID 16619)
-- Name: ratings; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.ratings (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    comment text,
    helpful_count integer NOT NULL,
    publication_id bigint NOT NULL,
    star integer NOT NULL,
    user_id bigint NOT NULL,
    verified_borrow boolean
);


ALTER TABLE public.ratings OWNER TO library;

--
-- TOC entry 228 (class 1259 OID 16549)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.refresh_tokens (
    uuid_token character varying(255) NOT NULL,
    device_id character varying(255),
    expiry_date timestamp(6) with time zone,
    revoked boolean DEFAULT false NOT NULL,
    user_id bigint
);


ALTER TABLE public.refresh_tokens OWNER TO library;

--
-- TOC entry 236 (class 1259 OID 16688)
-- Name: reservations; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.reservations (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    hold_expiration_time timestamp(6) with time zone,
    preferred_branch character varying(50) DEFAULT 'ANY'::character varying NOT NULL,
    assigned_item_id bigint,
    publication_id bigint NOT NULL,
    queue_position integer NOT NULL,
    reservation_date timestamp(6) with time zone NOT NULL,
    status character varying(20) NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT reservations_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'READY_FOR_PICKUP'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying, 'COMPLETED'::character varying])::text[])))
);


ALTER TABLE public.reservations OWNER TO library;

--
-- TOC entry 219 (class 1259 OID 16428)
-- Name: roles; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    description character varying(255),
    role_name character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO library;

--
-- TOC entry 229 (class 1259 OID 16565)
-- Name: search_history; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.search_history (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    search_query text NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.search_history OWNER TO library;

--
-- TOC entry 218 (class 1259 OID 16421)
-- Name: tags; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    name character varying(50) NOT NULL
);


ALTER TABLE public.tags OWNER TO library;

--
-- TOC entry 234 (class 1259 OID 16641)
-- Name: user_interactions; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.user_interactions (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    publication_id bigint NOT NULL,
    type character varying(30) NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT user_interactions_type_check CHECK (((type)::text = ANY ((ARRAY['WATCH'::character varying, 'WISHLIST'::character varying, 'BORROWED'::character varying])::text[])))
);


ALTER TABLE public.user_interactions OWNER TO library;

--
-- TOC entry 230 (class 1259 OID 16578)
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.user_notifications (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    is_read boolean NOT NULL,
    read_at timestamp with time zone,
    notification_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.user_notifications OWNER TO library;

--
-- TOC entry 227 (class 1259 OID 16534)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.user_roles OWNER TO library;

--
-- TOC entry 221 (class 1259 OID 16444)
-- Name: users; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    address character varying(255),
    ai_personalization_enabled boolean NOT NULL,
    credit_score integer DEFAULT 100 NOT NULL,
    date_of_birth date,
    email character varying(100) NOT NULL,
    faculty character varying(255),
    full_name character varying(100) NOT NULL,
    hashed_password character varying(255),
    last_login_at timestamp(6) without time zone,
    phone_number character varying(20),
    profile_picture_url character varying(255),
    provider character varying(255),
    provider_id character varying(255),
    status character varying(255) NOT NULL,
    student_id character varying(7),
    CONSTRAINT users_faculty_check CHECK (((faculty)::text = ANY ((ARRAY['KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH'::character varying, 'KHOA_DIEN_DIEN_TU'::character varying, 'KHOA_CO_KHI'::character varying, 'KHOA_KY_THUAT_HOA_HOC'::character varying, 'KHOA_KY_THUAT_XAY_DUNG'::character varying, 'KHOA_KY_THUAT_GIAO_THONG'::character varying, 'KHOA_QUAN_LY_CONG_NGHIEP'::character varying, 'KHOA_MOI_TRUONG_VA_TAI_NGUYEN'::character varying, 'KHOA_CONG_NGHE_VAT_LIEU'::character varying, 'KHOA_KHOA_HOC_UNG_DUNG'::character varying, 'KHOA_KY_THUAT_DIA_CHAT_VA_DAU_KHI'::character varying])::text[]))),
    CONSTRAINT users_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'LOCKED'::character varying, 'BANNED'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO library;

--
-- TOC entry 231 (class 1259 OID 16594)
-- Name: wish_lists; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.wish_lists (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    user_id bigint
);


ALTER TABLE public.wish_lists OWNER TO library;

--
-- TOC entry 232 (class 1259 OID 16604)
-- Name: wish_lists_item; Type: TABLE; Schema: public; Owner: library
--

CREATE TABLE public.wish_lists_item (
    id bigint NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    added_at timestamp(6) with time zone,
    publication_id bigint,
    wish_list_id bigint
);


ALTER TABLE public.wish_lists_item OWNER TO library;

--
-- TOC entry 3672 (class 0 OID 16738)
-- Dependencies: 239
-- Data for Name: ai_recommendations; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.ai_recommendations (user_id, pub_ids, strategy, computed_at) FROM stdin;
\.


--
-- TOC entry 3648 (class 0 OID 16398)
-- Dependencies: 215
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.authors (id, created_at, updated_at, bio, date_of_birth, date_of_death, name) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Tác giả cuốn Clean Code, chuyên gia về kiến trúc phần mềm	1952-12-05	\N	Robert C. Martin
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Tác giả Domain-Driven Design, người đặt nền móng cho DDD	1963-01-01	\N	Eric Evans
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Kiến trúc sư phần mềm nổi tiếng, tác giả Refactoring	1963-12-18	\N	Martin Fowler
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Giảng viên ĐHBK TP.HCM, chuyên ngành Cơ sở dữ liệu	1970-05-20	\N	Nguyễn Văn Linh
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Tác giả nhiều giáo trình Lập trình Java được sử dụng tại các trường	1975-09-15	\N	Trần Thị Minh Hoa
6	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author SICP	1947-04-26	\N	Harold Abelson
7	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author SICP	1947-02-08	\N	Gerald Jay Sussman
8	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor UT Austin, CS educator	1945-01-01	\N	Nell Dale
9	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Virginia Tech, CS educator	1958-01-01	\N	John Lewis
10	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Marquette University, author CS: An Overview	1950-01-01	\N	J. Glenn Brookshear
11	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Olin College, author Think Python and How to Think	1967-01-01	\N	Allen B. Downey
12	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Mathematician, co-author Concrete Mathematics	1935-10-31	2020-07-06	Ronald L. Graham
13	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Stanford, The Art of Computer Programming	1938-01-10	\N	Donald E. Knuth
14	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Computer scientist, co-author Concrete Mathematics	1954-01-01	\N	Oren Patashnik
15	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Cornell, author Quantum Computer Science	1935-03-30	\N	N. David Mermin
16	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Harvard, author Introduction to Theoretical CS	1974-01-01	\N	Boaz Barak
17	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Co-author Mathematics for Computer Science (MIT)	1970-01-01	\N	Eric Lehman
18	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author Mathematics for Computer Science	1956-11-06	\N	F. Thomson Leighton
19	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author Mathematics for Computer Science	1941-01-01	\N	Albert R. Meyer
20	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Dartmouth, co-author Introduction to Algorithms	1956-01-01	\N	Thomas H. Cormen
21	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author Introduction to Algorithms	1953-01-01	\N	Charles E. Leiserson
22	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor MIT, co-author CLRS, RSA inventor	1947-05-06	\N	Ronald L. Rivest
23	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Columbia, co-author Introduction to Algorithms	1965-01-01	\N	Clifford Stein
24	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Software engineer, Gang of Four, Eclipse architect	1961-03-13	\N	Erich Gamma
25	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Software engineer, Gang of Four	1960-01-01	\N	Richard Helm
26	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor UIUC, Gang of Four	1955-01-01	\N	Ralph Johnson
27	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Software engineer, Gang of Four	1961-08-02	2005-11-24	John Vlissides
28	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Yale, co-author OS Concepts and Database Concepts	1952-01-01	\N	Abraham Silberschatz
29	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Co-author Operating System Concepts	1960-01-01	\N	Peter B. Galvin
30	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Westminster College, co-author OS Concepts	1965-01-01	\N	Greg Gagne
31	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor VU Amsterdam, author Modern OS and Computer Networks	1944-03-16	\N	Andrew S. Tanenbaum
32	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor UC Berkeley, co-author AI: A Modern Approach	1962-01-01	\N	Stuart Russell
33	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Director of Research Google, co-author AI: A Modern Approach	1956-12-14	\N	Peter Norvig
34	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Research scientist, author Deep Learning textbook	1985-01-01	\N	Ian Goodfellow
35	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Université de Montréal, Turing Award winner	1964-03-05	\N	Yoshua Bengio
36	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Université de Montréal, co-author Deep Learning	1980-01-01	\N	Aaron Courville
37	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author Hands-On Machine Learning with Scikit-Learn, Keras, TF	1973-01-01	\N	Aurélien Géron
38	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Lehigh, co-author Database System Concepts	1955-01-01	\N	Henry S. Korth
39	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor IIT Bombay, co-author Database System Concepts	1966-01-01	\N	S. Sudarshan
40	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Columbia, co-author Compilers (Dragon Book)	1941-08-09	\N	Alfred V. Aho
41	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Stanford, co-author Compilers	1961-01-01	\N	Monica S. Lam
42	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	VP Avaya, co-author Compilers	1947-01-01	\N	Ravi Sethi
43	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor Stanford emeritus, co-author Compilers	1942-11-22	\N	Jeffrey D. Ullman
44	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor UC Berkeley, co-author Computer Organization and Design	1947-11-16	\N	David A. Patterson
45	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	President Stanford, co-author Computer Organization and Design	1952-09-22	\N	John L. Hennessy
46	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author Code Complete, software engineering expert	1962-01-01	\N	Steve McConnell
47	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author You Don't Know JS series	1980-01-01	\N	Kyle Simpson
48	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author Eloquent JavaScript	1983-01-01	\N	Marijn Haverbeke
49	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author Automate the Boring Stuff with Python	1982-01-01	\N	Al Sweigart
50	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Author The Linux Command Line	1963-01-01	\N	William Shotts
51	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Amazon, co-author Dive Into Deep Learning	1988-01-01	\N	Aston Zhang
52	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor CMU, co-author Dive Into Deep Learning	1990-01-01	\N	Zachary C. Lipton
53	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Amazon, co-author Dive Into Deep Learning	1985-01-01	\N	Mu Li
54	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Amazon, co-author Dive Into Deep Learning	1972-08-02	\N	Alexander J. Smola
55	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Professor University of Helsinki, creator Full Stack Open	1978-01-01	\N	Matti Luukkainen
\.


--
-- TOC entry 3668 (class 0 OID 16659)
-- Dependencies: 235
-- Data for Name: borrowing_transactions; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.borrowing_transactions (id, created_at, updated_at, borrowed_date, due_date, item_id, librarian_id_issue, librarian_id_return, picked_up_deadline, renewal_count, returned_date, status, user_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-04 04:41:44.111352+00	2026-05-18	2	2	\N	2026-05-05 04:41:44.111352+00	0	\N	BORROWING	4
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-24 04:41:44.111352+00	2026-05-08	3	2	3	2026-04-25 04:41:44.111352+00	0	2026-05-07 04:41:44.111352+00	RETURNED	5
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-14 04:41:44.111352+00	2026-05-12	4	3	\N	2026-04-15 04:41:44.111352+00	1	\N	OVERDUE	4
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	2026-05-16	1	2	\N	2026-05-15 04:41:44.111352+00	0	\N	WAITING_FOR_PICKUP	5
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-03-30 04:41:44.111352+00	2026-04-13	3	3	3	2026-03-31 04:41:44.111352+00	1	2026-04-12 04:41:44.111352+00	RETURNED	4
6	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-28	6	2	\N	2026-05-14 03:41:44.111352+00	0	\N	BORROWING	4
7	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-28	7	3	\N	2026-05-14 03:41:44.111352+00	0	\N	BORROWING	5
8	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-30 04:41:44.111352+00	2026-05-15	8	2	3	2026-05-01 04:41:44.111352+00	0	2026-05-14 04:41:44.111352+00	RETURNED	4
9	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-29 04:41:44.111352+00	2026-05-13	9	2	3	2026-04-30 04:41:44.111352+00	0	2026-05-14 04:41:44.111352+00	RETURNED	5
10	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-30 04:41:44.111352+00	2026-05-14	10	3	\N	2026-05-01 04:41:44.111352+00	0	\N	OVERDUE	4
11	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-30 04:41:44.111352+00	2026-05-14	11	2	\N	2026-05-01 04:41:44.111352+00	0	\N	OVERDUE	5
12	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-26 04:41:44.111352+00	2026-05-10	12	3	\N	2026-04-27 04:41:44.111352+00	0	\N	OVERDUE	4
13	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-04-19 04:41:44.111352+00	2026-05-03	13	2	\N	2026-04-20 04:41:44.111352+00	1	\N	OVERDUE	5
14	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	2026-05-17	14	2	\N	2026-05-15 04:41:44.111352+00	0	\N	WAITING_FOR_PICKUP	4
15	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	2026-05-17	15	3	\N	2026-05-16 04:41:44.111352+00	0	\N	WAITING_FOR_PICKUP	5
\.


--
-- TOC entry 3649 (class 0 OID 16405)
-- Dependencies: 216
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.categories (id, created_at, updated_at, bio, name, parent_category_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách về lĩnh vực CNTT	Công Nghệ Thông Tin	\N
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách về ngôn ngữ và kỹ thuật lập trình	Lập Trình	1
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách về thiết kế và kiến trúc hệ thống	Kiến Trúc Phần Mềm	1
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách về CSDL quan hệ và phi quan hệ	Cơ Sở Dữ Liệu	1
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách toán phục vụ kỹ thuật	Toán Ứng Dụng	\N
6	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	AI, Machine Learning, Deep Learning	Trí Tuệ Nhân Tạo	1
7	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Sách về hệ điều hành và quản lý tài nguyên	Hệ Điều Hành	1
8	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Sách về giao thức mạng và hạ tầng mạng	Mạng Máy Tính	1
9	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Sách về giải thuật và data structures	Thuật Toán & Cấu Trúc Dữ Liệu	2
10	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Nền tảng khoa học máy tính và lý thuyết	Khoa Học Máy Tính Cơ Bản	1
11	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Web development: frontend, backend, fullstack	Lập Trình Web	2
12	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Computer organization và kiến trúc phần cứng	Kiến Trúc Máy Tính	1
13	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Compiler design và lý thuyết ngôn ngữ lập trình	Trình Biên Dịch	1
\.


--
-- TOC entry 3670 (class 0 OID 16714)
-- Dependencies: 237
-- Data for Name: fines; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.fines (id, created_at, updated_at, fine_amount, paid_date, payment_status, transaction_id, type) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	50000	\N	UNPAID	3	OVERDUE_RETURN
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	30000	2026-04-14 04:41:44.111352+00	PAID	5	OVERDUE_RETURN
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	100000	2026-05-08 04:41:44.111352+00	PAID	2	DAMAGED_BOOK
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	40000	2026-05-14 04:41:44.111352+00	PAID	9	OVERDUE_RETURN
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	50000	\N	UNPAID	10	OVERDUE_RETURN
6	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	50000	\N	UNPAID	11	OVERDUE_RETURN
7	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	80000	\N	UNPAID	12	OVERDUE_RETURN
8	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	150000	\N	UNPAID	13	OVERDUE_RETURN
\.


--
-- TOC entry 3647 (class 0 OID 16389)
-- Dependencies: 214
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	create schema	SQL	V1__create_schema.sql	1621562537	library	2026-05-14 11:41:43.5918	414	t
2	2	seed data	SQL	V2__seed_data.sql	-789669172	library	2026-05-14 11:41:44.084706	66	t
3	3	test user	SQL	V3__test_user.sql	55806882	library	2026-05-14 11:41:44.193773	8	t
4	4	batch publications	SQL	V4__batch_publications.sql	521722659	library	2026-05-14 11:41:44.224761	32	t
5	5	ai recommendations	SQL	V5__ai_recommendations.sql	-931761002	library	2026-05-14 11:41:44.295015	22	t
\.


--
-- TOC entry 3656 (class 0 OID 16474)
-- Dependencies: 223
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.items (id, created_at, updated_at, barcode, branch, condition, location, publication_id, status) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-CC-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 301	1	RESERVED
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-CC-002	Cơ sở 1 - Lý Thường Kiệt	OLD	B4 - 301	1	BORROWED
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DDD-001	Cơ sở 2 - Dĩ An	NEW	H6 - 201	2	AVAILABLE
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DB-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 302	4	BORROWED
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-JAVA-001	Cơ sở 2 - Dĩ An	OLD	H6 - 202	5	IN_MAINTENANCE
6	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-REF-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 303	3	BORROWED
7	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-REF-002	Cơ sở 1 - Lý Thường Kiệt	OLD	B4 - 303	3	BORROWED
8	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DDD-002	Cơ sở 2 - Dĩ An	NEW	H6 - 201	2	AVAILABLE
9	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-CC-003	Cơ sở 1 - Lý Thường Kiệt	OLD	B4 - 304	1	AVAILABLE
10	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DB-002	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 302	4	BORROWED
11	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-JAVA-002	Cơ sở 2 - Dĩ An	NEW	H6 - 203	5	BORROWED
12	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DDD-003	Cơ sở 2 - Dĩ An	OLD	H6 - 201	2	BORROWED
13	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-CC-004	Cơ sở 1 - Lý Thường Kiệt	OLD	B4 - 304	1	BORROWED
14	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-REF-003	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 303	3	RESERVED
15	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	BK-DB-003	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 302	4	RESERVED
16	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-SICP-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 301	6	AVAILABLE
17	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-SICP-002	Cơ sở 2 - Dĩ An	NEW	H6 - 201	6	AVAILABLE
18	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CSI-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 302	7	AVAILABLE
19	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CSI-002	Cơ sở 2 - Dĩ An	NEW	H6 - 202	7	AVAILABLE
20	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CSO-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 303	8	AVAILABLE
21	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CSO-002	Cơ sở 2 - Dĩ An	NEW	H6 - 203	8	AVAILABLE
22	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-HTCS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 304	9	AVAILABLE
23	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-HTCS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 204	9	AVAILABLE
24	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CM-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 305	10	AVAILABLE
25	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CM-002	Cơ sở 2 - Dĩ An	NEW	H6 - 205	10	AVAILABLE
26	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-QCS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 306	11	AVAILABLE
27	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-QCS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 206	11	AVAILABLE
28	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TCS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 307	12	AVAILABLE
29	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TCS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 207	12	AVAILABLE
30	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-MCS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 308	13	AVAILABLE
31	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-MCS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 208	13	AVAILABLE
32	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CLRS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 309	14	AVAILABLE
33	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CLRS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 209	14	AVAILABLE
34	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DP-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 310	15	AVAILABLE
35	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DP-002	Cơ sở 2 - Dĩ An	NEW	H6 - 210	15	AVAILABLE
36	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-OSC-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 311	16	AVAILABLE
37	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-OSC-002	Cơ sở 2 - Dĩ An	NEW	H6 - 211	16	AVAILABLE
38	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CN-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 312	17	AVAILABLE
39	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CN-002	Cơ sở 2 - Dĩ An	NEW	H6 - 212	17	AVAILABLE
40	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-AI-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 313	18	AVAILABLE
41	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-AI-002	Cơ sở 2 - Dĩ An	NEW	H6 - 213	18	AVAILABLE
42	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DLG-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 314	19	AVAILABLE
43	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DLG-002	Cơ sở 2 - Dĩ An	NEW	H6 - 214	19	AVAILABLE
44	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-HML-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 315	20	AVAILABLE
45	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-HML-002	Cơ sở 2 - Dĩ An	NEW	H6 - 215	20	AVAILABLE
46	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DBC-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 316	21	AVAILABLE
47	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-DBC-002	Cơ sở 2 - Dĩ An	NEW	H6 - 216	21	AVAILABLE
48	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-MOS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 317	22	AVAILABLE
49	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-MOS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 217	22	AVAILABLE
50	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CPL-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 318	23	AVAILABLE
51	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CPL-002	Cơ sở 2 - Dĩ An	NEW	H6 - 218	23	AVAILABLE
52	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-COD-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 319	24	AVAILABLE
53	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-COD-002	Cơ sở 2 - Dĩ An	NEW	H6 - 219	24	AVAILABLE
54	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CC2-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 320	25	AVAILABLE
55	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-CC2-002	Cơ sở 2 - Dĩ An	NEW	H6 - 220	25	AVAILABLE
56	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-YDKJS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 321	26	AVAILABLE
57	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-YDKJS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 221	26	AVAILABLE
58	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-EJS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 322	27	AVAILABLE
59	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-EJS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 222	27	AVAILABLE
60	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-ATBS-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 323	28	AVAILABLE
61	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-ATBS-002	Cơ sở 2 - Dĩ An	NEW	H6 - 223	28	AVAILABLE
62	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TLCL-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 324	29	AVAILABLE
63	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TLCL-002	Cơ sở 2 - Dĩ An	NEW	H6 - 224	29	AVAILABLE
64	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TPY-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 325	30	AVAILABLE
65	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-TPY-002	Cơ sở 2 - Dĩ An	NEW	H6 - 225	30	AVAILABLE
66	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-D2L-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 326	31	AVAILABLE
67	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-D2L-002	Cơ sở 2 - Dĩ An	NEW	H6 - 226	31	AVAILABLE
68	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-FSO-001	Cơ sở 1 - Lý Thường Kiệt	NEW	B4 - 327	32	AVAILABLE
69	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	BK-FSO-002	Cơ sở 2 - Dĩ An	NEW	H6 - 227	32	AVAILABLE
\.


--
-- TOC entry 3653 (class 0 OID 16435)
-- Dependencies: 220
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.notifications (id, created_at, updated_at, title, message, link, reference_id, type) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00		Sách "Clean Code" đã có sẵn để mượn.	/publications/1	\N	BOOK_AVAILABLE
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00		Bạn đã đặt trước "Domain-Driven Design" thành công.	/reservations/2	\N	BOOK_RESERVED
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00		Bạn đã mượn thành công sách "Giáo Trình CSDL".	/transactions/1	\N	BORROW_SUCCESS
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00		Sách "Refactoring" bạn đặt trước đã có sẵn.	/publications/3	\N	BOOK_AVAILABLE
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00		Bạn đã mượn thành công sách "Lập Trình Java".	/transactions/4	\N	BORROW_SUCCESS
\.


--
-- TOC entry 3671 (class 0 OID 16732)
-- Dependencies: 238
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.password_reset_tokens (token, user_id, expires_at) FROM stdin;
\.


--
-- TOC entry 3657 (class 0 OID 16489)
-- Dependencies: 224
-- Data for Name: publication_authors; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.publication_authors (id, author_id, publication_id) FROM stdin;
1	1	1
2	2	2
3	3	3
4	4	4
5	5	5
6	6	6
7	7	6
8	8	7
9	9	7
10	10	8
11	11	9
12	12	10
13	13	10
14	14	10
15	15	11
16	16	12
17	17	13
18	18	13
19	19	13
20	20	14
21	21	14
22	22	14
23	23	14
24	24	15
25	25	15
26	26	15
27	27	15
28	28	16
29	29	16
30	30	16
31	31	17
32	32	18
33	33	18
34	34	19
35	35	19
36	36	19
37	37	20
38	28	21
39	38	21
40	39	21
41	31	22
42	40	23
43	41	23
44	42	23
45	43	23
46	44	24
47	45	24
48	46	25
49	47	26
50	48	27
51	49	28
52	50	29
53	11	30
54	51	31
55	52	31
56	53	31
57	54	31
58	55	32
\.


--
-- TOC entry 3658 (class 0 OID 16504)
-- Dependencies: 225
-- Data for Name: publication_categories; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.publication_categories (id, category_id, publication_id) FROM stdin;
1	2	1
2	3	1
3	3	2
4	4	4
5	2	5
6	2	6
7	10	6
8	10	7
9	1	7
10	10	8
11	1	8
12	2	9
13	10	9
14	5	10
15	9	10
16	10	11
17	10	12
18	9	12
19	5	13
20	9	13
21	9	14
22	2	14
23	3	15
24	2	15
25	7	16
26	8	17
27	6	18
28	6	19
29	6	20
30	2	20
31	4	21
32	7	22
33	13	23
34	2	23
35	12	24
36	3	25
37	2	25
38	2	26
39	11	26
40	2	27
41	11	27
42	2	28
43	11	28
44	2	29
45	2	30
46	10	30
47	6	31
48	11	32
49	2	32
\.


--
-- TOC entry 3659 (class 0 OID 16519)
-- Dependencies: 226
-- Data for Name: publication_tags; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.publication_tags (id, publication_id, tag_id) FROM stdin;
1	1	2
2	1	3
3	2	3
4	4	4
5	5	1
6	9	6
7	12	9
8	14	9
9	18	10
10	19	10
11	20	10
12	26	7
13	27	7
14	28	6
15	29	8
16	30	6
17	31	10
18	32	11
19	10	15
20	13	15
21	16	12
22	22	12
23	17	13
24	23	14
\.


--
-- TOC entry 3655 (class 0 OID 16457)
-- Dependencies: 222
-- Data for Name: publications; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.publications (id, created_at, updated_at, ai_summary, ai_target_audience, call_number, cover_image_url, description, edition, file_url, isbn, language, number_of_pages, publication_year, publisher_id, size, subtitle, title, weight) FROM stdin;
4	2026-05-14 04:41:44.111352+00	2026-05-14 06:14:13.552761+00	\N	KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH	005.74 N573g	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Gi_o_Tr_nh_C__S__D__Li_u_f7800efb-e51a-458f-a289-8ff918fcd782.jpg	Giáo trình CSDL dành cho sinh viên đại học kỹ thuật, bao gồm mô hình quan hệ và SQL.	3	\N	9786040234567	Vietnamese	380	2020	1	24x17cm	\N	Giáo Trình Cơ Sở Dữ Liệu	0.65
7	2026-05-14 04:41:44.24972+00	2026-05-14 06:02:03.662679+00	\N	\N	004 D138c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781284155617_519e6b9f-e198-43cd-9169-a271f350f9ff.jpg	Cái nhìn tổng quan toàn diện về khoa học máy tính: từ hệ nhị phân, phần cứng, hệ điều hành đến mạng và bảo mật. Lý tưởng cho sinh viên năm nhất.	7	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/7/documents/computer_science_illuminated.pdf_56235934-2b36-4368-97a2-c9743376ef61.pdf	9781284155617	English	602	2019	8	27x21cm	An Introduction to the Science and Technology of Computing	Computer Science Illuminated	1.2
9	2026-05-14 04:41:44.24972+00	2026-05-14 06:13:08.701171+00	\N	\N	005.133 D748h	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/How_to_Think_Like_a_Computer_Scientist_d9326740-1934-4914-b28f-19dd5883d3ac.jpg	Nhập môn lập trình Python theo tư duy khoa học máy tính: từ biến, hàm, đệ quy đến OOP. Miễn phí và mã nguồn mở.	3	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/9/documents/How_to_Think_Like_a_Computer_Scientist.pdf_c0ff997c-d8da-4f23-8ded-af8a39693364.pdf	9780987566331	English	242	2012	13	23x18cm	Learning with Python 3	How to Think Like a Computer Scientist	0.5
10	2026-05-14 04:41:44.24972+00	2026-05-14 06:02:42.511995+00	\N	\N	510.285 G739c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780201558029_2202eb0a-d88a-4d3e-8fde-2b59f36614b5.jpg	Nền tảng toán học bắt buộc cho CS: tổng quát hóa hàm đệ quy, toán tổ hợp, lý thuyết số và giải tích rời rạc.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/10/documents/Concrete_Mathematics.pdf_e4f95066-623c-4f32-8ab8-5816097d9b25.pdf	9780201558029	English	657	1994	4	24x18cm	A Foundation for Computer Science	Concrete Mathematics	1.2
14	2026-05-14 04:41:44.24972+00	2026-05-14 06:11:47.599812+00	\N	\N	005.1 C813i	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Introduction_to_Algorithms_8b5eee0c-200f-4109-811f-400fdc027b96.jpg	Sách giáo khoa thuật toán kinh điển nhất thế giới. Phân tích chi tiết: sắp xếp, tìm kiếm, đồ thị, lập trình động, NP và thuật toán xấp xỉ.	4	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/14/documents/Introduction_to_Algorithms.pdf_ee22c4e6-2656-477c-80c2-5440353543e9.pdf	9780262046305	English	1312	2022	6	25x19cm	Fourth Edition	Introduction to Algorithms	2.1
12	2026-05-14 04:41:44.24972+00	2026-05-14 06:12:24.082584+00	\N	\N	004.01 B224i	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Introduction_to_Theoretical_Computer_Science_48b852fb-758d-49fa-8e0d-5654b219b1a0.jpg	Lý thuyết tính toán hiện đại: automata, ngôn ngữ hình thức, NP-completeness, mật mã học và proof complexity. Sách mở miễn phí của Harvard.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/12/documents/Introduction_to_Theoretical_Computer_Science.pdf_9011db55-3aeb-4408-8ee6-9b8b4f94ddcb.pdf	9781734662559	English	446	2020	13	24x18cm	Computation and Complexity	Introduction to Theoretical Computer Science	0.9
17	2026-05-14 04:41:44.24972+00	2026-05-14 06:04:06.819287+00	\N	\N	004.6 T164c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780132126953_3c8edf93-78dc-4338-bb96-cbd8b05400b3.jpg	Phân tích toàn diện mạng máy tính theo mô hình phân lớp 5 tầng: từ tầng vật lý (Ethernet, WiFi) đến tầng ứng dụng (HTTP, DNS, P2P).	5	\N	9780132126953	English	960	2010	4	25x19cm	Fifth Edition	Computer Networks	1.8
16	2026-05-14 04:41:44.24972+00	2026-05-14 06:03:55.884014+00	\N	\N	005.43 S587o	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780470128725_f25fd8fe-6bd2-44a7-a552-cf288ef33f5f.jpg	Sách giáo khoa hệ điều hành toàn diện: quản lý tiến trình, bộ nhớ, file system, I/O và bảo mật. Được dùng tại hàng nghìn trường đại học.	8	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/16/documents/Operating_System_Concepts__8th_Edition.pdf_e4970dbc-aa03-4905-b4e5-cfd815240a73.pdf	9780470128725	English	976	2008	7	25x19cm	Eighth Edition (Dinosaur Book)	Operating System Concepts	1.8
2	2026-05-14 04:41:44.111352+00	2026-05-14 06:15:21.438212+00	\N	\N	005.117 E92d	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Domain-Driven_Design_87aae53d-33a2-42dc-9f91-5c5af1208db8.jpg	Sách nền tảng về DDD, giúp thiết kế hệ thống phức tạp theo nghiệp vụ.	1	\N	9780321125217	English	560	2003	4	23x18cm	Tackling Complexity in the Heart of Software	Domain-Driven Design	0.85
13	2026-05-14 04:41:44.24972+00	2026-05-14 06:10:57.791155+00	\N	\N	510.285 L519m	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Mathematics_for_Computer_Science_80e24d52-fec4-4321-804d-37296264cfe3.jpg	Tài liệu toán cho CS của MIT: logic mệnh đề, bằng chứng, lý thuyết đồ thị, xác suất và đại số tuyến tính. Tài liệu khóa 6.042J.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/13/documents/Mathematics_for_Computer_Science.pdf_87c66392-6989-466a-b5d6-cce497039f7f.pdf	9780262042925	English	979	2018	6	27x21cm	MIT OpenCourseWare Edition	Mathematics for Computer Science	1.5
22	2026-05-14 04:41:44.24972+00	2026-05-14 06:05:37.646089+00	\N	\N	005.43 T164m	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780133591620_0c961a68-8184-4f26-95da-9597b1f62c07.jpg	Phân tích sâu kiến trúc hệ điều hành: UNIX, Windows, Linux, Android, virtualization và distributed systems.	4	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/22/documents/Modern_Operating_System_-_Tanenbaum.pdf_db6e3709-3c37-4dc2-b382-5228749b71b1.pdf	9780133591620	English	1137	2014	4	25x19cm	Fourth Edition	Modern Operating Systems	1.9
5	2026-05-14 04:41:44.111352+00	2026-05-14 06:16:01.957536+00	\N	KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH	005.133 T764l	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/la__p-tri_nh-hu_o__ng-_o__i-tu_o__ng-la_-gi__2ede7abc-9a21-4046-b248-6cb6da895df8.png	Giáo trình Java OOP dành cho sinh viên năm 2, từ cơ bản đến design patterns.	2	\N	9786040345678	Vietnamese	420	2021	2	24x17cm	\N	Lập Trình Java Hướng Đối Tượng	0.7
1	2026-05-14 04:41:44.111352+00	2026-05-14 06:01:34.636068+00	\N	\N	005.13 M376c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780132350884_13f4e28d-75f9-4511-a97a-f578f1ef195c.jpg	Hướng dẫn viết code sạch, dễ bảo trì và mở rộng. Cuốn sách kinh điển của Robert C. Martin.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/1/documents/Clean_Code.pdf_6a9a8ff8-8786-4b9d-806e-8c498bc665d8.pdf	9780132350884	English	431	2008	5	23x18cm	A Handbook of Agile Software Craftsmanship	Clean Code	0.72
3	2026-05-14 04:41:44.111352+00	2026-05-14 06:01:40.654527+00	\N	\N	005.13 F679r	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780134757599_12b20c40-263a-46f1-be94-38e94fbee5f4.jpg	Kỹ thuật tái cấu trúc code mà không làm thay đổi hành vi hệ thống.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/3/documents/Refactoring-Improving-the-Design-of-Existing-Code-Addison-Wesley-Professional-1999.pdf_70470236-cbdc-453f-b7ea-e6ce84fa2d74.pdf	9780134757599	English	448	2018	4	23x18cm	Improving the Design of Existing Code	Refactoring	0.78
6	2026-05-14 04:41:44.24972+00	2026-05-14 06:01:50.149603+00	\N	\N	005.133 A138s	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780262510875_69b16324-e602-4754-8b71-1f68f29119d4.jpg	Cuốn sách kinh điển của MIT, dùng ngôn ngữ Scheme để dạy lập trình theo phong cách hàm, trừu tượng hóa, và meta-circular evaluation.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/6/documents/Structure_and_Interpretation_of_Computer_Programs__2nd_ed..pdf_2b1a689e-967a-41f1-80d3-28c2541d68d1.pdf	9780262510875	English	657	1996	6	24x18cm	Second Edition	Structure and Interpretation of Computer Programs	1.1
8	2026-05-14 04:41:44.24972+00	2026-05-14 06:02:30.130193+00	\N	\N	004 B873c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780133760064_c35d965a-de2b-457c-b763-59e630766e34.jpg	Khảo sát toàn bộ lĩnh vực khoa học máy tính từ lịch sử hình thành đến xu hướng hiện đại như cloud và IoT. Phù hợp cho môn nhập môn đại học.	12	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/8/documents/Computer_Science_-_An_Overview_12_E.pdf_385349ab-03a3-4886-90fb-4089c9775d64.pdf	9780133760064	English	675	2014	4	26x21cm	Twelfth Edition	Computer Science: An Overview	1.3
11	2026-05-14 04:41:44.24972+00	2026-05-14 06:02:49.086402+00	\N	\N	004.1 M565q	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780521876582_2536de42-6b39-4130-a0ba-b0d5a3150401.jpg	Giới thiệu về máy tính lượng tử: qubit, thuật toán Shor và Grover, mạch lượng tử và lý thuyết phức tạp lượng tử. Không cần nền tảng vật lý lượng tử.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/11/documents/Quantum_Computer_Science_-_An_Introduction.pdf_3185e160-73e2-42eb-9126-fefc33faa08f.pdf	9780521876582	English	263	2007	12	24x17cm	An Introduction	Quantum Computer Science	0.6
15	2026-05-14 04:41:44.24972+00	2026-05-14 06:03:26.551143+00	\N	\N	005.12 G186d	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780201633610_f83e028d-8009-4118-b4ab-777d06d53256.jpg	Cuốn sách Gang of Four định nghĩa 23 design pattern kinh điển. Cẩm nang không thể thiếu cho lập trình hướng đối tượng chuyên nghiệp.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/15/documents/Design_Patterns_Elements_of_Reusable_Object-Oriented_Software.pdf_dc59a1a5-cf9b-41d7-92d4-a24a87cde980.pdf	9780201633610	English	395	1994	4	23x18cm	Elements of Reusable Object-Oriented Software	Design Patterns	0.8
32	2026-05-14 04:41:44.24972+00	2026-05-14 06:17:33.086763+00	\N	\N	005.2762 L959f	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Full_Stack_Open_a5028100-7204-4b25-b3c8-22be7101a4f3.jpg	Khóa học full-stack miễn phí của ĐH Helsinki: React, Redux, Node.js, MongoDB, TypeScript, GraphQL, React Native. Được dùng trong chương trình đại học.	1	\N	9789521430046	English	800	2023	13	27x21cm	Deep Dive Into Modern Web Development	Full Stack Open	1.2
24	2026-05-14 04:41:44.24972+00	2026-05-14 06:05:54.881259+00	\N	\N	004.22 P317c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780128203316_7d32ca07-c490-4b08-af73-52c975f5a085.jpg	Kiến trúc máy tính theo RISC-V: datapath, control unit, pipeline, memory hierarchy, I/O và giới thiệu parallelism.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/24/documents/-computer_organization_and_design_3rd_edition.pdf_8ff83362-4e97-495e-b118-03e94126d320.pdf	9780128203316	English	736	2020	9	25x19cm	RISC-V Edition, Second Edition	Computer Organization and Design	1.5
26	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:11.058009+00	\N	\N	005.133 S592y	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781491924464_7fec25e8-472c-4950-b53c-87f218914601.jpg	Khám phá cơ chế nội tại của JavaScript: hoisting, scope, closures, prototype chain, this và async patterns. Sách miễn phí trên GitHub.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/26/documents/You-Dont-Know-JS-Yet-Get-Started-_Kyle-Simpson_-_Z-Library_.pdf_6f93d704-0ade-4928-a4cc-276bf251c342.pdf	9781491924464	English	143	2020	5	23x15cm	Get Started (Series Book 1)	You Don't Know JS Yet	0.3
28	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:32.504509+00	\N	\N	005.133 S972a	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781593279929_8f5f53e6-be80-4c82-9325-664cf4810e2d.jpg	Học Python qua dự án thực tế: xử lý file và folder, web scraping, Excel/Word/PDF, email, lịch, GUI automation với PyAutoGUI.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/28/documents/Automate_The_Boring_Stuff_With_Python.pdf_af651105-724d-4255-a3f8-c03d45cbaeeb.pdf	9781593279929	English	592	2019	11	23x18cm	Second Edition	Automate the Boring Stuff with Python	0.9
30	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:48.730876+00	\N	\N	005.133 D748t	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781491939369_5ec9c37a-23f2-4fc3-91cc-12b63a4b748d.jpg	Nhập môn lập trình Python cho người mới: tư duy thuật toán, hàm, đệ quy, data structures và OOP. Miễn phí online.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/30/documents/thinkpython.pdf_1a4390a3-95af-4d73-8dec-bc025fbc0c5b.pdf	9781491939369	English	291	2015	5	23x18cm	How to Think Like a Computer Scientist, Second Edition	Think Python	0.5
18	2026-05-14 04:41:44.24972+00	2026-05-14 06:04:28.219637+00	\N	\N	006.3 R961a	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780134610993_480ce7fe-340a-4daf-a718-37d66434cfc5.jpg	Sách giáo khoa AI toàn diện nhất: search, game playing, planning, probabilistic reasoning, machine learning, NLP và computer vision.	4	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/18/documents/Artificial_Intelligence_-_A_Modern_Approach.pdf_6b62938d-017f-4089-aeaa-d151facc9710.pdf	9780134610993	English	1132	2020	4	26x21cm	Fourth Edition	Artificial Intelligence: A Modern Approach	2.2
19	2026-05-14 04:41:44.24972+00	2026-05-14 06:04:47.115527+00	\N	\N	006.31 G649d	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780262035613_e2024351-04fc-425a-a59b-bd98bc680410.jpg	Nền tảng lý thuyết về deep learning: MLP, CNN, RNN, regularization, optimization, generative models và practical methodology.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/19/documents/Deep_Learning_Ian_Goodfellow.pdf_4fa3a048-c533-46cf-b290-e42f73c624a9.pdf	9780262035613	English	800	2016	6	24x19cm	An MIT Press Book	Deep Learning	1.6
21	2026-05-14 04:41:44.24972+00	2026-05-14 06:05:29.328291+00	\N	\N	005.74 S587d	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780078022159_bfd51391-379f-4fb3-9e1a-e49635b239f4.jpg	Sách giáo khoa CSDL toàn diện: mô hình quan hệ, SQL, thiết kế bình thường hóa, transaction, concurrency control và NoSQL.	7	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/21/documents/Abraham_Silberschatz__Henry_Korth_and_S._Sudarshan_-_Database_System_Concepts._7-McGraw-Hill_Education__2020_.pdf_a2c792ea-eb40-4770-9fe4-329e9e4839d1.pdf	9780078022159	English	1392	2019	8	26x21cm	Seventh Edition	Database System Concepts	2.3
23	2026-05-14 04:41:44.24972+00	2026-05-14 06:05:45.683658+00	\N	\N	005.453 A284c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780321486813_c923473e-5f1a-4e38-93c4-8fdb97ce8394.jpg	Sách kinh điển về xây dựng trình biên dịch: lexer, parser, semantic analysis, intermediate code, optimization và code generation.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/23/documents/Alfred-V.-Aho-Monica-S.-Lam-Ravi-Sethi-Jeffrey-D.-Ullman-Compilers-Principles-Techniques-and-Tools-Pearson_Addison-Wesley-2007.pdf_0e77a9a5-a04a-4685-8828-ec01168e8793.pdf	9780321486813	English	1009	2006	4	25x19cm	Second Edition (Dragon Book)	Compilers: Principles, Techniques, and Tools	1.8
25	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:06.010256+00	\N	\N	005.1 M139c	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9780735619678_0376434c-1318-41a0-a103-59ac9792db78.jpg	Bách khoa toàn thư về xây dựng phần mềm: từ construction fundamentals, naming, routines, OOP đến testing, debugging và code quality.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/25/documents/code-complete-2nd-edition-v413hav.pdf_e6803289-35ac-4578-b280-22566383b76e.pdf	9780735619678	English	960	2004	10	24x18cm	Second Edition	Code Complete	1.5
27	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:17.386288+00	\N	\N	005.133 H394e	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781593279509_7c308ad4-4a83-499c-9eb0-3cc30943d07c.jpg	Học JavaScript hiệu quả: từ căn bản, lập trình hàm, OOP đến DOM manipulation, Node.js và regular expressions. Miễn phí online.	3	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/27/documents/Eloquent_JavaScript_small.pdf_57734b9d-e6b0-4b3e-9f3b-d4809d62a82f.pdf	9781593279509	English	472	2018	11	23x18cm	A Modern Introduction to Programming	Eloquent JavaScript	0.8
29	2026-05-14 04:41:44.24972+00	2026-05-14 06:06:43.22593+00	\N	\N	005.432 S558l	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781593273897_075b6b99-d6e8-41c0-9079-0ad3ba318243.jpg	Hướng dẫn toàn diện về Linux shell: điều hướng filesystem, text processing, shell scripting, permissions, job control và networking tools.	2	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/29/documents/The_linux_command_line.pdf_783db852-74b5-4218-9b1e-7cf0cc159fe6.pdf	9781593273897	English	504	2019	11	23x18cm	A Complete Introduction, Second Edition	The Linux Command Line	0.8
31	2026-05-14 04:41:44.24972+00	2026-05-14 06:07:18.516081+00	\N	\N	006.31 Z63d	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/cover_9781009389433_be745660-74f4-4aec-a55d-096c46f6fecd.jpg	Tài liệu deep learning tương tác từ Amazon: lý thuyết kèm code PyTorch/TensorFlow, từ linear regression đến Transformer và GAN.	1	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/31/documents/Dive_Into_Deep_Learning.pdf_f6dd0573-5f45-433d-ad99-22674de9a031.pdf	9781009389433	English	1200	2023	12	26x21cm	Interactive Deep Learning Book with PyTorch, JAX, MXNet, and TensorFlow	Dive Into Deep Learning	2
20	2026-05-14 04:41:44.24972+00	2026-05-14 06:13:40.512362+00	\N	\N	006.31 G384h	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/covers/Hands-On_Machine_Learning_with_Scikit-Learn__Keras__and_TensorFlow_ed26f4ff-0779-4b0b-94fc-2b7d4b8b3e4d.jpg	Học ML thực hành từ A-Z: regression, SVM, decision trees với scikit-learn; CNN, RNN, Transformer, GANs với Keras/TensorFlow.	3	https://cnpmnc-document-storage-hk252.s3.ap-southeast-1.amazonaws.com/publications/20/documents/Hands_On_Machine_Learning_with_Scikit_Learn_and_TensorFlow.pdf_140f05cf-b5fd-42b8-9102-67390728a376.pdf	9781098125974	English	861	2022	5	24x18cm	Third Edition	Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow	1.4
\.


--
-- TOC entry 3650 (class 0 OID 16415)
-- Dependencies: 217
-- Data for Name: publishers; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.publishers (id, created_at, updated_at, address, name) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Hà Nội, Việt Nam	NXB Giáo Dục
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Hà Nội, Việt Nam	NXB Khoa Học Kỹ Thuật
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	TP. Hồ Chí Minh, Việt Nam	NXB Trẻ
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	London, United Kingdom	Pearson Education
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sebastopol, CA, USA	O'Reilly Media
6	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Cambridge, MA, USA	MIT Press
7	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Hoboken, NJ, USA	Wiley
8	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	New York, NY, USA	McGraw-Hill Education
9	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Burlington, MA, USA	Morgan Kaufmann
10	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Redmond, WA, USA	Microsoft Press
11	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	San Francisco, CA, USA	No Starch Press
12	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Cambridge, United Kingdom	Cambridge University Press
13	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Internet	Open Source / Online
\.


--
-- TOC entry 3666 (class 0 OID 16619)
-- Dependencies: 233
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.ratings (id, created_at, updated_at, comment, helpful_count, publication_id, star, user_id, verified_borrow) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sách rất hay, giúp tôi viết code sạch hơn rất nhiều!	10	1	5	4	t
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Nội dung sâu sắc nhưng khá khó đọc với người mới.	5	2	4	5	t
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Giáo trình dễ hiểu, ví dụ thực tế rõ ràng.	3	4	5	4	t
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Refactoring rất hữu ích, nhiều kỹ thuật áp dụng được ngay.	7	3	4	5	f
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Nội dung ổn nhưng ví dụ hơi cũ so với Java hiện đại.	2	5	3	4	t
\.


--
-- TOC entry 3661 (class 0 OID 16549)
-- Dependencies: 228
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.refresh_tokens (uuid_token, device_id, expiry_date, revoked, user_id) FROM stdin;
tok-uuid-0001	device-chrome-win	2026-05-21 04:41:44.111352+00	f	4
tok-uuid-0002	device-safari-mac	2026-05-21 04:41:44.111352+00	f	5
tok-uuid-0003	device-firefox-win	2026-05-21 04:41:44.111352+00	f	2
tok-uuid-0004	device-chrome-linux	2026-05-21 04:41:44.111352+00	f	1
tok-uuid-0005	device-mobile-ios	2026-05-13 04:41:44.111352+00	t	4
0QCDB3PS4KWZJ	deviceId	2026-05-21 06:01:27.001039+00	f	2
0QCD48DYMKX00	deviceId	2026-05-21 05:31:30.693567+00	t	842635214450193395
0QCDD5VV0KWXH	deviceId	2026-05-21 06:10:28.968974+00	f	842626525096485525
\.


--
-- TOC entry 3669 (class 0 OID 16688)
-- Dependencies: 236
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.reservations (id, created_at, updated_at, hold_expiration_time, preferred_branch, assigned_item_id, publication_id, queue_position, reservation_date, status, user_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	Cơ sở 1 - Lý Thường Kiệt	\N	1	1	2026-05-09 04:41:44.111352+00	PENDING	5
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	ANY	\N	2	1	2026-05-11 04:41:44.111352+00	PENDING	4
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	Cơ sở 2 - Dĩ An	\N	5	1	2026-04-29 04:41:44.111352+00	COMPLETED	5
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	ANY	\N	3	1	2026-04-24 04:41:44.111352+00	CANCELLED	4
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	\N	Cơ sở 1 - Lý Thường Kiệt	\N	4	1	2026-04-19 04:41:44.111352+00	EXPIRED	5
\.


--
-- TOC entry 3652 (class 0 OID 16428)
-- Dependencies: 219
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.roles (id, created_at, updated_at, description, role_name) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Quản trị viên hệ thống	ADMIN
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Thủ thư quản lý sách và giao dịch	LIBRARIAN
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Sinh viên mượn sách	STUDENT
\.


--
-- TOC entry 3662 (class 0 OID 16565)
-- Dependencies: 229
-- Data for Name: search_history; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.search_history (id, created_at, updated_at, search_query, user_id) FROM stdin;
1	2026-05-09 04:41:44.111352+00	2026-05-09 04:41:44.111352+00	clean code	4
2	2026-05-10 04:41:44.111352+00	2026-05-10 04:41:44.111352+00	java spring boot	4
3	2026-05-11 04:41:44.111352+00	2026-05-11 04:41:44.111352+00	domain driven design	5
4	2026-05-12 04:41:44.111352+00	2026-05-12 04:41:44.111352+00	cơ sở dữ liệu	5
5	2026-05-13 04:41:44.111352+00	2026-05-13 04:41:44.111352+00	refactoring martin fowler	4
\.


--
-- TOC entry 3651 (class 0 OID 16421)
-- Dependencies: 218
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.tags (id, created_at, updated_at, name) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Java
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Clean Code
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Architecture
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Database
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Machine Learning
6	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Python
7	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	JavaScript
8	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Linux
9	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Algorithms
10	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Neural Networks
11	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Web Development
12	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Operating Systems
13	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Networking
14	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Compiler Design
15	2026-05-14 04:41:44.24972+00	2026-05-14 04:41:44.24972+00	Mathematics
\.


--
-- TOC entry 3667 (class 0 OID 16641)
-- Dependencies: 234
-- Data for Name: user_interactions; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.user_interactions (id, created_at, updated_at, publication_id, type, user_id) FROM stdin;
1	2026-05-04 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	1	BORROWED	4
2	2026-05-06 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2	WISHLIST	4
3	2026-05-08 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	1	WATCH	5
4	2026-05-10 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	3	WISHLIST	5
5	2026-05-12 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	5	WATCH	4
\.


--
-- TOC entry 3663 (class 0 OID 16578)
-- Dependencies: 230
-- Data for Name: user_notifications; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.user_notifications (id, created_at, updated_at, is_read, read_at, notification_id, user_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	t	\N	1	4
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	f	\N	2	5
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	t	\N	3	4
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	f	\N	4	5
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	t	\N	5	5
\.


--
-- TOC entry 3660 (class 0 OID 16534)
-- Dependencies: 227
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.user_roles (user_id, role_id) FROM stdin;
1	1
2	2
3	2
4	3
5	3
6	3
842626522743481032	3
842626525096485525	2
842635214450193395	3
\.


--
-- TOC entry 3654 (class 0 OID 16444)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.users (id, created_at, updated_at, address, ai_personalization_enabled, credit_score, date_of_birth, email, faculty, full_name, hashed_password, last_login_at, phone_number, profile_picture_url, provider, provider_id, status, student_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	TP. Hồ Chí Minh	f	100	1990-01-15	admin@hcmut.edu.vn	\N	Nguyễn Quản Trị	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0901000001	\N	\N	\N	ACTIVE	\N
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Bình Dương	f	100	1988-06-20	librarian1@hcmut.edu.vn	\N	Trần Thủ Thư	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0901000002	\N	\N	\N	ACTIVE	\N
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	TP. Hồ Chí Minh	f	100	1992-03-10	librarian2@hcmut.edu.vn	\N	Lê Thị Thủ Thư	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0901000003	\N	\N	\N	ACTIVE	\N
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Thủ Đức, TP. Hồ Chí Minh	t	95	2003-08-25	phamvan.2151234@hcmut.edu.vn	KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH	Phạm Văn Sinh Viên	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0901000004	\N	\N	\N	ACTIVE	2151234
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	Bình Thạnh, TP. Hồ Chí Minh	t	100	2003-11-30	nguyenthi.2152345@hcmut.edu.vn	KHOA_DIEN_DIEN_TU	Nguyễn Thị Học Viên	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0901000005	\N	\N	\N	ACTIVE	2152345
6	2026-05-14 04:41:44.20209+00	2026-05-14 04:41:44.20209+00	TP. Hồ Chí Minh	f	100	2003-01-01	test.student@hcmut.edu.vn	KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH	Nguyễn Test Sinh Viên	$2a$10$B0AIAFUtwqSvnO46IogPfeaUR/SRYXGgQcezUasUWpbBMM9R/DCB6	\N	0909000006	\N	\N	\N	ACTIVE	2199999
842626522743481032	2026-05-14 04:56:58.414526+00	\N	\N	t	100	\N	student@hcmut.edu.vn	\N	System Administrator	$2a$10$bPcPrweDTnHpM97TDOZqa.oeCXl1T1.4Vf7iLzKfvfJnTUQhCHNr.	\N	\N	\N	\N	\N	ACTIVE	\N
842626525096485525	2026-05-14 04:56:58.833102+00	\N	\N	t	100	\N	librarian@hcmut.edu.vn	\N	System Administrator	$2a$10$nRXh.XkvLAvENwHn0nvQW.bvampdJoeFZJnfbf4KO3x7iAiusuoTO	\N	\N	\N	\N	\N	ACTIVE	\N
842635214450193395	2026-05-14 05:31:30.572555+00	2026-05-14 05:31:34.887139+00	\N	t	100	\N	thang.vokhmt04k22@hcmut.edu.vn	KHOA_KHOA_HOC_VA_KY_THUAT_MAY_TINH	VÕ QUANG THẮNG	\N	\N	\N	https://lh3.googleusercontent.com/a/ACg8ocKlchwO0kex-3v1wV9QMMDiOx-UOCmovunUHpUKIqQPQd7pRg=s96-c	google	102592700440162437076	ACTIVE	2213214
\.


--
-- TOC entry 3664 (class 0 OID 16594)
-- Dependencies: 231
-- Data for Name: wish_lists; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.wish_lists (id, created_at, updated_at, user_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	4
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	5
\.


--
-- TOC entry 3665 (class 0 OID 16604)
-- Dependencies: 232
-- Data for Name: wish_lists_item; Type: TABLE DATA; Schema: public; Owner: library
--

COPY public.wish_lists_item (id, created_at, updated_at, added_at, publication_id, wish_list_id) FROM stdin;
1	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-09 04:41:44.111352+00	2	1
2	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-11 04:41:44.111352+00	3	1
3	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-07 04:41:44.111352+00	1	2
4	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-12 04:41:44.111352+00	5	2
5	2026-05-14 04:41:44.111352+00	2026-05-14 04:41:44.111352+00	2026-05-13 04:41:44.111352+00	5	1
\.


--
-- TOC entry 3472 (class 2606 OID 16747)
-- Name: ai_recommendations ai_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ai_recommendations
    ADD CONSTRAINT ai_recommendations_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3385 (class 2606 OID 16404)
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- TOC entry 3455 (class 2606 OID 16664)
-- Name: borrowing_transactions borrowing_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.borrowing_transactions
    ADD CONSTRAINT borrowing_transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 3387 (class 2606 OID 16411)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3466 (class 2606 OID 16720)
-- Name: fines fines_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.fines
    ADD CONSTRAINT fines_pkey PRIMARY KEY (id);


--
-- TOC entry 3382 (class 2606 OID 16396)
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- TOC entry 3389 (class 2606 OID 16413)
-- Name: categories idx_category_name; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT idx_category_name UNIQUE (name);


--
-- TOC entry 3399 (class 2606 OID 16434)
-- Name: roles idx_role_name; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT idx_role_name UNIQUE (role_name);


--
-- TOC entry 3395 (class 2606 OID 16427)
-- Name: tags idx_tag_name; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT idx_tag_name UNIQUE (name);


--
-- TOC entry 3417 (class 2606 OID 16480)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 3403 (class 2606 OID 16443)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 3470 (class 2606 OID 16736)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (token);


--
-- TOC entry 3421 (class 2606 OID 16493)
-- Name: publication_authors publication_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT publication_authors_pkey PRIMARY KEY (id);


--
-- TOC entry 3423 (class 2606 OID 16508)
-- Name: publication_categories publication_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_categories
    ADD CONSTRAINT publication_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3425 (class 2606 OID 16523)
-- Name: publication_tags publication_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_tags
    ADD CONSTRAINT publication_tags_pkey PRIMARY KEY (id);


--
-- TOC entry 3412 (class 2606 OID 16464)
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- TOC entry 3393 (class 2606 OID 16419)
-- Name: publishers publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- TOC entry 3447 (class 2606 OID 16625)
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- TOC entry 3430 (class 2606 OID 16556)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (uuid_token);


--
-- TOC entry 3464 (class 2606 OID 16694)
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- TOC entry 3401 (class 2606 OID 16432)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3435 (class 2606 OID 16571)
-- Name: search_history search_history_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.search_history
    ADD CONSTRAINT search_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3397 (class 2606 OID 16425)
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- TOC entry 3432 (class 2606 OID 16558)
-- Name: refresh_tokens uk2m0kbqvkxcesg5q10ey1tu5o0; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT uk2m0kbqvkxcesg5q10ey1tu5o0 UNIQUE (user_id, device_id);


--
-- TOC entry 3406 (class 2606 OID 16455)
-- Name: users uk6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- TOC entry 3419 (class 2606 OID 16482)
-- Name: items uk863wqhi5cukg9lfl6i36lyhfu; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT uk863wqhi5cukg9lfl6i36lyhfu UNIQUE (barcode);


--
-- TOC entry 3449 (class 2606 OID 16627)
-- Name: ratings uk_user_publication; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT uk_user_publication UNIQUE (user_id, publication_id);


--
-- TOC entry 3414 (class 2606 OID 16466)
-- Name: publications uke6kemjuf6bi5uyyba0eyit1cx; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT uke6kemjuf6bi5uyyba0eyit1cx UNIQUE (isbn);


--
-- TOC entry 3453 (class 2606 OID 16646)
-- Name: user_interactions user_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_interactions
    ADD CONSTRAINT user_interactions_pkey PRIMARY KEY (id);


--
-- TOC entry 3438 (class 2606 OID 16582)
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 3427 (class 2606 OID 16538)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- TOC entry 3408 (class 2606 OID 16453)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3442 (class 2606 OID 16608)
-- Name: wish_lists_item wish_lists_item_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.wish_lists_item
    ADD CONSTRAINT wish_lists_item_pkey PRIMARY KEY (id);


--
-- TOC entry 3440 (class 2606 OID 16598)
-- Name: wish_lists wish_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 1259 OID 16397)
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- TOC entry 3473 (class 1259 OID 16753)
-- Name: idx_ai_recommendations_computed_at; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_ai_recommendations_computed_at ON public.ai_recommendations USING btree (computed_at);


--
-- TOC entry 3456 (class 1259 OID 16685)
-- Name: idx_borrow_due_date; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_borrow_due_date ON public.borrowing_transactions USING btree (due_date);


--
-- TOC entry 3457 (class 1259 OID 16686)
-- Name: idx_borrow_item_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_borrow_item_id ON public.borrowing_transactions USING btree (item_id);


--
-- TOC entry 3458 (class 1259 OID 16687)
-- Name: idx_borrow_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_borrow_user_id ON public.borrowing_transactions USING btree (user_id);


--
-- TOC entry 3404 (class 1259 OID 16456)
-- Name: idx_email; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_email ON public.users USING btree (email);


--
-- TOC entry 3467 (class 1259 OID 16726)
-- Name: idx_fine_transaction_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_fine_transaction_id ON public.fines USING btree (transaction_id);


--
-- TOC entry 3450 (class 1259 OID 16657)
-- Name: idx_interaction_timestamp; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_interaction_timestamp ON public.user_interactions USING btree (created_at);


--
-- TOC entry 3451 (class 1259 OID 16658)
-- Name: idx_interaction_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_interaction_user_id ON public.user_interactions USING btree (user_id);


--
-- TOC entry 3415 (class 1259 OID 16488)
-- Name: idx_item_publication_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_item_publication_id ON public.items USING btree (publication_id);


--
-- TOC entry 3390 (class 1259 OID 16414)
-- Name: idx_parent_category; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_parent_category ON public.categories USING btree (parent_category_id);


--
-- TOC entry 3468 (class 1259 OID 16737)
-- Name: idx_password_reset_tokens_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_password_reset_tokens_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- TOC entry 3409 (class 1259 OID 16472)
-- Name: idx_publication_publisher; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_publication_publisher ON public.publications USING btree (publisher_id);


--
-- TOC entry 3410 (class 1259 OID 16473)
-- Name: idx_publication_title; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_publication_title ON public.publications USING btree (title);


--
-- TOC entry 3391 (class 1259 OID 16420)
-- Name: idx_publisher_name; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_publisher_name ON public.publishers USING btree (name);


--
-- TOC entry 3443 (class 1259 OID 16638)
-- Name: idx_rating_publication_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_rating_publication_id ON public.ratings USING btree (publication_id);


--
-- TOC entry 3444 (class 1259 OID 16639)
-- Name: idx_rating_star; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_rating_star ON public.ratings USING btree (star);


--
-- TOC entry 3445 (class 1259 OID 16640)
-- Name: idx_rating_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_rating_user_id ON public.ratings USING btree (user_id);


--
-- TOC entry 3428 (class 1259 OID 16564)
-- Name: idx_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- TOC entry 3459 (class 1259 OID 16713)
-- Name: idx_reservation_assigned_item; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_reservation_assigned_item ON public.reservations USING btree (assigned_item_id);


--
-- TOC entry 3460 (class 1259 OID 16710)
-- Name: idx_reservation_publication_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_reservation_publication_id ON public.reservations USING btree (publication_id);


--
-- TOC entry 3461 (class 1259 OID 16711)
-- Name: idx_reservation_status; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_reservation_status ON public.reservations USING btree (status);


--
-- TOC entry 3462 (class 1259 OID 16712)
-- Name: idx_reservation_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_reservation_user_id ON public.reservations USING btree (user_id);


--
-- TOC entry 3433 (class 1259 OID 16577)
-- Name: idx_search_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_search_user_id ON public.search_history USING btree (user_id);


--
-- TOC entry 3436 (class 1259 OID 16593)
-- Name: idx_user_notification_user_id; Type: INDEX; Schema: public; Owner: library
--

CREATE INDEX idx_user_notification_user_id ON public.user_notifications USING btree (user_id);


--
-- TOC entry 3504 (class 2606 OID 16748)
-- Name: ai_recommendations ai_recommendations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ai_recommendations
    ADD CONSTRAINT ai_recommendations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3496 (class 2606 OID 16665)
-- Name: borrowing_transactions fk_borrow_item; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.borrowing_transactions
    ADD CONSTRAINT fk_borrow_item FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- TOC entry 3497 (class 2606 OID 16675)
-- Name: borrowing_transactions fk_borrow_librarian_issue; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.borrowing_transactions
    ADD CONSTRAINT fk_borrow_librarian_issue FOREIGN KEY (librarian_id_issue) REFERENCES public.users(id);


--
-- TOC entry 3498 (class 2606 OID 16680)
-- Name: borrowing_transactions fk_borrow_librarian_return; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.borrowing_transactions
    ADD CONSTRAINT fk_borrow_librarian_return FOREIGN KEY (librarian_id_return) REFERENCES public.users(id);


--
-- TOC entry 3499 (class 2606 OID 16670)
-- Name: borrowing_transactions fk_borrow_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.borrowing_transactions
    ADD CONSTRAINT fk_borrow_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3474 (class 2606 OID 16727)
-- Name: categories fk_category_parent; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) REFERENCES public.categories(id);


--
-- TOC entry 3503 (class 2606 OID 16721)
-- Name: fines fk_fine_transaction; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.fines
    ADD CONSTRAINT fk_fine_transaction FOREIGN KEY (transaction_id) REFERENCES public.borrowing_transactions(id);


--
-- TOC entry 3494 (class 2606 OID 16647)
-- Name: user_interactions fk_interaction_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_interactions
    ADD CONSTRAINT fk_interaction_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3495 (class 2606 OID 16652)
-- Name: user_interactions fk_interaction_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_interactions
    ADD CONSTRAINT fk_interaction_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3476 (class 2606 OID 16483)
-- Name: items fk_item_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_item_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3477 (class 2606 OID 16494)
-- Name: publication_authors fk_pub_author_author; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT fk_pub_author_author FOREIGN KEY (author_id) REFERENCES public.authors(id);


--
-- TOC entry 3478 (class 2606 OID 16499)
-- Name: publication_authors fk_pub_author_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT fk_pub_author_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3479 (class 2606 OID 16509)
-- Name: publication_categories fk_pub_category_category; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_categories
    ADD CONSTRAINT fk_pub_category_category FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 3480 (class 2606 OID 16514)
-- Name: publication_categories fk_pub_category_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_categories
    ADD CONSTRAINT fk_pub_category_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3481 (class 2606 OID 16524)
-- Name: publication_tags fk_pub_tag_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_tags
    ADD CONSTRAINT fk_pub_tag_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3482 (class 2606 OID 16529)
-- Name: publication_tags fk_pub_tag_tag; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publication_tags
    ADD CONSTRAINT fk_pub_tag_tag FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- TOC entry 3475 (class 2606 OID 16467)
-- Name: publications fk_publication_publisher; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT fk_publication_publisher FOREIGN KEY (publisher_id) REFERENCES public.publishers(id);


--
-- TOC entry 3492 (class 2606 OID 16628)
-- Name: ratings fk_rating_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT fk_rating_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3493 (class 2606 OID 16633)
-- Name: ratings fk_rating_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT fk_rating_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3485 (class 2606 OID 16559)
-- Name: refresh_tokens fk_refresh_token_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT fk_refresh_token_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3500 (class 2606 OID 16705)
-- Name: reservations fk_reservation_assigned_item; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservation_assigned_item FOREIGN KEY (assigned_item_id) REFERENCES public.items(id);


--
-- TOC entry 3501 (class 2606 OID 16695)
-- Name: reservations fk_reservation_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservation_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3502 (class 2606 OID 16700)
-- Name: reservations fk_reservation_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservation_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3486 (class 2606 OID 16572)
-- Name: search_history fk_search_history_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.search_history
    ADD CONSTRAINT fk_search_history_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3487 (class 2606 OID 16583)
-- Name: user_notifications fk_user_notification_notification; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT fk_user_notification_notification FOREIGN KEY (notification_id) REFERENCES public.notifications(id);


--
-- TOC entry 3488 (class 2606 OID 16588)
-- Name: user_notifications fk_user_notification_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT fk_user_notification_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3490 (class 2606 OID 16614)
-- Name: wish_lists_item fk_wish_list_item_publication; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.wish_lists_item
    ADD CONSTRAINT fk_wish_list_item_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id);


--
-- TOC entry 3491 (class 2606 OID 16609)
-- Name: wish_lists_item fk_wish_list_item_wish_list; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.wish_lists_item
    ADD CONSTRAINT fk_wish_list_item_wish_list FOREIGN KEY (wish_list_id) REFERENCES public.wish_lists(id);


--
-- TOC entry 3489 (class 2606 OID 16599)
-- Name: wish_lists fk_wish_list_user; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT fk_wish_list_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3483 (class 2606 OID 16544)
-- Name: user_roles fkh8ciramu9cc9q3qcqiv4ue8a6; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fkh8ciramu9cc9q3qcqiv4ue8a6 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- TOC entry 3484 (class 2606 OID 16539)
-- Name: user_roles fkhfh9dx7w3ubf1co1vdev94g3f; Type: FK CONSTRAINT; Schema: public; Owner: library
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fkhfh9dx7w3ubf1co1vdev94g3f FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2026-05-14 13:26:01

--
-- PostgreSQL database dump complete
--

