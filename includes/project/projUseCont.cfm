jQuery(document).ready(function(){
	$("#pucspc").html($("#v_pucspc").val());
	$("#pucspsc").html($("#v_pucspsc").val());
});


<cfoutput>
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			 		specimen_part,
			 		cataloged_item
			 	where
			 		project_trans.transaction_id = loan_item.transaction_id AND
			 		loan_item.collection_object_id = specimen_part.collection_object_id AND
			 		specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			 		project_trans.project_id = project.project_id AND
			 		cataloged_item.collection_object_id IN (
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
	<cfif getUsers.recordcount gt 0>
		<h2>Projects using contributed specimens</h2>
		#getUsers.recordcount# Projects
		<a href="/SpecimenResults.cfm?project_id=#project_id#&loan_project_id=#valuelist(getUsers.project_id)#">
			used specimens contributed by this project</a>.

			Those projects produced <span id="pucspc"></span> publications which include
			<span id="pucspsc"></span> citations.
			<cfset pucspc=0>
			<cfset pucspsc=0>

		<div class="scrollyTextBlock">
			<ul>
				<cfloop query="getUsers">
					<li><a href="/ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
					<cfquery name="pCits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							short_citation,
							publication.publication_id,
							DOI,
							count(citation.collection_object_id) numCits
						from
							publication,
							project_publication,
							citation
						where
							publication.publication_id=project_publication.publication_id and
							publication.publication_id=citation.publication_id (+) and
							project_publication.project_id=#project_id#
						group by
							short_citation,
							publication.publication_id,
							DOI
						order by
							short_citation
					</cfquery>



					<ul>
						<cfif pCits.recordcount is 0>
							<li>
								This project produced no publications.
							</li>
						<cfelse>
							<cfloop query="pCits">
								<cfset pucspc=pucspc+1>
								<cfset pucspsc=pucspsc+numCits>
								<li>
									<a href="/publication/#publication_id#">#short_citation#</a>
									<cfif len(DOI) gt 0>
										<a href="http://dx.doi.org/#doi#" target="_blank" class="external sddoi">#doi#</a>
									</cfif>
									<ul>
										<cfif numCits is 0>
											<li>This publication includes no citations.</li>
										<cfelse>
											<li><a href="/SpecimenResults.cfm?publication_id=#publication_id#">#numCits# Citations</a></li>
										</cfif>
									</ul>
								</li>
							</cfloop>
						</cfif>
					</ul>

				</cfloop>
			</ul>
		</div>
		<input type="hidden" id="v_pucspc" value="#pucspc#">
		<input type="hidden" id="v_pucspsc" value="#pucspsc#">
	</cfif>
</cfoutput>