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


create index ix_colln_coords_guid_prefix on colln_coords(guid_prefix) tablespace uam_idx_1;


drop table colln_coords_summary;


create table colln_coords_summary (
	guid_prefix varchar2(255),
	number_of_specimens number,
	number_of_georeferences number,
	georeferences_per_specimen number,
	georeferences_with_error number,
	georeferences_with_elevation number,
	calc_error_lt_1 number,
	calc_error_lt_10 number,
	calc_error_gt_10 number,
	calc_elev_fits number);



declare
	ns number;
	ng number;
	gps number;
	gwe number;
	gwv number;
	el1 number;
	el10 number;
	eg10 number;
	evg number;
begin

	delete from colln_coords_summary;

	for r in (select distinct guid_prefix from colln_coords) loop
		select count(*) into ns from collection,cataloged_item where collection.collection_id=cataloged_item.collection_id and
			collection.guid_prefix=r.guid_prefix;

		select count(*) into ng from colln_coords where dec_lat is not null and guid_prefix=r.guid_prefix;

		gps:=ng/ns;

		select count(*) into gwe from colln_coords where err_m is not null and guid_prefix=r.guid_prefix;

		select count(*) into gwv from colln_coords where min_elev_m is not null and guid_prefix=r.guid_prefix;

		select count(*) into el1 from colln_coords where
			getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)<1 and guid_prefix=r.guid_prefix;

		select count(*) into el10 from colln_coords where
			getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)>=1 and
			getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)<10 and guid_prefix=r.guid_prefix;

		select count(*) into eg10 from colln_coords where
			getHaversineDistance(dec_lat,dec_long,s$dec_lat,s$dec_long)>10 and guid_prefix=r.guid_prefix;

		select count(*) into evg from colln_coords where guid_prefix=r.guid_prefix and
			s_elev_m between min_elev_m and max_elev_m;





		insert into colln_coords_summary (
			guid_prefix,
			number_of_specimens,
			number_of_georeferences,
			georeferences_per_specimen,
			georeferences_with_error,
			georeferences_with_elevation,
			calc_error_lt_1,
			calc_error_lt_10,
			calc_error_gt_10,
			calc_elev_fits
		) values (
			r.guid_prefix,
			ns,
			ng,
			gps,
			gwe,
			gwv,
			el1,
			el10,
			eg10,
			evg
		);
	end loop;
end;
/



		<th>Colln</th>
		<th>##Spec</th>
		<th>##HasGeoref</th>
		<th>Georef/Specm</th>
		<th>##GeoreferencesWithoutError</th>
		<th>##GeoreferencesWithElevation</th>



---->


<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Arctos Georeference Summary">
<style>
th.rotate {
  /* Something you can count on */
  height: 140px;
  white-space: nowrap;
}

th.rotate > div {
  transform:
    /* Magic Numbers */
    translate(25px, 51px)
    /* 45 is really 360 - 45 */
    rotate(315deg);
  width: 30px;
}
th.rotate > div > span {
  border-bottom: 1px solid #ccc;
  padding: 5px 10px;
}
</style>

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
<cfoutput>
Column Keys
<table border>
	<tr>
		<th>Name</th>
		<th>Explanation</th>
	</tr>
	<tr>
		<td>Collection</td>
		<td>Collection</td>
	</tr>
	<tr>
		<td>##Specimen</td>
		<td>Number of specimens held by the collection</td>
	</tr>
	<tr>
		<td>##Georef</td>
		<td>Number of georeferences among the collection's specimens.</td>
	</tr>
	<tr>
		<td>##GeorefPerSpecimen</td>
		<td>##Georef/##Specimen. No indication of distribution is implied.</td>
	</tr>
	<tr>
		<td>##GeorefWithErr</td>
		<td>Number of georeferences containing an assertion of error. 0 (zero) is considerered legacy data synonymous with NULL, not
		"infinitely precise."</td>
	</tr>
	<tr>
		<td>##GeorefWithElev</td>
		<td>Number of georeferences including an assertion of elevation</td>
	</tr>
	<tr>
		<td>##Err<1</td>
		<td>Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries)
		are within one kilimeter of each other</td>
	</tr>
	<tr>
		<td>##Err<10</td>
		<td>Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries)
		are more than one and less than ten kilimeters from each other</td>
	</tr>
	<tr>
		<td>##Err>10</td>
		<td>Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries)
		are more than ten kilimeters from each other</td>
	</tr>
	<tr>
		<td>##ElevWithin</td>
		<td>Number of georeferences in which the calculated elevation (from various webservice queries) falls within the user-
		specified elevation range.</td>
	</tr>
	<tr>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td></td>
	</tr>
</table>
<ul>

</ul>


<cfquery name="cs" datasource="uam_god" >
	select * from colln_coords_summary
</cfquery>
<table border id="t" class="sortable">
	<tr>
		<th class="rotate">Collection</th>
		<th class="rotate">##Specimen</th>
		<th class="rotate">##Georef</th>
		<th class="rotate">##GeorefPerSpecimen</th>
		<th class="rotate">##GeorefWithErr</th>
		<th class="rotate">##GeorefWithElev</th>
		<th class="rotate">##GeorefWithElev</th>
		<th class="rotate">##Err<1</th>
		<th class="rotate">##Err<10</th>
		<th class="rotate">##Err>10</th>
		<th class="rotate">##ElevWithin</th>
	</tr>
	<cfloop query="cs">
		<tr>
			<td>#guid_prefix#</td>
			<td>#number_of_specimens#</td>
			<td>#number_of_georeferences#</td>
			<td>#georeferences_per_specimen#</td>
			<td>#georeferences_with_error#</td>
			<td>#georeferences_with_elevation#</td>
			<td>#calc_error_lt_1#</td>
			<td>#calc_error_lt_10#</td>
			<td>#calc_error_gt_10#</td>
			<td>#calc_elev_fits#</td>
		</tr>
	</cfloop>
</table>


<cfdump var=#cs#>

<!-----


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
		<th>##GeoreferencesWithoutError</th>
		<th>##GeoreferencesWithElevation</th>
	</tr>
	<cfloop query="#collns#">
		<cfquery name="thiscoln" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from colln_coords where guid_prefix='#guid_prefix#'
		</cfquery>



		<tr>
			<td>#guid_prefix#</td>
			<td>#specimencount#</td>
			<cfquery name="geoDet" dbtype="query">
				select sum(numUsingSpecimens) as numgeorefs from thiscoln
			</cfquery>
			<cfif len(geoDet.numgeorefs) is 0>
				<cfset ngr=0>
			<cfelse>
				<cfset ngr=geoDet.numgeorefs>
			</cfif>
			<cfset grps=ngr/specimencount>
			<td>#geoDet.numgeorefs#</td>
			<td>#grps#</td>
			<cfquery name="noerr" dbtype="query">
				select count(*) c from thiscoln where (err_m=0 or err_m is null)
			</cfquery>
			<td>#noerr.c#</td>
			<cfquery name="haselev" dbtype="query">
				select count(*) c from thiscoln where min_elev_m is not null
			</cfquery>
			<td>#haselev.c#</td>

		</tr>
	</cfloop>
</table>

----->
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
