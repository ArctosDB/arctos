<cfif not isdefined("action")><cfset action="nothing"></cfif>

run these in order

<br><a href="processBulkloadClassification.cfm?action=doEverything">doEverything</a>


<br><a href="processBulkloadClassification.cfm?action=checkConsistency">checkConsistency</a>
<br><a href="processBulkloadClassification.cfm?action=sciname_weird_check">sciname_weird_check</a>
<br><a href="processBulkloadClassification.cfm?action=sciname_valid_check">sciname_valid_check</a>
<br><a href="processBulkloadClassification.cfm?action=checkGaps">checkGaps</a>


<br><a href="processBulkloadClassification.cfm?action=checkMeta">checkMeta</a>
<br><a href="processBulkloadClassification.cfm?action=getTID">getTID</a>
<br><a href="processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus">fill_in_the_blanks_from_genus</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>
<br><a href="processBulkloadClassification.cfm?action=load">load</a>
<!---------------------------------------------------------->
<cfif action is "doEverything">
<cfoutput>
	 <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from CF_TEMP_CLASSIFICATION where status='go_go_all' and rownum <= 100
	</cfquery>
	<cfquery name="oClassTerms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			taxon_term
		from
			CTTAXON_TERM
		where
			IS_CLASSIFICATION=1 and
			-- ignore things which make sloppy namestrings
			taxon_term not in ('scientific_name','forma','subspecies','species','subgenus')
		order by
			RELATIVE_POSITION desc
	</cfquery>
	<cfset ttList=valuelist(oClassTerms.taxon_term)>
	<cfset ttList=replace(ttList,',order,',',phylorder,')>

	<cfloop query="d">
		<cftransaction>
			<cfset thisProb="">
			<!---- sciname_valid_check ---->
			<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select isValidTaxonName('#scientific_name#') v from dual
			</cfquery>
			<cfif p.v is not "valid">
				<cfset thisProb=listappend(thisProb,'invalid scientific_name: #p.v#',';')>
			</cfif>
			<!--- weird junk in terms --->
			<cfloop list="#ttList#" index="term">
				<cfset prob="">
				<cfset thisTerm=evaluate("d." & term)>
				<cfif len(thisTerm) gt 0>
					<!--- pretty much isValidTaxonName with some extra paranoia ---->
					<cfif thisTerm contains "  ">
						<cfset prob=listappend(prob,'double space detected in #term#=#thisTerm#',';')>
					</cfif>
					<cfif compare(trim(thisTerm), thisterm) neq 0>
						<cfset prob=listappend(prob,'Leading/trailing spaces@#term#=#thisTerm#',';')>
					</cfif>



					<cfif compare(lcase(thisTerm), thisterm) eq 0>
						<cfset prob=listappend(prob,'Names should not be all lower-case detected in #term#=#thisTerm#',';')>
					</cfif>
					<cfif compare(ucase(thisTerm), thisterm) eq 0>
						<cfset prob=listappend(prob,'Names should not be all upper-case detected in #term#=#thisTerm#',';')>
					</cfif>
					<cfif refind('[^A-Za-züë×ö\. -]',thisTerm)>
						<cfset prob=listappend(prob,'Invalid characters in #term#=#thisTerm#',';')>
					</cfif>
					<cfif len(trim(thisTerm)) eq 1>
						<cfset prob=listappend(prob,'Too short@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains ' x '>
						<cfset prob=listappend(prob,'Looks like a hybrid@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains ' sp ' or right(lcase(thisTerm),3) is ' sp'>
						<cfset prob=listappend(prob,'"sp" is not a valid name-part@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains ' ssp ' or right(lcase(thisTerm),4) is ' ssp'>
						<cfset prob=listappend(prob,'"ssp" is not a valid name-part@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains ' or '>
						<cfset prob=listappend(prob,'"or" is not a valid name-part@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains ' and '>
						<cfset prob=listappend(prob,'"and" is not a valid name-part@#term#=#thisTerm#',';')>
					</cfif>
					<cfif lcase(thisTerm) contains '.' >
						<cfset prob=listappend(prob,'"." is not a valid name-part@#term#=#thisTerm#',';')>
					</cfif>
					<cfif len(prob) gt 0>
						<cfset thisProb=listappend(thisProb,prob,';')>
					</cfif>
				</cfif>

			</cfloop>


			<!---- checkGaps ---->
			<cfquery name="hmc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					count(distinct(classification_id)) ccid
				from
					taxon_name,
					taxon_term
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.source='Arctos' and
					taxon_name.scientific_name='#scientific_name#'
			</cfquery>
			<cfif hmc.ccid gt 1>
				<cfset thisProb=listappend(thisProb,'#hmc.ccid# classifications detected',';')>
			</cfif>
			<cfquery name="funkyTerms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					TERM_TYPE , term
				from
					taxon_name,
					taxon_term
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.source='Arctos' and
					taxon_name.scientific_name='#scientific_name#' and
					(
						taxon_term.TERM_TYPE is null or
				 		taxon_term.TERM_TYPE not in (select taxon_term from CTTAXON_TERM)
					)
			</cfquery>
			<cfset prob="">
			<cfloop query="funkyTerms">
				<cfset prob=listappend(prob,'#term#=#TERM_TYPE#')>
			</cfloop>
			<cfif len(prob) gt 0>
				<cfset thisProb=listappend(thisProb,prob,';')>
			</cfif>

			<cfif len(subspecies) gt 0>
				<cfif scientific_name neq "#genus# #species# #subspecies#">
					<cfset thisProb=listappend(thisProb,"scientific_name is not genus+species+subspecies",';')>
				</cfif>
			<cfelseif len(species) gt 0>
				<cfif scientific_name neq "#genus# #species#">
					<cfset thisProb=listappend(thisProb,"scientific_name is not genus+species",';')>
				</cfif>
			</cfif>

			<cfset lowestTerm="">
			<cfset lowestTermValue="">
			<cfset lttList=ttList>
			<!--- check genus and above only, so... ---->
			<cfset termsToIgnore="forma,subspecies,species,subgenus">
			<cfloop list="#termsToIgnore#" index="t">
				<cfif listfind(lttList,t)>
					<cfset lttList=listdeleteat(lttList,listfindnocase(lttList,t))>
					<br>deleted #t#
				</cfif>
			</cfloop>


			<cfloop list="#lttList#" index="term">
				<cfif len(lowestTerm) eq 0>
					<cfset thisTerm=evaluate("d." & term)>
					<cfif len(thisTerm) gt 0>
						<cfset lowestTerm=term>
						<cfset lowestTermValue=thisTerm>
					</cfif>
				</cfif>
			</cfloop>
			<br>lowestTerm=#lowestTerm#
			<br>lowestTermValue=#lowestTermValue#

			<cfif compare(lowestTermValue,scientific_name) neq 0>
				<br>no match is problem
				<cfset thisProb=listappend(thisProb,"scientific name is not #lowestTermValue# (#lowestTerm#)",';')>
			</cfif>











			<p>
				#scientific_name#-->thisProb: #thisProb#
			</p>
			<cfif len(thisProb) is 0>
				<cfset thisProb='all_checks_passed'>
			</cfif>
			<cfquery name="ups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update CF_TEMP_CLASSIFICATION set status='#thisProb#' where scientific_name='#scientific_name#'
			</cfquery>



		</cftransaction>
	</cfloop>
</cfoutput>
</cfif>




<cfif action is "sciname_valid_check">
	<!--- get the stuff we care about ---->
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update CF_TEMP_CLASSIFICATION set status='sciname_valid_check: ' || isValidTaxonName(scientific_name)
		where status='sciname_valid_check'
	</cfquery>
</cfif>
<cfif action is "checkGaps">
	<!--- get the stuff we care about ---->
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			distinct CF_TEMP_CLASSIFICATION.scientific_name
		from
			CF_TEMP_CLASSIFICATION,
			taxon_name,
			taxon_term
		where
			CF_TEMP_CLASSIFICATION.scientific_name=taxon_name.scientific_name and
			taxon_name.taxon_name_id=taxon_term.taxon_name_id and
			taxon_term.source='Arctos' and
			status='go_go_gap_checker' and
			--upper(CF_TEMP_CLASSIFICATION.username)='#ucase(session.username)#' and
			( taxon_term.TERM_TYPE is null or
				 taxon_term.TERM_TYPE not in (select taxon_term from CTTAXON_TERM)
			)
	</cfquery>
	<cfoutput>
		<!--- and for the things we caught above, figure out the problem ---->
		<cfloop query="ins">
			<cfset prob="">
			<cfquery name="hmc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					count(distinct(classification_id)) ccid
				from
					taxon_name,
					taxon_term
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.source='Arctos' and
					taxon_name.scientific_name='#scientific_name#'
			</cfquery>
			<cfif hmc.ccid neq 1>
				<cfset prob="#hmc.ccid# classifications detected">
			<cfelse>
				<cfquery name="funkyTerms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						TERM_TYPE , term
					from
						taxon_name,
						taxon_term
					where
						taxon_name.taxon_name_id=taxon_term.taxon_name_id and
						taxon_term.source='Arctos' and
						taxon_name.scientific_name='#scientific_name#' and
						(
							taxon_term.TERM_TYPE is null or
					 		taxon_term.TERM_TYPE not in (select taxon_term from CTTAXON_TERM)
						)
				</cfquery>
				<cfloop query="funkyTerms">
					<cfset prob=listappend(prob,'#term#=#TERM_TYPE#')>
				</cfloop>
			</cfif>
			<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update CF_TEMP_CLASSIFICATION set status='existing_data_loss_warning: #prob#' where scientific_name='#scientific_name#'
			</cfquery>
		</cfloop>
		<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='existing_data_check_pass' where status='go_go_gap_checker'
		</cfquery>
	</cfoutput>
</cfif>



<cfif action is "sciname_weird_check">
	<cfoutput>
		<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				taxon_term
			from
				CTTAXON_TERM
			where
				IS_CLASSIFICATION=1 and
				-- ignore things which make sloppy namestrings
				taxon_term not in ('scientific_name','forma','subspecies','species','subgenus')
			order by
				RELATIVE_POSITION desc
		</cfquery>
		<!--- first deal with the stuff we ignored ---->
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='sci_name_looks_weird: ssp'
			where status='sciname_weird_check' and subspecies is not null and
			scientific_name != genus || ' ' || species || ' ' || subspecies
		</cfquery>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='sci_name_looks_weird: sp'
			where
				status='sciname_weird_check' and
				subspecies is null and
				species is not null and
			scientific_name != genus || ' ' || species
		</cfquery>
		<cfset ttList=valuelist(CTTAXON_TERM.taxon_term)>
		<cfset ttList=replace(ttList,',order,',',phylorder,')>
		<cfset checkedTerms="">
		<cfloop list="#ttList#" index="term">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update CF_TEMP_CLASSIFICATION set status='sci_name_looks_weird: #term#'
				where
					status='sciname_weird_check' and
					subspecies is null and
					species is null and
					<cfloop list="#checkedTerms#" index="ct">
						#ct# is null
							and
					</cfloop>
				 scientific_name != #term#
			</cfquery>
			<cfset checkedTerms=listappend(checkedTerms,term)>
			<cfset ttList=listDeleteAt(ttList,1)>
		</cfloop>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='sci_name_weirdcheck: pass' where
			status='sciname_weird_check'
		</cfquery>
	</cfoutput>
</cfif>

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
			<cfquery name="hasThis" dbtype="query">
				select count(*) c from d where #thisTerm# is not null
			</cfquery>
			<cfif hasThis.c gt 0>
				<cfset usedTerms=listappend(usedTerms,thisterm)>
			</cfif>
		</cfloop>
		<cfset lNum=1>
		<cfset thisHigher=usedTerms>
		<cfloop list="#usedTerms#" index="thisTerm">
			<!--- remove the current term; everything upstream should match ---->
			<cfset thisHigher=listDeleteAt(thisHigher,1)>
			<cfquery name="uThisTerm" dbtype="query">
				select #thisTerm# termvalue from d group by #thisTerm#
			</cfquery>
			<cfloop query="uThisTerm">
				<cfif len(uThisTerm.termvalue) gt 0 and len(thisHigher) gt 0>
					<cfquery name="thisHigherCombined" dbtype="query">
						select #thisHigher# from d where #thisTerm#='#termvalue#' group by #thisHigher#
					</cfquery>
					<cfif thisHigherCombined.recordcount neq 1>
						<!--- figure out what exactly is inconsistent ---->
						<cfset probTerms="">
						<cfloop list="#thisHigherCombined.columnList#" index="c">
							<cfquery name="dt" dbtype="query">
								select #c# from thisHigherCombined group by #c#
							</cfquery>
							<cfif dt.recordcount neq 1>
								<cfset probTerms="">
								<cfloop query="dt">
									<cfset thisP=evaluate("dt." & c)>
									<cfif len(thisP) is 0>
										<cfset thisP="NULL">
									</cfif>
									<cfset probTerms=listAppend(probTerms,thisP)>
								</cfloop>
								<cfset prob="#lcase(thisTerm)#=#termvalue# --> IN #lcase(c)# (#probTerms#)">
							</cfif>
						</cfloop>
				        <cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update CF_TEMP_CLASSIFICATION set status='inconsistency detected: #prob#'
							where status='go_go_check_consistency' and #thisTerm#='#termvalue#'
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		 <cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='consistency_check_passed'
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