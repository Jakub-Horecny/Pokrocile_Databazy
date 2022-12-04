-- rekurzÌvne vzùahy 
-- FK sa odkazuje na PF tej istej tabuæky - vzùak je neidentifikaËn˝ 
desc uniza_tab;

select * from uniza_tab order by nadriadeny;

-- ku kazdej osobe vypÌsaù ved˙ceho
select zam.meno, zam.priezvisko, ved.meno, ved.priezvisko
from uniza_tab zam, uniza_tab ved
where zam.nadriadeny = ved.os_cislo;

select zam.meno, zam.priezvisko, ved.meno ved_meno, ved.priezvisko ved_preizvisko
from uniza_tab zam
left join uniza_tab ved on (ved.os_cislo = zam.nadriadeny);
-- left join aby som mal aj t˝ch Ëo nemaj˙ nadriaden˝ch 


-- ku kaûdej osobe chcem podriadenÈho
select zam.meno, zam.priezvisko, pod.meno pod_meno, pod.priezvisko pod_preizvisko
from uniza_tab zam
left join uniza_tab pod on (zam.os_cislo = pod.nadriadeny)
order by zam.os_cislo;
-- list agg
select 
    zam.meno, zam.priezvisko,
    listagg(pod.meno || ' ' || pod.priezvisko || ' ' || pod.os_cislo, ', ')
    within group (order by pod.os_cislo)
from uniza_tab zam
left join uniza_tab pod on (zam.os_cislo = pod.nadriadeny)
group by zam.meno, zam.priezvisko, zam.os_cislo
order by zam.os_cislo;
-- pod.os_cislo musÌ byù v group by 



-- ku kaûdej osobe kolegu
select zam.meno, zam.priezvisko, kol.meno kol_meno, kol.priezvisko kol_preizvisko
from uniza_tab zam
left join uniza_tab kol on (zam.nadriadeny = kol.nadriadeny)
where zam.os_cislo <> kol.os_cislo -- s·m sebe nie je kolegom 
order by zam.os_cislo;
-- list agg
select 
    zam.meno, zam.priezvisko, 
    listagg(kol.meno || ' ' || kol.priezvisko, ', ') 
        within group (order by zam.os_cislo)
from uniza_tab zam
left join uniza_tab kol on (zam.nadriadeny = kol.nadriadeny)
where zam.os_cislo <> kol.os_cislo -- s·m sebe nie je kolegom 
or kol.os_cislo is null -- ak nem· kolegu  
group by zam.meno, zam.priezvisko, zam.os_cislo
order by zam.os_cislo;

-- d· 21 z·znamov, ale v tabuæke je ich 23
-- kam sa stratili? 
-- null hodnoty nie je moûnÈ porovn·vaù cez matematickÈ oper·tory
-- ak osoba nem· kolegu, ËÌslo kolegu je null - treba daù do podmienky   
-- st·le mi to ale d· iba 22 z·znamov 

select count(*) from uniza_tab;


-- rozdiel na zistenie ch˝baj˙ceho z·znamu 
select meno, priezvisko from uniza_tab
minus 
select 
    zam.meno, zam.priezvisko
from uniza_tab zam
left join uniza_tab kol on (zam.nadriadeny = kol.nadriadeny)
where zam.os_cislo <> kol.os_cislo -- s·m sebe nie je kolegom 
or kol.os_cislo is null -- ak nem· kolegu  
group by zam.meno, zam.priezvisko, zam.os_cislo;



-- hierarchick˝ prÌkaz select
select 
    lpad(' ', 3*level-3) || os_cislo || ' ' || meno || ' ' || priezvisko hierarchia
from uniza_tab
start with os_cislo = 1
connect by prior os_cislo= case when os_cislo=nadriadeny then -1 else nadriadeny end
order by level, os_cislo;



-- INDEXOVANIE

desc osoba_tab;
select * from osoba_tab; --40K
-- optimaliz·tor je heuristika - nemusÌ n·jsù optim·lne rieöenie 
-- optim·lne rieöenie sa nehlad· preto, lebo d·ta potrebujem r˝chlo 
-- vstupnÈ d·ta - m·m iba ötatistyky, ktorÈ nemusia presne odzrkadæovaù re·lny stav datab·zy 


-- zystenie indexov nad tabulkou os_udaje
select index_name from user_indexes where table_name='OSOBA_TAB';

--
select constraint_name, constraint_type
from user_constraints
where table_name='OSOBA_TAB';


-- rod_cislo je unik·tne - m·m unik·tny index 
select meno, priezvisko
from osoba_tab
where rod_cislo='865615/6696';

-- nem·m vhodn˝ index, pouûije sa table access full
select meno, priezvisko
from osoba_tab
where meno='Peter';
commit;
-- atrib˙ty v indexe by mali zaËÌnaù podmienkou WHERE

drop index tab2;
create index tab1 on osoba_tab(meno); -- iba toto mi nepomÙûe
create index tab2 on osoba_tab(meno, priezvisko);


-- pouûitie HINT
-- poviem optimaliz·toru, ktor˝ index pouûiù 
-- ak je HINT zle napÌsan˝, berie sa ako koment·r 

-- index sa pouûije aj keÔ nie je vhodn˝ 
-- nepouûije sa iba ak sa index neprekrÌva s atrib˙tmi - ak by som mal index na atrib˙t ulica a chcem iba meno a priezvisko tak sa index nepouûije 
select /*+index(osoba_tab tab1) */ meno, priezvisko
from osoba_tab
where meno='Peter';

-- ak m·m na tabulke alias, musÌ byù aj v HINT
select /*+index(o tab1) */ meno, priezvisko
from osoba_tab o
where meno='Peter';


-- poradie atrib˙tov v indexe 

-- ide·lny pre dan˝ select, lebo meno je vo WHERE aj ako prvÈ v selecte 
-- najskÙr obmedzujem mnoûinu d·t na spracovanie, a to robÌm podæa mena 
create index tab2 on osoba_tab(meno, priezvisko);

-- tento index nie je ide·lny pre spracovanie, lebo paradie atrib˙tov je inÈ ako v selecte 
create index tab2 on osoba_tab(priezvisko, meno);

-- FAST FULL SCAN - vöetky d·ta m·m v indexe, a prehladanie indexu je v˝hodnejöie ako celej tabuæky 



-- funkcion·lne indexy
select meno, priezvisko
from osoba_tab
where substr(rod_cislo,3,1) > 1;

-- nepouûije sa, lebo v podmienke WHERE porovn·vam string s ËÌslom
create index tab2 on osoba_tab(substr(rod_cislo,3,1), meno, priezvisko);
-- toto sa pouûije 
create index tab2 on osoba_tab(to_number(substr(rod_cislo,3,1)), meno, priezvisko);
-- tieû je moûnosù zmeniù 1 na '1', potom bude prv˝ index fungovaù a druh˝ nie 


-- nested loop
-- has join
-- merge join 


select meno, priezvisko, os_cislo, rocnik
from os_udaje join student using(rod_cislo)
where rod_cislo='841106/3456'; -- nested loop, chcem jeden konkrÈtny z·znam, nad ktor˝m je index 


select o.meno, o.priezvisko, s.os_cislo, s.rocnik
from os_udaje o join student s on(o.rod_cislo = s.rod_cislo)
where s.rod_cislo='841106/3456'; -- nested loop


select o.meno, o.priezvisko, s.os_cislo, s.rocnik
from os_udaje o join student s on(o.rod_cislo = s.rod_cislo)
where o.meno='Peter'; -- HASH JOIN, lebo musÌm prehladaù vöetko, lebo petrov je viac 


select o.meno, o.priezvisko, s.os_cislo, s.rocnik
from os_udaje o join student s on(o.rod_cislo = s.rod_cislo)
where s.rocnik='1' ; --nested loop - mnostvo d·t sa v˝razne zredukovalo 


-- HINT na pouûitie metodiky 
select /*+Use_Merge(o s)*/o.meno, o.priezvisko, s.os_cislo, s.rocnik
from os_udaje o join student s on(o.rod_cislo = s.rod_cislo)
where s.rocnik='1'