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
 
 -- ================= 5.1.3 =================
 
 --1
 -- vytvorte typ t_adresa s atrib˙tmi ulica, psc, mesto 
 -- procedura vypis pre formatovany vypis adresy 
create or replace type t_adresa as object( 
    ulica varchar2(50),
    psc char(5),
    mesto char(25),
    member procedure vypis -- deklaracia procedury 
)not final; -- not final, ûe sa to d· eöte dediù 
/

-- definicia tela procedury 
create or replace type body t_adresa as
member procedure vypis
is
    begin
        dbms_output.put_line(ulica || ' ' ||
                            psc || ', ' || 
                            mesto);
    end;
end;
/

-- 2
-- vytvorete typ t_osoba s atrib˙tom meno, priezvisko, adresa typu t_adresa
-- vytvorte proceduru vypis_adresu - vypise adresu, meno a priezvisko, 
-- pricom pouzije proceduru vypis atributu adresa 
create or replace type t_osoba as object(
    meno varchar2(50),
    priezvisko varchar2(50),
    adresa t_adresa,
    member procedure vypis_adresu
)not final;
/

create or replace type body t_osoba as
member procedure vypis_adresu
is
    begin
        dbms_output.put(meno || ' ' ||
                            priezvisko || ': ');
        adresa.vypis();
    end;
end;
/

-- v nepomenovanom bloku 
-- vytvorte object OSOBA typu t_osoba - A
-- osobu naplnte udajmi - B
-- vypiste adresu - C
declare
osoba t_osoba;
begin
    osoba := t_osoba('Jozko', 'Dolny', t_adresa('meno ulice', '01340', 'éilina')); -- B
    osoba.vypis_adresu();
end;
/

-- vytvorte tabuæku osby objektoveho typu t_osoba 
/*
create table osoby of t_osoba(primary key (meno)); 
keÔ to spravim takto, tak sa z typu t_osoba vezme stlpec meno, a pouûije ako PK
*/ 
create table osoby of t_osoba;
-- vloste aspoÚ 3 osoby do tabuæky
insert into osoby values('Jozko', 'Dolny', t_adresa('Jozko ulica', '01340', 'éilina'));
insert into osoby values('Jakub', 'Horny', t_adresa('Jakub ulica', '12345', 'Blava'));
insert into osoby values('Janko', 'Stredny', t_adresa('Janko ulica', '99999', 'Kosice'));

-- vypiöte vöetko cez - select *
select * from osoby;

-- vypiste vöetko cez - select value(p)
select value(p) from osoby p;
select 
value(p).meno meno, 
    value(p).priezvisko priezvisko,
    -- value(p).adresa ide tieû 
    value(p).adresa.ulica ulica,
    value(p).adresa.psc psc,
    value(p).adresa.mesto mesto
from osoby p;

-- pomocu procedury vypis_adresu vypÌöte adresy vöetk˝ch æudÌ z tabuæky osoby 
-- 1 pomocou kurzora
declare
cursor cur is (select value(p) from osoby p);
temp_osoba t_osoba;
begin
    open cur;
    loop
        fetch cur into temp_osoba;
        exit when cur%notfound;
        temp_osoba.vypis_adresu();
    end loop;
    close cur;
end;
/

-- 2 pomocou bulk collect 
declare
    type t_pole is table of t_osoba;
    pole t_pole;
begin
    select value(p) bulk collect into pole from osoby p;
    for i in pole.first..pole.last
    loop
        pole(i).vypis_adresu();
    end loop;
end;
/

