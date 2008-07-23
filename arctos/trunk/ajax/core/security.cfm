<cfsetting enablecfoutputonly="yes">
<cffunction name="createClientAuthenticationKey" returntype="string" output="false">
	<cfset initData = DateFormat(now(), "mm/dd/yyyy") & " " & TimeFormat(now()," hh:mm tt")>
	<cfset data = "IP=#CGI.REMOTE_ADDR#;DATE=#initData#">
	<cfset encryptedData = URLEncodedFormat(Encrypt(data, cfajaxPrivateEncryptionKey))>
	<cfreturn encryptedData>
</cffunction>

<cffunction name="decodeClientAuthenticationKey" returntype="struct" output="false">
	<cfargument name="key" type="string" required="yes" hint="Encrypted key">
	<cfset variables.retData = StructNew()>
	
	<cftry>
		<cfset variables.localKey = URLDecode(arguments.key)>
		<cfset variables.decodedKey = Decrypt(variables.localKey, cfajaxPrivateEncryptionKey)>
		<cfloop list="#variables.decodedKey#"  index="idx" delimiters=";">
			<cfset StructInsert(variables.retData, ListGetAt(idx,1,"="), ListGetAt(idx,2,"="))>
		</cfloop>
		
		<cfif StructKeyExists(variables.retData, "DATE")>
			<cfset StructInsert(variables.retData, "TIMEELAPSED", DateDiff("n", StructFind(variables.retData, "DATE"), now()))>
		</cfif>
		
		<cfif StructKeyExists(variables.retData, "IP")>
			<cfif trim(StructFind(variables.retData, "IP")) EQ trim(CGI.REMOTE_ADDR)>
				<cfset StructInsert(variables.retData, "IPVERIFIED", true)>
			<cfelse>
				<cfset StructInsert(variables.retData, "IPVERIFIED", false)>
			</cfif>
		</cfif>
		<cfcatch type="any">
			<!--- 
				Log the error if you want to.
				#cfcatch.Message# 
			--->
		</cfcatch>
	</cftry>
	<cfreturn variables.retData>
</cffunction>

<cfsetting enablecfoutputonly="No">