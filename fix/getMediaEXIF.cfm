
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
	<cfimage source="#media_uri#" name="myImage">
	<cfset data =ImageGetEXIFMetadata(myImage)>
	<cfdump var="#data#">
	<cfset idate = #data["Date/Time"]# />

	<cfset idate=dateformat(idate,"yyyy-mm-dd")>
	<br>idate: #idate#
</cfloop>




</cfoutput>
