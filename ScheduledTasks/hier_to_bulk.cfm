<!--- local table just for this
create table cf_temp_classification_fh as select * from cf_temp_classification where 1=2;

 --->

<!---- data ---->
<cfquery name="d" datasource="uam_god">
	select * from hierarchical_taxonomy where status='ready_to_push_bl' and rownum < 500
</cfquery>
<!---- column names in order ---->
<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'NOMENCLATURAL_CODE'))>





<cfoutput>
	<cfloop query="d">
		<!--- reset variables ---->
		<cfloop list="#tterms#" index="i">
			<cfset "variables.#i#"="">
		</cfloop>
	<p>

		#term# - #rank#

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
		<!----

		UAM@ARCTEST> desc ;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 STATUS 								    VARCHAR2(255)
 CLASSIFICATION_ID							    VARCHAR2(4000)
 USERNAME							   NOT NULL VARCHAR2(255)
 SOURCE 							   NOT NULL VARCHAR2(255)
 TAXON_NAME_ID								    NUMBER
 SCIENTIFIC_NAME						   NOT NULL VARCHAR2(255)
 AUTHOR_TEXT								    VARCHAR2(255)
 INFRASPECIFIC_AUTHOR							    VARCHAR2(255)
 NOMENCLATURAL_CODE						   NOT NULL VARCHAR2(255)
 SOURCE_AUTHORITY							    VARCHAR2(4000)
 VALID_CATALOG_TERM_FG							    VARCHAR2(255)
 TAXON_STATUS								    VARCHAR2(255)
 REMARK 								    VARCHAR2(255)
 DISPLAY_NAME								    VARCHAR2(255)
 SUPERKINGDOM								    VARCHAR2(255)
 KINGDOM								    VARCHAR2(255)
 SUBKINGDOM								    VARCHAR2(255)
 INFRAKINGDOM								    VARCHAR2(255)
 SUPERPHYLUM								    VARCHAR2(255)
 PHYLUM 								    VARCHAR2(255)
 SUBPHYLUM								    VARCHAR2(255)
 SUBDIVISION								    VARCHAR2(255)
 INFRAPHYLUM								    VARCHAR2(255)
 SUPERCLASS								    VARCHAR2(255)
 CLASS									    VARCHAR2(255)
 SUBCLASS								    VARCHAR2(255)
 INFRACLASS								    VARCHAR2(255)
 HYPERORDER								    VARCHAR2(255)
 SUPERORDER								    VARCHAR2(255)
 PHYLORDER								    VARCHAR2(255)
 SUBORDER								    VARCHAR2(255)
 INFRAORDER								    VARCHAR2(255)
 HYPORDER								    VARCHAR2(255)
 SUPERFAMILY								    VARCHAR2(255)
 FAMILY 								    VARCHAR2(255)
 SUBFAMILY								    VARCHAR2(255)
 SUPERTRIBE								    VARCHAR2(255)
 TRIBE									    VARCHAR2(255)
 SUBTRIBE								    VARCHAR2(255)
 GENUS									    VARCHAR2(255)
 SUBGENUS								    VARCHAR2(255)
 SPECIES								    VARCHAR2(255)
 SUBSPECIES								    VARCHAR2(255)
 SUBSP									    VARCHAR2(255)
 FORMA									    VARCHAR2(255)
---->
<p>


	<cfquery name="thisNoClass" datasource="uam_god">
		select * from htax_noclassterm where tid=#d.tid#
	</cfquery>
	<cfdump var=#thisNoClass#>

	<cfquery name="ins" datasource="uam_god">
		insert into cf_temp_classification_fh (
			<cfloop list="#tterms#" index="i">
				#i#,
			</cfloop>
			STATUS,
			username,
			SOURCE,
			SCIENTIFIC_NAME,
			NOMENCLATURAL_CODE
		) values (
			<cfloop list="#tterms#" index="i">
				'#evaluate("variables." & i)#',
			</cfloop>
			'autoinsert_from_hierarchy',
			'need user',
			'need source',
			'#d.term#',
			'need NOMENCLATURAL_CODE'
		)
		</cfquery>
	<cfquery name="goit" datasource="uam_god">
		update hierarchical_taxonomy set status='pushed_to_bl' where tid=#d.tid#
	</cfquery>
</p>
	</p>
	</cfloop>
</cfoutput>
