-- TP Révisions

-- Requête 1
-- le résultat attendu est 4 lignes
-- Non, nous ne pouvons pas écrire cette requette en utilisant une sous-requête car des données provenant des deux tables sont affichées. 
SELECT e.agt_nom||'-'||e.agt_prenom as Agent, c.chb_numero as "Chambre", c.chb_etage as "étage"
FROM HOTEL.chambre c JOIN HOTEL.agent_entretien e ON (c.agt_id = e.agt_id)
WHERE c.chb_etage = '1er'
AND c.chb_communique IS NULL
AND UPPER(e.agt_nom) IN ('PEZIN','BOUSSEL');


--Requête 2
-- a) Avec les jointures
SELECT DISTINCT t.tit_lib||' '||REPLACE(cl.cli_nom,' ','')||' '||cl.cli_prenom as Client
FROM HOTEL.client cl JOIN HOTEL.titre t ON (cl.tit_code = t.tit_code)
                    JOIN HOTEL.adresse a ON (cl.cli_id = a.cli_id)
                    JOIN HOTEL.planning p ON (cl.cli_id = p.cli_id)
                    JOIN HOTEL.chambre ch ON (p.chb_id = ch.chb_id)
WHERE UPPER(a.adr_ville) = 'REIMS'
AND ch.chb_etage = 'RDC'
AND EXTRACT(MONTH FROM p.pln_jour) IN (11,12)
AND EXTRACT(YEAR FROM p.pln_jour) = 2007;

-- b) Avec des sous-requêtes
SELECT DISTINCT t.tit_lib||' '||REPLACE(cl.cli_nom,' ','')||' '||cl.cli_prenom as Client
FROM HOTEL.client cl JOIN HOTEL.titre t ON (cl.tit_code = t.tit_code)
WHERE cl.cli_id IN (SELECT cli_id
                    FROM HOTEL.adresse
                    WHERE UPPER(adr_ville) = 'REIMS')
AND cl.cli_id IN (SELECT cli_id
                FROM HOTEL.planning
                WHERE EXTRACT(MONTH FROM pln_jour) IN (11,12)
                AND EXTRACT(YEAR FROM pln_jour) = 2007
                AND chb_id IN (SELECT chb_id
                            FROM HOTEL.chambre
                            WHERE chb_etage = 'RDC'));


-- Requête 3
--a) 
SELECT DISTINCT agt_nom||' '||agt_prenom as "Agent", EXTRACT(YEAR FROM agt_emb) as "Embauche"
FROM HOTEL.chambre c JOIN HOTEL.agent_entretien e ON (c.agt_id = e.agt_id)
ORDER BY "Embauche";

--b)
SELECT *
FROM (SELECT agt_nom||' '||agt_prenom as "Agent", EXTRACT(YEAR FROM agt_emb) as "Embauche"  FROM HOTEL.agent_entretien
                                                                                            WHERE agt_id IN (SELECT agt_id FROM HOTEL.chambre) ORDER BY "Embauche")
WHERE ROWNUM < 3;

--Requête 4
--a)
SELECT COUNT(reserve)as "Nb Réservations", COUNT(DISTINCT cli_id) as "Nb Clients"
FROM HOTEL.planning 
WHERE EXTRACT(MONTH FROM pln_jour) = 11
AND EXTRACT(YEAR FROM pln_jour) = 2007;

--b)
SELECT TO_CHAR(pln_jour,'day DD') as "Jour", COUNT(DISTINCT chb_id) as "Nb Chambres",SUM(nb_pers) as "Nb Personnes"
FROM HOTEL.planning
WHERE EXTRACT(YEAR FROM pln_jour) = 2007
AND EXTRACT(MONTH FROM pln_jour) = &mois
GROUP BY TO_CHAR(pln_jour,'day DD')
ORDER BY "Jour";


-- Requête 5
SELECT to_char(pln_jour,'Day DD Month YYYY') as "Jours Hôtel Complet"
FROM HOTEL.planning
GROUP BY TO_CHAR(pln_jour,'Day DD Month YYYY')
HAVING COUNT(chb_id) = (SELECT COUNT(DISTINCT chb_id)
                       FROM HOTEL.chambre);
   
                       
-- Requête 6
--a)
SELECT c.cli_id as CLI_ID, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom as CLIENT, COUNT(e.eml_id)||' '||'adr. mail' as "NB ADR."
FROM HOTEL.client c JOIN HOTEL.email e ON (c.cli_id = e.cli_id)
GROUP BY c.cli_id, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom
HAVING COUNT(e.eml_id) > 1
ORDER BY CLIENT;

--b)
SELECT c.cli_id as CLI_ID, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom as CLIENT, COUNT(e.eml_id)||' '||'adr. mail' as "PLUSIEURS ADR."
FROM HOTEL.client c JOIN HOTEL.email e ON (c.cli_id = e.cli_id)
GROUP BY c.cli_id, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom
HAVING COUNT(e.eml_id) > 1
UNION
SELECT c.cli_id as CLI_ID, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom as CLIENT, COUNT(a.adr_id)||' '||'adr. postales' as "PLUSIEURS ADR."
FROM HOTEL.client c JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
GROUP BY c.cli_id, REPLACE(c.cli_nom,' ','')||' '||c.cli_prenom
HAVING COUNT(a.adr_id) > 1
ORDER BY CLIENT;


--Requête 7
--Version 1
SELECT e.agt_nom||' '||e.agt_prenom as Agent,NVL2(c.chb_numero,'N°'||c.chb_numero,'Aucune chambre') as "Chambre", NVL(c.chb_etage,'--') as "étage"
FROM HOTEL.chambre c RIGHT JOIN HOTEL.agent_entretien e ON (c.agt_id = e.agt_id) -- Car c'est la colonne dominante 
WHERE e.agt_salaire BETWEEN 1100 AND 1200;

--version 2
SELECT e.agt_nom||' '||e.agt_prenom as Agent,NVL2(c.chb_numero,'N°'||c.chb_numero,'Aucune chambre') as "Chambre", NVL(c.chb_etage,'--') as "étage"
FROM HOTEL.chambre c, HOTEL.agent_entretien e
WHERE c.agt_id(+) = e.agt_id --car c'est la colonne succeptible d'avoir l'attribut null : colonne dominée
AND e.agt_salaire BETWEEN 1100 AND 1200;


--Requête 8
--Version 1
SELECT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c LEFT JOIN HOTEL.planning p ON (c.cli_id = p.cli_id)
                    JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
AND p.cli_id IS NULL;

--Version 2
SELECT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
MINUS
SELECT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
                    JOIN HOTEL.planning p ON (c.cli_id = p.cli_id);
                    
--Version 3
SELECT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
WHERE c.cli_id NOT IN (SELECT cli_id
                        FROM HOTEL.planning);
                        
--Version 4
SELECT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c , HOTEL.adresse a
WHERE NOT EXISTS (SELECT cli_id
                FROM HOTEL.planning p
                WHERE c.cli_id = p.cli_id)
AND c.cli_id = a.cli_id;

--Version 5 (Bonus)
SELECT DISTINCT REPLACE(c.cli_nom,' ','')||'-'||c.cli_prenom as CLIENT, a.adr_ligne1 as "Adresse", a.adr_cp as "Code Postal", a.adr_ville as Ville
FROM HOTEL.client c, HOTEL.adresse a,HOTEL.planning p
WHERE c.cli_id = a.cli_id
AND c.cli_id = p.cli_id(+)
AND p.cli_id IS NULL;


--Requête 9 
SELECT DISTINCT t.tit_lib||' '||REPLACE(cl.cli_nom,' ','')||' '||cl.cli_prenom as "Meilleur client 2007", e.eml_adresse as Email, COUNT(DISTINCT p.pln_jour) as "Nb Jours"
FROM HOTEL.client cl JOIN HOTEL.titre t ON (cl.tit_code = t.tit_code)
                    JOIN HOTEL.planning p ON (cl.cli_id = p.cli_id)
                    JOIN HOTEL.email e ON (cl.cli_id = e.cli_id)
WHERE EXTRACT(YEAR FROM p.pln_jour) = 2007
GROUP BY t.tit_lib||' '||REPLACE(cl.cli_nom,' ','')||' '||cl.cli_prenom,e.eml_adresse
HAVING COUNT(DISTINCT p.pln_jour) = (SELECT MAX(COUNT(DISTINCT pln_jour))
                            FROM HOTEL.planning
                            WHERE EXTRACT(YEAR FROM pln_jour) = 2007
                            GROUP BY (cli_id));


--Requête 10

--a)
SELECT REPLACE(cl.cli_nom,' ','') as "Nom", cl.cli_prenom as "Prénom", NVL(e.eml_adresse, 'Aucune adresse') as Email
FROM HOTEL.client cl LEFT JOIN HOTEL.email e ON (cl.cli_id = e.cli_id)
                     JOIN HOTEL.adresse a ON (cl.cli_id = a.cli_id)
WHERE UPPER(a.adr_ville) = 'PARIS'
ORDER BY "Nom","Prénom";

--b)
--Version 1
SELECT REPLACE(cl.cli_nom,' ','') as "Nom", cl.cli_prenom as "Prénom",NVL(t.tel_numero, 'Aucun Fax') as "Numéro Fax", NVL(e.eml_adresse, 'Aucune adresse') as Email --,t.typ_code 
FROM HOTEL.client cl LEFT JOIN HOTEL.email e ON (cl.cli_id = e.cli_id)
                     LEFT JOIN HOTEL.telephone t ON (cl.cli_id = t.cli_id AND UPPER(t.TYP_CODE) = 'FAX')
                     JOIN HOTEL.adresse a ON (cl.cli_id = a.cli_id)
WHERE UPPER(a.adr_ville) = 'PARIS'
ORDER BY "Nom","Prénom";

--Version 2
SELECT REPLACE(cl.cli_nom,' ','') as "Nom", cl.cli_prenom as "Prénom", NVL(t.tel_numero, 'Aucun Fax') as "Numéro Fax", NVL(e.eml_adresse, 'Aucune adresse') as Email --,t.typ_code
FROM (SELECT *  FROM HOTEL.telephone  WHERE UPPER(TYP_CODE) = 'FAX') t, HOTEL.client cl, HOTEL.email e, HOTEL.adresse a                                                                             
WHERE cl.cli_id = e.cli_id(+)
AND cl.cli_id = t.cli_id(+)
AND cl.cli_id = a.cli_id
AND UPPER(a.adr_ville) = 'PARIS'
ORDER BY "Nom","Prénom";

--c)
SELECT REPLACE(cli_nom,' ','') as "Nom", cli_prenom as "Prénom"
FROM HOTEL.client
WHERE cli_id NOT IN (SELECT cli_id
                    FROM HOTEL.email)
AND cli_id NOT IN (SELECT cli_id
                    FROM HOTEL.telephone
                    WHERE UPPER(typ_code) = 'FAX')
AND cli_id IN (SELECT cli_id
                FROM HOTEL.adresse
                WHERE UPPER(adr_ville) = 'PARIS')
ORDER BY "Nom","Prénom";


--Requête 11

--a)
--Version 1
SELECT 'N°'||ch.chb_numero as "Chambre", NVL(cl.cli_id, 0) as "N°CLient"
FROM HOTEL.chambre ch LEFT JOIN HOTEL.planning p ON (ch.chb_id = p.chb_id AND TO_CHAR(p.pln_jour,'DD/MM/YYYY') = '26/12/2007')
                        LEFT JOIN HOTEL.client cl ON (p.cli_id = cl.cli_id)
ORDER BY ch.chb_numero;

--Version 2
SELECT  'N°'||ch.chb_numero as "Chambre", NVL(cl.cli_id,0) as "N°CLient"
FROM HOTEL.chambre ch, (SELECT * FROM HOTEL.planning WHERE TO_CHAR(pln_jour,'DD/MM/YYYY') = '26/12/2007') p, HOTEL.client cl
WHERE ch.chb_id = p.chb_id(+)
AND p.cli_id = cl.cli_id(+)
ORDER BY ch.chb_numero;

--b)
SELECT 'N°'||ch.chb_numero as "Chambre", NVL(REPLACE(cl.cli_nom,' ',''),'Aucun') as "Nom", NVL(cl.cli_prenom,'client') as "Prenom"
FROM HOTEL.chambre ch, HOTEL.client cl, (SELECT * FROM HOTEL.planning WHERE TO_CHAR(pln_jour,'DD/MM/YYYY') = '26/12/2007') p
WHERE ch.chb_id = p.chb_id(+)
AND p.cli_id = cl.cli_id(+)
ORDER BY ch.chb_numero;


--Requête 12
--J'affiche d'abord les agents qui ont en charge au moins une chambre avec  plus  de  2  couchages ( avec les NVL correspondant) puis j'affiche le reste avec un autre entete de colonne
--Version 1
SELECT UPPER(e.agt_nom) as "Agent Entretien", NVL2(COUNT(c.chb_id),COUNT(c.chb_id)||' Chambres','Pas de Chambre de plus de 2 Couchages') as "Nb Chambres"
FROM (SELECT * FROM HOTEL.agent_entretien WHERE agt_sx = 2) e, (SELECT * FROM HOTEL.chambre WHERE chb_couchage > 2) c
WHERE e.agt_id = c.agt_id(+)
GROUP BY UPPER(e.agt_nom)
HAVING COUNT(c.chb_id) > 0
UNION
SELECT UPPER(e.agt_nom) as "Agent Entretien", 'Pas de Chambre de plus de 2 Couchages' as "Nb Chambres"
FROM (SELECT * FROM HOTEL.agent_entretien WHERE agt_sx = 2) e, (SELECT * FROM HOTEL.chambre WHERE chb_couchage > 2) c
WHERE e.agt_id = c.agt_id(+)
GROUP BY UPPER(e.agt_nom),'Pas de Chambre de plus de 2 Couchages'
HAVING COUNT(c.chb_id) = 0;

--Version 2
SELECT UPPER(e.agt_nom) as "Agent Entretien", NVL2(COUNT(c.chb_id),COUNT(c.chb_id)||' Chambres','Pas de Chambre de plus de 2 Couchages') as "Nb Chambres"
FROM HOTEL.agent_entretien e LEFT JOIN HOTEL.chambre c ON (e.agt_id = c.agt_id AND c.chb_couchage > 2)
WHERE e.agt_sx = 2
GROUP BY UPPER(e.agt_nom)
HAVING COUNT(c.chb_id) > 0
UNION
SELECT UPPER(e.agt_nom) as "Agent Entretien", 'Pas de Chambre de plus de 2 Couchages' as "Nb Chambres"
FROM HOTEL.agent_entretien e LEFT JOIN HOTEL.chambre c ON (e.agt_id = c.agt_id AND c.chb_couchage > 2)
WHERE e.agt_sx = 2
GROUP BY UPPER(e.agt_nom),'Pas de Chambre de plus de 2 Couchages'
HAVING COUNT(c.chb_id) = 0;


--Requête 13
--Version 1
SELECT UPPER(c.cli_nom) as "Client", UPPER(a.adr_ville) as "Ville", NVL(t.tel_numero, 'Numéro inconnu') as "téléphone"
FROM HOTEL.client c LEFT JOIN HOTEL.planning p ON (c.cli_id = p.cli_id AND p.nb_pers < 4)
                    JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
                    LEFT JOIN HOTEL.telephone t ON (c.cli_id = t.cli_id AND UPPER(t.typ_code) = 'TEL')
WHERE (p.cli_id IS NULL OR t.cli_id IS NULL);


--Version 2
SELECT UPPER(c.cli_nom) as "Client", UPPER(a.adr_ville) as "Ville", NVL(t.tel_numero, 'Numéro inconnu') as "téléphone"
FROM HOTEL.client c, (SELECT * FROM HOTEL.planning WHERE nb_pers < 4) p, HOTEL.adresse a, (SELECT * FROM HOTEL.telephone WHERE UPPER(typ_code) = 'TEL') t
WHERE c.cli_id = p.cli_id(+)
AND c.cli_id = a.cli_id
AND c.cli_id = t.cli_id(+)
AND (p.cli_id IS NULL OR t.cli_id IS NULL);

--Version 3
SELECT UPPER(c.cli_nom) as "Client", UPPER(a.adr_ville) as "Ville", NVL(t.tel_numero, 'Numéro inconnu') as "téléphone"
FROM HOTEL.client c LEFT JOIN HOTEL.planning p ON (c.cli_id = p.cli_id)
                    JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
                    LEFT JOIN HOTEL.telephone t ON (c.cli_id = t.cli_id AND UPPER(t.typ_code) = 'TEL')
MINUS
SELECT  UPPER(c.cli_nom) as "Client", UPPER(a.adr_ville) as "Ville", NVL(t.tel_numero, 'Numéro inconnu') as "téléphone"
FROM HOTEL.client c JOIN HOTEL.planning p ON (c.cli_id = p.cli_id AND p.nb_pers >= 4)
                    JOIN HOTEL.adresse a ON (c.cli_id = a.cli_id)
                    JOIN HOTEL.telephone t ON (c.cli_id = t.cli_id AND UPPER(t.typ_code) = 'TEL');




