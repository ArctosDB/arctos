<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		<p>
			This form will assign DOIs to individual items. Use the contact link in the footer if you need
			many DOIs.
		</p>
		<p>
			DOIs are stable identifiers, intended to "follow" the object to which they are attached (eg,
			specimen in a museum or an image-with-metadata entry). DOIs come with a maintenance cost:
			They must be updated if the assigned URI changes (eg, a specimen leaves Arctos) and DOI
			metadata should be updated when something significant about the object changes.
		</p>
		<p>
			All fields in the form below are required. We'll try to find appropriate values from the data,
			but initial values should be viewed as suggestions only.
		</p>
		<p>
			More about DOIs can be found at the <a href="http://www.doi.org/hb.html" class="external" target="_blank">DOI Handbook</a>
			or the <a href="http://ezid.cdlib.org/" class="external" target="_blank">EZID homepage.</a>
		</p>
		<p>
			All Arctos DOIs are (currently) provided by EZID, and metadata (including QR codes) may be viewed by appending the DOI onto
			<blockquote>http://ezid.cdlib.org/id/doi:</blockquote>
			to form URLs of the form
			<blockquote>
				<a href="http://ezid.cdlib.org/id/doi:10.7299/X7WS8R7J" class="external" target="_blank">http://ezid.cdlib.org/id/doi:10.7299/X7WS8R7J</a>
			</blockquote>
			DOI metadata is maintained at <a href="http://datacite.org/" class="external" target="_blank">DataCite</a>
		</p>
		<cfset publicationyear="">
		<cfset target="">
		<cfset resourcetype="">
		<cfset creator="">
		<cfset title="">
		<cfset publisher="">


		<!----
		<cfset ctinst=querynew("inst")>
		<cfset thisRow=1>
		<cfset queryaddrow(ctinst,1)>
		<cfset QuerySetCell(ctinst, "inst", "University of Alaska Museum",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Museum of Southwestern Biology",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Museum of Vertebrate Zoology",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "College of the Atlantic",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Denver Museum of Nature and Science",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Harold W. Manter Laboratory of Parasitology",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Kenai National Wildlife Refuge",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Western New Mexico University",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Kenelm W. Philip lepidoptera collection",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "University of Wyoming",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Occidental College",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "U. S. National Parasite Collection",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "Northern Michigan University",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "University of Washington",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "University of Utah",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "",thisRow)>
		<cfset queryaddrow(ctinst,1)>
		<cfset thisRow = thisRow + 1>
		<cfset QuerySetCell(ctinst, "inst", "",thisRow)>

			---->
		<cfquery name="octinst" datasource="uam_god">
			select institution inst from collection group by institution order by institution
		</cfquery>
		<cfif isdefined("archive_id") and len(archive_id) gt 0>
			<cfquery name="alreadyGotOne" datasource="uam_god">
				select doi from doi where archive_id=#archive_id#
			</cfquery>
			<cfif len(alreadyGotOne.doi) gt 0>
				That record already has a DOI
				<p>
					#alreadyGotOne.doi#
				</p>
				<cfabort>
			</cfif>
			<cfquery name="archive" datasource="uam_god">
				select
					archive_name,
					create_date,
					creator,
					is_locked,
					count(specimen_archive.guid) c
				from
					archive_name,
					specimen_archive
				where
					archive_name.archive_id=specimen_archive.archive_id (+) and
					archive_name.archive_id=#archive_id#
				group by
					archive_name,
					create_date,
					creator,
					is_locked
			</cfquery>
			<cfif archive.recordcount is 0>
				<div class="error">archive not found</div>
				<cfabort>
			</cfif>
			<cfif archive.is_locked is 0>
				<div class="error">Unlocked archives cannot have DOIs</div>
				<cfabort>
			</cfif>
			<cfquery name="d" datasource="uam_god">
				select
					collection.institution
				from
					flat,
					collection,
					specimen_archive
				where
					flat.collection_id=collection.collection_id and
					flat.guid = specimen_archive.guid and
					specimen_archive.archive_id=#archive_id#
				group by
					collection.institution
			</cfquery>


			<cfset target="#Application.serverRootUrl#/archive/#archive.archive_name#">
			<cfset columname="archive_id">
			<cfset pkeyval=archive_id>
			<cfset publicationyear=dateformat(archive.create_date,"yyyy")>
			<cfset resourcetype="Dataset">

			<cfquery name="createdby" datasource="uam_god">
				select
					preferred_agent_name
				from
					agent,
					agent_name
				where
					agent.agent_id=agent_name.agent_id and
					upper(agent_name.agent_name)='#ucase(archive.creator)#'
			</cfquery>
			<cfset creator=createdby.preferred_agent_name>
			<cfset title="Archived Dataset #archive.archive_name#">

		</cfif><!--- end Archive --->



		<cfif isdefined("media_id") and len(media_id) gt 0>
			<cfquery name="alreadyGotOne" datasource="uam_god">
				select doi from doi where media_id=#media_id#
			</cfquery>
			<cfif len(alreadyGotOne.doi) gt 0>
				That record already has a DOI
				<p>
					#alreadyGotOne.doi#
				</p>
				<cfabort>
			</cfif>
			<cfquery name="media" datasource="uam_god">
				select
					media.MEDIA_URI,
					media.MEDIA_TYPE
				from
					media
				where
					media_id=#media_id#
			</cfquery>
			<cfif media.recordcount is 0>
				<div class="error">media not found</div>
				<cfabort>
			</cfif>
			<!--- formula for URI to Media --->
			<cfset target="#Application.serverRootUrl#/media/#media_id#">
			<cfset columname="media_id">
			<cfset pkeyval=media_id>

			<cfquery name="createdby" datasource="uam_god">
				select
					agent_name
				from
					preferred_agent_name,
					media_relations
				where
					media_relations.MEDIA_RELATIONSHIP='created by agent' and
					media_relations.RELATED_PRIMARY_KEY=preferred_agent_name.agent_id and
					media_relations.media_id=#media_id#
			</cfquery>
			<cfquery name="description" datasource="uam_god">
				select
					LABEL_VALUE
				from
					media_labels
				where
					MEDIA_LABEL='description' and
					media_id=#media_id#
			</cfquery>
			<!--- try to get "published year" from collecting event ---->
			<cfquery name="pyear" datasource="uam_god">
				select
					began_date publisheddateraw
				from
					media_relations,
					collecting_event
				where
					media_relations.media_relationship='created from collecting_event' and
					media_relations.RELATED_PRIMARY_KEY=collecting_event.collecting_event_id and
					media_relations.media_id=#media_id#
			</cfquery>
			<cfif pyear.recordcount neq 1>
				<!--- no "published year" from collecting event available - try locality ---->
				<cfquery name="pyear" datasource="uam_god">
					select
						began_date publisheddateraw
					from
						media_relations,
						collecting_event,
						locality
					where
						media_relations.media_relationship='shows locality' and
						media_relations.RELATED_PRIMARY_KEY=locality.locality_id and
						locality.locality_id=collecting_event.collecting_event_id and
						media_relations.media_id=#media_id#
				</cfquery>
				<cfif pyear.recordcount neq 1>
					<!--- no "published year" from locality available - try label 'published year' ---->
					<cfquery name="pyear" datasource="uam_god">
						select
							LABEL_VALUE publisheddateraw
						from
							media_labels
						where
							MEDIA_LABEL='published year' and
							media_id=#media_id#
					</cfquery>
					<cfif pyear.recordcount neq 1>
						<!--- no "published year" from label 'published year' available - try label 'made date' ---->
						<cfquery name="pyear" datasource="uam_god">
							select
								LABEL_VALUE publisheddateraw
							from
								media_labels
							where
								MEDIA_LABEL='made date' and
								media_id=#media_id#
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<cfif isdate(pyear.publisheddateraw)>
				<cfset publicationyear=dateformat(pyear.publisheddateraw,"yyyy")>
			<cfelse>
				<!---- no dates anywhere - fall back to now ---->
				<cfset publicationyear=dateformat(now(),"yyyy")>
			</cfif>
			<cfif media.MEDIA_TYPE is 'image'>
				<cfset resourcetype='Image'>
			<cfelseif  media.MEDIA_TYPE is 'multi-page document'>
				<cfset resourcetype='Text'>
			<cfelseif  media.MEDIA_TYPE is 'text'>
				<cfset resourcetype='Text'>
			<cfelseif  media.MEDIA_TYPE is 'audio'>
				<cfset resourcetype='Sound'>
			<cfelseif  media.MEDIA_TYPE is 'video'>
				<cfset resourcetype='Film'>
			</cfif>
			<cfset creator=createdby.agent_name>
			<cfset title=description.LABEL_VALUE>
		</cfif><!--- end Media --->
		<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
			<cfquery name="alreadyGotOne" datasource="uam_god">
				select doi from doi where collection_object_id=#collection_object_id#
			</cfquery>
			<cfif len(alreadyGotOne.doi) gt 0>
				That record already has a DOI
				<p>
					#alreadyGotOne.doi#
				</p>
				<cfabort>
			</cfif>
			<cfquery name="d" datasource="uam_god">
				select
					flat.guid,
					flat.YEAR,
					collection.institution,
					flat.collectors,
					flat.CATALOGED_ITEM_TYPE,
					flat.scientific_name
				from
					flat,
					collection
				where
					flat.collection_id=collection.collection_id and
					collection_object_id=#collection_object_id#
			</cfquery>
			<cfif d.recordcount is not 1>
				<div class="error">Item not found</div><cfabort>
			</cfif>
			<cfset columname="collection_object_id">
			<cfset pkeyval=collection_object_id>
			<cfset target="#Application.serverRootUrl#/guid/#d.guid#">
			<cfset publicationyear=d.year>
			<cfif d.CATALOGED_ITEM_TYPE is "specimen">
				<cfset resourcetype="PhysicalObject">
			<cfelse>
				<cfset resourcetype="Event">
			</cfif>

			<cfset creator=listgetat(d.collectors,1)>
			<cfset title=d.guid & ' - ' & d.scientific_name>
		</cfif>
		<cfif not isdefined("columname")>
			<div class="error">Improper Call</div><cfabort>
		</cfif>
		<cfset rtl="Collection,Dataset,Event,Image,InteractiveResource,Model,PhysicalObject,Service,Software,Sound,Text">
		<form name="doi" method="post" action="doi.cfm">
			<input type="hidden" name="action" value="createDOI">
			<input type="hidden" name="columname" value="#columname#">
			<input type="hidden" name="pkeyval" value="#pkeyval#">

			<label for="target">target: the URL of the object in Arctos</label>
			<input type="text" name="target" id="target" value="#target#" size="80">
			<a href="#target#" target="_blank" class="infoLink">[ open in new window ]</a>
			<label for="publicationyear">publicationyear: 4-digit year in which the data was "published"</label>
			<input type="text" name="publicationyear" id="publicationyear" value="#publicationyear#">
			<label for="resourcetype">resourcetype</label>
			<select name="resourcetype" id="resourcetype" size="1">
				<cfloop list="#rtl#" index="i">
					<option value="#i#" <cfif resourcetype is i> selected="selected" </cfif> >#i#</option>
				</cfloop>
			</select>
			<label for="publisher">publisher</label>
			<select name="publisher" id="publisher" size="1">
				<cfloop query="octinst">
					<option value="#inst#" <cfif d.institution is octinst.inst> selected="selected" </cfif> >#inst#</option>
				</cfloop>
			</select>
			<label for="creator">creator <a href="http://ezid.cdlib.org/doc/apidoc.html##profile-datacite" target="_blank" class="external">[ more info ]</a></label>
			<input type="text" name="creator" id="creator" value="#creator#" size="80">
			<label for="title">title <a href="http://ezid.cdlib.org/doc/apidoc.html##profile-datacite" target="_blank" class="external">[ more info ]</a></label>
			<input type="text" name="title" id="title" value="#title#" size="80">
			<br>
			<input type="submit" value="create DOI">
		</form>
	</cfif>
	<cfif action is "createDOI">
		<cfif len(publicationyear) is 0>
			<div class="error">publicationyear is required</div>
			<cfabort>
		</cfif>
		<cfif len(resourcetype) is 0>
			<div class="error">resourcetype is required</div>
			<cfabort>
		</cfif>
		<cfif len(creator) is 0>
			<div class="error">creator is required</div>
			<cfabort>
		</cfif>
		<cfif len(title) is 0>
			<div class="error">title is required</div>
			<cfabort>
		</cfif>
		<!--- create DOI ---->
		<cfset x="datacite.creator: #creator#">
		<cfset x=x & chr(10) & "datacite.title: #title#">
		<cfset x=x & chr(10) & "datacite.publisher: #publisher#">
		<cfset x=x & chr(10) & "datacite.publicationyear: #publicationyear#">
		<cfset x=x & chr(10) & "datacite.resourcetype: #resourcetype#">
		<cfset x=x & chr(10) & "_target: #target#">
		<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				ezid_username,
				ezid_password,
				ezid_shoulder
			from cf_global_settings
		</cfquery>
		<cfhttp
			username="#cf_global_settings.ezid_username#"
			password="#cf_global_settings.ezid_password#"
			method="POST"
			url="https://ezid.cdlib.org/shoulder/doi:#cf_global_settings.ezid_shoulder#">
			<cfhttpparam type="header" name="Accept" value="text/plain">
			<cfhttpparam type="header" name="Content-Type" value="text/plain; charset=UTF-8">
			<cfhttpparam type="body" value="#x#">
		</cfhttp>
		<cfif cfhttp.Statuscode is "201 CREATED">
			<cfset newDOI=replace(cfhttp.filecontent,'success:','')>
			<cfset newDOI=listgetat(newDOI,1,"|")>
			<cfset newDOI=trim(replace(newDOI,'doi:',''))>
			<cfquery name="saveit" datasource="uam_god">
				insert into doi (#columname#,doi) values (#pkeyval#,'#newDOI#')
			</cfquery>
			You've created a DOI!
			<p>Arctos URL: #target#</p>
			<p>DOI: #newDOI#</p>
			<p>DOI resolver (will take a few minutes to work): <a href="http://dx.doi.org/#newDOI#">http://dx.doi.org/#newDOI#</a></p>
		<cfelse>
			DOI creation failed.
			<cfdump var=#cfhttp#>
		</cfif>
	</cfif>

	<!--------------
	<cfquery name="tehMedia" datasource="uam_god">
		select
			media.media_id
		from
			media,
			media_labels
		where
			media.media_id=media_labels.media_id and
			MEDIA_LABEL='image number' and
			media.media_id not in (select media_id from doi) and
			rownum<2
		group by
			media.media_id
	</cfquery>
	<cfloop query="tehMedia">
		<cfset obj = CreateObject("component","component.functions")>
		<cfset thisMeta = obj.getDOI(media_id=#tehMedia.media_id#,publisher="Museum of Vertabrate Zoology")>
		<cfset status=listgetat(thisMeta,1,"|")>
		<cfif status is "success">
			<cfset doi=listgetat(thisMeta,2,"|")>
			<cfquery name="saveit" datasource="uam_god">
				insert into doi (media_id,doi) values (#tehMedia.media_id#,'#doi#')
			</cfquery>
			<br>did this:
			<br>insert into doi (media_id,doi) values (#tehMedia.media_id#,'#doi#')
		<cfelse>
			soemthing broke:
			<cfdump var=#thisMeta#>
		</cfif>
	</cfloop>


	------------>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
