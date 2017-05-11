<!--- local table just for this
create table cf_temp_classification_fh as select * from cf_temp_classification where 1=2;

	 --->
<cfoutput>

	<!--- queue ---->

	<cfquery name="q" datasource="uam_god">
		select * from htax_export where status='ready_to_push_bl'
	</cfquery>

	<cfdump var=#q#>
	<cfif q.recordcount is 0>
		nothing to do<cfabort>
	</cfif>

	<!---- data ---->
	<cfquery name="d" datasource="uam_god">
		select * from hierarchical_taxonomy where status='#q.export_id#' and rownum < 500
	</cfquery>
	got #d.recordcount# records
	<cfif d.recordcount is 0>
		<!--- it's all been processed, flag for next step ---->
		<cfquery name="ud" datasource="uam_god">
			update htax_export set status='export_done' where export_id='#q.export_id#'
		</cfquery>
		update htax_export set status='export_done' where export_id='#q.export_id#'
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


	<!--- AND GET RID OF NONCLASSIFICATION TERMS ---->

	<CFQUERY NAME="nct" dbtype="query">
		select taxon_term from dCTTAXON_TERM where IS_CLASSIFICATION=0
	</CFQUERY>
	<cfloop query="nct">
		<cfif listcontainsnocase(tterms,taxon_term)>
			<cfset tterms=listDeleteAt(tterms,listFindnocase(tterms,taxon_term))>
		</cfif>
	</cfloop>




	<cfloop query="d">
		<!--- reset variables ---->
		<cfloop list="#tterms#" index="i">
			<cfset "variables.#i#"="">
		</cfloop>
	<p>

		#term# - #rank#


<!-----------
		<cftry>
		---------->

		<cfset variables.TID=d.TID>
		<cfset variables.PARENT_TID=d.PARENT_TID>
		<cfset "variables.#RANK#"=d.term>



		<!---- loop a bunch...---->
		<cfloop from="1" to="500" index="l">
			<cfif len(variables.PARENT_TID) gt 0>
				<br>got a parent, get it
				<cfquery name="next" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select * from hierarchical_taxonomy where tid=#variables.PARENT_TID#
				</cfquery>
				<cfset variables.TID=next.TID>
				<cfset variables.PARENT_TID=next.PARENT_TID>
				<cfset "variables.#next.RANK#"=next.term>
				<br>#next.RANK#=#evaluate('variables.' & next.RANK)#
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
			<cfquery name="tnctv" dbtype="query">
				select distinct(TERM_VALUE) from thisNoClass where term_type='#taxon_term#'
			</cfquery>
			<br>tnctv
			<cfdump var=#tnctv#>
			<cfset thisMergedVal=valuelist(tnctv.TERM_VALUE,";")>
			<cfset queryaddrow(dNoClassTerm,
				{TERM_TYPE="#tnctv.taxon_term#",
				TERM_VALUE="#thisMergedVal#"}
			)>
		</cfloop>

		<cfloop query="dNoClassTerm">
			<BR>'#TERM_TYPE#=====#TERM_VALUE#',
		</cfloop>

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
			SCIENTIFIC_NAME
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
			'#d.term#'
		)
		</cfquery>
	<cfquery name="goit" datasource="uam_god">
		update hierarchical_taxonomy set status='pushed_to_bl' where tid=#d.tid#
	</cfquery>
</p>
	</p>

	<br />

	<!------------
		<cfcatch>
			<p>
				failed at #term#=#rank# with #cfcatch.message#: #cfcatch.detail#
			</p>
			<p>
				#cfcatch.sql#
			</p>
		</cfcatch>
		</cftry>


		------------->
		<cfflush>
	</cfloop>
</cfoutput>
