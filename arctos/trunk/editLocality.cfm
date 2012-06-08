<cfinclude template="includes/_header.cfm">
<cfoutput>
	<script>
		function useGL(glat,glon,gerr){
			$("##MAX_ERROR_DISTANCE").val(gerr);
			$("##MAX_ERROR_UNITS").val('m');
			$("##DATUM").val('World Geodetic System 1984');
			$("##georeference_source").val('GeoLocate');
			$("##georeference_protocol").val('GeoLocate');
			$("##dec_lat").val(glat);
			$("##dec_long").val(glon);
			closeGeoLocate();
		}
	</script>
</cfoutput>
					
<cfif action is "nothing">
<cfset title="Edit Locality">
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);			
		});
	    $.each($("input[id^='geo_att_determined_date_']"), function() {
			$("#" + this.id).datepicker();
	    });
	    if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
	});
	function geolocate() {
		alert('This opens a map. There is a help link at the top. Use it. The save button will create a new determination.');
		var guri='http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?georef=run';
		guri+="&state=" + $("#state_prov").val();
		guri+="&country="+$("#country").val();
		guri+="&county="+$("#county").val().replace(" County", "");
		guri+="&locality="+$("#spec_locality").val();
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		document.body.appendChild(bgDiv);
		var popDiv=document.createElement('div');
		popDiv.id = 'popDiv';
		popDiv.className = 'editAppBox';
		document.body.appendChild(popDiv);	
		var cDiv=document.createElement('div');
		cDiv.className = 'fancybox-close';
		cDiv.id='cDiv';
		cDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		$("#popDiv").append(cDiv);
		var hDiv=document.createElement('div');
		hDiv.className = 'fancybox-help';
		hDiv.id='hDiv';
		hDiv.innerHTML='<a href="https://arctosdb.wordpress.com/how-to/create/data-entry/geolocate/" target="blank">[ help ]</a>';
		$("#popDiv").append(hDiv);
		$("#popDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
		var theFrame = document.createElement('iFrame');
		theFrame.id='theFrame';
		theFrame.className = 'editFrame';
		theFrame.src=guri;
		$("#popDiv").append(theFrame);
	}
	function getGeolocate(evt) {
		var message;
		if (evt.origin !== "http://www.museum.tulane.edu") {
	    	alert( "iframe url does not have permision to interact with me" );
	        closeGeoLocate('intruder alert');
	    }
	    else {
	    	var breakdown = evt.data.split("|");
			if (breakdown.length == 4) {
			    var glat=breakdown[0];
			    var glon=breakdown[1];
			    var gerr=breakdown[2];
			    useGL(glat,glon,gerr)
			} else {
				alert( "Whoa - that's not supposed to happen. " +  breakdown.length);
				closeGeoLocate('ERROR - breakdown length');
	 		}
	    }
	}
	function closeGeoLocate(msg) {
		$('#bgDiv').remove();
		$('#bgDiv', window.parent.document).remove();
		$('#popDiv').remove();
		$('#popDiv', window.parent.document).remove();
		$('#cDiv').remove();
		$('#cDiv', window.parent.document).remove();
		$('#theFrame').remove();
		$('#theFrame', window.parent.document).remove();
	}
	function populateGeology(id) {
		if (id=='geology_attribute') {
			var idNum='';
			var thisValue=$("#geology_attribute").val();
			var dataValue=$("#geo_att_value").val();
			var theSelect="geo_att_value";
		} else {
			var idNum=id.replace('geology_attribute_','');
			var thisValue=$("#geology_attribute_" + idNum).val();;
			var dataValue=$("#geo_att_value_" + idNum).val();
			var theSelect="geo_att_value_";
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeologyValues",
				attribute : thisValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				var s='';
				for (i=0; i<r.ROWCOUNT; ++i) {
					s+='<option value="' + r.DATA.ATTRIBUTE_VALUE[i] + '"';
					if (r.DATA.ATTRIBUTE_VALUE[i]==dataValue) {
						s+=' selected="selected"';
					}
					s+='>' + r.DATA.ATTRIBUTE_VALUE[i] + '</option>';
				}
				$("select#" + theSelect + idNum).html(s);
			}
		);
	}	

	function cloneLocality(locality_id) {
		if(confirm('Are you sure you want to create a copy of this locality which you may then edit?')) {
			var rurl='editLocality.cfm?action=clone&locality_id=' + locality_id;
			document.location=rurl;
		}
	}
</script>
<cfoutput> 
	<cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select 
			locality.locality_id,
			geog_auth_rec.GEOG_AUTH_REC_ID,
			higher_geog,
			state_prov,
			county,
			country,
			spec_locality,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			LOCALITY_REMARKS,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			DEC_LAT,
			DEC_LONG,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			DATUm,
			georeference_source,
			georeference_protocol,
			locality_name
		from 
			locality, 
			geog_auth_rec 
		where 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and 
			locality.locality_id=#locality_id# 
	</cfquery>
	<cfif locDet.recordcount is not 1>
		<div class="error">locality not found</div><cfabort>
	</cfif>
	<cfquery name="geolDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select 
			*
		from 
			geology_attributes,
			preferred_agent_name
		where 
			geology_attributes.geo_att_determiner_id = preferred_agent_name.agent_id (+) and
			geology_attributes.locality_id=#locality_id# 
	</cfquery>
	<cfquery name="whatSpecs" datasource="uam_god">
  		SELECT 
			count(cataloged_item.cat_num) numOfSpecs, 
			collection.collection,
			collection.collection_id
		from 
			cataloged_item, 
			collection,
			specimen_event,
			collecting_event 
		WHERE
			cataloged_item.collection_object_id = specimen_event.collection_object_id and
			specimen_event.collecting_event_id = collecting_event.collecting_event_id and
			cataloged_item.collection_id = collection.collection_id and
			collecting_event.locality_id=#locality_id# 
		GROUP BY 
			collection.collection,
			collection.collection_id
  	</cfquery>
     <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select datum from ctdatum order by datum
     </cfquery>
	<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select orig_elev_units from ctorig_elev_units order by orig_elev_units
	</cfquery>
	<cfquery name="ctDepthUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select depth_units from ctdepth_units order by depth_units
	</cfquery>
    <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by LAT_LONG_ERROR_UNITS
     </cfquery>
     <cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select georeference_protocol from ctgeoreference_protocol order by georeference_protocol 
	</cfquery>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select geology_attribute from ctgeology_attribute order by geology_attribute
     </cfquery>
	
	<cfquery name="whatMedia" datasource="uam_god">
  		SELECT 
			media_id
		from 
			media_relations 
		WHERE
			 media_relationship like '% locality' and 
			 related_primary_key=#locality_id# 
		GROUP BY 
			media_id
	</cfquery>
    <span style="margin:1em;display:inline-block;padding:1em;border:10px solid red;">
		This locality (#locality_id#) contains
		<cfif whatSpecs.recordcount is 0 and whatMedia.recordcount is 0>
 			nothing. Please delete it if you don't have plans for it and there are no used Events.
 		<cfelse>
			<ul>
				<cfloop query="whatSpecs">
					<li><a href="SpecimenResults.cfm?collection_id=#collection_id#&locality_id=#locality_id#">#numOfSpecs# #collection# specimens</a></li>
				</cfloop>
				<cfif whatMedia.recordcount gt 0>
					<li>
						<a href="MediaSearch.cfm?action=search&media_id=#valuelist(whatMedia.media_id)#">#whatMedia.recordcount# Media records</a>
					</li>
				</cfif>
			</ul>
		</cfif>	
	</span>
	<br>
  
	<span style="margin:1em;display:inline-block;padding:1em;border:3px solid black;">
	<table width="100%"><tr><td valign="top">
	<p><strong>Locality</strong></p>
	<form name="locality" method="post" action="editLocality.cfm">
        <input type="hidden" id="state_prov" name="state_prov" value="#locDet.state_prov#">
        <input type="hidden" id="country" name="country" value="#locDet.country#">
        <input type="hidden" id="county" name="county" value="#locDet.county#">
		<input type="hidden" name="action" value="saveLocalityEdit">
        <input type="hidden" name="locality_id" value="#locDet.locality_id#">
        <input type="hidden" name="geog_auth_rec_id" value="#locDet.geog_auth_rec_id#">
       	<label for="higher_geog">Higer Geography</label>
		<input type="text" name="higher_geog" id="higher_geog" value="#locDet.higher_geog#" size="120" class="readClr" readonly="yes">
        <input type="button" value="Change" class="picBtn" id="changeGeogButton"
			onclick="GeogPick('geog_auth_rec_id','higher_geog','locality'); return false;">
		<input type="button" value="Edit" class="lnkBtn"
			onClick="document.location='Locality.cfm?action=editGeog&geog_auth_rec_id=#locDet.geog_auth_rec_id#'">
		<label for="spec_locality" class="likeLink" onClick="getDocs('locality','specific_locality')">
			Specific Locality
		</label>
		<input type="text"id="spec_locality" name="spec_locality" value="#stripQuotes(locDet.spec_locality)#" size="120">
		<label for="locality_name" class="likeLink" onClick="getDocs('locality','locality_name')">
			Locality Name
		</label>
		<input type="text"id="locality_name" name="locality_name" value="#stripQuotes(locDet.locality_name)#" size="120">
		<table>
			<tr>
				<td>
					<label for="minimum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Min. Elev.
					</label>
					<input type="text" name="minimum_elevation" id="minimum_elevation" value="#locDet.minimum_elevation#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="maximum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Max. Elev.
					</label>
					<input type="text" name="maximum_elevation" id="maximum_elevation" value="#locDet.maximum_elevation#" size="3">
				</td>
				<td>
					<label for="orig_elev_units" onClick="getDocs('locality','elevation')" class="likeLink">
						Elev. Unit
					</label>
					<select name="orig_elev_units" size="1" id="orig_elev_units">
						<option value=""></option>
	                    <cfloop query="ctElevUnit">
	                    	<option <cfif ctelevunit.orig_elev_units is locdet.orig_elev_units> selected="selected" </cfif>value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<label for="min_depth" onClick="getDocs('locality','depth')" class="likeLink">
						Min. Depth.
					</label>
					<input type="text" name="min_depth" id="min_depth" value="#locDet.min_depth#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="max_depth" class="likeLink" onClick="getDocs('locality','depth')">
						Max. Depth.
					</label>
					<input type="text" name="max_depth"  id="max_depth" value="#locDet.max_depth#" size="3">
				</td>
				<td>
					<label for="depth_units" class="likeLink" onClick="getDocs('locality','depth')">
						Depth Unit
					</label>
					<select name="depth_units" size="1" id="depth_units">
						<option value=""></option>
	                    <cfloop query="ctDepthUnit">
	                    	<option <cfif ctDepthUnit.depth_units is locdet.depth_units> selected="selected" </cfif>value="#ctDepthUnit.depth_units#">#ctDepthUnit.depth_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<label for="locality_remarks">Locality Remarks</label>
		<input type="text" name="locality_remarks" id="locality_remarks" value="#stripQuotes(locDet.locality_remarks)#"  size="120">
		<table>
			<tr>
				<td>
					<label for="dec_lat">Decimal Latitude</label>
					<input type="text" name="DEC_LAT" id="dec_lat" value="#locDet.DEC_LAT#" class="">
				</td>
				<td>
					<label for="dec_long">Decimal Longitude</label>
					<input type="text" name="DEC_LONG" value="#locDet.DEC_LONG#" id="dec_long" class="">
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<label for="MAX_ERROR_DISTANCE" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Max Error</label>
					<input type="text" name="MAX_ERROR_DISTANCE" id="MAX_ERROR_DISTANCE" value="#locDet.MAX_ERROR_DISTANCE#" size="6">
				</td>
				<td>
					<label for="MAX_ERROR_UNITS" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Max Error Units</label>
					<select name="MAX_ERROR_UNITS" size="1" id="MAX_ERROR_UNITS">
						<option value=""></option>
						<cfloop query="cterror">
							<option <cfif cterror.LAT_LONG_ERROR_UNITS is locDet.MAX_ERROR_UNITS> selected="selected" </cfif>
								value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
						</cfloop>
					</select> 
				</td>
			</tr>
		</table>
		<label for="DATUM" class="likeLink" onClick="getDocs('lat_long','datum')">Datum</label>
		<select name="DATUM" id="DATUM" size="1" class="reqdClr">
			<option value=''></option>
			<cfloop query="ctdatum">
				<option <cfif ctdatum.DATUM is locDet.DATUM> selected="selected" </cfif> value="#ctdatum.DATUM#">#ctdatum.DATUM#</option>
			</cfloop>
		</select> 
		<label for="georeference_source" class="likeLink" onClick="getDocs('lat_long','georeference_source')">georeference_source</label>
		<input type="text" name="georeference_source" id="georeference_source" size="120" class="reqdClr" value='#preservesinglequotes(locDet.georeference_source)#' />
		<label for="georeference_protocol" class="likeLink" onClick="getDocs('lat_long','georeference_protocol')">Georeference Protocol</label>
		<select name="georeference_protocol" id="georeference_protocol" size="1" class="reqdClr">
			<option value=''></option>
			<cfloop query="ctgeoreference_protocol">
				<option 
					<cfif locDet.georeference_protocol is ctgeoreference_protocol.georeference_protocol> selected="selected" </cfif>
					value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
			</cfloop>
		</select>
		<br>	   
		<input type="button" value="Save" class="savBtn" onclick="locality.action.value='saveLocalityEdit';locality.submit();">
		<input type="button" value="Delete" class="delBtn" onClick="locality.action.value='deleteLocality';confirmDelete('locality');">
		<input type="button" value="Clone Locality" class="insBtn" onClick="cloneLocality(#locality_id#)">
		<input type="button" value="Add Collecting Event" class="insBtn" 
			onclick="document.location='Locality.cfm?action=newCollEvent&locality_id=#locDet.locality_id#'">
		<input type="button" value="GeoLocate" class="insBtn" onClick="geolocate();">
	</form>
	</td><td valign="top">
		<cfif len(locDet.dec_lat) gt 0>
			<cfset iu="http://maps.google.com/maps/api/staticmap?center=#locDet.dec_lat#,#locDet.dec_long#">
			<cfset iu=iu & "&markers=color:red|size:tiny|#locDet.dec_lat#,#locDet.dec_long#&sensor=false&size=200x200&zoom=2">
			<cfset iu=iu & "&maptype=roadmap">
			<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#locality_id#" target="_blank"><img src="#iu#" alt="Google Map"></a>
		</cfif>
		<ul>
			<li><a href="Locality.cfm?action=findCollEvent&locality_id=#locDet.locality_id#" target="_blank">[ Find all Collecting Events ]</a></li>
			<li><a href="http://bg.berkeley.edu/latest/" target="_blank" class="external">BioGeoMancer</a></li>
			<li><a href="http://manisnet.org/gci2.html" target="_blank" class="external">Georef Calculator</a></li>
			<li><span class="likeLink" onClick="getDocs('lat_long')">lat_long Help</span></li>
		</ul>
	</td></tr></table>
	</span>
	<hr>
	<strong>Geology Attributes</strong>	
	<cfif geolDet.recordcount gt 0>
		<form name="editGeolAtt" method="post" action="editLocality.cfm">
			<input type="hidden" name="action" value="editGeol">
           	<input type="hidden" name="locality_id" value="#locDet.locality_id#">
			<input type="hidden" name="number_of_determinations" value="#geolDet.recordcount#">
			<cfset i=1>
			<table border>
				<cfloop query="geolDet">
					<input type="hidden" name="geology_attribute_id_#i#" value="#geology_attribute_id#">
					<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td>
							<label for="geology_attribute_#i#">Geology Attribute</label>
							<select name="geology_attribute_#i#" id="geology_attribute_#i#" class="reqdClr" onchange="populateGeology(this.id)">
								<option value="delete" class="red">Delete This</option>
								<cfloop query="ctgeology_attribute">
									<option <cfif #geology_attribute# is geolDet.geology_attribute> selected="selected" </cfif>value="#geology_attribute#">#geology_attribute#</option>
								</cfloop>
							</select>
							<span class="infoLink" onclick="document.getElementById('geology_attribute_#i#').value='delete'">Delete This</span>	
							<label for="geo_att_value">Value</label>
							<select name="geo_att_value_#i#" id="geo_att_value_#i#" class="reqdClr">
								<option value="#geo_att_value#">#geo_att_value#</option>
							</select>
							<label for="geo_att_determiner_#i#">Determiner</label>
							<input type="text" name="geo_att_determiner_#i#"  size="40"
								onchange="getAgent('geo_att_determiner_id_#i#','geo_att_determiner_#i#','editGeolAtt',this.value); return false;"
			 					onKeyPress="return noenter(event);"
			 					value="#agent_name#">
							<input type="hidden" name="geo_att_determiner_id_#i#" id="geo_att_determiner_id" value="#geo_att_determiner_id#">
							<label for="geo_att_determined_date_#i#">Date</label>
							<input type="text" name="geo_att_determined_date_#i#" id="geo_att_determined_date_#i#" value="#dateformat(geo_att_determined_date,'yyyy-mm-dd')#">
							<label for="geo_att_determined_method_#i#">Method</label>
							<input type="text" name="geo_att_determined_method_#i#" size="60"  value="#geo_att_determined_method#">
							<label for="geo_att_remark_#i#">Remark</label>
							<input type="text" name="geo_att_remark_#i#" size="60" value="#geo_att_remark#">
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<tr>
					<td colspan="2">
						<input type="submit" value="Save Changes"  class="savBtn">
					</td>
				</tr>
			</table>
		</form>
	</cfif>
	<table class="newRec">
		<tr>
			<td>
				<strong>Create Geology Determination</strong>
				<form name="newGeolDet" method="post" action="editLocality.cfm">
		            <input type="hidden" name="action" value="AddGeol">
		            <input type="hidden" name="locality_id" value="#locDet.locality_id#">
					<label for="geology_attribute">Geology Attribute</label>
					<select name="geology_attribute" id="geology_attribute" class="reqdClr" onchange="populateGeology(this.id)">
						<option value=""></option>
						<cfloop query="ctgeology_attribute">
							<option value="#geology_attribute#">#geology_attribute#</option>
						</cfloop>
					</select>
					<label for="geo_att_value">Value</label>
					<select name="geo_att_value" id="geo_att_value" class="reqdClr"></select>
					<label for="geo_att_determiner">Determiner</label>
					<input type="text" name="geo_att_determiner" id="geo_att_determiner" size="40"
						onchange="getAgent('geo_att_determiner_id','geo_att_determiner','newGeolDet',this.value); return false;"
				 		onKeyPress="return noenter(event);">
					<input type="hidden" name="geo_att_determiner_id" id="geo_att_determiner_id">
					<label for="geo_att_determined_date">Determined Date</label>
					<input type="text" name="geo_att_determined_date" id="geo_att_determined_date">
					<label for="geo_att_determined_method">Determination Method</label>
					<input type="text" name="geo_att_determined_method" id="geo_att_determined_method" size="60">
					<label for="geo_att_remark">Remark</label>
					<input type="text" name="geo_att_remark" id="geo_att_remark" size="60">
					<br>
					<input type="submit" value="Create Determination" class="insBtn">
				</form>
			</td>
		</tr>
	</table>
</cfoutput> 
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "editGeol">
<cfoutput>
	<cfloop from="1" to="#number_of_determinations#" index="n">
		<cfset deleteThis="">
		<cfset thisID = #evaluate("geology_attribute_id_" & n)#>
		<cfset thisAttribute = #evaluate("geology_attribute_" & n)#>
		<cfset thisValue = #evaluate("geo_att_value_" & n)#>
		<cfset thisDate = #evaluate("geo_att_determined_date_" & n)#>
		<cfset thisMethod = #evaluate("geo_att_determined_method_" & n)#>
		<cfset thisDeterminer = #evaluate("geo_att_determiner_id_" & n)#>
		<cfset thisRemark = #evaluate("geo_att_remark_" & n)#>
		
		<cfif #thisAttribute# is "delete">
			<cfquery name="deleteGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from geology_attributes where geology_attribute_id=#thisID#
			</cfquery>
		<cfelse>
			<cfquery name="upGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update 
					geology_attributes 
				set 
					geology_attribute='#thisAttribute#',
					geo_att_value='#stripQuotes(thisValue)#'
					<cfif len(#thisDeterminer#) gt 0>
						,geo_att_determiner_id=#thisDeterminer#
					<cfelse>
						,geo_att_determiner_id=NULL
					</cfif>
					<cfif len(#thisDate#) gt 0>
						,geo_att_determined_date='#dateformat(thisDate,"yyyy-mm-dd")#'
					<cfelse>
						,geo_att_determined_date=NULL
					</cfif>
					<cfif len(#thisMethod#) gt 0>
						,geo_att_determined_method='#stripQuotes(thisMethod)#'
					<cfelse>
						,geo_att_determined_method=NULL
					</cfif>
					<cfif len(#thisRemark#) gt 0>
						,geo_att_remark='#stripQuotes(thisRemark)#'
					<cfelse>
						,geo_att_remark=NULL
					</cfif>
				where
					geology_attribute_id=#thisID#
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "AddGeol">
<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into geology_attributes (
    			locality_id,
			    geology_attribute,
			    geo_att_value
			    <cfif len(#geo_att_determiner_id#) gt 0>
					,geo_att_determiner_id
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,geo_att_determined_date
				</cfif>
			   	<cfif len(#geo_att_determined_method#) gt 0>
					,geo_att_determined_method
				</cfif>
			   	<cfif len(#geo_att_remark#) gt 0>
					,geo_att_remark
				</cfif>			    
			   ) values (
			   #locality_id#,
			   '#geology_attribute#',
			   '#stripQuotes(geo_att_value)#'
			   <cfif len(#geo_att_determiner_id#) gt 0>
					,#geo_att_determiner_id#
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,'#dateformat(geo_att_determined_date,"yyyy-mm-dd")#'
				</cfif>
				<cfif len(#geo_att_determined_method#) gt 0>
					,'#stripQuotes(geo_att_determined_method)#'
				</cfif>
				<cfif len(#geo_att_remark#) gt 0>
					,'#stripQuotes(geo_att_remark)#'
				</cfif>
			 )
		</cfquery>
		<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveLocalityEdit">
	<cfoutput>

	<cfset sql = "UPDATE locality SET GEOG_AUTH_REC_ID = #GEOG_AUTH_REC_ID#">
	<cfset sql = "#sql#,MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#'">
	<cfset sql = "#sql#,DATUM = '#DATUM#'">
	<cfset sql = "#sql#,georeference_source = '#georeference_source#'">
	<cfset sql = "#sql#,georeference_protocol = '#georeference_protocol#'">
	<cfset sql = "#sql#,locality_name = '#locality_name#'">

	<cfif len(MAX_ERROR_DISTANCE) gt 0>
		<cfset sql = "#sql#,MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
	<cfelse>
		<cfset sql = "#sql#,MAX_ERROR_DISTANCE = null">
	</cfif>
	
	<cfif len(DEC_LAT) gt 0>
		<cfset sql = "#sql#,DEC_LAT = #DEC_LAT#">
	<cfelse>
		<cfset sql = "#sql#,DEC_LAT = null">
	</cfif>
	<cfif len(DEC_LONG) gt 0>
		<cfset sql = "#sql#,DEC_LONG = #DEC_LONG#">
	<cfelse>
		<cfset sql = "#sql#,DEC_LONG = null">
	</cfif>
	
	<cfif len(spec_locality) gt 0>
		<cfset sql = "#sql#,spec_locality = '#escapeQuotes(spec_locality)#'">
	  <cfelse>
		<cfset sql = ",spec_locality=null">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	<cfelse>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = null">
	</cfif>
	<cfif len(#min_depth#) gt 0>
		<cfset sql = "#sql#,min_depth = #min_depth#">
	<cfelse>
		<cfset sql = "#sql#,min_depth = null">
	</cfif>
	<cfif len(#max_depth#) gt 0>
		<cfset sql = "#sql#,max_depth = #max_depth#">
	<cfelse>
		<cfset sql = "#sql#,max_depth = null">
	</cfif>
	<cfif len(#depth_units#) gt 0>
		<cfset sql = "#sql#,depth_units = '#depth_units#'">
	<cfelse>
		<cfset sql = "#sql#,depth_units = null">
	</cfif>
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql = "#sql#,LOCALITY_REMARKS = '#escapeQuotes(LOCALITY_REMARKS)#'">
	<cfelse>
		<cfset sql = "#sql#,LOCALITY_REMARKS = null">
	</cfif>
	
	
	
	<cfset sql = "#sql# where locality_id = #locality_id#">
	<cfquery name="edLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#		
	</cfquery>
	<cflocation addtoken="no" url="editLocality.cfm?locality_id=#locality_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteLocality">
<cfoutput>
	<cfdump var=#form#>
	<cfquery name="isColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collecting_event_id from collecting_event where locality_id=#locality_id#
	</cfquery>
	<cfif len(isColl.collecting_event_id) gt 0>
		There are active collecting events for this locality. It cannot be deleted.
		<br><a href="editLocality.cfm?locality_id=#locality_id#">Return</a> to editing.
		<cfabort>
	</cfif>
	<cftransaction>
		<cfquery name="deleLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from locality where locality_id=#locality_id#
		</cfquery>
	</cftransaction>
	You deleted it.
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "clone">
	<cfoutput>
		<cftransaction>
			<cfquery name="nLocId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_locality_id.nextval nv from dual
			</cfquery>
			<cfset lid=nLocId.nv>
			<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO locality (
					LOCALITY_ID,
					GEOG_AUTH_REC_ID,
					MAXIMUM_ELEVATION,
					MINIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					SPEC_LOCALITY,
					LOCALITY_REMARKS,					
					DEPTH_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					DEC_LAT,
					DEC_LONG,
					MAX_ERROR_DISTANCE,
					MAX_ERROR_UNITS,
					DATUM,
					georeference_source,
					georeference_protocol,
					locality_name
				)  (
					select
						#lid#,
						GEOG_AUTH_REC_ID,
						MAXIMUM_ELEVATION,
						MINIMUM_ELEVATION,
						ORIG_ELEV_UNITS,
						SPEC_LOCALITY,
						LOCALITY_REMARKS,					
						DEPTH_UNITS,
						MIN_DEPTH,
						MAX_DEPTH,
						DEC_LAT,
						DEC_LONG,
						MAX_ERROR_DISTANCE,
						MAX_ERROR_UNITS,
						DATUM,
						georeference_source,
						georeference_protocol,
						DECODE(locality_name,NULL,NULL,'clone of ' || locality_name)
					from
						locality
					where
						locality_id=#locality_id#
				)
			</cfquery>		
		</cftransaction>
		<cflocation url="editLocality.cfm?locality_id=#lid#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "editAccLatLong">

<cfoutput>

<!--- update things that we're allowing changes to. Set non-original units to null and 
	get them once we have an Oracle procedure in place to handle conversions --->
<cftransaction>
<cfif ACCEPTED_LAT_LONG_FG is 1>
	<cfquery name="flagAllZero" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update lat_long set ACCEPTED_LAT_LONG_FG=0 where 
		locality_id = #locality_id#
	</cfquery>
</cfif>
<cfset sql = "
	UPDATE lat_long SET
		DATUM = '#DATUM#'
		,ACCEPTED_LAT_LONG_FG = #ACCEPTED_LAT_LONG_FG#	
		,orig_lat_long_units = '#orig_lat_long_units#'
		,determined_date = '#dateformat(determined_date,'yyyy-mm-dd')#'
		,lat_long_ref_source = '#stripQuotes(lat_long_ref_source)#'
		,determined_by_agent_id = #determined_by_agent_id#
		,georefMethod='#georefMethod#'
		,VerificationStatus='#VerificationStatus#'">
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
		  <cfelse>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE = NULL">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#'">
		  <cfelse>
			<cfset sql = "#sql#,MAX_ERROR_UNITS = NULL">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql = "#sql#,LAT_LONG_REMARKS = '#stripQuotes(LAT_LONG_REMARKS)#'">
		  <cfelse>
			<cfset sql = "#sql#,LAT_LONG_REMARKS = null">
		</cfif>
		<cfif len(#extent#) gt 0>
			<cfset sql = "#sql#,extent=#extent#">
		<cfelse>
			<cfset sql = "#sql#,extent=null">
		</cfif>
		<cfif len(#GpsAccuracy#) gt 0>
			<cfset sql = "#sql#,GpsAccuracy=#GpsAccuracy#">
		<cfelse>
			<cfset sql = "#sql#,GpsAccuracy=null">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset sql = "#sql#
				,LAT_DEG = #LAT_DEG#
				,LAT_MIN = #LAT_MIN#
				,LAT_SEC = #LAT_SEC#
				,LAT_DIR = '#LAT_DIR#'
				,LONG_DEG = #LONG_DEG#
				,LONG_MIN = #LONG_MIN#
				,LONG_SEC = #LONG_SEC#
				,LONG_DIR = '#LONG_DIR#'
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset sql = "#sql#
				,LAT_DEG = #dmLAT_DEG#
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = '#dmLAT_DIR#'
				,LONG_DEG = #dmLONG_DEG#
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = '#dmLONG_DIR#'
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null				
				,DEC_LAT_MIN = #DEC_LAT_MIN#
				,DEC_LONG_MIN = #DEC_LONG_MIN#
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset sql = "#sql#
				,LAT_DEG = null
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = null
				,LONG_DEG = null
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = null
				,DEC_LAT = #DEC_LAT#
				,DEC_LONG = #DEC_LONG#
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null				
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			<cfset sql = "#sql#
				,LAT_DEG = null
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = null
				,LONG_DEG = null
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = null
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = '#UTM_ZONE#'
				,UTM_EW = #UTM_EW#
				,UTM_NS = #UTM_NS#				
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null
				">
		<cfelse>
			<div class="error">
			You really can't load #ORIG_LAT_LONG_UNITS#. Really. I wouldn't lie to you! Clean up the code table!
			Use your back button or	
			<br><a href="editLocality.cfm?locality_id=#locality_id#">continue editing</a>.
			</div>
			<cfabort>
		</cfif>
		<cfset sql = "#sql#	where lat_long_id=#lat_long_id#">
<cfquery name="upLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>
</cftransaction>
<cfquery name="getAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select lat_long_id from lat_long where locality_id=#locality_id#
	and accepted_lat_long_fg = 1
</cfquery>
<cfif #getAcc.recordcount# is 1>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
<cfelseif #getAcc.recordcount# gt 1>
	<div class="error">
	There are more than one accepted lat_longs for this locality. Please change all but one
	of them to unaccepted. A better fix is coming soon.
	
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
	<cfabort>
<cfelseif #getAcc.recordcount# lt 1>
	<div class="error">
	There are no accepted lat_longs for this locality. Is that what you meant to do?
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
		<cfabort>
</cfif>
</cfoutput>		
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "AddLatLong">
<cfoutput>	
	<cfquery name="notAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE lat_long SET accepted_lat_long_fg = 0 where
		locality_id=#locality_id#
	</cfquery>	
	<cfset sql = "
	INSERT INTO lat_long (
		LAT_LONG_ID
		,LOCALITY_ID
		,ACCEPTED_LAT_LONG_FG
		,lat_long_ref_source
		,determined_by_agent_id
		,determined_date
		,ORIG_LAT_LONG_UNITS
		,georefmethod
		,verificationstatus
		,DATUM
		">
		<cfif len(#extent#) gt 0>
			<cfset sql = "#sql#,extent">
		</cfif>
		<cfif len(#gpsaccuracy#) gt 0>
			<cfset sql = "#sql#,gpsaccuracy">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql = "#sql#,LAT_LONG_REMARKS">
		</cfif>
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_UNITS">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset sql="#sql#
			,LAT_DEG
			,LAT_MIN
			,LAT_SEC
			,LAT_DIR
			,LONG_DEG
			,LONG_MIN
			,LONG_SEC
			,LONG_DIR">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset sql="#sql#
				,LAT_DEG
				,DEC_LAT_MIN
				,LAT_DIR
				,LONG_DEG
				,DEC_LONG_MIN
				,LONG_DIR
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset sql="#sql#
				,DEC_LAT
				,DEC_LONG">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			 <cfset sql="#sql#
			 	,UTM_ZONE
			 	,UTM_EW
			 	,UTM_NS">
		<cfelse>
			<div class="error">
			You really can't load #ORIG_LAT_LONG_UNITS#. Really. I wouldn't lie to you! Clean up the code table!
			Use your back button or	
			<br><a href="editLocality.cfm?locality_id=#locality_id#">continue editing</a>.
			</div>
			<cfabort>
		</cfif>
		<cfset sql="#sql#
		)
	VALUES (
		sq_lat_long_id.nextval,
		#LOCALITY_ID#
		,#ACCEPTED_LAT_LONG_FG#
		,'#stripQuotes(lat_long_ref_source)#'
		,#determined_by_agent_id#
		,'#dateformat(determined_date,'yyyy-mm-dd')#'
		,'#ORIG_LAT_LONG_UNITS#'
		,'#georefmethod#'
		,'#verificationstatus#'
		,'#DATUM#'">
		<cfif len(#extent#) gt 0>
			<cfset sql="#sql#,'#extent#'">
		</cfif>
		<cfif len(#gpsaccuracy#) gt 0>
			<cfset sql = "#sql#,#gpsaccuracy#">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql="#sql#,'#stripQuotes(LAT_LONG_REMARKS)#'">
		</cfif>
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql="#sql#,#MAX_ERROR_DISTANCE#">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql="#sql#,'#MAX_ERROR_UNITS#'">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
		<cfset sql="#sql#			
			,#LAT_DEG#
			,#LAT_MIN#
			,#LAT_SEC#
			,'#LAT_DIR#'
			,#LONG_DEG#
			,#LONG_MIN#
			,#LONG_SEC#
			,'#LONG_DIR#'">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
		<cfset sql="#sql#
			,#dmLAT_DEG#
			,#DEC_LAT_MIN#
			,'#dmLAT_DIR#'
			,#dmLONG_DEG#
			,#DEC_LONG_MIN#
			,'#dmLONG_DIR#'">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
		<cfset sql="#sql#
			,#DEC_LAT#
			,#DEC_LONG#">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			 <cfset sql="#sql#
			 	,'#UTM_ZONE#'
			 	,#UTM_EW#
			 	,#UTM_NS#">
		</cfif>
		<cfset sql="#sql# )">
	<cfquery name="newLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="getAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select lat_long_id from lat_long where locality_id=#locality_id#
		and accepted_lat_long_fg = 1
	</cfquery>
<cfif #getAcc.recordcount# is 1>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
<cfelseif #getAcc.recordcount# gt 1>
	<div class="error">
	There are more than one accepted lat_longs for this locality. Please change all but one
	of them to unaccepted. A better fix is coming soon.
	
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
	<cfabort>
<cfelseif #getAcc.recordcount# lt 1>
	<div class="error">
	There are no accepted lat_longs for this locality. Is that what you meant to do?
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
		<cfabort>
</cfif>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>		
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "deleteLatLong">
	<cfoutput>
		<cfif #ACCEPTED_LAT_LONG_FG# is "1">
			<div class="error">
			I can't delete the accepted lat/long!
			<cfabort>
			</div>
		</cfif>
		<cfquery name="killLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from lat_long where lat_long_id = #lat_long_id#
		</cfquery>
		
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->	  