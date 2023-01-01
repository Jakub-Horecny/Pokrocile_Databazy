-- vypíšte èloveka, èo má najväèší rozdiel v sumách zapletených na odvodoch
select 
    rc,
    (nest.maxs - nest.mins) rozdiel
from (
    select 
        o.rod_cislo rc,
        max(od.suma) maxs,
        min(od.suma) mins,
        dense_rank() over (order by (max(od.suma)-min(od.suma)) desc) rn
    from p_osoba o
    join p_poistenie p on(o.rod_cislo = p.rod_cislo)
    join p_odvod_platba od on(od.id_poistenca = p.id_poistenca)
    group by o.rod_cislo) nest
where rn = 1;

-- alebo
select 
    rod_cislo, 
    (max_suma-min_suma) rozdiel 
from(
      select 
          o.rod_cislo , 
          min(suma) min_suma, 
          max(suma) max_suma
      from p_osoba o
      join p_poistenie p on (o.rod_cislo = p.rod_cislo)
      join p_odvod_platba using(id_poistenca)
      group by o.rod_cislo) order by (max_suma-min_suma) desc
fetch first row with ties;


--aku pristupovu metodu by ste zvolili
--zdovodnite
-- INDEX v poradí dat_do, dat_od, rod_cislo
create index ind_do_od_rc on p_poberatel (dat_od, dat_do);
drop index ind_do_od_rc;

select dat_od, dat_do
from p_poberatel 
where dat_do is null;
--table access full
--ked je to null tak ti to nepouzije index


Select /*+index(p_osoba ind3)*/meno, priezvisko, id_poistenca, dat_od
	from p_osoba join p_poistenie using(rod_cislo)
	where dat_do is null; -- 30
    
drop index ind2;
create index ind1 on p_osoba(rod_cislo, meno, priezvisko);
create index ind2 on p_poistenie(rod_cislo, dat_do,id_poistenca,dat_od);
create index ind3 on p_osoba(meno);


-- index tesst 
select meno, priezvisko, os_cislo 
from os_udaje
join student using(rod_cislo);

create index ind1 on os_udaje(rod_cislo, meno, priezvisko);
create index ind2 on student(rod_cislo, os_cislo);


select meno, priezvisko, id_poistenca 
from p_osoba
join p_poistenie using(rod_cislo)
where substr(rod_cislo,3,1) < 5;

create index ind1 on p_osoba(to_number(substr(rod_cislo,3,1)), rod_cislo, meno, priezvisko);
create index ind2 on p_poistenie(to_number(substr(rod_cislo,3,1)), rod_cislo, id_poistenca);

drop index ind2;

select o.meno, o.priezvisko, p.id_poistenca 
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
where substr(o.rod_cislo,3,1) < 5;

create index ind1 on p_osoba(to_number(substr(rod_cislo,3,1)), rod_cislo, meno, priezvisko);
create index ind2 on p_poistenie(rod_cislo, id_poistenca);

-- to number 21
-- bez 20 

select * from p_osoba
where rod_cislo = '745426/8459'; -- 745426/8459



/* ----------- JSON ----------- */

create table json_test (
    doc CLOB, 
    constraint json_test_cons CHECK (doc is json)
);

select json_object('meno' value o.meno || ' ' || o.priezvisko,
                    'id' value p.id_poistenca,
                    'adresa' value json_array(o.psc, o.ulica),
                    'evidencia' value 
                                json_object('od' value p.dat_od,
                                            'do' value p.dat_do),
                    'sumy' value json_arrayagg(od.suma)
                    ) 
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
join p_odvod_platba od on(od.id_poistenca = p.id_poistenca)
group by o.meno, o.priezvisko, p.id_poistenca, p.dat_od, p.dat_do, o.rod_cislo, o.psc, o.ulica
order by o.rod_cislo;

insert into json_test(doc) 
select json_object('meno' value o.meno || ' ' || o.priezvisko,
                    'id' value p.id_poistenca,
                    'adresa' value json_array(o.psc, o.ulica),
                    'evidencia' value 
                                json_object('od' value p.dat_od,
                                            'do' value p.dat_do),
                    'sumy' value json_arrayagg(od.suma)
                    ) 
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
join p_odvod_platba od on(od.id_poistenca = p.id_poistenca)
group by o.meno, o.priezvisko, p.id_poistenca, p.dat_od, p.dat_do, o.rod_cislo
order by o.rod_cislo
FETCH FIRST 5 ROWS ONLY;
rollback;
select * from json_test;


select b.doc from json_test b;

select * from json_test b
where json_exists(b.doc, '$?(@.meno=="Marian")');



select b.doc.sumy from json_test b
where b.doc.meno = 'Marian';



select jt.meno2 from json_test b,
json_table(b.doc, '$' columns(meno2 varchar(50) path '$.meno')) jt;

select jt.meno2 from json_test b,
json_table(b.doc, '$' columns(meno2 number path '$.sumy')) jt;

select 
    jt.meno2,
    jt.priezvisko2,
    jt.id2,
    sum(jt.sumy2)
from json_test b,
json_table(b.doc, '$' columns(meno2 varchar2(50) path '$.meno',
                                priezvisko2 varchar2(50) path '$.priezvisko',
                                id2 number path '$.id',
                                sumy2 number path '$.sumy[0]')) jt 
group by jt.meno2, jt.priezvisko2, jt.id2;

define fragment frag1 as select rod_cislo, meno, preizvisko from os_udaje;
define fragment frag2 as select ulica, psc, obec from os_udaje;


select * from frag1
union
select * from frag2;

define fragment frag_1 as select id_poberatela, id_typu from p_prispevky;

select rod_cislo, meno, priezvisko from os_udaje
where meno like 'M%';

select ulica, psc, obec from os_udaje
where meno not like 'M%';

select * from os_udaje 
where meno like 'M%';

select rod_cislo, meno, priezvisko from os_udaje
where meno not like 'M%';










/*------------XML----------------*/

/*<osoby>
    <osoba RC=”551224/1234”>
       <cele_meno>Michal Tester</cele_meno>
       <id>123456</id>
       <sumy>1000</sumy>
    </osoba>
    ....
</osoby>
*/


create table xml_test of xmltype;

delete xml_test;

--insert into xml_test 
select xmlroot(
                xmlelement("osoby",
                            XMLagg(
                            xmlelement("osoba", xmlattributes(rod_cislo as "rc"),
                            xmlforest(cele as "cele_meno",
                                        id as "id"),
                            xmlelement("sumy", sumy)
                                         )
                                    )                           
                        ), version '1.0') as s_xml
from (
    select
        (o.meno || ' ' || o. priezvisko) cele,
        o.rod_cislo rod_cislo,
        p.id_poistenca id,
        sum(od.suma) sumy
    from p_osoba o
    join p_poistenie p on (o.rod_cislo= p.rod_cislo)
    join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
    group by o.meno, o.priezvisko, o.rod_cislo, p.id_poistenca
);


select * from xml_test;
select extract(value(x) , 'osoby/osoba[@rc="745426/8459"]') from xml_test x;
select extract(value(x), '/osoby/osoba/cele_meno') from xml_test x;


select * from p_osoba;



select 'insert into os_udaje(rod_cislo, meno, priezvisko) values(''' || rod_cislo || ''','''
                                                                    || meno || ''','''
                                                                    || priezvisko || ''');'
from p_osoba;


select * from priklad_db2.predmet_bod;

select 'insert into predmet_bod values(''' || cis_predm || ''','''
                                            || skrok || ''','''
                                            || ects || ''','''
                                            || semester || ''','''
                                            || forma_kont ||''');'
from priklad_db2.predmet_bod;


-- Pomocou SQL príkazu generujte príkazy na pridelenie práva "create any directory" 
--všetkým užívate¾om z predmetu II07 v šk. roku 2005. (
begin
    for riadok in (select 'create any directory to ' || login || from os_udaje
    where cis_pred='II07' and extract(year from skrok) = 2005
end;
/

begin
    for riadok in (select 'change password ' || login || ' set to ' 
    substr(meno,1,1) || substr(priezvisko,1,1) || os_cislo from os_udaje) as prikaz
    loop
        execute immediate riadok.prikaz; 
    end loop;
end;
/

/*
Príkaz 1: select id_poistenca, dat_od from p_poistenie; 
Príkaz 2: select DISTINCT id_poistenca, dat_od from p_poistenie; 
Príkaz 3: select id_poistenca from p_poistenie; (
*/

declare 
    type t_pole IS VARRAY(10) OF integer; 
    i integer; 
    pole t_pole; 
    j integer; 
begin 
    pole := t_pole(1,2,3,4,5,6,7,8);
    pole.delete(3); 
    j := pole.first; 
    for i in 1 .. pole.count 
    loop dbms_output.put_line(pole(j)); 
    j := pole.next(j); 
    end loop; 
end;
/

/*
40. Pomocou SQL vygenerujte príkazy na zamknutie kont všetkých študentov, ktorí nemajú zapísaný predmet v šk. roku 2005.
(pomocou tabulky zoznam a systémovej tabu¾ky all_users) syntax prikazu: alter user login account lock; (
*/

select 'alter user ' || login || ' account lock' from zoznam 
where not exists (select 'x' from zoznam where skrok<>2005);    

drop table pom1;
create table pom1(id integer);

create or replace procedure temp_p1
as
  --  PRAGMA AUTONOMOUS_TRANSACTION;
begin
    insert into pom1 values(100);
   -- rollback;
   commit;
end;
/

create or replace procedure temp_p2
as
begin
    temp_p1;
    insert into pom1 values(100);
    rollback;
end;
/

set autocommit on;
create or replace procedure temp_p3
as
begin
    for i in 1..10
    loop
        insert into pom1 values(i*10);
    end loop;
    rollback;
end;
/


exec temp_p3;
select * from pom1;