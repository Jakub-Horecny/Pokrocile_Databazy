-------------- indexy 
/* kaûd· datab·za m· v sebe indexy - ulahËuj˙ pr·cu
 pouûÌvaj˙ sa na zv˝öenie v˝konu query 
 PK je automaticky vytvoren˝ index
 vytv·raj˙ sa pomocou b+strom a bitmap index

 B-tree
 dobrÈ pre stÂpce s veæk˝m poËtom unik·tnych d·t 
 pouûÌva sa na usporiadanie veækÈho mnoûstva najme unik·tnych ˙dajov - zefektÌvnenie tranzakciÌ
 
 BitMap index
 - v podstate 2D pole 
 - kaûd˝ stÂpec m· unik·tnu bitov˙ hodnotu 
 - dobrÈ pre stÂpce, kde je m·lo unik·tnych hodnÙt (pohlavie, roËnÌk...)
 */
 
 select * from user_indexes;
 
 select * from p_osoba
 where meno like 'Martin'; -- pouûije sa full scan (z tabuæky som vybral vöetky ˙daje)
 
 -- aj keÔ vytvorÌm index nad 'meno' beriem vöetky z·znami, takûe sa pouûije full scan
 create index soc1 on p_osoba(meno);
 drop index soc1;
 commit;
 
 select meno, priezvisko
 from p_osoba
 where meno = 'Martin';
 
 create index soc2 on p_osoba(meno, priezvisko);
 -- keÔ ale vyber·m iba meno priezvisko, tak uû sa pouûije index
 -- pouûije sa RANGE SCAN
 
 -- ak chcem aj rod_cislo, to Ëi sa pouûije index z·visÌ od poËtu z·znamov v tabuæke
 -- ak je ich m·lo Veselina (1) tak sa pouûije index 
 -- ak je ich vela Martin (309) pouûije sa FULL SCAN
 select meno, priezvisko, rod_cislo
 from p_osoba
 where meno like 'Veselina%';
 
 -- keÔ je % na zaËiatku - FULL scan
 -- keÔ je % na konci - pouûije sa aj index 
 -- ak· vlastnosù indexu sa pouûije? ak˙ vlastnosù m· index na listovej ˙rovni? 
/*
ak je cel˝ z·znam NULL, neviem ho indexovaù
aj je iba meno NULL a priezvisko nie, viem ho indexovaù

na listovej ˙rovni s˙ d·ta zoradenÈ, preto ich viem referencovaù cez % na konci 
keÔ je na zaËiatku, Ëo koævek mÙûe byù na zaËiatku - musÌm priesù cel˝ index 
*/
 

select meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';
create index soc3 on p_osoba(substr(meno,1,1));

-- HINT (n·poveda)
-- poviem systÈmu ktor˝ index pouûiù (teraz sa pouûil neoptim·lny)
-- ak je to napÌsanÈ zle napr: /*index(p_osoba SOC2)*/ systÈm to berie iba ako koment·r 
select /*+index(p_osoba SOC2)*/  meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';


-- eöte lepöÌ index 
create index soc4 on p_osoba(substr(meno,1,1), meno); -- s priezviskom m· rovnakÈ n·klady 
drop index soc4;

select meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';


-- poradie prvkov 
select meno, priezvisko, rod_cislo
from p_osoba
where meno like 'Martin' and substr(rod_cislo, 3, 2) = 10; -- n·klady 13 bez indexu 

-- v podmienke WHERE nez·leûÌ na poradÌ (mÙûem vymeniù meno like a substr a st·le rovnkÈ n·klady;
-- z·leûÌ na poradÌ stÂpcov v indexe 
create index soc5 on p_osoba(meno, priezvisko, rod_cislo);
drop index soc5;

-- pri zmenenom poradÌ nedostanem takÈ dobrÈ n·klady 
create index soc5 on p_osoba(priezvisko, meno, rod_cislo);


-- ZLOZITE SELEKTY

select meno, priezvisko, id_ztp, nazov_postihnutia
from p_osoba
join p_ztp using(rod_cislo)
join p_typ_postihnutia using(id_postihnutia)
where meno like 'Martin' 
and substr(rod_cislo, 3,2) = 10
and id_postihnutia = 1;
-- je dobrÈ si pozrieù pl·n vykon·vania 
-- p_osoba -> p_ztp -> p_typ_posithnutia 

-- p_osoba - meno, rod_cislo, priezvisko (meno, rod_cislo s WHERE priezvisko so SELECT
-- p_ztp - rod_cilo(funkcionalny index) , id_ztp 
-- p_typ_postihnutia - id_postihnutia, nazov_postihnutia (nevyplatÌ sa tam daù iba id_postihnutia, 
                                                        -- preto tam je aj n·zov ) 

create index soc6 on p_osoba(meno, rod_cislo, priezvisko);
create index soc7 on p_ztp(to_number(substr(rod_cislo, 3,2)), id_postihnutia, id_ztp);
-- ak tam bude iba substr(rod_cislo, 3,2) tak to nepomÙûe, lebo v podmienke where
-- porovn·vam reùazec s ËÌslom - mÙûem daù 10 ako '10' alebo to_number 
create index soc8 on p_typ_postihnutia(id_postihnutia, nazov_postihnutia);
drop index soc6;
drop index soc7;
drop index soc8;
-- indexy sa vykonaj˙ postupne poËas vykon·vania celÈho prÌkazu 

/*
FULL SCAN nad indexom, INDEX FULL SCAN, TABLE FULL SCAN
FAST FULL SCAN NAD INDEXOM 
*/


--------------- KOLEKCIE A ZAZNAMI(RECORD) ---------------
/*
RECORD - pouûÌva sa na uchovanie zloûitejöiu ötrukt˙ru d·t aj rÙznych typov 

*/

-- 1 TABLE-BASED RECORD - vöetky atrib˙ty tabuæky sa stan˙ record 
set SERVEROUTPUT on;
declare
    zam p_zamestnanec%rowtype; -- vöetky riadky z tabuæky 
begin
    select * into zam
        from p_zamestnanec
            where rod_cislo = '630909/3230';
    dbms_output.put_line('ICO zamestnavatela: ' || zam.id_zamestnavatela);
    dbms_output.put_line('Rodne cislo: ' || zam.rod_cislo);
    dbms_output.put_line('Zaciatok preca: ' || zam.dat_od);
    dbms_output.put_line('Koniec prace: ' || zam.dat_do);
    dbms_output.put_line('Idcko poistenca: ' || zam.id_poistenca);
end;
/

-- 2 USER-DEFINED record 

declare
    type t_zam is record (
        id p_zamestnanec.id_zamestnavatela%type,
        rc p_zamestnanec.rod_cislo%type
    ); -- vytvorÌm typ premennej
    
    zam t_zam; -- vytvorÌm premenn˙ toho typu 
begin
    select id_zamestnavatela, rod_cislo into zam
        from p_zamestnanec
            where rod_cislo = '630909/3230';
            
    dbms_output.put_line('ID: ' || zam.id);
    dbms_output.put_line('rodne cislo: ' || zam.rc); 
end;
/


-- implicitn· deklar·cia recordu 
-- nie je nutnÈ deklarovaù premnn˙ toho typu 
begin
    for i in (select rod_cislo, meno, priezvisko from os_udaje)
    loop
        dbms_output.put_line('rod_cislo: ' || i.rod_cislo || ' meno: ' || i.meno || ' priezvisko: '
                        || i.priezvisko);
    end loop;
end;
/


-- vkladanie a update pomocou recordov
create table rec_insert(meno varchar2(20), priezvisko varchar2(30));

-- vloûenie do tabuæky 
declare
    rec rec_insert%rowtype; -- premenn· typu tabuæky 
begin
    --for i in 1..10
    --loop
        rec.meno := 'Aneta';
        rec.priezvisko := 'Gabrisova';
        insert into rec_insert values rec;
    --end loop;
end;
/
select * from rec_insert;


-- update tabuæky 
declare
    rec rec_insert%rowtype; -- premenn· typu tabuæky 
begin
    rec.meno := 'Jakub';
    rec.priezvisko := 'HÙreËn˝';
    update rec_insert set row=rec;
end;
/


--ULOHY
--1. pomocou implicitnej deklaracie recordu vypiste mena a priezviska osob osloboden˝ch od platenia 

begin
    for i in (select distinct meno, priezvisko from p_osoba
                join p_poistenie using(rod_cislo)
                where oslobodeny in ('A', 'a'))
    loop
        dbms_output.put_line(i.meno || '  ' || i.priezvisko);
    end loop;
end;
/

-- Ëo ak si deklarujem premennu i v deklaraËnej Ëasti?
DECLARE
    i integer := 10; -- ako sa teraz dostanem k tejto hodnote, keÔ sa vol· rovnako ako vo for
begin
    for i in (select distinct meno, priezvisko from p_osoba
                join p_poistenie using(rod_cislo)
                where oslobodeny in ('A', 'a'))
    loop
        dbms_output.put_line(i.meno || '  ' || i.priezvisko);
        dbms_output.put_line(i); -- takto to nepÙjde, i vo for prer˝va i v declare
        -- ak by som sa chcel na i odkazovaù tu, musel by som si pomenovaù jednotlivÈ bloky kÛdu 
    end loop;
    dbms_output.put_line(i); -- takto to pÙjde
end;
/

-- 3. pomocou recordu vypÌöte nazov a adresu zamestnavatela, ktoreho ICO je 12345678

declare
    type t_rec is record (
        t_nazov p_zamestnavatel.nazov%type,
        t_psc p_zamestnavatel.psc%type,
        t_ulica p_zamestnavatel.ulica%type
    );
    rec t_rec;   
begin
    select nazov, psc, ulica into rec
        from p_zamestnavatel
           where ico = '12345678';
    dbms_output.put_line('Nazov: ' || rec.t_nazov);
    dbms_output.put_line('psc: ' || rec.t_psc);
    dbms_output.put_line('ulica: ' || rec.t_ulica);
end;
/

-- record mÙûe drûaù iba jeden z·znam, ak chcem viac, musÌm vytvoriù kolekciu 
declare
    type t_rec is record (
        t_nazov p_zamestnavatel.nazov%type,
        t_psc p_zamestnavatel.psc%type,
        t_ulica p_zamestnavatel.ulica%type
    );
    type p_rec is table of t_rec;
    rec p_rec;
begin
    -- treba tu pouûiù bulk collect
    select nazov, psc, ulica bulk COLLECT into rec
        from p_zamestnavatel;
        
    for i in rec.first..rec.last
    loop
        dbms_output.put_line('Nazov: ' || rec(i).t_nazov);
        dbms_output.put_line('psc: ' || rec(i).t_psc);
        dbms_output.put_line('ulica: ' || rec(i).t_ulica);
    end loop;
end;
/

-- KOLEKCIE 
-- usporiadan· mnoûina elementov rovnakÈho typu
-- kaûd˝ element m· unik·tny index, ktor˙ udrûuje jeho pozÌciu v kolekcii

/*
    TYPY kolekcii
    1. index-by table 
    neohraniËen˝
    nie je dostupn· v DB
    bez konötruktora
    mÙûem tam priradiù aj null, ale vypÌöe to pr·zdne reùazce (nespadne to ani keby tam nebolo if osoba.exists(i)then
    prvok v kolekciÌ mÙûe byù null ale kolekcia cel· nemÙûe byù NULL
*/

declare
    type t_os is table of p_osoba%rowtype index by binary_integer; -- mÙûe tam byù aj in˝ typ indexu
    osoba t_os;
    counter int := 1;
begin
    -- osoba := null; -- toto nemÙûem spraviù
    for i in (select * from p_osoba where meno='Jozef')
    loop
        osoba(counter) := i; 
        counter := counter + 1;
    end loop;
    
    for i in osoba.first..osoba.last
    loop
        if osoba.exists(i)then
            dbms_output.put_line(osoba(i).meno || ' ' || osoba(i).priezvisko);
        end if; 
    end loop;
end;
/

/*
    2. nested table
    neohraniËen· kolekcia 
    je dostupn· v DB
    m· konötruktor - nemusÌm ho explicitne napÌsaù, ale systÈm ho zavol· napr. BULLK COLLECT INTO
    pr·zdny element je null
    cel· mÙûe byù null
    
*/

declare
    type t_os is table of p_osoba%rowtype; -- mÙûe tam byù aj in˝ typ indexu
    osoba t_os := t_os();
begin
    -- osoba := null; -- toto nemÙûem spraviù
    for i in (select * from p_osoba where meno='Maria')
    loop
        osoba.extend; 
        osoba(osoba.last) := i;
    end loop;
    
    for i in osoba.first..osoba.last
    loop
        if osoba.exists(i)then
            dbms_output.put_line(osoba(i).meno || ' ' || osoba(i).priezvisko);
        end if; 
    end loop;
end;
/

declare
    type t_os is table of p_osoba%rowtype; -- mÙûe tam byù aj in˝ typ indexu
    osoba t_os;
begin
    select * bulk collect into osoba from p_osoba; -- nezavola som konötruktor explicitne, ale aj tak sa zavol·
    
    for i in osoba.first..osoba.last
    loop
        if osoba.exists(i)then
            dbms_output.put_line(osoba(i).meno || ' ' || osoba(i).priezvisko);
        end if; 
    end loop;
end;
/


/*
    3. varray
    ohraniËen· kolekcia
    dostupn· v DB
    s konstruktorom
    prazdny element je null
    nemozem mazat jednotlivÈ elementy, iba cel˙ kolekciu 
*/

DECLARE
    type t_os is varray(30) of p_osoba%rowtype;
    os t_os := t_os();
begin
    for i in (select 
                    rod_cislo, meno, priezvisko, psc, ulica 
                from (
                    select o.*, ROW_NUMBER() OVER (order by rod_cislo) rn
                    from p_osoba o)
                where rn <= 30)
    loop
        os.extend;
        os(os.last) := i;
    end loop;
    
    for i in os.first..os.last
    loop
        dbms_output.put_line(os(i).meno || ' ' || os(i).priezvisko);
    end loop;
end;
/

-- deklarovat kolekciu ËÌsel nested table a potlaËiù duplicity 
declare
    type t_cislo is table of integer;
    cislo t_cislo := t_cislo(5,4,1,5,4,6,7,6,4,7,7,7,8,7,7, null, null, 3);
    cislo2 t_cislo := t_cislo();
    rovnake boolean := false;
begin
    for i in cislo.first..cislo.last
    loop
        if cislo2.count = 0 then
            cislo2.extend;
            cislo2(cislo2.last) := cislo(i);
        else
            
            for j in cislo2.first..cislo2.last
            loop
                if cislo(i) = cislo2(j) then
                    rovnake := true;
                    exit;
                end if;
            end loop;
            
            if rovnake = false then
                cislo2.extend;
                cislo2(cislo2.last) := cislo(i);
            end if;
            rovnake := false;
        end if;
    end loop;
    
    for i in cislo2.first..cislo2.last
    loop
        dbms_output.put_line(cislo2(i));
    end loop;  
end;
/

-- ULOHY
-- 1.) vytvorte kolekciu index-by table do ktorej vlozite sumy z tabulky p_prispevky
-- 2.) vypocitajte celkovu sumu, kttora bola vyplatena na prispevkoch pre ZTP
-- 3.) urobte to pre vsetky typy kolekcii 




--- inÈ veci 


-- ak˝ bude v˝sledok vypÌsan˝ po spustenÌ nasledovn˝ch prÌkazov?

create table pom1 (id integer);
insert into pom1 values(1);
insert into pom1 values(2);
savepoint sp1;
insert into pom1 values(3);
insert into pom1 values(4);
savepoint sp2;
insert into pom1 values(5);
insert into pom1 values(6);

rollback to sp1; -- vr·tim sa do bodu, keÔ som do tabuæky vloûil iba 2 prvky
rollback to sp2; -- uû neexistuje, lebo sa vytvoril aû po sp1 --> d· chybu 
select count(*) from pom1; -- 2 z·znami pred vytvorenÌm sp1




-- ak m·me nasledovn˙ postupnosù prÌkazov
create table pom1 (id integer);
insert into pom1 values(10);
insert into pom1 values(20);
savepoint sp1;
insert into pom1 values(30);
savepoint sp2;
insert into pom1 values(40);
rollback to sp1;

--Ëo spÙsobÌ nasleduj˙ci prÌkaz?
rollback to sp2;

-- ERROR, lebo po rollback to sp1, savepoint sp2 prest·va existovaù 




-- Ëo vypÌöe nasleduj˙ci blok prÌkazov (neviem Ëi je to celÈ)
set autocommit on;

create table pom1 (id integer);

create procedure proc1 as
begin
    insert into pom1 values(20);
    commit;
end;
/

create or replace procedure proc2 as
begin
    for i in 1..10
    loop
         --insert into pom1 values(i);
         proc1;
    end loop;
    rollback;
end;
/


exec proc2;
select count(*) from pom1;


-- Ëo sa stane ak pouûijem HINT append

select * from osoba;
insert /*+APPEND*/ into osoba;


-- 9. »o platÌ pre uvedenÈ premennÈ? 
Select count(*) from p_poistenie 
JOIN p_odvod_platba using(id_poistenca); -- 68164

Select count(*) from p_poistenie 
JOIN p_odvod_platba using(id_poistenca) 
JOIN p_zamestnavatel ON ( id_platitela = ICO ); --59020

Select count(*) from p_poistenie 
JOIN p_odvod_platba using(id_poistenca) 
LEFT JOIN p_zamestnavatel ON ( id_platitela = ICO ); -- 68164

Select count(*) from p_poistenie 
JOIN p_odvod_platba using(id_poistenca) 
where id_platitela IN ( select ico from p_zamestnavatel); -- 59020



select rod_cislo, meno, priezvisko, sum(suma) 
from p_osoba 
JOIN p_poistenie USING ( rod_cislo ) 
JOIN p_odvod_platba USING ( id_poistenca )
where to_char(obdobie, 'YYYY') = 2016 
group by rod_cislo, meno, priezvisko ; --137

drop index ind1;
create index ind1 on p_odvod_platba(to_number(to_char(obdobie, 'YYYY')), id_poistenca, suma); --33 


declare
    type t_int is table of integer;
    kol t_int := t_int(10,20,30,40,50);
begin
    dbms_output.put_line(kol.count);
    dbms_output.put_line(kol.last);
    kol.delete(2);
    dbms_output.put_line(kol.count);
    dbms_output.put_line(kol.last);
end;
/

set autocommit off;--toto sposobÌ ûe za kaûd˝m blokom prÌkazov bude comit
create table pom(id integer);

drop table pom;

create or replace procedure proc1 as 
begin
for i in 1 ..10
loop
insert into pom values(i);
end loop;
rollback; 
end;
/ 

create or replace procedure proc2 as
begin
proc1;
insert into pom values(20);
end;
/
exec proc2;
select * from pom;

delete pom;
drop table pom;

Select meno, priezvisko, id_poistenca, dat_od
	from p_osoba join p_poistenie using(rod_cislo)
	where dat_do is null; -- 30

commit;
create index ind1 on p_osoba(meno, priezvisko);
create index ind2 on p_poistenie(rod_cislo);
drop index ind2;

declare 
     type t_pole is table of integer; 
     i integer; pole t_pole;
     j integer; 
begin 
    pole := t_pole(1,2,3,4,5,6,7,8); 
    pole.delete(3); 
    j := pole.first; 
    for i in 1..pole.last 
    loop 
        dbms_output.put_line(pole(j)); 
        j := pole.next(j);
 	end loop; 
end; 


