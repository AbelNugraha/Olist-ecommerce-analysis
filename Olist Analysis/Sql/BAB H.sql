--G. Cohort Analysis
with AwalOrderKustomer as(
	select ocd.customer_unique_id,
		MIN(ood.order_purchase_timestamp::date) as "Tanggal Awal Order"
	from olist_customers_dataset ocd 
		join olist_orders_dataset ood on ocd.customer_id = ood.customer_id
	where ood.order_status != 'canceled' and ood.order_status != 'unavailable'
	group by ocd.customer_unique_id
),
UmurOrder as(
	select aok.customer_unique_id as "Kustomer",
		to_char(aok."Tanggal Awal Order", 'YYYY-MM') as "Cohort",
		ood.order_purchase_timestamp::date,
		(extract(year from ood.order_purchase_timestamp) * 12 + extract(month from ood.order_purchase_timestamp))
		- (extract(year from aok."Tanggal Awal Order") * 12 + extract(month from aok."Tanggal Awal Order")) as "Umur"
	from olist_customers_dataset ocd
		join olist_orders_dataset ood on ocd.customer_id = ood.customer_id
		join AwalOrderKustomer aok on ocd.customer_unique_id = aok.customer_unique_id
	where ood.order_status != 'canceled' and ood.order_status != 'unavailable'
),
KustomerPerCohort as(
	select "Cohort",
		"Umur",
		count(distinct "Kustomer") as "Jumlah Kustomer"
	from UmurOrder
	group by "Cohort", "Umur"
)
select "Cohort",
	"Umur",
	"Jumlah Kustomer",
	max("Jumlah Kustomer") over (partition by "Cohort") as "Total Kustomer",
	round(100.0 * "Jumlah Kustomer" / max("Jumlah Kustomer") over (partition by "Cohort"), 2) as "Retensi"
from KustomerPerCohort
where "Cohort" between '2017-01' and '2018-08'
order by "Cohort", "Umur";

	--2. Apakah customer yang pengalaman order pertamanya buruk lebih jarang kembali belanja?
with valid as (
	select o.order_id, c.customer_unique_id as cust, o.order_purchase_timestamp as ts,
		o.order_delivered_customer_date as tiba, o.order_estimated_delivery_date as estimasi
	from olist_orders_dataset o
		join olist_customers_dataset c on o.customer_id = c.customer_id
	where o.order_status not in ('canceled', 'unavailable')
),
urut as (
	select v.*,
		row_number() over (partition by cust order by ts, order_id) as nomor,
		min(date_trunc('month', ts)) over (partition by cust) as bulan_pertama,
		max(date_trunc('month', ts)) over (partition by cust) as bulan_terakhir
	from valid v
),
review_order as (
	select order_id, round(avg(review_score))::int as skor
	from olist_order_reviews_dataset
	group by order_id
),
pertama as (
	select u.cust, r.skor,
		(u.bulan_terakhir > u.bulan_pertama) as kembali,
		case when u.tiba is null then null
		     when u.tiba::date > u.estimasi::date then 'Terlambat'
		     else 'Tepat waktu' end as status_kirim
	from urut u
		left join review_order r on u.order_id = r.order_id
	where u.nomor = 1
		and u.ts >= '2017-01-01' and u.ts < '2018-03-01'
		and u.tiba is not null 
		and r.skor is not null
)
select 'Pengiriman order pertama' as dimensi, status_kirim as kelompok,
	count(*) as jumlah_customer,
	round(100.0 * count(*) filter (where kembali) / count(*), 2) as persen_kembali
from pertama
where status_kirim is not null
group by status_kirim
union all
select 'Skor review order pertama', skor::text,
	count(*),
	round(100.0 * count(*) filter (where kembali) / count(*), 2)
from pertama
where skor is not null
group by skor
order by 1, 2;