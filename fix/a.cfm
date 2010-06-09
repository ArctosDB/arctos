<cfoutput >
<cfif not isdefined("action") ><cfset action="nothing"></cfif>
<cfif action is "nothing">
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
	<a href="a.cfm?action=l&transaction_id=#transaction_id#&loan_number=#loan_number#">#loan_number#</a><br>
</cfloop>
</cfif>
<cfif action is "l">
	<a href="/Loan.cfm?transaction_id=#transaction_id#&Action=editLoan">#loan_number#</a>
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
		<cfset usepart=''>
	</cfif>
	<cfif not isdefined("pickedpart")>
		<cfset pickedpart="">
	</cfif>
	
	<cfquery name="pn" datasource="uam_god">
		select part_name from ctspecimen_part_name where collection_cde='Mamm' order by part_name
	</cfquery>
	<br>part is supposed to be #usepart#
	<form name="b" action="a.cfm" method="post">
		<input type="hidden" name="action" value="l">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="loan_number" value="#loan_number#">
		<select name="pickedpart">
			<cfloop query="pn">
				<option <cfif pickedpart is part_name> selected="selected" </cfif>value='#part_name#'>#part_name#</option>
			</cfloop>
		</select>
		<input type="submit">
	</form>
	
	<cfquery name="cat" datasource="uam_god">
		select 
			cat_num,
			cataloged_item.collection_object_id,
			concatparts(cataloged_item.collection_object_id) parts
		from cataloged_item,loan_item where cataloged_item.collection_object_id=loan_item.collection_object_id
		and loan_item.transaction_id=#transaction_id#
	</cfquery>
	
	<form name="a" action="a.cfm" method="post">
		<input type="hidden" name="action" value="addparts">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="loan_number" value="#loan_number#">
		<select name="part">
			<cfloop query="pn">
				<option value='#part_name#'>#part_name#</option>
			</cfloop>
		</select>
	<cfloop query="cat">
		<input type="hidden" name="catid" value="#collection_object_id#">
		<!---
		<cfif len(usepart) gt 0>
			<cfquery name="sp" datasource="uam_god">
				select part_name from specimen_part where part_name='#pickedpart#' and
				derived_from_cat_item=#collection_object_id#
				group by part_name
			</cfquery>
			<cfif sp.recordcount is 0>
				<cfquery name="sp" datasource="uam_god">
					select part_name from specimen_part where part_name like '%#pickedpart#%' and
					derived_from_cat_item=#collection_object_id#
				</cfquery>
				<cfif sp.recordcount is 0>
					<br>still not found
				</cfif>
			</cfif>
		<cfelse>
			<cfquery name="sp" datasource="uam_god">
				select 'WWWWWWWWWWWW' part_name from specimen_part where part_name='#usepart#' and
				derived_from_cat_item=#collection_object_id#
			</cfquery>
		</cfif>
		--->
		<br>#cat_num# ---- #parts#
	</cfloop>
	<input type="submit">
	
	</form>
</cfif>
<cfif action is "addparts">
	<cfdump var="#form#">
	<cfloop list="#catid#" index="i">
		<cfquery name="sp" datasource="uam_god">
			select part_name from specimen_part where part_name = '#part_name#' and
			derived_from_cat_item=#i#
		</cfquery>
		<cfif sp.recordcount is 1>
			<br>found a part
		<cfelse>
			<br>makin a part
		</cfif>
	</cfloop>
</cfif>

</cfoutput>
