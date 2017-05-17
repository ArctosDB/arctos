<cfinclude template="/includes/_header.cfm">


<cfquery name="d" datasource='uam_god'>
	select cat_num,OTHERCATALOGNUMBERS from temp_uwbm_mamm where OTHERCATALOGNUMBERS is not null
</cfquery>

<cfoutput>
	<cfloop query="d">
		<br>#OTHERCATALOGNUMBERS#
		<cfloop list='#OTHERCATALOGNUMBERS#' index="i" delimiters="|">
			<br>------#i#
		</cfloop>
	</cfloop>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">