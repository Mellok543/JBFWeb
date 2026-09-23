# JBForsaken Web

Веб-портал для CS2 Jailbreak проекта JBForsaken.

## Структура

```text
JBFWeb/
├── backend/     Java 21 + Spring Boot + Spring MVC + JPA + Flyway
├── frontend/    Flutter Web
└── .github/     CI
```

Сборочные каталоги `target/`, `build/`, IDE-файлы и логи не хранятся в репозитории.

## Быстрый локальный запуск

Без Docker и MySQL, для разработки и проверки интерфейса:

```powershell
.\run-local.ps1
```

Скрипт поднимет Spring Boot с H2 на `5080` и Flutter Web на `5173`.

Для проверки именно MySQL:

```powershell
.\run-mysql.ps1
```

Этот вариант использует `docker-compose.yml` и MySQL 8.4.

## Backend

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

По умолчанию API работает на:

```text
http://127.0.0.1:5080
```

Основные endpoint'ы:

```text
GET  /api/server/status
GET  /api/server/players

GET  /api/news

GET  /api/store/products
GET  /api/store/orders
POST /api/store/orders

GET  /api/battlepass/current

GET  /api/clans
POST /api/clans

GET  /api/stats/top
GET  /api/stats/me

GET  /api/auth/me
GET  /api/auth/steam/login
POST /api/auth/exchange
```

Изменяющие запросы frontend отправляет с `Idempotency-Key`.

## Frontend

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
```

Frontend по умолчанию обращается к `http://127.0.0.1:5080`.

Другой backend:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=https://api.example.com
```

## Реализованные разделы

- Главная
- Играть / статус CS2
- Steam авторизация
- Профиль
- Магазин
- Battle Pass
- Кланы
- Топы
- Правила

## База данных

Backend рассчитан на MySQL и использует Flyway.

Таблицы сайта имеют префикс `jbf_web_`, чтобы не смешиваться с таблицами игровых плагинов.

Игровая статистика должна синхронизироваться в `jbf_web_player_stats` либо через отдельный интеграционный сервис, либо напрямую из серверных плагинов. Сайт не должен угадывать схему существующей игровой БД.

## Что ещё требуется для production

- выбранный платёжный провайдер;
- схема таблиц VIPCore / экономики / косметики;
- production domain + HTTPS;
- административная панель;
- фоновые задачи синхронизации серверной статистики;
- роли администрации и аудит административных действий.
