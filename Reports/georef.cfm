<!----

create table spec_coords as select
  guid,
  locality.dec_lat,
  locality.dec_long,
  locality.s$dec_lat,
  locality.s$dec_long,
  to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS) err_m,
  getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long) s_err_km,
  to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) min_elev_m,
  to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) max_elev_m,
  locality.s$elevation s_elev_m,
  geog_auth_rec.higher_geog,
  locality.S$GEOGRAPHY
from
  flat,
  specimen_event,
  collecting_event,
  locality,
  geog_auth_rec
where
  flat.collection_object_id=specimen_event.collection_object_id and
  specimen_event.collecting_event_id=collecting_event.collecting_event_id and
  collecting_event.locality_id=locality.locality_id and
  locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
  locality.dec_lat is not null;

-- nope...
drop table spec_coords


create table colln_coords as select
  count(*) numUsingSpecimens,
  guid_prefix,
  locality.dec_lat,
  locality.dec_long,
  locality.s$dec_lat,
  locality.s$dec_long,
  to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS) err_m,
  getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long) s_err_km,
  to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) min_elev_m,
  to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS) max_elev_m,
  locality.s$elevation s_elev_m,
  geog_auth_rec.higher_geog,
  locality.S$GEOGRAPHY
from
  cataloged_item,
  collection,
  specimen_event,
  collecting_event,
  locality,
  geog_auth_rec
where
  cataloged_item.collection_id=collection.collection_id and
  cataloged_item.collection_object_id=specimen_event.collection_object_id and
  specimen_event.collecting_event_id=collecting_event.collecting_event_id and
  collecting_event.locality_id=locality.locality_id and
  locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
  locality.dec_lat is not null
group by
  guid_prefix,
  locality.dec_lat,
  locality.dec_long,
  locality.s$dec_lat,
  locality.s$dec_long,
  to_meters(locality.MAX_ERROR_DISTANCE,locality.MAX_ERROR_UNITS),
  getHaversineDistance(locality.dec_lat,locality.dec_long,locality.s$dec_lat,locality.s$dec_long),
  to_meters(locality.MINIMUM_ELEVATION,locality.ORIG_ELEV_UNITS),
  to_meters(locality.MAXIMUM_ELEVATION,locality.ORIG_ELEV_UNITS),
  locality.s$elevation,
  geog_auth_rec.higher_geog,
  locality.S$GEOGRAPHY
;





---->


<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>


IMPORTANT JUNK
<ul>
<li>This is a cached report and overview. It's not necessarily current or correct. Contact a DBA for an update.</li>
<li>Understanding http://arctosdb.org/documentation/places/specimen-event/ is important. Any specimen may have any number of localities, any
of which may be georeferenced.</li>
<li>It is important to understand the history of a collection in context of Arctos before drawing conclusions from these data. In part:
	<ul>
		<li>Some collections have many "unaccepted" georeferences because an
			old Arctos model allowed only one "accepted" coordinate determination.</li>
		<li>Some collections have many georeferences because of curatorial practices and discipline-specific data. </li>
		<li>Some collections were imported from systems with limited capabilities.</li>
		<li>Some collections where digitized photographically</li>
		<li></li>
		<li></li>
		<li></li>
	</ul>
 </li>
<li>We employ Google's services to obtain independent spatial and descriptive data. GIGO applies.</li>
</ul>






<cfquery name="collns" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		guid_prefix,
		count(*) specimencount
	from
		collection,
		cataloged_item
	where
		collection.collection_id=cataloged_item.collection_id
	group by guid_prefix order by guid_prefix
</cfquery>
<cfoutput>
<table border id="t" class="sortable">
	<tr>
		<th>Colln</th>
		<th>##Spec</th>
		<th>##HasGeoref</th>
		<th>Georef/Specm</th>
	</tr>
	<cfloop query="#collns#">
		<cfquery name="thiscoln" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from colln_coords where guid_prefix='#guid_prefix#'
		</cfquery>

		<cfquery name="geoDet" dbtype="query">
			select sum(numUsingSpecimens) as numgeorefs from thiscoln
		</cfquery>
		<cfif len(geoDet.numgeorefs) is 0>
			<cfset ngr=0>
		<cfelse>
			<cfset ngr=geoDet.numgeorefs>
		</cfif>
		<cfset grps=ngr/specimencount>

		<tr>
			<td>#guid_prefix#</td>
			<td>#specimencount#</td>
			<td>#geoDet.numgeorefs#</td>
			<td>#grps#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
