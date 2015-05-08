<cfcomponent>
<!------------------>
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
<cffunction name="checkRequest">
	<cfargument name="inp" type="any" required="false"/>
	<cfif session.roles contains "coldfusion_user">
       <!---- never blacklist "us" ---->
       <cfreturn>
    </cfif>
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
	<cfif isdefined("cgi.HTTP_USER_AGENT") and cgi.HTTP_USER_AGENT contains "slurp">
		<!--- yahoo ignoring robots.txt - buh-bye.... --->
		<cfset bl_reason='HTTP_USER_AGENT is slurp'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdur") and right(request.rdurl,5) is "-1%27">
		<cfset bl_reason='URL ends with -1%27'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdur") and right(request.rdurl,3) is "%00">
		<cfset bl_reason='URL ends with %00'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdur") and left(request.rdurl,6) is "/��#chr(166)#m&">
		<cfset bl_reason='URL starts with /��#chr(166)#m&'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>

	<!----- END: stuff in this block is always checked; this is called at onRequestStart ------>
	<!-----
		START: stuff in this block is only checked if there's an error
		Performance is unimportant here; this is going to end with an error
	 ------>
	<cfif isdefined("inp")>
		<cfif isdefined("request.rdurl")>
			<cfif request.rdurl contains "utl_inaddr" or request.rdurl contains "get_host_address">
				<cfset bl_reason='URL contains utl_inaddr or get_host_address'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfif request.rdurl contains "#chr(96)##chr(195)##chr(136)##chr(197)#">
				<cfset bl_reason='URL contains #chr(96)##chr(195)##chr(136)##chr(197)#'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<!---- random junk that is always indicitive of bot/spam/probe/etc. traffic---->
			<cfset x="">
			<cfset x=x & ",@@version">
			<cfset x=x & ",account,administrator,admin-console,attr(,asmx,abstractapp,adimages,asp,aspx,awstats,appConf,announce">
			<cfset x=x & ",backup,backend,blog,board,backup-db,backup-scheduler">
			<cfset x=x & ",char,chr,ctxsys,CHANGELOG,content,cms,checkupdate,comment,comments,connectors,cgi,cgi-bin,cgi-sys,calendar,config,client,cube">
			<cfset x=x & ",drithsx,Dashboard,dbg,dbadmin">
			<cfset x=x & ",etc,environ,exe,editor,ehcp">
			<cfset x=x & ",fulltext,feed,feeds,filemanager,fckeditor">
			<cfset x=x & ",getmappingxpath,get_host_address">
			<cfset x=x & ",html(,HNAP1,htdocs,horde,HovercardLauncher">
			<cfset x=x & ",inurl,invoker,ini">
			<cfset x=x & ",jbossws,jbossmq-httpil,jspa,jiraHNAP1,jsp,jmx-console">
			<cfset x=x & ",lib">
			<cfset x=x & ",mpx,mysql,mysql2,mydbs,manager,myadmin,muieblackcat,mail">
			<cfset x=x & ",news,nyet">
			<cfset x=x & ",ord_dicom,ordsys,owssvr,ol">
			<cfset x=x & ",php,phppath,phpMyAdmin,PHPADMIN,phpldapadmin,phpMyAdminLive,_phpMyAdminLive,printenv,proc,plugins,passwd,pma2,pma4,pma,phppgadmin">
			<cfset x=x & ",rand,reviews,rutorrent,rss,register,roundcubemail,roundcube,README">
			<cfset x=x & ",sys,swf,server-status,stories,setup,sign_up,signup,scripts,sqladm,soapCaller,simple-backup,sedlex">
			<cfset x=x & ",trackback">
			<cfset x=x & "utl_inaddr,uploadify,userfiles,updates">
			<cfset x=x & ",verify-tldnotify,version">
			<cfset x=x & ",wiki,wp-admin,wp,webcalendar,webcal,webdav,w00tw00t,webmail,wp-content">
			<cfset x=x & ",zboard">


			<cfloop list="#request.rdurl#" delimiters="./&+()" index="i">
				<cfif listfindnocase(x,i)>
					<cfset bl_reason='URL contains #i#'>
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
			<cfif session.roles does not contain "coldfusion_user">
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
			</cfif>
		</cfif>
		<cfif isdefined("cgi.HTTP_USER_AGENT") and cgi.HTTP_USER_AGENT contains "Synapse">
				<cfset bl_reason='HTTP_USER_AGENT is Synapse'>
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
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
</cfcomponent>