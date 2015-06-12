
<!----
drop table ds_temp_split_agent;

create table ds_temp_split_agent (
	original varchar2(4000),
	agent1 varchar2(255),
	agent2 varchar2(255),
	agent3 varchar2(255),
	agent4 varchar2(255),
	agent5 varchar2(255),
	agent6 varchar2(255),
	agent7 varchar2(255),
	agent8 varchar2(255),
	agent9 varchar2(255),
	agent10 varchar2(255)
	);

create or replace public synonym ds_temp_split_agent for ds_temp_split_agent;
grant all on ds_temp_split_agent to manage_agents;
----->


<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<cfset title="split agents">

<cfif action is "nothing">
<p>
	Load CSV, one column "original"
</p>
<p>
	Splits concatenated agent strings of format...
	<ul>
		<li>J. R. Rastorfer, H. Webster, D. Smith</li>
	</ul>

	into individual agent strings.
</p>
<p>
	Will probably do crazy things with non-person agents; CHECK WHATEVER THIS SPITS OUT CAREFULLY!!
</p>



	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<cfif action is "getFile">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into ds_temp_split_agent (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            		'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
	</cfoutput>

	<a href="agent_splitter.cfm?action=parse">parse</a>
</cfif>
<cfif action is "parse">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_split_agent
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<hr>
			<br>original:#original#
			<cfset orig=replace(original," and,",chr(7),"all")>
			<cfset orig=replace(original," and ",chr(7),"all")>
			<cfloop list="#orig#" index="x" delimiters=",&#chr(7)">
				<br>x: #x#
			</cfloop>

		</cfloop>
	</cfoutput>


</cfif>
