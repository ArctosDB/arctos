<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfset title="Contact Us">
<cfoutput>
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	
	<cfform action="contact.cfm" method="post" name="contact">
		<label for="name">Your Name</label>
		<input type="text" id="name" name="name" size="60" value="#session.username#">
		<label for="email">Your Email</label>
		<cfinput type="text" id="email" name="email" size="60" validate="email">
		<label for="msg">Message</label>
		<textarea name="msg" id="msg" rows="10" cols="50"></textarea>
		<br>
	    <cfimage action="captcha" width="300" height="50" text="#captcha#">
	   	<br>
		<label for="captcha">Enter the text above</label>
	    <input type="text" name="captcha" id="captcha">
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
	    <br><input type="submit" value="Send Message">
	</cfform>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">