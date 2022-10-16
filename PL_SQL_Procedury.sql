/*
proced�ra
blok pr�kazov m��e by� 
     annonymn� - priamo spust�m na DB sys�tme ale ni� sa tam neulo��
alebo to m��e by� proced�ra/funkcia 
mus� tam by� minim�lne jedenp r�kaz inak to nebude fungova�
*/

set SERVEROUTPUT on;
-- blok k�du pr�kazov
begin
    dbms_output.put_line('text');
end;  -- ukon�ovac� znak bloku pr�kazov, je potrebn�  
/

-- premenn� su defaultne NULL, v�etky
declare
i integer := 3;
text char(10):=''; -- toto nie je null
j integer :=10;
begin
    if text is null then 
        dbms_output.put_line('hodnota je jedna');
    elsif i = 2 then -- v rovnakom if
        dbms_output.put_line('hodnota je dva');
    else if i = 3 then -- nov� IF, ktor� treba ukon�i�
        dbms_output.put_line('hodnota je tri');
    else
        dbms_output.put_line('netu��m');
        end if; -- tu ho treba ukon�i� 
    end if;
end;
/

-- pr�kaz CASE
-- ka by tam nebolo else a ni� in� sa nezhoduje vyhod� v�nimku

declare
i integer;
j integer := 5;
begin
    case i
        -- nem��em pokri� hodnoty NULL
        -- nem,��em ma� when NULL then, preto�e je to cez = 
        when 1 then dbms_output.put_line('hodnota je jedna');
        when 2 then dbms_output.put_line('hodnota je dva');
        when 3 then dbms_output.put_line('hodnota je tri');
        when 4 then dbms_output.put_line('hodnota je 4');
        else dbms_output.put_line('?????????????');
    end case;
    
    -- takto to u� NULL pokrije 
    case j
        when j=1 then dbms_output.put_line('hodnota je jedna');
        when j=2 then dbms_output.put_line('hodnota je dva');
        when j=3 then dbms_output.put_line('hodnota je tri');
        when j is null then dbms_output.put_line('je to NULL');
        else dbms_output.put_line('?????????????');
    end case;
end;
/

-- cykli
-- loop - v podstate while, mus�m tam ma� podmienku na ukon�enie 
declare
i integer := 1;
j integer := 10;
begin
    loop
        dbms_output.put_line(i);
        i:=i+1;
        if i = 10 then
            exit;
        end if;
    end loop;
    dbms_output.put_line(' ');
    loop
        dbms_output.put_line(j);
        j:=j-1;
        exit when j=0;
    end loop;
end;
/

-- FOR
declare
i integer := 1;
begin
    FOR j IN 1..10 LOOP
          dbms_output.put_line(j);
        END LOOP;
    dbms_output.put_line('');
    FOR j IN reverse 1..10 LOOP
          dbms_output.put_line(j);
        END LOOP;
    dbms_output.put_line('');
    while i < 5 
    loop
        dbms_output.put_line(i);
        i := i + 1;
    end loop;
end;
/


--- prac� s d�tami v satab�zy
-- SELECT INTO - mus� vr�ti� pr�ve jeden z�znam
-- ak nevr�ti ni�, d� to v�nimku 

DECLARE
pocet integer; -- d�tov� typ by mal tak� ako v tabu�ke 
v_priezvisko varchar(50); -- premenn� by sa mali vola� inak ako st�pce v tabu�ke 
v_meno varchar(50);
v_meno2 os_udaje.meno%type; -- premnn� m� rovnak� d�tov� typ ako v tabu�ke 
begin
    select count(*) into pocet from os_udaje;
    dbms_output.put_line(pocet);
    
    select priezvisko into v_priezvisko from os_udaje where rod_cislo ='841106/3456';
    dbms_output.put_line(v_priezvisko);
    
    select meno, priezvisko into v_meno2, v_priezvisko 
    from os_udaje where rod_cislo ='841106/3456';
    dbms_output.put_line(v_meno2 || ' ' || v_priezvisko);
    
    -- v�nimky 
    EXCEPTION
        when no_data_found then 
            dbms_output.put_line('Osoba neexistuje !!!');
        when others then 
            dbms_output.put_line('in� chyba !!!');
end;
/

-- ======== vlastn� v�nimka ========

declare
pocet integer;
no_data EXCEPTION;
pragma exception_init(no_data, -20000);
begin
    select count(*) into pocet from os_udaje; -- toto nie tie� kurzor, ktor� spracov�va pr�ve jedne z�znam 
    if pocet <> 1 then
        -- od <-20000; 20999>
        RAISE_APPLICATION_ERROR(-20000, 'Nastala vlastn� v�nimka.');
    end if;
    
    EXCEPTION
        when no_data then dbms_output.put_line('RIP');
end;
/

--- ========== CURZOR ============

-- chcem si na konzolu vyp�sa� zoznam os�b cez kurzor
DECLARE
-- premenn� typu kurzor s asoci�ciou na select
cursor cur_osoba is (select meno, priezvisko, rod_cislo from os_udaje
                        where substr(rod_cislo,3,1) > 1);
-- teraz potrebujem premenn� kde budem uklada� meno a priezvisko
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
v_rod_cislo os_udaje.rod_cislo%type;
begin
    -- ne� m��em kurzor za�a� pou��va�, potrebujem ho otvori�
    -- skontroluj� sa pr�kazov� pr�va (�i to m��em spravi�)
    -- v pam�ti sa vytvor� objekt, zatia� sa �iadne d�ta nepriradili, iba sa naplnili 
    -- taraz m�m v pam�ti d�ta a sekven�ne ich m��em vypisova�
    open cur_osoba;
        loop
            -- fetch pr�kaz priradenia do dan�ch premnn�ch 
            fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
            -- notfound mi hovor� �i sa priradila nov� hodnota, ak nie exit 
            exit when cur_osoba%notfound;
            
            DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        end loop;
    CLOSE cur_osoba;
end;
/

-- kurzor s parametrom
-- tak�to kurzor sa d� pou�i� viac kr�t
declare
-- varchar2 - nezad�vam ve�kos� 
cursor cur(p_meno varchar2) is (select meno, priezvisko, rod_cislo from os_udaje
                        where meno like p_meno||'%');
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
v_rod_cislo os_udaje.rod_cislo%type;
begin
    -- teraz ho mus�m otvori� s parametrom 
    open cur('Z');
        loop
            fetch cur into v_meno, v_priezvisko, v_rod_cislo;
            exit when cur%notfound;
            DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        end loop;
    close cur;
end;
/

-- implicitn� kurzor 'anonymny' bez mena

begin
    -- platnos� premenej riadok je v r�mci loop 
    -- je v�dy typu record, aj keby som z�skal iba jeden z�znam  
    -- ak si tam d�m alias, mus�m sa odkazova� na alias
    for riadok in (select meno m, priezvisko from os_udaje)
        loop
            -- exit when riadok%notfound; -- tot nepotrebujem 
            DBMS_OUTPUT.PUT_LINE(riadok.m || ' ' || riadok.priezvisko);
        end loop;
    
end;
/

-- dva kurzori v jednej proced�re 
declare
-- explicitn�
cursor v_student(rc char) is (select os_cislo, rocnik from student 
                                where rod_cislo = rc);
v_os_cislo student.os_cislo%type;
v_rocnik student.rocnik%type;
begin
    -- impicitn�
    for riadok in (select meno m, priezvisko, rod_cislo from os_udaje)
        loop
            -- exit when riadok%notfound; -- tot nepotrebujem 
            
            open v_student(riadok.rod_cislo);
            loop
                fetch v_student into v_os_cislo, v_rocnik;
                exit when v_student%notfound;
                DBMS_OUTPUT.PUT(riadok.m || ' ' || riadok.priezvisko || ' ');
                DBMS_OUTPUT.PUT_LINE(v_os_cislo || ' ' || v_rocnik);
            end loop;
            CLOSE v_student;
        end loop;
end;
/

------- proced�ra z menom

create or replace procedure proc_select
is -- as
pocet integer;
begin
    select count(*) into pocet from os_udaje;
    DBMS_OUTPUT.PUT_line(pocet);
end;
/
-- proced�ru men��em spusti� cez select, lebo ni� nevr�ti
-- funkcia a ksp�na nejak� podmienky by to mo�n� bolo 
exec proc_select;

-- so svtupn�mi parametrami 
create or replace procedure proc_select2(m varchar2)
is
pocet integer;
begin
     select count(*) into pocet from os_udaje
        where meno like m||'%';
    DBMS_OUTPUT.PUT_line(pocet);
end;
/

-- pr�zdy re�azec a NULL je to ist�
exec proc_select2('M');

-- s n�vratovou hodnotou - to u� mus� by� funkcia 

-- ak by mala n�vratov� hodnotu boolea tak ju viam skompilova� ale nie zavola� v selecte 
create or replace function proc_select3(m varchar2)
return integer
is
pocet integer;
begin
     select count(*) into pocet from os_udaje
        where meno like m||'%';
    return pocet;
end;
/


select proc_select3('M') from dual;

variable i number
exec :i:=proc_select3('M')
print i
;