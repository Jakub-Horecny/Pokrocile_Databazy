/*
indick� tutorial 
https://www.youtube.com/watch?v=7bOU0m2FoYs
*/
set SERVEROUTPUT on;

declare
TYPE t_pole IS VARRAY(5) OF NUMBER; -- step 1 vytvorenie d�tov�ho typu
--pole t_pole := t_pole(); -- step 2

pole t_pole := t_pole();
begin
    --dbms_output.put_line(pole.limit);
    -- toto d� chybu, aj ke� tu nie je syntaxov� chyba
    -- najsk�r je potrebn� alokova� pam� 
    for i in 1..pole.limit
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;
/

declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    -- t�to inicializ�cia je dobr� iba ke� m�m mal� ve�kos� varray
    -- nemus� ich by� 5, ale 5 je maximum 
     pole t_pole := t_pole(null,null,null);
begin
    for i in 1..pole.count
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- dynamick� alok�cia pam�e 
declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    pole t_pole := t_pole();
begin
    for i in 1..pole.limit
    loop
        pole.extend;  -- pou�ije extend metod� 
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- jednor�zov� alok�cia 
declare
    TYPE t_pole IS VARRAY(5) OF NUMBER; 
    pole t_pole := t_pole();
begin
    pole.extend(5); -- 5 je max ve�kosr varrray
    for i in 1..pole.limit
    loop
        pole(i) := 10*i;
        dbms_output.put_line(pole(i));
    end loop;
end;    
/

-- ================ ULOHY ==================
-- ============= KOLEKCIE 5.1.2 =============

-- vytvorte nepomenovan� blok pr�kazov

declare
    TYPE t_pole IS VARRAY(10) OF NUMBER;  -- vytvorete typ t_pole ako pole cel�ch ��sel varray s max d�kou 10 
    pole t_pole := t_pole(10,20,30,40,50); -- vytvorte premenn� pole a naplnte ju 5 ��slami
begin
    dbms_output.put_line(pole.count);-- vyp�te po�et prvkov pola 
    
    -- vyp�te obsah pola
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vlo�te da��ie ��slo do pola 
    pole.extend;
    pole(pole.last):=60;
    dbms_output.put_line(pole(pole.last));
    
    -- op� vyp�te obsah pola 
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- pok�ste sa vymaza� 3 prvok po�a (d� to chybu)
    --pole.delete(3);
end;    
/

-- to ist� sprav�e pre nested table 
-- 'tabulka v tabulke'

declare
    type t_pole is table of number; -- vytvorete typ t_pole ako pole cel�ch ��sel varray s max d�kou 10 
    pole t_pole := t_pole(10,20,30,40,50); -- vytvorte premenn� pole a naplnte ju 5 ��slami
    j integer := 1;
begin
    dbms_output.put_line(pole.count);-- vyp�te po�et prvkov pola 
    
     -- vyp�te obsah pola
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vlo�te da��ie ��slo do pola 
    pole.extend;
    pole(pole.last):=60;
    dbms_output.put_line(pole(pole.last));
    
    -- op� vyp�te obsah pola 
    for i in 1..pole.count
    loop
         dbms_output.put_line(pole(i));
    end loop;
    
    -- vyma�te prvok 3 a 4
    pole.delete(3,4); -- alebo jeden po druhom
    
    -- op� vyp�te obsah pola pomocou nasledovn�ch cyklov 
    
    -- d� to chybu, no data found 
    for i in 1..pole.count
    loop
        dbms_output.put_line(pole(i));
    end loop;
    
    -- d� to chybu, no data found 
    for i in pole.first..pole.last 
    loop
        dbms_output.put_line(pole(i));
    end loop;
    
    -- vyp�e iba prv� dva prvky 
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
 dbms_output.put_line('pole.count: ' || pole.count); -- po�et prvkov 5
 dbms_output.put_line('pole.last: ' || pole.last); -- index posledn�ho prvku 5
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
    count > last --> ak zma�em prvok KTORY NIE JE NA INDEXE POLE.LAST
    count < last --> nikdy 
    
    DELETE
    pole.delete(3); --> zma�e prvok na indexe 3
    pole.delete(2, 3); --> zma�e prvok na indexe 2 a 3
    pole.delete(3, 2); --> �iadny prvok nebude zmazan�, ale nenastane chyba
                        prv� prvok mus� by� men�� rovn� druh�mu
    pole.delete(2, 2);  --> zma�e sa prvok dva, nenastane chyba  
    pole.delete --> vyma�e v�etko 
    
*/

declare
 type t_pole is table of integer;
 pole t_pole:=t_pole(10,20,30,40,50);
begin
 pole.extend(1);
 pole(pole.last):=60; -- prirad�m hodnotu 60 posledn�mu prvku (50)
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
 dbms_output.put_line(pole.count); -- 6, posledn� prvok je NULL	
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



























