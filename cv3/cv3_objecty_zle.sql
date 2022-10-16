/*
Indick˝ tutorial 
https://www.youtube.com/watch?v=cv-WdeFLCvk
*/
set SERVEROUTPUT on;
-- vytvorenie vlastnÈho data typu
create or replace type object_type as object(
    obj_id number,
    obj_name varchar2(10)
);
/

-- vytvorenie nested table pre vlastn˝ datatyp 
create or replace type my_nt is table of object_type;
/

-- vytvorenie tabuæky, ktor· obsahuje vlastn˝ data typ
create table base_table(
    tab_id number,
    tab_ele my_nt -- nested table 
)nested table tab_ele store as store_tab_1;
/

-- http://www.rebellionrider.com/how-to-create-nested-table-using-user-define-datatype-in-oracle-database/#.WOZEI9J97RY

 INSERT INTO base_table (tab_id, tab_ele) VALUES
 (1,  -- value for 1st colum 
   My_NT (object_type (1,'Superman')) -- values for 2nd column 
   -- meno nested table pre data type (vlastn˝ data type ( hodnoty datatypu))
 );
 /
 
 -- vypÌöem obsah tabuæky, stÂpec s nestet table vypisuje blbo
 select tab_ele from base_table;
 
 -- select, kde zÌskam inform·cie z nested table 
 SELECT * FROM TABLE(
  SELECT tab_ele FROM Base_Table WHERE tab_id = 1
);
 
 set SERVEROUTPUT on;
-- 5.1.3 objecty
-- 1

-- vytvorte typ t_adresa s atrib˙tmi ulica, psc, mesto 
create or replace type t_adresa as object( -- d· sa pred to daù create or replace 
    ulica varchar2(50),
    psc char(5),
    mesto char(25)
);
/


create or replace type t_adresa_pole is table of t_adresa;
/

-- vytvoriù proced˙ru v˝pis - form·tovan˝ v˝pis adresy 
create or replace procedure vypis(adr t_adresa)
as
-- nested table na uloûenie z·znamov 
--type t_adresa_pole is table of t_adresa;
--pole t_adresa_pole := t_adresa_pole();
begin
    /*
    pole.extend(2);
    pole(1):= t_adresa('meno ulice', '01340', 'éilina');
    pole(2):= t_adresa('meno ulice', '12345', 'Blava');
    
    for i in pole.first..pole.last
    loop
        dbms_output.put_line(pole(i).ulica || ' ' || 
                             pole(i).psc || ', ' || 
                             pole(i).mesto );
    end loop;
    */
    
    dbms_output.put_line(adr.ulica || ' ' || 
                             adr.psc || ', ' || 
                             adr.mesto );
end;
/
exec vypis(t_adresa('meno ulice', '01340', 'éilina'));

-- 2
-- vytvorete typ t_osoba s atrib˙tmi meno, priezvisko, rod cislo , adresa (typu t adresa)
create or replace type t_osoba as object (
    meno varchar(30),
    priezvisko varchar(30),
    adresa t_adresa
);
/

create or replace type t_osoba_pole is table of t_osoba;
/

-- proced˙ru vypis_adresu - v˝pis adresy aj s meno a priezvisko. priËom vyuûijete 
-- proced˙ru vypis atrib˙tu adresa 

create or replace procedure vypis_adresu(os t_osoba) 
as
--type t_osoba_pole is table of t_osoba;
--pole_o t_osoba_pole := t_osoba_pole();

begin
    /*
    pole_o.extend(2);
    pole_o(1) := t_osoba('Jakub', 'horecny', t_adresa('meno ulice', '01340', 'éilina'));
    pole_o(2) := t_osoba('Marek', 'Mokr˝', t_adresa('meno ulice', '12345', 'Blava'));
    
    for i in pole_o.first..pole_o.last
    loop
        dbms_output.put(pole_o(i).meno || ' ' || pole_o(i).priezvisko || ': ');
        vypis(pole_o(i).adresa); -- zavolanie druhej proceduri 
        -- dbms_output.put(pole_o(i).adresa.ulica); -- aj takto to ide 
    end loop;
    */
    dbms_output.put(os.meno || ' ' || os.priezvisko || ': ');
        vypis(os.adresa); -- zavolanie druhej proceduri 
end;
/
exec vypis_adresu(t_osoba('Jakub', 'horecny', t_adresa('meno ulice', '01340', 'éilina')));

-- 3 v nepomenovanom bloku
-- vytvorte object OSOBA typu t_osoba - A
-- osobu naplnte udajmi - B
-- vypiste adresu - C
declare
osoba t_osoba; -- A
begin
    osoba := t_osoba('Jakub', 'horecny', t_adresa('meno ulice', '01340', 'éilina')); -- B
    dbms_output.put_line(osoba.adresa.ulica || ' ' ||
                         osoba.adresa.psc || ', ' ||
                        osoba.adresa.mesto); -- C
end;
/

-- vytvorte tabuæku osoby objektovÈho typu t_osoba (nie tabuæku so stÂpcom objektovÈho typu)
create table osoby of t_osoba;
desc osoby; -- popis tabuæky 

-- vloöte aspoÚ 3 osoby rÙznimi formami insertu 
insert into osoby values('Jakub', 'Horecny', t_adresa('meno ulice', '01340', 'éilina'));
insert into osoby values('Marek', 'Mokr˝', t_adresa('meno ulice222', '12345', 'Blava'));
insert into osoby values('Marek', 'Mokr˝', t_adresa('ulice meno', '99999', 'Kosice'));
-- rovnak˝ zaznam ta viem daù viac kr·t 

-- vypÌöte obsah tabuæky cez select *
select * from osoby;

-- vypiöte obsah tabuæky cez select values(p)
select value(p) from osoby p;
select 
value(p).meno meno, 
    value(p).priezvisko priezvisko,
    value(p).adresa,
    value(p).adresa.psc psc,
    value(p).adresa.mesto mesto
from osoby p;

--pomocou procedury vypis_adresu vypÌöte adresy vöetk˝ch æudÌ z tabuæky osoby
-- ja to robÌm ako anonÌmny blok

-- pomocou kurzora 
declare
    cursor cur is (select 
                    value(p).meno meno,
                    value(p).priezvisko priezvisko,
                    value(p).adresa.ulica ulica,
                    value(p).adresa.psc psc,
                    value(p).adresa.mesto mesto
                from osoby p);
    c_meno osoby.meno%type;
    c_priezvisko osoby.priezvisko%type;
    
    c_ulica osoby.adresa.ulica%type;
    c_psc osoby.adresa.psc%type;
    c_mesto osoby.adresa.mesto%type;
begin
    dbms_output.put_line('Explicitny kurzor');
    open cur;
    loop
        FETCH cur into c_meno, c_priezvisko, c_ulica, c_psc, c_mesto;
        exit when cur%notfound;
        DBMS_OUTPUT.PUT_LINE(c_meno || ' ' ||
                            c_priezvisko || ': ' ||
                            c_ulica || ' ' ||
                            c_psc || ', ' ||
                            c_mesto);
    end loop;
    close cur;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('Implicitny kurzor');
    for os in (select 
                    value(p).meno meno,
                    value(p).priezvisko priezvisko,
                    value(p).adresa.ulica ulica,
                    value(p).adresa.psc psc,
                    value(p).adresa.mesto mesto
                from osoby p)
    loop
        DBMS_OUTPUT.PUT_LINE(os.meno || ' ' ||
                            os.priezvisko || ': ' ||
                            os.ulica || ' ' ||
                            os.psc || ', ' ||
                            os.mesto);
    end loop;
end;
/

-- pomocou bulk collect 
declare
type t_pole is table of t_osoba;
pole t_pole;
begin
    select * bulk collect into pole from osoby;
end;
/