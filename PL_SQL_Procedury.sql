/*
procedúra
blok príkazov môe by 
     annonymní - priamo spustím na DB sysétme ale niè sa tam neuloí
alebo to môe by procedúra/funkcia 
musí tam by minimálne jedenp ríkaz inak to nebude fungova
*/

set SERVEROUTPUT on;
-- blok kódu príkazov
begin
    dbms_output.put_line('text');
end;  -- ukonèovací znak bloku príkazov, je potrebné  
/

-- premenné su defaultne NULL, všetky
declare
i integer := 3;
text char(10):=''; -- toto nie je null
j integer :=10;
begin
    if text is null then 
        dbms_output.put_line('hodnota je jedna');
    elsif i = 2 then -- v rovnakom if
        dbms_output.put_line('hodnota je dva');
    else if i = 3 then -- novı IF, ktorı treba ukonèi
        dbms_output.put_line('hodnota je tri');
    else
        dbms_output.put_line('netuším');
        end if; -- tu ho treba ukonèi 
    end if;
end;
/

-- príkaz CASE
-- ka by tam nebolo else a niè iné sa nezhoduje vyhodí vınimku

declare
i integer;
j integer := 5;
begin
    case i
        -- nemôem pokri hodnoty NULL
        -- nem,ôem ma when NULL then, pretoe je to cez = 
        when 1 then dbms_output.put_line('hodnota je jedna');
        when 2 then dbms_output.put_line('hodnota je dva');
        when 3 then dbms_output.put_line('hodnota je tri');
        when 4 then dbms_output.put_line('hodnota je 4');
        else dbms_output.put_line('?????????????');
    end case;
    
    -- takto to u NULL pokrije 
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
-- loop - v podstate while, musím tam ma podmienku na ukonèenie 
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


--- pracá s dátami v satabázy
-- SELECT INTO - musí vráti práve jeden záznam
-- ak nevráti niè, dá to vınimku 

DECLARE
pocet integer; -- dátovı typ by mal takı ako v tabu¾ke 
v_priezvisko varchar(50); -- premenné by sa mali vola inak ako ståpce v tabu¾ke 
v_meno varchar(50);
v_meno2 os_udaje.meno%type; -- premnná má rovnakı dátovı typ ako v tabu¾ke 
begin
    select count(*) into pocet from os_udaje;
    dbms_output.put_line(pocet);
    
    select priezvisko into v_priezvisko from os_udaje where rod_cislo ='841106/3456';
    dbms_output.put_line(v_priezvisko);
    
    select meno, priezvisko into v_meno2, v_priezvisko 
    from os_udaje where rod_cislo ='841106/3456';
    dbms_output.put_line(v_meno2 || ' ' || v_priezvisko);
    
    -- vınimky 
    EXCEPTION
        when no_data_found then 
            dbms_output.put_line('Osoba neexistuje !!!');
        when others then 
            dbms_output.put_line('iná chyba !!!');
end;
/

-- ======== vlastná vınimka ========

declare
pocet integer;
no_data EXCEPTION;
pragma exception_init(no_data, -20000);
begin
    select count(*) into pocet from os_udaje; -- toto nie tie kurzor, ktorı spracováva práve jedne záznam 
    if pocet <> 1 then
        -- od <-20000; 20999>
        RAISE_APPLICATION_ERROR(-20000, 'Nastala vlastná vınimka.');
    end if;
    
    EXCEPTION
        when no_data then dbms_output.put_line('RIP');
end;
/

--- ========== CURZOR ============

-- chcem si na konzolu vypísa zoznam osôb cez kurzor
DECLARE
-- premenná typu kurzor s asociáciou na select
cursor cur_osoba is (select meno, priezvisko, rod_cislo from os_udaje
                        where substr(rod_cislo,3,1) > 1);
-- teraz potrebujem premenné kde budem uklada meno a priezvisko
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
v_rod_cislo os_udaje.rod_cislo%type;
begin
    -- ne môem kurzor zaèa pouíva, potrebujem ho otvori
    -- skontrolujú sa príkazové práva (èi to môem spravi)
    -- v pamäti sa vytvorí objekt, zatia¾ sa iadne dáta nepriradili, iba sa naplnili 
    -- taraz mám v pamôti dáta a sekvenène ich môem vypisova
    open cur_osoba;
        loop
            -- fetch príkaz priradenia do danıch premnnıch 
            fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
            -- notfound mi hovorí èi sa priradila nová hodnota, ak nie exit 
            exit when cur_osoba%notfound;
            
            DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        end loop;
    CLOSE cur_osoba;
end;
/

-- kurzor s parametrom
-- takıto kurzor sa dá poui viac krát
declare
-- varchar2 - nezadávam ve¾kos 
cursor cur(p_meno varchar2) is (select meno, priezvisko, rod_cislo from os_udaje
                        where meno like p_meno||'%');
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
v_rod_cislo os_udaje.rod_cislo%type;
begin
    -- teraz ho musím otvori s parametrom 
    open cur('Z');
        loop
            fetch cur into v_meno, v_priezvisko, v_rod_cislo;
            exit when cur%notfound;
            DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        end loop;
    close cur;
end;
/

-- implicitnı kurzor 'anonymny' bez mena

begin
    -- platnos premenej riadok je v rámci loop 
    -- je vdy typu record, aj keby som získal iba jeden záznam  
    -- ak si tam dám alias, musím sa odkazova na alias
    for riadok in (select meno m, priezvisko from os_udaje)
        loop
            -- exit when riadok%notfound; -- tot nepotrebujem 
            DBMS_OUTPUT.PUT_LINE(riadok.m || ' ' || riadok.priezvisko);
        end loop;
    
end;
/

-- dva kurzori v jednej procedúre 
declare
-- explicitnı
cursor v_student(rc char) is (select os_cislo, rocnik from student 
                                where rod_cislo = rc);
v_os_cislo student.os_cislo%type;
v_rocnik student.rocnik%type;
begin
    -- impicitnı
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

------- procedúra z menom

create or replace procedure proc_select
is -- as
pocet integer;
begin
    select count(*) into pocet from os_udaje;
    DBMS_OUTPUT.PUT_line(pocet);
end;
/
-- procedúru menôem spusti cez select, lebo niè nevráti
-- funkcia a kspåna nejaké podmienky by to moné bolo 
exec proc_select;

-- so svtupnımi parametrami 
create or replace procedure proc_select2(m varchar2)
is
pocet integer;
begin
     select count(*) into pocet from os_udaje
        where meno like m||'%';
    DBMS_OUTPUT.PUT_line(pocet);
end;
/

-- prázdy reazec a NULL je to isté
exec proc_select2('M');

-- s návratovou hodnotou - to u musí by funkcia 

-- ak by mala návratovú hodnotu boolea tak ju viam skompilova ale nie zavola v selecte 
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