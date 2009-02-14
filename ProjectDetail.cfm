<cfinclude template = "includes/_header.cfm">
<cfif not isdefined("project_id") or not isnumeric(#project_id#)>
	<p style="color:#FF0000; font-size:14px;">
		Did not get a project ID - aborting....
	</p>
	<cfabort>
</cfif>
<cfset title = "Project Detail">
<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT project.project_id,project_name,project_description,start_date,end_date,agent_name, agent_position,
	project_agent_role FROM project,project_agent,agent_name WHERE project.project_id = #project_id# 
	AND project.project_id = project_agent.project_id AND 
	project_agent.agent_name_id = agent_name.agent_name_id 
	ORDER BY project_id,agent_position
</cfquery>
<cfoutput query="proj" group="project_id">
<font size="+2">#project_name#</font><br>
<cfoutput group="agent_position">
	<B>#agent_name# (#project_agent_role#)<br>
	</cfoutput>
	<cfoutput group="project_id"><br>
	#dateformat(start_date,"dd mmmm yyyy")# - #dateformat(end_date,"dd mmmm yyyy")#</B>
	</cfoutput>
</cfoutput>

<p>&nbsp;</p>
<table WIDTH="90%">
  <tr>
    <td valign="top">
	<!--- more details table --->
	<table border="1">
	<cfoutput>
  <tr>
    <td nowrap>
		<a href="ProjectDetail.cfm?action=viewPubs&project_id=#project_id#">Publications</a>
	</td>
</tr>
  <tr>
    <td nowrap>
	<a href="ProjectDetail.cfm?action=viewUser&project_id=#project_id#">Projects using contributed specimens</a>
	</td>
   
  </tr>
  <tr>
   <td nowrap>
	<a href="ProjectDetail.cfm?action=viewUsed&project_id=#project_id#">Specimens Used</a>
	</td>
   
  </tr>
  <tr>
  <td nowrap>
	<a href="ProjectDetail.cfm?action=viewCont&project_id=#project_id#">Projects Contributing Specimens</a>
	</td>
   
  </tr>
  <tr>
   <td nowrap>
	<a href="ProjectDetail.cfm?action=viewSpec&project_id=#project_id#">Specimens Contributed</a>
	</td>
   
  </tr>
  <tr>
   <td nowrap>
	<a href="ProjectDetail.cfm?project_id=#project_id#">Project Description</a>
	</td>
   
  </tr>
  </cfoutput>
</table>

	
	</td>
    <td width="70%" valign="top">
	<!--- project description --->
	<!--- handle button-clicking --->
	<cfif #Action# is "nothing">
		<cfoutput query="proj" group="project_id">
			#project_description#
		</cfoutput>
	
		
	</cfif>
	<cfif #Action# is "viewPubs">
		<cfoutput>
			<cfquery name="pubJour" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					format_style = 'full citation' AND
					publication_type='Journal Article'
			</cfquery>
			<cfquery name="pubBook" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					format_style = 'full citation' AND
					publication_type='Book'
			</cfquery>
			<cfquery name="pubBookSec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					format_style = 'full citation' AND
					publication_type='Book Section'
			</cfquery>
		</cfoutput>
		
		<cfif pubJour.recordcount is 0 AND
			pubBookSec.recordcount is 0 AND
			pubBook.recordcount is 0>
				This project produced no publications.
		<cfelse>
				<blockquote>
				<cfoutput query="pubJour">
					<p>#formatted_publication#<br>
					<a href="PublicationResults.cfm?publication_id=#publication_id#">More Information</a>
				</cfoutput>
				<cfoutput query="pubBook">
					<p>#formatted_publication#<br>
					<a href="PublicationResults.cfm?publication_id=#publication_id#">More Information</a>
				</cfoutput>
				<cfoutput query="pubBookSec">
					<p>#formatted_publication#<br>
					<a href="PublicationResults.cfm?publication_id=#publication_id#">More Information</a>
				</cfoutput>
				</blockquote>
		</cfif>
		
	</cfif>
	<cfif #Action# is "viewUser">
		<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT project.project_id,project_name FROM project,
			project_agent,agent_name WHERE project.project_id = project_agent.project_id AND
			 project_agent.agent_name_id = agent_name.agent_name_id AND project.project_id 
			 IN (SELECT project_trans.project_id FROM project, project_trans, 
			 loan_item, cataloged_item 
			 where project_trans.transaction_id = loan_item.transaction_id AND 
			 loan_item.collection_object_id = cataloged_item.collection_object_id AND 
			 project_trans.project_id = project.project_id AND cataloged_item.collection_object_id 
			 IN 
			 (SELECT cataloged_item.collection_object_id FROM project,project_trans,accn,cataloged_item 
			 WHERE accn.transaction_id = cataloged_item.accn_id AND 
			 project_trans.transaction_id = accn.transaction_id AND 
			 project_trans.project_id = project.project_id AND 
			 project.project_id = #project_id#))  
			 ORDER BY project_name,project_id,agent_position
</cfquery>
		<cfif getUsers.recordcount is 0>
			No projects have used specimens contributed by this project.
		<cfelse>
			The following projects have contributed specimens. 
				Click the title to open that project in a new window.<br>
			<ul>
			<cfoutput query="getUsers" group="project_id">
				<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
			</cfoutput>
			</ul>
		</cfif>
		
	</cfif>
	<cfif #Action# is "viewUsed"><!---Specimens Used--->
		<!--- get specimen parts --->
		<cfquery name="getUsedParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, cataloged_item.collection_object_id
			FROM 
				cataloged_item,
				specimen_part,
				loan_item,
				project_trans
			WHERE
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
				AND specimen_part.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#	
		</cfquery>
		<!--- get specimen tissues --->
		<!---
		<cfquery name="getUsedTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, cataloged_item.collection_object_id
			FROM 
				cataloged_item,
				tissue_sample,
				loan_item,
				project_trans
			WHERE
				tissue_sample.derived_from_biol_indiv = cataloged_item.collection_object_id
				AND tissue_sample.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#	
		</cfquery>
		--->
		<!--- get cataloged items that have been loaned --->
		<cfquery name="getUsedSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num, loan_item.collection_object_id
			FROM 
				cataloged_item,
				loan_item,
				project_trans
			WHERE
				cataloged_item.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#
		</cfquery>
		
			
			<cfset collObjIds = "">
			<cfloop query="getUsedParts">
				<cfif len(#collObjIds#) is 0>
					<cfset collObjIds = "#getUsedParts.collection_object_id#">
				  <cfelse>
				  	<cfset collObjIds = "#collObjIds#,#getUsedParts.collection_object_id#">
				</cfif>
			</cfloop>
			
			<cfloop query="getUsedSpecs">
				<cfif len(#collObjIds#) is 0>
					<cfset collObjIds = "#getUsedSpecs.collection_object_id#">
				  <cfelse>
				  	<cfset collObjIds = "#collObjIds#,#getUsedSpecs.collection_object_id#">
				</cfif>
			</cfloop>
			
			
			
		<cfset numItems = getUsedSpecs.recordcount +  getUsedParts.recordcount>
		<cfoutput>
			<cfif #numItems# gt 0>
				This project used <cfoutput>#numItems#</cfoutput> specimens. 
				<form action="SpecimenResults.cfm" method="post" >
				<input type="submit" value="View Specimen Details" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
   
   
				
				<input type="hidden" name="collection_object_id" value="#collObjIds#">
				
				<input type="hidden" name="newQuery" value="1">
				<input type="hidden" name="displayRows" value="10"> <!--- just show them 10 rows --->
				</form>
				
			<cfelse>This project used no specimens.<br>
			</cfif>
		</cfoutput>
	</cfif>
		<cfif #Action# is "viewCont">
		
			<cfquery name="getContributors" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT project.project_id,project_name,start_date,end_date,agent_name,project_agent_role 
				FROM project,project_agent,agent_name WHERE project.project_id = project_agent.project_id AND
				project_agent.agent_name_id = agent_name.agent_name_id AND project.project_id IN 
				(SELECT project_trans.project_id FROM project, project_trans, accn, cataloged_item 
				where project_trans.transaction_id = accn.transaction_id AND 
				accn.transaction_id = cataloged_item.accn_id 
				AND project_trans.project_id = project.project_id 
				AND cataloged_item.collection_object_id IN 
				(
				SELECT cataloged_item.collection_object_id 
				FROM project,project_trans,loan_item,cataloged_item 
				WHERE loan_item.collection_object_id = cataloged_item.collection_object_id AND
				project_trans.transaction_id = loan_item.transaction_id AND 
				project_trans.project_id = project.project_id AND project.project_id = #project_id#
				UNION
				SELECT 
					cataloged_item.collection_object_id 
				FROM 
					project,
					project_trans,
					loan_item,
					specimen_part,
					cataloged_item 
				WHERE 
					loan_item.collection_object_id = specimen_part.collection_object_id AND
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
				project_trans.transaction_id = loan_item.transaction_id AND 
				project_trans.project_id = project.project_id AND project.project_id = #project_id#))  
				ORDER BY project_name,project_id,agent_position
		</cfquery>
			<cfif getContributors.recordcount gt 0>
			<cfquery name="contCnt" dbtype="query">
				select distinct(project_id) from getContributors
			</cfquery>
				<cfoutput>
					#contCnt.recordcount# projects contributed specimens used by
					this project. <br>
				</cfoutput>
				<ul>
				<cfoutput query="getContributors" group="project_id">
					<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
				</cfoutput>
				</ul>
			<cfelse>No projects contributed specimens used by this project.<br>
			</cfif>
			
	</cfif>
	<cfif #Action# is "viewSpec">
		<cfquery name="getContSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				cat_num,cataloged_item.collection_object_id 
			FROM 
				project,project_trans,accn,cataloged_item
			WHERE 
				accn.transaction_id = cataloged_item.accn_id AND 
				project_trans.transaction_id = accn.transaction_id AND 
				project.project_id = project_trans.project_id AND 
				project.project_id = #project_id#
		</cfquery>
			<cfif getContSpecs.recordcount gt 0>
				<cflocation url="SpecimenResults.cfm?project_id=#project_id#">
			<cfelse>
				This project contributed no specimens.<br>
			</cfif>
		
	</cfif>
	
	</td>
  </tr>
</table>
<cf_log cnt=1 coll=na>	 
<cfinclude template = "includes/_footer.cfm">
