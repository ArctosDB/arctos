<cfinclude template="/includes/_header.cfm">
<cffunction name="makeRandomString" returnType="string" output="false">
    <cfset var chars = "23456789ABCDEFGHJKMNPQRS">
    <cfset var length = randRange(4,7)>
    <cfset var result = "">
    <cfset var i = "">
    <cfset var char = "">
    <cfscript>
    for(i=1; i <= length; i++) {
        char = mid(chars, randRange(1, len(chars)),1);
        result&=char;
    }
    </cfscript>
    <cfreturn result>
</cffunction>
<cfif not isdefined("ref")>
	<cfset ref="">
</cfif>
<cfif action is "nothing">
	<cfset title="Contact Us">
<cfoutput>
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	<h2>Contact the Arctos folks</h2>
	<p>Data problems? Use a "report bad data" link if there's one available.</p>
	<cfform action="contact.cfm" method="post" name="contact">
		<input type="hidden" name="action" value="sendMail">
		<input type="hidden" name="ref" value="#ref#">
		<label for="name">Your Name or Arctos username (required)</label>
		<cfinput type="text" id="name" name="name" size="60" value="#session.username#" required="true" class="reqdClr">
		<label for="email">Your Email Address (required - we'll never share it)</label>
		<cfset eml=''>
		<cfset v="">
		<cfif len(session.username) gt 0>
			<cfquery name='temail' datasource="cf_dbuser">
				select email from cf_users,cf_user_data where
				cf_users.user_id=cf_user_data.user_id and
				username='#session.username#'
			</cfquery>
			<cfset eml=temail.email>
			<cfset v=captcha>
		</cfif>
		<cfinput type="text" id="email" name="email" size="60" value='#eml#' validate="email" required="true" class="reqdClr">
		<label for="msg">Your Message for us (20 characters minimum)</label>
		<cftextarea name="msg" id="msg" rows="10" cols="50" required="true" class="reqdClr"></cftextarea>
		<label for="captcha">Can't read the text? Just reload to get a new CAPTCHA.</label>
		<cfimage action="captcha" width="300" height="50" text="#captcha#" difficulty="low"
		    	overwrite="yes"
		    	destination="#application.webdirectory#/download/captcha.png">
		<img src="/download/captcha.png">
		<br>
		<label for="captcha">Enter the text above. Case doesn't matter. (required)</label>
	    <cfinput type="text" name="captcha" id="captcha" value="#v#" class="reqdClr" size="60">
	    <cfinput type="hidden" name="captchaHash" value="#captchaHash#">
	    <br><cfinput name="s" type="submit" value="Send Message" class="savBtn">
	</cfform>
</cfoutput>
</cfif>
<cfif action is "sendMail">
	<cfoutput>
		<cfif hash(ucase(form.captcha)) neq form.captchaHash>
			You did not enter the right text. Please use your back button.
			<cfabort>
		</cfif>
		<cfif len(msg) lt 20>
			A message of at least 20 characters is required to proceed. Please use your back button.
			<cfabort>
		</cfif>
		<cfif len(name) eq 0>
			A name is required to proceed. Please use your back button.
			<cfabort>
		</cfif>
		<cfmail subject="Arctos Contact"
			replyto="#email#"
			to="#Application.technicalEmail#"
			from="contact@#application.fromEmail#" type="html">
			Name: #name#
			<br>Email: #email#
			<br>Message: #msg#
			<cfif len(ref) gt 0>
				<br>Referring page: #ref#
			</cfif>
		</cfmail>
		Thanks for contacting us. Your message has been delivered.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">