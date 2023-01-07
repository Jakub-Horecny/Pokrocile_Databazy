-- 1.) pomocou selektu rozdeli� v�etk�ch zamestnancov do 10 skup�n tak
-- aby v ka�dej skupine bolo max o 1 viac/menej

-- ak� �lovek patr� do akej skupiny
Select 
    rod_cislo, 
    mod(rn,10) skupina 
from (select 
        rod_cislo, 
        row_number() over(order by rod_cislo) rn 
    from p_zamestnanec)
order by skupina;


-- ko�ko �ud� je v ktorej skupine 
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


-- 2.) naplni� index by table d�tami tak �e index, kde da� d�ta, bude id poberatela
-- a d�ta bud� d�tum_od, d�tum_do
set SERVEROUTPUT on;

-- deklar�cia objektu
create or replace type pob as object(
    t_dat_od date,
    t_dat_do date
);
/

declare
    type t_pob is table of pob index by binary_integer; 
    t_poberatelia t_pob;   
begin
    -- naplnenie tabu�ky 
    for i in (select id_poberatela, dat_od, dat_do from p_poberatel)
    loop
        t_poberatelia(i.id_poberatela) := pob(i.dat_od, i.dat_do);
    end loop;
    
    -- v�pis
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


-- nejak� jebl� selekty

-- K jednotliv�m mesiacom pr�vho polroka vyp�te ku ka�d�mu okresu Tren�iansk�ho kraja
-- po�et mu�ov a �ien, ktor� sa v tento mesiac narodili 

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


-- vyp�te 5% krajov, v ktorom je najme�� po�et samoplatcov trpacich na dusevnu chorobu
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



-- k jednotliv�m n�zvom zamestn�vate�ov a kvart�lom minul�ho roka
-- vyp�te po�et prijat�ch os�b do zamestnania 

select
    za.nazov,
    'Q' || CEIL((to_char(extract (month from z.dat_od))) / 3 ) AS kvartal,
    count(z.rod_cislo)
from p_zamestnavatel za
join p_zamestnanec z on (za.ico = z.id_zamestnavatela)
group by za.nazov, 'Q' || CEIL((to_char(extract (month from z.dat_od))) / 3 )
order by za.nazov, kvartal;



-- vytvori� najlep� index(indexy) pre select 
select meno, priezvisko, id_poistenca, dat_od
from p_osoba join p_poistenie using(rod_cislo)
where dat_do is null;
commit;

drop index test1;
create index test1 on p_poistenie(rod_cislo, dat_do, id_poistenca, dat_od);
create index test2 on p_osoba(rod_cislo, meno, priezvisko);

-- 30% naj�udnatej��ch okresov
select
    ok.n_okresu,
    count(o.rod_cislo),
    dense_rank() OVER (order by count(o.rod_cislo)) rn
from p_okres ok
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
group by ok.n_okresu
fetch first 30 percent row only;



-- doplni� deklar�ciu objektu osoba 
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

--K jednotliv�m n�zvom krajov zo �t�tu �esko vyp�te percentu�lne zlo�enie 
--samoplatcov a klasick�ch zamestnancov mal��ch ako 47 rokov

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


-- vyp�te 5 percent os�b, ktor� zaplatili za odvody minul� rok ako prv�
-- (zoradte datum paltby 
-- 2016 lebo tento rok ni� nevyp�e 
select
    o.rod_cislo,
    od.dat_platby
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
where extract(year from od.dat_platby) = '2016'
order by od.dat_platby
fetch first 5 percent row only;


-- vyp�te aspo� 10% os�b ktor� tento rok nezaplatili �iadny odvod
select DISTINCT
     o.rod_cislo
from p_osoba o
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
where EXISTS (select 'x' from p_odvod_platba od where extract(year from od.dat_platby) <> '2016')
fetch FIRST 10 percent row only;


--vyp�te osobu s najv���m rozdielom v odvodoch
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


-- vyp�te pre ka�d� kraj pre ka�d� mesiac prv�ho kvart�lu roku 2008 sumu 
-- zaplaten�ch odvodov od samoplatcov

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


--za prv� kvart�l tohto roka ku ka�d�mu zamestn�vate�ovi 
--vyp�salo za prv� mesiac mysl�m ko�ko prijal nov�ch zamestnancov v danom t��dn

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
