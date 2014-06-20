<cfinclude template="/includes/_header.cfm">
<cfset title="Spatially browse all Arctos records">
<!--- setup

drop table temp_gmapsrch;

create table temp_gmapsrch as select
	scientific_name,
	round(dec_lat,1) || ',' || round(dec_long,1) c
from 
	filtered_flat 
where
	dec_lat is not null and dec_long is not null
group by
	scientific_name,round(dec_lat,1) || ',' || round(dec_long,1)
;


create index ix_temp_gmapsrch_sn on temp_gmapsrch(scientific_name) tablespace uam_idx_1;
create index ix_temp_gmapsrch_c on temp_gmapsrch(c) tablespace uam_idx_1;

drop table gmap_srch;

create table gmap_srch (
	coordinates varchar2(255),
	taxa varchar2(4000),
	link varchar2(4000)
);


OR

truncate table gmap_srch;



declare
	sep varchar2(10);
	ctax varchar2(4000);
begin
	for r in (select c from temp_gmapsrch group by c) loop
		sep := '';
		ctax := '';
		for t in (select scientific_name from temp_gmapsrch where c = r.c group by scientific_name order by scientific_name) loop
			if length(ctax || sep || t.scientific_name) < 4000 then
				ctax := ctax || sep || t.scientific_name;
				sep := '; ';
			else
				ctax := substr(ctax,1,3990) || '...';
			end if;
		end loop;
		insert into gmap_srch (
			coordinates,
			taxa,
			link
		) values (
			r.c,
			ctax,
			'<a href="http://arctos.database.museum/SpecimenResults.cfm?rcoords=' || r.c || '" target="_blank">[ open specimen records ]</a>');
	end loop;
end;
/


-- check count - if over limitations, rebuild something

select count(*) from gmap_srch;

commit;


--- use table2csv to download gmap_srch

--- upload to fusiontables as arctos.database

-- make sure it's public

-- make sure tableID is used in JS below

-- cleanup

drop table temp_gmapsrch;
drop table gmap_srch;
drop index ix_temp_gmapsrch_sn;
drop index ix_temp_gmapsrch_c;

-- woot!




---->


<style type="text/css">
	html {height:100%}
	body {height:100%}
	#map-canvas { width:100%; height:80%; }
</style>

<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		google_client_id,
		google_private_key
	from cf_global_settings
</cfquery>
<cfoutput>
	<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false&libraries=places" type="text/javascript"></script>'>
</cfoutput>
<script language="javascript" type="text/javascript">
	var tableID='1DF_kVyrwkqJ2YU07FKAHFQCIDbM7xeTNLPdju8ih';

	function initialize() {
		var chicago = new google.maps.LatLng(64.8333333333,-147.7166666667);
		var mapOptions = {
			zoom: 3,
		    center: new google.maps.LatLng(55, -135),
		    mapTypeId: google.maps.MapTypeId.ROADMAP,
		    panControl: true,
		    scaleControl: true
		};
		var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
		layer = new google.maps.FusionTablesLayer({
			query: {
	    		select: 'COORDINATES',
	  			from: tableID
	  		}
		});
		layer.setMap(map);
		var input =  document.getElementById('gmapsrchtarget');
		var searchBox = new google.maps.places.SearchBox(input);
		var markers = [];
		google.maps.event.addListener(searchBox, 'places_changed', function() {
	    	var places = searchBox.getPlaces();
		
		    for (var i = 0, marker; marker = markers[i]; i++) {
		      marker.setMap(null);
		    }
	
		    markers = [];
	    	var bounds = new google.maps.LatLngBounds();
			for (var i = 0, place; place = places[i]; i++) {
				var image = {
					url: place.icon,
					size: new google.maps.Size(71, 71),
					origin: new google.maps.Point(0, 0),
					anchor: new google.maps.Point(17, 34),
					scaledSize: new google.maps.Size(25, 25)
				};
				var marker = new google.maps.Marker({
		        	map: map,
		        	icon: image,
		        	title: place.name,
		        	position: place.geometry.location
				});
				markers.push(marker);
				bounds.extend(place.geometry.location);
			}
			map.fitBounds(bounds);
		});
		google.maps.event.addListener(map, 'bounds_changed', function() {
		  var bounds = map.getBounds();
		  searchBox.setBounds(bounds);
		});
	}
	google.maps.event.addDomListener(window, 'load', initialize);
	function resetLayer (value) {
  		value = value.replace("'", "\\'");
		layer.setOptions({
			query: {
				select: "COORDINATES",
				from: tableID,
				where: "'TAXA' CONTAINS IGNORING CASE '" + value + "'"
			}
		});
		//$("#tname").select();
	}
</script>
<cfif application.serverrooturl is not 'http://arctos.database.museum'>
	<div style="border:3px solid red;margin:2em;padding:2em;text-align:center;">
		These data originate from and links return to <a href="http://arctos.database.museum">http://arctos.database.museum</a>.
	</div>
</cfif>
<table>
	<tr>
		<td>
			<label for="tname">Filter by taxon name</label>		
			<input type="text" id="tname" size="30"  onkeyup="resetLayer(this.value)">
		</td>
		<td>
			<label for="gmapsrchtarget">Search Map</label>
			<input type="text" id="gmapsrchtarget">
		</td>
		<td>
			<a href="#about">[ about ]</a>
		</td>
	</tr>
</table>
<div id="map-canvas">i am a map</div>
<a name="about"></a>
<h2>What's all this then?</h2>
<p>
	This is an extremely limited spatial browse tool. Points (error and datum transformation are ignored) 
	on the map are represented by coordinates rounded to tenth of a degree and a sometimes-incomplete
	concatenation of associated taxa. Data are updated manually - which means infrequently and unpredictably.
</p>
<p>
	These limitations have two causes:
	
<ul>
	<li>FusionTables is the only obvious way to push large datasets to Google Maps, but only the "first" 100,000 rows are used.</li>
	<li>We have no idea if anyone will use this thing. <a href="/contact.cfm">Drop us a line</a> and tell us what could be better if you find it useful.</li>
</ul>
</p>
<cfinclude template="/includes/_footer.cfm">