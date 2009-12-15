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
	Oops. Looks like you are on our blacklist. That's probably because someone from your IP 
	made a lame attempt to hack us, or possibly we were just feeling exceptionally paranoid when you 
	tried to do something legit, but ended up in our logs anyway. We get like that sometimes, and we'd
	like to apologize now if you are neither a robot nor a hacker.
	Use the form below to convince us that you 
	are a non-malicious carbon-based life form and we'll happily restore your access.
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" method="post" action="/errors/gtfo.cfm">
		<input type="hidden" name="action" value="p">
		<label for="c">Explain yourself</label>
		<textarea name="c" id="c" rows="6" cols="50"></textarea>
		<br>
	    <cfimage action="captcha" width="300" height="50" text="#captcha#">
	   	<br>
	    <label for="captcha">Enter the text above</label>
	    <input type="text" name="captcha" id="captcha">
	    <cfoutput>
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
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
	
		<cfmail subject="BlackList Objection" to="#Application.PageProblemEmail#" from="blacklist@#application.fromEmail#" type="html">
			IP #cgi.REMOTE_ADDR# had this to say:
			<p>
				#c#
			</p>
		</cfmail>
		Your message has been delivered.
	</cfoutput>
</cfif>