<cfinclude template="/includes/_header.cfm">
<!--- setup

drop table temp_gmapsrch;

create table temp_gmapsrch as select
	scientific_name,
	round(dec_lat,2) || ',' || round(dec_long,2) c
from 
	flat 
where
	dec_lat is not null and dec_long is not null
group by
	scientific_name,round(dec_lat,2) || ',' || round(dec_long,2)
;


create index ix_temp_gmapsrch_sn on temp_gmapsrch(scientific_name) tablespace uam_idx_1;
create index ix_temp_gmapsrch_c on temp_gmapsrch(c) tablespace uam_idx_1;


drop table gmap_srch;

create table gmap_srch (
	coordinates varchar2(255),
	taxa varchar2(4000),
	link varchar2(4000)
);



delete from gmap_srch;


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
				ctax := substr(ctax,1,3997) || '...';
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

--- use table2csv to download gmap_srch

--- upload to fusiontables as arctos.database

-- make sure it's public

-- make sure tableID is used in JS below

-- woot!




---->


<style type="text/css">
	#map-canvas { width:90%; }
</style>

<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		google_client_id,
		google_private_key
	from cf_global_settings
</cfquery>
<cfoutput>
	<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false" type="text/javascript"></script>'>
</cfoutput>
<script language="javascript" type="text/javascript">

var tableID='1eI0xLA9tXOVC53QnRxc6L32G72SFtqFVJT4COos';

function initialize() {
  var chicago = new google.maps.LatLng(64.8333333333,-147.7166666667);
  var mapOptions = {
    zoom: 3,
    center: chicago,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
layer = new google.maps.FusionTablesLayer({
  query: {
    select: 'COORDINATES',
    from: tableID
  }
});
layer.setMap(map);
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
$("#tname").select();
}

</script>
<div id="map-canvas">i am a map</div>
<label for="tname">Filter by taxon name</label>		
<input type="text" id="tname" onchange="resetLayer(this.value)">
<input type="button" value="filter" onclick="resetLayer($('#tname').val());">

<hr>

<h2>What's all this then?</h2>
<p>
	This is an extremely limited spatial browse tool. Points (error and datum transformation are ignored) 
	on the map are represented by coordinates rounded to hundredth of a degree and a sometimes-incomplete
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