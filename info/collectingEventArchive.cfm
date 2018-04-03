<cfinclude template="/includes/_header.cfm">
<cfset title="Collecting Event Archive">
<style>
	.nochange{border:3px solid green;}
	.haschange{border:3px solid red;}
	.original{
		border:2px solid black;
		font-weight:bold;
	}
</style>
<script>
	// see if we can pre-fetch media relevance
	$(document).ready(function() {
		$("#sdate").datepicker();
		$("#edate").datepicker();
		$.each($("[id^='m_l_d_']"), function() {
		    var mid=this.id;
		    var mds=mid.replace('m_l_d_','');
		    $.getJSON("/component/functions.cfc",
				{
					method : "getMediaLocalityCount",
					locid : mds,
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					$('a#' + mid).text('media (' + r + ')');
				}
			);
		});
	});
	// borowed from https://github.com/davidmerfield/randomColor
	(function(root,factory){if(typeof define==="function"&&define.amd){define([],factory)}else if(typeof exports==="object"){var randomColor=factory();if(typeof module==="object"&&module&&module.exports){exports=module.exports=randomColor}exports.randomColor=randomColor}else{root.randomColor=factory()}})(this,function(){var seed=null;var colorDictionary={};loadColorBounds();var randomColor=function(options){options=options||{};if(options.seed&&options.seed===parseInt(options.seed,10)){seed=options.seed}else if(typeof options.seed==="string"){seed=stringToInteger(options.seed)}else if(options.seed!==undefined&&options.seed!==null){throw new TypeError("The seed value must be an integer")}else{seed=null}var H,S,B;if(options.count!==null&&options.count!==undefined){var totalColors=options.count,colors=[];options.count=null;while(totalColors>colors.length){if(seed&&options.seed)options.seed+=1;colors.push(randomColor(options))}options.count=totalColors;return colors}H=pickHue(options);S=pickSaturation(H,options);B=pickBrightness(H,S,options);return setFormat([H,S,B],options)};function pickHue(options){var hueRange=getHueRange(options.hue),hue=randomWithin(hueRange);if(hue<0){hue=360+hue}return hue}function pickSaturation(hue,options){if(options.luminosity==="random"){return randomWithin([0,100])}if(options.hue==="monochrome"){return 0}var saturationRange=getSaturationRange(hue);var sMin=saturationRange[0],sMax=saturationRange[1];switch(options.luminosity){case"bright":sMin=55;break;case"dark":sMin=sMax-10;break;case"light":sMax=55;break}return randomWithin([sMin,sMax])}function pickBrightness(H,S,options){var bMin=getMinimumBrightness(H,S),bMax=100;switch(options.luminosity){case"dark":bMax=bMin+20;break;case"light":bMin=(bMax+bMin)/2;break;case"random":bMin=0;bMax=100;break}return randomWithin([bMin,bMax])}function setFormat(hsv,options){switch(options.format){case"hsvArray":return hsv;case"hslArray":return HSVtoHSL(hsv);case"hsl":var hsl=HSVtoHSL(hsv);return"hsl("+hsl[0]+", "+hsl[1]+"%, "+hsl[2]+"%)";case"hsla":var hslColor=HSVtoHSL(hsv);return"hsla("+hslColor[0]+", "+hslColor[1]+"%, "+hslColor[2]+"%, "+Math.random()+")";case"rgbArray":return HSVtoRGB(hsv);case"rgb":var rgb=HSVtoRGB(hsv);return"rgb("+rgb.join(", ")+")";case"rgba":var rgbColor=HSVtoRGB(hsv);return"rgba("+rgbColor.join(", ")+", "+Math.random()+")";default:return HSVtoHex(hsv)}}function getMinimumBrightness(H,S){var lowerBounds=getColorInfo(H).lowerBounds;for(var i=0;i<lowerBounds.length-1;i++){var s1=lowerBounds[i][0],v1=lowerBounds[i][1];var s2=lowerBounds[i+1][0],v2=lowerBounds[i+1][1];if(S>=s1&&S<=s2){var m=(v2-v1)/(s2-s1),b=v1-m*s1;return m*S+b}}return 0}function getHueRange(colorInput){if(typeof parseInt(colorInput)==="number"){var number=parseInt(colorInput);if(number<360&&number>0){return[number,number]}}if(typeof colorInput==="string"){if(colorDictionary[colorInput]){var color=colorDictionary[colorInput];if(color.hueRange){return color.hueRange}}}return[0,360]}function getSaturationRange(hue){return getColorInfo(hue).saturationRange}function getColorInfo(hue){if(hue>=334&&hue<=360){hue-=360}for(var colorName in colorDictionary){var color=colorDictionary[colorName];if(color.hueRange&&hue>=color.hueRange[0]&&hue<=color.hueRange[1]){return colorDictionary[colorName]}}return"Color not found"}function randomWithin(range){if(seed===null){return Math.floor(range[0]+Math.random()*(range[1]+1-range[0]))}else{var max=range[1]||1;var min=range[0]||0;seed=(seed*9301+49297)%233280;var rnd=seed/233280;return Math.floor(min+rnd*(max-min))}}function HSVtoHex(hsv){var rgb=HSVtoRGB(hsv);function componentToHex(c){var hex=c.toString(16);return hex.length==1?"0"+hex:hex}var hex="#"+componentToHex(rgb[0])+componentToHex(rgb[1])+componentToHex(rgb[2]);return hex}function defineColor(name,hueRange,lowerBounds){var sMin=lowerBounds[0][0],sMax=lowerBounds[lowerBounds.length-1][0],bMin=lowerBounds[lowerBounds.length-1][1],bMax=lowerBounds[0][1];colorDictionary[name]={hueRange:hueRange,lowerBounds:lowerBounds,saturationRange:[sMin,sMax],brightnessRange:[bMin,bMax]}}function loadColorBounds(){defineColor("monochrome",null,[[0,0],[100,0]]);defineColor("red",[-26,18],[[20,100],[30,92],[40,89],[50,85],[60,78],[70,70],[80,60],[90,55],[100,50]]);defineColor("orange",[19,46],[[20,100],[30,93],[40,88],[50,86],[60,85],[70,70],[100,70]]);defineColor("yellow",[47,62],[[25,100],[40,94],[50,89],[60,86],[70,84],[80,82],[90,80],[100,75]]);defineColor("green",[63,178],[[30,100],[40,90],[50,85],[60,81],[70,74],[80,64],[90,50],[100,40]]);defineColor("blue",[179,257],[[20,100],[30,86],[40,80],[50,74],[60,60],[70,52],[80,44],[90,39],[100,35]]);defineColor("purple",[258,282],[[20,100],[30,87],[40,79],[50,70],[60,65],[70,59],[80,52],[90,45],[100,42]]);defineColor("pink",[283,334],[[20,100],[30,90],[40,86],[60,84],[80,80],[90,75],[100,73]])}function HSVtoRGB(hsv){var h=hsv[0];if(h===0){h=1}if(h===360){h=359}h=h/360;var s=hsv[1]/100,v=hsv[2]/100;var h_i=Math.floor(h*6),f=h*6-h_i,p=v*(1-s),q=v*(1-f*s),t=v*(1-(1-f)*s),r=256,g=256,b=256;switch(h_i){case 0:r=v;g=t;b=p;break;case 1:r=q;g=v;b=p;break;case 2:r=p;g=v;b=t;break;case 3:r=p;g=q;b=v;break;case 4:r=t;g=p;b=v;break;case 5:r=v;g=p;b=q;break}var result=[Math.floor(r*255),Math.floor(g*255),Math.floor(b*255)];return result}function HSVtoHSL(hsv){var h=hsv[0],s=hsv[1]/100,v=hsv[2]/100,k=(2-s)*v;return[h,Math.round(s*v/(k<1?k:2-k)*1e4)/100,k/2*100]}function stringToInteger(string){var total=0;for(var i=0;i!==string.length;i++){if(total>=Number.MAX_SAFE_INTEGER)break;total+=string.charCodeAt(i)}return total}return randomColor});
	function colorinate(){
		var clr;
		var css;
		var items = {};
		$('tr.datarow').each(function() {
		    items[$(this).attr('data-lid')] = true;
		});
		var result = new Array();
		for(var i in items){
		    result.push(i);
		}
		for(var i in result){
		    clr=randomColor();
			$('.datarow[data-lid="' + result[i] + '"]').css({'background-color': clr});
		}
	}
	function decolorizinate(){
		$('.datarow[data-lid]').removeAttr( 'style' );
	}
</script>
<cfoutput>
	<hr>
		Collecting Event Change Log
		<ul>
			<li>Sort is by collecting_event_id, then by change date</li>
			<li>Newest records are closest to the top</li>
			<li>Changed values are red</li>
			<li>un-changed values are green</li>
			<li>[NULL] indicates a NULL data value, not the string "[NULL]"</li>
			<li>
				Links go to (usually edit of) CURRENT data. Eg,
				locality_id=1 may be "here" now but was "not here" when the collecting event was edited, or
				an event may have had zero (or millions) of specimens when it was edited, and
				millions of (or zero) specimens now.
			</li>
			<li>
				Media link finds media which is
					1) related to the event
				( Media links will attempt to pre-fetch recordcount.)
			</li>
			<li>
				UserID is the agent who changed FROM the data in the row; each change is an archive of :OLD values
				captured with Oracle triggers. That is, whodunit discarded the row on which their username appears,
				creating the next-newer row.
			</li>
			<li>
				Every row should represent at least one change; saves which do not change "primary data" (eg, those that
				do nothing, or updates to webservice-derived data) are not archived.
			</li>
			<li>All links open in a new window/tab</li>
			<li>
				You can
				<span class="likeLink" onclick="colorinate();">randomly color things by collecting_event_id </span> or
				<span class="likeLink" onclick="decolorizinate();">turn that off</span>.
			</li>
		</ul>
	<hr>
	<cfparam name="collecting_event_id" default="">
	<cfparam name="sdate" default="">
	<cfparam name="edate" default="">
	<cfparam name="who" default="">
	<form method="get" action="collectingEventArchive.cfm">
		<label for="collecting_event_id">Collecting Event ID (comma-list OK)</label>
		<input type="text" name="collecting_event_id" value="#collecting_event_id#">
		<label for="sdate">After date</label>
		<input type="text" id="sdate" name="sdate" value="#sdate#">
		<label for="edate">Before date</label>
		<input type="text" id="edate" name="edate" value="#edate#">
		<label for="who">Username</label>
		<input type="text" id="who" name="who" value="#who#">
		<br><input type="submit" value="filter">
	</form>

	<cfif len(collecting_event_id) is 0 and len(sdate) is 0 and len(edate) is 0 and len(who) is 0>
		No criteria: aborting<cfabort>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		select
			collecting_event_archive_id,
		 	collecting_event_id,
		 	locality_id,
		 	BEGAN_DATE,
			ENDED_DATE,
			COLLECTING_EVENT_NAME,
			VERBATIM_COORDINATES,
			whodunit,
			changedate,
		 	VERBATIM_DATE,
		 	VERBATIM_LOCALITY,
		 	COLL_EVENT_REMARKS
		 from
		 	collecting_event_archive
		 where
		 	1=1
		 	<cfif len(collecting_event_id) gt 0>
				and collecting_event_id in ( <cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ","> )
			</cfif>
			<cfif len(sdate) gt 0>
				and collecting_event_id in (select collecting_event_id from collecting_event_archive where changedate >= '#sdate#')
			</cfif>
			<cfif len(edate) gt 0>
				and collecting_event_id in (select collecting_event_id from collecting_event_archive where changedate <= '#edate#')
			</cfif>
			<cfif len(who) gt 0>
				and collecting_event_id in (select collecting_event_id from collecting_event_archive where upper(whodunit) like '%#ucase(who)#%')
			</cfif>
	</cfquery>
	<cfquery name="dlocid" dbtype="query">
		select distinct(collecting_event_id) from d
	</cfquery>
	<cfif d.recordcount is 0>
		No archived information found.<cfabort>
	</cfif>
	<table border>
		<tr>
			<th>ChangeDate</th>
			<th>UserID</th>
			<th>EventID</th>
			<th>LocalityID</th>
			<th>VerbatimLocality</th>
			<th>EventName</th>
			<th>BeganDate</th>
			<th>EndedDate</th>
			<th>Remark</th>
		</tr>



		<cfloop query="dlocid">
			<cfquery name="orig" datasource="uam_god">
				select
					collecting_event_id,
				 	locality_id,
				 	BEGAN_DATE,
					ENDED_DATE,
					COLLECTING_EVENT_NAME,
					VERBATIM_COORDINATES,
				 	VERBATIM_DATE,
				 	VERBATIM_LOCALITY,
				 	COLL_EVENT_REMARKS
				 from
				 	collecting_event
				 where
				 	collecting_event_id=<cfqueryparam value = "#dlocid.collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>


			<tr class="datarow" data-lid="#dlocid.collecting_event_id#">
				<td class="original">currentData</td>
				<td class="original">-n/a-</td>
				<td class="original">
					<a target="_blank" href="/Locality.cfm?action=editCollEvnt&collecting_event_id=#dlocid.collecting_event_id#">
						#orig.collecting_event_id#
					</a>
					<br><a target="_blank" href="/SpecimenResults.cfm?collecting_event_id=#dlocid.collecting_event_id#">specimens</a>
					<br><a id="m_l_d_#dlocid.collecting_event_id#" target="_blank" href="/MediaSearch.cfm?action=search&collecting_event_id=#dlocid.collecting_event_id#">media</a>
				</td>
				<cfset lastLocID=orig.locality_id>
				<td class="original">
					<a target="_blank" href="/editLocality.cfm?locality_id=#orig.locality_id#">
						#orig.locality_id#
					</a>
				</td>

				<cfset lastVLoc=orig.VERBATIM_LOCALITY>
				<td class="original">#orig.VERBATIM_LOCALITY#</td>


				<cfset lastEName=orig.COLLECTING_EVENT_NAME>
				<td class="original">#orig.COLLECTING_EVENT_NAME#</td>

				<cfset lastBDate=orig.BEGAN_DATE>
				<td class="original">#orig.BEGAN_DATE#</td>

				<cfset lastEDate=orig.ENDED_DATE>
				<td class="original">#orig.ENDED_DATE#</td>


				<cfset lastRem=orig.COLL_EVENT_REMARKS>
				<td class="original">#orig.COLL_EVENT_REMARKS#</td>
			</tr>

			<cfquery name="thisChanges" dbtype="query">
				select * from d where collecting_event_id=#dlocid.collecting_event_id# order by changedate desc
			</cfquery>
			<cfloop query="thisChanges">

				<tr class="datarow" data-lid="#dlocid.collecting_event_id#">
					<td>#changedate#</td>
					<td>#whodunit#</td>
					<td>#collecting_event_id#</td>
					<cfif locality_id is lastLocID>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastLocID=locality_id>
					<td class="#thisStyle#">
						<a target="_blank" href="/editLocality.cfm?locality_id=#locality_id#">
							#locality_id#
						</a>
					</td>

					<cfif VERBATIM_LOCALITY is lastVLoc>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastVLoc=VERBATIM_LOCALITY>
					<td class="#thisStyle#">
						#VERBATIM_LOCALITY#
					</td>



					<cfif COLLECTING_EVENT_NAME is lastEName>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastEName=COLLECTING_EVENT_NAME>
					<td class="#thisStyle#">
						#COLLECTING_EVENT_NAME#
					</td>

					<cfif BEGAN_DATE is lastBDate>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastBDate=BEGAN_DATE>
					<td class="#thisStyle#">
						#BEGAN_DATE#
					</td>


					<cfif ENDED_DATE is lastEDate>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastEDate=ENDED_DATE>
					<td class="#thisStyle#">
						#ENDED_DATE#
					</td>


					<cfif COLL_EVENT_REMARKS is lastRem>
						<cfset thisStyle="nochange">
					<cfelse>
						<cfset thisStyle="haschange">
					</cfif>
					<cfset lastRem=COLL_EVENT_REMARKS>
					<td class="#thisStyle#">
						#COLL_EVENT_REMARKS#
					</td>
				</tr>
			</cfloop>
		</cfloop>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">