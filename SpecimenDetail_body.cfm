<cfif not isdefined("toProperCase")>
	<cfinclude template="/includes/_frameHeader.cfm">
</cfif>
<style>
	.expandoscroll-medium {
		max-height:250px;overflow:auto;
	}
	.expandoscroll-small {
		max-height:150px;overflow:auto;
	}
	.expandoscroll-large {
		max-height:600px;overflow:auto;
	}
	.verified_and_locked{
		border:6px solid green;
		margin:1em;
	}
	.verified_accepted{
		border:3px solid green;
		margin:1em;
	}
	.verified_unaccepted{
		border:3px solid red;
		margin:1em;
		background-color:gray;
	}
	.verified_unverified{
		border:3px solid yellow;
		margin:1em;
	}
	.verified_default{
		border:3px solid black;
		margin:1em;
	}





</style>
<script src="/includes/sorttable.js"></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<cfoutput>
	<cfif not isdefined("collection_object_id") or not isnumeric(collection_object_id)>
		<div class="error">
			Improper call. Aborting.....
		</div>
		<cfabort>
	</cfif>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<cfset oneOfUs = 1>
		<cfset isClicky = "likeLink">
	<cfelse>
		<cfset oneOfUs = 0>
		<cfset isClicky = "">
	</cfif>
	<cfif oneOfUs is 0 and cgi.CF_TEMPLATE_PATH contains "/SpecimenDetail_body.cfm">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
	</cfif>
	<script>
		jQuery(document).ready(function(){
			//these are structured as
			//locColEventMedia_{specimen_event_id}_{collecting_event_id}_{locality_id}
			//they're in separate DIVs because paging replaces contents
			// just take what we need
			$("div[id^='locColEventMedia_']").each(function(e){
				var f = this.id.split(/_/);
				//var seid=f[1];
				var ceid=f[2];
				//var lid=f[3];
            	getMedia('specimenLocCollEvent',ceid,this.id,'2','1');
            });
            $("div[id^='colEventMedia_']").each(function(e){
				var f = this.id.split(/_/);
				//var seid=f[1];
				var ceid=f[2];
				//var lid=f[3];
				getMedia('specimenCollectingEvent',ceid,this.id,'2','1');
            });

			getMedia('specimenaccn','#collection_object_id#','SpecAccnMedia','2','1');
            getMedia('specimen','#collection_object_id#','specMediaDv','4','1');
            $("##mediaUpClickThis").click(function(){
			    addMedia('collection_object_id','#collection_object_id#');
			});



			$('*[class*="expandoscroll"]').each(function(i, obj) {
			   var tid=this.id;
			   if (this.offsetHeight < this.scrollHeight ||
				    this.offsetWidth < this.scrollWidth) {
				    var lk="<span class=\"likeLink\" onclick=\"noscrollify('" + tid + "');\">[ expand ]</span>";
				    $( "##expando-" + tid).html(lk);
				  //  $( "<div id='expctl_" + tid + "'><span class=\"likeLink\" onclick=\"noscrollify('" + tid + "');\">[ expand ]</span></div>" ).insertAfter( theLabelDiv );
				}
			});

			$("div[id^='eventPartLink_']").each(function(e){
				//console.log(this.id);
				var thisid=this.id;
				var f = this.id.split(/_/);
				//console.log(f);
				//var seid=f[1];
				var spid=f[1];
				//console.log(spid);
				//var lid=f[3];


				//$( "##" + thisid).prepend('processing....');


				$.getJSON("/component/SpecimenResults.cfc",
					{
						method : "getSpecimenEventLinkedData",
						returnformat : "json",
						queryformat : 'column',
						collection_object_id      : #collection_object_id#,
						related_key_type : "specimen_part",
						related_key_value: spid
					},
						function (data) {
							console.log(data);
							if (data.ROWCOUNT>0){
								var seid=data.DATA.SPECIMEN_EVENT_ID[0];
							} else {
								var seid='';
							}
							addSpecEvtLnkLnks('specimen_part',spid,seid);

							//if (data.ROWCOUNT>0){
							//	$( "##" + thisid).prepend('<span class="infoLink" onclick="highlightSpecimenEvent(' + "'" +  data.DATA.SPECIMEN_EVENT_ID[0] + "'" + ');">linked event:' + data.DATA.SPECIMEN_EVENT_ID[0] + '</span>');
							//} else {
							//	$( "##" + thisid).prepend('partID: ' + spid + '; notlinked ');
							//}
					}
				);
            });
		});

		function addSpecEvtLnkLnks(typ,id,seid){
			console.log('i am addSpecEvtLnkLnks');
			console.log('typ:' + typ);
			console.log('id:' + id);
			console.log('seid:' + seid);

			var theHTML='';
			if (typ='specimen_part'){
				console.log('running for specimen_part');
				// all we can handle at the moment
				if ( seid ){
					console.log('seid isnot null');
					// there is a linked event
					// show the ID, allow highlight
					theHTML+="<span class=\"infoLink\" onclick=\"highlightSpecimenEvent('" +  seid + "');\">linkedEvent:" + seid + "</span>";

				console.log('part1' + theHTML);
					// and add a delete button
					theHTML+="<br><span class=\"infoLink\" onclick=\"delinkSpecEvt('specimen_part','" + id + "');\">removeLink</span>";
				console.log('part3' + theHTML);
				}
				// always include the pick link; it'll just over-write any existing
				theHTML+="<br><span class=\"infoLink\" onclick=\"pickSpecEvtLnk('#collection_object_id#','specimen_part','" +id + "');\">pickEvent</span>";


				console.log('part3' + theHTML);
				// write
				$( "##eventPartLink_" + id).html(theHTML);

				//console.log(theHTML);

			}
		}
		function noscrollify(id){
			$("##" + id).removeClass($("##" + id).attr("data-expandoclass"));
			var s="<span class=\"likeLink\" onclick=\"rescrollify('" + id + "');\">[ collapse ]</span>";
			$("##expando-" + id).html(s);
		}

		function rescrollify(id){
			$("##" + id).addClass($("##" + id).attr("data-expandoclass"));
			var s="<span class=\"likeLink\" onclick=\"noscrollify('" + id + "');\">[ expand ]</span>";
			$("##expando-" + id).html(s);
		}
		function madeSpecimenEventLink(specimen_event_id,related_thing,related_key){
			alert('madeSpecimenEventLink from' +  specimen_event_id + ' to ' + related_thing + ' value ' + related_key);
			console.log(related_thing);

			//if (related_thing=='specimen_part'){
			//	console.log('here we are');
			//	$( "##eventPartLink_" + related_key).html('<span class="infoLink" onclick="highlightSpecimenEvent(' + "'" +  specimen_event_id + "'" + ');">linked event:' + specimen_event_id + '</span>');
			//	$( "##eventPartLink_" + related_key).append("<br><span class=\"infoLink\" onclick=\"pickSpecEvtLnk('#collection_object_id#','specimen_part','" +related_key + "');\">pickEvent</span>");
			//	$( "##eventPartLink_" + related_key).append("<br><span class=\"infoLink\" onclick=\"delinkSpecEvt('specimen_part','" + related_key + "');\">Remove Link</span>");

			//}
			console.log('looking for eventPartLink_' + related_key);

			addSpecEvtLnkLnks(related_thing,related_key,specimen_event_id);


			highlightSpecimenEvent(specimen_event_id);

		}

		function delinkSpecEvt(thing,key){
			$.getJSON("/component/SpecimenResults.cfc",
				{
					method : "deLinkSpecEvent",
					returnformat : "json",
					queryformat : 'column',
					collection_object_id      : #collection_object_id#,
					related_key_type : thing,
					related_key_value: key
				},
				function (data) {
					if (data.RECORDCOUNT==1){
						madeSpecimenEventLink('',thing,key);
					} else {
						alert('An error may have occurred: ' + JSON.stringify(data));
					}
				}
			);
		}
		function highlightSpecimenEvent(seid){
			$(".highlightSEID").removeClass("highlightSEID");
	    	$("##seidd_" + seid).addClass('highlightSEID').show();
	    	// collapse the locality pane so we've got something to scroll to
	    	rescrollify('locality_pane');
	    	$("##locality_pane").scrollTo( $("##seidd_" + seid), 800 );
		}
		function highlightEventDerivedJunk(seid){
			console.log('highlightEventDerivedJunk: ' + seid);
			// parts
			var sct='linkedEvent:' + seid ;
			$( "span:contains(" + sct + ")").each(function(e){
				console.log($(this));
				($(this)).addClass('evenRow');
			});
				//closest("tr").addClass('evenRow');


			//$("##eventPartLink_" + seid).each(function(e){
			//	console.log($(this));
			//	$(this).closest("tr").addClass('evenRow');
			//});




		}

	</script>
	<cfif not isdefined("seid") or seid is "undefined">
		<cfset seid="">
	</cfif>
	<cfif len(seid) gt 0>
	    <script>
	    	jQuery(document).ready(function(){
	    	   $("##seidd_#seid#").addClass('highlightSEID').show();
	        });
	    </script>
	</cfif>
</cfoutput>
<cfset obj = CreateObject("component","component.functions")>
<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		collection_object_id,
		cat_num,
		collection_cde,
		accn_id,
		collection,
		EnteredBy,
		LASTUSER EditedBy,
		entereddate,
		LASTDATE,
		accession,
		concatEncumbranceDetails(collection_object_id) encumbranceDetail,
		typestatus,
		encumbrances,
		COLLECTORS,
		PREPARATORS,
		concatCollectorAgent(#session.flatTableName#.collection_object_id,'maker') makers,
		concatCollectorAgent(#session.flatTableName#.collection_object_id,'copyright holder') copyright_holders,
		remarks,
		flags,
		PHYLCLASS,
		KINGDOM,
		PHYLUM,
		PHYLORDER,
		FAMILY,
		GENUS,
		SPECIES,
		SUBSPECIES,
		FORMATTED_SCIENTIFIC_NAME,
		full_taxon_name,
		associated_species
	FROM
		#session.flatTableName#
	WHERE
		#session.flatTableName#.collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		determination_method,
		determined_date,
		determiner attributeDeterminer
	from
		v_attributes
	where
		<cfif not listfind(session.roles,"COLDFUSION_USER")>
			is_encumbered=0 and
		</cfif>
		collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="rawevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		specimen_event.SPECIMEN_EVENT_ID,
		collecting_event.collecting_event_id,
		assigned_by_agent_id,
		getPreferredAgentName(assigned_by_agent_id) assigned_by_agent_name,
		assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLLECTING_METHOD,
		COLLECTING_SOURCE,
		VERIFICATIONSTATUS,
		habitat,
    	locality.LOCALITY_ID,
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		CASE
            WHEN #oneOfUs# != 1 and '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE verbatim_coordinates
        END verbatim_coordinates,
		collecting_event_name,
		CASE
            WHEN #oneOfUs# != 1 and '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE locality.DEC_LAT
        END DEC_LAT,
		CASE
            WHEN #oneOfUs# != 1 and '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE locality.DEC_LONG
        END DEC_LONG,
		collecting_event.DATUM,
		collecting_event.ORIG_LAT_LONG_UNITS,
		geog_auth_rec.GEOG_AUTH_REC_ID,
		geog_auth_rec.SOURCE_AUTHORITY,
		SPEC_LOCALITY,
		MINIMUM_ELEVATION,
		MAXIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		DEPTH_UNITS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		LOCALITY_REMARKS,
		georeference_source,
		georeference_protocol,
		locality_name,
		higher_geog,
		geog_auth_rec.SOURCE_AUTHORITY,
		geog_search_term.SEARCH_TERM,
		to_meters(MAX_ERROR_DISTANCE,MAX_ERROR_UNITS) err_in_m,
		getPreferredAgentName(specimen_event.VERIFIED_BY_AGENT_ID)  verifiedBy,
 		VERIFIED_DATE,
 		case
		       when specimen_event.verificationstatus = 'verified and locked' then 1
		       when specimen_event.verificationstatus = 'checked by collector' then 2
		       when specimen_event.verificationstatus = 'accepted' then 3
		       when specimen_event.verificationstatus = 'unverified' then 4
		       when specimen_event.verificationstatus = 'unaccepted' then 5
		       else 6
		    end order_by_vs
	from
		specimen_event,
		collecting_event,
		locality,
		geog_auth_rec,
		geog_search_term
	where
		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		collecting_event.locality_id=locality.locality_id and
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		geog_auth_rec.geog_auth_rec_id=geog_search_term.geog_auth_rec_id (+) and
		--specimen_event.verificationstatus != 'unaccepted' and
		specimen_event.collection_object_id=<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="event" dbtype="query">
	select
		SPECIMEN_EVENT_ID,
		collecting_event_id,
		assigned_by_agent_id,
		assigned_by_agent_name,
		assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLLECTING_METHOD,
		COLLECTING_SOURCE,
		VERIFICATIONSTATUS,
		habitat,
    	LOCALITY_ID,
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		verbatim_coordinates,
		collecting_event_name,
		DEC_LAT,
		DEC_LONG,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		GEOG_AUTH_REC_ID,
		SOURCE_AUTHORITY,
		SPEC_LOCALITY,
		MINIMUM_ELEVATION,
		MAXIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		DEPTH_UNITS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		err_in_m,
		LOCALITY_REMARKS,
		georeference_source,
		georeference_protocol,
		locality_name,
		higher_geog,
		SOURCE_AUTHORITY,
		 verifiedBy,
 		VERIFIED_DATE,
		order_by_vs
	from
		rawevent
	group by
		SPECIMEN_EVENT_ID,
		collecting_event_id,
		assigned_by_agent_id,
		assigned_by_agent_name,
		assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLLECTING_METHOD,
		COLLECTING_SOURCE,
		VERIFICATIONSTATUS,
		habitat,
    	LOCALITY_ID,
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		verbatim_coordinates,
		collecting_event_name,
		DEC_LAT,
		DEC_LONG,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		GEOG_AUTH_REC_ID,
		SOURCE_AUTHORITY,
		SPEC_LOCALITY,
		MINIMUM_ELEVATION,
		MAXIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		DEPTH_UNITS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		err_in_m,
		LOCALITY_REMARKS,
		georeference_source,
		georeference_protocol,
		locality_name,
		higher_geog,
		SOURCE_AUTHORITY,
		 verifiedBy,
 		VERIFIED_DATE,
		order_by_vs
	order by
		order_by_vs
</cfquery>
<cfoutput query="one">
	<cfif oneOfUs is 1>
		<form name="editStuffLinks" method="post" action="SpecimenDetail.cfm">
			<input type="hidden" id="collection_object_id" name="collection_object_id" value="#one.collection_object_id#">
			<input type="hidden" name="suppressHeader" value="true">
			<input type="hidden" name="action" value="nothing">
			<input type="hidden" name="Srch" value="Part">
	</cfif>
	<table width="95%" cellpadding="0" cellspacing="0"><!---- full page table ---->
		<tr>
			<td valign="top" width="50%">
<!------------------------------------ Taxonomy ---------------------------------------------->
				<div class="detailCell">
					<div class="detailLabel">
						Identifications
						<span class="expandoHolder" id="expando-id_pane"></span>
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentification');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock expandoscroll-small" id="id_pane" data-expandoclass="expandoscroll-small">
						<span class="detailData">
							<cfquery name="raw_identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								SELECT
									identification.scientific_name,
									concatidagent(identification.identification_id) agent_name,
									made_date,
									nature_of_id,
									identification_remarks,
									identification.identification_id,
									accepted_id_fg,
									taxa_formula,
									short_citation,
									identification.publication_id,
									taxon_name.scientific_name taxsciname,
									common_name.common_name
								FROM
									identification,
									publication,
									identification_taxonomy,
									taxon_name,
									common_name
								WHERE
									identification.publication_id=publication.publication_id (+) and
									identification.identification_id=identification_taxonomy.identification_id (+) and
									identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id (+) and
									identification_taxonomy.taxon_name_id=common_name.taxon_name_id (+) and
									identification.collection_object_id = #collection_object_id#
							</cfquery>
							<cfquery name="identification" dbtype="query">
								select
									scientific_name,
									agent_name,
									made_date,
									nature_of_id,
									identification_remarks,
									identification_id,
									accepted_id_fg,
									taxa_formula,
									short_citation,
									publication_id
								from
									raw_identification
								group by
									scientific_name,
									agent_name,
									made_date,
									nature_of_id,
									identification_remarks,
									identification_id,
									accepted_id_fg,
									taxa_formula,
									short_citation,
									publication_id
								ORDER BY accepted_id_fg DESC,made_date DESC
							</cfquery>
							<cfloop query="identification">
								<cfif accepted_id_fg is 1>
						        	<div class="acceptedIdDiv">
							    <cfelse>
						        	<div class="unAcceptedIdDiv">
						        </cfif>
								<cfquery name="thisTaxLinks" dbtype="query">
									select distinct taxsciname from raw_identification where identification_id=#identification_id#
								</cfquery>
								<cfquery name="thisCommonName" dbtype="query">
									select distinct common_name from raw_identification where common_name is not null and
									 identification_id=#identification_id#
									order by common_name
								</cfquery>
								<cfset link="">
								<cfset i=1>
								<cfset thisSciName="#scientific_name#">
								<cfloop query="thisTaxLinks">
									<cfset thisLink='<a href="/name/#taxsciname#" target="_blank">#taxsciname#</a>'>
									<cfset thisSciName=#replace(thisSciName,taxsciname,thisLink)#>
									<cfset i=i+1>
								</cfloop>
								#thisSciName#
								<cfif not isdefined("metaDesc")>
									<cfset metaDesc="">
								</cfif>
								<div class="taxDetDiv">
									<cfif accepted_id_fg is 1>
										<div class="taxaMeta">
											#one.full_taxon_name#
										</div>
									</cfif>
									<cfif thisCommonName.recordcount gt 0>
										<div class="taxaMeta">
											#valuelist(thisCommonName.common_name,'; ')#
										</div>
									</cfif>
									<cfif len(short_citation) gt 0>
										sensu <a href="/publication/#publication_id#" target="_mainFrame">#short_citation#</a><br>
									</cfif>
									Identified by #agent_name#
									<cfif len(made_date) gt 0>
										on #made_date#
									</cfif>
									<br>Nature of ID: #nature_of_id#
									<cfif len(identification_remarks) gt 0>
										<br>Remarks: #identification_remarks#
									</cfif>
								</div>
							</div>
						</cfloop>
					</span>
				</div>
			</div>
<!------------------------------------ citations ---------------------------------------------->
			<cfif len(one.typestatus) gt 0>
				<cfquery name="raw_citations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						citation.CITATION_ID,
						citation.PUBLICATION_ID,
						citation.type_status,
						identification.scientific_name idsciname,
						citation.CITATION_REMARKS,
						taxon_name.scientific_name taxsciname,
						publication.short_citation,
						citation.OCCURS_PAGE_NUMBER,
						media.preview_uri,
						media.media_type,
						media.media_uri,
						media.media_id,
						publication.doi
					FROM
						citation,
						identification,
						publication,
						identification_taxonomy,
						taxon_name,
						(select * from media_relations where media_relationship='shows publication') media_relations,
						media
					WHERE
						citation.identification_id=identification.identification_id AND
						citation.publication_id=publication.publication_id AND
						identification.identification_id=identification_taxonomy.identification_id and
						identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
						publication.publication_id = media_relations.related_primary_key (+) and
						media_relations.media_id=media.media_id (+) and
						citation.collection_object_id=#collection_object_id#
				</cfquery>
				<cfquery name="citations" dbtype="query">
					select
						PUBLICATION_ID,
						type_status,
						idsciname,
						short_citation,
						OCCURS_PAGE_NUMBER,
						CITATION_ID,
						CITATION_REMARKS,
						doi
					from
						raw_citations
					group by
						PUBLICATION_ID,
						type_status,
						idsciname,
						short_citation,
						OCCURS_PAGE_NUMBER,
						CITATION_ID,
						CITATION_REMARKS,
						doi
				</cfquery>
				<div class="detailCell">
					<div class="detailLabel">
							Citations
							<span class="expandoHolder" id="expando-citn_pane"></span>
						</div>
					<div class="detailBlock expandoscroll-small" id="citn_pane" data-expandoclass="expandoscroll-small">
						<cfloop query="citations">
							<cfquery name="thisTaxLinks" dbtype="query">
								select distinct taxsciname from raw_citations where citation_id=#citation_id# and
								taxsciname is not null
							</cfquery>
							<cfset thisSciName="#idsciname#">
							<cfloop query="thisTaxLinks">
								<cfset thisLink='<a href="/name/#taxsciname#" target="_blank">#taxsciname#</a>'>
								<cfset thisSciName=#replace(thisSciName,taxsciname,thisLink)#>
								<cfset i=i+1>
							</cfloop>
							<cfquery name="thisPubsMedia" dbtype="query">
								select distinct preview_uri,media_type,media_uri,media_id from
									raw_citations where media_id is not null and citation_id=#citation_id#
							</cfquery>
							<div class="detailBlock">
								#type_status# of #thisSciName#
								<cfif len(OCCURS_PAGE_NUMBER) gt 0>, page #OCCURS_PAGE_NUMBER#</cfif>
								in <a href="#Application.serverRootURL#/publication/#PUBLICATION_ID#">#short_citation#</a>
								<cfloop query="thisPubsMedia">
									 <cfset mp = obj.getMediaPreview(
										preview_uri="#preview_uri#",
										media_type="#media_type#")>
										<a href="/media/#media_id#?open" target="_blank"><img src="#mp#" class="smallMediaPreview"></a>
								 </cfloop>
								 <cfif len(doi) gt 0>
										<a href="http://dx.doi.org/#doi#" target="_blank" class="external sddoi">DOI:#doi#</a>
								</cfif>
								 <cfif len(CITATION_REMARKS) gt 0>
									<div class="detailCellSmall">
										#CITATION_REMARKS#
									</div>
								</cfif>
							</div>
						</cfloop>
					</div>
				</div>
			</cfif>
<!------------------------------------ locality ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">
					Location (#event.recordcount# Events)
					<span class="expandoHolder" id="expando-locality_pane"></span>
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('specLocality');">Edit</span>
					</cfif>
				</div>

				<div>
					<a target="_blank" class="external" href="/bnhmMaps/bnhmMapData.cfm?collection_object_id=#collection_object_id#">
						<span style="display: inline-block;">
							<img height="40px" src="/images/bnhm.png" alt="BerkeleyMapper">BerkeleyMapper
						</span>
					</a>
					<!-----
					query for https://github.com/ArctosDB/arctos/issues/1006
					but I have no idea how to display
					<cfquery name="sesumry" dbtype="query">
						select SPECIMEN_EVENT_TYPE,count(*) c from event group by SPECIMEN_EVENT_TYPE order by SPECIMEN_EVENT_TYPE
					</cfquery>
					---->
				</div>
				<div class="detailBlock expandoscroll-large" id="locality_pane" data-expandoclass="expandoscroll-large">
					<cfloop query="event">
						<cfif VERIFICATIONSTATUS is "verified and locked">
							<cfset thisClass="verified_and_locked">
						<cfelseif VERIFICATIONSTATUS is "accepted">
							<cfset thisClass="verified_accepted">
						<cfelseif VERIFICATIONSTATUS is "unaccepted">
							<cfset thisClass="verified_unaccepted">
						<cfelseif VERIFICATIONSTATUS is "unverified">
							<cfset thisClass="verified_unverified">
						<cfelse>
							<cfset thisClass="verified_default">
						</cfif>
						<div class="#thisClass#">
						   <div id="seidd_#specimen_event_id#" style="display:none;font-size:xx-small;">
							   OccurrenceID: #Application.serverRootURL#/guid/#guid#?seid=#specimen_event_id#
							</div>
							<span class="infoLink" onclick="highlightEventDerivedJunk('#specimen_event_id#');">highlight linked components</span>
						<table id="SD_#specimen_event_id#" width="100%">
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Determination&nbsp;Type:</td>
								<td id="SDCellRight">#specimen_event_type#</td>
							</tr>
							<tr>
								<td></td>
								<td id="SDCellRight" class="detailCellSmall">
									assigned by #assigned_by_agent_name# on #dateformat(assigned_date,'yyyy-mm-dd')#
								</td>
							</tr>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Higher Geography:</td>
								<td id="SDCellRight">
									<cfif left(source_authority,4) is "http">
										<a href="#source_authority#" target="_blank" class="external">#higher_geog#</a>
									<cfelse>
										#higher_geog#
									</cfif>
									<a href="/geography.cfm?geog_auth_rec_id=#geog_auth_rec_id#" class="infoLink">more</a>
									<cfquery name="geosrchterms" dbtype="query">
										select search_term from rawevent where specimen_event_id=#specimen_event_id# group by search_term order by search_term
									</cfquery>
									<div style="margin-left:1em;max-height:3em;overflow:auto;" class="detailBlock">
										<cfloop query='geosrchterms'>
											<div class="detailCellSmall">#search_term#</div>
										</cfloop>
									</div>
								</td>
							</tr>
							<cfif verbatim_locality is not spec_locality>
								<cfif len(verbatim_locality) gt 0>
									<tr class="detailData">
										<td id="SDCellLeft" class="innerDetailLabel">Verbatim Locality:</td>
										<td id="SDCellRight">#verbatim_locality#
										</td>
									</tr>
								</cfif>
							</cfif>
							<cfif len(locality_name) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Locality Nickname:</td>
									<td id="SDCellRight">#locality_name#</td>
								</tr>
							</cfif>
							<cfif len(collecting_event_name) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Event Nickname:</td>
									<td id="SDCellRight">#collecting_event_name#</td>
								</tr>
							</cfif>
							<cfif len(spec_locality) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Specific Locality:</td>
									<td id="SDCellRight">
										#spec_locality#
									</td>
								</tr>
							</cfif>
							<cfif len(specimen_event_remark) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Specimen/Event Remarks:</td>
									<td id="SDCellRight">#specimen_event_remark#</td>
								</tr>
							</cfif>
							<cfif len(COLL_EVENT_REMARKS) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Event Remarks:</td>
									<td id="SDCellRight">#COLL_EVENT_REMARKS#</td>
								</tr>
							</cfif>
							<cfif len(LOCALITY_REMARKS) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Locality Remarks:</td>
									<td id="SDCellRight">#LOCALITY_REMARKS#</td>
								</tr>
							</cfif>
							<cfif len(habitat) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Habitat:</td>
									<td id="SDCellRight">#habitat#</td>
								</tr>
							</cfif>
							<cfif len(collecting_method) gt 0>
								<div class="detailBlock">
									<tr class="detailData">
										<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Method:</td>
										<td id="SDCellRight">#collecting_method#</td>
									</tr>
								</div>
							</cfif>
							<cfif len(collecting_source) gt 0>
								<div class="detailBlock">
									<tr class="detailData">
										<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Source:</td>
										<td id="SDCellRight">#collecting_source#</td>
									</tr>
								</div>
							</cfif>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Event Date:</td>
								<td id="SDCellRight">#began_date#<cfif ended_date neq began_date> to #ended_date#</cfif></td>
							</tr>
							<tr>
								<td></td>
								<td id="SDCellRight" class="detailCellSmall">
									Verbatim Date: #verbatim_date#
								</td>
							</tr>
							<cfif len(VERIFICATIONSTATUS) gt 0>
								<div class="detailBlock">
									<tr class="detailData">
										<td id="SDCellLeft" class="innerDetailLabel">Verification&nbsp;Status:</td>
										<td id="SDCellRight">
											#VERIFICATIONSTATUS#
											<cfif VERIFICATIONSTATUS is "verified and locked">
												&##9989;
											<cfelseif VERIFICATIONSTATUS is "unaccepted">
												&##10060;
											<cfelseif  VERIFICATIONSTATUS is "unverified">
												&##9888;
											</cfif>
											<span class="infoLink" onclick="getCtDoc('ctverificationstatus','#VERIFICATIONSTATUS#');">Define</span>
										</td>
									</tr>
									<tr>
										<td></td>
										<td id="SDCellRight" class="detailCellSmall">
											<cfif len(verifiedBy) gt 0>
												<div>Verified By:  #verifiedBy#</div>
											</cfif>
											<cfif len(VERIFIED_DATE) gt 0>
												<div>Verified Date:  #VERIFIED_DATE#</div>
											</cfif>
										</td>
									</tr>
								</div>
							</cfif>
							<cfif len(one.associated_species) gt 0>
							<div class="detailBlock">
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Associated Species:</td>
									<td id="SDCellRight">#one.associated_species#</td>
								</tr>
							</div>
						</cfif>
							<tr>
								<td colspan="2">
									<table width="100%">
										<tr>
											<td valign="top" align="right"><!---- text stuff here ---->
												<table width="100%">
													<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
														<tr>
															<td align="right" valign="top">Coordinates:</td>
															<td align="left">
																#dec_lat# / #dec_long#
																<cfif len(verbatim_coordinates) gt 0>
																	<div class="detailCellSmall">
																		Verbatim Coordinates: #verbatim_coordinates#
																	</div>
																</cfif>
																<cfif len(DATUM) gt 0>
																	<div style="font-size:.8em;">
																		Datum: #DATUM#
																	</div>
																</cfif>
																<cfif len(MAX_ERROR_UNITS) gt 0>
																	<div style="font-size:.8em;">Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#</div>
																</cfif>
																<cfif len(georeference_source) gt 0>
																	<div style="font-size:.8em;">Georeference&nbsp;Source: #georeference_source#</div>
																</cfif>
																<cfif len(georeference_protocol) gt 0>
																	<div style="font-size:.8em;">Georeference&nbsp;Protocol: #georeference_protocol#</div>
																</cfif>
															</td>
														</tr>
													</cfif>
													<cfif len(orig_elev_units) gt 0>
														<tr>
															<td align="right">Elevation</td>
															<td align="left">#minimum_elevation# to #maximum_elevation# #orig_elev_units#</td>
														</tr>
													</cfif>
													<cfif len(DEPTH_UNITS) gt 0>
														<tr>
															<td align="right">Depth:</td>
															<td align="left">#MIN_DEPTH# to #MAX_DEPTH# #DEPTH_UNITS#</td>
														</tr>
													</cfif>
													<tr>
														<td valign="top" colspan="2">
															<div id="locColEventMedia_#specimen_event_id#_#collecting_event_id#_#locality_id#"></div>
															<div id="colEventMedia_#specimen_event_id#_#collecting_event_id#_#locality_id#"></div>
														</td>
													</tr>
												</table>
											</td>
											<td valign="top" align="right"><!---- map here --->
												<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
													<cfset coordinates="#dec_lat#,#dec_long#">
													<input type="hidden" id="coordinates_#specimen_event_id#" value="#coordinates#">
													<input type="hidden" id="error_#specimen_event_id#" value="#err_in_m#">
													<div class="#session.sdmapclass#" id="mapdiv_#specimen_event_id#"></div>
													<span class="infoLink mapdialog">map key/tools</div>
												</cfif>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<cfquery name="geology" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select * from
								geology_attributes,
								preferred_agent_name
								where
								geology_attributes.GEO_ATT_DETERMINER_ID=preferred_agent_name.agent_id (+) and
								 locality_id=#locality_id#
							</cfquery>
							<cfloop query="geology">
								<tr>
									 <td id="SDCellLeft" class="innerDetailLabel">#GEOLOGY_ATTRIBUTE#:</td>
									 <td id="SDCellRight">
										 #GEO_ATT_VALUE#
									</td>
								</tr>
								<tr>
									<td></td>
									<td id="SDCellRight" class="detailCellSmall">
										Determined by
										<cfif len(agent_name) gt 0>
											#agent_name#
										<cfelse>
											unknown
										</cfif>
										<cfif len(GEO_ATT_DETERMINED_DATE) gt 0>
											on #dateformat(GEO_ATT_DETERMINED_DATE,"yyyy-mm-dd")#
										</cfif>
										<cfif len(GEO_ATT_DETERMINED_METHOD) gt 0>
											Method: #GEO_ATT_DETERMINED_METHOD#
										</cfif>
										<cfif len(GEO_ATT_REMARK) gt 0>
											Remark: #GEO_ATT_REMARK#
										</cfif>
									</td>
								</tr>
							</cfloop>
						</table>
					</div>
				</cfloop>
				</div>
			</div>
			<cfquery name="isProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT project_name, project.project_id project_id FROM
				project, project_trans
				WHERE
				project_trans.project_id = project.project_id AND
				project_trans.transaction_id=#one.accn_id#
				GROUP BY project_name, project.project_id
		  </cfquery>
		  <cfquery name="isLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT project_name, project.project_id FROM
					loan_item,
					project,
					project_trans,
					specimen_part
				 WHERE
				 	specimen_part.derived_from_cat_item = #one.collection_object_id# AND
					loan_item.transaction_id=project_trans.transaction_id AND
					project_trans.project_id=project.project_id AND
					specimen_part.collection_object_id = loan_item.collection_object_id
				GROUP BY
					project_name, project.project_id
		</cfquery>
		<cfquery name="isLoanedItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				loan_item.collection_object_id
			FROM
				loan_item,
				specimen_part
			WHERE
				loan_item.collection_object_id=specimen_part.collection_object_id AND
				specimen_part.derived_from_cat_item=#one.collection_object_id#
			UNION
			SELECT
				loan_item.collection_object_id
			FROM
				loan_item
			WHERE
				loan_item.collection_object_id=#one.collection_object_id#
		</cfquery>
		</td>
		<td valign="top" width="50%">


<!------------------------------------ collectors ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Collector(s)
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<span class="innerDetailLabel"></span>
						<cfset collnks="">
						<cfloop list="#collectors#" delimiters="," index="i">
							<cfset t='<a href="/agent.cfm?agent_name=#trim(i)#" target="_blank" class="external">#i#</a>'>
							<cfset collnks=listappend(collnks,t,",")>
						</cfloop>
						#collnks#
					</span>
				</div>
			</div>
<!------------------------------------ preparators ---------------------------------------------->
			<cfif len(preparators) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Preparator(s)
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel"></span>
							<cfset collnks="">
							<cfloop list="#preparators#" delimiters="," index="i">
								<cfset t='<a href="/agent.cfm?agent_name=#trim(i)#" target="_blank" class="external">#i#</a>'>
								<cfset collnks=listappend(collnks,t,",")>
							</cfloop>
							#collnks#
						</span>
					</div>
				</div>
			</cfif>
<!------------------------------------ makers ---------------------------------------------->
			<cfif len(makers) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Maker(s)
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel"></span>
							<cfset collnks="">
							<cfloop list="#makers#" delimiters="," index="i">
								<cfset t='<a href="/agent.cfm?agent_name=#trim(i)#" target="_blank" class="external">#i#</a>'>
								<cfset collnks=listappend(collnks,t,",")>
							</cfloop>
							#collnks#
						</span>
					</div>
				</div>
			</cfif>

<!------------------------------------ copyright_holders ---------------------------------------------->
			<cfif len(makers) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Copyright Holder(s)
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel"></span>
							<cfset collnks="">
							<cfloop list="#copyright_holders#" delimiters="," index="i">
								<cfset t='<a href="/agent.cfm?agent_name=#trim(i)#" target="_blank" class="external">#i#</a>'>
								<cfset collnks=listappend(collnks,t,",")>
							</cfloop>
							#collnks#
						</span>
					</div>
				</div>
			</cfif>


	<!------------------------------------ identifiers ---------------------------------------------->
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT
					coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID,
					case when #oneOfUs# != 1 and
						concatencumbrances(coll_obj_other_id_num.collection_object_id) like '%mask original field number%' and
						coll_obj_other_id_num.other_id_type = 'original identifier'
						then 'Masked'
					else
						coll_obj_other_id_num.display_value
					end display_value,
					coll_obj_other_id_num.other_id_type,
					coll_obj_other_id_num.id_references,
					case when base_url is not null then
						ctcoll_other_id_type.base_url || coll_obj_other_id_num.display_value
					else
						null
					end link
				FROM
					coll_obj_other_id_num,
					ctcoll_other_id_type
				where
					collection_object_id=#one.collection_object_id# and
					coll_obj_other_id_num.other_id_type=ctcoll_other_id_type.other_id_type (+)
			</cfquery>
			<cfquery name="ids" dbtype="query">
				select * from oid where id_references='self' order by other_id_type
			</cfquery>
			<cfif len(ids.other_id_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Identifiers
						<span class="expandoHolder" id="expando-id_ids"></span>
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentifiers');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock expandoscroll-small" id="id_ids" data-expandoclass="expandoscroll-small">

						<cfloop query="ids">
							<div class="detailBlock">
								<span class="innerDetailLabel">
									#other_id_type#:
								</span>
								<cfif len(link) gt 0>
									<a class="external" href="#link#" target="_blank">#display_value#</a>
								<cfelse>
									#display_value#
								</cfif>
								<cfif other_id_type is 'NK' and oneOfUs is 1>
									<a target="_blank" href='/findContainer.cfm?container_type=cryovial&container_label=NK #display_value#%20%25'>check containers</a>
								</cfif>
							</div>
						</cfloop>
					</div>
				</div>
			</cfif>
			<cfquery name="rels" dbtype="query">
				select * from oid where id_references != 'self' order by id_references,other_id_type
			</cfquery>
			<cfif len(rels.other_id_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel">
						Relationships
						<span class="expandoHolder" id="expando-id_relations"></span>
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentifiers');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock expandoscroll-small" id="id_relations" data-expandoclass="expandoscroll-small">
						<cfloop query="rels">
							<cfquery name="relcache" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
								select * from cf_relations_cache where COLL_OBJ_OTHER_ID_NUM_ID=#COLL_OBJ_OTHER_ID_NUM_ID# order by term
							</cfquery>
							<cfset thisClass="">
							<cfif id_references is "same individual as">
								<!----
								<script>
									$("body").addClass("isDuplicateRecord");
								</script>
								---->
								<cfset thisClass="isDuplicateRecord">
							</cfif>
							<div class="detailBlock #thisClass#">
								<span class="innerDetailLabel">
									(<i>#id_references#</i>)
								</span>
								<cfif len(link) gt 0>
									<a class="external" href="#link#" target="_blank">#other_id_type#:#display_value#</a>
								<cfelse>
									#other_id_type#:#display_value#
								</cfif>
								<div class="relCacheDiv">
									<cfloop query="relcache">
										<div class="indivRelCacheTerm">
											#TERM#@#dateformat(CACHEDATE,"yyyy-mm-dd")#: #VALUE#
										</div>
									</cfloop>
								</div>
							</div>
						</cfloop>
					</div>
				</div>
			</cfif>


<!------------------------------------ parts ---------------------------------------------->

<cffunction name="getChildParts"  returnType="string">
	<!---- build table row(s) for one part and any attributes ---->

	<cfargument name="pid" type="string" required="yes">
	<cfargument name="level" type="string" required="yes">
	<cfargument name="p_q" type="query" required="yes">
	<cfargument name="l_q" type="query" required="yes">
	<cfquery name="p" dbtype="query">
		select
		*
		from
			p_q
		where
			part_id=#pid#
	</cfquery>
	<cfsavecontent variable="r">
		<cfset pdg=level-1>
		<tr>
			<td>
				<div style="padding-left:#pdg#em;">
					#p.part_name#
				</div>
			</td>
			<td>#p.part_condition#</td>
			<td>#p.part_disposition#</td>
			<td>#p.lot_count#</td>
			<cfif oneOfUs is 1>
				<td>#p.label#</td>
				<td>
					<cfif len(p.barcode) gt 0>
						<a href="/findContainer.cfm?barcode=#p.barcode#">#p.barcode#</a>
					</cfif>
				</td>
				<td>#replace(p.FCTree,':','←<wbr>','all')#</td>
				<cfquery dbtype="query" name="tlp">
					select * from l_q where transaction_id is not null and collection_object_id=#pid#
				</cfquery>
				<td>
					<cfloop query="tlp">
						<div>
							<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#loan_number# (#LOAN_STATUS#)</a>
						</div>
					</cfloop>
				</td>




				<td>
					<div id="eventPartLink_#pid#">
						<span class="infoLink" onclick="pickSpecEvtLnk('#collection_object_id#','specimen_part','#pid#');">pickEvent</span>
					</div>
				</td>
			</cfif>
			<td>#p.part_remarks#</td>
		</tr>
		<cfquery name="patt" dbtype="query">
			select
				attribute_type,
				attribute_value,
				attribute_units,
				determined_date,
				attribute_remark,
				agent_name
			from
				p_q
			where
				attribute_type is not null and
				part_id=#pid#
			group by
				attribute_type,
				attribute_value,
				attribute_units,
				determined_date,
				attribute_remark,
				agent_name
			order by
				attribute_type,
				determined_date
		</cfquery>
		<cfif patt.recordcount gt 0>
			<tr>
				<td colspan="6">
					<div style="padding-left:#level#em;">

					<table border id="patbl#pid#" class="detailCellSmall sortable">
						<tr>
							<th>
								Attribute
							</th>
							<th>
								Value
							</th>
							<th>
								Date
							</th>
							<th>
								Dtr.
							</th>
							<th>
								Rmk.
							</th>
						</tr>
						<cfloop query="patt">
							<tr>
								<td>
									#attribute_type#
								</td>
								<cfif not(oneOfUs) and attribute_type is "location" and one.encumbranceDetail contains "mask part attribute location">
									<td>masked</td>
									<td>-</td>
									<td>-</td>
									<td>-</td>
								<cfelse>
									<td>#attribute_value# <cfif len(attribute_units) gt 0>#attribute_units#</cfif></td>
									<td>#dateformat(determined_date,'yyyy-mm-dd')#</td>
									<td>#agent_name#</td>
									<td>#attribute_remark#</td>
								</cfif>
							</tr>
						</cfloop>
					</table>
					</div>
				</td>
			</tr>
		</cfif>
	</cfsavecontent>
<cfreturn r>
</cffunction>

<cfquery name="rparts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		specimen_part.collection_object_id part_id,
		pc.label,
		pc.barcode,
		part_name,
		sampled_from_obj_id,
		coll_object.COLL_OBJ_DISPOSITION part_disposition,
		coll_object.CONDITION part_condition,
		lot_count,
		coll_object_remarks part_remarks,
		attribute_type,
		attribute_value,
		attribute_units,
		determined_date,
		attribute_remark,
		agent_name,
		getContainerParentage(pc.container_id) FCtree
	from
		specimen_part,
		coll_object,
		coll_object_remark,
		coll_obj_cont_hist,
		container oc,
		container pc,
		specimen_part_attribute,
		preferred_agent_name
	where
		specimen_part.collection_object_id=specimen_part_attribute.collection_object_id (+) and
		specimen_part_attribute.determined_by_agent_id=preferred_agent_name.agent_id (+) and
		specimen_part.collection_object_id=coll_object.collection_object_id and
		coll_object.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_object.collection_object_id=coll_object_remark.collection_object_id (+) and
		coll_obj_cont_hist.container_id=oc.container_id and
		oc.parent_container_id=pc.container_id (+) and
		specimen_part.derived_from_cat_item=#one.collection_object_id#
</cfquery>
<!----
<cfquery name="parts" dbtype="query">
	select
		part_id,
		label,
		barcode,
		part_name,
		sampled_from_obj_id,
		part_disposition,
		part_condition,
		lot_count,
		part_remarks,
		FCTree
	from
		rparts
	group by
		part_id,
		label,
		barcode,
		part_name,
		sampled_from_obj_id,
		part_disposition,
		part_condition,
		lot_count,
		part_remarks,
		FCTree
	order by
		part_name
</cfquery>
---->
<cfquery name="orderedparts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		collection_object_id part_id,
 		level,
 		part_name
	from (
 		SELECT
			SAMPLED_FROM_OBJ_ID,
			collection_object_id,
			part_name
		FROM
			specimen_part
 		where
			derived_from_cat_item=#one.collection_object_id#
 		)
	START WITH SAMPLED_FROM_OBJ_ID is null
	CONNECT BY PRIOR collection_object_id = SAMPLED_FROM_OBJ_ID
	ORDER SIBLINGS BY part_name
</cfquery>

<cfquery name="ploan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		loan.loan_number,
		loan.LOAN_STATUS,
		loan.transaction_id,
		loan_item.collection_object_id
	FROM
		loan,
		loan_item,
		specimen_part
	WHERE
		loan.transaction_id=loan_item.transaction_id and
		loan_item.collection_object_id=specimen_part.collection_object_id AND
		specimen_part.derived_from_cat_item=#one.collection_object_id#
</cfquery>
			<div class="detailCell">

				<div class="detailLabel">
					Parts
					<span class="expandoHolder" id="expando-id_parts"></span>
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editParts');">Edit</span>
					<cfelse>
						<span class="detailEditCell" onClick="getInfo('parts','#one.collection_object_id#');">Details</span>
					</cfif>
				</div>
			<div class="detailBlock expandoscroll-medium" id="id_parts" data-expandoclass="expandoscroll-medium">


				<div class="detailBlock">
					<span class="detailData">
						<table border>
							<tr>
								<th><span class="innerDetailLabel">Part Name</span></th>
								<th><span class="innerDetailLabel">Condition</span></th>
								<th><span class="innerDetailLabel">Disposition</span></th>
								<th><span class="innerDetailLabel">Qty</span></th>
								<cfif oneOfUs is 1>
									<th><span class="innerDetailLabel">Label</span></th>
									<th><span class="innerDetailLabel">Barcode</span></th>
									<th><span class="innerDetailLabel">PLPath</span></th>
									<th><span class="innerDetailLabel">Loan</span></th>
									<th><span class="innerDetailLabel">Event</span></th>
								</cfif>
								<th><span class="innerDetailLabel">Remarks</span></th>
							</tr>
							<cfloop query="orderedparts">
								<cfset zxc=getChildParts(part_id,level,rparts,ploan)>
								#zxc#
							</cfloop>
						</table>
					</span>
				</div>
			</div>
		</div>
<!------------------------------------ attributes ---------------------------------------------->
			<cfif len(attribute.attribute_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel"><!---Attributes--->
						Attributes
						<span class="expandoHolder" id="expando-id_attrs"></span>
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">Edit</span>
						</cfif>
					</div>
					<cfquery name="sex" dbtype="query">
						select * from attribute where attribute_type = 'sex'
					</cfquery>
					<div class="detailBlock expandoscroll-medium" id="id_attrs" data-expandoclass="expandoscroll-medium">
						<cfloop query="sex">
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">sex:</span>
									#attribute_value#
									<cfif len(attributeDeterminer) gt 0>
										<cfset determination = "#attributeDeterminer#">
										<cfif len(determined_date) gt 0>
											<cfset determination = '#determination#, #determined_date#'>
										</cfif>
										<cfif len(determination_method) gt 0>
											<cfset determination = '#determination#, #determination_method#'>
										</cfif>
										<div class="detailBlock">
											<span class="detailCellSmall">
												#determination#
											</span>
										</div>
									</cfif>
									<cfif len(attribute_remark) gt 0>
										<div class="detailBlock">
											<span class="detailCellSmall">
												<span class="innerDetailLabel">Remark:</span>
												#attribute_remark#
											</span>
										</div>
									</cfif>
								</span>
							</div>
						</cfloop>
					<cfif one.collection_cde is "Mamm">
						<cfquery name="total_length" dbtype="query">
							select * from attribute where attribute_type = 'total length'
						</cfquery>
						<cfquery name="tail_length" dbtype="query">
							select * from attribute where attribute_type = 'tail length'
						</cfquery>
						<cfquery name="hf" dbtype="query">
							select * from attribute where attribute_type = 'hind foot with claw'
						</cfquery>
						<cfquery name="efn" dbtype="query">
							select * from attribute where attribute_type = 'ear from notch'
						</cfquery>
						<cfquery name="weight" dbtype="query">
							select * from attribute where attribute_type = 'weight'
						</cfquery>
						<cfquery name="theRest" dbtype="query">
							select * from attribute where attribute_type NOT IN (
								'weight','sex','total length','tail length','hind foot with claw','ear from notch'
							) order by attribute_type,DETERMINED_DATE
						</cfquery>
						<cfif len(total_length.attribute_units) gt 0 OR
								len(tail_length.attribute_units) gt 0 OR
								len(hf.attribute_units) gt 0  OR
								len(efn.attribute_units) gt 0  OR
								len(weight.attribute_units) gt 0><!---semi-standard measurements --->
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Std. Meas.</span>
									<table border width="100%">
										<tr>
											<td><font size="-1">total length</font></td>
											<td><font size="-1">tail length</font></td>
											<td><font size="-1">hind foot</font></td>
											<td><font size="-1">efn</font></td>
											<td><font size="-1">weight</font></td>
										</tr>
										<tr>
											<td>#total_length.attribute_value# #total_length.attribute_units#&nbsp;</td>
											<td>#tail_length.attribute_value# #tail_length.attribute_units#&nbsp;</td>
											<td>#hf.attribute_value# #hf.attribute_units#&nbsp;</td>
											<td>#efn.attribute_value# #efn.attribute_units#&nbsp;</td>
											<td>#weight.attribute_value# #weight.attribute_units#&nbsp;</td>
										</tr>
									</table>
									<cfif isdefined("attributeDeterminer") and len(#attributeDeterminer#) gt 0>
										<cfset determination = "#attributeDeterminer#">
										<cfif len(determined_date) gt 0>
											<cfset determination = '#determination#, #determined_date#'>
										</cfif>
										<cfif len(determination_method) gt 0>
											<cfset determination = '#determination#, #determination_method#'>
										</cfif>
										<div class="detailBlock">
											<span class="detailCellSmall">
												#determination#
											</span>
										</div>
									</cfif>
								</span>
							</div>
						</cfif>
					<cfelse>
						<cfquery name="theRest" dbtype="query">
							select * from attribute where attribute_type NOT IN ('sex') order by attribute_type,DETERMINED_DATE
						</cfquery>
					</cfif>
					<cfloop query="theRest">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#attribute_type#:</span>
								#attribute_value#
								<cfif len(attribute_units) gt 0>
									#attribute_units#
								</cfif>
								<cfif len(attributeDeterminer) gt 0>
									<cfset determination = "&nbsp;&nbsp;#attributeDeterminer#">
									<cfif len(determined_date) gt 0>
										<cfset determination = '#determination#, #determined_date#'>
									</cfif>
									<cfif len(determination_method) gt 0>,
										<cfset determination = '#determination#, #determination_method#'>
									</cfif>
									<div class="detailBlock">
										<span class="detailCellSmall">
											#determination#
										</span>
									</div>
								</cfif>
								<cfif len(attribute_remark) gt 0>
									<div class="detailBlock">
										<span class="detailCellSmall">
											&nbsp;&nbsp;<span class="innerDetailLabel">Remark:</span>
											#attribute_remark#
										</span>
									</div>
								</cfif>
							</div>
						</span>
					</cfloop>
				</div>
			</div>
			</cfif>
<!------------------------------------ cataloged item ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">Edit</span>
					</cfif>
					</div>
					<cfif len(one.remarks) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Remarks:</span>
								#one.remarks#
							</span>
						</div>
					</cfif>

					<cfif oneOfUs is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Entered By:</span>
								#one.EnteredBy# on #dateformat(one.entereddate,"yyyy-mm-dd")#
							</span>
						</div>
						<cfif one.EditedBy is not "unknown" OR len(one.lastdate) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Last Edited By:</span>
									#one.EditedBy# on #dateformat(one.lastdate,"yyyy-mm-dd")#
								</span>
							</div>
						</cfif>
						<cfif len(#one.flags#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Missing (flags):</span>
									#one.flags#
								</span>
							</div>
						</cfif>
						<cfif len(one.encumbranceDetail) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Encumbrances:</span>
									#replace(one.encumbranceDetail,";","<br>","all")#
								</span>
							</div>
						</cfif>
					</cfif>
				</div>
<!------------------------------------ accession ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Accession
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('addAccn');">Edit</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<cfif oneOfUs is 1>
							Edit <a href="/editAccn.cfm?Action=edit&transaction_id=#one.accn_id#" target="_blank">#accession#</a> or
						</cfif>
						View <a href="/viewAccn.cfm?transaction_id=#one.accn_id#" target="_blank">#accession#</a>
						<div id="SpecAccnMedia"></div>
					</span>
				</div>
			</div>
<!------------------------------------ usage ---------------------------------------------->
		<cfif isProj.recordcount gt 0 OR isLoan.recordcount gt 0 or (oneOfUs is 1 and isLoanedItem.collection_object_id gt 0)>
			<div class="detailCell">
				<div class="detailLabel">Usage</div>
					<cfloop query="isProj">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Contributed By Project:</span>
									<a href="/project/#isProj.project_id#">#isProj.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfloop query="isLoan">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Used By Project:</span>
		 						<a href="/project/#isLoan.project_id#" target="_mainFrame">#isLoan.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfif isLoanedItem.collection_object_id gt 0 and oneOfUs is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Loan History:</span>
									<a href="/Loan.cfm?action=listLoans&collection_object_id=#valuelist(isLoanedItem.collection_object_id)#"
										target="_mainFrame">Click for loan list</a>
							</span>
						</div>
					</cfif>
				</div>
		</cfif>
<!------------------------------------ Media ---------------------------------------------->
<cfquery name="mediaTag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select distinct
        tag.tag_id,
		media.media_id,
        media.media_uri,
        media.mime_type,
        media.media_type,
        media.preview_uri
     from
        media,
		tag
     where
         media.media_id=tag.media_id and
		tag.collection_object_id = #collection_object_id#
</cfquery>
<cfif mediaTag.recordcount gt 0>
	 <div class="detailCell">
		<div class="detailLabel">Tagged in Media
		</div>
		<div class="detailBlock">
			<cfloop query="mediaTag">
				<cfset puri = obj.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
				 <span class="detailData">
					<cfif media_type is "multi-page document">
						<a href="/document.cfm?media_id=#media_id#&tag_id=#tag_id#" target="_blank"><img src="#puri#"></a>
					<cfelse>
						<a href="/showTAG.cfm?media_id=#media_id#" target="_blank"><img src="#puri#"></a>
					</cfif>
				</span>
			</cfloop>
		</div>
	</div>
</cfif>
<div class="detailCell">
	<div class="detailLabel">
		Media
		<cfif isdefined("session.roles") and session.roles contains "manage_media">
			<a  class="detailEditCell" id="mediaUpClickThis">Attach/Upload Media</a>
		</cfif>
	</div>

	<div class="detailBlock">
		<span class="detailData">
		<div id="specMediaDv"></div>
	</div>
</div>
		<cftry>
			<!--- this thing is dicey sometimes.... ---->
			<cfquery name="barcode"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select p.barcode from
				container c,
				container p,
				coll_obj_cont_hist,
				specimen_part,
				cataloged_item
				where
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=c.container_id and
				c.parent_container_id=p.container_id and
				cataloged_item.collection_object_id=#collection_object_id#
			</cfquery>
			<cfloop query="barcode">
				<cfquery name="ocr" datasource="taccocr">
					select label from output where barcode = '#barcode#'
				</cfquery>
				<cfif ocr.recordcount is 1>
					<div class="detailLabel">
						OCR for #barcode#
					</div>
					<div class="detailBlock">
			            <span class="detailData">
							#replace(ocr.label,chr(10),'<br>','all')#
				        </span>
					</div>
				</cfif>
			</cfloop>
		<cfcatch>
		</cfcatch>
		</cftry>
	</div>
	</td><!--- end right half of table --->
</table>
<cfif oneOfUs is 1>
</form>
</cfif>
</cfoutput>
<div id="dialog" title="Would you like maps with that?">
	Map Border Key
	<ul>
		<li class="niceGeoSPatData">
			Green Border: There is a polygon for the asserted geography, and the specimen's georeference is within the polygon.
		</li>
		<li class="noWKT">
			Yellow Border: There is no polygon for the asserted geography.
		</li>
		<li class="uglyGeoSPatData">
			Red Border: There is a polygon for the asserted geography, and the specimen's georeference is <strong>not</strong> within the polygon.
		</li>
	</ul>
	Map Contents
	<ul>
		<li>Red Markers are specimen georeference point</li>
		<li>Red circle, centered on markers, is uncertainty radius. Zero-radius errors indicate unknown uncertainty, not absolute precision.</li>
		<li>Blue transparent polygon is the asserted geography's shape. Geography without supporting spatial data is ambiguous.</li>
	</ul>
	<label for="sdetmapsize">Map Size</label>
	<select id="sdetmapsize">
		<option <cfif session.sdmapclass is "tinymap"> selected="selected" </cfif> value="tinymap">tiny</option>
		<option <cfif session.sdmapclass is "smallmap"> selected="selected" </cfif> value="smallmap">small</option>
		<option <cfif session.sdmapclass is "largemap"> selected="selected" </cfif> value="largemap">large</option>
		<option <cfif session.sdmapclass is "hugemap"> selected="selected" </cfif> value="hugemap">huge</option>
	</select>
	<input type="button" onclick="saveSDMap()" value="save map settings">
</div>
<cf_customizeIFrame>