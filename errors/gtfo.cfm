<cfdump var=#cgi#>
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
<cfif not isdefined("action") or action is not "p">
	Oops. Looks like you are on our blacklist. If this is in error, please tell us why.
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" method="post" action="gtfo.cfm">
		<input type="hidden" name="action" value="p">
		<label for="c">Explain yourself</label>
		<textarea name="c" id="c" rows="6" cols="50"></textarea>
		<br>
	    <cfimage action="captcha" width="300" height="75" text="#captcha#">
	   	<br>
	    <label for="captcha">Enter the text above</label>
	    <input type="text" name="captcha" id="captcha">
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
		<br><input type="submit" value="go">
	</cfform>
</cfif>

<cfif isdefined("action") and action is "p">
	<cfif hash(ucase(form.captcha)) neq form.captchaHash>
	    <cfset errors = errors & "You did not enter the right text.">
		<cfabort>
	</cfif>
	<cfoutput>
	<cfmail subject="BlackList Objection" to="dustymc@gmail.com" from="blacklist@#application.fromEmail#" type="html">
		#Application.PageProblemEmail#
		IP #cgi.REMOTE_ADDR# had this to say:
		
		---#c#---
	</cfmail>
	Your message has been delivered.
	</cfoutput>
</cfif>