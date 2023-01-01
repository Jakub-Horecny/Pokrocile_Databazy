-- 1.) pomocou selektu rozdeli� v�etk�ch zamestnancov do 10 skup�n tak
-- aby v ka�dej skupine bolo max o 1 viac/menej

-- ak� �lovek patr� do akej skupiny
Select 
    rod_cislo, 
    mod(rn,10) skupina 
from (select 
        rod_cislo, 
        row_number() over(order by rod_cislo) rn 
    from p_zamestnanec)
order by skupina;


-- ko�ko �ud� je v ktorej skupine 
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


-- 2.) naplni� index by table d�tami tak �e index, kde da� d�ta, bude id poberatela
-- a d�ta bud� d�tum_od, d�tum_do
set SERVEROUTPUT on;

-- deklar�cia objektu
create or replace type pob as object(
    t_dat_od date,
    t_dat_do date
);
/

declare
    type t_pob is table of pob index by binary_integer; 
    t_poberatelia t_pob;   
begin
    -- naplnenie tabu�ky 
    for i in (select id_poberatela, dat_od, dat_do from p_poberatel)
    loop
        t_poberatelia(i.id_poberatela) := pob(i.dat_od, i.dat_do);
    end loop;
    
    -- v�pis
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