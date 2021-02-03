--Exercice 1

SET SERVEROUTPUT ON;

--1) Requete de sélection
SELECT l.LIF_ID "Ligne facture",
l.FAC_ID "Facture N°",
l.QTE "Quantité",
l.REMISE_POURCENT "Remise ne pourcent",
l.REMISE_MNT REMISE_MNT,
l.MNT "Montant",
l.TAUX_TVA "Taux TVA"
FROM ligne_facture l JOIN facture f ON (l.fac_id = f.fac_id)
                    JOIN adresse a ON (f.adr_id = a.adr_id)
WHERE UPPER(f.pmt_code) = 'CHQ'
AND a.adr_cp LIKE '02%';

--2)
--a) Requete suppression de la facture n°1476
DELETE FROM facture
WHERE fac_id = 1476;

--b)
--Suppression impossible car violerait la contrainte de clé étrangès. Des enregistrements liés à cette clé primaire sont présents dans d'autres tables

--Les solutions possibles sont l'ajout de contrainte de cascade ou d'un déclencheur.
--La solution préférable est l'ajout d'un déclencheur car elle peut etre definie une seule fois et paramétrée pour concerner toutes les tables liées à celle mis en exerge dans le déclencheur.
-- ce qui n'est pas le cas pour une contrainte de cascade qui dont etre définie à chaque fois.


--3)
--a)
CREATE OR REPLACE TRIGGER TR_Facture
BEFORE DELETE ON FACTURE
FOR EACH ROW
BEGIN
    ---- récupération de la ligne de facture à supprimer
    INSERT INTO old_lg(LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA) SELECT LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA FROM ligne_facture WHERE fac_id = :old.fac_id;
    --récupération de la ligne de facture liée à la facture à supprimer
    INSERT INTO old_fact(FAC_ID ,PMT_CODE ,CLI_ID ,ADR_ID ,FAC_DATE ,FAC_DAT_PMT) VALUES(:old.FAC_ID ,:old.PMT_CODE ,:old.CLI_ID ,:old.ADR_ID ,:old.FAC_DATE ,:old.FAC_DAT_PMT);
    DELETE FROM ligne_facture WHERE fac_id = :old.fac_id;
    --dbms_output.put_line ('Suppression effectuée');
END;
/

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

--c) effectué : confère lignes 38-43 



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
    --dbms_output.put_line ('Insertion effectuée');
END;
/

--suppression trigger
DROP TRIGGER TR_Couchage;

--Suppression de la contarinte VERIF_CHB_COUCHAGE
ALTER TABLE CHAMBRE 
DROP CONSTRAINT VERIF_CHB_COUCHAGE;



--Exercice 3

--1)
--Création du déclencheur TR_planning 
CREATE OR REPLACE TRIGGER TR_planning 
BEFORE INSERT OR UPDATE ON PLANNING
FOR EACH ROW

DECLARE c_chb_couchage   chambre.chb_couchage%TYPE;

BEGIN
    --recuperation du nombre de couchage de la chambre dont l'id corespond à celui que l'on s'apprete à inserer.
    SELECT chb_couchage INTO c_chb_couchage FROM CHAMBRE WHERE CHB_ID = :new.CHB_ID;
    
    IF((:new.PLN_JOUR IS NULL) OR (:new.PLN_JOUR < SYSDATE))
        THEN :new.PLN_JOUR := TRUNC(SYSDATE);
    END IF;
    IF(:new.nb_pers < c_chb_couchage)
        THEN dbms_output.put_line ('Réservation Enregistrée');
        ELSE RAISE_APPLICATION_ERROR (-20011, 'Refusé '|| :new.nb_pers || ' incorrect car supérieur  à ' || c_chb_couchage) ;
    END IF;
    
END;
/

DROP TRIGGER TR_planning;

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(1, TO_DATE('01/01/2020', 'DD/MM/YYYY'), 100, 2);

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(2,null ,100, 2);


--Requete d'affichage pour vérification du déclencheur
SELECT CHB_ID as "Reservation", pln_jour as "Jour réservation"
FROM PLANNING
WHERE CLI_ID = 100
ORDER BY pln_jour DESC;

--2) confère lignes 137-139

--3) Insertions de vérification
--rejeté
INSERT INTO PLANNING(CHB_ID,CLI_ID, NB_PERS)
VALUES(15,100, 15);

--accepté
INSERT INTO PLANNING(CHB_ID, CLI_ID, NB_PERS)
VALUES(15, 100, 2);


--Exercice 4

--a) affichage des agents d'entretien qui sont des femmes.
SELECT AGT_NOM as nom, AGT_PRENOM as prenom, AGT_SALAIRE as salaire
FROM agent_entretien
WHERE agt_sx = 2;

--b) Création du trigger
CREATE OR REPLACE TRIGGER TR_Chambre
BEFORE INSERT OR UPDATE ON CHAMBRE 
FOR EACH ROW
WHEN(new.chb_couchage > 3)

DECLARE C_AGT_ID  chambre.AGT_ID%TYPE;
BEGIN
  :NEW.CHB_BAIN  := 1;
  :NEW.CHB_DOUCHE := 1;
  
  UPDATE AGENT_ENTRETIEN 
    SET AGT_SALAIRE = AGT_SALAIRE * 1.05 
    WHERE AGT_ID = :new.AGT_ID
    AND agt_sx = 2;
    
END;
/

DROP TRIGGER TR_Chambre;

--b) insertions : toutes reussies le salaire de l'agent A02 a changé
INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(21, 22, 5, 'A03');

INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(22, 24, 5, 'A02');

INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(23, 24, 4, 'A02');


--Exercice 5

--1) Afficher le salaire moyen d’un agent d’entretien arrondi à la centaine
SELECT ROUND(AVG(AGT_SALAIRE)) as "Salaire moyen"
FROM AGENT_ENTRETIEN;

--2) 
CREATE OR REPLACE TRIGGER TR_AGENT 
FOR INSERT OR UPDATE ON AGENT_ENTRETIEN

--déclaration des variables à utiliser
COMPOUND TRIGGER
COUNT_AGT  INTEGER;  
G_AGT_SALAIRE AGENT_ENTRETIEN.AGT_SALAIRE%TYPE  := 0;
COMPTEUR_UPDATE INTEGER;

    BEFORE STATEMENT IS 
        BEGIN
            -- compte du nombre d'agents
            SELECT COUNT(AGT_ID) INTO COUNT_AGT  FROM AGENT_ENTRETIEN;
            -- calcul du salaire moyen
            SELECT ROUND(AVG(AGT_SALAIRE)) INTO G_AGT_SALAIRE FROM AGENT_ENTRETIEN;
    END BEFORE STATEMENT;
    BEFORE EACH ROW IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre total d''agents :' || COUNT_AGT);
        --Dans le cas d'une insertion
        IF UPDATING 
            THEN DBMS_OUTPUT.PUT_LINE('Ancien salaire de l''employé :' || :OLD.AGT_SALAIRE);
            COMPTEUR_UPDATE := COMPTEUR_UPDATE + 1;
        END IF;
        -- verification de la condition sur le salaire
        IF :NEW.AGT_SALAIRE < G_AGT_SALAIRE 
            THEN RAISE_APPLICATION_ERROR(-20015, 'Le nouveau salaire ' || :NEW.AGT_SALAIRE  || ' est inférieur à la moyenne ' || G_AGT_SALAIRE);   
        END IF; 
    END BEFORE EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        dbms_output.put_line ('Nombre total de lignes insérées'|| COMPTEUR_UPDATE ); 
    END AFTER STATEMENT;

END TR_AGENT;
/


--3) Tests
--Augmentation de 10 % les agents actuellement en poste
UPDATE AGENT_ENTRETIEN
SET AGT_SALAIRE = 2000;--AGT_SALAIRE * 1.1

--Affectant un salaire de 1000 € aux agents masculins en poste.
UPDATE AGENT_ENTRETIEN
SET AGT_SALAIRE = AGT_SALAIRE * 1.1
WHERE AGT_SX = 1;