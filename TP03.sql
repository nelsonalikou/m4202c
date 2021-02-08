SET SERVEROUTPUT ON;

--Exercice 1 Bloc PL/SQL –  package DBMS_OUTPUT

-- Affichage de Bonjour suivi de la date du jour. 
-- retrait des espaces inutiles à l'aide de la fonction REPALCE
BEGIN 
    dbms_output.put_line ('Bonjour !');
    dbms_output.put_line ('Aujourd’hui, nous sommes le '  || REPLACE(REPLACE(TO_CHAR(SYSDATE,'Day DD Month YYYY'),'  ',' '),'  ',' '));
END;
/

--Exercice 2 Bloc PL/SQL,  package DBMS_OUTPUT, SELECT .. INTO..

--a) affichage de la dernière réservation ayant eu lieu en PL/SQL
DECLARE 
last_insertion_name PLANNING.PLN_JOUR%TYPE;
BEGIN 
    SELECT MAX(PLN_JOUR) INTO last_insertion_name  FROM PLANNING WHERE PLN_JOUR <= SYSDATE;
    dbms_output.put_line ('La dernière réservation a eu lieu le '  || REPLACE(REPLACE(TO_CHAR(last_insertion_name,'Day DD Month YYYY'),'  ',' '),'  ',' '));
END;
/

--b) Insertion des données dans  table planning
INSERT INTO PLANNING (CHB_ID, PLN_JOUR, CLI_ID, NB_PERS) VALUES
(1,TO_DATE('01/03/2021', 'DD/MM/YYYY'),100,2);
INSERT INTO PLANNING (CHB_ID, PLN_JOUR, CLI_ID, NB_PERS) VALUES
(1,TO_DATE(SYSDATE - 1, 'DD/MM/YYYY'),100,2);
INSERT INTO PLANNING (CHB_ID, PLN_JOUR, CLI_ID, NB_PERS) VALUES
(2,TO_DATE(SYSDATE - 1, 'DD/MM/YYYY'),100,2);


--Exercice 3 Variables %TYPE – SELECT .. INTO... – structure conditionnelle (IF)

-- Bloc PL/SQL qui affiche le nombre de chambres entretenues par un agent d’entretien dont le nom est saisi par l’utilisateur. &mois


DECLARE 
nb_chambres INTEGER;
nom_agt AGENT_ENTRETIEN.AGT_NOM%TYPE;
BEGIN 
    --ACCEPT nom VARCHAR2(25) PROMPT 'Nom de l''agent:  ' ;
    SELECT NVL2(COUNT(CHB_ID),0, COUNT(CHB_ID)) INTO nb_chambres  FROM CHAMBRE WHERE AGT_ID = (SELECT AGT_ID FROM AGENT_ENTRETIEN WHERE UPPER(AGT_NOM) = UPPER('&nom_agt'));
    dbms_output.put_line ( nb_chambres );
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN dbms_output.put_line ( 'Agent ' || nom_agt || ' inexistant' );
END;
/


