create or replace trigger make_part_coll_obj_cont
after insert ON specimen_part
FOR EACH ROW
declare
	CONTAINER_ID number;
	label varchar2(255);
	institution_acronym varchar2(255);
BEGIN

	select max(container_id) + 1 into container_id from container;	
	
	select
		collection.institution_acronym,
		collection.institution_acronym || ' ' || collection.collection_cde || ' ' || cataloged_item.cat_num || ' ' || :NEW.part_name
	INTO 
		institution_acronym,
		label
	FROM
		collection,
		cataloged_item
	WHERE
		collection.collection_id = cataloged_item.collection_id AND
		cataloged_item.collection_object_id = :NEW.derived_from_cat_item
	;
	INSERT INTO container (
		CONTAINER_ID,
		PARENT_CONTAINER_ID,
		CONTAINER_TYPE,
		LABEL,
		locked_position,
		institution_acronym)
	VALUES (
		container_id,
		0,
		'collection object',
		label,
		0,
		institution_acronym
		);
			
			
	INSERT INTO coll_obj_cont_hist (
		COLLECTION_OBJECT_ID,
		CONTAINER_ID,
		INSTALLED_DATE,
		CURRENT_CONTAINER_FG)
	VALUES (
		:NEW.collection_object_id,
		container_id,
		sysdate,
		1);
end;
/
sho err;
