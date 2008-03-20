<cfinclude template="/includes/_header.cfm">	
<link rel="stylesheet" type="text/css" href="/includes/annotate.css">
<script type='text/javascript' src='/includes/annotate.js'></script>
<cfif not isdefined("collection_object_id")>
	<cfif isdefined("guid")>
		<cfset institution_acronym = listgetat(guid,1,":")>
		<cfset collection_cde = listgetat(guid,2,":")>
		<cfset cat_num = listgetat(guid,3,":")>
		<cfquery name="c" datasource="#Application.web_user#">
			select collection_object_id from 
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				cat_num = #cat_num# AND
				collection.collection_cde='#collection_cde#' AND
				collection.institution_acronym='#institution_acronym#'
		</cfquery>
		<cfif len(#c.collection_object_id#) gt 0>
			<cfset collection_object_id=#c.collection_object_id#>
		<cfelse>
			<p style="color:#FF0000; font-size:14px;">
				Unable to resolve GUID. Aborting.....
			</p>
			<cfabort>	
		</cfif>
	<cfelse>
		<p style="color:#FF0000; font-size:14px;">
			Did not get a collection_object_id - aborting....
		</p>
		<cfabort>
	</cfif>
</cfif>
<cfif (not isdefined("content_url")) or (len(#content_url#) is 0)>
		<cfset content_url = "SpecimenDetail_body.cfm">
</cfif>

<cfset detSelect = "
	SELECT DISTINCT
		institution_acronym,
		collection.collection,
		cataloged_item.collection_id,
		web_link,
		web_link_text,
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		continent_ocean,
		country,
		collecting_event.collecting_event_id,
		state_prov,
		quad,
		county,
		island,
		island_group,
		spec_locality,
		verbatim_date,
		BEGAN_DATE,
		ended_date,
		sea,
		feature,
		other_id_type,
		other_id_num,
		concatparts(cataloged_item.collection_object_id) as partString,
		concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action,
		dec_lat,
		dec_long">
		<cfif len(#Client.CustomOtherIdentifier#) gt 0>
			<cfset detSelect = "#detSelect#
			,concatSingleOtherId(cataloged_item.collection_object_id,'#Client.CustomOtherIdentifier#') as	CustomID">
		</cfif>		
<cfset detSelect = "#detSelect#	
	FROM 
		cataloged_item
	INNER JOIN collection ON (cataloged_item.collection_id = collection.collection_id)
	INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
	INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
	INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
	INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
	INNER JOIN Coll_object ON (cataloged_item.collection_object_id = coll_object.collection_object_id)
	LEFT OUTER JOIN coll_obj_other_id_num ON (cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id)
	LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
	WHERE 
		identification.accepted_id_fg = 1 AND
		cataloged_item.collection_object_id = #collection_object_id#
	ORDER BY
		cat_num">

<cfquery name="detail" datasource = "#Application.web_user#">
	#preservesinglequotes(detSelect)#
</cfquery>

<cfoutput>
<cf_customizeHeader collection_id=#detail.collection_id#>
<script>
		
/***********************************************
* IFrame SSI script- © Dynamic Drive DHTML code library (http://www.dynamicdrive.com)
* Visit DynamicDrive.com for hundreds of original DHTML scripts
* This notice must stay intact for legal use
***********************************************/
var iframeids=["theFrame"]
var iframehide="yes"
var getFFVersion=navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]
var FFextraHeight=parseFloat(getFFVersion)>=0.1? 18 : 0 //extra height in px to add to iframe in FireFox 1.0+ browsers
FFextraHeight = 60; // DLM - sometimes it doesn't fit
function dyniframesize() {
var dyniframe=new Array()
for (i=0; i<iframeids.length; i++){
if (document.getElementById){ //begin resizing iframe procedure
dyniframe[dyniframe.length] = document.getElementById(iframeids[i]);
if (dyniframe[i] && !window.opera){
dyniframe[i].style.display="block"
if (dyniframe[i].contentDocument && dyniframe[i].contentDocument.body.offsetHeight) //ns6 syntax
dyniframe[i].height = dyniframe[i].contentDocument.body.offsetHeight+FFextraHeight;
else if (dyniframe[i].Document && dyniframe[i].Document.body.scrollHeight) //ie5+ syntax
dyniframe[i].height = dyniframe[i].Document.body.scrollHeight;
}
}
if ((document.all || document.getElementById) && iframehide=="no"){
var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
tempobj.style.display="block"
}
}
}

if (window.addEventListener)
window.addEventListener("load", dyniframesize, false)
else if (window.attachEvent)
window.attachEvent("onload", dyniframesize)
else
window.onload=dyniframesize
		function switchIFrame(page,id, addlParamName, addlParamVal) {
		var theFrame = document.getElementById("theFrame");
		var theID = #collection_object_id#
		var theExt = ".cfm";
		if (id) {
			} else {
			id = "collection_object_id";
		}
		var theURL = page + theExt + "?" + id + "=" + theID;
		theFrame.src=theURL;
		var ms = document.getElementById("SpecimenDetail_bodySpan");
		var ids = document.getElementById("editIdentificationSpan");
		var ac = document.getElementById("addAccnSpan");
		var loc = document.getElementById("specLocalitySpan");
		var cev = document.getElementById("changeCollEventSpan");
		
		var col = document.getElementById("editCollsSpan");
		var rel = document.getElementById("editRelationshipSpan");
		var par = document.getElementById("editPartsSpan");
		var ctron = document.getElementById("ContainerSpan");
		var bi = document.getElementById("editBiolIndivSpan");
		var oid = document.getElementById("editIdentifiersSpan");
		var img = document.getElementById("editImagesSpan");
		var enc = document.getElementById("EncumbrancesSpan");
		var cce = document.getElementById("changeCollEventSpan");
		var cspan = document.getElementById("catalogSpan");
		var slspan = document.getElementById("specLocalitySpan");
		
		ms.className = 'likeLink';
		ids.className = 'likeLink';
		cev.className = 'likeLink';
		ac.className = 'likeLink';
		loc.className = 'likeLink';
		col.className = 'likeLink';
		rel.className = 'likeLink';
		par.className = 'likeLink';
		ctron.className = 'likeLink';
		bi.className = 'likeLink';
		oid.className = 'likeLink';
		img.className = 'likeLink';
		enc.className = 'likeLink';
		cce.className = 'likeLink';
		cspan.className = 'likeLink';
		slspan.className = 'likeLink';
		var thisID = page + 'Span';
		var thisSpan = "document.getElementById('" + thisID + "');";
		//alert(thisSpan);
		var theSpanEl = eval(thisSpan);
		theSpanEl.className = 'likeLink active';
		dyniframesize();
	}
</script>
<style>
	.thisFrame {
		border:0px;
		width:100%;
		/*height:1000px;*/
		}
</style>
<!---- kill the class=content div and replace it with a 95% pagewidth div --->
</div>
<div style="padding-left:25px; ">
	<!----
<cfif len(#client.username#) gt 0>
	<cfquery name="existingAnnotations" datasource="#Application.web_user#">
		select count(*) cnt from specimen_annotations
		where collection_object_id = #collection_object_id#
	</cfquery>
	

	<span class="pageHelp infoLink" style="border:1px dotted green;" onclick="openAnnotation('#collection_object_id#')">
		Annotate
		<cfif #existingAnnotations.cnt# gt 0>
			<br>(#existingAnnotations.cnt# existing)
		</cfif>
		
	</span>
<cfelse>
	<a href="/login.cfm" class="pageHelp infoLink">Login or Create Account</a>
</cfif>	


<cfif isdefined("returnURL") and #len(returnURL)# gt 0>
	<br><a href="SpecimenResultsss.cfm?#returnURL#" class="pageHelp infoLink">Return to Results</a>&nbsp;
</cfif>
---->

	<script type="text/javascript" language="javascript">
		//changeStyle('#detail.institution_acronym#');
		// set this as a variable
		//var thisStyle = '#detail.institution_acronym#';
		// define stylesheet
		parent.window.document.title = "#detail.institution_acronym# #detail.collection_cde# #detail.cat_num#";
	</script>
</cfoutput>
<cfoutput query="detail" group="cat_num">
<cfset hg="">
				<cfif len(#continent_ocean#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #continent_ocean#">
					<cfelse>
						<cfset hg="#continent_ocean#">
					</cfif>
				</cfif>
				<cfif len(#sea#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #sea#">
					<cfelse>
						<cfset hg="#sea#">
					</cfif>
				</cfif>
				<cfif len(#country#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #country#">
					<cfelse>
						<cfset hg="#country#">
					</cfif>
				</cfif>
				<cfif len(#state_prov#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #state_prov#">
					<cfelse>
						<cfset hg="#state_prov#">
					</cfif>
				</cfif>
				<cfif len(#feature#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #feature#">
					<cfelse>
						<cfset hg="#feature#">
					</cfif>
				</cfif>
				<cfif len(#county#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #county#">
					<cfelse>
						<cfset hg="#county#">
					</cfif>
				</cfif>
				<cfif len(#island_group#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #island_group#">
					<cfelse>
						<cfset hg="#island_group#">
					</cfif>
				</cfif>
				<cfif len(#island#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #island#">
					<cfelse>
						<cfset hg="#island#">
					</cfif>
				</cfif>
				<cfif len(#quad#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #quad# Quad">
					<cfelse>
						<cfset hg="#quad# Quad">
					</cfif>
				</cfif>
</cfoutput>
<table>
	<tr>
		<td><div><table><tr>
		<td nowrap valign="top">
			<cfoutput query="detail" group="cat_num">
				<font size="+1"><B>#collection#&nbsp;#cat_num#</b></font>
				<cfif len(#web_link#) gt 0>
					<a href="#web_link#" target="_blank"><img src="/images/linkOut.gif" border="0" alt="#web_link_text#"></a>
				</cfif>
				<cfif len(#Client.CustomOtherIdentifier#) gt 0>
					<BR>&nbsp;&nbsp;&nbsp;#Client.CustomOtherIdentifier#: #CustomID#
				</cfif>		
						
						
				<br>
				
						<font size="+1">
						<cfset sciname = '#replace(Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
							<b>
								<i>&nbsp;#sciname#</i>
								</b>
							</font>
				<span class="infoLink" onClick="getInfo('identification','#collection_object_id#');">
					Details			  			
				</span>
				 <cfif 
							(len(#dec_lat#) gt 0 and 
							len(#dec_long#) gt 0) 
						>
						<cfif #encumbrance_action# does not contain "coordinates" OR
							(isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>						
							<cfset bnhmUrl="/bnhmMaps/bnhmMapData.cfm?collection_object_id=#collection_object_id#">
							<br><input type="button" 
								value="BerkeleyMapper" 
								class="lnkBtn"
								onmouseover="this.className='lnkBtn btnhov'" 
								onmouseout="this.className='lnkBtn'"
								onClick="window.open('#bnhmUrl#', '_blank');">
								<img src="/images/info.gif" border="0" onClick="getDocs('maps')" class="likeLink">
	
						</cfif>
					</cfif>
		</td>
		<td valign="top">
			
				<em>#spec_locality#</em>
				<br>#hg#
				
			<cfif #encumbrance_action# does not contain "year collected" OR
							( isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
			<cfif (#verbatim_date# is #began_date#) AND
			 		(#verbatim_date# is #ended_date#)>
					<cfset thisDate = #dateformat(began_date,"dd mmm yyyy")#>
			<cfelseif (
						(#verbatim_date# is not #began_date#) OR
			 			(#verbatim_date# is not #ended_date#)
					)
					AND
					#began_date# is #ended_date#>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")#)">
			<cfelse>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#)">
			</cfif>
			<Cfelse>
			<cfif #began_date# is #ended_date#>
				<cfset thisDate = #dateformat(began_date,"dd mmm 8888")#>
			<cfelse>
				<cfset thisDate = '#dateformat(began_date,"dd mmm 8888")#-&nbsp;#dateformat(ended_date,"dd mmm 8888")#'>
			</cfif>
			
		</cfif>
			<br>#thisDate#
		</td>
		<td valign="top">
		
								<font size="-1">
								#partString#
								</font>
								
		</td>
		<td valign="top">
		

<span class="annotateSpace">
	<cfif len(#client.username#) gt 0>
		<cfquery name="existingAnnotations" datasource="#Application.web_user#">
			select count(*) cnt from specimen_annotations
			where collection_object_id = #collection_object_id#
		</cfquery>
		<a onclick="openAnnotation('#collection_object_id#')">
			[Annotate.]
		</a>
		<cfif #existingAnnotations.cnt# gt 0>
			<br>(#existingAnnotations.cnt# existing)
		</cfif>
	<cfelse>
		<a href="/login.cfm">Login or Create Account</a>
	</cfif>
	<cfif isdefined("returnURL")>
		<br><a onclick="window.location=SpecimenResults.cfm?#returnURL#">[Return to Results.]</a>
	</cfif>	
</span>
</td></tr></table></div></td>
		</cfoutput>
		
		
	</tr>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
	<tr>
		<td colspan="3" align="center">
		<cfoutput>
				
		<form name="incPg" method="post" action="SpecimenDetail.cfm">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
					<input type="hidden" name="content_url" value="#content_url#">
					<input type="hidden" name="suppressHeader" value="true">
					<input type="hidden" name="action" value="nothing">
					<input type="hidden" name="Srch" value="Part">
					<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap>		

<cfif #cgi.HTTP_USER_AGENT# contains "MSIE">
	<cfset isMS = "t">
<cfelse>
	<cfset isMS = "f">
</cfif>
<!--- browse --->
	<cfset isPrev = "no">
	<cfset isNext = "no">
	<cfset currPos = 0>
	<cfset lenOfIdList = 0>
	<cfset firstID = #collection_object_id#>
	<cfset nextID = #collection_object_id#>
	<cfset prevID = #collection_object_id#>
	<cfset lastID = #collection_object_id#>
<cfif isdefined("orderedCollObjIdList") and len(#orderedCollObjIdList#) gt 0>
	<!--- see where we are currently --->
	<cfset currPos = listfind(orderedCollObjIdList,collection_object_id)>
	<cfset lenOfIdList = listlen(orderedCollObjIdList)>
	<!--- get IDs to browse to --->
	<cfset firstID = listGetAt(orderedCollObjIdList,1)>
	<cfif #currPos# lt #lenOfIdList#>
		<cfset nextID = listGetAt(orderedCollObjIdList,currPos + 1)>
	</cfif>
	<cfif #currPos# gt 1>
		<cfset prevID = listGetAt(orderedCollObjIdList,currPos - 1)>
	</cfif>
	
	<cfset lastID = listGetAt(orderedCollObjIdList,lenOfIdList)>
	<!--- should we have first? --->
	<cfif #lenOfIdList# gt 1>
		<cfif #currPos# gt 1>
			<cfset isPrev = "yes">
		</cfif>
		<cfif #currPos# lt #lenOfIdList#>
			<cfset isNext = "yes">
		</cfif>
	</cfif>
</cfif>
	<ul id="navbar">
	<cfif #isPrev# is "yes">
		<img src="/images/first.gif" class="likeLink" onclick="document.location='SpecimenDetail.cfm?orderedCollObjIdList=#orderedCollObjIdList#&collection_object_id=#firstID#'" />
		<img src="/images/previous.gif" class="likeLink"  onclick="document.location='SpecimenDetail.cfm?orderedCollObjIdList=#orderedCollObjIdList#&collection_object_id=#prevID#'" />
	<cfelse>
		<img src="/images/no_first.gif"  />
		<img src="/images/no_previous.gif" />
	</cfif>
		<li>
			<span onclick="switchIFrame('SpecimenDetail_body')"
				class="likeLink active" id="SpecimenDetail_bodySpan">Main</span>
		</li>
		<li>
			<span onclick="switchIFrame('editIdentification')"
				class="likeLink" id="editIdentificationSpan">Taxa</span>
		</li>
		<li>
			<span onclick="switchIFrame('addAccn')"
				class="likeLink" id="addAccnSpan">Accn</span>
		</li>
		<!---
		<li>
			<span onclick="switchIFrame('Locality')"
				class="likeLink" id="LocalitySpan">Locality</span>
		</li>
		
		
		--->
		<li>
			<span onclick="switchIFrame('changeCollEvent')"
				class="likeLink" id="changeCollEventSpan">Pick New Coll Event</span>
		</li>
		<li>
			<span onclick="switchIFrame('specLocality')"
				class="likeLink" id="specLocalitySpan">Locality</span>
		</li>
		<li>
			<span onclick="switchIFrame('editColls')"
				class="likeLink" id="editCollsSpan">Agents</span>
		</li>
		<li>
			<span onclick="switchIFrame('editRelationship')"
				class="likeLink" id="editRelationshipSpan">Relations</span>
		</li>
		<li>
			<span onclick="switchIFrame('editParts')"
				class="likeLink" id="editPartsSpan">Parts</span>
		</li>
		
		<li>
			<span onclick="switchIFrame('location_tree')"
				class="likeLink" id="ContainerSpan">Part Locn.</span>
		</li>
		<li>
			<span onclick="switchIFrame('editBiolIndiv')"
				class="likeLink" id="editBiolIndivSpan">Attributes</span>
		</li>
		<li>
			<span onclick="switchIFrame('editIdentifiers')"
				class="likeLink" id="editIdentifiersSpan">Other IDs</span>
		</li>
		<li>
			<span onclick="switchIFrame('editImages')"
				class="likeLink" id="editImagesSpan">Images</span>
		</li>
		<li>
			<span onclick="switchIFrame('Encumbrances')"
				class="likeLink" id="EncumbrancesSpan">Encumbrances</span>
		</li>
		<li>
			<span onclick="switchIFrame('catalog')"
				class="likeLink" id="catalogSpan">Catalog</span>
		</li>
		<cfif #isNext# is "yes">
			<img src="/images/next.gif" class="likeLink"   onclick="document.location='SpecimenDetail.cfm?orderedCollObjIdList=#orderedCollObjIdList#&collection_object_id=#nextID#'"/>
			<img src="/images/last.gif"  class="likeLink"   onclick="document.location='SpecimenDetail.cfm?orderedCollObjIdList=#orderedCollObjIdList#&collection_object_id=#lastID#'"/>
		<cfelse>
			<img src="/images/no_next.gif" />
			<img src="/images/no_last.gif" />
		</cfif>
	</ul>
</td>
</tr>

</table>
			</form>
			</cfoutput>
		</td>
	</tr>
	</cfif>	
</table>
<cfoutput>
<table width="100%">
	<tr>
		<td>
			<div id="fHolder">
				<iframe class="thisFrame" 
					id="theFrame" 
					name="theFrame" 
					src="SpecimenDetail_body.cfm?collection_object_id=#collection_object_id#">
				</iframe>
			</div>
		</td>
	</tr>
</table>
</div>
<cfset exclusive_collection_id="#detail.collection_id#">
<cfinclude template="/includes/_footer.cfm">

	
	
	<cfset log.query_string="?collection_object_id=#collection_object_id#">
	<cfset log.reported_count = 1>
	<cfinclude template="/includes/activityLog.cfm">
	<cfif isdefined("showAnnotation") and #showAnnotation# is "true">
		<script>
			openAnnotation('#collection_object_id#');
		</script>		
	</cfif>
</cfoutput>