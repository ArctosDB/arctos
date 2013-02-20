	 <cfthrow message="This error was thrown from the bugTest action page.">


					 <cfabort>



<cfinclude template = "includes/_header.cfm">
<cfoutput>

<cfif not listfindnocase(request.rdurl,"project","/")>
	<cfquery name="redir" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select project_name from project where project_id=#project_id#
	</cfquery>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/project/#niceURL(redir.project_name)#">
<cfelse>
	<cfquery name="redir" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select project_id from project where niceURL(project_name)='#niceProjName#'
	</cfquery>
	<cfif redir.recordcount is 1>
		<cfset project_id=redir.project_id>
	<cfelse>
		<div class="error">
			Project not found.
			<br>Try <a href="/SpecimenUsage.cfm">searching</a>
		</div>


<!----
		<cfthrow
		    detail = "Project #niceProjName# matches #redir.recordcount# projects."
		    	message="a project is missing"
		    errorCode = "project_hosed">
---->

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
	<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			project.project_id,
			project_name,
			project_description,
			start_date,
			end_date,
			preferred_agent_name.agent_name,
			agent_position,
			project_agent_role,
			project_agent_remarks
		FROM
			project,
			project_agent,
			preferred_agent_name
		WHERE
			project.project_id = project_agent.project_id (+) AND
			project_agent.agent_id = preferred_agent_name.agent_id (+) and
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
			agent_name,
			project_agent_remarks
		from
			proj
		where
			project_agent_role='Sponsor'
		group by
			agent_name,
			project_agent_remarks
	</cfquery>
	<span class="annotateSpace">
		<cfif len(session.username) gt 0>
			<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<div class="proj_title">#p.project_name#</div>
	<cfloop query="s">
		<div class="proj_sponsor">
			Sponsored by #agent_name# <cfif len(project_agent_remarks) gt 0>: #project_agent_remarks#</cfif>
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