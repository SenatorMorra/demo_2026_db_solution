# 📊 Отчет: SQL запросы и функционал модулей 2 и 3

## 📋 Содержание:
1. [Обзор SQL запросов](#обзор-sql-запросов)
2. [Модуль 2: Просмотр каталога товаров](#модуль-2-просмотр-каталога-товаров)
3. [Модуль 3: Поиск, фильтрация и CRUD товаров](#модуль-3-поиск-фильтрация-и-crud-товаров)

---

## 🗃️ Обзор SQL запросов

### 🏗️ Структура базы данных

```sql
-- Создание базы данных
CREATE DATABASE shoe_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 👥 Таблицы пользователей и ролей

```sql
-- Таблица ролей
CREATE TABLE roles (
    id_role INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Таблица пользователей
CREATE TABLE users (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    login VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    id_role INT,
    FOREIGN KEY (id_role) REFERENCES roles(id_role)
);

-- Вставка ролей
INSERT INTO roles (role_name) VALUES
('Администратор'),
('Менеджер'),
('Гость');

-- Вставка пользователей
INSERT INTO users (login, password_hash, first_name, last_name, id_role) VALUES
('admin', 'hashed_password', 'Администратор', 'Системы', 1),
('manager', 'hashed_password', 'Менеджер', 'Продаж', 2);
```

### 📦 Таблица товаров

```sql
-- Таблица категорий
CREATE TABLE categories (
    id_category INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица производителей
CREATE TABLE manufacturers (
    id_manufacturer INT PRIMARY KEY AUTO_INCREMENT,
    manufacturer_name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица поставщиков
CREATE TABLE suppliers (
    id_supplier INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица товаров
CREATE TABLE products (
    id_product INT PRIMARY KEY AUTO_INCREMENT,
    article_number VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    unit VARCHAR(20) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    availability_status VARCHAR(50) NOT NULL,
    photo_url VARCHAR(255),
    id_category INT,
    id_manufacturer INT,
    id_supplier INT,
    FOREIGN KEY (id_category) REFERENCES categories(id_category),
    FOREIGN KEY (id_manufacturer) REFERENCES manufacturers(id_manufacturer),
    FOREIGN KEY (id_supplier) REFERENCES suppliers(id_supplier)
);

-- Вставка тестовых данных
INSERT INTO categories (category_name) VALUES
('Ботинки'), ('Кроссовки'), ('Туфли'), ('Сандалии');

INSERT INTO manufacturers (manufacturer_name) VALUES
('Nike'), ('Adidas'), ('Marco Tozzi'), ('Reebok');

INSERT INTO suppliers (supplier_name) VALUES
('Поставщик А'), ('Поставщик Б'), ('Поставщик В');
```

---

## 🖥️ Модуль 2: Просмотр каталога товаров

### 🎯 Функционал Модуля 2:
- ✅ Аутентификация пользователей
- ✅ Просмотр каталога товаров
- ✅ Отображение информации о товарах с фотографиями
- ✅ Ролевой доступ (разные права для гостя/менеджера/администратора)

### 🔐 1. Аутентификация пользователей

#### **Основной запрос:**
```sql
SELECT u.id_user, u.login, u.first_name, u.last_name, r.role_name
FROM users u
JOIN roles r ON u.id_role = r.id_role
WHERE u.login = ? AND u.password_hash = ?;
```

#### **Объяснение:**
- **Цель:** Проверка учетных данных пользователя
- **Тип запроса:** `SELECT JOIN` (выборка с объединением)
- **Параметры:** `?` (логин и хэш пароля)
- **Возвращает:** Полные данные пользователя с ролью

#### **Синтаксис команды:**
```sql
-- Базовый синтаксис
SELECT столбцы
FROM таблица1
JOIN таблица2 ON условие_связи
WHERE условие_фильтрации;

-- Пример использования
SELECT u.id_user, u.first_name, r.role_name
FROM users u
JOIN roles r ON u.id_role = r.id_role
WHERE u.login = 'admin';
```

---

### 📋 2. Получение каталога товаров

#### **Основной запрос:**
```sql
SELECT
    p.id_product,
    p.article_number,
    p.product_name,
    p.description,
    p.price,
    p.discount_percent,
    p.unit,
    p.stock_quantity,
    p.availability_status,
    p.photo_url,
    c.category_name,
    m.manufacturer_name,
    s.supplier_name
FROM products p
LEFT JOIN categories c ON p.id_category = c.id_category
LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
ORDER BY p.product_name;
```

#### **Объяснение:**
- **Цель:** Получение полного списка товаров с категориями, производителями, поставщиками
- **Тип запроса:** `SELECT LEFT JOIN` (внешнее объединение)
- **LEFT JOIN:** Возвращает товары даже если у них нет категории/производителя
- **ORDER BY:** Сортировка по названию товара

#### **Типовой запрос (пример):**
```sql
-- Получение товаров конкретной категории
SELECT
    p.product_name,
    p.price,
    c.category_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
WHERE c.category_name = 'Ботинки'
AND p.stock_quantity > 0
ORDER BY p.price ASC;

-- Получение товаров со скидкой
SELECT
    p.product_name,
    p.price,
    p.discount_percent,
    (p.price * (1 - p.discount_percent / 100)) AS discounted_price
FROM products p
WHERE p.discount_percent > 0;
```

---

### 🏷️ 3. Получение списка категорий для навигации

```sql
-- Все категории с количеством товаров
SELECT
    c.id_category,
    c.category_name,
    COUNT(p.id_product) as products_count
FROM categories c
LEFT JOIN products p ON c.id_category = p.id_category
GROUP BY c.id_category
ORDER BY c.category_name;
```

#### **Объяснение:**
- **Цель:** Построение меню категорий с количеством товаров
- **GROUP BY:** Группировка по категориям для подсчета
- **COUNT():** Подсчет количества товаров в каждой категории

---

## 🔍 Модуль 3: Поиск, фильтрация и CRUD товаров

### 🎯 Функционал Модуля 3:
- ✅ Поиск товаров по названию, артикулу, описанию
- ✅ Фильтрация по категориям, производителям, поставщикам
- ✅ Сортировка по цене, названию, количеству
- ✅ CRUD операции для товаров (только для администратора)
- ✅ Дополнительные права для менеджера и администратора

### 🔎 1. Поиск товаров

#### **Поиск по нескольким полям:**
```sql
SELECT
    p.id_product,
    p.article_number,
    p.product_name,
    p.description,
    p.price,
    p.discount_percent,
    p.stock_quantity,
    c.category_name,
    m.manufacturer_name,
    s.supplier_name
FROM products p
LEFT JOIN categories c ON p.id_category = c.id_category
LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
WHERE
    p.product_name LIKE ?
    OR p.article_number LIKE ?
    OR p.description LIKE ?
    OR c.category_name LIKE ?
    OR m.manufacturer_name LIKE ?
ORDER BY p.product_name;
```

#### **Объяснение:**
- **Цель:** Поиск товаров по разным параметрам
- **LIKE '%%?':** Поиск подстроки в текстовых полях
- **OR:** Условие ИЛИ - подходит любое из полей
- **Параметры:** Поисковый запрос для каждого поля

#### **Синтаксис оператора LIKE:**
```sql
-- Базовый синтаксис
SELECT * FROM products WHERE product_name LIKE '%поиск%';

-- Примеры операторов:
-- LIKE 'текст%'     - начинается с 'текст'
-- LIKE '%текст'     - заканчивается на 'текст'
-- LIKE '%текст%'    - содержит 'текст'
-- LIKE 'текст'      - равно 'текст'

-- Пример использования
SELECT product_name FROM products
WHERE product_name LIKE '%ботинки%'
   OR description LIKE '%зимние%';
```

---

### 🔧 2. Фильтрация товаров

#### **Фильтрация по категории:**
```sql
SELECT
    p.id_product,
    p.product_name,
    p.price,
    p.stock_quantity,
    m.manufacturer_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
WHERE c.category_name = ?
AND p.stock_quantity > 0
ORDER BY p.product_name;
```

#### **Множественная фильтрация:**
```sql
SELECT
    p.id_product,
    p.article_number,
    p.product_name,
    p.price,
    p.stock_quantity,
    p.availability_status,
    c.category_name,
    m.manufacturer_name,
    s.supplier_name
FROM products p
LEFT JOIN categories c ON p.id_category = c.id_category
LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
LEFT JOIN suppliers s ON p.id_supplier = p.id_supplier
WHERE
    (? IS NULL OR c.category_name = ?)
    AND (? IS NULL OR m.manufacturer_name = ?)
    AND (? IS NULL OR s.supplier_name = ?)
    AND (? IS NULL OR p.availability_status = ?)
    AND p.stock_quantity >= ?
ORDER BY
    CASE
        WHEN ? = 'price_asc' THEN p.price
        WHEN ? = 'name_asc' THEN p.product_name
        WHEN ? = 'stock_asc' THEN p.stock_quantity
    END ASC,
    CASE
        WHEN ? = 'price_desc' THEN p.price
        WHEN ? = 'name_desc' THEN p.product_name
        WHEN ? = 'stock_desc' THEN p.stock_quantity
    END DESC;
```

#### **Объяснение:**
- **? IS NULL OR:** Условие работает только если параметр не NULL
- **Гибкая фильтрация:** Можно фильтровать по любым комбинациям параметров
- **CASE WHEN:** Динамическая сортировка в зависимости от параметра

---

### 📊 3. Сортировка товаров

#### **Различные варианты сортировки:**
```sql
-- Сортировка по цене (возрастание)
SELECT * FROM products ORDER BY price ASC;

-- Сортировка по цене (убывание)
SELECT * FROM products ORDER BY price DESC;

-- Сортировка по названию (алфавит)
SELECT * FROM products ORDER BY product_name ASC;

-- Сортировка по количеству на складе
SELECT * FROM products ORDER BY stock_quantity DESC;

-- Комплексная сортировка
SELECT
    p.product_name,
    p.price,
    p.stock_quantity,
    c.category_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
ORDER BY c.category_name ASC, p.price DESC;
```

#### **Синтаксис ORDER BY:**
```sql
-- Базовый синтаксис
SELECT * FROM таблица ORDER BY колонка [ASC|DESC];

-- Множественная сортировка
SELECT * FROM products
ORDER BY category_name ASC, price DESC, product_name ASC;

-- Сортировка с выражениями
SELECT
    product_name,
    price,
    (price * (1 - discount_percent / 100)) as final_price
FROM products
ORDER BY final_price ASC;
```

---

### 📝 4. CRUD операции для товаров (только администратор)

#### **CREATE - Создание нового товара:**
```sql
INSERT INTO products (
    article_number,
    product_name,
    description,
    price,
    discount_percent,
    unit,
    stock_quantity,
    availability_status,
    photo_url,
    id_category,
    id_manufacturer,
    id_supplier
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
```

#### **Объяснение INSERT:**
- **Цель:** Добавление нового товара в базу данных
- **Параметры:** Все поля товара
- **Возвращает:** ID созданной записи (LAST_INSERT_ID())

#### **Пример использования:**
```sql
-- Добавление товара с известными ID
INSERT INTO products (
    article_number, product_name, description, price,
    unit, stock_quantity, availability_status,
    id_category, id_manufacturer, id_supplier
) VALUES (
    'BT001', 'Зимние ботинки', 'Теплые ботинки для зимы', 3500.00,
    'пара', 50, 'В наличии', 1, 2, 1
);
```

---

#### **READ - Чтение данных товара:**
```sql
SELECT
    p.*,
    c.category_name,
    m.manufacturer_name,
    s.supplier_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
JOIN suppliers s ON p.id_supplier = s.id_supplier
WHERE p.id_product = ?;
```

---

#### **UPDATE - Обновление товара:**
```sql
UPDATE products
SET
    article_number = ?,
    product_name = ?,
    description = ?,
    price = ?,
    discount_percent = ?,
    unit = ?,
    stock_quantity = ?,
    availability_status = ?,
    photo_url = ?,
    id_category = ?,
    id_manufacturer = ?,
    id_supplier = ?
WHERE id_product = ?;
```

#### **Объяснение UPDATE:**
- **Цель:** Изменение существующего товара
- **WHERE id_product = ?:** Важно для обновления только нужной записи
- **Все поля:** Можно обновлять как все поля, так и только некоторые

#### **Пример частичного обновления:**
```sql
-- Обновление только цены и количества
UPDATE products
SET price = 3999.99,
    stock_quantity = stock_quantity - 1
WHERE id_product = 15;

-- Обновление с условием
UPDATE products
SET availability_status = 'Нет в наличии'
WHERE stock_quantity = 0;
```

---

#### **DELETE - Удаление товара:**
```sql
DELETE FROM products WHERE id_product = ?;
```

#### **Безопасное удаление с проверкой:**
```sql
-- Проверка на использование в других таблицах (если есть связи)
SELECT COUNT(*) as usage_count
FROM order_items
WHERE id_product = ?;

-- Удаление только если не используется
DELETE FROM products
WHERE id_product = ?
AND NOT EXISTS (
    SELECT 1 FROM order_items WHERE id_product = ?
);
```

---

### 🏷️ 5. CRUD для справочников (категории, производители, поставщики)

#### **Категории:**
```sql
-- Создать категорию
INSERT INTO categories (category_name) VALUES (?);

-- Получить все категории
SELECT * FROM categories ORDER BY category_name;

-- Обновить категорию
UPDATE categories SET category_name = ? WHERE id_category = ?;

-- Удалить категорию (если нет товаров)
DELETE FROM categories
WHERE id_category = ?
AND NOT EXISTS (SELECT 1 FROM products WHERE id_category = ?);
```

#### **Производители:**
```sql
-- Создать производителя
INSERT INTO manufacturers (manufacturer_name) VALUES (?);

-- Получить всех производителей
SELECT * FROM manufacturers ORDER BY manufacturer_name;

-- Обновить производителя
UPDATE manufacturers SET manufacturer_name = ? WHERE id_manufacturer = ?;

-- Удалить производителя
DELETE FROM manufacturers
WHERE id_manufacturer = ?
AND NOT EXISTS (SELECT 1 FROM products WHERE id_manufacturer = ?);
```

#### **Поставщики:**
```sql
-- Создать поставщика
INSERT INTO suppliers (supplier_name) VALUES (?);

-- Получить всех поставщиков
SELECT * FROM suppliers ORDER BY supplier_name;

-- Обновить поставщика
UPDATE suppliers SET supplier_name = ? WHERE id_supplier = ?;

-- Удалить поставщика
DELETE FROM suppliers
WHERE id_supplier = ?
AND NOT EXISTS (SELECT 1 FROM products WHERE id_supplier = ?);
```

---

### 📊 6. Отчеты и статистика для Модуля 3

#### **Статистика по категориям:**
```sql
SELECT
    c.category_name,
    COUNT(p.id_product) as products_count,
    SUM(p.stock_quantity) as total_stock,
    AVG(p.price) as avg_price,
    MIN(p.price) as min_price,
    MAX(p.price) as max_price
FROM categories c
LEFT JOIN products p ON c.id_category = p.id_category
GROUP BY c.id_category
ORDER BY products_count DESC;
```

#### **Статистика по производителям:**
```sql
SELECT
    m.manufacturer_name,
    COUNT(p.id_product) as products_count,
    SUM(p.stock_quantity) as total_stock,
    AVG(p.price) as avg_price
FROM manufacturers m
LEFT JOIN products p ON m.id_manufacturer = p.id_manufacturer
GROUP BY m.id_manufacturer
ORDER BY products_count DESC;
```

#### **Товары с низкой скидкой (для администратора):**
```sql
SELECT
    p.product_name,
    p.price,
    p.discount_percent,
    (p.price * (1 - p.discount_percent / 100)) as discounted_price,
    c.category_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
WHERE p.discount_percent > 0
ORDER BY discounted_price ASC;
```

---

## 🛡️ Безопасность SQL запросов

### 📝 Рекомендации по безопасности:

1. **Использование параметризированных запросов:**
```sql
-- ПЛОХО (SQL инъекция)
"SELECT * FROM users WHERE login = '" + userInput + "'"

-- ХОРОШО (безопасно)
"SELECT * FROM users WHERE login = ?"
```

2. **Валидация входных данных:**
```sql
-- Проверка формата email
WHERE customer_email LIKE '%_@__%.__%'

-- Проверка положительных чисел
WHERE quantity > 0 AND price > 0

-- Проверка обязательных полей
WHERE product_name IS NOT NULL AND product_name != ''
```

3. **Ограничение количества записей:**
```sql
-- Ограничение выборки для производительности
SELECT * FROM products LIMIT 100;

-- Пагинация
SELECT * FROM products LIMIT 20 OFFSET 0;  -- Страница 1
SELECT * FROM products LIMIT 20 OFFSET 20; -- Страница 2
```

4. **Использование транзакций для CRUD операций:**
```sql
-- Начало транзакции
START TRANSACTION;

-- Несколько операций
INSERT INTO products (...) VALUES (...);
INSERT INTO products (...) VALUES (...);

-- Если все успешно - фиксация
COMMIT;

-- Если ошибка - откат
ROLLBACK;
```

---

## 🎯 Ролевой доступ в Модулях

### **Права доступа по ролям:**

#### **Гость:**
- ✅ Просмотр каталога товаров (Модуль 2)

#### **Менеджер:**
- ✅ Все функции гостя
- ✅ Поиск, фильтрация, сортировка товаров (Модуль 3)
- ❌ CRUD операции (только просмотр)

#### **Администратор:**
- ✅ Все функции менеджера
- ✅ Полные CRUD операции с товарами (Модуль 3)
- ✅ Управление справочниками (категории, производители, поставщики)

### **SQL для проверки прав:**
```sql
-- Проверка прав пользователя
SELECT
    u.login,
    u.first_name,
    r.role_name,
    CASE r.role_name
        WHEN 'Администратор' THEN 'full_access'
        WHEN 'Менеджер' THEN 'read_write_access'
        ELSE 'read_only_access'
    END as access_level
FROM users u
JOIN roles r ON u.id_role = r.id_role
WHERE u.id_user = ?;
```

---

## 📝 Заключение

### **Модуль 2** реализует:
- ✅ Аутентификацию и базовый просмотр каталога
- ✅ Отображение товаров с фотографиями
- ✅ Простую навигацию по категориям

### **Модуль 3** добавляет:
- ✅ Продвинутый поиск и фильтрацию
- ✅ Различные варианты сортировки
- ✅ CRUD операции для администраторов
- ✅ Управление справочниками
- ✅ Статистическую отчетность

### **Ключевые особенности SQL запросов:**
- **Безопасность:** Параметризированные запросы
- **Производительность:** Оптимизированные JOIN и индексы
- **Гибкость:** Динамическая фильтрация и сортировка
- **Масштабируемость:** Нормализованная структура данных
- **Ролевая модель:** Различные уровни доступа

---

*📅 Дата создания: 20.11.2024*
*👤 Автор: Claude Code Assistant*
