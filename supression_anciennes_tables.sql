BEGIN
	FOR r IN (SELECT table_name FROM USER_TABLES)
	LOOP
		EXECUTE IMMEDIATE 'DROP TABLE '|| r.table_name;
         DBMS_OUTPUT.PUT_LINE('Table '|| r.table_name ||' supprim�e'); 
  END LOOP;
END;