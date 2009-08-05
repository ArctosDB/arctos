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
			<cfhtmlhead text='<link rel="alternate stylesheet" type="text/css" href="/includes/css/#getCollApp.STYLESHEET#" title="#ssName#">'>
			<script>
				var header_color = document.getElementById('header_color');
				header_color.style.backgroundColor='#getCollApp.header_color#';
				var headerImageCell = document.getElementById('headerImageCell');
				headerImageCell.innerHTML='<a target="_top" href="#getCollApp.collection_url#"><img src="#getCollApp.header_image#" alt="Arctos" border="0"></a>';
				var collectionCell = document.getElementById('collectionCell');
				var contents = '<a target="_top" href="#getCollApp.collection_url#" class="novisit">';
				contents += '<span class="headerCollectionText">#getCollApp.collection_link_text#</span></a>';
				contents += '<br>';
				contents += '<a target="_top" href="#getCollApp.institution_url#" class="novisit">';
				contents += '<span class="headerInstitutionText">#getCollApp.institution_link_text#</span></a>';
				collectionCell.innerHTML=contents;
				var creditCell = document.getElementById('creditCell');
				var c='<span  class="hdrCredit">#getCollApp.header_credit#</span>';
				creditCell.innerHTML=c;
				changeStyle('#ssName#');
			</script>
			<cfset session.currentStyleSheet = '#ssName#'>
		</cfoutput>
</cfif>