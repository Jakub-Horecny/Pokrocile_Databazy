-- druh� vec 
-- funkcia, ktor� mi nahrad� re�azec 
-- vstup: Ahoj michal
-- m�m parameter �e z A sa stane male a.. a tak �alej, m��em neni� viac vec� 
-- funkcia m� 3 parametere
-- vstupn� ra�azec - m��em tam da� �ubovo�n� po�et zmien -- modelova� to pod�a nejakej kolekcie 
-- 2 parameter p�vodn� hodnoty ktor� transformujem -- vstupn� parameter mus� by� kolekcia 
-- 3 parameter na�o ich transformujem 
-- do piatku 

-- spracuj('AHOJ Mi�ko', kol('A', 'o'), kol('a', 'c'))

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
        RAISE_APPLICATION_ERROR(-20000, 'Vstupn� re�azce nemaj� rovnak� d�ku! ');
    --ELSIF ori.count = 0 or rep.count = 0 then
      --  RAISE_APPLICATION_ERROR(-20001, 'Vstupn� kolekcie nem��u by� pr�zdne! ');
    end if;
    
    for i in 1..ori.count
    loop
        temp_retazec := replace(temp_retazec, ori(i), rep(i));
        --dbms_output.put_line(replace(retazec, ori(i), rep(i)));
    end loop;
    return temp_retazec;
end;
/

select uprav_retazec('Ahoj ako sa m�', t_retazec(), t_retazec()) from dual;
select 
    uprav_retazec('Ahoj ako sa m�', t_retazec('a', 'h', 'o' ), t_retazec('x', 'y', 'z'))
from dual;
select REPLACE('Ahoj ako sa mas', 'a', 'x') from dual;







