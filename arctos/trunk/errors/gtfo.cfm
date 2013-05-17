<cffunction name="makeRandomString" returnType="string" output="false">
    <cfscript>
		var chars = "23456789ABCDEFGHJKMNPQRS";
		var length = randRange(4,7);
		var result = "";
	    for(i=1; i <= length; i++) {
	        char = mid(chars, randRange(1, len(chars)),1);
	        result&=char;
	    }
	    return result;
    </cfscript>
</cffunction>
<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
	<CFSET ipaddress=CGI.HTTP_X_Forwarded_For>
<CFELSEif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
	<CFSET ipaddress=CGI.Remote_Addr>
<cfelse>
	<cfset ipaddress='unknown'>
</CFIF>

<cfif not isdefined("action") or action is not "p">
	<cfquery name="d" datasource="uam_god">
		insert into blacklisted_entry_attempt (ip) values ('#ipaddress#')
	</cfquery>

	Oops. It looks like you are on our blacklist. That's probably because someone from your IP
	made a lame attempt to hack us, or possibly we were just feeling exceptionally paranoid when you
	tried to do something legit, so you ended up in our logs anyway. We get like that sometimes, and we'd
	like to apologize now if you are neither a robot nor a hacker.
	<p>Use the form below to convince us that you
	are a non-malicious carbon-based life form and we'll happily restore your access.</p>
	<p>Sometimes the text gets messed up, so just click reload if you can't read it.</p>
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" method="post" action="/errors/gtfo.cfm">
		<input type="hidden" name="action" value="p">
		<label for="c">Your request (min 20 characters)</label><br>
		<textarea name="c" id="c" rows="6" cols="50" class="reqdClr"></textarea>
		<br>
		<label for="c">Your email</label><br>
		<input type="text" name="email" id="email" class="reqdClr">
		<br>
	    <cfimage
	    	action="captcha"
	    	width="300"
	    	height="50"
	    	text="#captcha#"
	    	overwrite="yes"
	    	destination="#application.webdirectory#/temp/captcha.png">

	    <img src="/temp/captcha.png">
	   	<br>
	    <label for="captcha">Enter the text above</label>
	    <input type="text" name="captcha" id="captcha" class="reqdClr">
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
		<cfif len(c) lt 20>
			You need to explain how you got here.
			<cfabort>
		</cfif>
		<cfif len(email) is 0>
			Email is required.
			<cfabort>
		</cfif>
		

		<cfmail subject="BlackList Objection" replyto="#email#" to="#Application.PageProblemEmail#" from="blacklist@#application.fromEmail#" type="html">
			IP #ipaddress# ( #email# ) had this to say:
			<p>
				#c#
			</p>
		</cfmail>
		Your message has been delivered.
	</cfoutput>
</cfif>