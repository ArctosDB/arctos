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

<cfif action is "nothing">
	<cfset title="Contact Us">
<cfoutput>
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	
	<cfform action="contact.cfm" method="post" name="contact">
		<input type="text" name="action" value="sendMail">
		<label for="name">Your Name</label>
		<cfinput type="text" id="name" name="name" size="60" value="#session.username#" required="true" class="reqdClr">
		<label for="email">Your Email</label>
		<cfinput type="text" id="email" name="email" size="60" validate="email" required="true" class="reqdClr">
		<label for="msg">Message</label>
		<cftextarea name="msg" id="msg" rows="10" cols="50" required="true" class="reqdClr"></cftextarea>
		<br>
	    <cfimage action="captcha" width="300" height="50" text="#captcha#">
	   	<br>
		<label for="captcha">Enter the text above</label>
	    <cfinput type="text" name="captcha" id="captcha">
	    <cfinput type="hidden" name="captchaHash" value="#captchaHash#">
	    <br><cfinput name="s" type="submit" value="Send Message" class="savBtn">
	</cfform>
</cfoutput>
</cfif>
<cfif action is "sendMail">
	<cfoutput>
		<cfif hash((form.captcha)) neq form.captchaHash>
			You did not enter the right text.
			<cfabort>
		</cfif>
		<cfif len(c) lt 20>
			A message of at least 20 characters is required to proceed.
			<cfabort>
		</cfif>
		<cfmail subject="Arctos Contact" to="#Application.technicalEmail#" from="contact@#application.fromEmail#" type="html">
			Name: #name#
			<br>Email: #email#
			<br>Message: #msg#
		</cfmail>
		Your message has been delivered.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">