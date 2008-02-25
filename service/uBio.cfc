<cfcomponent>
	<cfoutput>
		<cffunction name="classificationbank_object" access="remote" returntype="string" output="no">
			<cfargument required="true" name="hierarchiesID" type="numeric">
			<cfhttp url="http://www.ubio.org/webservices/service.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classificationbank_object">
				<cfhttpparam type="url" name="hierarchiesID" value="#hierarchiesID#">
				<cfhttpparam type="url" name="childrenFlag" value="1">
				<cfhttpparam type="url" name="justificationsFlag" value="1">
				<cfhttpparam type="url" name="synonymsFlag" value="1">
				<cfhttpparam type="url" name="version" value="2.0">
			</cfhttp>
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	  	<!---
	  	
	  	http://www.ubio.org/webservices/service.php?function=classificationbank_object&hierarchiesID=2478349&synonymsFlag=1&childrenFlag=1&keyCode=0dcb58874a48e95725f591152981365d45833b56
	  	
	  	
	  	
	  	http://www.ubio.org/webservices/service.php?function=classificationbank_object&hierarchiesID=2478349&synonymsFlag=1&childrenFlag=1&keyCode=0dcb58874a48e95725f591152981365d45833b56
	  --->
	  	
	  	
	  	<cffunction name="namebank_search" access="remote" returntype="string" output="no">
			<cfargument required="true" name="searchName" type="string">
			<cfhttp url="http://www.ubio.org/webservices/service.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="namebank_search">
				<cfhttpparam type="url" name="searchName" value="#searchName#">
				<cfhttpparam type="url" name="sci" value="2">
				<cfhttpparam type="url" name="vern" value="1">
			</cfhttp>
			
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	 
	 	<cffunction name="classificationbank_search" access="remote" returntype="string" output="no">
			<cfargument required="true" name="namebankID" type="numeric">
			<cfhttp url="http://www.ubio.org/webservices/service.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classificationbank_search">
				<cfhttpparam type="url" name="namebankID" value="#namebankID#">
			</cfhttp>
			
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	 	<cffunction name="namebank_object" access="remote" returntype="string" output="no">
			<cfargument required="true" name="namebankID" type="numeric">
			<cfhttp url="http://www.ubio.org/webservices/service.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="namebank_object">
				<cfhttpparam type="url" name="namebankID" value="#namebankID#">
			</cfhttp>
			
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	  	
	  	<cffunction name="classification_list" access="remote" returntype="string" output="no">
			<cfargument required="true" name="namebankID" type="numeric">
			<cfhttp url="http://www.ubio.org/webservices/service.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classification_list">
				<cfhttpparam type="url" name="namebankID" value="#namebankID#">
			</cfhttp>
			
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	  	
	  	
	
	
	</cfoutput>
</cfcomponent>