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
	<h2>Contact Arctos</h2>
	<ul>
		<li>
			Please use the "Report Bad Data" link where available to ensure the correct Curator receives your message.
		</li>
		<li>
			You may also
			<a href="https://github.com/ArctosDB/arctos/issues/new" target="_blank" class="external">file an Issue at GitHub</a>.
		</li>
	</ul>

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
				upper(username)='#ucase(session.username)#'
			</cfquery>
			<cfset eml=temail.email>
			<cfset v=captcha>
		</cfif>
		<cfinput type="text" id="email" name="email" size="60" value='#eml#' validate="email" required="true" class="reqdClr">
		<label for="msg">Your Message for us (20 characters minimum)</label>
		<cftextarea name="msg" id="msg" rows="10" cols="50" required="true" class="reqdClr"></cftextarea>
		<label for="captcha">Can't read the text? Reload to get a new CAPTCHA.</label>
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
		<cfset urlRegex = "(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'"".,<>?«»“”‘’]))">
		<cfset UrlCount = rematch(urlRegex,msg)>
		<cfif arraylen(urlcount) gt 0>
			Links are not allowed.<cfabort>
		</cfif>


		processing normal stuff....<cfabort>


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
		<!--- see if we can detect spam links --->

		<cfmail subject="Arctos Contact"
			replyto="#email#"
			to="#Application.bugReportEmail#"
			from="contact@#application.fromEmail#" type="html">
			Name: #name#
			<br>Email: #email#
			<br>Message: #msg#
			<cfif len(ref) gt 0>
				<br>Referring page: #ref#
			</cfif>
			<p>
				<cftry>
					<cfhttp url="freegeoip.net/json/#exception.ipaddress#" timeout="5"></cfhttp>
					<cfset x=DeserializeJSON(cfhttp.fileContent)>
					<cfset ipinfo=x.country_name & '; ' & x.region_name & '; ' & x.city>
				<cfcatch><cfset ipinfo='ip info lookup failed'></cfcatch>
				</cftry>
				<br>
				ipinfo:#ipinfo#
				<br>
				<cfif isdefined("request.ipaddress")>
					<a href="http://whatismyipaddress.com/ip/#request.ipaddress#">[ lookup #request.ipaddress# @whatismyipaddress ]</a>
					<br><a href="https://www.ipalyzer.com/#request.ipaddress#">[ lookup #request.ipaddress# @ipalyzer ]</a>
					<br><a href="https://gwhois.org/#request.ipaddress#">[ lookup #request.ipaddress# @gwhois ]</a>
					<p>
						<br><a href="#Application.serverRootURL#/Admin/blacklist.cfm?ipstartswith=#request.ipaddress#">[ manage IP and subnet restrictions ]</a>
					</p>
				</cfif>
			</p>
		</cfmail>
		Thanks for contacting us. Your message has been delivered.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">