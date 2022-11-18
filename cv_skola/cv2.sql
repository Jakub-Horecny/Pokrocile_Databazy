/*
Generovanie pr�kazov
analytika 

�o je cie� - pomocou pr�kazu select vygenerova� pr�kaz, ktor� je mo�n� spusti�
v�stup pr�kazu select, ktor� sa d� pou�i� na dal�ie spracovanie 

pr�ca s pristupov�mi pr�vami - potrebn� pri generovan� - ak chcem da� niekomu pr�stupov� pr�va
dve kategorie 
grant
revoke
ukon�uj� tanzakcie

syst�mov� - admin option - proced�ri, funkcie...
objektov� - grand option - cascade ak dostanem pr�va a d�m to niekomu in�mu a pr�dem o pr�vo pr�du on v�etci 

ako na to 
grant select on NAZOV_TABULKY to MENO POUZIVATELA
*/

grant select on student to mazuch2;
grant select on student to varhanikova;

se�ect table_name from tabs;

select 'grant select on ' || table_name || ' to bikesharing with grant option' from tabs;

select * from student;

begin
 for riadok in (select 'grant select on ' || 
                            table_name || 
                            ' to varhanikova with grant option' 
                            as prikaz
                            from tabs) 
 
 loop
    execute immediate riadok.prikaz;
 end loop;
end;
/

-- najsk�r je dobr� zobrazi� si v�stup, a� potom to sp��ta� 

-- ========= delegovanie pr�v =============

select table_name from all_tables where owner = 'MAZUCH2';

-- d� sa to spusti� iba raz, potom to d�va error
begin
 for riadok in (select 'revoke select on ' || 
                            table_name || 
                            ' from mazuch2' 
                            as prikaz
                            from tabs) 
 
 loop
    execute immediate riadok.prikaz;
 end loop;
end;
/

-- ====== ANALYTIKA ========
/*
ako zoradi� mno�inu d�t - iba pre potreby spracovania poradov�ho ��sla
ROW_NUMBER() over;
t�to funkciu m��em vola� iba v SELECT !!!

select obal�m do in�ho selektu a t�m d�m where poradie je menej ako tri 

RANK - analytick� funkcia
rovnak� v�sledky dostan� rovnkak� hodnotu RANK ale ignoruje sa a ide sa dalej

DENSE_RANK
funguje podobne ako rank ale ni� sa nevynech�va 
m��e vr�ti� viac riadkov 

PARTITION BY


EMPLOYEE 

analytick� funkcie maj� jedn� �pecia�lnu vlasntos�
situ�cie - chcem �tudneta s najlep��m priemerom pohoda
pre ka�d� ro�n�k... to sprav�m iba cez analytiku 

vyp�a� najlep�ieho �tudenta v ka�dom ro�n�ku 

nth_value(stlpec,poradie) over (
funguje ako row number 

-- ======== NEDEFINOVANE HODNOTY =========
            NULL a ANALYTIKA

RANK - daj� sa porovna� NULL hodnoty - poviem �i ich chcem prv� alebo posledn�
    - NULL hodnoty dostan� rovnak� hodnotu RANK !!!
    

V jeden den rob�m jednu aktivitu
viac dn� m��em robi� jednu aktivitu 
chcem vedie� kedy som za�al a kedy som skon�il
aktivita nemus� by� spojit� v jeden den za�nem a skon��m, v in� pokra�ujem a dokon��m 
Pr�ca s �asom 
�o keby som si ich zoradil v �ase?
PARTITION_BY - aby som to delil pre ka�d� aktivitu osobne 
�� ak od �dtumu odpo��tam poradov� ��slo 
ak ako roddiel d�tumu vr�ti rovnak� hodnotu, znamen� to �e je spojit� 
ak to sko�� na da��iu hodnotu, nie je 


======== TEMPERATURE MONITORING =========

v hodinov�ch intervaloch m�m teplotu 
chcem vedie� ako sa teplota vyv�ja oproti tej predch�dzaj�cej 
Bez analytickej funkcie je to ve�mi �a�k�
�lo by to cez ROW-MUMBER - rodat�m ich v �ase a spoj�m 2 raidok z 3, 3 zo 4 ...
2 selecty a cez JOIN ich via�em cez ROW-NUMBER ale posunut� od jedno 

GET_PRIEVIous row 

ak z�znam neexistuje dostanem nULL
je lep�ie to spravi� cez CASE 

vystup cez 3 kurzory 


exists funfuje v�dy - IN nebude fungova� ke� o vr�ti null hodnotu
            
            
            
            
*/


