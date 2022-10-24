/*<osoby>
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
--vytvorenie tabuæky 

create table xml_osoba of xmltype;

insert into xml_osoba(select 
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
        from os_udaje));
        
delete xml_osoba;

select * from xml_osoba;
select extract(value(o), '//osoba/@rc') from xml_osoba o;
select extract(value(o), '//osoba[@rc="810505/2323"]') from xml_osoba o;
select extractvalue(value(o), '//osoba[@rc="810505/2323"]/meno') meno from xml_osoba o;
-- 810505/2323


/*
<?xml version="1.0"?>
<predmet cislo="A913" nazov="Modelovanie financnych investicii">
    <student>
        <oc>3270</oc>
        <meno>Marian Gazo</meno>
        <skupina>5ZE41</skupina>
    </student>
    <student>
        <oc>2892</oc>
        <meno>Martin Kluka</meno>
        <skupina>5ZE51</skupina>
    </student>
    ...
</predmet>
*/

select 
        XMLRoot(
            XMLElement ("predmet", 
                                XMLAttributes(p.cis_predm as "cislo",
                                                     p.nazov as "nazov"
                                              ),
                                XMLAGG(
                                        XMLElement("student",
                                                    XMLForest(s.os_cislo as "os",
                                                                (o.meno || ' ' || o.priezvisko) as "meno",
                                                                (substr(s.rod_cislo,5,2) || '.' ||
                                                                mod(substr(s.rod_cislo,3,2),50) || '.' ||
                                                                '19' || substr(s.rod_cislo,1,2)) as "datum_narodenia",
                                                                s.st_skupina as "skupina"
                                                              )
                                                    )
                                        )
                                
            ), version '1.0') as s_xml

from os_udaje o
    join student s on(o.rod_cislo = s.rod_cislo)
    join zap_predmety z on(z.os_cislo = s.os_cislo)
    join predmet p on(p.cis_predm = z.cis_predm)
    group by p.cis_predm, p.nazov;


/*
<osoba oc ="123456">
    <meno>Peter</meno>
    <priezv>Novak</priezv>
    <adresa>
        <adr_ulica>Univerzitna</adr_ulica>
        <adr_psc>01001</adr_psc>
        <adr_mesto>Zilina</adr_mesto>
    </adresa>
</osoba>
*/

select
    xmlroot(XMLElement("osoba", XMLAttributes(s.os_cislo as "oc"),
                                XMLForest(o.meno as "meno",
                                          o.priezvisko as "priezvisko"),
                                XMLElement("adresa",
                                            XMLForest(o.ulica as "adr_ulica",
                                                      o.psc as "adr.psc",
                                                      o.obec as "adr.mesto")
                                            )
                        ), version '1.0') as s_xml
from os_udaje o
join student s on(o.rod_cislo = s.rod_cislo);

create table xml_osoby of xmltype;

insert into xml_osoby(
select
    xmlroot(XMLElement("osoba", XMLAttributes(s.os_cislo as "oc"),
                                XMLForest(o.meno as "meno",
                                          o.priezvisko as "priezvisko"),
                                XMLElement("adresa",
                                            XMLForest(o.ulica as "adr_ulica",
                                                      o.psc as "adr.psc",
                                                      o.obec as "adr.mesto")
                                            )
                        ), version '1.0') as s_xml
from os_udaje o
join student s on(o.rod_cislo = s.rod_cislo));

select extract(value(o), '//osoba[@rc="810505/2323"]') from xml_osoba o;

select 
    extractvalue(value(o), '//osoba/@oc') os_cislo,
    extractvalue(value(o), '//meno') meno,
    extractvalue(value(o), '//priezvisko') priezvisko,
    extractvalue(value(o), '//adr_ulica') || ' ' ||
    extractvalue(value(o), '//adr.psc') || ', ' ||
    extractvalue(value(o), '//adr.mesto') adresa
from xml_osoby o
where extractvalue(value(o), '//osoba/@oc') = '501512';

select 
    extract(value(o), '/osoba/@oc') os_cislo,
    extract(value(o), '//meno/text()') meno,
    extract(value(o), '//priezvisko') priezvisko,
    extract(value(o), '//adresa') adresa
from xml_osoby o
where extractvalue(value(o), '/osoba/@oc') = '501512';

select
    xmlroot(XMLElement("osoba", XMLAttributes(os_cislo as "oc"),
                                XMLForest(meno as "meno",
                                          priezvisko as "priezvisko"),
                                XMLElement("adresa",
                                            XMLForest(ulica as "adr_ulica",
                                                      psc as "adr.psc",
                                                      obec as "adr.mesto")
                                            )
                        ), version '1.0') as s_xml
from ( select 
        o.meno meno,
        o.priezvisko priezvisko,
        o.ulica ulica,
        o.psc psc,
        o.obec obec,
        s.os_cislo os_cislo
from os_udaje o
join student s on(o.rod_cislo = s.rod_cislo));



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
    ....
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
        from os_udaje);/

create table xml_report of xmltype;

insert into xml_report(select 
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
        from os_udaje));
        
select * from xml_report;


create or replace type test_type as object (
    meno varchar2(15),
    priezvisko varchar2(15)
)not final;
/

create table test_table of test_type;

insert into test_table (select meno, priezvisko from os_udaje);
insert into test_table values(test_type('test meno', 'test priezvisko'));

select value(t).meno from test_table t;
SELECT meno FROM test_table;
delete test_table;

create or replace type test_type2 as object(
    rod_cislo char(11),
    test_t test_type
);
/

create table test_table2 of test_type2;
insert into test_table2 (select meno, priezvisko from os_udaje);


insert into test_table2 values('123456/7890', 
                                test_type('test meno', 'test priezvisko'));

select t.test_t.meno from test_table2 t;



begin
    for riadok in ( select 'alter index ' || index_name || ' rebult;' prikaz from user_indexes)
    loop
        execute immediate riadok.prikaz;
    end loop;
end;
/

-- ide to ale nep˙öùaj to
begin
    for riadok in (select ' alter table ' || table_name || ' rename to ' || 
        substr(table_name,1,4) prikaz from tabs)
    loop
        execute immediate riadok.prikaz;
    end loop;
end;
/
rollback;

select * from os_udaje;

begin
    for riadok in (select 'grant select on' || table_name || 
                ' to Mazuch2 with grant option ' prikaz from tabs)
    loop
        execute immediate riadok.prikaz;
    end loop;
end;
/


-- aktualizujte v tabuæke p_typ_prispevku historickÈ z·znami z d·tumu 1.1.2017 na 2.1.2017
-- pre typ s ID=34 z·znami vkladajte do nested table p_historia 

select * from p_typ_prispevku;
select * from p_historia order by dat_od;

set SERVEROUTPUT on;

declare
    type t_historia is table of p_historia%rowtype;
    p_historia_t t_historia := t_historia(); 
begin
    --p_historia_t.extend(1);
    for cur in (select * from p_historia where id_typu=4)
    loop
        p_historia_t.extend(1);
        p_historia_t(p_historia_t.last):= cur;
        p_historia_t(p_historia_t.last).dat_od := '2.1.2017';
        --dbms_output.put_line(p_historia_t(p_historia_t.last).dat_od);
    end loop;
    dbms_output.put_line(p_historia_t.count);
    
    for i in p_historia_t.first..p_historia_t.last
    loop
        dbms_output.put_line(p_historia_t(i).dat_od);
    end loop;
end;
/

select * from p_historia;
select * from p_historia where id_typu=34 and dat_od = '1.1.2017';