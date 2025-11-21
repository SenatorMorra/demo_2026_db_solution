# 🚀 Инструкция: C# Avalonia приложение - Модули 2 и 3

## 📋 Содержание:
1. [Обзор архитектуры приложения](#обзор-архитектуры-приложения)
2. [Структура проекта](#структура-проекта)
3. [Модуль 2: Просмотр каталога товаров](#модуль-2-просмотр-каталога-товаров)
4. [Модуль 3: Поиск, фильтрация и CRUD товаров](#модуль-3-поиск-фильтрация-и-crud-товаров)
5. [Рекомендации по разработке](#рекомендации-по-разработке)

---

## 🏗️ Обзор архитектуры приложения

### 🎯 Используемые технологии:
- **.NET 8.0** - последняя версия .NET
- **Avalonia UI** - кроссплатформенный фреймворк (аналог WPF)
- **CommunityToolkit.Mvvm** - библиотека для MVVM паттерна
- **MySQL.Data** - коннектор для работы с MySQL
- **Microsoft.Extensions.Configuration** - управление конфигурацией

### 📐 Архитектурный паттерн: MVVM (Model-View-ViewModel)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     View        │    │   ViewModel     │    │     Model       │
│  (XAML + Code)  │◄──►│ (C# логика)     │◄──►│  (Данные)       │
│                 │    │                 │    │                 │
│ LoginWindow     │    │ LoginViewModel  │    │ User, Product   │
│ MainWindow      │    │ MainViewModel   │    │ Category, Role  │
│ ProductEditView │    │ ProductViewModel│    │ Manufacturer    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 📦 Основные NuGet пакеты:
```xml
<PackageReference Include="Avalonia" Version="11.3.9" />
<PackageReference Include="Avalonia.Desktop" Version="11.3.9" />
<PackageReference Include="CommunityToolkit.Mvvm" Version="8.2.1" />
<PackageReference Include="MySql.Data" Version="8.2.0" />
<PackageReference Include="Microsoft.Extensions.Configuration" Version="8.0.0" />
<PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="8.0.0" />
```

---

## 📂 Структура проекта

```
ShoeShopGUI/
├── 📁 Models/                    # Модели данных
│   ├── Product.cs               # Модель товара
│   ├── User.cs                  # Модель пользователя
│   ├── Category.cs              # Модель категории
│   ├── Manufacturer.cs          # Модель производителя
│   └── Role.cs                  # Модель роли
│
├── 📁 ViewModels/                # ViewModel слои
│   ├── LoginWindowViewModel.cs  # ViewModel окна входа
│   ├── MainWindowViewModel.cs   # ViewModel главного окна
│   └── ProductEditViewModel.cs  # ViewModel редактирования товара
│
├── 📁 Views/                     # Пользовательский интерфейс (XAML)
│   ├── LoginWindow.axaml        # Окно входа
│   ├── MainWindow.axaml         # Главное окно
│   └── ProductEditWindow.axaml  # Окно редактирования товара
│
├── 📁 Services/                  # Сервисный слой
│   ├── DatabaseServiceSimple.cs # Сервис работы с БД
│   └── AuthenticationService.cs  # Сервис аутентификации
│
├── 📁 Assets/                    # Ресурсы приложения
│   ├── picture.png              # Изображение-заглушка
│   ├── 1.jpg, 2.jpg...          # Фотографии товаров
│   └── avalonia-logo.ico        # Иконка приложения
│
├── 📄 appsettings.json           # Конфигурация приложения
├── 📄 Program.cs                 # Точка входа
├── 📄 App.axaml                  # Глобальные стили
└── 📄 ShoeShopGUI.csproj         # Файл проекта
```

---

## 🖥️ Модуль 2: Просмотр каталога товаров

### 🎯 Функционал Модуля 2:
- ✅ Аутентификация пользователей с ролью доступа
- ✅ Отображение каталога товаров с фотографиями
- ✅ Простая навигация по категориям
- ✅ Базовая информация о товарах

### 🔐 1. Модели данных

#### **User.cs - Модель пользователя:**
```csharp
using System;

namespace ShoeShopGUI.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Login { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public Role? Role { get; set; }

        // Свойства для удобного доступа
        public string FullName => $"{FirstName} {LastName}".Trim();
        public bool IsAdmin => Role?.RoleName == "Администратор";
        public bool IsManager => Role?.RoleName == "Менеджер";
        public bool IsGuest => Role?.RoleName == "Гость" || Role == null;
    }
}
```

#### **Role.cs - Модель роли:**
```csharp
namespace ShoeShopGUI.Models
{
    public class Role
    {
        public int IdRole { get; set; }
        public string RoleName { get; set; } = string.Empty;
    }
}
```

#### **Product.cs - Модель товара:**
```csharp
using System;
using System.IO;
using Avalonia.Media.Imaging;

namespace ShoeShopGUI.Models
{
    public class Product
    {
        public int IdProduct { get; set; }
        public string ArticleNumber { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public decimal DiscountPercent { get; set; }
        public string Unit { get; set; } = "шт";
        public int StockQuantity { get; set; }
        public string AvailabilityStatus { get; set; } = "В наличии";
        public string? PhotoUrl { get; set; }

        // Навигационные свойства
        public Category? Category { get; set; }
        public Manufacturer? Manufacturer { get; set; }
        public Supplier? Supplier { get; set; }

        // Плоские свойства для удобного биндинга
        public string? CategoryName => Category?.CategoryName;
        public string? ManufacturerName => Manufacturer?.ManufacturerName;
        public string? SupplierName => Supplier?.SupplierName;

        // Вычисляемые свойства
        public decimal DiscountedPrice => Price * (1 - DiscountPercent / 100);
        public bool HasDiscount => DiscountPercent > 0;
        public string BackgroundColor => HasDiscount ? "#FFF5F5" : "#FFFFFF";

        // Изображение для отображения
        public Bitmap? ProductImage
        {
            get
            {
                try
                {
                    if (string.IsNullOrWhiteSpace(PhotoUrl))
                    {
                        var placeholderPath = $"{Directory.GetCurrentDirectory()}/Assets/picture.png";
                        return File.Exists(placeholderPath) ? new Bitmap(placeholderPath) : null;
                    }

                    var imagePath = $"{Directory.GetCurrentDirectory()}/Assets/{PhotoUrl}";
                    return File.Exists(imagePath) ? new Bitmap(imagePath) : null;
                }
                catch
                {
                    return null;
                }
            }
        }
    }
}
```

### 🗃️ 2. Сервис работы с базой данных

#### **DatabaseServiceSimple.cs - Основной сервис:**
```csharp
using Microsoft.Extensions.Configuration;
using MySql.Data.MySqlClient;
using ShoeShopGUI.Models;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace ShoeShopGUI.Services
{
    public class DatabaseServiceSimple
    {
        private readonly string _connectionString;

        public DatabaseServiceSimple(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        // 🔐 Аутентификация пользователя
        public async Task<User?> AuthenticateUserAsync(string login, string password)
        {
            try
            {
                using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT u.id_user, u.login, u.first_name, u.last_name,
                           r.id_role, r.role_name
                    FROM users u
                    JOIN roles r ON u.id_role = r.id_role
                    WHERE u.login = @login AND u.password_hash = @password";

                using var command = new MySqlCommand(query, connection);
                command.Parameters.AddWithValue("@login", login);
                command.Parameters.AddWithValue("@password", password); // В реальном приложении - хэш пароля

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return new User
                    {
                        Id = reader.GetInt32("id_user"),
                        Login = reader.GetString("login"),
                        FirstName = reader.GetString("first_name"),
                        LastName = reader.GetString("last_name"),
                        Role = new Role
                        {
                            IdRole = reader.GetInt32("id_role"),
                            RoleName = reader.GetString("role_name")
                        }
                    };
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка аутентификации: {ex.Message}");
            }

            return null;
        }

        // 📦 Получение всех товаров
        public async Task<List<Product>> GetProductsAsync()
        {
            var products = new List<Product>();

            try
            {
                using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = @"
                    SELECT
                        p.id_product, p.article_number, p.product_name, p.description,
                        p.price, p.discount_percent, p.unit, p.stock_quantity,
                        p.availability_status, p.photo_url,
                        c.id_category, c.category_name,
                        m.id_manufacturer, m.manufacturer_name,
                        s.id_supplier, s.supplier_name
                    FROM products p
                    LEFT JOIN categories c ON p.id_category = c.id_category
                    LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
                    LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
                    ORDER BY p.product_name";

                using var command = new MySqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    var product = new Product
                    {
                        IdProduct = reader.GetInt32("id_product"),
                        ArticleNumber = reader.GetString("article_number"),
                        ProductName = reader.GetString("product_name"),
                        Description = reader.IsDBNull("description") ? null : reader.GetString("description"),
                        Price = reader.GetDecimal("price"),
                        DiscountPercent = reader.GetDecimal("discount_percent"),
                        Unit = reader.GetString("unit"),
                        StockQuantity = reader.GetInt32("stock_quantity"),
                        AvailabilityStatus = reader.GetString("availability_status"),
                        PhotoUrl = reader.IsDBNull("photo_url") ? null : reader.GetString("photo_url")
                    };

                    // Категория
                    if (!reader.IsDBNull("id_category"))
                    {
                        product.Category = new Category
                        {
                            IdCategory = reader.GetInt32("id_category"),
                            CategoryName = reader.GetString("category_name")
                        };
                    }

                    // Производитель
                    if (!reader.IsDBNull("id_manufacturer"))
                    {
                        product.Manufacturer = new Manufacturer
                        {
                            IdManufacturer = reader.GetInt32("id_manufacturer"),
                            ManufacturerName = reader.GetString("manufacturer_name")
                        };
                    }

                    // Поставщик
                    if (!reader.IsDBNull("id_supplier"))
                    {
                        product.Supplier = new Supplier
                        {
                            IdSupplier = reader.GetInt32("id_supplier"),
                            SupplierName = reader.GetString("supplier_name")
                        };
                    }

                    products.Add(product);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка загрузки товаров: {ex.Message}");
            }

            return products;
        }

        // 📋 Получение категорий
        public async Task<List<Category>> GetCategoriesAsync()
        {
            var categories = new List<Category();

            try
            {
                using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                var query = "SELECT id_category, category_name FROM categories ORDER BY category_name";

                using var command = new MySqlCommand(query, connection);
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    categories.Add(new Category
                    {
                        IdCategory = reader.GetInt32("id_category"),
                        CategoryName = reader.GetString("category_name")
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка загрузки категорий: {ex.Message}");
            }

            return categories;
        }
    }
}
```

### 🔐 3. ViewModel окна входа

#### **LoginWindowViewModel.cs:**
```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ShoeShopGUI.Models;
using ShoeShopGUI.Services;
using System;
using System.Threading.Tasks;

namespace ShoeShopGUI.ViewModels
{
    public partial class LoginWindowViewModel : ViewModelBase
    {
        private readonly DatabaseServiceSimple _databaseService;

        [ObservableProperty]
        private string _userLogin = string.Empty;

        [ObservableProperty]
        private string _password = string.Empty;

        [ObservableProperty]
        private string _errorMessage = string.Empty;

        [ObservableProperty]
        private bool _hasErrorMessage = false;

        public User? CurrentUser { get; private set; }

        public event EventHandler<User?>? LoginSuccessful;

        public LoginWindowViewModel(DatabaseServiceSimple databaseService)
        {
            _databaseService = databaseService;
        }

        [RelayCommand]
        private async Task Login()
        {
            try
            {
                if (string.IsNullOrWhiteSpace(UserLogin) || string.IsNullOrWhiteSpace(Password))
                {
                    ShowError("Пожалуйста, введите логин и пароль");
                    return;
                }

                var user = await _databaseService.AuthenticateUserAsync(UserLogin, Password);

                if (user != null)
                {
                    CurrentUser = user;
                    ClearError();
                    LoginSuccessful?.Invoke(this, user);
                }
                else
                {
                    ShowError("Неверный логин или пароль");
                }
            }
            catch (Exception ex)
            {
                ShowError($"Ошибка при входе: {ex.Message}");
            }
        }

        [RelayCommand]
        private void LoginAsGuest()
        {
            try
            {
                CurrentUser = new User
                {
                    Id = 0,
                    Login = "guest",
                    FirstName = "Гость",
                    LastName = "",
                    Role = new Role { RoleName = "Гость" }
                };

                ClearError();
                LoginSuccessful?.Invoke(this, CurrentUser);
            }
            catch (Exception ex)
            {
                ShowError($"Ошибка при входе как гость: {ex.Message}");
            }
        }

        private void ShowError(string message)
        {
            ErrorMessage = message;
            HasErrorMessage = true;
        }

        private void ClearError()
        {
            ErrorMessage = string.Empty;
            HasErrorMessage = false;
        }
    }
}
```

### 🖼️ 4. View окна входа

#### **LoginWindow.axaml:**
```xml
<Window xmlns="https://github.com/avaloniaui"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:vm="clr-namespace:ShoeShopGUI.ViewModels"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        mc:Ignorable="d" d:DesignWidth="400" d:DesignHeight="500"
        x:Class="ShoeShopGUI.Views.LoginWindow"
        x:DataType="vm:LoginWindowViewModel"
        Title="🏪 Обувной магазин - Вход в систему"
        Width="450" Height="700"
        WindowStartupLocation="CenterScreen"
        CanResize="False">

    <Design.DataContext>
        <vm:LoginWindowViewModel/>
    </Design.DataContext>

    <Grid Background="#F5F5F5">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Шапка с логотипом -->
        <Border Grid.Row="0" Background="#2E7D32" Padding="20">
            <StackPanel HorizontalAlignment="Center">
                <TextBlock Text="🏪" FontSize="48" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                <TextBlock Text="Обувной магазин"
                          FontSize="24" FontWeight="Bold"
                          Foreground="White" HorizontalAlignment="Center"/>
                <TextBlock Text="Система управления каталогом"
                          FontSize="14" Foreground="#E8F5E9"
                          HorizontalAlignment="Center" Margin="0,5,0,0"/>
            </StackPanel>
        </Border>

        <!-- Форма входа -->
        <Border Grid.Row="1" Background="White"
                CornerRadius="10" Margin="30,20"
                BoxShadow="0 4 6 rgba(0,0,0,0.1)">
            <StackPanel Margin="40,30">
                <TextBlock Text="🔐 Вход в систему"
                          FontSize="20" FontWeight="Bold"
                          HorizontalAlignment="Center" Margin="0,0,0,30"/>

                <!-- Логин -->
                <StackPanel Margin="0,0,0,15">
                    <TextBlock Text="Логин:" FontWeight="SemiBold" Margin="0,0,0,5"/>
                    <TextBox Text="{Binding UserLogin}"
                             Watermark="Введите логин"
                             Height="40" FontSize="14"/>
                </StackPanel>

                <!-- Пароль -->
                <StackPanel Margin="0,0,0,25">
                    <TextBlock Text="Пароль:" FontWeight="SemiBold" Margin="0,0,0,5"/>
                    <TextBox Text="{Binding Password}"
                             Watermark="Введите пароль"
                             Height="40" FontSize="14"
                             PasswordChar="*"/>
                </StackPanel>

                <!-- Кнопки входа -->
                <StackPanel Spacing="10">
                    <Button Content="🔐 Войти"
                            Command="{Binding LoginCommand}"
                            Height="45" FontSize="16" FontWeight="SemiBold"
                            Background="#3498DB" Foreground="White"/>

                    <Button Content="👤 Продолжить без авторизации"
                            Command="{Binding LoginAsGuestCommand}"
                            Height="40" FontSize="14"
                            Background="#95A5A6" Foreground="White"/>
                </StackPanel>

                <!-- Сообщение об ошибке -->
                <TextBlock Text="{Binding ErrorMessage}"
                          Foreground="Red"
                          FontSize="12"
                          TextWrapping="Wrap"
                          IsVisible="{Binding HasErrorMessage}"
                          Margin="0,15,0,0"/>
            </StackPanel>
        </Border>

        <!-- Подвал с демо-данными -->
        <Border Grid.Row="2" Background="#F0F0F0" Padding="15,10">
            <StackPanel HorizontalAlignment="Center">
                <TextBlock Text="📋 Демонстрационные данные:"
                          FontSize="12" FontWeight="SemiBold"
                          HorizontalAlignment="Center"/>
                <TextBlock Text="Администратор: admin@example.com / admin123"
                          FontSize="11" HorizontalAlignment="Center"
                          Foreground="#666" Margin="0,2,0,0"/>
                <TextBlock Text="Менеджер: manager@example.com / manager123"
                          FontSize="11" HorizontalAlignment="Center"
                          Foreground="#666"/>
            </StackPanel>
        </Border>
    </Grid>
</Window>
```

### 🏪 5. ViewModel главного окна

#### **MainWindowViewModel.cs:**
```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ShoeShopGUI.Models;
using ShoeShopGUI.Services;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;

namespace ShoeShopGUI.ViewModels
{
    public partial class MainWindowViewModel : ViewModelBase
    {
        private readonly DatabaseServiceSimple _databaseService;
        private User? _currentUser;

        [ObservableProperty]
        private ObservableCollection<Product> _products = new();

        [ObservableProperty]
        private Product? _selectedProduct;

        [ObservableProperty]
        private string _searchText = string.Empty;

        [ObservableProperty]
        private string _statusMessage = "Загрузка товаров...";

        [ObservableProperty]
        private bool _isLoading = false;

        public User? CurrentUser
        {
            get => _currentUser;
            private set
            {
                SetProperty(ref _currentUser, value);
                OnPropertyChanged(nameof(CanEditProducts));
                OnPropertyChanged(nameof(IsLoggedIn));
                OnPropertyChanged(nameof(UserDisplayName));
            }
        }

        public bool CanEditProducts => CurrentUser?.IsAdmin == true;
        public bool IsLoggedIn => CurrentUser != null;
        public string UserDisplayName => CurrentUser?.FullName ?? "Гость";

        public MainWindowViewModel(DatabaseServiceSimple databaseService)
        {
            _databaseService = databaseService;
        }

        public async Task InitializeAsync()
        {
            await LoadProductsAsync();
        }

        [RelayCommand]
        private async Task LoadProductsAsync()
        {
            try
            {
                IsLoading = true;
                StatusMessage = "Загрузка товаров...";

                var products = await _databaseService.GetProductsAsync();

                Products.Clear();
                foreach (var product in products)
                {
                    Products.Add(product);
                }

                StatusMessage = $"Загружено {Products.Count} товаров";
            }
            catch (Exception ex)
            {
                StatusMessage = $"Ошибка загрузки: {ex.Message}";
            }
            finally
            {
                IsLoading = false;
            }
        }

        [RelayCommand]
        private async Task SearchProducts()
        {
            try
            {
                IsLoading = true;
                StatusMessage = "Поиск товаров...";

                var allProducts = await _databaseService.GetProductsAsync();
                var filteredProducts = string.IsNullOrWhiteSpace(SearchText)
                    ? allProducts
                    : allProducts.Where(p =>
                        p.ProductName.ToLower().Contains(SearchText.ToLower()) ||
                        p.ArticleNumber.ToLower().Contains(SearchText.ToLower()) ||
                        (p.Category?.CategoryName?.ToLower().Contains(SearchText.ToLower()) ?? false))
                    .ToList();

                Products.Clear();
                foreach (var product in filteredProducts)
                {
                    Products.Add(product);
                }

                StatusMessage = $"Найдено {Products.Count} товаров";
            }
            catch (Exception ex)
            {
                StatusMessage = $"Ошибка поиска: {ex.Message}";
            }
            finally
            {
                IsLoading = false;
            }
        }

        public void SetCurrentUser(User user)
        {
            CurrentUser = user;
            StatusMessage = $"Вы вошли как: {user.FullName} ({user.Role?.RoleName})";
        }
    }
}
```

---

## 🔍 Модуль 3: Поиск, фильтрация и CRUD товаров

### 🎯 Функционал Модуля 3:
- ✅ Расширенный поиск по нескольким полям
- ✅ Фильтрация по категориям, производителям, поставщикам
- ✅ Сортировка по цене, названию, количеству
- ✅ CRUD операции для администратора
- ✅ Управление справочниками

### 🔧 1. Расширение DatabaseService для Модуля 3

#### **Методы поиска и фильтрации:**
```csharp
// 🔍 Поиск товаров по нескольким параметрам
public async Task<List<Product>> SearchProductsAsync(string searchText)
{
    var products = new List<Product>();

    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        var query = @"
            SELECT
                p.id_product, p.article_number, p.product_name, p.description,
                p.price, p.discount_percent, p.unit, p.stock_quantity,
                p.availability_status, p.photo_url,
                c.id_category, c.category_name,
                m.id_manufacturer, m.manufacturer_name,
                s.id_supplier, s.supplier_name
            FROM products p
            LEFT JOIN categories c ON p.id_category = c.id_category
            LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
            LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
            WHERE
                p.product_name LIKE @searchText OR
                p.article_number LIKE @searchText OR
                p.description LIKE @searchText OR
                c.category_name LIKE @searchText OR
                m.manufacturer_name LIKE @searchText
            ORDER BY p.product_name";

        using var command = new MySqlCommand(query, connection);
        command.Parameters.AddWithValue("@searchText", $"%{searchText}%");

        products = await ExecuteProductQuery(command);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Ошибка поиска: {ex.Message}");
    }

    return products;
}

// 🔧 Фильтрация товаров
public async Task<List<Product>> FilterProductsAsync(
    string? category = null,
    string? manufacturer = null,
    string? supplier = null,
    string? status = null,
    decimal? minPrice = null,
    decimal? maxPrice = null,
    int? minStock = null,
    string sortBy = "name",
    bool sortAscending = true)
{
    var products = new List<Product();

    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        var whereConditions = new List<string>();
        var parameters = new List<MySqlParameter>();

        // Динамическое построение WHERE
        if (!string.IsNullOrWhiteSpace(category))
        {
            whereConditions.Add("c.category_name = @category");
            parameters.Add(new MySqlParameter("@category", category));
        }

        if (!string.IsNullOrWhiteSpace(manufacturer))
        {
            whereConditions.Add("m.manufacturer_name = @manufacturer");
            parameters.Add(new MySqlParameter("@manufacturer", manufacturer));
        }

        if (!string.IsNullOrWhiteSpace(supplier))
        {
            whereConditions.Add("s.supplier_name = @supplier");
            parameters.Add(new MySqlParameter("@supplier", supplier));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            whereConditions.Add("p.availability_status = @status");
            parameters.Add(new MySqlParameter("@status", status));
        }

        if (minPrice.HasValue)
        {
            whereConditions.Add("p.price >= @minPrice");
            parameters.Add(new MySqlParameter("@minPrice", minPrice.Value));
        }

        if (maxPrice.HasValue)
        {
            whereConditions.Add("p.price <= @maxPrice");
            parameters.Add(new MySqlParameter("@maxPrice", maxPrice.Value));
        }

        if (minStock.HasValue)
        {
            whereConditions.Add("p.stock_quantity >= @minStock");
            parameters.Add(new MySqlParameter("@minStock", minStock.Value));
        }

        // Сортировка
        string sortColumn = sortBy.ToLower() switch
        {
            "price" => "p.price",
            "stock" => "p.stock_quantity",
            "name" => "p.product_name",
            _ => "p.product_name"
        };

        string sortDirection = sortAscending ? "ASC" : "DESC";

        var query = $@"
            SELECT
                p.id_product, p.article_number, p.product_name, p.description,
                p.price, p.discount_percent, p.unit, p.stock_quantity,
                p.availability_status, p.photo_url,
                c.id_category, c.category_name,
                m.id_manufacturer, m.manufacturer_name,
                s.id_supplier, s.supplier_name
            FROM products p
            LEFT JOIN categories c ON p.id_category = c.id_category
            LEFT JOIN manufacturers m ON p.id_manufacturer = m.id_manufacturer
            LEFT JOIN suppliers s ON p.id_supplier = s.id_supplier
            {(whereConditions.Any() ? $"WHERE {string.Join(" AND ", whereConditions)}" : "")}
            ORDER BY {sortColumn} {sortDirection}";

        using var command = new MySqlCommand(query, connection);
        command.Parameters.AddRange(parameters.ToArray());

        products = await ExecuteProductQuery(command);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Ошибка фильтрации: {ex.Message}");
    }

    return products;
}

// Вспомогательный метод для выполнения запроса
private async Task<List<Product>> ExecuteProductQuery(MySqlCommand command)
{
    var products = new List<Product>();

    using var reader = await command.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        var product = new Product
        {
            IdProduct = reader.GetInt32("id_product"),
            ArticleNumber = reader.GetString("article_number"),
            ProductName = reader.GetString("product_name"),
            Description = reader.IsDBNull("description") ? null : reader.GetString("description"),
            Price = reader.GetDecimal("price"),
            DiscountPercent = reader.GetDecimal("discount_percent"),
            Unit = reader.GetString("unit"),
            StockQuantity = reader.GetInt32("stock_quantity"),
            AvailabilityStatus = reader.GetString("availability_status"),
            PhotoUrl = reader.IsDBNull("photo_url") ? null : reader.GetString("photo_url")
        };

        // Заполнение навигационных свойств...
        if (!reader.IsDBNull("id_category"))
        {
            product.Category = new Category
            {
                IdCategory = reader.GetInt32("id_category"),
                CategoryName = reader.GetString("category_name")
            };
        }

        products.Add(product);
    }

    return products;
}
```

#### **CRUD операции:**
```csharp
// ➕ Создание товара
public async Task<bool> CreateProductAsync(Product product)
{
    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        var query = @"
            INSERT INTO products (
                article_number, product_name, description, price,
                discount_percent, unit, stock_quantity, availability_status,
                photo_url, id_category, id_manufacturer, id_supplier
            ) VALUES (
                @articleNumber, @productName, @description, @price,
                @discountPercent, @unit, @stockQuantity, @availabilityStatus,
                @photoUrl, @idCategory, @idManufacturer, @idSupplier
            )";

        using var command = new MySqlCommand(query, connection);

        command.Parameters.AddWithValue("@articleNumber", product.ArticleNumber);
        command.Parameters.AddWithValue("@productName", product.ProductName);
        command.Parameters.AddWithValue("@description", (object?)product.Description ?? DBNull.Value);
        command.Parameters.AddWithValue("@price", product.Price);
        command.Parameters.AddWithValue("@discountPercent", product.DiscountPercent);
        command.Parameters.AddWithValue("@unit", product.Unit);
        command.Parameters.AddWithValue("@stockQuantity", product.StockQuantity);
        command.Parameters.AddWithValue("@availabilityStatus", product.AvailabilityStatus);
        command.Parameters.AddWithValue("@photoUrl", (object?)product.PhotoUrl ?? DBNull.Value);
        command.Parameters.AddWithValue("@idCategory", (object?)product.Category?.IdCategory ?? DBNull.Value);
        command.Parameters.AddWithValue("@idManufacturer", (object?)product.Manufacturer?.IdManufacturer ?? DBNull.Value);
        command.Parameters.AddWithValue("@idSupplier", (object?)product.Supplier?.IdSupplier ?? DBNull.Value);

        var result = await command.ExecuteNonQueryAsync();
        return result > 0;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Ошибка создания товара: {ex.Message}");
        return false;
    }
}

// 📝 Обновление товара
public async Task<bool> UpdateProductAsync(Product product)
{
    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        var query = @"
            UPDATE products SET
                article_number = @articleNumber,
                product_name = @productName,
                description = @description,
                price = @price,
                discount_percent = @discountPercent,
                unit = @unit,
                stock_quantity = @stockQuantity,
                availability_status = @availabilityStatus,
                photo_url = @photoUrl,
                id_category = @idCategory,
                id_manufacturer = @idManufacturer,
                id_supplier = @idSupplier
            WHERE id_product = @idProduct";

        using var command = new MySqlCommand(query, connection);

        command.Parameters.AddWithValue("@idProduct", product.IdProduct);
        command.Parameters.AddWithValue("@articleNumber", product.ArticleNumber);
        command.Parameters.AddWithValue("@productName", product.ProductName);
        command.Parameters.AddWithValue("@description", (object?)product.Description ?? DBNull.Value);
        command.Parameters.AddWithValue("@price", product.Price);
        command.Parameters.AddWithValue("@discountPercent", product.DiscountPercent);
        command.Parameters.AddWithValue("@unit", product.Unit);
        command.Parameters.AddWithValue("@stockQuantity", product.StockQuantity);
        command.Parameters.AddWithValue("@availabilityStatus", product.AvailabilityStatus);
        command.Parameters.AddWithValue("@photoUrl", (object?)product.PhotoUrl ?? DBNull.Value);
        command.Parameters.AddWithValue("@idCategory", (object?)product.Category?.IdCategory ?? DBNull.Value);
        command.Parameters.AddWithValue("@idManufacturer", (object?)product.Manufacturer?.IdManufacturer ?? DBNull.Value);
        command.Parameters.AddWithValue("@idSupplier", (object?)product.Supplier?.IdSupplier ?? DBNull.Value);

        var result = await command.ExecuteNonQueryAsync();
        return result > 0;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Ошибка обновления товара: {ex.Message}");
        return false;
    }
}

// 🗑️ Удаление товара
public async Task<bool> DeleteProductAsync(int productId)
{
    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        var query = "DELETE FROM products WHERE id_product = @idProduct";

        using var command = new MySqlCommand(query, connection);
        command.Parameters.AddWithValue("@idProduct", productId);

        var result = await command.ExecuteNonQueryAsync();
        return result > 0;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Ошибка удаления товара: {ex.Message}");
        return false;
    }
}

// 📋 CRUD для справочников
public async Task<List<Category>> GetCategoriesAsync() { /* реализация */ }
public async Task<bool> CreateCategoryAsync(Category category) { /* реализация */ }
public async Task<bool> UpdateCategoryAsync(Category category) { /* реализация */ }
public async Task<bool> DeleteCategoryAsync(int categoryId) { /* реализация */ }

public async Task<List<Manufacturer>> GetManufacturersAsync() { /* реализация */ }
public async Task<List<Supplier>> GetSuppliersAsync() { /* реализация */ }
```

### 🎨 2. ViewModel редактирования товара

#### **ProductEditViewModel.cs:**
```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ShoeShopGUI.Models;
using ShoeShopGUI.Services;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System;

namespace ShoeShopGUI.ViewModels
{
    public partial class ProductEditViewModel : ViewModelBase
    {
        private readonly DatabaseServiceSimple _databaseService;
        private Product? _originalProduct;

        [ObservableProperty]
        private Product _product;

        [ObservableProperty]
        private ObservableCollection<Category> _categories = new();

        [ObservableProperty]
        private ObservableCollection<Manufacturer> _manufacturers = new();

        [ObservableProperty]
        private ObservableCollection<Supplier> _suppliers = new();

        [ObservableProperty]
        private string _statusMessage = string.Empty;

        [ObservableProperty]
        private bool _isLoading = false;

        [ObservableProperty]
        private bool _hasChanges = false;

        public bool IsNewProduct => _originalProduct == null;
        public bool IsEditMode => !IsNewProduct;

        public ProductEditViewModel(DatabaseServiceSimple databaseService, Product? product = null)
        {
            _databaseService = databaseService;
            _product = product ?? new Product();
            _originalProduct = product != null ? CloneProduct(product) : null;
        }

        public async Task InitializeAsync()
        {
            await LoadReferenceDataAsync();
        }

        private async Task LoadReferenceDataAsync()
        {
            try
            {
                IsLoading = true;

                // Загрузка справочников параллельно
                var categoriesTask = _databaseService.GetCategoriesAsync();
                var manufacturersTask = _databaseService.GetManufacturersAsync();
                var suppliersTask = _databaseService.GetSuppliersAsync();

                await Task.WhenAll(categoriesTask, manufacturersTask, suppliersTask);

                Categories.Clear();
                foreach (var category in await categoriesTask)
                {
                    Categories.Add(category);
                }

                Manufacturers.Clear();
                foreach (var manufacturer in await manufacturersTask)
                {
                    Manufacturers.Add(manufacturer);
                }

                Suppliers.Clear();
                foreach (var supplier in await suppliersTask)
                {
                    Suppliers.Add(supplier);
                }

                // Установка текущих значений
                if (Product.Category != null)
                {
                    Product.Category = Categories.FirstOrDefault(c => c.IdCategory == Product.Category.IdCategory);
                }

                if (Product.Manufacturer != null)
                {
                    Product.Manufacturer = Manufacturers.FirstOrDefault(m => m.IdManufacturer == Product.Manufacturer.IdManufacturer);
                }

                if (Product.Supplier != null)
                {
                    Product.Supplier = Suppliers.FirstOrDefault(s => s.IdSupplier == Product.Supplier.IdSupplier);
                }
            }
            catch (Exception ex)
            {
                StatusMessage = $"Ошибка загрузки данных: {ex.Message}";
            }
            finally
            {
                IsLoading = false;
            }
        }

        [RelayCommand]
        private async Task SaveProduct()
        {
            try
            {
                IsLoading = true;
                StatusMessage = "Сохранение товара...";

                if (!ValidateProduct())
                {
                    IsLoading = false;
                    return;
                }

                bool success;
                if (IsNewProduct)
                {
                    success = await _databaseService.CreateProductAsync(Product);
                    StatusMessage = success ? "Товар успешно создан" : "Ошибка создания товара";
                }
                else
                {
                    success = await _databaseService.UpdateProductAsync(Product);
                    StatusMessage = success ? "Товар успешно обновлен" : "Ошибка обновления товара";
                }

                if (success)
                {
                    _originalProduct = CloneProduct(Product);
                    HasChanges = false;
                }
            }
            catch (Exception ex)
            {
                StatusMessage = $"Ошибка сохранения: {ex.Message}";
            }
            finally
            {
                IsLoading = false;
            }
        }

        [RelayCommand]
        private void Cancel()
        {
            if (_originalProduct != null)
            {
                Product = CloneProduct(_originalProduct);
                HasChanges = false;
            }
        }

        [RelayCommand]
        private void ResetForm()
        {
            Product = IsNewProduct ? new Product() : CloneProduct(_originalProduct!);
            HasChanges = false;
            StatusMessage = "Форма сброшена";
        }

        private bool ValidateProduct()
        {
            if (string.IsNullOrWhiteSpace(Product.ArticleNumber))
            {
                StatusMessage = "Артикул обязателен для заполнения";
                return false;
            }

            if (string.IsNullOrWhiteSpace(Product.ProductName))
            {
                StatusMessage = "Название товара обязательно для заполнения";
                return false;
            }

            if (Product.Price <= 0)
            {
                StatusMessage = "Цена должна быть положительным числом";
                return false;
            }

            if (Product.StockQuantity < 0)
            {
                StatusMessage = "Количество не может быть отрицательным";
                return false;
            }

            if (string.IsNullOrWhiteSpace(Product.Unit))
            {
                StatusMessage = "Единица измерения обязательна для заполнения";
                return false;
            }

            return true;
        }

        private Product CloneProduct(Product original)
        {
            return new Product
            {
                IdProduct = original.IdProduct,
                ArticleNumber = original.ArticleNumber,
                ProductName = original.ProductName,
                Description = original.Description,
                Price = original.Price,
                DiscountPercent = original.DiscountPercent,
                Unit = original.Unit,
                StockQuantity = original.StockQuantity,
                AvailabilityStatus = original.AvailabilityStatus,
                PhotoUrl = original.PhotoUrl,
                Category = original.Category,
                Manufacturer = original.Manufacturer,
                Supplier = original.Supplier
            };
        }
    }
}
```

### 🎯 3. Расширенный MainWindowViewModel

#### **Дополнительные команды для Модуля 3:**
```csharp
// 🔍 Расширенный поиск
[RelayCommand]
private async Task AdvancedSearch()
{
    try
    {
        IsLoading = true;
        StatusMessage = "Выполняется поиск...";

        var products = await _databaseService.SearchProductsAsync(SearchText);

        Products.Clear();
        foreach (var product in products)
        {
            Products.Add(product);
        }

        StatusMessage = $"Найдено {Products.Count} товаров по запросу: '{SearchText}'";
    }
    catch (Exception ex)
    {
        StatusMessage = $"Ошибка поиска: {ex.Message}";
    }
    finally
    {
        IsLoading = false;
    }
}

// ➕ Создание нового товара
[RelayCommand]
private async Task CreateProduct()
{
    try
    {
        var editViewModel = new ProductEditViewModel(_databaseService);
        await editViewModel.InitializeAsync();

        // Открытие окна редактирования (реализация зависит от UI фреймворка)
        var editWindow = new ProductEditWindow();
        editWindow.DataContext = editViewModel;

        if (await editWindow.ShowDialog<bool>(GetMainWindow()) == true)
        {
            await LoadProductsAsync();
        }
    }
    catch (Exception ex)
    {
        StatusMessage = $"Ошибка создания товара: {ex.Message}";
    }
}

// 📝 Редактирование товара
[RelayCommand]
private async Task EditProduct()
{
    if (SelectedProduct == null)
    {
        StatusMessage = "Выберите товар для редактирования";
        return;
    }

    try
    {
        var editViewModel = new ProductEditViewModel(_databaseService, SelectedProduct);
        await editViewModel.InitializeAsync();

        var editWindow = new ProductEditWindow();
        editWindow.DataContext = editViewModel;

        if (await editWindow.ShowDialog<bool>(GetMainWindow()) == true)
        {
            await LoadProductsAsync();
        }
    }
    catch (Exception ex)
    {
        StatusMessage = $"Ошибка редактирования товара: {ex.Message}";
    }
}

// 🗑️ Удаление товара
[RelayCommand]
private async Task DeleteProduct()
{
    if (SelectedProduct == null)
    {
        StatusMessage = "Выберите товар для удаления";
        return;
    }

    try
    {
        var result = await ShowConfirmationDialog(
            "Удаление товара",
            $"Вы уверены, что хотите удалить товар '{SelectedProduct.ProductName}'?",
            "Да", "Нет");

        if (!result) return;

        IsLoading = true;
        StatusMessage = "Удаление товара...";

        var success = await _databaseService.DeleteProductAsync(SelectedProduct.IdProduct);

        if (success)
        {
            StatusMessage = "Товар успешно удален";
            await LoadProductsAsync();
        }
        else
        {
            StatusMessage = "Ошибка удаления товара";
        }
    }
    catch (Exception ex)
    {
        StatusMessage = $"Ошибка удаления товара: {ex.Message}";
    }
    finally
    {
        IsLoading = false;
    }
}

// 🔄 Обновление товара
[RelayCommand]
private async Task RefreshProducts()
{
    SearchText = string.Empty;
    await LoadProductsAsync();
}
```

### 🎨 4. View для редактирования товара

#### **ProductEditWindow.axaml:**
```xml
<Window xmlns="https://github.com/avaloniaui"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:vm="clr-namespace:ShoeShopGUI.ViewModels"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        mc:Ignorable="d" d:DesignWidth="600" d:DesignHeight="700"
        x:Class="ShoeShopGUI.Views.ProductEditWindow"
        x:DataType="vm:ProductEditViewModel"
        Title="{Binding IsNewProduct, Converter={x:Static StringConverters.IsNotNull},
                         ConverterParameter='Новый товар|Редактирование товара'}"
        Width="600" Height="700"
        WindowStartupLocation="CenterScreen">

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Шапка -->
        <Border Grid.Row="0" Background="#2E7D32" Padding="20,15">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="{Binding IsNewProduct, Converter={x:Static StringConverters.IsNotNull},
                                           ConverterParameter='➕|📝'}"
                          FontSize="24" Margin="0,0,10,0" VerticalAlignment="Center"/>
                <TextBlock Text="{Binding IsNewProduct, Converter={x:Static StringConverters.IsNotNull},
                                           ConverterParameter='Создание нового товара|Редактирование товара'}"
                          FontSize="18" FontWeight="Bold"
                          Foreground="White" VerticalAlignment="Center"/>
            </StackPanel>
        </Border>

        <!-- Основная форма -->
        <ScrollViewer Grid.Row="1" Padding="20">
            <StackPanel Spacing="15">
                <!-- Основная информация -->
                <Border Background="White" CornerRadius="8" Padding="15" BoxShadow="0 2 4 rgba(0,0,0,0.1)">
                    <TextBlock Text="📋 Основная информация" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,10"/>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Spacing="10" Margin="0,0,10,0">
                            <StackPanel>
                                <TextBlock Text="Артикул:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                                <TextBox Text="{Binding Product.ArticleNumber}" Height="35"/>
                            </StackPanel>

                            <StackPanel>
                                <TextBlock Text="Название товара:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                                <TextBox Text="{Binding Product.ProductName}" Height="35"/>
                            </StackPanel>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Spacing="10" Margin="10,0,0,0">
                            <StackPanel>
                                <TextBlock Text="Цена:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                                <NumericUpDown Value="{Binding Product.Price}" Minimum="0" Maximum="999999" Height="35"/>
                            </StackPanel>

                            <StackPanel>
                                <TextBlock Text="Скидка (%):" FontWeight="SemiBold" Margin="0,0,0,3"/>
                                <NumericUpDown Value="{Binding Product.DiscountPercent}" Minimum="0" Maximum="100" Height="35"/>
                            </StackPanel>
                        </StackPanel>
                    </Grid>

                    <StackPanel Margin="0,10,0,0">
                        <TextBlock Text="Описание:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                        <TextBox Text="{Binding Product.Description}" Height="80" TextWrapping="Wrap"
                                AcceptsReturn="True" VerticalAlignment="Top"/>
                    </StackPanel>
                </Border>

                <!-- Классификация -->
                <Border Background="White" CornerRadius="8" Padding="15" BoxShadow="0 2 4 rgba(0,0,0,0.1)">
                    <TextBlock Text="🏷️ Классификация" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,10"/>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Margin="0,0,10,0">
                            <TextBlock Text="Категория:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <ComboBox ItemsSource="{Binding Categories}"
                                     SelectedItem="{Binding Product.Category}"
                                     DisplayMemberBinding="{Binding CategoryName}"
                                     Height="35"/>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Margin="5,0">
                            <TextBlock Text="Производитель:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <ComboBox ItemsSource="{Binding Manufacturers}"
                                     SelectedItem="{Binding Product.Manufacturer}"
                                     DisplayMemberBinding="{Binding ManufacturerName}"
                                     Height="35"/>
                        </StackPanel>

                        <StackPanel Grid.Column="2" Margin="10,0,0,0">
                            <TextBlock Text="Поставщик:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <ComboBox ItemsSource="{Binding Suppliers}"
                                     SelectedItem="{Binding Product.Supplier}"
                                     DisplayMemberBinding="{Binding SupplierName}"
                                     Height="35"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Склад и статус -->
                <Border Background="White" CornerRadius="8" Padding="15" BoxShadow="0 2 4 rgba(0,0,0,0.1)">
                    <TextBlock Text="📦 Склад и статус" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,10"/>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Margin="0,0,10,0">
                            <TextBlock Text="Количество:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <NumericUpDown Value="{Binding Product.StockQuantity}" Minimum="0" Maximum="999999" Height="35"/>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Margin="5,0">
                            <TextBlock Text="Единица:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <TextBox Text="{Binding Product.Unit}" Height="35"/>
                        </StackPanel>

                        <StackPanel Grid.Column="2" Margin="10,0,0,0">
                            <TextBlock Text="Статус:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                            <ComboBox SelectedItem="{Binding Product.AvailabilityStatus}" Height="35">
                                <ComboBoxItem Content="В наличии"/>
                                <ComboBoxItem Content="Под заказ"/>
                                <ComboBoxItem Content="Нет в наличии"/>
                                <ComboBoxItem Content="Снято с производства"/>
                            </ComboBox>
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Изображение -->
                <Border Background="White" CornerRadius="8" Padding="15" BoxShadow="0 2 4 rgba(0,0,0,0.1)">
                    <TextBlock Text="🖼️ Изображение" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,10"/>
                    <StackPanel>
                        <TextBlock Text="URL изображения:" FontWeight="SemiBold" Margin="0,0,0,3"/>
                        <TextBox Text="{Binding Product.PhotoUrl}" Height="35"/>
                        <TextBlock Text="Пример: photo.jpg" FontSize="12" Foreground="#666" Margin="3,3,0,0"/>
                    </StackPanel>
                </Border>
            </StackPanel>
        </ScrollViewer>

        <!-- Кнопки действий -->
        <Border Grid.Row="2" Background="#F5F5F5" Padding="20,15">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Статус -->
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="{Binding StatusMessage}" Foreground="#666" FontSize="12"/>
                    <ProgressBar IsIndeterminate="{Binding IsLoading}"
                                IsVisible="{Binding IsLoading}"
                                Margin="0,5,0,0" Height="3"/>
                </StackPanel>

                <!-- Кнопки -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" Spacing="10">
                    <Button Content="🔄 Сбросить"
                            Command="{Binding ResetFormCommand}"
                            Height="35" MinWidth="100"
                            Background="#FFA726"/>

                    <Button Content="❌ Отмена"
                            Command="{Binding CancelCommand}"
                            Height="35" MinWidth="100"
                            Background="#757575"/>

                    <Button Content="💾 Сохранить"
                            Command="{Binding SaveProductCommand}"
                            Height="35" MinWidth="120"
                            Background="#4CAF50" Foreground="White"
                            IsEnabled="{Binding IsLoading, Converter={x:Static ObjectConverters.IsNotNullToBooleanConverter}}"/>
                </StackPanel>
            </Grid>
        </Border>
    </Grid>
</Window>
```

---

## 🎯 Рекомендации по разработке

### 🔧 Конфигурация проекта

#### **appsettings.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=shoe_store;Uid=shopuser;Pwd=shopuser123;"
  },
  "Application": {
    "Name": "Обувной магазин",
    "Version": "1.0.0 (Avalonia UI)",
    "MaxSearchResults": 100,
    "ImageFolderPath": "./Assets/"
  }
}
```

#### **Program.cs:**
```csharp
using Avalonia;
using Avalonia.Controls;
using Avalonia.Markup.Xaml;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using ShoeShopGUI.Services;
using ShoeShopGUI.Views;

namespace ShoeShopGUI
{
    class Program
    {
        [STAThread]
        public static void Main(string[] args) => BuildAvaloniaApp()
            .StartWithClassicDesktopLifetime(args);

        public static AppBuilder BuildAvaloniaApp()
            => AppBuilder.Configure<App>()
                .UsePlatformDetect()
                .LogToTrace()
                .UseReactiveUI();

        public static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            services.AddSingleton<DatabaseServiceSimple>();
            services.AddSingleton<IConfiguration>(configuration);
        }
    }
}
```

### 🛡️ Рекомендации по безопасности

1. **Хеширование паролей:**
```csharp
// Используйте BCrypt или similar для хеширования
public string HashPassword(string password)
{
    return BCrypt.Net.BCrypt.HashPassword(password);
}

public bool VerifyPassword(string password, string hash)
{
    return BCrypt.Net.BCrypt.Verify(password, hash);
}
```

2. **Параметризированные запросы:** Всегда используйте параметры для защиты от SQL инъекций.

3. **Валидация входных данных:**
```csharp
private bool ValidateProductInput(Product product)
{
    return !string.IsNullOrWhiteSpace(product.ProductName) &&
           product.Price > 0 &&
           product.StockQuantity >= 0;
}
```

### 📝 Лучшая практика MVVM

1. **Разделение ответственности:** View только для отображения, ViewModel для логики, Model для данных.

2. **Использование ObservableCollection для списков:**
```csharp
[ObservableProperty]
private ObservableCollection<Product> _products = new();
```

3. **Асинхронные операции:** Всегда используйте async/await для операций с базой данных.

### 🎨 UI/UX Рекомендации

1. **Загрузка данных:** Показывайте прогресс-бары во время загрузки.

2. **Обработка ошибок:** Дружелюбные сообщения об ошибках для пользователя.

3. **Валидация:** Проверяйте данные перед сохранением в базу.

4. **Отзывчивость:** Используйте BackgroundWorker или async для долгих операций.

### 🔄 Тестирование

1. **Юнит-тесты для ViewModel:**
```csharp
[Test]
public async Task SearchProducts_ValidText_ReturnsFilteredProducts()
{
    // Arrange
    var mockDatabase = new Mock<IDatabaseService>();
    var viewModel = new MainWindowViewModel(mockDatabase.Object);

    // Act
    viewModel.SearchText = "ботинки";
    await viewModel.SearchProductsCommand.ExecuteAsync(null);

    // Assert
    Assert.IsNotEmpty(viewModel.Products);
}
```

2. **Интеграционные тесты для DatabaseService:**
```csharp
[Test]
public async Task CreateProduct_ValidProduct_ReturnsTrue()
{
    // Arrange
    var databaseService = new DatabaseServiceSimple(configuration);
    var product = new Product { /* инициализация */ };

    // Act
    var result = await databaseService.CreateProductAsync(product);

    // Assert
    Assert.IsTrue(result);
}
```

---

## 📝 Заключение

### **Модуль 2** предоставляет:
- ✅ Простую и интуитивную навигацию
- ✅ Базовый просмотр каталога
- ✅ Аутентификацию с ролевым доступом
- ✅ Отображение товаров с фотографиями

### **Модуль 3** добавляет:
- ✅ Мощные возможности поиска и фильтрации
- ✅ Полные CRUD операции для администраторов
- ✅ Управление справочниками
- ✅ Сортировку и статистику

### **Ключевые преимущества архитектуры:**
- **Масштабируемость:** Легко добавлять новые функции
- **Тестируемость:** Разделение на слои
- **Поддерживаемость:** Чистый код и архитектура
- **Кроссплатформенность:** Работает на Windows, macOS, Linux

---

*📅 Дата создания: 20.11.2024*
*👤 Автор: Claude Code Assistant*
*🛠️ Технологии: C# .NET 8.0, Avalonia UI, MySQL, MVVM*
