--F. Eksplorasi lanjutan
	--1. RFM Analysis
with Referensi as (
	select MAX(order_purchase_timestamp::date) as "RefDate"
	from olist_orders_dataset ood
		join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
),
KustomerInfo as(
	select ocd.customer_unique_id as "Kustomer",
		count(distinct ood.order_id) as "Total Pesanan",
		SUM(ooid.price) as "Total Harga",
		(select "RefDate" from Referensi) - max(ood.order_purchase_timestamp::date) as "Lama Hari"
	from olist_orders_dataset ood
		join olist_customers_dataset ocd on ood.customer_id = ocd.customer_id
		join olist_order_items_dataset ooid on ood.order_id = ooid.order_id
	where ood.order_status != 'canceled' and ood.order_status != 'unavailable'
	group by "Kustomer"
),
RFM as(
	select "Kustomer",
		"Lama Hari",
		ceil(5 * cume_dist() over (order by "Lama Hari" desc))::int as "Recency",
		"Total Pesanan",
		case
			when "Total Pesanan" = 1
				then 1
			when "Total Pesanan" = 2
				then 2
			when "Total Pesanan" = 3
				then 3
			when "Total Pesanan" = 4
				then 4
			when "Total Pesanan" >= 5
				then 5
		end as "Frequency",
		"Total Harga",
		ntile(5) over(
			order by "Total Harga"
		) as "Monetary"
	from KustomerInfo
)
select "Kustomer",
	"Lama Hari",
	"Recency",
	"Total Pesanan",
	"Frequency",
	"Total Harga",
	"Monetary",
	concat("Recency", "Frequency", "Monetary")::numeric as "Total RFM",
	case 
		when "Recency" >= 4 and "Frequency" >= 3 and "Monetary" >= 4
			then 'Champions'
		when "Recency" >= 4 and "Frequency" >= 2
			then 'Loyal Customer'
		when "Recency" = 3 and "Frequency" >= 2
			then 'Need Attention'
		when "Recency" <= 2 and "Frequency" >= 2
			then 'At Risk'
		when "Recency" >= 4 and "Frequency" = 1
			then 'New Customer'
		when "Recency" = 3 and "Frequency" = 1
			then 'Almost Lost'
		when "Recency" <=2 and "Frequency" = 1 and "Monetary" >= 4
			then 'One-Time Big Spender'
		when "Recency" <=2 and "Frequency" = 1 and "Monetary" <= 3
			then 'Lost'
		else 'Unclasified'
	end as "RFM Status"
from RFM
order by "Total RFM" desc;