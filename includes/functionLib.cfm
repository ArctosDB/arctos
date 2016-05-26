<cfscript>
	function isYear(x){
       var d = "^[1-9][0-9]{3}$";
       return isValid("regex", x, d);
	}
</cfscript>
<cffunction name="wrd">
	<!--- filter strings to contain only A-Z,_,- --->
	<cfargument name="w" required="yes">
	<cfif rereplacenocase(w,'[^A-Z_]','') is w>
		<cfreturn w>
	<cfelse>
		<cfreturn 'NOT_WRD'>
	</cfif>
</cffunction>
<cffunction name="isValidMediaPreview">
	<cfargument name="fileName" required="yes">
	<cfset err="">
	<cfset extension=listlast(fileName,".")>
	<cfset acceptExtensions="jpg,jpeg,gif,png">
	<cfif listfindnocase(acceptExtensions,extension) is 0>
		<cfset err="An valid file name extension is required. Acceptable preview extensions are #acceptExtensions#. Your extension is #extension#">
	</cfif>
	<cfset name=replace(fileName,".#extension#","")>
	<cfif REFind("[^A-Za-z0-9_-]",name,1) gt 0>
		<cfset err="Filenames may contain only letters, numbers, dash, and underscore.">
	</cfif>
	<cfreturn err>
</cffunction>
<cffunction name="isValidCSV">
	<cfargument name="fileName" required="yes">
	<cfset err="">
	<cfset extension=listlast(fileName,".")>
	<cfset acceptExtensions="csv">
	<cfif listfindnocase(acceptExtensions,extension) is 0>
		<cfset err="Only CSV files are accepted.">
	</cfif>
	<cfreturn err>
</cffunction>
<cffunction name="jsescape">
	<cfargument name="in" required="yes">
	<cfset out=replace(in,"'","`","all")>
	<cfset out=replace(out,'"','``',"all")>
	<cfset out=replace(out,chr(10),'[chr-10]',"all")>
	<cfset out=replace(out,chr(13),'[chr-13]',"all")>
	<cfset out=replace(out,chr(9),'[tab]',"all")>
	<cfreturn trim(out)>
</cffunction>
<cffunction name="niceURL" returntype="Any">
	<cfargument name="s" type="string" required="yes">
	<cfscript>
		var r=trim(s);
		r=trim(rereplace(r,'<[^>]*>','',"all"));
		r=rereplace(r,'[^A-Za-z ]','',"all");
		r=rereplace(r,' ','-',"all");
		r=lcase(r);
		if (len(r) gt 150) {r=left(r,150);}
		if (right(r,1) is "-") {r=left(r,len(r)-1);}
		r=rereplace(r,'-+','-','all');
		return r;
	</cfscript>
</cffunction>
<!------------------------------------------------------------------------------------->
<cffunction name="checkSql" access="public" output="true" returntype="boolean">
    <cfargument name="sql" required="true" type="string">
    <cfset nono="chr,char,update,insert,drop,create,execute,exec,begin,declare,all_tables,session,sys,ascii">
    <cfset safe=0>
    <cfloop index="i" list="#sql#" delimiters=" .,?!;:%$&""'/|[]{}()#chr(10)##chr(13)##chr(9)#@">
	    <cfif ListFindNoCase(nono, i)>
	        <cfset safe=i>
	    </cfif>
    </cfloop>
    <cfif safe is 0>
        <cfreturn true>
    <cfelse>
	    <cfset bl_reason='checkSql caught keyword #i#'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfreturn false>
    </cfif>
</cffunction>
<!--------------------------------------------------------------------->
<cffunction name="setDbUser" output="true" returntype="boolean">
	<cfargument name="portal_id" type="string" required="false">
	<cfif not isdefined("portal_id") or len(portal_id) is 0 or not isnumeric(portal_id)>
		<cfset portal_id=0>
	</cfif>
	<!--- get the information for the portal --->
	<cfquery name="portalInfo" datasource="cf_dbuser">
		select * from cf_collection where cf_collection_id = #portal_id#
	</cfquery>
	<!--- these things die sometimes ---->
	<cfif portalInfo.recordcount is 0>
		<cfthrow
			detail = "missing portal"
			errorCode = "5649"
			extendedInfo = "portal_id=#portal_id#; portalInfo.dbpwd=#portalInfo.dbpwd#;session.sessionKey=#session.sessionKey#; #cfcatch.detail#"
			message = "user #session.username# has a dead portal set; check exclusive_collection_id">
	</cfif>
	<cfif session.roles does not contain "coldfusion_user">
		<cfset session.dbuser=portalInfo.dbusername>
		<cfset session.epw = encrypt(portalInfo.dbpwd,session.sessionKey)>
		<cfset session.flatTableName = "filtered_flat">
	<cfelse>
		<cfset session.flatTableName = "flat">
	</cfif>
	<cfset session.portal_id=portal_id>
	<!--- may need to get generic appearance --->
	<cfif portalInfo.recordcount is 0 or
		len(portalInfo.header_color) is 0 or
		len(portalInfo.header_image) is 0 or
		len(portalInfo.collection_url) is 0 or
		len(portalInfo.collection_link_text) is 0 or
		len(portalInfo.institution_url) is 0 or
		len(portalInfo.institution_link_text) is 0>
		<cfquery name="portalInfo" datasource="cf_dbuser">
			select * from cf_collection where cf_collection_id = 0
		</cfquery>
	</cfif>
	<!---
	<cfquery name="getPrefs" datasource="cf_dbuser">
		update cf_users set exclusive_collection_id=
		<cfif len(#session.exclusive_collection_id#) gt 0>
			#session.exclusive_collection_id#
		<cfelse>
			NULL
		</cfif> where username = '#session.username#'
	</cfquery>
	--->
	<cfset session.header_color = portalInfo.header_color>
	<cfset session.header_image = portalInfo.header_image>
	<cfset session.collection_url = portalInfo.collection_url>
	<cfset session.collection_link_text = portalInfo.collection_link_text>
	<cfset session.institution_url = portalInfo.institution_url>
	<cfset session.institution_link_text = portalInfo.institution_link_text>
	<cfset session.meta_description = portalInfo.meta_description>
	<cfset session.meta_keywords = portalInfo.meta_keywords>
	<cfset session.stylesheet = portalInfo.stylesheet>
	<cfset session.header_credit = portalInfo.header_credit>

	<cfreturn true>
</cffunction>
<!----------------------------------------------------------->
<cffunction name="initSession" output="true" returntype="boolean">
	<cfargument name="username" type="string" required="false">
	<cfargument name="pwd" type="string" required="false">
	<cfoutput>
	<!------------------------ logout ------------------------------------>
	<cfset StructClear(Session)>
	<cflogout>
	<cfset session.sessionKey=hash(RandRange(1, 9999) & '_' & RandRange(1, 9999))>
	<cfset session.DownloadFileName = "ArctosData_#session.sessionKey#.txt">
	<cfset session.roles="public">
	<cfset session.showObservations="">
	<cfset session.result_sort="">
	<cfset session.username="">
	<cfset session.killrow="0">
	<cfset session.searchBy="">
	<cfset session.fancyCOID="">
	<cfset session.last_login="">
	<cfset session.customOtherIdentifier="">
	<cfset session.displayrows="20">
	<cfset session.loan_request_coll_id="">
	<cfset session.resultColumnList="">
	<cfset session.schParam = "">
	<cfset session.target=''>
	<cfset session.block_suggest=''>
	<cfset session.meta_description=''>
	<cfset session.SpecSrchTab="SpecSrch" & left(session.sessionKey,20)>
	<cfset session.SpecSumTab="SpecSum" & left(session.sessionKey,20)>
	<cfset session.MediaSrchTab="MediaSrch" & left(session.sessionKey,20)>
	<cfset session.TaxSrchTab="TaxSrch" & left(session.sessionKey,20)>
	<!---------------------------- login ------------------------------------------------>
	<cfif isdefined("username") and len(username) gt 0 and isdefined("pwd") and len(pwd) gt 0>
		<cfquery name="getPrefs" datasource="cf_dbuser">
			select * from cf_users where upper(username) = '#ucase(username)#' and password='#hash(pwd)#'
		</cfquery>
		<cfif getPrefs.recordcount is 0>
			<cfset session.username = "">
			<cfset session.epw = "">
       		<cflocation url="/login.cfm?badPW=true&username=#username#" addtoken="false">
		</cfif>
		<cfset session.username=getPrefs.username>
		<cfquery name="dbrole" datasource="uam_god">
			 select upper(granted_role) role_name
	         	from
	         dba_role_privs,
	         cf_ctuser_roles
	         	where
	         upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
	         upper(grantee) = '#ucase(getPrefs.username)#'
		</cfquery>
		<cfset session.roles = valuelist(dbrole.role_name)>
		<cfset session.roles=listappend(session.roles,"public")>
		<cfset session.last_login = "#getPrefs.last_login#">
		<cfset session.displayrows = "#getPrefs.displayRows#">
		<cfset session.taxaPickPrefs = getPrefs.taxaPickPrefs>
		<cfset session.resultcolumnlist = "#getPrefs.resultcolumnlist#">
		<cfset session.ResultsBrowsePrefs=getPrefs.ResultsBrowsePrefs>
		<cfif len(getPrefs.fancyCOID) gt 0>
			<cfset session.fancyCOID = getPrefs.fancyCOID>
		<cfelse>
			<cfset session.fancyCOID = "">
		</cfif>
		<cfif len(getPrefs.block_suggest) gt 0>
			<cfset session.block_suggest = getPrefs.block_suggest>
		</cfif>
		<cfif len(getPrefs.result_sort) gt 0>
			<cfset session.result_sort = getPrefs.result_sort>
		<cfelse>
			<cfset session.result_sort = "">
		</cfif>

		<cfset session.CustomOidOper = getPrefs.CustomOidOper>

		<cfif len(getPrefs.CustomOtherIdentifier) gt 0>
			<cfset session.customOtherIdentifier = getPrefs.CustomOtherIdentifier>
		<cfelse>
			<cfset session.customOtherIdentifier = "">
		</cfif>
		<cfif getPrefs.bigsearchbox is 1>
			<cfset session.searchBy="bigsearchbox">
		<cfelse>
			<cfset session.searchBy="">
		</cfif>
		<cfif getPrefs.killRow is 1>
			<cfset session.killRow=1>
		<cfelse>
			<cfset session.killRow=0>
		</cfif>
		<cfset session.srmapclass = getPrefs.srmapclass>
		<cfset session.sdmapclass = getPrefs.sdmapclass>
		<cfset session.locSrchPrefs=getPrefs.locSrchPrefs>
		<cfquery name="logLog" datasource="cf_dbuser">
			update cf_users set last_login = sysdate where upper(username) = '#ucase(session.username)#'
		</cfquery>
		<cfif listcontainsnocase(session.roles,"coldfusion_user")>
			<cfset session.dbuser = "#getPrefs.username#">
			<cfset session.epw = encrypt(pwd,session.sessionKey)>
			<cftry>
				<cfquery name="ckUserName" datasource="uam_god">
					select agent_id from agent_name where upper(agent_name)='#ucase(session.username)#' and
					agent_name_type='login'
				</cfquery>
				<cfcatch>
					<div class="error">
						Your Oracle login has issues. Contact a DBA.
					</div>
					<cfabort>
				</cfcatch>
			</cftry>
			<cfif len(ckUserName.agent_id) is 0>
				<div class="error">
					You must have an agent_name of type login that matches your Arctos username.
				</div>
				<cfabort>
			</cfif>
			<cfset session.myAgentId=ckUserName.agent_id>
		<cfset pwtime =  round(now() - getPrefs.pw_change_date)>
		<cfset pwage = Application.max_pw_age - pwtime>
		<cfif pwage lte 0>
			<cfset session.force_password_change = "yes">
			<cflocation url="ChangePassword.cfm" addtoken="false">
		</cfif>
		</cfif>
	</cfif>
	<cfif isdefined("getPrefs.exclusive_collection_id") and len(getPrefs.exclusive_collection_id) gt 0>
		<cfset ecid=getPrefs.exclusive_collection_id>
	<cfelse>
		<cfset ecid="">
	</cfif>
	<cfset setDbUser(ecid)>
	</cfoutput>
	<cfreturn true>
</cffunction>
<!------------------------------------------------------------------------------------->
<cffunction name="unsafeSql" access="public" output="false" returntype="boolean">
    <cfargument name="sql" required="true" type="string">
    <cfset nono="update,insert,delete,drop,create,alter,set,execute,exec,begin,declare,all_tables,v$session">
    <cfset dels="';','|',">
    <cfset safe=0>
    <cfloop index="i" list="#sql#" delimiters=" .,?!;:%$&""'/|[]{}()#chr(10)##chr(13)##chr(9)#">
	    <cfif ListFindNoCase(nono, i)>
	        <cfset safe=1>
	    </cfif>
    </cfloop>
    <cfif safe gt 0>
        <cfreturn true>
    <cfelse>
        <cfreturn false>
    </cfif>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="QueryToCSV" access="public" returntype="string" output="false">

	<!--- Define arguments. --->
	<cfargument name="Query" type="query" required="true" hint="media query being converted to CSV.">

	<cfargument name="Fields" type="string" required="true" hint="List of query fields to be used when creating the CSV value.">

	<cfargument name="CreateHeaderRow" type="boolean" required="false" default="true" hint="Boolean flag indicator for creating headers or not">

	<cfargument name="Delimiter" type="string" required="false" default="," hint="Field delimiter in the CSV value.">

	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />

	<!---
		Set up a column index so that we can
		iterate over the column names faster than if we used a
		standard list loop on the passed-in list.
	--->
	<cfset LOCAL.ColumnNames = [] />

	<!---
		Loop over column names and index them numerically. We
		are going to be treating this struct almost as if it
		were an array. The reason we are doing this is that
		look-up times on a table are a bit faster than look
		up times on an array (or so I have been told).
	--->

	<cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">

		<!--- Store the current column name. --->
		<cfset ArrayAppend(LOCAL.ColumnNames, Trim( LOCAL.ColumnName ))>

	</cfloop>

	<!--- Store the column count. --->
	<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />


	<!--- Create a short hand for the new line characters. --->
	<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />

	<!--- Create an array to hold the set of row data. --->
	<cfset LOCAL.Rows = [] />


	<!--- Check to see if we need to add a header row. --->
	<cfif ARGUMENTS.CreateHeaderRow>

		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />

		<!--- Loop over the column names. --->
		<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">

			<!--- Add the field name to the row data. --->
			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />

		</cfloop>

		<!--- Append the row data to the string buffer. --->
		<cfset ArrayAppend(
			LOCAL.Rows,
			ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )
			) />

	</cfif>


	<!---
		Now that we have dealt with any header value, let's
		convert the query body to CSV. When doing this, we are
		going to qualify each field value. This is done be
		default since it will be much faster than actually
		checking to see if a field needs to be qualified.
	--->

	<!--- Loop over the query. --->
	<cfloop query="ARGUMENTS.Query">
		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />

		<!--- Loop over the columns. --->
		<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#"	step="1">

			<!--- Add the field to the row data. --->
			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ], """", """""", "all" )#""" />

		</cfloop>

		<!--- Append the row data to the string buffer. --->
		<cfset ArrayAppend(LOCAL.Rows,	ArrayToList(LOCAL.RowData, ARGUMENTS.Delimiter ))>
	</cfloop>



	<!---
		Return the CSV value by joining all the rows together
		into one string.
	--->
	<cfreturn ArrayToList(
		LOCAL.Rows,
		LOCAL.NewLine
		) />

</cffunction>

<!----------------------------------------------------------------------------------------->
<cffunction name="roundDown" output="no">
    <cfargument name="target" type="numeric" required="true"/>
    <cfreturn (round((arguments.target * -1))) * -1/>
</cffunction>
<!----------------------------------------------------------------------------------------->

<cfscript>
    /**
        * Returns a random hexadecimal color
        * @return Returns a string.
        * @author andy matthews (andy@icglink.com)
        * @version 1, 7/22/2005
    */
    function randomHexColor() {
    	var chars = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f";
    	var totalChars = 6;
    	var hexCode = '';
    	for ( step=1;step LTE totalChars; step = step + 1) {
    		hexCode = hexCode & ListGetAt(chars,RandRange(1,ListLen(chars)));
    	}
        return hexCode;
    }
</cfscript>




<!----------------------------------------------------------------------------------------->
<cfscript>
/**
 * Returns the last index of an occurrence of a substring in a string from a specified starting position.
 * Big update by Shawn Seley (shawnse@aol.com) -
 * UDF was not accepting third arg for start pos
 * and was returning results off by one.
 * Modified by RCamden, added var, fixed bug where if no match it return len of str
 *
 * @param Substr 	 Substring to look for.
 * @param String 	 String to search.
 * @param SPos 	 Starting position.
 * @return Returns the last position where a match is found, or 0 if no match is found.
 * @author Charles Naumer (shawnse@aol.comcmn@v-works.com)
 * @version 2, February 14, 2002
 */
function RFind(substr,str) {
  var rsubstr  = reverse(substr);
  var rstr     = "";
  var i        = len(str);
  var rcnt     = 0;

  if(arrayLen(arguments) gt 2 and arguments[3] gt 0 and arguments[3] lte len(str)) i = len(str) - arguments[3] + 1;

  rstr = reverse(Right(str, i));
  rcnt = find(rsubstr, rstr);

  if(not rcnt) return 0;
  return len(str)-rcnt-len(substr)+2;
}
/**
 * Converts degrees to radians.
 *
 * @param degrees 	 Angle (in degrees) you want converted to radians.
 * @return Returns a simple value
 * @author Rob Brooks-Bilson (rbils@amkor.com)
 * @version 1.0, July 18, 2001
 */
function DegToRad(degrees)
{
  Return (degrees*(Pi()/180));
}


/**
 * Calculates the arc tangent of the two variables, x and y.
 *
 * @param x 	 First value. (Required)
 * @param y 	 Second value. (Required)
 * @return Returns a number.
 * @author Rick Root (rick.root@webworksllc.com)
 * @version 1, September 14, 2005
 */
function atan2(firstArg, secondArg) {
	var Math = createObject("java","java.lang.Math");
	return Math.atan2(javacast("double",firstArg), javacast("double",secondArg));
}

/**
 * Converts radians to degrees.
 *
 * @param radians 	 Angle (in radians) you want converted to degrees.
 * @return Returns a simple value.
 * @author Rob Brooks-Bilson (rbils@amkor.com)
 * @version 1.0, July 18, 2001
 */
function RadToDeg(radians)
{
  Return (radians*(180/Pi()));
}

/**
 * Computes the mathematical function Mod(y,x).
 *
 * @param y 	 Number to be modded.
 * @param x 	 Devisor.
 * @return Returns a numeric value.
 * @author Tom Nunamaker (tom@toshop.com)
 * @version 1, February 24, 2002
 */
function ProperMod(y,x) {
  var modvalue = y - x * int(y/x);

  if (modvalue LT 0) modvalue = modvalue + x;

  Return ( modvalue );
}
</cfscript>
<cffunction name="kmlStripper" returntype="string" output="false">
	<cfargument name="in" type="string">
	<cfset out = replace(in,"&","&amp;","all")>
	<cfset out = replace(out,"'","&apos;","all")>
	<cfset out = replace(out,'"','&quot;','all')>
	<cfset out = replace(out,'>',"&qt;","all")>
	<cfset out = replace(out,'<',"&lt;","all")>
	<cfreturn out>
</cffunction>
<!----------------------->
<cffunction
     name="CSVToArray"
     access="public"
     returntype="array"
     output="false"
     hint="Converts the given CSV string to an array of arrays.">
     <cfargument
     name="CSV"
     type="string"
     required="true"
     hint="This is the CSV string that will be manipulated."
     />

     <cfargument
     name="Delimiter"
     type="string"
     required="false"
     default=","
     hint="This is the delimiter that will separate the fields within the CSV value."
     />

     <cfargument
     name="Qualifier"
     type="string"
     required="false"
     default=""""
     hint="This is the qualifier that will wrap around fields that have special characters embeded."
     />
     <cfset var LOCAL = StructNew() />
     <cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
     <cfif Len( ARGUMENTS.Qualifier )>
     <cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
     </cfif>
     <cfset LOCAL.LineDelimiter = Chr( 13 ) />
     <cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
     "\r?\n",
     LOCAL.LineDelimiter
     ) />
     <cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll(
     "[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+",
     ""
     )
     .ToCharArray()
     />
     <cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />

     <!--- Now add the space to each field. --->
     <cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
     "([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})",
     "$1 "
     ) />
     <cfset LOCAL.Tokens = ARGUMENTS.CSV.Split(
     "[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}"
     ) />
     <cfset LOCAL.Return = ArrayNew( 1 ) />
     <cfset ArrayAppend(
     LOCAL.Return,
     ArrayNew( 1 )
     ) />
     <cfset LOCAL.RowIndex = 1 />
     <cfset LOCAL.IsInValue = false />
     <cfloop
     index="LOCAL.TokenIndex"
     from="1"
     to="#ArrayLen( LOCAL.Tokens )#"
     step="1">
     <cfset LOCAL.FieldIndex = ArrayLen(
     LOCAL.Return[ LOCAL.RowIndex ]
     ) />
     <cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst(
     "^.{1}",
     ""
     ) />
     <cfif Len( ARGUMENTS.Qualifier )>
     <cfif LOCAL.IsInValue>
     <cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
     "\#ARGUMENTS.Qualifier#{2}",
     "{QUALIFIER}"
     ) />
     <cfset LOCAL.Return[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (
     LOCAL.Return[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
     LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] &
     LOCAL.Token
     ) />
     <cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
     <cfset LOCAL.Return[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Return[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
     <cfset LOCAL.IsInValue = false />
     </cfif>
     <cfelse>
     <cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
     <cfset LOCAL.Token = LOCAL.Token.ReplaceFirst(
     "^.{1}",
     ""
     ) />
     <cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
     "\#ARGUMENTS.Qualifier#{2}",
     "{QUALIFIER}"
     ) />
     <cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
     <cfset ArrayAppend(
     LOCAL.Return[ LOCAL.RowIndex ],
     LOCAL.Token.ReplaceFirst(
     ".{1}$",
     ""
     )
     ) />
     <cfelse>
     <cfset LOCAL.IsInValue = true />
     <cfset ArrayAppend(
     LOCAL.Return[ LOCAL.RowIndex ],
     LOCAL.Token
     ) />
     </cfif>
     <cfelse>
     <cfset ArrayAppend(
     LOCAL.Return[ LOCAL.RowIndex ],
     LOCAL.Token
     ) />
     </cfif>
     </cfif>
     <cfset LOCAL.Return[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Return[ LOCAL.RowIndex ] ) ] = Replace(
     LOCAL.Return[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Return[ LOCAL.RowIndex ] ) ],
     "{QUALIFIER}",
     ARGUMENTS.Qualifier,
     "ALL"
     ) />
     <cfelse>
     <cfset ArrayAppend(
     LOCAL.Return[ LOCAL.RowIndex ],
     LOCAL.Token
     ) />
     </cfif>
     <cfif (
     (NOT LOCAL.IsInValue) AND
     (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND
     (LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter)
     )>
     <cfset ArrayAppend(
     LOCAL.Return,
     ArrayNew( 1 )
     ) />
     <cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
     </cfif>
     </cfloop>
     <cfreturn LOCAL.Return />

     </cffunction>


<cffunction name="toProperCase" output="false">
	<cfargument name="message" type="string">
	<cfscript>
	strlen = len(message);
    newstring = '';
    for (counter=1;counter LTE strlen;counter=counter + 1)
    {
    		frontpointer = counter + 1;

    		if (Mid(message, counter, 1) is " ")
    		{
    		 	newstring = newstring & ' ' & ucase(Mid(message, frontpointer, 1));
    		counter = counter + 1;
    		}
    	else
    		{
    			if (counter is 1)
    			newstring = newstring & ucase(Mid(message, counter, 1));
    			else
    			newstring = newstring & lcase(Mid(message, counter, 1));
    		}

    }
    </cfscript>
	<cfreturn newstring>
</cffunction>
<!------------------------------->
<cffunction name="passwordCheck">
	<cfargument name="password" required="true" type="string">
	<cfargument name="CharOpts" required="false" type="string" default="alpha,digit,punct">
	<cfargument name="typesRequired" required="false" type="numeric" default="3">
	<cfargument name="length" required="false" type="numeric" default="8">


	<!--- Initialize variables --->
	<cfset var TypesCount = 0>
	<cfset var i = "">
	<cfset var charClass = "">
	<cfset var checks = structNew()>
	<cfset var numReq = "">
	<cfset var reqCompare = "">
	<cfset var j = "">

	<!--- Use regular expressions to check for the presence banned characters such as tab, space, backspace, etc  and password length--->
	<cfif ReFind("[[:cntrl:] ]",password) OR len(password) LT length>
		<cfreturn false>
	</cfif>

	<!--- random things that Oracle doesn't like --->
	<!---
	<cfset badStuff = "=,#,&,*">
	--->
	<cfset badStuff = "#chr(40)#,#chr(41)#,#chr(42)#,#chr(38)#,#chr(35)#,+,@,=,!,$,%,^">
	<cfloop list="#badStuff#" index="i">
		<cfif #password# contains #i#>
			<cfreturn false>
		</cfif>
	</cfloop>

	<!--- Loop through the list 'mustHave' --->
	<cfloop list="#charOpts#" index="i">
		<cfset charClass = listGetat(i,1,' ')>
		<!--- Check to see if item in list should be included or excluded --->
		<cfif listgetat(i,1,"_") eq "no">
			<cfset regex = "[^[:#listgetat(charClass,2,'_')#:]]">
		<cfelse>
			<cfset regex = "[[:#charClass#:]]">
		</cfif>

		<!--- If regex found, set variable to position found --->
		<cfset checks["check#replace(charClass,' ','_','all')#"] = ReFind(regex,password)>

		<!--- If regex not found set valid to false --->
		<cfif checks["check#replace(charClass,' ','_','all')#"] GT 0>
			<cfset typesCount = typesCount + 1>
		</cfif>

		<cfif listLen(i, ' ') GT 1>
			<cfset numReq = listgetat(i,2,' ')>
			<cfset reqCompare = 0>
			<cfloop from="1" to="#len(password)#" index="j">
				<cfif REFind(regex,mid(password,j,1))>
					<cfset reqCompare = reqCompare + 1>
				</cfif>
			</cfloop>
			<cfif reqCompare LT numReq>
				<cfreturn false>
			</cfif>
		</cfif>
	</cfloop>

	<!--- Check that retrieved values match with the give criteria --->
	<cfif typesCount LT typesRequired>
		<cfreturn false>
	</cfif>
	<cfif not refind("[a-zA-Z]",left(password,1))>
		<cfreturn false>
	</cfif>
	<cfreturn true>

</cffunction>
<cffunction name="stripQuotes" returntype="string" output="false">
	<cfargument name="inStr" type="string">
	<cfset inStr = replace(inStr,"#chr(34)#","&quot;","all")>
	<cfset inStr = replace(inStr,"#chr(39)#","&##39;","all")>
	<cfset inStr = trim(inStr)>
	<cfreturn inStr>
</cffunction>
<cffunction name="escapeDoubleQuotes" returntype="string" output="false">
	<cfargument name="inStr" type="string">
	<cfset inStr = replace(inStr,'"','""',"all")>
	<cfreturn inStr>
</cffunction>
<cffunction name="escapeQuotes" returntype="string" output="false">
	<cfargument name="inStr" type="string">
	<cfset inStr = replace(inStr,"'","''","all")>
	<cfreturn inStr>
</cffunction>
<cffunction name="getMeters" returntype="numeric" output="false">
	<cfargument name="val" type="numeric" required="yes">
	<cfargument name="unit" type="string" required="yes">
	<cfif #unit# is "ft">
		<cfset valInM = #val# * .3048>
	<cfelseif #unit# is "km">
		<cfset valInM = #val# * 1000>
	<cfelseif #unit# is "mi">
		<cfset valInM = #val# * 1609.344>
	<cfelseif #unit# is "m">
		<cfset valInM = #val#>
	<cfelseif #unit# is "yd">
		<cfset valInM = #val# * 9144 >
	<cfelse>
		<cfset valInM = "-9999999999" >
	</cfif>
	<cfreturn valInM>
</cffunction>
<cfscript>
/**
 * Calculates the Julian Day for any date in the Gregorian calendar.
 *
 * @param TheDate 	 Date you want to return the Julian day for.
 * @return Returns a numeric value.
 * @author Beau A.C. Harbin (bharbin@figleaf.com)
 * @version 1, September 4, 2001
 */
 function GetJulianDay(){
	var date = Now();
	var year = 0;
	var month = 0;
	var day = 0;
	var hour = 0;
	var minute = 0;
	var second = 0;
	var a = 0;
	var y = 0;
	var m = 0;
	var JulianDay =0;
        if(ArrayLen(Arguments))
          date = Arguments[1];
	// The Julian Day begins at noon so in order to calculate the date properly, one must subtract 12 hours
	date = DateAdd("h", -12, date);
	year = DatePart("yyyy", date);
	month = DatePart("m", date);
	day = DatePart("d", date);
	hour = DatePart("h", date);
	minute = DatePart("n", date);
	second = DatePart("s", date);

	a = (14-month) \ 12;
	y = (year+4800) - a;
	m = (month + (12*a)) - 3;

	JD = (day + ((153*m+2) \ 5) + (y*365) + (y \ 4) - (y \ 100) + (y \ 400)) - 32045;
	JDTime = NumberFormat(CreateTime(hour, minute, second), ".99999999");

	JulianDay = JD + JDTime;

	return JulianDay;
}
Request.GetJulianDay=GetJulianDay;
</cfscript>