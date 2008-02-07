CREATE OR REPLACE function ConcatSingleOtherIdInt(
	p_key_val  in number,
    p_other_col_name in varchar2)
return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
	    l_sep    varchar2(1);
        l_val    varchar2(4000);
	    l_cur    rc;
begin
   	open l_cur for 'select  other_id_number
                         from coll_obj_other_id_num
                        where other_id_type=''' || p_other_col_name || ''' AND
                       collection_object_id  = :x '
                          using p_key_val;

       loop
           fetch l_cur into l_val;
           exit when l_cur%notfound;
           l_str := l_str || l_sep || l_val;
           l_sep := '-';
       end loop;
       close l_cur;

       return l_str;
   end;
/
create public synonym ConcatSingleOtherIdInt for ConcatSingleOtherIdInt;
grant execute on ConcatSingleOtherIdInt to public;
