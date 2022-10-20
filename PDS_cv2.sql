/*
1.  Vytvorte funkciu Get_pocet_opakovani, ktorej vstupn�m parametrom bude 
osobn� ��slo �tudenta, v�sledkom bude po�et predmetov, 
ktor� opakoval (pou�ite pr�kaz Select...into).
*/
set SERVEROUTPUT on;
-- retardovan� pr�stup 
create or replace function get_pocet_opakovani(os student.os_cislo%type)
return integer
is
cursor cur is (select 
                    count(*) as pocet, 
                    cis_predm 
                from zap_predmety 
                where os_cislo = os
                group by cis_predm
                having count(*) > 1);
pocet integer;
cis zap_predmety.cis_predm%type;
po integer:=0;
begin
    open cur;
    loop 
        fetch cur into pocet, cis;
        exit when cur%notfound;
        po:=po+1;
    end loop;
    --dbms_output.put_line(po);
    close cur;
    return po;
end;
/
-- neretardovan� pr�stup 
create or replace function get_pocet_opakovani2(os student.os_cislo%type)
return
    integer
is
    cursor cur is (select count(*) from 
                    (select
                        count(*)
                    from zap_predmety 
                    where os_cislo = os
                    group by cis_predm
                    having count(*) > 1));
t_pocet integer;
begin
    open cur;
    fetch cur into t_pocet;
    return t_pocet;
    close cur;
end;
/
-- a. Otestujte pomocou vykonania funkcie pr�kazom EXECUTE a pomocou pr�kazu Select.
select get_pocet_opakovani(500426) pocet from dual;
select get_pocet_opakovani2(500426) pocet from dual;

variable i number
exec :i:=Get_pocet_opakovani(500426)
print i
;

/* 
2 vytvorte anonymny blk, ktoreho parametrom bude ��slo predmetu (vy�iadajte 
v r�mci tela od pou��vate�a) na konzolu vyp�te n�zov predmetu
pou�ite pr�kaz select ... into
*/

-- otestova� na predmetoch BI06 a BI08
declare
cursor cur is (select nazov from predmet where cis_predm = 'BI08');
t_nazov predmet.nazov%type;

no_data EXCEPTION;
pragma exception_init(no_data, -20000);
begin
    open cur;
    fetch cur into t_nazov;
    if cur%notfound then
        RAISE_APPLICATION_ERROR(-20000, 'Nastala vlastn� v�nimka.');
    end if;
    dbms_output.put_line(t_nazov);
    close cur;
    
    EXCEPTION
        when no_data then dbms_output.put_line('Predmet s t�mto ��slo neexistuje!!!');
end;
/

select * from predmet order by cis_predm;
select nazov from predmet where cis_predm = 'BI08';

/*
-- 3 vytvorte funkciu, ktorej vstupn� paremetrom bude rodn� ��slo �tudenta,
v�sledkom je celkov� po�et predmetov, ktor� �spe�ne absolvoval. 
Pou�ite pr�kaz select...into
*/

-- otestujte pre rod_��slo 860907/1259, 840312/7845, 841106/3456

create or replace function get_pocet_predmetov(rc student.rod_cislo%type)
return INTEGER
as
cursor cur is (select count(vysledok) from student
                join zap_predmety using(os_cislo)
                 where vysledok is not null 
                  and vysledok <> 'F'
                   and rod_cislo = rc);
pocet integer;

no_data EXCEPTION;
pragma exception_init(no_data, -20000);
begin
    open cur;
    fetch cur into pocet;

    if cur%notfound then
        RAISE_APPLICATION_ERROR(-20000, 'Nastala vlastn� v�nimka.');
    end if;
    return pocet;
    close cur;
    
    
    EXCEPTION
        when no_data then dbms_output.put_line('�tudent s t�mto rod ��slo neexistuje!!!');
end;
/

select get_pocet_predmetov('860907/1234') pocet from dual;

/*
4 vytvorte proced�ru, ktor� na konzolu vyp�e ku ka�d�mu �tudentovi 
jeho �tudijni priemer
*/
-- a) pou�ite bulk collect
declare
type t_record is record( 
    meno varchar2(20),
    priezvisko varchar2(20),
    os_cislo integer,
    priemer number
);
type t_pole is table of t_record;
pole t_pole;
begin
     select 
        o.meno,
        o.priezvisko,
        s.os_cislo,
        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2)
    bulk collect into pole 
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo
    order by o.meno;
    
    for i in pole.first..pole.last 
    loop
        dbms_output.put_line(pole(i).meno || ' ' ||
                             pole(i).priezvisko || ' ' ||
                             pole(i).os_cislo || ' ' ||
                             pole(i).priemer);
    end loop;
end;
/
-- a) pou�ite bulk collect spolu s kurzorom
declare
type t_record is record( 
    meno varchar2(20),
    priezvisko varchar2(20),
    os_cislo integer,
    priemer number
);
type t_pole is table of t_record;
pole t_pole;

cursor cur is (select 
        o.meno,
        o.priezvisko,
        s.os_cislo,
        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2)
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
    order by o.meno;
begin
    open cur;
    fetch cur bulk collect into pole limit 10;
    close cur;
    
    for i in pole.first..pole.last 
    loop
        dbms_output.put_line(pole(i).meno || ' ' ||
                             pole(i).priezvisko || ' ' ||
                             pole(i).os_cislo || ' ' ||
                             pole(i).priemer);
    end loop;
end;
/


-- pou�ite kurzor open, loop
declare
    cursor cur is (select 
        o.meno,
        o.priezvisko,
        s.os_cislo,
        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2)
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
    order by o.meno;
    
t_meno os_udaje.meno%type;
t_priezvisko os_udaje.priezvisko%type;
t_os_cislo student.os_cislo%type;
t_priemer number;
begin
    open cur;
    loop
        fetch cur into t_meno, t_priezvisko, t_os_cislo, t_priemer;
        exit when cur%notfound;
        dbms_output.put_line(t_meno || ' ' ||
                             t_priezvisko || ' ' ||
                             t_os_cislo || ' ' ||
                             t_priemer);
    end loop;
    close cur;
end;
/

-- kurzor cez for 2kr�t 
declare
begin
    for rn in (select 
        o.meno meno,
        o.priezvisko priezvisko,
        s.os_cislo os_cislo,
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    order by o.meno)
    
    loop
            for rn1 in (select
                        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2) priemer
                    from zap_predmety z
                    where z.os_cislo = rn.os_cislo)
           loop 
                    dbms_output.put_line(rn.meno || ' ' ||
                                         rn.priezvisko || ' ' ||
                                         rn.os_cislo || ' ' ||
                                         rn1.priemer);
            end loop;
    end loop;
end;
/
-- 5.) upravi� predch�dzaj�cu proced�ru tak aby vyp�sala iba 10 najlep��ch
-- bez row_number

declare
cursor cur is (select 
        o.meno,
        o.priezvisko,
        s.os_cislo,
        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2) priemer
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
    order by priemer;
                
t_meno os_udaje.meno%type;
t_priezvisko os_udaje.priezvisko%type;
t_os_cislo student.os_cislo%type;
t_priemer number;
iter integer := 0;
begin
    open cur;
    loop
        fetch cur into t_meno, t_priezvisko, t_os_cislo, t_priemer;
        exit when cur%notfound;
        if iter = 10 then
            exit;
        end if;
        iter := iter + 1;
        dbms_output.put_line(iter || ': ' ||
                            t_meno || ' ' ||
                         t_priezvisko || ' ' ||
                         t_os_cislo || ' ' ||
                         t_priemer);
        
    end loop;
    close cur;
end;
/
-- 6.) upravi� predch�dzaj�cu proced�ru tak aby vyp�sala iba 10 najlep��ch
-- ak m� 11 rovnak� priemer ako 10, vyp�sa� aj jeho bez RANK
declare
cursor cur is (select 
        o.meno,
        o.priezvisko,
        s.os_cislo,
        round(avg(decode(z.vysledok, 'A', 1 ,'B', 1.5, 'C', 2, 'D', 2.5, 'E', 3, 'F',4, NULL, 4)),2) priemer
    from os_udaje o
    join student s on(s.rod_cislo = o.rod_cislo)
    join zap_predmety z on (s.os_cislo = z.os_cislo)
    group by o.meno, o.priezvisko, s.os_cislo)
    order by priemer;
                
t_meno os_udaje.meno%type;
t_priezvisko os_udaje.priezvisko%type;
t_os_cislo student.os_cislo%type;
t_priemer number;
t_priemer_o number := 10;
iter integer := 0;
begin
    open cur;
    loop
        fetch cur into t_meno, t_priezvisko, t_os_cislo, t_priemer;
        exit when cur%notfound;
        if iter >= 10 then
       -- dbms_output.put_line((t_priemer_o + 0.01));
            if t_priemer_o <> t_priemer then
                exit;
            end if;
        end if;
        iter := iter + 1;
        t_priemer_o := t_priemer;
        dbms_output.put_line(iter || ': ' ||
                            t_meno || ' ' ||
                         t_priezvisko || ' ' ||
                         t_os_cislo || ' ' ||
                         t_priemer);
        
    end loop;
    close cur;
end;
/
select
    count(*)
from(
select 
        count(*) as pocet, 
        cis_predm 
    from zap_predmety 
    where os_cislo = '501555'
    group by cis_predm
    having count(*) > 1);
select * from student;
