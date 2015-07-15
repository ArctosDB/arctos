<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("publication_title")>
	Didn't get a publication_title.<cfabort>
</cfif>
<style>
	.mightbe{padding:.2em; margin:.2em; border:2px solid green;}
	.probablynot{padding:.2em;margin:.2em; border:1px solid orange;}
	#help{display:none; border:1em solid black;margin:1em;padding:1em;}
</style>
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
		<cfset pt=urldecode(publication_title)>
		<cfset startttl=refind('[0-9]{4}\.',pt) + 5>
		<cfset noauths=mid(pt,startttl,len(pt))>
		<cfset stopttl=refind('\.',noauths)>
		<cfset ttl=Mid(pt, startttl, stopttl)>
		<cfset ttl=rereplace(ttl,'<[^>]*(?:>|$)','','all')>
		<cfset stripttl=ucase(trim(rereplacenocase(ttl, '[^a-z0-9]', '', 'all')))>
		<cfif len(stripttl) lt 10>
			<p style="border:2px solid red;padding:1em;margin:1em;text-align:center;">
				If this is a journal article, it's probably not formatted correctly.
			</p>
		</cfif>
		<br>COLOR KEY: orange=probably wrong; green=possibly correct.
		<span class="likeLink" onclick="$('##help').toggle()">help</span>
		<div id="help">
			hello
		</div>
		<cfhttp url="http://search.crossref.org/dois?q=#publication_title#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<cfloop array="#x#" index="data_index">
			<cfset baredoi=replace(data_index['doi'],'http://dx.doi.org/','','all')>
			<cfset thisCitation=data_index['fullcitation']>
			<cfif len(stripttl) gt 10>
				<cfset thisStripped=ucase(trim(rereplacenocase(thisCitation, '[^a-z0-9]', '', 'all')))>
				<!----
				<br>stripttl: #stripttl#
				<br>thisStripped: #thisStripped#
				---->
				<cfif thisStripped contains stripttl>
					<cfset thisStyle="mightbe">
				<cfelse>
					<cfset thisStyle="probablynot">
				</cfif>
			<cfelse>
				<cfset thisStyle="probablynot">
			</cfif>
			<div class="#thisStyle#">
				#thisCitation#
				<ul>
					<li><a href="#data_index['doi']#" target="_blank" class="external">#baredoi#</a></li>
					<li><span class="likeLink" onclick="useDOI('#baredoi#')">Use This DOI</span>
				</ul>
			</div>
		</cfloop>

	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">