<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("publication_title")>
	Didn't get a publication_title.<cfabort>
</cfif>
<script>
	function useDOI(doi){
		parent.$("#doi").val(doi);
		parent.$(".ui-dialog-titlebar-close").trigger('click');
	}
</script>
<cfoutput>
	<form name="additems" method="post" action="findDOI.cfm">
		<label for="publication_title">Title</label>
		<textarea name="publication_title" class="hugetextarea">#publication_title#</textarea>
		<br><input type="submit" value="Find DOI">
	</form>
	<cfif len(publication_title) gt 0>
		<cfset lpt=len(publication_title)>

		<br>lpt: #lpt#

		<cfset fs=round(lpt*.3)>

		<br>fs: #fs#


		<cfset ls=round(lpt*.6)>

		<br>ls: #ls#

		<cfhttp url="http://search.crossref.org/dois?q=#publication_title#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<cfloop array="#x#" index="data_index">
			<div style="padding:.2em; border:1px dotted green">
				#data_index['fullcitation']#
				<ul>
					<li><a href="#data_index['doi']#" target="_blank" class="external">#data_index['doi']#</a></li>
					<cfset baredoi=replace(data_index['doi'],'http://dx.doi.org/','','all')>
					<li><span class="likeLink" onclick="useDOI('#baredoi#')">USe This DOI</span>
				</ul>
			</div>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">