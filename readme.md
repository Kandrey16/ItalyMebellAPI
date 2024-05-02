{
    "order": {
        "number_order": "20240001",
        "status_order": "новый",
        "price_order": 250.00,
        "date_order": "2024-04-22"
    },
        "address": {
        "address_order": "Улица Победы 10, Квартира 15",
        "entrance_order": 3,
        "floor_order": 5,
        "home_code_order": "123456",
        "email_user": "akurdelov@gmail.com"
    },
    "products": [
        {
            "id_cart_product": 145,
            "count_order_product": 2
        },
        {
            "id_cart_product": 146,
            "count_order_product": 1
        }
    ],
    "payment_method": {
    "id_payment_method": 1
    }
}

OrderHistory 


CREATE TABLE order_histories (
id SERIAL PRIMARY KEY,
order_data JSONB,
order_address_data JSONB,
order_product_data JSONB,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION record_history() RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER before_order_update
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION record_history();