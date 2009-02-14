<cfif #action# is "saveGridUpdate">
<cfoutput>
<cfquery name="cNames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
</cfloop>
<cflocation url="betterBrowseBulkedData.cfm">
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "upBulk">
<cfoutput>
	<cfif len(#loaded#) gt 0 and
		len(#column_name#) gt 0 and
		len(#tValue#) gt 0>	
		<cfset sql="UPDATE bulkloader SET LOADED = '#loaded#'
			WHERE #column_name#	=
			'#trim(tValue)#' AND
			enteredby IN (#entBy#)">
			#preservesinglequotes(sql)#
		<!---
		
		--->
		<cfquery name="upBulk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfif>


		<cflocation url="betterBrowseBulkedData.cfm">
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "nothing">
<cfoutput>
<cfinclude template="/includes/_header.cfm">
<!--- no security --->
<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select grp.agent_name
	from
		preferred_agent_name grp,
		agent_name usr,
		group_member
		where
		grp.agent_id=group_member.GROUP_AGENT_ID and
		group_member.MEMBER_AGENT_ID = usr.agent_id and
		usr.agent_name='#session.username#' and
		grp.agent_name like '%Data Admin%'
</cfquery>
<cfif #u.recordcount# is 1>
	<cfset grpMembership = "#u.agent_name#">
	<!--- figure out who's records they should see based on enteredby 
		first 8 characters (eg, "UAM Data") should match between groups
	--->
	<cfset DEgrp = left(u.agent_name,8)>
	<cfset DEgrp = "#DEgrp# Entry">
	<cfquery name="entGrp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select usr.agent_name
	from
		preferred_agent_name grp,
		agent_name usr,
		group_member
		where
		grp.agent_id=group_member.GROUP_AGENT_ID and
		group_member.MEMBER_AGENT_ID = usr.agent_id AND
		usr.agent_name_type='login' AND
		grp.agent_name = '#DEgrp#'
	</cfquery>
<cfelse>
	<cfset grpMembership = "">
	You are not a member of the appropriate groups!
	<cfabort>
</cfif>
<cfset entBy = "">
<cfloop query="entGrp">
	<cfif len(#entBy#) is 0>
		<cfset entBy = "'#agent_name#'">
	<cfelse>
		<cfset entBy = "#entBy#,'#agent_name#'">
	</cfif>
</cfloop>
<span style="font-size:10px; font-style:italic;">
	You are in the #grpMembership# group, reviewing records entered by the #DEgrp# group. Members are: #entBy#
</span>
<cfset sql = "select * from bulkloader
	where enteredby IN (#entBy#)">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#	
</cfquery>
<cfquery name="cNames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select column_name from user_tab_cols where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<div style="background-color:##FFFFCC;">
Roll yer own:
<cfset columnList = "SPEC_LOCALITY,HIGHER_GEOG,ENTEREDBY,LOADED">

<form name="bulkStuff" method="post" action="betterBrowseBulkedData.cfm">
	<input type="hidden" name="action" value="upBulk" />
	<input type="hidden" name="entBy" value="#entBy#" />
	UPDATE bulkloader SET LOADED = 
	<select name="loaded" size="1">
		<option value="">NULL</option>
		<option value="FLAGGED BY BULKLOADER EDITOR">FLAGGED BY BULKLOADER EDITOR</option>
	</select>
	<br />WHERE
	<select name="column_name" size="1">
		<CFLOOP list="#columnList#" index="i">
			<option value="#i#">#i#</option>
		</CFLOOP>
	</select>
	= TRIM(
	<input type="text" name="tValue" size="50" />)
	<br />
	<input type="submit" 
				value="Go"
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
</form>
</div>
<cfset ColNameList = valuelist(cNames.column_name)>
<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
<cfset ColNameList = replace(ColNameList,"LOADED","","all")>

<cfform method="post" action="betterBrowseBulkedData.cfm">
	<cfinput type="hidden" name="action" value="saveGridUpdate">
	<cfgrid query="data"  name="blGrid" width="1200" height="400" selectmode="edit" rowheaders="yes">
		<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=editEnterData&ImAGod=yes&pMode=edit" hrefkey="collection_object_id" target="_blank">
		<cfgridcolumn name="loaded" select="yes">
		<cfloop list="#ColNameList#" index="thisName">
			<cfgridcolumn name="#thisName#">
		</cfloop>
	<cfinput type="submit" name="save" value="Save Changes In Grid">
	</cfgrid>
</cfform>

</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">