<cfoutput>
All the following data are for taxa:
Otariidae
Odobenidae
Balaenidae
Balaenopteridae
Eschrichtiidae
Monodontidae
Phocoenidae
Ziphiidae
Ursus maritimus
Enhydra lutris
<hr>
<cfquery name="ci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
SELECT count(distinct(cat_num)) cat_items FROM
	cataloged_item,
	loan_item,
	identification,
	identification_taxonomy,
	taxonomy
WHERE
	cataloged_item.collection_object_id = loan_item.collection_object_id AND
	cataloged_item.collection_object_id = identification.collection_object_id AND
	identification.identification_id = identification_taxonomy.identification_id AND
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
	(taxonomy.phylclass IN (
		'Otariidae',
		'Odobenidae',
		'Balaenidae',
		'Balaenopteridae',
		'Eschrichtiidae',
		'Monodontidae',
		'Phocoenidae',
		'Ziphiidae')
	OR taxonomy.scientific_name IN (
		'Ursus maritimus',
		'Enhydra lutris')
	)
</cfquery>
#ci.cat_items# distinct cataloged items have been loaned as legacy loan items. 
Catnum 1 will only be represented 1 time, even though it went out in 12 loans.

<cfquery name="collobj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
SELECT count(distinct(cat_num)) cat_items FROM
	cataloged_item,
	loan_item,
	identification,
	identification_taxonomy,
	taxonomy,
	specimen_part
WHERE
	cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
	specimen_part.collection_object_id = loan_item.collection_object_id AND
	cataloged_item.collection_object_id = identification.collection_object_id AND
	identification.identification_id = identification_taxonomy.identification_id AND
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
	(taxonomy.phylclass IN (
		'Otariidae',
		'Odobenidae',
		'Balaenidae',
		'Balaenopteridae',
		'Eschrichtiidae',
		'Monodontidae',
		'Phocoenidae',
		'Ziphiidae')
	OR taxonomy.scientific_name IN (
		'Ursus maritimus',
		'Enhydra lutris')
	)
</cfquery>
<hr>
#collobj.cat_items# distinct cataloged items that have been loaned as parts. 
Catnum 1 will only be represented 1 time, even though it went out in 12 loans.

<cfquery name="Allcollobj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
SELECT count(loan_item.collection_object_id) cat_items FROM
	cataloged_item,
	loan_item,
	identification,
	identification_taxonomy,
	taxonomy,
	specimen_part
WHERE
	cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
	specimen_part.collection_object_id = loan_item.collection_object_id AND
	cataloged_item.collection_object_id = identification.collection_object_id AND
	identification.identification_id = identification_taxonomy.identification_id AND
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
	(taxonomy.phylclass IN (
		'Otariidae',
		'Odobenidae',
		'Balaenidae',
		'Balaenopteridae',
		'Eschrichtiidae',
		'Monodontidae',
		'Phocoenidae',
		'Ziphiidae')
	OR taxonomy.scientific_name IN (
		'Ursus maritimus',
		'Enhydra lutris')
	)
</cfquery>
<hr>
#Allcollobj.cat_items# parts have been loaned as parts. 
Catnum 1 will be represented as many times as it's had a part loaned - 
spleen and lung in loan 1, then spleen again in loan2=3 hits here.

<cfquery name="AllCI" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
SELECT count(loan_item.collection_object_id) cat_items FROM
	cataloged_item,
	loan_item,
	identification,
	identification_taxonomy,
	taxonomy
WHERE
	cataloged_item.collection_object_id = loan_item.collection_object_id AND
	cataloged_item.collection_object_id = identification.collection_object_id AND
	identification.identification_id = identification_taxonomy.identification_id AND
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
	(taxonomy.phylclass IN (
		'Otariidae',
		'Odobenidae',
		'Balaenidae',
		'Balaenopteridae',
		'Eschrichtiidae',
		'Monodontidae',
		'Phocoenidae',
		'Ziphiidae')
	OR taxonomy.scientific_name IN (
		'Ursus maritimus',
		'Enhydra lutris')
	)
</cfquery>
<hr>
#AllCI.cat_items# cataloged items have been loaned as legacy items.
Catnum 1 will be represented as many times as it's been out as a cataloged item.


</cfoutput>