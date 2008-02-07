drop view taxa_terms;
drop public synonym taxa_terms;


create view taxa_terms as
select
identification.collection_object_id,
upper(scientific_name) taxa_term
from
identification
where accepted_id_fg=1
UNION
select
identification.collection_object_id,
upper(full_taxon_name) taxa_term
from
identification,
identification_taxonomy,
taxonomy
where
accepted_id_fg=1 AND
identification.identification_id = identification_taxonomy.identification_id AND
identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id
UNION
select
identification.collection_object_id,
upper(common_name) taxa_term
from
identification,
identification_taxonomy,
taxonomy,
common_name
where
accepted_id_fg=1 AND
identification.identification_id = identification_taxonomy.identification_id AND
identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
taxonomy.taxon_name_id = common_name.taxon_name_id
;

create public synonym taxa_terms for taxa_terms;
grant select on taxa_terms to public;