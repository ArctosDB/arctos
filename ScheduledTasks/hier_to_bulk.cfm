<!--- local table just for this
create table cf_temp_classification_fh as select * from cf_temp_classification where 1=2;
	 alter table cf_temp_classification_fh add export_id varchar2(255);

	 --->

<cfoutput>
	<!--- send email for any previous exports ---->
	<cfquery name="rtn" datasource="uam_god">
		select
			DATASET_ID,
			SEED_TERM,
			USERNAME,
			EXPORT_ID,
			get_address(agent_id,'email') email
		 from
		 	htax_export,
		 	agent_name
		 where
			upper(htax_export.username)=upper(agent_name.agent_name) and
			agent_name_type='login' and
			status='export_done'
	</cfquery>

	<cfloop query="rtn">
		<cfif len(email) gt 0>
			<cfmail to="#email#" subject="taxonomy export" cc="arctos.database@gmail.com" from="class_export@#Application.fromEmail#" type="html">
				Dear #username#,
				<p>
					Your export of #SEED_TERM# and children is available at
					#application.serverRootURL#//tools/taxonomyTree.cfm?action=manageExports&EXPORT_ID=#EXPORT_ID#
				</p>
			</cfmail>
			<cfquery name="sem" datasource="uam_god">
				update htax_export set status='email_sent' where EXPORT_ID='#EXPORT_ID#'
			</cfquery>
		<cfelse>
			<cfquery name="sem" datasource="uam_god">
				update htax_export set status='email_not_sent_noaddress' where EXPORT_ID='#EXPORT_ID#'
			</cfquery>
		</cfif>
	</cfloop>

	<!--- queue ---->

	<cfquery name="q" datasource="uam_god">
		select * from htax_export where status='ready_to_push_bl'
	</cfquery>

	<cfif q.recordcount is 0>
		nothing to do<cfabort>
	</cfif>

	<!---- data ---->
	<cfquery name="d" datasource="uam_god">
		select * from hierarchical_taxonomy where status='#q.export_id#' and rownum < 500
	</cfquery>
	<cfif d.recordcount is 0>
		<!--- it's all been processed, flag for next step ---->
		<cfquery name="ud" datasource="uam_god">
			update htax_export set status='export_done' where export_id='#q.export_id#'
		</cfquery>
		<cfabort>
	</cfif>

	<cfquery name="dataset" datasource="uam_god">
		select source from htax_dataset where dataset_id=#q.dataset_id#
	</cfquery>

	<!---- column names in order ---->
	<cfquery name="dCTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from
			CTTAXON_TERM
	</cfquery>
	<cfquery name="CTTAXON_TERM" datasource="uam_god">
		select column_name taxon_term from user_tab_cols where table_name=upper('cf_temp_classification_fh')
	</cfquery>

	<cfset tterms=valuelist(CTTAXON_TERM.taxon_term)>
	<!----
	get rid of admin stuff
	<cfset tterms=listappend(tterms,'phylorder')>
	---->

	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'STATUS'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'CLASSIFICATION_ID'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'USERNAME'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'SOURCE'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'TAXON_NAME_ID'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'SCIENTIFIC_NAME'))>
	<cfset tterms=listDeleteAt(tterms,listFind(tterms,'EXPORT_ID'))>


	<!--- AND GET RID OF NONCLASSIFICATION TERMS ---->

	<CFQUERY NAME="nct" dbtype="query">
		select taxon_term from dCTTAXON_TERM where IS_CLASSIFICATION=0
	</CFQUERY>
	<cfloop query="nct">
		<cfif listcontainsnocase(tterms,taxon_term)>
			<cfset tterms=listDeleteAt(tterms,listFindnocase(tterms,taxon_term))>
		</cfif>
	</cfloop>

	<!--- order, ugh... 	---->
<cfset tterms=replace(tterms,"PHYLORDER","ORDER")>

<cfdump var=#tterms#>

	<cfloop query="d">

	<cftransaction>
		<!--- reset variables ---->
		<cfloop list="#tterms#" index="i">
			<cfset "variables.#i#"="">
		</cfloop>
<cftry>
		<cfset variables.TID=d.TID>
		<cfset variables.PARENT_TID=d.PARENT_TID>
		<cfset "variables.#RANK#"=d.term>



		<!---- loop a bunch...---->
		<cfloop from="1" to="500" index="l">
			<cfif len(variables.PARENT_TID) gt 0>
				<cfquery name="next" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select * from hierarchical_taxonomy where tid=#variables.PARENT_TID#
				</cfquery>
				<cfset variables.TID=next.TID>
				<cfset variables.PARENT_TID=next.PARENT_TID>
				<cfset "variables.#next.RANK#"=next.term>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfquery name="thisNoClass" datasource="uam_god">
			select TERM_TYPE,TERM_VALUE from htax_noclassterm where tid=#d.tid#
		</cfquery>

		<cfset dNoClassTerm=queryNew("TERM_TYPE,TERM_VALUE")>
		<!---- need to merge ---->
		<cfloop query="nct">
			<cfif taxon_term is not "scientific_name" and taxon_term is not "display_name">
				<cfquery name="tnctv" dbtype="query">
					select distinct(TERM_VALUE) from thisNoClass where term_type='#taxon_term#'
				</cfquery>
				<cfset thisMergedVal=valuelist(tnctv.TERM_VALUE,";")>
				<cfset queryaddrow(dNoClassTerm,
					{TERM_TYPE="#nct.taxon_term#",
					TERM_VALUE="#thisMergedVal#"}
				)>
			</cfif>
		</cfloop>

	<cfdump var=#dNoClassTerm#>

	<cfquery name="ins" datasource="uam_god">
		insert into cf_temp_classification_fh (
			<cfloop list="#tterms#" index="i">
				#i#,
			</cfloop>
			<cfloop query="dNoClassTerm">
				#TERM_TYPE#,
			</cfloop>
			STATUS,
			username,
			SOURCE,
			SCIENTIFIC_NAME,
			export_id
		) values (
			<cfloop list="#tterms#" index="i">
				'#evaluate("variables." & i)#',
			</cfloop>
			<cfloop query="dNoClassTerm">
				'#TERM_VALUE#',
			</cfloop>
			'autoinsert_from_hierarchy',
			'#q.username#',
			'#dataset.source#',
			'#d.term#',
			'#q.export_id#'
		)
		</cfquery>

		<P>

		insert into cf_temp_classification_fh (
			<cfloop list="#tterms#" index="i">
				#i#,
			</cfloop>
			<cfloop query="dNoClassTerm">
				#TERM_TYPE#,
			</cfloop>
			STATUS,
			username,
			SOURCE,
			SCIENTIFIC_NAME,
			export_id
		) values (
			<cfloop list="#tterms#" index="i">
				'#evaluate("variables." & i)#',
			</cfloop>
			<cfloop query="dNoClassTerm">
				'#TERM_VALUE#',
			</cfloop>
			'autoinsert_from_hierarchy',
			'#q.username#',
			'#dataset.source#',
			'#d.term#',
			'#q.export_id#'
		)
		</P>

		<cfabort>
	<cfquery name="goit" datasource="uam_god">
		update hierarchical_taxonomy set status='pushed_to_bl' where tid=#d.tid#
	</cfquery>


		<cfcatch>

				<cfquery name="blargh" datasource="uam_god">
					insert into htax_export_errors (
						export_id,
						term,
						term_type,
						message,
						detail,
						sql
					) values (
						'#q.export_id#',
						'#term#',
						'#rank#',
						'#cfcatch.message#',
						'#cfcatch.detail#',
						<cfif isdefined("cfcatch.sql")>
							'#cfcatch.sql#'
						<cfelse>
							'NOT AVAILABLE'
						</cfif>
					)
				</cfquery>
				<cfquery name="goit" datasource="uam_god">
					update hierarchical_taxonomy set status='pushed_to_bl_FAIL' where tid=#d.tid#
				</cfquery>




		</cfcatch>
		</cftry>



		</cftransaction>
	</cfloop>
</cfoutput>
