
<cfinclude template="/includes/_frameHeader.cfm">
	<cfif #action# is "nothing">
		<cfif not isdefined("canned_id") or len(#canned_id#) is 0>
			Oops! Didn't get an ID - aborting....
			<cfabort>
		</cfif>
		<cfoutput>
		<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select SEARCH_NAME
			from cf_canned_search
			where canned_id=#canned_id#
		</cfquery>
		<form name="mailMe" method="post" action="mailSaveSearch.cfm">
			<input type="hidden" name="action" value="preview">
			<input type="hidden" name="canned_id" value="#canned_id#">
			<input type="hidden" name="SEARCH_NAME" value="#s.SEARCH_NAME#">
			<label for="msg">Message to Attach:</label>
			<textarea name="msg" id="msg" rows="4" cols="40"></textarea>
			<label for="address">Email Address (separate with commas)</label>
			<input type="text" name="address" id="address" size="50">
			<br>
			<input type="submit" value="Preview Message" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
		</form>
		</cfoutput>
	</cfif>
	<cfif #action# is "preview">
		<cfoutput>
		<cfif len(#address#) is 0>
			You must provide an email address.
			Use your back button.<cfabort>
		</cfif>
			From: savedSearch@#Application.fromEmail#<br>
			To: #address#<br>
			Subject: Arctos saved search: #SEARCH_NAME#<br>
			<p>
				#msg#<br>
				To view specimens, click the following link:<br>
				
				
				<a href="#Application.ServerRootUrl#/go.cfm?id=#canned_id#">#SEARCH_NAME#</a><br>
				or paste this address into your browser:<br>
				#Application.ServerRootUrl#/go.cfm?id=#canned_id#<br>
				-------------------------------------------------<br>
				<span style="font-size:small">
				This message was sent from #Application.ServerRootUrl# at the request of an Arctos user. Please report
				problems to #Application.PageProblemEmail#
				</span>
			</p>
			<p>
				<form name="m" method="post" action="mailSaveSearch.cfm">
					<input type="hidden" name="action" value="mail">
					<input type="hidden" name="canned_id" value="#canned_id#">
					<input type="hidden" name="SEARCH_NAME" value="#SEARCH_NAME#">
					<input type="hidden" name="msg" value="#msg#">
					<input type="hidden" name="address" value="#address#">
			
					<input type="submit" value="Send Message" class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
				</form>
			</p>
		</cfoutput>
	</cfif>
	<cfif #action# is "mail">
		<cfmail replyto="noreply@#Application.fromEmail#" 
			from="savedSearch@#Application.fromEmail#"
			to="#address#"
			subject="Arctos saved search: #SEARCH_NAME#" 
			type="html">
				#msg#<br>
				To view specimens, click the following link:<br>
				
				
				<a href="#Application.ServerRootUrl#/go.cfm?id=#canned_id#">#SEARCH_NAME#</a><br>
				or paste this address into your browser:<br>
				#Application.ServerRootUrl#/go.cfm?id=#canned_id#<br>
				-------------------------------------------------<br>
				<span style="font-size:small">
				This message was sent from #Application.ServerRootUrl# at the request of an Arctos user. Please report
				problems to #Application.PageProblemEmail#
				</span>
		</cfmail>
		<script>
			self.close();
		</script>
	</cfif>

