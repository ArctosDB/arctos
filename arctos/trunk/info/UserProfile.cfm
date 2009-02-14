<cfinclude template="/includes/_header.cfm">
<cfset title="User Profile">
<!--- make sure they have an account --->

<cfif not isdefined("session.username") OR len(#session.username#) is 0>
	<span style="color: #FF0000">You must be a registered user to create a profile!</span>  <br>
	Click <a href="/login.cfm">here</a> to log in or create a user account.
	<cfabort>
</cfif>

<cfif #action# is "nothing">
<cfquery name="getUserData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT   
		cf_users.user_id,
		first_name,
        middle_name,
        last_name,
        affiliation,
		email
	FROM 
		cf_user_data,
		cf_users
	WHERE
		cf_users.user_id = cf_user_data.user_id (+) AND
		username = '#session.username#'
</cfquery>
<cfoutput>
<table>

<form method="post" action="UserProfile.cfm" name="dlForm">
	<input type="hidden" name="user_id" value="#getUserData.user_id#">
	<input type="hidden" name="action" value="continue">
	<tr>
		<td colspan="2"><span style="font-weight: bold; font-style: italic;">
			This information is required only to download data. If you choose to supply this information, fields with a 
		    <input type="text" size="2" class="reqdClr"> 
		    background color are required. This information will not be shared with anyone. Your email address will only be used to reset your password. Your password will not be recoverable without your email address.
	</span></td>
	</tr>
	<tr>
		<td align="right" width="20%">First Name</td>
		<td> <input type="text" name="first_name" value="#getUserData.first_name#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right">Middle Name</td>
		<td><input type="text" name="middle_name" value="#getUserData.middle_name#"></td>
	</tr>
	<tr>
		<td align="right">Last Name</td>
		<td><input type="text" name="last_name" value="#getUserData.last_name#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right">Affiliation</td>
		<td><input type="text" name="affiliation" value="#getUserData.affiliation#" class="reqdClr"></td>
	</tr>
	
	<tr>
		<td align="right">Email</td>
		<td><input type="text" name="email" value="#getUserData.email#"></td>
	</tr>
	
	
	
	<tr>
		<td colspan="2" align="center">
		<input type="submit" value="Save" 
			class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
		</td>
		
	</tr>
</form>

</table>
</cfoutput>
</cfif>

<cfif #action# is "continue">
	<!--- get the values they filled in --->
	<cfif len(#first_name#) is 0 OR
		len(#last_name#) is 0 OR
		len(#affiliation#) is 0>
		You haven't filled in all required values! Please use your browser's back button to try again.
		<cfabort>
	</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	
	<cfquery name="isUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_user_data where user_id=#user_id#
	</cfquery>
		<!---- already have a user_data entry --->
		<cfif #isUser.recordcount# is 1>
			<cfquery name="upUser" datasource="#Application.uam_dbo#">
				UPDATE cf_user_data SET
					first_name = '#first_name#',
					last_name = '#last_name#',
					affiliation = '#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,middle_name = '#middle_name#'
					</cfif>
					<cfif len(#email#) gt 0>
						,email = '#email#'
					</cfif>
				WHERE
					user_id = #user_id#
			</cfquery>
		</cfif>
		<cfif #isUser.recordcount# is not 1>
			<cfquery name="newUser" datasource="#Application.uam_dbo#">
				INSERT INTO cf_user_data (
					user_id,
					first_name,
					last_name,
					affiliation
					<cfif len(#middle_name#) gt 0>
						,middle_name
					</cfif>
					<cfif len(#email#) gt 0>
						,email
					</cfif>
					)
				VALUES (
					#user_id#,
					'#first_name#',
					'#last_name#',
					'#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,'#middle_name#'
					</cfif>
					<cfif len(#email#) gt 0>
						,'#email#'
					</cfif>
					)
			</cfquery>
		</cfif>
	<!--- if they agree to the terms, send them to their download --->
	Thank you! 
	<p>
		<a href="UserProfile.cfm">Back to Profile</a>
	</p>
	
	<p>
		<a href="/home.cfm">Home</a>
	</p>
	
</cfif>
<cfinclude template="/includes/_footer.cfm">