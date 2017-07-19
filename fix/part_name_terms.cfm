<cfinclude template="/includes/_header.cfm">
<!---
	run at test
	talks to prod
	find all "words" used in parts, then count how many parts use them

	create table temp_part_wrds_raw (wrd varchar2(255));
	select distinct wrd from temp_part_wrds_raw order by wrd;

	create table temp_part_wrds as select distinct wrd from temp_part_wrds_raw;
	alter table temp_part_wrds add used_in_parts number;
---->

<cfoutput>

	<br><a href"part_name_term.cfm?action=getRaw">getRaw</a>
	<br><a href"part_name_term.cfm?action=getCount">getCount</a>
	<cfif action is "getCount">
		<cfquery name="d" datasource="prod">
			select * from temp_part_wrds
		</cfquery>
		<cfloop query="d">
			<cfquery name="dp" datasource="prod">
				select count(distinct(part_name) c from ctspecimen_part_name where part_name like '%#wrd#%'
			</cfquery>
			<cfquery name="udc" datasource="prod">
				update temp_part_wrds set used_in_parts=#dp.c# where wrd='#wrd#'
			</cfquery>

		</cfloop>



	</cfif>

	<cfif action is "getRaw">
	<cfquery name="d" datasource="prod">
		select distinct part_name from ctspecimen_part_name
	</cfquery>
	<cftransaction>
	<cfloop query="d">
		<p>
			#part_name#
			<cfloop list="#part_name#" index="p" delimiters=" ">
				<cfset p=replace(p,'(','','all')>
				<cfset p=replace(p,')','','all')>
				<cfset p=replace(p,',','','all')>
				<br>#p#
				<cfquery name="i1" datasource="prod">
					insert into temp_part_wrds_raw(wrd) values ('#p#')
				</cfquery>
			</cfloop>
		</p>
	</cfloop>
	</cftransaction>

	</cfif>
</cfoutput>