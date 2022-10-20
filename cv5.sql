-- pre kaûd˝ ötudÌjni odbor chcem vypÌsaù poËet ötudentov
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
                
-- koæko m·m A,B...
-- cez vek poËet muûov/ûeny
-- an teste urËite bude nejak· bodobn· piËovina :) 


-- ako niekomu zmeni PK
-- vytvorÌm kÛpiu tabuæky, ale so zmenenÌm PK 
--musÌ byù typu defereble - povoæuje kontrolu referenËn˙ integrity

-- insert update triger

-- v˝poËet v˝ûenhÈötudÌjneho priemeru
-- ako na to?

-- koeficient je zn·mka
-- ects - poËet kredito
-- v menovateli ËÌ ho absolvoval alebo nie - 0/1
-- prblÈm - v menovateli mÙûe byù 0 -- ke¥d to budem deliù, tak ak dostanem 0 v menovateli, tak vypÌöem 999
-- nie je rozsah od 1-4, mÙûe byù aj viac 

-- bereim len predmety z s a E
-- nemaù podiel v menovateli, a ak ·no treba odchitiù v˝nimku 
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
-- JSON a s˙bory tam nebud˙ 

/*
VP = [(K1 * Z1) + (K2 * Z2) + .... + (Kn  * Zn)] : [K1 + K2 + .... + Kn]

VP ñ v·ûen˝ ötudijn˝ priemer
K ñ hodnota kreditov za konkrÈtny predmet
Z ñ ËÌselnÈ vyjadrenie zn·mky za konkrÈtny predmet
*/



-- ===================== PRAKTICKE CVICENIE 5 ========================
-- ötatistika, zmena PK

-- generovanie ötatistiky prÌkazom SELECT
-- pre kaûdÈ mesto poËet ZPT osÙb 
select n_mesta, count(id_ztp) pocet
from p_mesto left join p_osoba using(psc) join p_ztp using(rod_cislo)
group by n_mesta
order by pocet;

-- pre kaûdÈ mesto vypÌsaù koæko m·m æudÌ s jednotliv˝m postihnutÌm 
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

-- v˝poËet v·ûenÈho ötudÌjnÈho priemeru 
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

-- nefunguje spr·vne keÔ chcem prv˝ch troch ötudentov s priemerom pre 
-- kaûd˝ roËnÌk osobytne
select * from kvet3.student;

-- alias sa d· pouûiù pre v˝sledok SELECT -> tabuæka Ëo zvnikne zo SELECTU

-- zmena hodnoty PK
-- chcem zneniù OS ËÌslo uËiteæa 

select * from ucitel;

-- ned· sa to spraviù jednokrokovo priamim update
-- mÙûem napr. pridaù novÈho uËiteæa, zmeniù os_cislo v in˝ch tabuæk·ch, a starÈho
-- vymazaù 
update ucitel set os_cislo='XXXXX' where os_cislo='KI003'; 


-- mÙûem vytvoriù triger, ktor˝ mi zabezpeËÌ kask·du 

-- je mi jedno Ëi to robÌm BEFORE alebo AFTER 
create or replace trigger trig_upd_ucitel
 BEFORE update on ucitel
  for each row
begin
 update zap_predmety set prednasajuci=:NEW.os_cislo where prednasajuci=:OLD.os_cislo;
 update predmet_bod set garant=:NEW.os_cislo where garant=:OLD.os_cislo;
end;
/

update ucitel set os_cislo='KI003' where os_cislo='KXXXX';

-- triger, ktor˝ zmenÌ os_cislo ötudenta 
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


-- triger ktor˝ zmen˝ rod_cislo pre p_osoba 
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
    
-- zruöil som vzùah mnedzi tabuækou uËitel a zap_predmety
alter table zap_predmety drop constraint SYS_C00556387; 
-- treba to spraviù aj nad tabuækou predmet_bod
alter table zap_predmety drop constraint SYS_C00556392; 
-- zruöil som FK

-- datab·za sa teraz nach·dza v nekonzistentnom stave 

-- teraz vytvorÌm vzùah nanovo
alter table zap_predmety add foreign key(prednasajuci) references ucitel(os_cislo) deferrable;
alter table predmet_bod add foreign key(garant) references ucitel(os_cislo) deferrable;

-- deferrable constrains umoûnÌ to ûe teraz mnÙûem robiù update v æubovoænom poradÌ
-- nekontroluje sa d·tov· integrita 

-- toto je default mod, kedy sa d·tov· integrita kontroluje okamûite 
alter session set constraints=immediate;


-- ====== GENEROVANIE PRIKAZOV POMOCOU PRIKAZOV ======  

-- chcem si vytvoriù nov˙ tabuæku a naimporovaù d·ta prÌkazom SELECT

create table predmety_zaloha (
    cis_predm char(4) primary key,
    nazov varchar2(200)
);

insert into predmety_zaloha values('BI06', 'DBS'); -- nieËo takÈto chcem vygenerovaù 

--                                          | tu tie ' musia byù v in˝ch ' 
select 'insert into predmety_zaloha values(''' || cis_predm || ''',''' || nazov || ''');'
from predmet;
-- cez kurzor by sa to dalo vöetko vykonaù 

-- ak by som to chcel daù do csv
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
    
    --pole.delete; -- zmaûe vöetko 
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
-- to istÈ 
insert into tab_student select t_student(meno, priezvisko) from os_udaje;

select * from tab_student t;


select t.meno, t.priezvisko, t.tried() rn
 from tab_student t
  order by rn;
  
  
-- OUTER JOIN

select st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania,  count(os_cislo)
from st_odbory left join student using(st_odbor, st_zameranie)
group by st_odbor, st_zameranie, popis_odboru, popis_zamerania, popis_zamerania;

-- je dÙleûitÈ Ëi podmienka - rocnik=2 - je vo where alebo v spojen˝ 
-- (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
-- ak je v spojenÌ, tak sp·jam tabuæky iba ak roËnÌk=2 --> podmienka je splnen· 
-- keÔ je vo where spracujem vöetky a potom s v˝sledku vyberiem kde je splnen· podmienka 
select s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania, count(os_cislo)
 from st_odbory sto left join student s on (s.st_odbor=sto.st_odbor and sto.st_zameranie=s.st_zameranie)
   where rocnik=2 
  group by s.st_odbor, s.st_zameranie, popis_odboru, popis_zamerania; 
  
-- kde sa mi stratili tie dva z·znami ?
-- pri OUTER JOIN nemusÌm zÌskaù vöetky hodnoty keÔ tam d·m NULL


-- vypÌsaù odboru ku ktor˝m nem·m ûiadnych ötudentov 
select * from st_odbory
where  not exists (select 'x' from student
                    where st_odbory.st_odbor = student.st_odbor
                            and st_odbory.st_zameranie = student.st_zameranie);
                            
                            

-- ========== ULOHY 4 ==================
-- 4.1
--v·ûen˝ ötudijn˝ priemer:
select os_cislo,skrok, (case when men = 0 then 9999 else cit/men end)as priemer from(
    select os_cislo,skrok,sum(citatel)as cit, sum(menovatel) as men from (
    select zp.os_cislo, zp.skrok,
        zp.ects*(case when forma_kont='s' and zp.zapocet is null then
             4
        else
            decode(vysledok,'A',1,'B',1.5,'C',2,'D',2.5,'E',3,4)
        end) as citatel, zp.ects*(case when vysledok in ('A','B','C','D','E') then 1 else 0 end) as menovatel --*(case when vysledok in ('A','B','C','D','E') then 1 else 0 end)
    from zap_predmety zp
        join predmet_bod p on(zp.cis_predm = p.cis_predm)
        where forma_kont in('e','s')   
   ) 
   group by os_cislo,skrok
  )
  order by os_cislo, skrok
;
 
-- 2.) select v selecte 
-- vypÌöte ötudenta s maxim·lnim poËtom kreditov, ak je ich viac vypÌsaù vöetk˝ch   

-- iba max
select 
    *
from (
    select
        o.meno meno,
        o.priezvisko priezvisko,
        s.os_cislo os,
        -- alebo takto? sum(case when z.vysledok in (NULL, 'F') then 0 else z.ects end) pocet
        -- potom by to celÈ muslo Ìsù do -- order by SEM desc
        sum(z.ects) pocet
    from os_udaje o
    join student s on (s.rod_cislo = o.rod_cislo)
    join zap_predmety z on(s.os_cislo = z.os_cislo)
    group by meno, priezvisko, s.os_cislo )
group by meno, priezvisko, os, pocet    -- musÌ tam byù aj 'pocet' lebo dÙvody 
having pocet = (select max(sum(ects)) from zap_predmety
                    group by os_cislo); -- d· ich to viac, ak je ich viac  

select max(sum(ects)) pocet  from zap_predmety
                    group by os_cislo
                    order by pocet;

-- cez analytickÈ funkcie
select 
    *
from (
    select
        o.meno,
        o.priezvisko,
        s.os_cislo,
        -- alebo takto? sum(case when z.vysledok in (NULL, 'F') then 0 else z.ects end) pocet
        -- potom by to celÈ muslo Ìsù do -- order by SEM desc
        sum(z.ects) pocet,
        rank() over (order by sum(z.ects) desc) rn -- musÌ tu byù rank(), aby to vypÌsalo viacer˝ch
    from os_udaje o
    join student s on (s.rod_cislo = o.rod_cislo)
    join zap_predmety z on(s.os_cislo = z.os_cislo)
    group by o.meno,
        o.priezvisko,
        s.os_cislo )
where rn = 1 ; -- rn = 4 je ich viac 

-- 3.) RANK VERZUS ROW_NUMBER   
-- vypÌöte 30% najlepöÌch ötudentov podæa poËtu zÌskan˝ch kreditov s pouûitÌm ROW_NUMBER a RANK

-- ROW_NUMBER
select
    *
from (
    select
        o.meno meno,
        o.priezvisko priezvisko,
        s.os_cislo os_cislo,
        sum(z.ects) pocet,
        ROW_NUMBER() over (order by sum(z.ects) desc) rn
    from os_udaje o
    join student s on (s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
where rn <= (select count(*) from student)*0.3;

-- RANK()
select
    *
from (
    select
        o.meno meno,
        o.priezvisko priezvisko,
        s.os_cislo os_cislo,
        sum(z.ects) pocet,
        RANK() over (order by sum(z.ects) desc) rn
    from os_udaje o
    join student s on (s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
where rn <= (select count(*) from student)*0.3;

-- 4 ötatistika
-- vytvorte pohæad poc_st ötatistika zloûenia fakulti,
-- riadky roËnÌm
-- stÂpce - pracovisk·
-- bunky - poËet ötudentov

select
    rocnik,
    sum(case when substr(st_skupina,2,1) = 'P' then 1 else 0 end) PD,
    sum(case when substr(st_skupina,2,1) = 'Z' then 1 else 0 end) ZA,
    sum(case when substr(st_skupina,2,1) = 'R' then 1 else 0 end) MM
from student
group by rocnik
order by rocnik;

-- ========== 4.2 DOPLNUJUCE ZADANIA ==========

-- 1.) RANDOM
-- vytvorte funkciu daj_heslo(dlzka), ktor· vygeneruje heslo. Pouûite tabuæku na 
-- vytvorenie mnoûiny znakov, z ktorej sa m· heslo generovaù 

-- m·m to ch·paù tak ûe najskÙr treba vytvoriù tabuæku so znakmi, a potom z nej
-- n·hodne vyberaù ?, a m·j˙ to byù iba ËÌsla alebo Ëo???

create table znak (
    id_znak integer NOT NULL PRIMARY KEY,
    znak char(1) NOT NULL
);

drop table znak;
insert into znak(id_znak, znak) values(1, 'a');
insert into znak(id_znak, znak) values(2, 'B');
insert into znak(id_znak, znak) values(3, 'c');
insert into znak(id_znak, znak) values(4, 'd');
insert into znak(id_znak, znak) values(5, 'E');
insert into znak(id_znak, znak) values(6, 'F');
insert into znak(id_znak, znak) values(7, 'g');
insert into znak(id_znak, znak) values(8, 'H');
insert into znak(id_znak, znak) values(9, 'X');
insert into znak(id_znak, znak) values(10, 'Y');
insert into znak(id_znak, znak) values(0, 'O');

select count(*) from znak;

-- ak v tabulke nebude znak z id_znak = 0, tak to nebude fungovaù dobre 
create or replace function daj_heslo(dlzka integer)
return varchar2
as
    max_id integer; 
    heslo varchar2(100); -- chcel som tam daù dlzka ale nejde to 
    temp_znak char(1);
begin
    select count(*) into max_id from znak;
    -- prv˝ znak hesla
    -- keÔ je heslo inicializovanÈ ako '', tak z toho vznikne null, lebo v oracle '' = NULL
    select znak into heslo from znak
            where id_znak = (select floor (DBMS_RANDOM.value*max_id) from dual);
    
    for i in 1..(dlzka-1)
    loop
        select znak into temp_znak from znak
            where id_znak = (select floor (DBMS_RANDOM.value*max_id) from dual);
        heslo := heslo || temp_znak;
    end loop;
    return heslo;
end;
/
select daj_heslo(5) from dual;

-- 2.)
-- vytvorte kÛpiu tabuæky predmet_bod s d·tami skrok = 2008 z priklad_db2.predmet_bod.
create table predmet_bod_copy as (select * from priklad_db2.predmet_bod
                                    where skrok = 2008);
select count(*) from priklad_db2.predmet_bod
    where skrok = 2008; -- 314
select count(*) from predmet_bod_copy; -- 314

-- vygenerujte riadky do tabuæky predmet_bod na rok 2009, priËom predmet BA06 sa neotv·ra
select * from priklad_db2.predmet_bod
    order by skrok desc;

select count(*) from predmet_bod where skrok=2009; --181
-- ja uû tam m·m 2009, preto to urobÌm pre 2010

select * from predmet_bod;

-- bez where, ale s˙ tam iba riadky ktorÈ spÂnaj˙ podmienku 
select 'insert into predmet_bod values(''' || cis_predm || ''',''' 
                                            || 2010 || ''',''' 
                                            || garant || ''','''
                                            || ects || ''','''
                                            || semester || ''','''
                                            || forma_kont || ''');'
from predmet_bod where skrok=2009 and cis_predm <> 'BA06';

-- podmienka where je v retazci ale takto to asi nem· byù 
select 'insert into predmet_bod values(''' || cis_predm || ''',''' 
                                            || 2010 || ''',''' 
                                            || garant || ''','''
                                            || ects || ''','''
                                            || semester || ''','''
                                            || forma_kont || ''')' 
                                            || ' from predmet_bod where skrok=2009 and cis_predm <> ' || '''BA06''' || ';'
from predmet_bod where skrok=2009 and cis_predm <> 'BA06';

-- vzor z prektickÈho cviËenia 
select 'insert into predmety_zaloha values(''' || cis_predm || ''',''' || nazov || ''');'
from predmet;


-- 3.)
-- Zmente poËet kreditov v ök.roku 2008 v tabuæke zap_redmety podæa tabuæky 
-- priklad_db2.predmet_bod(ects)
select * from priklad_db2.predmet_bod
    where skrok = 2008; -- 314
    
select * from predmet_bod
    where skrok = 2008; -- 6
    
/*
BI01	2008	KI001	6	Z	s
BA10	2008	KMM01	6	L	s
BI23	2008	EX001	5	Z	s
BI03	2008	KI001	6	Z	s
BI02	2008	KI001	6	L	s
BI11	2008	EX002	1	Z	z
*/
-- prejdem t˝ch 6 riadkov a upravÌm to 
update predmet_bod p1 set 
p1.ects=(select ects from priklad_db2.predmet_bod p2
            where p1.cis_predm = p2.cis_predm
                and p2.skrok = 2008)
where p1.skrok=2008;

-- na test, lebo po UPDATE som mal rovnakÈ hodnoty kreditov
update predmet_bod set ects=50 where cis_predm = 'BI01' and skrok = 2008;

rollback;


select * from priklad_db2.predmet_bod;

-- 4 zmente rodnÈ ËÌslo ötudentke z 755022/8569 na 755122/8569
-- tak˙ tam nem·m, takûe to bude 850130/3695 na 851130/3695

-- spravÌm to cez triger
create or replace trigger trig_upd_rod_cislo_student
    before update on student -- je jedno Ëi BEFORE alebo AFTER 
for each row
begin
    update os_udaje set rod_cislo=:new.rod_cislo where rod_cislo=:old.rod_cislo;
end;
/

update student set rod_cislo = '851130/3695' where rod_cislo = '850130/3695';
rollback;

select * from student order by rod_cislo;
