Retrieving map data - please wait....
<cfflush>

	<!---- map a lat_long_id ---->
	<cfif not isdefined("locality_id") or len(#locality_id#) is 0>
		You can't map a point without a locality_id.
		<cfabort>
	</cfif>
	<cfoutput>
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			locality.locality_id locality_id,
			lat_long_id,
			decode(accepted_lat_long_fg,
				1,'yes',
				0,'no') isAcceptedLatLong,
			spec_locality,
			dec_lat,
			dec_long,
			to_meters(max_error_distance,max_error_units) max_error_meters,
			datum
		FROM lat_long,locality
		WHERE
			locality.locality_id = lat_long.locality_id AND
			locality.locality_id IN (#locality_id#)
	</cfquery>
	</cfoutput>

<cfset dlPath = "#Application.webDirectory#/bnhmMaps/tabfiles/">
<cfset dlFile = "tabfile#cfid##cftoken#.txt">
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="" nameconflict="overwrite">
<cfoutput query="getMapData">
	<cfset relInfo='<a href="#Application.ServerRootUrl#/editLocality.cfm?locality_id=#locality_id#" target="_blank">#spec_locality#</a>'>
	<cfset oneLine="#relInfo##chr(9)##locality_id##chr(9)##lat_long_id##chr(9)##spec_locality##chr(9)##dec_lat##chr(9)##dec_long##chr(9)##max_error_meters##chr(9)##datum##chr(9)##isAcceptedLatLong#">
		
		
	<cfset oneLine=trim(oneLine)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
</cfoutput>
<cfoutput>


	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/index.php?ViewResults=tab&tabfile=#Application.ServerRootUrl#/bnhmMaps/tabfiles/#dlFile#&configfile=#Application.ServerRootUrl#/bnhmMaps/PointMap.xml&sourcename=Locality">
	

	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>