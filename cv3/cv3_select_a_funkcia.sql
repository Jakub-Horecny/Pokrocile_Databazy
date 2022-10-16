-- 3.1
-- a.) vytvorte tabu�ku kontakty a pre dvoch �tudentov vlo�te do tabu�ky po jednom kontakte
create table kontakty(
    id number(38) NOT NULL PRIMARY KEY,
    os_cislo integer not null,
    popis varchar2(10) not null,
    kontakt varchar2(30) not null,
    FOREIGN KEY (os_cislo) REFERENCES student(os_cislo)
);

insert into kontakty values(1, 501512, 'popis 1', 'Karol MatriTHRASHko');
insert into kontakty values(2, 501469, 'popis 2', 'Kvetinka');
insert into kontakty values(3, 501414, 'popis 3', 'COOL Kvet');
select * from student;

-- b.) V sqlplus vyp�te zoznam �tudentov a ak maj� nejak� kontakt, 
--tak ich vyp�te aj s kontaktom
select 
    o.meno,
    o.priezvisko,
    s.os_cislo,
    k.popis,
    k.kontakt
from os_udaje o
join student s on (o.rod_cislo = s.rod_cislo)
left join kontakty k on (k.os_cislo = s.os_cislo)
order by k.kontakt;

-- c.) Vytvorte package Student_package a implementujte met�du Vypis tak, 
-- aby vyp�sala �tudentom aj ich kontakt, ak nejak� maj�.

-- definicia package
create or replace package student_package as
    procedure vypis;
end student_package;
/

-- body 
create or replace package body student_package 
as
    procedure vypis
    is
    begin
        for rn in (select 
                    o.meno m,
                    o.priezvisko p,
                    s.os_cislo os,
                    k.popis po,
                    k.kontakt ko
                from os_udaje o
                join student s on (o.rod_cislo = s.rod_cislo)
                left join kontakty k on (k.os_cislo = s.os_cislo)
                order by k.kontakt)
        loop
            dbms_output.put_line(rn.m || '      ' ||
                                    rn.p || '      ' ||
                                    rn.os || '      ' ||
                                    rn.po || '      ' ||
                                    rn.ko);
        end loop;
    end;
end;
/

-- volanie procedury 
exec student_package.vypis();

-- d.)
-- Aspo� jedn�mu �tudentovi vlo�te viac kontaktov a upravte proced�ru Vypis tak, 
-- aby vyp�sala �tudentom v�etky kontakty (ka�d� do nov�ho riadku, ale meno,
-- priezvisko �tudenta bude len raz

insert into kontakty values(4, 501512, '�a���', 'Norko Adamko');
insert into kontakty values(5, 501469, '�a���-', 'Jardo Jan��ek');
insert into kontakty values(6, 501469, 'one more', 'Vargos');

create or replace package student_package as
    procedure vypis;
end student_package;
/

-- body 
create or replace package body student_package 
as
    procedure vypis
    is
    begin
        for stud in (select
                        o.meno m,
                        o.priezvisko p,
                        s.os_cislo os
                    from os_udaje o
                    join student s on (o.rod_cislo = s.rod_cislo))
        loop
        
        dbms_output.put_line(stud.m || '   ' ||
                                stud.p || '    ' ||
                                stud.os);
        dbms_output.put_line('�tudentove kontakty: ');
            for kon in (select 
                            popis,
                            kontakt
                        from kontakty
                        where os_cislo = stud.os)
            loop
                
                dbms_output.put_line( kon.popis || '      ' ||
                                        kon.kontakt);
            end loop;
            dbms_output.put_line('');
        end loop;
    end;
end;
/

exec student_package.vypis();


-- 3.2 str�nkovanie selectov
-- a.) Do vytvoren�ho package dopl�te met�du na str�nkovanie zoznamu �tudentov, 
-- pri�om maxim�lny po�et �tudentov nech je 3.

create or replace package student_package as
    max_strankovanie integer := 3;
    stud_index integer := 1;
    --procedure vypis;
    procedure strankovanie;
    procedure reset_strankovanie;
    -- b.) Dopl�te met�du na z�skanie nasledovnej a predch�dzaj�cej str�nky
    procedure next_strankovanie;
    procedure previous_strankovanie;
end student_package;
/

create or replace package body student_package 
as
    PROCEDURE strankovanie 
    as
    begin
        for stud in (select
                        *
                    from (select
                        o.meno m,
                        o.priezvisko p,
                        s.os_cislo os,
                        row_number() over (order by s.os_cislo) rn
                    from os_udaje o
                    join student s on (o.rod_cislo = s.rod_cislo))
                    where rn between stud_index and 
                                (stud_index + max_strankovanie-1)
                    )
        loop
            dbms_output.put_line(stud.m || '   ' ||
                                    stud.p || '    ' ||
                                    stud.os);
            dbms_output.put_line('�tudentove kontakty: ');
            for kon in (select 
                            popis,
                            kontakt
                        from kontakty
                        where os_cislo = stud.os)
            loop
                dbms_output.put_line( kon.popis || '      ' ||
                                        kon.kontakt);
            end loop;
            dbms_output.put_line('');
        end loop;
        stud_index := stud_index + max_strankovanie;
    end;
    
    procedure reset_strankovanie
    as
    begin
        stud_index:=1;
    end;
    
    procedure next_strankovanie
    as
    begin
        for stud in (select
                        *
                    from (select
                        o.meno m,
                        o.priezvisko p,
                        s.os_cislo os,
                        row_number() over (order by s.os_cislo) rn
                    from os_udaje o
                    join student s on (o.rod_cislo = s.rod_cislo))
                    where rn = stud_index )
        loop
            dbms_output.put_line(stud.m || '   ' ||
                                    stud.p || '    ' ||
                                    stud.os);
            dbms_output.put_line('�tudentove kontakty: ');
            for kon in (select 
                            popis,
                            kontakt
                        from kontakty
                        where os_cislo = stud.os)
            loop
                dbms_output.put_line( kon.popis || '      ' ||
                                        kon.kontakt);
            end loop;
            dbms_output.put_line('');
        end loop;
        stud_index := stud_index + 1;
    end;
    
    procedure previous_strankovanie
    as
    begin
        stud_index := stud_index - 1;
        for stud in (select
                        *
                    from (select
                        o.meno m,
                        o.priezvisko p,
                        s.os_cislo os,
                        row_number() over (order by s.os_cislo) rn
                    from os_udaje o
                    join student s on (o.rod_cislo = s.rod_cislo))
                    where rn = stud_index )
        loop
            dbms_output.put_line(stud.m || '   ' ||
                                    stud.p || '    ' ||
                                    stud.os);
            dbms_output.put_line('�tudentove kontakty: ');
            for kon in (select 
                            popis,
                            kontakt
                        from kontakty
                        where os_cislo = stud.os)
            loop
                dbms_output.put_line( kon.popis || '      ' ||
                                        kon.kontakt);
            end loop;
            dbms_output.put_line('');
        end loop;
        
    end;

end student_package;    
/

 -- indexi nie s� dobre spraven� 
exec student_package.strankovanie();
exec student_package.reset_strankovanie();
exec student_package.next_strankovanie();
exec student_package.previous_strankovanie();