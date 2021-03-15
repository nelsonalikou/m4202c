SET SERVEROUTPUT ON;


-- Exercice 1 : Gestion des EXCEPTIONS 

--  bloc PLSQL qui insère une réservation d’un client dans le planning 
SET VERIFY OFF

accept v_cli_id prompt 'Please enter the client code : ';

accept v_chb_id  prompt 'Please enter the CHB_ID ';

accept v_nb_pers  prompt 'Please enter the number of person ';

DECLARE
    chb_code CHAMBRE.CHB_ID%TYPE;
    cli_code CLIENT.CLI_ID%TYPE;
    nb_pers_chb INTEGER;
    x_1 INTEGER;
    x_2 INTEGER;
    -- gestion de l'erreur dans le cas où il y a plus de personnes qu'autorisé.
    E_TR_PLANNING exception;
    pragma exception_init(E_TR_PLANNING, -20011);
Begin
    
    chb_code := &v_chb_id;
    cli_code := &v_cli_id;
    nb_pers_chb := &v_nb_pers;     
        
         -- Vérification existance de la chambre
    BEGIN
        SELECT CHB_ID  INTO x_1
            FROM CHAMBRE
            WHERE CHB_ID = &v_chb_id;
        BEGIN
            --Récupération du nombre de chambres de l'agent
            SELECT CLI_ID
                INTO x_2               
                FROM CLIENT
                WHERE CLI_ID = &v_cli_id;
            
            BEGIN
                    
                --Insertion de la réservation pour le client dans la table planning
                INSERT INTO PLANNING (CHB_ID,CLI_ID,NB_PERS)
                VALUES(chb_code,cli_code,nb_pers_chb);
                dbms_output.put_line('Insertion effectuée : Le client ' || cli_code || ' a réservé la chambre ' || chb_code || ' pour ' || nb_pers_chb || ' personnes');
                    
                EXCEPTION
                    WHEN E_TR_PLANNING
                        THEN  dbms_output.put_line('Trop de personnes pour cette chambre');
                    WHEN DUP_VAL_ON_INDEX
                        THEN    UPDATE PLANNING 
                                SET nb_pers = nb_pers_chb
                                WHERE CHB_ID = chb_code
                                AND CLI_ID = cli_code;
                                dbms_output.put_line('modification éffectuée');
                    WHEN OTHERS 
                        THEN raise_application_error(-20025,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
                        --THEN dbms_output.put_line( 'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM ) ;
    
            END;
            EXCEPTION
                WHEN NO_DATA_FOUND
                    THEN dbms_output.put_line ( 'le client ' || cli_code || 'n''existe pas' );
                    
        END;
        -- Exception lancee par le premier select lorsque la chambre est inexistante
        EXCEPTION 
            WHEN NO_DATA_FOUND
                THEN dbms_output.put_line ( 'La chambre ' || chb_code || ' n''existe pas' ) ;
           
    END;
    
end;
/



-- tests
--cli_id chb_id nb_pers : result
-- 100 2 2 : success
-- 200 2 2 : client inconnu
-- 100 50 2 : chambre inconnue
-- 100 2 15 : nbpers incorrect
-- 100 2 1 : violation FK_PLANNING

--Vérification des insertion 
--requête qui liste les réservations du client 100 faites en 2020

SELECT CLI_ID, CHB_ID
FROM PLANNING
WHERE EXTRACT(YEAR FROM PLN_JOUR) = 2021;



--Exercice 2 : Curseurs
--1) Version 1 
accept v_date prompt 'Please enter the date : ';

accept v_agt_id  prompt 'Please enter the agent id ';



DECLARE
CURSOR agt_cur IS SELECT ch.CHB_ID, chb_couchage FROM CHAMBRE ch, AGENT_ENTRETIEN ag, PLANNING pl WHERE ch.AGT_ID = ag.AGT_ID AND ag.AGT_ID = '&v_agt_id' AND ch.CHB_ID = pl.CHB_ID AND PLN_JOUR = TO_DATE('&v_date', 'DD/MM/YYYY'); 
v_chb_id CHAMBRE.CHB_ID%TYPE;
v_chb_couchage CHAMBRE.chb_couchage%TYPE;
v_dates planning.pln_jour%TYPE;
v_agt_ids AGENT_ENTRETIEN.AGT_ID%TYPE;


BEGIN
    v_dates := '&v_date';
    v_agt_ids := '&v_agt_id';
    
    -- Récupération de l'agent avec erreur si il n'existe pas
    SELECT agt_id INTO v_agt_ids
    FROM agent_entretien
    WHERE agt_id = v_agt_ids;
    
    dbms_output.put_line ('Planning du ' || v_dates || ' pour l''agent ' || v_agt_ids || ' :');
    OPEN agt_cur;
    LOOP   
        FETCH agt_cur INTO v_chb_id,v_chb_couchage;
        EXIT WHEN (agt_cur%NOTFOUND);
        dbms_output.put_line ('Chambre N° ' || v_chb_id || ' avec ' || v_chb_couchage || ' couchages.');
    END LOOP;
    IF agt_cur%ROWCOUNT = 0 
        THEN dbms_output.put_line ('Pas de chambre pour cet agent le ' || v_dates );
    ELSE
         dbms_output.put_line ('Le nombre de chambre(s) de l''agent' || v_agt_ids || ' est : ' || agt_cur%ROWCOUNT );
    END IF;
    IF agt_cur%NOTFOUND
        THEN dbms_output.put_line ('Agent Inexistant');
    END IF;
    CLOSE agt_cur;
    
    EXCEPTION 
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Agent inexistant');
	WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erreur : '||SQLCODE||'-'||SQLERRM);
END;
/


--2) avec une boucle for


accept v_date prompt 'Please enter the date : ';

accept v_agt_id  prompt 'Please enter the agent id ';



DECLARE

CURSOR agt_cur IS SELECT ch.CHB_ID, chb_couchage FROM CHAMBRE ch, AGENT_ENTRETIEN ag, PLANNING pl WHERE ch.AGT_ID = ag.AGT_ID AND ag.AGT_ID = '&v_agt_id' AND ch.CHB_ID = pl.CHB_ID AND PLN_JOUR = TO_DATE('&v_date', 'DD/MM/YYYY'); 
v_chb_id CHAMBRE.CHB_ID%TYPE;
v_chb_couchage CHAMBRE.chb_couchage%TYPE;
v_dates planning.pln_jour%TYPE;
v_agt_ids AGENT_ENTRETIEN.AGT_ID%TYPE;
nb_ch INTEGER :=0;

BEGIN
    v_dates := '&v_date';
    v_agt_ids := '&v_agt_id';
    
    -- Récupération de l'agent avec erreur si il n'existe pas
    SELECT agt_id INTO v_agt_ids
    FROM agent_entretien
    WHERE agt_id = v_agt_ids;
    
    
    FOR x IN ( SELECT ch.CHB_ID, chb_couchage FROM CHAMBRE ch, AGENT_ENTRETIEN ag, PLANNING pl WHERE ch.AGT_ID = ag.AGT_ID AND ag.AGT_ID = '&v_agt_id' AND ch.CHB_ID = pl.CHB_ID AND PLN_JOUR = TO_DATE('&v_date', 'DD/MM/YYYY'))
    
    LOOP
        dbms_output.put_line ('Chambre N° ' || v_chb_id || ' avec ' || v_chb_couchage || ' couchages.');
        nb_ch := nb_ch + 1;
    END LOOP;
    
    IF nb_ch != 0
        THEN dbms_output.put_line ('Le nombre de chambre(s) de l''agent' || v_agt_ids || ' est : ' || nb_ch );
        ELSE dbms_output.put_line ('Pas de chambre pour cet agent le ' || v_dates );
    END IF;
 
    EXCEPTION 
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Agent inexistant');
	WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erreur : '||SQLCODE||'-'||SQLERRM);
END;
/



--Exercice 3 Curseurs et exceptions

-- 1) bloc  PL/SQL  qui  affiche  pour  un  type  de  téléphone  et  un  client  (numéro)  donnés,  la  liste  desnuméros de téléphone correspondant


accept v_phone_type prompt 'Please enter the phone type : ';

accept v_cli_id  prompt 'Please enter the customer id ';


DECLARE 

v_type TYPE.v_phone_type%TYPE := '&type';
v_cli 	CLIENT.v_cli_id%TYPE := '&clt';
nb_num INTEGER := 0;  
err_int EXCEPTION;

BEGIN
    --Verification existance tu type téléphone
    SELECT typ_code INTO v_type FROM TYPE WHERE typ_code = v_type;
    
    BEGIN 
        --Vérification existance client
        SELECT CLI_ID INTO v_cli FROM CLIENT WHERE cli_id = v_cli;
        
        FOR X IN (SELECT tel_numero  FROM telephone te, TYPE t,client c
                    WHERE te.typ_code = t.typ_code 
                    AND te.cli_id = c.cli_id  
                    AND t.typ_code = v_type  
                    AND  c.cli_id = v_clt)
        LOOP 
            --incrémentation du nombre de numéros de téléphones du client
            nb_num := nb_num + 1;
            dbms_output.put_line ('Numéro ' || nb_num || ':' || X.tel_numero );
        END LOOP;
    
       --Vérification du type des numéros 
       IF nb_ch = 0
        THEN RAISE err_int;
       END IF;
        dbms_output.put_line (nb_num || 'numéros correspondants');
    
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN dbms_output.put_line('client inexistant');
            WHEN err_int 
                THEN dbms_output.put_line('pas de numéro de téléphone de type  '||v_type);
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN dbms_output.put_line('Type téléphone inconnu');
END;
/


--2) 
-- Ajouter dans la table TYPE un nouveau type de téléphone : BUR – Téléphone Bureau 
INSERT INTO TYPE VALUES ('BUR','Téléphone Bureau');


--3) Dernière version

accept v_phone_type prompt 'Please enter the phone type : ';

accept v_cli_id  prompt 'Please enter the customer id ';


DECLARE 

v_type TYPE.v_phone_type%TYPE := '&type';
v_cli 	CLIENT.v_cli_id%TYPE := '&clt';
nb_num INTEGER := 0;  
err_int EXCEPTION;
err_supp EXCEPTION;
PRAGMA EXCEPTION_INIT (err_supp, -2292);

BEGIN
    --Verification existance tu type téléphone
    SELECT typ_code INTO v_type FROM TYPE WHERE typ_code = v_type;
    
    BEGIN 
        --Vérification existance client
        SELECT CLI_ID INTO v_cli FROM CLIENT WHERE cli_id = v_cli;
        
        FOR X IN (SELECT tel_numero  FROM telephone te, TYPE t,client c
                    WHERE te.typ_code = t.typ_code 
                    AND te.cli_id = c.cli_id  
                    AND t.typ_code = v_type  
                    AND  c.cli_id = v_clt)
        LOOP 
            --incrémentation du nombre de numéros de téléphones du client
            nb_num := nb_num + 1;
            dbms_output.put_line ('Numéro ' || nb_num || ':' || X.tel_numero );
        END LOOP;
    
       --Vérification du type des numéros 
       IF nb_ch = 0
        THEN RAISE err_int;
       END IF;
        dbms_output.put_line (nb_num || 'numéros correspondants');
    
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN dbms_output.put_line('client inexistant');
            WHEN err_int 
                THEN dbms_output.put_line('pas de numéro de téléphone de type  '||v_type);
                DELETE FROM type WHERE type_cod = v_type;
                dbms_output.put_line('Type téléphone '||v_type|| '  non utilisé et supprimé');
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN dbms_output.put_line('Type téléphone inconnu');
        WHEN err_supp THEN -- Erreur déclenchée par le DELETE si type utilisé par d'autres clients
        dbms_output.put_line('Supp. du type '||v_type|| '  impossible ');
END;    
/

--Exercice 4  Curseurs – Curseur paramétré – Type RECORD

accept v_chb_id prompt 'Please enter the room number: ';


DECLARE
chb_num chambre.ch_id%TYPE;

err_num 		NUMBER;
err_msg			VARCHAR(100);

v_nom		  	CLIENT.CLI_NOM%TYPE;
v_prenom		CLIENT.CLI_PRENOM%TYPE;
v_ville			ADRESSE.ADR_VILLE%TYPE;
v_jour    		PLANNING.PLN_JOUR%TYPE;
v_num 			CHAMBRE.chb_numero%TYPE :=  &chb_num;

CURSOR C1	IS 	SELECT DISTINCT cli_nom,cli_prenom, adr_ville, pln_jour
					FROM client c, planning p, chambre c, adresse a
					WHERE c.cli_id = p.cli_id
						AND a.cli_id = c.cli_id
						AND p.chb_id = c.chb_id
						AND c.chb_numero = v_num
						AND EXTRACT(MONTH FROM p.pln_jour) = 11
						AND EXTRACT(YEAR FROM p.pln_jour) = 2007
					ORDER BY pln_jour;

BEGIN
    -- vérification existance de la chambre
    SELECT chb_numero INTO v_num FROM chambre WHERE chb_numero = v_num;
    OPEN C1;
    LOOP
            FETCH C1 INTO v_nom, v_prenom, v_ville, v_jour ;
            EXIT WHEN C1%NOTFOUND;
            IF c1%ROWCOUNT = 1 
                THEN DBMS_OUTPUT.PUT_LINE('La chambre '|| v_num || ' est louée par :' );
            END IF;
            DBMS_OUTPUT.PUT_LINE(v_prenom||' '||REPLACE(v_nom,' ','')||' habitant '||REPLACE(v_ville,' ','') || ' le '|| TO_CHAR(v_jour, 'fmDay DD'));
    END LOOP;
    IF c1%ROWCOUNT = 0 
            THEN  DBMS_OUTPUT.PUT_LINE('Pas encore de location pour la chambre '|| v_num );
            ELSE DBMS_OUTPUT.PUT_LINE('Le Nombre de clients louant la chambre '||v_num||' : '||c1%ROWCOUNT);
    END IF;
    
    CLOSE C1;
    
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Chambre inexistante');
END;
/


-- Version 2  avec une boucle for

accept v_chb_id prompt 'Please enter the room number: ';

DECLARE

err_num 		NUMBER;
err_msg			VARCHAR(100);

TYPE mon_client IS RECORD (
		nom		  CLIENT.CLI_NOM%TYPE,
		prenom	CLIENT.CLI_PRENOM%TYPE,
		ville		ADRESSE.ADR_VILLE%TYPE,
		jour    PLANNING.PLN_JOUR%TYPE);

v_clt mon_client;

CURSOR C1	IS 	SELECT DISTINCT cli_nom,cli_prenom, adr_ville, pln_jour
					FROM client c, planning p, chambre c, adresse a
					WHERE c.cli_id = p.cli_id
						AND a.cli_id = c.cli_id
						AND p.chb_id = c.chb_id
						AND c.chb_numero = &num
						AND EXTRACT(MONTH FROM p.pln_jour) = 11
						AND EXTRACT(YEAR FROM p.pln_jour) = 2007
					ORDER BY 4;
						
v_num 	CHAMBRE.chb_numero%TYPE;
				
BEGIN

SELECT chb_numero INTO v_num FROM chambre WHERE chb_numero = &num;

OPEN C1;
LOOP
		FETCH C1 INTO v_clt ;
		EXIT WHEN C1%NOTFOUND;
		IF c1%ROWCOUNT = 1 
			THEN DBMS_OUTPUT.PUT_LINE('La chambre '|| v_num || ' est louée par :' );
		END IF;
		DBMS_OUTPUT.PUT_LINE(v_clt.prenom||' '||REPLACE(v_clt.nom,' ','')||' habitant '||REPLACE(v_clt.ville,' ','') || ' le '|| TO_CHAR(v_clt.jour, 'fmDay DD'));
END LOOP;
IF c1%ROWCOUNT = 0 
		THEN  DBMS_OUTPUT.PUT_LINE('Pas encore de location pour la chambre '|| v_num );
		ELSE DBMS_OUTPUT.PUT_LINE('Le Nombre de clients louant la chambre '||v_num||' : '||c1%ROWCOUNT);
END IF;

CLOSE C1;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Chambre inexistante');
END;
/



--version 3 

accept etage prompt 'Please enter the room level: ';

DECLARE
err_num 		NUMBER;
err_msg			VARCHAR(100);

TYPE mon_client IS RECORD (
		nom		  CLIENT.CLI_NOM%TYPE,
		prenom	CLIENT.CLI_PRENOM%TYPE,
		ville		ADRESSE.ADR_VILLE%TYPE,
		jour    PLANNING.PLN_JOUR%TYPE);

v_clt mon_client;


CURSOR C1(p_chb_num CHAMBRE.chb_numero%TYPE)	IS 	SELECT DISTINCT cli_nom,cli_prenom, adr_ville, pln_jour
					FROM client c, planning p, chambre c, adresse a
					WHERE c.cli_id = p.cli_id
						AND a.cli_id = c.cli_id
						AND p.chb_id = c.chb_id
						AND c.chb_numero = p_chb_num
            AND EXTRACT(MONTH FROM p.pln_jour) = 11
            AND EXTRACT(YEAR FROM p.pln_jour) = 2007
            ORDER BY 4;
						
nbc   INTEGER :=0;
err_chb EXCEPTION;
				
BEGIN

IF '&etage' NOT IN ('RDC','1er','2e') THEN
	RAISE err_chb;
ELSE
	DBMS_OUTPUT.PUT_LINE('Il y a '||nbc||' chambres à l''étage &etage');
END IF;

FOR C IN (SELECT chb_numero FROM chambre WHERE chb_etage = '&etage')
LOOP
	nbc := nbc + 1;
	OPEN C1(c.chb_numero);
	LOOP
		FETCH C1 INTO v_clt ;
		EXIT WHEN C1%NOTFOUND;
		IF c1%ROWCOUNT = 1 
			THEN DBMS_OUTPUT.PUT_LINE('La chambre '|| c.chb_numero || ' est louée par :' );
		END IF;
		DBMS_OUTPUT.PUT_LINE(v_clt.prenom||' '||REPLACE(v_clt.nom,' ','')||' habitant '||REPLACE(v_clt.ville,' ','') || ' le '|| TO_CHAR(v_clt.jour, 'fmDay DD'));
	END LOOP;
	IF c1%ROWCOUNT = 0 
		THEN  DBMS_OUTPUT.PUT_LINE('Pas encore de location pour la chambre '|| c.chb_numero );
		ELSE DBMS_OUTPUT.PUT_LINE('Le Nombre de clients louant la chambre '||c.chb_numero||' : '||c1%ROWCOUNT);
	END IF;
	CLOSE C1;
	DBMS_OUTPUT.PUT_LINE('***************');
END LOOP;

DBMS_OUTPUT.PUT_LINE('Il y a '|| nbc || ' chambres à cet étage');

EXCEPTION WHEN err_chb THEN
	DBMS_OUTPUT.PUT_LINE('&etage n''est pas un étage valide');
	
END;
/


