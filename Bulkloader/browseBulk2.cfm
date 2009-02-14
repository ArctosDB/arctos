<cfinclude template="/includes/alwaysInclude.cfm">
<cfif #action# IS "nothing">
<cfoutput>
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

<cfquery name="ctAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select accn from bulkloader where enteredby in (#preservesinglequotes(entBy)#) group by accn order by accn
</cfquery>
<span style="font-size:smaller; font-style:italic;">
	You are in the #grpMembership# group, reviewing records entered by the #DEgrp# group. 
	<br />Group Members are: #replace(entBy,"'"," ","all")#
</span>

<p>Filter records in bulkloader to:</p>


<form name="f" method="post" action="browseBulk2.cfm">
	<input type="hidden" name="action" value="viewTable" />
	<label for="enteredby">Entered By</label>
	<select name="enteredby" multiple="multiple" size="4" id="enteredby">
		<option value="#entBy#" selected>All</option>
		<cfloop query="entGrp">
			<option value="'#agent_name#'">#agent_name#</option>
		</cfloop>
	</select>
	<label for="accn">Accession</label>
	<select name="accn" multiple="multiple" size="10" id="accn">
		<option value="" selected>All</option>
		<cfloop query="ctAccn">
			<option value="'#accn#'">#accn#</option>
		</cfloop>
	</select>
	<br /><input type="submit" 
				value="View Table"
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'">
</form>
</cfoutput>
</cfif>
<!-------------------------->
<cfif #action# is "saveGridUpdate">
<cfoutput>
<cfquery name="cNames" datasource="#Application.uam_dbo#">
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
<cflocation url="browseBulk2.cfm?action=viewTable&enteredby=#enteredby#&accn=#accn#">
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "upBulk">
<cfoutput>
	<cfif len(#loaded#) gt 0 and
		len(#column_name#) gt 0 and
		len(#tValue#) gt 0>	
		<cfset sql="UPDATE bulkloader SET LOADED = ">
		<cfif #loaded# is "NULL">
			<cfset sql="#sql# NULL">
		<cfelse>
			<cfset sql="#sql# '#loaded#'">
		</cfif>
			<cfset sql="#sql# WHERE #column_name#	=
			'#trim(tValue)#' AND
			enteredby IN (#enteredby#)">
		<cfif len(#accn#) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
			#preservesinglequotes(sql)#
		<!---
		
		--->
		<cfabort>
		<cfquery name="upBulk" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfif>

<cflocation url="browseBulk2.cfm?action=viewTable&enteredby=#enteredby#&accn=#accn#">
		
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "viewTable">
<cfoutput>
<cfinclude template="/includes/_header.cfm">
<!--- no security --->
<cfset sql = "select * from bulkloader
	where enteredby IN (#enteredby#)">
<cfif len(#accn#) gt 0>
	<!----
	<cfset thisAccnList = "">
	<cfloop list="#accn#" index="a" delimiters=",">
		<cfif len(#thisAccnList#) is 0>
			<cfset thisAccnList = "'#a#'">
		<cfelse>
			<cfset thisAccnList = "#thisAccnList#,'#a#'">
		</cfif>
	</cfloop>
	<cfset sql = "#sql# AND accn IN (#preservesinglequotes(thisAccnList)#)">
	---->
	<cfset sql = "#sql# AND accn IN (#accn#)">
	
</cfif>
<cfquery name="data" datasource="#Application.uam_dbo#">
	#preservesinglequotes(sql)#	
</cfquery>
<cfquery name="cNames" datasource="#Application.uam_dbo#">
	select column_name from user_tab_cols where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<div style="background-color:##FFFFCC;">
Roll yer own:
<cfset columnList = "SPEC_LOCALITY,HIGHER_GEOG,ENTEREDBY,LOADED">

<form name="bulkStuff" method="post" action="browseBulk2.cfm">
	<input type="hidden" name="action" value="upBulk" />
	<input type="hidden" name="enteredby" value="#enteredby#" />
	<input type="hidden" name="accn" value="#accn#" />
	UPDATE bulkloader SET LOADED = 
	<select name="loaded" size="1">
		<option value="NULL">NULL</option>
		<option value="FLAGGED BY BULKLOADER EDITOR">FLAGGED BY BULKLOADER EDITOR</option>
		<option value="MARK FOR DELETION">MARK FOR DELETION</option>
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
				value="Update All Matches"
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
</form>
</div>
<hr />
<span style="background-color:##FF0000">
	NOTE: This button will load ALL marked records, not just those you see in this grid.
	<br />
	<input type="button" value="Load Marked Records" onclick="document.location='/Bulkloader/Bulkloader.cfm?action=loadData'" />

</span>
<cfset ColNameList = valuelist(cNames.column_name)>
<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
<!---
<cfset ColNameList = replace(ColNameList,"LOADED","","all")>
<cfset ColNameList = replace(ColNameList,"ENTEREDBY","","all")>
--->
<hr />There are #data.recordcount# records in this view.
<cfform method="post" action="browseBulk2.cfm">
	<cfinput type="hidden" name="action" value="saveGridUpdate">
	<cfinput type="hidden" name="enteredby" value="#enteredby#">
	<cfinput type="hidden" name="accn" value="#accn#">
	<cfgrid query="data"  name="blGrid" width="1200" height="400" selectmode="edit" rowheaders="yes">
		<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=editEnterData&ImAGod=yes&pMode=edit" hrefkey="collection_object_id" target="_blank">
		<!----
		<cfgridcolumn name="loaded" select="yes">
		<cfgridcolumn name="ENTEREDBY" select="yes">
		---->
		<cfloop list="#ColNameList#" index="thisName">
			<cfgridcolumn name="#thisName#">
		</cfloop>
	<cfinput type="submit" name="save" value="Save Changes In Grid">
	</cfgrid>
</cfform>

</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">