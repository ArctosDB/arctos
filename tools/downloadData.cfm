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
<cfelseif action is  "codeTableZip">
	<cfoutput>
		<cfquery name="ct" datasource="uam_god">
			select table_name from user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<cfif not directoryexists("#Application.webDirectory#/temp/ctzip")>
			<cfdirectory action="create" directory="#Application.webDirectory#/temp/ctzip">
		</cfif>
		
	
	
		<cfloop query="ct">
			<cfquery name="d" datasource="cf_dbuser">
				select * from #table_name# where table_name not in ('CTATTRIBUTE_CODE_TABLES')
			</cfquery>
			<cfset f=d.columnlist>
			<cfset stuffToDie="description,CTSPNID,IS_TISSUE,base_url">
			<cfloop list="#stuffToDie#" index="i">
				<cfif listfindnocase(f,i)>
					<cfset f=listdeleteat(f,listfindnocase(f,i))>
				</cfif>
			</cfloop>
			<cfset r=table_name>
			<cfif listfindnocase(f,"collection_cde")>
				<cfset hasCollCde=true>
				<cfset theColumn=listdeleteat(f,listfindnocase(f,"collection_cde"))>
			<cfelse>
				<cfset hasCollCde=false>
				<cfset theColumn=f>
			</cfif>
			<cfset variables.fileName="#Application.webDirectory#/temp/ctzip/#lcase(table_name)#.csv">
			<cfset variables.encoding="US-ASCII">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			</cfscript>		
			<cfloop query="d">
				<cfset t= evaluate("d." & theColumn)>
				<cfif hasCollCde>
					<cfset t=t & ',' & d.collection_cde>
				</cfif>
				<cfscript>
					variables.joFileWriter.writeLine(t);
				</cfscript>
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
		</cfloop>
		<cfzip file="#Application.webDirectory#/download/ctzip.zip" source="#Application.webDirectory#/temp/ctzip">
		<cflocation url="/download.cfm?file=ctzip.zip">		
	</cfoutput>
<cfelse>
	<cfoutput>
	<cfset tablename=action>
	<cfquery name="d" datasource="cf_dbuser">
		select * from #tablename#
	</cfquery>
	<cfset f=d.columnlist>
	<cfset stuffToDie="description,CTSPNID,IS_TISSUE,base_url">
	<cfloop list="#stuffToDie#" index="i">
		<cfif listfindnocase(f,i)>
			<cfset f=listdeleteat(f,listfindnocase(f,i))>
		</cfif>
	</cfloop>
	<cfset r=tablename>
	<cfif listfindnocase(f,"collection_cde")>
		<cfset hasCollCde=true>
		<cfset theColumn=listdeleteat(f,listfindnocase(f,"collection_cde"))>
	<cfelse>
		<cfset hasCollCde=false>
		<cfset theColumn=f>
	</cfif>
	
	<cfset variables.fileName="#Application.webDirectory#/download/#lcase(tablename)#.csv">
	<cfset variables.encoding="US-ASCII">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>		
	<cfloop query="d">
		<cfset t= evaluate("d." & theColumn)>
		<cfif hasCollCde>
			<cfset t=t & ',' & d.collection_cde>
		</cfif>
		<cfscript>
			variables.joFileWriter.writeLine(t);
		</cfscript>
	</cfloop>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=#lcase(tablename)#.csv">
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
