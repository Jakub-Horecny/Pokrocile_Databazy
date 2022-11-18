-- pr�ca s tranzakciami

-- tranzakcia je nejak� aktivita ktor� chcem vykona� - m��e by� �spe�n� alebo ne�spe�n� 
-- ak sa tranzakcia s nejak�ho d�vodu nedokon��m, urob�m rollback


-- undo sa nach�dza v - 
-- tranzakcia dosiahla commit - d�ta nemusia by� fyzicky v d�tov�ch blokoch
-- d�ta nemusia reprezentova� tranzakciu T2
-- ak� �trukt�ru vytv�ram paralerne s tranzakciu - logick� �urnal REDU a UNDO
-- 
/*
REDU - je v pam�ti a� do k�m nesprav�m commmit (najnesk�r pri commite) mus�m redu dosta� s pam�te na: online REDU log
UNDO - v�dy na disku

�iadne d�ta sa nepren�aj�, iba sa kop�ruj� 

RECOVERY - oper�cia - zoberiem online REDo log a dostamen db do stavu ak� bola perd hav�riou 

CHECKPOINT referen�n� bod od kedy to mus�me robi� - nerob� ni� s logmi
    prepisuje ich a� ked�potrebuje uvo�mi� diskov� priestor 
    
ak� �truktur� m� logick� �urn�l - ktor� oper�cie treba zapisa� do logu - SELECT,INSERT,UPDATE,DELETE
- pre�o select ked�ni� nemen�m? ob�as ju potrebujem ulo�i� - preto�e m��e modifikova� pam�ov� buffere - bud�ci t��den mi poviete :-)


ked strat�m to �o je v online logu tak datab�zu u� neobnov�m 


Arch�vne loggi - predt�m ak ovyma�em online dock - ulo��m ich do arch�vneho adres�ra
ak by som sa napr�klad potreboval vr�ti� do nejak�ho star�ho stavu
prim�rny ��el je - 


zoberiem z�lohu - zavol�m archivne logi k�m sa nedostanem do p�vodn�ho stavu
backup, arch�vne loggi, online redu - potrebjum v�etky 3, inak datab�zu neobnov�m PRIDEM UPNE O VSETKO
ned� sa vr�ti� iba �as� datab�zy, v�dy v�etky tabu�ky
ke� m�m nov� z�lohu, v�etko star�ie m��em vyhodi� 
*/

-- 16:19
create table studenti_zaloha as select * from student where rocnik=2;
create table predmety as select * from zap_predmety;


drop table predmety;
-- cez rollback t� tabu�ku neobnov�m
-- tabu�ka sa akoby presunie do ko�a - t�m najdem recyklebin name 
-- ak by som dal select * from recyklebin_name tak to p�jde
-- ale ide iba select 
-- flashback table predmety to before drop --> obnov� sa to do stavu ako pred drop
-- cez flashback ju viem aj premenova� -- flashback table predmety to before drom rename to predmety_tab;
-- drop table predmety_tab purge; - tabu�ka nebude v ko�i a u� nejde obnovi�
-- d� sa obnovi� iba cez backup - ni� jednoduch� 

/*
k���ov� slovo - no logging - nad objektom sa navytv�ra ani UNDO ani REDU
pre tabu�ky to nie je dobr� pou��va� - iba tie do�asn� 
na index - pre�o nie 
    negat�va - pri hav�rii sa nastav� na nonusable - zavol�m oper�ciu rebuild 
    pozit�va - zmena d�t bude r�chlej�ia(r�chlos� oper�cie),
*/
drop table studenti_zaloha;

desc studenti_zaloha;

insert into studenti_zaloha select * from student where rocnik <> 2;
commit;
rollback; -- nepom��e mi to, u� som vykonal commit

select log_mode from v$database;

select count(*) from studenti_zaloha;
-- sysdate - interval '10' minute - nem��e to by� sk�r ne� som tabu�ku vytvoril 
flashback table studenti_zaloha to timestamp(sysdate - interval '10' minute); -- nastane chyba 

alter table studenti_zaloha enable row movement; -- row ide sa m��e zmeni� 

-- z�skam d�ta s pred 5 dn� 
select * from student as of timestamp (sysdate - interval '5' day);
-- 37 787 922 244 424
select dbms_flashback.get_system_change_number from dual; -- identifikuje po�et zmien na serveri od is�tal�cie 

-- vlastn�kom tabu�ky je dan� pou��vate�
select * from student;
select * from priklady_db2.studnet; -- vlastn�kom je priklady_db2

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
     
     -- odkazujem sa na tabu�ku �tudent, jej vlatn�kom je priklad_db2
select * from priklad_db2.student@db_link;
-- odkazujem sa na d�ta na vzdialenom serveri 

select * from student@db_link; -- vlastnikom je student09

-- porovn�vam to s os_cislami in�ho pou��vate�a na inom serveri
select * from student
where os_cislo not in (select os_cislo from priklad_db2.student@db_link);

insert into os_udaje select rod_cislo, meno, priezvisko, null, null, null from priklad_db2.os_udaje@db_link
where rod_cislo not in (select rod_cislo from os_udaje);
rollback;

select * from os_udaje;

-- cez db_link sa nedaj� robi� struktur�lne zmeny - alter, drop...

-- vytvorenie lok�lneho s�boru je dobr� na kraj�iu defin�ciu db_link