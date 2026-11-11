{% docs confirmed_order %}
Признак подтверждённой покупки: заказ не является тестовым, имеет статус `paid` и хотя бы одну успешную оплату (`paid_amount > 0`, возвраты оплатой не считаются).
{% enddocs %}

{% docs __overview__ %}
# Аналитический слой интернет-магазина в Greenplum (dbt)

Проект строит аналитические витрины по схеме звезда в хранилище Greenplum (`dwh`, схема `analytics_marts`) поверх сырых данных OLTP-базы (`raw`).

### Слои проекта:
- **Staging (`analytics_staging`)** представления (`view`) один-к-одному с таблицами источника.
- **Intermediate (`analytics_intermediate`)** расчёт агрегатов по платежам, позициям заказов и рекурсивное дерево категорий.
- **Marts (`analytics_marts`)** таблицы фактов (`fct_orders`, `fct_order_items`) и измерений (`dim_customers`, `dim_products`, `dim_dates`).

### Известные аномалии данных:
- Заказ `113`: сумма заказа `200.00`, но списано два успешных платежа по `200.00` (`paid_amount = 400.00`). Отслеживается тестом `assert_no_overpayment_on_confirmed_orders` со статусом `WARN`.
{% enddocs %}