-- nieèo o tranzakciách 
-- èo je to tranzakcia - základná jednotka práce
--      zabezpeèuje - atomicita, durability, 

-- naèo máme tranzakcie? - hlávná vıhoda - prevádza databázu z konzistentného stavu do konzistentného stavu, bez toho to neviem zabezpeèi
-- 

/*
insert
insert
insert
create
insert
insert
rollback

v tabu¾ke budú 3 záznami, lebo create vytvorí tabu¾ku 

rollback príkazu - príkaz sa nevakoná (napr. pri chybe - tranzakcia sa nevykoná)
napr. keï mám v tabu¾ke integer a dám tam varchar




*/

create table index_tab (id integer);
create table tab (id integer);
create or replace procedure temp_p
is
begin
    for i in 1..10
    loop
        insert into index_tab values(i);
    end loop;
end;
/

begin
    temp_p;
end; -- auto commit sa vykoná tu, a ako posledná vec 
/

-- ak dám rollback po procedúre, nebude tam iadny príkaz
-- set autocommit on - vykoná sa po kadom bloku príkazov, na konci 
set autocommit on;

-- trigger ktorı loguje kto èo vloil do tabu¾ky - aj keï sa mu to nepodarí 

create table tab_log_info(
kto varchar(20),
kedy date,
id integer
);

create or replace trigger trig_log
before insert on tab -- je jedno èi after/ before 
    for each row
    declare PRAGMA AUTONOMOUS_TRANSACTION; -- autonómna tranzakcia - 
begin
    insert into tab_log_info values (user, sysdate, :new.id);
    commit; -- mus tu by commit 
end;
/

select * from tab;
delete tab;

insert into tab values(1);
insert into tab values(2);

-- 
create or replace procedure proc_vloz(id integer)
is
begin
    for i in 1..10
    loop
        insert into tab values(id * 10);
    end loop;
    commit;
end;
/

create or replace procedure proc_vloz2(id integer)
is
 PRAGMA AUTONOMOUS_TRANSACTION;
begin
    for i in 1..10
    loop
        insert into tab values(id * 10);
        proc_vloz(2); -- toto sa vykoná vdy úspešne 
    end loop;
    rollback; 
end;
/

select * from tab;
delete tab;
exec proc_vloz2(1);

drop table tab;

-- xml document, ktorı popisuje príspevky v modeli soc_poistovna
-- osoby - agregovaná suma a vypísa jednotlivé príspevky 
-- struktúra je na mne 
-- a to budem ma, tak to treba transformova do JSON 
-- do konca cvika?????









-- 10.1 cvièenie

desc student;
create table pom_oc1(id integer not null);
drop table pom_os1;

insert into pom_oc1 values(1);
insert into pom_oc1 values(2);
savepoint sp1;
insert into pom_oc1 values(3);
insert into pom_oc1 values(4);
savepoint sp2;
insert into pom_oc1 values(5);
insert into pom_oc1 values(6);

select * from pom_oc1;
-- akı bude obsah tabu¾ky keï sa spustia nasledovné príkazy

ROLLBACK TO sp1; -- 2

ROLLBACK TO sp2; -- 4

rollback; -- 0

commit; -- 6


-- 10.1.2 Autonomna transakcia, autocommit

--1. Vytvorte dve tabul'ky { pom1 a pom2 s jedinym stlpcom typu integer.

create table pom1(id integer);
create table pom2(id integer);


create or replace procedure podriadena
as
  PRAGMA AUTONOMOUS_TRANSACTION; --3
begin
    insert into pom1 values(100);
    commit; -- 2
end;
/

create or replace procedure hlavna
as
begin
    insert into pom2 values(99999);
    podriadena;
    insert into pom2 values(99999);
    --COMMIT; --1
    rollback; -- 2
end;
/

exec hlavna;
delete pom2;
drop table pom2;
select * from pom1; -- 1
select * from pom2; --2

--(a) commit bude len v procedúure HLAVNA
select * from pom1; -- 1
select * from pom2; --2

--(b) na konci hlavnej bude rollback a na konci podriadenej bude commit
select * from pom1; -- 1
select * from pom2; --1
-- po INSERT 2 sa zavolá ROLLBACK, preto je tam iba 1 

--(c) na konci hlavnej bude rollback a na konci podriadenej bude commit, ale podriadena bude
--autonomnou transakciou
select * from pom1; -- 1
select * from pom2; --0
-- ROLLBACK sa aplikuje iba na HLAVNA

-- 4. Nastavte AUTOCOMMIT ON a spustite nasledovné príkazy a overte 
--- rozdiel voèi (AUTOCOMMIT OFF):
set AUTOCOMMIT ON;
-- a
select * from pom1; -- 1
select * from pom2; --2
-- b
select * from pom1; -- 1
select * from pom2; -- 1
-- c
select * from pom1; -- 1
select * from pom2; -- 0
-- pri procedúrach sa commit volá a po skonèení precedúry 





