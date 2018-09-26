<cfinclude template="/includes/_pickHeader.cfm">
<cfif not isdefined("doi") or len(doi) is 0>
	DOI is required
</cfif>
<style>
	.refDiv{
		padding-left: 1em;
    	text-indent:-1em;
		margin-top:.5em;
		border:1px solid gray;
		background-color: #edefea;
	}
	#ldgthngee {
		position:fixed;
		top:0px;
		left:50%;
	}
</style>
<script>
	$(document).ready(function() {
		$.ajax({
			url: "/component/utilities.cfc?queryformat=column",
			type: "POST",
			dataType: "text",
			async: true,
			data: {
				method:  "getArctosPublication",
				doi : $("#doi").val(),
				returnformat : "plain"
			},
			success: function(r) {
				//console.log(r);
				$("#arctospubdata").html(r);
			},
			error: function (xhr, textStatus, errorThrown){
		    	alert(errorThrown + ': ' + textStatus + ': ' + xhr);
			}
		});
		$.ajax({
			url: "/component/utilities.cfc?queryformat=column",
			type: "POST",
			dataType: "text",
			async: true,
			data: {
				method:  "getCrossrefPublication",
				doi : $("#doi").val(),
				returnformat : "plain"
			},
			success: function(r) {
				//console.log(r);
				$("#crossrefpubdata").html(r);
			},
			error: function (xhr, textStatus, errorThrown){
		    	alert(errorThrown + ': ' + textStatus + ': ' + xhr);
			}
		});
		$.ajax({
			url: "/component/utilities.cfc?queryformat=column",
			type: "POST",
			dataType: "text",
			async: true,
			data: {
				method:  "getPublicationRefs",
				doi : $("#doi").val(),
				returnformat : "plain"
			},
			success: function(r) {
				//console.log(r);
				$("#pubrefs").html(r);
			},
			error: function (xhr, textStatus, errorThrown){
		    	alert(errorThrown + ': ' + textStatus + ': ' + xhr);
			}
		});

		$.ajax({
			url: "/component/utilities.cfc?queryformat=column",
			type: "POST",
			dataType: "text",
			async: true,
			data: {
				method:  "getPublicationCitations",
				doi : $("#doi").val(),
				returnformat : "plain"
			},
			success: function(r) {
				//console.log(r);
				$("#pubcitby").html(r);
			},
			error: function (xhr, textStatus, errorThrown){
		    	alert(errorThrown + ': ' + textStatus + ': ' + xhr);
			}
		});




	});
	function autocreatepublication(doi,eid){
		$("#" + eid).html('<img src="/images/indicator.gif">');
			$.ajax({
			url: "/component/functions.cfc?queryformat=column",
			type: "POST",
			dataType: "json",
			async: false,
			data: {
				method:  "autocreatepublication",
				doi : doi,
				returnformat : "json"
			},
			success: function(r) {
				if (r.STATUS=='SUCCESS'){
					var tl='<a target="_blank" href="/publication/' + r.PUBLICATION_ID + '">[ view publication in Arctos ]</a>';
					$("#" + eid).html('').append(tl);
				} else {
					alert(r.STATUS + ': ' + r.MSG);
					$("#" + eid).html('');
				}
			},
			error: function (xhr, textStatus, errorThrown){
			    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
			}
		});
	}

</script>
<cfoutput>
	<!--- for JS ---->
	<input type="hidden" id="doi" value="#doi#">
	<h2>Arctos Publication</h2>
	<div id="arctospubdata"><img src="/images/indicator.gif"></div>
	<h2>CrossRef Data</h2>
	<div id="crossrefpubdata"><img src="/images/indicator.gif"></div>
	<h2>References</h2>
	<div id="pubrefs"><img src="/images/indicator.gif"></div>
	<h2>Cited By <span style="font-size:x-small">(from http://opencitations.net)</span></h2>
	<div id="pubcitby"><img src="/images/indicator.gif"></div>


	<!-----
	<cfparam name="debug" default="false">
	<cfquery name="abp" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT
			publication.publication_id,
			publication.full_citation,
			publication.publication_remarks,
			publication.doi,
			publication.pmid,
			count(distinct(citation.collection_object_id)) numCits,
			getPreferredAgentName(pauth.AGENT_ID) authn,
			pauth.AUTHOR_ROLE,
			pauth.agent_id
		FROM
			publication,
			citation,
			publication_agent pauth
		WHERE
			publication.publication_id = citation.publication_id (+) and
			publication.publication_id = pauth.publication_id (+) and
			doi='#doi#'
		GROUP BY
			publication.publication_id,
			publication.full_citation,
			publication.publication_remarks,
			publication.doi,
			publication.pmid,
			getPreferredAgentName(pauth.AGENT_ID),
			pauth.AUTHOR_ROLE,
			pauth.agent_id
	</cfquery>
		<h2>Arctos Publication</h2>
	<cfif abp.recordcount gt 0>
		<cfquery name="pubs" dbtype="query">
			SELECT
				publication_id,
				full_citation,
				doi,
				pmid,
				publication_remarks,
				NUMCITS
			FROM
				abp
			GROUP BY
				publication_id,
				full_citation,
				doi,
				pmid,
				publication_remarks,
				NUMCITS
		</cfquery>
		Full Citation: #pubs.full_citation#
		<br>Number Citations: #pubs.NUMCITS#
		<br>Remarks: #pubs.publication_remarks#
		<br>Context: <a target="_blank" href="/publication/#abp.publication_id#">[ view in Arctos ]</a>
		<cfquery name="pauths" dbtype="query">
			select authn,AUTHOR_ROLE,agent_id from abp where authn is not null group by authn,AUTHOR_ROLE,agent_id order by authn
		</cfquery>
		<li>
			Publication Agents
			<ul>
				<cfloop query="pauths">
					<li><a target="_blank" href="/agent.cfm?agent_id=#agent_id#">#authn#</a> (#AUTHOR_ROLE#)</li>
				</cfloop>
			</ul>
		</li>

	<cfelse>
		Publication is not in Arctos.
	</cfif>







	<cfflush>
	<h2>CrossRef Data</h2>
	<cfflush>
	<p>
		<a target="_blank" class="external" href="https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">view data</a>
	</p>
	<!--- see if we have a recent cache --->
	<cfquery name="c" datasource="uam_god">
		select * from cache_publication_sdata where source='crossref' and doi='#doi#' and last_date > sysdate-30
	</cfquery>
	<cfif c.recordcount gt 0>
		<cfset x=DeserializeJSON(c.json_data)>
		<cfset jmamm_citation=c.jmamm_citation>
	<cfelse>
		<cfhttp result="d" method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">
			<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
		</cfhttp>
		<cfhttp result="jmc" method="get" url="https://dx.doi.org//#doi#">
			<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
			<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
		</cfhttp>
		<cfif debug is true>
			<cfdump var=#jmc#>
			<cfdump var=#d#>
		</cfif>
		<cfif not isjson(d.Filecontent)>
			invalid return
			<cfdump var=#d#>
			<cfabort>
		</cfif>
		<cfif left(jmc.statuscode,3) is "200">
			<cfset jmcdata=jmc.fileContent>
		<cfelse>
			<cfset jmcdata='ERROR: #jmc.statuscode#'>
		</cfif>
		<cfquery name="dc" datasource="uam_god">
			delete from cache_publication_sdata where source='crossref' and doi='#doi#'
		</cfquery>
		<cfquery name="uc" datasource="uam_god">
			insert into cache_publication_sdata (doi,json_data,jmamm_citation,source,last_date) values
			 ('#doi#', <cfqueryparam value="#d.Filecontent#" cfsqltype="cf_sql_clob">,'#jmcdata#','crossref',sysdate)
		</cfquery>
		<cfset x=DeserializeJSON(d.Filecontent)>
		<cfset jmamm_citation=jmc.fileContent>
	</cfif>


	<cfif debug is true>
		<cfdump var=#x#>
	</cfif>


	<h3>
		#jmamm_citation#
	</h3>


	<cfif structKeyExists(x.message,"title")>
		<cfset tar=x.message["title"]>
		<cfif ArrayIsDefined(tar,1)>
		<p>
			Title: #tar[1]#
		</p>
		</cfif>
	</cfif>
	<cfif structKeyExists(x.message,"created")>
		<cfset tar=x.message["created"]>
		<cfset z=tar["date-parts"]>
		<cfset y=z[1][1]>
		<br>Year: #y#
	</cfif>
	<cfif structKeyExists(x.message,"container-title")>
		<cfset tar=x.message["container-title"]>
		<cfif ArrayIsDefined(tar,1)>
			<br>Container Title: #tar[1]#
		</cfif>


	</cfif>
	<cfif structKeyExists(x.message,"issue")>
		<br>Issue: #x.message["issue"]#
	</cfif>
	<cfif structKeyExists(x.message,"publisher")>
		<br>Publisher: #x.message["publisher"]#
	</cfif>
	<cfif structKeyExists(x.message,"type")>
		<br>Type: #x.message["type"]#
	</cfif>
	<cfif structKeyExists(x.message,"volume")>
		<br>Volume: #x.message["volume"]#
	</cfif>
	<cfif structKeyExists(x.message,"page")>
		<br>Page: #x.message["page"]#
	</cfif>
	<cfif structKeyExists(x.message,"reference-count")>
		<br>Reference Count: #x.message["reference-count"]#
	</cfif>
	<cfif structKeyExists(x.message,"is-referenced-by-count")>
		<br>Referenced By Count: #x.message["is-referenced-by-count"]#
	</cfif>



	<h3>
		Authors
	</h3>
	<cfif structKeyExists(x.message,"author")>
		<cfloop array="#x.message.author#" index="idx">
		    <cfif StructKeyExists(idx, "given")>
				<br>#idx["given"]#
			</cfif>
		    <cfif StructKeyExists(idx, "family")>
				#idx["family"]#
			</cfif>
			<cfif StructKeyExists(idx, "sequence")>
				(#idx["sequence"]#)
			</cfif>
			<cfif StructKeyExists(idx, "ORCID")>
				<ul>
					<cfquery name="au" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
						select agent_id from address where ADDRESS_TYPE='ORCID' and address='#idx["ORCID"]#'
					</cfquery>
					<cfif au.recordcount gt 0>
						<li><a href="/agent.cfm?agent_id=#au.agent_id#" target="_blank">[ Arctos Agent ]</a></li>
					</cfif>
					<li><a href="#idx["ORCID"]#" class="external" target="_blank">#idx["ORCID"]#</a></li>
				</ul>
			</cfif>
		</cfloop>
	</cfif>

	<cfflush>
	<cfif structKeyExists(x.message,"funder")>
		<br>Funder(s):
		<cfset fd=x.message["funder"]>
		<ul>
		<cfloop array="#fd#" index="fdrs">
			<li>
				#fdrs["name"]#
				<cfif structKeyExists(fdrs,"DOI")>
					(<a href="https://dx.doi.org/#fdrs["DOI"]#" target="_blank" class="external">#fdrs["DOI"]#</a>)
				</cfif>

				<cfif structKeyExists(fdrs,"award")>
					<ul>
						<cfloop array='#fdrs["award"]#' index="ax">
							 <li>
								 Award #ax#
								<cfif fdrs["name"] is "National Science Foundation">
									<a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=#ax#" target="_blank" class="external">NSF Search</a>
								</cfif>
							</li>
						</cfloop>
					</ul>
				</cfif>
			</li>
		</cfloop>
		</ul>
	</cfif>
	<cfflush>
<h3>
	References
</h3>
	<cfif structKeyExists(x.message,"reference")>
		<cfloop array="#x.message.reference#" index="idx">
			<!--- referenes are a mess, if we have a DOI just use the damned thing --->
			<cfif StructKeyExists(idx, "doi")>
				<cfset thisDOI=idx["doi"]>
				<cfquery name="c" datasource="uam_god">
					select * from cache_publication_sdata where source='crossref' and doi='#thisDOI#' and last_date > sysdate-30
				</cfquery>
				<cfif c.recordcount gt 0>
					<cfset rfs=c.jmamm_citation>
				<cfelse>
					<cfhttp result="d" method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#thisDOI#">
						<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
					</cfhttp>
					<cfhttp result="jmc" method="get" url="https://dx.doi.org/#thisDOI#">
						<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
						<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
					</cfhttp>
					<cfif not isjson(d.Filecontent) or left(d.statuscode,3) is not "200" or left(jmc.statuscode,3) is not "200">
						<cfset rfs="invalid return; https://api.crossref.org/v1/works/http://dx.doi.org/#thisDOI# and / or 	https://dx.doi.org/#thisDOI# did not resolve (possibly not a valid DOI?)">
					<cfelse>
						<cfquery name="dc" datasource="uam_god">
							delete from cache_publication_sdata where source='crossref' and doi='#thisDOI#'
						</cfquery>
						<cfquery name="uc" datasource="uam_god">
							insert into cache_publication_sdata (doi,json_data,jmamm_citation,source,last_date) values
							 ('#thisDOI#', <cfqueryparam value="#d.Filecontent#" cfsqltype="cf_sql_clob">,'#jmc.fileContent#','crossref',sysdate)
						</cfquery>
						<cfset rfs=jmc.fileContent>
					</cfif>
				</cfif>
			<cfelse>
				<!--- no DOI, use what we have --->
				<cfif StructKeyExists(idx, "unstructured")>
					<cfset rfs=idx["unstructured"]>
				<cfelse>
			   		<cfset rfs="">
					<cfif StructKeyExists(idx, "author")>
						<cfset rfs=rfs & idx["author"]>
					</cfif>
				    <cfif StructKeyExists(idx, "year")>
						<cfset rfs=rfs & ' ' & idx["year"] & '. '>
					</cfif>
				   <cfif StructKeyExists(idx, "article-title")>
					   <cfset rfs=rfs & idx["article-title"]>
					<cfelseif StructKeyExists(idx, "volume-title")>
					   <cfset rfs=rfs & idx["volume-title"]>
				   </cfif>
				</cfif>
			</cfif>
			<div class="refDiv">
				#rfs#
				 <cfif StructKeyExists(idx, "doi")>
					 <cfset thisDOI=idx["doi"]>
					<br><a class="external" target="_blank" href="http://dx.doi.org/#thisDOI#">http://dx.doi.org/#thisDOI#</a>
					<br><a href="publicationDetails.cfm?doi=#thisDOI#">[ more information ]</a>
					<br><a target="_blank" class="external" href="https://api.crossref.org/v1/works/http://dx.doi.org/#thisDOI#">view raw data</a>
					<cfquery name="ap" datasource="uam_god" cachedwithin="#createtimespan(0,0,15,0)#">
						select publication_id from publication where doi='#thisDOI#'
					</cfquery>
					<cfif ap.recordcount gt 0>
						<br><a target="_blank" href="/publication/#ap.publication_id#">Arctos Publication</a>
					<cfelse>
						<div id="acp_#hash(thisDOI)#">
							<span class="likeLink" onclick="autocreatepublication('#thisDOI#','acp_#hash(thisDOI)#')">Auto-Create</span>
						</div>
					</cfif>
				</cfif>
			</div>
			<cfflush>
		</cfloop>
	</cfif>

	<cfquery name="c" datasource="uam_god">
		select * from cache_publication_sdata where source='opencitations' and doi='#doi#' and last_date > sysdate-30
	</cfquery>
	<cfif c.recordcount gt 0>
		<cfset x=DeserializeJSON(c.json_data)>
	<cfelse>
		<cfhttp result="d" method="get" url="http://opencitations.net/index/coci/api/v1/citations/#doi#">
			<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
			<cfhttpparam type = "header" name = "Accept" value = "application/json">
		</cfhttp>
		<cfhttp result="jmc" method="get" url="https://dx.doi.org/#doi#">
			<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
			<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
		</cfhttp>
		<cfif not isjson(d.Filecontent)>
			invalid return
			<cfdump var=#d#>
			<cfabort>
		</cfif>
		<cfquery name="dc" datasource="uam_god">
			delete from cache_publication_sdata where source='opencitations' and doi='#doi#'
		</cfquery>
		<cfquery name="uc" datasource="uam_god">
			insert into cache_publication_sdata (doi,json_data,jmamm_citation,source,last_date) values
			 ('#doi#', <cfqueryparam value="#d.Filecontent#" cfsqltype="cf_sql_clob">,'#jmc.fileContent#','opencitations',sysdate)
		</cfquery>
		<cfset x=DeserializeJSON(d.Filecontent)>
	</cfif>



<h3>
Cited By (from http://opencitations.net)
</h3>
<p>
	<a target="_blank" class="external" href="http://opencitations.net/index/coci/api/v1/citations/#doi#">view data</a>
</p>

	<cfloop array="#x#" index="idx">
		<cfset ctdstr="">
		<cfif StructKeyExists(idx, "citing")>
			<cfset cdoi=idx["citing"]>
			<cfquery name="c" datasource="uam_god">
				select * from cache_publication_sdata where source='crossref' and doi='#cdoi#' and last_date > sysdate-30
			</cfquery>
			<cfif c.recordcount gt 0>
				<cfset tr=DeserializeJSON(c.json_data)>
				<cfset jmamm_citation=c.jmamm_citation>
			<cfelse>
				<cfhttp result="d" method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#cdoi#">
					<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
				</cfhttp>
				<cfhttp result="jmc" method="get" url="https://dx.doi.org/#cdoi#">
					<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
					<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
				</cfhttp>
				<cfset jmamm_citation=jmc.fileContent>

				<cfif not isjson(d.Filecontent)>
					invalid return
					<cfdump var=#d#>
					<cfdump var=#jmc#>
				</cfif>
				<cfquery name="dc" datasource="uam_god">
					delete from cache_publication_sdata where source='crossref' and doi='#cdoi#'
				</cfquery>
				<cfquery name="uc" datasource="uam_god">
					insert into cache_publication_sdata (doi,json_data,source,jmamm_citation,last_date) values
					 ('#cdoi#', <cfqueryparam value="#d.Filecontent#" cfsqltype="cf_sql_clob">,'crossref','#jmamm_citation#',sysdate)
				</cfquery>
				<cfset tr=DeserializeJSON(d.Filecontent)>
			</cfif>

			<!----

			<cfset astr="">
			<cfif structKeyExists(tr.message,"author")>
				<cfloop array="#tr.message.author#" index="ax">
					<cfset a="">
				    <cfif StructKeyExists(ax, "given")>
						<cfset a=a & ' ' & #ax["given"]#>
					</cfif>
				    <cfif StructKeyExists(ax, "family")>
						<cfset a=a & ' ' & #ax["family"]#>
					</cfif>
					<cfif len(astr) is 0>
						<cfset astr=a>
					<cfelse>
						<cfset astr=astr & ', ' & a>
					</cfif>
				</cfloop>
			</cfif>
			<cfset ctdstr=ctdstr & astr & '. '>
			<cfif structKeyExists(tr.message,"title")>
				<cfset tar=tr.message["title"]>
				<cfset ctdstr=ctdstr & '#tar[1]#.'>
			</cfif>
			---->
			<div class="refDiv">
				#jmamm_citation#
				<br><a class="external" target="_blank" href="http://dx.doi.org/#cdoi#">http://dx.doi.org/#cdoi#</a>
				<br><a target="_blank" class="external" href="https://api.crossref.org/v1/works/http://dx.doi.org/#cdoi#">view raw data</a>
				<br><a href="publicationDetails.cfm?doi=#cdoi#">[ more information ]</a>
				<cfquery name="ap" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select publication_id from publication where doi='#cdoi#'
				</cfquery>
				<cfif ap.recordcount gt 0>
					<br><a target="_blank" href="/publication/#ap.publication_id#">Arctos Publication</a>
				<cfelse>
					<div id="acp_#hash(cdoi)#">
						<span class="likeLink" onclick="autocreatepublication('#cdoi#','acp_#hash(cdoi)#')">Auto-Create</span>
					</div>
				</cfif>
			</div>
			<cfflush>

		</cfif>
	</cfloop>
	---->
</cfoutput>