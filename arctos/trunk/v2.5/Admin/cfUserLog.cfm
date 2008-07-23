<cfinclude template="/includes/_header.cfm">
<script >
	function clearAll () {
		document.getElementById('format').value='';
		document.getElementById('usrname').value='';
		document.getElementById('begin_time').value='';
		document.getElementById('end_time').value='';
		document.getElementById('axes').value='';
		document.getElementById('template').value='';
		document.getElementById('referring_url').value='';
		document.getElementById('q_string').value='';		
	}
	function valThis() {
		if (document.getElementById('format').value=='') {
			alert('You must provide required information.');
			return false;
		} else {
			document.getElementById('params').submit();
		}
		
	}
	function formatOptions () {
		var v = document.getElementById('format').value;
		//alert(v);
		if (v == 'graph') {
			document.getElementById('graphTypeDiv').style.display='';
		} else {
			document.getElementById('graphTypeDiv').style.display='none';
		}
	}
</script>
<cfparam name="format" default="">
<cfparam name="usrname" default="">
<cfparam name="begin_time" default="">
<cfparam name="end_time" default="">
<cfparam name="axes" default="">
<cfparam name="template" default="">
<cfparam name="referring_url" default="">
<cfparam name="q_string" default="">

		
	View User Activity
	<cfoutput>
	<form method="post" name="params" id="params" action="cfUserLog.cfm">
		<input type="hidden" name="action" value="getData">
		<label for="format">Format</label>
		<select name="format" id="format" size="1" class="reqdClr" onchange="formatOptions();">
			<option <cfif #format# is "table"> selected </cfif>value="table">table</option>
			<option <cfif #format# is "graph"> selected </cfif>value="graph">graph</option>
			<option <cfif #format# is "summary"> selected </cfif>value="summary">summary</option>
			<option <cfif #format# is "text"> selected </cfif>value="text">text</option>
			
		</select>
		<br>
		<div id="graphTypeDiv" style="display:none">
			<select name="Axes" multiple="multiple" size="2">
				<option <cfif listfind(axes,"referring_url")> selected </cfif>value="referring_url">Referrers</option>
				<option <cfif listfind(axes,"template")> selected </cfif>value="template">Form</option>
			</select>
		</div>
		
		<br>
		<label for="usrname">Username</label>
		<input type="text" name="usrname" id="usrname" value="#usrname#">
		<br>
		<label for="begin_time">Date Span</label>
		<input type="text" name="begin_time" id="begin_time" value="#begin_time#"> to <input type="text" name="end_time" id="end_time" value="#end_time#">
		<br>
		<label for="template">Form</label>
		<input type="text" name="template" id="template" value="#template#">
		<br>
		<label for="referring_url">Referrer</label>
		<input type="text" name="referring_url" id="referring_url" value="#referring_url#">
		<br>
		<label for="q_string">Query</label>
		<input type="text" name="q_string" id="q_string" value="#q_string#">
		<br>
		
		
		
		<input type="button"
			class="lnkBtn"
		   	onmouseover="this.className='lnkBtn btnhov'" 
		   	onmouseout="this.className='lnkBtn'"
		   	value="Get Data"
		   	onclick="valThis();">
		<input type="button"
			class="clrBtn"
		   	onmouseover="this.className='clrBtn btnhov'" 
		   	onmouseout="this.className='clrBtn'"
		   	value="Clear Form"
		   	onclick="clearAll();">
		
	</form>
	<script>
		formatOptions();
	</script>
	</cfoutput>

<!------------------------------------------------------------------------------------>
<cfif #action# is "getData">
	<cfset sql = "select * from cf_log where log_id > 0">
	<cfif isdefined("usrname") and len(#usrname#) gt 0>
		<cfset sql = "#sql# AND upper(username) like '%#ucase(usrname)#%'">
	</cfif>
	<cfif isdefined("template") and len(#template#) gt 0>
		<cfset sql = "#sql# AND upper(template) like '%#ucase(template)#%'">
	</cfif>
	<cfif isdefined("referring_url") and len(#referring_url#) gt 0>
		<cfset sql = "#sql# AND upper(referring_url) like '%#ucase(referring_url)#%'">
	</cfif>
	<cfif isdefined("q_string") and len(#q_string#) gt 0>
		<cfset sql = "#sql# AND upper(query_string) like '%#ucase(q_string)#%'">
	</cfif>
	
	<cfif isdefined("begin_time") and len(#begin_time#) gt 0>
		<cfif not isdefined("end_time") or len(#end_time#) is 0>
			<cfset end_time = begin_time>
		</cfif>
		<cfset sql = "#sql# AND access_date between '#dateformat(begin_time,"dd-mmm-yyyy")#' 
				and '#dateformat(end_time,"dd-mmm-yyyy")#'">
	</cfif>
	
	<cfset sql = "#sql# order by username,access_date">
	<cfquery name="logData" datasource="#Application.uam_dbo#">
		 #preservesinglequotes(sql)#
	</cfquery>
	
	<cfoutput >
		 #preservesinglequotes(sql)#
	</cfoutput>
	<hr>
	
	<!----
	
	--->
</cfif>
<!--------------------------------------------------------------------------------->
<cfif #format# is "Summary">
	<cfquery name="s" dbtype="query">
		select 
			count(distinct(USERNAME)) users,
			count(distinct(TEMPLATE)) TEMPLATE,
			count(distinct(QUERY_STRING)) QUERY_STRING,
			count(distinct(REFERRING_URL)) REFERRING_URL,
			sum(reported_count) tot_items
		from
			logData
	</cfquery>
	<cfoutput >
		<table border>
			<tr>
				<td align="right">Number Distinct Users:</td>
				<td>#s.users#</td>
			</tr>
			<tr>
				<td align="right">Number Distinct Forms Accessed:</td>
				<td>#s.TEMPLATE#</td>
			</tr>
			<tr>
				<td align="right">Number Distinct Queries:</td>
				<td>#s.QUERY_STRING#</td>
			</tr>
			<tr>
				<td align="right">Number Referring URLs:</td>
				<td>#s.REFERRING_URL#</td>
			</tr>
			<tr>
				<td align="right">Total Records Accessed:</td>
				<td>#s.tot_items#</td>
			</tr>
		</table>
	
	</cfoutput>
	 LOG_ID                                    NOT NULL NUMBER
 USERNAME                                           VARCHAR2(255)
 TEMPLATE                                           VARCHAR2(255)
 ACCESS_DATE                                        DATE
 QUERY_STRING                                       VARCHAR2(4000)
 REPORTED_COUNT                                     NUMBER
 REFERRING_URL                                      VARCHAR2(4000)

</cfif>
<cfif #format# is "graph">
	<cfoutput>
	<cfloop list="#axes#" index="d">
	<cfquery name="chartData" dbtype="query">
		select #d# x,count(#d#) y from logData group by #d# order by y DESC
	</cfquery>
	
			
		<cfchart format="png"
		chartHeight = "500"
		chartWidth = "1000"
		xaxistitle="#d#" 
		yaxistitle="Count"
		show3D="yes"
		title = "Access by #d#"
		fontBold="yes"> 
		<cfchartseries type="bar" 
					query="chartData" 
					itemcolumn="x" 
					valuecolumn="y"
					seriesColor="##0066FF">
				</cfchartseries>
			</cfchart>
			
			<cfchart format="png"
		name="myChart" 
		chartHeight = "500"
		chartWidth = "500"
		xaxistitle="#d#" 
		yaxistitle="Count"
		show3D="yes"
		title = "Access by #d#"
		fontBold="yes"> 
		<cfchartseries type="pie" 
					query="chartData" 
					itemcolumn="x" 
					valuecolumn="y"
					seriesColor="##0066FF">
				</cfchartseries>
			</cfchart>	
			
				
		<cffile action="WRITE" 	file="#Application.webDirectory#/temp/#d#.png" output="#myChart#"> 
	<a href="#Application.ServerRootUrl#/temp/#d#.png">download chart image</a>
	</cfloop>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------->
<cfif #format# is "table">
<cfoutput >
	<table border="1">
		<tr>
			<th>Username</th>
			<th>Count</th>
			<th>Access Time</th>
			<th>From Form</th>
			<th>Accesed Form</th>
			<th>Query String</th>
			
		</tr>
	<cfset i=1>
	<cfloop query="logData">
		<tr>
			<td>#username#</td>
			<td>#reported_count#</td>
			<td>#access_date#</td>
			<td>
				<cfif len(#referring_url#) lt 100>
					<a href="#referring_url#" target="_blank">#referring_url#</a>
				<cfelse>
					<a href="#referring_url#" target="_blank">#left(referring_url,97)#...</a>					
				</cfif>
			</td>
			<td>
				<a href="#Application.ServerRootUrl##template##query_string#" target="_blank">#Application.ServerRootUrl##template#</a>
			</td>
			<td>#query_string#</td>
			
		</tr>
		<cfset i=#i#+1>
	</cfloop>
	</table>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------->
<cfif #format# is "text">
<cfoutput>
	<cfset line = '"log_id","username","template","access_date","query_string","reported_count","referring_url"'>
	<cffile action="write" nameconflict="overwrite" file="#Application.webDirectory#/temp/user_stats.txt" addnewline="yes" output="#line#">
	<cfloop query="logData">
		<cfset line = '"#log_id#","#username#","#template#","#access_date#","#query_string#","#reported_count#","#referring_url#"'>
		<cffile action="append" file="#Application.webDirectory#/temp/user_stats.txt" output="#line#" addnewline="yes">
	</cfloop>


<a href="#Application.ServerRootUrl#/temp/user_stats.txt">Right-click to save file</a>

</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">