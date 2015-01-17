<cfcomponent>
<!------------------>
<cffunction name="checkRequest">
	<cfargument name="inp" type="any" required="false"/>
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
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("cgi.blog_name") and len(cgi.blog_name) gt 0>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	
	<cfif isdefined("cgi.HTTP_REFERER") and cgi.HTTP_REFERER contains "/bash">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.HTTP_USER_AGENT") and cgi.HTTP_USER_AGENT contains "slurp">
		<!--- yahoo ignoring robots.txt - buh-bye.... --->
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif right(request.rdurl,5) is "-1%27" or right(request.rdurl,3) is "%00" or left(request.rdurl,6) is "/‰Û#chr(166)#m&">
		<cfset bl_reason='-1%27 in URL'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!----- END: stuff in this block is always checked; this is called at onRequestStart ------>
	<!----- 
		START: stuff in this block is only checked if there's an error
		Performance is unimportant here; this is going to end with an error
	 ------>
	<cfif isdefined("inp")>
		<cfif request.rdurl contains "utl_inaddr" or request.rdurl contains "get_host_address">
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
		<cfif request.rdurl contains "#chr(96)##chr(195)##chr(136)##chr(197)#">
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
		<cfif right(request.rdurl,5) is "-1%27">
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
		<!---- random junk that is always indicitive of bot/spam/probe/etc. traffic---->
		<cfset x="">
		<cfset x=x & ",@@version">
		<cfset x=x & ",account,administrator,admin-console,attr(,asmx,abstractapp,adimages,asp,aspx,awstats,appConf,announce">
		<cfset x=x & ",backup,backend,blog,board,backup-db,backup-scheduler">		
		<cfset x=x & ",char,chr,ctxsys,CHANGELOG,content,cms,checkupdate,comment,comments,connectors,cgi,cgi-bin,calendar,config,client,cube">
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
		<cfset x=x & ",wp-admin,wp,webcalendar,webcal,webdav,w00tw00t,webmail,wp-content">
		<cfset x=x & ",zboard">
		

		<cfloop list="#request.rdurl#" delimiters="./&+()" index="i">
			<cfif listfindnocase(x,i)>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfloop>
		
		<!---- this stuff is sometimes "us" eg, 
			/errors/forbidden.cfm?ref=/Admin/ 
			so tread a bit lighter
			ignore variables part, look only at page/template request
		--->
		<cfset x="admin">
		<cfif request.rdurl contains "?">
			<cfset rf=listgetat(request.rdurl,1,"?")>
			<cfloop list="#rf#" delimiters="./&+()" index="i">
				<cfif listfindnocase(x,i)>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif isdefined("cgi.HTTP_USER_AGENT") and cgi.HTTP_USER_AGENT contains "Synapse">
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
		<cfif isdefined("cgi.HTTP_ACCEPT_ENCODING") and cgi.HTTP_ACCEPT_ENCODING is "identity">
			<!--- probes, but also the occasional legit request - do nothing I guess maybe.... ---->
			<cfabort>
		</cfif>
		
		
		<cfif isdefined("inp.sql")>
			<cfif inp.sql contains "@@version">
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfif isdefined("inp.detail")>
				<cfif inp.detail is "ORA-00933: SQL command not properly ended" and  inp.sql contains 'href="http://'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif inp.detail is "ORA-00907: missing right parenthesis" and  inp.sql contains '1%'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif (inp.detail contains "ORA-00936" or inp.detail contains "ORA-00907") and  inp.sql contains "'A=0">
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfif>
		</cfif>
		<cfif isdefined("inp.Detail")>
			<cfif inp.Detail contains "missing right parenthesis" and request.rdurl contains "ctxsys">
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfif inp.Detail contains "network access denied by access control list">
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