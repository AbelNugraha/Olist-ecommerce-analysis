--C. Fase 1: produk dan seller
	--1. Kategori apa dengan review terendah?
select pcnt.product_category_name_english as "Kategori",
	AVG(oord.review_score ) as "Rata Rata Review",
	PERCENTILE_CONT(0.5) within group(
		order by
			oord.review_score
	) as "Median Review"
from olist_order_items_dataset ooid 
	join olist_products_dataset opd on ooid.product_id = opd.product_id 
	join olist_order_reviews_dataset oord on ooid.order_id = oord.order_id 
	join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
group by "Kategori"
order by "Rata Rata Review", "Median Review";

	--2. Apakah harga berkorelasi dengan volume penjualan?
select pcnt.product_category_name_english as "Kategori",
	AVG(ooid.price) as "Rata Rata Harga",
	PERCENTILE_CONT(0.5) within group(
		order by
			ooid.price
	)as "Median Harga",
	count(*) as "Total Terjual"
from olist_products_dataset opd 
	join olist_order_items_dataset ooid on opd.product_id = ooid.product_id 
	join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
group by "Kategori"
order by "Rata Rata Harga", "Median Harga";

	--3. Seller mana yang paling banyak review buruk?
with SellerReview as(
	select ooid.seller_id as "Seller",
		count(distinct ooid.order_id) as "Total Review",
		count(distinct ooid.order_id ) filter (where oord.review_score <= 3) as "Total Review Buruk"
	from olist_order_items_dataset ooid 
		join olist_order_reviews_dataset oord on ooid.order_id = oord.order_id
	group by "Seller"
)
select "Seller",
	"Total Review",
	"Total Review Buruk",
	round(100.0 * "Total Review Buruk" / "Total Review", 2) as "Persentase Review Buruk"
from SellerReview
where "Total Review" >= 30
order by "Persentase Review Buruk" desc;

	--4. Apakah keterlambatan menjelaskan review buruk di level seller?
with OrderSeller as (
	select distinct ooid.order_id,
		ooid.seller_id
	from olist_order_items_dataset ooid
),
TabelReview as(
	select os.seller_id,
		os.order_id,
		oord.review_score,
		case
			when ood.order_estimated_delivery_date::date < ood.order_delivered_customer_date::date
				then 'Terlambat'
			else 'Tepat Waktu'
		end as "Status"
	from OrderSeller os
		join olist_order_reviews_dataset oord on os.order_id = oord.order_id
		join olist_orders_dataset ood on os.order_id = ood.order_id
	where ood.order_delivered_customer_date is not null 
	and ood.order_estimated_delivery_date is not null
)
select tr.seller_id as "Seller",
	tr."Status",
	round(AVG(tr.review_score), 2) as "Rata Rata Skor",
	count(distinct tr.order_id) as "Total Terjual"
from TabelReview tr 
group by "Seller" ,"Status"
having count(distinct tr.order_id) >=5
order by "Seller", "Status";

	--5. seller yang review buruk meski pengiriman tepat waktu
with OrderSeller as(
	select distinct ooid.order_id,
		ooid.seller_id
	from olist_order_items_dataset ooid
),
TabelReview as(
	select os.seller_id as "Seller",
		case 
			when ood.order_estimated_delivery_date::date < ood.order_delivered_customer_date
				then 'Terlambat'
			else 'Tepat Waktu'
		end as "Status",
		round(AVG(oord.review_score), 2) as "Rata Rata Skor",
		count(distinct os.order_id) as "Jumlah Order"
	from OrderSeller os
		join olist_orders_dataset ood on os.order_id = ood.order_id
		join olist_order_reviews_dataset oord on os.order_id = oord.order_id
	where ood.order_delivered_customer_date is not null
		and ood.order_estimated_delivery_date is not null
	group by "Seller", "Status"
	having count(distinct os.order_id) > 5
)
select *
from TabelReview tr
where tr."Status" = 'Tepat Waktu'
	and tr."Rata Rata Skor" <= 3.8
order by tr."Rata Rata Skor" desc;

	--6. Persentase review buruk seller tepat waktu
with review_order as (
	select order_id, avg(review_score) as skor
	from olist_order_reviews_dataset
	group by order_id
),
order_seller as (
	select distinct order_id, seller_id from olist_order_items_dataset
)
select left(os.seller_id, 8) as seller,
	count(*) as jumlah_order_tepat_waktu,
	round(100.0 * count(*) filter (where r.skor <= 3) / count(*), 2) as persen_review_buruk
from order_seller os
	join olist_orders_dataset o on os.order_id = o.order_id
	join review_order r on os.order_id = r.order_id
where o.order_status not in ('canceled', 'unavailable')
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date::date <= o.order_estimated_delivery_date::date
group by os.seller_id
having count(*) >= 30
order by persen_review_buruk desc
limit 10;

with review_order as (
	select order_id, round(avg(review_score))::int as skor
	from olist_order_reviews_dataset
	group by order_id
),
dasar as (
	select o.order_id,
		case
			when o.order_delivered_customer_date::date <= o.order_estimated_delivery_date::date then '0. Tepat waktu'
			when o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date <= 3 then '1. Telat 1-3 hari'
			when o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date <= 7 then '2. Telat 4-7 hari'
			else '3. Telat lebih dari 7 hari'
		end as kelompok
	from olist_orders_dataset o
	where o.order_status not in ('canceled', 'unavailable')
		and o.order_delivered_customer_date is not null
		and o.order_estimated_delivery_date is not null
)
select d.kelompok, r.skor, count(*) as jumlah_order
from dasar d
	join review_order r on d.order_id = r.order_id
group by d.kelompok, r.skor
order by d.kelompok, r.skor;