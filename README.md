# 🛒 E-Commerce Customer Behavior Analysis (RetailRocket Dataset)

## 📌 Project Overview
Bu proje, **e-ticaret müşteri davranışlarını** anlamak amacıyla geliştirilmiştir.  
Amaç; kullanıcıların **görüntüleme, sepete ekleme ve satın alma** davranışlarını analiz ederek, kampanya ve strateji geliştirmeye ışık tutacak **işlevsel içgörüler** elde etmektir.  


---

## 📂 Dataset
- Kaynak: [RetailRocket E-Commerce Dataset (Kaggle)](https://www.kaggle.com/code/johnosorio/retail-rocket-ecommerce-recommender-system/input)  
- İçerik: 2M+ event kaydı (4 aylık dönem)  
- Event türleri: `view`, `addtocart`, `transaction`

---

## 🛠️ Tools & Libraries
- **SQL Server** → büyük veriyi yükleme ve sorgulama  
- **Python** → görselleştirme ve bot otomasyonları  
- **Kütüphaneler:**  
  - `pandas`, `sqlalchemy` → veri işleme & SQL bağlantısı  
  - `matplotlib`, `seaborn`, `mpl_toolkits` → görselleştirme  
  - `os` → dosya yönetimi  

---

## 🔍 Analysis Steps
1. **Exploratory Data Analysis (EDA)** → genel kontrol, tablo büyüklükleri  
2. **Event Distribution** → 4 ayda kaç `view`, `addtocart`, `transaction` gerçekleşti?  
3. **Funnel Analysis** → `view → addtocart → transaction` geçiş oranları  
4. **Top 10 Bestseller** → en çok satan ürünler  
5. **Pareto Analysis** → satışların ürünlere göre dağılımı  
6. **Transaction Distribution by Range** → satış hacmine göre ürün grupları  
7. **Hourly Analysis** → günün saatlerine göre tüm eventler + sadece transaction yoğunluğu  
8. **Custom Visuals** → inset grafikli Pareto, sales range overlay grafiği  

---

## 📊 Key Findings
- **Event dağılımı:**  
  - %96.7 `view`, %2.5 `addtocart`, %0.8 `transaction`  
- **Funnel sonuçları:**  
  - Görüntülemeden sepete ekleme oranı: **%2.1**  
  - Sepetten satın almaya dönüşüm: **%29.1**  
  - Genel dönüşüm (view → transaction): **%0.6**  
- **Pareto:**  
  - Ürünlerin **%80’i sadece %20 satış getiriyor.**  
  - Satışların %34’ü yalnızca **tek sefer satılan ürünlerden** geliyor.  
- **Saatlik analiz:**  
  - En yoğun transaction saatleri: **18:00–21:00**  
  - En düşük transaction saatleri: **09:00–11:00**  

---

## 📂 Repository Structure
📦 retail-rocket-analysis
┣ 📂 plots/ # PNG görseller
┣ 📂 sql_queries/ # Tüm SQL sorguları (.sql)
┣ 📂 notebooks/ # Python analiz dosyaları (.ipynb)
┣ 📂 bots/ # SQL'den veri çekme & hızlı görselleştirme botları
┣ 📂 presentation/ # PowerPoint sunumu
┗ README.md


---## Not
Bu proje yalnızca portföy amacıyla paylaşılmıştır.  
İzin almadan **tamamen veya kısmen kopyalanması/kullanılması yasaktır**.  

© 2025 Ceren Ç

## 🙋 Author
- **Ceren Ç** – *Junior Data Analyst*  
- Katkılar: SQL veri hazırlama, Python bot geliştirme, veri analizi & görselleştirme, iş yorumlama  

