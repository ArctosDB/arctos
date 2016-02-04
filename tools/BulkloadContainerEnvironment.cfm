
<cfinclude template="/includes/_header.cfm">
<cfsetting requestTimeOut = "1200">


<cfset title="Bulkload Container Environment">
<cfset thecolumns="barcode,check_date,checked_by_agent,parameter_type,parameter_value,remark">
<cfif action is "makeTemplate">
	<cfset header=thecolumns>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadContainerEnvironment.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadContainerEnvironment.csv" addtoken="false">
</cfif>


<cfif action is  "nothing">
	Use this form to ADD container environment checks.
	<p>
		<a href="BulkloadContainerEnvironment.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>more</th>
		</tr>
		<tr>
			<td>barcode</td>
			<td>yes</td>
			<td></td>
		</tr>
		<tr>
			<td>check_date</td>
			<td>yes</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>checked_by_agent</td>
			<td>yes</td>
			<td>Any unique agent name (login preferred)</td>
		</tr>
		<tr>
			<td>parameter_type</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCONTAINER_ENV_PARAMETER">CTCONTAINER_ENV_PARAMETER</a></td>
		</tr>
		<tr>
			<td>parameter_value</td>
			<td>yes</td>
			<td>See code table documentation for acceptable values</td>
		</tr>
		<tr>
			<td>remark</td>
			<td>no</td>
			<td></td>
		</tr>
	</table>

	Upload CSV:
	<form name="getFile" method="post" action="BulkloadContainerEnvironment.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "getFileData">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cftransaction>
            <cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from cf_container_environment
			</cfquery>

	        <cfloop query="x">
	            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		            insert into cf_container_environment (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "wkt_polygon">
		            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
		                <cfelse>
		            		'#stripQuotes(evaluate(i))#'
		            	</cfif>
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		<p>
			Loaded to temp table - <a href="BulkloadContainerEnvironment.cfm?action=validate">proceed to validate</a>
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "validate">
	<cftransaction>
		<cfquery name="agent_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set agent_id=getAgentID(checked_by_agent)
		</cfquery>
		<cfquery name="container_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set container_id=(
				select container.container_id from container where container.barcode=cf_container_environment.barcode
			)
		</cfquery>
		<cfquery name="isiso" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set status=is_iso8601(check_date) where is_iso8601(check_date) != 'valid'
		</cfquery>
		<cfquery name="badagent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set status='bad agent' where agent_id is null
		</cfquery>
		<cfquery name="badbc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set status='bad barcode' where container_id is null
		</cfquery>
		<cfquery name="badp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_container_environment set status='bad parameter' where parameter_type not in (
				select PARAMETER_TYPE from CTCONTAINER_ENV_PARAMETER
			)
		</cfquery>
		<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from cf_container_environment where status is not null
		</cfquery>
	</cftransaction>
	<cfif ss.c gt 0>
		validation failed
		<p>
		 <a href="BulkloadContainerEnvironment.cfm?action=getCSV">Download CSV (with errors) and try again</a>
		</p>
	<cfelse>
		validated - proceed....
	</cfif>
</cfif>

<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_container_environment
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=thecolumns)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadContainerEnvironmentData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadContainerEnvironmentData.csv" addtoken="false">
</cfif>



<!------------------------------------------------------------------------------------------------>
<cfif action is "load">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into container_environment (
			 	container_environment_id,
			 	container_id,
			 	check_date,
				checked_by_agent_id,
			 	parameter_type,
			 	parameter_value,
				remark
			 ) (
			 	select
			 		sq_container_environment_id.nextval,
			 		container_id,
			 		to_date(check_date),
			 		agent_id,
			 		parameter_type,
			 		parameter_value,
			 		remark
			 	from
			 		cf_container_environment
			 )
	</cfquery>
	all done
</cfif>
<cfinclude template="/includes/_footer.cfm">