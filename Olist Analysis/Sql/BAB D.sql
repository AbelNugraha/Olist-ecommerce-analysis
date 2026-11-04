--D. Fase 2: tren waktu
	--1. Bulan apa yang selalu ramai?
select to_char(ood.order_purchase_timestamp, 'Month') as "Bulan",
	count(distinct ood.order_id) as "Jumlah Pembelian",
	count(distinct to_char(ood.order_purchase_timestamp, 'YYYY-MM')) as "Jumlah Periode",
	round(count(distinct ood.order_id)::numeric
		/ count(distinct to_char(ood.order_purchase_timestamp, 'YYYY-MM'))) as "Rata Rata Penjualan"
from olist_orders_dataset ood
group by "Bulan"
order by "Jumlah Pembelian" desc;

	--2. Berapa growth revenue tahun ke tahun?
with RevenueTahunan as(
	select to_char(ood.order_purchase_timestamp, 'YYYY') as "Tahun",
		count(distinct ood.order_id) "Total Order",
		SUM(ooid.price) as "Total Harga"
	from olist_orders_dataset ood 
		join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
	where ood.order_status not in('canceled', 'unavailable')
	group by "Tahun"
)
select "Tahun",
	"Total Order",
	"Total Harga",
	round(
		(("Total Harga" - lag("Total Harga") over(order by "Tahun"))* 100.0
		/ lag("Total Harga") over (order by "Tahun")
	)::numeric, 2) as "Revenue"
from RevenueTahunan
order by "Tahun";

	--3. Hari apa paling ramai?
select to_char(ood.order_purchase_timestamp, 'Day') as "Hari",
	count(*) as "Total Order"
from olist_orders_dataset ood
group by "Hari"
order by "Total Order" desc;