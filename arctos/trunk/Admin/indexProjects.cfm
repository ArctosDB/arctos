	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
		project.project_id,
		project_name,
		project_description,
		start_date,
		end_date,
		CONCATprojagent(project.project_id) names
	FROM 
		project
	</cfquery>
	<cfindex 
	query="data" 
	collection="veritySearchData"
	action="Update"
	type="Custom"
	key="project_id"
	category="data,project"
	title="project_id"	
	custom1="project_name"
	body="
		project_name,
		project_description,
		names,
		start_date,
		end_date">
		
spiffy