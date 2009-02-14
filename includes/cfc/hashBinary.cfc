<cfcomponent output="false">
<cffunction name="hashBinary" returntype="string" output="false" hint="Function to create an MD5 checksum of a binary Byte array similar to md5sum command on linux.  This is useful for creating md5 sums of jpg/png images for integrity verification" >
	<cfargument name="byteArray" type="Binary" required="true">
	<cfargument name="algorithm" type="string" required="false" default="MD5" hint="Any algorithm supported by java MessageDigest - eg: MD5, SHA-1,SHA-256, SHA-384, and SHA-512.  Reference: http://java.sun.com/javase/6/docs/technotes/guides/security/StandardNames.html##MessageDigest">
	<cfset var i = "">
	<cfset var checksumByteArray = "">
	<cfset var checksumHex = "">
	<cfset var hexCouplet = "">
	<cfset var digester = createObject("java","java.security.MessageDigest").getInstance(arguments.algorithm)>
			
	<cfset digester.update(byteArray,0,len(byteArray))>
	<cfset checksumByteArray = digester.digest()>
	
	<!--- Convert byte array to hex values --->
	<cfloop from="1" to="#len(checksumByteArray)#" index="i">
		<cfset hexCouplet = formatBaseN(bitAND(checksumByteArray[i],255),16)>
		<!--- Pad with 0's --->
		<cfif len(hexCouplet) EQ 1>
			<cfset hexCouplet = "0#hexCouplet#">
		</cfif>
		<cfset checkSumHex = "#checkSumHex##hexCouplet#">
	</cfloop>
	<cfreturn checkSumHex>	
</cffunction>
</cfcomponent>