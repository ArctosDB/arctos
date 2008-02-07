CREATE OR REPLACE function concatDarwinRelations(p_key_val  in varchar2 )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);

       l_cur    rc;
   begin

      open l_cur for 'select biol_indiv_relationship || '' of URN:catalog:'' || 
      	institution_acronym || '':'' || collection.collection_cde || '':'' || cat_num 
                         from biol_indiv_relations, cataloged_item, collection
                        where biol_indiv_relations.related_coll_object_id = cataloged_item.collection_object_id and
                        cataloged_item.collection_id = collection.collection_id AND
                        biol_indiv_relations.collection_object_id  = :x '
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

create public synonym concatDarwinRelations for concatDarwinRelations;
grant execute on concatDarwinRelations to public;

