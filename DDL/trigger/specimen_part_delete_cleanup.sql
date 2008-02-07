 CREATE OR REPLACE TRIGGER specimen_part_delete_cleanup                                         
 AFTER DELETE  ON specimen_part
 for each row
 DECLARE cid container.container_id%TYPE;
    begin     
    	DELETE FROM coll_object WHERE collection_object_id = :OLD.collection_object_id;
    	DELETE FROM coll_object_remark WHERE collection_object_id = :OLD.collection_object_id;
    	select container_id INTO cid from coll_obj_cont_hist where
		    collection_object_id = :OLD.collection_object_id;
		DELETE FROM coll_obj_cont_hist WHERE collection_object_id = :OLD.collection_object_id;
		DELETE FROM container_history WHERE container_id = cid;
		DELETE FROM container WHERE container_id = cid;
    end;                                                                                            
/
sho err