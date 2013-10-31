<cfinclude template="/includes/_header.cfm">
<cfset title="Exit Link Report">
<script>
		jQuery(document).ready(function() {
			$("#fdate").datepicker();
			$("#ldate").datepicker();
		});
</script>
<cfoutput>
	<cfparam name="fdate" type="string" default="">
	<cfparam name="ldate" type="string" default="">
	<cfparam name="format" type="string" default="">
	
	<form method="post" action="exit_links.cfm">
		<label for="fdate">Earliest Date</label>
		<input type="text" id="fdate" name="fdate" value="#fdate#">
		
		<label for="ldate">Latest Date</label>
		<input type="text" id="ldate" name="ldate" value="#ldate#">
		<label for="format">Format</label>
		<select name="format" id="format">
			<option <cfif format is "table"> selected="selected" </cfif>value="table">table</option>
			<option <cfif format is "csv"> selected="selected" </cfif>value="csv">csv</option>
			<option <cfif format is "summary"> selected="selected" </cfif>value="summary">summary</option>
		</select>
		<br><input type="submit" value="go">
	</form>
	<cfif isdefined("form.fieldnames") and len(form.fieldnames)>
		<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				<cfif format is "summary">
					count(*) c
				<cfelse>
					*
				</cfif>
			 from exit_link
			 where 1=1 
			 <cfif len(fdate) gt 0>
			 	and WHEN_DATE > '#fdate#'
			 </cfif>
			 <cfif len(ldate) gt 0>
			 	and WHEN_DATE < '#ldate#'
			 </cfif>
			 order by WHEN_DATE desc
		</cfquery>
		
		<hr>
		
		select
				<cfif format is "summary">
					count(*) total,
					count(distinct(ip)) numberOfIPs,
					count(distinct(username)) numberOfUsers,
					count(distinct(referrer)) numberOfRefererrs,
					count(distinct(rawTarget)) numberOfMedia					
				<cfelse>
					*
				</cfif>
			 from exit_link
			 where 1=1 
			 <cfif len(fdate) gt 0>
			 	and WHEN_DATE > '#fdate#'
			 </cfif>
			 <cfif len(ldate) gt 0>
			 	and WHEN_DATE < '#fdate#'
			 </cfif>
			 order by WHEN_DATE desc
			 
			 <hr>
		<cfif format is "table">
			<table border>
				<tr>
					<th>ID</th>
					<th>Referrer</th>
					<th>HTTPTarget</th>
					<th>RawTarget</th>
					<th>Status</th>
					<th>Username</th>
					<th>IP</th>
					<th>Date</th>
				</tr>
				<cfloop query="exit">
					<tr>
						<td>#EXIT_LINK_ID#</td>
						<td>#FROM_PAGE#</td>
						<td>#HTTP_TARGET#</td>
						<td>#TARGET#</td>
						<td>#STATUS#</td>
						<td>#USERNAME#</td>
						<td>#IPADDRESS#</td>
						<td>#WHEN_DATE#</td> 	 	
					</tr>
				</cfloop>
			</table>
		<cfelseif format is "summary">
			<br>Total Clicks: #total#
			<br>Unique IPs: #numberOfIPs#
			<br>Unique Users: #numberOfUsers#
			<br>Unique Referrers: #numberOfRefererrs#
			<br>Unique Media/Files: #numberOfMedia#
		<cfelseif format is "csv">
			<cfset fileDir = "#Application.webDirectory#">
			<cfset variables.encoding="UTF-8">
			<cfset fname = "exit_links.csv">
			<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(ListQualify("ID,Referrer,HTTPTarget,RawTarget,Status,Username,IP,Date",'"')); 
			</cfscript>
			<cfloop query="exit">
				<cfset oneLine = "'#EXIT_LINK_ID#','#FROM_PAGE#','#HTTP_TARGET#','#TARGET#','#STATUS#','#USERNAME#','#IPADDRESS#','#WHEN_DATE#'">
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			</cfloop>
			<cfscript>	
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
			<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		<cfelse>
			bad call<cfabort>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">