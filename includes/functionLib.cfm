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
<cffunction name="getMediaPreview" access="public" output="true">
	   <cfargument name="puri" required="true" type="string">
	   <cfargument name="mt" required="false" type="string">
	   <cfset r=0>
	   <cfif len(puri) gt 0>
			<cfhttp method="head" url="#puri#">
			<cfif isdefined("cfhttp.responseheader.status_code") and cfhttp.responseheader.status_code is 200>
				<cfset r=1>
			</cfif>
		</cfif>
		<cfif r is 0>
			<cfif mt is "image">
				<cfreturn "/images/noThumb.jpg">
			<cfelseif mt is "audio">
				<cfreturn "/images/audioNoThumb.png">
			<cfelse>
				<cfreturn "/images/noThumb.jpg">
			</cfif>
		<cfelse>
			<cfreturn puri>
		</cfif>
</cffunction>
<!------------------------------------------------------------------------------------->
<cffunction name="getTagReln" access="public" output="true">
    <cfargument name="tag_id" required="true" type="numeric">
	<cfoutput>
		<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				tag_id,
				media_id,
				reftop,
				refleft,
				refh,
				refw,
				imgh,
				imgw,
				remark,
				collection_object_id,
				collecting_event_id,
				locality_id,
				agent_id
			from tag where tag_id=#tag_id#
			order by
				collection_object_id,
				collecting_event_id,
				locality_id,
				agent_id,
				remark
		</cfquery>
		<cfif r.collection_object_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select guid from flat where collection_object_id=#r.collection_object_id#
			</cfquery>
			<cfset rt="cataloged_item">
			<cfset rs="#d.guid#">
			<cfset ri="#r.collection_object_id#">
			<cfset rl="/guid/#d.guid#">
		<cfelseif r.collecting_event_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select verbatim_date, verbatim_locality from collecting_event where collecting_event_id=#r.collecting_event_id#
			</cfquery>
			<cfset rt="collecting_event">
			<cfset rs="#d.verbatim_locality# (#d.verbatim_date#)">
			<cfset ri="#r.collecting_event_id#">
			<cfset rl="/showLocality.cfm?action=srch&collecting_event_id=#r.collecting_event_id#">
		<cfelseif r.agent_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select agent_name from preferred_agent_name where agent_id=#r.agent_id#
			</cfquery>
			<cfset rt="agent">
			<cfset rs="#d.agent_name#">
			<cfset ri="#r.agent_id#">
			<cfset rl="/info/agentActivity.cfm?agent_id=#r.agent_id#">
		<cfelseif r.locality_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select spec_locality from locality where locality_id=#r.locality_id#
			</cfquery>
			<cfset rt="locality">
			<cfset rs="#d.spec_locality#">
			<cfset ri="#r.locality_id#">
			<cfset rl="/showLocality.cfm?action=srch&locality_id=#r.locality_id#">
		<cfelse>
			<cfset rt="comment">
			<cfset rs="">
			<cfset ri="">
			<cfset rl="">
		</cfif>
		<cfset rft = ArrayNew(1)>
		<cfset rfi = ArrayNew(1)>
		<cfset rfs = ArrayNew(1)>
		<cfset rfl = ArrayNew(1)>
		<cfset rft[1]=rt>
		<cfset rfi[1]=ri>
		<cfset rfs[1]=rs>
		<cfset rfl[1]=rl>
		<cfset temp = QueryAddColumn(r, "REFTYPE", "VarChar",rft)>
		<cfset temp = QueryAddColumn(r, "REFID", "Integer",rfi)>
		<cfset temp = QueryAddColumn(r, "REFSTRING", "VarChar",rfs)>
		<cfset temp = QueryAddColumn(r, "REFLINK", "VarChar",rfl)>
		<cfreturn r>
	</cfoutput>
</cffunction>
<!------------------------------------------------------------------------------------->
<cffunction name="checkSql" access="public" output="true" returntype="boolean">
    <cfargument name="sql" required="true" type="string">
    <cfset nono="update,insert,delete,drop,create,alter ,set,execute,exec,begin,declare,all_tables,v$session,cast,sys.,ascii">
    <cfset dels="';','|',">
    <cfset safe=0>
    <cfloop index="i" list="#sql#" delimiters=" .,?!;:%$&""'/|[]{}()#chr(10)##chr(13)##chr(9)#@">
	    <cfif ListFindNoCase(nono, i)>
	        <cfset safe=1>
	    </cfif>
    </cfloop>
    <cfif safe is 0>
        <cfreturn true>
    <cfelse>
        <div class="error">
			Your query contains invalid characters. If you believe you have received this message in error, 
			please file a <a href="/info/bugs.cfm">bug report</a>.
		</div>
		<cfmail subject="check SQL" to="#Application.PageProblemEmail#" from="sqlCheck@#Application.fromEmail#" type="html">
			<br>
			The following SQL failed:
			<br>
			#sql#
			<br>Session: <cfdump var="#session#">
			<br>CGI: <cfdump var="#cgi#">
		</cfmail>	
		<cfabort>
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
	<cfif session.roles does not contain "coldfusion_user">
		<cfset session.dbuser=portalInfo.dbusername>
		<cfset session.epw = encrypt(portalInfo.dbpwd,cfid)>
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
	<cfset session.DownloadFileName = "ArctosData_#cfid##cftoken#.txt">
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
	<cfset session.meta_description=''>
	<cfset temp=cfid & '_' & cftoken & '_' & RandRange(0, 10000)>
	<cfset session.SpecSrchTab="SpecSrch" & temp>
	<cfset session.TaxSrchTab="TaxSrch" & temp>

	<!---------------------------- login ------------------------------------------------>
	<cfif isdefined("username") and len(username) gt 0 and isdefined("pwd") and len(pwd) gt 0>
		<cfquery name="getPrefs" datasource="cf_dbuser">
			select * from cf_users where username = '#username#' and password='#hash(pwd)#'
		</cfquery>
		<cfif getPrefs.recordcount is 0>
			<cfset session.username = "">
			<cfset session.epw = "">
       		<cflocation url="login.cfm?badPW=true&username=#username#">
		</cfif>
		<cfset session.username=username>
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
		<cfset session.showObservations = "#getPrefs.showObservations#">
		<cfset session.resultcolumnlist = "#getPrefs.resultcolumnlist#">
		<cfif len(#getPrefs.fancyCOID#) gt 0>
			<cfset session.fancyCOID = "#getPrefs.fancyCOID#">
		<cfelse>
			<cfset session.fancyCOID = "">
		</cfif>
		<cfif len(#getPrefs.result_sort#) gt 0>
			<cfset session.result_sort = "#getPrefs.result_sort#">
		<cfelse>
			<cfset session.result_sort = "">
		</cfif>	
		<cfif len(#getPrefs.CustomOtherIdentifier#) gt 0>
			<cfset session.customOtherIdentifier = "#getPrefs.CustomOtherIdentifier#">
		<cfelse>
			<cfset session.customOtherIdentifier = "">
		</cfif>
		<cfif #getPrefs.bigsearchbox# is 1>
			<cfset session.searchBy="bigsearchbox">
		<cfelse>
			<cfset session.searchBy="">
		</cfif>	
		<cfif #getPrefs.killRow# is 1>
			<cfset session.killRow="1">
		<cfelse>
			<cfset session.killRow="0">
		</cfif>
		<cfset session.locSrchPrefs=getPrefs.locSrchPrefs>
		<cfquery name="logLog" datasource="cf_dbuser">
			update cf_users set last_login = sysdate where username = '#session.username#'
		</cfquery>
		<cfif listcontainsnocase(session.roles,"coldfusion_user")>
			<cfset session.dbuser = "#getPrefs.username#">
			<cfset session.epw = encrypt(pwd,cfid)>
			<cftry>
				<cfquery name="ckUserName" datasource="uam_god">
					select agent_id from agent_name where agent_name='#session.username#' and
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
			<cfset session.myAgentId=#ckUserName.agent_id#>		
		<cfset pwtime =  round(now() - getPrefs.pw_change_date)>
		<cfset pwage = Application.max_pw_age - pwtime>
		<cfif pwage lte 0>
			<cfset session.force_password_change = "yes">
			<cflocation url="ChangePassword.cfm">
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
<!----------------------------------------------------->
<cffunction name="getMediaRelations" access="public" output="false" returntype="Query">
	<cfargument name="media_id" required="true" type="numeric">
	<cfquery name="relns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media_relations,
		preferred_agent_name
		where
		media_relations.created_by_agent_id = preferred_agent_name.agent_id and
		media_id=#media_id#
	</cfquery>
	<cfset result = querynew("media_relations_id,media_relationship,created_agent_name,related_primary_key,summary,link")>
	<cfset i=1>
	<cfloop query="relns">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "media_relations_id", "#media_relations_id#", i)>	
		<cfset temp = QuerySetCell(result, "media_relationship", "#media_relationship#", i)>
		<cfset temp = QuerySetCell(result, "created_agent_name", "#agent_name#", i)>
		<cfset temp = QuerySetCell(result, "related_primary_key", "#related_primary_key#", i)>
		<cfset table_name = listlast(media_relationship," ")>
		<cfif table_name is "locality">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					higher_geog || ': ' || spec_locality data 
				from 
					locality, 
					geog_auth_rec 
				where 
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					locality.locality_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/showLocality.cfm?action=srch&locality_id=#related_primary_key#", i)>
		<cfelseif #table_name# is "agent">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select agent_name data from preferred_agent_name where agent_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
		<cfelseif table_name is "collecting_event">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					higher_geog || ': ' || verbatim_locality || ' (' || verbatim_date || ')' data 
				from 
					collecting_event,
					locality, 
					geog_auth_rec 
				where 
					collecting_event.locality_id=locality.locality_id and
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					collecting_event.collecting_event_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/showLocality.cfm?action=srch&collecting_event_id=#related_primary_key#", i)>
		<cfelseif table_name is "accn">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					collection || ' ' || accn_number data 
				from 
					collection,
					trans, 
					accn 
				where 
					collection.collection_id=trans.collection_id and
					trans.transaction_id=accn.transaction_id and
					accn.transaction_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/editAccn.cfm?Action=edit&transaction_id=#related_primary_key#", i)>
		<cfelseif table_name is "cataloged_item">
		<!--- upping this to uam_god for now - see Issue 135
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		---->
			<cfquery name="d" datasource="uam_god">
				select collection || ' ' || cat_num || ' (' || scientific_name || ')' data from 
				cataloged_item,
                collection,
                identification
                where
                cataloged_item.collection_object_id=identification.collection_object_id and
                accepted_id_fg=1 and
                cataloged_item.collection_id=collection.collection_id and
                cataloged_item.collection_object_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/SpecimenResults.cfm?collection_object_id=#related_primary_key#", i)>
		<cfelseif table_name is "media">
			<cfquery name="d" datasource="uam_god">
				select media_uri data from media where media_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/media.cfm?action=edit&media_id=#related_primary_key#", i)>
		<cfelseif table_name is "publication">
			<cfquery name="d" datasource="uam_god">
				select formatted_publication data from formatted_publication where format_style='long' and 
				publication_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/SpecimenUsage.cfm?publication_id=#related_primary_key#", i)>
		<cfelseif #table_name# is "project">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select project_name data from 
				project where project_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/ProjectDetail.cfm?project_id=#related_primary_key#", i)>
		<cfelseif table_name is "taxonomy">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select display_name data,scientific_name from 
				taxonomy where taxon_name_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/name/#d.scientific_name#", i)>
		<cfelse>
		<cfset temp = QuerySetCell(result, "summary", "#table_name# is not currently supported.", i)>
		</cfif>
		<cfset i=i+1>
	</cfloop>
	<cfreturn result>
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