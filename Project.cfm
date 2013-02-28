<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/internalAjax.js'></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#start_date").datepicker();
		jQuery("#end_date").datepicker();
		jQuery("#ended_date").datepicker();
	});
	function addProjTaxon() {
		if (document.getElementById('newTaxId').value.length == 0){
			alert('Choose a taxon name, then click the button');
			return false;
		} else {
			document.tpick.submit();
		}
	}
	function removeAgent(i) {
	 	$("#agent_name_" + i).val('deleted');
	 	$("#projAgentRow" + i).removeClass().addClass('red');}
</script>
<cfif action is "nothing">
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/SpecimenUsage.cfm">
</cfif>
<cfquery name="ctProjAgRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select project_agent_role from ctproject_agent_role
</cfquery>
<!------------------------------------------------------------------------------------------->
<cfif Action is "makeNew">
	<cfset title="create project">
<strong>Create New Project:</strong>
<cfoutput>
	<form name="project" action="Project.cfm" method="post">
		<input type="hidden" name="Action" value="createNew">
		<table>
			<tr>
				<td>
					<label for="project_name" class="likeLink" onClick="getDocs('project','title')">
						Project Title (say something useful, not just "My favorite species {buzzword of the week}.")
					</label>
					<textarea name="project_name" id="project_name" cols="80" rows="2" class="reqdClr"></textarea>
				</td>
				<td>
					<span class="infoLink" onclick="italicize('project_name')">italicize selected text</span>
					<br><span class="infoLink" onclick="bold('project_name')">bold selected text</span>
					<br><span class="infoLink" onclick="superscript('project_name')">superscript selected text</span>
					<br><span class="infoLink" onclick="subscript('project_name')">subscript selected text</span>
				</td>
			</tr>
		</table>
			<label for="start_date" class="likeLink" onClick="getDocs('project','date')">Start&nbsp;Date</label>
				<input type="text" name="start_date" id="start_date">
				<label for="end_date" class="likeLink" onClick="getDocs('project','date')">End&nbsp;Date</label>
				<input type="text" name="end_date" id="end_date">
				<label for="end_date" class="likeLink" onClick="getDocs('project','description')">
					Description (Include what, why, how, who cares. Be <i>descriptive</i>. Minimum 100 characters to show up in search.)
				</label>
				<textarea name="project_description" id="project_description" cols="80" rows="6"></textarea>
				<label for="project_remarks">Remarks</label>
				<textarea name="project_remarks" id="project_remarks" cols="80" rows="3"></textarea>
				<br>
				<input type="submit" value="Create Project" class="insBtn">
				<br>
				You can add Agents, Publications, Media, Transactions, and Taxonomy after you create the basic project.
			</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif Action is "createNew">
	<cfoutput>
		<cfquery name="nextID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_project_id.nextval nextid from dual
		</cfquery>
		<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				,'#dateformat(START_DATE,"yyyy-mm-dd")#'
			</cfif>

			<cfif len(#END_DATE#) gt 0>
				,'#dateformat(END_DATE,"yyyy-mm-dd")#'
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
<cfif action is "editProject">
	<cfset title="Edit Project">
	<cfoutput>
		<strong>Edit Project</strong> <a href="/ProjectDetail.cfm?project_id=#project_id#">[ Detail Page ]</a>
		<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				project_agent_id,
				project.project_id,
				project_name,
				start_date,
				end_date,
				project_description,
				preferred_agent_name.agent_name,
				project_agent.agent_id,
				project_agent_role,
				project_remarks,
				agent_position,
				project_agent_remarks
			FROM
				project,
				preferred_agent_name,
				project_agent
			WHERE
				project.project_id = project_agent.project_id (+) AND
				project_agent.agent_id = preferred_agent_name.agent_id (+) AND
				project.project_id = #project_id#
		</cfquery>
		<cfquery name="agents" dbtype="query">
			select
				project_agent_id,
				agent_name,
				agent_position,
				agent_id,
				project_agent_role,
				project_agent_remarks
			from
				getDetails
			where
				agent_name is not null
			group by project_agent_id,agent_name, agent_position, agent_id, project_agent_role,project_agent_remarks
			order by agent_position
		</cfquery>
		<cfquery name="getLoans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="getAccns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				taxonomy.taxon_name_id,
				scientific_name
			from
				project_taxonomy,
				taxonomy
			where
				taxonomy.taxon_name_id=project_taxonomy.taxon_name_id and
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
		<cfquery name="publications" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				full_citation, publication.publication_id
			FROM
				project_publication,
				publication
			WHERE
				project_publication.publication_id = publication.publication_id AND
				project_publication.project_id = #project_id#
			</cfquery>
			<form name="project" action="Project.cfm" method="post">
				<input type="hidden" name="action" value="save">
				<input type="hidden" name="project_id" id="project_id" value="#proj.project_id#">
				<table>
					<tr>
						<td>
							<label for="project_name" class="likeLink" onClick="getDocs('project','title')">Project Title</label>
							<textarea name="project_name" id="project_name" cols="80" rows="2" class="reqdClr">#proj.project_name#</textarea>
						</td>
						<td>
							<span class="infoLink" onclick="italicize('project_name')">italicize selected text</span>
							<br><span class="infoLink" onclick="bold('project_name')">bold selected text</span>
							<br><span class="infoLink" onclick="superscript('project_name')">superscript selected text</span>
							<br><span class="infoLink" onclick="subscript('project_name')">subscript selected text</span>
						</td>
					</tr>
				</table>
				<table>
					<tr>
						<td>
							<label for="start_date" class="likeLink" onClick="getDocs('project','date')">Start&nbsp;Date</label>
							<input type="text" name="start_date" id="start_date" value="#dateformat(proj.start_date,"yyyy-mm-dd")#">
						</td>
						<td>
							<label for="end_date" class="likeLink" onClick="getDocs('project','date')">End&nbsp;Date</label>
							<input type="text" name="end_date" id="end_date" value="#dateformat(proj.end_date,"yyyy-mm-dd")#">
						</td>
					</tr>
				</table>
				<label for="project_description" class="likeLink" onClick="getDocs('project','description')">Description</label>
				<textarea name="project_description" id="project_description" cols="80" rows="6">#proj.project_description#</textarea>
				<label for="project_remarks">Remarks</label>
				<textarea name="project_remarks" id="project_remarks" cols="80" rows="3">#proj.project_remarks#</textarea>
				<a name="agent"></a>
				<table>
				<tr>
					<td colspan="2">
						<a href="javascript:void(0);" onClick="getDocs('project','agent')">Project&nbsp;Agents</a>
					</td>
					<td>
						<a href="javascript:void(0);" onClick="getDocs('project','agent_role')">Agent&nbsp;Role</a>
					</td>
					<td>Remark</td>
				</tr>
				<cfset i=0>
				<cfloop query="agents">
					 <cfset i = i+1>
					<input type="hidden" name="agent_id_#i#" value="#agent_id#">
					<input type="hidden" name="project_agent_id_#i#" value="#project_agent_id#">
					<tr id="projAgentRow#i#"	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td>
							##
							<select name="agent_position_#i#" size="1" class="reqdClr">
								<cfloop from="1" to="#numberOfAgents#" index="a">
									<option <cfif agent_position is a> selected="selected" </cfif> value="#a#">#a#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="agent_name_#i#" id="agent_name_#i#"
								value="#agent_name#"
								class="reqdClr"
								onchange="getAgent('agent_id_#i#',this.id,'project',this.value); return false;"
								onKeyPress="return noenter(event);">
						</td>
						<td>
							<select name="project_agent_role_#i#" id="project_agent_role_#i#" size="1" class="reqdClr">
								<cfloop query="ctProjAgRole">
								<option
									<cfif ctProjAgRole.project_agent_role is agents.project_agent_role>
										selected="selected"
									</cfif> value="#ctProjAgRole.project_agent_role#">#ctProjAgRole.project_agent_role#
								</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="project_agent_remarks_#i#" id="project_agent_remarks_#i#" value='#project_agent_remarks#'>
						</td>
						<td nowrap valign="center">
							<input type="button"
								value="Remove"
								class="delBtn"
								onclick="removeAgent(#i#);">
						 </td>
					</tr>
				</cfloop>
				<input type="hidden" name="numberOfAgents" value="#i#">
				<tr class="newRec">
					<td colspan="5">
						Add Agent:
					</td>
				</tr>
				<cfset numNewAgents=3>
				<input type="hidden" name="numNewAgents" value="#numNewAgents#">
				<cfloop from="1" to="#numNewAgents#" index="x">
					<tr class="newRec">
						<td>
							##<select name="new_agent_position#x#" size="1" class="reqdClr">
								<cfloop from="1" to="#numberOfAgents#" index="i">
									<option
										<cfif numberOfAgents is i> selected </cfif>	value="#i#">#i#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="new_agent_name#x#" id="new_agent_name#x#"
								class="reqdClr"
								onchange="getAgent('new_agent_id#x#',this.id,'project',this.value); return false;"
								onKeyPress="return noenter(event);">
							<input type="hidden" name="new_agent_id#x#" id="new_agent_id#x#">
						</td>
						<td>
							<select name="new_role#x#" size="1" class="reqdClr">
								<cfloop query="ctProjAgRole">
									<option value="#ctProjAgRole.project_agent_role#">#ctProjAgRole.project_agent_role#
									</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="new_project_agent_remarks#x#" id="new_project_agent_remarks#x#">
						</td>
						<td>
						</td>
					</tr>
				</cfloop>
			</table>
			<input type="button" value="Save Updates" class="savBtn" onclick="document.project.action.value='save';submit();">
			<cfif agents.recordcount is 0 and
				getAccns.recordcount is 0 and
				getLoans.recordcount is 0 and
				publications.recordcount is 0 and
				taxonomy.recordcount is 0>
				<input type="button" value="Delete Project" class="delBtn" onclick="document.project.action.value='deleteProject';submit();">
			<cfelse>
				-not deleteable-
			</cfif>
		</form>
			<a name="trans"></a>
			<p>
				<strong>Project Accessions</strong>
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
				<strong>Project Loans</strong>
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
			<a name="pub"></a>
			<p>
				<strong>Project Publications</strong>
				<a href="/SpecimenUsage.cfm?toproject_id=#getDetails.project_id#">[ add Publication ]</a>
				<cfset i=1>
				<cfloop query="publications">
		 			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<div>
							#full_citation#
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
			<p><a name="taxonomy"></a>
				<strong>Project Taxonomy</strong>
				<form name="tpick" method="post" action="Project.cfm">
					<input type='hidden' name='project_id' value='#proj.project_id#'>
					<input type='hidden' name='action' value='addtaxon'>
					<label for="newtax">Add taxon name</label>
					<input type="text" name="newtax" id="newtax" onchange="taxaPick('newTaxId',this.id,'tpick',this.value)"
						onKeyPress="return noenter(event);">
					<input type="hidden" name="newTaxId" id="newTaxId">
					<input type="button" onclick="addProjTaxon()" value="Add Taxon">
				</form>
				<cfset i=1>
				<cfloop query="taxonomy">
		 			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<div>
							<a href="/name/#scientific_name#">#scientific_name#</a>
							<a href="/Project.cfm?action=removeTaxonomy&taxon_name_id=#taxon_name_id#&project_id=#project_id#">
								[ Remove Name ]
							</a>
						</div>
					</div>
					<cfset i=i+1>
				</cfloop>
			</p>
		</cfoutput>
</cfif>


<!------------------------------------------------------------------------------------------->
<cfif action is "save">
	<cfoutput>
  		<cfquery name="upProject" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 			UPDATE project SET
 				project_name = '#project_name#',
				start_date = '#dateformat(start_date,"yyyy-mm-dd")#',
				 end_date = '#dateformat(end_date,"yyyy-mm-dd")#',
				 project_description = '#project_description#',
				 project_remarks = '#project_remarks#'
			where project_id=#project_id#
		</cfquery>
		<cfloop from="1" to="#numberOfAgents#" index="n">
			<cfset project_agent_id = evaluate("project_agent_id_" & n)>
			<cfset agent_id = evaluate("agent_id_" & n)>
			<cfset agent_position = evaluate("agent_position_" & n)>
			<cfset agent_name = evaluate("agent_name_" & n)>
			<cfset project_agent_role = evaluate("project_agent_role_" & n)>
			<cfset project_agent_remarks = evaluate("project_agent_remarks_" & n)>
			<cfset project_agent_id = evaluate("project_agent_id_" & n)>
			<cfif agent_name is "deleted">
				<cfquery name="deleAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	 				DELETE FROM project_agent where project_agent_id=#project_agent_id#
				</cfquery>
			<cfelse>
				<cfquery name="upProjAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				 	UPDATE project_agent SET
						agent_id = #agent_id#,
						project_agent_role = '#project_agent_role#',
						agent_position = #agent_position#,
						project_agent_remarks='#project_agent_remarks#'
					WHERE
						project_agent_id = #project_agent_id#
				</cfquery>
				UPDATE project_agent SET
						agent_id = #agent_id#,
						project_agent_role = '#project_agent_role#',
						agent_position = #agent_position#,
						project_agent_remarks='#project_agent_remarks#'
					WHERE
						project_agent_id = #project_agent_id#
			</cfif>
		</cfloop>
		<cfloop from="1" to="#numNewAgents#" index="n">
			<cfset new_agent_id = evaluate("new_agent_id" & n)>
			<cfset new_role = evaluate("new_role" & n)>
			<cfset new_agent_position = evaluate("new_agent_position" & n)>
			<cfset new_project_agent_remarks = evaluate("new_project_agent_remarks" & n)>
			<cfif len(new_agent_id) gt 0>
			  <cfquery name="newProjAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				 INSERT INTO project_agent (
				 	 PROJECT_ID,
					 AGENT_ID,
					 PROJECT_AGENT_ROLE,
					 AGENT_POSITION,
					 project_agent_remarks)
				VALUES (
					#PROJECT_ID#,
					 #new_agent_id#,
					 '#new_role#',
					 #new_agent_position#,
					 '#new_project_agent_remarks#'
				 	)
				 </cfquery>
			</cfif>
		</cfloop>
  		<cflocation url="Project.cfm?Action=editProject&project_id=#project_id#" addtoken="false">
		<!----
	---->
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------->
<cfif action is "removeTaxonomy">
	<cfoutput>
		<cfquery name="addtaxon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from project_taxonomy where
			project_id=#project_id# and
			taxon_name_id=#taxon_name_id#
		</cfquery>
	<cflocation url="Project.cfm?Action=editProject&project_id=#project_id###taxonomy" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif action is "addtaxon">
	<cfoutput>
		<cfquery name="addtaxon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into project_taxonomy (
			    project_id,
			    taxon_name_id
			) values (
				#project_id#,
				#newTaxId#
			)
		</cfquery>
	<cflocation url="Project.cfm?Action=editProject&project_id=#project_id###taxonomy" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteProject">
 <cfoutput>
 	<cfquery name="isAgent"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select agent_id FROM project_agent WHERE project_id=#project_id#
	</cfquery>
	<cfif #isAgent.recordcount# gt 0>
		You must remove Project Agents before you delete a project.
		<cfabort>
	</cfif>
	<cfquery name="isTrans"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select project_id FROM project_trans WHERE project_id=#project_id#
	</cfquery>
	<cfif #isTrans.recordcount# gt 0>
		There are transactions for this project! Delete denied!
		<cfabort>
	</cfif>
	<cfquery name="isPub"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select project_id FROM project_publication WHERE project_id=#project_id#
	</cfquery>
	<cfif #isPub.recordcount# gt 0>
		There are publications for this project! Delete denied!
		<cfabort>
	</cfif>
	<cfquery name="killProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from project where project_id=#project_id#
	</cfquery>

	You've deleted the project.
	<br>
	<a href="Project.cfm">continue</a>
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "removeAgent">
 <cfoutput>
 	<cfquery name="deleAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 	DELETE FROM project_agent where project_agent_id=#project_agent_id#
	</cfquery>
	 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###agent" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveAgentChange">
 <cfoutput>
 <cfquery name="upProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 	UPDATE project_agent SET
		agent_id = #new_agent_id#
		project_agent_role = '#project_agent_role#',
		agent_position = #agent_position#,
		project_agent_remarks='#project_agent_remarks#'
	WHERE
		project_agent_id = #project_agent_id#
</cfquery>
<cflocation url="Project.cfm?Action=editProject&project_id=#project_id###agent" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "newAgent">
 <cfoutput>
  <cfquery name="newProjAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 INSERT INTO project_agent (
 	 PROJECT_ID,
	 AGENT_ID,
	 PROJECT_AGENT_ROLE,
	 AGENT_POSITION,
	 project_agent_remarks)
VALUES (
	#PROJECT_ID#,
	 #newAgent_id#,
	 '#newRole#',
	 #agent_position#,
	 '#project_agent_remarks#'
 	)
 </cfquery>
 <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###agent" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
 <cfoutput>
  <cfquery name="upProject" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">

 UPDATE project SET project_id = #project_id#
 ,project_name = '#project_name#'
 <cfif len(#start_date#) gt 0>
 	,start_date = '#dateformat(start_date,"yyyy-mm-dd")#'
<cfelse>
	,start_date = null
 </cfif>
 <cfif len(#end_date#) gt 0>
 	,end_date = '#dateformat(end_date,"yyyy-mm-dd")#'
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
  <cflocation url="Project.cfm?Action=editProject&project_id=#project_id#" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "addTrans">
 <cfoutput>

<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 	INSERT INTO project_trans (project_id, transaction_id) values (#project_id#, #transaction_id#)

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###trans" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "addPub">
 <cfoutput>

<cfquery name="newPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 	INSERT INTO project_publication (project_id, publication_id) values (#project_id#, #publication_id#)

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###pub" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "delePub">
 <cfoutput>

<cfquery name="newPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 	DELETE FROM project_publication WHERE project_id = #project_id# and publication_id = #publication_id#

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###pub" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "delTrans">
 <cfoutput>
<cfquery name="delTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
 DELETE FROM  project_trans where project_id = #project_id# and transaction_id = #transaction_id#

  </cfquery>
   <cflocation url="Project.cfm?Action=editProject&project_id=#project_id###trans" addtoken="false">
 </cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">