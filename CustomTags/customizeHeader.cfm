<cfset session.currentStyleSheet = ''>
<cfif isdefined("attributes.collection_id") and len(attributes.collection_id) gt 0>
	<cfquery name="getCollApp" datasource="cf_dbuser">
		select * from cf_collection where collection_id = #attributes.collection_id#
	</cfquery>
	<cfif len(getCollApp.header_color) is 0>
		<cfquery name="getCollApp" datasource="cf_dbuser">
			select * from cf_collection where cf_collection_id = 0
		</cfquery>
	</cfif>
	<cfoutput>
		<cfset ssName = replace(getCollApp.stylesheet,".css","","all")>
		<cfif len(trim(getCollApp.STYLESHEET)) gt 0>
			<cfhtmlhead text='<link rel="alternate stylesheet" type="text/css" href="/includes/css/#getCollApp.STYLESHEET#" title="#ssName#">'>
			<cfset session.currentStyleSheet = '#ssName#'>
		</cfif>
		<script>
			try {
			var header_color = document.getElementById('header_color');
			header_color.style.backgroundColor='#getCollApp.header_color#';
			var headerImageCell = document.getElementById('headerImageCell');
			headerImageCell.innerHTML='<a target="_top" href="#getCollApp.collection_url#"><img src="#getCollApp.header_image#" alt="Arctos" border="0"></a>';

			var collectionCell = document.getElementById('header-link-cell');
			var contents = '<div>';
				contents += '<a target="_top" href="#getCollApp.collection_url#" class="novisit">';
				contents += '<span class="headerInstitutionText">#getCollApp.institution_link_text#</span>';
				contents += '</a>';
			contents += '</div>';

			contents += '<div>';
			contents += '<a target="_top" href="#getCollApp.institution_url#" class="novisit">';
			contents += '<span class="headerInstitutionText">#getCollApp.institution_link_text#</span>';
			contents += '</a>';
			contents += '</div>';

			if (len(getCollApp.header_credit) gt 0)  {
				contents += '<div>';
				contents += '<span  class="hdrCredit">#getCollApp.header_credit#</span>';
				contents += '</div>';
			}
			collectionCell.innerHTML=contents;
			changeStyle('#ssName#');
			} catch(e) {}
		</script>
	</cfoutput>
</cfif>
