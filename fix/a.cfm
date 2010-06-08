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
	<hr>
	#loan_number# #transaction_id#<br>
	<cfquery name="sp" datasource="uam_god">
		select cat_num from cataloged_item,loan_item where cataloged_item.collection_object_id=loan_item.collection_object_id
		and loan_item.transaction_id=#transaction_id#
	</cfquery>
	<cfif loan_number is "1993.001.Mamm">
		<cfset usepart="kidney">
	<cfelseif loan_number is "1993.012.Mamm">
		<cfset usepart="feces (ethanol)">
	<cfelseif loan_number is "1993.014.Mamm">
		<cfset usepart="heart">
	<cfelseif loan_number is "1993.021.Mamm">
		<cfset usepart="muscle">
	<cfelseif loan_number is "1993.024.Mamm">
		<cfset usepart="tissues">
	<cfelseif loan_number is "1993.027.Mamm">
		<cfset usepart="skin, skull, skeleton">
	<cfelseif loan_number is "1993.028.Mamm">
		<cfset usepart="liver">
	<cfelseif loan_number is "1993.029.Mamm">
		<cfset usepart="liver">
	<cfelseif loan_number is "1993.033.Mamm">
		<cfset usepart="heart">
	<cfelseif loan_number is "1993.038.Mamm">
		<cfset usepart="skull">
	<cfelseif loan_number is "1994.002.Mamm">
		<cfset usepart="tissues">
	<cfelseif loan_number is "1994.004.Mamm">
		<cfset usepart="stomach (ethanol)"> 	
	<cfelseif loan_number is "1994.005.Mamm">
		<cfset usepart="skull, skeleton"> 
	<cfelseif loan_number is "1994.008.Mamm">
		<cfset usepart="heart">
	<cfelseif loan_number is "1994.009.Mamm">
		<cfset usepart="skull, skeleton">
	<cfelseif loan_number is "1994.011.Mamm">
		<cfset usepart="tissues">
	<cfelseif loan_number is "1994.012.Mamm">
		<cfset usepart="muscle">
	<cfelseif loan_number is "1994.015.Mamm">
		<cfset usepart="muscle">
	<cfelseif loan_number is "1994.017.Mamm">
		<cfset usepart="muscle">
	<cfelseif loan_number is "1994.019.Mamm">
		<cfset usepart="skull, skeleton, skin">
	<cfelseif loan_number is "1994.033.Mamm">
		<cfset usepart="blood">
	<cfelseif loan_number is "1994.034.Mamm">
		<cfset usepart="skull, skin"> 
	<cfelseif loan_number is "1994.040.Mamm">
		<cfset usepart="skull">
	<cfelseif loan_number is "1994.042.Mamm">
		<cfset usepart="liver">
	<cfelseif loan_number is "1994.044.Mamm">
		<cfset usepart="skull">
	<cfelseif loan_number is "1994.045.Mamm">
		<cfset usepart="skull">
	<cfelseif loan_number is "1994.048.Mamm">
		<cfset usepart="skeleton">
	<cfelseif loan_number is "1994.049.Mamm">
		<cfset usepart="tissues">
	<cfelseif loan_number is "1994.052.Mamm">
		<cfset usepart="skull, skeleton, skin">
	<cfelse>
		<cfset usepart='WHATEVER'>
	</cfif>
	<br>going to use part #usepart#


	<cfloop query="sp">
		<br>#cat_num#
	</cfloop>
</cfloop>
</cfoutput>
