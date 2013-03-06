<img src="http://maps.google.com/maps/api/staticmap?markers=color:red|size:tiny|57.5469444444,-134.4030555556&sensor=false&size=150x150&maptype=roadmap&zoom=2">


<cffunction name="HMAC_SHA1" returntype="binary" access="public" output="false">
   <cfargument name="signKey" type="string" required="true" />
   <cfargument name="signMessage" type="string" required="true" />

   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />

   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
   <cfset var mac = createObject("java","javax.crypto.Mac") />

   <cfset key = key.init(jKey,"HmacSHA1") />

   <cfset mac = mac.getInstance(key.getAlgorithm()) />
   <cfset mac.init(key) />
   <cfset mac.update(jMsg) />

   <cfreturn mac.doFinal() />

</cffunction>


<cfoutput>
	<cfset baseURL = "http://maps.googleapis.com">
	<br>baseURL: #baseURL#


	<cfset remainingURL="/maps/api/geocode/json"><!--- google test video --->
		<cfset remainingURL="/maps/api/staticmap">

	<br>remainingURL: #remainingURL#

		<cfset parameters = 'latlng=40.7%2c-73.96&client=gme-geotses&sensor=true'><!--- google test video --->


	<cfset parameters = 'center=#URLEncodedFormat("38.909084,-77.036767")#&sensor=false&zoom=13&size=600x300&client=gme-museumofvertebrate1'>


	<br>parameters: #parameters#
	<cfset fullURL = baseURL & remainingURL & "?" & parameters>
	<br>fullURL: #fullURL#
	<cfset urlToSign=remainingURL & "?" & parameters>
	<br>urlToSign: #urlToSign#
		<cfset privatekey = "BiQKYDplSq6r5GxxlaBCICXkT-A="><!--- google test video --->
	<cfset privatekey = "NSXubfdQUO4jQj1nGbeZVE27enI=">



	<br>privatekey: <cfdump var=#privatekey#>

	<cfset privatekeyBase64 = Replace(Replace(privatekey,"-","+","all"),"_","/","all")>


	<cfset decodedKeyBinary = BinaryDecode(privatekeyBase64,"base64")>

		<br>decodedKeyBinary: <cfdump var=#decodedKeyBinary#>


<cfset  secretKeySpec = CreateObject("java","javax.crypto.spec.SecretKeySpec").init(decodedKeyBinary,"HmacSHA1")>

<cfscript>
  Hmac  = CreateObject("java","javax.crypto.Mac").getInstance("HmacSHA1");

	Hmac.init(secretKeySpec);


	 encryptedBytes = Hmac.doFinal(toBinary(toBase64(urlToSign)));
	  signature = BinaryEncode(encryptedBytes, "base64");

	</cfscript>
	<!--------------


	<br>decodedKeyBinary: <cfdump var=#decodedKeyBinary#>

	<cfset encryptedBytes=HMac(urlToSign, privatekeyBase64, "HmacSHA1")>
	<br>encryptedBytes: #encryptedBytes#

		<cfset binaryEncryptedBytes=ToBinary(encryptedBytes)>


	<cfset signature = BinaryEncode(binaryEncryptedBytes, "base64")>


	<cfset signature=HMAC_SHA1(privatekeyBase64,urlToSign)>
		<br>signature: <cfdump var=#signature#>
	<cfset sigBin=BinaryEncode(signature,"Base64")>


		<br>sigBin: #sigBin#

		---------->


	<cfset signatureModified = Replace(Replace(signature,"+","-","all"),"/","_","all")>
	<br>signatureModified: #signatureModified#





	<cfset theFinalURL=fullURL & "&signature=" & signatureModified>

		<br>theFinalURL: #theFinalURL#

</cfoutput>



