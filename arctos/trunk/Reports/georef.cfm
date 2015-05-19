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
	specimens_with_georeference number,
	georeferences_with_error number,
	georeferences_with_elevation number,
	calc_error_lt_1 number,
	calc_error_lt_10 number,
	calc_error_gt_10 number,
	calc_elev_fits number);



declare
	ns number;
	ng number;
	gwe number;
	swg number;
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


		select sum(numUsingSpecimens) into swg from colln_coords where dec_lat is not null and guid_prefix=r.guid_prefix;



		insert into colln_coords_summary (
			guid_prefix,
			number_of_specimens,
			number_of_georeferences,
			specimens_with_georeference,
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
			swg,
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


<cfset tke=queryNew("ord,col,hdr,expn")>
<cfset thisRow=1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "guid_prefix", thisRow)>
<cfset QuerySetCell(tke, "hdr", "Collection", thisRow)>
<cfset QuerySetCell(tke, "expn", "Collection", thisRow)>
<cfset thisRow=thisRow+1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "number_of_specimens", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##Specimen", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of specimens held by the collection.", thisRow)>
<cfset thisRow=thisRow+1>


<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "number_of_georeferences", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##Georef", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences among the collection's specimens.", thisRow)>
<cfset thisRow=thisRow+1>



<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "georeferences_per_specimen", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##GeorefPerSpecimen", thisRow)>
<cfset QuerySetCell(tke, "expn", "##Georef/##Specimen. No indication of distribution is implied. (Rounded 2 places.)", thisRow)>
<cfset thisRow=thisRow+1>



<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "specimens_with_georeference", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##SpecimensWithGeoref", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of specimens with at least one georeference.", thisRow)>
<cfset thisRow=thisRow+1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_spec_geod", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%SpecGeorefd", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of specimens with at least one georeference.", thisRow)>
<cfset thisRow=thisRow+1>






<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "georeferences_with_error", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##GeorefWithErr", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences containing an assertion of error. 0 (zero) is considerered legacy data synonymous with NULL, not infinitely precise.", thisRow)>
<cfset thisRow=thisRow+1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_geo_w_err", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%GeorefWithErr", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences containing an assertion of error. 0 (zero) is considerered legacy data synonymous with NULL, not infinitely precise.", thisRow)>
<cfset thisRow=thisRow+1>




<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "georeferences_with_elevation", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##GeorefWithElev", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences including a curatorial assertion of elevation.", thisRow)>
<cfset thisRow=thisRow+1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_geo_w_elev", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%GeorefWithElev", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences containing an assertion of elevation.", thisRow)>
<cfset thisRow=thisRow+1>


<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "calc_error_lt_1", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##Err<1", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are within one kilometer of each other.", thisRow)>
<cfset thisRow=thisRow+1>

<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_err_lt_1", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%Err<1", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are within one kilometer of each other.", thisRow)>
<cfset thisRow=thisRow+1>


<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "calc_error_lt_10", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##Err<10", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are more than one and less than ten kilometers from each other.", thisRow)>
<cfset thisRow=thisRow+1>


<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_err_lt_10", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%Err<10", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are more than one and less than ten kilometers from each other.", thisRow)>
<cfset thisRow=thisRow+1>



<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "calc_error_gt_10", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##Err>10", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are more than ten kilometers from each other.", thisRow)>
<cfset thisRow=thisRow+1>



<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_err_gt_10", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%Err>10", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences in which the asserted point (not considering error) and the calculated point (from various webservice queries) are more than ten kilometers from each other.", thisRow)>
<cfset thisRow=thisRow+1>




<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "calc_elev_fits", thisRow)>
<cfset QuerySetCell(tke, "hdr", "##ElevWithin", thisRow)>
<cfset QuerySetCell(tke, "expn", "Number of georeferences in which the calculated elevation (from various webservice queries) falls within the user-specified elevation range.", thisRow)>
<cfset thisRow=thisRow+1>



<cfset queryAddRow(tke,1)>
<cfset QuerySetCell(tke, "ord", thisRow, thisRow)>
<cfset QuerySetCell(tke, "col", "pct_elev_fits", thisRow)>
<cfset QuerySetCell(tke, "hdr", "%ElevWithin", thisRow)>
<cfset QuerySetCell(tke, "expn", "Percentage of georeferences in which the calculated elevation (from various webservice queries) falls within the user-specified elevation range.", thisRow)>
<cfset thisRow=thisRow+1>





<cfquery name="meta" dbtype="query">
	select * from tke order by ord
</cfquery>



<table border>
	<tr>
		<th>Column</th>
		<th>Explanation</th>
	</tr>
	<cfloop query="meta">
		<tr>
			<td>#hdr#</td>
			<td>#expn#</td>
		</tr>
	</cfloop>
</table>


<cfquery name="cs" datasource="uam_god" >
	select
		guid_prefix,
		number_of_specimens,
		number_of_georeferences,
		round(number_of_georeferences/number_of_specimens,2) georeferences_per_specimen,
		specimens_with_georeference,
		decode(number_of_specimens,0,0,round(specimens_with_georeference/number_of_specimens,2)*100) pct_spec_geod,
		georeferences_with_error,
		decode(number_of_georeferences,0,0,round(georeferences_with_error/number_of_georeferences,2)*100) pct_geo_w_err,
		georeferences_with_elevation,
		decode(number_of_georeferences,0,0,round(georeferences_with_elevation/number_of_georeferences,2)*100) pct_geo_w_elev,
		calc_error_lt_1,
		decode(calc_error_lt_1,0,0,round(number_of_georeferences/calc_error_lt_1,2)*100) pct_err_lt_1,
		calc_error_lt_10,
		decode(calc_error_lt_10,0,0,round(number_of_georeferences/calc_error_lt_10,2)*100) pct_err_lt_10,
		calc_error_gt_10,
		decode(calc_error_gt_10,0,0,round(number_of_georeferences/calc_error_gt_10,2)*100) pct_err_gt_10,
		calc_elev_fits,
		decode(calc_elev_fits,0,0,round(number_of_georeferences/calc_elev_fits,2)*100) pct_elev_fits
	from
		colln_coords_summary
</cfquery>

<table border id="t" class="sortable">
	<tr>
		<cfloop query="meta">
			<th>#hdr#</th>
		</cfloop>
	</tr>
	<cfloop query="cs">
		<tr>
			<cfloop query="meta">
				<td>#evaluate("cs." & col)#</td>
			</cfloop>
		</tr>
	</cfloop>
</table>



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
