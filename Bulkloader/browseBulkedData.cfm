<cfif #action# is "remTheseLoaded">
	<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
	<cfoutput>
		<cfquery name="clearFlag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update bulkloader set loaded = null where collection_object_id IN ( #collection_object_id# )
		</cfquery>
	</cfoutput>	
	</cfif>
	<cfif isdefined("remThisId") and len(#remThisId#) gt 0>
	<cfoutput>
		<cfquery name="MAKEfLAG" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update bulkloader set loaded = 'FLAGGED BY BULKLOADER EDITOR' where collection_object_id IN ( #remThisId# )
		</cfquery>		
	</cfoutput>	
	</cfif>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "upBulk">
<cfoutput>
	<cfif len(#loaded#) gt 0 and
		len(#column_name#) gt 0 and
		len(#tValue#) gt 0>	
		<cfset sql="UPDATE bulkloader SET LOADED = '#loaded#'
			WHERE #column_name#	=
			'#trim(tValue)#'">
			#preservesinglequotes(sql)#
			<br />
			#entBy#
		<!---
		<cfquery name="upBulk" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
		--->
	</cfif>

</cfoutput>
</cfif>
<!---------------------------------------------------->

<cfinclude template="/includes/_pickHeader.cfm">
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
<cfoutput>
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
</cfoutput>

<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<br />
<div style="background-color:#FFFFCC;">
Roll yer own:
<cfset columnList = "SPEC_LOCALITY,HIGHER_GEOG,ENTEREDBY,LOADED">

<cfoutput>
<form name="bulkStuff" method="post" action="browseBulkedData.cfm">
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
</cfoutput>
<form name="remLoaded" method="post" action="browseBulkedData.cfm">
<input type="submit" 
				value="Change Marked Records"
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">



<cfif not isdefined("order_by") or len(#order_by#) is 0>
	<cfset order_by = "collection_object_id">
</cfif>
<cfif not isdefined("order_order") or len(#order_order#) is 0>
	<cfset order_order = "ASC">
</cfif>
<cfoutput>
<cfset sql = "select * from bulkloader
	where enteredby IN (#entBy#)">
<cfset sql = "#sql# 	 
	ORDER BY #order_by# #order_order#">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#	
</cfquery>
<cfset rowNum = 1>
<table border cellpadding="0" cellspacing="0">
	<tr>
	
		<cfloop query="getCols">
			<td><span style="font-size:10px">
				<cfif #column_name# is "collection_object_id">ID<cfelse>#column_name#
			<a href="##" 
				onClick="remLoaded.order_by.value='#column_name#';remLoaded.order_order.value='asc';remLoaded.submit();">
				<img src="/images/up.gif" border="0"></a>
			<a href="##" 
				onClick="remLoaded.order_by.value='#column_name#';remLoaded.order_order.value='desc';remLoaded.submit();">
				<img src="/images/down.gif" border="0"></a>
				</cfif>
				</span>
			</td>
		</cfloop>
	</tr>
	
		<input name="action" type="hidden" value="remTheseLoaded" />
		<input name="order_by" type="hidden" />
		<input name="order_order" type="hidden" />
		
		
	<cfloop query="data">
		<cfset thisCollObjId = #collection_object_id#>
		<cfquery name="thisRec" dbtype="query">
			select * from data where collection_object_id=#collection_object_id#
		</cfquery>
		<tr 
			<cfif len(#thisRec.loaded#) is 0> bgcolor="##00FF00"</cfif> 
			class="likeLink" 
			onclick="window.open('/DataEntryStage.cfm?action=editEnterData&ImAGod=yes&collection_object_id=#thisRec.collection_object_id#','_blank');"
			 >
			<cfloop query="getCols">
				<cfset thisData = evaluate("thisRec." & column_name)>
				<td nowrap="nowrap">
					<cfif #column_name# is "loaded">
						<cfif len(#thisData#) gt 0>
						<span style="background-color:##00FF00">
							Allow Load?&nbsp;<input type="checkbox" name="collection_object_id" value="#thisRec.collection_object_id#" />
						</span>
						<cfelse>
						<span style="background-color:##FF0000">
							Block Load?&nbsp;<input type="checkbox" name="remThisId" value="#thisRec.collection_object_id#" />
						</span>						
						</cfif>
						#thisData#&nbsp;
					<cfelse>
						#thisData#&nbsp;
					</cfif>
				</td>
			</cfloop>
		</tr>
	</cfloop>
	<tr>
		<td colspan="99" align="left">
			<input type="submit"/>
		</td>
	</tr>
	</form>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">