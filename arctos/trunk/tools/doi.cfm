<cfoutput>
	<cfif isdefined("media_id") and len(media_id) gt 0>
		<!--- get the basic stuff ---->
		<cfquery name="media" datasource="uam_god">
			select
				media.MEDIA_URI,
				media.MEDIA_TYPE
			from
				media
			where
				media_id=#media_id#
		</cfquery>
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
		<hr>pyear.publisheddateraw: #pyear.publisheddateraw#
		<cfif isdate(pyear.publisheddateraw)>
			<br>isdate
			<cfset madedate=dateformat(pyear.publisheddateraw,"yyyy")>
		</cfif>
		<cfif len(pyear.publisheddateraw) is 0>
			is null
			<cfset madedate=dateformat(now(),"yyyy")>
		</cfif>






<!----------

		associated with project
describes taxonomy
derived from media
shows agent
created by agent
documents accn
documents loan
shows cataloged_item
shows publication

created from collecting_event


		,
				media_labels.MEDIA_LABEL,
				media_labels.LABEL_VALUE,
				createdbyagent.agent_name createdby
			,
				media_labels,
				media_relations,
				preferred_agent_name createdbyagent
			where
				media.media_id=media_labels.media_id and
				media.media_id=media_relations.media_id and
				media_relations.RELATED_PRIMARY_KEY=createdbyagent.agent_id and


 creator=preferred agent name from media_relationship ""
uam@ARCTOSPROD> desc media
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_URI							   NOT NULL VARCHAR2(255)
 MIME_TYPE							   NOT NULL VARCHAR2(255)
 MEDIA_TYPE							   NOT NULL VARCHAR2(255)
 PREVIEW_URI								    VARCHAR2(255)
 MEDIA_LICENSE_ID							    NUMBER

uam@ARCTOSPROD> desc media_labels
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 MEDIA_LABEL_ID 						   NOT NULL NUMBER
 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_LABEL							   NOT NULL VARCHAR2(255)
 LABEL_VALUE							   NOT NULL VARCHAR2(4000)
 ASSIGNED_BY_AGENT_ID						   NOT NULL NUMBER

uam@ARCTOSPROD> desc media_relations
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 MEDIA_RELATIONS_ID						   NOT NULL NUMBER
 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_RELATIONSHIP						   NOT NULL VARCHAR2(40)
 CREATED_BY_AGENT_ID						   NOT NULL NUMBER
 RELATED_PRIMARY_KEY						   NOT NULL NUMBER


----------->
	</cfif>


<!--------------
<cfset x="datacite.creator: Arctos">
<cfset x=x & chr(10) & "datacite.title: this is a title">
<cfset x=x & chr(10) & "datacite.publisher: this is hte publisher">
<cfset x=x & chr(10) & "datacite.publicationyear: 1846">
<cfset x=x & chr(10) & "datacite.resourcetype: Image">



		<cfhttp username="apitest" password="apitest" method="POST" url="https://n2t.net/ezid/shoulder/doi:10.5072/FK2">
			<cfhttpparam type = "header" name = "Accept" value = "text/plain">
			<cfhttpparam type = "header" name = "Content-Type" value = "text/plain; charset=UTF-8">

			<cfhttpparam type = "body" value = "#x#">



			<cfhttpparam type = "header" name = "_target" value = "http://arctos-test.tacc.utexas.edu/media/10219911">
		</cfhttp>


	<cfif cfhttp.Statuscode is "201 CREATED">


		<cfset newDOI=replace(cfhttp.filecontent,'success:','')>


		<br>	newDOI: #newDOI#

		<cfset newDOI=listgetat(newDOI,1,"|")>

			<br>	newDOI: #newDOI#

			<cfset newDOI=replace(newDOI,'doi:','')>
			<br>	newDOI: #newDOI#

	<cfelse>
		error: <cfdump var=#cfhttp#>
	</cfif>

<cfdump var=#cfhttp#>
----------->
	</cfoutput>

