<cfinclude template="/includes/_header.cfm">
<cfparam name="filterForPending" default="true">
<cfif #action# is "showStatus">

<cfset title="Pending Relationships">
<cfquery name="getRels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_relations
	<cfif #filterForPending# is "true">
		where related_collection_object_id is null
	</cfif>
</cfquery>
<cfif #getRels.recordcount# is 0>
	There are no pending relationships.
</cfif>
<cfif #filterForPending# is "true">
		Unresolved
</cfif> 
Pending Relationships
<cfif #filterForPending# is "true">
		<br><a href="pendingRelations.cfm?action=showStatus&filterForPending=false">Show all relationships</a>
<cfelse>
	<br><a href="pendingRelations.cfm?action=showStatus&filterForPending=true">Show only unresolved relationships</a>
</cfif> 
<table border>
	<tr>
		<td>
			Specimen
		</td>
		<td>
			Relationship
		</td>
		<td>
			Related Number
		</td>
		<td>Start Date</td>
		<td>
			Last Try Date
		</td>
		<td>
			Status
		</td>
	</tr>
	<cfoutput>
		<cfloop query="getRels">
			<tr>
				<cfquery name="thisSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select cat_num,institution_acronym,cataloged_item.collection_cde from
					cataloged_item,collection where
					cataloged_item.collection_id = collection.collection_id
					and collection_object_id = #collection_object_id#
				</cfquery>
				<td>
					<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
						#thisSpec.institution_acronym# #thisSpec.collection_cde# #thisSpec.cat_num#</a>
				</td>
				<td>
					#relationship#
				</td>
				<td>
					#related_to_num_type# #related_to_number# 
				</td>
				<td>
					#dateformat(insert_date,"dd mmm yyyy")#
				</td>
				<td>
					#dateformat(lasttrydate,"dd mmm yyyy")#
				</td>
				<td>
					<cfif #len(fail_reason)# is 0 and len(#related_collection_object_id#) gt 0>
						<!--- spiffy, it's loaded --->
						<a href="/SpecimenDetail.cfm?collection_object_id=#related_collection_object_id#">
						Successfully resolved (click for related specimen)</a>
					<cfelseif #len(fail_reason)# is 0 and len(#related_collection_object_id#) is 0>
						Has not been tried or has failed unexpectedly. That's bad. 
						Click <a href="pendingRelations.cfm">here</a> to try again.
					<cfelseif #len(fail_reason)# gt 0 and len(#related_collection_object_id#) is 0>
						#fail_reason#
					<cfelse>
						Something hinky is going on. File a <a href="/info/bugs.cfm">bug report</a>. Now!
					</cfif>
				</td>
			</tr>
		</cfloop>
	</cfoutput>
</table>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<cfif #action# is "nothing">
<!--- always try to resolve these things at load --->
	<cfquery name="getRels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_relations
	</cfquery>
	<cfoutput>
		<cfloop query="getRels">
			<cfif #related_to_num_type# is "catalog number">
				<cftry>
				related_to_num_type: #related_to_num_type#<br>
				related_to_number: #related_to_number#<br>
				<cfset spos = find(" ",related_to_number)>
				spos: #spos#<br>
				<cfset inst = trim(left(related_to_number,spos))>
				inst: #inst#<br>
				<cfset rem = right(related_to_number,len(related_to_number)-spos)>
				rem: #rem#<br>
				<cfset spos = find(" ",rem)>
				spos: #spos#<br>
				<cfset coll = trim(left(rem,spos))>
				coll: #coll#<br>
				<cfset cnum = trim(right(rem,len(rem)-spos))>
				cnum: #cnum#<br>
				<cfquery name="isOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						collection_object_id 
					FROM 
						cataloged_item,
						collection
					where 
						cataloged_item.collection_id = collection.collection_id AND
						collection.institution_acronym = '#inst#' AND
						collection.collection_cde = '#coll#' AND
						cat_num = #cnum#
				</cfquery>
				<cfcatch>
					<cfquery name="nope" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update cf_temp_relations set 
							lasttrydate='#dateformat(now(),"dd-mmm-yyyy")#',
							fail_reason='Catalog Number does not exist or is not in UAM Mamm 1234 format'
						WHERE
							collection_object_id=#collection_object_id# and
							related_to_number = '#related_to_number#' and
							related_to_num_type = '#related_to_num_type#' and
							relationship = '#relationship#'
					</cfquery>
					<cfset isOne = queryNew("collection_object_id")>
				</cfcatch>
				</cftry>
			<cfelse>
				<cfquery name="isOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select collection_object_id FROM coll_obj_other_id_num
					where other_id_type = '#related_to_num_type#' and display_value = '#related_to_number#'
				</cfquery>			
			</cfif>
			
			<cfif #isOne.recordcount# is 0>
				<cfquery name="nope" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update cf_temp_relations set 
						lasttrydate='#dateformat(now(),"dd-mmm-yyyy")#',
						fail_reason='Related cataloged item does not exist.'
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
			<cfelseif #isOne.recordcount# gt 1>
				<cfquery name="toomany" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update cf_temp_relations set 
						lasttrydate='#dateformat(now(),"dd-mmm-yyyy")#',
						fail_reason='More than one cataloged item matched.'
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
			<cfelseif #isOne.recordcount# is 1>
				<cftry>
				<cfquery name="insNew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO
						 BIOL_INDIV_RELATIONS (
						 	COLLECTION_OBJECT_ID,
						 	RELATED_COLL_OBJECT_ID,
						 	BIOL_INDIV_RELATIONSHIP )
						 VALUES (
						 	#collection_object_id#,
						 	#isOne.collection_object_id#,
						 	'#relationship#' )
				</cfquery>
				<cfquery name="justRight" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					DELETE FROM cf_temp_relations 
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
				<cfcatch>
					<cfquery name="toomany" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update cf_temp_relations set 
							lasttrydate='#dateformat(now(),"dd-mmm-yyyy")#',
							fail_reason='DB Error. #cfcatch.detail#'
						WHERE
							collection_object_id=#collection_object_id# and
							related_to_number = '#related_to_number#' and
							related_to_num_type = '#related_to_num_type#' and
							relationship = '#relationship#'
					</cfquery>
				</cfcatch>
				</cftry>
				<!---- insert into relationships ---->
			<cfelse>
				<cfquery name="toomany" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update cf_temp_relations set 
						lasttrydate='#dateformat(now(),"dd-mmm-yyyy")#',
						fail_reason='unknown failure!'
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
			</cfif>
		</cfloop>
	<cflocation url="pendingRelations.cfm?action=showStatus">
	<!----
	
	---->
	</cfoutput>
</cfif>