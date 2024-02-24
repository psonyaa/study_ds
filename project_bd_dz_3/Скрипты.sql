--Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества. — (1 балл)
select job_industry_category, count(customer_id) as quantity
from dz_customers
group by job_industry_category
order by quantity DESC;
--Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности. — (1 балл)
select c.job_industry_category,
       split_part(tr.transaction_date, '.', 3) as year,
       split_part(tr.transaction_date, '.', 2) as month,
       sum(tr.list_price)
from dz_transactions tr
         inner join dz_customers c on tr.customer_id = c.customer_id
group by c.job_industry_category, year, month
order by year, month DESC;
--Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT. — (1 балл)
select tr.brand,
       count(tr.transaction_id)
from dz_transactions tr
         inner join dz_customers c on tr.customer_id = c.customer_id
where tr.online_order = true
  and tr.order_status = 'Approved'
group by tr.brand;
--Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, отсортировав результат по убыванию суммы транзакций и количества клиентов.
-- Выполните двумя способами: используя только group by и используя только оконные функции. Сравните результат. — (2 балла)
select c.customer_id,
       sum(t.list_price)       as sum,
       max(t.list_price)       as max,
       min(t.list_price)       as min,
       count(t.transaction_id) as count
from dz_customers c
         inner join dz_transactions t on t.customer_id = c.customer_id
group by c.customer_id
order by sum desc, count;
select c.customer_id,
       sum(t.list_price) over (partition by c.customer_id)       as sum,
       max(t.list_price) over (partition by c.customer_id)       as max,
       min(t.list_price) over (partition by c.customer_id)       as min,
       count(t.transaction_id) over (partition by c.customer_id) as count
from dz_customers c
         inner join dz_transactions t on t.customer_id = c.customer_id
order by sum desc, count;
--Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не может быть null).
-- Напишите отдельные запросы для минимальной и максимальной суммы. — (2 балла)
select c.first_name, c.last_name, sum(t.list_price) as max
from dz_customers c
         inner join dz_transactions t on t.customer_id = c.customer_id
group by c.customer_id
having sum(t.list_price) = (select sum(t.list_price) as sum
                            from dz_customers c
                                     inner join dz_transactions t on t.customer_id = c.customer_id
                            group by c.customer_id
                            order by sum asc
                            limit 1);

select c.first_name, c.last_name, sum(t.list_price) as min
from dz_customers c
         inner join dz_transactions t on t.customer_id = c.customer_id
group by c.customer_id
having sum(t.list_price) = (select sum(t.list_price) as sum
                            from dz_customers c
                                     inner join dz_transactions t on t.customer_id = c.customer_id
                            group by c.customer_id
                            order by sum asc
                            limit 1);
--Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. — (1 балл)
SELECT c.first_name, c.last_name, t.transaction_date, t.list_price
FROM (SELECT customer_id,
             transaction_date,
             list_price,
             ROW_NUMBER()
             OVER (PARTITION BY customer_id ORDER BY split_part(transaction_date, '.', 3)::int, split_part(transaction_date, '.', 2)::int, split_part(transaction_date, '.', 1)::int) as rn
      FROM dz_transactions) t
         JOIN dz_customers c ON c.customer_id = t.customer_id
WHERE t.rn = 1;
--Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях) — (2 балла).
SELECT c.first_name, c.last_name, c.job_title
FROM dz_customers c
         JOIN (SELECT customer_id, MAX(day_diff) as max_interval
               FROM (SELECT customer_id,
                            cleaned_date,
                            LEAD(cleaned_date) OVER (PARTITION BY customer_id ORDER BY cleaned_date) -
                            cleaned_date AS day_diff
                     FROM (SELECT customer_id,
                                  (split_part(transaction_date, '.', 3) || '-' ||
                                   split_part(transaction_date, '.', 2) || '-' ||
                                   split_part(transaction_date, '.', 1))::date as cleaned_date
                           from dz_transactions) as cleaned) sub
               GROUP BY customer_id) t1 ON c.customer_id = t1.customer_id
WHERE t1.max_interval = (SELECT MAX(max_interval)
                         FROM (SELECT MAX(day_diff) as max_interval
                               FROM (SELECT customer_id,
                                            cleaned_date,
                                            LEAD(cleaned_date)
                                            OVER (PARTITION BY customer_id ORDER BY cleaned_date) -
                                            cleaned_date AS day_diff
                                     FROM (SELECT customer_id,
                                                  (split_part(transaction_date, '.', 3) || '-' ||
                                                   split_part(transaction_date, '.', 2) || '-' ||
                                                   split_part(transaction_date, '.', 1))::date as cleaned_date
                                           from dz_transactions) as cleaned) sub
                               GROUP BY customer_id) t2);