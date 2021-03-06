--Exercice 2

--1)
DELETE FROM TRF_CHB ;
DELETE FROM PLANNING ;
DELETE FROM CHAMBRE ;
DELETE FROM AGENT_ENTRETIEN ;
DELETE FROM TELEPHONE ;
DELETE FROM TYPE ;
DELETE FROM EMAIL ;
DELETE FROM LIGNE_FACTURE ;
DELETE FROM FACTURE ;
DELETE FROM MODE_PAIEMENT ;
DELETE FROM ADRESSE ;
DELETE FROM CLIENT ;
DELETE FROM TITRE ;




INSERT INTO TITRE (TIT_CODE ,
TIT_LIB)
SELECT TIT_CODE ,
TIT_LIB
FROM HOTEL.TITRE;


INSERT INTO TYPE(TYP_CODE ,
TYP_LIB)
SELECT TYP_CODE ,
TYP_LIB 
FROM HOTEL.TYPE;


INSERT INTO CLIENT (CLI_ID,TIT_CODE,CLI_NOM,CLI_PRENOM,CLI_ENSEIGNE)
SELECT CLI_ID ,TIT_CODE ,CLI_NOM ,CLI_PRENOM ,CLI_ENSEIGNE  
FROM HOTEL.CLIENT;

INSERT INTO TELEPHONE (TEL_ID ,
CLI_ID ,
TYP_CODE ,
TEL_NUMERO ,
TEL_LOCALISATION)
SELECT TEL_ID ,
CLI_ID ,
TYP_CODE ,
TEL_NUMERO ,
TEL_LOCALISATION 
FROM HOTEL.TELEPHONE;


INSERT INTO EMAIL (EML_ID ,
CLI_ID ,
EML_ADRESSE ,
EML_LOCALISATION)
SELECT EML_ID ,
CLI_ID ,
EML_ADRESSE ,
EML_LOCALISATION 
FROM HOTEL.EMAIL;

INSERT INTO ADRESSE (CLI_ID ,
ADR_ID ,
ADR_LIGNE1 ,
ADR_LIGNE2 ,
ADR_LIGNE3 ,
ADR_LIGNE4 ,
ADR_CP ,
ADR_VILLE )
SELECT CLI_ID ,
ADR_ID ,
ADR_LIGNE1 ,
ADR_LIGNE2 ,
ADR_LIGNE3 ,
ADR_LIGNE4 ,
ADR_CP ,
ADR_VILLE  
FROM HOTEL.ADRESSE;

INSERT INTO MODE_PAIEMENT (PMT_CODE ,
PMT_LIB )
SELECT PMT_CODE ,
PMT_LIB 
FROM HOTEL.MODE_PAIEMENT;


INSERT INTO FACTURE (FAC_ID ,
PMT_CODE ,
CLI_ID ,
ADR_ID ,
FAC_DATE ,
FAC_DAT_PMT )
SELECT FAC_ID ,
PMT_CODE ,
CLI_ID ,
ADR_ID ,
FAC_DATE ,
FAC_DAT_PMT 
FROM HOTEL.FACTURE
WHERE EXTRACT(YEAR FROM FAC_DATE) >= 2007;

INSERT INTO LIGNE_FACTURE (LIF_ID ,
FAC_ID ,
QTE ,
REMISE_POURCENT ,
REMISE_MNT ,
MNT ,
TAUX_TVA )
SELECT l.LIF_ID ,
l.FAC_ID ,
l.QTE ,
l.REMISE_POURCENT ,
l.REMISE_MNT ,
l.MNT ,
l.TAUX_TVA 
FROM HOTEL.LIGNE_FACTURE l, HOTEL.FACTURE f
WHERE l.FAC_ID = f.FAC_ID
AND EXTRACT(YEAR FROM f.FAC_DATE) >= 2007;


INSERT INTO AGENT_ENTRETIEN (AGT_ID ,
AGT_NOM ,
AGT_PRENOM ,
AGT_SX ,
AGT_DNAIS ,
AGT_EMB ,
AGT_DPT ,
AGT_SALAIRE )
SELECT AGT_ID ,
AGT_NOM ,
AGT_PRENOM ,
AGT_SX ,
AGT_DNAIS ,
AGT_EMB ,
AGT_DPT ,
AGT_SALAIRE 
FROM HOTEL.AGENT_ENTRETIEN;


INSERT INTO CHAMBRE (CHB_ID ,
CHB_COMMUNIQUE ,
CHB_NUMERO ,
CHB_ETAGE ,
CHB_BAIN ,
CHB_DOUCHE ,
CHB_WC ,
CHB_COUCHAGE ,
CHB_POSTE_TEL ,
AGT_ID )
SELECT CHB_ID ,
CHB_COMMUNIQUE ,
CHB_NUMERO ,
CHB_ETAGE ,
CHB_BAIN ,
CHB_DOUCHE ,
CHB_WC ,
CHB_COUCHAGE ,
CHB_POSTE_TEL ,
AGT_ID 
FROM HOTEL.CHAMBRE;


INSERT INTO TRF_CHB (CHB_ID ,
TRF_DATE_DEBUT ,
TRF_CHB_PRIX)
SELECT CHB_ID ,
TRF_DATE_DEBUT ,
TRF_CHB_PRIX 
FROM HOTEL.TRF_CHB
WHERE EXTRACT(YEAR FROM TRF_DATE_DEBUT) >= 2007;



INSERT INTO PLANNING(CHB_ID ,
PLN_JOUR ,
CLI_ID ,
NB_PERS )
SELECT CHB_ID ,
PLN_JOUR ,
CLI_ID ,
NB_PERS 
FROM HOTEL.PLANNING
WHERE EXTRACT(YEAR FROM PLN_JOUR) >= 2007;


--2)
INSERT INTO TRF_CHB (CHB_ID ,TRF_DATE_DEBUT ,TRF_CHB_PRIX)
SELECT CHB_ID ,TO_DATE('01/01/2014', 'DD/MM/YYYY') ,ROUND(TRF_CHB_PRIX * 1.1) 
FROM HOTEL.TRF_CHB
WHERE EXTRACT(YEAR FROM TRF_DATE_DEBUT) >= 2007;

--3)
--Requete de suppression de la table Tarif
DROP TABLE TARIF CASCADE CONSTRAINTS;

--Cr?ation de la table TARIF
/*==============================================================*/
/* Table : TARIF                                              					*/
/*==============================================================*/
create table TARIF AS (
    SELECT TRF_DATE_DEBUT, TRF_TAUX_TAXES,TRF_PETIT_DEJ
    FROM HOTEL.TARIF
    WHERE EXTRACT(YEAR FROM TRF_DATE_DEBUT) > 2004
)
/

-- Suppression des donn?es de la table Tarif
--DELETE FROM TARIF ;

--AJout de la cl? primaire
ALTER TABLE TARIF ADD CONSTRAINT PK_TARIF PRIMARY KEY (TRF_DATE_DEBUT);

--Insertion des contraintes sur TRF_DATE_DEBUT dans la table TRF_CHB
ALTER TABLE TRF_CHB ADD CONSTRAINT FK_TRF_CHB_TARIF FOREIGN KEY (TRF_DATE_DEBUT) references TARIF (TRF_DATE_DEBUT) ON DELETE CASCADE;

--ALTER TABLE TRF_CHB ADD CONSTRAINT PK_TRF_CHB PRIMARY KEY (CHB_ID,TRF_DATE_DEBUT);
