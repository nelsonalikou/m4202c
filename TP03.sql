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
nom_agent AGENT_ENTRETIEN.AGT_NOM%TYPE;
BEGIN
    nom_agent := '&nom_agt';
    
    --ACCEPT nom VARCHAR2(25) PROMPT 'Nom de l''agent:  ' ;
    SELECT NVL(COUNT(c.CHB_ID),0) INTO nb_chambres
    FROM CHAMBRE c, AGENT_ENTRETIEN a  
    WHERE c.AGT_ID(+) = a.AGT_ID 
    AND UPPER(a.AGT_NOM) = UPPER(nom_agent);
    
    --Récupération du nom de l'agent
    IF(nb_chambres = 0)
        THEN dbms_output.put_line ( 'Aucune chambre pour l''agent ' || nom_agent );
        ELSE dbms_output.put_line ( 'L''agent ' || nom_agent || ' s''occupe de ' || nb_chambres || ' chambres');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN dbms_output.put_line ( 'Agent ' || nom_agent || ' inexistant' );
END;
/

SELECT NVL(COUNT(c.CHB_ID),0) as "nb chambres"
    FROM CHAMBRE c, AGENT_ENTRETIEN a  
    WHERE c.AGT_ID(+) = a.AGT_ID 
    AND UPPER(a.AGT_NOM) = UPPER('DUSSE');  --FECHOL DUSSE  BEVIERE
    
    
--Exercice 4 Variables %TYPE – Variables de substitution – Exception Oracle prédéfinie 

-- bloc PL/SQL qui, étant donné le nom d’un client saisi au clavier (ACCEPT – PROMPT), affiche son code, son identité (nom, prénom) et sa ville.

accept cli_name prompt 'Please enter your name: ';

--Amélioration lisibilité
SET VERIFY OFF;

declare
   id CLIENT.CLI_ID%TYPE;
   nom CLIENT.CLI_NOM%TYPE;
   prenom CLIENT.CLI_PRENOM%TYPE;
   ville ADRESSE.ADR_VILLE%TYPE;
   name CLIENT.CLI_NOM%TYPE;
   nb INTEGER;
begin
    name := '&cli_name';
    SELECT c.CLI_ID, UPPER(c.CLI_NOM), c.CLI_PRENOM,a.ADR_VILLE, COUNT(c.CLI_ID)
    INTO id, nom, prenom, ville, nb   
    FROM CLIENT c, ADRESSE a
    WHERE c.CLI_ID = a.CLI_ID
    AND UPPER(CLI_NOM) = UPPER('&cli_name') 
    group by c.CLI_ID, UPPER(c.CLI_NOM), c.CLI_PRENOM, a.ADR_VILLE;
    IF(SQL%ROWCOUNT > 1)
    THEN dbms_output.put_line ( 'Attention ! Plusieurs clients nommés ' || name);
    END IF;
    dbms_output.put_line('résultats pour '|| nom);
    
    dbms_output.put_line('le client '|| id || ' ' || prenom || REPLACE(nom,' ','') || ' habite à ' || ville);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN dbms_output.put_line ( 'Désolé, pas de client nommé ' || name);
end;
/

-- Exercice 5 Gestion des EXCEPTIONS, erreurs prédéfinies et non prédéfinies ORACLE

-- a)

accept agt_code prompt 'Please enter the agt code ';

accept date_depart prompt 'Please enter the new departure date: ';

DECLARE
    agt_cod AGENT_ENTRETIEN.AGT_ID%TYPE;
    date_dpt AGENT_ENTRETIEN.AGT_DPT%TYPE;
    nom_agt AGENT_ENTRETIEN.AGT_NOM%TYPE;
  
Begin
    
    agt_cod := '&agt_code';
    date_dpt := TO_DATE('&date_depart', 'DD/MM/YYYY');
    
    
    SELECT AGT_NOM
    INTO nom_agt    
    FROM AGENT_ENTRETIEN
    WHERE AGT_ID = agt_cod;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN dbms_output.put_line ( 'L''agent ' || agt_cod || ' n''existe pas' );
    
    UPDATE AGENT_ENTRETIEN
    SET AGT_DPT = date_dpt
    WHERE AGT_ID = agt_cod;
    dbms_output.put_line('L''agent a été modifié');

    WHEN OTHERS 
    THEN raise_application_error(-20020,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end;
/


-- Test
--AGT_ID = A08 : error agent inexistant
--AGT_ID = A05 et AGT_DPT = 01/15/2021 : error ce n'est pas un mois valide 
-- puis avec AGT_DPT 01/06/2021 - Success


-- b)

accept agt_code prompt 'Please enter the agt code ';

accept date_depart prompt 'Please enter the new departure date: ';

DECLARE
    agt_cod AGENT_ENTRETIEN.AGT_ID%TYPE;
    date_dpt AGENT_ENTRETIEN.AGT_DPT%TYPE;
    nom_agt AGENT_ENTRETIEN.AGT_NOM%TYPE;
    
    --Prise en charge de l'erreur due à la contrainte verif_agt_dpt
    e_verif_agt_dpt exception;
    pragma exception_init(e_verif_agt_dpt, -6502);
  
Begin
    
    agt_cod := '&agt_code';
    date_dpt := TO_DATE('&date_depart', 'DD/MM/YYYY');
    
    
    SELECT AGT_NOM
    INTO nom_agt    
    FROM AGENT_ENTRETIEN
    WHERE AGT_ID = agt_cod;

    UPDATE AGENT_ENTRETIEN
    SET AGT_DPT = date_dpt
    WHERE AGT_ID = agt_cod;
    IF (SQL%ROWCOUNT > 0)
        THEN dbms_output.put_line('L''agent a été modifié');
    ELSE dbms_output.put_line ( 'L''agent ' || agt_cod || ' n''existe pas' );
    END IF;
EXCEPTION
    WHEN e_verif_agt_dpt
    THEN dbms_output.put_line ( 'La date de départ de l’agent ne peut pas être inférieure à Sa date d’embauche.' );
end;
/


-- Test
--AGT_ID = A08 : error agent inexistant
--AGT_ID = A05 et AGT_DPT = 01/15/2021 : error ce n'est pas un mois valide 
-- puis avec AGT_DPT 01/06/2021 - Success


--c) contrainte qui vérifie que la date de départ est bien supérieure à la date d’embauche
ALTER TABLE AGENT_ENTRETIEN ADD CONSTRAINT verif_agt_dpt CHECK(AGT_DPT > AGT_EMB);

--Test
--AGT_ID = A05 et AGT_DPT = '20/10/1998' 
--Résultat violation de la contrainte verif_agt_dpt





-- Exercice 6 
accept v_chb_id  prompt 'Please enter the CHB_ID ';

accept v_agt_id prompt 'Please enter the new agent name : ';

DECLARE
    chb_code CHAMBRE.CHB_ID%TYPE;
    agt_code AGENT_ENTRETIEN.AGT_ID%TYPE;
    agt_name AGENT_ENTRETIEN.AGT_NOM%TYPE;
  
Begin
    
    chb_code := '&v_chb_id';
    agt_code := '&v_agt_id';
    
    SELECT agt_nom
    INTO agt_name
    FROM CHAMBRE c
    WHERE c.CHB_ID = chb_cod;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN dbms_output.put_line ( 'La chambre ' || chb_code || ' n''existe pas' );    
    
    UPDATE CHAMBRE
    SET AGT_ID = date_dpt
    WHERE AGT_ID = agt_cod;
    dbms_output.put_line('Modification effectuée : L''agent' || agt_code || ' est affecté à la chambre ' || chb_code);

    WHEN OTHERS 
    THEN raise_application_error(-20020,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end;
/
