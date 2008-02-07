ALTER TABLE locality ADD gps_distance_units VARCHAR2(2);
 -- rebuilt the trigger to handle new units
CREATE OR REPLACE TRIGGER lat_long_ct_check
before UPDATE or INSERT ON lat_long
for each row
declare
numrows number;
BEGIN
	SELECT COUNT(*) INTO numrows FROM ctVERIFICATIONSTATUS WHERE VERIFICATIONSTATUS = :NEW.VERIFICATIONSTATUS;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid VERIFICATIONSTATUS'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctGEOREFMETHOD WHERE GEOREFMETHOD = :NEW.GEOREFMETHOD;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid GEOREFMETHOD'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctdatum WHERE datum = :NEW.datum;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid datum'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctlat_long_units WHERE orig_lat_long_units = :NEW.orig_lat_long_units;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid orig_lat_long_units'
	      );
	END IF;
	IF (:NEW.MAX_ERROR_UNITS is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctlat_long_error_units WHERE LAT_LONG_ERROR_UNITS = :NEW.MAX_ERROR_UNITS;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid MAX_ERROR_UNITS'
		      );
		END IF;
	END IF;
	IF (:NEW.MAX_ERROR_UNITS is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctlat_long_error_units WHERE LAT_LONG_ERROR_UNITS = :NEW.gps_distance_units;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid gps_distance_units.'
		      );
		END IF;
	END IF;	
	IF (:NEW.orig_lat_long_units = 'decimal degrees') THEN
		IF (:NEW.dec_lat is null OR :NEW.dec_long is null) THEN
			raise_application_error(
		        -20001,
		        'dec_lat and dec_long are required when orig_lat_long_units is decimal degrees'
	      	);
	    END IF;	   
	ELSIF (:NEW.orig_lat_long_units = 'deg. min. sec.') THEN
		IF (:NEW.LAT_DEG is null OR :NEW.LAT_DIR is null OR :NEW.LONG_DEG is null OR :NEW.LONG_DIR is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with degrees minutes seconds'
	      	);
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'degrees dec. minutes') THEN
		IF (:NEW.LAT_DEG is null OR :NEW.LAT_DIR is null OR :NEW.LONG_DEG is null OR :NEW.LONG_DIR is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with degrees dec. minutes'
	      	);
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'UTM') THEN
		IF (:NEW.utm_ew is null OR :NEW.utm_ns is null OR :NEW.utm_zone is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with UTM'
	      	);
		END IF;	
	ELSE
		raise_application_error(
		        -20001,
		        :NEW.orig_lat_long_units || ' is not handled. Please contact your database administrator.'
	      	);
	END IF;    	
END;
/
sho err