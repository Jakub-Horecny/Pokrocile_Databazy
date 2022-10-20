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


-- ===================== PRAKTICKE CVICENIE 5 ========================
-- štatistika, zmena PK

-- generovanie štatistiky príkazom SELECT
-- pre kadé mesto poèet ZPT osôb 
select n_mesta, count(id_ztp) pocet
from p_mesto left join p_osoba using(psc) join p_ztp using(rod_cislo)
group by n_mesta
order by pocet;

-- pre kadé mesto vypísa ko¾ko mám ¾udí s jednotlivım postihnutím 
select 
    m.n_mesta mesto,
    sum(case when t.id_postihnutia=1 then 1 else 0 end) id_1,
    sum(case when t.id_postihnutia=2 then 1 else 0 end) id_2,
    sum(case when t.id_postihnutia=3 then 1 else 0 end) id_3,
    sum(case when t.id_postihnutia=4 then 1 else 0 end) id_4,
    sum(case when t.id_postihnutia=5 then 1 else 0 end) id_5
from p_mesto m
join p_osoba o on (m.psc = o.psc)
join p_ztp z on (z.rod_cislo = o.rod_cislo)
join p_typ_postihnutia t on (z.id_postihnutia = t.id_postihnutia)
group by m.n_mesta
order by id_1 desc;

select * from p_ztp;

-- vıpoèet váeného študíjného priemeru 
select 
    case when vysledok = 'A' then 1
        when vysledok = 'B' then 1.5
        when vysledok = 'C' then 2
        when vysledok = 'D' then 2.5
        when vysledok = 'E' then 3
from zap_predmety... predmet_bod
where forma_kont in ('e', 's');

select os_cislo,round(kvet3.priemer(os_cislo))
 from kvet3.student
  order by 2
   fetch first 3 rows with ties; -- with ties je v podstete varianta rank()

-- nefunguje správne keï chcem prvıch troch študentov s priemerom pre 
-- kadı roèník osobytne
select * from kvet3.student;

-- alias sa dá poui pre vısledok SELECT -> tabu¾ka èo zvnikne zo SELECTU

-- zmena hodnoty PK
-- chcem zneni OS èíslo uèite¾a 

select * from ucitel;

-- nedá sa to spravi jednokrokovo priamim update
-- môem napr. prida nového uèite¾a, zmeni os_cislo v inıch tabu¾kách, a starého
-- vymaza 
update ucitel set os_cislo='XXXXX' where os_cislo='KI003'; 


-- môem vytvori triger, ktorı mi zabezpeèí kaskádu 

-- je mi jedno èi to robím BEFORE alebo AFTER 
create or replace trigger trig_upd_ucitel
 BEFORE update on ucitel
  for each row
begin
 update zap_predmety set prednasajuci=:NEW.os_cislo where prednasajuci=:OLD.os_cislo;
 update predmet_bod set garant=:NEW.os_cislo where garant=:OLD.os_cislo;
end;
/

update ucitel set os_cislo='KI003' where os_cislo='KXXXX';

-- triger, ktorı zmení os_cislo študenta 
create or replace trigger trig_upd_os_cislo_student
    before update on student
for each row
begin
    update zap_predmety set os_cislo=:new.os_cislo where os_cislo=:old.os_cislo;
end;
/

update student set os_cislo=111111 where os_cislo=500428;
rollback;

select * from student where os_cislo = 500428;
select * from zap_predmety;


-- triger ktorı zmenı rod_cislo pre p_osoba 
create or replace trigger trig_upd_rod_cislo_p_osoba
before update on p_osoba
for each row
begin
    update p_zamestnanec set rod_cislo=:new.rod_cislo where rod_cislo=:old.rod_cislo;
    update p_poistenie set rod_cislo=:new.rod_cislo where rod_cislo=:old.rod_cislo;
    
    update p_poberatel set rod_cislo=:new.rod_cislo where rod_cislo=:old.rod_cislo;
    
    update p_ztp set rod_cislo=:new.rod_cislo where rod_cislo=:old.rod_cislo;
    
    update p_platitel set id_platitela=:new.rod_cislo where id_platitela=:old.rod_cislo;
end;
/

update p_osoba set rod_cislo='111111/1111' where rod_cislo = '745426/8459';

SELECT
    * FROM p_platitel
    order by id_platitela;
    
-- defferable constrains
-- (vraj je to opakovanie na test)
    
select u1.constraint_name, u2.constraint_name, u1.table_name, u2.table_name, u2.deferrable
 from user_constraints u1 join user_constraints u2 on (u1.constraint_name=u2.r_constraint_name)
  where u1.table_name='UCITEL';
    
-- zrušil som vzah mnedzi tabu¾kou uèitel a zap_predmety
alter table zap_predmety drop constraint SYS_C00556387; 
-- treba to spravi aj nad tabu¾kou predmet_bod
alter table zap_predmety drop constraint SYS_C00556392; 
-- zrušil som FK

-- databáza sa teraz nachádza v nekonzistentnom stave 

-- teraz vytvorím vzah nanovo
alter table zap_predmety add foreign key(prednasajuci) references ucitel(os_cislo) deferrable;
alter table predmet_bod add foreign key(garant) references ucitel(os_cislo) deferrable;

-- deferrable constrains umoní to e teraz mnôem robi update v ¾ubovo¾nom poradí
-- nekontroluje sa dátová integrita 

-- toto je default mod, kedy sa dátová integrita kontroluje okamite 
alter session set constraints=immediate;


-- ====== GENEROVANIE PRIKAZOV POMOCOU PRIKAZOV ======  

-- chcem si vytvori novú tabu¾ku a naimporova dáta príkazom SELECT

create table predmety_zaloha (
    cis_predm char(4) primary key,
    nazov varchar2(200)
);

insert into predmety_zaloha values('BI06', 'DBS'); -- nieèo takéto chcem vygenerova 

--                                          | tu tie ' musia by v inıch ' 
select 'insert into predmety_zaloha values(''' || cis_predm || ''',''' || nazov || ''');'
from predmet;
-- cez kurzor by sa to dalo všetko vykona 

-- ak by som to chcel da do csv
select cis_predm || ',' || nazov || ','
from predmet;



-- ====== KOLEKCIE =====
set SERVEROUTPUT on;
create or replace type t_student as object (
    meno varchar(20),
    priezvisko varchar(20)
);
/
drop type t_student;
declare
    type t_pole is table of t_student;
    pole t_pole := t_pole();
begin
    for rn in (select * from (select meno, priezvisko, row_number() over (order by os_cislo) rn
                    from os_udaje
                    join student using(rod_cislo))
                    where rn<=5)
                
    loop
        pole.extend;
        pole(pole.last) := t_student(rn.meno, rn.priezvisko);
    end loop;
    
    for i in pole.first..pole.last
    loop
        dbms_output.put_line(pole(i).meno || ' ' || pole(i).priezvisko);
    end loop;
    
    --pole.delete; -- zmae všetko 
    dbms_output.put_line('-----------------------');
    dbms_output.put_line(pole.count); -- 0
    dbms_output.put_line('-----------------------');

    
end;
/

alter type t_student
    add map member function tried return integer;
    
create or replace type body t_student
is
    map member function tried return integer
    is
    begin
        return dbms_random.value(1,10);
    end;
end;
/
drop table tab_student;
create table tab_student of t_student;
insert into tab_student select meno, priezvisko from os_udaje;
-- to isté 
insert into tab_student select t_student(meno, priezvisko) from os_udaje;

select * from tab_student t;


select t.meno, t.priezvisko, t.tried() rn
 from tab_student t
  order by rn;
  
  
-- OUTER JOIN

select st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania,  count(os_cislo)
from st_odbory left join student using(st_odbor, st_zameranie)
group by st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania;

-- je dôleité èi podmienka - rocnik=2 - je vo where alebo v spojenı 
-- (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
-- ak je v spojení, tak spájam tabu¾ky iba ak roèník=2 --> podmienka je splnená 
-- keï je vo where spracujem všetky a potom s vısledku vyberiem kde je splnená podmienka 
select s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania, count(os_cislo)
 from st_odbory sto left join student s on (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
   where rocnik=2 
  group by s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania; 
  
-- kde sa mi stratili tie dva záznami ?
-- pri OUTER JOIN nemusím získa všetky hodnoty keï tam dám NULL


-- vypísa odboru ku ktorım nemám iadnych študentov 
select * from st_odbory
where  not exists (select 'x' from student
                    where st_odbory.st_odbor = student.st_odbor
                            and st_odbory.st_zameranie = student.st_zameranie);