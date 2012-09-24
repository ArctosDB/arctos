<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfif action is "nothing">
	<br><A href="es_spec.cfm?action=insBulk">insBulk</A>
	<br><A href="es_spec.cfm?action=findSpec">findSpec</A>
	<br><A href="es_spec.cfm?action=shostat">shostat</A>
</cfif>


<cfif action is "shostat">
	<cfquery name="d" datasource="uam_god">
		select status,count(*) c from spec_scan group by status
	</cfquery>
	<cfdump var=#d#>
</cfif>

<cfif action is "findSpec">
	<cfquery name="d" datasource="uam_god">
		select 
			*
		from 
			spec_scan
		where 
			collection_object_id is null
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<cfquery name="cid" datasource="uam_god">
				select 
					flat.collection_object_id
				from 
					flat,
					specimen_part,
					coll_obj_cont_hist,
					container p,
					container c 
				where 
					flat.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=p.container_id and
					p.parent_container_id=c.container_id and
					c.barcode = '#barcode#'
			</cfquery>
			<cfif cid.recordcount is 1>
				<cfquery name="gguid" datasource="uam_god">
					update spec_scan set status='found_specimen', collection_object_id=#cid.collection_object_id# where id=#id#
				</cfquery>
			<cfelse>
				<cfquery name="gguid" datasource="uam_god">
					update spec_scan set status='specimen_not_found' where id=#id#
				</cfquery>
				<br>could not find #barcode#
				<cfquery name="specbyidnum" datasource="uam_god">
					select count(*) c from coll_obj_other_id_num where display_value='#IDNUM#'
				</cfquery>
				<cfif specbyidnum.c gt 0>
					<a href="/SpecimenResults.cfm?OIDNum=#IDNUM#&oidOper=IS">#IDNUM# - found #specbyidnum.c# times</a>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>
<cfif action is "insBulk">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select who from spec_scan group by who
		</cfquery>
		<cfloop query="d">
			<cfquery name="an" datasource="uam_god">
				select agent_name from agent_name where agent_name_type='login' and 
				upper(agent_name)='#ucase(who)#'
			</cfquery>
			<cfquery name="udn" datasource="uam_god">
				update spec_scan set who='#an.agent_name#' where who='#who#'
			</cfquery>
		</cfloop>
	</cfoutput>
	<cfquery name="d" datasource="uam_god">
		select 
			spec_scan.id,
			spec_scan.idnum,
			spec_scan.remark,
			spec_scan.barcode,
			spec_scan.container_id,
			spec_scan.taxon_name,
			spec_scan.part_name,
			spec_scan.who,
			spec_scan.when,
			loc_card_scan.accn_number,
			loc_card_scan.dec_lat,
			loc_card_scan.dec_long,
			loc_card_scan.error_m,
			loc_card_scan.age,
			loc_card_scan.formation,
			loc_card_scan.localityID,
			loc_card_scan.SeriesEpoch,
			loc_card_scan.SystemPeriod
		from 
			spec_scan,
			loc_card_scan 
		where 
			spec_scan.loc_id=loc_card_scan.loc_id and
			spec_scan.ins_bulk_date is null and
			spec_scan.collection_object_id is null and
			spec_scan.idnum like 'AK%'
	</cfquery>
	<cfloop query="d">
		<cftry>
		<cftransaction>
			<cfquery name="ib" datasource="uam_god">	
				insert into bulkloader (
					collection_object_id,
					loaded,
					enteredby,
					accn,
					taxon_name,
					nature_of_id,
					id_made_by_agent,
					verbatim_date,
					began_date,
					ended_date,
					higher_geog,
					spec_locality,
					verbatim_locality,
					SPECIMEN_EVENT_TYPE,
					<cfif len(dec_lat) gt 0>
						orig_lat_long_units,
						dec_lat,
						dec_long,
						datum,
						max_error_distance,
						max_error_units,
						GEOREFERENCE_SOURCE,
						GEOREFERENCE_PROTOCOL,
						event_assigned_by_agent,
						event_assigned_date,
						verificationstatus,
					</cfif>
					collector_agent_1,
					collector_role_1,
					collection_cde,
					institution_acronym,
					other_id_num_type_1,
					other_id_num_1,
					other_id_num_type_2,
					other_id_num_2,
					part_name_1,
					part_condition_1,
					part_barcode_1,
					part_lot_count_1,
					part_disposition_1,
					collecting_source
					<cfif len(age) gt 0>
						,geology_attribute_1,
						geo_att_value_1
					</cfif>
					<cfif len(formation) gt 0>
						,geology_attribute_2,
						geo_att_value_2
					</cfif>
					<cfif len(SeriesEpoch) gt 0>
						,geology_attribute_3,
						geo_att_value_3
					</cfif>
					<cfif len(SystemPeriod) gt 0>
						,geology_attribute_4,
						geo_att_value_4
					</cfif>
					,coll_object_remarks
				) values (
					bulkloader_pkey.nextval,
					NULL,
					'#who#',
					'#accn_number#',
					'#taxon_name#',
					'field',
					'unknown',
					'before #dateformat(now(),"yyyy-mm-dd")#',
					'1800-01-01',
					'#dateformat(now(),"yyyy-mm-dd")#',
					'no higher geography recorded',
					'no specific locality recorded',
					'no verbatim locality recorded',
					'accepted place of collection',
					<cfif len(dec_lat) gt 0>
						'decimal degrees',
						#dec_lat#,
						#dec_long#,
						<cfif len(error_m) gt 0>
							'World Geodetic System 1984',
							#error_m#,
							'm',
							'BioGeoMancer',
							'BioGeoMancer',
							'#who#',
							'#dateformat(when,"yyyy-mm-dd")#',
						<cfelse>
							'unknown',
							NULL,
							NULL,
							'locality card',
							'not recorded',
							'unknown',
							'#dateformat(when,"yyyy-mm-dd")#',
						</cfif>
						'unverified',		
					</cfif>
					'unknown',
					'c',
					'ES',
					'UAM',
					'Locality ID',
					'#localityID#',
					'original identifier',
					'#idnum#',
					'#part_name#',
					'unchecked',
					'#barcode#',
					1,
					'in collection',
					'wild caught'
					<cfif len(age) gt 0>
						,'Stage/Age',
						'#age#'
					</cfif>
					<cfif len(formation) gt 0>
						,'formation',
						'#formation#'
					</cfif>
					<cfif len(SeriesEpoch) gt 0>
						,'Series/Epoch',
						'#SeriesEpoch#'
					</cfif>
					<cfif len(SystemPeriod) gt 0>
						,'System/Period',
						'#SystemPeriod#'
					</cfif>
					,'#remark#'
				)	
			</cfquery>
			<cfquery name="uss" datasource="uam_god">
				update spec_scan set status='in_bulk',ins_bulk_date=sysdate where id=#id#
			</cfquery>
		</cftransaction>
		<cfcatch>
			<br>dammit
			<cfdump var=#cfcatch#>
			<cfquery name="uss" datasource="uam_god">
				update spec_scan set status='#cfcatch.message#' where id=#id#
			</cfquery>
		</cfcatch>
		</cftry>
	</cfloop>
</cfif>