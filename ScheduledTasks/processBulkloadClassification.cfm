<cfif not isdefined("action")><cfset action="nothing"></cfif>

run these in order


<br><a href="processBulkloadClassification.cfm?action=checkConsistency">checkConsistency</a>

<br><a href="processBulkloadClassification.cfm?action=checkMeta">checkMeta</a>
<br><a href="processBulkloadClassification.cfm?action=getTID">getTID</a>
<br><a href="processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus">fill_in_the_blanks_from_genus</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>
<br><a href="processBulkloadClassification.cfm?action=load">load</a>

<!---------------------------------------------------------->


<cfif action is "checkConsistency">
	<cfoutput>
        <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from CF_TEMP_CLASSIFICATION where status='go_go_check_consistency'
		</cfquery>
		<!--- run through ranks in order, make sure higher taxonomy is consistent ---->
		<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				taxon_term
			from
				CTTAXON_TERM
			where
				IS_CLASSIFICATION=1 and
				-- ignore things which have no logical parent
				taxon_term not in ('scientific_name')
			order by
				RELATIVE_POSITION desc
		</cfquery>

		<cfset oTerms=valuelist(CTTAXON_TERM.taxon_term)>
		<cfset usedTerms="">
		<!--- deal with order==>phylorder ---->
		<cfset oTerms=replace(oTerms,',order,',',phylorder,')>
		<cfloop list="#oTerms#" index="thisTerm">
			<br>#thisTerm#
			<cfquery name="hasThis" dbtype="query">
				select count(*) c from d where #thisTerm# is not null
			</cfquery>
			<cfif hasThis.c gt 0>
				<br>there are records with #thisTerm#
				<cfset usedTerms=listappend(usedTerms,thisterm)>
			</cfif>
		</cfloop>
		<br>these terms are used and need checked
		#usedTerms#
		<cfset lNum=1>
		<cfset thisHigher=usedTerms>
		<cfloop list="#usedTerms#" index="thisTerm">
			<!--- remove the current term; everything upstream should match ---->
			<cfset thisHigher=listDeleteAt(thisHigher,1)>

			<cfquery name="uThisTerm" dbtype="query">
				select #thisTerm# termvalue from d group by #thisTerm#
			</cfquery>
			<!----
			<cfif len(uThisTerm.termvalue) gt 0>
			</cfif>
			---->
			<cfloop query="uThisTerm">
				<cfif len(uThisTerm.termvalue) gt 0>
				<cfquery name="thisHigherCombined" dbtype="query">
						select #thisHigher# from d where #thisTerm#='#termvalue#' group by #thisHigher#
					</cfquery>
					<cfif thisHigherCombined.recordcount neq 1>
						<p>
							INCONSISTENCY DETECTED!!
						</p>
						<!--- figure out what exactly is inconsistent ---->
						<cfloop list="#thisHigherCombined.columnList#" index="c">
							<cfquery name="dt" dbtype="query">
								select #c# from thisHigherCombined group by #c#
							</cfquery>
							<cfif dt.recordcount neq 1>
								<br><cfdump var=#dt#>
								<br>#c# IN (#valuelist(dt.#c#)#)
							</cfif>
						</cfloop>

						<!----
				        <cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update CF_TEMP_CLASSIFICATION set status='inconsistency detected at #thisTerm#=#termvalue#'
							where status='go_go_check_consistency' and #thisTerm#='#termvalue#'
						</cfquery>
						---->
						<cfdump var=#thisHigherCombined#>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		 <cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='conssitency_check_passed'
			where status='go_go_check_consistency'
		</cfquery>

	</cfoutput>
</cfif>



<cfif action is "fill_in_the_blanks_from_genus">

<cfif not isdefined ("escapequotes")>
	<cfinclude template="/includes/functionLib.cfm">
</cfif>
	<!---
		grab genus (lowest term in supplied data)
		find everything "below" that uses the same string
		copy genus record with additional species/subspecies
	---->
	<cfoutput>
		<!--- globals ---->
		<cfquery name="dbcols" datasource="uam_god">
			select
				column_name
			from
				user_tab_cols
			where
				upper(table_name)='CF_TEMP_CLASSIFICATION' and
				lower(column_name) not in ('taxon_name_id','classification_id')
			ORDER BY INTERNAL_COLUMN_ID
		</cfquery>
		<cfset knowncols=valuelist(dbcols.column_name)>
		<cfset stuffToReplace="AUTHOR_TEXT,SOURCE_AUTHORITY,VALID_CATALOG_TERM_FG,TAXON_STATUS,REMARK,DISPLAY_NAME,SUBGENUS,SPECIES,SUBSPECIES">
		<cfset numberOfColumns=listlen(knowncols)>
		<cfquery name="d" datasource="uam_god">
			select * from CF_TEMP_CLASSIFICATION where species is null
			and genus is not null
			and status='fill_in_the_blanks_from_genus'
			and rownum<101
		</cfquery>
		<!---- /globals --->
		<cfloop query="d">
			<cfset updatedOrig=false>
			<hr>running for #genus#
			<cftransaction>
			<!--- build a query object from this row of the existing data --->
			<cfset nd=queryNew(knowncols)>
			<cfset temp=queryAddRow(nd,1)>
			<cfloop list="#knowncols#" index="c">
				<cfset thisval=evaluate(c)>
				<cfset temp=QuerySetCell(nd, c, thisval)>
			</cfloop>
			<cfquery name="otherstuff" datasource="uam_god">
				select distinct taxon_name_id from taxon_term where term_type='genus' and term='#genus#' and source='Arctos'
			</cfquery>
			<cfloop query="otherstuff">
				<cfset problem="">
				<cfquery name="oneclass" datasource="uam_god">
					select
						taxon_name.scientific_name,
						taxon_term.CLASSIFICATION_ID,
						taxon_term.TERM_TYPE,
						taxon_term.term
					from
						taxon_name,
						taxon_term
					where
						taxon_name.taxon_name_id=taxon_term.taxon_name_id and
						taxon_term.source='Arctos' and
						taxon_name.taxon_name_id=#taxon_name_id#
				</cfquery>


				<!----reset the stuff that we're changing in the query---->
				<cfloop list='#stuffToReplace#' index="x">
					<cfset temp=QuerySetCell(nd, x, "")>
				</cfloop>



				<cfloop query="oneclass">
					<cfif term_type is "order">
						<cfset ttt="phylorder">
					<cfelse>
						<cfset ttt=term_type>
					</cfif>
					<cfif len(TERM_TYPE) is 0 or not listfindnocase(knowncols,ttt)>
						<cfif len(ttt) is 0>
							<cfset clmn='[NULL]'>
						<cfelse>
							<cfset clmn=ttt>
						</cfif>
						<cfset problem=listappend(problem,'#clmn# is not a known column',';')>
					</cfif>
					<cfset this_TERM_TYPE=ttt>
					<cfset this_term=TERM>

					<cfif listfindnocase(stuffToReplace,ttt)>
						<cfset temp=QuerySetCell(nd, ttt, this_term)>
					</cfif>
				</cfloop>
				<!--- failures if there's no term scientific name, so force-update it from
					taxon_name ---->
				<cfset temp=QuerySetCell(nd, 'scientific_name', oneclass.scientific_name)>


				<cfif len(nd.species) gt 0>


					<cfset problem=listprepend(problem,'autoinsert',':')>

					<cfset temp=QuerySetCell(nd, "status", problem)>
					<cfset sql="insert into CF_TEMP_CLASSIFICATION (#knowncols#) values (">
					<cfset pos=0>
					<cfloop list="#knowncols#" index="c">
						<cfset thisval=evaluate("nd." & c)>
						<cfif len(thisval) gt 0>
							<cfset sql=sql & "'" & escapeQuotes(thisval) & "'">
						<cfelse>
							<cfset sql=sql & "NULL">
						</cfif>
						<cfset pos=pos+1>
						<cfif pos lt numberOfColumns>
							<cfset sql=sql & ",">
						</cfif>
					</cfloop>
					<cfset sql=sql & ")">
					<cftry>
					<cfquery name="insertone" datasource="uam_god">
						#preserveSingleQuotes(sql)#
					</cfquery>
					<cfcatch>
						<p>Something bad happened with this:</p>
						<br>#sql#
						<br>#cfcatch.detail#
					</cfcatch>
					</cftry>
				<cfelse>
					<p>
						updating genus-only record from Arctos
					</p>


					<cfset problem=listprepend(problem,'autofillintheblanks',':')>

					<cfset temp=QuerySetCell(nd, "status", problem)>
					<!---- ONLY update the original record when NULL ---->
					<cfset sql="update CF_TEMP_CLASSIFICATION set ">

					<cfloop list="#stuffToReplace#" index="col">
						<cfset thisval=evaluate("nd." & col)>
						<cfset origval=evaluate("d." & col)>
						<cfif len(origval) is 0 and len(thisval) gt 0>
							<cfset sql=sql & " #col#='#escapeQuotes(thisval)#', ">
						</cfif>
						<!--- so the SQL will always work ---->

					</cfloop>

					<cfset sql=sql & "status='#problem#' ">
					<cfset sql=sql & "WHERE SCIENTIFIC_NAME='#d.SCIENTIFIC_NAME#' ">




						<cfquery name="updateorig" datasource="uam_god">
							#preserveSingleQuotes(sql)#
						</cfquery>

						<cfset updatedOrig=true>

				</cfif>
			</cfloop>
			<cfif updatedOrig is false>
				<cfquery name="gotit" datasource="uam_god">
					update CF_TEMP_CLASSIFICATION set status = 'autoupdatefail: nothing found'
					where SCIENTIFIC_NAME='#d.SCIENTIFIC_NAME#'
				</cfquery>

			</cfif>






			</cftransaction>
		</cfloop>
	</cfoutput>




</cfif>
<!---------------------------------------------------------->

<cfif action is "checkMeta">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='display_name is required' where status ='ready_to_check' and display_name is null
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid source' where status ='ready_to_check' and source not in (
			select source from CTTAXONOMY_SOURCE
		)
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid nomenclatural_code' where status ='ready_to_check' and nomenclatural_code not in ('ICZN','ICBN')
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='subspecies is the only acceptable ICZN infraspecific data'
		where status='ready_to_check'  and nomenclatural_code = 'ICZN'
		and (forma is not null or subsp is not null)
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='subspecies is ICZN-only'
		where status ='ready_to_check' and nomenclatural_code != 'ICZN'
		and subspecies is not null
	</cfquery>

	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='only one infraspecific term may be given'
		where status='ready_to_check'  and
		(
			subspecies is not null and (forma is not null or subsp is not null) or
			forma is not null and (subspecies is not null or subsp is not null) or
			subsp is not null and (forma is not null or subspecies is not null)
		)
	</cfquery>

	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='pass_meta' where status ='ready_to_check'
	</cfquery>


</cfif>
<!---------------------------------------------------------->

<cfif action is "getTID">
	<cfquery name="getTID" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			status='found_name',
			taxon_name_id=(
				select taxon_name.taxon_name_id from taxon_name where
				taxon_name.scientific_name = CF_TEMP_CLASSIFICATION.scientific_name
			)
		where
			status ='pass_meta' and
			taxon_name_id is null
	</cfquery>



	<p>
		update
			CF_TEMP_CLASSIFICATION
		set
			status='found_name',
			taxon_name_id=(
				select taxon_name.taxon_name_id from taxon_name where
				taxon_name.scientific_name = CF_TEMP_CLASSIFICATION.scientific_name
			)
		where
			status ='pass_meta' and
			taxon_name_id is null
	</p>
	<cfquery name="fail" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			status='scientific_name not found'
		where
			status ='pass_meta' and
			taxon_name_id is null
	</cfquery>


	<p>

	update
			CF_TEMP_CLASSIFICATION
		set
			status='scientific_name not found'
		where
			status ='pass_meta' and
			taxon_name_id is null



	</p>

</cfif>
<!---------------------------------------------------------->

<cfif action is "getClassificationID">
	<cfquery name="mClassificationID" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			status='multiple classification found - update denied'
		where
			status ='found_name' and
			scientific_name in (
				select scientific_name from (
					select
						count(distinct(taxon_term.CLASSIFICATION_ID)),
			          	taxon_term.taxon_name_id,
			          	taxon_term.CLASSIFICATION_ID
			        from
			          CF_TEMP_CLASSIFICATION,
			          taxon_term
			        where
			          taxon_term.taxon_name_id=CF_TEMP_CLASSIFICATION.taxon_name_id and
			          taxon_term.source=CF_TEMP_CLASSIFICATION.source
			        having
			        	count(distinct(taxon_term.CLASSIFICATION_ID)) > 1
			        group by
			        	taxon_term.CLASSIFICATION_ID,
			        	taxon_term.taxon_name_id
			    )
			)
	</cfquery>



	<cfquery name="getClassificationID" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			status='passed_all_checks',
			classification_id=(
				select distinct
					classification_id
				from
					taxon_term
				where
					taxon_term.taxon_name_id=CF_TEMP_CLASSIFICATION.taxon_name_id and
					taxon_term.source=CF_TEMP_CLASSIFICATION.source
			)
		where
			status ='found_name'
	</cfquery>
	<cfquery name="findfail" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			classification_id='[NEW]',
			status='passed_all_checks'
		where
			status ='found_name' and
			classification_id is null
	</cfquery>

	<p>
	update
			CF_TEMP_CLASSIFICATION
		set
			classification_id='[NEW]'
			status='ready_to_load'
		where
			status ='found_name' and
			classification_id is null

	</p>


</cfif>
<!--------------------------------------------------------------------------->
<cfif action is "load">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from CF_TEMP_CLASSIFICATION where status='ready_to_load' and rownum<10
		</cfquery>
		<cfquery name="CTTAXON_TERM" datasource="uam_god">
			select * from CTTAXON_TERM
		</cfquery>
		<cfquery name="ncq" dbtype="query">
			select * from CTTAXON_TERM where IS_CLASSIFICATION=0
		</cfquery>
		<cfset noclassterms=valuelist(ncq.TAXON_TERM)>
		<cfquery name="cq" dbtype="query">
			select * from CTTAXON_TERM where IS_CLASSIFICATION=1 order by RELATIVE_POSITION
		</cfquery>
		<!---- these need to be ordered ---->
		<cfset classificationTerms="">
		<cfloop query="cq">
			<cfset classificationTerms=listappend(classificationTerms,TAXON_TERM)>
		</cfloop>
		<cfset classificationTerms=ListSetAt(classificationTerms,listfindnocase(classificationTerms,'order'),'phylorder')>

		<cfloop query="d">
			<cftransaction>
				<cfif classification_id is '[NEW]'>
					<cfset thisClassificationID=CreateUUID()>
				<cfelse>
					<cfset thisClassificationID=classification_id>
				</cfif>
				<br>delete from taxon_term where taxon_name_id=#taxon_name_id# and source='#source#'

				<cfloop list="#noclassterms#" index="thisTermType">
					<cfset thisTermVal=evaluate("d." & thisTermType)>
					<br>thisTermType: #thisTermType#
					<br>thisTermVal: #thisTermVal#
					<br>nomenclatural_code: #nomenclatural_code#

					<cfif len(thisTermVal) gt 0>
						<br>
						<cfquery name="insncterm" datasource="uam_god">
							insert into taxon_term (
								TAXON_TERM_ID,
								TAXON_NAME_ID,
								CLASSIFICATION_ID,
								TERM,
								TERM_TYPE,
								SOURCE,
								LASTDATE
							) values (
								sq_TAXON_TERM_ID.nextval,
								#TAXON_NAME_ID#,
								'#thisClassificationID#',
								'#thisTermVal#',
								'#thisTermType#',
								'#source#',
								sysdate
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfset thisPosn=1>

				<cfloop list="#classificationTerms#" index="thisTermType">
					<cfset thisTermType=replace(thisTermType,'.','','all')>
					<cfset thisTermVal=evaluate("d." & thisTermType)>
					<br>thisTermType: #thisTermType#
					<br>thisTermVal: #thisTermVal#
					<cfif len(thisTermVal) gt 0>
						<cfif thisTermType is "subsp">
						<cfset thisTermType= thisTermType & '.'>
						<br>issubsp
					</cfif>
					<br>
					<cfquery name="inscterm" datasource="uam_god">
						insert into taxon_term (
							TAXON_TERM_ID,
							TAXON_NAME_ID,
							CLASSIFICATION_ID,
							TERM,
							TERM_TYPE,
							SOURCE,
							LASTDATE,
							POSITION_IN_CLASSIFICATION
						) values (
							sq_TAXON_TERM_ID.nextval,
							#TAXON_NAME_ID#,
							'#thisClassificationID#',
							'#thisTermVal#',
							'#thisTermType#',
							'#source#',
							sysdate,
							#thisPosn#
						)
					</cfquery>
					<cfset thisPosn=thisPosn+1>
				</cfif>
			</cfloop>
			<cfquery name="git" datasource="uam_god">
				update CF_TEMP_CLASSIFICATION set status='made_updates_all_done' where scientific_name='#d.scientific_name#'
			</cfquery>

			</cftransaction>
		</cfloop>
	</cfoutput>


</cfif>

