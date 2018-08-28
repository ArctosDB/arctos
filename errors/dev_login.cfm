
<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfheader statuscode="401" statustext="Not authorized">
This is a development server. You may log in or create an account
for testing purposes. You may not access this machine without logging in.
Data available from this machine are for testing purposes only and are not
valid specimen data.

<p>
<a href="/login.cfm">Log In</a>
</p>
<p>
	<a href="http://arctos.database.museum">Go to Arctos</a>
</p>

	<cfif not isdefined("application.version") or application.version is not "test">
		nope<cfabort>
	</cfif>

	<cfset f = CreateObject("component","component.utilities")>
	<cfset captcha = f.makeCaptchaString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" id="g" method="post" action="/errors/dev_login.cfm">
		<input type="hidden" name="action" value="crufl">
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
	    <label for="usr">Who do you want to be?</label><br>
        <input type="text" name="text" id="text" >
        <br>
	    <cfoutput>
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
	    </cfoutput>
		<br><input type="submit" value="log in as user">
	</cfform>


</cfoutput>

<cfif action is "crufl">
	<cfdump var=#form#>
</cfif>
<cfinclude template="/includes/_footer.cfm">