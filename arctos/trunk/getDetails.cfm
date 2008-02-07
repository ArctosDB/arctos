 
<cfif isdefined("cat_num")>
	<cfquery name="getCOID" datasource="#Application.web_user#">
		SELECT
			collection_object_id
		FROM 
			cataloged_item
		WHERE
				cat_num=#cat_num# AND
			 collection_id=#collection_id#
	</cfquery>
	<cfoutput>
		<cfif #getCOID.recordcount# is 1>
			<script language="JavaScript">
				this.location.href="SpecimenDetail.cfm?collection_object_id=#getCOID.collection_object_id#&content_url=editParts.cfm"
			</script>
		<cfelse>
			<font color="##FF0000" size="+1">#getCOID.recordcount# records matched your query!</font>		
	  </cfif>
	</cfoutput>
	<cfelse>
		<cfabort>
</cfif>