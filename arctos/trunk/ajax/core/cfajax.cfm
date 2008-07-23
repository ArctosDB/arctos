<cfsetting enablecfoutputonly="yes">
<cfinclude template="settings.cfm">
<cfinclude template="security.cfm">
<!--- http://www.indiankey.com/cfajax --->

<!--- constants --->
<cfset DEFAULT_DELIMITER = ",">
<cfset DEFAULT_COMPLEX_RETURNTYPE = "array">
<cfset DEFAULT_INTERNAL_DELIMITER = chr(178)>
<cfset lineFeed =  "#Chr(10)#">

<cfif IsDefined("ajax")  AND ajax EQ "true">
	<!--- dont want to cache the page at all --->
	<cfheader name="Expires" value="Sun, 01 Jan 2005 05:00:00 GMT"> 
	<cfheader name="Cache-Control" value="no-cache, must-revalidate">
	<cfheader name="Pragma" value="no-cache">

	<cfscript>
		params = exactHttpDataParam();	//get post/get data
		
		//called for each batch
		prefix = "c0-";
		methodname = StructFind(params, "#prefix#methodname");
		variables.metaData = getMetadata(evaluate(methodname));
		result = "";
		
		variables.hintData = exactHintData();	//extract hint data
		id = StructFind(params, "#prefix#id");	//ajax call ID - used to communicate back with client
		
		variables.param = convertDataPassedToCFFunctionParam(prefix, params);	//figure out all the parameters that were passed

		functionName = methodname & "(" & variables.param & ")";	//CF function to be called, with required params

		variables.authenticationResult = authentication(hintData=variables.hintData, params=params);	
		variables.httpRequestMethodAuthenticationPassed = authenticationResult.httpRequestMethodAuthenticationPassed;  //if CFajax call passed Request Method authentication  GET or POST
		variables.clientAuthenticationCheckPassed = authenticationResult.clientAuthenticationCheckPassed;  //if CFAjax call passed the client authentication token
		variables.sessionCheckPassed = authenticationResult.sessionCheckPassed;  //holds value of If session authentication/check passed
	
		//Make sure that CFAjax call has passed the required authentication (if there was any) --->
		if ( (variables.httpRequestMethodAuthenticationPassed EQ true) OR (variables.clientAuthenticationCheckPassed EQ true) OR (variables.sessionCheckPassed EQ true) ) 
		{
			result = evaluate(functionName);   //execute the required CF function that was requested in CFAjax call
			
			/*if there is hint [meta data] that has to applied to result returned by coldfusion function
			then apply it now!*/
			variables.complexReturnDataType = DEFAULT_COMPLEX_RETURNTYPE;
			
			if (StructCount(variables.hintData) GT 0)
			{
				result = applyHint(result, variables.hintData);	//modify the coldfusion result based on hint data
	
				/*if specific .js return type is specified in hint, then change the return type to as requested 
					default return type is array*/
				if (StructKeyExists(variables.hintData, "jsreturn"))  variables.complexReturnDataType = variables.hintData.jsreturn;
			}
			result = convertResult(result, id, variables.complexReturnDataType);	//Convert the coldfusion result to, javascript data type
		}
	</cfscript>
		
	<cfoutput>
		****/ <!--- used for removing any extra information added by application.cfm --->
		<cfif (variables.httpRequestMethodAuthenticationPassed EQ true) AND (variables.clientAuthenticationCheckPassed EQ true) AND (variables.sessionCheckPassed EQ true)>
			#result#
			DWREngine._handleResponse('#id#', _#id#, true, true, true);
		<cfelse>
			DWREngine._handleResponse('#id#', '', #httpRequestMethodAuthenticationPassed#, #clientAuthenticationCheckPassed# , #sessionCheckPassed#);
		</cfif>
		 /* EOF CFAJAX */ <!--- /* EOF CFAJAX */ helpfull in removing debugging information or any extra information by onRequestEnd.cfm --->
	</cfoutput>
	<cfabort>
</cfif>

<cffunction name="convertDataPassedToCFFunctionParam" returntype="string" access="private" hint="convert the http param to CF param string">
	<cfargument name="prefix" type="string" required="yes" hint="prefix required to identify the call">
	<cfargument name="params" type="struct" required="yes" hint="get/post data">

	<cfset variables.param = "">
	<cfloop from="0" to="#StructCount(arguments.params)#" index="i">
		<cfif StructKeyExists(arguments.params, "#prefix#param#i#")>
			<cfset variables.var = StructFind(arguments.params, "#arguments.prefix#param#i#")>
		<cfelse>
			<cfbreak>
		</cfif>
		
		<cfif ListLen(variables.var, ":") GT 1>
			<cfset variables.firstPos = len(ListFirst(variables.var,":")) + 1>
			<cfif ListFirst(variables.var,":") EQ "number">
				<cfset variables.param = ListAppend(variables.param, mid(variables.var, variables.firstPos+1 , len(variables.var)-variables.firstPos) )>
			<cfelseif ListFirst(variables.var,":") EQ "boolean">
				<cfset variables.param = ListAppend(variables.param, mid(variables.var, variables.firstPos+1 , len(variables.var)-variables.firstPos) )>
			<cfelse>
				<cfset variables.param = ListAppend(variables.param,"""" & mid(variables.var, variables.firstPos+1 , len(variables.var)-variables.firstPos) & """")>
			</cfif>
		<cfelse>
			<cfset variables.param = ListAppend(variables.param,'""')>
		</cfif>
	</cfloop>
	<cfreturn variables.param>
</cffunction>

<cffunction name="exactHttpDataParam" returntype="struct" access="private" hint="gets http data i.e. form/get values">
	<cfset variables.params = StructNew()>	
	<cfif isDefined("Form") AND StructCount(Form) GT 0>
		<cfset variables.params =  StructCopy(form)>
	<cfelse>
		<cfif isDefined("url")>
			<cfset variables.params =  StructCopy(url)>
		</cfif>
	</cfif>
	<cfreturn variables.params>
</cffunction>


<cffunction name="exactHintData" returntype="struct" access="private" hint="parses hint data into CF struct">
	<!--- extract hint info, if any --->
	<cfset variables.hintData = StructNew()>
	<cfif isDefined("variables.metaData.hint")>
		<cfset variables._hint = trim(variables.metaData.hint)>
		<cfif len(variables._hint) GT 0>
			<cfloop list="#variables._hint#" index="item" delimiters=" ">
				<cfif ListLen(item, "=") GT 1>
					<cfset StructInsert(variables.hintData, trim(ListGetAt(item,1,"=")), replaceNoCase(trim( Mid(item, len(ListGetAt(item,1,"="))+2,len(item))),"'","","ALL") )>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<cfreturn variables.hintData>
</cffunction>

<cffunction name="authentication" returntype="struct" access="private" hint="returns back struct holding values of authentication status">
	<cfargument name="hintData" required="yes" type="struct" hint="hint value passed as a structure">
	<cfargument name="params" type="struct" required="yes" hint="get/post data">
	
	<cfscript>
		variables.retData = StructNew();
		variables.httpRequestMethodAuthenticationPassed = true;  //if CFajax call passed Request Method authentication  GET or POST
		variables.clientAuthenticationCheckPassed = true;	//if CFAjax call passed the client authentication token
		variables.sessionCheckPassed = true;		//holds value of If session authentication/check passed
	</cfscript>

	<!--- 
		first check if there is any Http Request method security applied  
		withing the function hint. Developer can restrict client access to POST , GET or both 
		type of http Request calls.
	--->
	<cfif StructKeyExists(arguments.hintData, "authenticateClient")>
		<cfset variables.authenticateClientValue = trim(arguments.hintData["authenticateClient"])>
		<cfif lcase(variables.authenticateClientValue) EQ "yes">
			<!--- 
				client authentication is enabled 
				Perform check if the authentication key was passed along with the request
				and if the key is valid
			--->
			<cfset variables.clientAuthenticationCheckPassed = false>  <!--- by default assume that authentication failed --->
			
			<!--- check if the authentication key was passed by client --->			
			<cfif StructKeyExists(arguments.params, "CLIENTAUTHENTICATIONKEY") >
				<!--- got the key --->
				<cfset variables.clientAuthenticationKey = trim(StructFind(arguments.params, "CLIENTAUTHENTICATIONKEY"))>
				<cfif len(variables.clientAuthenticationKey) GT 0>
					<!--- decode the key --->
					<cfset variables.DecodeData = decodeClientAuthenticationKey(key=variables.clientAuthenticationKey)>
					<cfdump var="#variables.DecodeData#">
					
					<!--- check if key is valid --->
					<cfif (StructKeyExists(variables.retData, "IPVERIFIED")) AND (StructFind(variables.retData, "IPVERIFIED") EQ true)>
						<!--- check if the time elapsed from when the key was generated is more then allowed --->
						<cfif (StructKeyExists(variables.retData, "TIMEELAPSED")) AND (StructFind(variables.retData, "TIMEELAPSED") LT cfajaxExpireClientRequestsAfterXMinutes)>
							<!--- passed both IP verification and key has not expired --->
							<cfset variables.clientAuthenticationCheckPassed = true>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
			
		</cfif>
	</cfif>
	
	<!--- 
		check for if the client authentication has been enabled, 
	--->
	<cfif StructKeyExists(arguments.hintData, "httpRequestMethodAllowed")>
		<!--- there is http method security enabled, time to check which all methods are allowed --->
		<cfset variables.httpMethod = trim(arguments.hintData["httpRequestMethodAllowed"])>
		<cfif len(variables.httpMethod) GT 0>
			<cfif ListFindNoCase(variables.httpMethod,cgi.REQUEST_METHOD) LTE 0>
				<!--- client failed Http Request method security --->
				<cfset variables.httpRequestMethodAuthenticationPassed = false>
			</cfif>
		</cfif>
	</cfif>
	
	
	<!--- 
		Is session authentication function defined.
		Developer can define custom function that perform session check to make
		sure if CFAjax call has access to data or not. 
	--->
	<cfif StructKeyExists(arguments.hintData, "sessioncheckfunction")>
		<cftry>
			<!--- custom session check function defined --->
			<cfset variables.sessionCheckFunctionName = arguments.hintData["sessioncheckfunction"] & "()">
			<!--- custom session check function executed, and return true or false value based on how session check was done --->
			<cfset variables.sessionCheckPassed = evaluate(variables.sessionCheckFunctionName)>
			<cfcatch type="any">
				<!--- if the session check was not complete, invalidate the function for security sake --->
				<cfset variables.sessionCheckPassed = false>
			</cfcatch>
		</cftry>
	</cfif>
	
	<!--- add authentication results to return struct --->
	<cfscript>
		StructInsert(variables.retData, "httpRequestMethodAuthenticationPassed" , variables.httpRequestMethodAuthenticationPassed);
		StructInsert(variables.retData, "clientAuthenticationCheckPassed" , variables.clientAuthenticationCheckPassed);
		StructInsert(variables.retData, "sessionCheckPassed" , variables.sessionCheckPassed);
	</cfscript>
	
	<!--- return all the authentication data --->
	<cfreturn variables.retData>
</cffunction>

<cffunction name="convertResult" returntype="string" access="private" hint="converts coldfusion data to javascript compatable data type">
	<cfargument name="var" required="yes">
	<cfargument name="id" required="yes">
	<cfargument name="complexReturnDataType" required="yes">
	
	<cfset variables.result =  "var _#id# = null;" & lineFeed>
	<cfif IsSimpleValue(arguments.var)>
		<cfset variables.result =  variables.result & "_#arguments.id# = " & parseResult(arguments.var, arguments.id, arguments.complexReturnDataType)>
	<cfelse>
		<cfset variables.result =  variables.result & parseResult(arguments.var, arguments.id, arguments.complexReturnDataType) & lineFeed>
	</cfif>
	<cfreturn variables.result>
</cffunction>

<cffunction name="parseResult" returntype="string" access="private">
	<cfargument name="var" required="yes">
	<cfargument name="id" required="yes">
	<cfargument name="complexReturnDataType" required="no">
	<cfargument name="addJsLineFeed" required="no" default="yes" type="boolean">
	
	<cfset variables.result = "">
	<cfif IsSimpleValue(arguments.var)>
		<!--- simple result --->
		<cfset variables.result = convertSimpleValue(arguments.var, arguments.addJsLineFeed)>
	<cfelseif IsQuery(arguments.var)>
		<!--- Query --->
		<cfset variables.counter = 0>
		<cfif arguments.complexReturnDataType eq "array">
			<cfset variables.result = variables.result & "_#id# = [" & lineFeed>
			<cfloop query="arguments.var">
				<cfset variables.counter = variables.counter + 1>
				<cfset variables.result = variables.result & "         { ">
				<cfset values="">
				<cfset variables.resultCopy = variables.result>
				
				<cfloop list="#arguments.var.ColumnList#" index="column">
					<cfset _result = column & ":" & parseResult(arguments.var["#column#"], arguments.id, arguments.complexReturnDataType, false)>
					<cfset values = ListAppend(values, _result)>
				</cfloop>
				<cfif variables.counter LT arguments.var.RecordCount>
					<cfset variables.result = variables.resultCopy & values & " }," & lineFeed>
				<cfelse>
					<cfset variables.result = variables.resultCopy & values & " }" & lineFeed>
				</cfif>
			</cfloop>
			<cfset variables.result = variables.result & "]" & lineFeed>
		<cfelse>
			<cfset variables.result =  variables.result & "function __#id#(#arguments.var.ColumnList#) {" & lineFeed>
			<cfloop list="#arguments.var.ColumnList#" index="column">
				<cfset variables.result =  variables.result & "this.#column# = #column#;" & lineFeed>
			</cfloop>
			<cfset variables.result =  variables.result & "}" & lineFeed>
			<cfset variables.result =  variables.result & "_#id# = new Array();" & lineFeed>
			
			<cfloop query="arguments.var">
				<cfset values="">
				<cfset variables.resultCopy = variables.result>
				<cfloop list="#arguments.var.ColumnList#" index="column">
					<cfset values = ListAppend(values,  parseResult(arguments.var["#column#"], arguments.id, arguments.complexReturnDataType, false))>
				</cfloop>
				<cfset newclass="new __#id#(" & values & ");" & lineFeed>
				<cfset variables.result =  variables.resultCopy & "_#id#[#variables.counter#] = " & newclass>
				<cfset variables.counter = variables.counter + 1> 
			</cfloop>
		</cfif>		

	<cfelseif IsArray(arguments.var)>
		<!--- Arrays --->
		<cfset variables.result =  variables.result & "_#id# = [ ">
		<cfloop from="1" to="#ArrayLen(arguments.var)#" index="i">
			<cfset variables.result =  variables.result &  parseResult(arguments.var[i], arguments.id, arguments.complexReturnDataType, false)>
			<cfif i LT ArrayLen(arguments.var)>
				<cfset variables.result =  variables.result &  ",">
			</cfif>
		</cfloop>
		<cfset variables.result =  variables.result & " ]">
	<cfelseif IsObject(arguments.var)>
		<!--- CFC --->
		<cfset variables.data = getMetadata(arguments.var)>
		<cfset variables.result =  variables.result & "function _#id#() {};" & lineFeed>
		<cfif  ((IsDefined('variables.data.type') AND variables.data.type eq "component"))>
			<cfset variables.result =  variables.result & "_#id# = new Array();" & lineFeed>
			<cfset variables.counter = 0>
			<cfloop collection="#arguments.var#" item="variables.varkeyName">
				<cfif (not IsCustomFunction(var[variables.varkeyName]))>
					<cfset variables.result =  variables.result & "_#id#.#variables.varKeyName# = " & parseResult(arguments.var[variables.varKeyName], arguments.id, arguments.complexReturnDataType)>
					<cfset variables.counter = variables.counter + 1> 
				</cfif>
			</cfloop>
		</cfif>
	<cfelseif IsStruct(arguments.var)>
		<!--- Structure --->
		<cfset variables.result = variables.result & "_#id# = [" & lineFeed>
		<cfset variables.counter = 0>
			
		<cfloop collection="#arguments.var#" item="item">
			<cfset variables.resultCopy = variables.result>

			<cfset variables.counter = variables.counter + 1> 
			<cfset variables.value = ListAppend("", "KEY:" & parseResult(item, arguments.id, arguments.complexReturnDataType, false))>
			<cfset variables.value = ListAppend(variables.value, "VALUE:" & parseResult(arguments.var[item], arguments.id, arguments.complexReturnDataType, false))>
			
			<cfif variables.counter LT StructCount(arguments.var)>
				<cfset variables.result = variables.resultCopy & "{ " & variables.value & " }," & lineFeed>
			<cfelse>
				<cfset variables.result = variables.resultCopy & "{ " & variables.value & " }" & lineFeed>
			</cfif>
		</cfloop>
		<cfset variables.result = variables.result & "]" & lineFeed>
	<cfelse>
		<!--- unhandled --->
	</cfif>
	<cfreturn variables.result>
</cffunction>

<cffunction name="applyHint" access="private" hint="applies the hint information to the data returned from CF function">
	<cfargument type="any" name="cfresult">
	<cfargument type="struct" name="hintData">
	
	<cfset variables.cfresult = arguments.cfresult>
	<cfset variables.hintData = arguments.hintData>
	<cfset variables.retData = variables.cfresult>

	<cfif StructKeyExists(variables.hintData, "type")>
		<cfset variables.hint = lcase(trim(variables.hintData.type))>
		<cfif (variables.hint EQ "keyvalue") or (variables.hint EQ "query")>
			<!--- figure out the delimiter used --->
			<cfif StructKeyExists(variables.hintData, "delimiter")>
				<cfset variables.delimiter = lcase(trim(variables.hintData.delimiter))>
			<cfelse>
				<cfset variables.delimiter = DEFAULT_DELIMITER>
			</cfif>
			
			<cfif StructKeyExists(variables.hintData, "listdelimiter")>
				<cfset variables.listdelimiter = lcase(trim(variables.hintData.listdelimiter))>
			<cfelse>
				<cfset variables.listdelimiter = DEFAULT_DELIMITER>
			</cfif>

			<cfset variables.fieldnames = "">
			<cfif StructKeyExists(variables.hintData, "fieldnames")>
				<cfset variables.fieldnames = lcase(trim(variables.hintData.fieldnames))>
			</cfif>

			<cfif IsSimpleValue(variables.cfresult)>
				<!--- check to see if its a list --->
				<cfif ListLen(variables.cfresult, listdelimiter) GT 0>
					<!--- yeh its a list convert it to array --->
					<cfset variables.cfResult = ListToArray(variables.cfresult, listdelimiter)>
				</cfif>
			</cfif>
			
			<!--- generate the query object --->
			<cfset variables._tempArray = ArrayNew(1)>
			
			<cfif IsArray(variables.cfresult)>
				<cfloop from="1" index="ctr" to="#ArrayLen(variables.cfresult)#">
					<cfif (variables.hint EQ "query")>
						<cfset ArrayAppend(variables._tempArray, Replace( variables.cfresult[ctr], variables.delimiter, DEFAULT_INTERNAL_DELIMITER, "ALL"))>
					<cfelse>
						<cfif ListLen( variables.cfresult[ctr], variables.delimiter) GT 1>
							<cfset ArrayAppend(variables._tempArray, ListGetAt(variables.cfresult[ctr], 1, variables.delimiter) & " #DEFAULT_INTERNAL_DELIMITER# " & ListGetAt(variables.cfresult[ctr], 2, variables.delimiter))>
						<cfelse>
							<cfset ArrayAppend(variables._tempArray, ListGetAt(variables.cfresult[ctr], 1, variables.delimiter) & " #DEFAULT_INTERNAL_DELIMITER# " & ListGetAt(variables.cfresult[ctr], 1, variables.delimiter))>
						</cfif>
					</cfif>
				</cfloop>
				
				<cfif (variables.hint EQ "query")>
					<cfif variables.fieldnames EQ "">
						<cfloop from="1" to="#ListLen( variables.cfresult[1], variables.delimiter)#" index="ctr">
							<cfset variables.fieldnames = ListAppend(variables.fieldnames, "FIELD#ctr#")>
						</cfloop>
					</cfif>
					<cfset variables.retData = generateQueryObject(fieldNames="#variables.fieldnames#", data=variables._tempArray)>
				<cfelse>
					<cfset variables.retData = generateQueryObject(fieldNames="key,value", data=variables._tempArray)>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfreturn variables.retData>
</cffunction>

<cffunction name="generateQueryObject" access="private" hint="creates a query object from a array">
	<cfargument type="string" name="fieldNames">
	<cfargument type="array" name="data">

	<cfset myQuery = QueryNew(arguments.fieldNames)>
	<cfloop from="1" to="#ArrayLen(arguments.data)#" index="i">
		<cfset newRow = QueryAddRow(MyQuery)>
		<cfset ctr=0>
		<cfloop list="#arguments.fieldNames#" index="field">
			<cfset ctr = ctr + 1>
			<cfset temp = QuerySetCell(myQuery, field, ListGetAt( arguments.data[i],ctr, DEFAULT_INTERNAL_DELIMITER ))>
		</cfloop>
	</cfloop>
	<cfreturn myQuery>
</cffunction>

<cffunction name="convertSimpleValue" returntype="string" access="private" hint="converts a simle value i.e. string to a javascript value">
	<cfargument name="var" required="yes">
	<cfargument name="addJsLineFeed" required="no" default="yes" type="boolean">	
	<cfif arguments.addJsLineFeed EQ true>
		<cfreturn "'" &  JSStringFormat(arguments.var) & "';" & lineFeed>
	<cfelse>
		<cfreturn "'" & JSStringFormat(arguments.var) & "'">
	</cfif>
</cffunction>

<cfsetting enablecfoutputonly="No">