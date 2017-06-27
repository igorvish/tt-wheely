# Задача

> API для рассчета стоимости поездки и микросервис для получения времени/расстояния между заданными точками. Приложение API запрашивает время/расстояние у второго микросервиса, затем выполняет расчеты по тарифу.

# Развертывание

Приложение состоит из 3 компонентов, которые можно запустить в докере или нативно:

* redis - для кеширования гео-запросов.
* `routing-service` - сервис для рассчета расстояния/времени.
* `rate-service` - сервис для рассчета стоимости по указанному тарифу.

Запуск при помощи docker-compose:

```bash
docker-compose up
```

или нативно:

```bash
# start redis...
rackup config.ru -p 3001 -s Puma
rackup config.ru -p 3002 -s Puma
```

# Интерфейсы

**routing-service** (http://localhost:3001/route?from=...&to=...)

Принимает в GET-параметрах координаты точек from и to. Возвращает json с полями `distance_m` и `duration_s`. Пример:

```
curl "http://localhost:3001/route?from=34.1330949,-117.9143879&to=33.8068768,-118.3527671"
# {"status":"OK","error_message":null,"distance_m":71606,"duration_s":3429}
```

**rate-service** (http://localhost:3002/rate?from=...&to=...plan=...)

Принимает в GET-параметрах координаты точек from и to. Возвращает массив с тарифными планами (или с указанным планом) в виде "тариф, стоимость". Пример:

```
curl "http://localhost:3002/rate?from=34.1330949,-117.9143879&to=33.8068768,-118.3527671"
# [["base",2886],["balanced",1953],["by_kilometers",2886],["by_minute",1020]]
```

В <docs> есть postman-файл `tt-wheely.postman_collection.json` с запросами.

# Реализация

В задаче реализовано 2 микросервиса, адаптеры к гео-сервисам (Google Directions + кастомный для примера), кеширование гео-запросов, тарифная система.

Основные файлы проекта:

```
├── docker-compose.yml                      # docker-compose
├── docs
│   └── tt-wheely.postman_collection.json   # Postman-коллекция запросов
├── rate-service
│   ├── ...
│   ├── data
│   │   └── tariff_plans.yml                # Настройки тарифных планов
│   ├── lib
│   │   ├── rate                            # Модуль Rate и калькуляторы тарифных планов
│   │   │   └── calcs
│   │   │       ├── abstract_calc.rb
│   │   │       ├── avg_of_kilo_and_duration_calc.rb
│   │   │       └── plain_calc.rb
│   │   └── rate.rb
│   └── services
│       ├── base_service.rb
│       └── rate_service.rb                 # Service object обработки запроса на рассчет тарифа
├── routing-service
│   ├── ...
│   ├── forms
│   │   └── route_form.rb                   # Валидация запроса на геокодирование
│   ├── lib
│   │   ├── geo_router                      # Адаптеры к гео-сервисам
│   │   │   └── adapters
│   │   │       ├── abstract_adapter.rb
│   │   │       ├── dummy_adapter.rb
│   │   │       └── google_directions.rb
│   │   ├── geo_router.rb
│   └── services
│       ├── base_service.rb
│       └── routing_service.rb              # Service object выполняющий геокодирование-fallback-кеширование
└── ...
```

Сервисы реализованы на Sinatra. Протокол взаимодействия REST (альтернативой могли бы быть бинарные протоколы, e.g. thrift, protobuffs, messagepack etc). Кеширование в редис по ключам геохешей. Тарифы как функции, тарифные планы как настройки.

(Скорее всего на практике реализованное в задаче кеширование ну будет работать, из-за мальнькой вероятности повторения и из-за того что даже округление 100 метров может дать значимые ошибки в случае особенностей топологии местности или дорог. Вероятно это должна быть графовая система, которая будет кешировать в т.ч. сегменты.)
