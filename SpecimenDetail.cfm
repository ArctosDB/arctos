<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("session.sdmapclass") or len(session.sdmapclass) is 0>
	<cfset session.sdmapclass='tinymap'>
</cfif>
<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<style>
		.mapdiv{width:300px;height:300px;}
		.uglyGeoSPatData{border:4px solid red;}
		.niceGeoSPatData{border:3px solid green;}
		.noWKT{border:3px solid yellow;}
	</style>
	<cfoutput>
		<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&libraries=geometry" type="text/javascript"></script>'>
	</cfoutput>
<cftry>

	<!----


											<div class="#session.sdmapclass#" id="mapdiv_#specimen_event_id#"></div>



	if (s=='nomap') {
		$("#srmapctrls-nomap").show();
		$("#srmapctrls").hide();
		$("#spresmapdiv").hide();
	} else {
		$("#srmapctrls-nomap").hide();
		$("#srmapctrls").show();
		$("#spresmapdiv").show();
		$("#spresmapdiv").removeClass().addClass(s);
		initializeMap();
	}
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeUserPreference",
			pref : "srmapclass",
			val : s,
			returnformat : "json",
			queryformat : 'column'
		}
	);
}



	}
	<label for="sdetmapsize">Map Size</label>
	<select id="sdetmapsize">
		<option <cfif session.sdmapclass is "tinymap"> selected="selected" </cfif> value="tinymap">tiny</option>
		<option <cfif session.sdmapclass is "smallmap"> selected="selected" </cfif> value="smallmap">small</option>
		<option <cfif session.sdmapclass is "largemap"> selected="selected" </cfif> value="largemap">large</option>
		<option <cfif session.sdmapclass is "hugemap"> selected="selected" </cfif> value="hugemap">huge</option>
	</select>
	<input type="button" onclick="saveSDMap()" value="save


---->
	<script>


		jQuery(document).ready(function() {
			$( "#dialog" ).dialog({
				autoOpen: false
			});

			$( ".mapdialog" ).click(function() {
				$( "#dialog" ).dialog( "open" );
			});

			mapsYo();

		});
	function (){


function saveSDMap(){
	var s=$("#saveSDMap").val();
	$("div[id^='mapdiv_']").each(function(e){
		$this.removeClass().addClass(s);
	});
}





	function mapsYo(){
		$("input[id^='coordinates_']").each(function(e){
			//var sid='coordinates_' + String(e+1);
			//console.log(this);
			//console.log('init for ' + sid);
			//console.log(this.id);
			var seid=this.id.split('_')[1];
			//this.id.replace('coordinates_','');
			//console.log(seid);
			//console.log(this.value);
			var coords=this.value;
			if (coords.length > 0 ){
				var bounds = new google.maps.LatLngBounds();
				var polygonArray = [];
				var ptsArray=[];
				var lat=coords.split(',')[0];
				var lng=coords.split(',')[1];
				//console.log('make a map');
				var errorm=$("#error_" + seid).val();
				//console.log(errorm);
				//console.log(wkt);
				var mapOptions = {
					zoom: 3,
				    center: new google.maps.LatLng(55, -135),
				    mapTypeId: google.maps.MapTypeId.ROADMAP,
				    panControl: false,
				    scaleControl: true
				};
				var map = new google.maps.Map(document.getElementById("mapdiv_" + seid), mapOptions);
				var center=new google.maps.LatLng(lat,lng);
				bounds.extend(center);
				var circleoptn = {
					strokeColor: '#FF0000',
					strokeOpacity: 0.8,
					strokeWeight: 2,
					fillColor: '#FF0000',
					fillOpacity: 0.15,
					map: map,
					center: center,
					radius: parseInt(errorm),
					zIndex:-99
				};
				crcl = new google.maps.Circle(circleoptn);
				var marker = new google.maps.Marker({
					position: center,
					map: map,
					title: 'ima dot',
					zIndex: 10
				});
				var wkt=$("#geog_polygon_" + seid).val();
				if (wkt.length > 0){
					var regex = /\(([^()]+)\)/g;
					var Rings = [];
					var results;
					while( results = regex.exec(wkt) ) {
					    Rings.push( results[1] );
					}
					for(var i=0;i<Rings.length;i++){
						var lary=[];
						var da=Rings[i].split(",");
						for(var i=0;i<da.length;i++){
							var xy = da[i].trim().split(" ");
							var pt=new google.maps.LatLng(xy[1],xy[0]);
							lary.push(pt);
							bounds.extend(pt);
						}
						ptsArray.push(lary);
					}
					var poly = new google.maps.Polygon({
					    paths: ptsArray,
					    strokeColor: '#1E90FF',
					    strokeOpacity: 0.8,
					    strokeWeight: 2,
					    fillColor: '#1E90FF',
					    fillOpacity: 0.35
					});
					poly.setMap(map);
					polygonArray.push(poly);
				} else {
					//$("#mapprobs_" + seid).html('Asserted georeference has no spatial data.').show();
	        		$("#mapdiv_" + seid).addClass('noWKT');
				}
				if (bounds.getNorthEast().equals(bounds.getSouthWest())) {
			       var extendPoint1 = new google.maps.LatLng(bounds.getNorthEast().lat() + 0.05, bounds.getNorthEast().lng() + 0.05);
			       var extendPoint2 = new google.maps.LatLng(bounds.getNorthEast().lat() - 0.05, bounds.getNorthEast().lng() - 0.05);
			       bounds.extend(extendPoint1);
			       bounds.extend(extendPoint2);
			    }
				map.fitBounds(bounds);
	        	for(var a=0; a<polygonArray.length; a++){
	        		if  (! google.maps.geometry.poly.containsLocation(center, polygonArray[a]) ) {
	        			//console.log('center is not in polygonArray[a]');
	        			//console.log(center);
	        			//console.log(polygonArray[a]);
	        			//$("#mapprobs_" + seid).html('Asserted georeference does not fall within asserted geography.').show();
	        			$("#mapdiv_" + seid).addClass('uglyGeoSPatData');
		        	} else {
		        		//$("#mapprobs_" + seid).html('Asserted georeference falls within asserted geography.').show();
	        			$("#mapdiv_" + seid).addClass('niceGeoSPatData');
	        		}
	        	}
			} else {
				$("#mapdiv_" + seid).remove();
			}
		});
	}
</script>

	<!------------





























														<div class="mapdiv" id="mapdiv_#specimen_event_id#"></div>


											<input type="text" id="coordinates_#specimen_event_id#" value="#dec_lat#,#dec_long#,#err_in_m#,#geog_a">
											<input type="text" id="error_#specimen_event_id#" value="#err_in_m#">
											<input type="text" id="geog_polygon_#specimen_event_id#" value="#geog_polygon#">

------------>
<cfif isdefined("collection_object_id")>
	<cfset checkSql(collection_object_id)>
	<cfoutput>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select GUID from #session.flatTableName# where collection_object_id=#collection_object_id#
		</cfquery>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/guid/#c.guid#">
		<cfabort>
	</cfoutput>
</cfif>
<cfif isdefined("guid")>
	<cfif cgi.script_name contains "/SpecimenDetail.cfm">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/guid/#guid#">
		<cfabort>
	</cfif>
	<cfset checkSql(guid)>
	<cfif guid contains ":">
		<cfoutput>
			<cfset sql="select #session.flatTableName#.collection_object_id from
					#session.flatTableName#,cataloged_item
				WHERE
					#session.flatTableName#.collection_object_id=cataloged_item.collection_object_id and
					upper(#session.flatTableName#.guid)='#ucase(guid)#'">
			<cfset checkSql(sql)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
		</cfoutput>
	</cfif>
	<cfif isdefined("c.collection_object_id") and len(c.collection_object_id) gt 0>
		<cfset collection_object_id=c.collection_object_id>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
		<cfabort>
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
	<cfabort>
</cfif>

<cfset detSelect = "
	SELECT
		#session.flatTableName#.guid,
		#session.flatTableName#.collection_id,
		#session.flatTableName#.locality_id,
		web_link,
		web_link_text,
		#session.flatTableName#.cat_num,
		#session.flatTableName#.collection_object_id as collection_object_id,
		#session.flatTableName#.scientific_name,
		#session.flatTableName#.collecting_event_id,
		#session.flatTableName#.higher_geog,
		#session.flatTableName#.spec_locality,
		#session.flatTableName#.verbatim_date,
		#session.flatTableName#.BEGAN_DATE,
		#session.flatTableName#.ended_date,
		#session.flatTableName#.parts as partString,
		#session.flatTableName#.dec_lat,
		#session.flatTableName#.dec_long">
<cfif len(session.CustomOtherIdentifier) gt 0>
	<cfset detSelect = "#detSelect#
	,concatSingleOtherId(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#') as	CustomID">
</cfif>
<cfset detSelect = "#detSelect#
	FROM
		#session.flatTableName#,
		collection
	where
		#session.flatTableName#.collection_id = collection.collection_id AND
		#session.flatTableName#.collection_object_id = #collection_object_id#
	ORDER BY
		cat_num">
<cfset checkSql(detSelect)>
<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfquery name="doi" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select doi from doi where COLLECTION_OBJECT_ID=#collection_object_id#
</cfquery>

<cfoutput>
	<cfset title="#detail.guid#: #detail.scientific_name#">
	<cfset metaDesc="#detail.guid#; #detail.scientific_name#; #detail.higher_geog#; #detail.spec_locality#">
	<cf_customizeHeader collection_id=#detail.collection_id#>
	<cfif (detail.verbatim_date is detail.began_date) AND (detail.verbatim_date is detail.ended_date)>
		<cfset thisDate = detail.verbatim_date>
	<cfelseif (
			(detail.verbatim_date is not detail.began_date) OR
	 		(detail.verbatim_date is not detail.ended_date)
		)
		AND
		detail.began_date is detail.ended_date>
		<cfset thisDate = "#detail.verbatim_date# (#detail.began_date#)">
	<cfelse>
		<cfset thisDate = "#detail.verbatim_date# (#detail.began_date# - #detail.ended_date#)">
	</cfif>
	<table width="100%" cellspacing="0" cellpadding="0">
		<tr>
			<td valign="top">
				<table cellspacing="0" cellpadding="0">
					<tr>
						<td nowrap valign="top">
							<div id="SDCollCatBlk">
								<span id="SDheaderCollCatNum">
									#detail.guid#
								</span>
								<cfif len(session.CustomOtherIdentifier) gt 0>
									<div id="SDheaderCustID">
										#session.CustomOtherIdentifier#: #detail.CustomID#
									</div>
								</cfif>
								<cfset sciname = '#replace(detail.Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
								<div id="SDheaderSciName">
									#sciname#
								</div>
								<div id="SDheaderGoBakBtn">
									<cfif isdefined("session.mapURL") and len(session.mapURL) gt 0>
										<a href="/SpecimenResults.cfm?#session.mapURL#"><< Return&nbsp;to&nbsp;results</a>
									</cfif>
								</div>
								<cfif len(doi.doi) gt 0>
									doi:#doi.doi#
								<cfelse>
									<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
										<a href="/tools/doi.cfm?collection_object_id=#collection_object_id#">get a DOI</a>
									</cfif>
								</cfif>
							</div>
						</td>
					</tr>
				</table>
			</td>
		    <td valign="top">
		    	<table cellspacing="0" cellpadding="0">
					<tr>
						<td valign="top">
							<div id="SDheaderSpecLoc">
								#detail.spec_locality#
							</div>
							<div id="SDheaderGeog">
								#detail.higher_geog#
							</div>
							<div id="SDheaderDate">
								#thisDate#
							</div>
						</td>
					</tr>
				</table>
			</td>
			<td valign="top">
				<div id="SDheaderPart">
					#detail.partString#
				</div>
			</td>
			<!----
			<td valign="top" align="right">
				<div id="SDheaderMap">
				 <cfif (len(detail.dec_lat) gt 0 and len(detail.dec_long) gt 0)>

					<div id="mapgohere-collection_object_id-#detail.collection_object_id#"></div>
					<!---
					<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
						<cfinvokeargument name="collection_object_id" value="#detail.collection_object_id#">
						<cfinvokeargument name="size" value="150x150">
						<cfinvokeargument name="showCaption" value="false">
					</cfinvoke>
					#contents#
					----->
				</cfif>
				</div>
			</td>
			---->
		    <td valign="top" align="right">
		        <div id="annotateSpace">
					<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select count(*) cnt from annotations
						where collection_object_id = #detail.collection_object_id#
					</cfquery>
					<span class="likeLink" onclick="openAnnotation('collection_object_id=#detail.collection_object_id#')">
						[&nbsp;Report&nbsp;Bad&nbsp;Data&nbsp;]
					</span>
					<cfif existingAnnotations.cnt gt 0>
						<br>(#existingAnnotations.cnt#&nbsp;annotations)
					</cfif>
					<cfif len(detail.web_link) gt 0>
						<cfif len(detail.web_link_text) gt 0>
							<cfset cLink=detail.web_link_text>
						<cfelse>
							<cfset cLink="collection">
						</cfif>
						<br><a href="#detail.web_link#" target="_blank" class="external">#cLink#</a>
					</cfif>
					<cfif isdefined("session.collObjIdList") and len(session.collObjIdList) gt 0 and listcontains(session.collObjIdList,detail.collection_object_id)>
						<cfset isPrev = "no">
						<cfset isNext = "no">
						<cfset currPos = 0>
						<cfset lenOfIdList = 0>
						<cfset firstID = collection_object_id>
						<cfset nextID = collection_object_id>
						<cfset prevID = collection_object_id>
						<cfset lastID = collection_object_id>
						<cfset currPos = listfind(session.collObjIdList,collection_object_id)>
						<cfset lenOfIdList = listlen(session.collObjIdList)>
						<cfset firstID = listGetAt(session.collObjIdList,1)>
						<cfif currPos lt lenOfIdList>
							<cfset nextID = listGetAt(session.collObjIdList,currPos + 1)>
						</cfif>
						<cfif currPos gt 1>
							<cfset prevID = listGetAt(session.collObjIdList,currPos - 1)>
						</cfif>
						<cfset lastID = listGetAt(session.collObjIdList,lenOfIdList)>
						<cfif lenOfIdList gt 1>
							<cfif currPos gt 1>
								<cfset isPrev = "yes">
							</cfif>
							<cfif currPos lt lenOfIdList>
								<cfset isNext = "yes">
							</cfif>
						</cfif>
						<div id="navSpace">
							<table width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<cfif isPrev is "yes">
										<th>
											<span onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#firstID#'">first</span>
										</th>
										<th>
											<span onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#prevID#'">prev</span>
										</th>
									<cfelse>
										<th>first</th>
										<th>prev</th>
									</cfif>
									<cfif isNext is "yes">
										<th>
											<span onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#nextID#'">next</span>
										</th>
										<th>
											<span onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#lastID#'">last</span>
										</th>
									<cfelse>
										<th>next</th>
										<th>last</th>
									</cfif>
								</tr>
								<tr>
								<cfif isPrev is "yes">
									<td align="middle">
										<img src="/images/first.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#firstID#'" alt="[ First Record ]">
									</td>
									<td align="middle">
									<img src="/images/previous.gif" class="likeLink"  onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#prevID#'" alt="[ Previous Record ]">
								</td>
								<cfelse>
									<td align="middle">
										<img src="/images/no_first.gif" alt="[ inactive button ]">
									</td>
									<td align="middle">
										<img src="/images/no_previous.gif" alt="[ inactive button ]">
									</td>
								</cfif>
								<cfif isNext is "yes">
									<td align="middle">
										<img src="/images/next.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#nextID#'" alt="[ Next Record ]">
									</td>
									<td align="middle">
										<img src="/images/last.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#lastID#'" alt="[ Last Record ]">
									</td>
								<cfelse>
									<td align="middle">
										<img src="/images/no_next.gif" alt="[ inactive button ]">
									</td>
									<td align="middle">
										<img src="/images/no_last.gif" alt="[ inactive button ]">
									</td>
								</cfif>
								</tr>
								<tr>
									<cfset lp=1>
									<td>Record</td>
									<td colspan="2">
										<select id="recpager" onchange="document.location='/SpecimenDetail.cfm?collection_object_id='+this.value">
											<cfloop list="#session.collObjIdList#" index="ccid">
												<option <cfif currPos is lp>selected="selected"</cfif>	value="#ccid#">#lp#</option>
												<cfset lp=lp+1>
											</cfloop>
										</select>
									</td>
									<td>of #listlen(session.collObjIdList)#</td>
								</tr>
							</table>
						</div>
					</cfif>
				 </div>
            </td>
        </tr>
    </table>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<script language="javascript" type="text/javascript">
			function closeEditApp() {
				$('##bgDiv').remove();
				$('##bgDiv', window.parent.document).remove();
				$('##popDiv').remove();
				$('##popDiv', window.parent.document).remove();
				$('##cDiv').remove();
				$('##cDiv', window.parent.document).remove();
				$('##theFrame').remove();
				$('##theFrame', window.parent.document).remove();
				$("span[id^='BTN_']").each(function(){
					$("##" + this.id).removeClass('activeButton');
					$('##' + this.id, window.parent.document).removeClass('activeButton');
				});
			}
			function loadEditApp(q) {
				closeEditApp();
				if (q=='media'){
					 addMedia('collection_object_id','#collection_object_id#');
				} else {
					var bgDiv = document.createElement('div');
					bgDiv.id = 'bgDiv';
					bgDiv.className = 'bgDiv';
					bgDiv.setAttribute('onclick','closeEditApp()');
					document.body.appendChild(bgDiv);
					var popDiv=document.createElement('div');
					popDiv.id = 'popDiv';
					popDiv.className = 'editAppBox';
					document.body.appendChild(popDiv);
					var links='<ul id="navbar">';
					links+='<li><span onclick="loadEditApp(\'editIdentification\')" class="likeLink" id="BTN_editIdentification">Identification</span></li>';
					links+='<li><span onclick="loadEditApp(\'addAccn\')" class="likeLink" id="BTN_addAccn">Accession</span></li>';
					links+='<li><span onclick="loadEditApp(\'specLocality\')" class="likeLink" id="BTN_specLocality">Locality</span></li>';
					links+='<li><span onclick="loadEditApp(\'editColls\')" class="likeLink" id="BTN_editColls">Agent</span></li>';
					links+='<li><span onclick="loadEditApp(\'editParts\')" class="likeLink" id="BTN_editParts">Parts</span></li>';
					links+='<li><span onclick="loadEditApp(\'findContainer\')" class="likeLink" id="BTN_findContainer">Part Location</span></li>';
					links+='<li><span onclick="loadEditApp(\'editBiolIndiv\')" class="likeLink" id="BTN_editBiolIndiv">Attributes</span></li>';
					links+='<li><span onclick="loadEditApp(\'editIdentifiers\')" class="likeLink" id="BTN_editIdentifiers">Other IDs</span></li>';
					links+='<li><span onclick="loadEditApp(\'media\');" class="likeLink" id="BTN_MediaSearch">Media</span></li>';
					links+='<li><span onclick="loadEditApp(\'Encumbrances\')" class="likeLink" id="BTN_Encumbrances">Encumbrance</span></li>';
					//links+='<li><span onclick="loadEditApp(\'catalog\')" class="likeLink" id="BTN_catalog">Catalog</span></li>';
					links+="</ul>";
					$("##popDiv").append(links);
					var cDiv=document.createElement('div');
					cDiv.className = 'fancybox-close';
					cDiv.id='cDiv';
					cDiv.setAttribute('onclick','closeEditApp()');
					$("##popDiv").append(cDiv);
					$("##popDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
					var theFrame = document.createElement('iFrame');
					theFrame.id='theFrame';
					theFrame.className = 'editFrame';
					var ptl="/" + q + ".cfm?collection_object_id=" + #collection_object_id#;
					theFrame.src=ptl;
					//document.body.appendChild(theFrame);
					$("##popDiv").append(theFrame);
					$("span[id^='BTN_']").each(function(){
						$("##" + this.id).removeClass('activeButton');
						$('##' + this.id, window.parent.document).removeClass('activeButton');
					});
					$("##BTN_" + q).addClass('activeButton');
					$('##BTN_' + q, window.parent.document).addClass('activeButton');
				}
			}
		</script>
		 <table width="100%">
		    <tr>
			    <td align="center">
					<form name="incPg" method="post" action="SpecimenDetail.cfm">
				        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
						<input type="hidden" name="suppressHeader" value="true">
						<input type="hidden" name="action" value="nothing">
						<input type="hidden" name="Srch" value="Part">
						<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">

						<ul id="navbar">
							<li><span onclick="loadEditApp('editIdentification')" class="likeLink" id="BTN_editIdentification">Identification</span></li>
							<li>
								<span onclick="loadEditApp('addAccn')"	class="likeLink" id="BTN_addAccn">Accn</span>
							</li>
							<li>
								<span onclick="loadEditApp('specLocality')" class="likeLink" id="BTN_specLocality">Locality</span>
							</li>
							<li>
								<span onclick="loadEditApp('editColls')" class="likeLink" id="BTN_editColls">Agents</span>
							</li>
							<li>
								<span onclick="loadEditApp('editParts')" class="likeLink" id="BTN_editParts">Parts</span>
							</li>
							<li>
								<span onclick="loadEditApp('findContainer')" class="likeLink" id="BTN_findContainer">Part Locn.</span>
							</li>
							<li>
								<span onclick="loadEditApp('editBiolIndiv')" class="likeLink" id="BTN_editBiolIndiv">Attributes</span>
							</li>
							<li>
								<span onclick="loadEditApp('editIdentifiers')"	class="likeLink" id="BTN_editIdentifiers">Other IDs</span>
							</li>
							<li>
								<span onclick="loadEditApp('media')" class="likeLink" id="BTN_MediaSearch">Media</span>
							</li>
							<li>
								<span onclick="loadEditApp('Encumbrances')" class="likeLink" id="BTN_Encumbrances">Encumbrances</span>
							</li>
							<!----
							<li>
								<span onclick="loadEditApp('catalog')" class="likeLink" id="BTN_catalog">Catalog</span>
							</li>
							---->
						</ul>
	                </form>
		        </td>
		    </tr>
		</table>
	</cfif>
	<cfinclude template="SpecimenDetail_body.cfm">
	<cfinclude template="/includes/_footer.cfm">
	<cfif isdefined("showAnnotation") and showAnnotation is "true">
		<script language="javascript" type="text/javascript">
			openAnnotation('collection_object_id=#collection_object_id#');
		</script>
	</cfif>
</cfoutput>
<cfcatch>
	<cf_logError subject="SpecimenDetail error" attributeCollection=#cfcatch#>

	<cfdump var=#cfcatch#>
	<div class="error">
		Oh no! Part of this page has failed to load!
		<br>This error has been logged. Please <a href="/contact.cfm?ref=specimendetail">contact us</a> with any useful information.
	</div>
</cfcatch>
</cftry>