/*
indický tutorial 
https://www.youtube.com/watch?v=7bOU0m2FoYs
*/
set SERVEROUTPUT on;

declare
TYPE t_pole IS VARRAY(5) OF NUMBER; -- step 1 vytvorenie dátového typu
--pole t_pole := t_pole(); -- step 2

pole t_pole := t_pole();
begin
    --dbms_output.put_line(pole.limit);
    -- toto dá chybu, aj keï tu nie je syntaxová chyba
    -- najskôr je potrebné alokova pamä 
    for i in 1..pole.limit
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;
/

declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    -- táto inicializácia je dobrá iba keï mám malú ve¾kos varray
    -- nemusí ich by 5, ale 5 je maximum 
     pole t_pole := t_pole(null,null,null);
begin
    for i in 1..pole.count
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- dynamická alokácia pamäe 
declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    pole t_pole := t_pole();
begin
    for i in 1..pole.limit
    loop
        pole.extend;  -- použije extend metodú 
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- jednorázová alokácia 
declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    pole t_pole := t_pole();
begin
    pole.extend(5); -- 5 je max ve¾kosr varrray
    for i in 1..pole.limit
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- ================ ULOHY ==================
-- ============= KOLEKCIE 5.1.2 =============

-- vytvorte nepomenovaný blok príkazov

declare
    TYPE t_pole IS VARRAY(10) OF NUMBER;  -- vytvorete typ t_pole ako pole celých èísel varray s max dåžkou 10 
    pole t_pole := t_pole(10,20,30,40,50); -- vytvorte premennú pole a naplnte ju 5 èíslami
begin
    dbms_output.put_line(pole.count);-- vypíšte poèet prvkov pola 
    
    -- vypíšte obsah pola
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vložte da¾šie èíslo do pola 
    pole.extend;
    pole(pole.last):=60;
    dbms_output.put_line(pole(pole.last));
    
    -- opä vypíšte obsah pola 
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- pokúste sa vymaza 3 prvok po¾a (dá to chybu)
    --pole.delete(3);
end;    
/

-- to isté sprave pre nested table 
-- 'tabulka v tabulke'

declare
    type t_pole is table of number; -- vytvorete typ t_pole ako pole celých èísel varray s max dåžkou 10 
    pole t_pole := t_pole(10,20,30,40,50); -- vytvorte premennú pole a naplnte ju 5 èíslami
    j integer := 1;
begin
    dbms_output.put_line(pole.count);-- vypíšte poèet prvkov pola 
    
     -- vypíšte obsah pola
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vložte da¾šie èíslo do pola 
    pole.extend;
    pole(pole.last):=60;
    dbms_output.put_line(pole(pole.last));
    
    -- opä vypíšte obsah pola 
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vymažte prvok 3 a 4
    pole.delete(3,4); -- alebo jeden po druhom
    
    -- opä vypíšte obsah pola pomocou nasledovných cyklov 
    
    -- dá to chybu, no data found 
    for i in 1..pole.count
    loop
        dbms_output.put_line(pole(i));
    end loop;
    
    -- dá to chybu, no data found 
    for i in pole.first..pole.last 
    loop
        dbms_output.put_line(pole(i));
    end loop;
    
    -- vypíše iba prvé dva prvky 
    while pole.exists(j) loop
        dbms_output.put_line(pole(j));
        j:=j+1;
    end loop;
end;
/


-- ========= ULOHY Z PREZENTACIE ADBS_P5_KOLEKCIE =========
declare
 type t_pole is table of integer;
 pole t_pole:=t_pole(10,20,30,40,50);
begin
 dbms_output.put_line('pole.count: ' || pole.count); -- poèet prvkov 5
 dbms_output.put_line('pole.last: ' || pole.last); -- index posledného prvku 5
 pole.delete(3);
  dbms_output.put_line('Po delete prvku na indexe 3:');
  dbms_output.put_line('pole.count: ' || pole.count); -- 4
 dbms_output.put_line('pole.last: ' || pole.last); -- 5
 pole(3) :=  30;
 pole.delete(pole.last);
 dbms_output.put_line('Po delete prvku na indexe pole.last:');
  dbms_output.put_line('pole.count: ' || pole.count); -- 4
 dbms_output.put_line('pole.last: ' || pole.last); -- 4
 
end;
/
/*
    NESTED TABLE
    count = last --> ak tam napr. deklarujem 5 prvkov
    count > last --> ak zmažem prvok KTORY NIE JE NA INDEXE POLE.LAST
    count < last --> nikdy 
    
    DELETE
    pole.delete(3); --> zmaže prvok na indexe 3
    pole.delete(2, 3); --> zmaže prvok na indexe 2 a 3
    pole.delete(3, 2); --> žiadny prvok nebude zmazaný, ale nenastane chyba
                        prvý prvok musí by menší rovný druhému
    pole.delete(2, 2);  --> zmaže sa prvok dva, nenastane chyba  
    pole.delete --> vymaže všetko 
    
*/

declare
 type t_pole is table of integer;
 pole t_pole:=t_pole(10,20,30,40,50);
begin
 pole.extend(1);
 pole(pole.last):=60; -- priradím hodnotu 60 poslednému prvku (50)
 dbms_output.put_line(pole.count);
 
 for i in 1..pole.count
 loop
    dbms_output.put_line(pole(i));
 end loop;
end;
/

declare
 type t_pole is table of integer;
 pole t_pole:=t_pole(10,20,30,40,50);
begin
 pole.extend(1);
 dbms_output.put_line(pole.count); -- 6, posledný prvok je NULL	
end;
end;
/

declare
 type t_pole is table of integer;
 pole t_pole:=t_pole(10,20,30,40,50);
begin
 pole.delete(3,4);
  dbms_output.put_line(pole(pole.next(6)));
end;
/


create or replace type t_varray is varray(10) of integer;
/
create table pole_tab(id integer, pole t_varray);

insert into pole_tab values(2, t_varray(22,222,2222));
insert into pole_tab values(3, t_varray(33,333,3333));

declare
 type t_pole is varray(10) of integer;
 v_pole t_pole;
begin
 v_pole:=t_pole(10,20,30);
 insert into pole_tab values(1,v_pole);
end;
/			
--toto nejde ? inconsistent datatypes



























