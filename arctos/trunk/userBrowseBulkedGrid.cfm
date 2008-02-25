<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">

<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfoutput>
<cfquery name="data" datasource="#Application.web_user#">
	select * from bulkloader
	where enteredby = '#client.username#'
</cfquery>
<cfset ColNameList = valuelist(getCols.column_name)>
<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
<cfset ColNameList = replace(ColNameList,"LOADED","","all")>
<cfset ColNameList = replace(ColNameList,"ENTEREDBY","","all")>
<cfform method="post" action="userBrowseBulkedGrid.cfm" >
	<cfinput type="hidden" name="action" value="saveGridUpdate">
	<cfgrid query="data"  name="blGrid" width="1200" height="400" selectmode="edit">
		<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=editEnterData&pMode=edit" hrefkey="collection_object_id" target="_blank">
		<cfgridcolumn name="loaded" select="no">
		<cfgridcolumn name="ENTEREDBY" select="no">
		<cfloop list="#ColNameList#" index="thisName">
			<cfgridcolumn name="#thisName#">
		</cfloop>
	</cfgrid>
	<br>
	<cfinput type="submit" name="save" value="Save Changes In Grid">
</cfform>
</cfoutput>


</cfif>

<cfif #action# is "saveGridUpdate">
<cfoutput>
<cfquery name="cNames" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER'
</cfquery>
<cfset ColNameList = valuelist(cNames.column_name)>
<cfset GridName = "blGrid">
<cfset numRows = #ArrayLen(form.blGrid.rowstatus.action)#>
<p></p>there are	#numRows# rows updated
<!--- loop for each record --->
<cfloop from="1" to="#numRows#" index="i">
	<!--- and for each column --->
	<cfset thisCollObjId = evaluate("Form.#GridName#.collection_object_id[#i#]")>
	<cfset sql ='update BULKLOADER SET collection_object_id = #thisCollObjId#'>
	<cfloop index="ColName" list="#ColNameList#">
		<cfset oldValue = evaluate("Form.#GridName#.original.#ColName#[#i#]")>
		<cfset newValue = evaluate("Form.#GridName#.#ColName#[#i#]")>
		<cfif #oldValue# neq #newValue#>
			<cfset sql = "#sql#, #ColName# = '#newValue#'">
		</cfif>
	</cfloop>
	
		<cfset sql ="#sql# WHERE collection_object_id = #thisCollObjId#">

	<cfquery name="up" datasource="#Application.uam_dbo#">
		#preservesinglequotes(sql)#
	</cfquery>
	


	

</cfloop>
	<cflocation url="userBrowseBulkedGrid.cfm" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">