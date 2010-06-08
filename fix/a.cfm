<cfoutput >
<cfquery name="d" datasource="uam_god">
	select
		collection,
		loan_number,
		loan.transaction_id
	from
		loan,
		loan_item,
		cataloged_item,
		collection
	where
		cataloged_item.collection_id=collection.collection_id and
		loan.transaction_id=loan_item.transaction_id and
		loan_item.collection_object_id=cataloged_item.collection_object_id
	group by
		collection,
		loan_number,
		loan.transaction_id
</cfquery>

<cfloop query="d">
	#loan_number# #transaction_id#<br>
	<cfquery name="sp" datasource="uam_god">
		select cat_num from cataloged_item where cataloged_item.collection_object_id=loan_item.collection_object_id
		and loan_item.transaction_id=#transaction_id#
	</cfquery>
	<cfloop query="sp">
		#cat_num#<br>
	</cfloop>
</cfloop>
</cfoutput>
