<cfinclude template="/includes/_frameHeader.cfm">
<cfoutput>
<cfif not isdefined("url.collection_object_id") or len(url.collection_object_id) is 0>
	<div class="error">Error.</div>
	<cfabort>
</cfif>
<cfquery name="isThere" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
	select count(*) c from attributes where attribute_type='image confirmed' and collection_object_id=#url.collection_object_id#
</cfquery>
<cfif isThere.c is 1>
	<div class="error">This image is already confirmed. Check Attributes.</div>
	<cfabort>
</cfif>
<cfquery name="nextID" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
	select max(attribute_id) + 1 as nextID from attributes
</cfquery>
			
<cfquery name="newAtt" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
	insert into attributes (
		attribute_id,
		COLLECTION_OBJECT_ID,
		DETERMINED_BY_AGENT_ID,
		ATTRIBUTE_TYPE,
		ATTRIBUTE_VALUE,
		DETERMINED_DATE
	) values (
		#nextID.nextID#,
		#url.collection_object_id#,
		#session.myAgentId#,
		'image confirmed',
		'yes',
		'#dateformat(now(),"dd-mmm-yyyy")#'
	)
</cfquery>
<script>
	var s=opener.document.getElementById('ala_image_confirm');
	s.innerHTML='Thank you!';
	self.close();
</script>

</cfoutput>