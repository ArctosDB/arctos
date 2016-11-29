<cfinclude template = "includes/_header.cfm">

<!----
		var text = $("#ht_desc_orig").htmldocument.getElementById('sourceTA').value,
      target = document.getElementById('targetDiv'),
      converter = new showdown.Converter(),
      html = converter.makeHtml(text);

    target.innerHTML = html;


    <div id="ht_desc"></div>
	<div id="ht_desc_orig"></div>












target = $("##ht_desc"),
      ,
      html = converter.makeHtml(text);

    target.innerHTML = html;

console.log(text);

var text = $("##ht_desc_orig").html();
console.log(text);

$("##ht_desc_orig").addClass('importantNotification');
----->




<cfoutput>



	<!-----------------
<cfif not listfindnocase(request.rdurl,"project","/") and isdefined("project_id")>
	<cfquery name="redir" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select niceURL(project_name) project_name from project where project_id=<cfqueryparam value="#project_id#" CFSQLType="cf_sql_integer">
	</cfquery>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/project/#redir.project_name#">
<cfelseif isdefined("niceProjName")>
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
		<cfthrow message="Project not found.">
		<cfabort>
	</cfif>
<cfelse>
	<div class="error">
		invalid call
		<br>Try <a href="/SpecimenUsage.cfm">searching</a>
	</div>
	<cfthrow message="invalid project call">
	<cfabort>
</cfif>


---------------->
<style>
	.proj_title {font-size:2em;font-weight:900;text-align:center;}
	.proj_sponsor {font-size:1.5em;font-weight:800;text-align:center;}
	.proj_agent {font-weight:800;text-align:center;}
	.cdiv {text-align:center;}
</style>
<script type='text/javascript' language="javascript" src='https://cdn.rawgit.com/showdownjs/showdown/1.5.0/dist/showdown.min.js'></script>




<script type="text/javascript" language="javascript">
	function load(name){
		var el=document.getElementById(name);
		var ptl="/includes/project/" + name + ".cfm?project_id=#project_id#";
		jQuery.get(ptl, function(data){
			 jQuery(el).html(data);
		})
	}
	jQuery(document).ready(function(){
		var elemsToLoad='pubs,specUsed,specCont,projCont,projUseCont,projTaxa';
		var elemAry = elemsToLoad.split(",");
		for(var i=0; i<elemAry.length; i++){
			load(elemAry[i]);
		}
		var am='/form/inclMedia.cfm?q=#project_id#&typ=project&tgt=projMedia';
		jQuery.get(am, function(data){
			 jQuery('##projMedia').html(data);
		})
		// convert project description, which is stored as markdown, to html

		// grab the markdown text
		var mdtext = $("##ht_desc_orig").html();
		// users can disable this by using <nomd> tags
		if (mdtext.trim().substring(0,6) != '<nomd>'){
			// convert to markdown
			var converter = new showdown.Converter();
			// people are used to github, so....
			showdown.setFlavor('github');
			converter.setOption('strikethrough', 'true');
			converter.setOption('simplifiedAutoLink', 'true');


			// make some HTML
			var htmlc = converter.makeHtml(mdtext);
			// add the HTML to the appropriate div
			$("##ht_desc").html(htmlc);
			// hide the original
			$("##ht_desc_orig").hide();
		}
	});
</script>

<span class="likeLink" onclick="showSettings()">showSettings</span>
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
			project_agent_remarks,
			funded_usd
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
			end_date,
			funded_usd
		from
			proj
		group by
			project_id,
			project_name,
			project_description,
			start_date,
			end_date,
			funded_usd
	</cfquery>
	<cfquery name="a" dbtype="query">
		select
			agent_name,
			project_agent_role,
			project_agent_remarks
		from
			proj
		group by
			agent_name,
			project_agent_role,
			project_agent_remarks
		order by
			agent_position
	</cfquery>
	<!----
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
	---->
	<span class="annotateSpace">
		<cfif len(session.username) gt 0>
			<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select count(*) cnt from annotations
				where project_id = #project_id#
			</cfquery>
			<a href="javascript: openAnnotation('project_id=#project_id#')">
				[ Report Problem ]
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
	<!----
	<cfloop query="s">
		<div class="proj_sponsor">
			Sponsored by #agent_name# <cfif len(project_agent_remarks) gt 0>: #project_agent_remarks#</cfif>
		</div>
	</cfloop>

	---->
	<cfloop query="a">
		<div class="proj_agent">
			<a target="_blank" href="/agent.cfm?agent_name=#agent_name#">#agent_name#</a>: #project_agent_role#<cfif len(project_agent_remarks) gt 0> (#project_agent_remarks#)</cfif>
		</div>
	</cfloop>
	<div class="cdiv">
		#dateformat(p.start_date,"yyyy-mm-dd")# - #dateformat(p.end_date,"yyyy-mm-dd")#
	</div>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
		<p><a href="/Project.cfm?Action=editProject&project_id=#p.project_id#">Edit Project</a></p>
	</cfif>
	<h2>Description</h2>
	<div id="ht_desc"></div>
	<div id="ht_desc_orig">#p.project_description#</div>




	<cfquery name="supported_research_value" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			sum(funded_usd) supported_research_value
		FROM
			project
		WHERE
			project.project_id IN (
				SELECT
			 		project_trans.project_id
			 	FROM
			 		project,
			 		project_trans,
			 		loan_item,
			 		specimen_part,
			 		cataloged_item
			 	where
			 		project_trans.transaction_id = loan_item.transaction_id AND
			 		loan_item.collection_object_id = specimen_part.collection_object_id AND
			 		specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			 		project_trans.project_id = project.project_id AND
			 		cataloged_item.collection_object_id IN (
			 			SELECT
			 				cataloged_item.collection_object_id
			 			FROM
			 				project,
			 				project_trans,
			 				accn,
			 				cataloged_item
			 			WHERE
			 				accn.transaction_id = cataloged_item.accn_id AND
			 				project_trans.transaction_id = accn.transaction_id AND
			 				project_trans.project_id = project.project_id AND
			 				project.project_id = #project_id#
			 		)
			 )
	</cfquery>
	<cfif len(p.funded_usd) gt 0>
		<cfset f="This project was funded for $#p.funded_usd#">
		<cfif len(supported_research_value.supported_research_value) gt 0>
			<cfset f=f & ", and has supported projects funded for $#supported_research_value.supported_research_value#">
		</cfif>
		<div class="funded_usd">
			#f#.
		</div>
	</cfif>
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
	<h2>Media</h2>
	<div id="projMedia">
		<img src="/images/indicator.gif">
	</div>
	<div id="projTaxa">
		<img src="/images/indicator.gif">
	</div>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">