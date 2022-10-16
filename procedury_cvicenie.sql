set SERVEROUTPUT on;

-- pre kaûd˝ mesiac minulÈho roky vypÌsaù poËet zamestnancov, ktorÌ boli prijatÌ/prepustenÌ
-- akoûe 2016 aby to nieËo vypÌsalo;
create or replace procedure vypis
is
cursor cur is (select 
                to_char(dat_od, 'YYYY') as rok,
                to_char(dat_od, 'MM') as mesiac,
                count(dat_od) od,
                count(dat_do) do
            from p_zamestnanec
            where extract(year from sysdate) - 6 = to_char(dat_od, 'YYYY')
            group by to_char(dat_od, 'YYYY'), to_char(dat_od, 'MM')) order by mesiac;
v_od integer;
v_do integer;
v_m char(2);
v_r char(4);
begin
    open cur;
    DBMS_OUTPUT.PUT_LINE('Rok' || ' ' || 'Mesiac' || ' ' || 'dat_od' || ' ' || 'dat_do');
    loop
        FETCH cur into v_r, v_m, v_od, v_do;
        exit when cur%notfound;
        DBMS_OUTPUT.PUT_LINE(v_r || '  |  ' || v_m || '    |   ' || v_od || '   |  ' || v_do);
    end loop;
    CLOSE cur;
end;
/

exec vypis;

-- procedura kde ako vstup ide os_cislo studenta a vystup je jeho meno a priezvisko
create or replace procedure student_info(os integer)
is
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
begin
    for stud in (select meno, priezvisko from os_udaje
                    join student using(rod_cislo)
                        where os_cislo = os)
    loop
        DBMS_OUTPUT.put_line(stud.meno || ' ' || stud.priezvisko);
    end loop;
end;
/

-- jeden kurzor vypÌöe zÌska_os ËÌsla, druh˝ vypÌöe meno,priezvisko
declare
cursor stud_cur(os integer) is (select meno, priezvisko from os_udaje
                                    join student using(rod_cislo)
                                        where os_cislo = os);
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
begin
    for zaznam in (select os_cislo o from student)
    loop
        open stud_cur(zaznam.o);
        loop
            fetch stud_cur into v_meno, v_priezvisko;
            exit when stud_cur%notfound;
            DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko);
        end loop;
        close stud_cur;
    end loop;
end;
/

-- pre kaûdÈho ötudenta vypÌöe meno, priezvisko, os_cislo a n·zvy vöetk˝ch predmetov
-- ktorÈ ötuduje 
-- jednim kurzorom zÌskam meno, priezvisko, os_cilo
-- druh˝m vypÌöem vöetky jeho zapÌsanÈ predmety 

create or replace procedure get_predmety
as
cursor cur_os is (select meno, priezvisko, os_cislo from os_udaje
                    join student using(rod_cislo));
v_meno os_udaje.meno%type;
v_priezvisko os_udaje.priezvisko%type;
v_os_cislo student.os_cislo%type;
cis_predm integer := 1;
begin
    open cur_os;
        loop
            fetch cur_os into v_meno, v_priezvisko, v_os_cislo;
            exit when cur_os%notfound;
            dbms_output.put_line(v_meno || ' ' || v_priezvisko || ' - ' || v_os_cislo);
            for predmety in (select distinct p.cis_predm cis, nazov n from zap_predmety z
                                join predmet p on( p.cis_predm = z.cis_predm)
                                    where z.os_cislo = v_os_cislo)
            loop
                dbms_output.put_line(cis_predm || '. ' || predmety.cis || ': ' || predmety.n);
                cis_predm:= cis_predm + 1;
            end loop;
            dbms_output.put_line(' ');
            cis_predm:=1;
        end loop;
    close cur_os;
end;
/

exec get_predmety;

exec student_info(501512);
select meno, priezvisko from os_udaje
                    join student using(rod_cislo)
                        where os_cislo = 501512;
                        
select distinct  
        z1.skrok as prvyrok, 
        z2.skrok as druhyrok 
        from zap_predmety z1, zap_predmety z2
        where 
                z1.skrok +1 =z2.skrok 
            and 
                z1.skrok between 2004 and 2005 
        order by z1.skrok;
        
select distinct 
    b.cis_predm as predmet, 
    nazov,
    meno, 
    priezvisko,
    z.skrok 
from zap_predmety z
    join predmet p on(p.cis_predm = z.cis_predm)
        join predmet_bod b on(b.cis_predm = p.cis_predm)
            join ucitel u on(u.os_cislo = b.garant)
 where z.skrok between 2004 and 2005 
 order by z.skrok, b.cis_predm

