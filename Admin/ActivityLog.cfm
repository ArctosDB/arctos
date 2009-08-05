<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	var cal1 = new CalendarPopup("theCalendar");
	cal1.showYearNavigation();
	cal1.showYearNavigationInput();
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	function clearForm() {
		document.getElementById('uname').value='';
		document.getElementById('object').value='';
		document.getElementById('bdate').value='';
		document.getElementById('edate').value='';
		document.getElementById('sql').value='';
	}
</SCRIPT>
<cfparam name="uname" default="">
<cfparam name="bdate" default="">
<cfparam name="edate" default="">
<cfparam name="sql" default="">
<cfparam name="object" default="">
<cfoutput>
<p><strong>This form accesses after approximately 7 August 2009</strong></p>	
	<form name="srch" method="post" action="ActivityLog.cfm">
		<label for="action">Data to search</label>
		<select name="action" id="action">
			<option <cfif action is 'search'> selected="selected"</cfif> value="search">7 Aug 2009-present</option>
			<option <cfif action is 'search_old'> selected="selected"</cfif> value="search_old">before 7 Aug 2009</option>
		</select>
		<label for="uname">Username</label>
		<input type="text" name="uname" id="uname" value="#uname#">
		<label for="bdate">Begin Date</label>
		<input type="text" name="bdate" id="bdate" value="#bdate#">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.bdate,'anchor1','dd-MMM-yyyy'); return false;"/>
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate" value="#edate#">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.edate,'anchor1','dd-MMM-yyyy'); return false;"/>					
					
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
		<p><strong>Data after approximately 7 August 2009</strong></p>
		<hr>
		
		select 
				to_char(TIMESTAMP,'dd-mon-yyyy') date_stamp, 
				SQL_TEXT sql_statement, 
				DB_USER username,
				OBJECT_NAME object
			from 
				uam.arctos_audit
			where
				1=1
				<cfif len(#uname#) gt 0>
					AND upper(DB_USER) like '%#ucase(uname)#%'
				</cfif>
				<cfif len(#bdate#) gt 0>
					AND (
						TIMESTAMP >= to_date('#dateformat(bdate,"dd-mmm-yyyy")#')
						and TIMESTAMP <= to_date('#dateformat(edate,"dd-mmm-yyyy")#')
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
				
				<hr>
		<cfquery name="activity" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				to_char(TIMESTAMP,'dd-mon-yyyy') date_stamp, 
				SQL_TEXT sql_statement, 
				DB_USER username,
				OBJECT_NAME object
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
				<td>#date_stamp#</td>
				<td>#sql_statement#</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<cfif #action# is "search_old">
	<cfquery name="activity" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			to_char(date_stamp,'dd-mon-yyyy') date_stamp, 
			sql_statement, 
			username
		from 
			cf_database_activity, 
			cf_users 
		where
			cf_database_activity.user_id = cf_users.user_id
			<cfif len(#uname#) gt 0>
				AND upper(username) like '%#ucase(uname)#%'
			</cfif>
			<cfif len(#date#) gt 0>
				AND upper(to_char(date_stamp,'dd-mon-yyyy')) like '%#ucase(date)#%'
			</cfif>
			<cfif len(#sql#) gt 0>
				AND upper(sql_statement) like '%#ucase(sql)#%'
			</cfif>
		ORDER BY 
			username,
			date_stamp,
			sql_statement
	</cfquery>
	<p><strong>Data previous to approximately 7 August 2009</strong></p>	
	<table border id="t_old" class="sortable">
		<tr>
			<th>username</th>
			<th>date_stamp</th>
			<th>sql_statement</th>
		</tr>
		<cfoutput>
		<cfloop query="activity">
			<tr>
				<td>#username#</td>
				<td>#date_stamp#</td>
				<td>#sql_statement#</td>
			</tr>
		</cfloop>
		</cfoutput>
	</table>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="/includes/_footer.cfm">