<cfinclude template = "includes/_header.cfm">
<cfif not isdefined("project_id") or not isnumeric(#project_id#)>
	<p style="color:#FF0000; font-size:14px;">
		Did not get a project ID - aborting....
	</p>
	<cfabort>
</cfif>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<style>
	.proj_title {font-size:2em;font-weight:900;text-align:center;}
	.proj_sponsor {font-size:1.5em;font-weight:800;text-align:center;}
	.proj_agent {font-weight:800;text-align:center;}
	.cdiv {text-align:center;}
</style>
<cfoutput>
	<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name,
			project_description,
			start_date,
			end_date,
			agent_name.agent_name, 
			agent_position,
			project_agent_role,
			ps.agent_name sponsor,
			acknowledgement
		FROM 
			project,
			project_agent,
			agent_name,
			project_sponsor,
			agent_name ps
		WHERE 
			project.project_id = project_agent.project_id (+) AND 
			project_agent.agent_name_id = agent_name.agent_name_id (+) and
			project.project_id=project_sponsor.project_id (+) and
			project_sponsor.agent_name_id=ps.agent_name_id (+) and
			project.project_id = #project_id# 
	</cfquery>
	<cfquery name="p" dbtype="query">
		select 
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
		from
			proj
		group by
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
	</cfquery>
	<cfquery name="a" dbtype="query">
		select
			agent_name,
			project_agent_role
		from 
			proj
		group by
			agent_name,
			project_agent_role
		order by 
			agent_position
	</cfquery>
	<cfquery name="s" dbtype="query">
		select 
			sponsor,
			acknowledgement
		from
			proj
		where
			sponsor is not null
		group by			
			sponsor,
			acknowledgement
	</cfquery>
	<cfset title = "Project Detail: #p.project_name#">
	<cfset metaDesc="Project: #p.project_name#">
	<div class="proj_title">#p.project_name#</div>
	<cfloop query="s">
		<div class="proj_sponsor">
			Sponsored by #sponsor# <cfif len(ACKNOWLEDGEMENT) gt 0>: #ACKNOWLEDGEMENT#</cfif>
		</div>
	</cfloop>
	<cfloop query="a">
		<div class="proj_agent">
			#agent_name#: #project_agent_role#
		</div>
	</cfloop>
	<div class="cdiv">
		#dateformat(p.start_date,"dd mmmm yyyy")# - #dateformat(p.end_date,"dd mmmm yyyy")#
	</div>
	<h2>Description</h2>
	#p.project_description#
	<div id="pubs">
		<h2>Publications</h2>
		<img src="">/images/indicator.gif
	</div>
	
<script>

		var tab=document.getElementById('pubs');
		var ptl="/includes/SpecSearch/" + id + ".cfm";
		$.get(ptl, function(data){
			 $(tab).html(data);
		})

</script>	
	<!-----------
	
	<h2>Specimens Used</h2>
	<cfquery name="getUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			collection,
			collection_id,
			sum(c) c
		from (
			SELECT 
				collection.collection,
				collection.collection_id,
				count(distinct(cataloged_item.collection_object_id)) c
			FROM 
				cataloged_item,
				collection,
				specimen_part,
				loan_item,
				project_trans
			WHERE
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
				cataloged_item.collection_id=collection.collection_id and
				specimen_part.collection_object_id = loan_item.collection_object_id AND
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#
			group by
				collection.collection,
				collection.collection_id
			UNION
			SELECT 
				collection.collection,
				collection.collection_id,
				count(distinct(cataloged_item.collection_object_id)) c
			FROM 
				cataloged_item,
				collection,
				loan_item,
				project_trans
			WHERE
				cataloged_item.collection_object_id = loan_item.collection_object_id AND
				cataloged_item.collection_id=collection.collection_id and
				loan_item.transaction_id = project_trans.transaction_id AND
				project_trans.project_id = #project_id#
			group by
				collection.collection,
				collection.collection_id)
		group by
			collection,
			collection_id
	</cfquery>
	<cfquery name="ts" dbtype="query">
		select sum(c) totspec from getUsed
	</cfquery>
	<cfif getUsed.recordcount is 0>
		<div class="notFound">
			This project used no specimens.
		</div>
	<cfelse>
		This project used <a href="/SpecimenResults.cfm?loan_project_id=#project_id#">#ts.totspec# Specimens</a>
		<ul>
			<cfloop query="getUsed">
				<li>
					<a href="/SpecimenResults.cfm?loan_project_id=#project_id#&collection_id=#collection_id#">
						#c# #collection# Specimens
					</a>
				</li>
			</cfloop>
		</ul>
	</cfif>
	<h2>Specimens Contributed</h2>
	<cfquery name="getContSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			collection,
			collection.collection_id,
			count(*) c
		FROM 
			project,
			project_trans,
			accn,
			cataloged_item,
			collection
		WHERE 
			accn.transaction_id = cataloged_item.accn_id AND
			cataloged_item.collection_id=collection.collection_id and
			project_trans.transaction_id = accn.transaction_id AND 
			project.project_id = project_trans.project_id AND 
			project.project_id = #project_id#
		group by
			collection,
			collection.collection_id
	</cfquery>
	<cfif getContSpecs.recordcount is 0>
		<div class="notFound">
			This project contributed no specimens.
		</div>
	<cfelse>
		<cfquery name="ts" dbtype="query">
			select sum(c) totspec from getContSpecs
		</cfquery>
		This project contributed <a href="SpecimenResults.cfm?project_id=#project_id#">#ts.totspec# Specimens</a>
		<ul>
			<cfloop query="getContSpecs">
				<li>#c# #collection# <a href="SpecimenResults.cfm?project_id=#project_id#&collection_id=#collection_id#">Specimens</a></li>
			</cfloop>
		</ul>
	</cfif>
	<h2>Projects contributing specimens</h2>
	<cfquery name="getContributors" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name
		FROM 
			project
		WHERE 
			project.project_id IN (
				SELECT 
					project_trans.project_id 
				FROM 
					project, 
					project_trans, 
					accn, 
					cataloged_item 
				where 
					project_trans.transaction_id = accn.transaction_id AND 
					accn.transaction_id = cataloged_item.accn_id AND 
					project_trans.project_id = project.project_id AND 
					cataloged_item.collection_object_id IN (
						SELECT 
							cataloged_item.collection_object_id 
						FROM 
							project,
							project_trans,
							loan_item,
							cataloged_item 
						WHERE 
							loan_item.collection_object_id = cataloged_item.collection_object_id AND
							project_trans.transaction_id = loan_item.transaction_id AND 
							project_trans.project_id = project.project_id AND 
							project.project_id = #project_id#
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
							project_trans.project_id = project.project_id AND 
							project.project_id = #project_id#
						)
					)  
			ORDER BY 
				project_name
	</cfquery>
	<cfif getContributors.recordcount is 0>
		<div class="notFound">
			This project used no specimens contributed by other projects.
		</div>
	<cfelse>
		#getContributors.recordcount# projects contributed specimens used by this project.
		<ul>
			<cfloop query="getContributors">
				<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
			</cfloop>
		</ul>
	</cfif>
	<h2>Projects using contributed specimens</h2>
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name 
		FROM 
			project
		WHERE 
			project.project_id IN (
				SELECT 
			 		project_trans.project_id 
			 	FROM 
			 		project, 
			 		project_trans, 
			 		loan_item, 
			 		cataloged_item 
			 	where 
			 		project_trans.transaction_id = loan_item.transaction_id AND 
			 		loan_item.collection_object_id = cataloged_item.collection_object_id AND 
			 		project_trans.project_id = project.project_id AND cataloged_item.collection_object_id IN (
			 			SELECT 
			 				cataloged_item.collection_object_id 
			 			FROM 
			 				project,
			 				project_trans,
			 				accn,
			 				cataloged_item 
			 			WHERE 
			 				accn.transaction_id = cataloged_item.accn_id AND 
			 				project_trans.transaction_id = accn.transaction_id AND 
			 				project_trans.project_id = project.project_id AND 
			 				project.project_id = #project_id#
			 			UNION
			 			SELECT 
			 				cataloged_item.collection_object_id 
			 			FROM 
			 				project,
			 				project_trans,
			 				accn,
			 				cataloged_item 
			 			WHERE 
			 				accn.transaction_id = cataloged_item.accn_id AND 
			 				project_trans.transaction_id = accn.transaction_id AND 
			 				project_trans.project_id = project.project_id AND 
			 				project.project_id = #project_id#
			 			)
			 		)
		group by 
			project.project_id,
			project_name
		order by project_name
	</cfquery>
	<cfif getUsers.recordcount is 0>
		<div class="notFound">
			No projects have used specimens contributed by this project.
		</div>
	<cfelse>
		#getUsers.recordcount# Projects used specimens contributed by this project.		
		<ul>
		<cfloop query="getUsers">
			<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
		</cfloop>
		</ul>
	</cfif>
	<h2>Media</h2>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select distinct 
	        media.media_id,
	        media.media_uri,
	        media.mime_type,
	        media.media_type,
	        media.preview_uri
	     from
	         media,
	         media_relations,
	         media_labels
	     where
	         media.media_id=media_relations.media_id and
	         media.media_id=media_labels.media_id (+) and
	         media_relations.media_relationship like '% project' and
	         media_relations.related_primary_key = #project_id#
	</cfquery>
	<cfif #media.recordcount# gt 0>
    	<div class="projMediaCell">
			<cfloop query="media">
            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select
						media_label,
						label_value
					from
						media_labels
					where
						media_id=#media_id#
				</cfquery>
                <cfset mrel=getMediaRelations(#media_id#)>
               <div class="oneMedia">
	               <cfif len(#preview_uri#) gt 0>
	                   <a href="#media_uri#" target="_blank"><img src="#preview_uri#" alt="Media Preview Image"></a>
	                   <br>#media_type# (#mime_type#)
	               <cfelse>
	                   <cfset h=left(media_uri,40) & "...">
	                   <a href="#media_uri#" target="_blank">#h#</a>
	                   <br>#media_type# (#mime_type#)
	               </cfif>
                   <cfif #mrel.recordcount# gt 0>
						<br>Relations:
							<ul>
								<cfloop query="mrel">
									<li>#media_relationship#: #summary#
										<cfif len(#link#) gt 0>
					                        <a class="infoLink" href="#link#" target="_blank">More...</a>
					                    </cfif>
									</li>
								</cfloop>
							</ul>
					</cfif>
					<cfif #labels.recordcount# gt 0>
						<br>Labels:
						<ul>
							<cfloop query="labels">
								<li>#media_label#: #label_value#</li>
							</cfloop>
						</ul>
					</cfif>
				</div>
			</cfloop>
		</div>		
	<cfelse>
		<div class="notFound">
			No Media is attached to this project.
		</div>
	</cfif>
	------>
</cfoutput>
<cf_log cnt=1 coll=na>	 
<cfinclude template = "includes/_footer.cfm">
