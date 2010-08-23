<cfinclude template = "includes/_header.cfm">
<cfoutput>
<cfif not listfindnocase(cgi.REDIRECT_URL,"project","/")>
	<cfquery name="redir" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select project_name from project where project_id=#project_id#
	</cfquery>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/project/#niceURL(redir.project_name)#">
<cfelse>
	<cfquery name="redir" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select project_id from project where niceURL(project_name)='#niceProjName#'
	</cfquery>
	<cfif redir.recordcount is 1>
		<cfset project_id=redir.project_id>
	<cfelse>
		<div class="error">
			Yikes! Something bad happened. Please file a <a href="/info/bugs.cfm">Bug Report</a>.
		</div>
			<cfmail subject="Jacked Up Project" to="#Application.PageProblemEmail#" from="hosedProject@#Application.fromEmail#" type="html">
				Project #niceProjName# matches #redir.recordcount# projects. Fix it.
				<cfif isdefined("project_id")>
					<br>project_id=#project_id#
				</cfif>
				<cfif isdefined("cgi.REDIRECT_URL")>
					<br>cgi.REDIRECT_URL=#cgi.REDIRECT_URL#
				</cfif>
				<cfdump var=#url#>
				<cfdump var=#variables#>
			</cfmail>
		<cfabort>
	</cfif>
</cfif>
<style>
	.proj_title {font-size:2em;font-weight:900;text-align:center;}
	.proj_sponsor {font-size:1.5em;font-weight:800;text-align:center;}
	.proj_agent {font-weight:800;text-align:center;}
	.cdiv {text-align:center;}
</style>
<script type="text/javascript" language="javascript">
	function load(name){
		var el=document.getElementById(name);
		var ptl="/includes/project/" + name + ".cfm?project_id=#project_id#";
		jQuery.get(ptl, function(data){
			 jQuery(el).html(data);
		})
	}
	jQuery(document).ready(function(){
		var elemsToLoad='pubs,specUsed,specCont,projCont,projUseCont,projMedia,projTaxa';
		var elemAry = elemsToLoad.split(",");
		for(var i=0; i<elemAry.length; i++){
			load(elemAry[i]);
		}
	});
</script>	
	<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name,
			project_description,
			start_date,
			end_date,
			agent_name.agent_name, 
			agent_position,
			project_agent_role,
			ps.agent_name sponsor,
			acknowledgement
		FROM 
			project,
			project_agent,
			agent_name,
			project_sponsor,
			agent_name ps
		WHERE 
			project.project_id = project_agent.project_id (+) AND 
			project_agent.agent_name_id = agent_name.agent_name_id (+) and
			project.project_id=project_sponsor.project_id (+) and
			project_sponsor.agent_name_id=ps.agent_name_id (+) and
			project.project_id = #project_id# 
	</cfquery>
	<cfquery name="p" dbtype="query">
		select 
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
		from
			proj
		group by
			project_id,
			project_name,
			project_description,
			start_date,
			end_date
	</cfquery>
	<cfquery name="a" dbtype="query">
		select
			agent_name,
			project_agent_role
		from 
			proj
		group by
			agent_name,
			project_agent_role
		order by 
			agent_position
	</cfquery>
	<cfquery name="s" dbtype="query">
		select 
			sponsor,
			acknowledgement
		from
			proj
		where
			sponsor is not null
		group by			
			sponsor,
			acknowledgement
	</cfquery>
	<span class="annotateSpace">
		<cfif len(session.username) gt 0>
			<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) cnt from annotations
				where project_id = #project_id#
			</cfquery>
			<a href="javascript: openAnnotation('project_id=#project_id#')">
				[Annotate]							
			<cfif #existingAnnotations.cnt# gt 0>
				<br>(#existingAnnotations.cnt# existing)
			</cfif>
			</a>
		<cfelse>
			<a href="/login.cfm">Login or Create Account</a>
		</cfif>
    </span>
	<cfset noHTML=replacenocase(p.project_name,'<i>','','all')>
	<cfset noHTML=replacenocase(noHTML,'</i>','','all')>
	<cfset title = "Project Detail: #noHTML#">
	<cfset metaDesc="Project: #p.project_name#">
	<div class="proj_title">#p.project_name#</div>
	<cfloop query="s">
		<div class="proj_sponsor">
			Sponsored by #sponsor# <cfif len(ACKNOWLEDGEMENT) gt 0>: #ACKNOWLEDGEMENT#</cfif>
		</div>
	</cfloop>
	<cfloop query="a">
		<div class="proj_agent">
			#agent_name#: #project_agent_role#
		</div>
	</cfloop>
	<div class="cdiv">
		#dateformat(p.start_date,"yyyy-mm-dd")# - #dateformat(p.end_date,"yyyy-mm-dd")#
	</div>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
		<p><a href="/Project.cfm?Action=editProject&project_id=#p.project_id#">Edit Project</a></p>
	</cfif>
	<h2>Description</h2>
	#p.project_description#
	<div id="pubs">
		<img src="/images/indicator.gif">
	</div>
	<div id="specUsed">
		<img src="/images/indicator.gif">
	</div>
	<div id="specCont">
		<img src="/images/indicator.gif">
	</div>
	<div id="projCont">
		<img src="/images/indicator.gif">
	</div>
	<div id="projUseCont">
		<!---<h2>Projects using contributed specimens</h2>--->
		<img src="/images/indicator.gif">
	</div>
	<div id="projMedia">
		<img src="/images/indicator.gif">
	</div>
	<div id="projTaxa">
		<img src="/images/indicator.gif">
	</div>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">