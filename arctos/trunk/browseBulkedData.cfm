<cfinclude template="/includes/_pickHeader.cfm">
<!--- no security --->
<cfquery name="u" datasource="#Application.web_user#">
	select grp.agent_name
	from
		preferred_agent_name grp,
		agent_name usr,
		group_member
		where
		grp.agent_id=group_member.GROUP_AGENT_ID and
		group_member.MEMBER_AGENT_ID = usr.agent_id and
		usr.agent_name='#client.username#'
</cfquery>
<cfoutput>
	you are a member of group #u.agent_name#
	<hr />
</cfoutput>


<cfif not isdefined("seeAll") or len(#seeAll#) is 0>
	<cfset seeALl = "no">
</cfif>
<cfif #action# is "remTheseLoaded">
	<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
	<cfoutput>
		<cfquery name="clearFlag" datasource="#Application.web_user#">
			update bulkloader set loaded = null where collection_object_id IN ( #collection_object_id# )
		</cfquery>
	</cfoutput>	
	</cfif>
	<cfif isdefined("remThisId") and len(#remThisId#) gt 0>
	<cfoutput>
		<cfquery name="MAKEfLAG" datasource="#Application.web_user#">
			update bulkloader set loaded = 'FLAGGED BY BULKLOADER EDITOR' where collection_object_id IN ( #remThisId# )
		</cfquery>		
	</cfoutput>	
	</cfif>
	
	
</cfif>



<form name="remLoaded" method="post" action="browseBulkedData.cfm">
reordering will clean up marked records.  Default is only unloaded records that at not ready to be loaded. Records marked to load are green.

<p></p>View All Records? <input <cfif #seeAll# is "yes"> checked </cfif>type="checkbox" name="seeAll" value="yes" />
<br /><input type="submit" />

<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfif not isdefined("order_by") or len(#order_by#) is 0>
	<cfset order_by = "collection_object_id">
</cfif>
<cfif not isdefined("order_order") or len(#order_order#) is 0>
	<cfset order_order = "ASC">
</cfif>
<cfoutput>
<cfquery name="data" datasource="#Application.web_user#">
	select * from bulkloader
	<cfif #seeAll# neq "yes">
	 where 
	 (loaded <> 'Success!') AND (loaded is not null)
	ORDER BY #order_by# #order_order#
	</cfif>
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
		<tr <cfif len(#thisRec.loaded#) is 0> bgcolor="##00FF00"</cfif> >
			<cfloop query="getCols">
				<cfset thisData = evaluate("thisRec." & column_name)>
				<td nowrap="nowrap">
					<cfif #column_name# is "collection_object_id">
						<a href="/DataEntryStage.cfm?action=editEnterData&ImAGod=yes&collection_object_id=#thisData#" 
							target="_blank">#thisData#&nbsp;</a>
						
					<cfelseif #column_name# is "loaded">
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