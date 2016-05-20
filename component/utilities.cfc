<cfcomponent>
<!------------------>
<cffunction name="loadFile" output="false" returnType="string" access="remote">
	<cftry>
		<cfset tempName=createUUID()>
		<cfset loadPath = "#Application.webDirectory#/mediaUploads/#session.username#">
		<cftry>
			<cfdirectory action="create" directory="#loadPath#" mode="775">
			<cfcatch>
	    		<!--- it already exists, do nothing--->
			</cfcatch>
		</cftry>
		<cffile action="upload"	destination="#Application.sandbox#/" nameConflict="overwrite" fileField="file" mode="600">
		<cfset fileName=cffile.serverfile>
		<cffile action = "rename" destination="#Application.sandbox#/#tempName#.tmp" source="#Application.sandbox#/#fileName#">
		<cfset fext=listlast(fileName,".")>
		<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
		<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
		<cfset fName=replace(fName,'__','_','all')>
		<cfset fileName=fName & '.' & fext>
		<cffile action="move" source="#Application.sandbox#/#tempName#.tmp" destination="#loadPath#/#fileName#" nameConflict="error" mode="644">
		<cfset media_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/#fileName#">
		<cfif IsImageFile("#loadPath#/#fileName#")>
			<cfset tnAbsPath=loadPath & '/tn_' & fileName>
			<cfset tnRelPath=replace(loadPath,application.webDirectory,'') & '/tn_' & fileName>
			<cfimage action="info" structname="imagetemp" source="#loadPath#/#fileName#">
			<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
	      	<cfset newheight = x*imagetemp.height>
	   		<cfimage action="resize" source="#loadPath#/#fileName#" width="#newwidth#" height="#newheight#"
				destination="#tnAbsPath#" overwrite="false">
			<cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
			<cfset r.preview_uri="#preview_uri#">
		<cfelse>
			<cfset r.preview_uri="">
		</cfif>
	    <cfset r.statusCode=200>
		<cfset r.filename="#fileName#">
		<cfset r.media_uri="#media_uri#">
		<cfcatch>
			<cftry>
				<cfset r.statusCode=400>
				<cfif cfcatch.message contains "already exists">
					<cfset umpth=#ucase(session.username)# & "/" & #ucase(fileName)#>
					<cfquery name="fexist" datasource="uam_god">
						select media_id from media where upper(media_uri) like '%#umpth#'
					</cfquery>
					<cfset midl=valuelist(fexist.media_id)>
					<cfset msg="The file \n\n#Application.serverRootURL#/mediaUploads/#session.username#/#fileName#\n\n">
					<cfset msg=msg & "already exists">
					<cfif len(midl) gt 0>
						<cfset msg=msg & " and may be used by \n\n#Application.ServerRootURL#/media/#midl#\n\nCheck the media_URL above.">
						<cfset msg=msg & " Link to the media using the media_id (#midl#) in the form below.">
					<cfelse>
						<cfset msg=msg & " and does not seem to be used for existing Media. Create media with the already-loaded file by">
						<cfset msg=msg & " pasting the above media_uri into ">
						<cfset msg=msg & "\n\n#Application.serverRootURL#/media.cfm?action=newMedia">
						<cfset msg=msg & "\n\nA preview may exist at ">
						<cfset msg=msg & "\n\n#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
					</cfif>
					<cfset msg=msg & "\n\nRe-name and re-load the file ONLY if you are sure it does not exist on the sever.">
					<cfset msg=msg & " Do not create duplicates.">
				<cfelse>
					<cfset msg=cfcatch.message & '; ' & cfcatch.detail>
				</cfif>
				<cfset r.msg=msg>
			<cfcatch>
				<cfset r.statusCode=400>
				<cfset r.msg=cfcatch.message & '; ' & cfcatch.detail>
			</cfcatch>
			</cftry>
		</cfcatch>
	</cftry>
	<cfreturn serializeJSON(r)>
</cffunction>
<!------------------>
<cffunction name="exitLink" access="remote">
	<cfargument name="target" required="yes">
	<!----
		This is called with the ?open parameter on media exit links

		One point of failure is enough; don't check anything once we lose the "spiffy" code
			(which is replaced with something more appropriate before return)

		Purpose:
			- ensure that the request looks like a URL (not a limitation, but we have nothing else
				at the moment and having anything else seems unlikely, so check)
			- ensure that the reqeust is for something in our Media table (avoid spambots etc)
			- check for a timely response
	---->
	<cfoutput>
	<cfset result=StructNew()>
	<cfset result.status='spiffy'>
	<!---- ensure that the request looks like a URL  ---->
	<cfif left(target,4) is not "http">
		<cfset result.status='error'>
		<cfset result.code='400'>
		<cfset result.msg='Invalid Format: the target does not seem to be a valid URL.'>
		<cfset http_target=URLDecode(target)>
	<cfelse>
		<!---- eventually we may want to guess at fixing errors etc, so local URL time ---->
		<cfset http_target=URLDecode(target)>
	</cfif>
	<cfset result.http_target=http_target>
	<!---- ensure that the reqeust is for something in our Media table ---->
	<cfif result.status is "spiffy">
		<cfquery name="isus"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from media where upper(trim(media_uri))='#ucase(trim(http_target))#'
		</cfquery>
		<cfif isus.c neq 1>
			<cfset result.status='error'>
			<cfset result.code='404'>
			<cfset result.msg='The Media does not exist at the URL you requested.'>
		</cfif>
	</cfif>
	<cfif result.status is "spiffy">
		<!---- check for a timely response ---->
		<cfhttp url="#http_target#" method="head" timeout="3"></cfhttp>
		<!---- yay ---->
		<cfif isdefined("cfhttp.statuscode") and left(cfhttp.statuscode,3) is "200">
			<cfset result.status='success'>
			<cfset result.code=200>
			<cfset result.msg='yay everybody!'>
		</cfif>
		<cfif result.status is not 'success'>
			<!---- no response; timed out ---->
			<cfif not isdefined("cfhttp.statuscode")>
				<cfset result.status='timeout'>
				<cfset result.code=408>
				<cfset result.msg='The Media server is not responding in a timely manner. This may be caused by a temporary interruption'>
				<cfset result.msg=result.msg & ", server configuration, or resource abandonment.">
			</cfif>
			<!--- response, but not 200 ---->
			<cfif isdefined("cfhttp.statuscode") and isnumeric(left(cfhttp.statuscode,3)) and left(cfhttp.statuscode,3) is not "200">
				<cfset result.status='error'>
				<cfset result.code=left(cfhttp.statuscode,3)>
				<cfif left(cfhttp.statuscode,3) is "405">
					<cfset result.msg='The server hosting the link refused our request method.'>
				<cfelseif left(cfhttp.statuscode,3) is "408">
					<cfset result.msg='The server hosting the link may be slow or nonresponsive.'>
				<cfelseif  left(cfhttp.statuscode,3) is "404">
					<cfset result.msg='The external resource does not appear to exist.'>
				<cfelseif left(cfhttp.statuscode,3) is "500">
					<cfset result.msg='The server may be down or misconfigured.'>
				<cfelseif left(cfhttp.statuscode,3) is "503">
					<cfset result.msg='The server is currently unavailable; this is generally temporary.'>
				<cfelse>
					<cfset result.msg='An unknown error occurred'>
				</cfif>
			</cfif>
			<cfif isdefined("cfhttp.statuscode") and not isnumeric(left(cfhttp.statuscode,3))>
				<cfset result.status='failure'>
				<cfset result.code=500>
				<cfset result.msg='The resource is not responding correctly, and may be misconfigured or missing.'>
			</cfif>
		</cfif>
	</cfif>
	<!--- all checked, log the request ---->
	<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into exit_link (
			username,
			ipaddress,
			from_page,
			target,
			http_target,
			when_date,
			status
		) values (
			'#session.username#',
			'#request.ipaddress#',
			'#cgi.HTTP_REFERER#',
			'#target#',
			'#http_target#',
			sysdate,
			'#result.status#'
		)
	</cfquery>
	<!--- and return the results ---->
	<cfreturn result>
</cfoutput>
</cffunction>
<!---------------------------------------------------------->
<cffunction name="isValidMediaUpload">
	<cfargument name="fileName" required="yes">
	<cfset err="">
	<cfset extension=listlast(fileName,".")>
	<cfset acceptExtensions="jpg,jpeg,gif,png,pdf,txt,m4v,mp3,wav,wkt">
	<cfif listfindnocase(acceptExtensions,extension) is 0>
		<cfset err="An valid file name extension (#acceptExtensions#) is required. extension=#extension#">
	</cfif>
	<cfset name=replace(fileName,".#extension#","")>
	<cfif REFind("[^A-Za-z0-9_-]",name,1) gt 0>
		<cfset err="Filenames may contain only letters, numbers, dash, and underscore.">
	</cfif>
	<cfreturn err>
</cffunction>
<!----------------------->
<cffunction name="mdflip" output="false" returnType="string" access="remote">
    <!--- translate mobile URLs to desktop and vice-versa --->
    <cfargument name="q" type="string" required="true" />
	<cfif q contains Application.mobileURL>
	   <cfset r=replace(q,Application.mobileURL,'/')>
	<cfelse>
	   <cfset r=Application.mobileURL & "/" & q>
	</cfif>
    <cfset r=replace(r,'//','/','all')>
    <cfset r=replace(r,'//','/','all')>
	<cfreturn r>
</cffunction>
<!------------------>
<cffunction name="isMobileClient" output="true" returnType="boolean" access="remote">
    <cfif reFindNoCase("(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino",CGI.HTTP_USER_AGENT) GT 0 OR
                reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-",Left(CGI.HTTP_USER_AGENT,4)) GT 0>
        <cfreturn true>
	<cfelse>
	   <cfreturn false>
    </cfif>
</cffunction>
<cffunction name="isMobileTemplate" output="true" returnType="boolean" access="remote">
	<cfset thisFolder=listgetat(request.rdurl,1,"/")>
	<cfif thisFolder is replace(Application.mobileURL,"/","","all")>
	   <cfreturn true>
	<cfelse>
	   <cfreturn false>
	</cfif>
</cffunction>
<!------------------------------------------------------->
<cffunction name="mobileDesktopRedirect" output="true" returnType="string" access="remote">
	<!----
		<br>START mobileDesktopRedirect
		<br>cgi.script_name: #cgi.script_name#
		This function redirects between mobile and desktop based on device detection scripts from
		http://detectmobilebrowsers.com/
		cookies and current page.
		Rules:
		IF no cookie AND is mobile device --- > redirect to mobile
		It's called at onRequestStart in Application.cfc
	---->
	<cfoutput>
		<!---- only redirect if they're coming in to something for which we have a mobile page ---->
		<cfif cgi.script_name is "/dm.cfm">
		  <cfreturn>
		</cfif>
		<cfif isdefined("request.rdurl") and (
			request.rdurl contains "/guid/" or
			request.rdurl contains "/name/" or
			replace(cgi.script_name,"/","","all") is "SpecimenSearch.cfm" or
			replace(cgi.script_name,"/","","all") is "taxonomy.cfm" or
			replace(cgi.script_name,"/","","all") is "SpecimenResults.cfm")>
			<!--- check to see if they have set a cookie ---->
			<cfif IsDefined("Cookie.dorm")>
				<!--- they have an explicit preference and we have a mobile option, send them where they want to be ---->
				<cfif cookie.dorm is "mobile" and isMobileTemplate() is false>
					<!---- DEVICE: untested; CURRENT SITE: desktop; DESIRED SITE: mobile; ACTION: redirect ---->
					<cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
					<cflocation url="#z#" addtoken="false">
				<cfelseif cookie.dorm is not "mobile" and isMobileTemplate() IS TRUE>
					<!---- DEVICE: untested; CURRENT SITE: mobile; DESIRED SITE: desktop; ACTION: redirect ---->
					<cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
					<cflocation url="#z#" addtoken="false">
				</cfif>
			<cfelse>
				<!----
					We have a mobile option and they've expressed no preferences.
					If they're on a mobile device and NOT a mobile page, redirect them - they're a first-time user
					---->
				<cfif isMobileClient() is true and isMobileTemplate() is false>
	                <!--- see if they're on a mobile device but not a mobile page ---->
				     <cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
	                <cflocation url="#z#" addtoken="false">
				</cfif>
			</cfif>
	    </cfif>
	</cfoutput>
	<cfreturn>
</cffunction>


<!---------------------------------------------->
<cffunction name="listCommon" output="false" returnType="string" access="remote">
   <cfargument name="list1" type="string" required="true" />
   <cfargument name="list2" type="string" required="true" />
   <cfset var list1Array = ListToArray(arguments.List1) />
   <cfset var list2Array = ListToArray(arguments.List2) />
   <cfset list1Array.retainAll(list2Array) />
   <!--- Return in list format --->
   <cfreturn ArrayToList(list1Array) />
</cffunction>
<!------------------>

<cffunction name="makeCaptchaString" returnType="string" output="false">
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
<!------------------------------------------------------------------------------------>
<cffunction name="getIpAddress">
	<!--- grab everything that might be a real IP ---->
	<CFSET ipaddress="">
	<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
		<CFSET ipaddress=listappend(ipaddress,CGI.HTTP_X_Forwarded_For,",")>
	</cfif>
	<CFif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
		<!--- we'll ultimately grab the last if we can't pick one and this is usually better than x_fwd so append last ---->
		<CFSET ipaddress=listappend(ipaddress,CGI.Remote_Addr,",")>
	</cfif>
	<!--- keep the raw/everything, it's useful ---->
	<cfset request.rawipaddress=ipaddress>
	<cfif listfind(ipaddress,'129.114.52.171')>
		<cfset ipaddress=listdeleteat(ipaddress,listfind(ipaddress,'129.114.52.171'))>
	</cfif>
	<!--- loop through the possibilities, keep only things that look like an IP ---->
	<cfset vips="">
	<cfloop list="#ipaddress#" delimiters="," index="tip">
		<cfset x=trim(tip)>
		<cfif listlen(x,".") eq 4 and
			isnumeric(replace(x,".","","all")) and
			refind("(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)",x) eq 0 and
			refind("^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$",x) eq 1
		>
			<cfset vips=listappend(vips,x,",")>
		</cfif>
	</cfloop>
	<cfif len(vips) gt 0>
		<!---- grab the last one, because why not....---->
		<cfset ipaddress=listlast(vips)>
	<cfelse>
		<!---- or something that looks vaguely like an IP to make other things slightly more predictable ---->
		<cfset ipaddress="0.0.0.0">
	</cfif>
	<cfset requestingSubnet=listgetat(ipaddress,1,".") & "." & listgetat(ipaddress,2,".")>
	<cfset request.ipaddress=ipaddress>
	<cfset request.requestingSubnet=requestingSubnet>
</cffunction>
<!------------------------------------------------------------------------------------>
<cffunction name="checkRequest">
	<cfargument name="inp" type="any" required="false"/>
	<cfif session.roles contains "coldfusion_user">
       <!---- never blacklist "us" ---->
       <cfreturn true>
    </cfif>
	<!---


rdurl: /includes/"+("/picks/findAgentModal.cfm&agentIdFld=%22+b+%22&agentNameFld=%22+d+%22&name=%22+(%22undefined%22!=typeof%20e?e:%22%22))+%22


rdurl: /home.cfm'A=0

rdurl: /includes/forms/manyCatItemToMedia.cfm?media_id='+b+'

		first check if they're already blacklisted
		If they are, just include the notification/form and abort
	---->
	<cfif listfind(application.subnet_blacklist,request.requestingSubnet)>
		<cfif replace(cgi.script_name,'//','/','all') is not "/errors/gtfo.cfm">
			<cfscript>
				getPageContext().forward("/errors/gtfo.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
	<cfif listfind(application.blacklist,request.ipaddress)>
		<cfif replace(cgi.script_name,'//','/','all') is not "/errors/gtfo.cfm">
			<cfscript>
				getPageContext().forward("/errors/gtfo.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
	<!---
		if they made it here, they are
			1) not "us"
			2) not on the blacklist
		See if it's a legit request. If so do nothing, otherwise call autoblacklist and abort.
	---->
	<cfif isdefined("request.rdurl")>
		<cfset lurl=request.rdurl>
	<cfelse>
		<cfset lurl="">
	</cfif>
	<!--- now replace all potential delimiters with chr(7), so we can predictable loop ---->
	<cfset lurl=replace(lurl,",",chr(7),"all")>
	<cfset lurl=replace(lurl,".",chr(7),"all")>
	<cfset lurl=replace(lurl,"/",chr(7),"all")>
	<cfset lurl=replace(lurl,"&",chr(7),"all")>
	<cfset lurl=replace(lurl,"+",chr(7),"all")>
	<cfset lurl=replace(lurl,"(",chr(7),"all")>
	<cfset lurl=replace(lurl,")",chr(7),"all")>
	<cfset lurl=replace(lurl,"%20",chr(7),"all")>
	<cfset lurl=replace(lurl,"%27",chr(7),"all")>
	<cfset lurl=replace(lurl,";",chr(7),"all")>
	<cfset lurl=replace(lurl,"?",chr(7),"all")>
	<cfset lurl=replace(lurl,"=",chr(7),"all")>
	<cfset lurl=replace(lurl,"%2B",chr(7),"all")>
	<cfset lurl=replace(lurl,"%28",chr(7),"all")>
	<cfset lurl=replace(lurl,"%22",chr(7),"all")>
	<cfset lurl=replace(lurl,"%3E",chr(7),"all")>


	<!-----
		START: stuff in this block is always checked; this is called at onRequestStart
		Performance is important here; keep it clean and minimal
	 ------>
	 <!---
	 	these seem to be malicious 99% of the time, but legit traffic often enough that blacklisting them
	 	isn't a great idea, so just ignore
	 ----->
	 <cfif isdefined("cgi.HTTP_ACCEPT_ENCODING") and cgi.HTTP_ACCEPT_ENCODING is "identity">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.REQUEST_METHOD") and cgi.REQUEST_METHOD is "OPTIONS">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.query_string")>
		<!--- this stuff is never allowed, ever ---->
		<cfset nono="passwd,proc">
		<cfloop list="#cgi.query_string#" delimiters="./," index="i">
			<cfif listfindnocase(nono,i)>
				<cfset bl_reason='#i# in query_string'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("cgi.blog_name") and len(cgi.blog_name) gt 0>
		<cfset bl_reason='cgi.blog_name exists'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.HTTP_REFERER") and cgi.HTTP_REFERER contains "/bash">
		<cfset bl_reason='HTTP_REFERER contains /bash'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!--- these are user-agents that regularly ignore the robots.txt file --->
	<cfset badbot="Baiduspider,bash">
	<cfset badbot=badbot & ",ca-crawler,CCBot">
	<cfset badbot=badbot & ",Domain,DeuSu">
	<cfset badbot=badbot & ",Gluten">
	<cfset badbot=badbot & ",HubSpot">
	<cfset badbot=badbot & ",MegaIndex,MJ12bot">
	<cfset badbot=badbot & ",naver,Nutch">
	<cfset badbot=badbot & ",re-animator">
	<cfset badbot=badbot & ",Qwantify">
	<cfset badbot=badbot & ",SemrushBot,spbot,Synapse,Sogou,SiteExplorer">
	<cfset badbot=badbot & ",TweetmemeBot">
	<cfset badbot=badbot & ",UnisterBot">
	<cfset badbot=badbot & ",Wotbox">
	<cfset badbot=badbot & ",YandexBot,Yeti">
	<cfif isdefined("cgi.HTTP_USER_AGENT")>
		<cfloop list="#badbot#" index="b">
			<cfif cgi.HTTP_USER_AGENT contains b>
				<cfset bl_reason='HTTP_USER_AGENT is blocked crawler #b#'>
				<cfinclude template="/errors/autoblacklist.cfm">

				<cfabort>
			</cfif>
		</cfloop>
	</cfif>

	<!----
		is blacklisting with http://arctos.database.museum/guid/UAM:EH:0301-0001 so turn off for now
	<cfif right(lurl,5) is "-1#chr(7)#">
		<cfset bl_reason='URL ends with -1%27'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	---->
	<cfif right(lurl,3) is "%00">
		<cfset bl_reason='URL ends with %00'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdurl") and left(request.rdurl,6) is "/��#chr(166)#m&">
		<cfset bl_reason='URL starts with /��#chr(166)#m&'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdurl") and request.rdurl contains "%27A=0">
		<cfset bl_reason="URL contains %27A=0">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdurl") and request.rdurl contains "'A=0">
		<cfset bl_reason="URL contains 'A=0">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!--- check these every time, even if there's no error; these things are NEVER allowed in a URL ---->
	<cfset x="script,write">
	<cfloop list="#lurl#" delimiters="#chr(7)#" index="i">
		<cfif listfindnocase(x,i)>
			<cfset bl_reason='URL contains #i#'>
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
	</cfloop>

	<!----- END: stuff in this block is always checked; this is called at onRequestStart ------>
	<!-----
		START: stuff in this block is only checked if there's an error
		Performance is unimportant here; this is going to end with an error
	 ------>



	<cfif isdefined("inp")>
		<cfif len(lurl) gt 0>
		<!----
			<cfif lurl contains "utl_inaddr" or lurl contains "get_host_address">
				<cfset bl_reason='URL contains utl_inaddr or get_host_address'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfif request.rdurl contains "#chr(96)##chr(195)##chr(136)##chr(197)#">
				<cfset bl_reason='URL contains #chr(96)##chr(195)##chr(136)##chr(197)#'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>

			_----->
			<!---- random junk that in combination with an error is always indicitive of bot/spam/probe/etc. traffic---->
			<cfset x="">
			<cfset x=x & ",@@version,#chr(96)##chr(195)##chr(136)##chr(197)#,'A=0">
			<cfset x=x & ",1phpmyadmin,2phpmyadmin,3phpmyadmin,4phpmyadmin">
			<cfset x=x & ",account,administrator,admin-console,attr(,asmx,abstractapp,adimages,asp,aspx,awstats,appConf,announce">
			<cfset x=x & ",backup,backend,blog,board,backup-db,backup-scheduler,batch">
			<cfset x=x & ",char,chr,ctxsys,CHANGELOG,content,cms,checkupdate,colorpicker,comment,comments,connectors,cgi,cgi-bin,cgi-sys">
			<cfset x=x & ",calendar,config,client,cube,cursor,COLUMN_NAME,CHECKSUM,CHARACTER_MAXIMUM_LENGTH,create">
			<cfset x=x & ",drithsx,Dashboard,dbg,dbadmin,declare,DB_NAME,databases,displayAbstract">
			<cfset x=x & ",etc,environ,exe,editor,ehcp,employee">
			<cfset x=x & ",fulltext,feed,feeds,filemanager,fckeditor,FileZilla,fetch,FETCH_STATUS">
			<cfset x=x & ",getmappingxpath,get_host_address">
			<cfset x=x & ",html(,HNAP1,htdocs,horde,HovercardLauncher,HelloWorld,has_dbaccess">
			<cfset x=x & ",inurl,invoker,ini,into,INFORMATION_SCHEMA,iefixes">
			<cfset x=x & ",jbossws,jbossmq-httpil,jspa,jiraHNAP1,jsp,jmx-console,journals,JBoss,jira,jkstatus">
			<cfset x=x & ",lib,lightbox,local-bin,LoginForm">
			<cfset x=x & ",master,mpx,mysql,mysql2,mydbs,manager,myadmin,muieblackcat,mail,magento_version,manifests">
			<cfset x=x & ",news,nyet">
			<cfset x=x & ",ord_dicom,ordsys,owssvr,ol">
			<cfset x=x & ",php,phppath,phpMyAdmin,PHPADMIN,phpldapadmin,phpMyAdminLive,_phpMyAdminLive,printenv,proc,plugins,passwd,pma2,pma4,php5">
			<cfset x=x & ",pma,phppgadmin,prescription">
			<cfset x=x & ",rand,reviews,rutorrent,rss,roundcubemail,roundcube,README,railo-context,railo,Rapid7">
			<cfset x=x & ",sys,swf,server-status,stories,setup,sign_up,system,signup,scripts,sqladm,soapCaller,simple-backup,sedlex,sysindexes,sysobjects">
			<cfset x=x & ",servlet,spiffymcgee,server-info,sparql,sysobjects">
			<cfset x=x & ",trackback,TABLE_NAME">
			<cfset x=x & "utl_inaddr,uploadify,userfiles,updates,update,UserFollowResource">
			<cfset x=x & ",verify-tldnotify,version,varien,viagra">
			<cfset x=x & ",wiki,wp-admin,wp,webcalendar,webcal,webdav,w00tw00t,webmail,wp-content">
			<cfset x=x & ",zboard">

			<!--- just remember to not add these...---->
			<cfset hasCausedProbsNoCheck="case,register">
			<cfloop list="#hasCausedProbsNoCheck#" index="i">
				<cfif listfindnocase(x,i)>
					<cfset x=listdeleteat(x,listfindnocase(x,i))>
				</cfif>
			</cfloop>
			<cfloop list="#lurl#" delimiters="#chr(7)#" index="i">
				<cfif listfindnocase(x,i)>
					<cfset bl_reason='URL contains #i#'>
					<p>#i#</p>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfloop>
			<!---- For the Admin folder, which is linked from email, be a little paranoid/cautious
				and only get obviously-malicious activity
				Common requests:
					/errors/forbidden.cfm?ref=/Admin/
						so tread a bit lighter; ignore variables part, look only at page/template request
			--->
			<cfset x="admin">
			<cfif request.rdurl contains "?">
				<cfset rf=listgetat(request.rdurl,1,"?")>
				<cfloop list="#rf#" delimiters="./&+()" index="i">
					<cfif listfindnocase(x,i)>
						<cfset bl_reason='URL contains #i#'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
				</cfloop>
			</cfif>

			<cfif isdefined("inp.sql")>
				<cfif inp.sql contains "@@version">
					<cfset bl_reason='SQL contains @@version'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif isdefined("inp.detail")>
					<cfif inp.detail is "ORA-00933: SQL command not properly ended" and  inp.sql contains 'href="http://'>
					<cfset bl_reason='SQL contains href=...'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
					<cfif inp.detail is "ORA-00907: missing right parenthesis" and  inp.sql contains '1%'>
						<cfset bl_reason='SQL contains 1%'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
					<cfif (inp.detail contains "ORA-00936" or inp.detail contains "ORA-00907") and  inp.sql contains "'A=0">
						<cfset bl_reason='SQL contains A=0'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdefined("inp.Detail")>
				<cfif inp.Detail contains "missing right parenthesis" and request.rdurl contains "ctxsys">
						<cfset bl_reason='detail contains ctxsys'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif inp.Detail contains "network access denied by access control list">
						<cfset bl_reason='detail contains network access '>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<!----- END: stuff in this block is only checked if there's an error; this is called at onError ------>
</cffunction>
<!--------------------------------->
	<cffunction name="QueryToCSV2" access="public" returntype="string" output="false" hint="I take a query and convert it to a comma separated value string.">
		<cfargument name="Query" type="query" required="true" hint="I am the query being converted to CSV."/>
		<cfargument name="Fields" type="string" required="true" hint="I am the list of query fields to be used when creating the CSV value."/>
	 	<cfargument name="CreateHeaderRow" type="boolean" required="false" default="true" hint="I flag whether or not to create a row of header values."/>
	 	<cfargument name="Delimiter" type="string" required="false" default="," hint="I am the field delimiter in the CSV value."/>
		<cfset var LOCAL = {} />
		<cfset LOCAL.ColumnNames = [] />
		<cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">
			<cfset ArrayAppend(LOCAL.ColumnNames,Trim( LOCAL.ColumnName )) />
	 	</cfloop>
		<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />
		<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />
		<cfset LOCAL.Rows = [] />
		<cfif ARGUMENTS.CreateHeaderRow>
			<cfset LOCAL.RowData = [] />
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
				<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />
	 		</cfloop>
	 		<cfset ArrayAppend(LOCAL.Rows,ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )) />
	 	</cfif>
		<cfloop query="ARGUMENTS.Query">
			<cfset LOCAL.RowData = [] />
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
	 			<cfset LOCAL.querydata = ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ] >
	 			<cfif isdate(LOCAL.querydata) and len(LOCAL.querydata) eq 21>
					<cfset LOCAL.querydata = dateformat(local.querydata,"yyyy-mm-dd")>
				</cfif>
	 			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( local.querydata, """", """""", "all" )#""" />
	 		</cfloop>
			<cfset ArrayAppend(LOCAL.Rows,ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )) />
	 	</cfloop>
		<cfreturn ArrayToList(LOCAL.Rows,LOCAL.NewLine) />
	</cffunction>
	<!---------------------------------------------------------------------------------------------->
	<cffunction name="CSVToQuery" access="remote" returntype="query" output="false" hint="Converts the given CSV string to a query.">
		<!--- from http://www.bennadel.com/blog/501-parsing-csv-values-in-to-a-coldfusion-query.htm ---->
		<cfargument name="CSV" type="string" required="true" hint="This is the CSV string that will be manipulated."/>
 		<cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value."/>
 		<cfargument name="Qualifier" type="string" required="false" default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded."/>
 		<cfargument name="FirstRowIsHeadings" type="boolean" required="false" default="true" hint="Set to false if the heading row is absent"/>
		<cfset var LOCAL = StructNew() />
		<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
 		<cfif Len( ARGUMENTS.Qualifier )>
 			<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
		</cfif>
 		<cfset LOCAL.LineDelimiter = Chr( 10 ) />
 		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(chr(13),LOCAL.LineDelimiter) />
		<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray()/>
 		<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />
		<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />
		<cfset LOCAL.Rows = ArrayNew( 1 ) />
		<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
		<cfset LOCAL.RowIndex = 1 />
		<cfset LOCAL.IsInValue = false />
		<cfloop index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
			<cfset LOCAL.FieldIndex = ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]) />
			<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst("^.{1}","") />
			<cfif Len( ARGUMENTS.Qualifier )>
				<cfif LOCAL.IsInValue>
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}") />
					<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] & LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token) />
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
						<cfset LOCAL.IsInValue = false />
					</cfif>
				<cfelse>
					<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst("^.{1}","") />
						<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}") />
						<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token.ReplaceFirst(".{1}$","")) />
						<cfelse>
							<cfset LOCAL.IsInValue = true />
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
						</cfif>
					<cfelse>
						<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
					</cfif>
				</cfif>
				<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],"{QUALIFIER}",ARGUMENTS.Qualifier,"ALL") />
			<cfelse>
				<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
			</cfif>
			<cfif ((NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND (LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter))>
				<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
				<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
			</cfif>
		</cfloop>
		<cfset LOCAL.MaxFieldCount = 0 />
		<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
		<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
			<cfset LOCAL.MaxFieldCount = Max(LOCAL.MaxFieldCount,ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ])) />
			<cfset ArrayAppend(LOCAL.EmptyArray,"") />
		</cfloop>
		<cfset LOCAL.Query = QueryNew( "" ) />
		<cfloop index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
		<cfset QueryAddColumn(LOCAL.Query,"COLUMN_#LOCAL.FieldIndex#","CF_SQL_VARCHAR",LOCAL.EmptyArray) />
	</cfloop>
	<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
		<cfloop index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
			<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast("string",LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]) />
		</cfloop>
	</cfloop>
<cfif FirstRowIsHeadings>
	<cfloop query="LOCAL.Query" startrow="1" endrow="1" >
		<cfloop list="#LOCAL.Query.columnlist#" index="col_name">
			<cfset field = evaluate("LOCAL.Query.#col_name#")>
			<cfset field = replace(field,"-","","ALL")>
			<cfset QueryChangeColumnName(LOCAL.Query,"#col_name#","#field#") >
		</cfloop>
	</cfloop>
	<cfset LOCAL.Query.RemoveRows( JavaCast( "int", 0 ), JavaCast( "int", 1 ) ) />
</cfif>


<cfreturn LOCAL.Query />
</cffunction>
<!----------------------------------------------------------------------------->
	<cffunction name="QueryChangeColumnName" access="public" output="false" returntype="query" hint="Changes the column name of the given query.">
		<cfargument name="Query" type="query" required="true"/>
		<cfargument name="ColumnName" type="string" required="true"/>
		<cfargument name="NewColumnName" type="string" required="true"/>
		<cfscript>
	 		var LOCAL = StructNew();
	 		LOCAL.Columns = ARGUMENTS.Query.GetColumnNames();
	 		LOCAL.ColumnList = ArrayToList(LOCAL.Columns);
	 		LOCAL.ColumnIndex = ListFindNoCase(LOCAL.ColumnList,ARGUMENTS.ColumnName);
	 		if (LOCAL.ColumnIndex){
	 			LOCAL.Columns = ListToArray(LOCAL.ColumnList);
				LOCAL.Columns[ LOCAL.ColumnIndex ] = ARGUMENTS.NewColumnName;
	 			ARGUMENTS.Query.SetColumnNames(LOCAL.Columns);
			}
	 		return( ARGUMENTS.Query );
		</cfscript>
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="stripQuotes" access="public" output="false">
		<cfargument name="inStr" type="string">
		<cfset inStr = replace(inStr,"#chr(34)#","&quot;","all")>
		<cfset inStr = replace(inStr,"#chr(39)#","&##39;","all")>
		<cfset inStr = trim(inStr)>
		<cfreturn inStr>
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="getFlatSQL" access="public" returnformat="plain">
		<!----
			for "normal" stuff that's matching a colulm in FLAT, just call this with eg

					<cfset temp=getFlatSql(fld="island_group", val=island_group)>

			instead of writing SQL
		---->
		<cfparam name="fld" type="string" default="">
		<cfparam name="val" type="string" default="">
		<cfif compare(val,"NULL") is 0>
			<cfset basQual = " #basQual# AND #session.flatTableName#.#fld# is null">
		<cfelseif len(val) gt 1 and left(val,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.#fld#) = '#UCASE(escapeQuotes(right(val,len(val)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.#fld#) LIKE '%#UCASE(escapeQuotes(val))#%'">
		</cfif>
		<cfset mapurl = "#mapurl#&#fld#=#URLEncodedFormat(val)#">
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="getChronMaker" access="remote" returnformat="plain">
		<cfparam name="exp" type="string" default="">
		<cfhttp url="http://www.cronmaker.com/rest/sampler?expression=#exp#&count=10">
		</cfhttp>
		<cfreturn cfhttp.filecontent>
	</cffunction>
</cfcomponent>