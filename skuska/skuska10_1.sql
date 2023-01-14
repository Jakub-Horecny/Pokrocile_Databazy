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

-- alebo:
select
    id_postihnutia,
    count(id_ztp) pocet
from p_ztp
where extract(year from dat_od) = extract(year from add_months(sysdate,-12))
group by id_postihnutia;


-- vypísa ZTP osoby èo majú platnı preukaz, a nedostali iadny príspevok
-- poui EXISTS

-- toto by malo by dobre 
Select distinct
    z.rod_cislo 
from p_ztp z
join p_poberatel p on (p.rod_cislo = z.rod_cislo) 
where not exists ( select 'x' from p_prispevky 
                    where id_poberatela = p.id_poberatela )
and z.dat_do is null or z.dat_do > sysdate;


select 
    count(*) 
from p_ztp z
where not exists (select 'x' from p_poberatel p
                    join p_prispevky pr on (pr.id_poberatela = p.id_poberatela)
                    where p.rod_cislo = z.rod_cislo 
                    and
                    (kedy between dat_od and dat_do));


-- pre kadı kraj vypísa 3 zamestnavate¾ov ktorı zaplatili 
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



-- ine 
-- naplnte danú kolekciu - poziciu bude dáva atribut id_ztp, samotná hodnota bude
-- vyjadrova roky, kedy osoba zaèala a skonèila by ZTP
-- prvok na pozícií 12: "2014-2020"
-- prvok na pozícii 23: "2019-neukonèené"
set SERVEROUTPUT on;
declare
    type t_pole is table of varchar2(30) index by binary_integer;
    pole t_pole;
begin
    -- toto bolo treba doplni 
    for i in (select 
                    id_ztp, 
                    to_char(extract(year from dat_od)) od, 
                    (case when dat_do is null then 'neukonèené' else to_char(extract(year from dat_od)) end) do
                from p_ztp)
    loop
        pole(i.id_ztp) := i.od ||' - ' || i.do;
        dbms_output.put_line(pole(i.id_ztp));
    end loop;
    -- *****************************
end;
/


-- Vygenerujete príkaz, pomocou ktorého nastavíte všetkım pouívate¾om heslo vo formáte priezvisko
-- meno, a ID_poistenca. Pouite tabu¾ku p_poistenie 
select 'Change password ' || users || ' to new password: ' || priezvisko || meno || id_poistenca
                                                    from p_osoba
                                                    join p_poistenie using(rod_cislo);



-- vytvori navhodnejší index pre tabu¾ku p_odvod_platba

select rod_cislo, meno, priezvisko, sum(suma)
from p_osoba join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
where obdobie > trunc(sysdate, 'YYYY')
group by rod_cislo, meno, priezvisko;

drop index ind100;
create index ind100 on p_odvod_platba(obdobie, id_poistenca, suma);




-- vypíšte nasledovnú štatistiku k jednotlivım mestám nitrianského kraja pre 
-- obdobie od 16.6.2016 do 19.6.2016 celkovú sumu, ktorá bolo zaplatená 
-- poberate¾mi v danom kraji

select
    m.n_mesta mesto,
    sum(case when pr.obdobie = to_date('16.6.2016', 'DD.MM.YYYY') then sum(suma) else 0 end) sum16,
    sum(case when pr.obdobie = to_date('17.6.2016', 'DD.MM.YYYY') then sum(suma) else 0 end) sum17,
    sum(case when pr.obdobie = to_date('18.6.2016', 'DD.MM.YYYY') then sum(suma) else 0 end) sum18,
    sum(case when pr.obdobie = to_date('19.6.2016', 'DD.MM.YYYY') then sum(suma) else 0 end) sum19
from p_kraj k
join p_okres ok on(ok.id_kraja = k.id_kraja)
join p_mesto m on (m.id_okresu = ok.id_okresu)
join p_osoba o on(o.psc = m.psc)
join p_poberatel po on(po.rod_cislo = o.rod_cislo)
join p_prispevky pr on (pr.id_poberatela = po.id_poberatela)
where k.id_kraja = 'NR' 
group by m.n_mesta;


-- Namiesto XXXXXX napísa vhodnı príkaz select, 
-- na naplnenie vzorovej tabu¾ky nested table

declare
    type t_tp is table of p_typ_prispevku.popis%type;
    p_prispevky_typ t_tp;
begin
    dbms_output.put_line('1');
    select popis bulk collect into p_prispevky_typ from p_typ_prispevku;
end;
/

-- vytvorte XML nasledujúceho formátu - poberatelia, ktorí dostali 
-- doteraz celkova aspoò 1000€
/*
<mesto nazov='Nazov'>
<osoby>
    <clovek>Michal Kvet</clovek>
    <clovek>Marak Kvet</clovek>
</osoby>
</mesto>
*/


-- vypíšte ICO a názvy všetkıch zamestnávate¾ov z mesta ilina.
-- Ak má zamestnavate¾ aj zamestnancov, vypíšte ich rodné èísla 
-- a dátum nástupu do zamestannia

select
    za.ico,
    z.rod_cislo,
    z.dat_od
from p_mesto m
join p_zamestnavatel za on (za.psc = m.psc)
left join p_zamestnanec z on(za.ico = z.id_zamestnavatela)
where m.n_mesta like '%Zilina%'; -- zilin je tu viac

-- vypíšte názvy miest, v ktorıch sa nevyskytujú osoby s postihnutím "mestálna porucha"

select
    m.n_mesta
from p_mesto m
join p_osoba o on(o.psc = m.psc)
join p_ztp z on(z.rod_cislo = o.rod_cislo)
join p_typ_postihnutia t on(t.id_postihnutia = z.id_postihnutia)
where t.nazov_postihnutia <> 'Mentalne/Dusevne Postihnutie';


-- aktualizujte v tabu¾ke p_typ_prispevku historické záznamy z ceny 500€ na 700€
-- pre typ s ID=12 a popisom 'testovanie systému'
-- (zíznami vkladajte do nested table p_historia).

update table(
    SELECT t.historia from p_typ_prispevku t
    where t.id_typu = 12
) inner_t 
set historia.suma = 700
where historia.suma = 500;

