<!--- local table just for this
drop table cf_temp_classification_fh;

create table cf_temp_classification_fh as select * from cf_temp_classification where 1=2;

 --->

<!---- verification: don't run if we can't ---->


<cfquery name="src" datasource="uam_god">
	select distinct(source) from htax_dataset,hierarchical_taxonomy where htax_dataset.dataset_id=hierarchical_taxonomy.dataset_id and
	hierarchical_taxonomy.status='ready_to_push_bl'
</cfquery>
<cfif src.recordcount is not 1 or not len(src.source) gt 0>
	bad src

	<cfdump var=#src#>
	<cfabort>
</cfif>


<cfdump var=#src#>
<!---- column names in order ---->
<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		IS_CLASSIFICATION,
		RELATIVE_POSITION,
		case when TAXON_TERM='order' then
			'phylorder'
		else
			TAXON_TERM
		end AS TAXON_TERM
	from
		CTTAXON_TERM
	where TAXON_TERM != 'scientific_name'
</cfquery>
<cfdump var=#CTTAXON_TERM#>



<cfquery name="tbldef" datasource="uam_god">
	select * from cf_temp_classification_fh where 1=2
</cfquery>

<cfset ctterms=valuelist(CTTAXON_TERM.TAXON_TERM)>
<cfset knterms=tbldef.columnlist>

<cfoutput>
<!--- any terms which need added to the table? ---->
<cfloop list="#ctterms#" index="t">
	<cfif not listfindnocase(knterms,t)>
		<br>#t# is not in the table plz add
	</cfif>


</cfloop>
</cfoutput>




<cfquery name="classTERM" dbtype="query">
	select
		TAXON_TERM
	from
		CTTAXON_TERM
	where IS_CLASSIFICATION=1
	order by RELATIVE_POSITION
</cfquery>
<cfquery name="noClassTERM" dbtype="query">
	select
		*
	from
		CTTAXON_TERM
	where IS_CLASSIFICATION=0
	order by RELATIVE_POSITION
</cfquery>
<!--- make sure we're not going to try to deal with any term type that we can't ---->

<cfquery name="ctt" datasource="uam_god">
	select distinct RANK from hierarchical_taxonomy where status='ready_to_push_bl' and RANK not in
		(#ListQualify(valuelist(classTERM.TAXON_TERM),"'")#)
</cfquery>

<cfdump var=#ctt#>


<cfquery name="cntt" datasource="uam_god">
	select distinct htax_noclassterm.term_type from
		htax_noclassterm,hierarchical_taxonomy
		where hierarchical_taxonomy.status='ready_to_push_bl' and
		htax_noclassterm.tid=hierarchical_taxonomy.tid and
		htax_noclassterm.term_type not in
		(#ListQualify(valuelist(noClassTERM.TAXON_TERM),"'")#)
</cfquery>


<cfquery name="missingNomCode" datasource="uam_god">
	select distinct
		term,
		tid
	from
		hierarchical_taxonomy
	where
		 status='ready_to_push_bl' and
		 tid not in (select tid from htax_noclassterm where term_type='nomenclatural_code')
</cfquery>
<cfif missingNomCode.recordcount gt 0>
	missing nomenclatural code; cannot proceed.

	<p>
		To fix, edit and try this:
	</p>
	<pre>
		 insert into htax_noclassterm (
			TID,
			TERM_TYPE,
			TERM_VALUE
		) (
			select distinct
				tid,
				'nomenclatural_code',
				'XXXXXXX'
			from
				hierarchical_taxonomy
			where
				 status='ready_to_push_bl' and
				tid not in (
					select tid from htax_noclassterm where term_type='nomenclatural_code'
				)
		);

	</pre>
	<cfabort>
</cfif>

select count(*) from hierarchical_taxonomy where status='ready_to_push_bl';



	select * from htax_noclassterm where tid=114132847;

		tid not in (select tid from

	htax_noclassterm.term_type from
		htax_noclassterm,hierarchical_taxonomy
		where hierarchical_taxonomy.status='ready_to_push_bl' and
		htax_noclassterm.tid=hierarchical_taxonomy.tid and
		htax_noclassterm.term_type not in
		(#



<cfdump var=#cntt#>



<!---- data ---->
<cfquery name="d" datasource="uam_god">
	select * from hierarchical_taxonomy where status='ready_to_push_bl' and rownum < 500
</cfquery>




<!----
<cfquery name="CTTAXON_TERM" datasource="uam_god">
	select column_name taxon_term from user_tab_cols where table_name=upper('cf_temp_classification_fh')
</cfquery>
---->
<cfset tterms=valuelist(classTERM.taxon_term)>
<!----
get rid of admin stuff
<cfset tterms=listappend(tterms,'phylorder')>






<cfset tterms=listDeleteAt(tterms,listFind(tterms,'STATUS'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'CLASSIFICATION_ID'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'USERNAME'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'SOURCE'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'TAXON_NAME_ID'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'SCIENTIFIC_NAME'))>
<cfset tterms=listDeleteAt(tterms,listFind(tterms,'NOMENCLATURAL_CODE'))>



---->






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
	<!--- if there are duplicate values, smoosh them ---->

	<cfquery name="tncc" dbtype="query">
		select distinct TERM_TYPE from thisNoClass
	</cfquery>


	<cfset nodupQ=queryNew("TERM_TYPE,TERM_VALUE")>

	<cfloop query="tncc">
		<cfquery name="thisValuQ" dbtype="query">
			select TERM_VALUE from thisNoClass where TERM_TYPE='#TERM_TYPE#'
		</cfquery>
		<cfset thisv="">
		<cfloop query="thisValuQ">
			<cfset thisv=listapped(thisv,term_value,'; ')>
		</cfloop>
		<cfset queryaddrow(nodupQ,
					{TERM_TYPE=term_type,
					TERM_VALUE=thisv
					}
				)>

	</cfloop>

	<cfdump var=#nodupQ#>

	<cfquery name="ins" datasource="uam_god">
		insert into cf_temp_classification_fh (
			<cfloop list="#tterms#" index="i">
				#i#,
			</cfloop>
			<cfloop query="nodupQ">
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
			<cfloop query="nodupQ">
				'#TERM_VALUE#',
			</cfloop>
			'autoinsert_from_hierarchy',
			'need user',
			'#src.source#',
			'#d.term#'
		)
		</cfquery>
	<cfquery name="goit" datasource="uam_god">
		update hierarchical_taxonomy set status='pushed_to_bl' where tid=#d.tid#
	</cfquery>
</p>
	</p>
	</cfloop>
</cfoutput>
