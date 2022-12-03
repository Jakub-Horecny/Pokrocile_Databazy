/* 1.) Určite správny príkaz na vloženie nového priadku do tabuľky zamestnanci s 
nasledujúcov štruktúrov */

create type t_osoba1 is object (
    rc char(11),
    meno varchar2(20),
    priezvisko varchar2(20)
)not final;
/

-- dedenie z t_osoby 
create type t_zam under t_osoba1(
    oc number, 
    pozicia varchar(10)
);
/

create table zamestnanci of t_zam;
desc zamestnanci;
-- správny insert, keď si to pozrieš cez desc t_zam, ako by tabuľka zamestnanci 
-- mala5 stĺpcov 
/*
Name       Null? Type         
---------- ----- ------------ 
RC               CHAR(11)     
MENO             VARCHAR2(20) 
PRIEZVISKO       VARCHAR2(20) 
OC               NUMBER       
POZICIA          VARCHAR2(10)
*/
-- toto pojde 
insert into zamestnanci values('123456/1234', 'Jakub', 'Horecny', 42, 'sef');
insert into zamestnanci values(t_zam('123456/1234', 'Jakub', 'Horecny', 42, 'sef'));

select * from zamestnanci;
select rc, meno from zamestnanci;

drop table zamestnanci;
drop type t_zam;
drop type t_osoba1;

/*
2.) K jednotlivým krajom Slovenskej republiky a mesiacom prvého kvartálu roku 2008 
vypíšte celkovú sumu odvedenú samoplatcami
*/
-- je to pre jednotlivé mesiace, ak iba kvartáli tak preč: 'M' ||  extract(month from dat_platby) mesiac 
select 
    kr.n_kraja, 
    sum(suma) suma,
    'M' ||  extract(month from dat_platby) mesiac
from p_kraj kr
join p_okres ok on (ok.id_kraja = kr.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
join p_poistenie p on (p.rod_cislo = o.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
where p.oslobodeny in ('n', 'N')
and extract(month from dat_platby) between 1 and 4
and extract(year from dat_platby) = 2016 -- 2008 nič nevráti nie sú záznami, 2016 áno
group by kr.n_kraja, kr.id_kraja, 'M' ||  extract(month from dat_platby) 
order by kr.n_kraja, 'M' ||  extract(month from dat_platby)
;

-- 6.) vypísať kraje kde býva viac žien ako mužov 
select 
    kraj
from (select 
            kr.n_kraja kraj,
            sum(case when (substr(o.rod_cislo,3,2) > 12) then 1 else 0 end) zena,
            sum(case when (substr(o.rod_cislo,3,2) < 12) then 1 else 0 end) muz
        from p_kraj kr
            join p_okres ok on (ok.id_kraja = kr.id_kraja)
            join p_mesto m on (m.id_okresu = ok.id_okresu)
            join p_osoba o on (o.psc = m.psc)
        group by kr.n_kraja
        )
where zena > muz;

-- 16.) Ku každému držiteľovi ZTP vypíšte sumu príspevkov, 
-- ktoré dostal za minulý kalendárny rok.

select 
    o.rod_cislo, 
    o.meno, 
    o.priezvisko, 
    sum(pr.suma) suma 
from p_osoba o 
join p_poberatel p on(p.rod_cislo = o.rod_cislo)
join p_prispevky pr on (pr.id_poberatela = p.id_poberatela)
where extract(year from pr.obdobie) = (extract(year from sysdate)) - 6
GROUP by o.rod_cislo, o.meno, o.priezvisko
order by o.meno;

-- 23.) K jednotlivým názvom zamestnávateľov a kvartálom minulého roka vypíšte 
-- počet prijatých osôb do zamestnania

select 
    ('Q' || ceil((extract(month from za.dat_od)) / 3)) kvartal,
    z.nazov,
    count(*)
from p_zamestnavatel z
join p_zamestnanec za on(za.id_zamestnavatela = z.ico)
where extract(year from dat_od) = extract(year from sysdate) -6  -- -1 nič nedá
group by ('Q' || ceil((extract(month from za.dat_od)) / 3)), z.nazov
order by z.nazov, kvartal;

-- 24.)
-- Pre každý okres vypíšte osobu, ktorá bola poistencom najdlhšie. Ak bola evidovaná viackrát, intervaly sčítajte
select n_okresu, rod_cislo, poradie, dlzka from(
    select n_okresu , 
            rod_cislo, 
            rank() over (partition by o.id_okresu order by sum( nvl(dat_do,sysdate) - dat_od )desc) poradie,
            sum( nvl(dat_do,sysdate) - dat_od ) dlzka
    from p_okres o
         join p_mesto m on(m.id_okresu = o.id_okresu)
            join p_osoba os on(os.PSC = m.PSC)
                join p_poistenie p using(rod_cislo)
                
    group by n_okresu, rod_cislo, o.id_okresu
) where poradie =1
order by n_okresu;

-- 38.)
-- Pre jednotlivé mestá Nitrianskeho kraja vypíšte percentuálne rozloženie mužov a žien.
select * from p_kraj; -- NR

select
    m.n_mesta,
    count(o.rod_cislo) vsetci,
    round((sum(case when substr(o.rod_cislo,3,2) > 12 then 1 else 0 end)/
        count(o.rod_cislo)*100),2) zeny,
    round((sum(case when substr(o.rod_cislo,3,2) between 1 and 12 then 1 else 0 end)/
        count(o.rod_cislo)*100),2) muzi
from p_kraj k
join p_okres ok on(k.id_kraja = ok.id_kraja)
join p_mesto m on(m.id_okresu = ok.id_okresu)
join p_osoba o on(o.psc = m.psc)
where k.id_kraja = 'NR'
group by m.n_mesta;

-- 43.)
-- Vypíšte 5% obyvateľov s najväčšími odvodmi do poisťovne pre každé mesto osobitne.
select
    mesto,
    meno,
    priezvisko,
    rod_cislo,
    suma
from
    (select
        m.n_mesta mesto,
        o.meno meno,
        o.priezvisko priezvisko,
        o.rod_cislo rod_cislo,
        sum(od.suma) suma,
        rank() over (order by sum(od.suma) desc) rn
    from p_mesto m
    join p_osoba o on(m.psc = o.psc)
    join p_poistenie po on(po.rod_cislo = o.rod_cislo)
    join p_odvod_platba od on(od.id_poistenca = po.id_poistenca)
    group by o.meno, o.priezvisko, o.rod_cislo, od.suma, m.n_mesta
    )
having rn <= ceil((select count(*) from p_odvod_platba)*0.05)
group by meno, priezvisko, rod_cislo,rn,suma, mesto;
    

SELECT mesto, meno, priezvisko FROM
(SELECT n_mesta mesto, meno, priezvisko, RANK() OVER (PARTITION BY n_mesta ORDER BY suma DESC) poradie
FROM
(SELECT n_mesta, meno, priezvisko, SUM(suma) suma
FROM p_mesto JOIN p_osoba USING (PSC) JOIN p_poistenie USING (rod_cislo) JOIN p_odvod_platba USING
(id_poistenca)
GROUP BY n_mesta, meno, priezvisko, rod_cislo))
WHERE poradie <= 0.05 * (SELECT COUNT(DISTINCT rod_cislo) FROM p_mesto JOIN p_osoba USING (PSC) JOIN
p_poistenie USING (rod_cislo) JOIN p_odvod_platba USING (id_poistenca) WHERE n_mesta = mesto);

-- =============== TEST 2 ====================
-- 13.)
-- K jednotlivým zamestnávateľom vypíšte počet zamestnancov a samoplatcov do 4O rokov.

select * from p_platitel;
select 
    z.nazov,
    count(za.rod_cislo) nad_40,
    count(p.id_poistenca) samoplatec
from p_zamestnavatel z
join p_zamestnanec za on(z.ico = za.id_zamestnavatela)
join p_poistenie p on (p.id_poistenca = za.id_poistenca)
where to_date(substr(za.rod_cislo,1,2) || '.' || 
        mod(substr(za.rod_cislo,3,2),50) || '.' || 
        substr(za.rod_cislo,5,2), 'RR.MM.DD') < add_months(sysdate,-480)
    and
        p.oslobodeny in ('n','N')
group by z.nazov;


--13. K jednotlivým zamestnávateľom vypíšte počet zamestnancov a samoplatcov do 4O rokov
select 
    nazov, 
    sum(case when id_platitela = rod_cislo then 1 else 0 end) samoplatca,
    sum(case when id_platitela = id_zamestnavatela then 1 else 0 end) zamestnanec
from p_zamestnavatel zl
join p_zamestnanec zc on(zc.id_zamestnavatela = zl.ICO)
join p_poistenie using(rod_cislo)
where to_number(substr(rod_cislo,1,2)) <= extract(year from sysdate)-40
group by nazov;

-- 24.)
-- Pre jednotlivé rozpätia súm 0 - 2000, 2001-40000,40001 - 80000 
-- vypíšte počet osôb, ktorí túto čiastku celkovo odviedli do
-- poisťovne a sú z okresu Žilina.

select
    sum(case when suma >= 0 and suma <= 2000 then 1 else 0 end) s_0_2000,
    sum(case when suma > 2000 and suma <= 40000 then 1 else 0 end) s_2001_40000,
    sum(case when suma > 40000 then 1 else 0 end) s_40001_80000
from (
select
    po.id_poistenca poistenec,
    sum(od.suma) suma
from p_okres ok
join p_mesto m on(ok.id_okresu = m.id_okresu)
join p_osoba o on(o.psc = m.psc)
join p_poistenie po on (po.rod_cislo = o.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = po.id_poistenca)
where ok.id_okresu = 'ZA'
group by po.id_poistenca);
-- suma môže byť v sume 
select
    sum(case when sum(od.suma) >= 0 and sum(od.suma) <= 2000 then 1 else 0 end) s_0_2000,
    sum(case when sum(od.suma) > 2000 and sum(od.suma) <= 40000 then 1 else 0 end) s_2001_40000,
    sum(case when sum(od.suma) > 40000 then 1 else 0 end) s_40001_80000
from p_okres ok
join p_mesto m on(ok.id_okresu = m.id_okresu)
join p_osoba o on(o.psc = m.psc)
join p_poistenie po on (po.rod_cislo = o.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = po.id_poistenca)
where ok.id_okresu = 'ZA'
group by po.id_poistenca;


-- 25.)
-- Vypíšte 30% najľudnatejších krajín
select 
    rn,
    krajina,
    pocet
from (
    select
        k.n_krajiny krajina,
        count(o.rod_cislo) pocet,
        row_number() over (order by count(o.rod_cislo) desc) rn
    from p_krajina k
    join p_kraj kr on (kr.id_krajiny = k.id_krajiny)
    join p_okres ok on (ok.id_kraja = kr.id_kraja)
    join p_mesto m on (m.id_okresu = ok.id_okresu)
    join p_osoba o on (o.psc = m.psc)
    group by k.n_krajiny )
having rn <= ceil((select count(id_krajiny) from p_krajina)*0.3)
group by krajina, rn, pocet
order by rn;

-- Vypíšte 30% najľudnatejších miest
select 
    rn,
    mesto,
    pocet
from (
    select
        m.n_mesta mesto,
        count(o.rod_cislo) pocet,
        row_number() over (order by count(o.rod_cislo) desc) rn
    from p_mesto m 
    join p_osoba o on (o.psc = m.psc)
    group by m.n_mesta )
having rn <= ceil((select count(psc) from p_mesto)*0.3)
group by mesto, rn, pocet
order by rn; --254
select count(psc) from p_mesto; -- 846

-- 26.)
-- Pre jednotlivé rozpätia súm 0 - 2000, 2001-40000,40001 - 80000 
-- vypíšte percentuálne rozloženie osôb, ktorí túto čiastku celkovo
-- odviedli do poisťovne a sú z okresu Žilina.
select
    round(sum(case when suma >= 0 and suma <= 2000 then 1 else 0 end)
        /count(suma)*100,2) s_0_2000,
    round(sum(case when suma > 2000 and suma <= 40000 then 1 else 0 end)
        /count(suma)*100,2) s_2001_40000,
    round(sum(case when suma > 40000 then 1 else 0 end)
        /count(suma)*100,2)s_40001_80000
from (
select
    po.id_poistenca poistenec,
    sum(od.suma) suma
from p_okres ok
join p_mesto m on(ok.id_okresu = m.id_okresu)
join p_osoba o on(o.psc = m.psc)
join p_poistenie po on (po.rod_cislo = o.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = po.id_poistenca)
where ok.id_okresu = 'ZA'
group by po.id_poistenca);



-- 37.)
-- Pre každý typ postihnutia vypíšte 3 osoby podľa dĺžky poberanie daného 
-- príspevku. Ak osoba poberala daný príspevok viackrát, dobu spočítajte (p_ztp)
select
    typ,
    rn,
    meno,
    priezvisko,
    rod_cislo
from(
    select 
        t.nazov_postihnutia typ,
        o.meno meno,
        o.priezvisko priezvisko,
        o.rod_cislo rod_cislo,
        row_number() over (partition by t.nazov_postihnutia order by p.dat_od) rn
    from p_typ_postihnutia t 
    join p_ztp z on(t.id_postihnutia = z.id_postihnutia)
    join p_osoba o on(o.rod_cislo = z.rod_cislo)
    join p_poberatel p on(p.rod_cislo = o.rod_cislo)
    group by o.meno, o.priezvisko, o.rod_cislo, p.dat_od, t.nazov_postihnutia)
where rn <= 3
group by typ, meno, priezvisko, rod_cislo,  rn
order by typ, rn;

-- 38.)
-- Pre každú firmu vypíšte 3 zamestnancov,
-- za ktorých sa zaplatilo minulý rok na odvodoch najviac.

select * from p_zamestnanec z
join p_poistenie p on(z.rod_cislo = p.rod_cislo);
    
select
    nazov,
    rn,
    rod_cislo
from (
    select 
        za.ico ico,
        za.nazov nazov,
        z.rod_cislo rod_cislo,
        sum(o.suma) suma,
        row_number() over (partition by za.ico order by sum(o.suma) desc) rn
    from p_zamestnavatel za
    join p_zamestnanec z on(za.ico = z.id_zamestnavatela)
    join p_poistenie p on (p.rod_cislo = z.rod_cislo)
    join p_odvod_platba o on (o.id_poistenca = p.id_poistenca)
    where extract(year from dat_platby) = extract(year from sysdate) - 6
    group by za.ico, za.nazov, z.rod_cislo, o.suma, p.id_poistenca
    )
where rn <= 3
group by  nazov, rn, rod_cislo
order by nazov, rn;

-- 40.)
-- pomocou SQL vygenerujte prízak na zamknutie kont všetkých študentov, ktorý nemajú zapísaný predmet 
-- v šk. roku 2005 (pomocou tabuľky zoznam a systémovej tabuľky all_users) 
-- syntax príkazu: alter user login account lock;

select 'alter user ' || login || ' account lock;'
from zoznam
where not exists (select 'x' from zoznam where skrok<>'2005');-- niečo tu je zle ale neviem čo 

-- 42.)
-- Vypíšte názvy typov príspevkov, ktoré NEBOLI vyplácané minulý kalendárny mesiac. 
-- Poučite EXISTS

-- -71 niečo vypíše 
select
    t.id_typu,
    t.popis
from p_typ_prispevku t
where not exists (select 'x' from p_prispevky
                  where t.id_typu = id_typu
                and extract(month from kedy) = extract(month from (add_months(sysdate,-71))));

-- ==================== TEST 3 ====================

-- 40.)
-- pre jednotlivé rozpetie súm 0-2000, 2001-40000, 40001-80000 vypíšte percentuálne
-- rozloženie osôb, ktorí túto čiastku celkovo odviedli do poistovne a sú z okresu Žilina 

select
    round(sum(case when suma >= 0 and suma <= 2000 then 1 else 0 end)
        /count(suma)*100,2) s_0_2000,
    round(sum(case when suma > 2000 and suma <= 40000 then 1 else 0 end)
        /count(suma)*100,2) s_2001_40000,
    round(sum(case when suma > 40000 then 1 else 0 end)
        /count(suma)*100,2)s_40001_80000
from (
-- tu som pre jednotlivých poistencov zistil koľko odviedli 
select
    po.id_poistenca poistenec,
    sum(od.suma) suma
from p_okres ok
join p_mesto m on(ok.id_okresu = m.id_okresu)
join p_osoba o on(o.psc = m.psc)
join p_poistenie po on (po.rod_cislo = o.rod_cislo)
join p_odvod_platba od on (od.id_poistenca = po.id_poistenca)
where ok.id_okresu = 'ZA'
group by po.id_poistenca);

-- 42.)
-- vypísať 5% obyvateľov s najväčšími odvodmi do poiťovne pre každé mesot osobitne
-- nefunguje dobre 
select 
    *
from
    (select 
        m.psc psc,
        m.n_mesta mesto,
        p.id_poistenca poistenec, 
        row_number() over (partition by m.n_mesta order by sum(od.suma) desc) rn
    from p_mesto m
    join p_osoba o on (m.psc = o.psc)
    join p_poistenie p on (o.rod_cislo = p.rod_cislo)
    join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
    group by m.psc, m.n_mesta, p.id_poistenca, p.rod_cislo) -- neviem či aj podľa o.rod_cislo
where rn <= ceil((select count(*) 
                    from p_osoba 
                    where p_osoba.psc = psc)*0.05)    
group by mesto, poistenec, rn, psc
order by mesto, rn;

-- iba 5% obyvateľov s najväčšími dovodmi 
select 
    *
from 
    (select
        o.meno meno,
        o.priezvisko priezvisko,
        o.rod_cislo rod_cislo,
        sum(od.suma) suma,
        row_number() over (order by sum(od.suma) desc) rn
    from p_osoba o
    join p_poistenie p on (o.rod_cislo = p.rod_cislo)
    join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
    group by o.meno, o.priezvisko, o.rod_cislo)
where rn <= ceil((select count(*) from p_osoba)*0.05)
order by rn;

-- ================ TEST 4 ===================

-- 23.)
-- vypíšte zamestnávateľov od 6 po 12 miesto na základe CELKOVEJ odvedenej sumy do 
-- poisťovne za svojich zamestnancov 

-- nepíše tam čo v prípade že majú dvaja rovnakú sume, takže sem dám iba row_number
select
    *
from( select 
        za.ico ico,
        za.nazov nazov,
        sum(od.suma) suma,
        row_number() over (order by sum(od.suma) desc) rn
      from p_zamestnavatel za
      join p_zamestnanec z on (za.ico = z.id_zamestnavatela)
      join p_poistenie p on (p.rod_cislo = z.rod_cislo)
      join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
      group by za.ico, za.nazov)
where rn between 6 and 12
order by rn;

-- ==================== TEST 5 ====================

-- 39.) k jednotlivým názvom krajov zo štátu Česko vypíšte percentuálne zloženie 
-- samoplatcom a klasických zamestnancov 

select count(*) from p_platitel; -- 5457
select count(*) from p_osoba; -- 5446 
select count(*) from p_poistenie; -- 8512

select
    k.n_kraja,
    -- dostal za to plnku ale nezdá sa mi to 
    sum( case when p.id_platitela is not null then 1 else 0 end) samoplatec,
    sum( case when p.id_platitela is null then 1 else 0 end) zamestnanec,
    count (p.rod_cislo)
from p_krajina kr
join p_kraj k on (k.id_krajiny = kr.id_krajiny)
join p_okres ok on (ok.id_kraja = k.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
join p_poistenie p on (p.rod_cislo = o.rod_cislo)
where n_krajiny = 'Cesko'
group by n_kraja;




---- TEST 6 ------
-- 43.)
-- Vypíšte ku každému okresu Trenčianskeho kraja počet mužov a žien, 
-- ktoré sa v narodili na Štedrý deň. 
 select * from p_kraj;
 select 
    ok.n_okresu okres,
    sum(case when substr(o.rod_cislo,3,1) > 1 then 1 else 0 end) zeny,
    sum(case when substr(o.rod_cislo,3,1) <= 1 then 1 else 0 end) muzi
from p_kraj k
join p_okres ok on (k.id_kraja = ok.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on (o.psc = m.psc)
where substr(o.rod_cislo,3,2) = '12' and substr(o.rod_cislo,5,2) = '24'
    and k.id_kraja = 'TN'
group by ok.n_okresu;


set SERVEROUTPUT on;
declare 
    type t_pole is table of integer; 
    i integer;
    pole t_pole; 
    j integer; 
begin 
    pole := t_pole(1,2,3,4,5,6,7,8); 
    pole.delete(3); 
    j := pole.first; 
    for i in 1 .. pole.count
        loop 
            dbms_output.put_line(pole(j)); 
            j := pole.next(j); 
        end loop; 
end;
/

-- ======== TITANIK EVERGREEN ===========

-- vypíšte všetkých zamestnávateľov, ktorý nemajú zamestnancov
select
    za.nazov
from p_zamestnavatel za
where not exists(select 'x' from p_zamestnanec z
                where z.id_zamestnavatela = za.ico) ;
                
                --85794515   
                
select * from p_zamestnavatel;
select count(*) from p_zamestnanec;
  -- where id_zamestnavatela <> '85794515';
  
-- pre každého zamestnavateľa vypísať koľko má zamestnncov 
select
    za.nazov,
    count(z.rod_cislo)
from p_zamestnavatel za
left join p_zamestnanec z on (za.ico = z.id_zamestnavatela)
--having count(z.rod_cislo) = 0
group by za.nazov;

-- vypísať poistencov a ak existuje pladba tak aj cis_platby a sumu
select
    o.meno,
    o.priezvisko,
    po.id_poistenca,
    od.cis_platby,
    od.suma
from p_osoba o
join p_poistenie po on(o.rod_cislo = po.rod_cislo)
left join p_odvod_platba od on(od.id_poistenca = po.id_poistenca)
order by od.suma ;

-- vypísať všetky ženy pre všetky okresy, ak tam nie sú ženy, 
-- vypísať aspoň názov okresa
select
    ok.n_okresu,
    o.meno,
    o.priezvisko
from p_okres ok
join p_mesto m on(m.id_okresu = ok.id_okresu)
right join p_osoba o on(m.psc = o.psc)
where substr(o.rod_cislo,3,1) > 1
order by n_okresu, o.meno;
-- mesto
select
    m.n_mesta,
    o.meno,
    o.priezvisko
from p_mesto m 
left join p_osoba o on(m.psc = o.psc)
where substr(o.rod_cislo,3,1) > 1
order by m.n_mesta, o.meno desc;
    
-- vypísať všetkých poistencov, odkedy sú poistencami a ak sú aj zamestnancami
-- tak ich ID a odkedy pracujú

select
    o.meno,
    o.priezvisko,
    p.rod_cislo,
    max(p.dat_od), -- aby to každého človeka vypísalo iba raz 
    z.id_poistenca,
    z.dat_od
from p_osoba o 
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
left join p_zamestnanec z on(z.rod_cislo = p.rod_cislo)
group by o.meno, o.priezvisko, z.id_poistenca, z.dat_od, p.rod_cislo
order by z.id_poistenca;

-- vytvoriť typ T_SUPERMARKET s troma ľubovoľními typmi a vytvoriť premennú typu T_SUPERMARKET

create type t_supermarket as object(
    id integer,
    nazov varchar2(25),
    popis varchar2(100)
)not final;
/
-- takto tú premnnú??
variable super t_supermarket;
;
/*
declare
    super t_supermarket := t_supermarket()
begin
    .....
end;
/
*/

set SERVEROUTPUT on;

-- ================= RECORD =================
declare
    -- deklarácia typu
    TYPE moj_rekord IS RECORD(
        rc char(11),
        meno varchar2(20),
        priezvisko varchar2(20)
    );
    rekord moj_rekord; -- deklarácia premennej toho typu
    cursor cur is (select rod_cislo, meno, priezvisko from os_udaje);
begin
    -- práce s kurzorom 
    open cur;
    loop
        fetch cur into rekord;
        exit when cur%notfound;
        dbms_output.put_line(rekord.rc || '  ' ||
                                rekord.meno || '  ' ||
                                rekord.priezvisko);
    end loop;
    close cur;
end;
/
-- ================= BULK COLLECTION =================
set serveroutput on;
declare
    type t_pole is table of varchar2(50);
    pole t_pole;
begin
    select meno bulk collect into pole from os_udaje;
    
    for i in pole.first..pole.count
    loop
        dbms_output.put_line(pole(i));
    end loop;
end;
/

-- do kurzora 
declare
    type t_pole is table of os_udaje%rowtype;
    pole t_pole;
    cursor cur is (select * from os_udaje);
begin
    open cur;
    loop
        fetch cur bulk collect into pole;
        exit when cur%notfound;
    end loop;
    close cur;
    
    for i in pole.first..pole.last
    loop
        dbms_output.put_line(pole(i).meno || ' ' || 
                                pole(i).priezvisko || ' ' ||
                                pole(i).rod_cislo);
    end loop;
end;
/


