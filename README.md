# Analisis E-Commerce Olist: SQL (PostgreSQL) dan Dashboard Power BI

Proyek latihan analisis data pada dataset publik Olist, sebuah marketplace di Brasil. Datanya mencakup sekitar 99 ribu order (2016-2018). Hasilnya berupa kumpulan query SQL dan dashboard Power BI tiga halaman yang menjawab tiga pertanyaan: bagaimana kinerja bisnisnya, apakah keterlambatan pengiriman merusak kepuasan pelanggan, dan apakah pelanggan kembali belanja.

## Temuan utama

1. **Revenue bulanan naik dari sekitar 0,12 juta (Jan 2017) ke sekitar 1,0 juta (Nov 2017), lalu bertahan di kisaran 0,84-0,99 juta sepanjang 2018** (Real Brasil).
2. **Makin lama telat, makin rendah review.** Review rata-rata 4,29 pada order tepat waktu dan 1,70 pada order yang telat lebih dari 7 hari. Persentase review buruk (skor 1-3) naik dari 17,34% ke 88,24%.
3. **96,96% customer hanya belanja sekali.** Pada tiap cohort, kurang dari 1% customer kembali di bulan tertentu, sehingga pertumbuhan platform sangat bergantung pada customer baru.

Semua temuan di atas adalah hubungan pada data observasi, bukan bukti sebab-akibat (lihat bagian Batasan).

## Pertanyaan bisnis

| Halaman dashboard | Pertanyaan |
|---|---|
| 1. Kinerja Bisnis | Bagaimana kinerja bisnis Olist? |
| 2. Pengiriman dan Kepuasan | Apakah keterlambatan pengiriman menurunkan kepuasan pelanggan? |
| 3. Retensi Pelanggan | Apakah pelanggan kembali belanja, dan apakah pengalaman order pertama berhubungan dengan itu? |

## Data

- **Sumber:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Tabel yang dipakai:** orders, order_items, customers, products, sellers, order_reviews, order_payments, product_category_name_translation
- **Periode:** September 2016 sampai Oktober 2018. Data 2016 dan sesudah Agustus 2018 sangat sedikit, sehingga analisis utama berfokus pada Januari 2017 sampai Agustus 2018.
- **Mata uang:** Real Brasil.
- **Alat:** PostgreSQL (DBeaver) untuk query, Power BI Desktop untuk dashboard.

## Aturan dan definisi

| Istilah | Definisi |
|---|---|
| Order valid | Status order bukan `canceled` dan bukan `unavailable` |
| Item vs order | Item adalah satu baris di `order_items`. Order dihitung dengan `COUNT(DISTINCT order_id)`, karena satu order bisa berisi beberapa item |
| Customer | `customer_unique_id`. `customer_id` unik per order, jadi tidak dipakai untuk menghitung orang |
| Terlambat | Tanggal tiba lebih besar dari tanggal estimasi, dibandingkan per tanggal (jam diabaikan) |
| Kelompok keterlambatan | Tepat waktu, telat 1-3 hari, telat 4-7 hari, telat lebih dari 7 hari |
| Review | Melekat pada order. Jika satu order punya beberapa review, skornya dirata-ratakan per order sebelum digabung. Review buruk adalah skor 1-3 |
| Cohort | Bulan order pertama seorang customer |
| Umur cohort | Selisih bulan kalender (tahun x 12 + bulan) antara order dan bulan cohort |
| Kembali belanja | Ada order di bulan kalender setelah bulan order pertama |

Cakupan tiap visual di dashboard:
- Halaman 1: seluruh periode data, order valid.
- Halaman 2: order valid yang sudah tiba dan memiliki review (95.824 order).
- Halaman 3: heatmap untuk cohort 2017-01 sampai 2018-08; kartu untuk periode Jan 2017 - Agu 2018; grafik pengalaman order pertama untuk customer yang order pertamanya Jan 2017 - Feb 2018 (agar ada minimal sekitar enam bulan untuk kembali).

## Dashboard

![Kinerja Bisnis](Screenshots/01_Kinerja_Bisnis.png)
![Pengiriman dan Kepuasan](Screenshots/02_Pengiriman_dan_Kepuasan.png)
![Retensi Pelanggan](Screenshots/03_Retensi_Pelanggan.png)

File: `dashboard/Olist_Dashboard.pbix` dan versi PDF-nya.

### Halaman 1: Kinerja Bisnis

- Total revenue 13.494.400,74; total order 98.199; total item 112.101; rata-rata nilai order 137,42.
- São Paulo (SP) menyumbang 41.125 order (sekitar 42%). Tiga state teratas (SP, RJ, MG) sekitar 67% dari seluruh order.
- Kartu kredit dipakai pada sekitar 74% transaksi pembayaran (75.905 dari 102.573). Satu order bisa memiliki lebih dari satu transaksi pembayaran, sehingga angka ini adalah jumlah transaksi pembayaran, bukan jumlah order.
- Revenue 2018 (Jan-Agu, sementara) 20,18% di atas total revenue 2017 setahun penuh. Angka ini bukan pertumbuhan tahunan: 2018 hanya delapan bulan, sedangkan 2017 dua belas bulan.

### Halaman 2: Pengiriman dan Kepuasan

| Kelompok | Jumlah order | Rata-rata review | Review buruk |
|---|---|---|---|
| Tepat waktu | 89.443 | 4,29 | 17,34% |
| Telat 1-3 hari | 1.852 | 3,29 | 46,76% |
| Telat 4-7 hari | 1.748 | 2,11 | 77,46% |
| Telat lebih dari 7 hari | 2.781 | 1,70 | 88,24% |

- Order terlambat adalah 6.381 dari 95.824 order (sekitar 6,7%).
- Penurunan review konsisten di setiap kelompok keterlambatan.
- Bahkan pada order tepat waktu, 17,34% review tetap buruk, sehingga keterlambatan bukan satu-satunya faktor kepuasan.

### Halaman 3: Retensi Pelanggan

- Dari 94.697 customer pada periode analisis, 91.822 (96,96%) hanya belanja sekali.
- Pada heatmap cohort, retensi bulanan setelah bulan pertama berada di bawah 1% di semua cohort (nilai tertinggi sekitar 0,7%). Cohort Januari 2017 berukuran 752 customer, sehingga 0,13% berarti satu customer. Variasi warna yang tipis pada cohort awal tidak dapat ditafsirkan.
- Baris cohort terakhir (Agustus 2018) ditampilkan apa adanya. Nilainya sangat rendah karena data berakhir di bulan itu dan belum ada bulan pengamatan sesudahnya, bukan karena retensinya rendah.
- Pengalaman order pertama dan kembali belanja (54.818 customer):

| Kelompok | Jumlah customer | Persentase yang kembali |
|---|---|---|
| Order pertama tepat waktu | 51.238 | 2,58% |
| Order pertama terlambat | 3.580 | 1,84% |
| Skor review order pertama 1 | 5.418 | 1,96% |
| Skor 2 | 1.764 | 2,04% |
| Skor 3 | 4.798 | 2,25% |
| Skor 4 | 11.024 | 2,41% |
| Skor 5 | 31.814 | 2,74% |

  Customer dengan order pertama terlambat kembali sekitar 29% lebih jarang, dan bintang 5 sekitar 40% lebih sering daripada bintang 1. Dalam angka mutlak selisihnya kecil: lebih dari 97% customer tidak kembali apa pun pengalaman pertamanya.

## Analisis tambahan (SQL, tidak masuk dashboard)

- **RFM.** Customer disegmentasi berdasarkan Recency (hari sejak order terakhir), Frequency, dan Monetary. Karena hampir semua customer hanya belanja sekali, Frequency nyaris tidak membedakan; pemisahan yang berguna adalah antara pembeli sekali beli (dibagi dengan Recency dan Monetary) dan pembeli berulang. Pelajaran metodologis: skor NTILE dapat memotong nilai kembar ke skor berbeda, dan aturan segmen harus saling lepas supaya tidak ada keranjang "sisa" yang besar.
- **Customer sekali beli dengan nilai order di atas rata-rata per order.** Sebanyak 27.220 customer pada hitungan awal.
- **Review per kategori produk.** Kategori dengan rata-rata review terendah pada hasil awal (level item, tanpa filter status): security_and_services (2,5), diapers_and_hygiene (3,26), office_furniture (3,49). Sebagian kategori berukuran sampel kecil.
- **Harga dan volume penjualan per kategori.** Dihitung dengan median harga dan volume per produk. Lima kategori teratas punya median harga yang mirip (sekitar 65-82), sehingga hubungan harga dan volume belum terbukti; perlu scatter plot atau korelasi peringkat dari seluruh 71 kategori.
- **Ongkos kirim dan review.** Rata-rata review 4,08 pada ongkir sampai 100(Murah), 3,87 pada 100-200(Menengah), dan 3,64 pada 200-300(Mahal). Kelompok ongkir di atas 300 hanya berisi 13 record sehingga tidak disimpulkan. Rata-rata ongkir terendah ada di SP (15,15) dan lebih tinggi di state lain (misalnya GO 22,77).
- **Pola hari dan bulan.** Senin paling ramai (16.196 order) dan Sabtu paling sepi (10.887). Pola musiman tidak disimpulkan: bulan tertinggi bergantung pada satuan hitung (item atau order) dan cakupan tahun tiap bulan tidak seragam.
- **Seller.** Ada seller dengan persentase review buruk tinggi, dan sebagian seller tetap berreview rendah pada order yang tepat waktu. Atribusi ke seller tidak pasti karena review melekat pada order, dan tidak dibuat sebagai halaman dashboard.

## Batasan

- **Hubungan, bukan sebab-akibat.** Temuan tentang keterlambatan, review, dan retensi tidak mengendalikan faktor lain seperti jenis barang atau seller.
- **Review melekat pada order, bukan pada barang atau seller.** Untuk order multi-item atau multi-seller, skornya menempel ke semuanya.
- **Hanya pelanggan yang menulis review yang terhitung** pada analisis kepuasan.
- **Cakupan waktu.** Data 2016 dan sesudah Agustus 2018 tidak lengkap. Pertumbuhan 2018 bersifat sementara, dan waktu pengamatan customer untuk kembali belanja tidak seragam (customer awal punya hampir dua tahun, yang akhir sekitar enam bulan).
- **Definisi dipilih dan dicatat.** Terlambat dihitung per tanggal; dengan timestamp penuh, order yang tiba di hari estimasi tetapi lewat tengah malam akan terhitung terlambat, sehingga kelompok terlambat bisa sedikit berbeda.
- **Pembayaran dihitung per transaksi pembayaran**, bukan per order.

## Yang dipelajari

- JOIN satu-ke-banyak menggandakan baris. Hitungan harus mengikuti level yang benar (`COUNT(DISTINCT order_id)`), dan agregasi dilakukan dulu sebelum JOIN bila perlu.
- Rata-rata per kelompok bisa menyembunyikan variasi; tampilkan ukuran sampel di samping rata-rata.
- Pembanding harus setara level dengan yang dibandingkan (per order dengan per order).
- Cara memilih visual dan menulis judul sebagai temuan, serta menyatakan batasan analisis dengan jelas.

## Struktur repository (sesuaikan dengan isi foldermu)

```
.
├── README.md
├── Dashboard/
│   ├── Olist Dashboard.pbix
│   └── Olist Dashboard.pdf
├── Screenshots/
├── Sql/
│   └── (satu file .sql per analisis)
└── Data/        # tidak disertakan; unduh dari Kaggle
```

## Cara menjalankan ulang

1. Unduh dataset dari Kaggle dan buat database PostgreSQL.
2. Impor tiap CSV sebagai tabel dengan nama yang sama seperti file-nya. Pastikan kolom uang (`price`, `freight_value`, `payment_value`) bertipe `numeric`. Untuk `olist_order_reviews_dataset`, gunakan `\copy` dari `psql` karena kolom komentar memuat baris baru.
3. Jalankan skrip di folder `sql/`.
4. Ekspor hasilnya ke CSV, lalu muat ke Power BI Desktop (periksa tipe kolom desimal; gunakan locale English (United States) bila angka terbaca salah).

## Tentang saya

Abel Khalil Nugraha. Fresh graduate S1 Teknik Informatika, Universitas Dian Nuswantoro. [Email / LinkedIn / AbelNugraha]
