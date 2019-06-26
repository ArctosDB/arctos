<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">

<cfoutput>
	<h2>Get data from bulkloader_deletes</h2>
	<p>
		Bulkloader_deletes is the trigger-maintained archive of everything that's deleted from the specimen bulkloader.
		The specimen bulkloader is written to by all specimen data entry channels.
	</p>
<cfquery name="gp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select guid_prefix,collection_id from collection order by guid_prefix
</cfquery>

<form name="f" method="get" action="bulkloader_archive.cfm">
	<select name="collection_id" id="collection_id">
		<option>pick one</option>
		<cfloop query="gp">
			<option value="#gp.collection_id#">#gp.guid_prefix#</option>
		</cfloop>
	</select>
	<br><input type="submit" value="get data" class="schBtn">
</form>
<cfif isdefined("collection_id") and len(collection_id) gt 0>
	<cfquery name="data" datasource="uam_god">
		select * from bulkloader_deletes where collection_id=#val(collection_id)#
	</cfquery>
	<cfset fname = "bulkloader_deletes.csv">
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=data,Fields=data.columnList)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/#fname#"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=#fname#" addtoken="false">
	<a href="/download/#fname#">Click here if your file does not automatically download.</a>
</cfif>
</cfoutput>


<cfinclude template="/includes/_footer.cfm">

