CREATE OR REPLACE TRIGGER attribute_ct_check
before UPDATE or INSERT ON attributes
for each row
declare
numrows number := 0;
collectionCode varchar2(4);
sqlString varchar2(4000);
vct varchar2(255);
uct varchar2(255);
ctctColname varchar2(255);
ctctCollCde number :=0;
no_problem_go_away exception;
BEGIN
	select count(*) into numrows from collection,cataloged_item where collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = :NEW.collection_object_id;
	if numrows = 0 then
		raise_application_error(
	        -20001,
	        'Cataloged item not found'
	      );
	END IF;
	select collection.collection_cde into collectionCode from collection,cataloged_item where collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = :NEW.collection_object_id;
	SELECT COUNT(*) INTO numrows FROM ctattribute_type WHERE attribute_type = :NEW.attribute_type AND collection_cde =collectionCode; 
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid attribute_type'
	      );
	END IF;
	select count(*) into numrows FROM ctattribute_code_tables WHERE attribute_type = :NEW.attribute_type;
	IF (numrows = 0) THEN
		-- this is NOT controlled - they can put anything they want in value, units must be null
		IF (:new.attribute_units is not null) THEN
			 raise_application_error(
	        -20001,
	        'This attribute cannot have units'
	      );
		end if;
		-- RAISE no_problem_go_away; -- no need to check anything; free text so anything is OK
	else
	-- one or the other if we made it to here
	SELECT upper(VALUE_CODE_TABLE),upper(UNITS_CODE_TABLE) INTO vct,uct FROM ctattribute_code_tables WHERE attribute_type = :NEW.attribute_type;
	IF (vct is not null) THEN
		 dbms_output.put_line ('there is a value code table');
		-- get the code table column name
		select column_name into ctctColname from user_tab_columns where upper(table_name) = vct  and upper(column_name) <>'COLLECTION_CDE' and upper(column_name) <>'DESCRIPTION';
		dbms_output.put_line (ctctColname);
		-- see if there's a collection_cde column; 1=yes, 0=default=no
		select count(*) into ctctCollCde from user_tab_columns where upper(table_name) = vct and column_name='COLLECTION_CDE';
		--dbms_output.put_line (ctctCollCde);
		IF (ctctCollCde = 1) THEN
			dbms_output.put_line ('there is a collection code for this attribute');
			sqlString := 'select count(*)  from ' || vct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_VALUE || ''' and collection_cde= ''' || collectionCode  || '''';
			execute immediate sqlstring into numrows;
			IF (numrows = 0) THEN
				 raise_application_error(
			        -20001,
			        'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection'
			      );
			END IF;
		ELSE
			-- no collection code
			sqlString := 'select count(*)  from ' || vct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_VALUE || '''';
			execute immediate sqlstring into numrows;
			IF (numrows = 0) THEN
				 raise_application_error(
			        -20001,
			        'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection'
			      );
			END IF;
		END IF;
	ELSIF (uct is not null) THEN
		dbms_output.put_line('controlled units');
		select column_name into ctctColname from user_tab_columns where upper(table_name) = uct and upper(column_name) <>'COLLECTION_CDE' and upper(column_name) <>'DESCRIPTION';
		dbms_output.put_line (ctctColname);
		-- these will never be collection-specific, according to me
		sqlString := 'select count(*)  from ' || uct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_UNITS || '''';
		execute immediate sqlstring into numrows;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid ATTRIBUTE_UNITS'
		      );
		END IF;
	END IF;
	END IF; --- end has units or value check
EXCEPTION
	WHEN no_problem_go_away THEN
	-- do something or it'll complain
	numrows:=1;
	-- dbms_output.put_line('bla');
		
	
END;
/
sho err