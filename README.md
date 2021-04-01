# scraping-eprijava
Prikupljanje finansijskih izvjestaja sa sajta eprijava.tax.gov.me

---

## Pokretanje

U fajlu **DownloadFinansijskihIzvjestaja.ps1** PIB se moze promijeniti na odgovarajuci (zadati PIB je za pravno lice **Azalea Maritime**, kao primjer), a skripta se potom moze pokrenuti putem batch fajla **Start.bat**.

## Output

Ispis na ekranu ce biti nalik sljedecem:

```
Pretraga po PIB-u: 02347806
Pronadjen: 02347806 - "AZALEA POMORSKI TRENING CENTAR" D.O.O. HERCEG NOVI

Pretraga liste finansijskih izvjestaja
Pronadjeno 7 finansijskih izvjestaja

Download finansijskih izvjestaja:
- Download izvjestaja br. 54244/2020 za godinu 2020
- Download izvjestaja br. 75292/2019 za godinu 2019
- Download izvjestaja br. 80068/2018 za godinu 2018
- Download izvjestaja br. 44783/2017 za godinu 2017
- Download izvjestaja br. 47482/2016 za godinu 2016
- Download izvjestaja br. 21542/2015 za godinu 2015
- Download izvjestaja br. 5359/2014 za godinu 2014

Gotovo.
```

## Rezultat

Program ce prikupiti sve finansijske izvjestaje za pronadjeno pravno lice i smjestiti u lokalni direktorijum u formatu: `PIB-GODINA.htm`.
