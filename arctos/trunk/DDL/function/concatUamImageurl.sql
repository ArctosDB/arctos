CREATE OR REPLACE function ConcatImageUrl(p_key_val  in number)
  
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(2);
       l_val    varchar2(4000);
   		l_cur    rc;
   begin

       open l_cur for 'select full_url || ''=''|| display_value
                         from coll_obj_other_id_num
                        where collection_object_id = :x
                        order by other_id_type, display_value'
                   using p_key_val;

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

