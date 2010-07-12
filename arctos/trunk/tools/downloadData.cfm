<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">

<a href="downloadData.cfm?action=highergeog">higher geog</a>
<br /><a href="downloadData.cfm?action=afnum">all "AF"</a>
<br /><a href="downloadData.cfm?action=agentnames">agent names</a>
<br /><a href="downloadData.cfm?action=taxonomy">scientific name</a>
<cfquery name="ct" datasource="uam_god">
	select table_name from user_tables where table_name like 'CT%' order by table_name
</cfquery>
<cfoutput>
	<cfloop query="ct">
		<br /><a href="downloadData.cfm?action=#table_name#">#table_name#</a>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------>

<cfif action is "afnum">
	<cfquery name="afnum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select display_value as af from coll_obj_other_id_num where other_id_type='AF'
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/afnum.txt" addnewline="yes" output="afnum">

	<cfoutput query="afnum">
		<cffile action="append" file="#application.webDirectory#/temp/afnum.txt" addnewline="yes" output="#af#">
	</cfoutput>
	<a href="/temp/afnum.txt">download afnum</a>
<cfelseif action is "taxonomy">
	<cfquery name="taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from taxonomy order by scientific_name
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/taxonomy.txt" addnewline="yes" output="scientific_name">

	<cfoutput query="taxonomy">
		<cffile action="append" file="#application.webDirectory#/temp/taxonomy.txt" addnewline="yes" output="#scientific_name#">
	</cfoutput>
	<a href="/temp/taxonomy.txt">download taxonomy</a>
<cfelseif action is  "agentnames">
	<cfquery name="agentnames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name from agent_name
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/agentnames.txt" addnewline="yes" output="agent_name">

	<cfoutput query="agentnames">
		<cffile action="append" file="#application.webDirectory#/temp/agentnames.txt" addnewline="yes" output="#agent_name#">
	</cfoutput>
	<a href="/temp/agentnames.txt">download agents</a>
<cfelse>
	<cfoutput>
	<cfset tablename=action>
	<cfquery name="d" datasource="cf_dbuser">
		select * from #tablename#
	</cfquery>
	<cfset f=d.columnlist>
	<br>f:#f# 
	<cfif listfindnocase(f,"description")>
		<cfset f=listdeleteat(f,listfindnocase(f,"description"))>
	</cfif>
	<cfif listfindnocase(f,"CTSPNID")>
		<cfset f=listdeleteat(f,listfindnocase(f,"CTSPNID"))>
	</cfif>
	<cfif listfindnocase(f,"IS_TISSUE")>
		<cfset f=listdeleteat(f,listfindnocase(f,"IS_TISSUE"))>
	</cfif>
	<cfset r=tablename>
	<cfif listfindnocase(f,"collection_cde")>
		<cfset hasCollCde=true>
		<cfset theColumn=listdeleteat(f,listfindnocase(f,"collection_cde"))>
	<cfelse>
		<cfset hasCollCde=false>
		<cfset theColumn=f>
	</cfif>
	<cfset r=tablename & "," & theColumn & "," & hasCollCde & "::">
	<cfset i=1>
	<cfloop query="d">
		<cfset t=evaluate("d." & theColumn)>
		<cfif hasCollCde>
			<cfset t=t & "|" & d.collection_cde>
		</cfif>
		<cfset r=listappend(r,t,",")>
	</cfloop>
	<cfset r=replace(r,"::,","::")>
	#r#
		<!----

	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select phylclass from taxonomy where upper(phylclass) like '%#ucase(q)#%'
		group by phylclass
		order by phylclass
	</cfquery>
	<cfloop query="pn">
		#phylclass# #chr(10)#
	</cfloop>
	---->
</cfoutput>

</cfif>
<!------------------------------>
<cfif #action# is "highergeog">
	<cfquery name="geog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select higher_geog from geog_auth_rec order by higher_geog
	</cfquery>
	<cffile action="write" file="#application.webDirectory#/temp/geog.txt" addnewline="yes" output="higher_geog">

	<cfoutput query="geog">
		<cffile action="append" file="#application.webDirectory#/temp/geog.txt" addnewline="yes" output="#higher_geog#">
	</cfoutput>
	<cflocation url="/temp/geog.txt">
</cfif>
