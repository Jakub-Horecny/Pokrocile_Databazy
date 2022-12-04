-- nie�o o tranzakci�ch 
-- �o je to tranzakcia - z�kladn� jednotka pr�ce
--      zabezpe�uje - atomicita, durability, 

-- na�o m�me tranzakcie? - hl�vn� v�hoda - prev�dza datab�zu z konzistentn�ho stavu do konzistentn�ho stavu, bez toho to neviem zabezpe�i�
-- 

/*
insert
insert
insert
create
insert
insert
rollback

v tabu�ke bud� 3 z�znami, lebo create vytvor� tabu�ku 

rollback pr�kazu - pr�kaz sa nevakon� (napr. pri chybe - tranzakcia sa nevykon�)
napr. ke� m�m v tabu�ke integer a d�m tam varchar




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
end; -- auto commit sa vykon� tu, a� ako posledn� vec 
/

-- ak d�m rollback po proced�re, nebude tam �iadny pr�kaz
-- set autocommit on - vykon� sa po ka�dom bloku pr�kazov, na konci 
set autocommit on;

-- trigger ktor� loguje kto �o vlo�il do tabu�ky - aj ke� sa mu to nepodar� 

create table tab_log_info(
kto varchar(20),
kedy date,
id integer
);

create or replace trigger trig_log
before insert on tab -- je jedno �i after/ before 
    for each row
    declare PRAGMA AUTONOMOUS_TRANSACTION; -- auton�mna tranzakcia - 
begin
    insert into tab_log_info values (user, sysdate, :new.id);
    commit; -- mus tu by� commit 
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
        proc_vloz(2); -- toto sa vykon� v�dy �spe�ne 
    end loop;
    rollback; 
end;
/

select * from tab;
delete tab;
exec proc_vloz2(1);

drop table tab;

-- xml document, ktor� popisuje pr�spevky v modeli soc_poistovna
-- osoby - agregovan� suma a vyp�sa� jednotliv� pr�spevky 
-- strukt�ra je na mne 
-- a� to budem ma�, tak to treba transformova� do JSON 
-- do konca cvika?????









-- 10.1 cvi�enie

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
-- ak� bude obsah tabu�ky ke� sa spustia nasledovn� pr�kazy

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

--(a) commit bude len v proced�ure HLAVNA
select * from pom1; -- 1
select * from pom2; --2

--(b) na konci hlavnej bude rollback a na konci podriadenej bude commit
select * from pom1; -- 1
select * from pom2; --1
-- po INSERT 2 sa zavol� ROLLBACK, preto je tam iba 1 

--(c) na konci hlavnej bude rollback a na konci podriadenej bude commit, ale podriadena bude
--autonomnou transakciou
select * from pom1; -- 1
select * from pom2; --0
-- ROLLBACK sa aplikuje iba na HLAVNA

-- 4. Nastavte AUTOCOMMIT ON a spustite nasledovn� pr�kazy a overte 
--- rozdiel vo�i (AUTOCOMMIT OFF):
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
-- pri proced�rach sa commit vol� a� po skon�en� preced�ry 





