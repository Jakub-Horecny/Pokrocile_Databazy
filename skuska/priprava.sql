-- 1.) pomocou selektu rozdeli všetkıch zamestnancov do 10 skupín tak
-- aby v kadej skupine bolo max o 1 viac/menej

-- akı èlovek patrí do akej skupiny
Select 
    rod_cislo, 
    mod(rn,10) skupina 
from (select 
        rod_cislo, 
        row_number() over(order by rod_cislo) rn 
    from p_zamestnanec)
order by skupina;


-- ko¾ko ¾udí je v ktorej skupine 
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


-- 2.) naplni index by table dátami tak e index, kde da dáta, bude id poberatela
-- a dáta budú dátum_od, dátum_do
set SERVEROUTPUT on;

-- deklarácia objektu
create or replace type pob as object(
    t_dat_od date,
    t_dat_do date
);
/

declare
    type t_pob is table of pob index by binary_integer; 
    t_poberatelia t_pob;   
begin
    -- naplnenie tabu¾ky 
    for i in (select id_poberatela, dat_od, dat_do from p_poberatel)
    loop
        t_poberatelia(i.id_poberatela) := pob(i.dat_od, i.dat_do);
    end loop;
    
    -- vıpis
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

select id_poberatela from p_poberatel;