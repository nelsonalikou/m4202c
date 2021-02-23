SET SERVEROUTPUT ON;


-- Exercice 1 : Gestion des EXCEPTIONS 

--  bloc PLSQL qui insère une réservation d’un client dans le planning 

accept v_cli_id prompt 'Please enter the client code : ';

accept v_chb_id  prompt 'Please enter the CHB_ID ';

accept v_nb_pers  prompt 'Please enter the CHB_ID ';

DECLARE
    chb_code CHAMBRE.CHB_ID%TYPE;
    cli_code AGENT_ENTRETIEN.AGT_ID%TYPE;
    agt_name AGENT_ENTRETIEN.AGT_NOM%TYPE;
    nb_pers_chb INTEGER;
  
    --Prise en charge de l'erreur due à la contrainte FK_CHAMBRE_AGT_ID
    E_FK_CHAMBRE_AGT_ID exception;
    pragma exception_init(E_FK_CHAMBRE_AGT_ID, -02291);
    
    --Vérification du nombre de chambres prises en charge par l'agent
    E_NB_CHAMBRE_AGT exception;
    
Begin
    
    chb_code := &v_chb_id;
    cli_code := '&v_cli_id';
    nb_pers_chb := v_nb_pers;
    
   
   --Insertion de la réservation pour le client dans la table planning
   INSERT INTO PLANNING (CHB_ID,CLI_ID,NB_PERS)
   VALUES(chb_code,cli_code,nb_pers_chb);
   
    --Récupération du nombre de chambres de l'agent
    SELECT COUNT(CHB_ID)
    INTO nb_chambres_agt
    FROM CHAMBRE
    WHERE AGT_ID = agt_code;
    
    dbms_output.put_line ( 'nb chambres ' || nb_chambres_agt);
    
    IF (nb_chambres_agt >= 12)
        THEN RAISE E_NB_CHAMBRE_AGT;
    END IF;
    
    UPDATE CHAMBRE
    SET AGT_ID = agt_code
    WHERE CHB_ID = chb_code;
    
    IF (SQL%ROWCOUNT > 0)
        THEN dbms_output.put_line('Modification effectuée : L''agent ' || agt_code || ' est affecté à la chambre ' || chb_code);
    ELSE dbms_output.put_line ( 'La chambre ' || chb_code || ' n''existe pas' );
    END IF;
EXCEPTION
    WHEN E_FK_CHAMBRE_AGT_ID
        THEN dbms_output.put_line ( 'L’agent ' || agt_code || ' n''existe pas' );
    WHEN E_NB_CHAMBRE_AGT
       THEN dbms_output.put_line('Trop de chambres pour l’agent ' || agt_code || '. Modification annulée.') ;
    WHEN OTHERS 
        THEN raise_application_error(-20020,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end;
/