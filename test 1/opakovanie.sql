-- join napola�� duplicity 
select meno, priezvisko
from os_udaje
where rod_cislo IN (select rod_cislo from student);

select meno, priezvisko
from os_udaje o
where exists (select os_cislo from student s 
                where o.rod_cislo = s.rod_cislo);

-- join
select distinct meno, priezvisko, os_cislo
from os_udaje
left join student using(rod_cislo);

-- semi join - cez IN/exists 
-- anti join - NOT IN/ NOT EXISTS

-- ======== agrega�n� funkcie ========
-- ignoruj� NULL hodnoty 
-- do GROUP by definujem skupiny, pre ktor� rob�m v�po�et


-- ko�ko kr�t bola dan� osoba �tudentom
select count(*) pocet, meno, priezvisko, rod_cislo
from os_udaje
join student using(rod_cislo)
group by meno, priezvisko, rod_cislo
-- to �o je v select mus� �s� do GROUP BY, okrem agrega�nej funkcie
having count(*) > 1
order by meno;

select * from student where rod_cislo = '791229/5431';

/*
najsk�r sa vykon� podmienka where a vykon� sa spojenie tabuliek
dat� ktor� sa z�skaj� sa rozdelia do skup�n pod�a GROUP BY
vypo��ta sa hodnota agrega�nej funkcie 
ak potrebujem podmienku s agrega�nou funkciuo tak HAVING
*/

-- pre ka�d�ho �tudenta vyp�sa� po�et zap�san�ch predmetov 
-- mus� ma� v GOUP BY s.os_��slo preto�e chce� �tudentov
select 
    count(z.os_cislo) pocet, 
    meno, priezvisko, 
    s.os_cislo
from os_udaje o 
join student s ON(o.rod_cislo = s.rod_cislo)
left join zap_predmety z ON(z.os_cislo = s.os_cislo) 
-- left join ak chcem aj tak�ch �o maj� 0 predmetov
group by meno, priezvisko, s.os_cislo
order by pocet desc, meno;

select distinct os_cislo from zap_predmety;

select * from student where ukoncenie IS NOT NULL;
select count(*) from student;
select count(ukoncenie) from student;

-- osoba ktor� m� najviac zap�san�ch predmetov 
select 
    meno, 
    priezvisko, 
    s.rod_cislo,
    s.os_cislo,
    count(*) pocet
from os_udaje o 
join student s ON(o.rod_cislo = s.rod_cislo)
join zap_predmety z ON(z.os_cislo = s.os_cislo) 
group by meno, priezvisko, s.rod_cislo, s.os_cislo
having count(*) = (select max(count(*)) from zap_predmety group by os_cislo)
order by pocet desc, meno;

select max(count(*)) from zap_predmety group by os_cislo;

-- vyp�sa� ko�ko kreditov z�skala dan� osoba 
select
    meno,
    priezvisko,
    s.rod_cislo,
    s.os_cislo,
    sum(z.ects) pocet
from os_udaje o
join student s on(o.rod_cislo = s.rod_cislo)
left join zap_predmety z on(z.os_cislo = s.os_cislo)
group by meno, priezvisko, s.rod_cislo, s.os_cislo
order by pocet desc, meno, priezvisko;

-- pre ka�d�ho �tudenta vyp�sa� zoznam predmetov 
-- ktor� si m��e zap�sa� a e�te ich neabsolvovoal 

