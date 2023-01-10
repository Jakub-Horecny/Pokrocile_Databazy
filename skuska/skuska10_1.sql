-- vypísa poèet vydanıch ZTP preukazov pre kadı typ postihnutia osobytne na
-- minulı kalendárny rok (toto si nepamätám presne, ale bolo tam nieèo s èasom)
select
    t.nazov_postihnutia,
    count(z.id_ztp)
from p_ztp z
join p_typ_postihnutia t on (z.id_postihnutia = t.id_postihnutia)
where extract(year from dat_od) = extract(year from sysdate)-1
group by t.nazov_postihnutia, t.id_postihnutia
order by t.id_postihnutia;

-- vypísa ZTP osoby èo majú platnı preukaz, a nedostali iadny príspevok
-- poui EXISTS

select distinct
    z.rod_cislo
from p_ztp z
where exists(select o.rod_cislo from p_osoba o
                join p_poberatel p on (o.rod_cislo = p.rod_cislo)
                join p_prispevky pr on (pr.id_poberatela = p.id_poberatela)
                group by o.rod_cislo
                having sum(suma) = 0)
and dat_do is null or dat_do > sysdate;

-- pre kadı kraj vypísa 3 zamestnavate¾ov pre kadıá kraj ktorı zaplatili 
-- najviac na odvodoch za poslednı mesiac

select
    *
from (
    select
        k.n_kraja kraj,
        za.ico ico,
        sum(od.suma) suma,
        rank() over (partition by k.n_kraja order by sum(od.suma) desc) rn
    from p_kraj k
    join p_okres ok on (k.id_kraja = ok.id_kraja)
    join p_mesto m on (m.id_okresu = ok.id_okresu)
    join p_zamestnavatel za on(za.psc = m.psc)
    join p_zamestnanec z on (z.id_zamestnavatela = za.ico)
    join p_poistenie p on (p.id_poistenca = z.id_poistenca)
    join p_odvod_platba od on (od.id_poistenca = p.id_poistenca)
    where extract(month from od.dat_platby) = extract(month from add_months(sysdate,-1))
    group by k.n_kraja, za.ico)
where rn <= 3;


