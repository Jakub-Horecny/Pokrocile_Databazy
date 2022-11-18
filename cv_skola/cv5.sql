-- pre kadı študíjni odbor chcem vypísa poèet študentov
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
                
-- ko¾ko mám A,B...
-- cez vek poèet muov/eny
-- an teste urèite bude nejaká bodobná pièovina :) 


-- ako niekomu zmeni PK
-- vytvorím kópiu tabu¾ky, ale so zmenením PK 
--musí by typu defereble - povo¾uje kontrolu referenènú integrity

-- insert update triger

-- vıpoèet vıenhéštudíjneho priemeru
-- ako na to?

-- koeficient je známka
-- ects - poèet kredito
-- v menovateli èí ho absolvoval alebo nie - 0/1
-- prblém - v menovateli môe by 0 -- ke´d to budem deli, tak ak dostanem 0 v menovateli, tak vypíšem 999
-- nie je rozsah od 1-4, môe by aj viac 

-- bereim len predmety z s a E
-- nema podiel v menovateli, a ak áno treba odchiti vınimku 
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
-- JSON a súbory tam nebudú 

/*
VP = [(K1 * Z1) + (K2 * Z2) + .... + (Kn  * Zn)] : [K1 + K2 + .... + Kn]

VP – váenı študijnı priemer
K – hodnota kreditov za konkrétny predmet
Z – èíselné vyjadrenie známky za konkrétny predmet
*/

select
    z.ects * (case WHEN pr.forma_kont='s' and z.zapocet is null then 4 else 
    decode(z.vysledok, 'A', 1, 'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F', 4, NULL, 4) end)
    / sum(ects
   ; 
 
-- vypíšte študenta s maximálnim poètom kreditov, ak je ich viac vypísa všetkıch   
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
