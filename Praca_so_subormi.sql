set serveroutput on;

/*
potrebujem oracle directory ako objekt, a potom smern�k - je priamo v datab�ze 
pri kop�rovn� na cezar sta�� da� ignorova� chybu 
*/

-- create or replace directory horecny4 as [local path]

-- ide iba na obelix serveri
select json_web_service_geo from dual; -- defaultne d� d�ta pre SK
select json_web_service_geo('AL') from dual;

-- univerz�lne ire�enie aj na star��ch verzi�ch ORACLE
Create table states_json(
    code char(2), 
    doc CLOB, 
    constraint state_json_cons CHECK (doc is json)
);
             
-- d�tov� typ JSON v novej verzii 
create table states_json(
    code char(2),
    doc json
);
/
desc states_json;
drop table states_json;

insert into states_json(code,doc) values('SK',(select json_web_service_geo from dual));
insert into states_json(code, doc) values('AT', (select json_web_service_geo('AT') from dual));
insert into states_json(code, doc) values('AL', (select json_web_service_geo('AL') from dual));
insert into states_json(code, doc) values('DZ', (select json_web_service_geo('DZ') from dual));
insert into states_json(code, doc) values('AI', (select json_web_service_geo('AI') from dual));
insert into states_json(code, doc) values('BD', (select json_web_service_geo('BD') from dual));

select * from states_json;

update states_json set doc=(select json_web_service_geo from dual)
where code = 'SK';

delete states_json where code = 'DZ';

select 
    s.code code,
    s.doc.geonames.continent continent,
    s.doc.geonames.capital capital,
    s.doc.geonames.languages languages,
    s.doc.geonames.countryName countryName
from states_json s;

/*
'{	
    "Title": "Datab�zov� syst�my", 			
    "Author": [{"Name":"Karol Matiasko", "email": "karol.matiasko@fri.uniza.sk"}, 
                       {"Name":"Michal Kvet", "email": "michal.kvet@fri.uniza.sk"},
                      {"Name":"Marek Kvet", "email": "marek.kvet@fri.uniza.sk"}
                    ],
    "Type": "studying literature",
        "Detail": 
        { 
          	"Publisher": "EDIS", 	
            "Publication_year": 2018, 	
           	"ISBN": "978-80-554-14881", 
           	"Language": "Slovak", 
            "Pages": null,
            "Price": 21.20,
            "In_stock": false
        } 
					
    }'
*/

/*
{"geonames": 
    [{
      "continent": "EU",
      "capital": "Bratislava",
      "languages": "sk,hu",
      "geonameId": 3057568,
      "south": 47.7313590000001,
      "isoAlpha3": "SVK",
      "north": 49.6137360000001,
      "fipsCode": "LO",
      "population": "5447011",
      "east": 22.5657383340001,
      "isoNumeric": "703",
      "areaInSqKm": "48845.0",
      "countryCode": "SK",
      "west": 16.8334234020001,
      "countryName": "Slovakia",
      "postalCodeFormat": "### ##",
      "continentName": "Europe",
      "currencyCode": "EUR"
    }]
}
*/
-- z nejak�ho d�vodu to nejde 


select
    jt.m 
from states_json s,
json_table(s.doc, '$' columns(m varchar2(50) path geonames.north)) jt;


-- mus�m sa najsk�r odkazova� na premenn� v tabu�ke 
select s.doc.geonames.languages from states_json s;

select * from (
    select 
        s.doc.geonames.languages languages, 
        rank() over (order by s.doc.geonames.languages) rn  
    from states_json s)
where rn > 0;

-- takto sprav�m substr pre languages
select distinct 
    regexp_substr(s.doc.geonames.languages,'[^,]+', 1, level) languages
from states_json s
connect by regexp_substr(s.doc.geonames.languages, '[^,]+', 1, level) is not null;



-- ==================== PRAKTICKE CVICENIE ======================

Create table books_json(
    doc CLOB, 
    constraint books_json_cons CHECK (doc is json)
);

drop table books_json;
-- tomo mi s nejak�ho d�vodu nejde ani na asterix 
Create table books_json(
    doc json
);

insert into books_json (doc)
values (
    '{	
    "Title": "Tempor�lne datab�zy", 			
    "Author": ["Michal Kvet", "Karol Matiasko"], 
    "Type": "Monography", 
    "Detail": 
        { 
          	"Publisher": "EDIS", 	
            "Publication_year": 2020, 	
           	"ISBN": "978-80-554-1662-5", 
           	"Language": "Slovak", 
            "Pages": 320,
            "Price": 21
        } 					
    }'
);

select b.doc.Author from books_json b;

insert into books_json (doc)
values (
    '{	
    "Title": "Pokro�il� datab�zy", 			
    "Author": "Michal Kvet", 
    "Type": "studying literature", 
    "Detail": 
        { 
          	"Publisher": "APEX", 	
            "Publication_year": 2019, 	
           	"ISBN": "123-89-445-2551-9", 
           	"Language": "Slovak", 
            "Pages": 500,
            "Price": 0
        } 					
    }'
);

select * from books_json;
select b.doc from books_json b;
select b.doc.Title from books_json b;
-- ned� to ni�, lebo JSON je key sensitive 
select b.doc.title from books_json b;

-- vyjadruje �e konvertujem JSON dokument do textovej podoby 
select json_serialize(b.doc) from books_json b;


-- teraz neviem poveda� �i tam nem�m tak�ho autora, alebo tak�to element neexistuje 
select 
    b.doc.Author[0] 
from books_json b
where b.doc.Author like '%Matiasko%';


select
     b.doc.Author 
from books_json b
where json_exists(b.doc, '$?(@.Author=="Karol Matiasko")');

-- v bin�rnej forme mi vr�ti �i ten element existuje 
select 
    b.doc.Author 
from books_json b
-- $ vyjadruje korenov� element, a potom prech�dzam dokument  
where json_exists(b.doc, '$.Detail.Pages'); -- existuje, vyp�e b.doc.Author

select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail.Status'); -- neexistuje, ni� nevyp�e 


-- ak to porovn�vam na rovnos�, musia tam by� dve rovn� sa 
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$?(@.Title=="Pokro�il� datab�zy")');


-- pracujem s parametrom ROK
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK)' 
                    passing 2020 as "ROK")
        or
            json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK)' 
                    passing 2019 as "ROK");

-- zlo�itej�ia podmienka aj takto             
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK || @.Language==$LAN)' 
                    passing 2020 as "ROK", 'Slovak' as "LAN");

                    

insert into books_json (doc)
values (
    '{	
    "Title": "Datab�zov� syst�my", 			
    "Author": [{"Name":"Karol Matiasko", "email": "karol.matiasko@fri.uniza.sk"}, 
                       {"Name":"Michal Kvet", "email": "michal.kvet@fri.uniza.sk"},
                      {"Name":"Marek Kvet", "email": "marek.kvet@fri.uniza.sk"}
                    ],
    "Type": "studying literature",
        "Detail": 
        { 
          	"Publisher": "EDIS", 	
             	"Publication_year": 2018, 	
           	"ISBN": "978-80-554-14881", 
           	"Language": "Slovak", 
             	"Pages": null,
             	"Price": 21.20
        } 
					
    }'
);

-- ka�d� element v poly je JSON dokument

select 
    b.doc.Title
from books_json b
where json_exists(b.doc, '$.Author?(@.email like "%fri.uniza.sk%")');

-- json_value variant pr�stupu cez bodku 
select 
    json_value(b.doc, '$.Title') Title
from books_json b;

-- =============== PRACA S BOOLEAN ============

delete books_json;

insert into books_json (doc)
values (
    '{	
    "Title": "Datab�zov� syst�my", 			
    "Author": [{"Name":"Karol Matiasko", "email": "karol.matiasko@fri.uniza.sk"}, 
                       {"Name":"Michal Kvet", "email": "michal.kvet@fri.uniza.sk"},
                      {"Name":"Marek Kvet", "email": "marek.kvet@fri.uniza.sk"}
                    ],
    "Type": "studying literature",
        "Detail": 
        { 
          	"Publisher": "EDIS", 	
            "Publication_year": 2018, 	
           	"ISBN": "978-80-554-14881", 
           	"Language": "Slovak", 
            "Pages": null,
            "Price": 21.20,
            "In_stock": false
        } 
					
    }'
);


-- neporovn�vam to ako BOOLEAN, ale ako string re�azec 
select 
    b.doc.Title
from books_json b
where b.doc.Detail.In_stock='false';

-- json value, cez returning number sa d� vyjadri� pr�stup k boolean hodnote ako k ��slu
select 
    b.doc.Title
from books_json b
where json_value(b.doc, '$.Detail.In_stock' returning number)=0;


-- select s JSON dokumentu  
-- json_table - kon�truktor, ktor� sa po��va napr. pri kolekci�ch (princ�p je rovnak�)
-- tieto rela�n� atrib�ty nie s� key sensitive, preto�e nie sme v JSON �trukt�re 

select jt.nazov_knihy, jt.kategoria
from books_json b, 
     json_table(b.doc, '$'
        columns(Nazov_knihy varchar2(50) path Title, 
                Kategoria varchar2(30) path Type)) jt;
                

-- vydavatel je premen�, do ktorej sa ulo�� hodnota s JOSN dokumentu 
select 
    jt.vydavatel
from books_json b,
json_table(b.doc, '$' columns(vydavatel varchar2(50) path Detail.Publisher)) jt;


select 
    jt.prvy_autor
from books_json b,
json_table(b.doc, '$' 
                    columns(prvy_autor varchar2(50) path Author[0])) jt;


-- prvy_autor vyp�en null, aj ke�d som to skop�roval s jeho prezent�cie \_(o,o)_/
select 
    jt.nazov_knihy, 
    prvy_autor
from books_json b, 
 json_table(b.doc, '$'
      columns(Nazov_knihy varchar2(50) path Title, 
              Prvy_autor varchar2(50) path Author[1])) jt;
   
   
-- ================= vytvorenie JSON objektu cez SELECK =================          


-- kde nedo�lo k spojeniu je NULL
select json_object(meno, priezvisko, os_cislo)
from os_udaje 
left join student using(rod_cislo);


-- ABSENT ON NULL, ak je os_cislo NULL atrib�t tam nebude 
select json_object(meno, priezvisko, os_cislo ABSENT ON NULL)
from os_udaje 
left join student using(rod_cislo);


-- vytvorenie vlastn�ch atrib�tov pre JSON s�bor 
select json_object('full_name' value meno || ' ' || priezvisko,
                    'student_id' value os_cislo,
                    'student_info' value json_object('class' value rocnik,
                                                     'st_group' value st_skupina))
from os_udaje join student using(rod_cislo);


-- pou�itie agrega�nej funkcie MIN MAX
select json_object('name' value meno || ' ' || priezvisko, 
                   'student_id' value os_cislo, 
                   'student_info' value 
                         json_object('class' value rocnik, 
                                     'st_group' value st_skupina), 
                   'reg_subjects' value 
                        json_array(min(vysledok), max(vysledok)))
from os_udaje 
join student using(rod_cislo)
join zap_predmety using(os_cislo)
group by meno, priezvisko, os_cislo, rocnik, st_skupina; 


-- z tohto nevznikne pole 
select
    os_cislo,
    json_objectagg('predmet' value cis_predm || '-' || vysledok)
from zap_predmety
group by os_cislo;

-- indexova� sa daj� aj JSON dokumenty, nem��em indexova� cel� dokument, ale iba konkr�tny element
-- d� sa to indexova� aj pre JSON pole 

