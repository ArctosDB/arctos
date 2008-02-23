<cfcomponent>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfoutput>
		<cffunction name="namebank_search_canonical" access="remote" returntype="string" output="no">
			<cfargument required="true" name="classificationBankID" type="numeric">
			<cfhttp url="http://www.ubio.org/webservices/service_internal.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classificationbank_object">
				<cfhttpparam type="url" name="classificationBankID" value="#classificationBankID#">
				<cfhttpparam type="url" name="childrenFlag" value="1">
				<cfhttpparam type="url" name="ancestryFlag" value="1">
				<cfhttpparam type="url" name="citationsFlag" value="1">
				<cfhttpparam type="url" name="synonymsFlag" value="1">
				<cfhttpparam type="url" name="version" value="2.0">
			</cfhttp>
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	  	
	  	
	  	<cffunction name="namebank_search" access="remote" returntype="string" output="no">
			<cfargument required="true" name="searchName" type="string">
			<cfhttp url="http://www.ubio.org/webservices/service_internal.php" charset="utf-8" method="get">
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
			<cfhttp url="http://www.ubio.org/webservices/service_internal.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classificationbank_search">
				<cfhttpparam type="url" name="namebankID" value="#namebankID#">
			</cfhttp>
			
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	 

	</cfoutput>
</cfcomponent>