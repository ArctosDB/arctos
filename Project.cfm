<cfinclude template="includes/_header.cfm">

<script language="JavaScript" src="/includes/jquery/jquery.ui.core.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#start_date").datepicker();
			jQuery("#end_date").datepicker();
			jQuery("#ended_date").datepicker();	
		});		
	});
</script>
<cfquery name="ctProjAgRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select project_agent_role from ctproject_agent_role
</cfquery>

<cfif #Action# is "nothing">
<cfset title = "Search for Projects">
<table width="75%"><tr valign="top"><td>
<h2>Project Search</h2>
<table width="90%" border><tr><td>
Projects are activities that have contributed specimens, used specimens, or both.  For example, theses and expeditions.  From here you can find:
<ul>
	<li>Which specimens came from, and contributed to, different projects.</li>
	<li>Precisely how different projects have contributed to each other.</li>
	<li>Publications resulting from projects.</li>
</ul>
</td></tr></table>
</td>
<td>
<form action="ProjectList.cfm?src=proj" method="post">
<cfoutput>
<input name="Action" value="#Action#" type="hidden">
</cfoutput>
<table>
  <tr>
    <td>
		<label for="projTitle">Project Title</label>
		<input id="projTitle" name="projTitle" type="text"></td>
  </tr>
  <tr>
    <td>
		<label for="projParticipant">Participant Name</label>
		<input name="projParticipant" id="projParticipant" type="text"></td>
  </tr>
 <tr>
    <td>
		<label for="sponsor">Sponsor</label>
		<input name="sponsor" id="sponsor" type="text">
	</td>
  </tr>
  <tr>
    <td>
		<table>
			<tr>
				<td>
					<label for="begYear">Begin&nbsp;Year</label>
					<input name="begYear" id="begYear" type="text" size="5" maxlength="4">
				</td>
				<td>
					to
				</td>
				<td>
					<label for="endYear">Ended&nbsp;Year</label>
					<input name="endYear" id="endYear" type="text" size="5" maxlength="4">
				</td>
			</tr>
		</table>
	</td>
  </tr>
</table>
<cfoutput>
<input type="submit" 
	value="Search" 
	class="schBtn">	

<input type="reset" 
	value="Clear Form" 
	class="clrBtn">

			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
		<input type="button" 
	value="Create New Project" 
	class="insBtn"
    onmouseover="this.className='insBtn btnhov'" 
    onmouseout="this.className='insBtn'"
	onClick="window.open('Project.cfm?action=makeNew', '_self');">
	</cfif>
</cfoutput>
</form>
</td>
</tr></table>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "makeNew">
<strong>Create New Project:</strong>
<cfoutput>
<cfform name="project" action="Project.cfm" method="post">
	<input type="hidden" name="Action" value="createNew">
	<table>
		<tr>
			<td align="right">
				<a href="javascript:void(0);" onClick="getDocs('project','title')">Project&nbsp;Title</a>
			</td>
			<td colspan="3">
				<textarea name="project_name" cols="50" rows="2" class="reqdClr"></textarea>
			</td>
		</tr>
		<tr>
			<td align="right"><a href="javascript:void(0);" onClick="getDocs('project','date')">Start&nbsp;Date</a> </td>
			<td><input type="text" name="start_date"></td>
			<td align="right">End Date</td>
			<td><input type="text" name="end_date"></td>
		</tr>
		<tr>
			<td align="right">
				<a href="javascript:void(0);" onClick="getDocs('project','description')">Description</a>
			</td>
			<td colspan="3"><textarea name="project_description" cols="50" rows="6"></textarea></td>
		</tr>
		<tr>
			<td align="right">Remarks</td>
			<td colspan="3"><textarea name="project_remarks" cols="50" rows="3"></textarea></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				<input type="submit" 
					value="Create Project" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
					onmouseout="this.className='savBtn'">
				<input type="reset" 
					value="Clear Form" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
					onmouseout="this.className='clrBtn'">
				<input type="button"
					value="Quit"
					class="qutBtn"
					onmouseover="this.className='qutBtn btnhov'"
					onmouseout="this.className='qutBtn'"
					onClick="document.location='Project.cfm';">
			</td>
		</tr>
	</table>
</cfform>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "createNew">
	<cfoutput>
		<cfquery name="nextID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_project_id.nextval nextid from dual
		</cfquery>
		<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO project (
			PROJECT_ID,
			PROJECT_NAME
			<cfif len(#START_DATE#) gt 0>
				,START_DATE
			</cfif>
			
			<cfif len(#END_DATE#) gt 0>
				,END_DATE
			</cfif>
			<cfif len(#PROJECT_DESCRIPTION#) gt 0>
				,PROJECT_DESCRIPTION
			</cfif>
			<cfif len(#PROJECT_REMARKS#) gt 0>
				,PROJECT_REMARKS
			</cfif>
			 )
		VALUES ( 
			#nextID.nextid#,
			'#PROJECT_NAME#'
			<cfif len(#START_DATE#) gt 0>
				,'#dateformat(START_DATE,"dd-mmm-yyyy")#'
			</cfif>
			
			<cfif len(#END_DATE#) gt 0>
				,'#dateformat(END_DATE,"dd-mmm-yyyy")#'
			</cfif>
			<cfif len(#PROJECT_DESCRIPTION#) gt 0>
				,'#PROJECT_DESCRIPTION#'
			</cfif>
			<cfif len(#PROJECT_REMARKS#) gt 0>
				,'#PROJECT_REMARKS#'
			</cfif>
			 )   
	</cfquery>  
	<cflocation url="Project.cfm?Action=editProject&project_id=#nextID.nextid#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif action is "editProject">
	<cfset title="Edit Project">
	<strong>Edit Project</strong>
	<cfoutput>
		<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				project.project_id,
				project_name,
				start_date,
				end_date,
				project_description,
				project_agent_name.agent_name,
				project_agent_name.agent_name_id,
				project_agent_role,
				project_remarks,
				agent_position,
				PROJECT_SPONSOR_ID,
				ACKNOWLEDGEMENT,
				project_sponsor.agent_name_id project_name_id,
				s_name.agent_name sponsor_name
			FROM 
				project,
				project_sponsor,
				agent_name project_agent_name,
				agent_name s_name,
				project_agent					
			WHERE 
				project.project_id = project_agent.project_id (+) AND 
				project.project_id = project_sponsor.project_id (+) AND 
				project_agent.agent_name_id = project_agent_name.agent_name_id (+) AND
				project_sponsor.agent_name_id = s_name.agent_name_id (+) AND
				project.project_id = #project_id# order by project_id
		</cfquery>
		<cfquery name="sponsors" dbtype="query">
			select
				PROJECT_SPONSOR_ID,
				ACKNOWLEDGEMENT,
				project_name_id,
				sponsor_name,
				project_name_id
			from
				getDetails
			WHERE
				PROJECT_SPONSOR_ID is not null
			group by
				PROJECT_SPONSOR_ID,
				ACKNOWLEDGEMENT,
				project_name_id,
				sponsor_name,
				project_name_id
		</cfquery>
		<cfquery name="agents" dbtype="query">
			select agent_name, agent_position, agent_name_id, project_agent_role from getDetails 
			group by agent_name, agent_position, agent_name_id, project_agent_role
			order by agent_position
		</cfquery>
		<cfquery name="getLoans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				collection.collection,
				loan.loan_number,
				loan.transaction_id,
				nature_of_material,
				trans.trans_remarks,
				loan_description
			from 
				project_trans, 
				loan, 
				trans,
				collection
			where
				project_trans.transaction_id=loan.transaction_id and
				loan.transaction_id = trans.transaction_id and
				trans.collection_id=collection.collection_id and
				project_trans.project_id = #getDetails.project_id#
			order by collection, loan_number
		</cfquery>
		<cfquery name="getAccns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				accn_number,
				collection,
				accn.transaction_id,
				nature_of_material,
				trans_remarks
			from 
				project_trans, 
				accn, 
				trans,
				collection
			where
				project_trans.transaction_id=accn.transaction_id and
				accn.transaction_id = trans.transaction_id and
				trans.collection_id=collection.collection_id and
				project_id = #getDetails.project_id#
				order by collection, accn_number
		</cfquery>
		<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				scientific_name
			from 
				project_taxonomy, 
				taxonomy
			where
				project_taxonomy.taxon_name_id=project_taxonomy.taxon_name_id and
				project_id = #getDetails.project_id#
			order by 
				scientific_name
		</cfquery>
		<cfquery name="proj" dbtype="query">
			SELECT 
				project_id,
				project_name,
				start_date,
				end_date,
				project_description,
				project_remarks
			FROM 
				getDetails
			group by
				project_id,
				project_name,
				start_date,
				end_date,
				project_description,
				project_remarks
		</cfquery>
		<cfquery name="numAgents" dbtype="query">
			select max(agent_position) as  agent_position from agents
		</cfquery>
		<cfif len(numAgents.agent_position) gt 0>
			<cfset numberOfAgents = numAgents.agent_position + 1>
		<cfelse>
			<cfset numberOfAgents = 1>
		</cfif>
		<cfquery name="publications" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				formatted_publication, formatted_publication.publication_id  
			FROM 
				project_publication,
				formatted_publication,
				publication
			WHERE 
				project_publication.project_id = #project_id# AND  
				project_publication.publication_id = formatted_publication.publication_id AND 
				project_publication.publication_id = publication.publication_id AND 
				format_style = 'long'
			</cfquery>
			<form name="project" action="Project.cfm" method="post">
				<input type="hidden" name="action">
				<input type="hidden" name="project_id" id="project_id" value="#proj.project_id#">
				<label for="project_name" class="likeLink" onClick="getDocs('project','title')">Project&nbsp;Title</label>
				<textarea name="project_name" id="project_name" cols="80" rows="2" class="reqdClr">#proj.project_name#</textarea>
				<label for="start_date" class="likeLink" onClick="getDocs('project','date')">Start&nbsp;Date</label>
				<input type="text" name="start_date" id="start_date" value="#dateformat(proj.start_date,"dd mmm yyyy")#">
				<label for="end_date" class="likeLink" onClick="getDocs('project','date')">End&nbsp;Date</label>
				<input type="text" name="end_date" id="end_date" value="#dateformat(proj.end_date,"dd mmm yyyy")#">
				<label for="end_date" class="likeLink" onClick="getDocs('project','description')">Description</label>
				<textarea name="project_description" id="project_description" cols="80" rows="6">#proj.project_description#</textarea>
				<label for="project_remarks">Description</label>
				<textarea name="project_remarks" id="project_remarks" cols="80" rows="3">#proj.project_remarks#</textarea>
				<br>
				<input type="button" 
					value="Save Updates" 
					class="savBtn"
					onclick="document.project.Action.value='saveEdits';submit();">
				<input type="button"
					value="Delete"
					class="delBtn"
					onclick="document.project.Action.value='deleteProject';submit();">
				<input type="button"
					value="Quit"
					class="qutBtn"
					onClick="document.location='Project.cfm';">
			</form>
			<table>
				<tr>
					<td colspan="2">
						<a href="javascript:void(0);" onClick="getDocs('project','agent')">Project&nbsp;Agents</a>
					</td>
					<td colspan="2">
						<a href="javascript:void(0);" onClick="getDocs('project','agent_role')">Agent&nbsp;Role</a>
					</td>
				</tr>
				<cfset i = 1>
				<cfloop query="agents">
					<form name="projAgents#i#" method="post" action="Project.cfm">
					    <input type="hidden" name="Action" value="saveAgentChange">
						<input type="hidden" name="project_id" value="#getDetails.project_id#">
						<input type="hidden" name="agent_name_id" value="#agents.agent_name_id#">
						<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
							<td>
								##
								<select name="agent_position" size="1" class="reqdClr">
									<cfloop from="1" to="#numberOfAgents#" index="a">
										<option 
											<cfif #agent_position# is #a#> selected="selected" </cfif>
											value="#a#">#a#</option>
									</cfloop>
									<option value=""></option>
								</select>
							</td>
							<td>			
								<input type="text" name="agent_name" 
									value="#AGENTS.agent_name#" 
									class="reqdClr" 
									onchange="findAgentName('new_name_id','agent_name','projAgents#i#',this.value); return false;"
									onKeyPress="return noenter(event);">
								<input type="hidden" name="new_name_id">
							</td>
							<td>
								<cfset thisRole = agents.project_agent_role>
								<select name="project_agent_role" size="1" class="reqdClr">
									<cfloop query="ctProjAgRole">
									<option 
										<cfif #ctProjAgRole.project_agent_role# is "#thisRole#"> 
											selected 
										</cfif> value="#ctProjAgRole.project_agent_role#">#ctProjAgRole.project_agent_role#
									</option>
									</cfloop>
								</select>
							</td>
							<td nowrap valign="center">			
								<input type="button" 
									value="Delete"
									class="delBtn"
									onclick="document.location='Project.cfm?Action=removeAgent&project_id=#project_id#&agent_name_id=#agent_name_id#';">
								<input type="submit" 
										value="Save" 
										class="savBtn">
							 </td>
						     <cfset i = i+1>
						</tr>
					</form>
				</cfloop>
				<tr class="newRec">
					<td colspan="5">
						Add Agent:
					</td>
				</tr>
				<tr class="newRec">
					<form name="newAgent" method="post" action="Project.cfm">
						<input type="hidden" name="Action" value="newAgent">
						<input type="hidden" name="project_id" value="#getDetails.project_id#">
						<td>	
							##<select name="agent_position" size="1" class="reqdClr">
								<cfloop from="1" to="#numberOfAgents#" index="i">
									<option 
										<cfif #numberOfAgents# is #i#> selected </cfif>	value="#i#">#i#</option>
								</cfloop>
								<option value=""></option>
							</select>
						</td>
						<td>
							<input type="text" name="newAgent_name" 
								class="reqdClr" 
								onchange="findAgentName('newAgent_name_id','newAgent_name','newAgent',this.value); return false;"
								onKeyPress="return noenter(event);">
							<input type="hidden" name="newAgent_name_id">
						</td>
						<td>
							<select name="newRole" size="1" class="reqdClr">
								<cfloop query="ctProjAgRole">
									<option value="#ctProjAgRole.project_agent_role#">#ctProjAgRole.project_agent_role#
									</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="submit" 
									value="Save" 
									class="savBtn">
						</td>
					</form>
				</tr>
			</table>
			<table border>
				<tr>
					<th>Project Sponsor</th>
					<th>Acknowledgement</th>
				</tr>
				<cfset i=1>
				<cfloop query="sponsors">
					<form name="sponsor#i#" method="post" action="Project.cfm">
						<input type="hidden" name="action" value="saveSponsorChange">
						<input type="hidden" name="project_id" value="#project_id#">
						<input type="hidden" name="PROJECT_SPONSOR_ID" value="#PROJECT_SPONSOR_ID#">
						<input type="hidden" name="agent_name_id" value="#project_name_id#">
						<tr>
							<td>
								<input type="text" name="sponsor_name" 
								class="reqdClr" 
								onchange="findAgentName('agent_name_id','sponsor_name','sponsor#i#',this.value); return false;"
								onKeyPress="return noenter(event);"
								value="#sponsor_name#">
							</td>
							<td>
								<input type="text" size="80" name="ACKNOWLEDGEMENT" value="#ACKNOWLEDGEMENT#" class="reqdClr">
							</td>
							<td>
								<input type="submit" 
									value="Save Edits" 
									class="savBtn">
							</td>
							<td>
								<input type="button" 
									value="Delete Sponsor" 
									class="delBtn"
									onclick="sponsor#i#.action.value='deleteSponsor';submit();")>
							</td>
						</tr>
					</form>
					<cfset i=i+1>
				</cfloop>
				<form name="addSponsor" method="post" action="Project.cfm">
					<input type="hidden" name="new_sponsor_id">
					<input type="hidden" name="project_id" value="#project_id#">
					<input type="hidden" name="action" value="addSponsor">
					<tr class="newRec">
						<td colspan="3">
							Add Sponsor
						</td>
					</tr>
					<tr>
						<td>
							<input type="text" name="new_sponsor_name" 
								class="reqdClr" 
								onchange="findAgentName('new_sponsor_id','new_sponsor_name','addSponsor',this.value); return false;"
								onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="text" size="50" name="newAcknowledgement" id="newAcknowledgement">
						</td>
						<td>
							<label for="add">&nbsp;</label>
							<input type="submit" 
									value="Add Sponsor" 
									class="savBtn">
						</td>
					</tr>
				</form>
			</table>
			<p>
				<strong>Project Accessions:</strong>
				[ <a href="editAccn.cfm?project_id=#getDetails.project_id#">Add Accession</a> ]
				<cfset i=1>
				<cfloop query="getAccns">
	 				<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>	
						<a href="editAccn.cfm?action=edit&transaction_id=#getAccns.transaction_id#">
							<strong>#collection#  #accn_number#</strong>
						</a>
						<a href="/Project.cfm?Action=delTrans&transaction_id=#transaction_id#&project_id=#getDetails.project_id#">
							[ Remove ]
						</a>
						<br>
							#nature_of_material# - #trans_remarks#
					</div>
					<cfset i=i+1>		
				</cfloop>
			</p>
			<p>
				<strong>Project Loans:</strong>
				<a href="/Loan.cfm?project_id=#getDetails.project_id#&Action=addItems">[ Add Loan ] </a>
				<cfset i=1>
				<cfloop query="getLoans">
		 			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">
							<strong>#collection# #loan_number#</strong>
						</a>
						<a href="Project.cfm?Action=delTrans&transaction_id=#transaction_id#&project_id=#getDetails.project_id#">
							[ Remove ]
						</a>
						<div>
							#nature_of_material# - #LOAN_DESCRIPTION#
						</div>
					</div>
					<cfset i=i+1>
				</cfloop>
			</p>
			<p>
				<strong>Project Publications:</strong>
				<a href="/SpecimenUsage.cfm?toproject_id=#getDetails.project_id#">[ add Publication ]</a>
				<cfset i=1>
				<cfloop query="publications">
		 			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<div>
							#formatted_publication#
						</div>
						<br>
						<a href="/Publication.cfm?publication_id=#publication_id#">[ Edit Publication ]</a>
						<a href="/Project.cfm?Action=delePub&publication_id=#publication_id#&project_id=#getDetails.project_id#">
							[ Remove Publication ]
						</a>
					</div>
					<cfset i=i+1>
				</cfloop>
			</p>
			<p>
				<strong>Project Taxonomy:</strong>
				<form name="tpick" method="post" action="Project.cfm">
					<input type='hidden' name='action' value='addtaxon'>
					<label for="newtax">Add taxon name</label>
					<input type="text" name="newtax" id="newtax" onchange="taxaPick('newTaxId',this.id,'tpick',this.value)">
					<input type="submit" value="Add Taxon">
				</form>
				
				<a href="/SpecimenUsage.cfm?toproject_id=#getDetails.project_id#">[ add Publication ]</a>
				<cfset i=1>
				<cfloop query="publications">
		 			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<div>
							#formatted_publication#
						</div>
						<br>
						<a href="/Publication.cfm?publication_id=#publication_id#">[ Edit Publication ]</a>
						<a href="/Project.cfm?Action=delePub&publication_id=#publication_id#&project_id=#getDetails.project_id#">
							[ Remove Publication ]
						</a>
					</div>
					<cfset i=i+1>
				</cfloop>
			</p>	
		</cfoutput>
</cfif>


<!------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteSponsor">
	<cfoutput>
		<cfquery name="deleteSponsor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from project_sponsor
			where PROJECT_SPONSOR_ID=#PROJECT_SPONSOR_ID#
		</cfquery>
	<cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveSponsorChange">
	<cfoutput>
		<cfquery name="updateSponsor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update project_sponsor
			set 
			agent_name_id=#agent_name_id#,
			ACKNOWLEDGEMENT='#ACKNOWLEDGEMENT#'
			where PROJECT_SPONSOR_ID=#PROJECT_SPONSOR_ID#
		</cfquery>
	<cflocation url="Project.cfm?action=editProject&project_id=#project_id#" addtoken="no">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteProject">
 <cfoutput>
 	<cfquery name="isAgent"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name_id FROM project_agent WHERE project_id=#project_id#
	</cfquery>
	<cfif #isAgent.recordcount# gt 0>
		There are agents for this project! Delete denied!
		<cfabort>
	</cfif>
	<cfquery name="isTrans"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select project_id FROM project_trans WHERE project_id=#project_id#
	</cfquery>
	<cfif #isTrans.recordcount# gt 0>
		There are transactions for this project! Delete denied!
		<cfabort>
	</cfif>
	<cfquery name="isPub"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select project_id FROM project_publication WHERE project_id=#project_id#
	</cfquery>
	<cfif #isPub.recordcount# gt 0>
		There are publications for this project! Delete denied!
		<cfabort>
	</cfif>
	<cfquery name="killProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from project where project_id=#project_id#
	</cfquery>
	
	You've deleted the project.
	<br>
	<a href="Project.cfm">continue</a>
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "addSponsor">
	 <cfoutput>
	<cfquery name="addSponsor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into project_sponsor
			(PROJECT_ID,
			AGENT_NAME_ID,
			ACKNOWLEDGEMENT
		) values (
			#project_id#,
			#new_sponsor_id#,
			'#newAcknowledgement#'			
		)
	</cfquery>
 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "removeAgent">
 <cfoutput>
 	<cfquery name="deleAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	DELETE FROM project_agent where project_id=#project_id# and agent_name_id=#agent_name_id#
	</cfquery>
	 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveAgentChange">
 <cfoutput>
 <cfquery name="upProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 UPDATE project_agent SET
 	project_id = #project_id#
 	<cfif len(#new_name_id#) gt 0>
		,agent_name_id = #new_name_id#
	</cfif>
	<cfif len(#project_agent_role#) gt 0>
		,project_agent_role = '#project_agent_role#'
	</cfif>
	<cfif len(#agent_position#) gt 0>
		,agent_position = #agent_position#
	</cfif>
	WHERE project_id = #project_id# AND agent_name_id = #agent_name_id#
		</cfquery>
	 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "newAgent">
 <cfoutput>
  <cfquery name="newProjAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 INSERT INTO project_agent (
 	 PROJECT_ID,
	 AGENT_NAME_ID,
	 PROJECT_AGENT_ROLE,
	 AGENT_POSITION)
VALUES (
	#PROJECT_ID#,
	 #newAgent_name_id#,
	 '#newRole#',
	 #agent_position#                  
 	)                 
 </cfquery>
 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
 <cfoutput>
  <cfquery name="upProject" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 
 UPDATE project SET project_id = #project_id#
 ,project_name = '#project_name#'
 <cfif len(#start_date#) gt 0>
 	,start_date = '#dateformat(start_date,"dd-mmm-yyyy")#'
<cfelse>
	,start_date = null
 </cfif>
 <cfif len(#end_date#) gt 0>
 	,end_date = '#dateformat(end_date,"dd-mmm-yyyy")#'
 <cfelse>
 	,end_date = null
 </cfif>
 <cfif len(#project_description#) gt 0>
 	,project_description = '#project_description#'
<cfelse>
 	,project_description = null
 </cfif>
 <cfif len(#project_remarks#) gt 0>
 	,project_remarks = '#project_remarks#'
<cfelse>
 	,project_remarks = null
 </cfif>
 where project_id=#project_id#
  </cfquery>
  <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "addTrans">
 <cfoutput>
 
<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	INSERT INTO project_trans (project_id, transaction_id) values (#project_id#, #transaction_id#)

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "addPub">
 <cfoutput>
 
<cfquery name="newPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	INSERT INTO project_publication (project_id, publication_id) values (#project_id#, #publication_id#)

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "delePub">
 <cfoutput>
 
<cfquery name="newPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	DELETE FROM project_publication WHERE project_id = #project_id# and publication_id = #publication_id#

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "delTrans">
 <cfoutput>
 
<cfquery name="delTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 DELETE FROM  project_trans where project_id = #project_id# and transaction_id = #transaction_id#

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#">
 </cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
