<!----
create table ttaxonomy (
id int,
AUTHOR_TEXT varchar(255),
family  varchar(255),
genus  varchar(255),
INFRASPECIFIC_AUTHOR varchar(255),
INFRASPECIFIC_RANK varchar(255),
KINGDOM varchar(255),
NOMENCLATURAL_CODE varchar(255),
PHYLCLASS varchar(255),
PHYLORDER varchar(255),
PHYLUM varchar(255),
SCIENTIFIC_NAME varchar(255),
SPECIES varchar(255),
SUBCLASS varchar(255),
SUBFAMILY varchar(255),
SUBGENUS varchar(255),
SUBORDER varchar(255),
SUBSPECIES varchar(255),
SUPERFAMILY varchar(255),
TRIBE varchar(255)
);


create table one_col (
	id number,
	parent_id number,
	rank varchar2(255),
	name_element varchar2(255),
	author_string varchar2(255)
);

---->
<cfif not isdefined("action") ><cfset action="nothing"></cfif>
<cfif action is "lamtest">
<cfquery name="lamtest" datasource="uam_god">
	select * from common_name_element where id=264183
</cfquery>
<cfdump var=#lamtest#>
</cfif>
<cfif action is "nothing">


<cfoutput>
	select 
		scientific_name_element.name_element,
		taxonomic_rank.rank,
		taxon_name_element.parent_id
	from 
		taxon,
		taxonomic_rank,
		scientific_name_element,
		taxon_name_element		
	where
		taxon.taxonomic_rank_id=taxonomic_rank.id and
		taxon.id=scientific_name_element.id and
		taxon.id=taxon_name_element.taxon_id and
		rank='subspecies'
		limit 100
<cfquery name="d" datasource="uam_god">
	select 
		taxon_name_element.taxon_id,
		taxon_name_element.parent_id,
		scientific_name_element.name_element ,
		taxonomic_rank.rank
	from 
		taxon_name_element,
		scientific_name_element,
		taxon,
		taxonomic_rank
	where 
		taxon_name_element.scientific_name_element_id=scientific_name_element.id and 
		taxon_name_element.taxon_id=taxon.id and
		taxon.taxonomic_rank_id=taxonomic_rank.id and
		rank='subspecies' and
		taxon_name_element.taxon_id not in (select id from ttaxonomy)
		and rownum < 100
</cfquery>
<cfdump var=#d#>
<cfloop query="d">
	<cfset t_id=taxon_id>
	<cfset t_AUTHOR_TEXT=''>
	<cfset t_family=''>
	<cfset t_genus=''>
	<cfset t_INFRASPECIFIC_AUTHOR=''>
	<cfset t_INFRASPECIFIC_RANK=''>
	<cfset t_KINGDOM=''>
	<cfset t_NOMENCLATURAL_CODE=''>
	<cfset t_PHYLCLASS=''>
	<cfset t_PHYLORDER=''>
	<cfset t_PHYLUM=''>
	<cfset t_SCIENTIFIC_NAME=''>
	<cfset t_SPECIES=''>
	<cfset t_SUBCLASS=''>
	<cfset t_SUBFAMILY=''>
	<cfset t_SUBGENUS=''>
	<cfset t_SUBORDER=''>
	<cfset t_SUBSPECIES=''>
	<cfset t_SUPERFAMILY=''>
	<cfset t_TRIBE=''>
	<cfset t_class=''>
	<cfset t_order=''>
	<!-----------------
	
		change the following to match whatever rank is in query D
		
	------------------>
	
	<cfset t_subspecies=name_element>
	
	
	
	
	<br>#name_element#-#rank#-#parent_id#
	<cfif len(parent_id) gt 0>
		<cfset pid=parent_id>
		<cfset i=1>
		<cfset go=1>
		<cfloop condition="go is 1">
			<cfquery name="p#i#" datasource="uam_god">
				select 
					taxon_name_element.taxon_id,
					taxon_name_element.parent_id,
					scientific_name_element.name_element ,
					taxonomic_rank.rank
				from 
					taxon_name_element,
					scientific_name_element,
					taxon,
					taxonomic_rank
				where 
					taxon_name_element.scientific_name_element_id=scientific_name_element.id and 
					taxon_name_element.taxon_id=taxon.id and
					taxon.taxonomic_rank_id=taxonomic_rank.id and
					taxon_name_element.taxon_id=#pid#
			</cfquery>
			<hr>
			<br>
			select 
					taxon_name_element.taxon_id,
					taxon_name_element.parent_id,
					scientific_name_element.name_element ,
					taxonomic_rank.rank
				from 
					taxon_name_element,
					scientific_name_element,
					taxon,
					taxonomic_rank
				where 
					taxon_name_element.scientific_name_element_id=scientific_name_element.id and 
					taxon_name_element.taxon_id=taxon.id and
					taxon.taxonomic_rank_id=taxonomic_rank.id and
					taxon_name_element.taxon_id=#pid#
			
			<cfset pid=evaluate("p" & i & ".parent_id")>
			<cfset ne=evaluate("p" & i & ".name_element")>
			<cfset r=evaluate("p" & i & ".rank")>
			<cfset "t_#r#"=ne>
			
			
			<br>i: #i#
			<br>pid: #pid#
			<br>ne: #ne#
			<br>r: #r#
			<cfif len(pid) is 0>
				<cfset go=2>
				<br>---------LASTLOOP---------
			</cfif>
			<cfset i=i+1>
		</cfloop>
	</cfif><!--- end parent_id check--->
	<cfset t_phylclass=t_class>
	<cfset t_phylorder=t_order>
	insert into ttaxonomy (
		id,
		KINGDOM,
		PHYLUM,
		PHYLCLASS,
		SUBCLASS,
		PHYLORDER,
		SUBORDER,
		SUPERFAMILY,
		family,
		SUBFAMILY,
		TRIBE,
		genus,
		SUBGENUS,
		SPECIES,
		SUBSPECIES,		
		AUTHOR_TEXT,
		INFRASPECIFIC_AUTHOR,
		INFRASPECIFIC_RANK
	) values (
		#t_id#,
		'#t_KINGDOM#',
		'#t_PHYLUM#',
		'#t_PHYLCLASS#',
		'#t_SUBCLASS#',
		'#t_PHYLORDER#',
		'#t_SUBORDER#',
		'#t_SUPERFAMILY#',
		'#t_family#',
		'#t_SUBFAMILY#',
		'#t_TRIBE#',
		'#t_genus#',
		'#t_SUBGENUS#',
		'#t_SPECIES#',
		'#t_SUBSPECIES#',		
		'#t_AUTHOR_TEXT#',
		'#t_INFRASPECIFIC_AUTHOR#',
		'#t_INFRASPECIFIC_RANK#'
	)
</cfloop>



</cfoutput>

</cfif>