/*
index - nemusím prechádza kadı záznam, ale pozriem sa do indexu, vidím k¾úèové slovo

indexovanie v databáz - mám jeden ståpec alebo mnoinu ståpcov alebo vısledok funkcie 
a túto hodnotu indexuje - mám tam informáciu kde sa nachádza konkrétny záznam - adresa

B+ strom - štandartná štukrtúra v DS

indexova sa dajú aj JSON dokumenty - je to znakovı large object
*/ 

select * from books_json;

-- nemôem indexova celı JSON dokument 
create index ind_json on books_json(doc);

-- musím indexova konkrétny element
--                                          -- doc je ståpec v tabu¾ke
create index ind_json on books_json(JSON_value(doc, '$.Title'));
drop index ind_json;
-- môem indexova aj viacero atribútov, ale je tam obmedzená dåka klúèa
create index ind_json2 
on books_json(JSON_value(doc, '$.Type'), JSON_value(doc,'$.Detail.Publication_year'));


-- mám tu viac autorov - JOSN POLE
select b.doc.Author
from books_json b;

-- aj keï to je JSON pole dokáem to indexova
--
create index ind_json2 on books_json(JSON_value(doc, '$.Author'));

select b.doc.Detail
from books_json b;

-- parametrom indexu bude celı JSON dokument, ale musí tam by konštruktor JSON_value 
create index ind_json5 on books_json(JSON_value(doc, '$'));


-- explicitné indexi - pouívate¾sky definované 



/*
HASH INDEX
    snaí sa rovnomerne distribuova indexi do bucket 
    je to hash funkcia, ktorá zabezpeèí vyuitie len toho rozsahu backeto ktoré mám k dispozícií
    cie¾ je èo najrovnomernejšie rozloenie dát - nie je to jednoduché ak sa štruktúra dát mení
    je to dôvod preèo tento index prestal by pouívanı 
    v prípade ve¾kıch zime je potrebné prerobi HASH fuknciu
    
*/