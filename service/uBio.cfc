<cfcomponent>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfoutput>
		<cffunction name="namebank_search_canonical" access="remote" returntype="string" output="no">
			<cfhttp url="http://www.ubio.org/webservices/service_internal.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="function" value="classificationbank_object">
				<cfhttpparam type="url" name="classificationBankID" value="2038379">
				<cfhttpparam type="url" name="childrenFlag" value="1">
				<cfhttpparam type="url" name="ancestryFlag" value="1">
				<cfhttpparam type="url" name="citationsFlag" value="1">
				<cfhttpparam type="url" name="synonymsFlag" value="1">
				<cfhttpparam type="url" name="version" value="2.0">
			</cfhttp>
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	  	<cffunction name="namebank_search" access="remote" returntype="string" output="no">
			<cfhttp url="http://www.ubio.org/webservices/service_internal.php" charset="utf-8" method="get">
				<cfhttpparam type="url" name="keyCode" value="0dcb58874a48e95725f591152981365d45833b56">
				<cfhttpparam type="url" name="search" value="Alces">
				<cfhttpparam type="url" name="version" value="2.0">
			</cfhttp>
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	 
	</cfoutput>
</cfcomponent>