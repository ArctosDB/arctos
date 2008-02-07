CREATE OR REPLACE function get_taxonomy(collobjid IN number, rank in varchar2 )
    return varchar2
    as
        l_str    varchar2(4000);
	begin
	execute immediate 'select distinct(taxonomy.' || rank || ') tname from identification, identification_taxonomy, taxonomy
		where identification.identification_id = identification_taxonomy.identification_id AND
		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
		accepted_id_fg=1 AND
		collection_object_id = ' || collobjid into l_str;		
	return l_str;
	EXCEPTION
	when TOO_MANY_ROWS then
		l_str := 'undefinable';
		return  l_str;
	when NO_DATA_FOUND then
		l_str := 'not recorded';
		return  l_str;
	when others then
		l_str := 'error!';
		return  trim(l_str);
  end;
  --create public synonym get_taxonomy for get_taxonomy;
  --grant execute on get_taxonomy to public;
/

/*

		*/