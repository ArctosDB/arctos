CREATE OR REPLACE FUNCTION concatGUID(p_key_val IN number)
RETURN varchar2
AS
	l_str	varchar2(4000);
	l_sep	varchar2(2);
	l_val	varchar2(4000);
BEGIN
	FOR r IN (
		SELECT
			'(' || biol_indiv_relationship || ') URN:catalog:' ||
			institution_acronym || ':' ||
			collection.collection_cde ||':' || cat_num guid
		FROM
			cataloged_item,
			collection,
			biol_indiv_relations
		WHERE
			cataloged_item.collection_object_id = biol_indiv_relations.related_coll_object_id
		AND cataloged_item.collection_id = collection.collection_id
		AND cataloged_item.collection_object_id = p_key_val
	) LOOP
		l_val := r.guid;
		l_str := l_str || l_sep || l_val;
		l_sep := '; ';
	END LOOP;
	RETURN l_str;
END;
/
sho err

CREATE PUBLIC SYNONYM ConcatGUID FOR ConcatGUID;
GRANT EXECUTE ON ConcatGUID TO PUBLIC;
-- select ConcatGUID(273173) from dual;
