-- indexi 

--drop table uniza_tab;

create table uniza_tab
(
  os_cislo integer primary key, 
  nadriadeny integer, 
  meno varchar(50), 
  priezvisko varchar(50), 
  org_zlozka varchar(50)
);

alter table uniza_tab add constraint uniza_fk foreign key (nadriadeny) references uniza_tab(os_cislo);

insert into uniza_tab
 values(1, null, 'Jan', 'Celko', 'rektorat');
 
insert into uniza_tab
 values(2, 1, 'Karol', 'Matiasko', 'Oddelenie pre inf. systemy');
 
insert into uniza_tab
 values(3, 1, 'Pavol', 'Rafajdus', 'Oddelenie vedy a vyskumu'); 
 
insert into uniza_tab
 values(4, 1, 'Andrej', 'Czan', 'Oddelenie pre rozvoj'); 
 
insert into uniza_tab
 values(5, 2, 'Dagmar', 'Komarek', 'Oddelenie pre inf. systemy');
 
insert into uniza_tab
 values(6, 2, 'Dasa', 'Zidekova', 'Oddelenie pre inf. systemy');
 
insert into uniza_tab
 values(7, 2, 'Irena', 'Kubinova', 'Oddelenie pre inf. systemy'); 
 
insert into uniza_tab
 values(8, 1, 'Emil', 'Krsak', 'dekanat FRI'); 

insert into uniza_tab
 values(9, 8, 'Viliam', 'Lendel', 'dekanat FRI'); 
 
insert into uniza_tab
 values(10, 8, 'Peter', 'Marton', 'dekanat FRI');
 
insert into uniza_tab
 values(11, 8, 'Michal', 'Kohani', 'dekanat FRI');

insert into uniza_tab
 values(12, 8, 'Vitaly', 'Levashenko', 'KI FRI'); 
 
insert into uniza_tab
 values(13, 12, 'Miroslav', 'Kvassay', 'KI FRI');  
 
insert into uniza_tab
 values(14, 12, 'Marek', 'Kvet', 'KI FRI');   
 
insert into uniza_tab
 values(15, 12, 'Michal', 'Kvet', 'KI FRI'); 
 
insert into uniza_tab
 values(16, 15, 'Roman', 'Ceresnak', 'KI FRI');   
 
insert into uniza_tab
 values(17, 15, 'Veronika', 'Salgova', 'KI FRI');   
 
insert into uniza_tab
 values(18, 15, 'Martina', 'Hrinova', 'KI FRI');  
 
insert into uniza_tab
 values(19, 8, 'Ludmila', 'Janosikova', 'KI FRI');  
 
insert into uniza_tab
 values(20, 8, 'Norbert', 'Adamko', 'KI FRI');  
 
insert into uniza_tab
 values(21, 20, 'Andrea', 'Galadikova', 'KI FRI');   

insert into uniza_tab
 values(22, 8, 'Jaroslav', 'Janacek', 'KI FRI');
 
insert into uniza_tab
 values(23, 8, 'Peter', 'Jankovic', 'KI FRI'); 
 
COMMIT;

-- nadriaden� ku ka�dej osobe 
select osoba.meno, osoba.priezvisko, veduci.meno, veduci.priezvisko
from uniza_tab osoba
left join uniza_tab veduci on(osoba.nadriadeny = veduci.os_cislo);

-- podriaden� ku ka�dej osobe 
select osoba.meno, osoba.priezvisko, podriadeny.meno, podriadeny.priezvisko
from uniza_tab osoba
left join uniza_tab podriadeny on(osoba.os_cislo = podriadeny.nadriadeny);

-- t� �o maj� rovnakeho nadriaden�ho 
select osoba.meno, osoba.priezvisko, kolega.meno, kolega.priezvisko
from uniza_tab osoba
left join uniza_tab kolega on(osoba.nadriadeny = kolega.nadriadeny)
where 
    osoba.os_cislo <> kolega.os_cislo
    or
        kolega.os_cislo is null
order by osoba.meno; -- nie je tu osoba ktor� nem� nadriaden�ho 


select osoba.meno, osoba.priezvisko, listagg(kolega.meno || ' ' || kolega.priezvisko, ', ') 
                                                within group (order by kolega.os_cislo)
from uniza_tab osoba
left join uniza_tab kolega on(osoba.nadriadeny = kolega.nadriadeny)
where osoba.os_cislo <> kolega.os_cislo or kolega.os_cislo is null
group by osoba.meno, osoba.priezvisko, kolega.os_cislo
order by osoba.meno;

-- mus�me definova� poradie krokov - pl�n vykonania - ke� to spust�m viac kr�t, vykon� sa to rovnako 
-- hierarchia selektu 
-- univerz�lne rie�enie 


-- hierarchia celej univerzity 
select lpad(' ', 2*level) || os_cislo || ': ' || meno || ' ' || priezvisko
from uniza_tab u
start with os_cislo = 1 -- lebo nem� �iadneho nadriaden�ho 
connect by prior os_cislo=nadriadeny;
--order by level;


-- Iba hierarchia FRI
-- vyhlad�m si iba dekana 
select lpad(' ', 2*level) || os_cislo || ': ' || meno || ' ' || priezvisko
from uniza_tab u
start with os_cislo > 8 -- lebo nem� �iadneho nadriaden�ho 
connect by prior os_cislo=case when os_cislo=nadriadeny then -1 else nadriadeny end;
-- kedy to nebude fungova�? ke� tam niekto nebude na niekoha 
-- keby som s�m sebe nadriaden�, zacykl� sa to 

update uniza_tab set nadriadeny=1 where os_cislo=1; -- zacykl� sa to 
-- syst�m to vie zisti�, aby to ne�lo do nekone�na

-- da� tam podmienku? -nie, najsk�r rie�im hierarchiu, a� potom podmienku
-- m��em to cel� obali� do SELECT, ale nevyp�em rektora 
-- d�m tam case: connect by prior os_cislo=case when os_cislo=nadriadeny then -1 else nadriadeny end;


-- indexy 
-- F6 l�n vykonanie 

-- �i sa pou�ije index, alebo sekven�n� prehlad�vanie 
select meno, priezvisko
from os_udaje
where meno='Peter';

create index ind1 on os_udaje(meno, priezvisko); -- prv� to �o je v pl�ne vykonania 
drop index ind1;
create index ind1 on os_udaje(priezvisko, meno);
create index ind1 on os_udaje(meno);

select /*+INDEX(os_udaje ind1)*/ meno, priezvisko
from os_udaje o
where meno = 'Peter'; -- ke� tam d�m alias, u� to berie iba ako koment�r, nie n�povedu

-- ke� je m�lo d�t, nie je ve�k� rodieml medzi pou�it�m indexu a prehladan�m celej tabu�ky 


select os_cislo, rocnik
from student
where to_char(dat_zapisu, 'YYYY') = '2003';

create index ind2 on student(dat_zapisu, os_cislo, rocnik);-- na porad� v selecte nez�le�i, optimaliz�tor si to vie prehodie� 
-- nebude sa to pou��va�, treba da� cel� funkciu do indexu
create index ind2 on student(to_char(dat_zapisu, 'YYYY'), os_cislo, rocnik); -- ak tam d�m RRRR namiesto YYYY tak sa nebude pou��va�
-- e�te treba da� '2003'
drop index ind2;

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where meno = 'Peter';

-- mo�nosti 3 met�dy 
-- LEFT JOIN (nem��em pou�i�, nad FK nem�m index)
-- nested loop
-- hash join

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where rod_cislo = '841106/3456';
-- pou�ije sa in� prstup - nad rod_cislo u� je syst�mov� index
-- vyberie si pod�a n�kladov 

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where rocnik =2;

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where to_char(dat_zapisu, 'RRRR') = '2003';

-- treba si uvedomi� �e nad FK nem�m index, mus�m j uprehlada� cel�
-- u� ide iba o to, �i si ju nejak m��em zmen�i� 
-- zmne�i� mnostvo d�t kde m�m index mi moc nep�m��e
-- pom�ha to iba v tabu�k�ch kde nem�m index 

create index ind3 on student(rod_cislo); -- toto nepom��e, lebo v podmienke je v podmienke in� st�pec 
create index ind3 on student(to_char(dat_zapisu, 'RRRR'), rod_cislo); -- toto pom��e

-- na dva rovnak� selekty sa m��e pou�� in� pr�stup - raz index, raz nie
-- optimaliz�tor sa rozhoduje na z�klade �tatist�k - m��u by� in�
-- mno�stvo d�tov�ch blokou m��e by� in�
-- distrib�cia d�t m��e by� in�
-- optimaliz�tor je heuristika, nie optimaliza�n� funkcia 


-- ulohy 
-- 1:)
desc kvet3.osoba_tab

create table osoba_tab as select * from kvet3.osoba_tab;

-- 2. Ko�ko riadkov bolo naimportovan�ch? Ak� �trukt�ru m� tabu�ka?
select count(*) from osoba_tab;
desc osoba_tab;

-- 3. Vytvorte prim�rny k���. Index nech sa zadefinuje implicitne. 
select distinct count(rod_cislo) from osoba_tab;
alter table osoba_tab add primary key(rod_cislo);

-- 4.Vytvorte index nad atrib�tmi meno apriezvisko (v danom porad�). 
create index os_tab1 on osoba_tab(meno, priezvisko);

-- 5. Pok�ste sa vytvori� index nad atrib�tmi priezvisko ameno (v danom porad�). 
-- Je to mo�n�? Ak �no, pre�o, ak nie, pre�o?
create index os_tab2 on osoba_tab(priezvisko, meno);

-- 6 Vyp�te si zoznam vytvoren�ch indexov (user_indexes). 
select * from user_INDEXES where table_name = 'OSOBA_TAB';

-- 7 Ktor� znich je prim�rnym k���om? (user_constraints)
select * from user_INDEXES where table_name = 'OSOBA_TAB';

-- 8 Vyp�te atrib�ty, zktor�ch sa skladaj� jednotliv� indexy? Vakom porad� s� indexovan� atrib�ty? (user_ind_columns)
select * from user_ind_columns where table_name = 'OSOBA_TAB' order by column_position;

-- 9 Vytvorte si tabu�ku muzi_tab, ktor� bude ma� rovnak� �trukt�ru ako tabu�ka osoba_tab, 
-- ale bude obsahova� len �daje o mu�och. Ak� kardinalitu m� vytvoren� tabu�ka? Ak� indexy s� v nej definovan�?
create table muzi_tab as select * from osoba_tab where substr(rod_cislo,3,1) < 2;

-- 10 Vyp�te meno a priezvisko osoby s rodn�m ��slom 660227/4987. 
-- Ak� pr�stupov� met�da bola pou�it�? Ktor� index (ak nejak� pou�it� bol...)
select meno ,priezvisko from muzi_tab where rod_cislo = '660227/4987'; -- TABLE ACCESS

-- 11 Vyp�te �daje(rod_cislo, meno)oosobe,ktorej priezvisko je Jurisin. 
-- Ko�ko z�znamov ste z�skali? Ak� pr�stupov� met�da bola pou�it�? Pre�o?(porovn�vajte na rovnos�)