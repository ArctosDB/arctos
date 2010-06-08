<cfabort>
<cfoutput >
<cfquery name="d" datasource="uam_god">
	select * from bfu where status is null
</cfquery>

<cfloop query="d">
	<cftransaction>
	<cfset locid=''>
	<hr>
	catnum: #cn#
	<cfquery name="g" datasource="uam_god">
		select geog_auth_rec_id from geog_auth_rec where higher_geog='#hg#'
	</cfquery>
	<cfif g.recordcount is 1>
		<br>one geo
		<cfif len(LAD) gt 0>
			<br>hasloc coords?
			<cfquery name="l" datasource="uam_god">
				select 
					min(locality.locality_id)  locality_id
				from
					locality,
					lat_long
				where
					locality.locality_id=lat_long.locality_id and
					locality.geog_auth_rec_id=#g.geog_auth_rec_id# and
					spec_locality='#sl#' and
					orig_lat_long_units='deg. min. sec.' and
					LAT_DEG=#lad# and
					LAT_MIN=#lam# and
					LAT_SEC=#las# and
					LAT_DIR='#lar#' and
					LONG_DEG=#lod# and
					LONG_MIN=#lom# and
					LONG_SEC=#los# and
					LONG_DIR='#lor#'
			</cfquery>
		<cfelse>
			<br>hasloc nocoords?
			<cfquery name="l" datasource="uam_god">
				select 
					min(locality_id)  locality_id
				from
					locality					
				where
					locality.locality_id not in (select locality_id from lat_long) and
					locality.geog_auth_rec_id=#g.geog_auth_rec_id# and
					spec_locality='#sl#'
			</cfquery>
		</cfif>
		<cfif l.recordcount is 1 and len(l.locality_id) gt 0>
			<cfset locid=l.locality_id>
		<cfelse>
			<br>making locality
			<cfquery name="nlid" datasource="uam_god">
				select sq_locality_id.nextval n from dual
			</cfquery>
			<cfset locid=nlid.n>
			<cfquery name="nl" datasource="uam_god">
				insert into locality (
					LOCALITY_ID,
					GEOG_AUTH_REC_ID,
					SPEC_LOCALITY
				) values (
					#nlid.n#,
					#g.geog_auth_rec_id#,
					'#sl#'
				)
			</cfquery>
			<cfif len(LAD) gt 0>
				<br>making coords
				<cfquery name="nl" datasource="uam_god">
					insert into lat_long (
						LAT_LONG_ID,
						LOCALITY_ID,
						lat_deg,
						LAT_MIN,
						LAT_SEC,
						LAT_DIR,
						LONG_DEG,
						LONG_MIN,
						LONG_SEC,
						LONG_DIR,
						DATUM,
						ORIG_LAT_LONG_UNITS,
						DETERMINED_BY_AGENT_ID,
						DETERMINED_DATE,
						LAT_LONG_REF_SOURCE,
						ACCEPTED_LAT_LONG_FG,
						GEOREFMETHOD,
						VERIFICATIONSTATUS
					) values (
						sq_lat_long_id.nextval,
						#locid#,
						#lad#,
						#lam#,
						#las#,
						'#lar#',
						#lod#,
						#lom#,
						#los#,
						'#lor#',
						'unknown',
						'deg. min. sec.',
						0,
						sysdate,
						'unknown',
						1,
						'not recorded',
						'unverified'
					)
				</cfquery>
			</cfif>
		</cfif>
		<br>locid is #locid#
		<cfquery name="ci" datasource="uam_god">
			select * from cataloged_item,
			collecting_event
			 where
			 cataloged_item.collecting_event_id=collecting_event.collecting_event_id and
			  cat_num=#cn# and collection_id=43
		</cfquery>
		<cfquery name="cid" datasource="uam_god">
			select collecting_event_id from collecting_event where
			locality_id=#locid# and
			BEGAN_DATE=to_date('#dateformat(ci.began_date,'dd-mmm-yyyy')#') and
			ENDED_DATE=to_date('#dateformat(ci.ENDED_DATE,'dd-mmm-yyyy')#') and
 			VERBATIM_DATE='#ci.VERBATIM_DATE#' and
			VERBATIM_LOCALITY='#ci.VERBATIM_LOCALITY#' and
			COLL_EVENT_REMARKS='#ci.COLL_EVENT_REMARKS#' and
			COLLECTING_SOURCE='#ci.COLLECTING_SOURCE#' and
			COLLECTING_METHOD='#ci.COLLECTING_METHOD#' and
			HABITAT_DESC='#ci.HABITAT_DESC#'
		</cfquery>
		<cfif cid.recordcount is 1>
			<br>gonna use event #cid.collecting_event_id#
			<cfquery name="uci" datasource="uam_god">
				update cataloged_item set collecting_event_id=#cid.collecting_event_id# where  cat_num=#cn# and collection_id=43
			</cfquery>
			<cfquery name="f" datasource="uam_god">
				update bfu set status='spiffy' where cn=#cn#
			</cfquery>
		<cfelse>
			<br>making event
			<cfquery name="ncid" datasource="uam_god">
				select sq_collecting_event_id.nextval n from dual
			</cfquery>
			<cfquery name="inc" datasource="uam_god">
				insert into collecting_event (
					COLLECTING_EVENT_ID,
					LOCALITY_ID,
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					COLLECTING_SOURCE,
					COLLECTING_METHOD,
					HABITAT_DESC
				) values (
					#ncid.n#,
					#locid#,
					to_date('#dateformat(ci.began_date,'dd-mmm-yyyy')#'),
					to_date('#dateformat(ci.ENDED_DATE,'dd-mmm-yyyy')#'),
					'#ci.VERBATIM_DATE#',
					'#ci.VERBATIM_LOCALITY#',
					'#ci.COLL_EVENT_REMARKS#',
					'#ci.COLLECTING_SOURCE#',
					'#ci.COLLECTING_METHOD#',
					'#ci.HABITAT_DESC#'
				)
			</cfquery>
			<cfquery name="uci" datasource="uam_god">
				update cataloged_item set collecting_event_id=#ncid.n# where  cat_num=#cn# and collection_id=43
			</cfquery>
			<cfquery name="f" datasource="uam_god">
				update bfu set status='spiffy' where cn=#cn#
			</cfquery>
		</cfif>
	<cfelse>
		<cfquery name="f" datasource="uam_god">
			update bfu set status='nogeog' where cn=#cn#
		</cfquery>
	</cfif>
</cftransaction>
</cfloop>
</cfoutput>
