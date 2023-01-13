-- 1.) pomocou selektu rozdeliù vöetk˝ch zamestnancov do 10 skupÌn tak
-- aby v kaûdej skupine bolo max o 1 viac/menej

-- ak˝ Ëlovek patrÌ do akej skupiny
Select 
    rod_cislo, 
    mod(rn,10) skupina 
from (select 
        rod_cislo, 
        row_number() over(order by rod_cislo) rn 
    from p_zamestnanec)
order by skupina;


-- koæko æudÌ je v ktorej skupine 
select 
    skupina,
    count(skupina)
from (
    Select 
        rod_cislo, 
        mod(rn,10) skupina 
    from (select 
            rod_cislo, 
            row_number() over(order by rod_cislo) rn 
          from p_zamestnanec) 
          )
group by skupina
order by skupina;

-- napÌöte select, ktor˝m rozdelÌùe vöetky ZTP osoby do 10 skupÌn tak, aby 
-- rozdiel poËtu osob v jednotlivej skupine bol maxim·lne +- 1

select
    mod(rn,10) skupina,
    rod
from (
select 
    o.rod_cislo rod,
    row_number() over (order by o.rod_cislo) rn
from p_osoba o
where exists(select 'x' from p_ztp z
                where z.rod_cislo = o.rod_cislo));

                

-- 2.) naplniù index by table d·tami tak ûe index, kde daù d·ta, bude id poberatela
-- a d·ta bud˙ d·tum_od, d·tum_do
set SERVEROUTPUT on;

-- deklar·cia objektu
create or replace type pob as object(
    t_dat_od date,
    t_dat_do date
);
/

declare
    type t_pob is table of pob index by binary_integer; 
    t_poberatelia t_pob;   
begin
    -- naplnenie tabuæky 
    for i in (select id_poberatela, dat_od, dat_do from p_poberatel)
    loop
        t_poberatelia(i.id_poberatela) := pob(i.dat_od, i.dat_do);
    end loop;
    
    -- v˝pis
    for i in t_poberatelia.first..t_poberatelia.last
    loop
        if t_poberatelia.exists(i) then
            dbms_output.put_line('dat_od:' || ' ' || t_poberatelia(i).t_dat_od 
                                 || ' ' ||
                                 'dat_do:' || ' ' || t_poberatelia(i).t_dat_do);
        end if;
    end loop;
end;
/


-- nejakÈ jeblÈ selekty

-- K jednotliv˝m mesiacom prÈvho polroka vypÌöte ku kaûdÈmu okresu TrenËianskÈho kraja
-- poËet muûov a ûien, ktorÈ sa v tento mesiac narodili 

select
    nazov,
    sum(case when substr(rc,3,1) > 1 then 1 else 0 end) zeny,
    sum(case when substr(rc,3,1) < 1 then 1 else 0 end) muzi
from (
    select
        ok.n_okresu nazov,
        o.rod_cislo rc
    from p_kraj k
    join p_okres ok on (k.id_kraja = ok.id_kraja)
    join p_mesto m on (m.id_okresu = ok.id_okresu)
    join p_osoba o on (m.psc = o.psc)
    where 
        k.id_kraja = 'TN'
        and
        mod(substr(o.rod_cislo,3,2),50) <= 6
    )
group by nazov
order by nazov;

select 
    n_okresu 
from p_kraj
join p_okres using(id_kraja)
where id_kraja = 'TN';


-- vypÌöte 5% krajov, v ktorom je najmeöÌ poËet samoplatcov trpacich na dusevnu chorobu
-- Mentalne/Dusevne Postihnutie

select distinct
    n_kraja nazov,
    count(o.rod_cislo),
    rank() OVER (ORDER BY count(o.rod_cislo)) rn
from p_kraj k
join p_okres ok on (k.id_kraja = ok.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (m.psc = o.psc)
join p_ztp t on (o.rod_cislo = t.rod_cislo)
join p_typ_postihnutia ty on (ty.id_postihnutia = t.id_postihnutia)
join p_poistenie po on (po.rod_cislo = o.rod_cislo)
where 
    ty.nazov_postihnutia = 'Mentalne/Dusevne Postihnutie'
and
    po.id_platitela = o.rod_cislo -- samoplatec 
GROUP by n_kraja
fetch first 5 percent rows only;



select n_kraja, poradie,pocet from(
     select 
        n_kraja, 
        row_number() over ( order by count(id_ZTP)) poradie, count(id_ZTP) pocet
     from p_kraj    
        join p_okres using(id_kraja)
        join p_mesto using(id_okresu)
        join p_osoba o using(psc)
        join p_poistenie p on(p.rod_cislo = o.rod_Cislo)
        join p_ZTP z on(o.rod_cislo = z.rod_Cislo)
        where id_platitela = o.rod_Cislo and id_postihnutia = 6
        group by n_kraja
        ) pom where poradie <=0.05*(select count(*) from p_kraj);



-- k jednotliv˝m n·zvom zamestn·vateæov a kvart·lom minulÈho roka
-- vypÌöte poËet prijat˝ch osÙb do zamestnania 

select
    za.nazov,
    'Q' || CEIL((to_char(extract (month from z.dat_od))) / 3 ) AS kvartal,
    count(z.rod_cislo)
from p_zamestnavatel za
join p_zamestnanec z on (za.ico = z.id_zamestnavatela)
group by za.nazov, 'Q' || CEIL((to_char(extract (month from z.dat_od))) / 3 )
order by za.nazov, kvartal;



-- vytvoriù najlepÌ index(indexy) pre select 
select meno, priezvisko, id_poistenca, dat_od
from p_osoba join p_poistenie using(rod_cislo)
where dat_do is null;
commit;

drop index test1;
create index test1 on p_poistenie(rod_cislo, dat_do, id_poistenca, dat_od);
create index test2 on p_osoba(rod_cislo, meno, priezvisko);

-- 30% najæudnatejöÌch okresov
select
    ok.n_okresu,
    count(o.rod_cislo),
    dense_rank() OVER (order by count(o.rod_cislo)) rn
from p_okres ok
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
group by ok.n_okresu
fetch first 30 percent row only;



-- doplniù deklar·ciu objektu osoba 
create or replace type t_osoba2 as object(
meno varchar2(15),
priezvisko varchar2(15),
narodenie date);
/

declare
    osoba t_osoba2 ;
begin
    osoba := t_osoba2('Meno', 'priezvisko', sysdate);
end;
/

--K jednotliv˝m n·zvom krajov zo öt·tu Ëesko vypÌöte percentu·lne zloûenie 
--samoplatcov a klasick˝ch zamestnancov malöÌch ako 47 rokov

select
    k.n_kraja,
    count(p.rod_cislo),
    sum(case when o.rod_cislo = p.id_platitela then 1 else 0 end)/count(p.rod_cislo)*100 samo,
    sum(case when o.rod_cislo <> p.id_platitela then 1 else 0 end)/count(p.rod_cislo)*100 zam
from p_krajina kr
join p_kraj k on (kr.id_krajiny = k.id_krajiny)
join p_okres ok on (ok.id_kraja = k.id_kraja) 
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
--join p_platitel pl on (pl.id_platitela = p.id_platitela)
where kr.id_krajiny = 'CZK'
and floor(months_between(sysdate, to_date(substr(o.rod_cislo,5,2) || '-' ||
        mod(substr(o.rod_cislo , 3,2),50) || '-' || 19 ||
        substr(o.rod_cislo,1,2), 'DD-MM-YYYY'))/12) < 47
group by k.n_kraja;


-- vypÌöte 5 percent osÙb, ktorÈ zaplatili za odvody minul˝ rok ako prv˝
-- (zoradte datum paltby 
-- 2016 lebo tento rok niË nevypÌöe 
select
    o.rod_cislo,
    od.dat_platby
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
where extract(year from od.dat_platby) = '2016'
order by od.dat_platby
fetch first 5 percent row only;


-- vypÌöte aspoÚ 10% osÙb ktorÈ tento rok nezaplatili ûiadny odvod
select DISTINCT
     o.rod_cislo
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
where EXISTS (select 'x' from p_odvod_platba od where extract(year from od.dat_platby) <> '2016')
fetch FIRST 10 percent row only;


--vypÌöte osobu s najv‰ËöÌm rozdielom v odvodoch
select
    *
from (
    select
        o.rod_cislo rc,
        max(od.suma) maximum,
        min(od.suma) minimum,
        max(od.suma) - min(od.suma) diff,
        rank() over (order by (max(od.suma) - min(od.suma)) desc) rn
    from p_osoba o 
    join p_poistenie p on (o.rod_cislo = p.rod_cislo)
    join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
    group by o.rod_cislo)
where rn = 1;


-- vypÌöte pre kaûd˝ kraj pre kaûd˝ mesiac prvÈho kvart·lu roku 2008 sumu 
-- zaplaten˝ch odvodov od samoplatcov

SELECT
    k.n_kraja,
    sum(case when extract(MONTH from od.dat_platby) = 1 then od.suma else 0 end) M1,
    sum(case when extract(MONTH from od.dat_platby) = 2 then od.suma else 0 end) M2,
    sum(case when extract(MONTH from od.dat_platby) = 3 then od.suma else 0 end) M3
from p_kraj k
join p_okres ok on (ok.id_kraja = k.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
join p_poistenie p on (p.rod_cislo = o.rod_cislo)
join p_platitel pl on (p.id_platitela = pl.id_platitela)
join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
where extract(year from od.dat_platby) = '2016'
and o.rod_cislo = p.id_platitela -- samoplatec 
group by k.n_kraja;


--za prv˝ kvart·l tohto roka ku kaûdÈmu zamestn·vateæovi 
--vypÌsalo za prv˝ mesiac myslÌm koæko prijal nov˝ch zamestnancov v danom t˝ûdn

select 
    nazov, 
    sum(case when extract(day from dat_od) between 1 and 7 then 1 else 0 end) prvy,
    sum(case when extract(day from dat_od) between 8 and 14 then 1 else 0 end) druhy,
    sum(case when extract(day from dat_od) between 15 and 21 then 1 else 0 end) treti,
    sum(case when extract(day from dat_od) between 22 and 31 then 1 else 0 end) stvrty
from p_zamestnavatel zl
join p_zamestnanec zc on(zc.id_zamestnavatela = zl.ico)
where 
        --to_char(dat_od,'Q')=1 
        extract(month from dat_od) in (1,2,3,4)
    and 
        extract(year from dat_od) = 2016
group by nazov;

select to_char(dat_od, 'Q') from p_zamestnanec;

-- 3 
-- K3
select count(*) from os_udaje
join student using(rod_cislo);

-- K2
select count(*) from os_udaje;

-- K1
select count(*) from student;


create table test1(nieco integer);



set autocommit on
drop table pom;
create table pom (id integer);
begin
insert into pom values(10);
insert into pom values(20);
rollback;
end;
/

select count(*) from pom;


select rod_cislo, meno, priezvisko, sum(suma) 
from p_osoba JOIN p_poistenie USING ( rod_cislo ) 
JOIN p_odvod_platba USING ( id_poistenca ) 
where to_char(obdobie, 'YYYY') = 2016 
group by rod_cislo, meno, priezvisko ;

CREATE INDEX test1 ON p_odvod_platba(to_char(obdobie, 'YYYY'), suma);
drop index test1;

-- VypÌöte 5% obyvateæov s najv‰ËöÌmi odvodmi do poisùovne pre kaûdÈ mesto osobitne
select
    mesto,
    rod_cislo,
    suma,
    rn
from (
    select
        m.n_mesta mesto,
        o.rod_cislo rod_cislo,
        sum(od.suma) suma,
        rank() over (partition by m.n_mesta order by sum(od.suma) desc) rn
    from p_mesto m
    join p_osoba o on(o.psc = m.psc)
    join p_poistenie po on(po.rod_cislo = o.rod_cislo)
    join p_odvod_platba od on(od.id_poistenca = po.id_poistenca) 
    group by m.n_mesta, o.rod_cislo)
where rn <= ceil(0.05 * (SELECT COUNT(DISTINCT rod_cislo) 
                            FROM p_mesto JOIN p_osoba USING (PSC) 
                            JOIN p_poistenie USING (rod_cislo) 
                            JOIN p_odvod_platba USING (id_poistenca) 
                            WHERE n_mesta = mesto));
                            
                            
-- vypÌöte zoznam aktu·lnych drûiteæov ZTP, ktorÌ poËas platnosti preukazu 
-- nedostali ûiaden prÌspevok. Pouûite EXISTS

select 
    * 
from p_ztp z
where not exists(select 'x' 
                    from p_poberatel po
                    join p_prispevky pr on (po.id_poberatela = pr.id_poberatela)
                    where po.rod_cislo = z.rod_cislo
                    and
                    pr.kedy between z.dat_od and dat_do);




-- dopniù do XML group by 
select xmlroot(xmlelement("osoba",xmlAttributes(rod_cislo as "RC"),
            xmlelement("meno", meno),
                    xmlelement("proezvisko", priezvisko),
            xmlelement("priznane_ztp",
                xmlagg(
                    xmlelement("ztp", xmlAttributes(id_ztp as "id"), nazov_postihnutia)
                    )
                    )
                    ), version '1.0')
from p_osoba left join p_ztp using(rod_cislo) join p_typ_postihnutia using(id_postihnutia)
having count(distinct id_postihnutia) >1
group by rod_cislo, meno, priezvisko; -- ide tam vöetko okrem stÂpcov v XMLAGG



create table tab1 ( id integer not null primary key,
poznamka varchar2(20) );

create table tab2 ( id integer not null primary key,
cislo_fk integer not null );

create table tab3 ( id integer not null primary key,
fk_tab2 integer);

alter table tab2 add foreign key (cislo_fk) references tab1 (id);

alter table tab3 add foreign key (fk_tab2) references tab2 (id);

insert into tab3 values(4,3);
insert into tab1 values(2,'poznamka');
insert into tab2 values(3,2);

rollback;


select 'insert into p_osoba values(''' || rod_cislo || ''','''
                                        || meno || ''','''
                                        || priezvisko || ''','''
                                        || psc || ''','''
                                        || ulica || ''');'
                                        from os_udaje;


select * from tab1;


create or replace type t_osoba3 as object (
    id integer,
    map member function tried return integer
) not final; 
/

-- definicia tela procedury 
create or replace type body t_osoba3 as
map member function tried return integer
as
    begin
        return 5;
    end;
end;
/

create table osoba21 (
    osoba t_osoba3
);
/

insert into osoba21 values(t_osoba3(1));
insert into osoba21 values(t_osoba3(2));
insert into osoba21 values(t_osoba3(3));

select * from osoba21 o order by o.osoba.tried;
select o.osoba.id from osoba21 o order by osoba;

select value(o) from osoba21 o;
select * from osoba21 os order by value(os);




-- fragmentujte rel·ciu p_odvod_platby na odvody zaplatnÈ
-- samoplatcami a odvody zamestnancov 

define fragment frag1 as
select 
     sum(od.suma)
from p_odvod_platba od
join p_poistenie p on(p.id_poistenca = od.id_poistenca)
join p_osoba o on(o.rod_cislo = p.rod_cislo)
where o.rod_cislo = p.id_platitela;


define fragment frag2 as
select 
     sum(od.suma)
from p_odvod_platba od
join p_poistenie p on(p.id_poistenca = od.id_poistenca)
join p_osoba o on(o.rod_cislo = p.rod_cislo)
where o.rod_cislo <> p.id_platitela;



select
    t.nazov_postihnutia,
    count(z.id_ztp)
from p_ztp z
join p_typ_postihnutia t on (z.id_postihnutia = t.id_postihnutia)
group by t.nazov_postihnutia, t.id_postihnutia
order by t.id_postihnutia;

drop table osoby;

create table osoby of t_osoba;

insert into osoba values (t_osoba(12, 'Jakub', 'h', t_adresa('12345', 'vysokoskolakov' , 'Zilina')));
insert into osoba values (t_osoba(555, 'Jakub', 'h', t_adresa('12345', 'vysokoskolakov' , 'Zilina')));

select * from osoby o order by value(o);