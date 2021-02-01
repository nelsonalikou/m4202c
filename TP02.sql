--Exercice 1

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
    dbms_output.put_line ('Suppression effectu�e');
END;






