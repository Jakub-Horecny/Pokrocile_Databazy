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

-- alebo:
select
    id_postihnutia,
    count(id_ztp) pocet
from p_ztp
where extract(year from dat_od) = extract(year from add_months(sysdate,-12))
group by id_postihnutia;


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


select 
    count(*) 
from p_ztp z
where not exists (select 'x' from p_poberatel p
                    join p_prispevky pr on (pr.id_poberatela = p.id_poberatela)
                    where p.rod_cislo = z.rod_cislo 
                    and
                    (kedy between dat_od and dat_do));


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



-- ine 
-- naplnte dan� kolekciu - poziciu bude d�va� atribut id_ztp, samotn� hodnota bude
-- vyjadrova� roky, kedy osoba za�ala a skon�ila by� ZTP
-- prvok na poz�ci� 12: "2014-2020"
-- prvok na poz�cii 23: "2019-neukon�en�"
set SERVEROUTPUT on;
declare
    type t_pole is table of varchar2(30) index by binary_integer;
    pole t_pole;
begin
    -- toto bolo treba doplni� 
    for i in (select 
                    id_ztp, 
                    to_char(extract(year from dat_od)) od, 
                    (case when dat_do is null then 'neukon�en�' else to_char(extract(year from dat_od)) end) do
                from p_ztp)
    loop
        pole(i.id_ztp) := i.od ||' - ' || i.do;
        dbms_output.put_line(pole(i.id_ztp));
    end loop;
    -- *****************************
end;
/


-- Vygenerujete pr�kaz, pomocou ktor�ho nastav�te v�etk�m pou��vate�om heslo vo form�te priezvisko
-- meno, a ID_poistenca. Pou�ite tabu�ku p_poistenie 
select 'Change password ' || users || ' to new password: ' || priezvisko || meno || id_poistenca
                                                    from p_osoba
                                                    join p_poistenie using(rod_cislo);



-- vytvori� navhodnej�� index pre tabu�ku p_odvod_platba

select rod_cislo, meno, priezvisko, sum(suma)
from p_osoba join p_poistenie using(rod_cislo)
join p_odvod_platba using(id_poistenca)
where obdobie > trunc(sysdate, 'YYYY')
group by rod_cislo, meno, priezvisko;

drop index ind100;
create index ind100 on p_odvod_platba(obdobie, id_poistenca, suma);




-- vyp�te nasledovn� �tatistiku k jednotliv�m mest�m nitriansk�ho kraja pre 
-- obdobie od 16.6.2016 do 19.6.2016 celkov� sumu, ktor� bolo zaplaten� 
-- poberate�mi v danom kraji

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


-- Namiesto XXXXXX nap�sa� vhodn� pr�kaz select, 
-- na naplnenie vzorovej tabu�ky nested table

declare
    type t_tp is table of p_typ_prispevku.popis%type;
    p_prispevky_typ t_tp;
begin
    dbms_output.put_line('1');
    select popis bulk collect into p_prispevky_typ from p_typ_prispevku;
end;
/

-- vytvorte XML nasleduj�ceho form�tu - poberatelia, ktor� dostali 
-- doteraz celkova aspo� 1000�
/*
<mesto nazov='Nazov'>
<osoby>
    <clovek>Michal Kvet</clovek>
    <clovek>Marak Kvet</clovek>
</osoby>
</mesto>
*/


-- vyp�te ICO a n�zvy v�etk�ch zamestn�vate�ov z mesta �ilina.
-- Ak m� zamestnavate� aj zamestnancov, vyp�te ich rodn� ��sla 
-- a d�tum n�stupu do zamestannia

select
    za.ico,
    z.rod_cislo,
    z.dat_od
from p_mesto m
join p_zamestnavatel za on (za.psc = m.psc)
left join p_zamestnanec z on(za.ico = z.id_zamestnavatela)
where m.n_mesta like '%Zilina%'; -- zilin je tu viac

-- vyp�te n�zvy miest, v ktor�ch sa nevyskytuj� osoby s postihnut�m "mest�lna porucha"

select
    m.n_mesta
from p_mesto m
join p_osoba o on(o.psc = m.psc)
join p_ztp z on(z.rod_cislo = o.rod_cislo)
join p_typ_postihnutia t on(t.id_postihnutia = z.id_postihnutia)
where t.nazov_postihnutia <> 'Mentalne/Dusevne Postihnutie';


-- aktualizujte v tabu�ke p_typ_prispevku historick� z�znamy z ceny 500� na 700�
-- pre typ s ID=12 a popisom 'testovanie syst�mu'
-- (z�znami vkladajte do nested table p_historia).

update table(
    SELECT t.historia from p_typ_prispevku t
    where t.id_typu = 12
) inner_t 
set historia.suma = 700
where historia.suma = 500;

