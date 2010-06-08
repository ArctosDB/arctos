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
		select cat_num from cataloged_item,loan_item where cataloged_item.collection_object_id=loan_item.collection_object_id
		and loan_item.transaction_id=#transaction_id#
	</cfquery>
	<cfif loan_number is "1993.001.Mamm">
		<br>kidney
	<cfelseif loan_number is "1993.012.Mamm">
		<br>feces (ethanol) - create if part doesn't exist
	<cfelseif loan_number is "1993.014.Mamm">
		<br>heart
	<cfelseif loan_number is "1993.021.Mamm">
		<br>muscle
	<cfelseif loan_number is "1993.024.Mamm">
		<br>random tissue 
	<cfelseif loan_number is "1993.027.Mamm">
		<br>skins, skulls and skeletons
	<cfelseif loan_number is "1993.028.Mamm">
		<br>liver
	<cfelseif loan_number is "1993.029.Mamm">
		<br>liver
	<cfelseif loan_number is "1993.033.Mamm">
		<br>heart
	<cfelseif loan_number is "1993.038.Mamm">
		<br>skull
	<cfelseif loan_number is "1994.002.Mamm">
		<br>tissues
	<cfelseif loan_number is "1994.004.Mamm">
		<br>stomach (ethanol) - create these parts 	
	<cfelseif loan_number is "1994.005.Mamm">
		<br>skull, skeleton 
	<cfelseif loan_number is "1994.008.Mamm">
		<br>heart
	<cfelseif loan_number is "1994.009.Mamm">
		<br>skull, skeleton
	<cfelseif loan_number is "1994.011.Mamm">
		<br>tissues
	<cfelseif loan_number is "1994.012.Mamm">
		<br>muscle
	<cfelseif loan_number is "1994.015.Mamm">
		<br>muscle
	<cfelseif loan_number is "1994.017.Mamm">
		<br>muscle
	<cfelseif loan_number is "1994.019.Mamm">
		<br>skull, skeleton, skin
	<cfelseif loan_number is "1994.033.Mamm">
		<br>blood
	<cfelseif loan_number is "1994.034.Mamm">
		<br>skull, skin 
	<cfelseif loan_number is "1994.040.Mamm">
		<br>skull
	<cfelseif loan_number is "1994.042.Mamm">
		<br>liver
	<cfelseif loan_number is "1994.044.Mamm">
		<br>skull
	<cfelseif loan_number is "1994.045.Mamm">
		<br>skull
	<cfelseif loan_number is "1994.048.Mamm">
		<br>skeleton
	<cfelseif loan_number is "1994.049.Mamm">
		<br>tissues
	<cfelseif loan_number is "1994.052.Mamm">
		<br>skull, skel, skin
	</cfif>
	 


	<cfloop query="sp">
		<br>#cat_num#
	</cfloop>
</cfloop>
</cfoutput>
