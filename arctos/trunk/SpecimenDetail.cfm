<cfinclude template="/includes/_header.cfm">
<!---
<cfif isdefined("collection_object_id")>
	<cfset checkSql(collection_object_id)>
	<cfoutput>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select GUID from #session.flatTableName# where collection_object_id=#collection_object_id# 
		</cfquery>
		<cflocation url="/guid/#c.guid#" addtoken="false">
	</cfoutput>	
</cfif>
<cfif isdefined("guid")>
	<cfset checkSql(guid)>
	<cfif guid contains ":">
		<cfoutput>
			<cfset sql="select collection_object_id from 
					#session.flatTableName#
				WHERE
					upper(guid)='#ucase(guid)#'">
			<cfset checkSql(sql)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(sql)#
			</cfquery>
		</cfoutput>
	<cfelseif guid contains " ">
		<cfset spos=find(" ",reverse(guid))>
		<cfset cc=left(guid,len(guid)-spos)>
		<cfset cn=right(guid,spos)>
		<cfset sql="select collection_object_id from 
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				cat_num = #cn# AND
				lower(collection.collection)='#lcase(cc)#'">
		<cfset checkSql(sql)>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
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
--->
<cfset detSelect = "
	SELECT DISTINCT
		#session.flatTableName#.collection,
		#session.flatTableName#.collection_id,
		web_link,
		web_link_text,
		#session.flatTableName#.cat_num,
		#session.flatTableName#.collection_object_id as collection_object_id,
		#session.flatTableName#.scientific_name,
		#session.flatTableName#.continent_ocean,
		#session.flatTableName#.country,
		#session.flatTableName#.collecting_event_id,
		#session.flatTableName#.state_prov,
		#session.flatTableName#.quad,
		#session.flatTableName#.higher_geog,
		#session.flatTableName#.county,
		#session.flatTableName#.island,
		#session.flatTableName#.island_group,
		#session.flatTableName#.spec_locality,
		#session.flatTableName#.verbatim_date,
		#session.flatTableName#.BEGAN_DATE,
		#session.flatTableName#.ended_date,
		#session.flatTableName#.sea,
		#session.flatTableName#.feature,
		concatparts(#session.flatTableName#.collection_object_id) as partString,
		concatEncumbrances(#session.flatTableName#.collection_object_id) as encumbrance_action,
		#session.flatTableName#.dec_lat,
		#session.flatTableName#.dec_long">
		<cfif len(#session.CustomOtherIdentifier#) gt 0>
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
<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfoutput>
	
		#preservesinglequotes(detSelect)#

<cfif detail.recordcount lt 1>
	<div class="error">
		Oops! No specimen was found for that URL.
		<ul>
			<li>Did you mis-type the URL?</li>
			<li>
				Did you click a link? <a href="/info/bugs.cfm">Tell us about it</a>.
			</li>
			<li>
				You may need to log out or change your preferences to access all public data.
			</li>
		</ul>
	</div>
</cfif>
<!---
<cfset title="#detail.collection# #detail.cat_num#: #detail.scientific_name#">
<cfset metaDesc="#detail.collection# #detail.cat_num# (#guid#); #detail.scientific_name#; #detail.higher_geog#; #detail.spec_locality#">
<cf_customizeHeader collection_id=#detail.collection_id#>
--->
<script type="text/javascript" language="javascript">
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
			var theURL = '/' + page + theExt + "?" + id + "=" + theID;
			theFrame.src=theURL;
			var ms = document.getElementById("SpecimenDetail_bodySpan");
			var ids = document.getElementById("editIdentificationSpan");
			var ac = document.getElementById("addAccnSpan");
			var loc = document.getElementById("specLocalitySpan");
			var cev = document.getElementById("changeCollEventSpan");
			
			var col = document.getElementById("editCollsSpan");
			var rel = document.getElementById("editRelationshipSpan");
			var par = document.getElementById("editPartsSpan");
			var ctron = document.getElementById("findContainerSpan");
			var bi = document.getElementById("editBiolIndivSpan");
			var oid = document.getElementById("editIdentifiersSpan");
			var img = document.getElementById("MediaSearchSpan");
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
<!---
<div style="background-color:blue;">
	--->
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
	    <table >
	        <tr>
			    <td nowrap valign="top">
					<font size="+1"><strong>#collection#&nbsp;#cat_num#</strong></font>
					<cfif len(#web_link#) gt 0>
						<a href="#web_link#" target="_blank"><img src="/images/linkOut.gif" border="0" alt="#web_link_text#"></a>
					</cfif>
					<cfif len(#session.CustomOtherIdentifier#) gt 0>
						<br>&nbsp;&nbsp;&nbsp;#session.CustomOtherIdentifier#: #CustomID#
					</cfif>						
					<br>
					<font size="+1">
					    <cfset sciname = '#replace(Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
					    <strong>
						    <i>&nbsp;#sciname#</i>
						</strong>
					</font>
					 <cfif 
						(len(#dec_lat#) gt 0 and 
						len(#dec_long#) gt 0) 
					>
					    <cfif #encumbrance_action# does not contain "coordinates" OR
							(isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>						
						    	<cfset bnhmUrl="/bnhmMaps/bnhmMapData.cfm?collection_object_id=#collection_object_id#">
						    	<br><input type="button" 
									value="BerkeleyMapper" 
									class="lnkBtn"
									onClick="window.open('#bnhmUrl#', '_blank');">
								<img src="/images/info.gif" border="0" onClick="getDocs('maps')" class="likeLink">
		                </cfif>
					</cfif>
			    </td>
			    <td valign="top">
				    <strong><em>#spec_locality#</em></strong>
					<br><strong>#hg#</strong>
					<cfif #encumbrance_action# does not contain "year collected" OR
						( isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>					
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
	                <cfelse>
				        <cfif #began_date# is #ended_date#>
					        <cfset thisDate = #dateformat(began_date,"dd mmm 8888")#>
				        <cfelse>
					        <cfset thisDate = '#dateformat(began_date,"dd mmm 8888")#-&nbsp;#dateformat(ended_date,"dd mmm 8888")#'>
				        </cfif>
					</cfif>
				    <br><strong>#thisDate#</strong>
			    </td>
			    <td valign="top">
					<font size="-1">
			    		<strong>#partString#</strong>
					</font>
				</td>
				<td>
					<cfif len(dec_lat) gt 0 and len(dec_long) gt 0 and (dec_lat is not 0 and dec_long is not 0)>
						<cfset iu="http://maps.google.com/maps/api/staticmap?key=#application.gmap_api_key#&center=#dec_lat#,#dec_long#">
						<cfset iu=iu & "&markers=color:red|size:tiny|#dec_lat#,#dec_long#&sensor=false&size=100x100&zoom=2">
						<cfset iu=iu & "&maptype=roadmap">
						<a href="http://maps.google.com/maps?q=#dec_lat#,#dec_long#" target="_blank">
							<img src="#iu#" alt="Google Map">
						</a>
					</cfif>
				</td>
			    <td valign="top">
			        <span class="annotateSpace">
						<cfif len(#session.username#) gt 0>
							<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select count(*) cnt from annotations
								where collection_object_id = #collection_object_id#
							</cfquery>
							<a href="javascript: openAnnotation('collection_object_id=#collection_object_id#')">
								[Report&nbsp;Bad&nbsp;Data]							
							<cfif #existingAnnotations.cnt# gt 0>
								<br>(#existingAnnotations.cnt# existing)
							</cfif>
							</a>
						<cfelse>
							<a href="/login.cfm">Login or Create Account</a>
						</cfif>
						<cfif isdefined("session.mapURL") and len(session.mapURL) gt 0>
							<br><a onclick="document.location='/SpecimenResults.cfm?#session.mapURL#'">[Return to results]</a>
						</cfif>	
	                </span>
	            </td>
	        </tr>
	    </table>
	<cfif #cgi.HTTP_USER_AGENT# contains "MSIE">
		<cfset isMS = "t">
	<cfelse>
		<cfset isMS = "f">
	</cfif>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
	    <table>
		    <tr>
			    <td align="center">
					<form name="incPg" method="post" action="SpecimenDetail.cfm">
				        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
						<input type="hidden" name="suppressHeader" value="true">
						<input type="hidden" name="action" value="nothing">
						<input type="hidden" name="Srch" value="Part">
						<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
						<cfif isdefined("session.collObjIdList") and len(session.collObjIdList) gt 0>
						    <cfset isPrev = "no">
							<cfset isNext = "no">
							<cfset currPos = 0>
							<cfset lenOfIdList = 0>
							<cfset firstID = #collection_object_id#>
							<cfset nextID = #collection_object_id#>
							<cfset prevID = #collection_object_id#>
							<cfset lastID = #collection_object_id#>
							<!--- see where we are currently --->
							<cfset currPos = listfind(session.collObjIdList,collection_object_id)>
							<cfset lenOfIdList = listlen(session.collObjIdList)>
							<!--- get IDs to browse to --->
							<cfset firstID = listGetAt(session.collObjIdList,1)>
							<cfif #currPos# lt #lenOfIdList#>
								<cfset nextID = listGetAt(session.collObjIdList,currPos + 1)>
							</cfif>
							<cfif #currPos# gt 1>
								<cfset prevID = listGetAt(session.collObjIdList,currPos - 1)>
							</cfif>	
							<cfset lastID = listGetAt(session.collObjIdList,lenOfIdList)>
							<!--- should we have first? --->
							<cfif #lenOfIdList# gt 1>
								<cfif #currPos# gt 1>
									<cfset isPrev = "yes">
								</cfif>
								<cfif #currPos# lt #lenOfIdList#>
									<cfset isNext = "yes">
								</cfif>
							</cfif>
						<cfelse>
							<cfset isNext="">
							<cfset isPrev="">
						</cfif>
		                <ul id="navbar">
							<cfif #isPrev# is "yes">
								<img src="/images/first.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#firstID#'" />
								<img src="/images/previous.gif" class="likeLink"  onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#prevID#'" />
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
								<span onclick="switchIFrame('findContainer')"
									class="likeLink" id="findContainerSpan">Part Locn.</span>
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
								<span onclick="switchIFrame('MediaSearch')"
									class="likeLink" id="MediaSearchSpan">Media</span>
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
								<img src="/images/next.gif" class="likeLink"   onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#nextID#'"/>
								<img src="/images/last.gif"  class="likeLink"   onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#lastID#'"/>
							<cfelse>
								<img src="/images/no_next.gif" />
								<img src="/images/no_last.gif" />
							</cfif>
						</ul>
	                </form>
		        </td>
		    </tr>
		</table>
		<table width="100%">
			<tr>
				<td>
					<div id="fHolder">
						<iframe class="thisFrame" 
							style="border:none;width:100%;"
	                        id="theFrame" 
							name="theFrame" 
							src="/SpecimenDetail_body.cfm?collection_object_id=#collection_object_id#">
						</iframe>
					</div>
				</td>
			</tr>
		</table>
	<cfelse><!--- not coldfusion user --->
		<cfinclude template="SpecimenDetail_body.cfm">
	</cfif>	
<cfinclude template="/includes/_footer.cfm">
	<cfif isdefined("showAnnotation") and #showAnnotation# is "true">
		<script language="javascript" type="text/javascript">
			openAnnotation('collection_object_id=#collection_object_id#');
		</script>		
	</cfif>
</cfoutput>