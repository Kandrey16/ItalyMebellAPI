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

--
-- Name: add_to_order_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_to_order_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.order_history (
        id_order,
        number_order,
        price_order,
        date_order,
        id_order_address,
        id_payment_method,
		id_order_product,
        address_order,
        entrance_order,
        floor_order,
        home_code_order,
        name_payment_method,
        email_user
    ) VALUES (
        NEW.id_order,
        NEW.number_order,
        NEW.price_order,
        NEW.date_order,
        NEW.id_order_address,
        NEW.id_payment_method,
		NEW.id_order_product,
        (SELECT address_order FROM public.order_addresses WHERE id_order_address = NEW.id_order_address), -- Получение адреса доставки из таблицы order_addresses
        (SELECT entrance_order FROM public.order_addresses WHERE id_order_address = NEW.id_order_address), -- Получение номера подъезда из таблицы order_addresses
        (SELECT floor_order FROM public.order_addresses WHERE id_order_address = NEW.id_order_address), -- Получение этажа из таблицы order_addresses
        (SELECT home_code_order FROM public.order_addresses WHERE id_order_address = NEW.id_order_address), -- Получение кода домофона из таблицы order_addresses
        (SELECT name_payment_method FROM public.payment_methods WHERE id_payment_method = NEW.id_payment_method), -- Получение названия способа оплаты из таблицы payment_methods
        (SELECT email_user FROM public.order_addresses WHERE id_order_address = NEW.id_order_address), -- Получение электронной почты пользователя из таблицы order_addresses
		(SELECT
    		oh.id_order_history,                       -- Уникальный идентификатор записи истории заказа
			oh.id_order,                               -- Идентификатор заказа
			oh.number_order,                           -- Номер заказа
			oh.price_order,                            -- Цена заказа
			op.count_order_product,                    -- Количество товара в заказе
			p.id_product FROM public.order_history oh
				INNER JOIN public.order_products op ON oh.id_order_product = op.id_order_product
				INNER JOIN public.products p ON op.id_product = p.id_product )
	);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.add_to_order_history() OWNER TO postgres;

--
-- Name: record_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.record_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  order_info JSONB;
  address_info JSONB;
  products_info JSONB;
BEGIN
  -- Собираем информацию о заказе
  SELECT jsonb_build_object(
    'id_order', NEW.id_order,
    'number_order', NEW.number_order,
    'price_order', NEW.price_order,
    'date_order', NEW.date_order,
    'createdAt', NEW.created_at,
    'updatedAt', NEW.updated_at,
    'id_order_address', NEW.id_order_address,
    'id_payment_method', NEW.id_payment_method
  ) INTO order_info FROM orders WHERE id = NEW.id_order;

  -- Собираем информацию об адресе заказа
  SELECT jsonb_agg(jsonb_build_object(
    'address', address_order,
    'entrance', entrance_order,
    'floor', floor_order,
    'home_code', home_code_order,
    'createdAt', created_at,
    'updatedAt', updated_at,
    'email_user', email_user
  )) INTO address_info FROM order_addresses WHERE id_order_address = NEW.id_order_address;

  -- Собираем информацию о товарах в заказе
  SELECT jsonb_agg(jsonb_build_object(
    'count_order_product', count_order_product,
    'id_order_product', id_order_product,
    'createdAt', created_at,
    'updatedAt', updated_at,
    'id_product', id_product
  )) INTO products_info FROM order_products WHERE id_order = NEW.id_order;

  -- Вставка данных в таблицу истории
  INSERT INTO order_histories (order_data, order_address_data, order_product_data)
  VALUES (order_info, address_info, products_info);

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.record_history() OWNER TO postgres;

--
-- Name: update_order_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- В данном случае, мы вставляем данные непосредственно в таблицу order_histories
    -- Здесь мы предполагаем, что у вас есть соответствующие поля для хранения данных заказа в формате JSONB
    -- Этот код необходимо настроить в соответствии с вашей логикой и структурой данных
    INSERT INTO order_histories (id_order, number_order, price_order, date_order, created_at, updated_at, id_order_address, id_payment_method, order_data, order_address_data, order_product_data)
    VALUES (NEW.id_order, NEW.number_order, NEW.price_order, NEW.date_order, NEW."createdAt", NEW."updatedAt", NEW.id_order_address, NEW.id_payment_method,
            jsonb_build_object('order', NEW), -- placeholder для вашей логики получения данных заказа
            (SELECT jsonb_agg(jsonb_build_object('order_address', address_order, 'entrance_order', entrance_order, 'floor_order', floor_order, 'home_code_order', home_code_order))
             FROM order_addresses WHERE id_order_address = NEW.id_order_address),
            (SELECT jsonb_agg(jsonb_build_object('product_id', id_product, 'count', count_order_product))
             FROM order_products WHERE id_order = NEW.id_order));

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_order_history() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ConfirmationCodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ConfirmationCodes" (
    email_user character varying(255) NOT NULL,
    code character varying(6) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."ConfirmationCodes" OWNER TO postgres;

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
-- Name: category_attribute_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_attribute_groups (
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    id_attribute_group integer NOT NULL,
    id_category integer NOT NULL
);


ALTER TABLE public.category_attribute_groups OWNER TO postgres;

--
-- Name: collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections (
    id_collection integer NOT NULL,
    name_collection character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.collections OWNER TO postgres;

--
-- Name: collections_id_collection_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collections_id_collection_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collections_id_collection_seq OWNER TO postgres;

--
-- Name: collections_id_collection_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collections_id_collection_seq OWNED BY public.collections.id_collection;


--
-- Name: confirmation_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.confirmation_codes (
    email_user character varying(255) NOT NULL,
    code character varying(6) NOT NULL,
    "createdAt" timestamp with time zone
);


ALTER TABLE public.confirmation_codes OWNER TO postgres;

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
-- Name: order_deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_deliveries (
    id_order_delivery integer NOT NULL,
    name_order_delivery character varying(255) NOT NULL,
    price_order_delivery numeric(18,2) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.order_deliveries OWNER TO postgres;

--
-- Name: order_deliveries_id_order_delivery_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_deliveries_id_order_delivery_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_deliveries_id_order_delivery_seq OWNER TO postgres;

--
-- Name: order_deliveries_id_order_delivery_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_deliveries_id_order_delivery_seq OWNED BY public.order_deliveries.id_order_delivery;


--
-- Name: order_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_history (
    id_order_history integer NOT NULL,
    id_order integer NOT NULL,
    number_order integer NOT NULL,
    price_order numeric(18,2) NOT NULL,
    date_order timestamp with time zone NOT NULL,
    id_order_address integer,
    id_payment_method integer,
    id_order_product integer,
    address_order text NOT NULL,
    entrance_order integer,
    floor_order integer,
    home_code_order character varying(255),
    name_payment_method character varying(255) NOT NULL,
    email_user character varying(255) NOT NULL
);


ALTER TABLE public.order_history OWNER TO postgres;

--
-- Name: order_history_id_order_history_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_history_id_order_history_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_history_id_order_history_seq OWNER TO postgres;

--
-- Name: order_history_id_order_history_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_history_id_order_history_seq OWNED BY public.order_history.id_order_history;


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
-- Name: order_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_statuses (
    id_order_status integer NOT NULL,
    name_order_status character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.order_statuses OWNER TO postgres;

--
-- Name: order_statuses_id_order_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_statuses_id_order_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_statuses_id_order_status_seq OWNER TO postgres;

--
-- Name: order_statuses_id_order_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_statuses_id_order_status_seq OWNED BY public.order_statuses.id_order_status;


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
    id_order_address integer,
    id_payment_method integer,
    id_order_delivery integer,
    id_order_status integer
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
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_methods (
    id_payment_method integer NOT NULL,
    name_payment_method character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.payment_methods OWNER TO postgres;

--
-- Name: payment_methods_id_payment_method_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_methods_id_payment_method_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_methods_id_payment_method_seq OWNER TO postgres;

--
-- Name: payment_methods_id_payment_method_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_methods_id_payment_method_seq OWNED BY public.payment_methods.id_payment_method;


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
    rating numeric(10,2),
    id_collection integer
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
-- Name: collections id_collection; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections ALTER COLUMN id_collection SET DEFAULT nextval('public.collections_id_collection_seq'::regclass);


--
-- Name: image_comments id_image_comment; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_comments ALTER COLUMN id_image_comment SET DEFAULT nextval('public.image_comments_id_image_comment_seq'::regclass);


--
-- Name: order_addresses id_order_address; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_addresses ALTER COLUMN id_order_address SET DEFAULT nextval('public.order_addresses_id_order_address_seq'::regclass);


--
-- Name: order_deliveries id_order_delivery; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_deliveries ALTER COLUMN id_order_delivery SET DEFAULT nextval('public.order_deliveries_id_order_delivery_seq'::regclass);


--
-- Name: order_history id_order_history; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history ALTER COLUMN id_order_history SET DEFAULT nextval('public.order_history_id_order_history_seq'::regclass);


--
-- Name: order_products id_order_product; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_products ALTER COLUMN id_order_product SET DEFAULT nextval('public.order_products_id_order_product_seq'::regclass);


--
-- Name: order_statuses id_order_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_statuses ALTER COLUMN id_order_status SET DEFAULT nextval('public.order_statuses_id_order_status_seq'::regclass);


--
-- Name: orders id_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_order SET DEFAULT nextval('public.orders_id_order_seq'::regclass);


--
-- Name: payment_methods id_payment_method; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN id_payment_method SET DEFAULT nextval('public.payment_methods_id_payment_method_seq'::regclass);


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
-- Data for Name: ConfirmationCodes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ConfirmationCodes" (email_user, code, "createdAt") FROM stdin;
\.


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
20240420082204-add-payment-method-table.js
20240420082722-add-fk-payment-method-to-order.js
20240424082850-create_category_attribute_group.js
20240424084011-rename_category_attribute_group.js
20240425183021-create-collection-table.js
20240425185927-create-collection-table_2.js
20240425192036-add-fk-collection-to-product.js
20240426074557-add-fk-delyvery-to-order.js
20240426075420-add-table-delyvery-to-order.js
20240426080357-add-fk-delyvery-to-order-2.js
20240429025951-add-order-status-to-order.js
20240429030352-add-fk-order-status-to-order.js
20240501071053-create-confirmation-code.js
\.


--
-- Data for Name: attribute_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attribute_groups (id_attribute_group, name_attribute_group, "createdAt", "updatedAt") FROM stdin;
2	Размеры	2024-03-08 10:32:59.262+03	2024-03-08 10:32:59.262+03
3	Цвет	2024-04-06 23:03:06.04+03	2024-04-07 13:09:10.195+03
1	Материал	2024-02-25 17:50:49.498+03	2024-04-30 12:16:52.991+03
10	Стиль	2024-04-26 17:40:10.742+03	2024-04-30 12:17:09.907+03
11	Функциональность	2024-04-30 12:17:30.344+03	2024-04-30 12:17:30.344+03
\.


--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attributes (id_attribute, name_attribute, "createdAt", "updatedAt", id_attribute_group) FROM stdin;
1	Ширина	2024-02-25 17:50:14.884+03	2024-03-24 11:23:48.778+03	1
2	Количество ящиков	2024-03-09 21:03:15.269+03	2024-04-30 12:18:22.946+03	11
3	Длина	2024-04-07 12:53:11.282+03	2024-04-30 12:18:33.478+03	2
7	Глубина	2024-04-30 12:18:51.869+03	2024-05-04 13:01:21.255+03	2
8	Цвет	2024-05-04 20:51:31.758+03	2024-05-04 20:51:31.758+03	3
9	Материал	2024-05-04 20:51:42.596+03	2024-05-04 20:51:42.596+03	1
10	Стиль	2024-05-04 20:51:51.628+03	2024-05-04 20:51:51.628+03	10
11	Высота	2024-05-04 20:52:07.735+03	2024-05-04 20:52:07.735+03	2
12	Отделка	2024-05-04 20:52:26.133+03	2024-05-04 20:52:26.133+03	1
13	Тип дверей	2024-05-04 20:52:41.425+03	2024-05-04 20:52:41.425+03	11
14	Вес	2024-05-04 20:53:04.09+03	2024-05-04 20:53:04.09+03	2
15	Форма	2024-05-04 20:53:16.956+03	2024-05-04 20:53:16.956+03	2
16	Толщина	2024-05-04 20:53:23.765+03	2024-05-04 20:53:23.765+03	2
17	Вместимость	2024-05-04 20:53:36.056+03	2024-05-04 20:53:36.056+03	11
18	Тип объема	2024-05-04 20:53:51.949+03	2024-05-04 20:53:51.949+03	11
19	Модель	2024-05-04 20:54:06.758+03	2024-05-04 20:54:06.758+03	10
20	Страна производства	2024-05-04 20:54:26.584+03	2024-05-04 20:54:26.584+03	1
21	Гарантия	2024-05-04 20:54:38.265+03	2024-05-04 20:54:38.265+03	11
\.


--
-- Data for Name: cart_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_products (id_cart_product, "createdAt", "updatedAt", id_cart, id_product, count_cart_product) FROM stdin;
187	2024-05-11 22:38:45.374+03	2024-05-11 22:38:45.374+03	1	91	1
44	2024-03-13 21:06:25.128+03	2024-03-13 21:06:25.128+03	4	\N	0
45	2024-03-13 21:06:35.591+03	2024-03-13 21:06:35.591+03	4	\N	0
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (id_cart, "createdAt", "updatedAt", email_user) FROM stdin;
1	2024-03-08 19:12:39.652+03	2024-03-08 19:12:39.652+03	akurdelov@gmail.com
4	2024-03-13 19:03:36.87+03	2024-03-13 19:03:36.87+03	kandrey16@yandex.ru
5	2024-04-26 20:45:19.91+03	2024-04-26 20:45:19.91+03	turkandrey16@yandex.ru
6	2024-05-10 18:09:15.184+03	2024-05-10 18:09:15.184+03	turkandrey1618@gmail.com
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
-- Data for Name: category_attribute_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_attribute_groups ("createdAt", "updatedAt", id_attribute_group, id_category) FROM stdin;
\.


--
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collections (id_collection, name_collection, "createdAt", "updatedAt") FROM stdin;
1	Микилянджело	2024-04-25 22:12:57.325+03	2024-04-25 22:12:57.325+03
3	Барелла	2024-04-25 23:19:33.265+03	2024-04-25 23:19:33.265+03
4	Барокко	2024-05-06 17:14:19.26+03	2024-05-06 17:14:19.26+03
\.


--
-- Data for Name: confirmation_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.confirmation_codes (email_user, code, "createdAt") FROM stdin;
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
105		\N	\N		2024-04-26 22:22:19.251+03	2024-04-26 22:22:19.251+03	akurdelov@gmail.com
106		\N	\N		2024-04-26 22:25:33.784+03	2024-04-26 22:25:33.784+03	akurdelov@gmail.com
107		\N	\N		2024-04-26 22:33:22.911+03	2024-04-26 22:33:22.911+03	akurdelov@gmail.com
108	Адрес	1222	1222	12222	2024-04-27 11:54:26.41+03	2024-04-27 11:54:26.41+03	akurdelov@gmail.com
109	192.168.11.195	1	1	1	2024-04-27 14:09:28.059+03	2024-04-27 14:09:28.059+03	akurdelov@gmail.com
110	192.168.11.195	1	1	1	2024-04-29 06:50:58.223+03	2024-04-29 06:50:58.223+03	akurdelov@gmail.com
111	192.168.11.195	1	1	1	2024-04-29 07:14:33.528+03	2024-04-29 07:14:33.528+03	akurdelov@gmail.com
112	192.168.11.195	1	1	1	2024-04-29 07:19:05.133+03	2024-04-29 07:19:05.133+03	akurdelov@gmail.com
113	192.168.11.195	1	1	1	2024-04-29 17:28:41.683+03	2024-04-29 17:28:41.683+03	turkandrey16@yandex.ru
114	192.168.177.254	2	2	2	2024-04-30 14:42:34.827+03	2024-04-30 14:42:34.827+03	akurdelov@gmail.com
115	Улица Победы 10, Квартира 15	3	5	123456	2024-05-03 23:34:26.363+03	2024-05-03 23:34:26.363+03	akurdelov@gmail.com
117	192.168.11.195	1	1	1	2024-05-04 12:44:06.418+03	2024-05-04 12:44:06.418+03	akurdelov@gmail.com
34	Улица Пример 12311	1	5	ABC123	2024-04-15 15:00:49.672+03	2024-04-15 15:00:49.672+03	akurdelov@gmail.com
118	192.168.11.195	1	1	1	2024-05-04 12:50:12.376+03	2024-05-04 12:50:12.376+03	akurdelov@gmail.com
37	Улица Пример 12311	1	5	ABC123	2024-04-15 15:21:56.675+03	2024-04-15 15:21:56.675+03	akurdelov@gmail.com
122	пппп	4	6	4	2024-05-05 22:19:20.026+03	2024-05-05 22:19:20.026+03	akurdelov@gmail.com
123	еизда	1	1	1	2024-05-05 22:24:39.23+03	2024-05-05 22:24:39.23+03	akurdelov@gmail.com
124	ее	1	1	1	2024-05-05 22:27:00.328+03	2024-05-05 22:27:00.328+03	akurdelov@gmail.com
43	Улица Пример 123	1	5	ABC123	2024-04-20 13:25:26.513+03	2024-04-20 13:25:26.513+03	akurdelov@gmail.com
125	192.168.11.195	1	1	1	2024-05-06 10:55:44.249+03	2024-05-06 10:55:44.249+03	akurdelov@gmail.com
126	Нахимовский проспект 21	1	1	1	2024-05-06 11:29:59.453+03	2024-05-06 11:29:59.453+03	akurdelov@gmail.com
50	Улица Пример 123	1	5	ABC123	2024-04-20 14:33:01.266+03	2024-04-20 14:33:01.266+03	akurdelov@gmail.com
51	Улица Пример 123	1	5	ABC123	2024-04-20 18:48:46.297+03	2024-04-20 18:48:46.297+03	akurdelov@gmail.com
52	test	99	99	test	2024-04-21 10:26:12.695+03	2024-04-21 10:26:12.695+03	akurdelov@gmail.com
53	order	99	99	order	2024-04-21 11:03:49.652+03	2024-04-21 11:03:49.652+03	akurdelov@gmail.com
54	order2	99	99	order2	2024-04-21 15:05:40.167+03	2024-04-21 15:05:40.167+03	akurdelov@gmail.com
104	Новый адрес доставки	2	3	654321	2024-04-26 22:19:55.385+03	2024-05-11 00:03:21.18+03	akurdelov@gmail.com
\.


--
-- Data for Name: order_deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_deliveries (id_order_delivery, name_order_delivery, price_order_delivery, "createdAt", "updatedAt") FROM stdin;
1	Самовызов	0.00	2024-04-26 11:09:41.577+03	2024-04-26 11:09:41.577+03
2	Доставка с помощью ТК	2000.00	2024-04-26 11:10:01.442+03	2024-04-26 11:10:01.442+03
3	Доставка в пределах МКАД	3000.00	2024-04-26 20:35:58.696+03	2024-04-28 22:29:20.444+03
5	Самокат	500.00	2024-05-04 16:21:57.106+03	2024-05-04 16:21:57.106+03
\.


--
-- Data for Name: order_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_history (id_order_history, id_order, number_order, price_order, date_order, id_order_address, id_payment_method, id_order_product, address_order, entrance_order, floor_order, home_code_order, name_payment_method, email_user) FROM stdin;
\.


--
-- Data for Name: order_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_products (id_order_product, count_order_product, "createdAt", "updatedAt", id_order, id_product) FROM stdin;
54	3	2024-04-26 22:19:55.439+03	2024-05-11 00:03:21.183+03	79	138
55	1	2024-04-26 22:22:19.265+03	2024-04-26 22:22:19.265+03	80	138
56	1	2024-04-26 22:25:33.799+03	2024-04-26 22:25:33.799+03	81	138
57	1	2024-04-26 22:33:22.923+03	2024-04-26 22:33:22.923+03	82	91
58	1	2024-04-27 11:54:26.551+03	2024-04-27 11:54:26.551+03	83	64
59	1	2024-04-27 14:09:28.106+03	2024-04-27 14:09:28.106+03	84	135
60	1	2024-04-29 06:50:58.261+03	2024-04-29 06:50:58.261+03	85	90
61	1	2024-04-29 06:50:58.285+03	2024-04-29 06:50:58.285+03	85	135
62	1	2024-04-29 07:14:33.551+03	2024-04-29 07:14:33.551+03	86	135
63	1	2024-04-29 07:19:05.146+03	2024-04-29 07:19:05.146+03	87	64
64	1	2024-04-29 17:28:41.72+03	2024-04-29 17:28:41.72+03	88	91
65	1	2024-04-30 14:42:34.865+03	2024-04-30 14:42:34.865+03	89	64
66	1	2024-05-03 23:34:26.455+03	2024-05-03 23:34:26.455+03	90	135
68	5	2024-05-04 12:44:06.468+03	2024-05-04 12:44:06.468+03	92	64
69	1	2024-05-04 12:50:12.387+03	2024-05-04 12:50:12.387+03	93	135
70	3	2024-05-05 22:19:20.071+03	2024-05-05 22:19:20.071+03	94	89
71	1	2024-05-05 22:19:20.085+03	2024-05-05 22:19:20.085+03	94	135
72	2	2024-05-05 22:19:20.092+03	2024-05-05 22:19:20.092+03	94	147
73	2	2024-05-05 22:24:39.273+03	2024-05-05 22:24:39.273+03	95	89
74	1	2024-05-05 22:27:00.372+03	2024-05-05 22:27:00.372+03	96	89
75	1	2024-05-06 10:55:44.296+03	2024-05-06 10:55:44.296+03	97	91
76	1	2024-05-06 11:29:59.5+03	2024-05-06 11:29:59.5+03	98	89
\.


--
-- Data for Name: order_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_statuses (id_order_status, name_order_status, "createdAt", "updatedAt") FROM stdin;
1	В пути	2024-04-29 06:19:02.522+03	2024-04-29 06:19:02.522+03
2	В отбработке	2024-04-29 06:38:05.398+03	2024-04-29 06:38:05.398+03
3	Принят	2024-04-29 06:38:16.735+03	2024-04-29 06:38:16.735+03
4	Завершен	2024-04-29 06:38:21.634+03	2024-04-29 06:38:21.634+03
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id_order, number_order, price_order, date_order, "createdAt", "updatedAt", id_order_address, id_payment_method, id_order_delivery, id_order_status) FROM stdin;
88	521711	102000.00	2024-04-29 17:28:41.682008+03	2024-04-29 17:28:41.686+03	2024-04-30 18:36:14.124+03	113	1	1	4
89	899856	20000.00	2024-04-30 14:42:34.827393+03	2024-04-30 14:42:34.854+03	2024-04-30 18:39:10.577+03	114	1	1	1
96	26148	5000.00	2024-05-05 22:27:02.719+03	2024-05-05 22:27:00.33+03	2024-05-05 22:27:00.33+03	124	2	2	2
97	463909	103000.00	2024-05-06 10:55:44.248513+03	2024-05-06 10:55:44.258+03	2024-05-06 10:55:44.258+03	125	1	3	2
98	81078	5000.00	2024-05-06 11:29:59.153+03	2024-05-06 11:29:59.456+03	2024-05-06 11:29:59.456+03	126	2	3	2
82	489723	100000.00	2024-04-26 22:33:22.911652+03	2024-04-26 22:33:22.915+03	2024-05-10 23:03:02.544+03	107	1	1	4
90	20240002	250.00	2024-04-22 03:00:00+03	2024-05-03 23:34:26.397+03	2024-05-10 23:09:19.027+03	115	1	1	1
92	932247	100000.00	2024-05-04 12:44:06.414968+03	2024-05-04 12:44:06.43+03	2024-05-10 23:29:11.736+03	117	1	1	2
93	825462	1000000.00	2024-05-04 12:50:12.376736+03	2024-05-04 12:50:12.38+03	2024-05-10 23:29:58.807+03	118	1	1	2
94	883521	1024000.00	2024-05-05 22:19:22.113+03	2024-05-05 22:19:20.029+03	2024-05-10 23:30:59.045+03	122	1	3	2
95	403905	10000.00	2024-05-05 22:24:41.526+03	2024-05-05 22:24:39.233+03	2024-05-10 23:38:18.42+03	123	2	3	3
79	419127	270003.00	2024-04-30 03:00:00+03	2024-04-26 22:19:55.393+03	2024-05-11 10:43:08.911+03	104	2	2	3
81	592974	150000.00	2024-04-26 22:25:33.782954+03	2024-04-26 22:25:33.793+03	2024-04-26 22:25:33.793+03	106	1	1	\N
84	808437	1002000.00	2024-04-27 14:09:28.058265+03	2024-04-27 14:09:28.069+03	2024-04-27 14:09:28.069+03	109	1	3	\N
85	234697	1015000.00	2024-04-29 06:50:58.219887+03	2024-04-29 06:50:58.25+03	2024-04-29 06:50:58.25+03	110	1	1	\N
86	853351	1002000.00	2024-04-29 07:14:33.527185+03	2024-04-29 07:14:33.533+03	2024-04-29 07:14:33.533+03	111	1	2	2
83	785501	22000.00	2024-04-27 11:54:26.403249+03	2024-04-27 11:54:26.433+03	2024-04-30 18:02:30.073+03	108	1	3	2
87	777588	20000.00	2024-04-29 07:19:05.133615+03	2024-04-29 07:19:05.138+03	2024-04-30 18:02:56.396+03	112	1	1	3
80	163284	150000.00	2024-04-26 22:22:19.249926+03	2024-04-26 22:22:19.259+03	2024-04-30 18:18:32.266+03	105	1	1	4
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_methods (id_payment_method, name_payment_method, "createdAt", "updatedAt") FROM stdin;
1	Картой	2024-04-20 11:57:53.584+03	2024-04-20 11:57:53.584+03
2	Наличные	2024-04-20 11:58:09.592+03	2024-04-20 11:58:09.592+03
\.


--
-- Data for Name: product_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_comments (id_product_comment, mark_comment, description_comment, "createdAt", "updatedAt", id_product, email_user) FROM stdin;
28	5	Прекрасная кровать	2024-04-18 23:07:02.091+03	2024-04-23 21:37:06.872+03	91	akurdelov@gmail.com
35	5	Very good	2024-04-19 11:05:32.495+03	2024-04-19 11:05:32.495+03	91	akurdelov@gmail.com
36	5	Супер гуд	2024-04-22 16:02:30.593+03	2024-04-22 16:02:30.593+03	91	akurdelov@gmail.com
2	5	Супер!	2024-04-16 20:32:50.469+03	2024-04-23 21:34:44.563+03	91	akurdelov@gmail.com
1	5	Лучший товар на свете!!!	2024-01-25 20:03:09.409+03	2024-04-23 21:25:30.429+03	91	akurdelov@gmail.com
40	1	мимо	2024-05-11 13:01:29.572+03	2024-05-11 13:01:29.572+03	91	akurdelov@gmail.com
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images (id_product_image, url_image, "createdAt", "updatedAt", id_product) FROM stdin;
2	5b6137da-a621-4508-83f5-86e481694fff.jpg	2024-02-17 17:13:53.971+03	2024-02-17 17:13:53.971+03	\N
1	https://mkmgroup.ru/d/sero_belye_gostinye_2.jpg	2024-01-25 20:06:29.047+03	2024-02-04 19:29:38.596+03	\N
3	34360145-6693-4a2d-b3e2-482c262d944c.jpg	2024-02-17 17:14:28.295+03	2024-02-17 17:14:28.295+03	\N
4	223a57aa-2f6a-44d1-bd64-27290391eece.jpg	2024-02-19 11:53:52.241+03	2024-02-19 11:53:52.241+03	\N
5	67dbb1e9-8efb-4636-82a4-bdbcd80c6a1a.jpg	2024-05-04 15:41:54.611+03	2024-05-04 15:41:54.611+03	\N
6	b9d63167-8bc7-4b1b-8659-ad9c27a985a7.jpg	2024-05-04 15:41:54.616+03	2024-05-04 15:41:54.616+03	\N
7	c101ff15-222f-43bf-9b40-ac355595b1b2.jpg	2024-05-04 17:50:53.982+03	2024-05-04 17:50:53.982+03	\N
8	5e688afa-dbcd-4cfe-9c0e-da4188ac716a.webp	2024-05-04 17:50:53.989+03	2024-05-04 17:50:53.989+03	\N
9	5210beef-f1d0-4224-9613-6211b61515eb.webp	2024-05-04 20:59:18.742+03	2024-05-04 20:59:18.742+03	\N
10	6ba6b0bf-e7dd-46d2-a826-d0600ff603d6.webp	2024-05-04 20:59:18.748+03	2024-05-04 20:59:18.748+03	91
11	e9b49085-195f-4867-ada2-7725fb2f0538.webp	2024-05-04 20:59:18.752+03	2024-05-04 20:59:18.752+03	91
12	85e66672-628c-49d1-82dd-1454dc2c21ba.jpg	2024-05-06 10:47:26.773+03	2024-05-06 10:47:26.773+03	91
13	f7f6a4a2-0747-40ab-b532-00928aad3c86.jpg	2024-05-06 10:47:26.781+03	2024-05-06 10:47:26.781+03	91
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id_product, article_product, name_product, price_product, description_product, count_product, is_enabled, "createdAt", "updatedAt", url_main_image_product, id_category, rating, id_collection) FROM stdin;
146	ART123455555	Кровать	1000000.00	сУПЕР КРОВАТЬ	10	t	2024-05-04 16:19:05.166+03	2024-05-11 01:34:54.933+03	4bcb64c4-8d7a-416c-949c-3996fef67e05.jpg	57	\N	1
91	ART567890	Диван 'Уютный уголок	100000.00	Мягкий и комфортный диван для вашего уютного уголка	10	t	2024-03-21 13:14:54.536+03	2024-05-11 13:01:29.607+03	71d8263e-e119-4940-a058-54025a760c06.jpg	59	4.33	1
90	ART234567	Стол письменный	15000.00	Стильный и удобный стол для работы с ящиками для хранения	15	f	2024-03-21 11:14:05.229+03	2024-04-05 11:20:56.115+03	4673a0c1-8488-4ef5-8d40-a477880d64e0.jpg	56	\N	\N
92	ART678901	Кровать 'Сон в облаках	10000.00	Просторная кровать с мягким изголовьем для невероятно комфортного сна	20	f	2024-03-21 13:28:21.358+03	2024-04-05 11:21:25.946+03	b4d52134-b2ea-4446-9fec-33bf07664111.jpg	60	\N	\N
138	ART12222	Кровать Barokko	150000.00	Кровать	10	f	2024-04-12 22:26:06.805+03	2024-04-12 22:26:06.805+03	44df96d4-c308-4038-a766-28d4e7cbcfc6.jpg	60	\N	\N
64	ART345678	Шкаф для книг	20000.00	Прочный шкаф для книг с полками из массива дерева	7	f	2024-02-27 20:32:31.043+03	2024-05-04 12:44:06.477+03	ffde0ce7-f2da-4b5e-a54e-ba97e6356974.jpg	57	4.00	1
89	ART123456	Стул из дуба	5000.00	Красивый и прочный стул из натурального дуба	20	f	2024-03-21 11:11:23.329+03	2024-04-18 22:04:47.147+03	3047a24f-76eb-4a33-8662-eb75d365af01.jpg	55	5.00	\N
135	ART79854	Гостиная	1000000.00	Гостиная	9	t	2024-03-24 19:21:30.949+03	2024-05-04 12:50:12.396+03	96efb195-c11e-4231-a599-59a9b662525e.jpg	55	5.00	\N
137	ART12345777777	Шкаф Barokko	10000000.00	Шкаф	100	f	2024-04-12 22:19:41.896+03	2024-04-18 22:06:17.763+03	87a34173-70e8-4b7e-be98-7ba6974f9128.jpg	57	1.00	\N
151	ART1234567	Солнечный круг	28000.00	Круглый обеденный стол с солнечным узором на столешнице	20	t	2024-05-04 20:59:18.713+03	2024-05-04 20:59:18.713+03	58d027ff-32e4-4873-9a78-76bf63fb5755.jpg	56	\N	\N
\.


--
-- Data for Name: specifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specifications (id_specification, value_specification, "createdAt", "updatedAt", id_attribute, id_product) FROM stdin;
55	1	2024-05-06 10:47:26.765+03	2024-05-06 10:47:26.765+03	3	91
52	Модерн	2024-05-06 10:47:26.759+03	2024-05-06 10:47:26.759+03	10	91
35	2	2024-05-04 15:47:57.931+03	2024-05-04 15:47:57.931+03	2	92
48	Турция	2024-05-04 20:59:18.735+03	2024-05-04 20:59:18.735+03	20	92
53	Италия	2024-05-06 10:47:26.76+03	2024-05-06 10:47:26.76+03	20	91
29	5	2024-04-12 22:19:42.288+03	2024-04-12 22:19:42.288+03	2	\N
27	3	2024-03-24 19:21:31.099+03	2024-03-24 19:21:31.099+03	2	91
32	3	2024-04-12 22:26:07.04+03	2024-04-12 22:26:07.04+03	2	64
38	3м	2024-05-04 16:19:05.174+03	2024-05-04 16:19:05.174+03	1	91
36	6м	2024-05-04 16:04:06.356+03	2024-05-04 16:04:06.356+03	1	\N
37	3М	2024-05-04 16:05:07.767+03	2024-05-04 16:05:07.767+03	1	\N
33	3м	2024-05-04 15:41:54.603+03	2024-05-04 15:41:54.603+03	1	\N
34	2м	2024-05-04 15:41:54.608+03	2024-05-04 15:41:54.608+03	3	\N
30	5м	2024-04-12 22:19:42.394+03	2024-04-12 22:19:42.394+03	1	\N
31	0.5м	2024-04-12 22:19:42.415+03	2024-04-12 22:19:42.415+03	3	\N
39	3	2024-05-04 16:19:05.178+03	2024-05-04 16:19:05.178+03	3	\N
41	1	2024-05-04 17:22:38.456+03	2024-05-04 17:22:38.456+03	1	\N
42	1	2024-05-04 17:30:40.127+03	2024-05-04 17:30:40.127+03	7	\N
43	1	2024-05-04 17:50:53.973+03	2024-05-04 17:50:53.973+03	7	\N
44	2м	2024-05-04 20:59:18.723+03	2024-05-04 20:59:18.723+03	1	\N
45	Дуб	2024-05-04 20:59:18.727+03	2024-05-04 20:59:18.727+03	9	\N
46	15кг	2024-05-04 20:59:18.729+03	2024-05-04 20:59:18.729+03	14	\N
47	Круг	2024-05-04 20:59:18.732+03	2024-05-04 20:59:18.732+03	15	\N
49	Темно-коричневый	2024-05-04 20:59:18.736+03	2024-05-04 20:59:18.736+03	8	\N
28	100	2024-03-24 19:21:31.106+03	2024-03-24 19:21:31.106+03	1	\N
40	2	2024-05-04 17:18:01.574+03	2024-05-04 17:18:01.574+03	7	\N
50	3	2024-05-06 10:47:26.748+03	2024-05-06 10:47:26.748+03	2	\N
51	Коричневый	2024-05-06 10:47:26.756+03	2024-05-06 10:47:26.756+03	8	\N
54	2	2024-05-06 10:47:26.763+03	2024-05-06 10:47:26.763+03	1	\N
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (email_user, password_user, role_user, first_name_user, second_name_user, phone_number_client, image_user_profile, "createdAt", "updatedAt") FROM stdin;
test@example.com	$2b$05$JChn7osiqA1a04IIRuxmfeImlwEXOjNHJQar6rKEKBK5JXc/TPrvG	user	\N	\N	\N	\N	2024-03-24 20:57:35.537+03	2024-03-24 20:57:35.537+03
kandrey16@yandex.ru	$2b$05$TBKqW9svizEVf2zQLOHueuvaL.v4LJKLEfR0sWROgozwxsiQx9Dki	ADMIN	Андрей	Курделов	\N	\N	2024-03-13 19:03:36.855+03	2024-03-30 12:35:34.132+03
turkandrey16@yandex.ru	$2b$05$HiMxqK5twVvNdSdmKKB/YOq/RZZN7J7guqMTypmIT4k3XhkbBaGGS	ADMIN	Человек	Дождя	+79167012039	\N	2024-04-26 20:45:19.89+03	2024-04-29 17:28:41.658+03
turkandrey16@gmail.com	$2b$05$kowNRZ.CCYVnJYniUBCNwOMR4UwF2vj23KCdVLfaN7RR2/.gjzWj.	ADMIN	\N	\N	\N	\N	2024-04-30 22:50:26.037+03	2024-04-30 22:50:26.037+03
turkandrey1605@gmail.com	$2b$05$Ut.C1SxkeFljAEAU2si6Cea/6XKW0yDFrsWzWhcqQkOKQroeKm.Fe	ADMIN	\N	\N	\N	\N	2024-04-30 23:02:28.144+03	2024-04-30 23:02:28.144+03
turkandrey1606@gmail.com	$2b$05$xX0wvrrzYs.u0FTvZHPp9OU16p/hnXo2VmnPKhYrBWkBTDN7ZsDAW	ADMIN	\N	\N	\N	\N	2024-04-30 23:03:18.077+03	2024-04-30 23:03:18.077+03
turkandrey1607@gmail.com	$2b$05$ooRyW/hVKcvBtzKmcYo8qe3obzGVoTrf26SAdVw7TPanFG7UN.Qwq	ADMIN	\N	\N	\N	\N	2024-04-30 23:09:37.289+03	2024-04-30 23:09:37.289+03
turkandrey1604@gmail.com	$2b$05$16iduVIpdyhrHAzJuewcsOKq1bm7qq8L8sKCUDOPQS.uxYv6ImHDG	ADMIN	LYUDMILA	Дзюба	+79586387106	\N	2024-04-30 23:00:48.218+03	2024-05-02 19:58:08.483+03
akurdelov@gmail.com	$2b$05$SOQj.g5zCC1I27VvqrW/E.S8JYi1YKBb.Of7j00YPBKWShh1ewyGK	ADMIN	Андрей 	Курделов 	+79586387103	03b85cfb-5acb-4f85-8b83-61efcbfac91a.jpg	2024-01-25 18:47:31.896+03	2024-05-10 14:27:55.191+03
turkandrey1615@gmail.com	$2b$05$GgI7k/Q4sn80wHIhgbX7ROTrZp5Bo0b7emj6GR396qOz0iyu2fQ3W	USER	\N	\N	\N	\N	2024-05-10 17:32:57.231+03	2024-05-10 17:32:57.231+03
turkandrey1616@gmail.com	$2b$05$RZZSCjSsgzJK5/74Mb/VseUoLRMGPYj9qCYEODc/qp2Pxds4/403C	USER	\N	\N	\N	\N	2024-05-10 17:38:41.122+03	2024-05-10 17:38:41.122+03
turkandrey1617@gmail.com	$2b$05$IFbtZtbp/qPiArskCJZNxu4rP3G6nqWPlTAwy8XSIEOqFA.dfU2GW	USER	\N	\N	\N	\N	2024-05-10 18:03:59.313+03	2024-05-10 18:03:59.313+03
turkandrey1618@gmail.com	$2b$05$foupvbN7.6HbWOF8gLyjce9Xh3ZsWY3a/F2msZPCg09xjETVXagoS	USER	\N	\N	\N	\N	2024-05-10 18:09:15.153+03	2024-05-10 18:09:15.153+03
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
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:29:58:2958"}	2024-04-20 11:29:58.984167
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:35:14:3514"}	2024-04-20 11:35:14.234591
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:35:32:3532"}	2024-04-20 11:35:33.067044
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:38:39:3839"}	2024-04-20 11:38:39.697339
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:39:39:3939"}	2024-04-20 11:39:39.785309
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:40:22:4022"}	2024-04-20 11:40:22.210646
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:42:01:421"}	2024-04-20 11:42:02.068121
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:43:16:4316"}	2024-04-20 11:43:16.877345
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:43:58:4358"}	2024-04-20 11:43:58.571106
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:46:10:4610"}	2024-04-20 11:46:10.663484
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:55:48:5548"}	2024-04-20 11:55:48.880942
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:57:48:5748"}	2024-04-20 11:57:48.470976
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:13:30:1330"}	2024-04-20 12:13:30.85628
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:17:29:1729"}	2024-04-20 12:17:29.572169
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:20:18:2018"}	2024-04-20 12:20:18.236087
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:05:30:530"}	2024-04-20 13:05:30.488219
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:08:49:849"}	2024-04-20 13:08:49.663844
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:09:03:93"}	2024-04-20 13:09:03.796679
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:09:29:929"}	2024-04-20 13:09:29.096772
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:17:1417"}	2024-04-20 13:14:17.917488
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:29:1429"}	2024-04-20 13:14:29.878788
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:56:1456"}	2024-04-20 13:14:56.283683
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:15:00:150"}	2024-04-20 13:15:00.527144
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:32:2032"}	2024-04-20 13:20:32.735878
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:39:2039"}	2024-04-20 13:20:39.684324
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:47:2047"}	2024-04-20 13:20:48.046914
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:21:01:211"}	2024-04-20 13:21:01.586394
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:21:21:2121"}	2024-04-20 13:21:21.412775
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:30:23:3023"}	2024-04-20 13:30:23.637606
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:32:17:3217"}	2024-04-20 13:32:17.183059
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:32:51:3251"}	2024-04-20 13:32:51.547434
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:37:08:378"}	2024-04-20 13:37:08.721403
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:38:38:3838"}	2024-04-20 13:38:38.618962
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:39:15:3915"}	2024-04-20 13:39:15.348174
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:39:49:3949"}	2024-04-20 13:39:49.47188
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:41:41:4141"}	2024-04-20 13:41:41.32025
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:49:16:4916"}	2024-04-20 13:49:16.206033
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:23:26:2326"}	2024-04-20 18:23:26.217698
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:23:53:2353"}	2024-04-20 18:23:53.219403
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:05:275"}	2024-04-20 18:27:05.621815
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:15:2715"}	2024-04-20 18:27:15.876505
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:35:2735"}	2024-04-20 18:27:35.776592
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:28:13:2813"}	2024-04-20 18:28:13.092727
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:28:33:2833"}	2024-04-20 18:28:33.696455
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:37:27:3727"}	2024-04-20 18:37:27.212782
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:38:48:3848"}	2024-04-20 18:38:48.342109
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:38:51:3851"}	2024-04-20 18:38:51.662216
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:39:30:3930"}	2024-04-20 18:39:30.647658
info	Server started on PORT 5000...	{"timestamp":"2024-04-21 10:21:28:2128"}	2024-04-21 10:21:29.186711
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:46:24:4624"}	2024-04-22 12:46:24.98546
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:50:43:5043"}	2024-04-22 12:50:44.026376
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:58:15:5815"}	2024-04-22 12:58:15.616932
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:59:57:5957"}	2024-04-22 12:59:57.532729
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:00:22:022"}	2024-04-22 13:00:22.649106
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:02:21:221"}	2024-04-22 13:02:21.765958
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:03:16:316"}	2024-04-22 13:03:16.271767
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:04:49:449"}	2024-04-22 13:04:49.588434
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:05:41:541"}	2024-04-22 13:05:41.421378
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:06:24:624"}	2024-04-22 13:06:24.522904
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:07:56:756"}	2024-04-22 13:07:56.510015
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:09:48:948"}	2024-04-22 13:09:48.792464
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:10:16:1016"}	2024-04-22 13:10:17.064124
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:10:49:1049"}	2024-04-22 13:10:49.640919
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:12:51:1251"}	2024-04-22 13:12:51.685163
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:13:48:1348"}	2024-04-22 13:13:48.42834
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:16:44:1644"}	2024-04-22 13:16:44.960097
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:30:32:3032"}	2024-04-22 13:30:32.231471
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:17:01:171"}	2024-04-22 14:17:01.371159
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:17:33:1733"}	2024-04-22 14:17:33.214257
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:29:16:2916"}	2024-04-22 14:29:16.31702
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:29:32:2932"}	2024-04-22 14:29:32.338441
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:32:23:3223"}	2024-04-22 14:32:24.068431
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:27:13:2713"}	2024-04-22 15:27:13.14935
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:32:20:3220"}	2024-04-22 15:32:20.234838
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:43:19:4319"}	2024-04-22 15:43:19.292684
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:24:09:249"}	2024-04-22 21:24:09.796936
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:24:15:2415"}	2024-04-22 21:24:15.345963
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:25:55:2555"}	2024-04-22 21:25:55.316998
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:25:57:2557"}	2024-04-22 21:25:57.145742
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:30:27:3027"}	2024-04-22 21:30:27.29035
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:46:16:4616"}	2024-04-23 00:46:16.484668
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:47:53:4753"}	2024-04-23 00:47:54.053737
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:48:34:4834"}	2024-04-23 00:48:34.571484
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:54:25:5425"}	2024-04-23 00:54:25.481437
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:54:56:5456"}	2024-04-23 00:54:56.276703
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 09:44:28:4428"}	2024-04-23 09:44:28.402435
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 14:55:49:5549"}	2024-04-23 14:55:49.682967
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 22:41:33:4133"}	2024-04-23 22:41:33.276339
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 22:41:46:4146"}	2024-04-23 22:41:46.579494
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:06:36:636"}	2024-04-23 23:06:36.921508
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:06:53:653"}	2024-04-23 23:06:53.391082
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:01:71"}	2024-04-23 23:07:01.205497
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:14:714"}	2024-04-23 23:07:14.455837
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:22:722"}	2024-04-23 23:07:22.282738
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:28:728"}	2024-04-23 23:07:28.64065
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:16:41:1641"}	2024-04-24 11:16:41.668722
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:18:02:182"}	2024-04-24 11:18:02.826209
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:35:50:3550"}	2024-04-24 11:35:50.900509
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:37:59:3759"}	2024-04-24 11:37:59.970763
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:18:28:1828"}	2024-04-24 12:18:28.579791
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:31:32:3132"}	2024-04-24 12:31:32.362346
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:32:22:3222"}	2024-04-24 12:32:22.663943
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:42:33:4233"}	2024-04-24 18:42:33.541233
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:48:27:4827"}	2024-04-24 18:48:27.23808
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:48:56:4856"}	2024-04-24 18:48:56.832603
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:58:24:5824"}	2024-04-24 18:58:24.091795
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:59:23:5923"}	2024-04-24 18:59:23.785909
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:00:06:06"}	2024-04-24 19:00:06.726684
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:03:49:349"}	2024-04-24 19:03:49.287833
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:04:42:442"}	2024-04-24 19:04:42.978829
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:04:45:445"}	2024-04-24 19:04:45.69823
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:07:12:712"}	2024-04-24 19:07:12.122919
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:07:50:750"}	2024-04-24 19:07:50.313547
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:08:06:86"}	2024-04-24 19:08:06.057304
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:20:5320"}	2024-04-24 20:53:20.453481
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:36:5336"}	2024-04-24 20:53:36.65968
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:54:5354"}	2024-04-24 20:53:55.005538
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 21:08:03:83"}	2024-04-24 21:08:03.159456
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 13:55:07:557"}	2024-04-25 13:55:07.484137
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:35:635"}	2024-04-25 14:06:35.172183
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:46:646"}	2024-04-25 14:06:46.676239
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:55:655"}	2024-04-25 14:06:55.382661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:20:58:2058"}	2024-04-25 14:20:58.516843
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:21:05:215"}	2024-04-25 14:21:05.154436
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:21:44:2144"}	2024-04-25 14:21:44.197562
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:27:58:2758"}	2024-04-25 14:27:59.0812
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:30:26:3026"}	2024-04-25 14:30:26.785891
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:32:27:3227"}	2024-04-25 14:32:27.391499
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:34:03:343"}	2024-04-25 14:34:04.014915
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:34:50:3450"}	2024-04-25 14:34:50.821215
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:42:28:4228"}	2024-04-25 14:42:28.992032
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:42:36:4236"}	2024-04-25 14:42:36.356091
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:43:15:4315"}	2024-04-25 14:43:15.950116
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:43:51:4351"}	2024-04-25 14:43:51.233694
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:52:51:5251"}	2024-04-25 14:52:51.944558
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:52:54:5254"}	2024-04-25 14:52:55.091933
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:03:533"}	2024-04-25 14:53:03.850072
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:09:539"}	2024-04-25 14:53:09.258587
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:12:5312"}	2024-04-25 14:53:13.083931
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:02:02:22"}	2024-04-25 15:02:02.613829
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:02:25:225"}	2024-04-25 15:02:25.882342
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:08:31:831"}	2024-04-25 15:08:31.817644
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:09:09:99"}	2024-04-25 15:09:09.486888
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:10:30:1030"}	2024-04-25 15:10:30.19922
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:10:55:1055"}	2024-04-25 15:10:55.540716
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:11:30:1130"}	2024-04-25 15:11:30.82345
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:12:06:126"}	2024-04-25 15:12:06.852433
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:14:29:1429"}	2024-04-25 15:14:29.834172
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:22:52:2252"}	2024-04-25 15:22:52.179099
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:23:13:2313"}	2024-04-25 15:23:13.555413
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:23:58:2358"}	2024-04-25 15:23:58.869754
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 17:59:01:591"}	2024-04-25 17:59:01.70134
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:10:08:108"}	2024-04-25 18:10:09.034746
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:10:27:1027"}	2024-04-25 18:10:27.807152
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:11:09:119"}	2024-04-25 18:11:09.900187
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:12:39:1239"}	2024-04-25 18:12:39.080768
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:12:48:1248"}	2024-04-25 18:12:49.133839
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:13:02:132"}	2024-04-25 18:13:02.171607
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:13:22:1322"}	2024-04-25 18:13:22.779849
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:17:42:1742"}	2024-04-25 18:17:42.596714
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:49:04:494"}	2024-04-25 18:49:04.780806
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:25:27:2527"}	2024-04-25 19:25:27.734295
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:26:18:2618"}	2024-04-25 19:26:18.886539
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:26:56:2656"}	2024-04-25 19:26:56.660611
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:27:01:271"}	2024-04-25 19:27:01.913237
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:59:35:5935"}	2024-04-25 19:59:35.850116
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:00:56:056"}	2024-04-25 20:00:56.298919
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:14:114"}	2024-04-25 20:01:14.422259
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:24:124"}	2024-04-25 20:01:25.015294
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:29:129"}	2024-04-25 20:01:29.843728
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:36:136"}	2024-04-25 20:01:36.940326
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:03:43:343"}	2024-04-25 20:03:43.378842
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:09:11:911"}	2024-04-25 20:09:11.106628
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:12:28:1228"}	2024-04-25 20:12:28.56519
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:13:25:1325"}	2024-04-25 20:13:25.096765
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:14:23:1423"}	2024-04-25 20:14:23.387532
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:18:16:1816"}	2024-04-25 20:18:16.65379
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:21:02:212"}	2024-04-25 20:21:02.770281
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:27:22:2722"}	2024-04-25 20:27:22.852804
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:10:2810"}	2024-04-25 20:28:10.446768
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:17:2817"}	2024-04-25 20:28:17.109588
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:24:2824"}	2024-04-25 20:28:25.028557
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:06:316"}	2024-04-25 20:31:06.657245
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:19:3119"}	2024-04-25 20:31:19.546331
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:49:3149"}	2024-04-25 20:31:49.795478
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:34:06:346"}	2024-04-25 20:34:06.735267
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:44:04:444"}	2024-04-25 20:44:04.987442
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:46:03:463"}	2024-04-25 20:46:03.353383
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:04:474"}	2024-04-25 20:47:04.305666
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:17:4717"}	2024-04-25 20:47:17.061354
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:24:4724"}	2024-04-25 20:47:24.177327
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:34:4734"}	2024-04-25 20:47:34.693612
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:06:506"}	2024-04-25 20:50:06.704984
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:13:5013"}	2024-04-25 20:50:13.776679
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:19:5019"}	2024-04-25 20:50:19.771341
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:52:17:5217"}	2024-04-25 20:52:17.083089
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:08:568"}	2024-04-25 20:56:08.286848
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:28:5628"}	2024-04-25 20:56:29.018661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:44:5644"}	2024-04-25 20:56:44.33882
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:56:5656"}	2024-04-25 20:56:56.510789
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:57:12:5712"}	2024-04-25 20:57:12.718301
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:58:44:5844"}	2024-04-25 20:58:44.659679
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:59:24:5924"}	2024-04-25 20:59:24.796726
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:25:59:2559"}	2024-04-25 21:25:59.815841
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:27:00:270"}	2024-04-25 21:27:01.019343
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:38:22:3822"}	2024-04-25 21:38:22.165626
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:46:51:4651"}	2024-04-25 21:46:51.557416
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:47:56:4756"}	2024-04-25 21:47:56.696318
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:54:24:5424"}	2024-04-25 21:54:24.700602
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:12:5712"}	2024-04-25 21:57:12.231196
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:29:5729"}	2024-04-25 21:57:29.449793
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:58:5758"}	2024-04-25 21:57:58.116872
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:12:34:1234"}	2024-04-25 22:12:34.595488
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:13:57:1357"}	2024-04-25 22:13:58.030144
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:14:38:1438"}	2024-04-25 22:14:38.135661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:15:14:1514"}	2024-04-25 22:15:14.265506
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:16:50:1650"}	2024-04-25 22:16:50.535594
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:26:32:2632"}	2024-04-25 22:26:32.307786
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:57:36:5736"}	2024-04-25 22:57:36.801717
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:59:23:5923"}	2024-04-25 22:59:23.305793
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:07:06:76"}	2024-04-25 23:07:06.508939
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:08:39:839"}	2024-04-25 23:08:39.905516
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:13:57:1357"}	2024-04-25 23:13:57.245374
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:40:05:405"}	2024-04-25 23:40:06.158153
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:40:39:4039"}	2024-04-25 23:40:39.939471
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 10:16:47:1647"}	2024-04-26 10:16:47.865893
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 10:48:31:4831"}	2024-04-26 10:48:31.283888
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:05:58:558"}	2024-04-26 11:05:58.483116
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:08:04:84"}	2024-04-26 11:08:05.094267
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:09:16:916"}	2024-04-26 11:09:16.987706
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 12:33:02:332"}	2024-04-26 12:33:02.742515
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:04:44:444"}	2024-04-26 13:04:44.318914
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:12:04:124"}	2024-04-26 13:12:04.839458
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:15:02:152"}	2024-04-26 13:15:02.4435
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:15:23:1523"}	2024-04-26 13:15:23.603952
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 16:21:53:2153"}	2024-04-26 16:21:53.674663
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:45:05:455"}	2024-04-26 20:45:05.998507
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:47:19:4719"}	2024-04-26 20:47:19.453454
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:04:484"}	2024-04-26 20:48:04.282841
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:34:4834"}	2024-04-26 20:48:34.717704
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:41:4841"}	2024-04-26 20:48:41.341226
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:49:00:490"}	2024-04-26 20:49:00.135341
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:49:16:4916"}	2024-04-26 20:49:16.848692
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:50:27:5027"}	2024-04-26 20:50:27.36003
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:51:18:5118"}	2024-04-26 20:51:18.181275
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:51:27:5127"}	2024-04-26 20:51:27.938841
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:15:49:1549"}	2024-04-26 21:15:49.117145
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:10:2210"}	2024-04-26 21:22:10.132892
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:32:2232"}	2024-04-26 21:22:32.550295
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:56:2256"}	2024-04-26 21:22:56.506623
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:26:01:261"}	2024-04-26 21:26:01.160984
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:26:37:2637"}	2024-04-26 21:26:37.120234
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:47:27:4727"}	2024-04-26 21:47:27.821131
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:47:53:4753"}	2024-04-26 21:47:53.393451
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:49:48:4948"}	2024-04-26 21:49:48.912019
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:50:14:5014"}	2024-04-26 21:50:14.458097
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:04:54:454"}	2024-04-26 22:04:54.897692
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:07:32:732"}	2024-04-26 22:07:32.255272
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:13:40:1340"}	2024-04-26 22:13:40.502183
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:13:46:1346"}	2024-04-26 22:13:46.206658
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:14:01:141"}	2024-04-26 22:14:01.059468
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:17:03:173"}	2024-04-26 22:17:03.28356
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:19:54:1954"}	2024-04-26 22:19:54.933777
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:20:26:2026"}	2024-04-26 22:20:26.255385
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:22:14:2214"}	2024-04-26 22:22:14.395273
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:25:17:2517"}	2024-04-26 22:25:17.652459
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:26:52:2652"}	2024-04-26 22:26:52.078539
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:33:14:3314"}	2024-04-26 22:33:14.391001
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:24:47:2447"}	2024-04-26 23:24:47.446038
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:25:53:2553"}	2024-04-26 23:25:53.992192
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:27:44:2744"}	2024-04-26 23:27:44.46684
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:28:47:2847"}	2024-04-26 23:28:47.835082
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:31:34:3134"}	2024-04-26 23:31:34.830611
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:31:38:3138"}	2024-04-26 23:31:38.421059
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:32:46:3246"}	2024-04-26 23:32:46.230595
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:39:04:394"}	2024-04-26 23:39:04.844922
info	Server started on PORT 5000...	{"timestamp":"2024-04-27 10:57:17:5717"}	2024-04-27 10:57:18.067174
info	Server started on PORT 5000...	{"timestamp":"2024-04-27 12:32:25:3225"}	2024-04-27 12:32:25.940204
info	Server started on PORT 5000...	{"timestamp":"2024-04-28 13:07:30:730"}	2024-04-28 13:07:30.937276
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:05:04:54"}	2024-04-29 06:05:04.379995
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:06:33:633"}	2024-04-29 06:06:33.693292
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:11:22:1122"}	2024-04-29 06:11:22.498339
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:12:31:1231"}	2024-04-29 06:12:31.268203
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:17:50:1750"}	2024-04-29 06:17:50.493728
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:19:43:1943"}	2024-04-29 06:19:43.540397
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:20:02:202"}	2024-04-29 06:20:02.182618
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:43:31:4331"}	2024-04-29 06:43:31.109497
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:14:17:1417"}	2024-04-29 07:14:17.831155
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:16:33:1633"}	2024-04-29 07:16:33.303791
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:17:33:1733"}	2024-04-29 07:17:33.859715
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 15:11:14:1114"}	2024-04-29 15:11:14.524289
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 15:35:12:3512"}	2024-04-29 15:35:12.703304
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 20:28:11:2811"}	2024-04-29 20:28:11.979226
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 22:19:31:1931"}	2024-04-29 22:19:31.151138
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 11:21:43:2143"}	2024-04-30 11:21:43.358999
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:10:38:1038"}	2024-04-30 17:10:38.943246
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:12:58:1258"}	2024-04-30 17:12:58.721199
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:13:31:1331"}	2024-04-30 17:13:31.414161
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:07:147"}	2024-04-30 17:14:07.619948
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:25:1425"}	2024-04-30 17:14:25.515371
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:48:1448"}	2024-04-30 17:14:48.354828
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:15:19:1519"}	2024-04-30 17:15:19.832296
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:16:22:1622"}	2024-04-30 17:16:23.032399
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:17:47:1747"}	2024-04-30 17:17:47.692444
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:17:55:1755"}	2024-04-30 17:17:55.894933
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:19:36:1936"}	2024-04-30 17:19:36.806226
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:31:29:3129"}	2024-04-30 17:31:30.03024
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:48:53:4853"}	2024-04-30 17:48:53.321125
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:49:01:491"}	2024-04-30 17:49:01.437861
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:49:09:499"}	2024-04-30 17:49:10.04747
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:50:54:5054"}	2024-04-30 17:50:54.784361
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:51:41:5141"}	2024-04-30 17:51:41.217334
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:59:53:5953"}	2024-04-30 17:59:53.352336
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:02:27:227"}	2024-04-30 18:02:27.891772
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:51:14:5114"}	2024-04-30 18:51:14.40831
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:51:54:5154"}	2024-04-30 18:51:54.684936
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:53:02:532"}	2024-04-30 18:53:02.288715
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:53:25:5325"}	2024-04-30 18:53:25.586647
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:54:00:540"}	2024-04-30 18:54:00.672405
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:35:2335"}	2024-04-30 19:23:35.528131
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:50:2350"}	2024-04-30 19:23:50.073155
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:59:2359"}	2024-04-30 19:23:59.505813
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:13:2413"}	2024-04-30 19:24:13.462015
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:24:2424"}	2024-04-30 19:24:24.401073
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:44:2444"}	2024-04-30 19:24:44.494514
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:26:35:2635"}	2024-04-30 19:26:35.817421
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:02:272"}	2024-04-30 19:27:02.461214
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:33:2733"}	2024-04-30 19:27:33.665084
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:51:2751"}	2024-04-30 19:27:51.192568
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:28:18:2818"}	2024-04-30 19:28:18.393312
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:28:51:2851"}	2024-04-30 19:28:51.143591
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:30:52:3052"}	2024-04-30 19:30:52.657015
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:31:24:3124"}	2024-04-30 19:31:24.950917
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:31:51:3151"}	2024-04-30 19:31:51.88611
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:37:18:3718"}	2024-04-30 19:37:18.750725
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:40:41:4041"}	2024-04-30 19:40:41.318011
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:40:50:4050"}	2024-04-30 19:40:50.626964
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:46:54:4654"}	2024-04-30 19:46:54.714349
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:05:475"}	2024-04-30 19:47:05.307346
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:13:4713"}	2024-04-30 19:47:13.519626
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:29:4729"}	2024-04-30 19:47:29.136261
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:43:4743"}	2024-04-30 19:47:43.634707
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:57:00:570"}	2024-04-30 19:57:00.816544
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:02:44:244"}	2024-04-30 20:02:44.29408
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:04:12:412"}	2024-04-30 20:04:12.478017
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:04:30:430"}	2024-04-30 20:04:30.799456
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:05:08:58"}	2024-04-30 20:05:08.322183
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:07:77"}	2024-04-30 20:07:07.373119
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:17:717"}	2024-04-30 20:07:18.03826
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:38:738"}	2024-04-30 20:07:38.481229
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:55:755"}	2024-04-30 20:07:55.265266
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:31:831"}	2024-04-30 20:08:31.665981
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:51:851"}	2024-04-30 20:08:51.365394
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:56:856"}	2024-04-30 20:08:56.397376
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:21:02:212"}	2024-04-30 20:21:02.89604
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:21:24:2124"}	2024-04-30 20:21:24.751557
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:22:42:2242"}	2024-04-30 20:22:42.870714
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:23:17:2317"}	2024-04-30 20:23:17.152504
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:16:20:1620"}	2024-04-30 21:16:21.049622
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:07:337"}	2024-04-30 21:33:08.033315
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:15:3315"}	2024-04-30 21:33:15.350128
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:50:3350"}	2024-04-30 21:33:50.709822
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:34:25:3425"}	2024-04-30 21:34:25.077111
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:35:00:350"}	2024-04-30 21:35:00.57391
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:35:29:3529"}	2024-04-30 21:35:29.27812
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:48:43:4843"}	2024-04-30 21:48:43.656694
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:48:46:4846"}	2024-04-30 21:48:46.257343
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:49:22:4922"}	2024-04-30 21:49:22.214616
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:58:48:5848"}	2024-04-30 21:58:48.971448
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:58:51:5851"}	2024-04-30 21:58:51.665228
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:00:58:058"}	2024-04-30 22:00:58.563897
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:05:34:534"}	2024-04-30 22:05:34.742862
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:02:62"}	2024-04-30 22:06:02.560277
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:15:615"}	2024-04-30 22:06:15.361824
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:25:625"}	2024-04-30 22:06:25.453633
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:09:209"}	2024-04-30 22:20:09.098783
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:35:2035"}	2024-04-30 22:20:35.602146
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:43:2043"}	2024-04-30 22:20:43.92715
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:22:05:225"}	2024-04-30 22:22:05.771271
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:26:45:2645"}	2024-04-30 22:26:45.785701
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:41:44:4144"}	2024-04-30 23:41:44.888181
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:44:55:4455"}	2024-04-30 23:44:55.741391
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:47:51:4751"}	2024-04-30 23:47:51.518667
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:29:35:2935"}	2024-05-01 10:29:35.273675
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:36:18:3618"}	2024-05-01 10:36:18.405514
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:43:15:4315"}	2024-05-01 10:43:16.050496
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:44:03:443"}	2024-05-01 10:44:03.531115
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:46:17:4617"}	2024-05-01 10:46:17.592881
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:46:48:4648"}	2024-05-01 10:46:48.366639
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:48:10:4810"}	2024-05-01 10:48:11.051459
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:48:20:4820"}	2024-05-01 10:48:20.877356
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:49:54:4954"}	2024-05-01 10:49:54.835274
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:50:21:5021"}	2024-05-01 10:50:21.882254
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:06:16:616"}	2024-05-01 11:06:16.835756
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:06:46:646"}	2024-05-01 11:06:46.832564
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:07:23:723"}	2024-05-01 11:07:23.591681
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:08:27:827"}	2024-05-01 11:08:27.606132
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:11:54:1154"}	2024-05-01 11:11:54.246117
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 13:59:44:5944"}	2024-05-01 13:59:44.682382
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:06:26:626"}	2024-05-01 14:06:26.929299
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:05:85"}	2024-05-01 14:08:05.405556
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:22:822"}	2024-05-01 14:08:22.731049
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:48:848"}	2024-05-01 14:08:48.711782
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:03:93"}	2024-05-01 14:09:03.310554
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:39:939"}	2024-05-01 14:09:39.847445
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:51:951"}	2024-05-01 14:09:51.06893
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:58:958"}	2024-05-01 14:09:58.753837
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:10:10:1010"}	2024-05-01 14:10:10.261294
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:10:41:1041"}	2024-05-01 14:10:41.843661
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:13:28:1328"}	2024-05-01 14:13:28.943332
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:05:165"}	2024-05-01 14:16:05.700763
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:10:1610"}	2024-05-01 14:16:10.517961
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:27:1627"}	2024-05-01 14:16:27.981988
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:59:1659"}	2024-05-01 14:16:59.379883
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:17:07:177"}	2024-05-01 14:17:08.028366
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:10:1810"}	2024-05-01 14:18:10.892944
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:44:1844"}	2024-05-01 14:18:44.940331
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:55:1855"}	2024-05-01 14:18:55.96561
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:26:42:2642"}	2024-05-01 14:26:42.351169
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:27:05:275"}	2024-05-01 14:27:06.003479
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:27:55:2755"}	2024-05-01 14:27:55.233892
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:28:51:2851"}	2024-05-01 14:28:51.354671
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:39:3039"}	2024-05-01 14:30:39.38606
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:42:3042"}	2024-05-01 14:30:42.075927
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:49:3049"}	2024-05-01 14:30:49.213742
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:59:3059"}	2024-05-01 14:30:59.622099
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:31:04:314"}	2024-05-01 14:31:04.900404
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:31:07:317"}	2024-05-01 14:31:07.845608
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:44:48:4448"}	2024-05-01 14:44:48.200173
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:45:44:4544"}	2024-05-01 14:45:44.863141
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:52:30:5230"}	2024-05-01 14:52:30.280094
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:52:42:5242"}	2024-05-01 14:52:42.231655
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:58:22:5822"}	2024-05-01 14:58:22.377775
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:58:39:5839"}	2024-05-01 14:58:39.427793
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:03:10:310"}	2024-05-01 15:03:10.833487
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:06:57:657"}	2024-05-01 15:06:57.593728
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:07:00:70"}	2024-05-01 15:07:00.133916
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:07:01:71"}	2024-05-01 15:07:01.833025
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:09:43:943"}	2024-05-01 15:09:43.59829
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:10:54:1054"}	2024-05-01 15:10:54.461579
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:18:27:1827"}	2024-05-01 15:18:27.596724
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:19:01:191"}	2024-05-01 15:19:01.71056
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:19:55:1955"}	2024-05-01 15:19:55.238087
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:32:08:328"}	2024-05-01 15:32:08.771253
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:34:09:349"}	2024-05-01 15:34:09.314108
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:35:43:3543"}	2024-05-01 15:35:43.204324
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:38:03:383"}	2024-05-01 15:38:03.427416
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:41:19:4119"}	2024-05-01 15:41:19.663319
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:41:37:4137"}	2024-05-01 15:41:37.401132
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:14:4314"}	2024-05-01 15:43:14.211669
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:19:4319"}	2024-05-01 15:43:19.16651
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:48:4348"}	2024-05-01 15:43:48.417158
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:44:10:4410"}	2024-05-01 15:44:11.017935
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:46:06:466"}	2024-05-01 15:46:06.880624
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:02:512"}	2024-05-01 15:51:02.101891
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:29:5129"}	2024-05-01 15:51:29.608991
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:45:5145"}	2024-05-01 15:51:45.28135
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:57:39:5739"}	2024-05-01 15:57:39.13593
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:58:10:5810"}	2024-05-01 15:58:10.928058
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:38:5938"}	2024-05-01 15:59:38.203757
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:46:5946"}	2024-05-01 15:59:46.672736
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:57:5957"}	2024-05-01 15:59:57.274858
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:00:22:022"}	2024-05-01 16:00:22.853404
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:07:08:78"}	2024-05-01 16:07:08.093292
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:08:98"}	2024-05-01 16:09:08.84946
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:15:915"}	2024-05-01 16:09:15.961312
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:41:941"}	2024-05-01 16:09:41.386666
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:48:948"}	2024-05-01 16:09:48.868831
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:41:08:418"}	2024-05-01 16:41:08.389093
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:42:10:4210"}	2024-05-01 16:42:10.289377
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:42:29:4229"}	2024-05-01 16:42:29.264831
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:45:47:4547"}	2024-05-01 16:45:47.962136
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:45:53:4553"}	2024-05-01 16:45:53.094097
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:46:20:4620"}	2024-05-01 16:46:20.87907
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:01:41:141"}	2024-05-01 18:01:41.25457
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:02:00:20"}	2024-05-01 18:02:00.180871
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:02:31:231"}	2024-05-01 18:02:32.034365
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:04:13:413"}	2024-05-01 18:04:13.881321
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:51:15:5115"}	2024-05-01 18:51:15.427626
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:13:13:1313"}	2024-05-01 20:13:13.544587
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:33:58:3358"}	2024-05-01 20:33:59.023104
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:34:35:3435"}	2024-05-01 20:34:35.677396
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:55:40:5540"}	2024-05-01 20:55:40.717974
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:01:36:136"}	2024-05-01 21:01:36.941634
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:03:39:339"}	2024-05-01 21:03:39.241901
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:08:41:841"}	2024-05-01 21:08:41.449927
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 11:45:12:4512"}	2024-05-02 11:45:13.007013
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 12:27:23:2723"}	2024-05-02 12:27:23.266075
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 14:34:16:3416"}	2024-05-02 14:34:16.928704
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 14:34:19:3419"}	2024-05-02 14:34:19.691711
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 17:38:04:384"}	2024-05-02 17:38:04.284101
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 17:38:11:3811"}	2024-05-02 17:38:11.453377
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 18:58:45:5845"}	2024-05-02 18:58:45.147458
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:00:39:039"}	2024-05-02 19:00:39.713421
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:28:08:288"}	2024-05-02 19:28:08.629253
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:44:41:4441"}	2024-05-02 19:44:41.14859
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:41:12:4112"}	2024-05-02 22:41:12.915197
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:45:07:457"}	2024-05-02 22:45:08.054941
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:45:45:4545"}	2024-05-02 22:45:45.883111
info	Server started on PORT 5000...	{"timestamp":"2024-05-03 13:22:30:2230"}	2024-05-03 13:22:30.096785
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 11:38:56:3856"}	2024-05-04 11:38:56.130366
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:14:3714"}	2024-05-04 12:37:14.231948
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:31:3731"}	2024-05-04 12:37:31.721585
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:43:3743"}	2024-05-04 12:37:43.417484
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:49:3749"}	2024-05-04 12:37:49.979847
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:59:3759"}	2024-05-04 12:37:59.433836
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:02:382"}	2024-05-04 12:38:02.196244
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:08:388"}	2024-05-04 12:38:08.502013
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:12:3812"}	2024-05-04 12:38:12.106704
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:35:3835"}	2024-05-04 12:38:35.540596
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:46:3946"}	2024-05-04 12:39:46.918504
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:48:3948"}	2024-05-04 12:39:49.019325
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:57:3957"}	2024-05-04 12:39:57.149309
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:40:15:4015"}	2024-05-04 12:40:15.376532
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:40:18:4018"}	2024-05-04 12:40:18.800563
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:44:03:443"}	2024-05-04 12:44:04.03387
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:48:34:4834"}	2024-05-04 12:48:34.508785
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:48:51:4851"}	2024-05-04 12:48:51.752586
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:01:491"}	2024-05-04 12:49:01.46006
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:19:4919"}	2024-05-04 12:49:20.012848
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:22:4922"}	2024-05-04 12:49:22.491778
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:25:4925"}	2024-05-04 12:49:25.493352
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:51:19:5119"}	2024-05-04 13:51:19.54565
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:51:27:5127"}	2024-05-04 13:51:27.801827
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:08:528"}	2024-05-04 13:52:08.982726
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:19:5219"}	2024-05-04 13:52:19.275019
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:28:5228"}	2024-05-04 13:52:28.361942
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:39:5239"}	2024-05-04 13:52:39.610706
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:49:5249"}	2024-05-04 13:52:49.310802
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:56:5256"}	2024-05-04 13:52:57.014684
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 15:52:33:5233"}	2024-05-04 15:52:33.442863
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:13:08:138"}	2024-05-04 17:13:08.670141
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:02:272"}	2024-05-04 17:27:02.728155
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:08:278"}	2024-05-04 17:27:08.567326
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:19:2719"}	2024-05-04 17:27:19.750048
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:34:2734"}	2024-05-04 17:27:34.050522
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:41:2741"}	2024-05-04 17:27:41.238105
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:49:2749"}	2024-05-04 17:27:49.278085
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:29:36:2936"}	2024-05-04 17:29:36.299956
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:32:11:3211"}	2024-05-04 17:32:12.090251
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:33:37:3337"}	2024-05-04 17:33:37.401973
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:45:00:450"}	2024-05-04 17:45:00.723737
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:45:55:4555"}	2024-05-04 17:45:55.240335
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:08:478"}	2024-05-04 17:47:08.04529
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:30:4730"}	2024-05-04 17:47:30.586088
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:56:4756"}	2024-05-04 17:47:56.362858
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:48:04:484"}	2024-05-04 17:48:04.780343
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:50:27:5027"}	2024-05-04 17:50:27.062777
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:50:53:5053"}	2024-05-04 17:50:53.570502
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:30:29:3029"}	2024-05-04 18:30:29.50506
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:30:37:3037"}	2024-05-04 18:30:37.701803
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:31:26:3126"}	2024-05-04 18:31:26.498698
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:32:42:3242"}	2024-05-04 18:32:42.180573
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:00:360"}	2024-05-04 18:36:00.946842
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:04:364"}	2024-05-04 18:36:04.873845
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:35:3635"}	2024-05-04 18:36:35.192064
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:07:40:740"}	2024-05-04 19:07:40.838171
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:08:41:841"}	2024-05-04 19:08:41.531686
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:08:58:858"}	2024-05-04 19:08:59.00901
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:09:41:941"}	2024-05-04 19:09:41.557315
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:10:55:1055"}	2024-05-04 19:10:55.51814
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:14:00:140"}	2024-05-04 19:14:00.617878
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:26:03:263"}	2024-05-04 19:26:03.998272
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 22:02:00:20"}	2024-05-04 22:02:00.990187
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 22:09:26:926"}	2024-05-04 22:09:26.862413
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 23:01:21:121"}	2024-05-04 23:01:21.726147
info	Server started on PORT 5000...	{"timestamp":"2024-05-05 20:37:00:370"}	2024-05-05 20:37:00.407945
info	Server started on PORT 5000...	{"timestamp":"2024-05-06 10:34:07:347"}	2024-05-06 10:34:07.813362
info	Server started on PORT 5000...	{"timestamp":"2024-05-06 15:23:51:2351"}	2024-05-06 15:23:51.573403
info	Server started on PORT 5000...	{"timestamp":"2024-05-06 15:23:55:2355"}	2024-05-06 15:23:55.843018
error	Ошибка при создании продукта:	{"timestamp":"2024-05-06 16:35:33:3533"}	2024-05-06 16:35:33.748349
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
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:29:58:2958"}	2024-04-20 11:29:58.984167
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:35:14:3514"}	2024-04-20 11:35:14.234591
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:35:32:3532"}	2024-04-20 11:35:33.067044
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:38:39:3839"}	2024-04-20 11:38:39.697339
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:39:39:3939"}	2024-04-20 11:39:39.785309
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:40:22:4022"}	2024-04-20 11:40:22.210646
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:42:01:421"}	2024-04-20 11:42:02.068121
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:43:16:4316"}	2024-04-20 11:43:16.877345
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:43:58:4358"}	2024-04-20 11:43:58.571106
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:46:10:4610"}	2024-04-20 11:46:10.663484
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:55:48:5548"}	2024-04-20 11:55:48.880942
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 11:57:48:5748"}	2024-04-20 11:57:48.470976
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:13:30:1330"}	2024-04-20 12:13:30.85628
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:17:29:1729"}	2024-04-20 12:17:29.572169
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 12:20:18:2018"}	2024-04-20 12:20:18.236087
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:05:30:530"}	2024-04-20 13:05:30.488219
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:08:49:849"}	2024-04-20 13:08:49.663844
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:09:03:93"}	2024-04-20 13:09:03.796679
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:09:29:929"}	2024-04-20 13:09:29.096772
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:17:1417"}	2024-04-20 13:14:17.917488
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:29:1429"}	2024-04-20 13:14:29.878788
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:14:56:1456"}	2024-04-20 13:14:56.283683
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:15:00:150"}	2024-04-20 13:15:00.527144
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:32:2032"}	2024-04-20 13:20:32.735878
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:39:2039"}	2024-04-20 13:20:39.684324
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:20:47:2047"}	2024-04-20 13:20:48.046914
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:21:01:211"}	2024-04-20 13:21:01.586394
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:21:21:2121"}	2024-04-20 13:21:21.412775
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:30:23:3023"}	2024-04-20 13:30:23.637606
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:32:17:3217"}	2024-04-20 13:32:17.183059
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:32:51:3251"}	2024-04-20 13:32:51.547434
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:37:08:378"}	2024-04-20 13:37:08.721403
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:38:38:3838"}	2024-04-20 13:38:38.618962
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:39:15:3915"}	2024-04-20 13:39:15.348174
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:39:49:3949"}	2024-04-20 13:39:49.47188
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:41:41:4141"}	2024-04-20 13:41:41.32025
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 13:49:16:4916"}	2024-04-20 13:49:16.206033
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:23:26:2326"}	2024-04-20 18:23:26.217698
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:23:53:2353"}	2024-04-20 18:23:53.219403
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:05:275"}	2024-04-20 18:27:05.621815
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:15:2715"}	2024-04-20 18:27:15.876505
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:27:35:2735"}	2024-04-20 18:27:35.776592
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:28:13:2813"}	2024-04-20 18:28:13.092727
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:28:33:2833"}	2024-04-20 18:28:33.696455
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:37:27:3727"}	2024-04-20 18:37:27.212782
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:38:48:3848"}	2024-04-20 18:38:48.342109
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:38:51:3851"}	2024-04-20 18:38:51.662216
info	Server started on PORT 5000...	{"timestamp":"2024-04-20 18:39:30:3930"}	2024-04-20 18:39:30.647658
info	Server started on PORT 5000...	{"timestamp":"2024-04-21 10:21:28:2128"}	2024-04-21 10:21:29.186711
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:46:24:4624"}	2024-04-22 12:46:24.98546
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:50:43:5043"}	2024-04-22 12:50:44.026376
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:58:15:5815"}	2024-04-22 12:58:15.616932
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 12:59:57:5957"}	2024-04-22 12:59:57.532729
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:00:22:022"}	2024-04-22 13:00:22.649106
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:02:21:221"}	2024-04-22 13:02:21.765958
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:03:16:316"}	2024-04-22 13:03:16.271767
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:04:49:449"}	2024-04-22 13:04:49.588434
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:05:41:541"}	2024-04-22 13:05:41.421378
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:06:24:624"}	2024-04-22 13:06:24.522904
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:07:56:756"}	2024-04-22 13:07:56.510015
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:09:48:948"}	2024-04-22 13:09:48.792464
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:10:16:1016"}	2024-04-22 13:10:17.064124
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:10:49:1049"}	2024-04-22 13:10:49.640919
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:12:51:1251"}	2024-04-22 13:12:51.685163
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:13:48:1348"}	2024-04-22 13:13:48.42834
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:16:44:1644"}	2024-04-22 13:16:44.960097
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 13:30:32:3032"}	2024-04-22 13:30:32.231471
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:17:01:171"}	2024-04-22 14:17:01.371159
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:17:33:1733"}	2024-04-22 14:17:33.214257
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:29:16:2916"}	2024-04-22 14:29:16.31702
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:29:32:2932"}	2024-04-22 14:29:32.338441
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 14:32:23:3223"}	2024-04-22 14:32:24.068431
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:27:13:2713"}	2024-04-22 15:27:13.14935
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:32:20:3220"}	2024-04-22 15:32:20.234838
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 15:43:19:4319"}	2024-04-22 15:43:19.292684
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:24:09:249"}	2024-04-22 21:24:09.796936
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:24:15:2415"}	2024-04-22 21:24:15.345963
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:25:55:2555"}	2024-04-22 21:25:55.316998
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:25:57:2557"}	2024-04-22 21:25:57.145742
info	Server started on PORT 5000...	{"timestamp":"2024-04-22 21:30:27:3027"}	2024-04-22 21:30:27.29035
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:46:16:4616"}	2024-04-23 00:46:16.484668
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:47:53:4753"}	2024-04-23 00:47:54.053737
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:48:34:4834"}	2024-04-23 00:48:34.571484
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:54:25:5425"}	2024-04-23 00:54:25.481437
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 00:54:56:5456"}	2024-04-23 00:54:56.276703
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 09:44:28:4428"}	2024-04-23 09:44:28.402435
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 14:55:49:5549"}	2024-04-23 14:55:49.682967
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 22:41:33:4133"}	2024-04-23 22:41:33.276339
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 22:41:46:4146"}	2024-04-23 22:41:46.579494
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:06:36:636"}	2024-04-23 23:06:36.921508
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:06:53:653"}	2024-04-23 23:06:53.391082
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:01:71"}	2024-04-23 23:07:01.205497
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:14:714"}	2024-04-23 23:07:14.455837
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:22:722"}	2024-04-23 23:07:22.282738
info	Server started on PORT 5000...	{"timestamp":"2024-04-23 23:07:28:728"}	2024-04-23 23:07:28.64065
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:16:41:1641"}	2024-04-24 11:16:41.668722
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:18:02:182"}	2024-04-24 11:18:02.826209
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:35:50:3550"}	2024-04-24 11:35:50.900509
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 11:37:59:3759"}	2024-04-24 11:37:59.970763
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:18:28:1828"}	2024-04-24 12:18:28.579791
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:31:32:3132"}	2024-04-24 12:31:32.362346
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 12:32:22:3222"}	2024-04-24 12:32:22.663943
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:42:33:4233"}	2024-04-24 18:42:33.541233
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:48:27:4827"}	2024-04-24 18:48:27.23808
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:48:56:4856"}	2024-04-24 18:48:56.832603
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:58:24:5824"}	2024-04-24 18:58:24.091795
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 18:59:23:5923"}	2024-04-24 18:59:23.785909
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:00:06:06"}	2024-04-24 19:00:06.726684
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:03:49:349"}	2024-04-24 19:03:49.287833
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:04:42:442"}	2024-04-24 19:04:42.978829
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:04:45:445"}	2024-04-24 19:04:45.69823
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:07:12:712"}	2024-04-24 19:07:12.122919
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:07:50:750"}	2024-04-24 19:07:50.313547
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 19:08:06:86"}	2024-04-24 19:08:06.057304
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:20:5320"}	2024-04-24 20:53:20.453481
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:36:5336"}	2024-04-24 20:53:36.65968
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 20:53:54:5354"}	2024-04-24 20:53:55.005538
info	Server started on PORT 5000...	{"timestamp":"2024-04-24 21:08:03:83"}	2024-04-24 21:08:03.159456
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 13:55:07:557"}	2024-04-25 13:55:07.484137
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:35:635"}	2024-04-25 14:06:35.172183
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:46:646"}	2024-04-25 14:06:46.676239
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:06:55:655"}	2024-04-25 14:06:55.382661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:20:58:2058"}	2024-04-25 14:20:58.516843
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:21:05:215"}	2024-04-25 14:21:05.154436
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:21:44:2144"}	2024-04-25 14:21:44.197562
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:27:58:2758"}	2024-04-25 14:27:59.0812
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:30:26:3026"}	2024-04-25 14:30:26.785891
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:32:27:3227"}	2024-04-25 14:32:27.391499
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:34:03:343"}	2024-04-25 14:34:04.014915
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:34:50:3450"}	2024-04-25 14:34:50.821215
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:42:28:4228"}	2024-04-25 14:42:28.992032
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:42:36:4236"}	2024-04-25 14:42:36.356091
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:43:15:4315"}	2024-04-25 14:43:15.950116
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:43:51:4351"}	2024-04-25 14:43:51.233694
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:52:51:5251"}	2024-04-25 14:52:51.944558
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:52:54:5254"}	2024-04-25 14:52:55.091933
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:03:533"}	2024-04-25 14:53:03.850072
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:09:539"}	2024-04-25 14:53:09.258587
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 14:53:12:5312"}	2024-04-25 14:53:13.083931
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:02:02:22"}	2024-04-25 15:02:02.613829
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:02:25:225"}	2024-04-25 15:02:25.882342
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:08:31:831"}	2024-04-25 15:08:31.817644
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:09:09:99"}	2024-04-25 15:09:09.486888
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:10:30:1030"}	2024-04-25 15:10:30.19922
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:10:55:1055"}	2024-04-25 15:10:55.540716
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:11:30:1130"}	2024-04-25 15:11:30.82345
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:12:06:126"}	2024-04-25 15:12:06.852433
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:14:29:1429"}	2024-04-25 15:14:29.834172
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:22:52:2252"}	2024-04-25 15:22:52.179099
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:23:13:2313"}	2024-04-25 15:23:13.555413
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 15:23:58:2358"}	2024-04-25 15:23:58.869754
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 17:59:01:591"}	2024-04-25 17:59:01.70134
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:10:08:108"}	2024-04-25 18:10:09.034746
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:10:27:1027"}	2024-04-25 18:10:27.807152
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:11:09:119"}	2024-04-25 18:11:09.900187
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:12:39:1239"}	2024-04-25 18:12:39.080768
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:12:48:1248"}	2024-04-25 18:12:49.133839
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:13:02:132"}	2024-04-25 18:13:02.171607
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:13:22:1322"}	2024-04-25 18:13:22.779849
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:17:42:1742"}	2024-04-25 18:17:42.596714
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 18:49:04:494"}	2024-04-25 18:49:04.780806
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:25:27:2527"}	2024-04-25 19:25:27.734295
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:26:18:2618"}	2024-04-25 19:26:18.886539
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:26:56:2656"}	2024-04-25 19:26:56.660611
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:27:01:271"}	2024-04-25 19:27:01.913237
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 19:59:35:5935"}	2024-04-25 19:59:35.850116
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:00:56:056"}	2024-04-25 20:00:56.298919
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:14:114"}	2024-04-25 20:01:14.422259
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:24:124"}	2024-04-25 20:01:25.015294
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:29:129"}	2024-04-25 20:01:29.843728
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:01:36:136"}	2024-04-25 20:01:36.940326
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:03:43:343"}	2024-04-25 20:03:43.378842
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:09:11:911"}	2024-04-25 20:09:11.106628
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:12:28:1228"}	2024-04-25 20:12:28.56519
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:13:25:1325"}	2024-04-25 20:13:25.096765
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:14:23:1423"}	2024-04-25 20:14:23.387532
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:18:16:1816"}	2024-04-25 20:18:16.65379
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:21:02:212"}	2024-04-25 20:21:02.770281
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:27:22:2722"}	2024-04-25 20:27:22.852804
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:10:2810"}	2024-04-25 20:28:10.446768
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:17:2817"}	2024-04-25 20:28:17.109588
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:28:24:2824"}	2024-04-25 20:28:25.028557
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:06:316"}	2024-04-25 20:31:06.657245
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:19:3119"}	2024-04-25 20:31:19.546331
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:31:49:3149"}	2024-04-25 20:31:49.795478
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:34:06:346"}	2024-04-25 20:34:06.735267
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:44:04:444"}	2024-04-25 20:44:04.987442
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:46:03:463"}	2024-04-25 20:46:03.353383
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:04:474"}	2024-04-25 20:47:04.305666
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:17:4717"}	2024-04-25 20:47:17.061354
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:24:4724"}	2024-04-25 20:47:24.177327
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:47:34:4734"}	2024-04-25 20:47:34.693612
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:06:506"}	2024-04-25 20:50:06.704984
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:13:5013"}	2024-04-25 20:50:13.776679
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:50:19:5019"}	2024-04-25 20:50:19.771341
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:52:17:5217"}	2024-04-25 20:52:17.083089
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:08:568"}	2024-04-25 20:56:08.286848
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:28:5628"}	2024-04-25 20:56:29.018661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:44:5644"}	2024-04-25 20:56:44.33882
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:56:56:5656"}	2024-04-25 20:56:56.510789
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:57:12:5712"}	2024-04-25 20:57:12.718301
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:58:44:5844"}	2024-04-25 20:58:44.659679
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 20:59:24:5924"}	2024-04-25 20:59:24.796726
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:25:59:2559"}	2024-04-25 21:25:59.815841
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:27:00:270"}	2024-04-25 21:27:01.019343
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:38:22:3822"}	2024-04-25 21:38:22.165626
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:46:51:4651"}	2024-04-25 21:46:51.557416
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:47:56:4756"}	2024-04-25 21:47:56.696318
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:54:24:5424"}	2024-04-25 21:54:24.700602
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:12:5712"}	2024-04-25 21:57:12.231196
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:29:5729"}	2024-04-25 21:57:29.449793
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 21:57:58:5758"}	2024-04-25 21:57:58.116872
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:12:34:1234"}	2024-04-25 22:12:34.595488
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:13:57:1357"}	2024-04-25 22:13:58.030144
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:14:38:1438"}	2024-04-25 22:14:38.135661
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:15:14:1514"}	2024-04-25 22:15:14.265506
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:16:50:1650"}	2024-04-25 22:16:50.535594
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:26:32:2632"}	2024-04-25 22:26:32.307786
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:57:36:5736"}	2024-04-25 22:57:36.801717
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 22:59:23:5923"}	2024-04-25 22:59:23.305793
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:07:06:76"}	2024-04-25 23:07:06.508939
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:08:39:839"}	2024-04-25 23:08:39.905516
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:13:57:1357"}	2024-04-25 23:13:57.245374
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:40:05:405"}	2024-04-25 23:40:06.158153
info	Server started on PORT 5000...	{"timestamp":"2024-04-25 23:40:39:4039"}	2024-04-25 23:40:39.939471
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 10:16:47:1647"}	2024-04-26 10:16:47.865893
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 10:48:31:4831"}	2024-04-26 10:48:31.283888
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:05:58:558"}	2024-04-26 11:05:58.483116
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:08:04:84"}	2024-04-26 11:08:05.094267
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 11:09:16:916"}	2024-04-26 11:09:16.987706
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 12:33:02:332"}	2024-04-26 12:33:02.742515
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:04:44:444"}	2024-04-26 13:04:44.318914
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:12:04:124"}	2024-04-26 13:12:04.839458
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:15:02:152"}	2024-04-26 13:15:02.4435
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 13:15:23:1523"}	2024-04-26 13:15:23.603952
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 16:21:53:2153"}	2024-04-26 16:21:53.674663
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:45:05:455"}	2024-04-26 20:45:05.998507
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:47:19:4719"}	2024-04-26 20:47:19.453454
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:04:484"}	2024-04-26 20:48:04.282841
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:34:4834"}	2024-04-26 20:48:34.717704
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:48:41:4841"}	2024-04-26 20:48:41.341226
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:49:00:490"}	2024-04-26 20:49:00.135341
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:49:16:4916"}	2024-04-26 20:49:16.848692
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:50:27:5027"}	2024-04-26 20:50:27.36003
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:51:18:5118"}	2024-04-26 20:51:18.181275
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 20:51:27:5127"}	2024-04-26 20:51:27.938841
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:15:49:1549"}	2024-04-26 21:15:49.117145
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:10:2210"}	2024-04-26 21:22:10.132892
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:32:2232"}	2024-04-26 21:22:32.550295
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:22:56:2256"}	2024-04-26 21:22:56.506623
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:26:01:261"}	2024-04-26 21:26:01.160984
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:26:37:2637"}	2024-04-26 21:26:37.120234
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:47:27:4727"}	2024-04-26 21:47:27.821131
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:47:53:4753"}	2024-04-26 21:47:53.393451
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:49:48:4948"}	2024-04-26 21:49:48.912019
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 21:50:14:5014"}	2024-04-26 21:50:14.458097
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:04:54:454"}	2024-04-26 22:04:54.897692
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:07:32:732"}	2024-04-26 22:07:32.255272
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:13:40:1340"}	2024-04-26 22:13:40.502183
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:13:46:1346"}	2024-04-26 22:13:46.206658
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:14:01:141"}	2024-04-26 22:14:01.059468
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:17:03:173"}	2024-04-26 22:17:03.28356
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:19:54:1954"}	2024-04-26 22:19:54.933777
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:20:26:2026"}	2024-04-26 22:20:26.255385
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:22:14:2214"}	2024-04-26 22:22:14.395273
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:25:17:2517"}	2024-04-26 22:25:17.652459
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:26:52:2652"}	2024-04-26 22:26:52.078539
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 22:33:14:3314"}	2024-04-26 22:33:14.391001
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:24:47:2447"}	2024-04-26 23:24:47.446038
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:25:53:2553"}	2024-04-26 23:25:53.992192
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:27:44:2744"}	2024-04-26 23:27:44.46684
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:28:47:2847"}	2024-04-26 23:28:47.835082
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:31:34:3134"}	2024-04-26 23:31:34.830611
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:31:38:3138"}	2024-04-26 23:31:38.421059
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:32:46:3246"}	2024-04-26 23:32:46.230595
info	Server started on PORT 5000...	{"timestamp":"2024-04-26 23:39:04:394"}	2024-04-26 23:39:04.844922
info	Server started on PORT 5000...	{"timestamp":"2024-04-27 10:57:17:5717"}	2024-04-27 10:57:18.067174
info	Server started on PORT 5000...	{"timestamp":"2024-04-27 12:32:25:3225"}	2024-04-27 12:32:25.940204
info	Server started on PORT 5000...	{"timestamp":"2024-04-28 13:07:30:730"}	2024-04-28 13:07:30.937276
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:05:04:54"}	2024-04-29 06:05:04.379995
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:06:33:633"}	2024-04-29 06:06:33.693292
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:11:22:1122"}	2024-04-29 06:11:22.498339
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:12:31:1231"}	2024-04-29 06:12:31.268203
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:17:50:1750"}	2024-04-29 06:17:50.493728
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:19:43:1943"}	2024-04-29 06:19:43.540397
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:20:02:202"}	2024-04-29 06:20:02.182618
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 06:43:31:4331"}	2024-04-29 06:43:31.109497
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:14:17:1417"}	2024-04-29 07:14:17.831155
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:16:33:1633"}	2024-04-29 07:16:33.303791
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 07:17:33:1733"}	2024-04-29 07:17:33.859715
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 15:11:14:1114"}	2024-04-29 15:11:14.524289
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 15:35:12:3512"}	2024-04-29 15:35:12.703304
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 20:28:11:2811"}	2024-04-29 20:28:11.979226
info	Server started on PORT 5000...	{"timestamp":"2024-04-29 22:19:31:1931"}	2024-04-29 22:19:31.151138
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 11:21:43:2143"}	2024-04-30 11:21:43.358999
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:10:38:1038"}	2024-04-30 17:10:38.943246
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:12:58:1258"}	2024-04-30 17:12:58.721199
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:13:31:1331"}	2024-04-30 17:13:31.414161
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:07:147"}	2024-04-30 17:14:07.619948
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:25:1425"}	2024-04-30 17:14:25.515371
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:14:48:1448"}	2024-04-30 17:14:48.354828
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:15:19:1519"}	2024-04-30 17:15:19.832296
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:16:22:1622"}	2024-04-30 17:16:23.032399
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:17:47:1747"}	2024-04-30 17:17:47.692444
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:17:55:1755"}	2024-04-30 17:17:55.894933
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:19:36:1936"}	2024-04-30 17:19:36.806226
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:31:29:3129"}	2024-04-30 17:31:30.03024
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:48:53:4853"}	2024-04-30 17:48:53.321125
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:49:01:491"}	2024-04-30 17:49:01.437861
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:49:09:499"}	2024-04-30 17:49:10.04747
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:50:54:5054"}	2024-04-30 17:50:54.784361
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:51:41:5141"}	2024-04-30 17:51:41.217334
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 17:59:53:5953"}	2024-04-30 17:59:53.352336
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:02:27:227"}	2024-04-30 18:02:27.891772
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:51:14:5114"}	2024-04-30 18:51:14.40831
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:51:54:5154"}	2024-04-30 18:51:54.684936
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:53:02:532"}	2024-04-30 18:53:02.288715
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:53:25:5325"}	2024-04-30 18:53:25.586647
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 18:54:00:540"}	2024-04-30 18:54:00.672405
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:35:2335"}	2024-04-30 19:23:35.528131
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:50:2350"}	2024-04-30 19:23:50.073155
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:23:59:2359"}	2024-04-30 19:23:59.505813
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:13:2413"}	2024-04-30 19:24:13.462015
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:24:2424"}	2024-04-30 19:24:24.401073
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:24:44:2444"}	2024-04-30 19:24:44.494514
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:26:35:2635"}	2024-04-30 19:26:35.817421
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:02:272"}	2024-04-30 19:27:02.461214
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:33:2733"}	2024-04-30 19:27:33.665084
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:27:51:2751"}	2024-04-30 19:27:51.192568
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:28:18:2818"}	2024-04-30 19:28:18.393312
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:28:51:2851"}	2024-04-30 19:28:51.143591
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:30:52:3052"}	2024-04-30 19:30:52.657015
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:31:24:3124"}	2024-04-30 19:31:24.950917
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:31:51:3151"}	2024-04-30 19:31:51.88611
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:37:18:3718"}	2024-04-30 19:37:18.750725
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:40:41:4041"}	2024-04-30 19:40:41.318011
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:40:50:4050"}	2024-04-30 19:40:50.626964
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:46:54:4654"}	2024-04-30 19:46:54.714349
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:05:475"}	2024-04-30 19:47:05.307346
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:13:4713"}	2024-04-30 19:47:13.519626
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:29:4729"}	2024-04-30 19:47:29.136261
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:47:43:4743"}	2024-04-30 19:47:43.634707
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 19:57:00:570"}	2024-04-30 19:57:00.816544
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:02:44:244"}	2024-04-30 20:02:44.29408
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:04:12:412"}	2024-04-30 20:04:12.478017
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:04:30:430"}	2024-04-30 20:04:30.799456
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:05:08:58"}	2024-04-30 20:05:08.322183
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:07:77"}	2024-04-30 20:07:07.373119
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:17:717"}	2024-04-30 20:07:18.03826
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:38:738"}	2024-04-30 20:07:38.481229
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:07:55:755"}	2024-04-30 20:07:55.265266
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:31:831"}	2024-04-30 20:08:31.665981
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:51:851"}	2024-04-30 20:08:51.365394
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:08:56:856"}	2024-04-30 20:08:56.397376
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:21:02:212"}	2024-04-30 20:21:02.89604
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:21:24:2124"}	2024-04-30 20:21:24.751557
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:22:42:2242"}	2024-04-30 20:22:42.870714
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 20:23:17:2317"}	2024-04-30 20:23:17.152504
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:16:20:1620"}	2024-04-30 21:16:21.049622
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:07:337"}	2024-04-30 21:33:08.033315
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:15:3315"}	2024-04-30 21:33:15.350128
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:33:50:3350"}	2024-04-30 21:33:50.709822
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:34:25:3425"}	2024-04-30 21:34:25.077111
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:35:00:350"}	2024-04-30 21:35:00.57391
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:35:29:3529"}	2024-04-30 21:35:29.27812
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:48:43:4843"}	2024-04-30 21:48:43.656694
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:48:46:4846"}	2024-04-30 21:48:46.257343
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:49:22:4922"}	2024-04-30 21:49:22.214616
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:58:48:5848"}	2024-04-30 21:58:48.971448
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 21:58:51:5851"}	2024-04-30 21:58:51.665228
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:00:58:058"}	2024-04-30 22:00:58.563897
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:05:34:534"}	2024-04-30 22:05:34.742862
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:02:62"}	2024-04-30 22:06:02.560277
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:15:615"}	2024-04-30 22:06:15.361824
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:06:25:625"}	2024-04-30 22:06:25.453633
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:09:209"}	2024-04-30 22:20:09.098783
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:35:2035"}	2024-04-30 22:20:35.602146
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:20:43:2043"}	2024-04-30 22:20:43.92715
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:22:05:225"}	2024-04-30 22:22:05.771271
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 22:26:45:2645"}	2024-04-30 22:26:45.785701
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:41:44:4144"}	2024-04-30 23:41:44.888181
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:44:55:4455"}	2024-04-30 23:44:55.741391
info	Server started on PORT 5000...	{"timestamp":"2024-04-30 23:47:51:4751"}	2024-04-30 23:47:51.518667
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:29:35:2935"}	2024-05-01 10:29:35.273675
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:36:18:3618"}	2024-05-01 10:36:18.405514
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:43:15:4315"}	2024-05-01 10:43:16.050496
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:44:03:443"}	2024-05-01 10:44:03.531115
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:46:17:4617"}	2024-05-01 10:46:17.592881
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:46:48:4648"}	2024-05-01 10:46:48.366639
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:48:10:4810"}	2024-05-01 10:48:11.051459
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:48:20:4820"}	2024-05-01 10:48:20.877356
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:49:54:4954"}	2024-05-01 10:49:54.835274
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 10:50:21:5021"}	2024-05-01 10:50:21.882254
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:06:16:616"}	2024-05-01 11:06:16.835756
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:06:46:646"}	2024-05-01 11:06:46.832564
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:07:23:723"}	2024-05-01 11:07:23.591681
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:08:27:827"}	2024-05-01 11:08:27.606132
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 11:11:54:1154"}	2024-05-01 11:11:54.246117
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 13:59:44:5944"}	2024-05-01 13:59:44.682382
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:06:26:626"}	2024-05-01 14:06:26.929299
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:05:85"}	2024-05-01 14:08:05.405556
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:22:822"}	2024-05-01 14:08:22.731049
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:08:48:848"}	2024-05-01 14:08:48.711782
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:03:93"}	2024-05-01 14:09:03.310554
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:39:939"}	2024-05-01 14:09:39.847445
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:51:951"}	2024-05-01 14:09:51.06893
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:09:58:958"}	2024-05-01 14:09:58.753837
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:10:10:1010"}	2024-05-01 14:10:10.261294
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:10:41:1041"}	2024-05-01 14:10:41.843661
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:13:28:1328"}	2024-05-01 14:13:28.943332
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:05:165"}	2024-05-01 14:16:05.700763
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:10:1610"}	2024-05-01 14:16:10.517961
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:27:1627"}	2024-05-01 14:16:27.981988
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:16:59:1659"}	2024-05-01 14:16:59.379883
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:17:07:177"}	2024-05-01 14:17:08.028366
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:10:1810"}	2024-05-01 14:18:10.892944
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:44:1844"}	2024-05-01 14:18:44.940331
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:18:55:1855"}	2024-05-01 14:18:55.96561
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:26:42:2642"}	2024-05-01 14:26:42.351169
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:27:05:275"}	2024-05-01 14:27:06.003479
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:27:55:2755"}	2024-05-01 14:27:55.233892
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:28:51:2851"}	2024-05-01 14:28:51.354671
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:39:3039"}	2024-05-01 14:30:39.38606
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:42:3042"}	2024-05-01 14:30:42.075927
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:49:3049"}	2024-05-01 14:30:49.213742
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:30:59:3059"}	2024-05-01 14:30:59.622099
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:31:04:314"}	2024-05-01 14:31:04.900404
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:31:07:317"}	2024-05-01 14:31:07.845608
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:44:48:4448"}	2024-05-01 14:44:48.200173
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:45:44:4544"}	2024-05-01 14:45:44.863141
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:52:30:5230"}	2024-05-01 14:52:30.280094
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:52:42:5242"}	2024-05-01 14:52:42.231655
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:58:22:5822"}	2024-05-01 14:58:22.377775
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 14:58:39:5839"}	2024-05-01 14:58:39.427793
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:03:10:310"}	2024-05-01 15:03:10.833487
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:06:57:657"}	2024-05-01 15:06:57.593728
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:07:00:70"}	2024-05-01 15:07:00.133916
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:07:01:71"}	2024-05-01 15:07:01.833025
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:09:43:943"}	2024-05-01 15:09:43.59829
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:10:54:1054"}	2024-05-01 15:10:54.461579
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:18:27:1827"}	2024-05-01 15:18:27.596724
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:19:01:191"}	2024-05-01 15:19:01.71056
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:19:55:1955"}	2024-05-01 15:19:55.238087
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:32:08:328"}	2024-05-01 15:32:08.771253
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:34:09:349"}	2024-05-01 15:34:09.314108
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:35:43:3543"}	2024-05-01 15:35:43.204324
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:38:03:383"}	2024-05-01 15:38:03.427416
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:41:19:4119"}	2024-05-01 15:41:19.663319
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:41:37:4137"}	2024-05-01 15:41:37.401132
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:14:4314"}	2024-05-01 15:43:14.211669
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:19:4319"}	2024-05-01 15:43:19.16651
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:43:48:4348"}	2024-05-01 15:43:48.417158
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:44:10:4410"}	2024-05-01 15:44:11.017935
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:46:06:466"}	2024-05-01 15:46:06.880624
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:02:512"}	2024-05-01 15:51:02.101891
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:29:5129"}	2024-05-01 15:51:29.608991
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:51:45:5145"}	2024-05-01 15:51:45.28135
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:57:39:5739"}	2024-05-01 15:57:39.13593
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:58:10:5810"}	2024-05-01 15:58:10.928058
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:38:5938"}	2024-05-01 15:59:38.203757
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:46:5946"}	2024-05-01 15:59:46.672736
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 15:59:57:5957"}	2024-05-01 15:59:57.274858
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:00:22:022"}	2024-05-01 16:00:22.853404
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:07:08:78"}	2024-05-01 16:07:08.093292
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:08:98"}	2024-05-01 16:09:08.84946
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:15:915"}	2024-05-01 16:09:15.961312
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:41:941"}	2024-05-01 16:09:41.386666
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:09:48:948"}	2024-05-01 16:09:48.868831
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:41:08:418"}	2024-05-01 16:41:08.389093
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:42:10:4210"}	2024-05-01 16:42:10.289377
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:42:29:4229"}	2024-05-01 16:42:29.264831
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:45:47:4547"}	2024-05-01 16:45:47.962136
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:45:53:4553"}	2024-05-01 16:45:53.094097
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 16:46:20:4620"}	2024-05-01 16:46:20.87907
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:01:41:141"}	2024-05-01 18:01:41.25457
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:02:00:20"}	2024-05-01 18:02:00.180871
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:02:31:231"}	2024-05-01 18:02:32.034365
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:04:13:413"}	2024-05-01 18:04:13.881321
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 18:51:15:5115"}	2024-05-01 18:51:15.427626
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:13:13:1313"}	2024-05-01 20:13:13.544587
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:33:58:3358"}	2024-05-01 20:33:59.023104
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:34:35:3435"}	2024-05-01 20:34:35.677396
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 20:55:40:5540"}	2024-05-01 20:55:40.717974
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:01:36:136"}	2024-05-01 21:01:36.941634
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:03:39:339"}	2024-05-01 21:03:39.241901
info	Server started on PORT 5000...	{"timestamp":"2024-05-01 21:08:41:841"}	2024-05-01 21:08:41.449927
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 11:45:12:4512"}	2024-05-02 11:45:13.007013
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 12:27:23:2723"}	2024-05-02 12:27:23.266075
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 14:34:16:3416"}	2024-05-02 14:34:16.928704
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 14:34:19:3419"}	2024-05-02 14:34:19.691711
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 17:38:04:384"}	2024-05-02 17:38:04.284101
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 17:38:11:3811"}	2024-05-02 17:38:11.453377
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 18:58:45:5845"}	2024-05-02 18:58:45.147458
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:00:39:039"}	2024-05-02 19:00:39.713421
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:28:08:288"}	2024-05-02 19:28:08.629253
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 19:44:41:4441"}	2024-05-02 19:44:41.14859
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:41:12:4112"}	2024-05-02 22:41:12.915197
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:45:07:457"}	2024-05-02 22:45:08.054941
info	Server started on PORT 5000...	{"timestamp":"2024-05-02 22:45:45:4545"}	2024-05-02 22:45:45.883111
info	Server started on PORT 5000...	{"timestamp":"2024-05-03 13:22:30:2230"}	2024-05-03 13:22:30.096785
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 11:38:56:3856"}	2024-05-04 11:38:56.130366
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:14:3714"}	2024-05-04 12:37:14.231948
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:31:3731"}	2024-05-04 12:37:31.721585
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:43:3743"}	2024-05-04 12:37:43.417484
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:49:3749"}	2024-05-04 12:37:49.979847
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:37:59:3759"}	2024-05-04 12:37:59.433836
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:02:382"}	2024-05-04 12:38:02.196244
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:08:388"}	2024-05-04 12:38:08.502013
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:12:3812"}	2024-05-04 12:38:12.106704
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:38:35:3835"}	2024-05-04 12:38:35.540596
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:46:3946"}	2024-05-04 12:39:46.918504
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:48:3948"}	2024-05-04 12:39:49.019325
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:39:57:3957"}	2024-05-04 12:39:57.149309
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:40:15:4015"}	2024-05-04 12:40:15.376532
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:40:18:4018"}	2024-05-04 12:40:18.800563
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:44:03:443"}	2024-05-04 12:44:04.03387
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:48:34:4834"}	2024-05-04 12:48:34.508785
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:48:51:4851"}	2024-05-04 12:48:51.752586
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:01:491"}	2024-05-04 12:49:01.46006
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:19:4919"}	2024-05-04 12:49:20.012848
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:22:4922"}	2024-05-04 12:49:22.491778
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 12:49:25:4925"}	2024-05-04 12:49:25.493352
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:51:19:5119"}	2024-05-04 13:51:19.54565
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:51:27:5127"}	2024-05-04 13:51:27.801827
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:08:528"}	2024-05-04 13:52:08.982726
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:19:5219"}	2024-05-04 13:52:19.275019
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:28:5228"}	2024-05-04 13:52:28.361942
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:39:5239"}	2024-05-04 13:52:39.610706
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:49:5249"}	2024-05-04 13:52:49.310802
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 13:52:56:5256"}	2024-05-04 13:52:57.014684
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 15:52:33:5233"}	2024-05-04 15:52:33.442863
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:13:08:138"}	2024-05-04 17:13:08.670141
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:02:272"}	2024-05-04 17:27:02.728155
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:08:278"}	2024-05-04 17:27:08.567326
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:19:2719"}	2024-05-04 17:27:19.750048
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:34:2734"}	2024-05-04 17:27:34.050522
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:41:2741"}	2024-05-04 17:27:41.238105
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:27:49:2749"}	2024-05-04 17:27:49.278085
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:29:36:2936"}	2024-05-04 17:29:36.299956
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:32:11:3211"}	2024-05-04 17:32:12.090251
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:33:37:3337"}	2024-05-04 17:33:37.401973
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:45:00:450"}	2024-05-04 17:45:00.723737
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:45:55:4555"}	2024-05-04 17:45:55.240335
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:08:478"}	2024-05-04 17:47:08.04529
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:30:4730"}	2024-05-04 17:47:30.586088
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:47:56:4756"}	2024-05-04 17:47:56.362858
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:48:04:484"}	2024-05-04 17:48:04.780343
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:50:27:5027"}	2024-05-04 17:50:27.062777
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 17:50:53:5053"}	2024-05-04 17:50:53.570502
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:30:29:3029"}	2024-05-04 18:30:29.50506
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:30:37:3037"}	2024-05-04 18:30:37.701803
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:31:26:3126"}	2024-05-04 18:31:26.498698
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:32:42:3242"}	2024-05-04 18:32:42.180573
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:00:360"}	2024-05-04 18:36:00.946842
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:04:364"}	2024-05-04 18:36:04.873845
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 18:36:35:3635"}	2024-05-04 18:36:35.192064
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:07:40:740"}	2024-05-04 19:07:40.838171
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:08:41:841"}	2024-05-04 19:08:41.531686
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:08:58:858"}	2024-05-04 19:08:59.00901
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:09:41:941"}	2024-05-04 19:09:41.557315
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:10:55:1055"}	2024-05-04 19:10:55.51814
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:14:00:140"}	2024-05-04 19:14:00.617878
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 19:26:03:263"}	2024-05-04 19:26:03.998272
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 22:02:00:20"}	2024-05-04 22:02:00.990187
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 22:09:26:926"}	2024-05-04 22:09:26.862413
info	Server started on PORT 5000...	{"timestamp":"2024-05-04 23:01:21:121"}	2024-05-04 23:01:21.726147
info	Server started on PORT 5000...	{"timestamp":"2024-05-06 16:57:00:570"}	2024-05-06 16:57:00.341526
info	Server started on PORT 5000...	{"timestamp":"2024-05-06 17:13:50:1350"}	2024-05-06 17:13:50.506522
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 11:47:00:470"}	2024-05-07 11:47:00.308653
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:04:30:430"}	2024-05-07 17:04:30.519197
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:06:16:616"}	2024-05-07 17:06:17.069749
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:09:00:90"}	2024-05-07 17:09:00.625567
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:09:43:943"}	2024-05-07 17:09:43.60594
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:10:25:1025"}	2024-05-07 17:10:25.881821
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:17:37:1737"}	2024-05-07 17:17:37.424115
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:19:14:1914"}	2024-05-07 17:19:14.407344
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:21:53:2153"}	2024-05-07 17:21:53.327817
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:23:35:2335"}	2024-05-07 17:23:35.185864
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:24:29:2429"}	2024-05-07 17:24:29.44267
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:24:34:2434"}	2024-05-07 17:24:35.011138
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:11:2511"}	2024-05-07 17:25:11.793727
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:21:2521"}	2024-05-07 17:25:21.298184
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:41:2541"}	2024-05-07 17:25:41.185384
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:47:2547"}	2024-05-07 17:25:47.813103
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:53:2553"}	2024-05-07 17:25:53.343873
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:25:59:2559"}	2024-05-07 17:25:59.675338
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:26:04:264"}	2024-05-07 17:26:04.269241
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:26:24:2624"}	2024-05-07 17:26:24.51772
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:26:56:2656"}	2024-05-07 17:26:56.767174
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:27:05:275"}	2024-05-07 17:27:05.760467
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:27:26:2726"}	2024-05-07 17:27:26.556487
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:27:34:2734"}	2024-05-07 17:27:34.498745
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:33:22:3322"}	2024-05-07 17:33:22.42492
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:33:33:3333"}	2024-05-07 17:33:33.268399
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:36:04:364"}	2024-05-07 17:36:04.150775
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:39:15:3915"}	2024-05-07 17:39:15.399603
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:39:45:3945"}	2024-05-07 17:39:45.89562
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:40:04:404"}	2024-05-07 17:40:04.741075
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:41:39:4139"}	2024-05-07 17:41:39.397433
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:42:30:4230"}	2024-05-07 17:42:30.0783
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:42:55:4255"}	2024-05-07 17:42:55.327877
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:43:14:4314"}	2024-05-07 17:43:14.722116
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:43:46:4346"}	2024-05-07 17:43:46.438949
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:44:04:444"}	2024-05-07 17:44:04.954054
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:44:18:4418"}	2024-05-07 17:44:19.160148
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 17:59:44:5944"}	2024-05-07 17:59:44.703428
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:00:01:01"}	2024-05-07 18:00:01.220923
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:00:32:032"}	2024-05-07 18:00:32.088048
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:00:49:049"}	2024-05-07 18:00:49.904321
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:01:21:121"}	2024-05-07 18:01:21.739565
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:04:53:453"}	2024-05-07 18:04:53.611646
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:05:03:53"}	2024-05-07 18:05:03.745917
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:05:10:510"}	2024-05-07 18:05:10.196481
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:05:18:518"}	2024-05-07 18:05:18.700924
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:06:06:66"}	2024-05-07 18:06:06.279373
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:06:38:638"}	2024-05-07 18:06:38.40824
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:08:44:844"}	2024-05-07 18:08:44.452376
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:08:51:851"}	2024-05-07 18:08:51.932
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:08:55:855"}	2024-05-07 18:08:55.204472
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:00:90"}	2024-05-07 18:09:00.395899
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:03:93"}	2024-05-07 18:09:03.289124
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:05:95"}	2024-05-07 18:09:05.343222
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:24:924"}	2024-05-07 18:09:25.030928
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:30:930"}	2024-05-07 18:09:31.031186
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:09:45:945"}	2024-05-07 18:09:45.858681
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:10:16:1016"}	2024-05-07 18:10:16.455412
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:10:39:1039"}	2024-05-07 18:10:39.362988
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:12:16:1216"}	2024-05-07 18:12:16.98675
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:14:17:1417"}	2024-05-07 18:14:17.837968
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:15:12:1512"}	2024-05-07 18:15:12.226354
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:18:06:186"}	2024-05-07 18:18:06.487474
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:18:56:1856"}	2024-05-07 18:18:56.820817
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:18:58:1858"}	2024-05-07 18:18:59.007527
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:21:54:2154"}	2024-05-07 18:21:54.856596
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:22:01:221"}	2024-05-07 18:22:01.57757
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:25:57:2557"}	2024-05-07 18:25:57.761166
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:27:42:2742"}	2024-05-07 18:27:42.912353
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:33:58:3358"}	2024-05-07 18:33:58.77746
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:34:02:342"}	2024-05-07 18:34:03.044162
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:34:18:3418"}	2024-05-07 18:34:18.678941
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:34:51:3451"}	2024-05-07 18:34:51.818842
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:39:47:3947"}	2024-05-07 18:39:47.4586
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:40:08:408"}	2024-05-07 18:40:08.454578
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:41:50:4150"}	2024-05-07 18:41:50.346617
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:41:52:4152"}	2024-05-07 18:41:53.090763
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:42:23:4223"}	2024-05-07 18:42:23.448229
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 18:42:39:4239"}	2024-05-07 18:42:40.020372
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:08:21:821"}	2024-05-07 19:08:21.500885
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:16:10:1610"}	2024-05-07 19:16:10.443448
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:17:40:1740"}	2024-05-07 19:17:40.833697
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:21:20:2120"}	2024-05-07 19:21:20.388655
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:24:36:2436"}	2024-05-07 19:24:36.326184
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:24:43:2443"}	2024-05-07 19:24:43.486871
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:27:28:2728"}	2024-05-07 19:27:28.377805
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:28:25:2825"}	2024-05-07 19:28:25.350842
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:30:52:3052"}	2024-05-07 19:30:52.417588
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:31:13:3113"}	2024-05-07 19:31:13.953781
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:33:52:3352"}	2024-05-07 19:33:52.684222
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:34:49:3449"}	2024-05-07 19:34:49.980218
info	Server started on PORT 5000...	{"timestamp":"2024-05-07 19:35:41:3541"}	2024-05-07 19:35:41.111644
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 10:33:49:3349"}	2024-05-08 10:33:49.844958
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:00:26:026"}	2024-05-08 22:00:26.875731
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:01:45:145"}	2024-05-08 22:01:45.606425
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:01:58:158"}	2024-05-08 22:01:58.55152
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:02:03:23"}	2024-05-08 22:02:04.027577
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:02:36:236"}	2024-05-08 22:02:36.310722
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:02:54:254"}	2024-05-08 22:02:54.866024
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:03:01:31"}	2024-05-08 22:03:01.552039
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:03:15:315"}	2024-05-08 22:03:15.138617
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:04:31:431"}	2024-05-08 22:04:31.890181
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:06:48:648"}	2024-05-08 22:06:48.6995
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:07:33:733"}	2024-05-08 22:07:33.302024
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:19:57:1957"}	2024-05-08 22:19:57.994297
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 22:22:21:2221"}	2024-05-08 22:22:21.914068
info	Server started on PORT 5000...	{"timestamp":"2024-05-08 23:22:30:2230"}	2024-05-08 23:22:30.392907
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 00:08:20:820"}	2024-05-09 00:08:20.764864
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 00:16:41:1641"}	2024-05-09 00:16:41.201968
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 00:32:16:3216"}	2024-05-09 00:32:16.704153
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 00:51:37:5137"}	2024-05-09 00:51:38.142676
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 11:06:21:621"}	2024-05-09 11:06:22.13738
info	Server started on PORT 5000...	{"timestamp":"2024-05-09 17:54:26:5426"}	2024-05-09 17:54:26.916743
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 12:50:30:5030"}	2024-05-10 12:50:30.429034
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 13:06:32:632"}	2024-05-10 13:06:32.324562
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 13:54:02:542"}	2024-05-10 13:54:02.325376
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 13:57:30:5730"}	2024-05-10 13:57:30.569922
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:00:57:057"}	2024-05-10 14:00:57.383385
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:07:58:758"}	2024-05-10 14:07:59.012638
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:08:45:845"}	2024-05-10 14:08:45.592897
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:16:45:1645"}	2024-05-10 14:16:45.144602
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:17:02:172"}	2024-05-10 14:17:02.759637
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:17:11:1711"}	2024-05-10 14:17:11.884186
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:19:21:1921"}	2024-05-10 14:19:22.004464
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:21:32:2132"}	2024-05-10 14:21:32.737958
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:22:50:2250"}	2024-05-10 14:22:50.113419
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:24:03:243"}	2024-05-10 14:24:03.580323
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:24:24:2424"}	2024-05-10 14:24:24.748632
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 14:34:47:3447"}	2024-05-10 14:34:47.133104
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 18:29:51:2951"}	2024-05-10 18:29:51.636701
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 18:42:40:4240"}	2024-05-10 18:42:40.643727
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:08:01:81"}	2024-05-10 23:08:01.555219
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:08:11:811"}	2024-05-10 23:08:11.510433
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:08:22:822"}	2024-05-10 23:08:22.645198
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:28:31:2831"}	2024-05-10 23:28:31.249308
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:29:07:297"}	2024-05-10 23:29:07.592323
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:29:51:2951"}	2024-05-10 23:29:52.030356
info	Server started on PORT 5000...	{"timestamp":"2024-05-10 23:30:54:3054"}	2024-05-10 23:30:54.591236
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:38:50:3850"}	2024-05-11 00:38:50.337526
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:39:45:3945"}	2024-05-11 00:39:45.610833
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:40:22:4022"}	2024-05-11 00:40:22.911292
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:41:50:4150"}	2024-05-11 00:41:50.146865
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:42:05:425"}	2024-05-11 00:42:05.89423
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:44:10:4410"}	2024-05-11 00:44:10.221416
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:45:30:4530"}	2024-05-11 00:45:30.387628
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:46:45:4645"}	2024-05-11 00:46:45.394687
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:47:04:474"}	2024-05-11 00:47:04.555667
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:48:58:4858"}	2024-05-11 00:48:58.639653
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:49:02:492"}	2024-05-11 00:49:02.830682
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:49:10:4910"}	2024-05-11 00:49:10.120338
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:49:17:4917"}	2024-05-11 00:49:17.495713
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:49:26:4926"}	2024-05-11 00:49:26.515698
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:49:32:4932"}	2024-05-11 00:49:32.881126
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:51:57:5157"}	2024-05-11 00:51:58.036628
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:54:03:543"}	2024-05-11 00:54:03.330161
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:56:52:5652"}	2024-05-11 00:56:52.28015
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 00:57:58:5758"}	2024-05-11 00:57:58.741306
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:03:29:329"}	2024-05-11 01:03:29.204432
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:04:31:431"}	2024-05-11 01:04:31.816041
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:04:54:454"}	2024-05-11 01:04:54.783241
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:14:02:142"}	2024-05-11 01:14:02.113204
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:34:42:3442"}	2024-05-11 01:34:42.631036
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:43:05:435"}	2024-05-11 01:43:05.176821
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:43:22:4322"}	2024-05-11 01:43:22.534179
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:43:24:4324"}	2024-05-11 01:43:25.071739
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:44:08:448"}	2024-05-11 01:44:08.956395
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:46:59:4659"}	2024-05-11 01:46:59.394012
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:47:32:4732"}	2024-05-11 01:47:32.272978
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:48:02:482"}	2024-05-11 01:48:02.863277
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:48:07:487"}	2024-05-11 01:48:08.063374
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 01:59:55:5955"}	2024-05-11 01:59:55.153639
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:40:16:4016"}	2024-05-11 10:40:16.713763
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:54:54:5454"}	2024-05-11 10:54:54.538337
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:55:12:5512"}	2024-05-11 10:55:12.662063
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:55:55:5555"}	2024-05-11 10:55:56.015341
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:56:32:5632"}	2024-05-11 10:56:32.801915
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:56:48:5648"}	2024-05-11 10:56:48.419025
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:59:02:592"}	2024-05-11 10:59:02.439433
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 10:59:48:5948"}	2024-05-11 10:59:48.065911
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 11:00:13:013"}	2024-05-11 11:00:13.945368
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 11:00:35:035"}	2024-05-11 11:00:35.870881
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 12:06:17:617"}	2024-05-11 12:06:17.717257
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 13:20:22:2022"}	2024-05-11 13:20:22.995978
info	Server started on PORT 5000...	{"timestamp":"2024-05-11 13:22:26:2226"}	2024-05-11 13:22:26.746799
\.


--
-- Name: attribute_groups_id_attribute_group_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attribute_groups_id_attribute_group_seq', 11, true);


--
-- Name: attributes_id_attribute_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attributes_id_attribute_seq', 21, true);


--
-- Name: cart_products_id_cart_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_products_id_cart_product_seq', 187, true);


--
-- Name: carts_id_cart_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_id_cart_seq', 6, true);


--
-- Name: categories_id_category_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_category_seq', 65, true);


--
-- Name: collections_id_collection_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collections_id_collection_seq', 8, true);


--
-- Name: image_comments_id_image_comment_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_comments_id_image_comment_seq', 1, true);


--
-- Name: order_addresses_id_order_address_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_addresses_id_order_address_seq', 124, true);


--
-- Name: order_deliveries_id_order_delivery_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_deliveries_id_order_delivery_seq', 5, true);


--
-- Name: order_history_id_order_history_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_history_id_order_history_seq', 1, false);


--
-- Name: order_products_id_order_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_products_id_order_product_seq', 69, true);


--
-- Name: order_statuses_id_order_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_statuses_id_order_status_seq', 4, true);


--
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_order_seq', 96, true);


--
-- Name: payment_methods_id_payment_method_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_methods_id_payment_method_seq', 2, true);


--
-- Name: product_comments_id_product_comment_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_comments_id_product_comment_seq', 40, true);


--
-- Name: product_images_id_product_image_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_images_id_product_image_seq', 11, true);


--
-- Name: products_id_product_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_product_seq', 152, true);


--
-- Name: specifications_id_specification_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specifications_id_specification_seq', 49, true);


--
-- Name: ConfirmationCodes ConfirmationCodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ConfirmationCodes"
    ADD CONSTRAINT "ConfirmationCodes_pkey" PRIMARY KEY (email_user);


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
-- Name: category_attribute_groups category_attribute_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_attribute_groups
    ADD CONSTRAINT category_attribute_groups_pkey PRIMARY KEY (id_attribute_group, id_category);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id_collection);


--
-- Name: confirmation_codes confirmation_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.confirmation_codes
    ADD CONSTRAINT confirmation_codes_pkey PRIMARY KEY (email_user);


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
-- Name: order_deliveries order_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_deliveries
    ADD CONSTRAINT order_deliveries_pkey PRIMARY KEY (id_order_delivery);


--
-- Name: order_history order_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_pkey PRIMARY KEY (id_order_history);


--
-- Name: order_products order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_products
    ADD CONSTRAINT order_products_pkey PRIMARY KEY (id_order_product);


--
-- Name: order_statuses order_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_statuses
    ADD CONSTRAINT order_statuses_pkey PRIMARY KEY (id_order_status);


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
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id_payment_method);


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
-- Name: category_attribute_groups category_attribute_groups_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_attribute_groups
    ADD CONSTRAINT category_attribute_groups_category_id_fkey FOREIGN KEY (id_category) REFERENCES public.categories(id_category) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: category_attribute_groups category_attribute_groups_id_attribute_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_attribute_groups
    ADD CONSTRAINT category_attribute_groups_id_attribute_group_fkey FOREIGN KEY (id_attribute_group) REFERENCES public.attribute_groups(id_attribute_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image_comments image_comments_id_product_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_comments
    ADD CONSTRAINT image_comments_id_product_comment_fkey FOREIGN KEY (id_product_comment) REFERENCES public.product_comments(id_product_comment) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_history order_history_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_fk1 FOREIGN KEY (id_order) REFERENCES public.orders(id_order) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_history order_history_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_fk2 FOREIGN KEY (id_order_address) REFERENCES public.order_addresses(id_order_address) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_history order_history_fk3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_fk3 FOREIGN KEY (id_payment_method) REFERENCES public.payment_methods(id_payment_method) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_history order_history_fk4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_history
    ADD CONSTRAINT order_history_fk4 FOREIGN KEY (id_order_product) REFERENCES public.order_products(id_order_product) ON UPDATE CASCADE ON DELETE SET NULL;


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

