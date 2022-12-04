-------------- indexy 
/* ka�d� datab�za m� v sebe indexy - ulah�uj� pr�cu
 pou��vaj� sa na zv��enie v�konu query 
 PK je automaticky vytvoren� index
 vytv�raj� sa pomocou b+strom a bitmap index

 B-tree
 dobr� pre st�pce s ve�k�m po�tom unik�tnych d�t 
 pou��va sa na usporiadanie ve�k�ho mno�stva najme unik�tnych �dajov - zefekt�vnenie tranzakci�
 
 BitMap index
 - v podstate 2D pole 
 - ka�d� st�pec m� unik�tnu bitov� hodnotu 
 - dobr� pre st�pce, kde je m�lo unik�tnych hodn�t (pohlavie, ro�n�k...)
 */
 
 select * from user_indexes;
 
 select * from p_osoba
 where meno like 'Martin'; -- pou�ije sa full scan (z tabu�ky som vybral v�etky �daje)
 
 -- aj ke� vytvor�m index nad 'meno' beriem v�etky z�znami, tak�e sa pou�ije full scan
 create index soc1 on p_osoba(meno);
 drop index soc1;
 commit;
 
 select meno, priezvisko
 from p_osoba
 where meno = 'Martin';
 
 create index soc2 on p_osoba(meno, priezvisko);
 -- ke� ale vyber�m iba meno priezvisko, tak u� sa pou�ije index
 -- pou�ije sa RANGE SCAN
 
 -- ak chcem aj rod_cislo, to �i sa pou�ije index z�vis� od po�tu z�znamov v tabu�ke
 -- ak je ich m�lo Veselina (1) tak sa pou�ije index 
 -- ak je ich vela Martin (309) pou�ije sa FULL SCAN
 select meno, priezvisko, rod_cislo
 from p_osoba
 where meno like 'Veselina%';
 
 -- ke� je % na za�iatku - FULL scan
 -- ke� je % na konci - pou�ije sa aj index 
 -- ak� vlastnos� indexu sa pou�ije? ak� vlastnos� m� index na listovej �rovni? 
/*
ak je cel� z�znam NULL, neviem ho indexova�
aj je iba meno NULL a priezvisko nie, viem ho indexova�

na listovej �rovni s� d�ta zoraden�, preto ich viem referencova� cez % na konci 
ke� je na za�iatku, �o ko�vek m��e by� na za�iatku - mus�m pries� cel� index 
*/
 

select meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';
create index soc3 on p_osoba(substr(meno,1,1));

-- HINT (n�poveda)
-- poviem syst�mu ktor� index pou�i� (teraz sa pou�il neoptim�lny)
-- ak je to nap�san� zle napr: /*index(p_osoba SOC2)*/ syst�m to berie iba ako koment�r 
select /*+index(p_osoba SOC2)*/  meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';


-- e�te lep�� index 
create index soc4 on p_osoba(substr(meno,1,1), meno); -- s priezviskom m� rovnak� n�klady 
drop index soc4;

select meno, priezvisko
from p_osoba
where substr(meno,1,1) = 'M';


-- poradie prvkov 
select meno, priezvisko, rod_cislo
from p_osoba
where meno like 'Martin' and substr(rod_cislo, 3, 2) = 10; -- n�klady 13 bez indexu 

-- v podmienke WHERE nez�le�� na porad� (m��em vymeni� meno like a substr a st�le rovnk� n�klady;
-- z�le�� na porad� st�pcov v indexe 
create index soc5 on p_osoba(meno, priezvisko, rod_cislo);
drop index soc5;

-- pri zmenenom porad� nedostanem tak� dobr� n�klady 
create index soc5 on p_osoba(priezvisko, meno, rod_cislo);


-- ZLOZITE SELEKTY

select meno, priezvisko, id_ztp, nazov_postihnutia
from p_osoba
join p_ztp using(rod_cislo)
join p_typ_postihnutia using(id_postihnutia)
where meno like 'Martin' 
and substr(rod_cislo, 3,2) = 10
and id_postihnutia = 1;
-- je dobr� si pozrie� pl�n vykon�vania 
-- p_osoba -> p_ztp -> p_typ_posithnutia 

-- p_osoba - meno, rod_cislo, priezvisko (meno, rod_cislo s WHERE priezvisko so SELECT
-- p_ztp - rod_cilo(funkcionalny index) , id_ztp 
-- p_typ_postihnutia - id_postihnutia, nazov_postihnutia (nevyplat� sa tam da� iba id_postihnutia, 
                                                        -- preto tam je aj n�zov ) 

create index soc6 on p_osoba(meno, rod_cislo, priezvisko);
create index soc7 on p_ztp(to_number(substr(rod_cislo, 3,2)), id_postihnutia, id_ztp);
-- ak tam bude iba substr(rod_cislo, 3,2) tak to nepom��e, lebo v podmienke where
-- porovn�vam re�azec s ��slom - m��em da� 10 ako '10' alebo to_number 
create index soc8 on p_typ_postihnutia(id_postihnutia, nazov_postihnutia);
drop index soc6;
drop index soc7;
drop index soc8;
-- indexy sa vykonaj� postupne po�as vykon�vania cel�ho pr�kazu 

/*
FULL SCAN nad indexom, INDEX FULL SCAN, TABLE FULL SCAN
FAST FULL SCAN NAD INDEXOM 
*/


--------------- KOLEKCIE A ZAZNAMI(RECORD) ---------------
/*
RECORD - pou��va sa na uchovanie zlo�itej�iu �trukt�ru d�t aj r�znych typov 

*/

-- 1 TABLE-BASED RECORD - v�etky atrib�ty tabu�ky sa stan� record 
set SERVEROUTPUT on;
declare
    zam p_zamestnanec%rowtype; -- v�etky riadky z tabu�ky 
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
    ); -- vytvor�m typ premennej
    
    zam t_zam; -- vytvor�m premenn� toho typu 
begin
    select id_zamestnavatela, rod_cislo into zam
        from p_zamestnanec
            where rod_cislo = '630909/3230';
            
    dbms_output.put_line('ID: ' || zam.id);
    dbms_output.put_line('rodne cislo: ' || zam.rc); 
end;
/


-- implicitn� deklar�cia recordu 
-- nie je nutn� deklarova� premnn� toho typu 
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

-- vlo�enie do tabu�ky 
declare
    rec rec_insert%rowtype; -- premenn� typu tabu�ky 
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


-- update tabu�ky 
declare
    rec rec_insert%rowtype; -- premenn� typu tabu�ky 
begin
    rec.meno := 'Jakub';
    rec.priezvisko := 'H�re�n�';
    update rec_insert set row=rec;
end;
/


--ULOHY
--1. pomocou implicitnej deklaracie recordu vypiste mena a priezviska osob osloboden�ch od platenia 

begin
    for i in (select distinct meno, priezvisko from p_osoba
                join p_poistenie using(rod_cislo)
                where oslobodeny in ('A', 'a'))
    loop
        dbms_output.put_line(i.meno || '  ' || i.priezvisko);
    end loop;
end;
/

-- �o ak si deklarujem premennu i v deklara�nej �asti?
DECLARE
    i integer := 10; -- ako sa teraz dostanem k tejto hodnote, ke� sa vol� rovnako ako vo for
begin
    for i in (select distinct meno, priezvisko from p_osoba
                join p_poistenie using(rod_cislo)
                where oslobodeny in ('A', 'a'))
    loop
        dbms_output.put_line(i.meno || '  ' || i.priezvisko);
        dbms_output.put_line(i); -- takto to nep�jde, i vo for prer�va i v declare
        -- ak by som sa chcel na i odkazova� tu, musel by som si pomenova� jednotliv� bloky k�du 
    end loop;
    dbms_output.put_line(i); -- takto to p�jde
end;
/

-- 3. pomocou recordu vyp�te nazov a adresu zamestnavatela, ktoreho ICO je 12345678

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

-- record m��e dr�a� iba jeden z�znam, ak chcem viac, mus�m vytvori� kolekciu 
declare
    type t_rec is record (
        t_nazov p_zamestnavatel.nazov%type,
        t_psc p_zamestnavatel.psc%type,
        t_ulica p_zamestnavatel.ulica%type
    );
    type p_rec is table of t_rec;
    rec p_rec;
begin
    -- treba tu pou�i� bulk collect
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
-- usporiadan� mno�ina elementov rovnak�ho typu
-- ka�d� element m� unik�tny index, ktor� udr�uje jeho poz�ciu v kolekcii

/*
    TYPY kolekcii
    1. index-by table 
    neohrani�en�
    nie je dostupn� v DB
    bez kon�truktora
    m��em tam priradi� aj null, ale vyp�e to pr�zdne re�azce (nespadne to ani keby tam nebolo if osoba.exists(i)then
    prvok v kolekci� m��e by� null ale kolekcia cel� nem��e by� NULL
*/

declare
    type t_os is table of p_osoba%rowtype index by binary_integer; -- m��e tam by� aj in� typ indexu
    osoba t_os;
    counter int := 1;
begin
    -- osoba := null; -- toto nem��em spravi�
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
    neohrani�en� kolekcia 
    je dostupn� v DB
    m� kon�truktor - nemus�m ho explicitne nap�sa�, ale syst�m ho zavol� napr. BULLK COLLECT INTO
    pr�zdny element je null
    cel� m��e by� null
    
*/

declare
    type t_os is table of p_osoba%rowtype; -- m��e tam by� aj in� typ indexu
    osoba t_os := t_os();
begin
    -- osoba := null; -- toto nem��em spravi�
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
    type t_os is table of p_osoba%rowtype; -- m��e tam by� aj in� typ indexu
    osoba t_os;
begin
    select * bulk collect into osoba from p_osoba; -- nezavola som kon�truktor explicitne, ale aj tak sa zavol�
    
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
    ohrani�en� kolekcia
    dostupn� v DB
    s konstruktorom
    prazdny element je null
    nemozem mazat jednotliv� elementy, iba cel� kolekciu 
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

-- deklarovat kolekciu ��sel nested table a potla�i� duplicity 
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




--- in� veci 


-- ak� bude v�sledok vyp�san� po spusten� nasledovn�ch pr�kazov?

create table pom1 (id integer);
insert into pom1 values(1);
insert into pom1 values(2);
savepoint sp1;
insert into pom1 values(3);
insert into pom1 values(4);
savepoint sp2;
insert into pom1 values(5);
insert into pom1 values(6);

rollback to sp1; -- vr�tim sa do bodu, ke� som do tabu�ky vlo�il iba 2 prvky
rollback to sp2; -- u� neexistuje, lebo sa vytvoril a� po sp1 --> d� chybu 
select count(*) from pom1; -- 2 z�znami pred vytvoren�m sp1




-- ak m�me nasledovn� postupnos� pr�kazov
create table pom1 (id integer);
insert into pom1 values(10);
insert into pom1 values(20);
savepoint sp1;
insert into pom1 values(30);
savepoint sp2;
insert into pom1 values(40);
rollback to sp1;

--�o sp�sob� nasleduj�ci pr�kaz?
rollback to sp2;

-- ERROR, lebo po rollback to sp1, savepoint sp2 prest�va existova� 




-- �o vyp�e nasleduj�ci blok pr�kazov (neviem �i je to cel�)
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


-- �o sa stane ak pou�ijem HINT append

select * from osoba;
insert /*+APPEND*/ into osoba;


-- 9. �o plat� pre uveden� premenn�? 
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

set autocommit off;--toto sposob� �e za ka�d�m blokom pr�kazov bude comit
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


