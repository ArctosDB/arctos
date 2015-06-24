<cfif not isdefined("action")><cfset action="nothing"></cfif>

run these in order


<br><a href="processBulkloadClassification.cfm?action=checkMeta">checkMeta</a>
<br><a href="processBulkloadClassification.cfm?action=getTID">getTID</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>
<br><a href="processBulkloadClassification.cfm?action=load">load</a>


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
		select * from CF_TEMP_CLASSIFICATION where rownum<10
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

