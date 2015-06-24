<cfif not isdefined("action")><cfset action="nothing"></cfif>

run these in order


<br><a href="processBulkloadClassification.cfm?action=checkMeta">checkMeta</a>
<br><a href="processBulkloadClassification.cfm?action=getTID">getTID</a>
<br><a href="processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus">fill_in_the_blanks_from_genus</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>
<br><a href="processBulkloadClassification.cfm?action=load">load</a>

<!---------------------------------------------------------->

<cfif action is "fill_in_the_blanks_from_genus">
	<!---
		grab genus (lowest term in supplied data)
		find everything "below" that uses the same string
		copy genus record with additional species/subspecies
	---->
	<cfoutput>

		<cfquery name="dbcols" datasource="uam_god">
			select
				column_name
			from
				user_tab_cols
			where
				upper(table_name)='CF_TEMP_CLASSIFICATION' and
				lower(column_name) not in ('status','taxon_name_id','classification_id')
			ORDER BY INTERNAL_COLUMN_ID
		</cfquery>

		<cfset knowncols=valuelist(dbcols.column_name)>

	<br>knowncols: #knowncols#
		<cfquery name="d" datasource="uam_god">
			select * from CF_TEMP_CLASSIFICATION where species is null
			and rownum<2
		</cfquery>
		<cfloop query="d">

			<!--- build a query object from this row of the existing data --->
			<cfset nd=queryNew(knowncols)>

			<cfdump var=#nd#>
			<cfset temp=queryAddRow(nd,1)>

			<cfdump var=#nd#>




			<cfloop list="#knowncols#" index="c">

				<cfset thisval=evaluate(c)>
				<cfset temp=QuerySetCell(nd, c, thisval)>
			</cfloop>

			<cfdump var=#nd#>

			<!----
			<cfquery name="otherstuff" datasource="uam_god">
				select distinct taxon_name_id from taxon_term where term_type='genus' and term='#genus#' and source='Arctos'
			</cfquery>
			<cfloop query="otherstuff">
				<br>taxon_name_id: #taxon_name_id#
				<cfquery name="oneclass" datasource="uam_god">
					select CLASSIFICATION_ID,TERM_TYPE,term from taxon_term where source='Arctos' and taxon_name_id=#taxon_name_id#
				</cfquery>
				<cfloop query="oneclass">
					<cfif term_type is "order">
						<cfset ttt="phylorder">
					<cfelse>
						<cfset ttt=term_type>
					</cfif>
					<cfif len(TERM_TYPE) is 0 or not listfindnocase(knowncols,ttt)>
						<hr>CUIDADO!!!! #TERM_TYPE# (#term#) [#ttt#] is not a known column name
					</cfif>
					<cfset this_TERM_TYPE=ttt>
					<cfset this_term=TERM>
					<br><br>this_TERM_TYPE: #this_TERM_TYPE#
					<br><br>this_term: #this_term#
				</cfloop>

			</cfloop>
			---->
		</cfloop>
	</cfoutput>




</cfif>
<!---------------------------------------------------------->

<cfif action is "checkMeta">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid operation' where status is null and operation not in ('update','replace')
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='display_name is required' where status is null and display_name is null
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid source' where status is null and source not in (
			select source from CTTAXONOMY_SOURCE
		)
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid nomenclatural_code' where status is null and nomenclatural_code not in ('ICZN','ICBN')
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='subspecies is the only acceptable ICZN infraspecific data'
		where status is null and nomenclatural_code = 'ICZN'
		and (forma is not null or subsp is not null)
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='subspecies is ICZN-only'
		where status is null and nomenclatural_code != 'ICZN'
		and subspecies is not null
	</cfquery>

	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='only one infraspecific term may be given'
		where status is null and
		(
			subspecies is not null and (forma is not null or subsp is not null) or
			forma is not null and (subspecies is not null or subsp is not null) or
			subsp is not null and (forma is not null or subspecies is not null)
		)
	</cfquery>

	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='pass_meta' where status is null
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
			status='ready_to_load',
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

	<p>
	update
			CF_TEMP_CLASSIFICATION
		set
			status='ready_to_load',
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
	</p>
	<cfquery name="findfail" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			classification_id='[NEW]',
			status='ready_to_load'
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




	<br>classificationTerms: #classificationTerms#
	<br>noclassterms: #noclassterms#




		<cfloop query="d">
			<cfif d.operation is "replace">
				<br>replacing....
			</cfif>
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
				</cfif>
			</cfloop>
			<cfset thisPosn=1>

			<cfloop list="#classificationTerms#" index="thisTermType">
				<cfset thisTermVal=evaluate("d." & thisTermType)>
				<br>thisTermType: #thisTermType#
				<br>thisTermVal: #thisTermVal#
				<cfif len(thisTermVal) gt 0>
					<cfif thisTermType is "subsp">
					<cfset thisTermType= thisTermType & '.'>
					<br>issubsp
				<cfelse>
				<br>nope
				</cfif>


					<br>
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
					<cfset thisPosn=thisPosn+1>

				</cfif>
			</cfloop>






			<!----
			<cfquery name="remold" datasource="uam_god">
				delete from taxon_term where taxon_name_id=#taxon_name_id# and classification_id='#classification_id#'
			</cfquery>

			--->


		</cfloop>
	</cfoutput>


</cfif>

