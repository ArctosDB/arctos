<cfinclude template="/includes/_header.cfm">
		<script src="/includes/sorttable.js"></script>

<cfoutput>
	<cfif not isdefined("n")>
		<cfset n=5000>
	</cfif>
	<cfif action is "nothing">
		
		<br><a href="cumv.cfm?action=bulkmap&coln=Bird">bulkmap bird</a>
		<br><a href="cumv.cfm?action=bulkmap&coln=Herp">bulkmap herp</a>
		<br><a href="cumv.cfm?action=bulkmap&coln=Fish">bulkmap fish</a>
		<br><a href="cumv.cfm?action=bulkmap&coln=Mamm">bulkmap mamm</a>
		<br><a href="cumv.cfm?action=checkTables">checkTables</a>
		<br><a href="cumv.cfm?action=bulkmap">bulkmap</a>
		<br><a href="cumv.cfm?action=accnmap">accnmap</a>
		<br><a href="cumv.cfm?action=agentmerge">agentmerge</a>
		<br><a href="cumv.cfm?action=multiaccepttax&coln=Fish">multiaccepttax&coln=Fish</a>
		<br><a href="cumv.cfm?action=noaccepttax&coln=Fish">noaccepttax&coln=Fish</a>
		<br><a href="cumv.cfm?action=showparts&coln=Fish">showparts&coln=Fish</a>
		
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "showparts">
		<cfset title="showparts">
		
		<cfquery name="tt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				*
			from
				cumv.parts
			where
				CO_COLLECTIONCDE='#coln#' and
				rownum<1000
		</cfquery>
		<cfdump var=#tt#>
	</cfif>
	
	
	<cfif action is "noaccepttax">
		<cfset title="multiaccepttax">
		
		<cfquery name="tt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				CollectionObjectCatalog.collectioncde,
				catalognumber,
				taxonname,
				FULLTAXONNAME
			from
				(select * from cumv.CollectionObjectCatalog where collectioncde='#coln#') CollectionObjectCatalog,
				(select * from cumv.CollectionObject where collectioncde='#coln#') CollectionObject,
				(select * from cumv.determination where collectioncde='#coln#') determination,
				(select * from cumv.taxonname where collectioncde='#coln#') taxonname
			where
				collectionobjectcatalog.collectionobjectcatalogid=collectionobject.collectionobjectid (+) and
				collectionobject.COLLECTIONOBJECTID=determination.BIOLOGICALOBJECTID (+) and
				determination.TAXONNAMEID=taxonname.TAXONNAMEID (+) and
				BIOLOGICALOBJECTID in (
					select BIOLOGICALOBJECTID from cumv.determination where collectioncde='#coln#' and currentflag=1 having count(*) =0 group by BIOLOGICALOBJECTID
				)
		</cfquery>
		<cfdump var=#tt#>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "bulkmap">
		<cfset title="CUMV specimen-->bulkloader map">
		<!--- check keys via SQL - report here only if problem
			
			RECHECK THIS BEFORE REAL MIGRATION!!!
		
		select count(*) from cumv.CollectionObjectCatalog where AccessionID not in (select AccessionID from cumv.Accession);
		
		
		 select count(*) from cumv.collectionobjectcatalog where collectionobjectcatalogid not in (select collectionobjectid from cumv.collectionobject);
		 
		
		select count(*) from cumv.collectionobject where collectingEventID not in (select collectingEventID from cumv.collectingEvent);
		
		
		--pull geography out so we can start cleanup - leave a clear path back to specimens
		
		create table cumv.distinctgeog as select 
			CONTINENTOROCEAN CONTINENT_OCEAN,
			COUNTRY,
			STATE STATE_PROV,
			COUNTY,
			ISLANDGROUP ISLAND_GROUP,
			ISLAND
			from
			cumv.geography 
			group by
			CONTINENTOROCEAN,
			COUNTRY,
			STATE,
			COUNTY,
			ISLANDGROUP,
			ISLAND
			;
		

		---->
		
		
		<hr>
		
		<br>plain_old_strings are mapped.
		<br>c_string is concat_string - something still needs done
		<br>a_string are attributes that need broken out
		<br>an_string are new attribute - these need discussed with the AC, and some may get merged into other types of attributes
		<br>ar_string is attribute remark for _string_
		<br>i_string are identifiers that need broken out
		<br>u_string do not have a definite home (fish u_determinationconfidence - new field in Identification? ID remarks? ???)
		<br>p_string are "probably" - p_elevation (birds) can _probably_ be broken out into structured elevation data - but we may decide to jsut stuff it into specloc or something too.
		<br>All controlled vocabularies will need cleaned
		
		<hr>
		<!------------- common mappings ------------------>
		<cfset sql="
			COLLECTIONOBJECT.COLLECTIONOBJECTID COLLECTIONOBJECTID,
				COLLECTIONOBJECT.derivedfromid derivedfromid,
				Accession.Number0 ACCN,
				CollectionObjectCatalog.CollectionCde COLLECTION_CDE,
				CollectionObject.FieldNumber i_collector_number,
				CollectionObjectCatalog.Location i_original_identifier,
				CollectionObjectCatalog.CatalogNumber CAT_NUM,
				CollectingEvent.Method collecting_method,				
				CollectingEvent.VerbatimDate verbatim_date,
				CollectingEvent.Remarks COLL_EVENT_REMARKS,
				CollectingEvent.StationFieldNumber collecting_event_name,
				Locality.LocalityName spec_locality,
				Locality.Datum datum,
				Locality.Remarks LOCALITY_REMARKS,
				Locality.NamedPlaceExtent c_georeference_source1,
				Locality.Text1 c_GEOREFERENCE_SOURCE2,
				Locality.GeoRefDetRef c_GEOREFERENCE_SOURCE3,
				Locality.GeoRefDetDate 	c_GEOREFERENCE_SOURCE4,
				Locality.Latitude1 DEC_LAT,
				Locality.Longitude1 DEC_LONG,
				BiologicalObjectAttributes.Remarks c_COLL_OBJECT_REMARKS1,
				CollectionObject.Description c_COLL_OBJECT_REMARKS2,
				Determination.Remarks c_COLL_OBJECT_REMARKS3,
				DeterminerAgent.merged_name ID_MADE_BY_AGENT,
				taxonname.fullTaxonName taxon_name,
				Determination.YesNo1 p_id_remark,
				CollectorAgent.merged_name collector_agent_1,
		">
		<!---------------- collection-specific, not decoded ---------------->
		<cfif coln is "Bird">
			<cfset sql=sql&"BiologicalObjectAttributes.LengthBill an_LengthBill,
					BiologicalObjectAttributes.LengthBody a_wing_chord ,
					BiologicalObjectAttributes.LengthMiddleToe an_LengthMiddleToe,
					BiologicalObjectAttributes.Condition a_stomach_contents,
					BiologicalObjectAttributes.LengthTarsus an_LengthTarsus,
					BiologicalObjectAttributes.Wingspan a_extension,
					BiologicalObjectAttributes.LengthGonad a_length_left_gonad,
					BiologicalObjectAttributes.WidthGonad an_width_left_gonad,
					BiologicalObjectAttributes.Sex ar_weight,
					BiologicalObjectAttributes.Age a_fat_deposition,
					BiologicalObjectAttributes.Length a_total_length,
					BiologicalObjectAttributes.LengthTail an_tail_length,
					BiologicalObjectAttributes.LengthHeadBody an_length_right_gonad,
					BiologicalObjectAttributes.Width an_width_right_gonad,
					BiologicalObjectAttributes.InsideHeightAperture a_bursa_length,
					BiologicalObjectAttributes.InsideWidthAperture an_bursa_width,
					BiologicalObjectAttributes.BranchingAt a_verbatim_preservation_date,
					BiologicalObjectAttributes.ReproductiveCondition an_Reproductive_Condition,
					BiologicalObjectAttributes.Weight a_weight,
					BiologicalObjectAttributes.Text2 an_brood_patch,
					BiologicalObjectAttributes.Text3 a_molt_condition,
					BiologicalObjectAttributes.Text4 an_bill_color,
					BiologicalObjectAttributes.Text5 an_leg_color,
					BiologicalObjectAttributes.Text6 an_cere_color,
					BiologicalObjectAttributes.Text7 a_skull_ossification,
					determination.CONFIDENCE an_age_or_devstage,
					Determination.Method a_sex,
					CollectingEvent.VerbatimLocality c_HABITAT0,
					Habitat.text1 c_Habitat1,
					Locality.BaseMeridian ORIG_LAT_LONG_UNITS,
					Locality.Text2 p_elevation,
					Locality.Number1 p_max_error_distance,
					BiologicalObjectAttributes.Text1 Preparator,
					BiologicalObjectAttributes.Stage collecting_method,
					BiologicalObjectAttributes.Activity i_preparator_number,">
				<cfelseif coln is "Mamm">
					<cfset sql=sql&"
					determination.CONFIDENCE a_age_class,
					BiologicalObjectAttributes.LengthTragus a_tragus_length,
					BiologicalObjectAttributes.LengthHindFoot a_hind_foot_with_claw,
					BiologicalObjectAttributes.LengthForeArm a_forearm_length,
					BiologicalObjectAttributes.Condition a_stomach_contents,
					BiologicalObjectAttributes.LengthEar a_ear_from_notch,
					BiologicalObjectAttributes.Wingspan an_wing_span,
					BiologicalObjectAttributes.LengthGonad an_len_left_gonad,
					BiologicalObjectAttributes.WidthGonad an_width_left_gonad,
					BiologicalObjectAttributes.Length a_total_length,
					BiologicalObjectAttributes.LengthHeadBody an_length_right_gonad,
					BiologicalObjectAttributes.LengthTail a_tail_length,
					BiologicalObjectAttributes.Width an_width_right_gonad,
					BiologicalObjectAttributes.ReproductiveCondition a_reproductive_data,
					BiologicalObjectAttributes.Weight a_weight,
					Determination.Method a_sex,
					Locality.RangeDirection LATDIR,
					Locality.TownshipDirection LONGDIR,
					Locality.Text2 ORIG_LAT_LONG_UNITS,
					Locality.Number1 p_max_error_distance,">
				<cfelseif coln is "Fish">
					<cfset sql=sql&"determination.CONFIDENCE identification_remark,
					Determination.Text1 an_sex_or_devstage,
					Locality.RelationToNamedPlace ORIG_LAT_LONG_UNITS,
					Locality.RangeDirection LATDIR,
					Locality.TownshipDirection LONGDIR,
					Locality.Text1 habitat4,
					Locality.Text2 habitat3,">
				<cfelseif coln is "Herp">
					<cfset sql=sql&"determination.CONFIDENCE identification_remark,
					Determination.Text1 a_age_class,
					Locality.Text1 c_elevation,">
				</cfif>
				
				<cfloop list="#sql#" delimiters="," index="pair">
					<!----
						<br>pair: #pair#
					---->
					<cfset specify=listgetat(pair,1," ")>
					<cfset arctos=listgetat(pair,2," ")>
					<cfset stable=listgetat(specify,1,".")>
					<cfset scol=listgetat(specify,2,".")>
				
					<br>#arctos#==<a href="cumv.cfm?action=showDistinctContents&tableName=#stable#&columnName=#scol#&collectioncde=#coln#">#specify#</a>
				</cfloop>
				<cfif coln is "Bird">
					<cfset sql=sql&"
						decode (BiologicalObjectAttributes.YesNo4,
							'-1','no',
							'0','yes',
							'1','ambiguous',
							NULL,NULL,
							'somethingelse'
						) a_bursa,">
					<br>a_bursa==<a href="cumv.cfm?action=showDistinctContents&tableName=BiologicalObjectAttributes&columnName=YesNo4&collectioncde=#coln#">BiologicalObjectAttributes.YesNo</a>
				<cfelseif coln is "Fish">
					<cfset sql=sql&"decode (Locality.ElevationMethod,
						'B','brackish',
						'F','fresh',
						'M','marine') c_habitat2,">
					<br>an_salinity==<a href="cumv.cfm?action=showDistinctContents&tableName=Locality&columnName=ElevationMethod&collectioncde=#coln#">Locality.ElevationMethod</a>
				</cfif>
				<cfset sql=sql&"
					substr(CollectingEvent.STARTDATE,1,4) || decode(substr(CollectingEvent.STARTDATE,5,2),
					'00','',
					'-' || substr(CollectingEvent.STARTDATE,5,2) || 
					decode(substr(CollectingEvent.STARTDATE,7,2),
						'00','',	
						'-' || substr(CollectingEvent.STARTDATE,7,2) || 
						decode(CollectingEvent.STARTTIME,
							NULL,'',
							'-1','',
							decode(length(CollectingEvent.starttime),
								1,'T0' || CollectingEvent.starttime,
								2,'T' || CollectingEvent.starttime,
								3,'T0' || substr(CollectingEvent.starttime,1,1) || ':' || substr(CollectingEvent.starttime,2,2),
								4,'T' || substr(CollectingEvent.starttime,1,2) || ':' || substr(CollectingEvent.starttime,3,2)
							)
						)
					)
				) began_date,
				substr(CollectingEvent.ENDDATE,1,4) || 
				decode(substr(CollectingEvent.ENDDATE,5,2),
					'00','',
					'-' || substr(CollectingEvent.ENDDATE,5,2) || 
					decode(substr(CollectingEvent.ENDDATE,7,2),
						'00','',	
						'-' || substr(CollectingEvent.ENDDATE,7,2) || 
						decode(CollectingEvent.ENDTIME,
							NULL,'',
							'-1','',
							decode(length(CollectingEvent.ENDTIME),
								1,'T0' || CollectingEvent.ENDTIME,
								2,'T' || CollectingEvent.ENDTIME,
								3,'T0' || substr(CollectingEvent.ENDTIME,1,1) || ':' || substr(CollectingEvent.ENDTIME,2,2),
								4,'T' || substr(CollectingEvent.ENDTIME,1,2) || ':' || substr(CollectingEvent.ENDTIME,3,2)
							)
						)
					)
				) ended_date,
				substr(determination.DETERMINATIONDATE,1,4) || 
					decode(substr(determination.DETERMINATIONDATE,5,2),
						'00','',
						'-' || substr(determination.DETERMINATIONDATE,5,2) || 
						decode(substr(determination.DETERMINATIONDATE,7,2),
							'00','',	
							'-' || substr(determination.DETERMINATIONDATE,7,2)
						)
					)
				MADE_DATE,
				CONTINENTOROCEAN || ':' || COUNTRY || ':' || STATE || ':' || COUNTY || ':' || ISLANDGROUP || ':' || ISLAND c_higher_geog
			from
				(select * from cumv.CollectionObjectCatalog where collectioncde='#coln#') CollectionObjectCatalog,
				(select * from cumv.Accession where collectioncde='#coln#') Accession,
				(select * from cumv.CollectionObject where collectioncde='#coln#') CollectionObject,
				(select * from cumv.CollectingEvent where collectioncde='#coln#') CollectingEvent,
				(select * from cumv.locality where collectioncde='#coln#') locality,
				(select * from cumv.geography where collectioncde='#coln#') geography,
				(select * from cumv.BiologicalObjectAttributes where collectioncde='#coln#') BiologicalObjectAttributes,
				(select * from cumv.Determination where collectioncde='#coln#' and CurrentFlag=1) Determination,
				(select * from cumv.taxonname where collectioncde='#coln#') taxonname,
				(select * from cumv.agent where collectioncde='#coln#') DeterminerAgent,
				(select * from cumv.collectors where collectioncde='#coln#') collectors,
				(select * from cumv.agent where collectioncde='#coln#') CollectorAgent,
				(select * from cumv.Habitat where collectioncde='#coln#') Habitat
			where
				CollectionObjectCatalog.AccessionID=Accession.AccessionID (+) and
				collectionobjectcatalog.collectionobjectcatalogid=collectionobject.collectionobjectid (+) and
				collectionobject.collectingEventID=collectingevent.collectingEventID (+) and
				collectingevent.BIOOBJECTTYPECOLLECTEDID=Habitat.BIOOBJECTTYPECOLLECTEDID (+) and
				collectingevent.localityID=locality.localityID (+) and
				locality.geographyID=geography.geographyID (+) and
				collectionobject.collectionobjectid=BiologicalObjectAttributes.BiologicalObjectAttributesID (+) and
				collectionobject.derivedfromid is null and 
				collectionobject.COLLECTIONOBJECTID = Determination.BIOLOGICALOBJECTID (+) and
				determination.TAXONNAMEID=taxonname.TAXONNAMEID (+) and
				determination.DeterminerID=DeterminerAgent.AgentID (+) and
				collectionobject.collectingEventID=collectors.collectingEventID (+) and
				collectors.AgentID=CollectorAgent.AgentID (+) and
				rownum<50	">
		<cfset dsql=replace(sql,",",",<br>","all")>
		<cfset dsql=replace(dsql," and"," and<br>","all")>
		<hr>sql
		<p></p>
		<cfset sql="select #sql#">
				 
		<cfquery name="x" datasource="uam_god">
			#preservesinglequotes(sql)#							
		</cfquery>
		<cfquery name="specimen" dbtype="query">
			select * from x where derivedfromid is null			
		</cfquery>
		<cfset ac = specimen.columnlist>
		<table border id="t" class="sortable">
			<tr>
				<!----
					<cfloop from="1" to="4" index="p">
					<th>part_name_#p#</th>
					<th>part_remark_#p#>
					<th>part_disposition_#p#</th>
				</cfloop>
				---->
				<cfloop list="#ac#" index="i">
					<th>#i#</th>
				</cfloop>
			</tr>
			<cfloop query="specimen">	
				<tr>
					
					<!-----
				<cfquery name="part" datasource="uam_god">
					select	
						COLLECTIONOBJECTID,
						COLLECTIONOBJECTTYPEID,
						DESCRIPTION,
						PREPARATIONMETHOD,
						TEXT1,
						TEXT2,
						NUMBER1,
						YESNO1,
						YESNO2,
						REMARKS
					from
						cumv.collectionobject
					where
						collectioncde='#coln#' and
						derivedfromid=#COLLECTIONOBJECTID#
				</cfquery>
				<!--- looks like there are always 4 or fewer parts - RECONFIRM THIS!! --->
				
					<cfloop from="1" to="4" index="p">
						<cfset remk="">
						<cfset remk=listappend(remk,text1,";")>
						
						<cfif part.text2[p] is "F">
							<cfset dpn="in collection">
						<cfelseif part.text2[p] is "M">
							<cfset dpn='missing'>
						<cfelse>
							<cfset dpn='unchecked'>
							<cfset remk=listappend(remk,part.text2[p],";")>
						</cfif>
						<td>#part.PREPARATIONMETHOD[p]#</td>	
						<td>#part.PREPARATIONMETHOD[p]#</td>	
					</cfloop>
						<cfloop query="part">
							
							<br>PREPARATIONMETHOD=#PREPARATIONMETHOD#
							
							<br>DESCRIPTION=#DESCRIPTION#
							<br>YESNO1=#YESNO1#
							<br>YESNO2=#YESNO2#
							<br>REMARKS=#REMARKS#
						</cfloop>
						
					</td>
					---->
					<cfloop list="#ac#" index="c">
						<td>#evaluate(c)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		
		
 ----------------------------------------------------------------- -------- --------------------------------------------
  						<!----
				parts stuff
				
				collectionobject.COLLECTIONOBJECTID,
				 collectionobject.COLLECTIONOBJECTTYPEID,
				 collectionobject.DESCRIPTION,
				 collectionobject.PREPARATIONMETHOD,
				 collectionobject.TEXT1,
				 collectionobject.TEXT2,
				 collectionobject.NUMBER1,
				 collectionobject.YESNO1,
				 collectionobject.YESNO2,
				 collectionobject.thecount,
				 collectionobject.REMARKS,
				 ---->	
 OTHER_ID_NUM_5 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_5							    VARCHAR2(255)

 								    VARCHAR2(255)
 NATURE_OF_ID								    VARCHAR2(255)
 							    VARCHAR2(255)
 								    VARCHAR2(20)
  						    VARCHAR2(4000)
 HIGHER_GEOG								    VARCHAR2(255)
 VERBATIM_LOCALITY							    VARCHAR2(255)
 							    VARCHAR2(255)
 								    VARCHAR2(255)
 								    VARCHAR2(255)
 LATDEG 								    VARCHAR2(20)
 DEC_LAT_MIN								    VARCHAR2(255)
 LATMIN 								    VARCHAR2(255)
 LATSEC 								    VARCHAR2(255)
  								    VARCHAR2(50)
 LONGDEG								    VARCHAR2(20)
 DEC_LONG_MIN								    VARCHAR2(255)
 LONGMIN								    VARCHAR2(255)
 LONGSEC								    VARCHAR2(255)
 								    VARCHAR2(50)
 							    VARCHAR2(255)
 MAX_ERROR_DISTANCE							    VARCHAR2(255)
 MAX_ERROR_UNITS							    VARCHAR2(255)
 GEOREFERENCE_PROTOCOL							    VARCHAR2(255)
 EVENT_ASSIGNED_BY_AGENT						    VARCHAR2(255)
 EVENT_ASSIGNED_DATE							    VARCHAR2(20)
 VERIFICATIONSTATUS							    VARCHAR2(255)
 MAXIMUM_ELEVATION							    VARCHAR2(20)
 MINIMUM_ELEVATION							    VARCHAR2(20)
 ORIG_ELEV_UNITS							    VARCHAR2(255)
 							    VARCHAR2(4000)
 								    VARCHAR2(4000)
 							    VARCHAR2(4000)
 COLLECTOR_AGENT_1							    VARCHAR2(255)
 COLLECTOR_ROLE_1							    VARCHAR2(255)
 COLLECTOR_AGENT_2							    VARCHAR2(255)
 COLLECTOR_ROLE_2							    VARCHAR2(255)
 COLLECTOR_AGENT_3							    VARCHAR2(255)
 COLLECTOR_ROLE_3							    VARCHAR2(255)
 COLLECTOR_AGENT_4							    VARCHAR2(255)
 COLLECTOR_ROLE_4							    VARCHAR2(50)
 COLLECTOR_AGENT_5							    VARCHAR2(255)
 COLLECTOR_ROLE_5							    VARCHAR2(255)
 COLLECTOR_AGENT_6							    VARCHAR2(255)
 COLLECTOR_ROLE_6							    VARCHAR2(255)
 COLLECTOR_AGENT_7							    VARCHAR2(255)
 COLLECTOR_ROLE_7							    VARCHAR2(255)
 COLLECTOR_AGENT_8							    VARCHAR2(255)
 COLLECTOR_ROLE_8							    VARCHAR2(255)
 
 FLAGS									    VARCHAR2(20)
 							    VARCHAR2(4000)
 OTHER_ID_NUM_2 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_2							    VARCHAR2(255)
 OTHER_ID_NUM_3 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_3							    VARCHAR2(255)
 OTHER_ID_NUM_4 							    VARCHAR2(255)
 OTHER_ID_NUM_TYPE_4							    VARCHAR2(255)
 PART_NAME_1								    VARCHAR2(255)
 PART_CONDITION_1							    VARCHAR2(255)
 PART_BARCODE_1 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_1 						    VARCHAR2(50)
 PART_LOT_COUNT_1							    VARCHAR2(5)
 PART_DISPOSITION_1							    VARCHAR2(255)
 PART_REMARK_1								    VARCHAR2(255)
 PART_NAME_2								    VARCHAR2(255)
 PART_CONDITION_2							    VARCHAR2(255)
 PART_BARCODE_2 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_2 						    VARCHAR2(50)
 PART_LOT_COUNT_2							    VARCHAR2(5)
 PART_DISPOSITION_2							    VARCHAR2(255)
 PART_REMARK_2								    VARCHAR2(255)
 PART_NAME_3								    VARCHAR2(255)
 PART_CONDITION_3							    VARCHAR2(255)
 PART_BARCODE_3 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_3 						    VARCHAR2(50)
 PART_LOT_COUNT_3							    VARCHAR2(2)
 PART_DISPOSITION_3							    VARCHAR2(255)
 PART_REMARK_3								    VARCHAR2(255)
 PART_NAME_4								    VARCHAR2(255)
 PART_CONDITION_4							    VARCHAR2(255)
 PART_BARCODE_4 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_4 						    VARCHAR2(50)
 PART_LOT_COUNT_4							    VARCHAR2(2)
 PART_DISPOSITION_4							    VARCHAR2(255)
 PART_REMARK_4								    VARCHAR2(255)
 PART_NAME_5								    VARCHAR2(255)
 PART_CONDITION_5							    VARCHAR2(255)
 PART_BARCODE_5 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_5 						    VARCHAR2(50)
 PART_LOT_COUNT_5							    VARCHAR2(2)
 PART_DISPOSITION_5							    VARCHAR2(255)
 PART_REMARK_5								    VARCHAR2(255)
 PART_NAME_6								    VARCHAR2(255)
 PART_CONDITION_6							    VARCHAR2(255)
 PART_BARCODE_6 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_6 						    VARCHAR2(50)
 PART_LOT_COUNT_6							    VARCHAR2(2)
 PART_DISPOSITION_6							    VARCHAR2(255)
 PART_REMARK_6								    VARCHAR2(255)
 PART_NAME_7								    VARCHAR2(255)
 PART_CONDITION_7							    VARCHAR2(255)
 PART_BARCODE_7 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_7 						    VARCHAR2(50)
 PART_LOT_COUNT_7							    VARCHAR2(2)
 PART_DISPOSITION_7							    VARCHAR2(255)
 PART_REMARK_7								    VARCHAR2(255)
 PART_NAME_8								    VARCHAR2(255)
 PART_CONDITION_8							    VARCHAR2(255)
 PART_BARCODE_8 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_8 						    VARCHAR2(50)
 PART_LOT_COUNT_8							    VARCHAR2(2)
 PART_DISPOSITION_8							    VARCHAR2(255)
 PART_REMARK_8								    VARCHAR2(255)
 PART_NAME_9								    VARCHAR2(255)
 PART_CONDITION_9							    VARCHAR2(255)
 PART_BARCODE_9 							    VARCHAR2(50)
 PART_CONTAINER_LABEL_9 						    VARCHAR2(50)
 PART_LOT_COUNT_9							    VARCHAR2(50)
 PART_DISPOSITION_9							    VARCHAR2(255)
 PART_REMARK_9								    VARCHAR2(255)
 PART_NAME_10								    VARCHAR2(255)
 PART_CONDITION_10							    VARCHAR2(255)
 PART_BARCODE_10							    VARCHAR2(50)
 PART_CONTAINER_LABEL_10						    VARCHAR2(50)
 PART_LOT_COUNT_10							    VARCHAR2(50)
 PART_DISPOSITION_10							    VARCHAR2(255)
 PART_REMARK_10 							    VARCHAR2(255)
 PART_NAME_11								    VARCHAR2(255)
 PART_CONDITION_11							    VARCHAR2(255)
 PART_BARCODE_11							    VARCHAR2(50)
 PART_CONTAINER_LABEL_11						    VARCHAR2(50)
 PART_LOT_COUNT_11							    VARCHAR2(50)
 PART_DISPOSITION_11							    VARCHAR2(255)
 PART_REMARK_11 							    VARCHAR2(255)
 PART_NAME_12								    VARCHAR2(255)
 PART_CONDITION_12							    VARCHAR2(255)
 PART_BARCODE_12							    VARCHAR2(50)
 PART_CONTAINER_LABEL_12						    VARCHAR2(50)
 PART_LOT_COUNT_12							    VARCHAR2(50)
 PART_DISPOSITION_12							    VARCHAR2(255)
 PART_REMARK_12 							    VARCHAR2(255)
 ATTRIBUTE_1								    VARCHAR2(50)
 ATTRIBUTE_VALUE_1							    VARCHAR2(255)
 ATTRIBUTE_UNITS_1							    VARCHAR2(255)
 ATTRIBUTE_REMARKS_1							    VARCHAR2(255)
 ATTRIBUTE_DATE_1							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_1							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_1 						    VARCHAR2(255)
 ATTRIBUTE_2								    VARCHAR2(50)
 ATTRIBUTE_VALUE_2							    VARCHAR2(255)
 ATTRIBUTE_UNITS_2							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_2							    VARCHAR2(255)
 ATTRIBUTE_DATE_2							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_2							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_2 						    VARCHAR2(255)
 ATTRIBUTE_3								    VARCHAR2(50)
 ATTRIBUTE_VALUE_3							    VARCHAR2(255)
 ATTRIBUTE_UNITS_3							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_3							    VARCHAR2(255)
 ATTRIBUTE_DATE_3							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_3							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_3 						    VARCHAR2(255)
 ATTRIBUTE_4								    VARCHAR2(50)
 ATTRIBUTE_VALUE_4							    VARCHAR2(4000)
 ATTRIBUTE_UNITS_4							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_4							    VARCHAR2(255)
 ATTRIBUTE_DATE_4							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_4							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_4 						    VARCHAR2(255)
 ATTRIBUTE_5								    VARCHAR2(50)
 ATTRIBUTE_VALUE_5							    VARCHAR2(255)
 ATTRIBUTE_UNITS_5							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_5							    VARCHAR2(255)
 ATTRIBUTE_DATE_5							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_5							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_5 						    VARCHAR2(255)
 ATTRIBUTE_6								    VARCHAR2(50)
 ATTRIBUTE_VALUE_6							    VARCHAR2(255)
 ATTRIBUTE_UNITS_6							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_6							    VARCHAR2(4000)
 ATTRIBUTE_DATE_6							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_6							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_6 						    VARCHAR2(255)
 ATTRIBUTE_7								    VARCHAR2(50)
 ATTRIBUTE_VALUE_7							    VARCHAR2(255)
 ATTRIBUTE_UNITS_7							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_7							    VARCHAR2(255)
 ATTRIBUTE_DATE_7							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_7							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_7 						    VARCHAR2(255)
 ATTRIBUTE_8								    VARCHAR2(50)
 ATTRIBUTE_VALUE_8							    VARCHAR2(255)
 ATTRIBUTE_UNITS_8							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_8							    VARCHAR2(255)
 ATTRIBUTE_DATE_8							    VARCHAR2(20)
 ATTRIBUTE_DET_METH_8							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_8 						    VARCHAR2(255)
 ATTRIBUTE_9								    VARCHAR2(50)
 ATTRIBUTE_VALUE_9							    VARCHAR2(255)
 ATTRIBUTE_UNITS_9							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_9							    VARCHAR2(255)
 ATTRIBUTE_DATE_9							    VARCHAR2(50)
 ATTRIBUTE_DET_METH_9							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_9 						    VARCHAR2(255)
 ATTRIBUTE_10								    VARCHAR2(50)
 ATTRIBUTE_VALUE_10							    VARCHAR2(255)
 ATTRIBUTE_UNITS_10							    VARCHAR2(50)
 ATTRIBUTE_REMARKS_10							    VARCHAR2(255)
 ATTRIBUTE_DATE_10							    VARCHAR2(50)
 ATTRIBUTE_DET_METH_10							    VARCHAR2(50)
 ATTRIBUTE_DETERMINER_10						    VARCHAR2(255)
 RELATIONSHIP								    VARCHAR2(60)
 RELATED_TO_NUMBER							    VARCHAR2(60)
 RELATED_TO_NUM_TYPE							    VARCHAR2(255)
 MIN_DEPTH								    VARCHAR2(20)
 MAX_DEPTH								    VARCHAR2(20)
 DEPTH_UNITS								    VARCHAR2(30)
 COLLECTING_SOURCE							    VARCHAR2(255)
 ASSOCIATED_SPECIES							    VARCHAR2(4000)
 LOCALITY_ID								    VARCHAR2(20)
 UTM_ZONE								    VARCHAR2(3)
 UTM_EW 								    VARCHAR2(60)
 UTM_NS 								    VARCHAR2(60)
 GEOLOGY_ATTRIBUTE_1							    VARCHAR2(255)
 GEO_ATT_VALUE_1							    VARCHAR2(255)
 GEO_ATT_DETERMINER_1							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_1						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_1						    VARCHAR2(255)
 GEO_ATT_REMARK_1							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_2							    VARCHAR2(255)
 GEO_ATT_VALUE_2							    VARCHAR2(255)
 GEO_ATT_DETERMINER_2							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_2						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_2						    VARCHAR2(255)
 GEO_ATT_REMARK_2							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_3							    VARCHAR2(255)
 GEO_ATT_VALUE_3							    VARCHAR2(255)
 GEO_ATT_DETERMINER_3							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_3						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_3						    VARCHAR2(255)
 GEO_ATT_REMARK_3							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_4							    VARCHAR2(255)
 GEO_ATT_VALUE_4							    VARCHAR2(255)
 GEO_ATT_DETERMINER_4							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_4						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_4						    VARCHAR2(255)
 GEO_ATT_REMARK_4							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_5							    VARCHAR2(255)
 GEO_ATT_VALUE_5							    VARCHAR2(255)
 GEO_ATT_DETERMINER_5							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_5						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_5						    VARCHAR2(255)
 GEO_ATT_REMARK_5							    VARCHAR2(4000)
 GEOLOGY_ATTRIBUTE_6							    VARCHAR2(255)
 GEO_ATT_VALUE_6							    VARCHAR2(255)
 GEO_ATT_DETERMINER_6							    VARCHAR2(255)
 GEO_ATT_DETERMINED_DATE_6						    VARCHAR2(255)
 GEO_ATT_DETERMINED_METHOD_6						    VARCHAR2(255)
 GEO_ATT_REMARK_6							    VARCHAR2(4000)
 COLLECTING_EVENT_ID							    NUMBER
 COLLECTION_ID							   NOT NULL NUMBER
 ENTERED_AGENT_ID						   NOT NULL NUMBER
 ENTEREDTOBULKDATE							    TIMESTAMP(6)
 SPECIMEN_EVENT_REMARK							    VARCHAR2(255)
 SPECIMEN_EVENT_TYPE							    VARCHAR2(255)
 LOCALITY_NAME								    VARCHAR2(255)
 C$LAT									    NUMBER(12,10)
 C$LONG 								    NUMBER(13,10)
 COLLECTING_EVENT_NAME							    VARCHAR2(255)

uam@ARCTOSPROD> 


	</cfif>
	<!------------------------------------------------------->
	<cfif action is "multiaccepttax">
		<cfset title="multiaccepttax">
		
		<cfquery name="tt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				CollectionObjectCatalog.collectioncde,
				catalognumber,
				taxonname,
				FULLTAXONNAME
			from
				(select * from cumv.CollectionObjectCatalog where collectioncde='#coln#') CollectionObjectCatalog,
				(select * from cumv.CollectionObject where collectioncde='#coln#') CollectionObject,
				(select * from cumv.determination where collectioncde='#coln#') determination,
				(select * from cumv.taxonname where collectioncde='#coln#') taxonname
			where
				collectionobjectcatalog.collectionobjectcatalogid=collectionobject.collectionobjectid (+) and
				collectionobject.COLLECTIONOBJECTID=determination.BIOLOGICALOBJECTID (+) and
				determination.TAXONNAMEID=taxonname.TAXONNAMEID (+) and
				BIOLOGICALOBJECTID in (
					select BIOLOGICALOBJECTID from cumv.determination where collectioncde='#coln#' and currentflag=1 having count(*) > 1 group by BIOLOGICALOBJECTID
				)
		</cfquery>
		<cfdump var=#tt#>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "agentmerge">
		<cfset title="agentmerge">
		necessary because agent names are in random places - see if we can come up with a unified namestring
		
		update cumv.agent set merged_name=trim(replace(firstname || ' ' || middleinitial || ' ' || lastname,'  ',' ')) where merged_name is null;

		<cfquery name="tt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from cumv.agent			
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>FIRSTNAME</th>
				<th>LASTNAME</th>
				<th>MIDDLEINITIAL</th>
				<th>TITLE</th>
				<th>INTERESTS</th>
				<th>ABBREVIATION</th>
				<th>NAME</th>
				<th>REMARKS</th>
				<th>allnull</th>
			</tr>
			
			<cfloop query="tt">
				<tr>
					<td>#AGENTTYPE#</td>
					<td>#FIRSTNAME#</td>
					<td>#LASTNAME#</td>
					<td>#MIDDLEINITIAL#</td>
					<td>#TITLE#</td>
					<td>#INTERESTS#</td>
					<td>#ABBREVIATION#</td>
					<td>#NAME#</td>
					<td>#REMARKS#</td>
					<td><cfif len(trim(LASTNAME)) is 0 and len(trim(NAME)) is 0>1</cfif></td>
				</tr>
				
			</cfloop>

		</table>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "checkTables">
		<cfset title="cumv tables">
		<cfset tableList="AccessionAgents,
			AccessionAuthorizations,
			Accession,
			Address,
			AgentAddress,
			Agent,
			BiologicalObjectAttributes,
			BiologicalObjectRelationType,
			BorrowAgents,
			Borrow,
			BorrowMaterial,
			BorrowShipments,
			CatalogSeries,
			CatalogSeriesDefinition,
			CollectingEvent,
			Collection,
			CollectionObjectCatalog,
			CollectionObject,
			CollectionObjectType,
			CollectionTaxonomyTypes,
			Collectors,
			DeaccessionAgents,
			DeaccessionCollectionObject,
			Deaccession,
			Determination,
			Geography,
			GeologicTimeBoundary,
			GeologicTimePeriod,
			GroupPersons,
			Habitat,
			LoanAgents,
			Loan,
			LoanPhysicalObject,
			LoanReturnPhysicalObject,
			Locality,
			Observation,
			Permit,
			Preparation,
			Shipment,
			TaxonName,
			TaxonomicUnitType,
			TaxonomyType">
		<hr>running for tables:
		<ul>
			<cfloop list="#tableList#" index="t">
				<li>#t#</li>
			</cfloop>
		</ul>
		<cfloop list="#tableList#" index="t">
			<hr>
			Looking at table #t#....
			<a href="cumv.cfm?action=showTable&tableName=#t#">[ Show first 5000 rows ]</a>
			<cfquery name="tt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select * from cumv.#t# where 1=2
			</cfquery>
			<cfset thisColumns=tt.columnlist>
			<br>columnlist: #thisColumns#
			<cfloop list="#thisColumns#" index="cname">
					<cfquery name="nn" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
						select COLLECTIONCDE,count(*) c from cumv.#t# where #cname# is not null group by COLLECTIONCDE
					</cfquery>
					<cfquery name="sc" dbtype="query">
						select sum(c) s from nn						
					</cfquery>
					<ul>
						<cfif sc.s gt 0>
							<li><a href="cumv.cfm?action=showDistinctContents&tableName=#t#&columnName=#cname#">Show all distinct values of #t#.#cname#</a>
							<ul>
							<cfloop query="nn">
								<cfif nn.c gt 0>
									<li><a href="cumv.cfm?action=showDistinctContents&tableName=#t#&columnName=#cname#&collectioncde=#collectioncde#">Show all distinct values of #t#.#cname# for #collectioncde#</a></li>
								</cfif>
							</cfloop>
							</ul>
							</li>
						<cfelse>
							<li>-------- #t#.#cname# is not used -----------
						</cfif>
					</ul>
					<!--------
				<cfif left(c,6) is "number" or left(c,4) is "text" or left(c,5) is "yesno">
					<br>Column #c# starts with "number" or "text" or "yesno".... 
				</cfif>
				----->
			</cfloop>
		</cfloop>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "showDistinctContents">
		<cfset title="cumv #tableName#.#columnName#">
		<script src="/includes/sorttable.js"></script>
		<cfif not isdefined("collectioncde")>
			<cfset collectioncde="">
		</cfif>
		Showing Showing first #n# rows (max) distinct values of #columnName# <cfif len(collectioncde) gt 0>for collection #collectioncde#</cfif> in table #tableName#
		<cfquery name="x" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select 
				#columnName#,
				collectioncde,
				count(*) c 
			from 
				cumv.#tableName# 
				where #columnName# is not null and
				rownum < #n#
				<cfif len(collectioncde) gt 0> and collectioncde='#collectioncde#' </cfif> 
			group by #columnName#,collectioncde
			order by collectioncde,#columnName#
		</cfquery>
		<p>
		Found #x.recordcount# rows
		</p>
		<table border id="t" class="sortable">
			<tr>
				<th>#columnName#</th>
				<th>coln</th>
				<th>##</th>
			</tr>
			<cfloop query="x">
				<tr>
					<td>#evaluate("x." & columnName)#</td>
					<td>#collectioncde#</td>
					<td>#c#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "showTable">
		<cfset title="cumv #tableName#">

		<cfif not isdefined("collectioncde")>
			<cfset collectioncde="">
		</cfif>
		Showing first #n# rows (max) from <cfif len(collectioncde) gt 0> collection #collectioncde#</cfif> in table #tableName#
		<cfquery name="x" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select 
				*
			from 
				cumv.#tableName# 
				<cfif len(collectioncde) gt 0> where collectioncde='#collectioncde#' </cfif>
			where rownum < #n#
		</cfquery>
		<p>
		Found #x.recordcount# rows
		</p>
		<table border id="t" class="sortable">
			<tr>
				<cfloop list="#x.columnList#" index="f">
					<th>#f#</th>
				</cfloop>
			</tr>
			<cfloop query="x">
				<tr>
					<cfloop list="#x.columnList#" index="f">
						<td>#evaluate("x." & f)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
	</cfif>
	
	<!------------------------------------------------------->
	<cfif action is "accnmap">
		<cfset title="cumv accn map">
		
		<!-------
		<br>test the join from accession to accessionAgents
		<cfquery name="acnNoAgent" datasource="uam_god">
			select
				*
			from
				cumv.accession
			where 
				accessionid not in (select accessionid from cumv.accessionagents)
		</cfquery>
		<br>These accessions have no agents:
		<br>JF:  We checked on a few of these accessions in our Specify databases, and these lack agents here as well, so it does not appear to be a mapping issues.  
		<cfdump var=#acnNoAgent#>
		
		<br>the ER diagram gives a join from accessionagents to agentaddress, so test that too
		<cfquery name="acnAgentNoAddress" datasource="uam_god">
			select
				*
			from
				cumv.accessionagents
			where 
				AgentAddressID not in (select AgentAddressID from cumv.agentaddress)
		</cfquery>
		<br>These accessionAgents have no agentaddress:
		<cfdump var=#acnAgentNoAddress#>
		
		<br>and finally from agentaddress to agent to get an agent name, what we really want
			<cfquery name="accessionAgentsNoAgent" datasource="uam_god">
			select
				*
			from
				cumv.agentaddress
			where 
				AgentID not in (select AgentID from cumv.agent)
		</cfquery>
		<br>These agentaddress have no agent:
		<cfdump var=#accessionAgentsNoAgent#>
		
		<br>These values of DATEACCESSIONED are not valid
			<cfquery name="DATEACCESSIONED" datasource="uam_god">
			select
				DATEACCESSIONED
			from
				cumv.accession
			where 
				isdate(DATEACCESSIONED)=0
			group by 
				DATEACCESSIONED
		</cfquery>
		<br>These agentaddress have no agent:
		<cfdump var=#DATEACCESSIONED#>
		
		
		
		
		
		
		
		------------>
		
			
		<cfset maxNumberOfAccnAgents='0'>
		<cfquery name="x" datasource="uam_god">
			select
				collectionCde,
				accessionID,
				Accession.Number0 ACCN_NUMBER,
				decode (yesno1,
					-1,Accession.Status || '; checklist complete',
					Accession.Status
				) ACCN_STATUS,
				Accession.Type ACCN_TYPE,
				Accession.DateReceived,
				Accession.DateAccessioned,
				Accession.Text1 nom1,
				Accession.Text2 nom2,
				Accession.Text3 nom3,
				remarks,
				yesno2,
				verbatimdate,
				DateReceived
			from
				cumv.accession
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>ACCN_NUMBER</th>
				<th>collectionCde</th>
				<th>ACCN_STATUS</th>
				<th>ACCN_TYPE</th>
				<th>nature_of_material</th>
				<th>RECEIVED_DATE</th>
				<th>TRANS_DATE</th>
				<th>##agents</th>
				<th>agent1</th>
				<th>role1</th>
				<th>agent2</th>
				<th>role2</th>
				<th>agent3</th>
				<th>role3</th>
				<th>agent4</th>
				<th>role4</th>
				<th>agent5</th>
				<th>role5</th>
				<th>agent6</th>
				<th>role6</th>
				<th>agent7</th>
				<th>role7</th>
				<th>TRANS_REMARKS</th>
			</tr>
		<cfloop query="x">
			<cfset nom=''>
			<cfif len(nom1) gt 0>
				<cfif collectionCde is "Bird" or collectionCde is "Fish">
					<cfset nom="Where/Origin: " & nom1>
				<cfelseif collectionCde is "Mamm">
					<cfset nom="Agents: (null in final?) " & nom1>
				<cfelseif collectionCde is "Herp">
					<cfset nom="Description: " & nom1>
				</cfif>				
			</cfif>
			<cfif len(nom2) gt 0>
				<cfif collectionCde is "Bird">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Description: " & nom2>
					<cfelse>
						<cfset nom="Description: " & nom2>
					</cfif>
				<cfelseif collectionCde is "Mamm">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Where/Origin: " & nom2>
					<cfelse>
						<cfset nom="Where/Origin: " & nom2>
					</cfif>
				<cfelseif collectionCde is "Fish">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Paperwork: " & nom2>
					<cfelse>
						<cfset nom="Paperwork: " & nom2>
					</cfif>
				<cfelseif collectionCde is "Herp">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Where/Origin: " & nom2>
					<cfelse>
						<cfset nom="Where/Origin: " & nom2>
					</cfif>
				</cfif>
			</cfif>
			<cfif len(nom3) gt 0>
				<cfif collectionCde is "Bird">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Paperwork: " & nom3>
					<cfelse>
						<cfset nom="Paperwork: " & nom3>
					</cfif>
				<cfelseif collectionCde is "Mamm">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Description: " & nom3>
					<cfelse>
						<cfset nom="Description: " & nom3>
					</cfif>
				<cfelseif collectionCde is "Fish">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Description: " & nom3>
					<cfelse>
						<cfset nom="Description: " & nom3>
					</cfif>
				<cfelseif collectionCde is "Herp">
					<cfif len(nom) gt 0>
						<cfset nom=nom & "; Agents: (null in final?) " & nom3>
					<cfelse>
						<cfset nom="Agents: (null in final?) " & nom3>
					</cfif>
				</cfif>
			</cfif>
			<cfif (collectionCde is "Herp" or collectionCde is "Bird" or collectionCde is "Mamm") and len(YesNo2) gt 0>
				<cfif len(nom) gt 0>
					<cfset nom=nom & "; " & "field notes supplied with accession?: " & YesNo2>
				<cfelse>
					<cfset nom="field notes supplied with accession?: " & YesNo2>
				</cfif>				
			</cfif>
			<cfif len(verbatimdate) gt 0>
				<cfif len(nom) gt 0>
					<cfset nom=nom & "; verbatim date=" & verbatimdate>
				<cfelse>
					<cfset nom="verbatim date=" & verbatimdate>
				</cfif>
			</cfif>			
			<cfif len(nom) is 0>
				<cfset nom='not given'>
			</cfif>
			<cfif DateReceived gt 0>
				<cfset y=left(DateReceived,4)>
				<cfset m=mid(DateReceived,5,2)>
				<cfset d=right(DateReceived,2)>
				<cfset RECEIVED_DATE="#y#-#m#-#d#">
			<cfelse>
				<cfset RECEIVED_DATE="">
			</cfif>
			<cfif DateAccessioned gt 0>
				<cfset y=left(DateAccessioned,4)>
				<cfset m=mid(DateAccessioned,5,2)>
				<cfset d=right(DateAccessioned,2)>
				<cfset TRANS_DATE="#y#-#m#-#d#">
			<cfelse>
				<cfset TRANS_DATE="">
			</cfif>
			<tr>
				<td>#ACCN_NUMBER#</td>
				<td>#collectionCde#</td>
				<td>#ACCN_STATUS#</td>
				<td>#ACCN_TYPE#</td>
				<td>#nom#</td>
				<td>#RECEIVED_DATE#</td>
				<td>#TRANS_DATE#</td>
				<cfquery name="a" datasource="uam_god">
					select 
						role,
						merged_name,
						AccessionAgents.Remarks
					from 
						(select * from cumv.accessionagents where collectioncde='#collectioncde#') accessionagents,
						(select * from cumv.AgentAddress where collectioncde='#collectioncde#') AgentAddress,
						(select * from cumv.Agent where collectioncde='#collectioncde#') Agent
					where
						accessionagents.AgentAddressID=AgentAddress.AgentAddressID (+) and
						AgentAddress.AgentID=Agent.AgentID (+) and
						accessionagents.accessionID=#accessionID#
					group by
						role,
						merged_name,
						AccessionAgents.Remarks
				</cfquery>
				<td>#a.recordcount#</td>
				<cfif a.recordcount gt maxNumberOfAccnAgents>
					<cfset maxNumberOfAccnAgents=a.recordcount>
				</cfif>
				<cfset remk=remarks>
				<cfloop from="1" to="7" index="x"><!-- make sure this number stays OK --->
					<!---deal with AccessionAgents.Remarks--->
					<cfif len(a.Remarks[x]) gt 0>
						<cfif len(remk) gt 0>
							<cfset remk=remk & "; " & a.Remarks[x]>
						<cfelse>
							<cfset remk=a.Remarks[x]>
						</cfif>
					</cfif>	
					<td>#a.merged_name[x]#</td>
					<td>#a.role[x]#</td>
				</cfloop>
				<td>#remk#</td>
			</tr>
		</cfloop>
		</table>
		<hr>the max number of agents in an accn is #maxNumberOfAccnAgents#
	</cfif>
	<!------------------------------------------------------->
		
	<cfif action is "baddate">
		<cfset title="bad dates">
		<cfquery name="x" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from cumv.cdate where BEGAN_IS_DATE!='valid' or ENDED_IS_DATE!= 'valid'
		</cfquery>
		<cfdump var=#x#>
	</cfif>
	
	<!------------------------------------------------------->
		
		;
</cfoutput>		
<cfinclude template="/includes/_footer.cfm">

<!------------------

drop table cumv.temp;
drop table cumv.cdate;


create table cumv.temp as
select 
	STARTDATE,
	STARTTIME,
	ENDDATE,
	ENDTIME,
	substr(STARTDATE,1,4) || 
	decode(substr(STARTDATE,5,2),
		'00','',
		'-' || substr(STARTDATE,5,2) || 
		decode(substr(STARTDATE,7,2),
			'00','',	
			'-' || substr(STARTDATE,7,2) || 
			decode(STARTTIME,
				NULL,'',
				'-1','',
				decode(length(starttime),
					1,'T0' || starttime,
					2,'T' || starttime,
					3,'T0' || substr(starttime,1,1) || ':' || substr(starttime,2,2),
					4,'T' || substr(starttime,1,2) || ':' || substr(starttime,3,2)
				)
			)
		)
	) began_date,
	substr(ENDDATE,1,4) || 
	decode(substr(ENDDATE,5,2),
		'00','',
		'-' || substr(ENDDATE,5,2) || 
		decode(substr(ENDDATE,7,2),
			'00','',	
			'-' || substr(ENDDATE,7,2) || 
			decode(ENDTIME,
				NULL,'',
				'-1','',
				decode(length(ENDTIME),
					1,'T0' || ENDTIME,
					2,'T' || ENDTIME,
					3,'T0' || substr(ENDTIME,1,1) || ':' || substr(ENDTIME,2,2),
					4,'T' || substr(ENDTIME,1,2) || ':' || substr(ENDTIME,3,2)
				)
			)
		)
	) ended_date
	from cumv.collectingevent;
	



	
create table cumv.cdate as select STARTDATE,STARTTIME,ENDDATE,ENDTIME,BEGAN_DATE,ENDED_DATE from cumv.temp group by STARTDATE,STARTTIME,ENDDATE,ENDTIME,BEGAN_DATE,ENDED_DATE;

alter table cumv.cdate add began_is_date varchar2(255);
alter table cumv.cdate add ended_is_date varchar2(255);

update cumv.cdate set began_is_date=is_iso8601(began_date);
update cumv.cdate set ended_is_date=is_iso8601(ended_date);


--- ignore all this - there is only ever one collector (which may contain multiple agent strings)
declare 
	i number;
	maxi number;
begin
	for r in (select COLLECTIONCDE,COLLECTINGEVENTID from cumv.collectionobject group by COLLECTIONCDE,COLLECTINGEVENTID) loop
		i:=1;
		for a in (select MERGED_NAME from cumv.collectors,cumv.agent where cumv.collectors.agentid=cumv.agent.agentid and cumv.collectors.COLLECTINGEVENTID=r.COLLECTINGEVENTID) loop
			i:=i+1;
		end loop;
		if i > maxi then
			maxi:=i;
		end if;
	end loop;
	dbms_output.put_line('max num colls: ' || maxi);
end;
/

create table cumv.collector_agent (
	collectioncde varchar2(10),
	COLLECTINGEVENTID varchar2(300),
	agent_1 varchar2(300),
	order_1 varchar2(300),
	
);

 select COLLECTINGEVENTID from cumv.collectors where COLLECTINGEVENTID not in (select COLLECTINGEVENTID from cumv.collectionobject);

declare 
	i number;
	maxi number;
begin
	for r in (select COLLECTIONCDE,COLLECTINGEVENTID from cumv.collectionobject group by COLLECTIONCDE,COLLECTINGEVENTID) loop
		i:=1;
		for a in (select MERGED_NAME from cumv.collectors,cumv.agent where cumv.collectors.agentid=cumv.agent.agentid and cumv.collectors.COLLECTINGEVENTID=r.COLLECTINGEVENTID) loop
			i:=i+1;
		end loop;
		if i > maxi then
			maxi:=i;
		end if;
	end loop;
	dbms_output.put_line('max num colls: ' || maxi);
end;
/

-------------- end ignore agnet


----------------------------------------PARTS-------------------------------

CO_PREPARATIONMETHOD=part name
CO_DESCRIPTION = part name
CO_YESNO2 - part of part_name
P_MEDIUM - part of part name 


co_remarks=part remarks
co_text1=part remarks
co_text2 = part disposition
CO_THECOUNT - lot count
co_yesno1 - disposition (-1="on loan" ????)


P_NUMBER1  -->  Cell#

P_PARTINFORMATION - Tissue Voucher #


P_PREPARATIONTYPE - storage location

P_TEXT1 -  Box #

P_TEXT2 - Tissue #

P_NUMBER2 - door #



drop table cumv.upart;

create table cumv.upart as select
	CO_COLLECTIONCDE,
	CO_PREPARATIONMETHOD,
	CO_DESCRIPTION,
 	CO_YESNO2,
	P_MEDIUM
from
	cumv.parts
where
	CO_DERIVEDFROMID is not null
group by
	CO_COLLECTIONCDE,
	CO_PREPARATIONMETHOD,
	CO_DESCRIPTION,
 	CO_YESNO2,
	P_MEDIUM
;

select
	CATALOGNUMBER
from
	(select * from cumv.collectionobjectcatalog where collectioncde='Bird') collectionobjectcatalog,
	(select * from cumv.parts where co_collectioncde='Bird') parts
where 
	collectionobjectcatalog.COLLECTIONOBJECTCATALOGID =parts.CO_DERIVEDFROMID and
	parts.co_description like '%Rollin G Bauer%'
;

select * from cumv.parts where co_description like '%Rollin G Bauer%';

 desc cumv.collectionobjectcatalog
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTIONCDE							   NOT NULL VARCHAR2(10)
 COLLECTIONOBJECTCATALOGID						    VARCHAR2(300)
 COLLECTIONOBJECTTYPEID 						    VARCHAR2(300)
 CATALOGSERIESID							    VARCHAR2(300)
 SUBNUMBER								    VARCHAR2(300)
 NAME									    VARCHAR2(300)
 MODIFIER								    VARCHAR2(300)
 ACCESSIONID								    VARCHAR2(300)
 CATALOGERID								    VARCHAR2(300)
 CATALOGEDDATE								    VARCHAR2(300)
 LOCATION								    VARCHAR2(300)
 TIMESTAMPCREATED							    VARCHAR2(300)
 TIMESTAMPMODIFIED							    VARCHAR2(300)
 LASTEDITEDBY								    VARCHAR2(300)
 DEACCESSIONED								    VARCHAR2(300)
 								    VARCHAR2(300)

	Rollin G Bauer
-------------------->