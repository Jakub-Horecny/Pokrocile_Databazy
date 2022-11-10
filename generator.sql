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


