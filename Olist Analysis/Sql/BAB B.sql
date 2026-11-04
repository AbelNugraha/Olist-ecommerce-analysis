--B. Pertanyaan bisnis dasar
	--1. Kategori produk apa yang paling laku (jumlah unit)?
select pcnt.product_category_name_english as "Kategori",
	count(ooid.order_id) as "Total Terjual"
from olist_products_dataset opd 
	join olist_order_items_dataset ooid on opd.product_id = ooid.product_id
	join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
group by "Kategori"
order by "Total Terjual" desc;

	--2. State mana dengan order terbanyak?
select ocd.customer_state as "State",
	count(distinct ooid.order_id) as "Total Terjual"
from olist_customers_dataset ocd 
	join olist_orders_dataset ood on ocd.customer_id = ood.customer_id
	join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
where ood.order_status not in ('canceled', 'unavailable')
group by "State"
order by "Total Terjual" desc;

	--3. Siapa 10 customer yang paling sering belanja?
select ocd.customer_unique_id as "Kustomer",
	count(ood.order_id) as "Total Terjual"
from olist_customers_dataset ocd 
	join olist_orders_dataset ood on ocd.customer_id = ood.customer_id
group by "Kustomer"
order by "Total Terjual" desc
limit 10;

	--4. Metode pembayaran apa yang paling populer?
select oopd.payment_type as "Tipe Pembayaran",
	count(distinct ood.order_id) as "Jumlah"
from olist_order_payments_dataset oopd 
	join olist_orders_dataset ood on oopd.order_id = ood.order_id
where ood.order_status not in('canceled', 'unavailable')
group by "Tipe Pembayaran"
order by "Jumlah" desc;

	--5. Apakah keterlambatan pengiriman menurunkan review?
with review_order as (
	select order_id, avg(review_score) as "Skor"
	from olist_order_reviews_dataset
	group by order_id
),
order_valid as (
	select o.order_id,
		case
			when o.order_delivered_customer_date::date <= o.order_estimated_delivery_date::date then '0. Tepat waktu'
			when o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date <= 3 then '1. Telat 1-3 hari'
			when o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date <= 7 then '2. Telat 4-7 hari'
			else '3. Telat lebih dari 7 hari'
		end as "Kelompok"
	from olist_orders_dataset o
	where o.order_status not in ('canceled', 'unavailable')
		and o.order_delivered_customer_date is not null
		and o.order_estimated_delivery_date is not null
)
select v."Kelompok",
	count(*) as "Jumlah Order",
	round(avg(r."Skor")::numeric, 2) as "Rata Review",
	round(100.0 * count(*) filter (where r."Skor" <= 3) / count(*), 2) as "Persen Review Buruk"
from order_valid v
join review_order r on v.order_id = r.order_id
group by v."Kelompok"
order by v."Kelompok";