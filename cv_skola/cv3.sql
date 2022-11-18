/*
    è. 3 - kolekcie 
    èo je to kolekcia - mnoina záznamov v systéme 
                        poradie prvkov urèuje o ktorı sa jedná - index 1, stále ten istı prvok --> je usporiadná
                        usporiadaná mnoina rovnakého typu 
    typy kolekcií 3
    
    veray -  obmedzení poèet prvkov ktoré ram môem vloi - štrktúra je zo samotními dátami musí tam by IS VARRAY
            - count a last sú vdy rovnaké 
    nested table - konštruktor má, ak chce prida nejakı prvok potrebujem to rozšíri  - uloená osobitne 
    index by table - odkazujem sa na ¾ubovošnú pozíciu - tabu¾ka v tabu¾ke INTEX BY a pod¾a èoho to indexujem 
    
    pole t_pole := t_pole(10,20,30,40,50);  je to konštruktor 
    (10,20,30); - 
    count != last ak niešo zmaem 
    count > last nikdy nebude veèie v iadnej kolekcií
    
    pole(pole.count) - dá to 50, nie index 5
    
    pole.limit -vyjadruje ko¾ko maximálne im môem ma - relevanté iba pre vervar, inak vráti NULL - error;
    pole(pole.limit)
    
    
    pole.last:=60 - nebude fungova lebo pole.last mi dá index a ja tomu chcem priradi hodnotu 
    pole.(pole.last):= 60 - takto prepíšem poslednı index na 60
    
    pole.extend(1); - pridám prázdny prvok NULL
    pole.count - teraz vráti 6 aj keï som tam nepriradil hodnotu 
    pole.last - stále dá 6, aj keï tam je NULL hodnota
    
    pole.delete(3) - pole.delate(3,2) - prvé èíslo musí by menšie rovné druhé
    vznikne mi tam prázdny element
    (10,20,NULL,40,50) - vınimka no data found 
    nemôem to ošetri na IS NULL, lebo som vymazal smerník --> nemôem kontrolova èi existuje 
    musí sa to robi cez pole.EXISTS(i)
    
    ak vymaem nejakı prvok, a ak idem ce count tak nevimaem všetky - bıva to na teste !!!!!!!!!!!!!!!!!
    
    funkcia NEXT - vráti najbliší prvok ktorí existuje 
    TRIM - oree poslednı prvok - vymae prvok aj smerník - ak pouijem TRIM count sa zmenší 
    
    vstupnı parameter je index pola 
    NEXT(0) vráti prvı prvok, aj keby som tam dal -50 
    ak tam dám viac ako count dá to chybu - iba do hranice pola 
    
    PRIOR - vráti mi index prvého not null elementu - ide z prava do ¾ava 
    PRIOR(1) dá  chybu, lebo idem za ranicu pola 
    
    REF - v tabu¾ke objektov vytvorím smerník na objekt 
    
    
    DBMS_RANDOM PACKAGE (generátor náhodnıch èísel) 
    
    INITIALIZA - stará metóda ktorá sa moc nepouíva 
    teraz sa pouíva SEED - nastavenie násady - èíslo alebo reazec 
    NORMAL - náhodné èíslo z normálneho rozdelenia 
    RANDOM
    geerovanie raazca - urèím akı raazec mám generova 
    - otázka na teste - vygenerova pre pouívate¾ov meno, heslo
    
    VALUE - vygeneruje èíslo od 0-1 ale z nejakého rozsahu ¾avaá uzavretá, pravá otvorená
    
    varray - pokúsi sa vymaza znamení e sa to nedá LOL 
    
    treba si dáva pozor na GROUP BY a OUTHER JOIN 
    NOT EXIST - treba ma vezobnú podmienku 
    
*/

select count(cis_predm) cis_predm from zap_predmety

-- problémi z testu
-- osoba ktorá nikdy nebola študentom
select meno, priezvisko
    from os_udaje
    where not exists(select 'x' from os_udaje o join student s on (o.rod_cislo = s.rod_cislo
                        where o1.rod_cislo = s.rod_cislo); -- netreba tam znovu JOIN pre os_udaje
                        
                        
-- pre kadı okres poistenca z maxi odvodmi
select id_kraja, rod_cislo, count(*)
from p_kraj 
join p_okres using(id_kraja)
join p_mesto using(id_kresu)
join p_osoba using(psc)
join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
group by id_kraja, rod_cislo -- nemôem ma v goup by rod_cslo 
order by 1;

-- treba spravi vnorenı select 
-- ak chcem MAX MIN pre nejakú skupinu mím tam ma vnorenı select 
select rod_cislo, count(*)
from n p_osoba using(psc)
join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
group by id_kraja, rod_cislo -- nemôem ma v goup by rod_cslo 
order by 1;


-- ku kadému mesiacu poèel šudí ktorí sa v nom narodili
select to_char(dat_od, 'MM') mesiac, count(*)
from p_poberatel
group by to_char(dat_od, 'MM')
order by mesiac;

select rn, count(rod_cislo)
from os_udaje right join 
(
select rn
from(
select row_number() over(order by meno) as rn from os_udaje)
where rn<=12
) on (mod(substr(rod_cislo,3,2),50) = rn)
group by rn
order by 1;

-- jediná podmienka je e musím ma tabu¾ku ktorá má aspoò 12 ZZNAMOV 
select rn
from(
select row_number() over(order by meno) as rn from os_udaje)
where rn<=12;


-- ak tam dám RANK() - dá to samé jednotky 
select row_number() over(order by rowid)
from dual
connect by level <= 12;

-- poèet dní od zaèiatku ku koncu roku dá sa to spravi 

/*
osoba bude ma byt alebo dom -sú to objekty
a chcem identifikova susedov
budú tam referencie cez smerníky take fakt super 
*/