-- =====================================================
-- Вставка тестовых данных для приложения
-- =====================================================

USE shoe_store;

-- Вставка ролей
INSERT INTO roles (id_role, role_name) VALUES
(1, 'Администратор'),
(2, 'Менеджер'),
(3, 'Авторизированный клиент');

-- Вставка категорий
INSERT INTO categories (id_category, category_name) VALUES
(1, 'Женская обувь'),
(2, 'Мужская обувь');

-- Вставка поставщиков
INSERT INTO suppliers (id_supplier, supplier_name) VALUES
(1, 'Kari'),
(2, 'Обувь для вас');

-- Вставка производителей
INSERT INTO manufacturers (id_manufacturer, manufacturer_name) VALUES
(1, 'Kari'),
(2, 'Marco Tozzi'),
(3, 'Рос'),
(4, 'Rieker'),
(5, 'Alessio Nesca'),
(6, 'CROSBY');

-- Вставка пользователей
INSERT INTO users (id_user, last_name, first_name, middle_name, login, password_hash, id_role) VALUES
(1, 'Никифорова', 'Весения', 'Николаевна', '94d5ous@gmail.com', 'uzWC67', 1),
(2, 'Сазонов', 'Руслан', 'Германович', 'uth4iz@mail.com', '2L6KZG', 1),
(3, 'Одинцов', 'Серафим', 'Артёмович', 'yzls62@outlook.com', 'JlFRCZ', 1),
(4, 'Степанов', 'Михаил', 'Артёмович', '1diph5e@tutanota.com', '8ntwUp', 2),
(5, 'Кузнецов', 'Александр', 'Дмитриевич', 'w2cbgp@outlook.com', 'l6lWDW', 2),
(6, 'Морозова', 'Анна', 'Сергеевна', 'c5qsrf@gmail.com', 'dO88bR', 3),
(7, 'Васильев', 'Игорь', 'Павлович', '8n9t7z@inbox.ru', 'wYtBq0', 3),
(8, 'Петрова', 'Елена', 'Александровна', 'k3p0hz@mail.com', 'vcnXZQ', 3),
(9, 'Соколов', 'Дмитрий', 'Ильич', '7k8i2t@yandex.ru', 'oOcS55', 3),
(10, 'Новикова', 'Ольга', 'Викторовна', 'p4x1ej@rambler.ru', 'uKkL3n', 3);

-- Вставка статусов заказов
INSERT INTO order_statuses (id_status, status_name) VALUES
(1, 'Новый'),
(2, 'Завершен');

-- Вставка товаров (упрощенно - несколько примеров)
INSERT INTO products (id_product, article_number, product_name, price, unit, stock_quantity,
                     discount_percent, description, photo_url, id_category, id_supplier, id_manufacturer) VALUES
(1, 'А112Т4', 'Ботинки женские демисезонные', 4990.00, 'шт.', 6, 3.00, 'Женские Ботинки демисезонные kari', '1.jpg', 1, 1, 1),
(2, 'F635R4', 'Ботинки Marco Tozzi женские', 3244.00, 'шт.', 13, 2.00, 'Ботинки Marco Tozzi женские демисезонные, размер 39, цвет бежевый', '2.jpg', 1, 2, 2),
(3, 'H782T5', 'Туфли женские на каблуке', 8900.00, 'шт.', 4, 0.00, 'Элегантные туфли на высоком каблуке', '3.jpg', 1, 1, 2),
(4, 'J384T6', 'Кроссовки мужские спортивные', 3500.00, 'шт.', 10, 10.00, 'Удобные кроссовки для занятий спортом', '4.jpg', 2, 1, 4),
(5, 'G783F5', 'Ботинки мужские зимние', 7500.00, 'шт.', 2, 5.00, 'Теплые зимние ботинки с натуральным мехом', '5.jpg', 2, 2, 3);

-- Вставка пунктов выдачи (несколько примеров)
INSERT INTO pickup_points (id_pickup_point, postal_code, city, street, house_number) VALUES
(1, '125061', 'Москва', 'Подгорная', '8'),
(2, '630370', 'Новосибирск', 'Шоссейная', '24'),
(3, '400562', 'Волгоград', 'Зеленая', '32');

-- Вставка нескольких заказов для тестирования
INSERT INTO orders (id_order, order_number, order_date, delivery_date, pickup_code, id_user, id_pickup_point, id_status) VALUES
(1, 1, '2024-01-15', '2024-01-18', '901', 6, 1, 2),
(2, 2, '2024-01-16', '2024-01-19', '902', 7, 2, 2),
(3, 3, '2024-01-17', '2024-01-20', '903', 8, 1, 1);

-- Вставка состава заказов
INSERT INTO order_items (id_order_item, quantity, price_at_time, id_order, id_product) VALUES
(1, 2, 4990.00, 1, 1),
(2, 1, 3244.00, 1, 2),
(3, 1, 8900.00, 2, 3),
(4, 2, 3500.00, 3, 4);

SELECT 'Test data inserted successfully!' as status;