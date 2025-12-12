# Dostupnost základních potravin v České republice

Autor: **Petra Chapčáková**  
Kurz: Data Academy – SQL projekt  
Databáze: `data_academy_2025_04_24`, schéma `data_academy_content`

---

## Devlog / Patch notes

### 2025-12-12 – Refactor po zpětné vazbě (čitelnost a modularita)
- Původní odevzdání bylo funkčně správné, ale bylo vytvořeno jako **jeden ucelený SQL skript**, což zhoršovalo přehlednost.
- Na základě zpětné vazby byl projekt doplněn o **modulární variantu**:
  - každý `VIEW` má vlastní `.sql` soubor,
  - vytvoření **primární** a **sekundární** tabulky je oddělené,
  - analytické dotazy pro **Q1–Q5** jsou rozdělené do samostatných souborů.
- **Logika výpočtů ani výsledné tabulky se nezměnily** – změna je čistě organizační (struktura kódu).
- Úprava `README.md` souboru aby reflektoval přídavky 

Repozitář tedy obsahuje:
- původní “monolit” `petra_chapcakova_project.sql` (spustitelný odshora dolů),
- složku `sql/` s jednotlivými skripty (doporučeno pro kontrolu/čitelnost).

---

## 1. Cíl projektu

Cílem projektu je pomocí SQL zjistit, jak se v čase vyvíjí:

- průměrné mzdy v České republice (celkově i podle odvětví),
- ceny vybraných základních potravin,
- dostupnost těchto potravin z pohledu kupní síly (kolik jednotek lze koupit z průměrné mzdy),
- a jak tento vývoj souvisí s makroekonomickými ukazateli, zejména s růstem HDP.

Součástí zadání je zodpovědět pět výzkumných otázek a připravit dvě finální tabulky:

- **primární tabulka** pro Českou republiku (mzdy + ceny potravin),
- **sekundární tabulka** pro další evropské země (HDP, GINI, populace).

---

## 2. Použitá data

V projektu pracuji s následujícími tabulkami ze schématu `data_academy_content`:

- `czechia_payroll` – údaje o mzdách v ČR  
- `czechia_payroll_value_type` – typy mzdových ukazatelů  
- `czechia_payroll_industry_branch` – odvětví (CZ-NACE)  
- `czechia_price` – ceny vybraných potravin v čase  
- `czechia_price_category` – číselník kategorií potravin  
- `economies` – makroekonomická data (HDP, GINI, populace) pro jednotlivé státy  
- `countries` – číselník zemí (včetně příznaku kontinentu)

Pracuji pouze s národními průměry cen (řádky, kde `region_code IS NULL`) a s hodnotou mzdového ukazatele  
**„Průměrná hrubá mzda na zaměstnance“**.

---

## 3. Postup zpracování

Celý postup je zapsaný v souboru **`petra_chapcakova_project.sql`**. Skript lze spustit odshora dolů; provede následující kroky:

### 3.1 Pomocné pohledy (VIEW)

1. `v_petra_chapcakova_payroll_year`  
   – roční průměrná hrubá mzda za ČR + meziroční změna (`wage_yoy_pct`).

2. `v_petra_chapcakova_price_year`  
   – roční průměrná cena potravin podle kategorie + meziroční změna (`price_yoy_pct`).

3. `v_petra_chapcakova_payroll_industry_year`  
   – průměrná hrubá mzda podle odvětví a roku + meziroční změna.

4. `v_petra_chapcakova_cz_gdp_year`  
   – HDP ČR podle roku, včetně meziroční změny (`gdp_yoy_pct`).

Později, po vytvoření primární tabulky, vznikají ještě:

5. `v_petra_chapcakova_food_wage_year`  
   – „index cen potravin“ (průměr `price_yoy_pct`) + růst mezd za jednotlivé roky.

6. `v_petra_chapcakova_macro_vs_food_wage`  
   – spojení růstu HDP, indexu cen potravin a růstu mezd podle roku.

### 3.2 Finální tabulky

1. **Primární tabulka ČR**  
   `t_petra_chapcakova_project_sql_primary_final`  
   Obsahuje pro každý rok a potravinovou kategorii:

   - `year` – rok  
   - `category_code`, `category_name` – kód a název potraviny  
   - `price_unit` – jednotka (kg, l, ks, …)  
   - `avg_price` – průměrná cena v daném roce  
   - `price_yoy_pct` – meziroční změna ceny v %  
   - `avg_gross_wage` – průměrná hrubá mzda v ČR  
   - `wage_yoy_pct` – meziroční změna mzdy v %  
   - `units_from_avg_wage` – kolik jednotek dané potraviny lze koupit za průměrnou mzdu

2. **Sekundární tabulka – evropské státy**  
   `t_petra_chapcakova_project_sql_secondary_final`  
   Obsahuje pro evropské země (mimo ČR) v obdobném časovém rozsahu:

   - `country`, `year`  
   - `gdp`, `gdp_yoy_pct` – HDP a jeho meziroční změna  
   - `population` – počet obyvatel  
   - `gini` – GINI koeficient

### 3.3 Analytické dotazy

Ve spodní části skriptu jsou samostatné dotazy (SELECT) pro zodpovězení otázek Q1–Q5.  
Dotazy využívají výše uvedené pohledy a finální tabulky.

---

## 4. Jak skript spustit

### Varianta A (původní monolit)
1. Připojit se k databázi `data_academy_2025_04_24` (PostgreSQL).  
2. Spustit soubor `petra_chapcakova_project.sql` odshora dolů.

### Varianta B (modulární skripty – doporučeno)
1. Připojit se k databázi `data_academy_2025_04_24` (PostgreSQL).
2. Postupně spustit soubory ve složce `sql/` v tomto pořadí:

   - `00_setup.sql`
   - `01_view_payroll_year.sql`
   - `02_view_price_year.sql`
   - `03_view_payroll_industry_year.sql`
   - `04_view_cz_gdp_year.sql`
   - `10_table_primary_final.sql`
   - `11_table_secondary_final.sql`
   - `20_view_food_wage_year.sql`
   - `21_view_macro_vs_food_wage.sql`
   - otázky:
     - `30_q1.sql`
     - `31_q2.sql`
     - `32_q3.sql`
     - `33_q4.sql`
     - `34_q5.sql`

Pozn.: Každý soubor obsahuje `SET search_path TO data_academy_content;`, takže je možné je spouštět i samostatně.

---

## Výzkumné otázky a odpovědi

### Otázka 1  
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Na základě pohledu `v_petra_chapcakova_payroll_industry_year` jsem sledovala meziroční změnu průměrné hrubé mzdy ve 19 odvětvích dle klasifikace CZ-NACE.

- **V 15 z 19 odvětví** se v období 2000–2021 objevil alespoň jeden rok se záporným meziročním růstem mezd.  
- Pokles mezd se vyskytl například v těchto odvětvích:  
  - Administrativní a podpůrné činnosti (N)  
  - Činnosti v oblasti nemovitostí (L)  
  - Informační a komunikační činnosti (J)  
  - Kulturní, zábavní a rekreační činnosti (R)  
  - Peněžnictví a pojišťovnictví (K)  
  - Profesní, vědecké a technické činnosti (M)  
  - Stavebnictví (F)  
  - Těžba a dobývání (B)  
  - Ubytování, stravování a pohostinství (I)  
  - Velkoobchod a maloobchod (G)  
  - Veřejná správa a obrana (O)  
  - Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu (D)  
  - Vzdělávání (P)  
  - Zásobování vodou, činnosti související s odpady a sanacemi (E)  
  - Zemědělství, lesnictví, rybářství (A)

- **Pouze čtyři odvětví nikdy nevykázala meziroční pokles průměrné mzdy** – tj. jejich minimální meziroční změna byla kladná:  
  - Doprava a skladování (H)  
  - Zpracovatelský průmysl (C)  
  - Ostatní činnosti (S)  
  - Zdravotní a sociální péče (Q)

- Největší zaznamenaný propad mezd byl v odvětví **Peněžnictví a pojišťovnictví (K)**, kde minimální meziroční změna dosáhla přibližně **−8,9 %**.  
  Další výrazné propady se objevily v odvětví **činnosti v oblasti nemovitostí (L)** (cca −7,0 %) a **ubytování, stravování a pohostinství (I)** (cca −5,9 %).

Závěr: Mzdy dlouhodobě rostou, ale **ve většině odvětví se vyskytují jednotlivé roky s poklesem**. Stabilně rostoucí bez poklesu jsou jen čtyři sledovaná odvětví.


---

### Otázka 2  
Kolik je možné si koupit litrů mléka a kilogramů chleba za průměrnou mzdu  
na první a poslední srovnatelné období v dostupných datech?

Z primární tabulky `t_petra_chapcakova_project_sql_primary_final` jsem určila první a poslední rok, kdy jsou současně dostupná data o mzdách i cenách: **2006** a **2018**. Pro tyto roky jsem spočítala, kolik jednotek dané potraviny lze koupit z průměrné hrubé mzdy.

Použité položky:
- „**Chléb konzumní kmínový**“ (kg)  
- „**Mléko polotučné pasterované**“ (l)

Výsledky:

- **Rok 2006**
  - Chléb: průměrná cena ~16,1 Kč/kg, z průměrné mzdy lze koupit cca **1 282 kg**.
  - Mléko: průměrná cena ~14,4 Kč/l, z průměrné mzdy lze koupit cca **1 432 l**.

- **Rok 2018**
  - Chléb: průměrná cena ~24,2 Kč/kg, z průměrné mzdy lze koupit cca **1 340 kg**.
  - Mléko: průměrná cena ~19,8 Kč/l, z průměrné mzdy lze koupit cca **1 639 l**.

Závěr: Přestože ceny chleba i mléka vzrostly, **reálná dostupnost těchto základních potravin se zlepšila** – z průměrné mzdy lze v roce 2018 koupit více chleba i mléka než v roce 2006.


---

### Otázka 3  
Která kategorie potravin zdražuje nejpomaleji (má nejnižší průměrný meziroční nárůst)?

V tabulce `t_petra_chapcakova_project_sql_primary_final` jsem spočítala průměrnou meziroční změnu ceny (`price_yoy_pct`) za celé dostupné období pro každou kategorii potravin.

Pět kategorií s nejnižším průměrným růstem cen:

1. **Cukr krystalový** – průměrný meziroční růst cca **−1,9 %** (dlouhodobě mírné zlevňování).  
2. **Rajská jablka červená kulatá** – cca **−0,7 %** ročně.  
3. **Banány žluté** – cca **+0,8 %** ročně.  
4. **Vepřová pečeně s kostí** – cca **+1,0 %** ročně.  
5. **Přírodní minerální voda uhličitá** – cca **+1,0 %** ročně.

Závěr: **Nejpomaleji zdražují (a u dvou položek dokonce mírně zlevňují) zejména základní suroviny typu cukr a rajčata.** Oproti nim jiné sledované potraviny rostou v ceně výrazně rychleji.


---

### Otázka 4  
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd  
(více než o 10 procentních bodů)?

Nejprve jsem vytvořila „index cen potravin“ jako průměr meziročního růstu ceny (`price_yoy_pct`) napříč všemi potravinovými kategoriemi v daném roce. Tento index jsem porovnala s meziročním růstem průměrné hrubé mzdy (`wage_yoy_pct`) z téhož roku.

- Pro každý rok jsem spočítala rozdíl:  
  `diff_pp = food_yoy_pct − wage_yoy_pct`
- Následně jsem hledala roky, kde `diff_pp > 10` (tj. potraviny zdražily o více než 10 p.b. rychleji než mzdy).

Výsledek dotazu:

- **Nebyl nalezen žádný rok**, ve kterém by růst cen potravin převýšil růst mezd o více než 10 procentních bodů (výsledná množina byla prázdná).

Závěr: Ačkoli existují roky, kdy ceny potravin rostly rychleji než mzdy, **rozdíl nikdy nepřekročil hranici 10 procentních bodů**.


---

### Otázka 5  
Má výše HDP vliv na změny mezd a cen potravin?

Pomocí pohledu `v_petra_chapcakova_macro_vs_food_wage` jsem porovnala:

- meziroční změnu HDP ČR (`gdp_yoy_pct`),
- průměrný meziroční růst cen potravin (`food_yoy_pct`),
- meziroční změnu průměrné hrubé mzdy (`wage_yoy_pct`).

Vyhodnocovala jsem zejména období, pro které existují všechna tři data současně (přibližně 2006–2018).

**Vztah HDP a mezd:**

- V letech s vyšším růstem HDP, např. **2007**, **2015** a **2017**  
  (HDP přibližně +5–6 %), vykazují mzdy také rychlejší růst (cca **+5–8 %**).
- Po propadu HDP v roce **2009** (cca −4,7 %) sice mzdy stále rostou, ale výrazně pomaleji (okolo **+3 %**).
- V letech **2012–2013**, kdy je růst HDP velmi slabý až mírně záporný, je růst mezd utlumený a v roce **2013** dochází dokonce k **meziročnímu poklesu mezd**.
- Naopak po silnějším růstu HDP v roce **2015** se v následujících letech 2016–2018 růst mezd opět zrychluje.

**Vztah HDP a cen potravin:**

- V letech **2007–2008** rostou HDP i ceny potravin relativně rychle (food index cca +9 %), což působí „učebnicově“.  
- V letech **2012–2013** však ceny potravin rostou velmi rychle (cca +6–8 %), zatímco HDP prakticky stagnuje nebo je lehce v minusu.  
- Naopak v roce **2015–2016** roste HDP solidním tempem, ale ceny potravin se pohybují jen mírně, případně lehce klesají.

Závěr:

- **Mezi HDP a mzdami je zřetelný vztah** – vyšší růst HDP je většinou spojen s rychlejším růstem mezd, a naopak v obdobích slabého růstu či poklesu HDP se růst mezd zpomaluje nebo krátkodobě klesá. Často se zdá, že mzdy reagují na vývoj HDP s určitým zpožděním (cca 1 rok).
- **Mezi HDP a cenami potravin je vztah mnohem slabší a méně stabilní.** Ceny potravin jsou zjevně ovlivněny i jinými faktory (světové ceny komodit, kurz měny, počasí apod.), takže se jejich vývoj od vývoje HDP často odchyluje.

Celkově lze říci, že **HDP má výraznější vliv na vývoj mezd než na vývoj cen potravin**. Kupní síla domácností se tedy ve sledovaném období mění spíše přes mzdovou úroveň než čistě přes změny cen potravin.
