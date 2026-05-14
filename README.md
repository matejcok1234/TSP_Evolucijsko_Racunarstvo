# Seminar: Evolucijsko računarstvo - Analiza operatora križanja za TSP

Ovaj projekt sadrži cjelovitu implementaciju i statističku analizu tri operatora križanja (Cycle Crossover - CX, Simple Crossover - SX, Edge Recombination Crossover - ERX) unutar evolucijskog algoritma za rješavanje problema trgovačkog putnika (TSP) u MATLAB-u.

## Struktura projekta

Sve MATLAB skripte nalaze se u korijenskom direktoriju projekta radi jednostavnosti izvođenja:

* `run_all.m` - Glavna skripta. Pokreće apsolutno cijeli cjevovod: generiranje problema (ako fale), pokretanje 900 eksperimenata, računanje statistike i crtanje svih grafova.
* `pokreni_ea.m` - Jezgra evolucijskog algoritma koja prima parametre i izvršava odabrani operator (selekcija, križanje, mutacija/inverzija).
* `ucitaj_tsp.m` - Pomoćna skripta za čitanje standardnih TSPLIB datoteka.
* `crossover_cx.m`, `crossover_sx.m`, `crossover_erx.m` - Implementacije odgovarajućih operatora križanja.

### Skripte za analizu i vizualizaciju
* `izracunaj_statistiku.m` - Obrađuje sirove podatke i računa medijane, minimume, standardne devijacije te ih sprema u agregirani CSV.
* `provjeri_normalnost.m` - Provodi Shapiro-Wilk test (oslanja se na vanjsku `swtest.m` skriptu) na svim podacima.
* `analiziraj_rezultate.m` - Vrši Friedmanov test, izračun prosječnih rangova, Kendallov W i Wilcoxonovu post-hoc analizu uz Holmovu korekciju.
* `crtaj_grafove.m` - Generira sve gotove figure za seminar (mape ruta, krivulje konvergencije, boxplotove distribucije fitnessa, histograme, graf prosječnih rangova te usporedbu vremenskog izvođenja).

## Podaci i Rezultati

* **`data/`** - Sadrži `tsplib/` mapu sa standardnim problemima (npr. `berlin52`, `kroC100`, `Croatia50`) te `generated/` mapu gdje skripta automatski generira 3 vlastita problema (`vlastiti_uniform60`, `vlastiti_clustered55`, `vlastiti_circle45`) ukoliko već ne postoje.
* **`results/`** - Ovdje algoritam sprema izlazne CSV datoteke sa sirovim i analiziranim podacima nakon izvođenja.
* **`figures/`** - Ovdje se spremaju renderirani grafovi (.png) formatirani za izravno umetanje u LaTeX izvještaj.

## Kako pokrenuti

1. Otvorite MATLAB i postavite trenutni radni direktorij (*Current Folder*) na ovaj direktorij (`seminar_tsp_ea`).
2. U zapovjednu liniju (Command Window) upišite samo:
   ```matlab
   run_all
   ```
3. Skripta će ispisivati napredak u konzoli. Ukupno se odvija 900 pokretanja (10 problema × 3 algoritma × 30 ponavljanja sa zadanim seedovima). Eksperiment će trajati određeno vrijeme (najveći dio otpada na zahtjevniji ERX operator na problemima sa 100 gradova).
4. Po završetku izvršavanja, gotove CSV tablice nalazit će se u `results/`, a gotove slike u `figures/` direktoriju.

## Parametri algoritma

Za sva izvođenja algoritma strogo su kontrolirani uvjeti: populacija = 120, maksimalno generacija = 1000, uvjet zaustavljanja na stagnaciji (*stall limit*) = 150, vjerojatnost križanja = 60%, vjerojatnost inverzijske mutacije = 35%, elitizam (1 najbolja jedinka prelazi u novu generaciju), turnirska selekcija (k=3). Radi ponovljivosti (reproducibility), unutar petlje od 30 pokretanja strogo se kontrolira state pomoću `rng(r)`.
