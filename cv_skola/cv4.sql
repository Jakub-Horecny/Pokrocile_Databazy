select XMLRoot(
         XMLElement("student", XMLAttributes(st.os_cislo as "oc"),
           XMLForest( o.meno as "meno",
                      o.priezvisko as "priezvisko",
                      st.st_skupina as "skupina"),
           XMLElement("zap_predmety",
               XMLAgg(
               XMLElement("predmet", XMLAttributes(pr.cis_predm as "cislo_predmetu"),
                   XMLForest(p.nazov as "nazov",
                             pr.ects as "kredity",
                             pr.skrok as "skrok"))
                     )
                )), version '1.0' ) as XML
  from os_udaje o
   join student st using(rod_cislo)
   join zap_predmety pr on(st.os_cislo = pr.os_cislo)
   join predmet p on(p.cis_predm = pr.cis_predm)
  where pr.cis_predm IN ('IP07', 'IS04')
  group by st.os_cislo, meno, priezvisko, st_skupina;
  
  
  create table xml_studenti of XMLTYPE ;
  /
  
  create table xml_studenti2 (
    rod_cislo char(11) primary key,
    udaje xmltype
  );
  /
  
desc xml_studenti; -- nezobraz� sa mi ni�, lebo tam nie je �aidne sch�ma vo�i ktorej budem porovn�va� 
desc xml_studenti2;

insert into xml_studenti(select XMLRoot(
         XMLElement("student", XMLAttributes(st.os_cislo as "oc"),
           XMLForest( o.meno as "meno",
                      o.priezvisko as "priezvisko",
                      st.st_skupina as "skupina"),
           XMLElement("zap_predmety",
               XMLAgg(
               XMLElement("predmet", XMLAttributes(pr.cis_predm as "cislo_predmetu"),
                   XMLForest(p.nazov as "nazov",
                             pr.ects as "kredity",
                             pr.skrok as "skrok"))
                     )
                )), version '1.0' ) as XML
  from os_udaje o
   join student st using(rod_cislo)
   join zap_predmety pr on(st.os_cislo = pr.os_cislo)
   join predmet p on(p.cis_predm = pr.cis_predm)
  where pr.cis_predm IN ('IP07', 'IS04')
  group by st.os_cislo, meno, priezvisko, st_skupina);  
  
  -- nesmie sa zabudn�� na priamry key 
  insert into xml_studenti2(select o.rod_cislo, XMLRoot(
         XMLElement("student", XMLAttributes(st.os_cislo as "oc"),
           XMLForest( o.meno as "meno",
                      o.priezvisko as "priezvisko",
                      st.st_skupina as "skupina"),
           XMLElement("zap_predmety",
               XMLAgg(
               XMLElement("predmet", XMLAttributes(pr.cis_predm as "cislo_predmetu"),
                   XMLForest(p.nazov as "nazov",
                             pr.ects as "kredity",
                             pr.skrok as "skrok"))
                     )
                )), version '1.0' ) as XML
  from os_udaje o
   join student st on(o.rod_cislo = st.rod_cislo)
   join zap_predmety pr on(st.os_cislo = pr.os_cislo)
   join predmet p on(p.cis_predm = pr.cis_predm)
  where pr.cis_predm IN ('IP07', 'IS04')
  group by st.os_cislo, meno, priezvisko, st_skupina, o.rod_cislo); 
  
  select value(s) from xml_studenti s;
  
  -- vypi�e meno aj s tagmi <meno>Jozef</meno>
  select extract(value(s), '/student/meno') from xml_studenti s;

-- cze extractvalue z�skam iba men�   
select extractvalue(value(s), '/student/meno') from xml_studenti s;

-- ako prist�pi� k jednotliv�m elementom
-- z�skam cel� podstrom zap_predmetu 
select extract(value(s), '/student/zap_predmety/predmet[1]') from xml_studenti s;
 -- ak d�m neplatn� index dostanme null
 
 -- o�etrenie null hodnoty
 select nvl(extract(value(s), '/student/zap_predmety/predmet[1]').getClobVal(), 'neexistuje') from xml_studenti s;
 
 -- pr�stup k elementu cez @
  select extract(value(s), '/student/zap_predmety/predmet[1]/@cislo_predmetu') from xml_studenti s;
select extractvalue(value(s), '/student/zap_predmety/predmet[1]/@cislo_predmetu') from xml_studenti s;

select extractvalue(value(s), '/student/@oc') from xml_studenti s; 



select extractvalue(udaje, '/student/@oc') from xml_studenti2;





----------- cvicenie 8 -------------
-- 1 vytvorte tabulkuosobaxmltypu XMLTYPE
create table osoba_xml of XMLTYPE ;
  /
-- 2 vlo�te aspo� dva z�znami cez insert
insert into osoba_xml values(XMLType('<osoba rc="123456/4321">
                            <meno>Jakub</meno>
                            <priezvisko>Horency</priezvisko>
                            </osoba>'));/

-- 3 vyp�te obsah tabu�ky 
select * from osoba_xml;
select value(s) from osoba_xml s;

-- 4 vyp�te menn� zoznam os�b
select 
    extractvalue(value(s), '/osoba/@rc') rod_cislo,
    extractvalue(value(s), '/osoba/meno') meno,
    extractvalue(value(s), '/osoba/priezvisko') priezvisko
    from osoba_xml s;
    
-- 5 zmente priezvisko nejakej osobe 
update osoba_xml s
set value(s) = UPDATEXML(value(s),
'/osoba/priezvisko/text()', 'Karol')
            where extractvalue(value(s), '/osoba/@rc') = '810505/2323';

-- 5 zmente rod_cislo nejakej osobe     
update osoba_xml s
set value(s) = UPDATEXML(value(s),
'/osoba/@rc/text()', '810505/9632')
            where extractvalue(value(s), '/osoba/@rc') = '810505/2323';
            
-- 7 vlo�te osobu z osoba xml do tabu�ky os udaje
insert into os_udaje(rod_cislo, meno, priezvisko) 
(select 
    extractvalue(value(s), '/osoba/@rc'), 
    extractvalue(value(s), '/osoba/meno'), 
    extractvalue(value(s), '/osoba/priezvisko')
    from osoba_xml s);
    
    
select * from priklad_db2.student;
