-- vyp�sa� po�et vydan�ch ZTP preukazov pre ka�d� typ postihnutia osobytne na
-- minul� kalend�rny rok (toto si nepam�t�m presne, ale bolo tam nie�o s �asom)
select
    t.nazov_postihnutia,
    count(z.id_ztp)
from p_ztp z
join p_typ_postihnutia t on (z.id_postihnutia = t.id_postihnutia)
where extract(year from dat_od) = extract(year from sysdate)-1
group by t.nazov_postihnutia, t.id_postihnutia
order by t.id_postihnutia;


-- vyp�sa� ZTP osoby �o maj� platn� preukaz, a nedostali �iadny pr�spevok
-- pou�i� EXISTS

-- toto by malo by� dobre 
Select distinct
    z.rod_cislo 
from p_ztp z
join p_poberatel p on (p.rod_cislo = z.rod_cislo) 
where not exists ( select 'x' from p_prispevky 
                    where id_poberatela = p.id_poberatela )
and z.dat_do is null or z.dat_do > sysdate;


-- pre ka�d� kraj vyp�sa� 3 zamestnavate�ov ktor� zaplatili 
-- najviac na odvodoch za posledn� mesiac
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




