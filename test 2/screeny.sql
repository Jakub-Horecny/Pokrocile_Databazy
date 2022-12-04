-- vytvorte najvhodnejší index(indexy) pre danı príkaz Select
select rod_cislo, meno, priezvisko, n_mesta as aktualne_mesto
from p_osoba
join p_mesto using(psc)
where substr(meno, 1,4) = 'Mich'; --16 bez

drop index t_ind1;
drop index t_ind2;

-- musi tam by aj meno, lebo je v selecte 
-- psc tam musí by, lebo cez to sa robí spojenie tabuliek, a tie je to FK 
create index t_ind1 on p_osoba(substr(meno, 1,4), rod_cislo, meno, priezvisko, psc);
create index t_ind2 on p_mesto(psc, n_mesta);



-- ktorım príkazom zabezpeèíme vloenie nového riadku do tabu¾ky s nasledovnou štruktúrou:
create or replace type t_adresa is object (
    psc char(5),
    ulica varchar2(25),
    nazov_mesta varchar2(30)
);
create or replace type t_osoba is object (
    id_osoby integer,
    meno varchar2(15),
    priezvisko varchar2(15),
    adresa t_adresa
); 

create table osoba of t_osoba;
insert into osoba values (t_osoba(12, 'Jakub', 'h', t_adresa('12345', 'vysokoskolakov' , 'Zilina')));



