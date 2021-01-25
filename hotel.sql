/*==============================================================*/
/* Nom de la base :  HOTEL                              					*/
/* Nom de SGBD :  ORACLE 			  	        	          */
/*==============================================================*/


DROP TABLE AGENT_ENTRETIEN CASCADE CONSTRAINTS;
DROP TABLE CHAMBRE CASCADE CONSTRAINTS;
DROP TABLE TITRE CASCADE CONSTRAINTS;
DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE EMAIL CASCADE CONSTRAINTS;
DROP TABLE TYPE CASCADE CONSTRAINTS;
DROP TABLE TELEPHONE CASCADE CONSTRAINTS;
DROP TABLE ADRESSE CASCADE CONSTRAINTS;
DROP TABLE MODE_PAIEMENT CASCADE CONSTRAINTS;
DROP TABLE FACTURE CASCADE CONSTRAINTS;
DROP TABLE LIGNE_FACTURE CASCADE CONSTRAINTS;
DROP TABLE PLANNING CASCADE CONSTRAINTS;
DROP TABLE TRF_CHB CASCADE CONSTRAINTS;



/*==============================================================*/
/* Table : AGENT_ENTRETIEN                                     				 */
/*==============================================================*/
create table AGENT_ENTRETIEN  (
   AGT_ID           CHAR(3) 
		CONSTRAINT pk_agt PRIMARY KEY ,
   AGT_NOM          VARCHAR2(25),
   AGT_PRENOM       VARCHAR2(15),
   AGT_SX           CHAR(1) 
		CONSTRAINT chk_AGT_sx CHECK (AGT_SX IN ('1','2')),
   AGT_DNAIS	  	DATE,
   AGT_EMB          DATE 	DEFAULT SYSDATE,
   AGT_DPT          DATE,
   AGT_SALAIRE      FLOAT
)
/

/*==============================================================*/
/* Table : CHAMBRE                                              					*/
/*==============================================================*/
create table CHAMBRE  (
   CHB_ID               INTEGER
        CONSTRAINT PK_CHAMBRE primary key,
   CHB_COMMUNIQUE       INTEGER,
   AGT_ID				CHAR(3),
   CHB_NUMERO           SMALLINT
        CONSTRAINT chk_CHB_NUMERO CHECK (CHB_NUMERO != 13 ),
   CHB_ETAGE            CHAR(3)
        CONSTRAINT chk_CHB_ETAGE CHECK (CHB_ETAGE IN ('RDC','1er','2e')),
   CHB_BAIN             SMALLINT
        CONSTRAINT chk_CHB_BAIN CHECK (CHB_BAIN IN (0,1)),
   CHB_DOUCHE           SMALLINT,
   CHB_WC               SMALLINT
        CONSTRAINT chk_CHB_WC CHECK (CHB_WC IN (0,1)),
   CHB_POSTE_TEL        CHAR(3),
   CHB_COUCHAGE         SMALLINT,
   --CONSTRAINT POSTE_TEL_CHECK  CHECK (SUBSTR(CHB_POSTE_TEL, 1, CHAR_LENGTH(CHB_POSTE_TEL) - 1) = CONVERT(char(2),CHB_ID))
   CONSTRAINT POSTE_TEL_CHECK CHECK (SUBSTR(CHB_POSTE_TEL, 2) = CHB_ID)
)
/

/*==============================================================*/
/* Table : TITRE                                                					*/
/*==============================================================*/
create table TITRE  (
   TIT_CODE             CHAR(8),
   constraint PK_TITRE primary key(TIT_CODE),
   TIT_LIB              VARCHAR2(32)
)
/

/*==============================================================*/
/* Table : CLIENT                                               					*/
/*==============================================================*/
create TABLE CLIENT  (
   CLI_ID               INTEGER
		constraint PK_CLIENT primary key,
   TIT_CODE             CHAR(8)
    	constraint FK_CLIENT_TITRE references TITRE (TIT_CODE),
   CLI_NOM              CHAR(32),
   CLI_PRENOM           VARCHAR2(25),
   CLI_ENSEIGNE         VARCHAR2(100)
)
/

/*==============================================================*/
/* Table : EMAIL                                               					*/
/*==============================================================*/
create TABLE EMAIL  (
   EML_ID               INTEGER                         not null
        constraint PK_EMAIL primary key,
   CLI_ID               INTEGER
		constraint FK_EMAIL_CLI_ID references CLIENT (CLI_ID),
   EML_ADRESSE           VARCHAR2(64)                   not null
        CONSTRAINT chk_EML_ADRESSE CHECK (EML_ADRESSE LIKE '%@%.%'),
   EML_LOCALISATION         VARCHAR2(20)
        CONSTRAINT chk_EML_LOCALISATION CHECK (EML_LOCALISATION IN ('domicile','bureau'))
)
/

/*==============================================================*/
/* Table : TYPE                                                					 */
/*==============================================================*/
create table "TYPE"  (
   TYP_CODE             CHAR(8)   						not null
		constraint PK_TYPE primary key ,
   TYP_LIB              VARCHAR2(32)
)
/

/*==============================================================*/
/* Table : TELEPHONE                                           					 */
/*==============================================================*/
create table TELEPHONE  (
   TEL_ID               INTEGER                          not null
        constraint PK_TELEPHONE primary key ,
   CLI_ID               INTEGER                          not null
        constraint FK_TEL_CLIENT references CLIENT (CLI_ID),
   TYP_CODE             CHAR(8)                          not null
        constraint FK_TEL_TYPE references "TYPE" (TYP_CODE),
   TEL_NUMERO           CHAR(20),
   TEL_LOCALISATION     VARCHAR2(20)
)
/

/*==============================================================*/
/* Table : ADRESSE                                              					*/
/*==============================================================*/
create table ADRESSE  (
   CLI_ID               INTEGER                          not null
        CONSTRAINT FK_ADRESSE_CLIENT references CLIENT (CLI_ID),
   ADR_ID               INTEGER                          not null,
   ADR_LIGNE1           VARCHAR2(32),
   ADR_LIGNE2           VARCHAR2(32),
   ADR_LIGNE3           VARCHAR2(32),
   ADR_LIGNE4           VARCHAR2(32),
   ADR_CP               CHAR(5),
   ADR_VILLE            CHAR(32),
   CONSTRAINT PK_ADRESSE primary key (CLI_ID, ADR_ID)
)
/

/*==============================================================*/
/* Table : MODE_PAIEMENT                                       				 */
/*==============================================================*/
create table MODE_PAIEMENT  (
   PMT_CODE             CHAR(8)
			constraint PK_MODE_PAIEMENT primary key,
   PMT_LIB              VARCHAR2(64)
)
/

/*==============================================================*/
/* Table : FACTURE                                              					*/
/*==============================================================*/
create table FACTURE  (
   FAC_ID               INTEGER                          not null
        CONSTRAINT PK_FACTURE primary key,
   PMT_CODE             CHAR(8)
        CONSTRAINT FK_FACTURE_MODE_PAIEMENT references MODE_PAIEMENT (PMT_CODE),
   CLI_ID               INTEGER                          not null,
   ADR_ID               INTEGER                          not null,
   FAC_DATE             DATE,
   FAC_DAT_PMT          DATE,
   CONSTRAINT FK_FACTURE_ADRESSE foreign key (CLI_ID, ADR_ID)
         references ADRESSE (CLI_ID, ADR_ID),
   CONSTRAINT FK_FAC_DAT_PMT CHECK (FAC_DAT_PMT > FAC_DATE)
)
/

/*==============================================================*/
/* Table : LIGNE_FACTURE                                       				 */
/*==============================================================*/
create table LIGNE_FACTURE  (
   LIF_ID               INTEGER                         
		constraint PK_LIGNE_FACTURE primary key,
   FAC_ID               INTEGER  not null
		constraint FK_LIGNE_FACTURE references FACTURE (FAC_ID),
   QTE                  NUMBER,
   REMISE_POURCENT      NUMBER
		CONSTRAINT CK_LIGNE_FACTURE CHECK (REMISE_POURCENT BETWEEN 0 AND 100),
   REMISE_MNT           NUMBER(8,2),
   MNT                  NUMBER(8,2),
   TAUX_TVA             NUMBER 
)
/

/*==============================================================*/
/* Table : PLANNING                                             					*/
/*==============================================================*/
create table PLANNING  (
   CHB_ID               INTEGER                          not null
        CONSTRAINT FK_PLANNING_CHAMBRE references CHAMBRE (CHB_ID),
   PLN_JOUR             DATE                             not null,
   CLI_ID               INTEGER                          not null
		CONSTRAINT FK_PLANNING_CLIENT references CLIENT (CLI_ID),
   NB_PERS              SMALLINT,
        CONSTRAINT PK_PLANNING primary key (CHB_ID, PLN_JOUR)
)
/

/*==============================================================*/
/* Table : TRF_CHB                                              					*/
/*==============================================================*/
-- la contrainte PK_TRF_CHB de la table TRF_CHB ne peut pas etre définie car  TRF_DATE_DEBUT  est clé primaire de la table  Tarif qui n'as pas encore été définie 
create table TRF_CHB  (
   CHB_ID               INTEGER                          not null
        CONSTRAINT FK_TRF_CHB_CHAMBRE references CHAMBRE (CHB_ID),
   TRF_DATE_DEBUT       DATE                             not null,
   TRF_CHB_PRIX         NUMBER(8,2)
      --CONSTRAINT PK_TRF_CHB primary key (CHB_ID, TRF_DATE_DEBUT)
)
/


/*==============================================================*/
/* Crï¿½ation des INDEX sur clï¿½ ï¿½trangï¿½res                        			*/
/*==============================================================*/

create index I_ADR on ADRESSE (CLI_ID ASC);

create index I_PLAN_CHB_ID on PLANNING (CHB_ID ASC);
create index I_PLAN_CLI_ID on PLANNING (CLI_ID ASC);

create index I_FACT_PMT_CODE on FACTURE (PMT_CODE ASC);
create index I_FACT_CLI_ADR on FACTURE (CLI_ID ASC, ADR_ID ASC);

create index I_LIG_FACT on LIGNE_FACTURE (FAC_ID ASC);

create index I_TEL_CLI_ID on TELEPHONE (CLI_ID ASC);
create index I_TEL_TYP_CODE on TELEPHONE (TYP_CODE ASC);

create index I_CLIENT ON CLIENT (TIT_CODE ASC);




