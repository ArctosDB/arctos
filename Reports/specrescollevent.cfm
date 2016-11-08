<cfinclude template="/includes/_header.cfm">
<cfset title="download collecting event">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		geog_auth_rec.HIGHER_GEOG,
		locality.SPEC_LOCALITY,
		locality.DEC_LAT,
		locality.DEC_LONG,
		collecting_event.BEGAN_DATE,
		collecting_event.ENDED_DATE,
		specimen_event.COLLECTING_METHOD,
		locality.locality_name locality_nickname
	from
		#session.SpecSrchTab#,
		specimen_event,
		collecting_event,
		locality,
		geog_auth_rec
	where
		#session.SpecSrchTab#.collection_object_id = specimen_event.collection_object_id and
		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		collecting_event.locality_id=locality.locality_id and
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id
	group by
		geog_auth_rec.HIGHER_GEOG,
		locality.SPEC_LOCALITY,
		locality.DEC_LAT,
		locality.DEC_LONG,
		collecting_event.BEGAN_DATE,
		collecting_event.ENDED_DATE,
		specimen_event.COLLECTING_METHOD,
		locality.locality_name
	order by
		geog_auth_rec.HIGHER_GEOG,
		locality.SPEC_LOCALITY,
		locality.DEC_LAT,
		locality.DEC_LONG,
		collecting_event.BEGAN_DATE,
		collecting_event.ENDED_DATE,
		specimen_event.COLLECTING_METHOD
</cfquery>


<cfset fname = "collecting_event.csv">

<cfset  util = CreateObject("component","component.utilities")>
<cfset csv = util.QueryToCSV2(Query=d,Fields=d.columnlist)>
<cffile action = "write"
    file = "#Application.webDirectory#/download/#fname#"
   	output = "#csv#"
   	addNewLine = "no">
<cflocation url="/download.cfm?file=#fname#" addtoken="false">

