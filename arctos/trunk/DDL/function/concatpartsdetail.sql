CREATE OR REPLACE function concatpartsdetail( collobjid in integer)
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(2);
       l_val    varchar2(4000);

       l_cur    rc;
   begin

       open l_cur for 'select 
       		decode(part_modifier,
				null,decode(preserve_method,
						null, part_name,
						part_name||'' (''||preserve_method||'')''),
				part_modifier||'' ''||
					decode(preserve_method,
					null, part_name,
					part_name||'' (''||preserve_method||'')''))
					||
					decode(condition,
					''unchecked'','''',
					'' Condition: '' || condition
					)
                         from specimen_part,ctspecimen_part_list_order,coll_object
                         where specimen_part.collection_object_id =  coll_object.collection_object_id AND
                        	specimen_part.part_name =  ctspecimen_part_list_order.partname (+)
                           	and SAMPLED_FROM_OBJ_ID is NULL
                           	and derived_from_cat_item = :x
                        ORDER BY list_order'
                   using collobjid;

       loop
           fetch l_cur into l_val;
           exit when l_cur%notfound;
           l_str := l_str || l_sep || l_val;
           l_sep := '; ';
       end loop;
       close l_cur;

       return l_str;
   end;
/


sho err;



--create public synonym concatpartsdetail for concatpartsdetail;
--grant execute on concatpartsdetail to public;


--  select concatpartsdetail(12) from dual;
--  select concatpartsdetail(2578556) from dual;

 -- select concatpartsdetail(12) from dual;

