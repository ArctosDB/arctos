<cffunction name="unsafeSql" access="public" output="false" returntype="boolean">
    <cfargument name="sql" required="true" type="string">
    <cfset nono="update,insert,delete,drop,create,alter,set,execute,exec,begin,end,declare,all_tables,v$session">
    <cfset dels="';','|',">
    <cfset safe=0>
    <cfloop index="i" list="#sql#" delimiters=" .,?!;:%$&""'/|[]{}() chr(10)chr(13)chr(9)">
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

<cffunction name="getMediaRelations" access="public" output="false" returntype="Query">
	<cfargument name="media_id" required="true" type="numeric">
	<cfquery name="relns" datasource="#application.web_user#">
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
		<cfif #table_name# is "locality">
			<cfquery name="d" datasource="#application.web_user#">
				select spec_locality data from #table_name# where locality_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/SpecimenResults.cfm?locality_id=#related_primary_key#", i)>
		<cfelseif #table_name# is "agent">
			<cfquery name="d" datasource="#application.web_user#">
				select agent_name data from preferred_agent_name where agent_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/SpecimenResults.cfm?coll=#d.data#", i)>
		<cfelseif #table_name# is "collecting_event">
			<cfquery name="d" datasource="#application.web_user#">
				select verbatim_locality || ' (' || verbatim_date || ')' data from 
				collecting_event where collecting_event_id=#related_primary_key#
			</cfquery>
			<cfset temp = QuerySetCell(result, "summary", "#d.data#", i)>
            <cfset temp = QuerySetCell(result, "link", "/SpecimenResults.cfm?collecting_event_id=#related_primary_key#", i)>
		<cfelseif #table_name# is "cataloged_item">
			<cfquery name="d" datasource="#application.web_user#">
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
	<cfset out = replace(out,'"',"&quot;","all")>
	<cfset out = replace(out,'>',"&qt;","all")>
	<cfset out = replace(out,'<',"&lt;","all")>
	<cfreturn out>
</cffunction>
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
	<cfargument name="typesRequired" required="false" type="numeric" default="2">
	<cfargument name="length" required="false" type="numeric" default="6">


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