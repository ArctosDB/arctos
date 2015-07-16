<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("publication_title")>
	Didn't get a publication_title.<cfabort>
</cfif>
<style>
	.mightbe{padding:.2em; margin:.2em; border:2px solid green;}
	.probablynot{padding:.2em;margin:.2em; border:1px solid orange;}
	#help{display:none; border:1px solid black;margin:1em;padding:1em;}
</style>
<script>
	function useDOI(doi){
		parent.$("#doi").val(doi);
		parent.$(".ui-dialog-titlebar-close").trigger('click');
	}
	function nofindDOI(){
		var er=parent.$("#publication_remarks").val();
		var tr=$("#failbox").val();
		if(er.length==0){
			tr+='; ' + er;
		}
		parent.$("#publication_remarks").val(tr);
		parent.$(".ui-dialog-titlebar-close").trigger('click');
	}
</script>
<cfoutput>
	<form name="additems" method="post" action="findDOI.cfm">
		<label for="publication_title">Title</label>
		<textarea name="publication_title" class="hugetextarea">#publication_title#</textarea>
		<br><input type="submit" value="Find DOI">
		
		<!---- simplify failure.... ---->
		<input id="failbox" type="hidden" value="Unable to locate suitable DOI; #session.username# #dateformat(now(),'yyyy-mm-dd')#">
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
		<p>
			Not finding what you need? <span class="likeLink" onclick="nofindDOI();">Add a remark.</span>
		</p>
		<span class="likeLink" onclick="$('##help').toggle()">help</span>
		<div id="help">
			The box above is the publication full citation as pulled from Arctos.
			If you aren't finding what you're looking for, try editing it (which will increase
			the number of false positives returned, but perhaps also find the
			correct article). For example, removing parenthetical taxa may be useful.
			<p>
				The results below are pulled from CrossRef. Read them before clicking;
				there are many situations in which an incorrect match is highlighted as
				correct, and in which a correct match is buried in the probable failures.
				<br>
				If what you're looking for isn't obvious, try searching (CTL-F or splat-F) by a hopefully-unique
				term from the original title.
				<br>Note that not all publications are in CrossRef; ZooTaxa does not seem to participate in
				DOIs, for example. Note also that many old and obscure publications HAVE been made available
				through CrossRef (largely by BHL).
			</p>
			<p>
				Consider correcting data in Arctos. This form ONLY finds DOIs; close this window and
				edit the publication.
			</p>
			<p>
				This for is a tool, not magic. If you don't find what you're looking for here, try
				<a target="_blank" class="external" href="http://google.com/search?q=#publication_title#">Google</a>.
			</p>
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