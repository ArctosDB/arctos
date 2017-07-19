<!---
	run at test
	talks to prod
	find all "words" used in parts, then count how many parts use them

	create table temp_part_wrds_raw (wrd varchar2(255));
---->

<cfoutput>
	<cfquery name="d" datasource="prod">
		select distinct part_name from ctspecimen_part_name
	</cfquery>
	<cfloop query="d">
		<p>
			#part_name#
			<cfloop list="#part_name#" index="p" delimiters=" ">
				<cfset p=replace(p,'(','','all')>
				<cfset p=replace(p,')','','all')>
				<cfset p=replace(p,',','','all')>
				<br>#p#
			</cfloop>
		</p>
	</cfloop>

</cfoutput>