spool C:\Users\Jakub\Desktop\ulica.txt;
select distinct priezvisko from priklad_db2.student
join priklad_db2.os_udaje using(rod_cislo)
where ulica is not null;
spool off;


select distinct obec from priklad_db2.student
join priklad_db2.os_udaje using(rod_cislo)
where obec is not null
having length(obec) > 5
group by obec;

select * from priklad_db2.os_udaje;


select * from os_udaje;
select to_date(substr(rod_cislo,1,2) || '.' || mod(substr(rod_cislo,3,2),50) ||.||
        substr(rod_cislo,5,2), 'YYYY.MM.DD') from os_udaje;
        
select 
rod_cislo, 
(to_date(sysdate, 'DD.MM.YYYY') - to_date(substr(rod_cislo,5,2) || '.' ||
mod(substr(rod_cislo , 3,2),50) || '.' ||
substr(rod_cislo,1,2), 'DD.MM.YYYY')) datum
from os_udaje;
-- months_between(SYSDATE,DOB)
select to_date(sysdate, 'DD.MM.YYYY') from dual;


select 
rod_cislo, 
months_between(SYSDATE,
to_date(substr(rod_cislo,5,2) || '.' ||
mod(substr(rod_cislo , 3,2),50) || '.' ||
substr(rod_cislo,1,2), 'DD.MM.YYYY')) datum
from os_udaje;

select
    rc,
    floor(months_between(sysdate, datum)/12)
from (
    select
        rod_cislo rc,
        to_date(substr(rod_cislo,5,2) || '-' ||
        mod(substr(rod_cislo , 3,2),50) || '-' || 19 ||
        substr(rod_cislo,1,2), 'DD-MM-YYYY') datum
    from os_udaje
);

select
        rod_cislo rc,
        to_date(substr(rod_cislo,5,2) || '-' ||
        mod(substr(rod_cislo , 3,2),50) || '-' || 19 ||
        substr(rod_cislo,1,2), 'DD-MM-YYYY') datum
    from os_udaje;

select floor(months_between(sysdate, date '2011-10-10')) from dual;