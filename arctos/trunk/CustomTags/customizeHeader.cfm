<cfset client.currentStyleSheet = ''>
<cfif isdefined("attributes.collection_id") and len(attributes.collection_id) gt 0>
	<cfquery name="getCollApp" datasource="#Application.web_user#">
		select * from cf_collection_appearance where collection_id = #attributes.collection_id#
	</cfquery>
	<cfif getCollApp.collection_id gt 0>
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
				changeStyle('#ssName#');
			</script>
			<cfset client.currentStyleSheet = '#ssName#'>
		</cfoutput>
	<cfelse>
		<!--- no collection-specific settings, they may have an exclusive_collection_id set and we do NOT want
		to show other collection's records with those settings - revert to default --->
		<cfoutput>
			<script>
				var header_color = document.getElementById('header_color');
				header_color.style.backgroundColor='#Application.header_color#';
				var headerImageCell = document.getElementById('headerImageCell');
				headerImageCell.innerHTML='<a target="_top" href="#Application.collection_url#"><img src="#Application.header_image#" alt="Arctos" border="0"></a>';
				var collectionCell = document.getElementById('collectionCell');
				var contents = '<a target="_top" href="#Application.collection_url#" class="novisit">';
				contents += '<span class="headerCollectionText">#Application.collection_link_text#</span></a>';
				contents += '<br>';
				contents += '<a target="_top" href="#Application.institution_url#" class="novisit">';
				contents += '<span class="headerInstitutionText">#Application.institution_link_text#</span></a>';
				collectionCell.innerHTML=contents;
				changeStyle('');
			</script>
		</cfoutput>
	</cfif>
</cfif>