/*
    �. 3 - kolekcie 
    �o je to kolekcia - mno�ina z�znamov v syst�me 
                        poradie prvkov ur�uje o ktor� sa jedn� - index 1, st�le ten ist� prvok --> je usporiadn�
                        usporiadan� mno�ina rovnak�ho typu 
    typy kolekci� 3
    
    veray -  obmedzen� po�et prvkov ktor� ram m��em vlo�i� - �trkt�ra je zo samotn�mi d�tami mus� tam by� IS VARRAY
            - count a last s� v�dy rovnak� 
    nested table - kon�truktor m�, ak chce prida� nejak� prvok potrebujem to roz��ri�  - ulo�en� osobitne 
    index by table - odkazujem sa na �ubovo�n� poz�ciu - tabu�ka v tabu�ke INTEX BY a pod�a �oho to indexujem 
    
    pole t_pole := t_pole(10,20,30,40,50);  je to kon�truktor 
    (10,20,30); - 
    count != last ak nie�o zma�em 
    count > last nikdy nebude ve�ie v �iadnej kolekci�
    
    pole(pole.count) - d� to 50, nie index 5
    
    pole.limit -vyjadruje ko�ko maxim�lne im m��em ma� - relevant� iba pre vervar, inak vr�ti NULL - error;
    pole(pole.limit)
    
    
    pole.last:=60 - nebude fungova� lebo pole.last mi d� index a ja tomu chcem priradi� hodnotu 
    pole.(pole.last):= 60 - takto prep�em posledn� index na 60
    
    pole.extend(1); - prid�m pr�zdny prvok NULL
    pole.count - teraz vr�ti 6 aj ke� som tam nepriradil hodnotu 
    pole.last - st�le d� 6, aj ke� tam je NULL hodnota
    
    pole.delete(3) - pole.delate(3,2) - prv� ��slo mus� by� men�ie rovn� druh�
    vznikne mi tam pr�zdny element
    (10,20,NULL,40,50) - v�nimka no data found 
    nem��em to o�etri� na IS NULL, lebo som vymazal smern�k --> nem��em kontrolova� �i existuje 
    mus� sa to robi� cez pole.EXISTS(i)
    
    ak vyma�em nejak� prvok, a ak idem ce count tak nevima�em v�etky - b�va to na teste !!!!!!!!!!!!!!!!!
    
    funkcia NEXT - vr�ti najbli��� prvok ktor� existuje 
    TRIM - ore�e posledn� prvok - vyma�e prvok aj smern�k - ak pou�ijem TRIM count sa zmen�� 
    
    vstupn� parameter je index pola 
    NEXT(0) vr�ti prv� prvok, aj keby som tam dal -50 
    ak tam d�m viac ako count d� to chybu - iba do hranice pola 
    
    PRIOR - vr�ti mi index prv�ho not null elementu - ide z prava do �ava 
    PRIOR(1) d�  chybu, lebo idem za ranicu pola 
    
    REF - v tabu�ke objektov vytvor�m smern�k na objekt 
    
    
    DBMS_RANDOM PACKAGE (gener�tor n�hodn�ch ��sel) 
    
    INITIALIZA - star� met�da ktor� sa moc nepou��va 
    teraz sa pou��va SEED - nastavenie n�sady - ��slo alebo re�azec 
    NORMAL - n�hodn� ��slo z norm�lneho rozdelenia 
    RANDOM
    geerovanie ra�azca - ur��m ak� ra�azec m�m generova� 
    - ot�zka na teste - vygenerova� pre pou��vate�ov meno, heslo
    
    VALUE - vygeneruje ��slo od 0-1 ale z nejak�ho rozsahu �ava� uzavret�, prav� otvoren�
    
    varray - pok�si� sa vymaza� znamen� �e sa to ned� LOL 
    
    treba si d�va� pozor na GROUP BY a OUTHER JOIN 
    NOT EXIST - treba ma� vezobn� podmienku 
    
*/

select count(cis_predm) cis_predm from zap_predmety

-- probl�mi z testu
-- osoba ktor� nikdy nebola �tudentom
select meno, priezvisko
    from os_udaje
    where not exists(select 'x' from os_udaje o join student s on (o.rod_cislo = s.rod_cislo
                        where o1.rod_cislo = s.rod_cislo); -- netreba tam znovu JOIN pre os_udaje
                        
                        
-- pre ka�d� okres poistenca z maxi odvodmi
select id_kraja, rod_cislo, count(*)
from p_kraj 
join p_okres using(id_kraja)
join p_mesto using(id_kresu)
join p_osoba using(psc)
join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
group by id_kraja, rod_cislo -- nem��em ma� v goup by rod_cslo 
order by 1;

-- treba spravi� vnoren� select 
-- ak chcem MAX MIN pre nejak� skupinu m�m tam ma� vnoren� select 
select rod_cislo, count(*)
from n p_osoba using(psc)
join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
group by id_kraja, rod_cislo -- nem��em ma� v goup by rod_cslo 
order by 1;


-- ku ka�d�mu mesiacu po�el �ud� ktor� sa v nom narodili
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

-- jedin� podmienka je �e mus�m ma� tabu�ku ktor� m� aspo� 12 ZZNAMOV 
select rn
from(
select row_number() over(order by meno) as rn from os_udaje)
where rn<=12;


-- ak tam d�m RANK() - d� to sam� jednotky 
select row_number() over(order by rowid)
from dual
connect by level <= 12;

-- po�et dn� od za�iatku ku koncu roku d� sa to spravi� 

/*
osoba bude ma� byt alebo dom -s� to objekty
a chcem identifikova� susedov
bud� tam referencie cez smern�ky tak�e fakt super 
*/