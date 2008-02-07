/* change management log for QA */
/* 2007/09/24 */

ALTER TABLE container
    ADD CONSTRAINT pkey_container
    PRIMARY KEY (container_id);
	
CREATE TABLE container_check (
	container_check_id NUMBER NOT NULL,
	container_id NUMBER NOT NULL,
	check_date DATE NOT NULL,
	checked_agent_id NUMBER NOT NULL,
	check_remark VARCHAR2(255));
	
CREATE PUBLIC SYNONYM container_check FOR container_check;
GRANT SELECT ON container_check TO PUBLIC;
GRANT INSERT ON container_check TO manage_specimens, manage_transactions;
	
ALTER TABLE container_check
	ADD CONSTRAINT pkey_container_check
	PRIMARY KEY (container_check_id);

ALTER TABLE container_check
    ADD CONSTRAINT fkey_cont_chk_container
    FOREIGN KEY (container_id)
    REFERENCES container (container_id);
	
ALTER TABLE container_check
    ADD CONSTRAINT fkey_cont_agnt_agent
	FOREIGN KEY (checked_agent_id)
	REFERENCES agent (agent_id);

CREATE OR REPLACE TRIGGER container_check_id                                         
BEFORE INSERT ON container_check  
FOR EACH ROW
BEGIN
    IF :new.container_check_id IS NULL THEN
        SELECT somerandomsequence.nextval INTO :new.container_check_id 
        FROM dual;
    end if;
    IF :new.check_date IS NULL THEN
        :new.check_date:= sysdate;
    END IF;
END;                                                                                            
/
sho err

/* 2007/09/25 */
ALTER TABLE binary_object
    ADD CONSTRAINT pk_binary_object
    PRIMARY  KEY (collection_object_id);
    
ALTER TABLE binary_object
    ADD CONSTRAINT fk_binary_object
    FOREIGN KEY (derived_from_coll_obj)
    REFERENCES binary_object(collection_object_id);
  
  
/* 2007/09/26 */
ALTER TABLE collecting_event 
    MODIFY date_determined_by_agent_id NULL;
        
/* ATTENTION! RUN BELOW BEFORE MIGRATION TO QA!! */        
CREATE OR REPLACE TRIGGER specimen_part_delete_cleanup                                         
AFTER DELETE ON specimen_part
FOR EACH ROW
DECLARE cid container.container_id%TYPE;
BEGIN
    DELETE FROM coll_object WHERE collection_object_id = :OLD.collection_object_id;
    DELETE FROM coll_object_remark WHERE collection_object_id = :OLD.collection_object_id;
    SELECT container_id INTO cid 
    FROM coll_obj_cont_hist 
    WHERE collection_object_id = :OLD.collection_object_id;
    DELETE FROM coll_obj_cont_hist WHERE collection_object_id = :OLD.collection_object_id;
    DELETE FROM container_history WHERE container_id = cid;
    DELETE FROM container WHERE container_id = cid;
END;                                                                                            
/
sho err
/* ATTENTION! RUN ABOVE BEFORE MIGRATION TO QA!! */        
/* ATTENTION! RUN BEFORE MIGRATION TO QA!! */        
