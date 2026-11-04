--G. Freight
	--1. Rasio Ongkir terhadap Harga Barang per Kategori
select pcnt.product_category_name_english as "Kategori",
	SUM(ooid.freight_value) as "Total Freight",
	SUM(ooid.price) as "Total Harga",
	AVG(ooid.freight_value / ooid.price) as "Rasio Freight"
from olist_products_dataset opd 
	join olist_order_items_dataset ooid on opd.product_id = ooid.product_id
	join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
group by "Kategori"
order by "Rasio Freight" desc;

	--2. Ongkir vs review
with KelompokOngkir as(
	select distinct ooid.order_id as "Order",
		ooid.freight_value as "Ongkir",
		case
			when ooid.freight_value <= 100
				then 'Murah'
			when ooid.freight_value between 100.1 and 200
				then 'Menengah'
			when ooid.freight_value between 200.1 and 300
				then 'Mahal'
			when ooid.freight_value > 300
				then 'Sangat Mahal'
		end as "Kelompok Ongkir",
		oord.review_score as "Review"
	from olist_order_reviews_dataset oord
		join olist_order_items_dataset ooid on oord.order_id = ooid.order_id
)
select "Kelompok Ongkir",
	AVG("Review"),
	count(*) as "Total Order"
from KelompokOngkir
group by "Kelompok Ongkir";

	--3. Rata-rata ongkir per state pelanggan
select ocd.customer_state as "State",
	AVG(ooid.freight_value) "Rata Rata Ongkir"
from olist_orders_dataset ood 
	join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
	join olist_customers_dataset ocd on ood.customer_id = ocd.customer_id
group by "State"
order by "Rata Rata Ongkir";