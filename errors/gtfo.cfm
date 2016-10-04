<cfif not isdefined("request.ipaddress") or len(request.ipaddress) eq 0>
	<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
		<CFSET ipaddress=CGI.HTTP_X_Forwarded_For>
	<CFELSEif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
		<CFSET ipaddress=CGI.Remote_Addr>
	<cfelse>
		<cfset ipaddress='unknown'>
	</CFIF>
<cfelse>
	<cfset ipaddress=request.ipaddress>
</cfif>
<cfif not isdefined("action") or action is not "p">
	<cfquery name="d" datasource="uam_god">
		insert into blacklisted_entry_attempt (ip) values ('#ipaddress#')
	</cfquery>

	Oops. It looks like you are on our blacklist. That's probably because someone from your IP
	made a lame attempt to hack us, or possibly we were just feeling exceptionally paranoid when you
	tried to do something legit, so you ended up in our logs anyway. We get like that sometimes, and we'd
	like to apologize now if you are neither a robot nor a hacker.
	<p>Use the form below to remove yourself from the blacklist. Leave us a note if you have any problems or if this is a recurring event.</p>
	<p>Sometimes the text gets messed up, so just click reload if you can't read it.</p>


    <cfset isSubNetBlock=false>
	<cfif listlen(ipaddress,".") is 4>
        <cfset requestingSubnet=listgetat(ipaddress,1,".") & "." & listgetat(ipaddress,2,".")>
    <cfelse>
        <cfset requestingSubnet="0.0">
    </cfif>
    <cfif listfind(application.subnet_blacklist,requestingSubnet)>
		<cfset isSubNetBlock=true>
        <p>
		  Your subnet has been blocked. The self-serve option is not available. You must supply a message and an email address.
	   </p>
    </cfif>
	<cfset f = CreateObject("component","component.utilities")>
	<cfset captcha = f.makeCaptchaString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" method="post" action="/errors/gtfo.cfm">
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
</cfif>
<cfif isdefined("action") and action is "p">
	<cfoutput>


		<cfif hash(ucase(form.captcha)) neq form.captchaHash>
			You did not enter the right text.
			<cfabort>
		</cfif>

		<cfif len(email) is 0  and (len(c) gt 0 and len(c) lt 20)>
			If you want to leave us a note, we need at least 20 characters and an email address.
			<cfabort>
		</cfif>

		<cfif isSubNetBlock is true and (len(email) is 0 or len(c) lt 20)>
		  <p>You are on a blocked subnet. You must supply an email address and a message of at least 20 characters.</p>
		  <cfabort>
		</cfif>
		<cfif len(email) gt 0 and len(c) gt 0>
			<cfmail subject="BlackList Objection" replyto="#email#" to="#Application.bugReportEmail#" from="blacklist@#application.fromEmail#" type="html">
				IP #ipaddress# ( #email# ) had this to say:
				<p>
					#c#
				</p>
				<p>
				    isSubNetBlock: #isSubNetBlock#
				</p>
				<hr>
				<p>
					If this looks like a legitimate request, make sure you're logged in (you may get blacklisted if you aren't!), then
					<a href="#Application.serverRootUrl#/Admin/blacklist.cfm?action=del&ip=#ipaddress#">[ remove IP restrictions ]</a>.
				</p>
				<p>
					Check the arctos.database email account (search for the IP);
					there is probably an autoblacklist notification with a reason.
					Inform the user how to avoid the problem in the future. If the request was legitimate and the blacklist should not
					exist, inform the Arctos development team.
				</p>
					Subnet blocks must be removed via Arctos forms. Firewall blocks must be removed by network personnel.
				</p>
			</cfmail>
			<p>Your message has been delivered.</p>
		</cfif>
		<cfif isSubNetBlock is false>
			<cfquery name="unbl" datasource="uam_god">
			  update uam.blacklist set status='released' where status='active' and ip = '#ipaddress#'
			</cfquery>
			<cfset application.blacklist=listDeleteAt(application.blacklist,listFind(application.blacklist,#ipaddress#))>
			<cfmail subject="BlackList Removed" to="#Application.bugReportEmail#" from="blacklist@#application.fromEmail#" type="html">
			  IP #ipaddress# has removed themselves from the blacklist.
			</cfmail>

			<p>
			  Your IP has been successfully removed from the blacklist. <a href="/">click here to continue</a>.
			</p>
		</cfif>
	</cfoutput>
</cfif>