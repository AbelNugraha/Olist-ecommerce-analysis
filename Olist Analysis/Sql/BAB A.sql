--A. Eksplorasi dasar
	--1. Berapa total order?
select count(order_id) from olist_orders_dataset ood;

	--2. Data mencakup rentang waktu kapan?
select date(MIN(ood.order_purchase_timestamp)) as TanggalAwal,
	date(MAX(ood.order_purchase_timestamp)) as TanggalAkhir
from olist_orders_dataset ood;

	--3. Status order apa saja yang ada?
select distinct(ood.order_status ) as "Status Order"
from olist_orders_dataset ood;

	--4. Berapa revenue per bulan?
select to_char(ood.order_purchase_timestamp, 'YYYY-MM') as "Bulan",
	SUM(ooid.price) as "Revenue",
	count(distinct ooid.order_id) as "Total Terjual"
from olist_orders_dataset ood
	join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
where ood.order_status != 'canceled' and ood.order_status != 'unavailable'
group by "Bulan"
order by "Bulan";

	--5. KPI
select sum(oi.price)::numeric(14,2) as total_revenue,
	count(distinct oi.order_id) as total_order,
	count(*) as total_item,
	round(sum(oi.price)::numeric / count(distinct oi.order_id), 2) as rata_nilai_order
from olist_order_items_dataset oi
join olist_orders_dataset o on oi.order_id = o.order_id
where o.order_status not in ('canceled', 'unavailable');`1