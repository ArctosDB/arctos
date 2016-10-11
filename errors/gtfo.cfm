
<cfif not isdefined("action") or action is not "p">
	<cfquery name="d" datasource="uam_god">
		insert into blacklisted_entry_attempt (ip) values ('#request.ipaddress#')
	</cfquery>
	<!---- if the subnet is hardblock, the IP range has been annoying enough for
		someone to click the button, but not annoying enough to
		firewall block. Check that
	---->
	<cfquery name="bsn" datasource="uam_god">
		select count(*) c from blacklist_subnet where SUBNET='#request.requestingsubnet#' and status='hardblock'
	</cfquery>
	<p>
		Your IP or organization has been blocked. You may wish to check your computer for malicious software and alert
		others who may have accessed Arctos from your IP or organization. Further intrusion attempts may result in more
		restrictive blocks.
	</p>
	<cfif bsn.c gt 0>
		<cfset isSubNetBlock=true>
		<p>
		  Your subnet has been blocked. The self-release option is not available. You must supply a message and an email address.
	   </p>
	<cfelse>
		<cfset isSubNetBlock=false>
		<p>
			You may use the form below to remove access restrictions. Please include a message if you have any information which
			might help up provide uninterrupted service.
		</p>
	</cfif>
	<p>
		Just reload this page for new CAPTCHA text.
	</p>
	<cfset f = CreateObject("component","component.utilities")>
	<cfset captcha = f.makeCaptchaString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" id="g" method="post" action="/errors/gtfo.cfm">
		<input type="hidden" name="action" value="p">
	    <cfimage
	    	action="captcha"
	    	width="300"
	    	height="50"
	    	text="#captcha#"
	    	overwrite="yes"
	    	difficulty="high"
	    	destination="#application.webdirectory#/download/captcha.png">

	    <img src="/download/captcha.png">
	   	<br>
	    <label for="captcha">Enter the text above (required)</label>
	    <input type="text" name="captcha" id="captcha" class="reqdClr">
	    <p></p>
	    <label for="c">Tell us how you got here</label><br>
        <textarea name="c" id="c" rows="6" cols="50"></textarea>
        <br>
        <label for="c">Your email</label><br>
        <input type="text" name="email" id="email" >
        <br>
	    <cfoutput>
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
        <input type="hidden" name="isSubNetBlock" value="#isSubNetBlock#">
	    </cfoutput>
		<br><input type="submit" value="go">
	</cfform>

	<cfif application.version is not "prod">
		<script>
			function autorelease(){
				var x=document.getElementById("captcha").value='<cfoutput>#captcha#</cfoutput>';
				document.getElementById("g").submit();
			}
		</script>
		<span class="likeLink" onclick="autorelease()">autorelease</span>
	</cfif>

</cfif>
<cfif isdefined("action") and action is "p">
	<cfoutput>
		<cfif hash(ucase(form.captcha)) neq form.captchaHash>
			You did not enter the correct text; use your back button.
			<cfabort>
		</cfif>
		<cfif isSubNetBlock is true and (len(email) is 0 or len(c) lt 20)>
		  <p>You are on a blocked subnet. You must supply an email address and a message of at least 20 characters.</p>
		  <cfabort>
		</cfif>
		<cfif len(email) is 0  and (len(c) gt 0 and len(c) lt 20)>
			If you want to leave us a note, we need at least 20 characters and an email address.
			<cfabort>
		</cfif>
		<cfif isSubNetBlock is false>
			<cfquery name="unbl" datasource="uam_god">
			  update uam.blacklist set status='released' where status='active' and ip = '#request.ipaddress#'
			</cfquery>
			<cfquery name="unbl" datasource="uam_god">
			  update uam.blacklist_subnet set status='released' where status in ('active','autoinsert') and SUBNET = '#request.requestingsubnet#'
			</cfquery>
			<cfset f = CreateObject("component","component.utilities")>
			<cfset f.setAppBL()>
			<cfmail subject="BlackList Removed" to="#Application.bugReportEmail#" from="blacklist@#application.fromEmail#" type="html">
				IP #request.ipaddress# has removed themselves from the blacklist.
				<p>
					email: #email#
				</p>
				<p>
					msg: #c#
				</p>
			</cfmail>
			<p>
			  Your IP has been removed from the blacklist. <a href="/">click here to continue</a>.
			</p>
		<cfelse>
			<cfmail subject="BlackList Objection" replyto="#email#" to="#Application.bugReportEmail#" from="blacklist@#application.fromEmail#" type="html">
				IP #request.ipaddress# ( #email# ) had this to say:
				<p>
					#c#
				</p>

				<p>
					If you are seeing this, the subnet has been hard-blocked.
					Hard-blocked subnets probably got that way for a reason; carefully check the arctos.database email account
					before taking action.
				</p>
				<p>
					If the request was legitimate and the blacklist should not
					exist, inform the Arctos development team.
				</p>
			</cfmail>
			<p>Your message has been delivered.</p>
		</cfif>
	</cfoutput>
</cfif>