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


-- ===================== PRAKTICKE CVICENIE 5 ========================
-- �tatistika, zmena PK

-- generovanie �tatistiky pr�kazom SELECT
-- pre ka�d� mesto po�et ZPT os�b 
select n_mesta, count(id_ztp) pocet
from p_mesto left join p_osoba using(psc) join p_ztp using(rod_cislo)
group by n_mesta
order by pocet;

-- pre ka�d� mesto vyp�sa� ko�ko m�m �ud� s jednotliv�m postihnut�m 
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

-- v�po�et v�en�ho �tud�jn�ho priemeru 
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

-- nefunguje spr�vne ke� chcem prv�ch troch �tudentov s priemerom pre 
-- ka�d� ro�n�k osobytne
select * from kvet3.student;

-- alias sa d� pou�i� pre v�sledok SELECT -> tabu�ka �o zvnikne zo SELECTU

-- zmena hodnoty PK
-- chcem zneni� OS ��slo u�ite�a 

select * from ucitel;

-- ned� sa to spravi� jednokrokovo priamim update
-- m��em napr. prida� nov�ho u�ite�a, zmeni� os_cislo v in�ch tabu�k�ch, a star�ho
-- vymaza� 
update ucitel set os_cislo='XXXXX' where os_cislo='KI003'; 


-- m��em vytvori� triger, ktor� mi zabezpe�� kask�du 

-- je mi jedno �i to rob�m BEFORE alebo AFTER 
create or replace trigger trig_upd_ucitel
 BEFORE update on ucitel
  for each row
begin
 update zap_predmety set prednasajuci=:NEW.os_cislo where prednasajuci=:OLD.os_cislo;
 update predmet_bod set garant=:NEW.os_cislo where garant=:OLD.os_cislo;
end;
/

update ucitel set os_cislo='KI003' where os_cislo='KXXXX';

-- triger, ktor� zmen� os_cislo �tudenta 
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


-- triger ktor� zmen� rod_cislo pre p_osoba 
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
    
-- zru�il som vz�ah mnedzi tabu�kou u�itel a zap_predmety
alter table zap_predmety drop constraint SYS_C00556387; 
-- treba to spravi� aj nad tabu�kou predmet_bod
alter table zap_predmety drop constraint SYS_C00556392; 
-- zru�il som FK

-- datab�za sa teraz nach�dza v nekonzistentnom stave 

-- teraz vytvor�m vz�ah nanovo
alter table zap_predmety add foreign key(prednasajuci) references ucitel(os_cislo) deferrable;
alter table predmet_bod add foreign key(garant) references ucitel(os_cislo) deferrable;

-- deferrable constrains umo�n� to �e teraz mn��em robi� update v �ubovo�nom porad�
-- nekontroluje sa d�tov� integrita 

-- toto je default mod, kedy sa d�tov� integrita kontroluje okam�ite 
alter session set constraints=immediate;


-- ====== GENEROVANIE PRIKAZOV POMOCOU PRIKAZOV ======  

-- chcem si vytvori� nov� tabu�ku a naimporova� d�ta pr�kazom SELECT

create table predmety_zaloha (
    cis_predm char(4) primary key,
    nazov varchar2(200)
);

insert into predmety_zaloha values('BI06', 'DBS'); -- nie�o tak�to chcem vygenerova� 

--                                          | tu tie ' musia by� v in�ch ' 
select 'insert into predmety_zaloha values(''' || cis_predm || ''',''' || nazov || ''');'
from predmet;
-- cez kurzor by sa to dalo v�etko vykona� 

-- ak by som to chcel da� do csv
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
    
    --pole.delete; -- zma�e v�etko 
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
-- to ist� 
insert into tab_student select t_student(meno, priezvisko) from os_udaje;

select * from tab_student t;


select t.meno, t.priezvisko, t.tried() rn
 from tab_student t
  order by rn;
  
  
-- OUTER JOIN

select st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania,  count(os_cislo)
from st_odbory left join student using(st_odbor, st_zameranie)
group by st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania;

-- je d�le�it� �i podmienka - rocnik=2 - je vo where alebo v spojen� 
-- (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
-- ak je v spojen�, tak sp�jam tabu�ky iba ak ro�n�k=2 --> podmienka je splnen� 
-- ke� je vo where spracujem v�etky a potom s v�sledku vyberiem kde je splnen� podmienka 
select s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania, count(os_cislo)
 from st_odbory sto left join student s on (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
   where rocnik=2 
  group by s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania; 
  
-- kde sa mi stratili tie dva z�znami ?
-- pri OUTER JOIN nemus�m z�ska� v�etky hodnoty ke� tam d�m NULL


-- vyp�sa� odboru ku ktor�m nem�m �iadnych �tudentov 
select * from st_odbory
where  not exists (select 'x' from student
                    where st_odbory.st_odbor = student.st_odbor
                            and st_odbory.st_zameranie = student.st_zameranie);