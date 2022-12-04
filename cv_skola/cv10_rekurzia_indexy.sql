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

-- nadriadenı ku kadej osobe 
select osoba.meno, osoba.priezvisko, veduci.meno, veduci.priezvisko
from uniza_tab osoba
left join uniza_tab veduci on(osoba.nadriadeny = veduci.os_cislo);

-- podriadenı ku kadej osobe 
select osoba.meno, osoba.priezvisko, podriadeny.meno, podriadeny.priezvisko
from uniza_tab osoba
left join uniza_tab podriadeny on(osoba.os_cislo = podriadeny.nadriadeny);

-- tı èo majú rovnakeho nadriadeného 
select osoba.meno, osoba.priezvisko, kolega.meno, kolega.priezvisko
from uniza_tab osoba
left join uniza_tab kolega on(osoba.nadriadeny = kolega.nadriadeny)
where 
    osoba.os_cislo <> kolega.os_cislo
    or
        kolega.os_cislo is null
order by osoba.meno; -- nie je tu osoba ktorá nemá nadriadeného 


select osoba.meno, osoba.priezvisko, listagg(kolega.meno || ' ' || kolega.priezvisko, ', ') 
                                                within group (order by kolega.os_cislo)
from uniza_tab osoba
left join uniza_tab kolega on(osoba.nadriadeny = kolega.nadriadeny)
where osoba.os_cislo <> kolega.os_cislo or kolega.os_cislo is null
group by osoba.meno, osoba.priezvisko, kolega.os_cislo
order by osoba.meno;

-- musíme definova poradie krokov - plán vykonania - keï to spustím viac krát, vykoná sa to rovnako 
-- hierarchia selektu 
-- univerzálne riešenie 


-- hierarchia celej univerzity 
select lpad(' ', 2*level) || os_cislo || ': ' || meno || ' ' || priezvisko
from uniza_tab u
start with os_cislo = 1 -- lebo nemá iadneho nadriadeného 
connect by prior os_cislo=nadriadeny;
--order by level;


-- Iba hierarchia FRI
-- vyhladám si iba dekana 
select lpad(' ', 2*level) || os_cislo || ': ' || meno || ' ' || priezvisko
from uniza_tab u
start with os_cislo > 8 -- lebo nemá iadneho nadriadeného 
connect by prior os_cislo=case when os_cislo=nadriadeny then -1 else nadriadeny end;
-- kedy to nebude fungova? keï tam niekto nebude na niekoha 
-- keby som sám sebe nadriadenı, zacyklí sa to 

update uniza_tab set nadriadeny=1 where os_cislo=1; -- zacyklí sa to 
-- systém to vie zisti, aby to nešlo do nekoneèna

-- da tam podmienku? -nie, najskôr riešim hierarchiu, a potom podmienku
-- môem to celé obali do SELECT, ale nevypíšem rektora 
-- dám tam case: connect by prior os_cislo=case when os_cislo=nadriadeny then -1 else nadriadeny end;


-- indexy 
-- F6 lán vykonanie 

-- èi sa pouije index, alebo sekvenèné prehladávanie 
select meno, priezvisko
from os_udaje
where meno='Peter';

create index ind1 on os_udaje(meno, priezvisko); -- prvé to èo je v pláne vykonania 
drop index ind1;
create index ind1 on os_udaje(priezvisko, meno);
create index ind1 on os_udaje(meno);

select /*+INDEX(os_udaje ind1)*/ meno, priezvisko
from os_udaje o
where meno = 'Peter'; -- keï tam dám alias, u to berie iba ako komentár, nie nápovedu

-- keï je málo dát, nie je ve¾kı rodieml medzi pouitím indexu a prehladaním celej tabu¾ky 


select os_cislo, rocnik
from student
where to_char(dat_zapisu, 'YYYY') = '2003';

create index ind2 on student(dat_zapisu, os_cislo, rocnik);-- na poradí v selecte nezálei, optimalizátor si to vie prehodie 
-- nebude sa to pouíva, treba da celú funkciu do indexu
create index ind2 on student(to_char(dat_zapisu, 'YYYY'), os_cislo, rocnik); -- ak tam dám RRRR namiesto YYYY tak sa nebude pouíva
-- ešte treba da '2003'
drop index ind2;

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where meno = 'Peter';

-- monosti 3 metódy 
-- LEFT JOIN (nemôem poui, nad FK nemám index)
-- nested loop
-- hash join

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where rod_cislo = '841106/3456';
-- pouije sa inı prstup - nad rod_cislo u je systémovı index
-- vyberie si pod¾a nákladov 

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where rocnik =2;

select meno, priezvisko, os_cislo
from os_udaje
join student using(rod_cislo)
where to_char(dat_zapisu, 'RRRR') = '2003';

-- treba si uvedomi e nad FK nemám index, musím j uprehlada celú
-- u ide iba o to, èi si ju nejak môem zmenši 
-- zmneši mnostvo dát kde mám index mi moc nepômôe
-- pomáha to iba v tabu¾kách kde nemám index 

create index ind3 on student(rod_cislo); -- toto nepomôe, lebo v podmienke je v podmienke inı ståpec 
create index ind3 on student(to_char(dat_zapisu, 'RRRR'), rod_cislo); -- toto pomôe

-- na dva rovnaké selekty sa môe pouí inı prístup - raz index, raz nie
-- optimalizátor sa rozhoduje na základe štatistík - môu by iné
-- mnostvo dátovıch blokou môe by inı
-- distribúcia dát môe by iná
-- optimalizátor je heuristika, nie optimalizaèná funkcia 


-- ulohy 
-- 1:)
desc kvet3.osoba_tab

create table osoba_tab as select * from kvet3.osoba_tab;

-- 2. Ko¾ko riadkov bolo naimportovanıch? Akú štruktúru má tabu¾ka?
select count(*) from osoba_tab;
desc osoba_tab;

-- 3. Vytvorte primárny k¾úè. Index nech sa zadefinuje implicitne. 
select distinct count(rod_cislo) from osoba_tab;
alter table osoba_tab add primary key(rod_cislo);

-- 4.Vytvorte index nad atribútmi meno apriezvisko (v danom poradí). 
create index os_tab1 on osoba_tab(meno, priezvisko);

-- 5. Pokúste sa vytvori index nad atribútmi priezvisko ameno (v danom poradí). 
-- Je to moné? Ak áno, preèo, ak nie, preèo?
create index os_tab2 on osoba_tab(priezvisko, meno);

-- 6 Vypíšte si zoznam vytvorenıch indexov (user_indexes). 
select * from user_INDEXES where table_name = 'OSOBA_TAB';

-- 7 Ktorı znich je primárnym k¾úèom? (user_constraints)
select * from user_INDEXES where table_name = 'OSOBA_TAB';

-- 8 Vypíšte atribúty, zktorıch sa skladajú jednotlivé indexy? Vakom poradí sú indexované atribúty? (user_ind_columns)
select * from user_ind_columns where table_name = 'OSOBA_TAB' order by column_position;

-- 9 Vytvorte si tabu¾ku muzi_tab, ktorá bude ma rovnakú štruktúru ako tabu¾ka osoba_tab, 
-- ale bude obsahova len údaje o muoch. Akú kardinalitu má vytvorená tabu¾ka? Aké indexy sú v nej definované?
create table muzi_tab as select * from osoba_tab where substr(rod_cislo,3,1) < 2;

-- 10 Vypíšte meno a priezvisko osoby s rodnım èíslom 660227/4987. 
-- Aká prístupová metóda bola pouitá? Ktorı index (ak nejakı pouitı bol...)
select meno ,priezvisko from muzi_tab where rod_cislo = '660227/4987'; -- TABLE ACCESS

-- 11 Vypíšte údaje(rod_cislo, meno)oosobe,ktorej priezvisko je Jurisin. 
-- Ko¾ko záznamov ste získali? Aká prístupová metóda bola pouitá? Preèo?(porovnávajte na rovnos)