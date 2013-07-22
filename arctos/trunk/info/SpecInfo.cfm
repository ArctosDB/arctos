<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
<div align="left">
<cfif #subject# is "parts">
<cfquery name="id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			part_name,
			sampled_from_obj_id,
			condition,
			coll_obj_disposition,
			enteredPerson.agent_name enteredBy,
			editedPerson.agent_name editedBy,
			coll_object_entered_date,
			last_edit_date,
			lot_count
		FROM
			specimen_part,
			coll_object,
			preferred_agent_name enteredPerson,
			preferred_agent_name editedPerson			
		WHERE
			specimen_part.collection_object_id= coll_object.collection_object_id AND
			coll_object.entered_person_id = enteredPerson.agent_id (+) AND
			coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
			specimen_part.derived_from_cat_item= #thisId# 
		ORDER BY part_name
	</cfquery>
	<table border>
		<tr>
			<td><b>Part Name</b></td>
			<td><b>Condition</b></td>
			<td><b>Disposition</b></td>
			<td><b>Cnt</b></td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<td><b>Entered By</b></td>
				<td><b>Edited By</b></td>
			</cfif>
		</tr>
		<cfset i=1>
		<cfloop query="id">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				
				<td>#part_name#<cfif len(sampled_from_obj_id) gt 0>&nbsp;subsample</cfif>
				</td>
				<td>#condition#</td>
				<td>#coll_obj_disposition#&nbsp;</td>
				<td>#lot_count#&nbsp;</td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					<td>#enteredBy# on #dateformat(coll_object_entered_date,"yyyy-mm-dd")#</td>
					
					<td>#editedBy# on #dateformat(last_edit_date,"yyyy-mm-dd")#</td>
				</cfif>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfif>
</div>
</cfoutput>

<div align="right">
    <p><a href="javascript: void(0);" onClick="self.close();">Close this window</a></p>
</div>

<cfinclude template="/includes/_pickFooter.cfm">
<!----
<script>
	var contentHeight = document.clientHeight;
	var contentWidth = document.clientWidth;
	//var contentHeight = 200;
	//var contentWidth = 600;
	//var newHeight = contentHeight + 10;
	window.resizeTo(contentWidth,contentHeight);
</script>
---->