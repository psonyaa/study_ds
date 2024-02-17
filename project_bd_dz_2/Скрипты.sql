-- Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.
select distinct brand
from dz_transactions
where standard_cost > 1500;
--Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.
select *
from dz_transactions
where order_status = 'Approved'
  and split_part(transaction_date, '.', 3)::Int = 2017
  and split_part(transaction_date, '.', 2)::Int = 4
  and split_part(transaction_date, '.', 1)::Int >= 1
  and split_part(transaction_date, '.', 1)::Int <= 9;
-- Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.
select distinct job_title
from dz_customers
where job_industry_category in ('IT', 'Financial Services')
  and starts_with(job_title, 'Senior');
-- Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services
select distinct brand
from dz_transactions tr
         inner join dz_customers c on c.customer_id = tr.customer_id
where c.job_industry_category = 'Financial Services';
-- Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
select c.*
from dz_customers c
         inner join dz_transactions tr on tr.customer_id = c.customer_id
where tr.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
limit 10;
-- Вывести всех клиентов, у которых нет транзакций.
select c.*
from dz_customers c
         left join dz_transactions tr on tr.customer_id = c.customer_id
where tr is null;
-- Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.
select distinct c.*
from dz_customers c
         inner join dz_transactions tr on tr.customer_id = c.customer_id
where tr.standard_cost = (select max(standard_cost) from dz_transactions)
and c.job_industry_category = 'IT';
select * from dz_transactions where standard_cost = (select max(standard_cost) from dz_transactions);
-- Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.
select distinct c.*
from dz_customers c
         inner join dz_transactions tr on tr.customer_id = c.customer_id
where job_industry_category in ('IT', 'Health')
  and split_part(transaction_date, '.', 3)::Int = 2017
  and split_part(transaction_date, '.', 2)::Int = 7
  and split_part(transaction_date, '.', 1)::Int >= 7
  and split_part(transaction_date, '.', 1)::Int <= 17;