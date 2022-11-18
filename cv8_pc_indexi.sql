/*
index - nemus�m prech�dza� ka�d� z�znam, ale pozriem sa do indexu, vid�m k���ov� slovo

indexovanie v datab�z - m�m jeden st�pec alebo mno�inu st�pcov alebo v�sledok funkcie 
a t�to hodnotu indexuje - m�m tam inform�ciu kde sa nach�dza konkr�tny z�znam - adresa

B+ strom - �tandartn� �tukrt�ra v DS

indexova� sa daj� aj JSON dokumenty - je to znakov� large object
*/ 

select * from books_json;

-- nem��em indexova� cel� JSON dokument 
create index ind_json on books_json(doc);

-- mus�m indexova� konkr�tny element
--                                          -- doc je st�pec v tabu�ke
create index ind_json on books_json(JSON_value(doc, '$.Title'));
drop index ind_json;
-- m��em indexova� aj viacero atrib�tov, ale je tam obmedzen� d�ka kl��a
create index ind_json2 
on books_json(JSON_value(doc, '$.Type'), JSON_value(doc,'$.Detail.Publication_year'));


-- m�m tu viac autorov - JOSN POLE
select b.doc.Author
from books_json b;

-- aj ke� to je JSON pole dok�em to indexova�
--
create index ind_json2 on books_json(JSON_value(doc, '$.Author'));

select b.doc.Detail
from books_json b;

-- parametrom indexu bude cel� JSON dokument, ale mus� tam by� kon�truktor JSON_value 
create index ind_json5 on books_json(JSON_value(doc, '$'));


-- explicitn� indexi - pou��vate�sky definovan� 



/*
HASH INDEX
    sna�� sa rovnomerne distribuova� indexi do bucket 
    je to hash funkcia, ktor� zabezpe�� vyu�itie len toho rozsahu backeto ktor� m�m k dispoz�ci�
    cie� je �o najrovnomernej�ie rozlo�enie d�t - nie je to jednoduch� ak sa �trukt�ra d�t men�
    je to d�vod pre�o tento index prestal by� pou��van� 
    v pr�pade ve�k�ch zime je potrebn� prerobi� HASH fuknciu
    
*/