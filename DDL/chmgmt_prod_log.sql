/* change management log for QA */

/* 2007/09/25 */
ALTER TABLE binary_object
    ADD CONSTRAINT pk_binary_object
    PRIMARY  KEY (collection_object_id);
  
ALTER TABLE binary_object
    ADD CONSTRAINT fk_binary_object
    FOREIGN KEY (derived_from_coll_obj)
    REFERENCES binary_object(collection_object_id);
    
/* 2007/09/25 */
ALTER TABLE collecting_event 
    MODIFY date_determined_by_agent_id NULL;