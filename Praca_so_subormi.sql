set serveroutput on;

/*
potrebujem oracle directory ako objekt, a potom smernÌk - je priamo v datab·ze 
pri kopÌrovnÌ na cezar staËÌ daù ignorovaù chybu 
*/

-- create or replace directory horecny4 as [local path]

-- ide iba na obelix serveri
select json_web_service_geo from dual; -- defaultne d· d·ta pre SK
select json_web_service_geo('AL') from dual;

-- univerz·lne ireöenie aj na staröÌch verzi·ch ORACLE
Create table states_json(
    code char(2), 
    doc CLOB, 
    constraint state_json_cons CHECK (doc is json)
);
             
-- d·tov˝ typ JSON v novej verzii 
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

select * from states_json;

update states_json set doc=(select json_web_service_geo from dual)
where code = 'SK';


-- ==================== PRAKTICKE CVICENIE ======================

Create table books_json(
    doc CLOB, 
    constraint books_json_cons CHECK (doc is json)
);

drop table books_json;
-- tomo mi s nejakÈho dÙvodu nejde ani na asterix 
Create table books_json(
    doc json
);

insert into books_json (doc)
values (
    '{	
    "Title": "Tempor·lne datab·zy", 			
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

insert into books_json (doc)
values (
    '{	
    "Title": "PokroËilÈ datab·zy", 			
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
-- ned· to niË, lebo JSON je key sensitive 
select b.doc.title from books_json b;

-- vyjadruje ûe konvertujem JSON dokument do textovej podoby 
select json_serialize(b.doc) from books_json b;


-- teraz neviem povedaù Ëi tam nem·m takÈho autora, alebo tak˝to element neexistuje 
select 
    b.doc.Author 
from books_json b
where b.doc.Author like '%Matiasko%';

-- v bin·rnej forme mi vr·ti Ëi ten element existuje 
select 
    b.doc.Author 
from books_json b
-- $ vyjadruje korenov˝ element, a potom prech·dzam dokument  
where json_exists(b.doc, '$.Detail.Pages'); -- existuje, vypÌöe b.doc.Author

select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail.Status'); -- neexistuje, niË nevypÌöe 


-- ak to porovn·vam na rovnosù, musia tam byù dve rovn· sa 
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$?(@.Title=="PokroËilÈ datab·zy")');


-- pracujem s parametrom ROK
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK)' 
                    passing 2020 as "ROK")
        or
            json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK)' 
                    passing 2019 as "ROK");

-- zloûitejöia podmienka aj takto             
select 
    b.doc.Author 
from books_json b
where json_exists(b.doc, '$.Detail?(@.Publication_year==$ROK || @.Language==$LAN)' 
                    passing 2020 as "ROK", 'Slovak' as "LAN");

                    

insert into books_json (doc)
values (
    '{	
    "Title": "Datab·zovÈ systÈmy", 			
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

-- kaûd˝ element v poly je JSON dokument

select 
    b.doc.Title
from books_json b
where json_exists(b.doc, '$.Author?(@.email like "%fri.uniza.sk%")');

-- json_value variant prÌstupu cez bodku 
select 
    json_value(b.doc, '$.Title') Title
from books_json b;

-- =============== PRACA S BOOLEAN ============

delete books_json;

insert into books_json (doc)
values (
    '{	
    "Title": "Datab·zovÈ systÈmy", 			
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


-- neporovn·vam to ako BOOLEAN, ale ako string reùazec 
select 
    b.doc.Title
from books_json b
where b.doc.Detail.In_stock='false';

-- json value, cez returning number sa d· vyjadriù prÌstup k boolean hodnote ako k ËÌslu
select 
    b.doc.Title
from books_json b
where json_value(b.doc, '$.Detail.In_stock' returning number)=0;


-- vytvorenie JSON dokumentu cez select 
-- json_table - konötruktor, ktor˝ sa poûÌva napr. pri kolekci·ch (princÌp je rovnak˝)
-- tieto relaËnÈ atrib˙ty nie s˙ key sensitive, pretoûe nie sme v JSON ötrukt˙re 

select jt.nazov_knihy, jt.kategoria
from books_json b, 
     json_table(b.doc, '$'
        columns(Nazov_knihy varchar2(50) path Title, 
                Kategoria varchar2(30) path Type)) jt;


