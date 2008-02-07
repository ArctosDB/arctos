SET ESCAPE \
CREATE OR REPLACE function get_scientific_name_auths(collobjid IN number )
    return varchar2
    as
        final_str    varchar2(4000); 		
	begin
		FOR rec IN (
			select 
				'<i>' || taxonomy.scientific_name || '</i>' || 
					decode(author_text,
					NULL,'',
					' ' || trim(author_text)) scientific_name ,
				taxa_formula,
				variable
			FROM
				identification,
				identification_taxonomy,
				taxonomy
			WHERE
				identification.identification_id = identification_taxonomy.identification_id AND
				identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
				accepted_id_fg = 1 and
				collection_object_id = collobjid)
		LOOP
   			if (final_str is null) then
   				final_str := rec.taxa_formula;
   			end if;
			final_str := replace(final_str,rec.VARIABLE,rec.scientific_name);
  		END LOOP;
  		return  final_str;
EXCEPTION
	when others then
		final_str := 'error!';
		return  final_str;
  end;
  --create public synonym get_scientific_name_auths for get_scientific_name_auths;
 -- grant execute on get_scientific_name_auths to public;
/

sho err

--   select get_scientific_name_auths(min(collection_object_id)),taxa_formula  from identification group by taxa_formula