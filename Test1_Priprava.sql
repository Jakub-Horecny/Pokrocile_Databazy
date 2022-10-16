/* 1.) UrËite spr·vny prÌkaz na vloûenie novÈho priadku do tabuæky zamestnanci s 
nasleduj˙cov ötrukt˙rov */

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
-- spr·vny insert, keÔ si to pozrieö cez desc t_zam, ako by tabuæka zamestnanci 
-- mala5 stÂpcov 
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

drop table zamestnanci;
drop type t_zam;
drop type t_osoba1;

/*
2.) K jednotliv˝m krajom Slovenskej republiky a mesiacom prvÈho kvart·lu roku 2008 
vypÌöte celkov˙ sumu odveden˙ samoplatcami
*/
-- je to pre jednotlivÈ mesiace, ak iba kvart·li tak preË: 'M' ||  extract(month from dat_platby) mesiac 
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
and extract(year from dat_platby) = 2016 -- 2008 niË nevr·ti nie s˙ z·znami, 2016 ·no
group by kr.n_kraja, kr.id_kraja, 'M' ||  extract(month from dat_platby) 
order by kr.n_kraja, 'M' ||  extract(month from dat_platby)
;

-- 6.) vypÌsaù kraje kde b˝va viac ûien ako muûov 
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

-- 16.) Ku kaûdÈmu drûiteæovi ZTP vypÌöte sumu prÌspevkov, 
-- ktorÈ dostal za minul˝ kalend·rny rok.

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

-- 23.) K jednotliv˝m n·zvom zamestn·vateæov a kvart·lom minulÈho roka vypÌöte 
-- poËet prijat˝ch osÙb do zamestnania

select 
    ('Q' || ceil((extract(month from za.dat_od)) / 3)) kvartal,
    z.nazov,
    count(*)
from p_zamestnavatel z
join p_zamestnanec za on(za.id_zamestnavatela = z.ico)
where extract(year from dat_od) = extract(year from sysdate) -6  -- -1 niË ned·
group by ('Q' || ceil((extract(month from za.dat_od)) / 3)), z.nazov
order by z.nazov, kvartal;

-- 24.)
-- Pre kaûd˝ okres vypÌöte osobu, ktor· bola poistencom najdlhöie. Ak bola evidovan· viackr·t, intervaly sËÌtajte
SELECT 
    n_okresu, 
    meno, 
    priezvisko 
FROM
    (SELECT 
        n_okresu, 
        meno, 
        priezvisko, 
        RANK() OVER (PARTITION BY id_okresu ORDER BY trvanie DESC) poradie 
    FROM
        (SELECT 
            n_okresu, 
            id_okresu, 
            meno, 
            priezvisko, 
            SUM(NVL(dat_do, SYSDATE) - dat_od) trvanie
        FROM p_okres 
        JOIN p_mesto USING (id_okresu) 
        JOIN p_osoba USING (PSC)
        JOIN p_poistenie 
        USING (rod_cislo)
        GROUP BY n_okresu, id_okresu, meno, priezvisko, rod_cislo))
WHERE poradie = 1;

-- 38.)
-- Pre jednotlivÈ mest· Nitrianskeho kraja vypÌöte percentu·lne rozloûenie muûov a ûien.
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
-- VypÌöte 5% obyvateæov s najv‰ËöÌmi odvodmi do poisùovne pre kaûdÈ mesto osobitne.
select
    meno,
    priezvisko,
    rod_cislo,
    suma
from
    (select
        o.meno meno,
        o.priezvisko priezvisko,
        o.rod_cislo rod_cislo,
        sum(od.suma) suma,
        rank() over (order by sum(od.suma) desc) rn
    from p_mesto m
    join p_osoba o on(m.psc = o.psc)
    join p_poistenie po on(po.rod_cislo = o.rod_cislo)
    join p_odvod_platba od on(od.id_poistenca = po.id_poistenca)
    group by o.meno, o.priezvisko, o.rod_cislo, od.suma
    )
having rn <= ceil((select count(*) from p_odvod_platba)*0.05)
group by meno, priezvisko, rod_cislo,rn,suma;
    

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
-- K jednotliv˝m zamestn·vateæom vypÌöte poËet zamestnancov a samoplatcov do 4O rokov.

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

-- 24.)
-- Pre jednotlivÈ rozp‰tia s˙m 0 - 2000, 2001-40000,40001 - 80000 
-- vypÌöte poËet osÙb, ktorÌ t˙to Ëiastku celkovo odviedli do
-- poisùovne a s˙ z okresu éilina.

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
-- suma mÙûe byù v sume 
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
-- VypÌöte 30% najæudnatejöÌch krajÌn
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

-- VypÌöte 30% najæudnatejöÌch miest
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
-- Pre jednotlivÈ rozp‰tia s˙m 0 - 2000, 2001-40000,40001 - 80000 
-- vypÌöte percentu·lne rozloûenie osÙb, ktorÌ t˙to Ëiastku celkovo
-- odviedli do poisùovne a s˙ z okresu éilina.
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
-- Pre kaûd˝ typ postihnutia vypÌöte 3 osoby podæa dÂûky poberanie danÈho 
-- prÌspevku. Ak osoba poberala dan˝ prÌspevok viackr·t, dobu spoËÌtajte (p_ztp)
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
-- Pre kaûd˙ firmu vypÌöte 3 zamestnancov,
-- za ktor˝ch sa zaplatilo minul˝ rok na odvodoch najviac.

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
    where extract(year from dat_platby) = extract(year from sysdate) - 1
    group by za.ico, za.nazov, z.rod_cislo, o.suma, p.id_poistenca
    )
where rn <= 3
group by  nazov, rn, rod_cislo
order by nazov, rn;


---- TEST 6 ------
-- 43.)
-- VypÌöte ku kaûdÈmu okresu TrenËianskeho kraja poËet muûov a ûien, 
-- ktorÈ sa v narodili na ätedr˝ deÚ. 
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

-- vypÌöte vöetk˝ch zamestn·vateæov, ktor˝ nemaj˙ zamestnancov
select
    za.nazov
from p_zamestnavatel za
where not exists(select 'x' from p_zamestnanec z
                where z.id_zamestnavatela = za.ico) ;
                
                --85794515   
                
select * from p_zamestnavatel;
select count(*) from p_zamestnanec;
  -- where id_zamestnavatela <> '85794515';
  
-- pre kaûdÈho zamestnavateæa vypÌsaù koæko m· zamestnncov 
select
    za.nazov,
    count(z.rod_cislo)
from p_zamestnavatel za
left join p_zamestnanec z on (za.ico = z.id_zamestnavatela)
--having count(z.rod_cislo) = 0
group by za.nazov;

-- vypÌsaù poistencov a ak existuje pladba tak aj cis_platby a sumu
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

-- vypÌsaù vöetky ûeny pre vöetky okresy, ak tam nie s˙ ûeny, 
-- vypÌsaù aspoÚ n·zov okresa
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
    
-- vypÌsaù vöetk˝ch poistencov, odkedy s˙ poistencami a ak s˙ aj zamestnancami
-- tak ich ID a odkedy pracuj˙

select
    o.meno,
    o.priezvisko,
    p.rod_cislo,
    max(p.dat_od), -- aby to kaûdÈho Ëloveka vypÌsalo iba raz 
    z.id_poistenca,
    z.dat_od
from p_osoba o 
join p_poistenie p on(o.rod_cislo = p.rod_cislo)
left join p_zamestnanec z on(z.rod_cislo = p.rod_cislo)
group by o.meno, o.priezvisko, z.id_poistenca, z.dat_od, p.rod_cislo
order by z.id_poistenca;

-- vytvoriù typ T_SUPERMARKET s troma æubovoænÌmi typmi a vytvoriù premenn˙ typu T_SUPERMARKET

create type t_supermarket as object(
    id integer,
    nazov varchar2(25),
    popis varchar2(100)
)not final;
/
-- takto t˙ premnn˙??
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

