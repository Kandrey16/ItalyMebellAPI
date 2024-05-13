--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO postgres;

--
-- Name: attribute_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attribute_groups (
    id_attribute_group integer NOT NULL,
    name_attribute_group character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.attribute_groups OWNER TO postgres;

--
-- Name: attribute_groups_id_attribute_group_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attribute_groups_id_attribute_group_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attribute_groups_id_attribute_group_seq OWNER TO postgres;

--
-- Name: attribute_groups_id_attribute_group_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attribute_groups_id_attribute_group_seq OWNED BY public.attribute_groups.id_attribute_group;


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attributes (
    id_attribute integer NOT NULL,
    name_attribute character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_attribute_group integer
);


ALTER TABLE public.attributes OWNER TO postgres;

--
-- Name: attributes_id_attribute_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attributes_id_attribute_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attributes_id_attribute_seq OWNER TO postgres;

--
-- Name: attributes_id_attribute_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attributes_id_attribute_seq OWNED BY public.attributes.id_attribute;


--
-- Name: cart_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_products (
    id_cart_product integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_cart integer,
    id_product integer,
    count_cart_product integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.cart_products OWNER TO postgres;

--
-- Name: cart_products_id_cart_product_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_products_id_cart_product_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cart_products_id_cart_product_seq OWNER TO postgres;

--
-- Name: cart_products_id_cart_product_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_products_id_cart_product_seq OWNED BY public.cart_products.id_cart_product;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carts (
    id_cart integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    email_user character varying(255)
);


ALTER TABLE public.carts OWNER TO postgres;

--
-- Name: carts_id_cart_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carts_id_cart_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.carts_id_cart_seq OWNER TO postgres;

--
-- Name: carts_id_cart_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carts_id_cart_seq OWNED BY public.carts.id_cart;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id_category integer NOT NULL,
    name_category character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    img_category character varying(255)
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_category_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_category_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_category_seq OWNER TO postgres;

--
-- Name: categories_id_category_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_category_seq OWNED BY public.categories.id_category;


--
-- Name: image_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_comments (
    id_image_comment integer NOT NULL,
    url_image_comment text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_product_comment integer
);


ALTER TABLE public.image_comments OWNER TO postgres;

--
-- Name: image_comments_id_image_comment_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_comments_id_image_comment_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_comments_id_image_comment_seq OWNER TO postgres;

--
-- Name: image_comments_id_image_comment_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.image_comments_id_image_comment_seq OWNED BY public.image_comments.id_image_comment;


--
-- Name: order_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_addresses (
    id_order_address integer NOT NULL,
    address_order text NOT NULL,
    entrance_order integer,
    floor_order integer,
    home_code_order character varying(255) DEFAULT NULL::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    email_user character varying(255)
);


ALTER TABLE public.order_addresses OWNER TO postgres;

--
-- Name: order_addresses_id_order_address_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_addresses_id_order_address_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_addresses_id_order_address_seq OWNER TO postgres;

--
-- Name: order_addresses_id_order_address_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_addresses_id_order_address_seq OWNED BY public.order_addresses.id_order_address;


--
-- Name: order_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_products (
    id_order_product integer NOT NULL,
    count_order_product integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_order integer,
    id_product integer
);


ALTER TABLE public.order_products OWNER TO postgres;

--
-- Name: order_products_id_order_product_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_products_id_order_product_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_products_id_order_product_seq OWNER TO postgres;

--
-- Name: order_products_id_order_product_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_products_id_order_product_seq OWNED BY public.order_products.id_order_product;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id_order integer NOT NULL,
    number_order integer NOT NULL,
    price_order numeric(18,2) NOT NULL,
    date_order timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_order_address integer
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_order_seq OWNER TO postgres;

--
-- Name: orders_id_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_order_seq OWNED BY public.orders.id_order;


--
-- Name: product_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_comments (
    id_product_comment integer NOT NULL,
    mark_comment integer NOT NULL,
    description_comment text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_product integer,
    email_user character varying(255)
);


ALTER TABLE public.product_comments OWNER TO postgres;

--
-- Name: product_comments_id_product_comment_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_comments_id_product_comment_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_comments_id_product_comment_seq OWNER TO postgres;

--
-- Name: product_comments_id_product_comment_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_comments_id_product_comment_seq OWNED BY public.product_comments.id_product_comment;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_images (
    id_product_image integer NOT NULL,
    url_image text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_product integer
);


ALTER TABLE public.product_images OWNER TO postgres;

--
-- Name: product_images_id_product_image_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_images_id_product_image_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_images_id_product_image_seq OWNER TO postgres;

--
-- Name: product_images_id_product_image_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_images_id_product_image_seq OWNED BY public.product_images.id_product_image;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id_product integer NOT NULL,
    article_product character varying(255) DEFAULT NULL::character varying,
    name_product character varying(255) NOT NULL,
    price_product numeric(10,2) NOT NULL,
    description_product text NOT NULL,
    count_product integer NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    url_main_image_product text,
    id_category text,
    rating numeric(10,2)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_product_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_product_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_product_seq OWNER TO postgres;

--
-- Name: products_id_product_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_product_seq OWNED BY public.products.id_product;


--
-- Name: specifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specifications (
    id_specification integer NOT NULL,
    value_specification character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_attribute integer,
    id_product integer
);


ALTER TABLE public.specifications OWNER TO postgres;

--
-- Name: specifications_id_specification_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specifications_id_specification_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.specifications_id_specification_seq OWNER TO postgres;

--
-- Name: specifications_id_specification_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specifications_id_specification_seq OWNED BY public.specifications.id_specification;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    email_user character varying(255) NOT NULL,
    password_user text NOT NULL,
    role_user character varying(255) DEFAULT 'USER'::character varying NOT NULL,
    first_name_user character varying(255) DEFAULT NULL::character varying,
    second_name_user character varying(255) DEFAULT NULL::character varying,
    phone_number_client text,
    image_user_profile text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: winston_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.winston_logs (
    level character varying,
    message character varying,
    meta json,
    "timestamp" timestamp without time zone DEFAULT now()
);


ALTER TABLE public.winston_logs OWNER TO postgres;

--
-- Name: attribute_groups id_attribute_group; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_groups ALTER COLUMN id_attribute_group SET DEFAULT nextval('public.attribute_groups_id_attribute_group_seq'::regclass);


--
-- Name: attributes id_attribute; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes ALTER COLUMN id_attribute SET DEFAULT nextval('public.attributes_id_attribute_seq'::regclass);


--
-- Name: cart_products id_cart_product; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_products ALTER COLUMN id_cart_product SET DEFAULT nextval('public.cart_products_id_cart_product_seq'::regclass);


--
-- Name: carts id_cart; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts ALTER COLUMN id_cart SET DEFAULT nextval('public.carts_id_cart_seq'::regclass);


--
-- Name: categories id_category; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id_category SET DEFAULT nextval('public.categories_id_category_seq'::regclass);


--
-- Name: image_comments id_image_comment; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_comments ALTER COLUMN id_image_comment SET DEFAULT nextval('public.image_comments_id_image_comment_seq'::regclass);


--
-- Name: order_addresses id_order_address; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_addresses ALTER COLUMN id_order_address SET DEFAULT nextval('public.order_addresses_id_order_address_seq'::regclass);


--
-- Name: order_products id_order_product; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_products ALTER COLUMN id_order_product SET DEFAULT nextval('public.order_products_id_order_product_seq'::regclass);


--
-- Name: orders id_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_order SET DEFAULT nextval('public.orders_id_order_seq'::regclass);


--
-- Name: product_comments id_product_comment; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_comments ALTER COLUMN id_product_comment SET DEFAULT nextval('public.product_comments_id_product_comment_seq'::regclass);


--
-- Name: product_images id_product_image; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id_product_image SET DEFAULT nextval('public.product_images_id_product_image_seq'::regclass);


--
-- Name: products id_product; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id_product SET DEFAULT nextval('public.products_id_product_seq'::regclass);


--
-- Name: specifications id_specification; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications ALTER COLUMN id_specification SET DEFAULT nextval('public.specifications_id_specification_seq'::regclass);


--
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SequelizeMeta" (name) FROM stdin;
20240123185400-updatePasswordConstraints.js
20240123191926-updatePasswordConstraints.js
20240125141931-removenumbervalidate.js
20240227170802-add_category_migration.js
20240227172111-add_id_category_migration.js
20240308105926-addtables.js
20240315163109-addcount_cart_product_migration.js
20240331091104-refactor-order-product-fk.js
20240401075829-add-id--product-to-order-products.js
20240413192831-add-img-category-field.js
20240418145648-add-rating-to-product.js
\.


--
-- Data for Name: attribute_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attribute_groups (id_attribute_group, name_attribute_group, "createdAt", "updatedAt") FROM stdin;
1	Ширина	2024-02-25 17:50:49.498+03	2024-02-25 17:50:49.498+03
2	Размеры	2024-03-08 10:32:59.262+03	2024-03-08 10:32:59.262+03
3	Цвет	2024-04-06 23:03:06.04+03	2024-04-07 13:09:10.195+03
\.


--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attributes (id_attribute, name_attribute, "createdAt", "updatedAt", id_attribute_group) FROM stdin;
2	Цвет	2024-03-09 21:03:15.269+03	2024-03-09 21:03:15.269+03	1
1	Ширина	2024-02-25 17:50:14.884+03	2024-03-24 11:23:48.778+03	1
3	Длина	2024-04-07 12:53:11.282+03	2024-04-07 17:22:19.092+03	2
\.


--
-- Data for Name: cart_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_products (id_cart_product, "createdAt", "updatedAt", id_cart, id_product, count_cart_product) FROM stdin;
44	2024-03-13 21:06:25.128+03	2024-03-13 21:06:25.128+03	4	64	0
132	2024-04-18 19:51:59.494+03	2024-04-18 19:51:59.494+03	1	135	1
45	2024-03-13 21:06:35.591+03	2024-03-13 21:06:35.591+03	4	\N	0
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (id_cart, "createdAt", "updatedAt", email_user) FROM stdin;
1	2024-03-08 19:12:39.652+03	2024-03-08 19:12:39.652+03	akurdelov@gmail.com
4	2024-03-13 19:03:36.87+03	2024-03-13 19:03:36.87+03	kandrey16@yandex.ru
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id_category, name_category, "createdAt", "updatedAt", img_category) FROM stdin;
55	Стулья	2024-04-05 11:12:59.893+03	2024-04-13 22:34:43.025+03	b8198836-4641-422d-b108-36bb4f749789.jpg
56	Столы	2024-04-05 11:13:08.183+03	2024-04-14 12:12:33.304+03	a94f532e-f620-4fdc-921c-8b0013a5233a.jpg
57	Шкафы	2024-04-05 11:13:18.318+03	2024-04-14 12:13:32.437+03	6bc01b73-6b12-4d96-b07d-148142f55df9.jpg
58	Тумбы	2024-04-05 11:13:31.565+03	2024-04-14 12:14:27.921+03	d34bbbe3-cf7b-4e6f-b71d-1426ad42d25d.jpg
59	Диваны	2024-04-05 11:13:39.52+03	2024-04-14 12:15:03.159+03	f167753d-4539-4ead-acfc-15dc57ad85c3.jpg
60	Кровати	2024-04-05 11:13:46.325+03	2024-04-14 12:15:31.314+03	21a6d8a1-93a2-4149-ab8c-0da6db41f08b.jpg
61	Комоды	2024-04-05 11:13:53.829+03	2024-04-14 12:16:20.07+03	600faa2f-83ac-4935-83de-2948dd5f9904.jpg
62	Кушетки	2024-04-05 11:13:59.764+03	2024-04-14 12:16:57.772+03	ceeff152-d42a-4a00-8709-1e3c80654ff7.jpg
63	Табуреты	2024-04-05 11:14:07.458+03	2024-04-14 12:17:28.798+03	d704d2c0-951f-403a-8b72-1d84c8a3cfbb.jpg
\.


--
-- Data for Name: image_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.image_comments (id_image_comment, url_image_comment, "createdAt", "updatedAt", id_product_comment) FROM stdin;
1	https://i.pinimg.com/originals/5e/e3/3d/5ee33defad930238b8065771f35429f6.jpg	2024-01-25 20:15:36.809+03	2024-01-25 20:15:36.809+03	1
\.


--
-- Data for Name: order_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_addresses (id_order_address, address_order, entrance_order, floor_order, home_code_order, "createdAt", "updatedAt", email_user) FROM stdin;
1	Улица дружная	1	1	123qwer	2024-01-25 19:45:08.526+03	2024-01-25 19:46:04.251+03	akurdelov@gmail.com
2	Улица Пример 123	1	5	ABC123	2024-03-31 13:18:40.977+03	2024-03-31 13:18:40.977+03	\N
3	Новый адрес 789	2	7	XYZ789	2024-03-31 21:19:34.41+03	2024-03-31 21:19:34.41+03	akurdelov@gmail.com
6	qwerty	1	1	1	2024-03-31 21:37:19.241+03	2024-03-31 21:37:19.241+03	akurdelov@gmail.com
14	Улица Пример 123	1	5	ABC123	2024-04-01 16:33:09.008+03	2024-04-01 16:33:09.008+03	\N
16	Улица Пример 123	1	5	ABC123	2024-04-02 18:29:59.372+03	2024-04-02 18:29:59.372+03	\N
18	Улица Пример 123	1	5	ABC123	2024-04-02 18:40:01.352+03	2024-04-02 18:40:01.352+03	\N
19	Улица Пример 123	1	5	ABC123	2024-04-02 18:45:10.906+03	2024-04-02 18:45:10.906+03	\N
22	Улица Пример 123	1	5	ABC123	2024-04-02 19:22:54.049+03	2024-04-02 19:22:54.049+03	akurdelov@gmail.com
23	Улица 123	11	11	111	2024-04-02 19:35:51.212+03	2024-04-02 19:35:51.212+03	akurdelov@gmail.com
24	Адрес	1	1	1	2024-04-02 20:27:12.657+03	2024-04-02 20:27:12.657+03	akurdelov@gmail.com
25	123	1	1	1	2024-04-02 20:34:11.678+03	2024-04-02 20:34:11.678+03	akurdelov@gmail.com
26	55	55	55	55	2024-04-02 20:37:22.891+03	2024-04-02 20:37:22.891+03	akurdelov@gmail.com
27	565656	5656	5656	5656	2024-04-02 21:33:05.698+03	2024-04-02 21:33:05.698+03	akurdelov@gmail.com
28	45	45	45	45	2024-04-02 21:36:17.772+03	2024-04-02 21:36:17.772+03	akurdelov@gmail.com
29	9	9	9	9	2024-04-02 21:38:10.738+03	2024-04-02 21:38:10.738+03	akurdelov@gmail.com
30	Нахимовский проспект 21	1	1	1	2024-04-12 22:21:18.805+03	2024-04-12 22:21:18.805+03	akurdelov@gmail.com
31	Нахимовский проспект 21	1	1	1	2024-04-12 22:26:44.161+03	2024-04-12 22:26:44.161+03	akurdelov@gmail.com
34	Улица Пример 12311	1	5	ABC123	2024-04-15 15:00:49.672+03	2024-04-15 15:00:49.672+03	akurdelov@gmail.com
37	Улица Пример 12311	1	5	ABC123	2024-04-15 15:21:56.675+03	2024-04-15 15:21:56.675+03	akurdelov@gmail.com
\.


--
-- Data for Name: order_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_products (id_order_product, count_order_product, "createdAt", "updatedAt", id_order, id_product) FROM stdin;
1	10	2024-01-25 21:08:15.901+03	2024-01-25 21:08:15.901+03	1	90
2	10	2024-03-31 12:59:53.015+03	2024-03-31 12:59:53.015+03	1	90
3	2	2024-03-31 13:18:40.997+03	2024-03-31 13:18:40.997+03	2	90
4	1	2024-03-31 21:19:34.429+03	2024-03-31 21:19:34.429+03	3	90
5	1	2024-03-31 21:37:19.249+03	2024-03-31 21:37:19.249+03	6	90
9	2	2024-04-01 16:33:09.021+03	2024-04-01 16:33:09.021+03	14	\N
10	2	2024-04-02 18:29:59.377+03	2024-04-02 18:29:59.377+03	16	\N
11	2	2024-04-02 18:40:01.494+03	2024-04-02 18:40:01.494+03	18	135
12	2	2024-04-02 18:45:10.948+03	2024-04-02 18:45:10.948+03	19	64
13	2	2024-04-02 18:45:10.951+03	2024-04-02 18:45:10.951+03	19	89
16	2	2024-04-02 19:22:54.105+03	2024-04-02 19:22:54.105+03	22	64
17	2	2024-04-02 19:22:54.107+03	2024-04-02 19:22:54.107+03	22	89
18	1	2024-04-02 19:35:51.253+03	2024-04-02 19:35:51.253+03	23	135
19	1	2024-04-02 20:27:12.698+03	2024-04-02 20:27:12.698+03	24	135
20	1	2024-04-02 20:34:11.719+03	2024-04-02 20:34:11.719+03	25	135
21	1	2024-04-02 20:37:22.896+03	2024-04-02 20:37:22.896+03	26	135
22	1	2024-04-02 21:33:05.739+03	2024-04-02 21:33:05.739+03	27	135
23	4	2024-04-02 21:36:17.781+03	2024-04-02 21:36:17.781+03	28	135
24	1	2024-04-02 21:38:10.746+03	2024-04-02 21:38:10.746+03	29	64
25	3	2024-04-12 22:21:18.9+03	2024-04-12 22:21:18.9+03	30	135
26	1	2024-04-12 22:26:44.37+03	2024-04-12 22:26:44.37+03	31	135
27	2	2024-04-15 15:00:49.861+03	2024-04-15 15:00:49.861+03	34	91
28	2	2024-04-15 15:21:56.782+03	2024-04-15 15:21:56.782+03	36	64
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id_order, number_order, price_order, date_order, "createdAt", "updatedAt", id_order_address) FROM stdin;
1	12345	1.00	2024-01-25 20:57:40.504387+03	2024-01-25 20:57:40.495+03	2024-01-25 21:01:49.866+03	1
2	123	49.99	2024-03-31 13:18:40.976765+03	2024-03-31 13:18:40.99+03	2024-03-31 13:18:40.99+03	2
3	123456	150.00	2022-10-22 13:00:00+03	2024-03-31 21:19:34.425+03	2024-03-31 21:19:34.425+03	3
6	309896	1000000.00	2024-03-31 21:37:19.241436+03	2024-03-31 21:37:19.246+03	2024-03-31 21:37:19.246+03	6
14	123111	49.99	2023-04-04 03:00:00+03	2024-04-01 16:33:09.016+03	2024-04-01 16:33:09.016+03	14
16	123777	49.99	2023-04-04 03:00:00+03	2024-04-02 18:29:59.374+03	2024-04-02 18:29:59.374+03	16
18	12377712	49.99	2023-04-04 03:00:00+03	2024-04-02 18:40:01.354+03	2024-04-02 18:40:01.354+03	18
19	1237771212	49.99	2023-04-04 03:00:00+03	2024-04-02 18:45:10.909+03	2024-04-02 18:45:10.909+03	19
22	1237771232	49.99	2023-04-04 03:00:00+03	2024-04-02 19:22:54.059+03	2024-04-02 19:22:54.059+03	22
23	302962	1000000.00	2024-04-02 19:35:51.211987+03	2024-04-02 19:35:51.216+03	2024-04-02 19:35:51.216+03	23
24	368436	1000000.00	2024-04-02 20:27:12.656588+03	2024-04-02 20:27:12.662+03	2024-04-02 20:27:12.662+03	24
25	154638	1000000.00	2024-04-02 20:34:11.678307+03	2024-04-02 20:34:11.682+03	2024-04-02 20:34:11.682+03	25
26	298750	1000000.00	2024-04-02 20:37:22.890715+03	2024-04-02 20:37:22.893+03	2024-04-02 20:37:22.893+03	26
27	206460	1000000.00	2024-04-02 21:33:05.698142+03	2024-04-02 21:33:05.701+03	2024-04-02 21:33:05.701+03	27
28	282414	4000000.00	2024-04-02 21:36:17.77154+03	2024-04-02 21:36:17.777+03	2024-04-02 21:36:17.777+03	28
29	514967	20000.00	2024-04-02 21:38:10.737878+03	2024-04-02 21:38:10.742+03	2024-04-02 21:38:10.742+03	29
30	508416	3000000.00	2024-04-12 22:21:18.800215+03	2024-04-12 22:21:18.818+03	2024-04-12 22:21:18.818+03	30
31	4919	1000000.00	2024-04-12 22:26:44.160068+03	2024-04-12 22:26:44.177+03	2024-04-12 22:26:44.177+03	31
34	123113331	49.99	2023-04-04 03:00:00+03	2024-04-15 15:00:49.68+03	2024-04-15 15:00:49.68+03	34
36	1233111	49.99	2023-04-04 03:00:00+03	2024-04-15 15:21:56.684+03	2024-04-15 15:21:56.684+03	37
\.


--
-- Data for Name: product_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_comments (id_product_comment, mark_comment, description_comment, "createdAt", "updatedAt", id_product, email_user) FROM stdin;
1	5	Лучший товар на свете	2024-01-25 20:03:09.409+03	2024-04-14 22:20:50.353+03	135	akurdelov@gmail.com
2	5	Супер	2024-04-16 20:32:50.469+03	2024-04-16 20:37:13.383+03	64	akurdelov@gmail.com
17	5	Nice	2024-04-18 18:04:03.572+03	2024-04-18 18:04:03.572+03	135	akurdelov@gmail.com
28	4	nice 	2024-04-18 23:07:02.091+03	2024-04-18 23:07:02.091+03	92	akurdelov@gmail.com
30	4	Nice	2024-04-19 10:29:20.642+03	2024-04-19 10:29:20.642+03	64	akurdelov@gmail.com
31	4	Nice	2024-04-19 10:33:41.078+03	2024-04-19 10:33:41.078+03	64	akurdelov@gmail.com
32	3	so so	2024-04-19 10:49:29.729+03	2024-04-19 10:49:29.729+03	64	akurdelov@gmail.com
33	4	so so	2024-04-19 10:58:16.234+03	2024-04-19 10:58:16.234+03	64	akurdelov@gmail.com
34	2	so so	2024-04-19 10:58:44.698+03	2024-04-19 10:58:44.698+03	64	akurdelov@gmail.com
35	5	Very good	2024-04-19 11:05:32.495+03	2024-04-19 11:05:32.495+03	64	akurdelov@gmail.com
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images (id_product_image, url_image, "createdAt", "updatedAt", id_product) FROM stdin;
2	5b6137da-a621-4508-83f5-86e481694fff.jpg	2024-02-17 17:13:53.971+03	2024-02-17 17:13:53.971+03	\N
1	https://mkmgroup.ru/d/sero_belye_gostinye_2.jpg	2024-01-25 20:06:29.047+03	2024-02-04 19:29:38.596+03	\N
3	34360145-6693-4a2d-b3e2-482c262d944c.jpg	2024-02-17 17:14:28.295+03	2024-02-17 17:14:28.295+03	\N
4	223a57aa-2f6a-44d1-bd64-27290391eece.jpg	2024-02-19 11:53:52.241+03	2024-02-19 11:53:52.241+03	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id_product, article_product, name_product, price_product, description_product, count_product, is_enabled, "createdAt", "updatedAt", url_main_image_product, id_category, rating) FROM stdin;
90	ART234567	Стол письменный	15000.00	Стильный и удобный стол для работы с ящиками для хранения	15	f	2024-03-21 11:14:05.229+03	2024-04-05 11:20:56.115+03	4673a0c1-8488-4ef5-8d40-a477880d64e0.jpg	56	\N
91	ART567890	Диван 'Уютный уголок	100000.00	Мягкий и комфортный диван для вашего уютного уголка	10	f	2024-03-21 13:14:54.536+03	2024-04-05 11:21:09.626+03	71d8263e-e119-4940-a058-54025a760c06.jpg	59	\N
92	ART678901	Кровать 'Сон в облаках	10000.00	Просторная кровать с мягким изголовьем для невероятно комфортного сна	20	f	2024-03-21 13:28:21.358+03	2024-04-05 11:21:25.946+03	b4d52134-b2ea-4446-9fec-33bf07664111.jpg	60	\N
138	ART12222	Кровать Barokko	150000.00	Кровать	10	f	2024-04-12 22:26:06.805+03	2024-04-12 22:26:06.805+03	44df96d4-c308-4038-a766-28d4e7cbcfc6.jpg	60	\N
135	ART79854	Гостиная	1000000.00	Гостиная	10	f	2024-03-24 19:21:30.949+03	2024-04-18 21:48:47.225+03	96efb195-c11e-4231-a599-59a9b662525e.jpg	55	5.00
89	ART123456	Стул из дуба	5000.00	Красивый и прочный стул из натурального дуба	20	f	2024-03-21 11:11:23.329+03	2024-04-18 22:04:47.147+03	3047a24f-76eb-4a33-8662-eb75d365af01.jpg	55	5.00
137	ART12345777777	Шкаф Barokko	10000000.00	Шкаф	100	f	2024-04-12 22:19:41.896+03	2024-04-18 22:06:17.763+03	87a34173-70e8-4b7e-be98-7ba6974f9128.jpg	57	1.00
64	ART345678	Шкаф для книг	20000.00	Прочный шкаф для книг с полками из массива дерева	12	f	2024-02-27 20:32:31.043+03	2024-04-19 11:05:32.592+03	ffde0ce7-f2da-4b5e-a54e-ba97e6356974.jpg	57	3.86
\.


--
-- Data for Name: specifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specifications (id_specification, value_specification, "createdAt", "updatedAt", id_attribute, id_product) FROM stdin;
1	12	2024-03-24 09:44:24.087+03	2024-03-24 09:44:24.087+03	\N	\N
2	12	2024-03-24 09:44:24.088+03	2024-03-24 09:44:24.088+03	\N	\N
3	1	2024-03-24 10:10:03.552+03	2024-03-24 10:10:03.552+03	\N	\N
4	2	2024-03-24 10:17:20.674+03	2024-03-24 10:17:20.674+03	\N	\N
5	3	2024-03-24 10:20:16.559+03	2024-03-24 10:20:16.559+03	\N	\N
6	333	2024-03-24 10:20:16.566+03	2024-03-24 10:20:16.566+03	\N	\N
8	3444	2024-03-24 10:29:34.119+03	2024-03-24 10:29:34.119+03	\N	\N
9	44	2024-03-24 10:31:07.677+03	2024-03-24 10:31:07.677+03	\N	\N
10	6	2024-03-24 14:30:21.186+03	2024-03-24 14:30:21.186+03	\N	\N
7	12	2024-03-24 10:27:18.289+03	2024-03-24 10:27:18.289+03	\N	\N
11	2	2024-03-24 15:02:48.259+03	2024-03-24 15:02:48.259+03	\N	\N
12	7	2024-03-24 15:05:03.929+03	2024-03-24 15:05:03.929+03	1	\N
13	3333	2024-03-24 15:08:15.535+03	2024-03-24 15:08:15.535+03	\N	\N
14	3333	2024-03-24 15:08:15.537+03	2024-03-24 15:08:15.537+03	\N	\N
15	44	2024-03-24 15:10:40.319+03	2024-03-24 15:10:40.319+03	\N	\N
16	444444	2024-03-24 15:10:40.322+03	2024-03-24 15:10:40.322+03	\N	\N
17	22	2024-03-24 15:16:09.971+03	2024-03-24 15:16:09.971+03	1	\N
18	1222	2024-03-24 15:33:52.238+03	2024-03-24 15:33:52.238+03	\N	\N
19	56	2024-03-24 15:45:36.161+03	2024-03-24 15:45:36.161+03	\N	\N
20	45	2024-03-24 15:46:31.912+03	2024-03-24 15:46:31.912+03	\N	\N
21	3444	2024-03-24 16:00:22.711+03	2024-03-24 16:00:22.711+03	\N	\N
22	121212	2024-03-24 16:05:19.096+03	2024-03-24 16:05:19.096+03	\N	\N
25	qqqq	2024-03-24 17:35:33.909+03	2024-03-24 17:35:33.909+03	\N	\N
26	1212	2024-03-24 17:55:38.255+03	2024-03-24 17:55:38.255+03	2	\N
27	Черный	2024-03-24 19:21:31.099+03	2024-03-24 19:21:31.099+03	2	135
28	100	2024-03-24 19:21:31.106+03	2024-03-24 19:21:31.106+03	1	135
29	Черный	2024-04-12 22:19:42.288+03	2024-04-12 22:19:42.288+03	2	137
30	5м	2024-04-12 22:19:42.394+03	2024-04-12 22:19:42.394+03	1	137
31	0.5м	2024-04-12 22:19:42.415+03	2024-04-12 22:19:42.415+03	3	137
32	Ореховый	2024-04-12 22:26:07.04+03	2024-04-12 22:26:07.04+03	2	138
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (email_user, password_user, role_user, first_name_user, second_name_user, phone_number_client, image_user_profile, "createdAt", "updatedAt") FROM stdin;
test@example.com	$2b$05$JChn7osiqA1a04IIRuxmfeImlwEXOjNHJQar6rKEKBK5JXc/TPrvG	user	\N	\N	\N	\N	2024-03-24 20:57:35.537+03	2024-03-24 20:57:35.537+03
kandrey16@yandex.ru	$2b$05$TBKqW9svizEVf2zQLOHueuvaL.v4LJKLEfR0sWROgozwxsiQx9Dki	ADMIN	Андрей	Курделов	\N	\N	2024-03-13 19:03:36.855+03	2024-03-30 12:35:34.132+03
akurdelov@gmail.com	$2b$05$eXz3.emr0sz630UpdsJYpOVJMzCU0WmOEWmA.UQDk0WvE2AdP9KWa	ADMIN	Андрей	Курделов	+79586387103	d8744eea-d102-472c-af66-e63e0f3a2035.jpg	2024-01-25 18:47:31.896+03	2024-04-14 20:33:08.317+03
\.


--
-- Data for Name: winston_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.winston_logs (level, message, meta, "timestamp") FROM stdin;
[31merror[39m	[31mError: This is a simulated error[39m	{"timestamp":"2024-03-20 14:40:33:4033"}	2024-03-20 14:40:33.321181
[31merror[39m	[31mError: This is a simulated error[39m	{"timestamp":"2024-03-20 14:47:41:4741"}	2024-03-20 14:47:41.819548
[31merror[39m	[31mError: This is a simulated error[39m	{"timestamp":"2024-03-20 14:50:42:5042"}	2024-03-20 14:50:42.795701
[31merror[39m	[31mError: This is a simulated error[39m	{"timestamp":"2024-03-20 14:51:59:5159"}	2024-03-20 14:51:59.979906
error	Error: This is a simulated error	{"timestamp":"2024-03-20 15:16:40:1640"}	2024-03-20 15:16:40.971684
info	Server started on PORT 5000...	{"timestamp":"2024-03-20 15:17:51:1751"}	2024-03-20 15:17:51.33903
info	Server started on PORT 5000...	{"timestamp":"2024-03-20 20:16:36:1636"}	2024-03-20 20:16:36.552104
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 11:00:56:056"}	2024-03-21 11:00:56.806922
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:06:55:655"}	2024-03-21 20:06:55.212851
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:07:24:724"}	2024-03-21 20:07:24.157794
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:07:39:739"}	2024-03-21 20:07:39.919638
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:07:48:748"}	2024-03-21 20:07:48.521403
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:07:56:756"}	2024-03-21 20:07:56.833588
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:11:811"}	2024-03-21 20:08:11.542174
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:27:827"}	2024-03-21 20:08:27.488364
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:30:830"}	2024-03-21 20:08:30.961424
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:37:837"}	2024-03-21 20:08:37.540591
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:50:850"}	2024-03-21 20:08:50.119387
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:54:854"}	2024-03-21 20:08:54.743703
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:08:57:857"}	2024-03-21 20:08:57.528968
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:09:55:955"}	2024-03-21 20:09:55.259464
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:09:59:959"}	2024-03-21 20:09:59.730965
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:02:102"}	2024-03-21 20:10:02.581124
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:07:107"}	2024-03-21 20:10:07.614819
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:09:109"}	2024-03-21 20:10:09.98883
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:14:1014"}	2024-03-21 20:10:14.596835
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:18:1018"}	2024-03-21 20:10:18.678036
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:21:1021"}	2024-03-21 20:10:21.209384
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:23:1023"}	2024-03-21 20:10:23.449772
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:10:33:1033"}	2024-03-21 20:10:33.095796
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:13:00:130"}	2024-03-21 20:13:00.049551
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:14:17:1417"}	2024-03-21 20:14:17.842886
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:14:30:1430"}	2024-03-21 20:14:30.684406
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:17:06:176"}	2024-03-21 20:17:06.956446
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:18:04:184"}	2024-03-21 20:18:04.109811
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:19:21:1921"}	2024-03-21 20:19:21.832492
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:19:36:1936"}	2024-03-21 20:19:36.480935
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:21:37:2137"}	2024-03-21 20:21:37.776911
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:22:04:224"}	2024-03-21 20:22:04.158634
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:25:20:2520"}	2024-03-21 20:25:20.290926
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:27:46:2746"}	2024-03-21 20:27:46.184977
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:28:34:2834"}	2024-03-21 20:28:34.700126
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:29:34:2934"}	2024-03-21 20:29:34.461939
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:30:53:3053"}	2024-03-21 20:30:53.877148
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:48:51:4851"}	2024-03-21 20:48:51.244505
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:53:43:5343"}	2024-03-21 20:53:43.508333
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 20:57:23:5723"}	2024-03-21 20:57:23.389516
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:02:44:244"}	2024-03-21 21:02:44.540987
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:02:53:253"}	2024-03-21 21:02:53.963773
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:03:08:38"}	2024-03-21 21:03:08.815745
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:06:41:641"}	2024-03-21 21:06:41.349218
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:07:40:740"}	2024-03-21 21:07:40.537527
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:09:24:924"}	2024-03-21 21:09:24.157746
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:09:39:939"}	2024-03-21 21:09:39.885708
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:10:01:101"}	2024-03-21 21:10:01.812744
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:11:33:1133"}	2024-03-21 21:11:33.930819
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:13:03:133"}	2024-03-21 21:13:03.393935
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:29:28:2928"}	2024-03-21 21:29:28.260452
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:30:00:300"}	2024-03-21 21:30:00.11637
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:40:51:4051"}	2024-03-21 21:40:51.243501
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:41:22:4122"}	2024-03-21 21:41:22.429625
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:41:45:4145"}	2024-03-21 21:41:45.977006
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:43:09:439"}	2024-03-21 21:43:09.516609
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:46:16:4616"}	2024-03-21 21:46:16.521045
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:46:37:4637"}	2024-03-21 21:46:37.30736
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:47:26:4726"}	2024-03-21 21:47:27.041949
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:48:47:4847"}	2024-03-21 21:48:47.419996
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:50:34:5034"}	2024-03-21 21:50:34.784495
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:50:43:5043"}	2024-03-21 21:50:43.330472
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:50:49:5049"}	2024-03-21 21:50:49.924469
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:50:56:5056"}	2024-03-21 21:50:56.107383
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:51:04:514"}	2024-03-21 21:51:04.513459
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:52:03:523"}	2024-03-21 21:52:03.775327
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:52:07:527"}	2024-03-21 21:52:07.970146
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 21:52:24:5224"}	2024-03-21 21:52:24.268773
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:15:54:1554"}	2024-03-21 22:15:54.905251
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:17:39:1739"}	2024-03-21 22:17:39.501822
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:17:49:1749"}	2024-03-21 22:17:49.378927
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:20:13:2013"}	2024-03-21 22:20:13.356258
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:20:30:2030"}	2024-03-21 22:20:30.498177
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:22:45:2245"}	2024-03-21 22:22:45.332194
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:22:57:2257"}	2024-03-21 22:22:57.619627
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:23:58:2358"}	2024-03-21 22:23:58.442074
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:24:42:2442"}	2024-03-21 22:24:42.406437
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:25:56:2556"}	2024-03-21 22:25:56.618848
info	Server started on PORT 5000...	{"timestamp":"2024-03-21 22:28:03:283"}	2024-03-21 22:28:03.50805
info	Server started on PORT 5000...	{"timestamp":"2024-03-22 08:44:09:449"}	2024-03-22 08:44:09.49347
info	Server started on PORT 5000...	{"timestamp":"2024-03-22 09:13:19:1319"}	2024-03-22 09:13:19.741047
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 11:46:44:4644"}	2024-03-23 11:46:44.455493
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:14:49:1449"}	2024-03-23 17:14:49.975009
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:18:57:1857"}	2024-03-23 17:18:57.202773
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:30:08:308"}	2024-03-23 17:30:08.622099
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:49:55:4955"}	2024-03-23 17:49:55.826998
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:51:14:5114"}	2024-03-23 17:51:14.803789
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:51:21:5121"}	2024-03-23 17:51:21.619387
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:51:44:5144"}	2024-03-23 17:51:44.89294
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:53:03:533"}	2024-03-23 17:53:03.981935
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:53:13:5313"}	2024-03-23 17:53:13.728553
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:53:19:5319"}	2024-03-23 17:53:19.638254
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:53:22:5322"}	2024-03-23 17:53:22.67513
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:54:03:543"}	2024-03-23 17:54:03.739049
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:55:27:5527"}	2024-03-23 17:55:27.857715
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:56:09:569"}	2024-03-23 17:56:09.90032
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:56:15:5615"}	2024-03-23 17:56:15.660528
info	Server started on PORT 5000...	{"timestamp":"2024-03-23 17:56:54:5654"}	2024-03-23 17:56:54.859361
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:13:22:1322"}	2024-03-24 09:13:23.076336
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:47:16:4716"}	2024-03-24 09:47:16.508484
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:50:11:5011"}	2024-03-24 09:50:11.9887
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:52:03:523"}	2024-03-24 09:52:03.300746
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:55:58:5558"}	2024-03-24 09:55:58.216863
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 09:56:36:5636"}	2024-03-24 09:56:37.078324
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:09:47:947"}	2024-03-24 10:09:47.200824
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:15:22:1522"}	2024-03-24 10:15:22.889258
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:15:48:1548"}	2024-03-24 10:15:48.535646
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:16:14:1614"}	2024-03-24 10:16:14.383637
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:16:36:1636"}	2024-03-24 10:16:36.775647
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:16:43:1643"}	2024-03-24 10:16:44.171863
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 10:16:52:1652"}	2024-03-24 10:16:52.270763
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 14:31:53:3153"}	2024-03-24 14:31:53.984891
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 14:37:10:3710"}	2024-03-24 14:37:10.815244
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 14:39:00:390"}	2024-03-24 14:39:00.92836
info	Server started on PORT 5000...	{"timestamp":"2024-03-24 15:03:56:356"}	2024-03-24 15:03:56.877628
info	Server started on PORT 5000...	{"timestamp":"2024-03-26 12:02:41:241"}	2024-03-26 12:02:42.025826
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 20:05:52:552"}	2024-03-27 20:05:52.449433
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 21:23:00:230"}	2024-03-27 21:23:00.677026
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 21:23:02:232"}	2024-03-27 21:23:02.168838
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 21:25:38:2538"}	2024-03-27 21:25:39.031026
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 21:50:44:5044"}	2024-03-27 21:50:44.769207
info	Server started on PORT 63612...	{"timestamp":"2024-03-27 21:50:55:5055"}	2024-03-27 21:50:55.139352
info	Server started on PORT 5000...	{"timestamp":"2024-03-27 22:07:26:726"}	2024-03-27 22:07:26.082474
info	Server started on PORT 5000...	{"timestamp":"2024-03-28 13:53:12:5312"}	2024-03-28 13:53:12.98775
info	Server started on PORT 5000...	{"timestamp":"2024-03-29 16:52:40:5240"}	2024-03-29 16:52:40.599304
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:24:55:2455"}	2024-03-30 12:24:55.320953
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:25:42:2542"}	2024-03-30 12:25:42.647187
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:26:44:2644"}	2024-03-30 12:26:44.80472
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:28:26:2826"}	2024-03-30 12:28:26.134614
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:29:20:2920"}	2024-03-30 12:29:20.232311
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:30:29:3029"}	2024-03-30 12:30:29.553646
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:33:54:3354"}	2024-03-30 12:33:54.753725
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 12:59:36:5936"}	2024-03-30 12:59:36.928727
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 13:00:21:021"}	2024-03-30 13:00:21.610979
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 13:01:03:13"}	2024-03-30 13:01:03.705748
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 13:01:35:135"}	2024-03-30 13:01:35.430134
info	Server started on PORT 5000...	{"timestamp":"2024-03-30 18:03:14:314"}	2024-03-30 18:03:14.661594
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 08:35:01:351"}	2024-03-31 08:35:01.673944
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:20:58:2058"}	2024-03-31 12:20:58.999369
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:21:20:2120"}	2024-03-31 12:21:20.929003
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:46:00:460"}	2024-03-31 12:46:00.842672
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:46:36:4636"}	2024-03-31 12:46:36.974879
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:47:36:4736"}	2024-03-31 12:47:36.327655
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 12:58:51:5851"}	2024-03-31 12:58:52.014458
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:08:14:814"}	2024-03-31 13:08:15.045111
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:08:22:822"}	2024-03-31 13:08:22.452697
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:08:26:826"}	2024-03-31 13:08:26.372217
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:09:00:90"}	2024-03-31 13:09:00.211919
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:09:28:928"}	2024-03-31 13:09:28.369603
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:09:46:946"}	2024-03-31 13:09:46.43131
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:10:34:1034"}	2024-03-31 13:10:34.289073
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:10:43:1043"}	2024-03-31 13:10:43.323325
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:10:49:1049"}	2024-03-31 13:10:49.224249
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:10:59:1059"}	2024-03-31 13:10:59.231159
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:11:14:1114"}	2024-03-31 13:11:14.467534
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:11:41:1141"}	2024-03-31 13:11:41.574395
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:12:07:127"}	2024-03-31 13:12:07.706629
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:12:28:1228"}	2024-03-31 13:12:28.079456
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:13:00:130"}	2024-03-31 13:13:00.605522
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:15:34:1534"}	2024-03-31 13:15:34.954791
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:17:21:1721"}	2024-03-31 13:17:21.263694
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:18:20:1820"}	2024-03-31 13:18:20.826142
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:21:33:2133"}	2024-03-31 13:21:33.967007
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:21:51:2151"}	2024-03-31 13:21:51.329657
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:24:56:2456"}	2024-03-31 13:24:57.04782
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 13:25:47:2547"}	2024-03-31 13:25:47.292613
info	Server started on PORT 5000...	{"timestamp":"2024-03-31 21:14:52:1452"}	2024-03-31 21:14:52.924396
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 10:44:32:4432"}	2024-04-01 10:44:32.102796
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 10:44:42:4442"}	2024-04-01 10:44:42.217089
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:05:11:511"}	2024-04-01 11:05:11.327184
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:09:50:950"}	2024-04-01 11:09:50.575925
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:10:28:1028"}	2024-04-01 11:10:28.346464
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:19:12:1912"}	2024-04-01 11:19:12.136488
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:23:54:2354"}	2024-04-01 11:23:54.307532
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:24:47:2447"}	2024-04-01 11:24:47.158634
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:42:14:4214"}	2024-04-01 11:42:14.903479
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 11:42:38:4238"}	2024-04-01 11:42:38.637558
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:08:23:823"}	2024-04-01 12:08:23.325417
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:08:37:837"}	2024-04-01 12:08:37.183839
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:08:50:850"}	2024-04-01 12:08:50.177378
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:08:56:856"}	2024-04-01 12:08:56.573698
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:09:22:922"}	2024-04-01 12:09:22.103065
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:12:27:1227"}	2024-04-01 12:12:27.184839
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:13:48:1348"}	2024-04-01 12:13:48.598541
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:16:40:1640"}	2024-04-01 12:16:40.5247
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:17:13:1713"}	2024-04-01 12:17:13.306821
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:18:42:1842"}	2024-04-01 12:18:42.792075
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:28:21:2821"}	2024-04-01 12:28:21.574123
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 12:31:59:3159"}	2024-04-01 12:32:00.008993
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 16:20:45:2045"}	2024-04-01 16:20:45.841952
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 16:27:52:2752"}	2024-04-01 16:27:52.548945
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 16:28:50:2850"}	2024-04-01 16:28:50.502632
info	Server started on PORT 5000...	{"timestamp":"2024-04-01 19:59:20:5920"}	2024-04-01 19:59:20.303995
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:28:45:2845"}	2024-04-02 18:28:45.918713
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:37:32:3732"}	2024-04-02 18:37:33.11483
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:38:00:380"}	2024-04-02 18:38:00.625727
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:38:51:3851"}	2024-04-02 18:38:51.900271
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:39:08:398"}	2024-04-02 18:39:08.209531
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 18:39:26:3926"}	2024-04-02 18:39:26.969905
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 19:05:26:526"}	2024-04-02 19:05:26.132447
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 19:19:36:1936"}	2024-04-02 19:19:36.594445
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 19:22:50:2250"}	2024-04-02 19:22:50.861549
info	Server started on PORT 5000...	{"timestamp":"2024-04-02 19:31:12:3112"}	2024-04-02 19:31:12.825106
info	Server started on PORT 5000...	{"timestamp":"2024-04-03 15:12:06:126"}	2024-04-03 15:12:06.241107
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 10:22:26:2226"}	2024-04-04 10:22:26.89561
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 15:24:07:247"}	2024-04-04 15:24:08.154446
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 15:24:11:2411"}	2024-04-04 15:24:11.200588
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 15:24:36:2436"}	2024-04-04 15:24:36.07262
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 15:27:13:2713"}	2024-04-04 15:27:13.495943
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 15:34:39:3439"}	2024-04-04 15:34:39.469816
info	Server started on PORT 5000...	{"timestamp":"2024-04-04 18:46:13:4613"}	2024-04-04 18:46:13.179717
info	Server started on PORT 5000...	{"timestamp":"2024-04-05 10:03:00:30"}	2024-04-05 10:03:00.801391
info	Server started on PORT 5000...	{"timestamp":"2024-04-06 20:12:23:1223"}	2024-04-06 20:12:23.235488
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 10:14:28:1428"}	2024-04-07 10:14:29.067994
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:27:1027"}	2024-04-07 16:10:27.737363
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:33:1033"}	2024-04-07 16:10:33.56747
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:43:1043"}	2024-04-07 16:10:43.75532
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:49:1049"}	2024-04-07 16:10:49.554156
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:54:1054"}	2024-04-07 16:10:54.521972
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:10:58:1058"}	2024-04-07 16:10:58.336701
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:11:01:111"}	2024-04-07 16:11:01.330212
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:11:07:117"}	2024-04-07 16:11:07.907846
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:11:11:1111"}	2024-04-07 16:11:12.025671
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:11:14:1114"}	2024-04-07 16:11:14.870644
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:11:19:1119"}	2024-04-07 16:11:19.867254
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:12:00:120"}	2024-04-07 16:12:00.92914
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:12:56:1256"}	2024-04-07 16:12:56.772884
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:13:08:138"}	2024-04-07 16:13:08.305756
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 16:13:11:1311"}	2024-04-07 16:13:11.479764
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 17:24:59:2459"}	2024-04-07 17:24:59.633975
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:27:50:2750"}	2024-04-07 18:27:50.781798
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:28:18:2818"}	2024-04-07 18:28:18.489288
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:29:07:297"}	2024-04-07 18:29:07.525416
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:29:33:2933"}	2024-04-07 18:29:33.90764
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:30:25:3025"}	2024-04-07 18:30:25.332773
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:31:33:3133"}	2024-04-07 18:31:33.292847
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:32:54:3254"}	2024-04-07 18:32:54.074043
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:33:10:3310"}	2024-04-07 18:33:10.439047
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:33:36:3336"}	2024-04-07 18:33:36.455788
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:34:31:3431"}	2024-04-07 18:34:31.816242
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:34:41:3441"}	2024-04-07 18:34:41.653553
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:35:38:3538"}	2024-04-07 18:35:38.844793
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:35:53:3553"}	2024-04-07 18:35:53.246702
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:36:16:3616"}	2024-04-07 18:36:16.087562
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 18:54:06:546"}	2024-04-07 18:54:07.037048
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:13:43:1343"}	2024-04-07 19:13:43.531191
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:14:03:143"}	2024-04-07 19:14:03.41296
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:14:21:1421"}	2024-04-07 19:14:21.710955
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:14:59:1459"}	2024-04-07 19:14:59.913944
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:18:21:1821"}	2024-04-07 19:18:21.249125
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:22:38:2238"}	2024-04-07 19:22:38.815598
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:23:55:2355"}	2024-04-07 19:23:56.147815
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:26:15:2615"}	2024-04-07 19:26:15.724355
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:28:31:2831"}	2024-04-07 19:28:31.906443
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:32:03:323"}	2024-04-07 19:32:03.905348
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:33:17:3317"}	2024-04-07 19:33:17.400401
info	Server started on PORT 5000...	{"timestamp":"2024-04-07 19:35:50:3550"}	2024-04-07 19:35:50.469057
info	Server started on PORT 5000...	{"timestamp":"2024-04-08 13:42:36:4236"}	2024-04-08 13:42:36.873188
info	Server started on PORT 5000...	{"timestamp":"2024-04-09 12:04:38:438"}	2024-04-09 12:04:38.584271
info	Server started on PORT 5000...	{"timestamp":"2024-04-11 16:14:11:1411"}	2024-04-11 16:14:11.166914
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 20:10:23:1023"}	2024-04-13 20:10:23.948306
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 22:25:15:2515"}	2024-04-13 22:25:15.222192
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 22:26:15:2615"}	2024-04-13 22:26:15.488991
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 22:30:43:3043"}	2024-04-13 22:30:44.029857
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 22:34:10:3410"}	2024-04-13 22:34:10.161044
info	Server started on PORT 5000...	{"timestamp":"2024-04-13 22:34:58:3458"}	2024-04-13 22:34:58.595273
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 10:39:52:3952"}	2024-04-14 10:39:52.683413
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:04:24:424"}	2024-04-14 20:04:24.557438
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:07:47:747"}	2024-04-14 20:07:47.868014
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:08:25:825"}	2024-04-14 20:08:25.21216
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:11:06:116"}	2024-04-14 20:11:06.63536
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:14:27:1427"}	2024-04-14 20:14:27.729449
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:32:39:3239"}	2024-04-14 20:32:39.817607
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:46:20:4620"}	2024-04-14 20:46:20.441399
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 20:49:01:491"}	2024-04-14 20:49:01.833675
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 21:55:23:5523"}	2024-04-14 21:55:23.163848
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 21:55:59:5559"}	2024-04-14 21:55:59.937702
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 21:58:35:5835"}	2024-04-14 21:58:35.342293
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 22:02:43:243"}	2024-04-14 22:02:43.310495
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 22:03:23:323"}	2024-04-14 22:03:23.153386
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 22:04:04:44"}	2024-04-14 22:04:04.928779
info	Server started on PORT 5000...	{"timestamp":"2024-04-14 22:07:08:78"}	2024-04-14 22:07:08.634904
info	Server started on PORT 5000...	{"timestamp":"2024-04-15 14:02:18:218"}	2024-04-15 14:02:19.13256
info	Server started on PORT 5000...	{"timestamp":"2024-04-15 22:13:57:1357"}	2024-04-15 22:13:57.831552
info	Server started on PORT 5000...	{"timestamp":"2024-04-16 18:46:01:461"}	2024-04-16 18:46:01.750936
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 11:59:46:5946"}	2024-04-18 11:59:46.682171
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:44:08:448"}	2024-04-18 17:44:08.538108
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:45:28:4528"}	2024-04-18 17:45:28.595734
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:46:15:4615"}	2024-04-18 17:46:15.225863
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:49:14:4914"}	2024-04-18 17:49:14.78635
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:49:26:4926"}	2024-04-18 17:49:26.339343
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:49:31:4931"}	2024-04-18 17:49:32.042979
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:49:46:4946"}	2024-04-18 17:49:47.043393
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:49:51:4951"}	2024-04-18 17:49:51.863629
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:06:506"}	2024-04-18 17:50:06.663045
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:11:5011"}	2024-04-18 17:50:11.635864
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:15:5015"}	2024-04-18 17:50:15.082009
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:19:5019"}	2024-04-18 17:50:19.640595
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:26:5026"}	2024-04-18 17:50:26.801406
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:32:5032"}	2024-04-18 17:50:32.572472
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:39:5039"}	2024-04-18 17:50:39.656083
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:44:5044"}	2024-04-18 17:50:44.163366
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:53:5053"}	2024-04-18 17:50:53.311446
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:50:58:5058"}	2024-04-18 17:50:58.093897
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:14:5114"}	2024-04-18 17:51:14.066556
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:17:5117"}	2024-04-18 17:51:17.935851
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:21:5121"}	2024-04-18 17:51:21.603208
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:30:5130"}	2024-04-18 17:51:30.65891
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:40:5140"}	2024-04-18 17:51:41.029809
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:49:5149"}	2024-04-18 17:51:49.280258
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:53:5153"}	2024-04-18 17:51:53.133769
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:51:57:5157"}	2024-04-18 17:51:57.855221
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:03:523"}	2024-04-18 17:52:03.981097
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:07:527"}	2024-04-18 17:52:07.413659
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:16:5216"}	2024-04-18 17:52:16.238801
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:22:5222"}	2024-04-18 17:52:22.736724
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:25:5225"}	2024-04-18 17:52:25.774861
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:36:5236"}	2024-04-18 17:52:36.15831
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:45:5245"}	2024-04-18 17:52:46.041038
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:54:5254"}	2024-04-18 17:52:54.877346
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:52:59:5259"}	2024-04-18 17:52:59.352298
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:02:532"}	2024-04-18 17:53:02.430987
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:07:537"}	2024-04-18 17:53:07.470095
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:10:5310"}	2024-04-18 17:53:10.968675
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:17:5317"}	2024-04-18 17:53:17.154921
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:22:5322"}	2024-04-18 17:53:22.162275
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:25:5325"}	2024-04-18 17:53:25.148535
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:27:5327"}	2024-04-18 17:53:27.918423
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:33:5333"}	2024-04-18 17:53:33.482112
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:39:5339"}	2024-04-18 17:53:39.562318
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:46:5346"}	2024-04-18 17:53:46.684386
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:53:52:5352"}	2024-04-18 17:53:52.338997
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:00:540"}	2024-04-18 17:54:00.785143
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:03:543"}	2024-04-18 17:54:03.120378
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:04:544"}	2024-04-18 17:54:04.699718
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:09:549"}	2024-04-18 17:54:09.909363
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:16:5416"}	2024-04-18 17:54:16.55346
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:19:5419"}	2024-04-18 17:54:19.413767
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:21:5421"}	2024-04-18 17:54:21.489544
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:30:5430"}	2024-04-18 17:54:30.703221
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:38:5438"}	2024-04-18 17:54:38.456895
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:54:44:5444"}	2024-04-18 17:54:44.688485
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:57:54:5754"}	2024-04-18 17:57:54.790129
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:58:40:5840"}	2024-04-18 17:58:40.195768
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:58:47:5847"}	2024-04-18 17:58:48.11774
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:59:00:590"}	2024-04-18 17:59:00.62387
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 17:59:07:597"}	2024-04-18 17:59:07.411101
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 18:03:45:345"}	2024-04-18 18:03:45.630328
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 20:20:45:2045"}	2024-04-18 20:20:45.893535
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:02:55:255"}	2024-04-18 22:02:55.340607
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:03:04:34"}	2024-04-18 22:03:04.833267
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:11:44:1144"}	2024-04-18 22:11:44.386882
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:16:01:161"}	2024-04-18 22:16:01.271646
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:18:13:1813"}	2024-04-18 22:18:13.638328
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:20:12:2012"}	2024-04-18 22:20:12.125156
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:22:50:2250"}	2024-04-18 22:22:51.075778
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:32:42:3242"}	2024-04-18 22:32:43.084932
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:33:33:3333"}	2024-04-18 22:33:33.179134
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:33:45:3345"}	2024-04-18 22:33:46.044113
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:53:22:5322"}	2024-04-18 22:53:23.031902
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:59:00:590"}	2024-04-18 22:59:00.642619
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 22:59:24:5924"}	2024-04-18 22:59:25.0421
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 23:02:39:239"}	2024-04-18 23:02:39.747546
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 23:05:21:521"}	2024-04-18 23:05:22.020525
info	Server started on PORT 5000...	{"timestamp":"2024-04-18 23:06:29:629"}	2024-04-18 23:06:30.059834
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:27:37:2737"}	2024-04-19 10:27:38.069432
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:33:40:3340"}	2024-04-19 10:33:40.870118
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:36:08:368"}	2024-04-19 10:36:08.313339
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:36:17:3617"}	2024-04-19 10:36:17.948767
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:38:20:3820"}	2024-04-19 10:38:20.368861
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:40:23:4023"}	2024-04-19 10:40:23.328291
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:41:25:4125"}	2024-04-19 10:41:25.858401
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:41:38:4138"}	2024-04-19 10:41:38.971244
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:42:45:4245"}	2024-04-19 10:42:45.785552
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:44:13:4413"}	2024-04-19 10:44:13.749636
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:45:18:4518"}	2024-04-19 10:45:19.073276
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:45:37:4537"}	2024-04-19 10:45:37.77782
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:46:16:4616"}	2024-04-19 10:46:16.154962
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:46:48:4648"}	2024-04-19 10:46:49.058088
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:46:53:4653"}	2024-04-19 10:46:53.156957
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:48:34:4834"}	2024-04-19 10:48:34.174642
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:48:59:4859"}	2024-04-19 10:48:59.995309
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:52:37:5237"}	2024-04-19 10:52:37.368016
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:52:46:5246"}	2024-04-19 10:52:46.188402
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:53:58:5358"}	2024-04-19 10:53:58.659669
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:54:42:5442"}	2024-04-19 10:54:42.937265
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:54:49:5449"}	2024-04-19 10:54:49.304905
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:55:06:556"}	2024-04-19 10:55:06.600486
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:55:14:5514"}	2024-04-19 10:55:14.414557
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:55:24:5524"}	2024-04-19 10:55:24.633669
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:55:31:5531"}	2024-04-19 10:55:32.011277
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:03:573"}	2024-04-19 10:57:03.138346
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:10:5710"}	2024-04-19 10:57:10.19603
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:28:5728"}	2024-04-19 10:57:28.138221
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:37:5737"}	2024-04-19 10:57:37.595861
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:47:5747"}	2024-04-19 10:57:48.112821
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 10:57:55:5755"}	2024-04-19 10:57:55.467873
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 11:01:54:154"}	2024-04-19 11:01:54.377165
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 11:03:06:36"}	2024-04-19 11:03:06.245425
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 11:03:26:326"}	2024-04-19 11:03:27.044592
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 11:04:43:443"}	2024-04-19 11:04:44.105397
info	Server started on PORT 5000...	{"timestamp":"2024-04-19 11:05:17:517"}	2024-04-19 11:05:17.362974
\.


--
-- Name: attribute_groups_id_attribute_group_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attribute_groups_id_attribute_group_seq', 7, true);


--
-- Name: attributes_id_attribute_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attributes_id_attribute_seq', 6, true);


--
-- Name: cart_products_id_cart_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_products_id_cart_product_seq', 132, true);


--
-- Name: carts_id_cart_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_id_cart_seq', 4, true);


--
-- Name: categories_id_category_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_category_seq', 65, true);


--
-- Name: image_comments_id_image_comment_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_comments_id_image_comment_seq', 1, true);


--
-- Name: order_addresses_id_order_address_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_addresses_id_order_address_seq', 37, true);


--
-- Name: order_products_id_order_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_products_id_order_product_seq', 28, true);


--
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_order_seq', 36, true);


--
-- Name: product_comments_id_product_comment_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_comments_id_product_comment_seq', 35, true);


--
-- Name: product_images_id_product_image_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_images_id_product_image_seq', 4, true);


--
-- Name: products_id_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_product_seq', 138, true);


--
-- Name: specifications_id_specification_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specifications_id_specification_seq', 32, true);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: attribute_groups attribute_groups_name_attribute_group_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_groups
    ADD CONSTRAINT attribute_groups_name_attribute_group_key UNIQUE (name_attribute_group);


--
-- Name: attribute_groups attribute_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_groups
    ADD CONSTRAINT attribute_groups_pkey PRIMARY KEY (id_attribute_group);


--
-- Name: attributes attributes_name_attribute_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_name_attribute_key UNIQUE (name_attribute);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id_attribute);


--
-- Name: cart_products cart_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_products
    ADD CONSTRAINT cart_products_pkey PRIMARY KEY (id_cart_product);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id_cart);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id_category);


--
-- Name: image_comments image_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_comments
    ADD CONSTRAINT image_comments_pkey PRIMARY KEY (id_image_comment);


--
-- Name: order_addresses order_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_addresses
    ADD CONSTRAINT order_addresses_pkey PRIMARY KEY (id_order_address);


--
-- Name: order_products order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_products
    ADD CONSTRAINT order_products_pkey PRIMARY KEY (id_order_product);


--
-- Name: orders orders_number_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_number_order_key UNIQUE (number_order);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id_order);


--
-- Name: product_comments product_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_comments
    ADD CONSTRAINT product_comments_pkey PRIMARY KEY (id_product_comment);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id_product_image);


--
-- Name: products products_article_product_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_article_product_key UNIQUE (article_product);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id_product);


--
-- Name: specifications specifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specifications_pkey PRIMARY KEY (id_specification);


--
-- Name: user_profiles user_profiles_phone_number_client_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_phone_number_client_key UNIQUE (phone_number_client);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (email_user);


--
-- Name: attributes attributes_id_attribute_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_id_attribute_group_fkey FOREIGN KEY (id_attribute_group) REFERENCES public.attribute_groups(id_attribute_group) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_products cart_products_id_cart_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_products
    ADD CONSTRAINT cart_products_id_cart_fkey FOREIGN KEY (id_cart) REFERENCES public.carts(id_cart) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_products cart_products_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_products
    ADD CONSTRAINT cart_products_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(id_product) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: carts carts_email_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_email_user_fkey FOREIGN KEY (email_user) REFERENCES public.user_profiles(email_user) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: image_comments image_comments_id_product_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_comments
    ADD CONSTRAINT image_comments_id_product_comment_fkey FOREIGN KEY (id_product_comment) REFERENCES public.product_comments(id_product_comment) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_addresses order_addresses_email_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_addresses
    ADD CONSTRAINT order_addresses_email_user_fkey FOREIGN KEY (email_user) REFERENCES public.user_profiles(email_user) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_products order_products_id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_products
    ADD CONSTRAINT order_products_id_order_fkey FOREIGN KEY (id_order) REFERENCES public.orders(id_order) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_id_order_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_id_order_address_fkey FOREIGN KEY (id_order_address) REFERENCES public.order_addresses(id_order_address) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_comments product_comments_email_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_comments
    ADD CONSTRAINT product_comments_email_user_fkey FOREIGN KEY (email_user) REFERENCES public.user_profiles(email_user) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_comments product_comments_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_comments
    ADD CONSTRAINT product_comments_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(id_product) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_images product_images_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(id_product) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: specifications specifications_id_attribute_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specifications_id_attribute_fkey FOREIGN KEY (id_attribute) REFERENCES public.attributes(id_attribute) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: specifications specifications_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specifications_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(id_product) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

