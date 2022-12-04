-- undo sa v�dy zapisuje do DB na disk 
-- redu je �tandartne v pam�ti do bodu kedy sa tranzakcia ukon�� - potom sa zap�e na disk

-- redu log - zapisujem do DB alebo na disk?
-- nie je to jedno pre obnovu DB

-- online log
-- kedy m��em vymaze� redu? do kedy ho potrebujem?
/*
    keby som ho vymazal po commite a nastane hav�ria syst�mu, tak ho budem potrebova�
    tranzakcie ktor� skon�ili v minulosti �spene�ne potrebujem znovu spusti�, aby DB bola v konzistentnom stave 
    bu� to rob�m od z�lohy, alebo od chceckpoint - zap�e sa to do DB, a to je 
    referen�� bod, od ktor�ho potrebujem tranzakcie obnovi� 
*/

/*
    undo - kedy m��em vymaza�
    undo potrebujem na zru�enie be�iacich tranzakci�, ak nastane hav�ria 
    sna��m sa ich ma� k dispoz�ci� �o najdlh�ie, je to bezpe�n� maza� ke�
    undo potrebujem pre tranzakciu ktor� be��, ako n�hle skon��, m��em ho vymaza�, ale neurob�m to
    ktor� vlastnost tranzakcie potrebuje k �ivotu undo? - izolovanos�
    ak mi nejak� oper�cia trv� dlho a neviem z�ska� d�ta ktor� existovali v minulosti dostanem error 
*/

-- nem��em prep�sa� logi, ktor� sa odkazuj� na akt�vne tranzakcie 
-- bu� roz��rim po�et loggov, alebo po�k�m na dokon�enie tranzakcie 



create table studenti_tab as select * from priklad_db2.student;

select * from student;-- aktualne data 

select log_mode from v$database;-- �i je DB v arch�vnom m�de alebo nie 
-- v$ dynamick� pohlady ktor� nie s� ulo�en� v DB - nie s� to syst�mov� tabu�ky
-- iba poh�ady, ktor� popisuj� aktu�lny stav - pri havarii sa ma��
-- envad� to, lebo iba popisuj� aktu�lny stva DB a in�tanci� 


-- chcem sa pozrie� ako tabu�ky vyzerala pred 1 hodinou 
select * from student as of timestamp(sysdate - interval '1' hour);
-- na za�iatku sa aplikuj� online loggy, a potom arch�vne loggi
-- OBMEDZENIE tabu�ka nesmie zmeni� �trukt�ru - nem��em prida� st�pec

-- pomocou arch�vnych loggov dok�em z�ska� star� d�ta aj po ukon�en� tranzakcie 

delete from student s where s.os_cislo not in (select z.os_cislo from zap_predmety z);


-- obnovie d�t 
-- rozdiel 
insert into student(
select * from student as of timestamp(sysdate - interval '1' hour)
minus
select * from student);

-- aby som to nemusel robi� takto explicitne, m��em pou�i� tranzak�n� loggi a obnov� to tak 
FLASHBACK table zap_predmety to timestamp(sysdate - interval '1' hour);
-- nejde to, lebo m� bloky na fyzickej �rovny - odkazujem sa na ne cez ROWID

alter table zap_predmety enable row movement; -- povolim zmenu ROWID jednotliv�ch z�znamov 
-- teraz mi pr�kaz vy��ie p�jde 


DELETE from studenti_tab;
commit;
select count(*) from studenti_tab;
rollback; -- nepom��e, u� som potvrdil tranzakciu 

-- mus�m urobi� flashback, ale predt�m zapn�� row movement 
FLASHBACK table studenti_tab to TIMESTAMP (sysdate - interval '10' minute);
alter table studenti_tab enable row movement;

-- nev�hoda - vy�aduje row movement
-- m��e to sp�sobi� �e status indexu sa zmen� na invalid 
-- nerob� sa to automaticky, syst�m sa v�dy sn�� zachova� index ak je to mo�n� 
select index_name, status from user_indexes where table_name='STUDENTI_TAB';


-- vytvor�m index na tabulku
CREATE index stud_tab1 on studenti_tab(rocnik);

select * from studenti_tab;
select count(*) from studenti_tab; -- 6946
delete from studenti_tab where rocnik in (0,1);
select count(*) from studenti_tab; -- 810
commit;
rollback; -- nepom��e mi to

FLASHBACK table studenti_tab to TIMESTAMP (sysdate - interval '10' minute);
alter table studenti_tab enable row movement;

alter table studenti_tab move; -- po tomto by bol index UNUSABLE

-- potom ho mus�m REBUILD 
alter index STUD_TAB1 rebuild;

-- ak nad tabulkou nie �s �iadne d�ta, index sa nezmen� na UNUSABLE


-- vieme tabu�ku vr�ti� dostavu hodnoty system change number 
-- nie len �asov� referencia, ale aj na tranzakciu samotn� 
select DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER from dual; -- po�et zmien ktor� sa vykonali 


flashback table studenti_tab to SCN 39052109530130;
alter table studenti_tab enable row movement;








