-- undo sa vdy zapisuje do DB na disk 
-- redu je štandartne v pamäti do bodu kedy sa tranzakcia ukonèí - potom sa zapíše na disk

-- redu log - zapisujem do DB alebo na disk?
-- nie je to jedno pre obnovu DB

-- online log
-- kedy môem vymaze redu? do kedy ho potrebujem?
/*
    keby som ho vymazal po commite a nastane havária systému, tak ho budem potrebova
    tranzakcie ktoré skonèili v minulosti úspenešne potrebujem znovu spusti, aby DB bola v konzistentnom stave 
    buï to robím od zálohy, alebo od chceckpoint - zapíše sa to do DB, a to je 
    referenèí bod, od ktorého potrebujem tranzakcie obnovi 
*/

/*
    undo - kedy môem vymaza
    undo potrebujem na zrušenie beiacich tranzakcií, ak nastane havária 
    snaím sa ich ma k dispozícií èo najdlhšie, je to bezpeèné maza keï
    undo potrebujem pre tranzakciu ktorú beí, ako náhle skonèí, môem ho vymaza, ale neurobím to
    ktorá vlastnost tranzakcie potrebuje k ivotu undo? - izolovanos
    ak mi nejaká operácia trvá dlho a neviem získa dáta ktoré existovali v minulosti dostanem error 
*/

-- nemôem prepísa logi, ktoré sa odkazujú na aktívne tranzakcie 
-- buï rozšírim poèet loggov, alebo poèkám na dokonèenie tranzakcie 



create table studenti_tab as select * from priklad_db2.student;

select * from student;-- aktualne data 

select log_mode from v$database;-- èi je DB v archívnom móde alebo nie 
-- v$ dynamické pohlady ktoré nie sú uloené v DB - nie sú to systémové tabu¾ky
-- iba poh¾ady, ktoré popisujú aktuálny stav - pri havarii sa maú
-- envadí to, lebo iba popisujú aktuálny stva DB a inštancií 


-- chcem sa pozrie ako tabu¾ky vyzerala pred 1 hodinou 
select * from student as of timestamp(sysdate - interval '1' hour);
-- na zaèiatku sa aplikujú online loggy, a potom archívne loggi
-- OBMEDZENIE tabu¾ka nesmie zmeni štruktúru - nemôem prida ståpec

-- pomocou archívnych loggov dokáem získa staré dáta aj po ukonèení tranzakcie 

delete from student s where s.os_cislo not in (select z.os_cislo from zap_predmety z);


-- obnovie dát 
-- rozdiel 
insert into student(
select * from student as of timestamp(sysdate - interval '1' hour)
minus
select * from student);

-- aby som to nemusel robi takto explicitne, môem poui tranzakèné loggi a obnoví to tak 
FLASHBACK table zap_predmety to timestamp(sysdate - interval '1' hour);
-- nejde to, lebo má bloky na fyzickej úrovny - odkazujem sa na ne cez ROWID

alter table zap_predmety enable row movement; -- povolim zmenu ROWID jednotlivıch záznamov 
-- teraz mi príkaz vyššie pôjde 


DELETE from studenti_tab;
commit;
select count(*) from studenti_tab;
rollback; -- nepomôe, u som potvrdil tranzakciu 

-- musím urobi flashback, ale predtım zapnú row movement 
FLASHBACK table studenti_tab to TIMESTAMP (sysdate - interval '10' minute);
alter table studenti_tab enable row movement;

-- nevıhoda - vyaduje row movement
-- môe to spôsobi e status indexu sa zmení na invalid 
-- nerobí sa to automaticky, systém sa vdy snáí zachova index ak je to moné 
select index_name, status from user_indexes where table_name='STUDENTI_TAB';


-- vytvorím index na tabulku
CREATE index stud_tab1 on studenti_tab(rocnik);

select * from studenti_tab;
select count(*) from studenti_tab; -- 6946
delete from studenti_tab where rocnik in (0,1);
select count(*) from studenti_tab; -- 810
commit;
rollback; -- nepomôe mi to

FLASHBACK table studenti_tab to TIMESTAMP (sysdate - interval '10' minute);
alter table studenti_tab enable row movement;

alter table studenti_tab move; -- po tomto by bol index UNUSABLE

-- potom ho musím REBUILD 
alter index STUD_TAB1 rebuild;

-- ak nad tabulkou nie ús iadne dáta, index sa nezmení na UNUSABLE


-- vieme tabu¾ku vráti dostavu hodnoty system change number 
-- nie len èasová referencia, ale aj na tranzakciu samotnú 
select DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER from dual; -- poèet zmien ktoré sa vykonali 


flashback table studenti_tab to SCN 39052109530130;
alter table studenti_tab enable row movement;








