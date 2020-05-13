<cfcomponent>

<cffunction name="getAggregatorLinks" output="true" returnType="any" access="remote">
	<cfargument name="guid" required="yes"><!--- DWC triplet --->
	<cfargument name="globi" required="no"><!--- list of id_references --->
	<cfset r="">
	<cftry>
		<cfoutput>
			<cfset theFullGuid="http://arctos.database.museum/guid/#guid#">
			<cfhttp result="gbr" url="http://api.gbif.org/v1/occurrence/search?organismId=#theFullGuid#" method="get"></cfhttp>
			<cfif gbr.statusCode is "200 OK" and len(gbr.filecontent) gt 0 and isjson(gbr.filecontent)>
				<cfset gb=DeserializeJSON(gbr.filecontent)>
				<cfloop from ="1" to="#arraylen(gb.results)#" index="i">
					<cfset thisStruct=gb.results[i]>
					<cfset thisGBID=thisStruct.gbifID>
					<cfset r=r & '<div><a href="https://www.gbif.org/occurrence/#thisGBID#" target="_blank" class="external">GBIF Occurrence</a></div>'>
				</cfloop>
			</cfif>
			<!---
				idigbio's undocumented fulltext search matches substrings, so this gets really crazy with catnum=1
				we're providing catnum as DWC triplets so the alternative sort of works....

				<cfset idburl=URLEncodedFormat('{"data":{"type":"fulltext","value":"#theFullGuid#"}}')>
			--->
			<cfset idburl=URLEncodedFormat('{"catalognumber":"#guid#"}')>
			<cfhttp result="idbr" url="https://search.idigbio.org/v2/search/records?fields=uuid&rq=#idburl#" method="get"></cfhttp>
			<cfif idbr.statusCode is "200 OK" and len(idbr.filecontent) gt 0 and isjson(idbr.filecontent)>
				<cfset idb=DeserializeJSON(idbr.filecontent)>
				<cfloop from ="1" to="#arraylen(idb.items)#" index="i">
					<cfset thisStruct=idb.items[i]>
					<cfset thisIDBID=thisStruct.indexTerms.uuid>
					<cfset r=r & '<div><a href="https://www.idigbio.org/portal/records/#thisIDBID#" target="_blank" class="external">iDigBio Occurrence</a></div>'>
				</cfloop>
			</cfif>
			<cfif isdefined("globi") and len(globi) gt 0>
				<!--- we got some id_references, see if they're used things --->
				<cfset gHandles="eaten by,ate,host of,parasite of">
				<cfset goGoGlobi=false>
				<cfloop list="#gHandles#" index="i">
					<cfif listfind(globi,i)>
						<!--- there's a potential globi refrence; we should check it, but that's not available yet so... ---->
						<cfset goGoGlobi=true>
					</cfif>
				</cfloop>
				<cfif goGoGlobi is true>
					<!---- make sure that the resource exists ---->
					<cfhttp result="gbi" url="https://api.globalbioticinteractions.org/exists?accordingTo=http://arctos.database.museum/guid/#guid#" method="head"></cfhttp>
					<cfif isdefined("gbi.statuscode") and gbi.statuscode is "200 OK">
						<cfset r=r & '<div><a href="https://globalbioticinteractions.org/?accordingTo=http://arctos.database.museum/guid/#guid#" target="_blank" class="external">GloBI</a></div>'>
					</cfif>
				</cfif>
			</cfif>
		</cfoutput>
		<cfcatch>
			<cfset r="">
		</cfcatch>
	</cftry>
	<cfreturn r>
</cffunction>
<!-------------------------------------------------->
<cffunction name="sandboxToS3" output="false" returnType="any" access="remote">
	<!---
		upload a file and return a URL
		accept:
		path to tmp
		filename as loaded

	---->
	<cfargument name="tmp_path" required="yes">
	<cfargument name="filename" required="yes">

	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listcontains(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>



	<cftry>
		<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
		</cfquery>

		<!---- make a username bucket. This will create or return an error of some sort. ---->
		<cfset currentTime = getHttpTimeString( now() ) />
		<cfset contentType = "text/html" />
		<cfset bucket="#replace(lcase(session.username),'_','','all')#">

		<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket
			] />
		<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
		<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>
		<cfhttp result="mkunamebkt" method="put" url="#s3.s3_endpoint#/#bucket#">
			<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
		    <cfhttpparam type="header" name="Content-Type" value="#contentType#" />
		    <cfhttpparam type="header" name="Date" value="#currentTime#" />
		</cfhttp>



		<cffile variable="content" action = "readBinary"  file="#tmp_path#">



		<cfset fext=listlast(fileName,".")>
		<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
		<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
		<cfset fName=replace(fName,'__','_','all')>
		<cfset fileName=fName & '.' & fext>
		<cfset vfn=isValidMediaUpload(fileName)>
		<cfif len(vfn) gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg=vfn>
			<cfreturn serializeJSON(r)>
		</cfif>
		<!--- generate a checksum while we're holding the binary ---->
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(content)>
		<!--- see if the media exists ---->
		<cfquery name="ckck" datasource="uam_god">
			select media_id from media_labels where MEDIA_LABEL='MD5 checksum' and LABEL_VALUE='#md5#'
		</cfquery>
		<cfif ckck.recordcount gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg='Media Exists'>
			<cfloop list="#valuelist(ckck.media_id)#" index="i">
				<cfset r.msg=r.msg & '\n#Application.serverRootURL#/media/#i#'>
			</cfloop>
			<cfset r.msg=r.msg & '\nUse the "link to existing" option'>
			<cfreturn serializeJSON(r)>
		</cfif>


		<cfset r.md5=md5>
		<!----
			this does not work properly; Adobe ColdFusion thinks Adobe DNGs are TIFFs
			<cfset mimetype=FilegetMimeType("#Application.sandbox#/#tempName#.tmp")>
			<cfset r.mimetype=mimetype>
		 ---->
		<cfif fext is "jpg" or fext is "jpeg">
			<cfset mimetype="image/jpeg">
			<cfset mediatype="image">
		<cfelseif fext is "dng">
			<cfset mimetype="image/dng">
			<cfset mediatype="image">
		<cfelseif fext is "pdf">
			<cfset mimetype="application/pdf">
			<cfset mediatype="text">
		<cfelseif fext is "png">
			<cfset mimetype="image/png">
			<cfset mediatype="image">
		<cfelseif fext is "txt">
			<cfset mimetype="text/plain">
			<cfset mediatype="text">
		<cfelseif fext is "wav">
			<cfset mimetype="audio/x-wav">
			<cfset mediatype="audio">
		<cfelseif fext is "m4v">
			<cfset mimetype="video/mp4">
			<cfset mediatype="video">
		<cfelseif fext is "tif" or fext is "tiff">
			<cfset mimetype="image/tiff">
			<cfset mediatype="image">
		<cfelseif fext is "mp3">
			<cfset mimetype="audio/mpeg3">
			<cfset mediatype="audio">
		<cfelseif fext is "mov">
			<cfset mimetype="video/quicktime">
			<cfset mediatype="video">
		<cfelseif fext is "xml">
			<cfset mimetype="application/xml">
			<cfset mediatype="text">
		<cfelseif fext is "wkt">
			<cfset mimetype="text/plain">
			<cfset mediatype="text">
		<cfelse>
			<cfset r.statusCode=400>
			<cfset r.msg='Invalid filetype: could not determine mime or media type.'>
			<cfreturn serializeJSON(r)>
		</cfif>

		<cfset r.media_type=mediatype>
		<cfset r.mime_type=mimetype>

		<!--- now load the file ---->
		<!--- "virtual" date-bucket inside the username bucket ---->
		<cfset bucket="#replace(lcase(session.username),'_','','all')#/#dateformat(now(),'YYYY-MM-DD')#">
		<cfset currentTime = getHttpTimeString( now() ) />
		<cfset contentType=mimetype>
		<cfset contentLength=arrayLen( content )>
		<cfset stringToSignParts = [
		    "PUT",
		    "",
		    contentType,
		    currentTime,
		    "/" & bucket & "/" & fileName
		] />

		<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
		<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>
		<cfhttp result="putfile" method="put" url="#s3.s3_endpoint#/#bucket#/#fileName#">
			<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
		    <cfhttpparam type="header" name="Content-Length" value="#contentLength#" />
		    <cfhttpparam type="header" name="Content-Type" value="#contentType#"/>
		    <cfhttpparam type="header" name="Date" value="#currentTime#" />
		    <cfhttpparam type="body" value="#content#" />
		</cfhttp>
		<cfset media_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#fileName#">

		<!--- statuscode of putting the actual file - the important thing--->
	    <cfset r.statusCode=left(putfile.statusCode,3)>
	  	<cfif r.statuscode is not "200">
			 <cfset r.statusCode=putfile.statusCode>
			 <cfset r.fileContent=putfile.fileContent>
		</cfif>
		<cfset r.filename="#fileName#">
		<cfset r.media_uri="#media_uri#">
			<cfcatch>
				<cfset r.statusCode=444>
				<cfset r.msg=cfcatch.message & '; ' & cfcatch.detail>
				<cfif isdefined("putTN")>
					<cfset r.putTN=putTN>
				</cfif>
				<cfif isdefined("putfile")>
					<cfset r.putfile=putfile>
				</cfif>
				<cfif isdefined("mkunamebkt")>
					<cfset r.mkunamebkt=mkunamebkt>
				</cfif>
			</cfcatch>
	</cftry>
	<cfreturn serializeJSON(r)>
</cffunction>


<!-------------------------------------------------------->
<cffunction name="getPublicationCitations"  access="remote">
	<cfargument name="doi" required="true" type="string" access="remote">
	<cfoutput>
		<cfquery name="c" datasource="uam_god">
			select * from cache_publication_sdata where source='opencitations' and doi='#doi#' and last_date > sysdate-30
		</cfquery>
		<cfif c.recordcount gt 0>
			<!---this gets validated before cache so should be skookum --->
			<cfset x=DeserializeJSON(c.json_data)>
		<cfelse>
			<cfhttp result="d" method="get" url="http://opencitations.net/index/coci/api/v1/citations/#doi#">
				<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
				<cfhttpparam type = "header" name = "Accept" value = "application/json">
			</cfhttp>
			<cfif not isjson(d.Filecontent)>
				<cfreturn "Invalid return for http://opencitations.net/index/coci/api/v1/citations/#doi#">
			</cfif>
			<cfhttp result="jmc" method="get" url="https://dx.doi.org/#doi#">
				<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
				<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
			</cfhttp>

			<cfif left(jmc.Statuscode,3) is not "200" or len(jmc.Filecontent) is 0>
				<cfreturn "Invalid return for https://dx.doi.org/#doi#">
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
		<cfsavecontent variable="r">
			<br><a target="_blank" class="external" href="http://opencitations.net/index/coci/api/v1/citations/#doi#">view data</a>
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
						<cfif left(jmc.statuscode,3) is "200">
							<cfset jmamm_citation=jmc.fileContent>
						<cfelse>
							<cfset jmamm_citation='lookup failure: https://dx.doi.org/#cdoi#'>
						</cfif>

						<cfif not isjson(d.Filecontent)>
							<cfreturn "lookup failure for https://api.crossref.org/v1/works/http://dx.doi.org/#cdoi#">
						</cfif>
						<cfquery name="dc" datasource="uam_god">
							delete from cache_publication_sdata where source='crossref' and doi='#cdoi#'
						</cfquery>
						<cfquery name="uc" datasource="uam_god">
							insert into cache_publication_sdata (doi,json_data,source,jmamm_citation,last_date) values
							 ('#cdoi#', <cfqueryparam value="#d.Filecontent#" cfsqltype="cf_sql_clob">,'crossref','#jmamm_citation#',sysdate)
						</cfquery>
						<!----
						this isn't used
						<cfset tr=DeserializeJSON(d.Filecontent)>
						---->
					</cfif>
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
				</cfif>
			</cfloop>
		</cfsavecontent>
	</cfoutput>
	<cfreturn r>
</cffunction>
<!-------------------------------------------------------->
<cffunction name="getPublicationRefs"  access="remote">
	<cfargument name="doi" required="true" type="string" access="remote">
	<cfoutput>
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
			<cfhttp result="jmc" method="get" url="https://dx.doi.org/#doi#">
				<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
				<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
			</cfhttp>
			<cfif left(d.statuscode,3) is not "200" or not isjson(d.Filecontent)>
				<cfreturn "Lookup failed at https://api.crossref.org/v1/works/http://dx.doi.org/#doi#">
			</cfif>
			<cfif left(jmc.statuscode,3) is "200">
				<cfset jmcdata=jmc.fileContent>
			<cfelse>
				<cfset jmcdata='Lookup failed at https://dx.doi.org/#doi# with #jmc.statuscode#'>
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

		<cfsavecontent variable="r">
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
			</cfloop>
		</cfif>
		</cfsavecontent>
	</cfoutput>
	<cfreturn r>
</cffunction>
<!-------------------------------------------------------->
<cffunction name="getCrossrefPublication"  access="remote">
	<cfargument name="doi" required="true" type="string" access="remote">
	<cfoutput>
		<cfsavecontent variable="r">
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
			<cfhttp result="jmc" method="get" url="https://dx.doi.org/#doi#">
				<cfhttpparam type = "header" name = "User-Agent" value = "Arctos (https://arctos.database.museum; mailto:dustymc@gmail.com)">
				<cfhttpparam type = "header" name = "Accept" value = "text/bibliography; style=journal-of-mammalogy">
			</cfhttp>
			<cfif not isjson(d.Filecontent)>
				<cfreturn 'lookup failed at https://api.crossref.org/v1/works/http://dx.doi.org/#doi#'>
			</cfif>
			<cfif left(jmc.statuscode,3) is "200">
				<cfset jmcdata=jmc.fileContent>
			<cfelse>
				<cfset jmcdata='lookup of https://dx.doi.org/#doi# failed with #jmc.statuscode#'>
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
		<h3>
			#jmamm_citation#
		</h3>

		<ul>
		<cfif structKeyExists(x.message,"title")>
			<cfset tar=x.message["title"]>
			<cfif ArrayIsDefined(tar,1)>
			<li>Title: #tar[1]#</li>
			</cfif>
		</cfif>
		<cfif structKeyExists(x.message,"created")>
			<cfset tar=x.message["created"]>
			<cfset z=tar["date-parts"]>
			<cfset y=z[1][1]>
			<li>Year: #y#</li>
		</cfif>
		<cfif structKeyExists(x.message,"container-title")>
			<cfset tar=x.message["container-title"]>
			<cfif ArrayIsDefined(tar,1)>
				<li>Container Title: #tar[1]#</li>
			</cfif>
		</cfif>
		<cfif structKeyExists(x.message,"issue")>
			<li>Issue: #x.message["issue"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"publisher")>
			<li>Publisher: #x.message["publisher"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"type")>
			<li>Type: #x.message["type"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"volume")>
			<li>Volume: #x.message["volume"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"page")>
			<li>Page: #x.message["page"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"reference-count")>
			<li>Reference Count: #x.message["reference-count"]#</li>
		</cfif>
		<cfif structKeyExists(x.message,"is-referenced-by-count")>
			<li>Referenced By Count: #x.message["is-referenced-by-count"]#</li>
		</cfif>
		</ul>

		<h3>
			Authors
		</h3>
		<ul>
		<cfif structKeyExists(x.message,"author")>
			<cfloop array="#x.message.author#" index="idx">
				<li>
				    <cfif StructKeyExists(idx, "given")>
						#idx["given"]#
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
				</li>
			</cfloop>
		</cfif>
		</ul>
		<cfif structKeyExists(x.message,"funder")>
			<h3>Funder(s):</h3>
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
		</cfsavecontent>
	</cfoutput>
	<cfreturn r>
</cffunction>
<!-------------------------------------------------------->
<cffunction name="getArctosPublication"  access="remote">
	 <cfargument name="doi" required="true" type="string" access="remote">
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
	<cfoutput>
	<cfsavecontent variable="r">
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
		<div id="acp_#hash(doi)#">
			<span class="likeLink" onclick="autocreatepublication('#doi#','acp_#hash(doi)#')">Auto-Create</span>
		</div>
	</cfif>
	</cfsavecontent>
	</cfoutput>
	<cfreturn r>
</cffunction>
<!-------------------------------------------------------->
<cffunction name="makeMBLDownloadFile">
	 <cfargument name="zid" required="true" type="numeric"/>
	 <cfquery name="f" datasource="uam_god">
		select * from cf_temp_zipfiles where zid=#zid#
	</cfquery>
	<cfset q=QueryNew("TEMP_original_filename, TEMP_new_filename,MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license,media_label_1,media_label_value_1")>
	<cfloop query="f">
		<cfset queryaddrow(q,
				{
				TEMP_original_filename=filename,
				TEMP_new_filename=new_filename,
				MEDIA_URI=remotepath,
				MIME_TYPE=mime_type,
				MEDIA_TYPE=media_type,
				PREVIEW_URI=remote_preview,
				media_license='',
				media_label_1='MD5 checksum',
				media_label_value_1=md5
				}
			)>
	</cfloop>
	<!----
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=q,Fields=q.columnlist)>
	---->
	<cfset csv = QueryToCSV2(Query=q,Fields=q.columnlist)>

	<cffile action = "write"
	    file = "#Application.webDirectory#/download/media_bulk_zip#zid#.csv"
    	output = "#csv#"
    	addNewLine = "no">
</cffunction>



<cffunction name="isProtectedIp" returnType="string" access="public">
	<cfargument name="ip" type="string" required="yes">
	<cfquery name="protected_ip_list" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select protected_ip_list from cf_global_settings
	</cfquery>
	<cfset isprot=false>
	<cfloop list="#protected_ip_list.protected_ip_list#" index="i">
		<cfset lclip=ip>
		<cfif listlast(i,".") is "*">
			<cfset i=listDeleteAt(i,listlen(i,'.'),'.')>
			<cfset lclip=listDeleteAt(lclip,listlen(lclip,'.'),'.')>
		</cfif>
		<cfif listlast(i,".") is "*">
			<cfset i=listDeleteAt(i,listlen(i,'.'),'.')>
			<cfset lclip=listDeleteAt(lclip,listlen(lclip,'.'),'.')>
		</cfif>
		<cfif i is lclip>
			<cfset isprot=true>
		</cfif>
	</cfloop>
	<cfreturn isprot>
</cffunction>

<cffunction name="georeferenceAddress" returnType="string" access="remote">
	<cfargument name="address" type="string" required="yes">
	 <!---- this has to be called remotely by a function, which does not pass on credentials==public--->
	<cfset obj = CreateObject("component","component.functions")>
	<cfset coords="">
	<cfset mAddress=address>
	<cfset mAddress=replace(mAddress,chr(10),", ","all")>
	<!----
		extract ZIP
		start at the end, take the "first" thing that's numbers
	 ---->

	<cfset ttu="">
	<cfloop index="i" list="#mAddress#">
		<cfif REFind("[0-9]+", i) gt 0>
			<cfset ttu=i>
		</cfif>
	</cfloop>
	<cfset signedURL = obj.googleSignURL(
		urlPath="/maps/api/geocode/json",
		urlParams="address=#URLEncodedFormat('#ttu#')#",
		int_ext="int")>
	<cfhttp result="x" method="GET" url="#signedURL#"  timeout="20"/>

		<cfset llresult=DeserializeJSON(x.filecontent)>
		<cfif llresult.status is "OK">
			<cfset coords=llresult.results[1].geometry.location.lat & "," & llresult.results[1].geometry.location.lng>
		</cfif>
		<!----
		<cfif left(x.Statuscode,3) is "200">
	<cfelse>
		<!--- just return NULL if fail ---->
		<cfset coords="">
	</cfif>
		---->
	<cfreturn coords>
</cffunction>
<cffunction name="getGeogWKT" returnType="string" access="remote">
	<cfargument name="specimen_event_id" type="numeric" required="yes">
	<cfquery name="d" datasource="uam_god">
		select
			geog_auth_rec.wkt_media_id
		from
			geog_auth_rec,
			locality,
			collecting_event,
			specimen_event
		where
			geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id and
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			specimen_event.specimen_event_id=#specimen_event_id#
	</cfquery>
	<cfif len(d.wkt_media_id) gt 0>
		<cfquery name="m" datasource="uam_god">
			select media_uri from media where media_id=#d.wkt_media_id#
		</cfquery>
		<cfhttp method="get" url="#m.media_uri#"></cfhttp>
		<cfreturn cfhttp.filecontent>
	<cfelse>
		<cfreturn>
	</cfif>
</cffunction>

<cffunction name="getLocalityWKT" returnType="string" access="remote">
	<cfargument name="specimen_event_id" type="numeric" required="yes">
	<cfquery name="d" datasource="uam_god">
		select
			locality.wkt_media_id
		from
			locality,
			collecting_event,
			specimen_event
		where
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			specimen_event.specimen_event_id=#specimen_event_id#
	</cfquery>
	<cfif len(d.wkt_media_id) gt 0>
		<cfquery name="m" datasource="uam_god">
			select media_uri from media where media_id=#d.wkt_media_id#
		</cfquery>
		<cfhttp method="get" url="#m.media_uri#"></cfhttp>
		<cfreturn cfhttp.filecontent>
	<cfelse>
		<cfreturn>
	</cfif>
</cffunction>
<cffunction name="generateDisplayName" returnType="string" access="public">
	<cfargument name="cid" type="string" required="yes">
	<cfoutput>
		<cftry>
		<cfset nomencode=''>
		<cfquery name="ct" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select * from cttaxon_term
		</cfquery>
		<!--- establish variables --->
		<cfloop query="ct">
			<cfset "v_#TAXON_TERM#"=''>
		</cfloop>
		<cfquery name="d" datasource="uam_god">
			select term,term_type from taxon_term where classification_id='#cid#'
		</cfquery>
		<!--- set variables --->
		<cfloop query="d">
			<cfset "v_#term_type#"=term>
		</cfloop>
		<cfset formatstyle=''>
		<cfif v_nomenclatural_code is "ICBN">
			<cfset formatstyle='plant'>
		<cfelseif v_nomenclatural_code is "ICZN">
			<cfset formatstyle='animal'>
		<cfelseif v_kingdom is "Plantae">
			<cfset formatstyle='plant'>
		<cfelseif v_kingdom is "Animalia">
			<cfset formatstyle='animal'>
		</cfif>
		<cfset gdn=''>
		<!--- start at the right, add stuff on until we have something ---->
		<cfif formatstyle is "plant">
			<cfif len(v_species) gt 0>
				<!--- most common, deal with it and leave when we can ---->
				<cfset gdn='<i>#v_species#</i>'>
				<cfif len(v_author_text) gt 0>
					<cfset gdn=gdn & ' #v_author_text#'>
				</cfif>
				<!---- any subspecific terms we need to care about? ---->
				<cfquery name="sprank" dbtype="query">
					select RELATIVE_POSITION from ct where taxon_term='species'
				</cfquery>
				<cfset sst=''>
				<cfloop query="ct">
					<cfif len(ct.RELATIVE_POSITION) gt 0 and ct.RELATIVE_POSITION gt sprank.RELATIVE_POSITION and len(sst) is 0>
						<cfif len("v_#taxon_term#") gt 0>
							<cfset sst=evaluate("v_" & taxon_term)>
						</cfif>
					</cfif>
				</cfloop>
				<cfif len(sst) gt 0>
					<cfset itrm=replace(sst,v_species,'')>
					<cfif listlen(itrm,' ') gt 0>
						<!--- the last item is a name and needs italicized. The rest is rank stuff and does NOT need italicized. ---->
						<cfset ttrm=listlast(itrm,' ')>
						<cfset nttrm=listDeleteAt(itrm,listlen(itrm,' '),' ')>
						<cfset gdn=gdn & ' #nttrm# <i>#ttrm#</i>'>
					<cfelseif len(itrm) gt 0>
						<!--- shuold never, but whatever --->
						<cfset gdn=gdn & ' <i>#itrm#</i>'>
					</cfif>
				</cfif>
				<cfif len(v_infraspecific_author) gt 0>
					<cfset gdn=gdn & ' ' & v_infraspecific_author>
				</cfif>
			</cfif>
			<!--- genus separate, because italics ---->
			<cfif len(gdn) is 0 and len(v_genus) gt 0>
				<cfset gdn='<i>#v_genus#</i>'>
				<cfif len(v_author_text) gt 0>
					<cfset gdn=gdn & ' #v_author_text#'>
				</cfif>
			</cfif>
			<!--- if if we didn't get anything, try scientific_name ---->
			<cfif len(gdn) is 0 and len(v_scientific_name) gt 0>
				<cfset gdn=v_scientific_name>
				<cfif len(v_author_text) gt 0>
					<cfset gdn=gdn & ' #v_author_text#'>
				</cfif>
			</cfif>
			<cfif len(gdn) is 0>
				<!---- if we STILL didn't get anything, grab the lowest term ---->
				<cfquery name="genusrank" dbtype="query">
					select RELATIVE_POSITION from ct where taxon_term='genus'
				</cfquery>
				<cfloop query="ct">
					<cfif len(RELATIVE_POSITION) gt 0 and RELATIVE_POSITION lt genusrank.RELATIVE_POSITION and len(gdn) is 0>
						<cfif len("v_#taxon_term#") gt 0>
							<br>got this one
							<cfset gdn=evaluate("v_" & taxon_term)>
						</cfif>
					</cfif>
				</cfloop>
				<cfif len(v_author_text) gt 0>
					<cfset gdn=gdn & ' #v_author_text#'>
				</cfif>
			</cfif>
		<cfelse>
			<!---
				default, I suppose....

			--->
			<cfif len(v_subspecies) gt 0>
				<cfset gdn='<i>#v_subspecies#</i>'>
			<cfelseif len(v_species) gt 0>
				<cfset gdn='<i>#v_species#</i>'>
			<cfelseif len(v_genus) gt 0>
				<cfset gdn='<i>#v_genus#</i>'>
			<cfelseif len(v_scientific_name) gt 0>
				<cfset gdn=v_scientific_name>
			<cfelse>
				<!---- lowest-ranked term, no italics ---->
				<cfquery name="genusrank" dbtype="query">
					select RELATIVE_POSITION from ct where taxon_term='genus'
				</cfquery>
				<cfloop query="ct">
					<cfif len(RELATIVE_POSITION) gt 0 and RELATIVE_POSITION lt genusrank.RELATIVE_POSITION and len(gdn) is 0>
						<cfif len("v_#taxon_term#") gt 0>
							<cfset gdn=evaluate("v_" & taxon_term)>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<cfif len(v_author_text) gt 0>
				<cfset gdn=gdn & ' ' & v_author_text>
			</cfif>
		</cfif>
		<cfset gdn=trim(replace(gdn,' ,',',','all'))>
		<cfset gdn=trim(replace(gdn,'<i></i>','','all'))>
		 <cfset gdn=reReplace(gdn,"\s+"," ","All")>
		<cfreturn gdn>

		<cfcatch>
			<!---
			<cfreturn 'ERROR: ' & cfcatch.message>
			---->
			<cfreturn ''>
		</cfcatch>
		</cftry>
	</cfoutput>
</cffunction>



<cffunction name="getBlacklistHistory" returnType="string" access="public">
	<cfargument name="ip" required="yes">
	<!---- look up blacklist history; return email-safe HTML ---->
	<cfoutput>
		<cfsavecontent variable="t">
			<cftry>
				<cfif listlen(ip,'.') is not 4>
					<cfabort>
				</cfif>
				<cfset sn=listgetat(ip,1,'.') & '.' & listgetat(ip,2,'.')>
				<cfquery name="bl" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
					select
						count(*) c,
					    CASE when sysdate-LISTDATE > 180 then 'expired'
					      else 'recent'
					    END dstatus,
					    status
				    from
				        blacklist
				        where
				        CALC_SUBNET='#sn#'
				    group by
					    CASE when sysdate-LISTDATE > 180 then 'expired'
					      else 'recent'
					    END,
					    status
				</cfquery>
				<cfquery name="blsn" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
					select
						count(*) c,
						round(sysdate-INSERT_DATE) days_since_block,
					    status
				    from
				        blacklist_subnet
				        where
				        subnet='#sn#'
				        group by
				   round(sysdate-INSERT_DATE),
				    status
				</cfquery>
				Block history:
				<table border>
					<tr>
						<th>BlockAt</th>
						<th>TimeStatus</th>
						<th>Status</th>
						<th>Count</th>
					</tr>
					<cfloop query="bl">
						<tr>
							<td>IP</td>
							<td>#dstatus#</td>
							<td>#status#</td>
							<td>#c#</td>
						</tr>
					</cfloop>
					<cfloop query="blsn">
						<tr>
							<td>subnet</td>
							<td>#days_since_block#</td>
							<td>#status#</td>
							<td>#c#</td>
						</tr>
					</cfloop>
				</table>
				*** summary data are cached; check Arctos for current ***
				<cfcatch>
					----exception getting IP/Subnet info-----
				</cfcatch>
				</cftry>
			</cfsavecontent>
		</cfoutput>
	<cfreturn t>
</cffunction>




<cffunction name="loadFileS3" output="false" returnType="any" access="remote">
	<cfargument name="nothumb" required="no" default="false">
	 <!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listcontains(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cftry>
		<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
		</cfquery>

		<!---- make a username bucket. This will create or return an error of some sort. ---->
		<cfset currentTime = getHttpTimeString( now() ) />
		<cfset contentType = "text/html" />
		<cfset bucket="#replace(lcase(session.username),'_','','all')#">
		<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket
			] />
		<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
		<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>
		<cfhttp result="mkunamebkt" method="put" url="#s3.s3_endpoint#/#bucket#">
			<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
		    <cfhttpparam type="header" name="Content-Type" value="#contentType#" />
		    <cfhttpparam type="header" name="Date" value="#currentTime#" />
		</cfhttp>


		<cfset tempName=createUUID()>
		<cffile action="upload"	destination="#Application.sandbox#/" nameConflict="overwrite" fileField="file" mode="600">
		<cfset fileName=cffile.serverfile>
		<cffile action = "rename" destination="#Application.sandbox#/#tempName#.tmp" source="#Application.sandbox#/#fileName#">
		<cfset fext=listlast(fileName,".")>
		<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
		<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
		<cfset fName=replace(fName,'__','_','all')>
		<cfset fileName=fName & '.' & fext>
		<cfset vfn=isValidMediaUpload(fileName)>
		<cfif len(vfn) gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg=vfn>
			<cfreturn serializeJSON(r)>
		</cfif>
		<cfset lclFile="#Application.sandbox#/#fileName#">
		<cffile variable="content" action = "readBinary"  file="#Application.sandbox#/#tempName#.tmp">
		<!--- generate a checksum while we're holding the binary ---->
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(content)>
		<!--- see if the image exists ---->
		<cfquery name="ckck" datasource="uam_god">
			select media_id from media_labels where MEDIA_LABEL='MD5 checksum' and LABEL_VALUE='#md5#'
		</cfquery>
		<cfif ckck.recordcount gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg='Media Exists'>
			<cfloop list="#valuelist(ckck.media_id)#" index="i">
				<cfset r.msg=r.msg & '\n#Application.serverRootURL#/media/#i#'>
			</cfloop>
			<cfset r.msg=r.msg & '\nUse the "link to existing" option'>
			<cfreturn serializeJSON(r)>
		</cfif>


		<cfset r.md5=md5>
		<!----
			this does not work properly; Adobe ColdFusion thinks Adobe DNGs are TIFFs
			<cfset mimetype=FilegetMimeType("#Application.sandbox#/#tempName#.tmp")>
			<cfset r.mimetype=mimetype>
		 ---->
		<cfif fext is "jpg" or fext is "jpeg">
			<cfset mimetype="image/jpeg">
			<cfset mediatype="image">
		<cfelseif fext is "dng">
			<cfset mimetype="image/dng">
			<cfset mediatype="image">
		<cfelseif fext is "pdf">
			<cfset mimetype="application/pdf">
			<cfset mediatype="text">
		<cfelseif fext is "png">
			<cfset mimetype="image/png">
			<cfset mediatype="image">
		<cfelseif fext is "txt">
			<cfset mimetype="text/plain">
			<cfset mediatype="text">
		<cfelseif fext is "wav">
			<cfset mimetype="audio/x-wav">
			<cfset mediatype="audio">
		<cfelseif fext is "m4v">
			<cfset mimetype="video/mp4">
			<cfset mediatype="video">
		<cfelseif fext is "tif" or fext is "tiff">
			<cfset mimetype="image/tiff">
			<cfset mediatype="image">
		<cfelseif fext is "mp3">
			<cfset mimetype="audio/mpeg3">
			<cfset mediatype="audio">
		<cfelseif fext is "mov">
			<cfset mimetype="video/quicktime">
			<cfset mediatype="video">
		<cfelseif fext is "xml">
			<cfset mimetype="application/xml">
			<cfset mediatype="text">
		<cfelseif fext is "wkt">
			<cfset mimetype="text/plain">
			<cfset mediatype="text">
		<cfelse>
			<cfset r.statusCode=400>
			<cfset r.msg='Invalid filetype: could not determine mime or media type.'>
			<cfreturn serializeJSON(r)>
		</cfif>

		<cfset r.media_type=mediatype>
		<cfset r.mime_type=mimetype>

		<!--- now load the file ---->
		<!--- "virtual" date-bucket inside the username bucket ---->
		<cfset bucket="#replace(lcase(session.username),'_','','all')#/#dateformat(now(),'YYYY-MM-DD')#">
		<cfset currentTime = getHttpTimeString( now() ) />
		<cfset contentType=mimetype>
		<cfset contentLength=arrayLen( content )>
		<cfset stringToSignParts = [
		    "PUT",
		    "",
		    contentType,
		    currentTime,
		    "/" & bucket & "/" & fileName
		] />

		<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
		<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>
		<cfhttp result="putfile" method="put" url="#s3.s3_endpoint#/#bucket#/#fileName#">
			<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
		    <cfhttpparam type="header" name="Content-Length" value="#contentLength#" />
		    <cfhttpparam type="header" name="Content-Type" value="#contentType#"/>
		    <cfhttpparam type="header" name="Date" value="#currentTime#" />
		    <cfhttpparam type="body" value="#content#" />
		</cfhttp>
		<cfset media_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#fileName#">

		<!----
			the nothumb var allows for just uploading an image eg a new thumb
			https://github.com/ArctosDB/arctos/issues/1659
		---->
		<cfif nothumb is false and IsImageFile("#Application.sandbox#/#tempName#.tmp")>
			<!---- make a thumbnail ---->
			<cfimage action="info" structname="imagetemp" source="#Application.sandbox#/#tempName#.tmp">
			<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
	    	<cfset newheight = x*imagetemp.height>
		    <cfset barefilename=listgetat(filename,1,".")>
		    <cfset tfilename="tn_#barefilename#.jpg">
		   	<cfimage action="convert" source="#Application.sandbox#/#tempName#.tmp" width="#newwidth#" height="#newheight#" destination="#Application.sandbox#/#tfilename#" overwrite = "true">
		   	<cfimage action="resize" source="#Application.sandbox#/#tfilename#" width="#newwidth#" height="#newheight#" destination="#Application.sandbox#/#tfilename#" overwrite = "true">
		   	<cfset bucket="#replace(lcase(session.username),'_','','all')#/#dateformat(now(),'YYYY-MM-DD')#/tn">
			<cfset currentTime = getHttpTimeString( now() ) />
			<cfset contentType = "image/jpeg" />
			<cffile variable="content" action = "readBinary"  file="#Application.sandbox#/#tfilename#">
			<cfset contentLength=arrayLen( content )>
			<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket & "/" & tfilename
			] />
			<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
			<cfset signature = binaryEncode(
				binaryDecode(
					hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
					"hex"
				),
				"base64"
			)>
			<cfhttp result="putTN" method="put" url="#s3.s3_endpoint#/#bucket#/#tfilename#">
				<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
			    <cfhttpparam type="header" name="Content-Length"  value="#contentLength#" />
			    <cfhttpparam type="header" name="Content-Type"  value="#contentType#" />
			    <cfhttpparam type="header" name="Date" value="#currentTime#" />
			    <cfhttpparam type="body" value="#content#" />
			</cfhttp>
			<cfset r.preview_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#tfilename#">
		<cfelse>
			<cfset r.preview_uri="">
		</cfif>
		<!--- statuscode of putting the actual file - the important thing--->
	    <cfset r.statusCode=left(putfile.statusCode,3)>
	  	<cfif r.statuscode is not "200">
			 <cfset r.statusCode=putfile.statusCode>
			 <cfset r.fileContent=putfile.fileContent>
		</cfif>
		<cfset r.filename="#fileName#">
		<cfset r.media_uri="#media_uri#">
			<cfcatch>
				<cfset r.statusCode=444>
				<cfset r.msg=cfcatch.message & '; ' & cfcatch.detail>
				<cfif isdefined("putTN")>
					<cfset r.putTN=putTN>
				</cfif>
				<cfif isdefined("putfile")>
					<cfset r.putfile=putfile>
				</cfif>
				<cfif isdefined("mkunamebkt")>
					<cfset r.mkunamebkt=mkunamebkt>
				</cfif>
			</cfcatch>
	</cftry>
	<cfreturn serializeJSON(r)>
</cffunction>
<!--------
<cffunction name="loadFile" output="false" returnType="string" access="remote">
	<!--- keep this as we're testing loadFileS3; delete when that has demonstrated stability --->


	<cftry>
		<cfset tempName=createUUID()>
		<cfset loadPath = "#Application.webDirectory#/mediaUploads/#session.username#">
		<cftry>
			<cfdirectory action="create" directory="#loadPath#" mode="775">
			<cfcatch>
	    		<!--- it already exists, do nothing--->
			</cfcatch>
		</cftry>
		<cffile action="upload"	destination="#Application.sandbox#/" nameConflict="overwrite" fileField="file" mode="600">
		<cfset fileName=cffile.serverfile>
		<cffile action = "rename" destination="#Application.sandbox#/#tempName#.tmp" source="#Application.sandbox#/#fileName#">
		<cfset fext=listlast(fileName,".")>
		<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
		<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
		<cfset fName=replace(fName,'__','_','all')>

		<cfset fileName=fName & '.' & fext>

		<cfset vfn=isValidMediaUpload(fileName)>

		<cfif len(vfn) gt 0>
			 <cfset r.statusCode=400>
			<cfset r.msg=vfn>
			<cfreturn serializeJSON(r)>
		</cfif>

		<cffile action="move" source="#Application.sandbox#/#tempName#.tmp" destination="#loadPath#/#fileName#" nameConflict="error" mode="644">
		<cfset media_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/#fileName#">
		<cfif IsImageFile("#loadPath#/#fileName#")>
			<cfset tnAbsPath=loadPath & '/tn_' & fileName>
			<cfset tnRelPath=replace(loadPath,application.webDirectory,'') & '/tn_' & fileName>
			<cfimage action="info" structname="imagetemp" source="#loadPath#/#fileName#">
			<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
	      	<cfset newheight = x*imagetemp.height>
	   		<cfimage action="resize" source="#loadPath#/#fileName#" width="#newwidth#" height="#newheight#"
				destination="#tnAbsPath#" overwrite="false">
			<cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
			<cfset r.preview_uri="#preview_uri#">
		<cfelse>
			<cfset r.preview_uri="">
		</cfif>
	    <cfset r.statusCode=200>
		<cfset r.filename="#fileName#">
		<cfset r.media_uri="#media_uri#">

		<cfcatch>
			<cftry>
				<cfset r.statusCode=400>
				<cfif cfcatch.message contains "already exists">
					<cfset umpth=#ucase(session.username)# & "/" & #ucase(fileName)#>
					<cfquery name="fexist" datasource="uam_god">
						select media_id from media where upper(media_uri) like '%#umpth#'
					</cfquery>
					<cfset midl=valuelist(fexist.media_id)>
					<cfset msg="The file \n\n#Application.serverRootURL#/mediaUploads/#session.username#/#fileName#\n\n">
					<cfset msg=msg & "already exists">
					<cfif len(midl) gt 0>
						<cfset msg=msg & " and may be used by \n\n#Application.ServerRootURL#/media/#midl#\n\nCheck the media_URL above.">
						<cfset msg=msg & " Link to the media using the media_id (#midl#) in the form below.">
					<cfelse>
						<cfset msg=msg & " and does not seem to be used for existing Media. Create media with the already-loaded file by">
						<cfset msg=msg & " pasting the above media_uri into ">
						<cfset msg=msg & "\n\n#Application.serverRootURL#/media.cfm?action=newMedia">
						<cfset msg=msg & "\n\nA preview may exist at ">
						<cfset msg=msg & "\n\n#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
					</cfif>
					<cfset msg=msg & "\n\nRe-name and re-load the file ONLY if you are sure it does not exist on the sever.">
					<cfset msg=msg & " Do not create duplicates.">
				<cfelse>
					<cfset msg=cfcatch.message & '; ' & cfcatch.detail>
				</cfif>
				<cfset r.msg=msg>
			<cfcatch>
				<cfset r.statusCode=400>
				<cfset r.msg=cfcatch.message & '; ' & cfcatch.detail>
			</cfcatch>
			</cftry>
		</cfcatch>
	</cftry>
	<cfreturn serializeJSON(r)>
</cffunction>
---------->
<!------------------>
<cffunction name="exitLink" access="public">
	<cfargument name="target" required="yes">
	<!----
		This is called with the ?open parameter on media exit links

		One point of failure is enough; don't check anything once we lose the "spiffy" code
			(which is replaced with something more appropriate before return)

		Purpose:
			- ensure that the request looks like a URL (not a limitation, but we have nothing else
				at the moment and having anything else seems unlikely, so check)
			- ensure that the reqeust is for something in our Media table (avoid spambots etc)
			- check for a timely response
	---->
	<cfoutput>
	<cfset result=StructNew()>
	<cfset result.status='spiffy'>
	<!---- ensure that the request looks like a URL  ---->
	<cfif left(target,4) is not "http">
		<cfset result.status='error'>
		<cfset result.code='400'>
		<cfset result.msg='Invalid Format: the target does not seem to be a valid URL.'>
		<cfset http_target=URLDecode(target)>
	<cfelse>
		<!---- eventually we may want to guess at fixing errors etc, so local URL time ---->
		<cfset http_target=URLDecode(target)>
	</cfif>
	<cfset result.http_target=http_target>
	<!---- ensure that the reqeust is for something in our Media table ---->
	<cfif result.status is "spiffy">
	<!------>
		<cfquery name="isus"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from media where upper(trim(media_uri))='#ucase(trim(http_target))#'
		</cfquery>
		<cfif isus.c neq 1>
			<cfset result.status='error'>
			<cfset result.code='404'>
			<cfset result.msg='The Media does not exist at the URL you requested.'>
		</cfif>
	</cfif>


		<cfif isdefined("debug") and debug is true>
			<cfdump var=#result#>
		</cfif>


	<cfif result.status is "spiffy">
		<!---- check for a timely response ---->

		<cfif http_target contains "https://arctos.database.museum">
			<cfset ftgt=replace(http_target,'https://arctos.database.museum','http://arctos.database.museum')>
		<cfelse>
			<cfset ftgt=http_target>
		</cfif>

		<cfhttp url="#ftgt#" method="head" timeout="3"></cfhttp>

		<cfif isdefined("debug") and debug is true>
			<cfdump var=#cfhttp#>
		</cfif>
		<!---- yay ---->
		<cfif isdefined("cfhttp.statuscode") and left(cfhttp.statuscode,3) is "200">
			<cfset result.status='success'>
			<cfset result.code=200>
			<cfset result.msg='yay everybody!'>
		</cfif>
		<cfif result.status is not 'success'>
			<!---- no response; timed out ---->
			<cfif not isdefined("cfhttp.statuscode")>
				<cfset result.status='timeout'>
				<cfset result.code=408>
				<cfset result.msg='The Media server is not responding in a timely manner. This may be caused by a temporary interruption'>
				<cfset result.msg=result.msg & ", server configuration, or resource abandonment.">
			</cfif>
			<!--- response, but not 200 ---->
			<cfif isdefined("cfhttp.statuscode") and isnumeric(left(cfhttp.statuscode,3)) and left(cfhttp.statuscode,3) is not "200">
				<cfset result.status='error'>
				<cfset result.code=left(cfhttp.statuscode,3)>
				<cfif left(cfhttp.statuscode,3) is "405">
					<cfset result.msg='The server hosting the link refused our request method.'>
				<cfelseif left(cfhttp.statuscode,3) is "408">
					<cfset result.msg='The server hosting the link may be slow or nonresponsive.'>
				<cfelseif  left(cfhttp.statuscode,3) is "404">
					<cfset result.msg='The external resource does not appear to exist.'>
				<cfelseif left(cfhttp.statuscode,3) is "500">
					<cfset result.msg='The server may be down or misconfigured.'>
				<cfelseif left(cfhttp.statuscode,3) is "503">
					<cfset result.msg='The server is currently unavailable; this is generally temporary.'>
				<cfelse>
					<cfset result.msg='An unknown error occurred'>
				</cfif>
			</cfif>
			<cfif isdefined("cfhttp.statuscode") and not isnumeric(left(cfhttp.statuscode,3))>
				<cfset result.status='failure'>
				<cfset result.code=500>
				<cfset result.msg='The resource is not responding correctly, and may be misconfigured or missing.'>
			</cfif>
		</cfif>
	</cfif>
	<!--- all checked, log the request ---->
	<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into exit_link (
			username,
			ipaddress,
			from_page,
			target,
			http_target,
			when_date,
			status
		) values (
			'#session.username#',
			'#request.ipaddress#',
			'#cgi.HTTP_REFERER#',
			'#target#',
			'#http_target#',
			sysdate,
			'#result.status#'
		)
	</cfquery>
	<!--- and return the results ---->
	<cfreturn result>
</cfoutput>
</cffunction>
<!---------------------------------------------------------->
<cffunction name="isValidMediaUpload">
	<cfargument name="fileName" required="yes">
	<cfset err="">
	<cfset extension=listlast(fileName,".")>
	<cfset acceptExtensions="jpg,jpeg,gif,png,pdf,txt,m4v,mp3,wav,wkt,dng,tif,tiff,mov,xml">
	<cfif listfindnocase(acceptExtensions,extension) is 0>
		<cfset err="An valid file name extension (#acceptExtensions#) is required. extension=#extension#">
	</cfif>
	<cfset name=replace(fileName,".#extension#","")>
	<cfif REFind("[^A-Za-z0-9_-]",name,1) gt 0>
		<cfset err="Filenames may contain only letters, numbers, dash, and underscore.">
	</cfif>
	<cfif REFind("[^A-Za-z0-9]",left(name,1)) gt 0>
		<cfset err="Filenames must start with a letter or number.">
	</cfif>
	<cfreturn err>
</cffunction>

















<!------------------>
<cffunction name="isMobileClient" output="true" returnType="boolean" access="remote">
    <cfif reFindNoCase("(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino",CGI.HTTP_USER_AGENT) GT 0 OR
                reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-",Left(CGI.HTTP_USER_AGENT,4)) GT 0>
        <cfreturn true>
	<cfelse>
	   <cfreturn false>
    </cfif>
</cffunction>
<cffunction name="isMobileTemplate" output="true" returnType="boolean" access="public">
	<cfset thisFolder=listgetat(request.rdurl,1,"/")>
	<cfif thisFolder is replace(Application.mobileURL,"/","","all")>
	   <cfreturn true>
	<cfelse>
	   <cfreturn false>
	</cfif>
</cffunction>
<!------------------------------------------------------->
<cffunction name="mobileDesktopRedirect" output="true" returnType="string" access="public">
	<!----
		<br>START mobileDesktopRedirect
		<br>cgi.script_name: #cgi.script_name#
		This function redirects between mobile and desktop based on device detection scripts from
		http://detectmobilebrowsers.com/
		cookies and current page.
		Rules:
		IF no cookie AND is mobile device --- > redirect to mobile
		It's called at onRequestStart in Application.cfc
	---->
	<cfoutput>
		<!---- only redirect if they're coming in to something for which we have a mobile page ---->
		<cfif cgi.script_name is "/dm.cfm">
		  <cfreturn>
		</cfif>
		<cfif isdefined("request.rdurl") and (
			request.rdurl contains "/guid/" or
			request.rdurl contains "/name/" or
			replace(cgi.script_name,"/","","all") is "SpecimenSearch.cfm" or
			replace(cgi.script_name,"/","","all") is "taxonomy.cfm" or
			replace(cgi.script_name,"/","","all") is "SpecimenResults.cfm")>
			<!--- check to see if they have set a cookie ---->
			<cfif IsDefined("Cookie.dorm")>
				<!--- they have an explicit preference and we have a mobile option, send them where they want to be ---->
				<cfif cookie.dorm is "mobile" and isMobileTemplate() is false>
					<!---- DEVICE: untested; CURRENT SITE: desktop; DESIRED SITE: mobile; ACTION: redirect ---->
					<cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
					<cflocation url="#z#" addtoken="false">
				<cfelseif cookie.dorm is not "mobile" and isMobileTemplate() IS TRUE>
					<!---- DEVICE: untested; CURRENT SITE: mobile; DESIRED SITE: desktop; ACTION: redirect ---->
					<cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
					<cflocation url="#z#" addtoken="false">
				</cfif>
			<cfelse>
				<!----
					We have a mobile option and they've expressed no preferences.
					If they're on a mobile device and NOT a mobile page, redirect them - they're a first-time user
					---->
				<cfif isMobileClient() is true and isMobileTemplate() is false>
	                <!--- see if they're on a mobile device but not a mobile page ---->
				     <cfset z="/dm.cfm?r=" & mdflip(request.rdurl)>
	                <cflocation url="#z#" addtoken="false">
				</cfif>
			</cfif>
	    </cfif>
	</cfoutput>
	<cfreturn>
</cffunction>
<!------------------>

<cffunction name="mdflip" output="false" returnType="string" access="private">
    <!--- translate mobile URLs to desktop and vice-versa --->
    <cfargument name="q" type="string" required="true" />
	<cfif q contains Application.mobileURL>
	   <cfset r=replace(q,Application.mobileURL,'/')>
	<cfelse>
	   <cfset r=Application.mobileURL & "/" & q>
	</cfif>
    <cfset r=replace(r,'//','/','all')>
    <cfset r=replace(r,'//','/','all')>
	<cfreturn r>
</cffunction>

<!------------------>

<cffunction name="makeCaptchaString" returnType="string" output="false">
    <cfscript>
		var chars = "23456789ABCDEFGHJKMNPQRS";
		var length = randRange(4,7);
		var result = "";
	    for(i=1; i <= length; i++) {
	        char = mid(chars, randRange(1, len(chars)),1);
	        result&=char;
	    }
	    return result;
    </cfscript>
</cffunction>
<!------------------------------------------------------------------------------------>
<cffunction name="getIpAddress">
	<!--- grab everything that might be a real IP ---->
	<CFSET ipaddress="">
	<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
		<CFSET ipaddress=listappend(ipaddress,CGI.HTTP_X_Forwarded_For,",")>
	</cfif>
	<CFif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
		<!--- we'll ultimately grab the last if we can't pick one and this is usually better than x_fwd so append last ---->
		<CFSET ipaddress=listappend(ipaddress,CGI.Remote_Addr,",")>
	</cfif>
	<!--- keep the raw/everything, it's useful ---->
	<cfset request.rawipaddress=ipaddress>
	<cfif listfind(ipaddress,'129.114.52.171')>
		<cfset ipaddress=listdeleteat(ipaddress,listfind(ipaddress,'129.114.52.171'))>
	</cfif>
	<!--- loop through the possibilities, keep only things that look like an IP ---->
	<cfset vips="">
	<cfloop list="#ipaddress#" delimiters="," index="tip">
		<cfset x=trim(tip)>
		<cfif listlen(x,".") eq 4 and
			isnumeric(replace(x,".","","all")) and
			refind("(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)",x) eq 0 and
			refind("^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$",x) eq 1
		>
			<cfset vips=listappend(vips,x,",")>
		</cfif>
	</cfloop>
	<cfif len(vips) gt 0>
		<!---- grab the last one, because why not....---->
		<cfset ipaddress=listlast(vips)>
	<cfelse>
		<!---- or something that looks vaguely like an IP to make other things slightly more predictable ---->
		<cfset ipaddress="0.0.0.0">
	</cfif>
	<cfset requestingSubnet=listgetat(ipaddress,1,".") & "." & listgetat(ipaddress,2,".")>
	<cfset request.ipaddress=trim(ipaddress)>
	<cfset request.requestingSubnet=trim(requestingSubnet)>
</cffunction>
<!------------------------------------------------------------------------------------>
<cffunction name="setAppBL">
	<!--- get IPs that aren't subnet-blocked --->
	<cfquery name="d" datasource="uam_god">
		select distinct ip from uam.blacklist where
			status='active' and
			sysdate-LISTDATE<180 and
			calc_subnet not in (
				select distinct subnet from (
		    		select subnet from uam.blacklist_subnet where status in  ('active','autoinsert') and sysdate-INSERT_DATE<180
					union
		    		select  subnet from uam.blacklist_subnet where status ='hardblock'
		    	)
			)
	</cfquery>
	<cfset Application.blacklist=valuelist(d.ip)>
	<!---
		actively blocked subnets
		never autorelease hardblock
		the weird format performs slightly better
	---->
	<cfquery name="sn" datasource="uam_god">
		select distinct subnet from (
    		select subnet from uam.blacklist_subnet where status in  ('active','autoinsert') and sysdate-INSERT_DATE<180
			union
    		select  subnet from uam.blacklist_subnet where status ='hardblock'
    	)
	</cfquery>
	<cfset application.subnet_blacklist=valuelist(sn.subnet)>
</cffunction>
<!------------------------------------------------------------------------------------>
<cffunction name="checkRequest">
	<cfargument name="inp" type="any" required="false"/>
	<cfif session.roles contains "coldfusion_user">
       <!---- never blacklist "us" ---->
       <cfreturn true>
    </cfif>
	<!---
		first check if they're already blacklisted
		If they are, just include the notification/form and abort
	---->
	<cfif listfind(application.subnet_blacklist,request.requestingSubnet)>
		<cfif replace(cgi.script_name,'//','/','all') is not "/errors/blocked.cfm">
			<cfscript>
				getPageContext().forward("/errors/blocked.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
	<cfif listfind(application.blacklist,request.ipaddress)>
		<cfif replace(cgi.script_name,'//','/','all') is not "/errors/blocked.cfm">
			<cfscript>
				getPageContext().forward("/errors/blocked.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
	<!---
		if they made it here, they are
			1) not "us"
			2) not on the blacklist
		See if it's a legit request. If so do nothing, otherwise call autoblacklist and abort.
	---->
	<cfif isdefined("request.rdurl")>
		<cfset lurl=request.rdurl>
	<cfelse>
		<cfset lurl="">
	</cfif>
	<!--- now replace all potential delimiters with chr(7), so we can predictable loop ---->
	<cfset lurl=replace(lurl,",",chr(7),"all")>
	<cfset lurl=replace(lurl,".",chr(7),"all")>
	<cfset lurl=replace(lurl,"/",chr(7),"all")>
	<cfset lurl=replace(lurl,"&",chr(7),"all")>
	<cfset lurl=replace(lurl,"+",chr(7),"all")>
	<cfset lurl=replace(lurl,"(",chr(7),"all")>
	<cfset lurl=replace(lurl,")",chr(7),"all")>
	<cfset lurl=replace(lurl,"%20",chr(7),"all")>
	<cfset lurl=replace(lurl,"%27",chr(7),"all")>
	<cfset lurl=replace(lurl,";",chr(7),"all")>
	<cfset lurl=replace(lurl,"?",chr(7),"all")>
	<cfset lurl=replace(lurl,"=",chr(7),"all")>
	<cfset lurl=replace(lurl,"%2B",chr(7),"all")>
	<cfset lurl=replace(lurl,"%28",chr(7),"all")>
	<cfset lurl=replace(lurl,"%22",chr(7),"all")>
	<cfset lurl=replace(lurl,"%3E",chr(7),"all")>
	<cfset lurl=replace(lurl,"%2F",chr(7),"all")>


	<!-----
		START: stuff in this block is always checked; this is called at onRequestStart
		Performance is important here; keep it clean and minimal
	 ------>
	 <!---
	 	these seem to be malicious 99% of the time, but legit traffic often enough that blacklisting them
	 	isn't a great idea, so just ignore
	 ----->
	 <cfif isdefined("cgi.HTTP_ACCEPT_ENCODING") and cgi.HTTP_ACCEPT_ENCODING is "identity">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.REQUEST_METHOD") and cgi.REQUEST_METHOD is "OPTIONS">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.query_string")>
		<!--- this stuff is never allowed, ever ---->
		<cfset nono="passwd,proc">
		<cfloop list="#cgi.query_string#" delimiters="./," index="i">
			<cfif listfindnocase(nono,i)>
				<cfset bl_reason='#i# in query_string'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("cgi.blog_name") and len(cgi.blog_name) gt 0>
		<cfset bl_reason='cgi.blog_name exists'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("cgi.HTTP_REFERER") and cgi.HTTP_REFERER contains "/bash">
		<cfset bl_reason='HTTP_REFERER contains /bash'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!--- these are user-agents that regularly ignore the robots.txt file --->
	<!--- keep this synced up with /ScheduledTasks/createRobots.cfm ---->
	<cfset badbot="Apache-HttpClient,AlphaBot,admx,arquivo">
	<cfset badbot=badbot & ",Baiduspider,bash,BUbiNG,Barkrowler,BLEXBot">
	<cfset badbot=badbot & ",ca-crawler,CCBot,coccocbot">
	<cfset badbot=badbot & ",Domain,DeuSu,DomainTunoCrawler,DnyzBot">
	<cfset badbot=badbot & ",Exabot">
	<cfset badbot=badbot & ",FemtosearchBot">
	<cfset badbot=badbot & ",Gluten,Gluten Free Crawler,GrapeshotCrawler,Go-http-client">
	<cfset badbot=badbot & ",HubSpot">
	<cfset badbot=badbot & ",ltx71">
	<cfset badbot=badbot & ",MegaIndex,MJ12bot,multi_get,MauiBot,meg,Mail.RU_Bot">
	<cfset badbot=badbot & ",naver,Nutch,netEstate">
	<cfset badbot=badbot & ",Qwantify">
	<cfset badbot=badbot & ",re-animator">
	<cfset badbot=badbot & ",SemrushBot,spbot,Synapse,Sogou,SiteExplorer,Slurp,SeznamBot,Seekport,sqlmap">
	<cfset badbot=badbot & ",TweetmemeBot,TurnitinBot">
	<cfset badbot=badbot & ",UnisterBot">
	<cfset badbot=badbot & ",VelenPublicWebCrawler">
	<cfset badbot=badbot & ",Wotbox">
	<cfset badbot=badbot & ",YandexBot,Yeti">

	<cfif isdefined("cgi.HTTP_USER_AGENT")>
		<cfloop list="#badbot#" index="b">
			<cfif cgi.HTTP_USER_AGENT contains b>
				<cfset bl_reason='HTTP_USER_AGENT is blocked crawler #b#'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfloop>
	</cfif>

	<!----
		is blacklisting with http://arctos.database.museum/guid/UAM:EH:0301-0001 so turn off for now
	<cfif right(lurl,5) is "-1#chr(7)#">
		<cfset bl_reason='URL ends with -1%27'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	---->
	<cfif right(lurl,3) is "%00">
		<cfset bl_reason='URL ends with %00'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdurl") and left(request.rdurl,6) is "/��#chr(166)#m&">
		<cfset bl_reason='URL starts with /��#chr(166)#m&'>
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<cfif isdefined("request.rdurl") and (request.rdurl contains "%27A=0" or request.rdurl contains "%270=A")>
		<cfset bl_reason="URL contains %27A=0 or %270=A">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!---- various attempts at SQL injection ---->
	<cfif isdefined("request.rdurl") and (
			request.rdurl contains "' and 'x'='x" or
			request.rdurl contains "%27%20and%20%27x%27%3D%27x" or
			request.rdurl contains "%22%20and%20%22x%22%3D%22x"
		)>
		<cfset bl_reason="URL contains 'x'='x">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>

	<cfif isdefined("request.rdurl") and request.rdurl contains "'A=0">
		<cfset bl_reason="URL contains 'A=0">
		<cfinclude template="/errors/autoblacklist.cfm">
		<cfabort>
	</cfif>
	<!--- check these every time, even if there's no error; these things are NEVER allowed in a URL ---->
	<cfset x="script,write">
	<cfloop list="#lurl#" delimiters="#chr(7)#" index="i">
		<cfif listfindnocase(x,i)>
			<cfset bl_reason='URL contains #i#'>
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
	</cfloop>

	<!----- END: stuff in this block is always checked; this is called at onRequestStart ------>
	<!-----
		START: stuff in this block is only checked if there's an error
		Performance is unimportant here; this is going to end with an error
	 ------>



	<cfif isdefined("inp")>
		<cfif len(lurl) gt 0>
		<!----
			<cfif lurl contains "utl_inaddr" or lurl contains "get_host_address">
				<cfset bl_reason='URL contains utl_inaddr or get_host_address'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfif request.rdurl contains "#chr(96)##chr(195)##chr(136)##chr(197)#">
				<cfset bl_reason='URL contains #chr(96)##chr(195)##chr(136)##chr(197)#'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			----->
			<!---- random junk that in combination with an error is always indicitive of bot/spam/probe/etc. traffic---->
			<cfset x="">
			<cfset x=x & ",@@version,#chr(96)##chr(195)##chr(136)##chr(197)#,'A=0,/,0admin,0manager)">
			<cfset x=x & ",1phpmyadmin,2phpmyadmin,3phpmyadmin,4phpmyadmin">
			<cfset x=x & ",account,administrator,admin-console,attr(,asmx,abstractapp,adimages,asp,aspx,awstats,appConf,announce,ads,ackBulletin,aupm,apply">
			<cfset x=x & ",ashx,app_debug,assets,auth,App,ASPSamp,AdvWorks,AccountService,Accounts,autoprov,amf">
			<cfset x=x & ",backup,backend,backoffice,blog,board,backup-db,backup-scheduler,batch,bea_wls_deployment_internal,bitrix">
			<cfset x=x & ",career,char,chr,ctxsys,CHANGELOG,content,cms,checkupdate,colorpicker,comment,comments,connectors,cgi,cgi-bin,cgi-sys">
			<cfset x=x & ",calendar,config,client,cube,cursor,COLUMN_NAME,CHECKSUM,CHARACTER_MAXIMUM_LENGTH,create,check_proxy,cfide,cfgmaker,cfg">
			<cfset x=x & ",catalog,cart,CoordinatorPortType,chat,cpanel,cf_scripts,COMMIT_EDITMSG,console,CHANGELOG,com_sun_web_ui,cfdocs">
			<cfset x=x & ",classLoader,cacheObjectMaxSize,configs,cisco,cof">
			<cfset x=x & ",drithsx,dbg,dbadmin,declare,DB_NAME,databases,displayAbstract,db_backup,do,downloader,DEADBEEF,deployment-config,dbm,device">
			<cfset x=x & ",etc,environ,exe,editor,ehcp,employee,entries,elfinder,erpfilemanager,equipment,env">
			<cfset x=x & ",fulltext,feed,feeds,filemanager,fckeditor,FileZilla,fetch,FETCH_STATUS,ftpconfig,flex2gateway,FxCodeShell">
			<cfset x=x & ",getmappingxpath,get_host_address,git,globalHandler,git,.git,grandstream,glp">
			<cfset x=x & ",html(,HNAP1,htdocs,horde,HovercardLauncher,HelloWorld,has_dbaccess,hana,hooks,heads">
			<cfset x=x & ",inurl,invoker,ini,into,INFORMATION_SCHEMA,iefixes,id_rsa,id_dsa">
			<cfset x=x & ",jbossws,jbossmq-httpil,jspa,jiraHNAP1,jsp,jmx-console,journals,JBoss,jira,jkstatus,joomla,jsf,jobs,jd_rsa">
			<cfset x=x & ",lib,lightbox,local-bin,LoginForm,localization,logs,logon,linksys,ldskflks">
			<cfset x=x & ",master,mpx,mysql,mysql2,mydbs,manager,myadmin,muieblackcat,mail,magento_version,manifests,market,mrtg,modules,mychat">
			<cfset x=x & ",news,nyet,newdsn,node">
			<cfset x=x & ",ord_dicom,ordsys,owssvr,ol,objects,owa,openshift,onrequestend,openings">
			<cfset x=x & ",php,phppath,phpMyAdmin,PHPADMIN,phpldapadmin,phpMyAdminLive,_phpMyAdminLive,printenv,proc,plugins,passwd,pma2,pmc">
			<cfset x=x & ",pma4,php5,pre-receive,provisioning,prov">
			<cfset x=x & ",pma,phppgadmin,prescription,phpmychat,pre-push,polycom">
			<cfset x=x & ",rand,reviews,rutorrent,rss,roundcubemail,roundcube,README,railo-context,railo,Rapid7,register,remote_support,remote_tunnel">
			<cfset x=x & ",remote-sync,regex,register,rar,refs,receive,remotes,rsa,rsp">
			<cfset x=x & ",sys,swf,server-status,stories,setup,sign_up,system,signup,scripts,sqladm,soapCaller,simple-backup,sedlex,sysindexes">
			<cfset x=x & ",sftp-config,store,shop,server_info">
			<cfset x=x & ",sysobjects,svn,sap,ssh,stash,STRAGG">
			<cfset x=x & ",servlet,spiffymcgee,server-info,sparql,sysobjects,sample">
			<cfset x=x & ",trackback,texteditor,tar">
			<cfset x=x & ",utl_inaddr,uploadify,userfiles,updates,update,UserFollowResource,unepwcmcsml">
			<cfset x=x & ",verify-tldnotify,version,varien,viagra,vscode,views,vacancies">
			<cfset x=x & ",wiki,wp-admin,wp,webcalendar,webcal,webdav,w00tw00t,webmail,wp-content,wdisp,wooebay,wlwmanifest,webfig,wordpress,webforms,wdpa">
			<cfset x=x & ",YandexImages,yealink">
			<cfset x=x & ",zboard">


			<!--- just remember to not add these...---->
			<cfset hasCausedProbsNoCheck="case,register,TABLE_NAME,dashboard">
			<cfloop list="#hasCausedProbsNoCheck#" index="i">
				<cfif listfindnocase(x,i)>
					<cfset x=listdeleteat(x,listfindnocase(x,i))>
				</cfif>
			</cfloop>
			<cfloop list="#lurl#" delimiters="#chr(7)#" index="i">
				<cfif listfindnocase(x,i)>
					<cfset bl_reason='URL contains #i#'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfloop>
			<!---- For the Admin folder, which is linked from email, be a little paranoid/cautious
				and only get obviously-malicious activity
				Common requests:
					/errors/forbidden.cfm?ref=/Admin/
						so tread a bit lighter; ignore variables part, look only at page/template request
			--->
			<cfset x="admin">
			<cfif request.rdurl contains "?">
				<cfset rf=listgetat(request.rdurl,1,"?")>
				<cfloop list="#rf#" delimiters="./&+()" index="i">
					<cfif listfindnocase(x,i)>
						<cfset bl_reason='URL contains #i#'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
				</cfloop>
			</cfif>

			<cfif isdefined("inp.sql")>
				<cfif inp.sql contains "@@version">
					<cfset bl_reason='SQL contains @@version'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif isdefined("inp.detail")>
					<cfif inp.detail is "ORA-00933: SQL command not properly ended" and  inp.sql contains 'href="http://'>
					<cfset bl_reason='SQL contains href=...'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
					<cfif inp.detail is "ORA-00907: missing right parenthesis" and  inp.sql contains '1%'>
						<cfset bl_reason='SQL contains 1%'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
					<cfif (inp.detail contains "ORA-00936" or inp.detail contains "ORA-00907") and  inp.sql contains "'A=0">
						<cfset bl_reason='SQL contains A=0'>
						<cfinclude template="/errors/autoblacklist.cfm">
						<cfabort>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdefined("inp.Detail")>
				<cfif inp.Detail contains "missing right parenthesis" and request.rdurl contains "ctxsys">
						<cfset bl_reason='detail contains ctxsys'>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
				<cfif inp.Detail contains "network access denied by access control list">
						<cfset bl_reason='detail contains network access '>
					<cfinclude template="/errors/autoblacklist.cfm">
					<cfabort>
				</cfif>
			</cfif>
			<!--- 403s from Yandex are some crazy Russian phishing thing --->
			<cfif isdefined("cgi.HTTP_REFERER") and cgi.HTTP_REFERER contains "//yandex.ru/">
				<cfset bl_reason='HTTP_REFERER contains //yandex.ru/'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
		</cfif>
	</cfif>

	<cfreturn 'done'>
	<!----- END: stuff in this block is only checked if there's an error; this is called at onError ------>
</cffunction>
<!--------------------------------->
	<cffunction name="QueryToCSV2" access="public" returntype="string" output="false" hint="I take a query and convert it to a comma separated value string.">
		<cfargument name="Query" type="query" required="true" hint="I am the query being converted to CSV."/>
		<cfargument name="Fields" type="string" required="true" hint="I am the list of query fields to be used when creating the CSV value."/>
	 	<cfargument name="CreateHeaderRow" type="boolean" required="false" default="true" hint="I flag whether or not to create a row of header values."/>
	 	<cfargument name="Delimiter" type="string" required="false" default="," hint="I am the field delimiter in the CSV value."/>
		<cfset var LOCAL = {} />
		<cfset LOCAL.ColumnNames = [] />
		<cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">
			<cfset ArrayAppend(LOCAL.ColumnNames,Trim( LOCAL.ColumnName )) />
	 	</cfloop>
		<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />
		<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />
		<cfset LOCAL.Rows = [] />
		<cfif ARGUMENTS.CreateHeaderRow>
			<cfset LOCAL.RowData = [] />
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
				<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />
	 		</cfloop>
	 		<cfset ArrayAppend(LOCAL.Rows,ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )) />
	 	</cfif>
		<cfloop query="ARGUMENTS.Query">
			<cfset LOCAL.RowData = [] />
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
	 			<cfset LOCAL.querydata = ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ] >
	 			<cfif isdate(LOCAL.querydata) and len(LOCAL.querydata) eq 21>
					<cfset LOCAL.querydata = dateformat(local.querydata,"yyyy-mm-dd")>
				</cfif>
	 			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( local.querydata, """", """""", "all" )#""" />
	 		</cfloop>
			<cfset ArrayAppend(LOCAL.Rows,ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )) />
	 	</cfloop>
		<cfreturn ArrayToList(LOCAL.Rows,LOCAL.NewLine) />
	</cffunction>
	<!---------------------------------------------------------------------------------------------->
	<cffunction name="CSVToQuery" access="public" returntype="query" output="false" hint="Converts the given CSV string to a query.">
		<!--- from http://www.bennadel.com/blog/501-parsing-csv-values-in-to-a-coldfusion-query.htm ---->
		<cfargument name="CSV" type="string" required="true" hint="This is the CSV string that will be manipulated."/>
 		<cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value."/>
 		<cfargument name="Qualifier" type="string" required="false" default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded."/>
 		<cfargument name="FirstRowIsHeadings" type="boolean" required="false" default="true" hint="Set to false if the heading row is absent"/>
		<cfset var LOCAL = StructNew() />
		<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
 		<cfif Len( ARGUMENTS.Qualifier )>
 			<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
		</cfif>
 		<cfset LOCAL.LineDelimiter = Chr( 10 ) />
 		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(chr(13),LOCAL.LineDelimiter) />
		<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray()/>
 		<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />
		<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />
		<cfset LOCAL.Rows = ArrayNew( 1 ) />
		<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
		<cfset LOCAL.RowIndex = 1 />
		<cfset LOCAL.IsInValue = false />
		<cfloop index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
			<cfset LOCAL.FieldIndex = ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]) />
			<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst("^.{1}","") />
			<cfif Len( ARGUMENTS.Qualifier )>
				<cfif LOCAL.IsInValue>
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}") />
					<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] & LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token) />
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
						<cfset LOCAL.IsInValue = false />
					</cfif>
				<cfelse>
					<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst("^.{1}","") />
						<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}") />
						<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token.ReplaceFirst(".{1}$","")) />
						<cfelse>
							<cfset LOCAL.IsInValue = true />
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
						</cfif>
					<cfelse>
						<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
					</cfif>
				</cfif>
				<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],"{QUALIFIER}",ARGUMENTS.Qualifier,"ALL") />
			<cfelse>
				<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
			</cfif>
			<cfif ((NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND (LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter))>
				<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
				<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
			</cfif>
		</cfloop>
		<cfset LOCAL.MaxFieldCount = 0 />
		<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
		<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
			<cfset LOCAL.MaxFieldCount = Max(LOCAL.MaxFieldCount,ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ])) />
			<cfset ArrayAppend(LOCAL.EmptyArray,"") />
		</cfloop>
		<cfset LOCAL.Query = QueryNew( "" ) />
		<cfloop index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
		<cfset QueryAddColumn(LOCAL.Query,"COLUMN_#LOCAL.FieldIndex#","CF_SQL_VARCHAR",LOCAL.EmptyArray) />
	</cfloop>
	<cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
		<cfloop index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
			<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast("string",LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]) />
		</cfloop>
	</cfloop>
<cfif FirstRowIsHeadings>
	<cfloop query="LOCAL.Query" startrow="1" endrow="1" >
		<cfloop list="#LOCAL.Query.columnlist#" index="col_name">
			<cfset field = evaluate("LOCAL.Query.#col_name#")>
			<cfset field = replace(field,"-","","ALL")>
			<cfset QueryChangeColumnName(LOCAL.Query,"#col_name#","#field#") >
		</cfloop>
	</cfloop>
	<cfset LOCAL.Query.RemoveRows( JavaCast( "int", 0 ), JavaCast( "int", 1 ) ) />
</cfif>


<cfreturn LOCAL.Query />
</cffunction>
<!----------------------------------------------------------------------------->
	<cffunction name="QueryChangeColumnName" access="public" output="false" returntype="query" hint="Changes the column name of the given query.">
		<cfargument name="Query" type="query" required="true"/>
		<cfargument name="ColumnName" type="string" required="true"/>
		<cfargument name="NewColumnName" type="string" required="true"/>
		<cfscript>
	 		var LOCAL = StructNew();
	 		LOCAL.Columns = ARGUMENTS.Query.GetColumnNames();
	 		LOCAL.ColumnList = ArrayToList(LOCAL.Columns);
	 		LOCAL.ColumnIndex = ListFindNoCase(LOCAL.ColumnList,ARGUMENTS.ColumnName);
	 		if (LOCAL.ColumnIndex){
	 			LOCAL.Columns = ListToArray(LOCAL.ColumnList);
				LOCAL.Columns[ LOCAL.ColumnIndex ] = ARGUMENTS.NewColumnName;
	 			ARGUMENTS.Query.SetColumnNames(LOCAL.Columns);
			}
	 		return( ARGUMENTS.Query );
		</cfscript>
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="stripQuotes" access="public" output="false">
		<cfargument name="inStr" type="string">
		<cfset inStr = replace(inStr,"#chr(34)#","&quot;","all")>
		<cfset inStr = replace(inStr,"#chr(39)#","&##39;","all")>
		<cfset inStr = trim(inStr)>
		<cfreturn inStr>
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="getFlatSQL" access="public" returnformat="plain">
		<!----
			for "normal" stuff that's matching a colulm in FLAT, just call this with eg

					<cfset temp=getFlatSql(fld="island_group", val=island_group)>

			instead of writing SQL
		---->
		<cfparam name="fld" type="string" default="">
		<cfparam name="val" type="string" default="">
		<cfif compare(val,"NULL") is 0>
			<cfset basQual = " #basQual# AND #session.flatTableName#.#fld# is null">
		<cfelseif len(val) gt 1 and left(val,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.#fld#) = '#UCASE(escapeQuotes(right(val,len(val)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.#fld#) LIKE '%#UCASE(escapeQuotes(val))#%'">
		</cfif>
		<cfset mapurl = "#mapurl#&#fld#=#URLEncodedFormat(val)#">
	</cffunction>
	<!----------------------------------------------------------------------------->
	<cffunction name="getChronMaker" access="remote" returnformat="plain">
		<cfparam name="exp" type="string" default="">
		<cfhttp url="http://www.cronmaker.com/rest/sampler?expression=#exp#&count=10">
		</cfhttp>
		<cfreturn cfhttp.filecontent>
	</cffunction>



	<!--------- deprecated




<!----------------------->



--------------->
</cfcomponent>