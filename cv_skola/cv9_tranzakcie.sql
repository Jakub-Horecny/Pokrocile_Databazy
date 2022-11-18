-- práca s tranzakciami

-- tranzakcia je nejaká aktivita ktorú chcem vykona - môe by úspešná alebo neáspešná 
-- ak sa tranzakcia s nejakého dôvodu nedokonèím, urobím rollback


-- undo sa nachádza v - 
-- tranzakcia dosiahla commit - dáta nemusia by fyzicky v dátovıch blokoch
-- dáta nemusia reprezentova tranzakciu T2
-- akú štruktúru vytváram paralerne s tranzakciu - logickı urnal REDU a UNDO
-- 
/*
REDU - je v pamäti a do kım nespravím commmit (najneskôr pri commite) musím redu dosta s pamúte na: online REDU log
UNDO - vdy na disku

iadne dáta sa neprenášajú, iba sa kopírujú 

RECOVERY - operácia - zoberiem online REDo log a dostamen db do stavu aká bola perd haváriou 

CHECKPOINT referenènı bod od kedy to musíme robi - nerobí niè s logmi
    prepisuje ich a ked¡potrebuje uvo¾mi diskovı priestor 
    
akú štrukturú má logickı urnál - ktoré operácie treba zapisa do logu - SELECT,INSERT,UPDATE,DELETE
- preèo select ked¡niè nemením? obèas ju potrebujem uloi - pretoe môe modifikova pamäové buffere - budúci tıden mi poviete :-)


ked stratím to èo je v online logu tak databázu u neobnovım 


Archívne loggi - predtım ak ovymaem online dock - uloím ich do archívneho adresára
ak by som sa napríklad potreboval vráti do nejakého starého stavu
primárny úèel je - 


zoberiem zálohu - zavolám archivne logi kım sa nedostanem do pôvodného stavu
backup, archívne loggi, online redu - potrebjum všetky 3, inak databázu neobnovım PRIDEM UPNE O VSETKO
nedá sa vráti iba èas databázy, vdy všetky tabu¾ky
keï mám novú zálohu, všetko staršie môem vyhodi 
*/

-- 16:19
create table studenti_zaloha as select * from student where rocnik=2;
create table predmety as select * from zap_predmety;


drop table predmety;
-- cez rollback tú tabu¾ku neobnovím
-- tabu¾ka sa akoby presunie do koša - tám najdem recyklebin name 
-- ak by som dal select * from recyklebin_name tak to pôjde
-- ale ide iba select 
-- flashback table predmety to before drop --> obnovı sa to do stavu ako pred drop
-- cez flashback ju viem aj premenova -- flashback table predmety to before drom rename to predmety_tab;
-- drop table predmety_tab purge; - tabu¾ka nebude v koši a u nejde obnovi
-- dá sa obnovi iba cez backup - niè jednoduché 

/*
k¾úèové slovo - no logging - nad objektom sa navytvára ani UNDO ani REDU
pre tabu¾ky to nie je dobré pouíva - iba tie doèasné 
na index - preèo nie 
    negatíva - pri havárii sa nastaví na nonusable - zavolám operáciu rebuild 
    pozitíva - zmena dát bude rıchlejšia(rıchlos operácie),
*/
drop table studenti_zaloha;

desc studenti_zaloha;

insert into studenti_zaloha select * from student where rocnik <> 2;
commit;
rollback; -- nepomôe mi to, u som vykonal commit

select log_mode from v$database;

select count(*) from studenti_zaloha;
-- sysdate - interval '10' minute - nemôe to by skôr ne som tabu¾ku vytvoril 
flashback table studenti_zaloha to timestamp(sysdate - interval '10' minute); -- nastane chyba 

alter table studenti_zaloha enable row movement; -- row ide sa môe zmeni 

-- získam dáta s pred 5 dní 
select * from student as of timestamp (sysdate - interval '5' day);
-- 37 787 922 244 424
select dbms_flashback.get_system_change_number from dual; -- identifikuje poèet zmien na serveri od istalácie 

-- vlastníkom tabu¾ky je danı pouívate¾
select * from student;
select * from priklady_db2.studnet; -- vlastníkom je priklady_db2

-- aj na semke 

-- potrebujem db link - vytvorenie linku 
create database link db_link
   connect to student09
    identified by student09 using
   '(DESCRIPTION=
    (ADDRESS=
     (PROTOCOL=TCP)
     (HOST=obelix.fri.uniza.sk)
     (PORT=1521))
    (CONNECT_DATA=
     (SERVICE_NAME=orcladm.fri.uniza.sk)))';
     
     -- odkazujem sa na tabu¾ku študent, jej vlatníkom je priklad_db2
select * from priklad_db2.student@db_link;
-- odkazujem sa na dáta na vzdialenom serveri 

select * from student@db_link; -- vlastnikom je student09

-- porovnávam to s os_cislami iného pouívate¾a na inom serveri
select * from student
where os_cislo not in (select os_cislo from priklad_db2.student@db_link);

insert into os_udaje select rod_cislo, meno, priezvisko, null, null, null from priklad_db2.os_udaje@db_link
where rod_cislo not in (select rod_cislo from os_udaje);
rollback;

select * from os_udaje;

-- cez db_link sa nedajú robi strukturálne zmeny - alter, drop...

-- vytvorenie lokálneho súboru je dobré na krajšiu definíciu db_link