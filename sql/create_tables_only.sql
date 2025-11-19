-- =====================================================
-- База данных "Обувной магазин"
-- Только создание таблиц и представлений
-- =====================================================

USE shoe_store;

-- Удаляем существующие таблицы для чистого разворачивания
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS pickup_points;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS order_statuses;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS manufacturers;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- Таблицы-справочники
-- =====================================================

-- 1. Таблица ролей пользователей
CREATE TABLE roles (
    id_role INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID роли',
    role_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Название роли'
) COMMENT 'Роли пользователей системы';

-- 2. Таблица категорий товаров
CREATE TABLE categories (
    id_category INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID категории',
    category_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Название категории'
) COMMENT 'Категории товаров';

-- 3. Таблица поставщиков
CREATE TABLE suppliers (
    id_supplier INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID поставщика',
    supplier_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Название поставщика'
) COMMENT 'Поставщики товаров';

-- 4. Таблица производителей
CREATE TABLE manufacturers (
    id_manufacturer INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID производителя',
    manufacturer_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Название производителя'
) COMMENT 'Производители товаров';

-- 5. Таблица статусов заказов
CREATE TABLE order_statuses (
    id_status INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID статуса',
    status_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Название статуса'
) COMMENT 'Статусы заказов';

-- 6. Таблица пунктов выдачи
CREATE TABLE pickup_points (
    id_pickup_point INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID пункта выдачи',
    postal_code VARCHAR(10) NOT NULL COMMENT 'Почтовый индекс',
    city VARCHAR(100) NOT NULL COMMENT 'Город',
    street VARCHAR(100) NOT NULL COMMENT 'Улица',
    house_number VARCHAR(20) NOT NULL COMMENT 'Номер дома',
    INDEX idx_city (city),
    INDEX idx_postal_code (postal_code)
) COMMENT 'Пункты выдачи заказов';

-- =====================================================
-- Основные таблицы
-- =====================================================

-- 7. Таблица пользователей
CREATE TABLE users (
    id_user INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID пользователя',
    last_name VARCHAR(100) NOT NULL COMMENT 'Фамилия',
    first_name VARCHAR(100) NOT NULL COMMENT 'Имя',
    middle_name VARCHAR(100) COMMENT 'Отчество',
    login VARCHAR(100) NOT NULL UNIQUE COMMENT 'Логин (email)',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Хэш пароля',
    id_role INT NOT NULL COMMENT 'ID роли',

    FOREIGN KEY (id_role) REFERENCES roles(id_role) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_login (login),
    INDEX idx_last_name (last_name),
    INDEX idx_first_name (first_name),
    INDEX idx_full_name (last_name, first_name, middle_name)
) COMMENT 'Пользователи системы';

-- 8. Таблица товаров
CREATE TABLE products (
    id_product INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID товара',
    article_number VARCHAR(20) NOT NULL UNIQUE COMMENT 'Артикул товара',
    product_name VARCHAR(255) NOT NULL COMMENT 'Наименование товара',
    price DECIMAL(10,2) NOT NULL COMMENT 'Цена товара',
    unit VARCHAR(10) NOT NULL DEFAULT 'шт.' COMMENT 'Единица измерения',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT 'Количество на складе',
    discount_percent DECIMAL(5,2) DEFAULT 0 COMMENT 'Действующая скидка в процентах',
    description TEXT COMMENT 'Описание товара',
    photo_url VARCHAR(255) COMMENT 'URL фотографии товара',

    id_category INT NOT NULL COMMENT 'ID категории товара',
    id_supplier INT NOT NULL COMMENT 'ID поставщика',
    id_manufacturer INT NOT NULL COMMENT 'ID производителя',

    FOREIGN KEY (id_category) REFERENCES categories(id_category) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_supplier) REFERENCES suppliers(id_supplier) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_manufacturer) REFERENCES manufacturers(id_manufacturer) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_article_number (article_number),
    INDEX idx_product_name (product_name),
    INDEX idx_price (price),
    INDEX idx_stock_quantity (stock_quantity),
    INDEX idx_category (id_category),
    INDEX idx_supplier (id_supplier),
    INDEX idx_manufacturer (id_manufacturer)
) COMMENT 'Товары (обувь)';

-- 9. Таблица заказов
CREATE TABLE orders (
    id_order INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID заказа',
    order_number INT NOT NULL UNIQUE COMMENT 'Номер заказа',
    order_date DATE NOT NULL COMMENT 'Дата заказа',
    delivery_date DATE COMMENT 'Дата доставки',
    pickup_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Код для получения заказа',

    id_user INT NOT NULL COMMENT 'ID пользователя-клиента',
    id_pickup_point INT NOT NULL COMMENT 'ID пункта выдачи',
    id_status INT NOT NULL DEFAULT 2 COMMENT 'ID статуса заказа',

    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_pickup_point) REFERENCES pickup_points(id_pickup_point) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_status) REFERENCES order_statuses(id_status) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_order_number (order_number),
    INDEX idx_order_date (order_date),
    INDEX idx_delivery_date (delivery_date),
    INDEX idx_user (id_user),
    INDEX idx_pickup_point (id_pickup_point),
    INDEX idx_status (id_status),
    INDEX idx_pickup_code (pickup_code)
) COMMENT 'Заказы клиентов';

-- 10. Таблица состава заказа (заказанные товары)
CREATE TABLE order_items (
    id_order_item INT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID позиции заказа',
    quantity INT NOT NULL CHECK (quantity > 0) COMMENT 'Количество товара',
    price_at_time DECIMAL(10,2) NOT NULL COMMENT 'Цена товара на момент заказа',

    id_order INT NOT NULL COMMENT 'ID заказа',
    id_product INT NOT NULL COMMENT 'ID товара',

    FOREIGN KEY (id_order) REFERENCES orders(id_order) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_product) REFERENCES products(id_product) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_order (id_order),
    INDEX idx_product (id_product),
    UNIQUE KEY uk_order_product (id_order, id_product)
) COMMENT 'Состав заказов (заказанные товары)';

-- =====================================================
-- Представления для удобной работы
-- =====================================================

-- Представление для информации о заказах с деталями
CREATE VIEW v_orders_details AS
SELECT
    o.id_order,
    o.order_number,
    o.order_date,
    o.delivery_date,
    o.pickup_code,
    CONCAT(u.last_name, ' ', u.first_name, IFNULL(CONCAT(' ', u.middle_name), '')) as customer_name,
    pp.city,
    pp.street,
    pp.house_number,
    os.status_name,
    COUNT(oi.id_order_item) as items_count,
    SUM(oi.quantity * oi.price_at_time) as total_amount
FROM orders o
LEFT JOIN users u ON o.id_user = u.id_user
LEFT JOIN pickup_points pp ON o.id_pickup_point = pp.id_pickup_point
LEFT JOIN order_statuses os ON o.id_status = os.id_status
LEFT JOIN order_items oi ON o.id_order = oi.id_order
GROUP BY o.id_order, o.order_number, o.order_date, o.delivery_date, o.pickup_code,
         CONCAT(u.last_name, ' ', u.first_name, IFNULL(CONCAT(' ', u.middle_name), '')),
         pp.city, pp.street, pp.house_number, os.status_name;

-- Представление для информации о товарах
CREATE VIEW v_products_info AS
SELECT
    p.id_product,
    p.article_number,
    p.product_name,
    p.price,
    p.stock_quantity,
    p.discount_percent,
    p.photo_url,
    c.category_name,
    s.supplier_name,
    m.manufacturer_name,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Нет в наличии'
        WHEN p.stock_quantity <= 5 THEN 'Мало в наличии'
        ELSE 'В наличии'
    END as availability_status
FROM products p
LEFT JOIN categories c ON p.id_category = c.id_category
LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer;

-- Представление для пользователей с ролями
CREATE VIEW v_users_with_roles AS
SELECT
    u.id_user,
    CONCAT(u.last_name, ' ', u.first_name, IFNULL(CONCAT(' ', u.middle_name), '')) as full_name,
    u.last_name,
    u.first_name,
    u.middle_name,
    u.login,
    r.role_name
FROM users u
LEFT JOIN roles r ON u.id_role = r.id_role;

SELECT 'Tables and views created successfully!' as status;