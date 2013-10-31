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
						<td>#WHEN_DATE#</td>
						<td>#IPADDRESS#</td>	 	 	
					</tr>
				</cfloop>
			</table>
		<cfelseif format is "summary">
			count: #exit.c#
		<cfelseif format is "csv">
			building csv.....
		<cfelse>
			bad call<cfabort>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">