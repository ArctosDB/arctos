<cfcomponent>

<!--------------------------------------------------------------------------------------->
	<cffunction name="getDisplayClassData" access="remote">
		<cfargument name="taxon_name_id" type="numeric" required="true">
		<cfquery name="raw" datasource="uam_god">
			select
				TERM,
				TERM_TYPE,
				SOURCE,
				CLASSIFICATION_ID,
				TAXON_NAME_ID
			from
				taxon_term
			where
				SOURCE in (select SOURCE from CTTAXONOMY_SOURCE) and
				term_type in ('taxon_status','display_name') and
				TAXON_NAME_ID=#val(taxon_name_id)#
		</cfquery>
		<cfquery name="dcid" dbtype="query">
			select CLASSIFICATION_ID, TAXON_NAME_ID from raw group by CLASSIFICATION_ID,TAXON_NAME_ID
		</cfquery>
		<cfset d=StructNew()>
		<cfloop query="dcid">
			<cfset o.CLASSIFICATION_ID=dcid.CLASSIFICATION_ID>
			<cfquery name="ts" dbtype="query">
				select TERM from raw where CLASSIFICATION_ID='#CLASSIFICATION_ID#' and term_type='taxon_status'
			</cfquery>
			<cfset o.taxon_status=valuelist(ts.term,"|")>
			<cfquery name="dv" dbtype="query">
				select TERM from raw where CLASSIFICATION_ID='#CLASSIFICATION_ID#' and term_type='display_name'
			</cfquery>
			<cfset o.display_name=valuelist(dv.term,"|")>
			<cfset StructAppend(d, o)>
		</cfloop>

		<cfreturn d>

	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getWormsData" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="taxon_name" type="string" required="true">
		<cfparam name="debug" default="false">
		<cfoutput>
		<cftry>
			<cfhttp  result="ga" url="http://www.marinespecies.org/rest/AphiaRecordsByName/#urlencodedformat(taxon_name)#?like=false&marine_only=false&offset=1" method="get"></cfhttp>
			<cfif debug is true>
				<cfdump var=#ga#>
			</cfif>
			<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
				<cfset gao=DeserializeJSON(ga.filecontent)>
				<cfif debug is true>
					<cfdump var=#gao#>
				</cfif>
				<cfset therecord=gao[1]>
				<cfif isdefined("therecord.AphiaID") and len(therecord.AphiaID) gt 0>
					<!--- now get tree --->
					<cfhttp  result="gt" url="http://www.marinespecies.org/rest/AphiaClassificationByAphiaID/#therecord.AphiaID#" method="get"></cfhttp>
					<cfif gt.statusCode is "200 OK" and len(gt.filecontent) gt 0 and isjson(gt.filecontent)>
						<cfset gto=DeserializeJSON(gt.filecontent)>
						<cfset skey="gto">
						<cfset taxonRankStringified="">
						<cfloop from ="1" to="100" index="i">
							<cfif isdefined("#skey#")>
								<cftry>
									<cfset rn="rank_#i#">
									<cfset rt="term_#i#">
									<CFSET StructInsert(therecord, "#rn#", evaluate(skey & ".rank"))>
									<CFSET StructInsert(therecord, "#rt#", evaluate(skey & ".scientificname"))>
								<cfcatch></cfcatch>
								</cftry>
								<cfset skey=skey & ".child">
							<cfelse>
								<cfbreak >
							</cfif>
						</cfloop>
						<cfif i gt 1>
							<!----
								if we made it here everything should be happy and we should have some data, so create the classification
								try to use Arctos terms for easy copy-pasta
							---->
							<CFSET StructInsert(therecord, "number_of_cterms", i-1)>
							<cftransaction>
								<cfquery name="tid" datasource="uam_god">
									select taxon_name_id from taxon_name where scientific_name='#taxon_name#'
								</cfquery>
								<cfset thisSourceID=CreateUUID()>
								<cfset thisSrcName="WoRMS (via Arctos)">
								<cfquery name="flushOld" datasource="uam_god">
									delete from taxon_term where taxon_name_id=#tid.taxon_name_id# and source='#thisSrcName#'
								</cfquery>
								<cfif structkeyexists(therecord,"authority")>
									<cfset t="author_text">
									<cfset d=therecord.authority>
									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											NULL,
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>
								<cfif structkeyexists(therecord,"citation")>
									<cfset t="citation">
									<cfset d=therecord.citation>
									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											NULL,
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>

								<cfif structkeyexists(therecord,"isExtinct")>
									<cfif therecord.isExtinct is "0" or therecord.isExtinct is 1>
										<cfset t="taxon_status">
										<cfif therecord.isExtinct is "1">
											<cfset d='extinct'>
										<cfelse>
											<cfset d='extant'>
										</cfif>
									</cfif>
									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											NULL,
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>


								<cfif structkeyexists(therecord,"status")>
									<cfset t="taxon_status">
									<!--- try to get local terminology --->
									<cfif therecord.status is 'accepted'>
										<cfset d='valid'>
									<cfelseif therecord.status is 'unaccepted'>
										<cfset d='invalid'>
									<cfelse>
										<cfset d=therecord.status>
									</cfif>
									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											NULL,
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>

								<cfif structkeyexists(therecord,"unacceptreason")>
									<cfif therecord.unacceptreason is not "undefined">
										<cfset t="remark">
										<cfset d="unacceptreason: " & therecord.unacceptreason>
										<cfquery name="meta" datasource="uam_god">
											insert into taxon_term (
												taxon_term_id,
												taxon_name_id,
												term,
												term_type,
												source,
												position_in_classification,
												classification_id
											) values (
												sq_taxon_term_id.nextval,
												#tid.taxon_name_id#,
												'#d#',
												'#t#',
												'#thisSrcName#',
												NULL,
												'#thisSourceID#'
											)
										</cfquery>
									</cfif>
								</cfif>

								<cfif structkeyexists(therecord,"url")>
									<cfset t="URL">
									<cfset d='<a href="#therecord.URL#" target="_blank" class="external">#therecord.URL#</a>'>
									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											NULL,
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>

								<cfif structkeyexists(therecord,"valid_name")>
									<cfif not (structkeyexists(therecord,"scientificname")) or (therecord.valid_name is not therecord.scientificname)>
										<cfset t="valid_name">
										<cfset d=therecord.valid_name>
										<cfquery name="meta" datasource="uam_god">
											insert into taxon_term (
												taxon_term_id,
												taxon_name_id,
												term,
												term_type,
												source,
												position_in_classification,
												classification_id
											) values (
												sq_taxon_term_id.nextval,
												#tid.taxon_name_id#,
												'#d#',
												'#t#',
												'#thisSrcName#',
												NULL,
												'#thisSourceID#'
											)
										</cfquery>
									</cfif>
								</cfif>

								<cfif structkeyexists(therecord,"valid_authority")>
									<cfif not (structkeyexists(therecord,"authority")) or (therecord.authority is not therecord.valid_authority)>
										<cfset t="valid_authority">
										<cfset d=therecord.valid_authority>
										<cfquery name="meta" datasource="uam_god">
											insert into taxon_term (
												taxon_term_id,
												taxon_name_id,
												term,
												term_type,
												source,
												position_in_classification,
												classification_id
											) values (
												sq_taxon_term_id.nextval,
												#tid.taxon_name_id#,
												'#d#',
												'#t#',
												'#thisSrcName#',
												NULL,
												'#thisSourceID#'
											)
										</cfquery>
									</cfif>
								</cfif>

								<cfif structkeyexists(therecord,"number_of_cterms")>
									<cfloop from ="1" to="#therecord.number_of_cterms#" index="i">
										<cfset t=lcase(evaluate("therecord.rank_" & i))>
										<cfset d=evaluate("therecord.term_" & i)>
										<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id
										) values (
											sq_taxon_term_id.nextval,
											#tid.taxon_name_id#,
											'#d#',
											'#t#',
											'#thisSrcName#',
											#i#,
											'#thisSourceID#'
										)
									</cfquery>
									</cfloop>
								</cfif>
							</cftransaction>
						</cfif>
					</cfif>
				<cfelse>
					<cfset r.status='fail'>
					<cfset r.msg='no aphiaid found'>
					<cfreturn r>
				</cfif>
			<cfelse>
				<cfset r.status='fail'>
				<cfset r.msg='not found at WoRMS'>
				<cfreturn r>
			</cfif>
			<cfcatch>
				<cfset r.status='fail'>
				<cfset r.msg=cfcatch.detail>
				<cfreturn r>
			</cfcatch>
			</cftry>
			<cfset r.status='success'>
			<cfreturn r>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getRelatedTaxa" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="TAXON_NAME_ID" type="numeric" required="true">
		<cfoutput>
			<!----
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#"  cachedwithin="#createtimespan(0,0,60,0)#">
				select #TAXON_NAME_ID# TAXON_NAME_ID,reldir,scientific_name,TAXON_RELATIONSHIP from (
					select
						'from' reldir,
						scientific_name,
						TAXON_RELATIONSHIP
					from
						taxon_name,
						taxon_relations
					where
						taxon_name.taxon_name_id=taxon_relations.taxon_name_id and
						taxon_relations.RELATED_TAXON_NAME_ID=#taxon_name_id#
					union
					select
						'to' reldir,
						scientific_name,
						TAXON_RELATIONSHIP
					from
						taxon_name,
						taxon_relations
					where
						taxon_name.taxon_name_id=taxon_relations.RELATED_TAXON_NAME_ID and
						taxon_relations.taxon_name_id=#taxon_name_id#
				) order by scientific_name

			</cfquery>

---->

<cfquery name="related" datasource="uam_god">
		select
			TAXON_RELATIONSHIP,
			RELATION_AUTHORITY,
			a.scientific_name related_name,
			b.scientific_name this_name
		from
			taxon_relations,
			taxon_name a,
			taxon_name b
		where
			taxon_relations.related_taxon_name_id=a.taxon_name_id and
			taxon_relations.taxon_name_id=b.taxon_name_id and
			taxon_relations.taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfquery name="revrelated" datasource="uam_god">
		select
			TAXON_RELATIONSHIP,
			RELATION_AUTHORITY,
			b.scientific_name related_name ,
			a.scientific_name this_name
		from
			taxon_relations,
			taxon_name a,
			taxon_name b
		where
			taxon_relations.related_taxon_name_id=a.taxon_name_id and
			taxon_relations.taxon_name_id=b.taxon_name_id and
			taxon_relations.related_taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfset d=queryNew('relationship')>
    <cfloop query="related">
	  	<cfset tr='#this_name# &##8594; #TAXON_RELATIONSHIP# &##8594; <a target="_blank" href="/name/#related_name#">#related_name#</a>'>

        <cfif len(RELATION_AUTHORITY) gt 0>
			<cfset tr=tr & " (Authority: #RELATION_AUTHORITY#)">
		</cfif>
		<cfset queryAddRow(d,{relationship="#tr#"})>
     </cfloop>
 <cfloop query="revrelated">
		<cfset tr='<a target="_blank" href="/name/#related_name#">#related_name#</a>  &##8594; #TAXON_RELATIONSHIP# &##8594; #this_name#'>

        <cfif len(RELATION_AUTHORITY) gt 0>
			<cfset tr=tr & " (Authority: #RELATION_AUTHORITY#)">
		</cfif>
		<cfset queryAddRow(d,{relationship="#tr#"})>
     </cfloop>
			<cfreturn d>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getTaxonStatus" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="taxon_name_id" type="numeric" required="true">
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#"  cachedwithin="#createtimespan(0,0,60,0)#">
				select term, source from taxon_term where term_type='taxon_status' and taxon_name_id=#taxon_name_id# group by term, source order by term, source
			</cfquery>
			<cfset x="">
			<cfloop query="d">
				<cfset x=listappend(x,'#term# (#source#)',';')>
			</cfloop>

			<cfset result.status="success">
			<cfset result.taxon_name_id=taxon_name_id>
			<cfset result.taxon_status=x>
			<cfreturn result>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->


<!--------------------------------------------------------------------------------------->
	<cffunction name="validateName" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="taxon_name" type="string" required="true">
		<cfoutput>
			<cfset result.consensus="probably_not_valid">
			<cfhttp url="https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#taxon_name#&language=en&format=json" method="get">
			<cfif isdefined("debug") and debug is true>
				<p>https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#taxon_name#&language=en&format=json</p>
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif cfhttp.filecontent contains '"search":[]'>
				<cfset result.wiki='not_found'>
			<cfelse>
				<cfset result.wiki='found'>
				<cfset result.consensus="might_be_valid">
			</cfif>

			<cfhttp url="http://gni.globalnames.org/name_strings.json?search_term=exact:#taxon_name#" method="get">
			</cfhttp>

			<cfif isdefined("debug") and debug is true>
				<p>http://gni.globalnames.org/name_strings.json?search_term=exact:#taxon_name#</p>
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif cfhttp.filecontent contains '"name_strings_total":0'>
				<cfset result.gni='not_found'>
			<cfelse>
				<cfset result.gni='found'>
				<cfset result.consensus="might_be_valid">
			</cfif>

			<cfhttp url="http://www.marinespecies.org/rest/AphiaIDByName/#taxon_name#?marine_only=false" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>

			<cfif isdefined("debug") and debug is true>
				<p>http://www.marinespecies.org/rest/AphiaIDByName/#taxon_name#?marine_only=false</p>
				<cfdump var=#cfhttp#>
			</cfif>


			<cfif len(cfhttp.filecontent) gt 0 and cfhttp.filecontent does not contain "Not found">
				<cfset result.worms='found'>
				<cfset result.consensus="might_be_valid">
			<cfelse>
				<cfset result.worms='not_found'>
			</cfif>


			<cfhttp url="http://eol.org/api/search/1.0.json?page=1&q=/#taxon_name#&exact=true" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>

			<cfif isdefined("debug") and debug is true>
				<p>http://eol.org/api/search/1.0.json?page=1&q=#taxon_name#&exact=true</p>
				<cfdump var=#cfhttp#>
			</cfif>

			<cfif cfhttp.filecontent contains '"totalResults":0'>
				<cfset result.eol='not_found'>
			<cfelse>
				<cfset result.eol='found'>
				<cfset result.consensus="might_be_valid">
			</cfif>

			<cfhttp url="http://api.gbif.org/v1/species?strict=true&name=#taxon_name#&nameType=scientific" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>

			<cfif isdefined("debug") and debug is true>
				<p>http://api.gbif.org/v1/species?strict=true&name=#taxon_name#&nameType=scientific</p>
				<cfdump var=#cfhttp#>
			</cfif>


			<cfif cfhttp.filecontent contains '"results":[]'>
				<cfset result.gbif='not_found'>
			<cfelse>
				<cfset result.gbif='found'>
				<cfset result.consensus="might_be_valid">
			</cfif>
			<cfreturn result>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="deleteSeed" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="tid" type="string" required="true">
		<cfoutput>
			<cftry>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into htax_markdeletetree (
					seed_tid,
					seed_term,
					username,
					delete_id,
					status
				) (
					select
						#tid#,
						term,
						'#session.username#',
						SYS_GUID(),
						'mark_to_delete'
					from
						hierarchical_taxonomy
					where
						tid=#tid#
				)
			</cfquery>
			<cfreturn 'success'>
			<cfcatch>
				<cfreturn 'ERROR: ' & cfcatch.message>
			</cfcatch>
			</cftry>
			<!----

			---->
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="exportSeed" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="tid" type="string" required="true">
		<cfoutput>
			<cftry>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into htax_export (
					dataset_id,
					seed_term,
					username,
					status,
					export_id
				) (
					select
						dataset_id,
						term,
						'#session.username#',
						'mark_to_export',
						SYS_GUID()
					from
						hierarchical_taxonomy
					where
						tid=#tid#
				)
			</cfquery>
			<cfreturn 'success'>
			<cfcatch>
				<cfreturn 'ERROR: ' & cfcatch.message>
			</cfcatch>
			</cftry>
			<!----

			---->
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="consistencyCheck" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="term" type="string" required="true">
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					taxon_term.term_type,
					count(*) timesUsed
				from
					taxon_name,
					taxon_term,
					CTTAXONOMY_SOURCE
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.source=CTTAXONOMY_SOURCE.source and
					taxon_term.position_in_classification is not null and
					-- exclude usage as name
					taxon_term.term_type != 'scientific_name' and
					taxon_term.term='#term#'
				group by taxon_term.term_type
				order by count(*)
			</cfquery>
			<cfreturn d>
		</cfoutput>
	</cffunction>
<!----------------------------------------------
	<cffunction name="moveTermNewParent" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="term" type="string" required="true">
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from hierarchical_taxonomy where term='#term#'
			</cfquery>
			<cfif d.recordcount is 1 and len(d.tid) gt 0>
				<cfquery name="np" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update hierarchical_taxonomy set parent_tid=#d.tid# where tid=#id#
				</cfquery>
				<!--- return
					1) the parent; it's what we'll need to expand;
					2) the child so we can focus it
				---->
				<cfset myStruct = {}>
				<cfset myStruct.status='success'>
				<cfset myStruct.child=id>
				<cfset myStruct.parent=d.tid>

			<cfelse>
				<cfset myStruct = {}>
				<cfset myStruct.status='fail'>
				<cfset myStruct.child=id>
				<cfset myStruct.parent=-1>
			</cfif>
			<cfreturn myStruct>
		</cfoutput>
	</cffunction>
----------------------------------------->
<!--------------------------------------------------------------------------------------->
	<cffunction name="createTerm" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="newChildTerm" type="string" required="true">
		<cfargument name="newChildTermRank" type="string" required="true">
		<cftry>
			<cfoutput>
				<cfif len(newChildTerm) is 0 or len(newChildTermRank) is 0>
					<cfthrow message="newChildTerm and newChildTermRank are required">
				</cfif>
			<cftransaction>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from hierarchical_taxonomy where tid=#id#
				</cfquery>
				<cfquery name="ntid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select somerandomsequence.nextval ntid from dual
				</cfquery>
				<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into hierarchical_taxonomy (
						TID,
						PARENT_TID,
						TERM,
						RANK,
						DATASET_ID
					) values (
						#ntid.ntid#,
						#id#,
						'#newChildTerm#',
						'#newChildTermRank#',
						#d.DATASET_ID#
					)
				</cfquery>
			</cftransaction>
			<cfset r={}>
			<cfset r.status='success'>
			<cfset r.parent_id=id>
			<cfset r.child_id=ntid.ntid>
			<cfreturn r>
		</cfoutput>
		<cfcatch>
			<cfset r={}>
			<cfset r.status='fail'>
			<cfset r.parent_id=id>
			<cfset r.child_id="">
			<cfset r.message=cfcatch.message & '; ' & cfcatch.detail>
			<cfreturn r>
		</cfcatch>
		</cftry>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="deleteTerm" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfoutput>
			<cftry>
			<cftransaction>

				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from hierarchical_taxonomy where tid=#id#
				</cfquery>

				<cfquery name="deorphan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from htax_noclassterm where tid=#id#
				</cfquery>
				<cfif len(d.PARENT_TID) is 0>
					<cfquery name="udc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update hierarchical_taxonomy set PARENT_TID=NULL where parent_tid=#id#
					</cfquery>
				<cfelse>
					<cfquery name="udc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update hierarchical_taxonomy set PARENT_TID=#d.PARENT_TID# where parent_tid=#id#
					</cfquery>
				</cfif>
				<cfquery name="bye" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from hierarchical_taxonomy where tid=#id#
				</cfquery>
			</cftransaction>
			<cfreturn 'success'>
			<cfcatch>
				<cfreturn 'FAIL: ' & cfcatch.message & '; ' & cfcatch.detail >
			</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="saveMetaEdit" access="remote">
		<!---- hierarchical taxonomy editor ---->
		 <cfargument name="q" type="string" required="true">
	<cfoutput>
		<!----
			de-serialize q
			throw it in a query because easy
		---->
		<cfset qry=queryNew("qtrm,qval")>
		<cfloop list="#q#" delimiters="&?" index="i">
			<cfif listlen(i,"=") eq 2>
				<cfset t=listGetAt(i,1,"=")>
				<cfset v=listGetAt(i,2,"=")>
				<cfset queryAddRow(qry, {qtrm=t,qval=v})>
			</cfif>
		</cfloop>
		<cfif isdefined("debug") and debug is 1>
			<cfdump var=#qry#>
		</cfif>
		<!--- should always have this; fail if no --->
		<cfquery name="x" dbtype="query">
			select qval from qry where qtrm='tid'
		</cfquery>
		<cfset tid=x.qval>
		<cftry>
		<cftransaction>
			<cfloop query="qry">
				<cfif isdefined("debug") and debug is 1>
					<br>loopy @ #qtrm#
				</cfif>
				<cfif left(qtrm,15) is "nctermtype_new_">
					<!--- there should be a corresponding nctermvalue_new_1 ---->
					<cfset thisIndex=listlast(qtrm,"_")>
					<cfquery name="thisval" dbtype="query">
						select QVAL from qry where qtrm='nctermvalue_new_#thisIndex#'
					</cfquery>
					<cfif isdefined("debug") and debug is 1>
						<br>nctermtype_new_
						<br>qval: #qval#
						<br>thisval.qval: #thisval.qval#
					</cfif>
					<cfquery name="insone" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into htax_noclassterm (
							NC_TID,
							TID,
							TERM_TYPE,
							TERM_VALUE
						) values (
							somerandomsequence.nextval,
							#tid#,
							'#qval#',
							'#URLDecode(thisval.qval)#'
						)
					</cfquery>
				<cfelseif left(qtrm,11) is "nctermtype_">
					<cfif isdefined("debug") and debug is 1>
						<br>nctermtype_
						<br>qval: #qval#
						<br>thisval.qval: #thisval.qval#
					</cfif>
					<cfset thisIndex=listlast(qtrm,"_")>
					<cfquery name="thisval" dbtype="query">
						select QVAL from qry where qtrm='nctermvalue_#thisIndex#'
					</cfquery>
					<cfif QVAL is "DELETE">
						<cfquery name="done" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from htax_noclassterm where NC_TID=#thisIndex#
						</cfquery>
					<cfelse>
						<cfquery name="uone" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update htax_noclassterm set TERM_TYPE='#qval#',TERM_VALUE='#URLDecode(thisval.qval)#' where NC_TID=#thisIndex#
						</cfquery>
					</cfif>
				<cfelseif qtrm is "newParentTermValue">
					<cfset nptv=qval>
				</cfif>
			</cfloop>
			<!--- if we got in newParentTermValue, move the child --->
			<cfif isdefined("nptv") and len(nptv) gt 0>
				<cfif isdefined("debug") and debug is 1>
					<br>got nptv
				</cfif>
				<cfquery name="thisID" dbtype="query">
					select QVAL from qry where QTRM='tid'
				</cfquery>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from hierarchical_taxonomy where term='#nptv#' and dataset_id in (select dataset_id from hierarchical_taxonomy where tid=#tid#)
				</cfquery>
				<!----
					<cfdump var=#d#>
					---->
				<cfif d.recordcount is 1 and len(d.tid) gt 0>
					<cfquery name="np" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update hierarchical_taxonomy set parent_tid=#d.tid# where tid=#thisID.QVAL#
					</cfquery>
					<!--- return
						1) the parent; it's what we'll need to expand;
						2) the child so we can focus it
					---->
					<cfif isdefined("debug") and debug is 1>
						<br>set nptv status success
					</cfif>
					<cfset myStruct = {}>
					<cfset myStruct.status='success'>
					<cfset myStruct.child=thisID.QVAL>
					<cfset myStruct.parent=d.tid>
				<cfelse>
					<cfif isdefined("debug") and debug is 1>
						<br>set nptv status fail
					</cfif>
					<!----
					<cfdump var=#d#>
					---->
					<cfset myStruct = {}>
					<cfset myStruct.status='fail'>
					<cfset myStruct.message='unable to find parent term'>
					<cfset myStruct.child=thisID.QVAL>
					<cfset myStruct.parent=-1>
				</cfif>
			<cfelse>

				<cfif isdefined("debug") and debug is 1>
					<br>set NON-nptv status success
				</cfif>
				<!---- not changing parent, just return success. We'll be in the catch if the normal update failed --->
				<cfset myStruct = {}>
				<cfset myStruct.status='success'>
			</cfif>

		</cftransaction>
		<cfif isdefined("debug") and debug is 1>
			<br>returning this:<cfdump var=#myStruct#>
		</cfif>

		<cfreturn myStruct>
		<cfcatch>
			<!----
			<cfdump var=#cfcatch#>
			---->
			<cfset myStruct = {}>
			<cfset myStruct.status='fail'>
			<cfset myStruct.message=cfcatch.message & cfcatch.detail>
		</cfcatch>
		</cftry>

		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getSeedTaxSum" access="remote">
		<!---- hierarchical taxonomy editor ---->
		 <cfargument name="source" type="string" required="false">
	   <cfargument name="kingdom" type="string" required="false">
	   <cfargument name="phylum" type="string" required="false">
	   <cfargument name="class" type="string" required="false">
	   <cfargument name="order" type="string" required="false">
	   <cfargument name="family" type="string" required="false">
	   <cfargument name="genus" type="string" required="false">



		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					count(distinct(scientific_name)) c
				from
					taxon_name,
					taxon_term
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.source='#source#'
					<cfif len(kingdom) gt 0>
						and term_type='kingdom' and term='#kingdom#'
					</cfif>
					<cfif len(phylum) gt 0>
						and term_type='phylum' and term='#phylum#'
					</cfif>
					<cfif len(class) gt 0>
						and term_type='class' and term='#class#'
					</cfif>
					<cfif len(order) gt 0>
						and term_type='order' and term='#order#'
					</cfif>
					<cfif len(family) gt 0>
						and term_type='family' and term='#family#'
					</cfif>
					<cfif len(genus) gt 0>
						and term_type='genus' and term='#genus#'
					</cfif>
			</cfquery>
			<cfreturn d>
		</cfoutput>

	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="saveParentUpdate" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfargument name="tid" type="numeric" required="true">
		<cfargument name="parent_tid" type="numeric" required="true">
		<cfoutput>
			<cftry>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update hierarchical_taxonomy set parent_tid=#parent_tid# where
					dataset_id=#dataset_id# and tid=#tid#
				</cfquery>
				<cfreturn 'success'>
				<cfcatch>
					<cfreturn 'ERROR: ' & cfcatch.message>
				</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getTaxTreeChild" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfargument name="id" type="numeric" required="true">
		<cfoutput>
			<cftry>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select term,tid,nvl(parent_tid,0) parent_tid, rank from hierarchical_taxonomy where
					dataset_id=#dataset_id# and parent_tid = #id# order by term
				</cfquery>
				<cfreturn d>
				<cfcatch>
					<cfreturn 'ERROR: ' & cfcatch.message>
				</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->

	<cffunction name="getTaxTreeSrch" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
	   <cfargument name="q" type="string" required="true">
		<!---- https://goo.gl/TWqGAo is the quest for a better query. For now, ugly though it be..... ---->
		<cfoutput>
			<cftry>
				<!--- temp key ---->
				<cfset key=RandRange(1, 99999999)>
				<!--- build rows in Oracle ---->
				<cfstoredproc procedure="proc_htax_srch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#dataset_id#"><!---- v_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#q#"><!---- v_parent_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#key#"><!---- v_container_type ---->
				</cfstoredproc>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						nvl(parent_tid,0) parent_tid,
						tid,
						term,
						rank
					from htax_srchhlpr
					where key=#key#
					order by parent_tid
				</cfquery>
				<!--- cf's query-->JSON is dumb and dhtmlxtree is too so....---->
				<cfset x="[">
				<cfset i=1>
				<cfloop query="d">
					<cfset x=x & '["#tid#","#parent_tid#","#term# (#rank#)"]'>
					<cfif i lt d.recordcount>
						<cfset x=x & ",">
					</cfif>
					<cfset i=i+1>
				</cfloop>
				<cfset x=x & "]">

				<!--- now clean up, because we're cool like that ---->
				<cfquery name="cleanup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from htax_srchhlpr where key=#key#
				</cfquery>


				<cfreturn x>
				<!----
				<cfdump var=#d#>
				--->



			<!-------------

			<!---- first get the terms that match our search ---->

			<!--- result isn't working properly with this type of SQL so.... ---->
			<cftransaction>

				<!--- this works
				<cfquery name="dc0" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="r_dc0">
					insert into htax_srchhlpr (
						key,
						parent_tid
					) (
						select distinct
							#key#,
							nvl(parent_tid,0)
						from
							hierarchical_taxonomy
						where
							dataset_id=#dataset_id# and
							upper(term) like '#ucase(q)#%'
					)
				</cfquery>
				<cfquery name="rst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="r_dc0">
					select count(*) c from htax_srchhlpr where key=#key#
				</cfquery>
			</cftransaction>

			<cfif not rst.c gt 0>
				<!--- nothing to clean up, just return ---->
				<cfreturn 'ERROR: nothing found'>
			</cfif>


			<!--- this will die if we ever get more than 100-deep ---->
			<cfset thisIds=valuelist(dc0.parent_tid)>
			<cfloop from="1" to="100" index="i">
				<!---find next parent--->
				<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where tid in (#thisIds#)
				</cfquery>


---->
			<!---- first get the terms that match our search ---->
			<cfquery name="dc0" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select distinct nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where
				dataset_id=#dataset_id# and
				upper(term) like '#ucase(q)#%'
			</cfquery>
			<cfif not dc0.recordcount gt 0>
				<cfreturn 'ERROR: nothing found'>
			</cfif>

			<!---- copy init query---->
			<cfquery name="rsltQry" dbtype="query">
				select * from dc0
			</cfquery>
			<!--- this will die if we ever get more than 100-deep ---->
			<cfset thisIds=valuelist(dc0.parent_tid)>
			<cfloop from="1" to="100" index="i">
				<!---find next parent--->
				<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where tid in (#thisIds#)
				</cfquery>



				<!--- next loop --->

				<cfset thisIds=valuelist(q.parent_tid)>

				<cfif len(thisIds) is 0>
					<cfbreak>
				</cfif>


				<cfloop query="q">
					<!--- don't insert if we already have it ---->
					<cfquery dbtype="query" name="alreadyGotOne">
						select count(*) c from rsltQry where tid=#tid#
					</cfquery>
					<cfif not alreadyGotONe.c gt 0>
						<!--- insert ---->
						<cfset queryaddrow(rsltQry,{
							tid=q.tid,
							parent_tid=q.parent_tid,
							term=q.term,
							rank=q.rank
						})>
					</cfif>
				</cfloop>

			</cfloop>

			<cfset x="[">
			<cfset i=1>
			<cfloop query="rsltQry">

				<!----
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
				---->
				<cfset x=x & '["#tid#","#parent_tid#","#term# (#rank#)"]'>
				<cfif i lt rsltQry.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">

			<cfreturn x>
			-------------->
	<cfcatch>
		<cfreturn 'ERROR: ' & cfcatch.message & ' ' & cfcatch.detail>
	</cfcatch>
		</cftry>

		</cfoutput>

	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getInitTaxTree" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where
				dataset_id=#dataset_id# and parent_tid is null order by term
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '["#tid#","#parent_tid#","#term# (#rank#)"]'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">
			<cfreturn x>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
</cfcomponent>
