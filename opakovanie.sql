-- join napolaèí duplicity 
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

-- ======== agregaèné funkcie ========
-- ignorujú NULL hodnoty 
-- do GROUP by definujem skupiny, pre ktoré robím vıpoèet


-- ko¾ko krát bola daná osoba študentom
select count(*) pocet, meno, priezvisko, rod_cislo
from os_udaje
join student using(rod_cislo)
group by meno, priezvisko, rod_cislo
-- to èo je v select musí ís do GROUP BY, okrem agregaènej funkcie
having count(*) > 1
order by meno;

select * from student where rod_cislo = '791229/5431';

/*
najskôr sa vykoná podmienka where a vykoná sa spojenie tabuliek
datá ktoré sa získajú sa rozdelia do skupín pod¾a GROUP BY
vypoèíta sa hodnota agregaènej funkcie 
ak potrebujem podmienku s agregaènou funkciuo tak HAVING
*/

-- pre kadého študenta vypísa poèet zapísanıch predmetov 
-- musí ma v GOUP BY s.os_èíslo pretoe chceš študentov
select 
    count(z.os_cislo) pocet, 
    meno, priezvisko, 
    s.os_cislo
from os_udaje o 
join student s ON(o.rod_cislo = s.rod_cislo)
left join zap_predmety z ON(z.os_cislo = s.os_cislo) 
-- left join ak chcem aj takıch èo majú 0 predmetov
group by meno, priezvisko, s.os_cislo
order by pocet desc, meno;

select distinct os_cislo from zap_predmety;

select * from student where ukoncenie IS NOT NULL;
select count(*) from student;
select count(ukoncenie) from student;

-- osoba ktorá má najviac zapísaních predmetov 
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

-- vypísa ko¾ko kreditov získala daná osoba 
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

-- pre kadého študenta vypísa zoznam predmetov 
-- ktoré si môe zapísa a ešte ich neabsolvovoal 

