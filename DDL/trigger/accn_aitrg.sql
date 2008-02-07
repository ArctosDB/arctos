CREATE OR REPLACE TRIGGER lam_accn_ai
AFTER INSERT ON lam_accn
FOR EACH ROW
BEGIN
    FOR rec IN (SELECT COUNT(*) rcount, t.institution_acronym || '|' || a.accn_number tian 
        FROM lam_accn a, lam_trans t
        WHERE a.transaction_id = t.transaction_id
        AND a.accn_number = :NEW.accn_number
        GROUP BY t.institution_acronym || '|' || a.accn_number
    ) LOOP
        IF rec.rcount > 1 THEN
            ROLLBACK TRANSACTION;
            raise_application_error(
	        -20001,
	        'ERROR: The combination of the institution_acronym and accn_number already exists.'
	      );
            dbms_output.put_line('institution_acronym and accn_number combo not unique');
        END IF;
    END LOOP;
END;