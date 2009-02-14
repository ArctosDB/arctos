<cfinclude template="/Application.cfm">
<cfif not isdefined("attributes.name")>
	Your query did not submit a name to find.
	If you
	<ul>
		
		<li>Typed an agent name, or</li>
		<li>Selected an agent via a pick</li>
	</ul>
	and are still recieving this message, something is broken!
	Please submit a bug report.
<cfelse>
	<cfset name = #attributes.name#>
</cfif>

			<!---- they typed a name in, see if we can match it ---->
			<cfquery name="isValidName" datasource="#Application.uam_dbo#">
				SELECT distinct(agent_id) FROM agent_name WHERE agent_name = '#name#'
			</cfquery>
			<cfif #isValidName.recordcount# is 1>
				<!---- they got it! Just return the ID. ---->
				<cfset thisAgentId = #isValidName.agent_id#>
			<cfelse>
				<!---- open a window and let them pick from the alternatives ---->
				<!---- make sure we have everything we need ---->
					<cfif not isdefined("attributes.formName") 
						OR len(#attributes.formName#) is 0
						OR not isdefined("attributes.control")
						OR len(#attributes.control#) is 0
						OR not isdefined("attributes.button")
						OR len(#attributes.button#) is 0>
						You didn't give me something I need!
						<cfabort>
					<cfelse>
						<cfset formName = #attributes.formName#>
						<cfset control = #attributes.control#>
						<cfset button = #attributes.button#>
					</cfif>
				<!---- first, redirect them back to the form they came from ---->
					<cfoutput>
						<script>
							// open a window, pass it all the good stuff
							window.open ("/includes/redirToPick.cfm?formName=#formName#&control=#control#&button=#button#","redirWin","width=200,height=200");
							//history.back();document.getElementById('agent_name').className='readClr'
						</script>
					</cfoutput>
					<!---- stop loading ---->
					<cfabort>
				<!---- set the color of the pick they're populating to something distinctive ----->
				
				<!----- open the pick window, populated with whatever they initially provided ---->
				<!----
			<cfelseif #isValidName.recordcount# lt 1>
				<!--- see if we can find some possibilities ---->
				<cfquery name="somethingClose" datasource="#Application.uam_dbo#">
					select agent_name, agent_name_type, agent_id FROM agent_name WHERE
					upper(agent_name) LIKE '%#ucase(name)#%'	
				</cfquery>
				<font color="##FF0000">The name you typed did not match any agents. 
				You must supply a full, recognized, unique agent name. Some possible matches are:
				<ul>
					<cfloop query="somethingClose">
						<cfif #agent_name_type# is "preferred">
							<li>
								<a href="javascript:void(0);" onClick="newColl.name.value='#agent_name#';newColl.newagent_id.value='#agent_id#';">#agent_name#</a>
							</li>
						</cfif>
					</cfloop>
				</ul>
				
				
				</font>			  
				<cfabort>
			<cfelseif #isValidName.recordcount# gt 1>
				<!--- see if we can offer any suggestions ---->
				<cfset listOfMatches = "">
				<cfloop query="isValidName">
					<cfif len(#listOfMatches#) is 0>
						<cfset listOfMatches = #agent_id#>
					<cfelse>
						<cfset listOfMatches = "#listOfMatches#,#agent_id#">
					</cfif>
				</cfloop>
				<font color="##FF0000">Multiple agents matched the name you typed. Some possibilities are:</font>			  
				<cfquery name="findNames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						agent_name, 
						agent_name_type,
						agent_id
					FROM agent_name
					WHERE agent_id IN (#listOfMatches#)
					ORDER BY agent_id, agent_name_type,agent_name
				</cfquery>
				<ul>
					<cfloop query="findNames">
						<li><font color="##FF0000">#agent_name# (#agent_name_type#)</font></li>
					</cfloop>
				</ul>
				<cfabort>
				---->
			</cfif>