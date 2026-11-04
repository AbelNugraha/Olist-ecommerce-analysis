--E. Fase 3: SQL lanjutan
	--1. Produk terlaris di tiap kategori
with KategoriPerProduk as(
	select pcnt.product_category_name_english as "Kategori",
		ooid.product_id as "Produk",
		count(*) as "Total Terjual"
	from olist_products_dataset opd
		join olist_order_items_dataset ooid on opd.product_id = ooid.product_id
		join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
	group by "Kategori", "Produk"
	order by "Kategori", "Total Terjual" desc
),
TabelRanking as(
	select "Kategori",
		"Produk",
		"Total Terjual",
		row_number() over(
			partition by "Kategori"
		) as "Ranking"
	from KategoriPerProduk
)
select *
from TabelRanking
where "Ranking" = 1;

	--2. Customer yang order sekali dengan nilai besar (churn)
with TotalPerOrder as(
	select ooid.order_id as "Order",
		SUM(ooid.price) as "Total Belanja per Order"
	from olist_order_items_dataset ooid
	group by ooid.order_id
),
CustomerOrder as(
	select ocd.customer_unique_id as "Kustomer",
		count(distinct ooid.order_id) as "Total Order",
		SUM(ooid.price) as "Total Belanja per Kustomer"
	from olist_orders_dataset ood
		join olist_customers_dataset ocd on ood.customer_id = ocd.customer_id
		join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
	group by "Kustomer"
)
select "Kustomer",
	"Total Order",
	"Total Belanja per Kustomer"
from CustomerOrder
where "Total Belanja per Kustomer" > (select avg("Total Belanja per Order") from TotalPerOrder)
	and "Total Order" = 1
order by "Total Belanja per Kustomer" desc;

	--3. Persentase Kustomer Sekali Beli
with KustomerInfo as(
	select ocd.customer_unique_id as "Kustomer",
		count(distinct ood.order_id) as "Total Order",
		to_char(MIN(ood.order_purchase_timestamp), 'YYYY-MM') as "Tanggal"
	from olist_customers_dataset ocd 
		join olist_orders_dataset ood on ocd.customer_id = ood.customer_id
	where ood.order_status not in ('canceled', 'unavailable')
	group by "Kustomer"
)
select count(*) as "Kustomer",
	count(*) filter (where "Total Order" = 1) as "Kustomer Sekali Beli",
	round(100.0 * count(*) filter (where "Total Order" = 1) / count(*), 2) as "Persentase Sekali Beli"
from KustomerInfo
where "Tanggal" between '2017-01' and '2018-08';

select count(distinct ocd.customer_unique_id) as "Kustomer"
from olist_customers_dataset ocd 
	join olist_orders_dataset ood on ocd.customer_id = ood.customer_id 
where ood.order_purchase_timestamp::date < '2017-01-01'
	and ood.order_status not in ('canceled', 'unavailable');