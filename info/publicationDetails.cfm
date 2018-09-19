<cfif not isdefined("doi") or len(doi) is 0>
	DOI is required
</cfif>
<cfoutput>
	<h2>CrossRef Data</h2>
	<p>
		<a target="_blank" class="external" href="https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">view data</a>
	</p>
	<!--- see if we have a recent cache --->
	<cfquery name="c" datasource="uam_god">
		select * from cache_publication_sdata where doi='#doi#' and last_date > sysdate-30
	</cfquery>
	<cfif c.recordcount gt 0>
		<br>got cache
		<cfset x=DeserializeJSON(c.json_data)>
	<cfelse>
		<cfhttp result="d" method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">
			<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
		</cfhttp>
		<cfif not isjson(d.Filecontent)>
			invalid return
			<cfdump var=#cfhttp#>
			<cfabort>
		</cfif>
		<cfquery name="dc" datasource="uam_god">
			delete from cache_publication_sdata where doi='#doi#'
		</cfquery>
		<cfquery name="uc" datasource="uam_god">
			insert into cache_publication_sdata (doi,json_data,last_date) values ('#doi#','#d.Filecontent#',sysdate)
		</cfquery>
		<br>added to cache
		<cfset x=DeserializeJSON(d.Filecontent)>
	</cfif>





	<cfif structKeyExists(x.message,"title")>
		<cfset tar=x.message["title"]>
		<p>
			Title: #tar[1]#
		</p>
	</cfif>
	<cfif structKeyExists(x.message,"publisher")>
		<br>Publisher: #x.message["publisher"]#
	</cfif>
	<cfif structKeyExists(x.message,"container-title")>
		<cfset tar=x.message["container-title"]>
		<br>Container Title: #tar[1]#
	</cfif>
	<cfif structKeyExists(x.message,"issue")>
		<br>Issue: #x.message["issue"]#
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
		</cfloop>
	</cfif>

<h3>
	References
</h3>
	<cfif structKeyExists(x.message,"reference")>
		<cfloop array="#x.message.reference#" index="idx">
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
					journal-title
			</cfif>
		   <cfif StructKeyExists(idx, "doi")>
				<cfset rfs=rfs & '. <a class="external" target="_blank" href="http://dx.doi.org/#idx["doi"]#">http://dx.doi.org/#idx["doi"]#</a>'>
			</cfif>
			<br>#rfs#
		</cfloop>
	</cfif>


	<cfhttp method="get" url="http://opencitations.net/index/coci/api/v1/citations/#doi#">
		<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
		<cfhttpparam type = "header" name = "Accept" value = "application/json">
	</cfhttp>
<h3>
Cited By (from http://opencitations.net)
</h3>
<p>
	<a target="_blank" class="external" href="http://opencitations.net/index/coci/api/v1/citations/#doi#">view data</a>
</p>
	<cfif not isjson(cfhttp.Filecontent)>
		invalid return
		<cfdump var=#cfhttp#>
		<cfabort>
	</cfif>
	<cfset x=DeserializeJSON(cfhttp.Filecontent)>
	<cfloop array="#x#" index="idx">
		<cfset ctdstr="">
		<cfif StructKeyExists(idx, "citing")>
			<cfset cdoi=idx["citing"]>
			<cfhttp method="get" url="https://api.crossref.org/v1/works/http://dx.doi.org/#cdoi#">
				<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
			</cfhttp>
			<cfset tr=DeserializeJSON(cfhttp.Filecontent)>
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
			<br>#ctdstr#. <a class="external" target="_blank" href="http://dx.doi.org/#cdoi#">http://dx.doi.org/#cdoi#</a>
			<br><a target="_blank" class="external" href="https://api.crossref.org/v1/works/http://dx.doi.org/#cdoi#">view data</a>

		</cfif>
	</cfloop>
</cfoutput>