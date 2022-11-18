-- pre ka�d� �tud�jni odbor chcem vyp�sa� po�et �tudentov
select 
    popis_odboru, 
    popis_zamerania, 
    count(*) celkovo, 
    rocnik 
from st_odbory 
left join student using(st_odbor, st_zameranie)
group by popis_odboru, popis_zamerania, st_odbor, st_zameranie, rocnik
order by st_odbor;

select popis_odboru, 
    popis_special,
(select count(*) from priklad_db2.student s
            where rocnik=1
                and s.C_ST_Odboru= sto.C_ST_ODBORU and s.C_specializacie=sto.c_specializacie) as prvaci,
(select count(*) from priklad_db2.student s
            where rocnik=2
                and s.C_ST_Odboru= sto.C_ST_ODBORU and s.C_specializacie=sto.c_specializacie) as druhaci,
(select count(*) from priklad_db2.student s
            where rocnik=3
                and s.C_ST_Odboru= sto.C_ST_ODBORU and s.C_specializacie=sto.c_specializacie) as tretiaci
from priklad_db2.st_odbory sto;


select popis_odboru, 
    popis_special,
    count(case when rocnik=1 then 1 else null end) pocet_prvaci,
    count(case when rocnik=2 then 1 else null end) pocet_druhaci,
    count(case when rocnik=3 then 1 else null end) pocet_tretiaci
from
priklad_db2.st_odbory sto left join priklad_db2.student using(C_ST_ODBORU, C_SPECIALIZACIE)
group by popis_odboru, 
    popis_special,C_ST_ODBORU, C_SPECIALIZACIE;
                
-- ko�ko m�m A,B...
-- cez vek po�et mu�ov/�eny
-- an teste ur�ite bude nejak� bodobn� pi�ovina :) 


-- ako niekomu zmeni PK
-- vytvor�m k�piu tabu�ky, ale so zmenen�m PK 
--mus� by� typu defereble - povo�uje kontrolu referen�n� integrity

-- insert update triger

-- v�po�et v��enh�tud�jneho priemeru
-- ako na to?

-- koeficient je zn�mka
-- ects - po�et kredito
-- v menovateli �� ho absolvoval alebo nie - 0/1
-- prbl�m - v menovateli m��e by� 0 -- ke�d to budem deli�, tak ak dostanem 0 v menovateli, tak vyp�em 999
-- nie je rozsah od 1-4, m��e by� aj viac 

-- bereim len predmety z s a E
-- nema� podiel v menovateli, a ak �no treba odchiti� v�nimku 
select
    (z.ects * (case WHEN pr.forma_kont='s' and z.zapocet is null then 4 
                    WHEN z.vysledok in ('A', '1') then 1 
                    WHEN z.vysledok in ('B','1.5') then 1.5 
                    WHEN z.vysledok in ('C','2') then 2 
                    WHEN z.vysledok in ('D','2.5') then 2.5 
                    WHEN z.vysledok in ('E','3') then 3 
                    WHEN z.vysledok in (NULL,'F', '4') then 4 end) /
    case when (sum(case when z.vysledok in (NULL,'F', '4') then 0 else 1 end)) = 0 then 99 else 
        (sum(case when z.vysledok in (NULL,'F', '4') then 0 else 1 end)) end) priemer
         
    from priklad_db2.zap_predmety z
    join priklad_db2.predmet p on (z.cis_predm = p.cis_predm)
    join priklad_db2.predmet_bod pr on (pr.cis_predm = p.cis_predm)
    where pr.forma_kont in ('e','s')
    group by z.ects, pr.forma_kont, z.zapocet, z.vysledok;

select * from  priklad_db2.zap_predmety;
select * from  priklad_db2.predmet_bod;        
-- JSON a s�bory tam nebud� 

/*
VP = [(K1 * Z1) + (K2 * Z2) + .... + (Kn  * Zn)] : [K1 + K2 + .... + Kn]

VP � v�en� �tudijn� priemer
K � hodnota kreditov za konkr�tny predmet
Z � ��seln� vyjadrenie zn�mky za konkr�tny predmet
*/

select
    z.ects * (case WHEN pr.forma_kont='s' and z.zapocet is null then 4 else 
    decode(z.vysledok, 'A', 1, 'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F', 4, NULL, 4) end)
    / sum(ects
   ; 
 
-- vyp�te �tudenta s maxim�lnim po�tom kreditov, ak je ich viac vyp�sa� v�etk�ch   
 select
    o.meno,
    o.priezvisko,
    s.os_cislo,
    sum(case when z.vysledok in (NULL, 'F') then 0 else z.ects end) pocet
from os_udaje o
join student s on (s.rod_cislo = o.rod_cislo)
join zap_predmety z on(s.os_cislo = z.os_cislo)
group by o.meno,
    o.priezvisko,
    s.os_cislo
;
select * from zap_predmety;
