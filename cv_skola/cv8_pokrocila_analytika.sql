-- C:\Bloby_student

DECLARE?
  v_source_clob BFILE := BFILENAME('horecny4', 'text.txt');?
  --v_source_blob BFILE := BFILENAME('horecny4', ëFotka.jpgí);?
    v_size_clob integer;?
    v_size_blob integer;?
        v_clob CLOB := EMPTY_CLOB();?
        v_blob BLOB := EMPTY_BLOB();?
BEGIN?
    DBMS_LOB.OPEN(v_source_clob, DBMS_LOB.LOB_READONLY);?
    DBMS_LOB.OPEN(v_source_blob, DBMS_LOB.LOB_READONLY);?
       v_size_clob := DBMS_LOB.GETLENGTH(v_source_clob);?
       v_size_blob := DBMS_LOB.GETLENGTH(v_source_blob);?
    INSERT INTO Lob_tab(id, text, fotka) ?
           values(5, EMPTY_CLOB(), EMPTY_BLOB())?
                returning text, fotka into v_clob, v_blob;;?
    DBMS_LOB.LOADFROMFILE(v_clob, v_source_clob, v_size_clob);? -- zÌskavam tempol·rni LOB
    DBMS_LOB.LOADFROMFILE(v_blob, v_source_blob, v_size_blob);?
      DBMS_LOB.CLOSE(v_source_clob);?
      DBMS_LOB.CLOSE(v_source_blob);?
   UPDATE Lob_tab?
      SET text=v_clob, fotka=v_blob? -- aû tu ej ten s˙bor permanentn˝ 
        WHERE ID=5;?
END;?
/ ?
-- nie je tu commit, bude to v r·mci tejto session ale nie po vypnutÌ 

-- Delete fyzickÈ vymazanie z datab·zy
-- deötruktor ostane NULL EMPTY_BLOB()

-- kedy to m· zmysel rozliöovaù - keÔ sa na s˙bor odkazujem z viacer˝ch miest
-- 3 aspekty - kompresia, öifrovanie, duplikacie 

-- kedy m·m len smernÌk bez value? Pri akom type?
-- keÔ je s˙bor mimo datab·zy - b_file - extern˝ mimo datab·zy

drop table osoba;
create table osoba(id integer primary key, 
                   meno varchar2(10), 
                   priezvisko varchar2(20),  
                   matka integer null,
                   vek integer,
                   foreign key(matka) references osoba(id)
                  ); 

insert into osoba values(1, 'Peter', 'Maly', null, 10);    
insert into osoba values(2, 'Jana', 'Lieskova', null, 60); 
insert into osoba values(3, 'Ivana', 'Lieskova', 2,3);
insert into osoba values(34, 'Maria', 'Lieskova', 2,30);
insert into osoba values(40, 'Petra', 'Lieskova', 2,30);
insert into osoba values(35, 'KarolÌna', 'Lefantovsk·', null, 60);
insert into osoba values(36, 'Jarmila', 'Drahovsk·', 35,23);
insert into osoba values(38, 'Maroö', 'Kerpo', 35,17);
commit;

-- pre rekurzÌvnom vstahu je FK neidentifikaËn˝ 

-- ku kaûdej osobe vypÌsaù jej matku
select 
    d.id, d.meno, d.priezvisko, 
    m.id, m.meno, m.priezvisko
from osoba d left join osoba m on(d.matka = m.id);

-- ku kazdej osobe vypisaù jej s˙rodenca 
select 
    d.id, d.meno, d.priezvisko, 
    s.id, s.meno, s.priezvisko
from osoba d 
left join osoba s on(d.matka = s.matka)
where d.id <> s.id -- nie som s·m sebe s˙rodencom
order by 1;

-- ku kaûdej osobe vypÌsaù vöetk˝ch s˙rodencov v jednom riadku 
select 
    d.id, d.meno, d.priezvisko, 
    listagg(s.id || ': ' || s.meno || ' ' || s.priezvisko || ', ' )
    within group (order by s.id)
from osoba d 
left join osoba s on(d.matka = s.matka)
where d.id <> s.id -- nie som s·m sebe s˙rodencom
group by d.id, d.meno, d.priezvisko
order by 1;

--k matke chcem vypÌsaù iba dieùa ak m· menej ako 18 rokov 
select 
    d.id, d.meno, d.priezvisko, d.vek, 
    m.id, m.meno, m.priezvisko, m.vek
from osoba d left join osoba m on(d.matka = m.id and d.vek < 18); -- full join vÙbec nepomÙûe - st·le tie istÈ d·ta
--where d.vek < 18; -- d· to v˝sledok, ale nie dobr˝ 

-- podmieka musÌ Ìsù do spojenia

rollback;
create table skladove_zasoby
(id integer,
 produkt_id integer, 
 nazov varchar(20 char), 
 id_nakupu integer, 
 datum_nakupu date, 
 id_lokality integer, 
 sklad integer, 
 regal char(1), 
 pozicia integer, 
 mnozstvo integer
);

Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1379','7870','Piesok','760',to_date('29.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'2','1','A','2','39');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1466','4160','Skridla','776',to_date('22.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'3','1','A','3','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1421','4280','Tehly-paleta','767',to_date('23.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'4','1','A','4','37');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1394','5310','Cement','762',to_date('24.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'5','1','A','5','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1196','5430','Fasadna omietka','728',to_date('25.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'9','1','A','9','41');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1289','7790','Malta','744',to_date('28.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'12','1','A','12','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1217','4040','Porobetonove kocky','731',to_date('21.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'13','1','A','13','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1262','6520','Dlazobne kocky','739',to_date('26.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'16','1','A','16','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1448','5310','Cement','772',to_date('24.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'17','1','A','17','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1361','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'18','1','A','18','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1151','7870','Piesok','719',to_date('19.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'23','1','A','23','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1343','7790','Malta','754',to_date('28.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'24','1','A','24','3');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1271','4040','Porobetonove kocky','741',to_date('21.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'25','1','A','25','5');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1295','7950','Doska','745',to_date('31.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'27','1','A','27','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1163','5310','Cement','722',to_date('24.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'28','1','A','28','41');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1316','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'29','1','A','29','14');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1415','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'30','1','A','30','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1349','7950','Doska','755',to_date('31.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'34','1','B','2','39');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1382','7870','Piesok','760',to_date('29.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'39','1','B','7','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1340','6600','Mineralna vata','753',to_date('27.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'40','1','B','8','16');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1199','5430','Fasadna omietka','728',to_date('25.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'46','1','B','14','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1436','7870','Piesok','770',to_date('29.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'51','1','B','19','42');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1184','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'53','1','B','21','29');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1253','5430','Fasadna omietka','738',to_date('25.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'58','1','B','26','44');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1346','7790','Malta','754',to_date('28.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'61','1','B','29','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1274','4040','Porobetonove kocky','741',to_date('21.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'62','1','B','30','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1457','7950','Doska','775',to_date('30.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'63','1','B','31','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1478','6520','Dlazobne kocky','779',to_date('26.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'64','1','B','32','43');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1193','4280','Tehly-paleta','727',to_date('23.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'65','1','C','1','36');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1418','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'67','1','C','3','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1319','6520','Dlazobne kocky','749',to_date('26.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'69','1','C','5','70');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1166','5310','Cement','722',to_date('24.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'71','1','C','7','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1400','7790','Malta','764',to_date('28.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'73','1','C','9','7');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1328','4040','Porobetonove kocky','751',to_date('21.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'74','1','C','10','3');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1352','7950','Doska','755',to_date('31.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'76','1','C','12','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1205','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'77','1','C','13','20');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1220','5310','Cement','732',to_date('24.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'82','1','C','18','44');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1454','7790','Malta','774',to_date('28.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'85','1','C','21','31');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1439','7870','Piesok','770',to_date('29.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'87','1','C','23','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1406','7950','Doska','765',to_date('30.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'88','1','C','24','42');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1397','6600','Mineralna vata','763',to_date('27.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'89','1','C','25','19');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1187','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'90','1','C','26','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1256','5430','Fasadna omietka','738',to_date('25.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'95','1','C','31','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1460','7950','Doska','775',to_date('30.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'100','1','D','4','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1451','6600','Mineralna vata','773',to_date('27.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'101','1','D','5','8');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1241','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'102','1','D','6','31');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1310','5430','Fasadna omietka','748',to_date('25.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'107','1','D','11','40');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1403','7790','Malta','764',to_date('28.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'110','1','D','14','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1208','7870','Piesok','730',to_date('28.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'111','1','D','15','41');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1331','4040','Porobetonove kocky','751',to_date('21.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'112','1','D','16','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1250','4280','Tehly-paleta','737',to_date('23.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'114','1','D','18','39');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1376','6520','Dlazobne kocky','759',to_date('26.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'115','1','D','19','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1223','5310','Cement','732',to_date('24.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'116','1','D','20','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1385','4040','Porobetonove kocky','761',to_date('21.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'123','1','D','27','7');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1409','7950','Doska','765',to_date('30.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'125','1','D','29','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1277','5310','Cement','742',to_date('24.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'126','1','D','30','40');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1190','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'127','1','D','31','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1430','6520','Dlazobne kocky','769',to_date('26.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'129','2','A','1','72');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1172','7790','Malta','724',to_date('28.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'133','2','A','5','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1244','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'139','2','A','11','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1472','5430','Fasadna omietka','778',to_date('25.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'143','2','A','15','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1313','5430','Fasadna omietka','748',to_date('25.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'144','2','A','16','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1211','7870','Piesok','730',to_date('28.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'147','2','A','19','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1178','7950','Doska','725',to_date('31.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'148','2','A','20','41');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1169','6600','Mineralna vata','723',to_date('27.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'149','2','A','21','19');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1298','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'151','2','A','23','27');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1367','5430','Fasadna omietka','758',to_date('25.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'156','2','A','28','39');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1265','7870','Piesok','740',to_date('29.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'158','2','A','30','44');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1388','4040','Porobetonove kocky','761',to_date('21.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'160','2','A','32','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1307','4280','Tehly-paleta','747',to_date('23.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'163','2','B','3','35');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1280','5310','Cement','742',to_date('24.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'164','2','B','4','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1433','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'165','2','B','5','14');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1175','7790','Malta','724',to_date('28.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'170','2','B','10','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1442','4040','Porobetonove kocky','771',to_date('21.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'172','2','B','12','31');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1334','5310','Cement','752',to_date('24.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'175','2','B','15','39');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1247','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'176','2','B','16','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1154','7950','Doska','720',to_date('20.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'179','2','B','19','36');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1475','5430','Fasadna omietka','778',to_date('25.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'180','2','B','20','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1229','7790','Malta','734',to_date('28.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'182','2','B','22','8');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1157','4040','Porobetonove kocky','721',to_date('21.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'183','2','B','23','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1181','7950','Doska','725',to_date('31.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'185','2','B','25','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1202','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'186','2','B','26','24');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1301','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'188','2','B','28','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1370','5430','Fasadna omietka','758',to_date('25.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'193','2','C','1','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1268','7870','Piesok','740',to_date('29.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'196','2','C','4','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1235','7950','Doska','735',to_date('31.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'197','2','C','5','44');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1226','6600','Mineralna vata','733',to_date('27.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'198','2','C','6','21');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1469','4280','Tehly-paleta','777',to_date('23.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'199','2','C','7','19');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1355','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'200','2','C','8','26');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1424','5430','Fasadna omietka','768',to_date('25.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'205','2','C','13','42');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1481','7870','Piesok','780',to_date('29.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'208','2','C','16','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1322','7870','Piesok','750',to_date('29.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'209','2','C','17','40');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1364','4280','Tehly-paleta','757',to_date('23.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'212','2','C','20','34');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1337','5310','Cement','752',to_date('24.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'215','2','C','23','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1232','7790','Malta','734',to_date('28.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'219','2','C','27','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1160','4040','Porobetonove kocky','721',to_date('21.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'220','2','C','28','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1373','6520','Dlazobne kocky','759',to_date('26.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'223','2','C','31','21');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1463','4160','Skridla','776',to_date('22.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'224','2','C','32','30');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1304','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'225','2','D','1','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1391','5310','Cement','762',to_date('24.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'227','2','D','3','42');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1286','7790','Malta','744',to_date('28.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'231','2','D','7','5');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1214','4040','Porobetonove kocky','731',to_date('21.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'232','2','D','8','8');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1259','6520','Dlazobne kocky','739',to_date('26.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'233','2','D','9','26');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1238','7950','Doska','735',to_date('31.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'234','2','D','10','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1445','5310','Cement','772',to_date('24.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'236','2','D','12','6');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1358','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'237','2','D','13','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1427','5430','Fasadna omietka','768',to_date('25.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'242','2','D','18','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1148','7870','Piesok','719',to_date('19.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'244','2','D','20','11');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1484','7870','Piesok','780',to_date('29.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'245','2','D','21','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1325','7870','Piesok','750',to_date('29.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'246','2','D','22','48');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1283','6600','Mineralna vata','743',to_date('27.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'247','2','D','23','17');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1412','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'249','2','D','25','29');
Insert into skladove_zasoby (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1292','7950','Doska','745',to_date('31.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'252','2','D','28','40');

create table objednavky
(id_zak integer, 
 meno_zak varchar(20 char), 
 id_obj integer, 
 id_prod integer, 
 nazov_prod varchar(20 char), 
 mnozstvo integer
); 

create table objednavky2
(id_zak integer, 
 meno_zak varchar(20 char), 
 id_obj integer, 
 id_prod integer, 
 nazov_prod varchar(20 char), 
 mnozstvo integer
); 

Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Karol Matiasko','421','4280','Tehly-paleta','110');
Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Karol Matiasko','421','6520','Dlazobne kocky','140');

Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','4280','Tehly-paleta','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','6520','Dlazobne kocky','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','4280','Tehly-paleta','60');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','6520','Dlazobne kocky','40');

commit;


-- jeden produk mÙûe byù v sklade na viacer˝ch miestach
-- snaûÌm sa predaù najstaröie veci
-- treba identifikovaù miesta 

-- musÌm postupne poËÌtaù produkty podæa toho kedy som ich k˙pil 
desc skladove_zasoby;

-- je tam over, SUM nie je to agregaËn· funkcia ale analytick· 
select 
    produkt_id, nazov, 
    datum_nakupu,
    sum(mnozstvo) over (partition by produkt_id order by datum_nakupu 
                            rows between unbounded preceding and current row), 
    mnozstvo
from  skladove_zasoby
order by 1, datum_nakupu; -- vyjadruje celkov˝ poËet 
-- Ëo vyjadruje suma?

select * from objednavky;

select * from skladove_zasoby where produkt_id = '4280'
order by datum_nakupu;


select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu) suma
from skladove_zasoby
where produkt_id = 4280
order by datum_nakupu;


select inner.*
from 
(select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu) pocet
from skladove_zasoby
where produkt_id = 4280
order by datum_nakupu) inner
where pocet <= 110;

--6520
-- druh· objedn·vka
select inner.*
from 
(select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu 
                        rows between unbounded preceding and current row) as pocet -- musÌ tam byù toto, inak to nepÙjde 
from skladove_zasoby
where produkt_id = 6520
order by datum_nakupu) inner
where pocet <= 140;
-- nast·va problÈm, nepouûil som rows, preto vöade dost·vam celkov˙ hodnotu 


-- beriem predch·dzaj˙ci riadok 
select inner.*, pocet
from 
(select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu 
                        rows between unbounded preceding and 1 preceding) as pocet -- musÌ tam byù toto, inak to nepÙjde 
from skladove_zasoby
where produkt_id = 6520
order by datum_nakupu) inner
where pocet  <= 140 + inner.mnozstvo;

-- z poslednÈho miesta zoberiem iba toæko koæko potrebujem 
select inner.*, case when pocet > 140 then 140 else pocet end
from 
(select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu 
                        rows between unbounded preceding and 1 preceding) as pocet -- musÌ tam byù toto, inak to nepÙjde 
from skladove_zasoby
where produkt_id = 6520
order by datum_nakupu) inner
where pocet  <= 140 + inner.mnozstvo;
-- pocet - celkov˝ poËet do aktu·lneho z·znamu a k tomu eöte treba pripoËÌtaù aktu·lny riadok 

-- ak by som tam mal current row, tak mi to ned· 



-- ako dostaù lepöiu trasu? aby som kaûd˝ druh˝ rad iöli opaËne?
-- dense_rank mi to oËÌsluje  

select * from (
select inner.*, case when pocet > 140 then 140 else pocet end, dense_rank() over(order by sklad, regal) as dr -- partioion by sklad, order by sklad 
from 
(select 
    skladove_zasoby.*, 
    sum(mnozstvo) over (order by datum_nakupu 
                        rows between unbounded preceding and 1 preceding) as pocet 
                         -- vypoËÌtam dese_rank pre vn˙tornÈ z·znami, ale neberiem ich vöetky 
                        -- poËÌtam to bez ohladu na daæöie parametre skladu 
                        -- dense rank musÌ byù hore v selecte 
from skladove_zasoby
where produkt_id = 6520
order by datum_nakupu) inner
where pocet  <= 140 + inner.mnozstvo
)
order by sklad, case when mod(dr, 2)=0 then -pozicia else pozicia end;

-- ako to mu povedaù iba jedni ölo z dola a druhÈ z hora -  case modulo 2


-- Ëo ak sa pokazia dvere a musÌm Ìsù druh˝mi
-- a Ëo keby sme öli domov?????
-- eöte partion by pre dense rank pre sklad
-- pre kaûd˝ sklad to budeme ËÌslovaù osobytne 


-- chcem dostaù to Ëo som vypÌsal teraz, ale vozidlo bude braù veöky objedn·vky naraz
-- ale musÌm oddelovaù Ëi beriem tovar pre prv˙, alebo druh˙ objedn·vky
-- vo v˙zbe na tabuæku objedn·vky dva 
-- vûdy si treba poËÌtaù koæko mi eöte ch·va do naplnenia jednotliv˝ch objedn·vok 
-- ak nezoberiem vöetko, zvyöok mÙûem pouûiù pre objedn·vku dva
-- musÌm oddeliù jednotlivÈ objedn·vky -- PARTIOION BY le to treba oddeliù osobytne pre jednotlivÈ objedn·vky 

-- druh· vec 
-- funkcia, ktor· mi nahradÌ reùazec 
-- vstup: Ahoj michal
-- m·m parameter ûe z A sa stane male a.. a tak Ôalej, mÙûem neniù viac vecÌ 
-- funkcia m· 3 parametere
-- vstupn˝ raùazec - mÙûem tam daù æubovoæn˝ poËet zmien -- modelovaù to podæa nejakej kolekcie 
-- 2 parameter pÙvodnÈ hodnoty ktorÈ transformujem -- vstupn˝ parameter musÌ byù kolekcia 
-- 3 parameter naËo ich transformujem 
-- do piatku 

-- spracuj('AHOJ Miöko', kol('A', 'o'), kol('a', 'c'))
