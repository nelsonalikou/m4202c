--Exercice 1

SET SERVEROUTPUT ON;

--1) Requete de s�lection
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
--a) Requete suppression de la facture n�1476
DELETE FROM facture
WHERE fac_id = 1476;






--b) Cr�ation des tables OLD_FACT et OLD_LG
--Cr�ation de la table OLD_FACT
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

--Cr�ation de la table OLD_LG
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
--Suppression impossible car violerait la contrainte de cl��trang�s. Des enregistrements li�s � cette cl� primaire sont pr�sents dans d'autres tables

--Les solutions possibles sont l'ajout de contrainte de cascade ou d'un d�clencheur.
--La solution pr�f�rable est l'ajout d'un d�clencheur car elle peut etre definie une seule fois et param�tr�e pour concerner toutes les tables li�es � celle mis en exerge dans le d�clencheur.
-- ce qui n'est pas le cas pour une contrainte de cascade qui dont etre d�finie � chaque fois.
--3)
 
CREATE OR REPLACE TRIGGER TR_Facture
BEFORE DELETE ON FACTURE
FOR EACH ROW
BEGIN
    ---- r�cup�ration de la ligne de facture � supprimer
    INSERT INTO old_lg(LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA) SELECT LIF_ID ,FAC_ID ,QTE ,REMISE_POURCENT ,REMISE_MNT ,MNT ,TAUX_TVA FROM ligne_facture WHERE fac_id = :old.fac_id;
    --r�cup�ration de la ligne de facture li�e � la facture � supprimer
    INSERT INTO old_fact(FAC_ID ,PMT_CODE ,CLI_ID ,ADR_ID ,FAC_DATE ,FAC_DAT_PMT) VALUES(:old.FAC_ID ,:old.PMT_CODE ,:old.CLI_ID ,:old.ADR_ID ,:old.FAC_DATE ,:old.FAC_DAT_PMT);
    DELETE FROM ligne_facture WHERE fac_id = :old.fac_id;
    --dbms_output.put_line ('Suppression effectu�e');
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
--Cr�ation du d�clencheur TR_couchage
CREATE OR REPLACE TRIGGER TR_Couchage
BEFORE INSERT ON CHAMBRE
FOR EACH ROW
WHEN((new.chb_couchage not  between 1 and 5) OR (new.chb_couchage IS NULL))
BEGIN
    :new.CHB_COUCHAGE := 2;
    --dbms_output.put_line ('Insertion effectu�e');
END;
/

DROP TRIGGER TR_Couchage;

--Suppression de la contarinte VERIF_CHB_COUCHAGE
ALTER TABLE CHAMBRE 
DROP CONSTRAINT VERIF_CHB_COUCHAGE;


--Exercice 3

--1)
--Cr�ation du d�clencheur TR_planning 
CREATE OR REPLACE TRIGGER TR_planning 
BEFORE INSERT OR UPDATE ON PLANNING
FOR EACH ROW

DECLARE c_chb_couchage   chambre.chb_couchage%TYPE;

BEGIN
    --recuperation du nombre de couchage de la chambre dont l'id corespond � celui que l'on s'apprete � inserer.
    SELECT chb_couchage INTO c_chb_couchage FROM CHAMBRE WHERE CHB_ID = :new.CHB_ID;
    
    IF((:new.PLN_JOUR IS NULL) OR (:new.PLN_JOUR < SYSDATE))
        THEN :new.PLN_JOUR := SYSDATE;
    END IF;
    IF(:new.nb_pers < c_chb_couchage)
        THEN dbms_output.put_line ('R�servation Enregistr�e');
        ELSE RAISE_APPLICATION_ERROR (-20011, 'Refus� '|| :new.nb_pers || ' incorrect car sup�rieur  � ' || c_chb_couchage) ;
    END IF;
    
END;
/

DROP TRIGGER TR_planning;

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(1, TO_DATE('01/01/2020', 'DD/MM/YYYY'), 100, 2);

INSERT INTO PLANNING(CHB_ID, PLN_JOUR, CLI_ID, NB_PERS)
VALUES(2,null ,100, 2);


--Requete d'affichage pour v�rification du d�clencheur
SELECT CHB_ID as "Reservation", pln_jour as "Jour r�servation"
FROM PLANNING
WHERE CLI_ID = 100
ORDER BY pln_jour DESC;


--3)
--rejet�
INSERT INTO PLANNING(CHB_ID,CLI_ID, NB_PERS)
VALUES(15,100, 15);

--accept�
INSERT INTO PLANNING(CHB_ID, CLI_ID, NB_PERS)
VALUES(15, 100, 2);


--Exercice 4

--a) affichage des agents d'entretien qui sont des femmes.
SELECT AGT_NOM, AGT_PRENOM, AGT_SALAIRE
FROM agent_entretien
WHERE agt_sx = 2;

--b)
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

--insertions
INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(21, 22, 5, 'A03');

INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(22, 24, 5, 'A02');

INSERT INTO CHAMBRE(CHB_ID, CHB_NUMERO, CHB_COUCHAGE, AGT_ID )
VALUES(23, 24, 4, 'A02');



