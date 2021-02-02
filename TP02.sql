--Exercice 1

--1) Requete de sélection
SELECT l.LIF_ID LIF_ID,
l.FAC_ID FAC_ID,
l.QTE QTE,
l.REMISE_POURCENT REMISE_POURCENT,
l.REMISE_MNT REMISE_MNT,
l.MNT MNT,
l.TAUX_TVA TAUX_TVA
FROM ligne_facture l JOIN facture f ON (l.fac_id = f.fac_id)
                    JOIN mode_paiement m ON (f.pmt_code = m.pmt_code)
                    JOIN adresse a ON (f.adr_id = a.adr_id)
WHERE UPPER(m.pmt_lib) = 'CHEQUE'
AND a.adr_cp LIKE '02%';

--2)
--a) Requete suppression de la facture n°1476
DELETE FROM facture
WHERE fac_id = 1476;






--b) Création des tables OLD_FACT et OLD_LG
--Création de la table OLD_FACT
/*==============================================================*/
/* Table : OLD_FACT                                              					*/
/*==============================================================*/
create table OLD_FACT AS (
    SELECT FAC_ID ,
PMT_CODE ,
CLI_ID ,
ADR_ID ,
FAC_DATE ,
FAC_DAT_PMT 
    FROM facture
    WHERE fac_id IS NULL
)
/

--Création de la table OLD_LG
/*==============================================================*/
/* Table : OLD_LG                                              					*/
/*==============================================================*/
create table OLD_LG AS (
    SELECT LIF_ID ,
FAC_ID ,
QTE ,
REMISE_POURCENT ,
REMISE_MNT ,
MNT ,
TAUX_TVA 
    FROM ligne_facture
    WHERE LIF_ID IS NULL
)
/

--Suppression des deux tables
DELETE FROM OLD_FACT ;
DELETE FROM OLD_LG ;

--









-- b)
--Suppression impossible car violerait la contrainte de cléétrangès. Des enregistrements liés à cette clé primaire sont présents dans d'autres tables

--Les solutions possibles sont l'ajout de contrainte de cascade ou d'un déclencheur.
--La solution préférable est l'ajout d'un déclencheur car elle peut etre definie une seule fois et paramétrée pour concerner toutes les tables liées à celle mis en exerge dans le déclencheur.
-- ce qui n'est pas le cas pour une contrainte de cascade qui dont etre définie à chaque fois.
--3)
 
CREATE OR REPLACE TRIGGER TR_Facture
BEFORE DELETE ON FACTURE
FOR EACH ROW
BEGIN
    ---- récupération de la ligne de facture à supprimer
    INSERT INTO old_lg(LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA) SELECT LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA FROM ligne_facture WHERE fac_id = :old.fac_id;
    --récupération de la ligne de facture liée à la facture à supprimer
    INSERT INTO old_fact(FAC_ID ,PMT_CODE ,CLI_ID ,ADR_ID ,FAC_DATE ,FAC_DAT_PMT) VALUES(:old.FAC_ID ,:old.PMT_CODE ,:old.CLI_ID ,:old.ADR_ID ,:old.FAC_DATE ,:old.FAC_DAT_PMT);
    DELETE FROM ligne_facture WHERE fac_id = :old.fac_id;
    dbms_output.put_line ('Suppression effectuée');
END;
/

--Exercice 2
--1)
--Ajout contrainte check
ALTER TABLE CHAMBRE ADD CONSTRAINT VERIF_CHB_COUCHAGE CHECK (CHB_COUCHAGE BETWEEN 1 AND 5);
--insertion
INSERT INTO CHAMBRE (CHB_ID, CHB_NUMERO, CHB_ETAGE, CHB_COUCHAGE) 
VALUES(30,29,'RDC', 6);



--2)
--Création du déclencheur TR_couchage
CREATE OR REPLACE TRIGGER TR_Couchage
BEFORE INSERT ON CHAMBRE
FOR EACH ROW
WHEN((new.chb_couchage not  between 1 and 5) OR (new.chb_couchage IS NULL))
BEGIN
    :new.CHB_COUCHAGE := 2;
    dbms_output.put_line ('Insertion effectuée');
END;
/

--Suppression de la contarinte VERIF_CHB_COUCHAGE
ALTER TABLE CHAMBRE 
DROP CONSTRAINT VERIF_CHB_COUCHAGE;


--Exercice 3

--1)
--Création du déclencheur TR_planning 
CREATE OR REPLACE TRIGGER TR_planning 
BEFORE INSERT OR UPDATE ON PLANNING
FOR EACH ROW
BEGIN
    IF((:new.PLN_JOUR IS NULL) OR (:new.PLN_JOUR < SYSDATE))
        THEN :new.PLN_JOUR := SYSDATE;
    END IF;
    dbms_output.put_line ('Réservation Enregistrée');
END;
/


INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(1, TO_DATE('01/01/2020', 'DD/MM/YYYY'), 100, 2);

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(2,null ,100, 2);


--Requete d'affichage pour vérification du déclencheur
SELECT CHB_ID as "Reservation", pln_jour as "Jour réservation"
FROM PLANNING
WHERE CLI_ID = 100
ORDER BY pln_jour DESC;


--3)
INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(15, null, 100, 15);

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(15, null, 100, 2);