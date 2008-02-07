<cfinclude template="/includes/_footer.cfm">
<!----
<cfif isdefined("attributes.collection_id") AND len (#attributes.collection_id#) gt 0>
	<cfquery name="getCollApp" datasource="#Application.web_user#">
		select * from cf_collection_appearance where collection_id = #attributes.collection_id#
	</cfquery>
	<cfif #getCollApp.recordcount# gt 0>
		<cfoutput>
		<cftry>
			<cfif len(#getCollApp.stylesheet#) gt 0>
				<cfset ssName = replace(getCollApp.stylesheet,".css","","all")>
				<cfhtmlhead text='<link rel="alternate stylesheet" type="text/css" href="/includes/css/#getCollApp.stylesheet#" title="#ssName#">'>
				<script>
					changeStyle('#ssName#');
				</script>
			</cfif>
			<cfset header_imageHTML='<a href="#getCollApp.collection_url#"><img src="#getCollApp.header_image#" alt="Arctos" border="0"></a>'>
			<script>
				document.getElementById('header_color').setAttribute('style','background-color:#getCollApp.header_color#');
				document.getElementById('header_color').innerHTML='#header_imageHTML#';
			</script>
		<cfcatch>
			<!--- 
				do nothing, couldn't process the header
				This is almost certainly because a CFFLUSH was called - we 
				just don't get a title on the pages
			 --->
		</cfcatch>
		</cftry>
		</cfoutput>
		
		
<div style='background-color:#Client.header_color#;'>
	<!--- allow option for header that doesn't eat a bunch of screen space --->
	<table width="95%" cellpadding="0" cellspacing="0" border="0" id="headerContent">
		<tr>
			<td width="95" nowrap>
				<a href="#client.collection_url#"><img src="#Client.header_image#" alt="Arctos" border="0"></a>
			</td>
			<td align="left">
				<table>
					<tr>
						<td rowspan="2">
							<img src="/images/nada.gif" width="15px" border="0" alt="spacer">
						</td>
						<td align="left" nowrap>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td align="left" nowrap>
							<a href="#client.collection_url#" class="novisit">
								<span class="headerCollectionText">
										#client.collection_link_text#
								</span>
							</a>
							<br>
							<a href="#client.institution_url#" class="novisit">
								<span class="headerInstitutionText">
									#client.institution_link_text#
								</span>
							</a>
						</td>
					</tr>			 
				</table>
			</td>
		
		
		
		
				
	</cfif>
</cfif>
	
	
		---->
		

	
	
	
	
	
	
	
	<!----
	
	
	
	
	
	
	
	
	
	<cfquery name="whatColl" datasource="#Application.web_user#">
		select collection_cde, institution_acronym
		from collection where collection_id = #attributes.collection_id#
	</cfquery>
	<cfset institution = "#whatColl.institution_acronym#">
	<cfset collection = "#whatColl.collection_cde#">
<cfelse>
	<cfif isdefined("attributes.institution")>
		<cfset institution = "#attributes.institution#">
	</cfif> 
	<cfif isdefined("attributes.collection")>
		<cfset collection = "#attributes.collection#">
	</cfif>
</cfif>
<cfif len(#institution#) gt 0 and len(#collection#) gt 0>
	<cfset instColl = "#institution##collection#">
	<cfset hasFooter="UAMMamm,MSBMamm,DGRMamm,KWPEnto">
	<cfif listfind(hasFooter,instColl)>
		<cfset footer = "/includes/_#instColl#Footer.cfm">
	<cfelse>
		<cfset footer = "/includes/_footer.cfm">
	</cfif>
<cfelseif len(#institution#) gt 0>
	<!--- just institutional footer, see if we have one --->
	<cfset hasIFooter = "UAM,DGR,MSB,KWP,UAMObs">
	<cfif listfind(hasIFooter,institution)>
		<cfset footer = "/includes/_#institution#Footer.cfm">
	<cfelse>
		<cfset footer = "/includes/_Footer.cfm">
	</cfif>
<cfelse>
	<cfset footer = "/includes/_Footer.cfm">
</cfif>
<cfinclude template="#footer#">
---->