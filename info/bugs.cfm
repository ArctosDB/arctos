<cfif len(#CGI.HTTP_REFERER#) is 0 OR #CGI.HTTP_REFERER# does not contain #Application.ServerRootUrl#>
	Illegal use of form.
	<cfabort>
</cfif>
<cfinclude template="/includes/_header.cfm">
<cfif #Action# is "nothing">
<center>
<table>
<tr>
	<td colspan="2" align="center">
		<div style="width:600px;" align="left">
		<i>Use this form to report bugs. 
		<br>All fields are optional. 
		<br>Include your email address if you would like us to contact you when the issue you submit has been addressed. Your email address will </i><b>not</b><i> be released or publicly displayed on our site.</i>
		<br>Please user the bad data icon <img src="/images/bad.gif"> to report data problems if possible. Doing so will allow us to resolve the issue sooner.
		<p>&nbsp;</p>
		</div>
	</td>
</tr>
	<form name="bug" method="post" action="bugs.cfm">
		<input type="hidden" name="action" value="save">
		
		<tr>
			<td valign="top">
				<div align="right">Who are you?
		    </div></td>
			<td>
				<input type="text" name="reported_name" size="60">
			</td>
		</tr>
		<tr>
			<td valign="top">
				<div align="right">What is your email address?
		    </div></td>
			<td>
				<input type="text" name="user_email" size="60">
			</td>
		</tr>
		<tr>
			<td valign="top">
				<div align="right">What form (URL) don't you like?
		    </div></td>
			<td>
				<input type="text" name="form_name" size="60">
			</td>
		</tr>
		<tr>
			<td valign="top">
				<div align="right">What about it?
		    </div></td>
			<td>
				<textarea name="complaint" rows="6" cols="50"></textarea>		
			</td>
		</tr>
		<tr>
			<td valign="top">
				<div align="right">What do you want us to do about it?
		    </div></td>
			<td>
				<textarea name="suggested_solution" rows="6" cols="50"></textarea>		
			</td>
		</tr>
		<tr>
			<td valign="top">
				<div align="right">How important is this to you?
		    </div></td>
			<td>
				<select name="user_priority" size="1" style="background-color:#00FF00">
					<option value="0" 
						style="background-color:#00FF00 ">Observation - no action required</option>
					<option value="1" 
						style="background-color:#99CCFF" 
						onClick="document.bug.user_priority.style.backgroundColor='#99CCFF';">Just a suggestion</option>
					<option value="2"  
						style="background-color:#FFFF33" 
						onClick="document.bug.user_priority.style.backgroundColor='#FFFF33';">It would make my life easier</option>
					<option value="3"  
						style="background-color:#FF6600" 
						onClick="document.bug.user_priority.style.backgroundColor='#FF6600';">I can't do what I need to without it</option>
					<option value="4" style="background-color:#FF0000" 
						onClick="document.bug.user_priority.style.backgroundColor='#FF0000';">Something is broken</option>
					<option value="5" style="background-color: #000000; color:#FFFFFF"  
						onClick="document.bug.user_priority.style.backgroundColor='#000000';document.bug.user_priority.style.color='#FFFFFF';">
						Data are misrepresented</option>
				</select>
			</td>
		</tr>
		<tr>
			<td valign="top"><div align="right">Anything else we can do for you?</div></td>
			<td><textarea name="user_remarks" rows="6" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td align="center">
				<input type="submit" 
					value="k, I'm all done. Now do something about it!" class="insBtn"
   					onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
				<br><input type="button" 
					value="Read bug reports" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
					onclick="document.location='bugs.cfm?action=read';">	
			</td>
		</tr>
	</form>
</table>
</center>
</cfif>
<!------------------------------------------------------------>
<cfif #action# is "save">
<cfoutput>
<cfset user_id=0>
<cfif isdefined("session.username") and len(#session.username#) gt 0>
	<cfquery name="isUser" datasource="cf_dbuser">
		SELECT user_id FROM cf_users WHERE username = '#session.username#'
	</cfquery>
	<cfset user_id = #isUser.user_id#>
</cfif>
	<cfquery name="bugID" datasource="cf_dbuser">
		select max(bug_id) + 1 as id from cf_bugs
	</cfquery>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	<!--- strip out the crap....--->
	<cfset badStuff = "---a href,---script,[link,[url">
	<cfset concatSub = "#reported_name# #complaint# #suggested_solution# #user_remarks# #user_email#">
	<cfset concatSub = replace(concatSub,"#chr(60)#","---","all")>
	
	<cfif #ucase(concatSub)# contains "invalidTag">
			Bug reports may not contain markup or script.
			<cfabort>
		</cfif>
	<cfloop list="#badStuff#" index="i">
		<cfif #ucase(concatSub)# contains #ucase(i)#>
			Bug reports may not contain markup or script.
			<cfabort>
		</cfif>
	</cfloop>
	<cfquery name="newBug" datasource="cf_dbuser">
		INSERT INTO cf_bugs (
			bug_id,
			user_id,
			reported_name,
			form_name,
			complaint,
			suggested_solution,
			user_priority,
			user_remarks,
			user_email,
			submission_date)
		VALUES (
			#bugID.id#,
			#user_id#,
			'#reported_name#',
			'#form_name#',
			'#complaint#',
			'#suggested_solution#',
			#user_priority#,
			'#user_remarks#',
			'#user_email#',
			'#thisDate#')			
	</cfquery>
	
	<cfmail to="#Application.bugReportEmail#" subject="ColdFusion bug report submitted" from="BugReport@#Application.fromEmail#" type="html">
		<p>Reported Name: #reported_name# (AKA #session.username#) submitted a bug report on #thisDate#.</p>
		
		<P>Form: #form_name#</P>
		
		<P>Complaint: #complaint#</P>
		
		<P>Solution: #suggested_solution#</P>
		
		<P>Priority: #user_priority#</P>
		
		<P>Remarks: #user_remarks#</P>
		
		<P>Email: #user_email#</P>
		
	</cfmail>
	<div align="center">Your report has been successfully submitted.
	  
	</div>
	<P align="center">Thank you for helping to improve this site!
	
<p>	
<div align="center">Click <a href="/home.cfm">here</a> to return to Arctos home.
</div>
<p>	
<div align="center">Click <a href="bugs.cfm?action=read">here</a> to read bug reports.
</div>
</cfoutput>
</cfif>
<!------------------------------------------------------------>
<cfif #action# is "read">

	
	<form name="filter" method="post" action="bugs.cfm">
		<input type="hidden" name="action" value="read">
		<table>
			<tr>
				<td colspan="2">
					<i><b>Filter results:</b></i>
				</td>
			</tr>
			<tr>
				<td align="right">Submitter:</td>
				<td><input type="text" name="reported_name"></td>
			</tr>
			<tr>
				<td align="right">Form:</td>
				<td><input type="text" name="FORM_NAME"></td>
			</tr>
			<tr>
				<td align="right">Complaint:</td>
				<td><input type="text" name="Complaint" size="60"></td>
			</tr>
			<tr>
				<td align="right">Suggested Solution:</td>
				<td><input type="text" name="suggested_solution" size="60"></td>
			</tr>
			<tr>
				<td align="right">Our Solution:</td>
				<td><input type="text" name="admin_solution" size="60"></td>
			</tr>
			<tr>
				<td align="right">User Remarks:</td>
				<td><input type="text" name="user_remarks" size="60"></td>
			</tr>
			<tr>
				<td align="right">Our Remarks:</td>
				<td><input type="text" name="admin_remarks" size="60"></td>
			</tr>
			<tr>
				<td align="right">User Priority:</td>
				<td>
					<select name="user_priority" size="1">
					<option value=""></option>
					<option value="0" 
						style="background-color:#00FF00" 
						onClick="document.filter.user_priority.style.backgroundColor='#00FF00';">I just like to snivel</option>
					<option value="1" 
						style="background-color:#99CCFF" 
						onClick="document.filter.user_priority.style.backgroundColor='#99CCFF';">Just a suggestion</option>
					<option value="2"  
						style="background-color:#FFFF33" 
						onClick="document.filter.user_priority.style.backgroundColor='#FFFF33';">It would make my life easier</option>
					<option value="3"  
						style="background-color:#FF6600" 
						onClick="document.filter.user_priority.style.backgroundColor='#FF6600';">I can't do what I need to without it</option>
					<option value="4" style="background-color:#FF0000" 
						onClick="document.filter.user_priority.style.backgroundColor='#FF0000';">Something is broken</option>
					<option value="5" style="background-color: #000000; color:#FFFFFF"  
						onClick="document.filter.user_priority.style.backgroundColor='#000000';document.filter.user_priority.style.color='#FFFFFF';">
						We'll all die if this isn't fixed immediately</option>
				</select>
				</td>
			</tr>
			<tr>
				<td align="right">Our Priority:</td>
				<td>
					<select name="admin_priority" size="1">
					<option value=""></option>
					<option value="0" 
						style="background-color:#00FF00"
						onClick="document.filter.admin_priority.style.backgroundColor='#00FF00';">I just like to snivel</option>
					<option value="1" 
						style="background-color:#99CCFF" 
						onClick="document.filter.admin_priority.style.backgroundColor='#99CCFF';">Just a suggestion</option>
					<option value="2"  
						style="background-color:#FFFF33" 
						onClick="document.filter.admin_priority.style.backgroundColor='#FFFF33';">It would make my life easier</option>
					<option value="3"  
						style="background-color:#FF6600" 
						onClick="document.filter.admin_priority.style.backgroundColor='#FF6600';">I can't do what I need to without it</option>
					<option value="4" style="background-color:#FF0000" 
						onClick="document.filter.admin_priority.style.backgroundColor='#FF0000';">Something is broken</option>
					<option value="5" style="background-color: #000000; color:#FFFFFF"  
						onClick="document.filter.admin_priority.style.backgroundColor='#000000';document.filter.admin_priority.style.color='#FFFFFF';">
						We'll all die if this isn't fixed immediately</option>
				</select>
				</td>
			</tr>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
			<tr>
				<td align="right"><font color="#FF0000">username</font>: </td>
				<td><input type="text" name="cf_username" size="60"></td>
			</tr>
			<tr>
				<td align="right"><font color="#FF0000">email</font>:</td>
				<td><input type="text" name="user_email" size="60"></td>
			</tr>
			</cfif>
			<tr>
				<td align="right">Show only unresolved bugs:</td>
				<td><input type="checkbox" name="resolved" value="1" checked></td>
			</tr>
			<tr>
				<td colspan="2">
					<div align="center">
					<input type="submit" value="Filter" class="schBtn"
   					onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">	
					<input type="button" value="Remove Filter" class="clrBtn"
   					onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'" onClick="reset(); submit();">	
					
				      </div></td>
			</tr>
		</table>
	
	</form>
	
	<cfset sql = "select 
					 BUG_ID,
					 cf_bugs.USER_ID,
					 REPORTED_NAME,
					 FORM_NAME,
					 COMPLAINT,
					 SUGGESTED_SOLUTION,
					 ADMIN_SOLUTION,
					 USER_PRIORITY,
					 ADMIN_PRIORITY,
					 USER_REMARKS,
					 ADMIN_REMARKS,
					 SOLVED_FG,
					 USER_EMAIL,
					 SUBMISSION_DATE,
					 username
				from 
					cf_bugs,
					cf_users
				where 
					cf_bugs.user_id = cf_users.user_id (+) AND
					bug_id > 0">
		<cfif isdefined("FORM_NAME") and len(#FORM_NAME#) gt 0>
			<cfset sql = "#sql# AND upper(FORM_NAME) LIKE '%#ucase(trim(FORM_NAME))#%'">
		</cfif>
		<cfif isdefined("reported_name") and len(#reported_name#) gt 0>
			<cfset sql = "#sql# AND upper(reported_name) LIKE '%#ucase(trim(reported_name))#%'">
		</cfif>
		<cfif isdefined("complaint") and len(#complaint#) gt 0>
			<cfset sql = "#sql# AND upper(complaint) LIKE '%#ucase(trim(complaint))#%'">
		</cfif>
		<cfif isdefined("suggested_solution") and len(#suggested_solution#) gt 0>
			<cfset sql = "#sql# AND upper(suggested_solution) LIKE '%#ucase(trim(suggested_solution))#%'">
		</cfif>
		<cfif isdefined("admin_solution") and len(#admin_solution#) gt 0>
			<cfset sql = "#sql# AND upper(admin_solution) LIKE '%#ucase(trim(admin_solution))#%'">
		</cfif>
		<cfif isdefined("user_remarks") and len(#user_remarks#) gt 0>
			<cfset sql = "#sql# AND upper(user_remarks) LIKE '%#ucase(trim(user_remarks))#%'">
		</cfif>
		<cfif isdefined("user_priority") and len(#user_priority#) gt 0>
			<cfset sql = "#sql# AND user_priority = #user_priority#">
		</cfif>
		<cfif isdefined("admin_priority") and len(#admin_priority#) gt 0>
			<cfset sql = "#sql# AND admin_priority = #admin_priority#">
		</cfif>
		<cfif isdefined("cf_username") and len(#cf_username#) gt 0>
			<cfset sql = "#sql# AND upper(username) LIKE '%#ucase(trim(cf_username))#%'">
		</cfif>
		<cfif isdefined("email") and len(#email#) gt 0>
			<cfset sql = "#sql# AND upper(email) LIKE '%#ucase(trim(email))#%'">
		</cfif>
		<cfif isdefined("resolved") and len(#resolved#) gt 0>
			<cfset sql = "#sql# AND solved_fg =1">
		<cfelse>
			<cfset sql = "#sql# AND (solved_fg <> 1 OR solved_fg is null)">
		</cfif>
		<cfif isdefined("bug_id") and len(#bug_id#) gt 0>
			<cfset sql = "#sql# AND bug_id = #bug_id#">
		</cfif>
		
	<cfset sql = "#sql# order by submission_date DESC">
		
		<cfquery name="getBug" datasource="cf_dbuser">
			 #preservesinglequotes(sql)#
		</cfquery>
		
	<cfoutput query="getBug">
			<cfif currentrow MOD 2>
				<cfset bgc = "##C7D5D6">
			<cfelse>
				<cfset bgc = "##F5F5F5">
			</cfif>
			<div style="background-color:#bgc# ">
			<form name="admin#CurrentRow#" method="post" action="bugs.cfm">
				<input type="hidden" name="action" value="saveAdmin">
				<input type="hidden" name="bug_id" value="#bug_id#">
			<i><b>Filed by:</b></i> #reported_name# &nbsp;&nbsp;&nbsp;
			<cfif #solved_fg# is 1>
				<font color="##00FF00" size="+1">Resolved</font>			
			</cfif>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					<br>
					<font color="##FF0000"><i>username: #username#
					<br>email: #user_email#
					<br>Date Submitted: #dateformat(submission_date,"dd mmm yyyy")#</i></font>
				
			</cfif>
			<br><i><b>Concerning form:</b></i> #form_name#
			<br><i><b>Complaint:</b></i> #complaint#
			<br><i><b>Suggested Solution:</b></i> #suggested_solution#
			<br>
			<font color="##0000FF"><i><b>Our Solution:</b></i> #admin_solution#</font>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<br>
				<font color="##FF0000"><i>Update admin solution to:</i></font>
				<br>
				<textarea name="admin_solution" rows="6" cols="50">#admin_solution#</textarea>
			</cfif>
			<br><i><b>Submitted Priority:</b></i> #user_priority#
			<br>
			<font color="##0000FF"><i><b>Our Priority:</b></i> #admin_priority#</font>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<font color="##FF0000"><i>Update admin priority to:</i></font>
				<select name="admin_priority" size="1" style="background-color:##00FF00">
					<option value="0" 
						style="background-color:##00FF00 ">I just like to snivel</option>
					<option value="1" 
						style="background-color:##99CCFF" 
						onClick="document.bug.admin_priority.style.backgroundColor='##99CCFF';">Just a suggestion</option>
					<option value="2"  
						style="background-color:##FFFF33" 
						onClick="document.bug.admin_priority.style.backgroundColor='##FFFF33';">It would make my life easier</option>
					<option value="3"  
						style="background-color:##FF6600" 
						onClick="document.bug.admin_priority.style.backgroundColor='##FF6600';">I can't do what I need to without it</option>
					<option value="4" style="background-color:##FF0000" 
						onClick="document.bug.admin_priority.style.backgroundColor='##FF0000';">Something is broken</option>
					<option value="5" style="background-color: ##000000; color:##FFFFFF"  
						onClick="document.bug.admin_priority.style.backgroundColor='##000000';document.bug.admin_priority.style.color='##FFFFFF';">
						We'll all die if this isn't fixed immediately</option>
				</select>
			</cfif>
			<br><i><b>Submitted Remarks:</b></i> #user_remarks#
			<br><i><b>Our Remarks:</b></i> #admin_remarks#
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					
				<br><textarea name="admin_remarks" rows="6" cols="50">#admin_remarks#</textarea>
			</cfif>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<input type="hidden" name="solved_fg" value="0">
				<br><input type="submit" value="update">
				<br><input type="button" value="Update and Mark Resolved" onclick="admin#CurrentRow#.solved_fg.value=1;submit();">
				
			</cfif>
	  </form>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<form name="killit#CurrentRow#" method="post" action="bugs.cfm">
					<input type="hidden" name="action" value="killit">
					<input type="hidden" name="bug_id" value="#bug_id#">
					<input type="submit" value="delete">
				</form>
			</cfif>
	  </div>
		</cfoutput>

</cfif>
<!------------------------------------------------------------>


<!------------------------------------------------------------>
<cfif #action# is "saveAdmin">
	<cfquery name="upAd" datasource="cf_dbuser">
		UPDATE cf_bugs SET 
			admin_remarks = '#admin_remarks#',
			admin_priority = #admin_priority#,
			admin_solution = '#admin_solution#',
			solved_fg=#solved_fg#
		WHERE
			bug_id = #bug_id#		
	</cfquery>
	<cflocation url="bugs.cfm?action=read">
</cfif>
<!------------------------------------------------------------>
<cfif #action# is "killit">
	<cfquery name="upAd" datasource="cf_dbuser">
		DELETE FROM cf_bugs WHERE bug_id=#bug_id#	
	</cfquery>
	<cflocation url="bugs.cfm?action=read">
</cfif>



<cfinclude template="/includes/_footer.cfm">