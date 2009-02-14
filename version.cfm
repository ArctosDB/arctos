<!--- no security --->

<cfinclude template="/includes/_header.cfm">
<cfoutput>
	Current version: #session.arctos_version#
</cfoutput>
<cfif #action# is "nothing">
<cfquery name="vsns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_version order by release_date desc
</cfquery>
<cfoutput>
<br>
<a href="version.cfm?action=new">Create New Version</a>
<br>
<cfloop query="vsns">
<a href="version.cfm?action=edit&version_id=#version_id#">#version_number#</a> (released #dateformat(release_date,"dd mmm yyyy")#)<br>
	
</cfloop>
</cfoutput>
</cfif>
<cfif #action# is "new">
	New Version:
	<form name="new" method="post" action="version.cfm">
		<input type="hidden" name="action" value="addNew">
		 <label for="VERSION_NUMBER">Version Number</label>
		 <input type="text" name="VERSION_NUMBER" id="VERSION_NUMBER">
		 <label for="RELEASE_DATE">Release Date</label>
		 <input type="text" name="RELEASE_DATE" id="RELEASE_DATE">
		 <label for="VERSION_REMARKS">Remarks</label>
		 <input type="text" name="VERSION_REMARKS" id="VERSION_REMARKS">
		 <br>
		  <input type="submit" value="Create Version" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
	</form>
</cfif>
<cfif #action# is "edit">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cf_version.version_id,
			version_number,
			release_date,
			version_remarks,
			version_log_id,
			change_description,
			made_agent_id,
			change_date,
			agent_name	as made_agent	
		 from cf_version
		left outer join	cf_version_log	on (cf_version.version_id = cf_version_log.version_id)
		left outer join	preferred_agent_name	on (cf_version_log.made_agent_id = preferred_agent_name.agent_id)
		where
		cf_version.version_id = #version_id#
		order by change_date
	</cfquery>
	<cfquery name="tv" dbtype="query">
		select
			version_id,
			version_number,
			release_date,
			version_remarks
		from d
		group by
			version_id,
			version_number,
			release_date,
			version_remarks
	</cfquery>
	<table border>
		<tr>
			<td>
			
	<form name="editVers" method="post" action="version.cfm">
		<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="version_id" value="#tv.version_id#">
		 <label for="VERSION_NUMBER">Version Number</label>
		 <input type="text" name="VERSION_NUMBER" id="VERSION_NUMBER" value="#tv.version_number#">
		 <label for="RELEASE_DATE">Release Date</label>
		 <input type="text" name="RELEASE_DATE" id="RELEASE_DATE" value="#dateformat(tv.release_date,'dd-mmm-yyyy')#">
		 <label for="VERSION_REMARKS">Remarks</label>
		 <textarea name="VERSION_REMARKS" id="VERSION_REMARKS" rows="4" cols="20">#tv.VERSION_REMARKS#</textarea>	
		 <br>
		 <input type="submit" value="Save Changes" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
	</form>
	</td>
		
			<td valign="top">
			Add Change:
				<table>
				<tr  class="newRec">
				<form name="newEvent" method="post" action="version.cfm">
					<input type="hidden" name="action" value="addEvent">
					<input type="hidden" name="version_id" value="#tv.version_id#">
					<td>
					<label for="change_description">Description</label>
					<input type="text" class="reqdClr" name="change_description" id="change_description" size="50">
					</td>
					<td>
					<label for="change_date">Date</label>
					<input type="text" class="reqdClr" name="change_date" id="change_date" value="#dateformat(now(),'dd-mmm-yyyy')#">
					</td>
					<td>
					<label for="made_agent">Made By</label>
					<input type="hidden" name="made_agent_id" id="made_agent_id"/>
							<input type="text" name="made_agent" id="made_agent"
								class="reqdClr" 
								onchange="getAgent('made_agent_id','made_agent','newEvent',this.value); return false;" />
					</td>
					<td>
					<input type="submit" value="Save New" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
				</form>
				</td></tr>
				<tr>
					<td colspan="4"><!--- just a spacer --->Existing Changes:</td>
				</tr>
				<cfset i=1>
				<cfloop query="d">
					<form name="chgEvent#i#" method="post" action="version.cfm">
					<input type="hidden" name="action" value="editEvent">
					<input type="hidden" name="version_id" value="#tv.version_id#">
					<input type="hidden" name="version_log_id" value="#version_log_id#">
					<tr>
						
						<td>
						<input type="text" class="reqdClr" name="change_description" id="change_description" size="50" value="#change_description#">
						</td>
						<td>
						<input type="text" class="reqdClr" name="change_date" id="change_date" value="#dateformat(change_date,'dd-mmm-yyyy')#">
						</td>
						<td>
						<input type="hidden" name="made_agent_id" id="made_agent_id"  value="#made_agent_id#" />
								<input type="text" name="made_agent" id="made_agent"
								 value="#made_agent#"
									class="reqdClr" 
									onchange="getAgent('made_agent_id','made_agent','newEvent',this.value); return false;" />
						</td>
						<td>
						
					<input type="submit" value="Save" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
   					<input type="button" value="Delete" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
   onClick="chgEvent#i#.action.value='deleteEvent';submit();">
					</form>
					</tr>
						<cfset i=#i#+1>
				</cfloop>
				
				</table>
			</td>
		</tr>
	</table>
</cfoutput>	
</cfif>
<!---------------------------------------------------------------------->
<cfif #action# is "saveEdits">
	<cfoutput>
		<cfquery name="update" datasource="#Application.uam_dbo#">
			 update cf_version set
			 	VERSION_NUMBER = '#VERSION_NUMBER#'
				<cfif len(#RELEASE_DATE#) gt 0>
					,RELEASE_DATE = '#dateformat(RELEASE_DATE,"dd-mmm-yyyy")#'
				</cfif>
				<cfif len(#VERSION_REMARKS#) gt 0>
					,VERSION_REMARKS = '#VERSION_REMARKS#'
				</cfif>
				where VERSION_ID = #VERSION_ID#
		</cfquery>
		<cflocation url="version.cfm?action=edit&version_id=#version_id#">
	</cfoutput>
</cfif>

<!---------------------------------------------------------------------->
<cfif #action# is "deleteEvent">
	<cfoutput>
	<cfquery name="delEv" datasource="#Application.uam_dbo#">
		delete from cf_version_log where
		version_log_id = #version_log_id#
	</cfquery>
	<cflocation url="version.cfm?action=edit&version_id=#version_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------->

<cfif #action# is "addEvent">
<cfoutput>
<cftransaction>
	<cfquery name="nev" datasource="#Application.uam_dbo#">
		insert into cf_version_log (
			version_id,
			change_description,
			made_agent_id,
			change_date)
		values (
			#version_id#,
			'#change_description#',
			'#made_agent_id#',
			'#change_date#')
	</cfquery>
</cftransaction>
<cflocation url="version.cfm?action=edit&version_id=#version_id#">
</cfoutput>
</cfif>


<cfif #action# is "addNew">
<cfoutput>
insert into cf_version
				(VERSION_NUMBER
				<cfif len(#RELEASE_DATE#) gt 0>
					,RELEASE_DATE
				</cfif>
				<cfif len(#VERSION_REMARKS#) gt 0>
					,VERSION_REMARKS
				</cfif>
				) values (
				('#VERSION_NUMBER#',
				'#dateformat(RELEASE_DATE,"dd-mmm-yyyy")#'
				<cfif len(#VERSION_REMARKS#) gt 0>
					,'#VERSION_REMARKS#'
				</cfif>
				) 
	<cftransaction>
		<cfquery name="nv" datasource="#Application.uam_dbo#">
			insert into cf_version
				(VERSION_NUMBER
				<cfif len(#RELEASE_DATE#) gt 0>
					,RELEASE_DATE
				</cfif>
				<cfif len(#VERSION_REMARKS#) gt 0>
					,VERSION_REMARKS
				</cfif>
				) values (
				'#VERSION_NUMBER#'
				<cfif len(#RELEASE_DATE#) gt 0>
					,'#dateformat(RELEASE_DATE,"dd-mmm-yyyy")#'
				</cfif>
				<cfif len(#VERSION_REMARKS#) gt 0>
					,'#VERSION_REMARKS#'
				</cfif>
				) 
		</cfquery>
		<cfquery name="n" datasource="#Application.uam_dbo#">
			select cf_version_seq.currval id from dual
		</cfquery>
	</cftransaction>
	<cflocation url="version.cfm?action=edit&version_id=#n.id#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">