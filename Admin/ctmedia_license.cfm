<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			*
		from ctmedia_license
		ORDER BY
			display
	</cfquery>
	<cfoutput>
	

		<table class="newRec" border="1">
			<tr>
				<th>DisplayName</th>
				<th>description</th>
				<td>URI</td>
			</tr>
			<form name="newData" method="post" action="">
				<input type="hidden" name="action" value="insert">
				<tr>
					<td>
						<input type="text" name="display" class="reqdClr">
					</td>
					<td>
						<textarea name="description"  class="reqdClr" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="text" name="uri" class="reqdClr">
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit
		<table border="1">
			<tr>
				<th>Display</th>
				<th>description</th>
				<th>URI</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="m#media_license_id#" id="m#media_license_id#">
						<input name="action" type="hidden">
						<input name="media_license_id" type="hidden" value="#media_license_id#">
						<td><input type="text" name="display" class="reqdClr" value="#display#"></td>
						<td><textarea name="description"  class="reqdClr" id="description" rows="4" cols="40">#description#</textarea></td>
						<td><input type="text" name="uri" value="#uri#" class="reqdClr"></td>				
						<td nowrap="nowrap">
							<span class="likeLink" onclick="m#media_license_id#.action.value='delete';submit();">[ Delete ]</span>
							<br><span class="likeLink" onclick="m#media_license_id#.action.value='save';submit();">[ Update ]</span>	
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif action is "delete">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ctmedia_license where media_license_id=#media_license_id#
	</cfquery>
	<cflocation url="ctmedia_license.cfm" addtoken="false">
</cfif>	
<cfif action is "update">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update ctmedia_license set
			display='#display#',
			description='#description#',
			uri='#uri#'
		where media_license_id=#media_license_id#
	</cfquery>
	<cflocation url="ctmedia_license.cfm" addtoken="false">
</cfif>	
<cfif action is "insert">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into ctmedia_license (
			display,
			description,
			uri
		) values (
			'#display#',
			'#description#',
			'#uri#'
		)
	</cfquery>
	<cflocation url="ctmedia_license.cfm" addtoken="false">
</cfif>	
<cfinclude template="/includes/_footer.cfm">