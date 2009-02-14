
<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("autorun")>
	<cfset autorun="nope">
</cfif>
<cfif #action# is "nothing">
<a href="mergeDups.cfm?autorun=yep">Autorun</a>
 <p>First Hundred Duplicates:
	<cfquery name="findAllDups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cataloged_item.collection_object_id,
			collection,
			cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.customotheridentifier#') AS CustomID,
			concatencumbrances(cataloged_item.collection_object_id) encumbrances,
			scientific_name,
			RELATED_COLL_OBJECT_ID,
			flags
		FROM
			collection,
			cataloged_item,
			coll_object,
			identification,
			biol_indiv_relations
		where
			cataloged_item.collection_id = collection.collection_id and
			cataloged_item.collection_object_id = identification.collection_object_id and
			cataloged_item.collection_object_id = coll_object.collection_object_id and
			accepted_id_fg=1 and
			cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id and
			BIOL_INDIV_RELATIONSHIP = 'duplicate of' and
			coll_object.flags is null and
			concatencumbrances(cataloged_item.collection_object_id) is null and
			rownum < 100
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<td>Record One</td>
				<td>Record Two</td>
				<td>&nbsp;</td>
			</tr>

		<cfloop query="findAllDups">
			<cfquery name="dupRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					cataloged_item.collection_object_id,
					collection,
					cat_num,
					concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') AS CustomID,
					concatencumbrances(cataloged_item.collection_object_id) encumbrances,
					scientific_name,
					flags
				FROM
					collection,
					cataloged_item,
					coll_object,
					identification
				where
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = identification.collection_object_id and
					accepted_id_fg=1 and
					cataloged_item.collection_object_id = coll_object.collection_object_id and
					flags is null and
					cataloged_item.collection_object_id = #RELATED_COLL_OBJECT_ID#
			</cfquery>
			<tr>
				<td><a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection# #cat_num#</a> (#session.customOtherIdentifier# #CustomID#) <em>#scientific_name#</em></td>
				<td><a href="/SpecimenDetail.cfm?collection_object_id=#dupRec.collection_object_id#">#dupRec.collection# #dupRec.cat_num#</a>
					(#session.customOtherIdentifier# #dupRec.CustomID#) 
					<em>#dupRec.scientific_name#</em>
				</td>
				<td>
					<cfif len(#dupRec.collection_object_id#) gt 0 and
						len(#encumbrances#) is 0 AND len(#dupRec.encumbrances#) is 0 and len(#flags#) is 0 and len(#duprec.flags#) is 0>
						<a href="mergeDups.cfm?action=merge&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#">Merge</a>
						<cfif #autorun# is "yep">
							<script>
								document.location = 'mergeDups.cfm?autorun=yep&action=merge&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#';
							</script>
						</cfif>
					<cfelse>
						no merge
					</cfif>
				</td>
			</tr>
		</cfloop>
			</table>
	
	</cfoutput>
</cfif>
<!--------------------------->
<cfif #action# is "merge">
	<cfoutput>
	<cfset problems = "">
		<cfset sql = "
			select 
				cataloged_item.collection_object_id,
				collection,
				cat_num,
				concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') AS CustomID,
				concatencumbrances(cataloged_item.collection_object_id) encumbrances,
				scientific_name,
				accepted_id_fg,
				nature_of_id,
				verbatim_date,
				spec_locality,
				higher_geog,
				concatcoll(cataloged_item.collection_object_id) collectors,
				concatparts(cataloged_item.collection_object_id) parts
			FROM
				collection,
				cataloged_item,
				identification,
				collecting_event,
				locality,
				geog_auth_rec
			where
				cataloged_item.collection_id = collection.collection_id and
				cataloged_item.collection_object_id = identification.collection_object_id and
				cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
				collecting_event.locality_id = locality.locality_id and
				locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id
		">
		<cfquery name="one" datasource="#Application.uam_dbo#">
			 #preservesinglequotes(sql)# and
				cataloged_item.collection_object_id = #id1#
		</cfquery>
		<cfquery name="two" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)# and
				cataloged_item.collection_object_id = #id2#
		</cfquery>
		<cfdump var="#one#" label="one">
		<cfdump var="#two#" label="two">
		<!---
		
		---->
		<cfif #one.verbatim_date# is "not recorded" and
			#one.spec_locality# is "No specific locality recorded." and
			#one.higher_geog# is "no higher geography recorded" and
			#one.collectors# is "unknown" and
			#one.parts# is #two.parts#>
			<cfquery name="bad" dbtype="query">
				select * from one
			</cfquery>
			<cfquery name="good" dbtype="query">
				select * from two
			</cfquery>
		<cfelseif #two.verbatim_date# is "not recorded" and
			#two.spec_locality# is "No specific locality recorded." and
			#two.higher_geog# is "no higher geography recorded" and
			#two.collectors# is "unknown" and
			#one.parts# is #two.parts#>	
			<cfquery name="bad" dbtype="query">
				select * from two
			</cfquery>
			<cfquery name="good" dbtype="query">
				select * from one
			</cfquery>
		<cfelse>
			<cfset problems = "No bad record found.">
		</cfif>
		<cfif len(#problems#) is 0>
			<cfif #bad.recordcount# neq 1>
				<cfset problems = "#problems#; Too many bads - perhaps extra IDs?">
			</cfif>
		</cfif>
		<cfif len(#problems#) is 0>
			<cfif len(#problems#) is 0 and (len(bad.encumbrances) gt 0 or len(good.encumbrances) gt 0)>
				<cfset problems = "#problems#; found encumbrances">
			</cfif>
		</cfif>
		<cfif len(#problems#) is 0>
			<cfquery name="part" datasource="#Application.uam_dbo#">
			select container.container_id,container.parent_container_id from
					specimen_part,
					coll_object,
					coll_obj_cont_hist,
					container
				where
					specimen_part.collection_object_id= coll_object.collection_object_id and
					specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id = container.container_id and
					specimen_part.derived_from_cat_item = #good.collection_object_id#
			</cfquery>
			<cfif #part.parent_container_id# neq 0>
				<cfset problems = "#problems#;good container has a location">
			</cfif>
		</cfif>
		
		<cfif len(#problems#) is 0>
	<cftransaction>
		<cfquery name="goodID" datasource="#Application.uam_dbo#">
			select * from identification,identification_taxonomy where 
			identification.identification_id = identification_taxonomy.identification_id and
			collection_object_id = #bad.collection_object_id#
		</cfquery>
		<cfquery name="nid" datasource="#Application.uam_dbo#">
			select max(identification_id) + 1 id from identification
		</cfquery>
		<cfset idid = nid.id>
		<cfloop query="goodID">
			<br>create ID			
			<cfquery name="newInsId" datasource="#Application.uam_dbo#">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				IDENTIFICATION_REMARKS,
				TAXA_FORMULA ,
				SCIENTIFIC_NAME)
			values (
				#idid#,
				#good.collection_object_id#,
				'#dateformat(MADE_DATE,"dd-mmm-yyyy")#',
				'#NATURE_OF_ID#',
				0,
				'#IDENTIFICATION_REMARKS#',
				'#TAXA_FORMULA#',
				'#SCIENTIFIC_NAME#')
			</cfquery>
				<br>insert ID taxonomy
			<cfquery name="newInsIdTax" datasource="#Application.uam_dbo#">
			insert into identification_taxonomy (
					IDENTIFICATION_ID,
					TAXON_NAME_ID,
					VARIABLE)
				values (
					#idid#,
					#TAXON_NAME_ID#,
					'#VARIABLE#')
			</cfquery>
			<cfquery name="IDAgnt" datasource="#Application.uam_dbo#">
				select * from identification_agent where IDENTIFICATION_ID = #IDENTIFICATION_ID#
			</cfquery>
			<cfloop query="IDAgnt">
			<br>insert ID agent(s)
			<cfquery name="newInsIdAgnt" datasource="#Application.uam_dbo#">
				insert into identification_agent (
					IDENTIFICATION_ID,
					AGENT_ID,
					IDENTIFIER_ORDER)
				values (
					#idid#,
					#agent_id#,
					#identifier_order#)
				</cfquery>
			</cfloop>
			<cfset idid = idid + 1>
		</cfloop>

		
		<cfquery name="badpart" datasource="#Application.uam_dbo#">
			select container.container_id,container.parent_container_id from
				specimen_part,
				coll_object,
				coll_obj_cont_hist,
				container
			where
				specimen_part.collection_object_id= coll_object.collection_object_id and
				specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id = container.container_id and
				specimen_part.derived_from_cat_item = #bad.collection_object_id#
		</cfquery>
		<br>Bring container position over
		<cfquery name="upcont" datasource="#Application.uam_dbo#">
			update container set parent_container_id = #badpart.parent_container_id#
			where container_id = #part.container_id#
		</cfquery>
		
		<br>Encumber the bad record
		<cfquery name="mkenc" datasource="#Application.uam_dbo#">
			insert into  COLL_OBJECT_ENCUMBRANCE (ENCUMBRANCE_ID,COLLECTION_OBJECT_ID)
			values (1000025,#bad.collection_object_id#)
		</cfquery>	
		It's done:	
		</cftransaction>
		<br><a href="/SpecimenDetail.cfm?collection_object_id=#good.collection_object_id#">Good Record</a>
		<br><a href="/SpecimenDetail.cfm?collection_object_id=#bad.collection_object_id#">Bad Record</a>
		<cfelse>
			<cfif isdefined("bad.collection_object_id")>
				<cfset thisOneToFlag = bad.collection_object_id>
			<cfelse>
				<cfset thisOneToFlag = id1>
			</cfif>
			<cfquery name="flag" datasource="#Application.uam_dbo#">
				update coll_object set flags='duplicate' where collection_object_id = #thisOneToFlag#
			</cfquery>
			<br>There are problems with these records. One has been flagged ("Missing") as "duplicate".
			<br>#problems#
			<br><a href="/SpecimenDetail.cfm?collection_object_id=#id1#">One Record</a>
			<br><a href="/SpecimenDetail.cfm?collection_object_id=#id2#">Other Record</a>
		</cfif>
		
		<br><a href="mergeDups.cfm">Back to list</a>
		<cfif #autorun# is "yep">
			<cflocation url="mergeDups.cfm?autorun=yep">
		</cfif>		
	</cfoutput>
</cfif>
