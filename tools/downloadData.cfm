<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">

<a href="downloadData.cfm?action=highergeog">higher geog</a>
<br /><a href="downloadData.cfm?action=afnum">all "AF"</a>
<br /><a href="downloadData.cfm?action=agentnames">agent names</a>
<br /><a href="downloadData.cfm?action=taxonomy">scientific name</a>


<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------>

<cfif #action# is "afnum">
	<cfquery name="afnum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select other_id_num as af from coll_obj_other_id_num where other_id_type='AF'
	</cfquery>
	<cffile action="write" file="/var/www/html/temp/afnum.txt" addnewline="yes" output="afnum">

	<cfoutput query="afnum">
		<cffile action="append" file="/var/www/html/temp/afnum.txt" addnewline="yes" output="#af#">
	</cfoutput>
	<a href="/temp/afnum.txt">download afnum</a>
</cfif>
<cfif #action# is "taxonomy">
	<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from taxonomy
	</cfquery>
	<cffile action="write" file="/var/www/html/temp/taxonomy.txt" addnewline="yes" output="scientific_name">

	<cfoutput query="taxonomy">
		<cffile action="append" file="/var/www/html/temp/taxonomy.txt" addnewline="yes" output="#scientific_name#">
	</cfoutput>
	<a href="/temp/taxonomy.txt">download taxonomy</a>
</cfif>
<!------------------------------>

<cfif #action# is "agentnames">
	<cfquery name="agentnames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name from agent_name
	</cfquery>
	<cffile action="write" file="/var/www/html/temp/agentnames.txt" addnewline="yes" output="agent_name">

	<cfoutput query="agentnames">
		<cffile action="append" file="/var/www/html/temp/agentnames.txt" addnewline="yes" output="#agent_name#">
	</cfoutput>
	<a href="/temp/agentnames.txt">download agents</a>
</cfif>
<!------------------------------>
<cfif #action# is "highergeog">
	<cfquery name="geog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select higher_geog from geog_auth_rec
	</cfquery>
	<cffile action="write" file="/var/www/html/temp/geog.txt" addnewline="yes" output="higher_geog">

	<cfoutput query="geog">
		<cffile action="append" file="/var/www/html/temp/geog.txt" addnewline="yes" output="#higher_geog#">
	</cfoutput>
	<cflocation url="/temp/geog.txt">
</cfif>
