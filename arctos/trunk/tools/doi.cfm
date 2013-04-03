<cfoutput>
	<cfset obj = CreateObject("component","component.functions")>
	<cfset thisMeta = obj.getDOIMeta(media_id=#media_id#)>



	<cfdump var=#thisMeta#>



<!----------

		<cfset x="datacite.creator: Arctos">
		<cfset x=x & chr(10) & "datacite.title: this is a title">
		<cfset x=x & chr(10) & "datacite.publisher: this is hte publisher">
		<cfset x=x & chr(10) & "datacite.publicationyear: 1846">
		<cfset x=x & chr(10) & "datacite.resourcetype: Image">

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

</cfif>

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

