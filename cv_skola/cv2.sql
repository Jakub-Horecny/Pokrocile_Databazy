/*
Generovanie príkazov
analytika 

èo je cie¾ - pomocou príkazu select vygenerova príkaz, ktorí je moné spusti
vıstup príkazu select, ktorı sa dá poui na dalšie spracovanie 

práca s pristupovími právami - potrebné pri generovaní - ak chcem da niekomu prístupové práva
dve kategorie 
grant
revoke
ukonèujú tanzakcie

systémové - admin option - procedúri, funkcie...
objektové - grand option - cascade ak dostanem práva a dám to niekomu inému a prídem o právo prídu on všetci 

ako na to 
grant select on NAZOV_TABULKY to MENO POUZIVATELA
*/

grant select on student to mazuch2;
grant select on student to varhanikova;

seôect table_name from tabs;

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

-- najskôr je dobré zobrazi si vıstup, a potom to spúšta 

-- ========= delegovanie práv =============

select table_name from all_tables where owner = 'MAZUCH2';

-- dá sa to spusti iba raz, potom to dáva error
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
ako zoradi mnoinu dát - iba pre potreby spracovania poradového èísla
ROW_NUMBER() over;
túto funkciu môem vola iba v SELECT !!!

select obalím do iného selektu a tám dám where poradie je menej ako tri 

RANK - analytická funkcia
rovnaké vısledky dostanú rovnkakú hodnotu RANK ale ignoruje sa a ide sa dalej

DENSE_RANK
funguje podobne ako rank ale niè sa nevynecháva 
môe vráti viac riadkov 

PARTITION BY


EMPLOYEE 

analytické funkcie majú jednú špeciaálnu vlasntos
situácie - chcem študneta s najlepším priemerom pohoda
pre kadı roèník... to spravím iba cez analytiku 

vypíša najlepšieho študenta v kadom roèníku 

nth_value(stlpec,poradie) over (
funguje ako row number 

-- ======== NEDEFINOVANE HODNOTY =========
            NULL a ANALYTIKA

RANK - dajú sa porovna NULL hodnoty - poviem èi ich chcem prvé alebo posledné
    - NULL hodnoty dostanú rovnakú hodnotu RANK !!!
    

V jeden den robím jednu aktivitu
viac dní môem robi jednu aktivitu 
chcem vedie kedy som zaèal a kedy som skonèil
aktivita nemusí by spojitá v jeden den zaènem a skonèím, v inı pokraèujem a dokonèím 
Práca s èasom 
èo keby som si ich zoradil v èase?
PARTITION_BY - aby som to delil pre kadú aktivitu osobne 
èé ak od ádtumu odpoèítam poradové èíslo 
ak ako roddiel dátumu vráti rovnakú hodnotu, znamená to e je spojitá 
ak to skoèí na da¾šiu hodnotu, nie je 


======== TEMPERATURE MONITORING =========

v hodinovıch intervaloch mám teplotu 
chcem vedie ako sa teplota vyvíja oproti tej predchádzajúcej 
Bez analytickej funkcie je to ve¾mi aké
šlo by to cez ROW-MUMBER - rodatím ich v èase a spojím 2 raidok z 3, 3 zo 4 ...
2 selecty a cez JOIN ich viaem cez ROW-NUMBER ale posunuté od jedno 

GET_PRIEVIous row 

ak záznam neexistuje dostanem nULL
je lepšie to spravi cez CASE 

vystup cez 3 kurzory 


exists funfuje vdy - IN nebude fungova keï o vráti null hodnotu
            
            
            
            
*/


