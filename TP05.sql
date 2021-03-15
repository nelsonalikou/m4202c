SET SERVEROUTPUT ON;

--Exercice 1 : Procédure – Appel de procédure

CREATE OR REPLACE PROCEDURE clientville (p_ville IN ADRESSE.ADR_VILLE%TYPE) IS
v_nom		CLIENT.CLI_NOM%TYPE;
v_prnm	CLIENT.CLI_PRENOM%TYPE;

CURSOR C1 IS
	SELECT cli_nom, cli_prenom
	FROM client c, adresse a
	WHERE c.cli_id = a.cli_id
  AND ADR_VILLE = p_ville;
BEGIN

OPEN C1;
 dbms_output.put_line('Ville :'||p_ville);
 dbms_output.put_line('----------------');

LOOP
	FETCH C1 INTO v_nom, v_prnm;
	EXIT WHEN c1%NOTFOUND;
	dbms_output.put_line(v_nom||' '||v_prnm);
END LOOP;

IF c1%ROWCOUNT != 0
	THEN  dbms_output.put_line('Nb de clients :'||c1%ROWCOUNT);
	ELSE  dbms_output.put_line('Aucun client dans cette ville');
END IF;
CLOSE C1;
END;
/

-- autre version avec une boucle FOR
CREATE OR REPLACE PROCEDURE clientville2 (p_ville IN ADRESSE.ADR_VILLE%TYPE) IS
nbcli INTEGER :=0;
BEGIN

 dbms_output.put_line('Ville :'||p_ville);
 dbms_output.put_line('----------------');

FOR C in (SELECT cli_nom, cli_prenom FROM client c, adresse a
			WHERE c.cli_id = a.cli_id  AND ADR_VILLE = p_ville)
LOOP
	 dbms_output.put_line(c.cli_nom||' '||c.cli_prenom);
	nbcli := nbcli + 1;
END LOOP;

IF nbcli  != 0
	THEN  dbms_output.put_line('Nb de clients :'||nbcli);
	ELSE  dbms_output.put_line('Aucun client dans cette ville');
END IF;
END;
/

-- Appel de la procédure
EXECUTE clientville('REIMS');


--Appel de la procédure
BEGIN
	FOR v IN (SELECT DISTINCT ADR_VILLE from adresse
		 	WHERE ADR_CP LIKE '51%')
		LOOP
			clientville(v.ADR_VILLE);
		END LOOP;
END;
/


--Exercice 2 : Procédure – Appel de procédure

SET SERVEROUTPUT ON
-- Question a)
CREATE OR REPLACE PROCEDURE agt_chb(  p_num IN CHAMBRE.CHB_ID%TYPE, 
                                      p_nom_agt OUT AGENT_ENTRETIEN.AGT_NOM%TYPE, 
                                      p_prnm_agt OUT AGENT_ENTRETIEN.AGT_PRENOM%TYPE) 		
IS
BEGIN

SELECT agt_nom, agt_prenom INTO p_nom_agt, p_prnm_agt
FROM agent_entretien 
WHERE agt_id = (SELECT agt_id 
				FROM chambre
				WHERE chb_id = p_num);

EXCEPTION 
	WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001,'chambre inexistante') ; 

END;
/

-- Question b)
DECLARE
v_num 	VARCHAR2(15) := '&num';
v_nom_agt  AGENT_ENTRETIEN.AGT_NOM%TYPE;
v_prenom_agt  AGENT_ENTRETIEN.AGT_PRENOM%TYPE;
chb_inex	EXCEPTION;
PRAGMA EXCEPTION_INIT (chb_inex,-20001);

BEGIN
	agt_chb (v_num ,v_nom_agt,v_prenom_agt);
	dbms_output.put_line('La chambre  '||v_num||' est en charge de : '||v_nom_agt||' '||v_prenom_agt);
EXCEPTION 
	WHEN chb_inex THEN dbms_output.put_line('chambre '|| v_num ||' '||SUBSTR(SQLERRM,12));

END;
/


-- Question c)
-- Appel de la proc?dure dans un bloc PL/SQL
DECLARE
v_nom_agt  AGENT_ENTRETIEN.AGT_NOM%TYPE;
v_prenom_agt  AGENT_ENTRETIEN.AGT_PRENOM%TYPE;
v_etage CHAMBRE.CHB_ETAGE%TYPE;
v_date DATE;
err_etage EXCEPTION;
nb_chb INTEGER:=0;


BEGIN
  v_etage := '&etage';
  v_date := TO_DATE('&date','DD/MM/YY');
  IF v_etage NOT IN ('RDC','1er','2e')THEN
    RAISE err_etage;
  END IF;
	dbms_output.put_line('-------PERSONNEL ATTENDU le '||v_date|| ' A l''ETAGE : '||v_etage||'--------');
	FOR v IN (SELECT c.chb_id from planning p, chambre c
				WHERE  pln_jour = v_date
				AND c.chb_id = p.chb_id
				AND c.chb_etage = v_etage)
	LOOP
		agt_chb (v.chb_id ,v_nom_agt,v_prenom_agt);
		dbms_output.put_line(v_nom_agt||' '||v_prenom_agt||' pour la chambre  '||v.chb_id);
    nb_chb :=nb_chb +1;
	END LOOP;
  
  IF nb_chb = 0 
    THEN dbms_output.put_line('Pas de chambre réservée le '||v_date||' à l''étage ' ||v_etage);
  END IF ;
  
  EXCEPTION 
    WHEN err_etage
      THEN dbms_output.put_line('Ce n''est pas un etage valide');
    WHEN OTHERS
      THEN dbms_output.put_line('Erreur de DATE');
  

END;
/
