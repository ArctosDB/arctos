
<cfinclude template="/includes/_header.cfm">

<cfoutput>
<!----
create table temp_uam_eh_img as select
  media.media_id,
  media_uri,
  ' ' exif_date
from
  media,
  media_relations,
  cataloged_item,
  collection
where
  media.media_id=media_relations.media_id and
  media_relations.related_primary_key=cataloged_item.collection_object_id and
  cataloged_item.collection_id=collection.collection_id and
  media_relations.media_relationship='shows cataloged_item' and
  collection.guid_prefix='UAM:EH' and
  media.media_id not in (select media_id from media_labels where MEDIA_LABEL='made date')
;
---->

<cfquery name="d" datasource="prod">
	select * from temp_uam_eh_img where exif_date is null and rownum<10
</cfquery>

<cfloop query="d">
	<br>media_uri: #media_uri#
	<cftry>
	<cfimage source="#media_uri#" name="myImage">
	<cfset data =ImageGetEXIFMetadata(myImage)>
	<cfset idate = #data["Date/Time"]# />

	<cfset idate=listgetat(idate,1," ")>
	<cfset idate=replace(idate,":","-","all")>
	<br>idate: #idate#

	<cfcatch>
		<cfdump var=#cfcatch#>
		<cfset idate='exif-not-accessible'>
	</cfcatch>
	</cftry>

	<cfquery name="r" datasource="prod">
		update temp_uam_eh_img set exif_date='#idate#' where media_uri='#media_uri#'
	</cfquery>
</cfloop>




</cfoutput>
