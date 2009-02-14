 
 
 <cfif not isdefined("transaction_id")>
	<cfabort>
</cfif>
<cfif not isdefined("Action")>
	<cfset Action = "nothing">
</cfif>

<cfquery name="thisLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from loan, trans where loan.transaction_id = trans.transaction_id and trans.transaction_id=#transaction_id#
	</cfquery>
	
	<cfoutput query="thisLoan">
<br>Find items to add to loan #loan_num_prefix#.#loan_num#.#loan_num_suffix#
	</cfoutput>
	
	<cfform name="findCatItems" action="LoanItem.cfm" method="post" >
		<cfoutput>
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="action" value="search">
		</cfoutput>
		<cfquery name="collections" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_cde from ctCollection_Cde order by collection_cde
		</cfquery>
		<p>Collection: <select name="collection_cde" size="1">
			<option value=""></option>
			<cfoutput query="collections"> 
				<option value="#collections.collection_cde#">#collections.collection_cde#</option>
			</cfoutput> 
		</select>
		<br>Cat Num:<input type="text" name="catnum" value="50000">
		<br>AF Num:<input type="text" name="afnum">
		<br>Part Name:
			<cfquery name="Part" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select distinct(part_name) from specimen_part order by part_name
			</cfquery>
			<select name="Part_name" size="1">
          		<option value=""></option>
          		<cfoutput query="Part"> 
          			<option value="#Part.Part_Name#">#Part.Part_Name#</option>
          		</cfoutput> </select>
		<input type="submit" value="Search">
	</cfform>



<!---------------------------------------------------------------------------------------------->
<cfif #Action# is "search">
<cfset sql = " SELECT cataloged_item.collection_object_id as collection_object_id,
	specimen_part.collection_object_id as partID,
	cat_num,af_num.af_num,scientific_name,collection_cde, part_name, tissue_type FROM identification,
	cataloged_item,taxonomy, specimen_part, af_num
	WHERE  identification.taxon_name_id = taxonomy.taxon_name_id 
	AND cataloged_item.collection_object_id = identification.collection_object_id
	AND identification.accepted_id_fg = 1
	AND  cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+)
	AND  cataloged_item.collection_object_id = af_num.collection_object_id (+)
	">
	<cfset basQual = "">
	
	<cfif isdefined("collection_cde") AND #collection_cde# is not ""><!--- will also fire if null ---->
	<cfset basQual = "#basQual#  AND cataloged_item.collection_cde = '#collection_cde#'" >
</cfif>

<cfif isdefined("catnum") AND isnumeric(#catnum#)>
	<cfset basQual = " #basQual# AND cat_num = #catnum#" >
</cfif>

<cfif isdefined("part_name") AND len(#part_name#) gt 0>
	<cfset basQual = " #basQual# AND Part_Name LIKE '#part_name#'">
</cfif>

<cfif isdefined("afnum") AND isnumeric(#afnum#)>
	<cfset basQual = " #basQual# AND af_num.af_num = #afnum#" >
</cfif>

<cfset SqlString = #sql# & #basQual# & " ORDER BY collection_object_id">

<cfquery name="getData" datasource = "#Application.web_user#" >
#preserveSingleQuotes(SqlString)#
</cfquery>



<cfquery name="getPart" dbtype="query">
select partID,cat_num,af_num,scientific_name,collection_cde,part_name from getData group by
partID,cat_num,af_num,scientific_name,collection_cde,part_name 
</cfquery>

<cfform name="loanItemPick" method="post" action="LoanItemList.cfm" target="_loanItemList">
<table border><tr><td>
<cfoutput query="getData" group="collection_object_id">
<tr><td colspan="3" bgcolor="##999999">
<br>#cat_num# #af_num# #scientific_name# #collection_cde# 
</tr></td>
	<cfquery name="getPart" dbtype="query">
		select partID,part_name 
		from getData 
		where collection_object_id = #collection_object_id#
		group by
		partID,part_name
	</cfquery>
	
	<cfloop query="getPart">
		<cfif len(#partid#) gt 0>
			<tr bgcolor="##00FF00">
			<td><br>&nbsp;&nbsp;&nbsp;#part_name#(#partid#)</td>
			<td><input type="checkbox" name="item" value="#partID#"></td>
			<td><input type="checkbox" name="subsample" value="#partID#"></td>
			</tr>		
		</cfif>
	</cfloop>
	
</cfoutput>
</td></tr></table>
<hr>
<input type="submit">


</cfform>

</cfif>

<cfif #Action# is "list">
<cfoutput>
#item#
<br>#subsample#
</cfoutput>

</cfif>

<!---------------------------------------------------------------------------------------------->