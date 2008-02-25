<cfquery name="d" datasource="uam_god">
select
st.PHYLUM Phylum_s,
PCLASS phylclass_s,
PORDER phylorder_s,
 st.FAMILY Family_s,
 st.GENUS Genus_s,
st.SPECIES Species_s,
AUTHOR author_text_s,
SCINAME scientific_name_s,
PHYLCLASS,
PHYLORDER,
SUBORDER,
t.FAMILY,
SUBFAMILY,
t.GENUS,
SUBGENUS,
t.SPECIES,
SUBSPECIES,
VALID_CATALOG_TERM_FG,
SOURCE_AUTHORITY,
SCIENTIFIC_NAME,
AUTHOR_TEXT,
TRIBE,
INFRASPECIFIC_RANK,
TAXON_REMARKS,
t.PHYLUM
from 
st,taxonomy t
where st.sciname=t.scientific_name(+)
order by sciname
</cfquery>
<cfdump var=#d#>