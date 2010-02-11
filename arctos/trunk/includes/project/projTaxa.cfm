<cfoutput>
	<script>
		jQuery(document).ready(function() {
			var ptl="/includes/taxonomy/specTaxMedia.cfm?taxon_name_id=#taxon_name_id#";
			jQuery.get(ptl, function(data){
				 jQuery('##taxDiv#taxon_name_id#').html(data);
			})
		});
	
	function load(name){
			//var el=document.getElementById(name);
			
			jQuery.get(ptl, function(data){
				 jQuery('##' + name).html(data);
			})
		}
	</script>	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			taxonomy.taxon_name_id,
			scientific_name
		from 
			project_taxonomy, 
			taxonomy
		where
			taxonomy.taxon_name_id=project_taxonomy.taxon_name_id and
			project_id = #project_id#
	</cfquery>
	<cfif d.recordcount gt 0>
		<h2>Taxonomy</h2>
		<ul>
			<cfloop query="d">
				<li>
					<a href="/name/#scientific_name#">#scientific_name#</a>
					<div id="taxDiv#taxon_name_id#">
					</div>
				</li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>