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
         dbms_output.put_line ('Le nombre de chambre(s) de l''agent' || v_agt_ids || ' est : ' || v_agt_ids );
    END IF;
    IF agt_cur%NOTFOUND
        THEN dbms_output.put_line ('Agent Inexistant');
    END IF;
    CLOSE agt_cur;
END;
/