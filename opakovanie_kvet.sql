-- VypÌöte osoby, ktorÈ nikdy neboli evidovanÈ ako telesne postihnutÈ. 
select * from
p_osoba o
where not exists (select 'x' from p_ztp z
                    where o.rod_cislo = z.rod_cislo);
-- Ku kaûdÈmu kraju vypÌöte 30% osÙb s najv‰ËöÌmi odvodmi. 

select count(* ) from (
select kraj, poradie,rod_cislo, pocet from(
select n_kraja kraj,rod_cislo, rank() over( partition by n_kraja order by sum(suma) desc) poradie, sum(suma) pocet
    from p_kraj
        join p_okres using(id_kraja)
            join p_mesto using(id_okresu)
                join p_osoba using(PSC)
                    join p_poistenie using(rod_cislo)
                        join p_odvod_platba using(id_poistenca)
            group by n_kraja,rod_cislo
 ) pom where poradie <= 0.3*(select count( distinct rod_cislo) from p_kraj kr
        join p_okres using(id_kraja)
            join p_mesto using(id_okresu)
                join p_osoba using(PSC)
                    join p_poistenie using(rod_cislo)
                        join p_odvod_platba using(id_poistenca) where kr.n_kraja = pom.kraj )
 order by kraj desc, poradie desc)
;

-- Vygenerujte prÌkazy Insert na vloûenie d·t do tabuæky p_osoba z tabuæky 
-- os_udaje v schÈme priklad_db2
select 'insert into p_osoba values(''' || rod_cislo || ''','''
                                        || meno || ''',''' 
                                        || priezvisko || ''','''
                                        || psc || ''','''
                                        || ulica || ''');'
                                    from priklad_db2.os_udaje;
      
-- Vytvorte objektov˝ typ t_zviera, ktor˝ bude obsahovaù aspoÚ 4 atrib˙ty, konötruktor a metÛdu na triedenie. 

-- spÌtaù sa na konötruktor 
create or replace type t_slimak as object
(
  meno varchar(200),
  farba varchar(200),
  vaha number,
  vek integer,
  constructor function t_slimak(meno varchar, farba varchar, vaha number, vek integer)
  return self as result,
  map member function tried return varchar
) not final;
/

declare
    slimak t_slimak := t_slimak();
begin
    dbms_output.put_line('');
end;
/

--alter type t_slimak add MAP member function zorad return varchar cascade;


-- Majme tabuæku objektov typu t_zviera. Vytvorte druh˙ tabuæku, kde bude objektov˝ atrib˙t typu t_zviera. 
-- NapÌöte prÌkaz Select, pomocou ktorÈho vloûÌte d·ta z existuj˙cej tabuæky do novej. 
  
create or replace type t_zviera as object (
    meno varchar2(50)
) not final;
/
-- tabuæka objektov 
create table t_zviera_2 of t_zviera;
-- tabuæka objektovÈho typu
create table t_zviera_3 (
    zviera t_zviera   
);
/
-- TOTO JE IBA INSERT DO TABULKY    
insert into t_zviera_2 values(t_zviera('Pes'));
--  TOTO FUNGUJE 
insert into t_zviera_3 (select * from t_zviera_2);

select * from t_zviera_3;
select t.zviera.meno  from t_zviera_3 t; -- vypÌsanie jednotliv˝ch atrig˙tov 


-- Vygenerujte a spustite prÌkazy na rekompil·ciu vöetk˝ch Vaöich indexov 
-- (user_indexes ñ table_name, index_name) => alter index index_name rebuild;

begin
    for riadok in(select 'alter index ' || index_name || ' rebuild;' prikaz from user_indexes) 
    loop
        execute immediate riadok.prikaz;
    end loop;
end;
/

-- VypÌöte menn˝ zoznam osÙb, za ktorÈ nebolo nikdy platenÈ poistenie 
-- (t.j. buÔ boli oslobodenÈ od platenia poistnÈho, alebo nemaj˙ ûiaden z·znam v tabuæke p_poistenie). 

-- TOTO JE DOBRE
select 
    count(*)
    from (
select distinct
    o.meno,
    o.priezvisko,
    o.rod_cislo
from p_osoba o
left join p_poistenie p on (o.rod_cislo = p.rod_cislo)
where 
p.oslobodeny in ('a', 'A') or
not exists (select 'x' from p_poistenie po
                where o.rod_cislo = po.rod_cislo)
                    order by meno); -- 4478

-- TOTO JE IBA NA KONTROLU
select distinct oslobodeny from p_poistenie;
-- AJ TOTO :-(
select * from p_poistenie where rod_cislo = '555323/0001';

-- Bronislav	Matunak	551214/0001


-- Vytvorte tabuæku teplÙt, v ktorej budete uchov·vaù hodnotu teploty kaûd˙ hodinu. 
-- NapÌöte skript, ktor˝ vygeneruje teplotu pre 2 dni s t˝m, ûe rozdiel teplÙt medzi susedn˝mi hodinami nebude viac ako 2 stupne. 

-- TOTO JE VYTVORENIE TABULKY 
CREATE table t_teplota (
    hodina TIMESTAMP primary key,
    teplota number
);
/

drop table t_teplota;
-- TOTO NAPLNI TABULKU DATAMI NA DVA DNY 
declare
    index_max integer := 48;
    teplota number;
    last_time timestamp;
begin
    --last_time := sysdate;
    teplota := round(dbms_random.value(-10,10),2);
    insert into t_teplota values(sysdate, teplota);
    
    for i in 1..(index_max-1)
    loop
        teplota := teplota + round(dbms_random.value(-2,2),2);
        insert into t_teplota values(sysdate + (1/24) * i, teplota);
    end loop;
end;
/

select * from t_teplota;

select round(DBMS_RANDOM.value,2) from dual;
dbms_random.value(1,10);
select dbms_random.value(-10,10) from dual;

    
-- VypÌöte ötvrt˙ najvyööiu sumu zaplaten˙ na odvodoch pre kaûd˝ ötvrùrok tohto roku. 

select distinct 
    kv, 
    poradie, 
    suma 
from (
    select 
        to_char(dat_platby,'Q') kv, -- takto sa robÌ kvart·l
        cis_platby, 
        dense_rank() over( partition by to_char(dat_platby,'Q') order by suma desc) poradie, 
        suma
    from p_odvod_platba
    where extract(year from dat_platby) = 2016
    order by kv, poradie)
where poradie = 4;


-- ProstrednÌctvom kurzora vypÌöte k jednotliv˝m osob·m dobu, v ktorej boli evidovanÌ ako ZçP. 
-- Ak osoba nebola nikdy evidovan·, tak vypÌöte aspoÚ info o osobe. 
set SERVEROUTPUT on;
declare
    cursor cur is (select o.rod_cislo, 
                        sum(nvl(dat_do,sysdate)-dat_od) pocet_dni 
                        from p_osoba o 
                        left join p_ZTP z on (o.rod_cislo = z.rod_cislo) 
                        group by o.rod_cislo);
begin
    for riadok in cur
    loop
        dbms_output.put_line(riadok.rod_cislo || ': ' || riadok.pocet_dni);
    end loop;
end;
/

-- Vytvorte kolekciu ËÌsel, vygenerujte do nej 100 ËÌsel a prostrednÌctvom 
-- anonymnÈho bloku n·jdite minimum a maximum. Sk˙ste vöetky 3 varianty kolekciÌ. 

declare
    TYPE t_pole IS VARRAY(100) OF NUMBER;
    pole t_pole := t_pole();
    
    TYPE t_table IS table OF NUMBER;
    table2 t_table := t_table();
    
    type t_index_tab is table of NUMBER index by binary_integer;--?
    
    table_max integer := -100000000;
    varray_max integer := -100000000;
    
    table_min integer := 100000000;
    varray_min integer := 100000000;
    
begin
    for i in 1..100
    loop
        pole.extend;
        table2.extend;
        
        pole(pole.last) := dbms_random.value(-10000000,10000000);
        table2(table2.last) := dbms_random.value(-10000000,10000000);
    end loop;

    for i in 1..100
    loop
        -- max
        if pole(i) > varray_max then
            varray_max := pole(i);
        end if;
        
        if table2(i) > table_max then
            table_max := table2(i);
        end if; 
        
        -- min
        if pole(i) < table_min then
            table_min := pole(i);
        end if;
        
        if table2(i) < varray_min then
            varray_min := table2(i);
        end if; 
    end loop;
    
    dbms_output.put_line('MAX vo VARRAY je: ' || varray_max);
    dbms_output.put_line('MAX vo TABLE je: ' || table_max);
    dbms_output.put_line('----------------------------------');
    dbms_output.put_line('MIN vo VARRAY je: ' || varray_min);
    dbms_output.put_line('MIN vo TABLE je: ' || table_min);
    
end;
/

--index table
declare
    type t_pole3 is table of integer index by binary_integer;
   pole3 t_pole3;
    t_min integer:=10000;
    t_max integer:=0;
begin
    for i in 1 .. 100
    loop
        --pole3.extend(1);
        pole3(i):= round(dbms_random.value() * 100) + 1;
        dbms_output.put_line(pole3(i));
    end loop;
    for i in pole3.first .. pole3.last
    loop
        if pole3(i) < t_min then
            t_min := pole3(i);
        end if;
        if pole3(i) > t_max then
            t_max:= pole3(i);
        end if;
    end loop;
    dbms_output.put_line('max: ' || t_max || ' min: ' ||  t_min);
end;
/

-- SPYTAT SA CI TO CHCE CEZ TRIGGER ALE AKO 
-- ZmeÚte hodnotu typu ZçP ñ pÙvodn˙ hodnotu kaûdÈho typu inkrementujte o 1. 
-- Pozor na referenËn˙ integritu. 

create or replace trigger trig_update_typ
    before update on p_typ_postihnutia
for each row
begin
    update p_ztp set id_postihnutia=:new.id_postihnutia where id_postihnutia=:old.id_postihnutia;
end;
/
declare
    t_size integer;
begin
    select count(*) into t_size from p_typ_postihnutia;
    
    for i in 0..t_size
    loop
        update p_typ_postihnutia set id_postihnutia=(t_size-i+1) where id_postihnutia=(t_size-i);
    end loop;
end;
/

rollback;
select * from p_typ_postihnutia;
select * from p_ztp where id_postihnutia = 6;

/*
Pre nasleduj˙ci prÌkaz Select napÌöte deklar·ciu premennej (record),
aby sme tam mohli uloûiù postupne jednotlivÈ z·znamy kurzorom: 
	
    select C_ST_ODBORU, C_SPECIALIZACIE, POPIS_ODBORU, POPIS_SPECIAL, count(os_cislo)
   from priklad_db2.student right join priklad_db2.st_odbory 
                                                             using(C_ST_ODBORU, C_SPECIALIZACIE)
                      group by C_ST_ODBORU, C_SPECIALIZACIE, POPIS_ODBORU, POPIS_SPECIAL;

*/

declare
    TYPE moj_rekord IS RECORD(
        ODBOR priklad_db2.student.C_ST_ODBORU%type,
        SPECIALIZACIA priklad_db2.student.C_SPECIALIZACIE%type,
        P_ODBORU priklad_db2.st_odbory.POPIS_ODBORU%type,
        P_SPECIAL priklad_db2.st_odbory.POPIS_SPECIAL%type,
        pocet integer
    );
    rekord moj_rekord; 
    
   cursor cur is (select C_ST_ODBORU, C_SPECIALIZACIE, POPIS_ODBORU, POPIS_SPECIAL, count(os_cislo)
   from priklad_db2.student right join priklad_db2.st_odbory 
                                                             using(C_ST_ODBORU, C_SPECIALIZACIE)
                      group by C_ST_ODBORU, C_SPECIALIZACIE, POPIS_ODBORU, POPIS_SPECIAL);
begin
    open cur;
    loop
        exit when cur%notfound;
        fetch cur into rekord;
        
        dbms_output.put_line(rekord.ODBOR || '    ' || 
                            rekord.SPECIALIZACIA || '    ' ||
                            rekord.P_ODBORU || '    ' ||
                            rekord.P_SPECIAL || '    ' ||
                            rekord.pocet );
    end loop;
    close cur;
     
end;
/

--Zadefinujte objektov˝ typ t_zamestnanec. 
--Vytvorte kolekciu zamestnancov a naplÚte ju obsahom tabuæky p_zamestnanec. 

declare
    type kol_zam is table of p_zamestnanec%rowtype;
    kolekcia kol_zam:= kol_zam();
begin
    for cur in(select * from p_zamestnanec)
    loop
        kolekcia.extend(1);
        kolekcia(kolekcia.last) := cur;
    end  loop;
end;
/

/*
Vytvorte XML report nasleduj˙cej ötrukt˙ry. 
<osoby>
    <osoba RC=î551224/1234î>
       <meno>Michal</meno>
      <priezvisko>Tester</priezvisko>
     </datum_narodenia>
    </osoba>
    <osoba RC=î570112/7777î>
       <meno>Jana</meno>
      <priezvisko>Bartlov·</priezvisko>
     <datum_narodenia> 12.januar.1957</datum_narodenia>
    </osoba>
</osoby>
Je vyööie uveden˝ XML dokument dobre formulovan˝? Je valÌdny? OdpoveÔ zdÙvodnite. 
*/

select 
XMLRoot(
    XMLElement("osoby", 
                    XMLAGG(
                        XMLElement("osoba", XMLAttributes(rod_cislo as "rc"),
                        XMLForest(meno as "meno",
                                    priezvisko as "priezvisko",
                                    dat as "datum_narodenia"
                                    )
                                )
                       )     
                ), version '1.0' ) as vysledok
    from (select meno, priezvisko, rod_cislo, 
                    to_date(substr(rod_cislo,5,2) || '.' ||
                        mod(substr(rod_cislo,3,2),50) || '.' ||
                        substr(rod_cislo,1,2), 'DD.MM.RR') dat
            from os_udaje);
            /
            
declare
    type t_pole3 is table of integer index by binary_integer;
   pole3 t_pole3;
begin
    for i in 1 .. 5
    loop
        --pole3.extend(1);
        pole3(pole3.count+1):= round(dbms_random.value() * 100) + 1;
        dbms_output.put_line(pole3(i));
    end loop;
        pole3.delete(2);
     dbms_output.put_line('----------------------------------'); 
     dbms_output.put_line((pole3.count));  -- ned· niË 
     dbms_output.put_line(pole3.last); -- toto uû pÙjde

end;
/

----na premyslenie: VypÌöte osoby, ktorÈ 3 mesiace po sebe nezaplatili odvody, hoci mali. 
    
 declare
    cursor cur is select rod_cislo,p.id_poistenca, dat_od ,dat_do, dat_platby, 
                        lead(dat_platby,1) 
                        over(partition by p.id_poistenca order by dat_platby) dp2
                        from p_poistenie p 
                        join p_odvod_platba d on(d.id_poistenca = p.id_poistenca) 
                        order by rod_cislo,p.id_poistenca,dat_platby;                       
    begin
        for i in cur
        loop
            if i.dp2> add_months(i.dat_platby,3)then
                dbms_output.put_line( i.rod_cislo || '  od: ' ||  
                                        i.dat_od || ' platene: ' ||
                                        i.dat_platby || ' a ' || 
                                        i.dp2 || ' do: ' || 
                                        i.dat_do);
             end if;
            
        end loop;
    end;
    /
    
select 
    rod_cislo,
    p.id_poistenca, 
    dat_od ,
    dat_do, 
    dat_platby, 
    lead(dat_platby,1) 
    over(partition by p.id_poistenca order by dat_platby) dp2
from p_poistenie p 
join p_odvod_platba d on(d.id_poistenca = p.id_poistenca) 
order by rod_cislo,p.id_poistenca,dat_platby;