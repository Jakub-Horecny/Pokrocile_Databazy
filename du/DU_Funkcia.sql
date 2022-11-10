-- druhá vec 
-- funkcia, ktorá mi nahradí reazec 
-- vstup: Ahoj michal
-- mám parameter e z A sa stane male a.. a tak ïalej, môem neni viac vecí 
-- funkcia má 3 parametere
-- vstupnı raazec - môem tam da ¾ubovo¾nı poèet zmien -- modelova to pod¾a nejakej kolekcie 
-- 2 parameter pôvodné hodnoty ktoré transformujem -- vstupnı parameter musí by kolekcia 
-- 3 parameter naèo ich transformujem 
-- do piatku 

-- spracuj('AHOJ Miško', kol('A', 'o'), kol('a', 'c'))

set SERVEROUTPUT on;
create type t_retazec as table of varchar2(1);
/

drop type t_retazec;

create or replace function uprav_retazec(retazec varchar2, ori t_retazec, rep t_retazec)
return varchar2
is
temp_retazec varchar2(150) := retazec;
begin
    if ori.count <> rep.count then
        RAISE_APPLICATION_ERROR(-20000, 'Vstupné reazce nemajú rovnakú dåku! ');
    --ELSIF ori.count = 0 or rep.count = 0 then
      --  RAISE_APPLICATION_ERROR(-20001, 'Vstupné kolekcie nemôu by prázdne! ');
    end if;
    
    for i in 1..ori.count
    loop
        temp_retazec := replace(temp_retazec, ori(i), rep(i));
        --dbms_output.put_line(replace(retazec, ori(i), rep(i)));
    end loop;
    return temp_retazec;
end;
/

select uprav_retazec('Ahoj ako sa máš', t_retazec(), t_retazec()) from dual;
select 
    uprav_retazec('Ahoj ako sa máš', t_retazec('a', 'h', 'o' ), t_retazec('x', 'y', 'z'))
from dual;
select REPLACE('Ahoj ako sa mas', 'a', 'x') from dual;







