> документ сгенерирован нейросетью и несёт в себе докуменатцию сверх-требований Модулей 2 и 3

# SQL Запросы для Модулей 2 и 3

## Модуль 2: Управление пользователями и аутентификация

### 2.1 Регистрация нового пользователя
```sql
INSERT INTO Users (username, email, password_hash, first_name, last_name, role_id, created_at)
VALUES (@username, @email, @password_hash, @first_name, @last_name, @role_id, GETDATE());
```
**Функция:** Создание новой учетной записи пользователя в системе

### 2.2 Аутентификация пользователя
```sql
SELECT u.user_id, u.username, u.email, u.password_hash, r.role_name
FROM Users u
JOIN Roles r ON u.role_id = r.role_id
WHERE u.username = @username OR u.email = @email;
```
**Функция:** Проверка учетных данных пользователя при входе в систему

### 2.3 Получение информации о пользователе
```sql
SELECT user_id, username, email, first_name, last_name,
       role_id, created_at, last_login, is_active
FROM Users
WHERE user_id = @user_id;
```
**Функция:** Получение полной информации о профиле пользователя

### 2.4 Обновление данных пользователя
```sql
UPDATE Users
SET first_name = @first_name,
    last_name = @last_name,
    email = @email,
    updated_at = GETDATE()
WHERE user_id = @user_id;
```
**Функция:** Обновление личных данных пользователя

### 2.5 Изменение пароля пользователя
```sql
UPDATE Users
SET password_hash = @new_password_hash,
    updated_at = GETDATE(),
    password_changed_at = GETDATE()
WHERE user_id = @user_id;
```
**Функция:** Смена пароля пользователя

### 2.6 Проверка существования пользователя
```sql
SELECT COUNT(*) as user_exists
FROM Users
WHERE username = @username OR email = @email;
```
**Функция:** Проверка доступности логина или email при регистрации

### 2.7 Получение списка всех пользователей (для администратора)
```sql
SELECT u.user_id, u.username, u.email, u.first_name, u.last_name,
       r.role_name, u.created_at, u.last_login, u.is_active
FROM Users u
JOIN Roles r ON u.role_id = r.role_id
ORDER BY u.created_at DESC;
```
**Функция:** Получение списка всех пользователей системы

### 2.8 Блокировка/разблокировка пользователя
```sql
UPDATE Users
SET is_active = @is_active,
    updated_at = GETDATE()
WHERE user_id = @user_id;
```
**Функция:** Изменение статуса активности пользователя

---

## Модуль 3: Управление ролями и правами доступа

### 3.1 Получение всех ролей системы
```sql
SELECT role_id, role_name, description, created_at
FROM Roles
WHERE is_active = 1
ORDER BY role_name;
```
**Функция:** Получение списка всех доступных ролей в системе

### 3.2 Создание новой роли
```sql
INSERT INTO Roles (role_name, description, created_at, is_active)
VALUES (@role_name, @description, GETDATE(), 1);
```
**Функция:** Создание новой пользовательской роли

### 3.3 Получение прав доступа для роли
```sql
SELECT p.permission_id, p.permission_name, p.description, p.module_name
FROM Role_Permissions rp
JOIN Permissions p ON rp.permission_id = p.permission_id
WHERE rp.role_id = @role_id;
```
**Функция:** Получение всех разрешений для конкретной роли

### 3.4 Назначение прав доступа роли
```sql
INSERT INTO Role_Permissions (role_id, permission_id, granted_at, granted_by)
VALUES (@role_id, @permission_id, GETDATE(), @admin_user_id);
```
**Функция:** Предоставление права доступа конкретной роли

### 3.5 Удаление права доступа у роли
```sql
DELETE FROM Role_Permissions
WHERE role_id = @role_id AND permission_id = @permission_id;
```
**Функция:** Отзыв права доступа у роли

### 3.6 Проверка прав доступа пользователя
```sql
SELECT COUNT(*) as has_permission
FROM Users u
JOIN Role_Permissions rp ON u.role_id = rp.role_id
JOIN Permissions p ON rp.permission_id = p.permission_id
WHERE u.user_id = @user_id
  AND p.permission_name = @permission_name
  AND p.module_name = @module_name;
```
**Функция:** Проверка是否有 у пользователя указанное право доступа

### 3.7 Получение всех доступных прав
```sql
SELECT permission_id, permission_name, description, module_name, created_at
FROM Permissions
WHERE is_active = 1
ORDER BY module_name, permission_name;
```
**Функция:** Получение полного списка всех прав доступа в системе

### 3.8 Создание нового права доступа
```sql
INSERT INTO Permissions (permission_name, description, module_name, created_at, is_active)
VALUES (@permission_name, @description, @module_name, GETDATE(), 1);
```
**Функция:** Создание нового права доступа

### 3.9 Получение пользователей с определенной ролью
```sql
SELECT u.user_id, u.username, u.email, u.first_name, u.last_name
FROM Users u
WHERE u.role_id = @role_id AND u.is_active = 1
ORDER BY u.username;
```
**Функция:** Получение списка пользователей с указанной ролью

### 3.10 Изменение роли пользователя
```sql
UPDATE Users
SET role_id = @new_role_id,
    updated_at = GETDATE()
WHERE user_id = @user_id;
```
**Функция:** Изменение роли пользователя

### 3.11 Получение истории изменений ролей
```sql
SELECT rh.history_id, rh.user_id, u.username,
       rh.old_role_id, old_role.role_name as old_role_name,
       rh.new_role_id, new_role.role_name as new_role_name,
       rh.changed_at, rh.changed_by
FROM Role_History rh
JOIN Users u ON rh.user_id = u.user_id
JOIN Roles old_role ON rh.old_role_id = old_role.role_id
JOIN Roles new_role ON rh.new_role_id = new_role.role_id
WHERE rh.user_id = @user_id
ORDER BY rh.changed_at DESC;
```
**Функция:** Получение истории изменений ролей пользователя

---

## Мини-справочник по синтаксису SQL

### Основные операторы SQL:

**SELECT** - извлечение данных из таблиц
```sql
SELECT column1, column2 FROM table_name WHERE condition;
```
*Что делает:* Выбирает указанные столбцы из таблицы с применением условий
*Что получаем:* Набор данных (результирующий набор строк)

**INSERT** - добавление новых записей в таблицу
```sql
INSERT INTO table_name (column1, column2) VALUES (value1, value2);
```
*Что делает:* Добавляет новую строку в указанную таблицу
*Что получаем:* Количество добавленных строк

**UPDATE** - обновление существующих записей
```sql
UPDATE table_name SET column1 = value1 WHERE condition;
```
*Что делает:* Изменяет значения в указанных столбцах для строк, удовлетворяющих условию
*Что получаем:* Количество обновленных строк

**DELETE** - удаление записей из таблицы
```sql
DELETE FROM table_name WHERE condition;
```
*Что делает:* Удаляет строки, удовлетворяющие указанному условию
*Что получаем:* Количество удаленных строк

### Дополнительные операторы:

**JOIN** - объединение таблиц
```sql
SELECT * FROM table1 INNER JOIN table2 ON table1.id = table2.id;
```
*Что делает:* Объединяет строки из двух таблиц на основе связанного столбца
*Что получаем:* Комбинированный набор данных из обеих таблиц

**INNER JOIN** - возвращает только совпадающие строки
**LEFT JOIN** - возвращает все строки из левой таблицы и совпадающие из правой
**RIGHT JOIN** - возвращает все строки из правой таблицы и совпадающие из левой
**FULL OUTER JOIN** - возвращает все строки из обеих таблиц

**WHERE** - фильтрация данных
```sql
SELECT * FROM table_name WHERE column = 'value' AND column2 > 100;
```
*Что делает:* Фильтрует строки на основе указанных условий
*Операторы:* =, !=, <>, >, <, >=, <=, AND, OR, NOT, LIKE, IN, BETWEEN

**ORDER BY** - сортировка результатов
```sql
SELECT * FROM table_name ORDER BY column1 ASC, column2 DESC;
```
*Что делает:* Сортирует результат по указанным столбцам
*ASC* - по возрастанию (по умолчанию)
*DESC* - по убыванию

**COUNT()** - подсчет строк
```sql
SELECT COUNT(*) FROM table_name WHERE condition;
```
*Что делает:* Подсчитывает количество строк, удовлетворяющих условию
*Что получаем:* Числовое значение - количество строк

**GROUP BY** - группировка результатов
```sql
SELECT column, COUNT(*) FROM table_name GROUP BY column;
```
*Что делает:* Группирует строки с одинаковыми значениями и применяет агрегатные функции
*Что получаем:* Сгруппированные данные с вычисленными агрегатными значениями

**HAVING** - фильтрация групп
```sql
SELECT column, COUNT(*) FROM table_name GROUP BY column HAVING COUNT(*) > 5;
```
*Что делает:* Фильтрует результаты после группировки (в отличие от WHERE, который фильтрует до группировки)

**GETDATE()** - получение текущей даты и времени
```sql
INSERT INTO table_name (created_at) VALUES (GETDATE());
```
*Что делает:* Возвращает текущую дату и время сервера
*Что получаем:* Значение типа datetime с текущей датой и временем

### Параметризованные запросы:
```sql
SELECT * FROM Users WHERE username = @username;
```
*Что делает:* Использует параметры вместо прямых значений для защиты от SQL-инъекций
*Что получаем:* Безопасное выполнение запроса с подставленными параметрами
