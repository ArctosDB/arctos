<cfinclude template="/includes/_header.cfm">

create table temp_uwbm_oid (cat_num varchar2(4000),oidn varchar2(4000),oidt varchar2(4000));
<cfquery name="d" datasource='uam_god'>
	select cat_num,OTHERCATALOGNUMBERS from temp_uwbm_mamm where OTHERCATALOGNUMBERS is not null
</cfquery>

<cfoutput>
	<cfloop query="d">
		<br>#OTHERCATALOGNUMBERS#
		<cfloop list='#OTHERCATALOGNUMBERS#' index="i" delimiters="|">
			<br>------#i#
<cfquery name="ins" datasource='uam_god'>
	<cfif i contains "NPS Number">
		<cfset t='U. S. National Park Service catalog'>
	<cfelse>
		<cfset t='original identifier'>
	</cfif>
	insert into temp_uwbm_oid (cat_num,oidn,oidt) values ('#cat_num#','#trim(i)#','#t#')
</cfquery>

		</cfloop>
	</cfloop>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">