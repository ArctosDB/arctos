	<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from locality where locality_remarks like '%{"UTM":"%'
	</cfquery>



<cfoutput>
	<cfset csv="locality_id,northing, easting, zone">
<cfloop query="one">
	<hr>#locality_remarks#
	<cftry>
	<cfset lremk=mid(locality_remarks,find('{',locality_remarks,1),find('}',locality_remarks,1))>
	<br>lremk:#lremk#
	<cfset j=DeserializeJSON(lremk)>
	<cfset u=j.UTM>
	<cfset n=replace(listgetat(u,1," "),'N','')>
	<br>n:#n#
	<cfset e=replace(listgetat(u,2," "),'E','')>
	<br>e:#e#
	<cfset z=listgetat(u,4," ")>
	<br>z:#z#
	<cfset csv=csv & chr(10) & "#locality_id#,#n#,#e#,#z#">
	<cfcatch><p>----------------------------------------------------------------------FAIL-----------------------------------------------------------</p></cfcatch>
</cftry>

</cfloop>
<textarea>#csv#</textarea>

<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>

</cfoutput>
