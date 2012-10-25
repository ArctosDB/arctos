<cfoutput>
	
	
	<!---
	create table uw_af (
		preferred_name varchar2(4000),
		n1  varchar2(4000),
		n2  varchar2(4000),
		n3  varchar2(4000),
		n4  varchar2(4000),
		n5  varchar2(4000),
		n6  varchar2(4000),
		n7  varchar2(4000),
		n8  varchar2(4000),
		n1  varchar2(4000),
	
	
	---->
	<cfquery name="d" datasource="uam_god">
		select preferred_name from uw_agentlast group by preferred_name
	</cfquery>
	
	<cfset nname=1>
	<cfloop query="d">
		<cfquery name="one" datasource="uam_god">
			select * from uw_agentlast where preferred_name='#preferred_name#'
		</cfquery>
		<hr>preferred_name=#preferred_name#
		<cfset namelist=preferred_name>
		<cfset i=1>
		<cfloop query="one">
			<cfif not listcontains(namelist,PREFERRED_NAME,'|')>
				<cfset namelist=listappend(namelist,PREFERRED_NAME,'|')>
			</cfif>
			<br>thisPREFERRED_NAME=#PREFERRED_NAME#
			
			<br>FIRST_NAME=#FIRST_NAME#
			<br>MIDDLE_NAME=#MIDDLE_NAME#
			<br>LAST_NAME=#LAST_NAME#
			<cfif not listcontains(namelist,ORIG,'|')>
				<cfset namelist=listappend(namelist,ORIG,'|')>
			</cfif>
			<br>ORIG=#ORIG#
			
				<cfif len(first_name) gt 2 and first_name contains ",">
					<cfset pname='hascommamorethan2==' & LAST_NAME & ' ' & MIDDLE_NAME & ' ' &  FIRST_NAME>
				<cfelse>
					<cfset pname=FIRST_NAME  & ' ' & MIDDLE_NAME & ' ' & LAST_NAME >
				</cfif>
				<cfset pname=replace(pname,',','','all')>
				<cfset pname=replace(pname,'  ',' ','all')>
				<br>pname=#pname#
				<cfif not listcontains(namelist,pname,'|')>
					<cfset namelist=listappend(namelist,pname,'|')>
				</cfif>
				<cfset i=i+1>
				<cfif i gt nname><cfset nname=i></cfif>
				<br>namelist=#namelist#
			</cfloop>
		
					


	</cfloop>
	<br>
nname: #nname#
</cfoutput>

			
	<!----------------


	<cfhttp method="head" url="http://web.corral.tacc.utexas.edu/UAF/2008_10_15/jpegs/tn_H1175660.jpg">
			<cfdump var=#cfhttp#>
			
			
			
		
	
	<cfloop query="d">
		<cfset l=listgetat(PREFERRED_NAME,1)>
		<cfquery name="f" datasource="uam_god">
			select PREFERRED_NAME from uw_split where trim(first_NAME)='#trim(l)#' group by PREFERRED_NAME
		</cfquery>
		<cfif f.recordcount is 1>
			<cfdump var=#f#>
			
			<cfquery name="u" datasource="uam_god">
				update uw_ac set orig='#f.PREFERRED_NAME#' where PREFERRED_NAME='#PREFERRED_NAME#'
			</cfquery>
			
			<!----
			
			---->
		<cfelse>
			<br>#PREFERRED_NAME#
		</cfif>
	</cfloop>	
			
	<cfquery datasource="uam_god" name="cols">
		select * from taxonomy where 1=2		
	</cfquery>
	<cfset c=cols.columnlist>
	
	<cfset c=listdeleteat(c,listfindnocase(c,"taxon_name_id"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"VALID_CATALOG_TERM_FG"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"display_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"scientific_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"author_text"))>

	<cfset c=listdeleteat(c,listfindnocase(c,"FULL_TAXON_NAME"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_RANK"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_AUTHOR"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"NOMENCLATURAL_CODE"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"SOURCE_AUTHORITY"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_REMARKS"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_STATUS"))>

	<cfloop list="#c#" index="fl">
	
		<cfloop list="#c#" index="sl">
			<cfif sl is not fl>
				
				<cfquery datasource="uam_god" name="ttt">
					select #fl#,count(*) c from taxonomy where #fl#=#sl# group by #fl#
				</cfquery>
				<cfif ttt.c gt 0>
					
					<cfdump var=#ttt#>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>	
	
		---------->