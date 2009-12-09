<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	function clearForm() {
		document.getElementById('uname').value='';
		document.getElementById('object').value='';
		document.getElementById('bdate').value='';
		document.getElementById('edate').value='';
		document.getElementById('sql').value='';
	}
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#bdate").datepicker();
			jQuery("#edate").datepicker();
		});
	});
	
</SCRIPT>
<cfparam name="uname" default="">
<cfparam name="bdate" default="">
<cfparam name="edate" default="">
<cfparam name="sql" default="">
<cfparam name="object" default="">
<cfoutput>
	<form name="srch" method="post" action="ActivityLog.cfm">
		<input type="hidden" name="action" id="action" value="search">
		<label for="uname">Username</label>
		<input type="text" name="uname" id="uname" value="#uname#">
		<label for="bdate">Begin Date</label>
		<input type="text" name="bdate" id="bdate" value="#bdate#">
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate" value="#edate#">
		<label for="sql">SQL</label>
		<input type="text" name="sql" id="sql" value="#sql#">
		<label for="object">Object</label>
		<input type="text" name="object" id="object" value="#object#">
		<br>
		<input type="submit" 
		 	value="Filter" 
			class="lnkBtn">
		<input type="button" value="Clear" class="clrBtn" onclick="clearForm()">
	</form>
</cfoutput>
<cfif action is "search">
	<cfoutput>
		<cfif len(bdate) gt 0 and len(edate) is 0>
			<cfset edate=bdate>
		</cfif>
		<p><strong>Data after 7 August 2009</strong></p>
		<cfquery name="activity" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				to_char(TIMESTAMP,'dd-Mon-yyyy HH24:MI:SS') date_stamp, 
				SQL_TEXT sql_statement, 
				DB_USER username,
				OBJECT_NAME object,
				SQL_BIND
			from 
				uam.arctos_audit
			where
				1=1
				<cfif len(#uname#) gt 0>
					AND upper(DB_USER) like '%#ucase(uname)#%'
				</cfif>
				<cfif len(#bdate#) gt 0>
					AND (
						to_date(to_char(TIMESTAMP,'dd-mon-yyy')) between to_date('#dateformat(bdate,"dd-mmm-yyyy")#')
						and to_date('#dateformat(edate,"dd-mmm-yyyy")#')
					)
				</cfif>
				<cfif len(#sql#) gt 0>
					AND upper(SQL_TEXT) like '%#ucase(sql)#%'
				</cfif>
				<cfif len(#object#) gt 0>
					AND upper(object_name) like '%#ucase(object)#%'
				</cfif>
			ORDER BY 
				username,
				date_stamp,
				sql_statement
		</cfquery>
		<table border id="t" class="sortable">
		<tr>
			<th>username</th>
			<th>object</th>
			<th>date_stamp</th>
			<th>sql_statement</th>
		</tr>
		<cfloop query="activity">
			<tr>
				<td>#username#</td>
				<td>#object#</td>
				<td nowrap="nowrap">#date_stamp#</td>
				<td>
					#sql_statement#
					<cfif len(sql_bind) gt 0><br><span style='font-size:smaller;color:gray'>[#sql_bind#]</span></cfif>
				</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">