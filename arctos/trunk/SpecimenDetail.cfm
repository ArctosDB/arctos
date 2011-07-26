<cfinclude template="/includes/_header.cfm">
<cfif isdefined("collection_object_id")>
	<cfset checkSql(collection_object_id)>
	<cfoutput>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cfset detSelect = "
	SELECT DISTINCT
		#session.flatTableName#.collection,
		#session.flatTableName#.collection_id,
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
	<cfset title="#detail.collection# #detail.cat_num#: #detail.scientific_name#">
	<cfset metaDesc="#detail.collection# #detail.cat_num# (#guid#); #detail.scientific_name#; #detail.higher_geog#; #detail.spec_locality#">
	<cf_customizeHeader collection_id=#detail.collection_id#>
</cfoutput>
<cfoutput query="detail" group="cat_num">
    <table>
        <tr>
		    <td nowrap valign="top">
				<font size="+1"><strong>#collection#&nbsp;#cat_num#</strong></font>
				<cfif len(web_link) gt 0>
					<a href="#web_link#" target="_blank"><img src="/images/linkOut.gif" border="0" alt="#web_link_text#"></a>
				</cfif>
				<cfif len(session.CustomOtherIdentifier) gt 0>
					<br>&nbsp;&nbsp;&nbsp;#session.CustomOtherIdentifier#: #CustomID#
				</cfif>						
				<br>
				<cfset sciname = '#replace(Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
				<span style="font-size:larger;font-weight:bold;font-style:italic">
					&nbsp;#sciname#
				</span>
				 <cfif (len(dec_lat) gt 0 and len(dec_long) gt 0)>
				    <cfif encumbrance_action does not contain "coordinates" OR
						(isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>						
					    <br><a href="/bnhmMaps/bnhmMapData.cfm?collection_object_id=#collection_object_id#" target="_blank" class="external">BerkeleyMapper</a>
					    <img src="/images/info.gif" border="0" onClick="getDocs('maps')" class="likeLink">
	                </cfif>
				</cfif>
		    </td>
		    <td valign="top">
			    <strong><em>#spec_locality#</em></strong>
				<br><strong>#higher_geog#</strong>
				<cfif encumbrance_action does not contain "year collected" OR
					(isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>					
			        <cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
						<cfset thisDate = verbatim_date>
					<cfelseif (
							(verbatim_date is not began_date) OR
					 		(verbatim_date is not ended_date)
						)
						AND
						began_date is ended_date>
						<cfset thisDate = "#verbatim_date# (#began_date#)">
					<cfelse>
						<cfset thisDate = "#verbatim_date# (#began_date# - #ended_date#)">
					</cfif>
                <cfelse>
			        <cfif began_date is ended_date>
				        <cfset thisDate = replace(began_date,left(began_date,4),"8888")>
			        <cfelse>
				        <cfset thisDate = '#replace(began_date,left(began_date,4),"8888")#-&nbsp;#replace(ended_date,left(ended_date,4),"8888")#'>
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
					<cfif len(session.username) gt 0>
						<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select count(*) cnt from annotations
							where collection_object_id = #collection_object_id#
						</cfquery>
						<span class="likeLink" onclick="openAnnotation('collection_object_id=#collection_object_id#')">
							[&nbsp;Report&nbsp;Bad&nbsp;Data&nbsp;]	
						</span>
						<cfif existingAnnotations.cnt gt 0>
							<br>(#existingAnnotations.cnt# existing)
						</cfif>
					<cfelse>
						<a href="/login.cfm">Login or Create Account</a>
					</cfif>
					<cfif isdefined("session.mapURL") and len(session.mapURL) gt 0>
						<br><a href="/SpecimenResults.cfm?#session.mapURL#">[&nbsp;Return&nbsp;to&nbsp;results&nbsp;]</a>
					</cfif>	
                </span>
            </td>
        </tr>
    </table>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<script language="javascript" type="text/javascript">
			//$(document).ready(function() { 
			//    document.body.onselectstart = function() {return false;} 
			//    $('##popDiv').animaDrag(); 
			//}); 
			
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
				links+='<li><span onclick="loadEditApp(\'editIdentification\')" class="likeLink" id="BTN_editIdentification">Taxa</span></li>';
				links+='<li><span onclick="loadEditApp(\'addAccn\')" class="likeLink" id="BTN_addAccn">Accn</span></li>';
				links+='<li><span onclick="loadEditApp(\'changeCollEvent\')" class="likeLink" id="BTN_changeCollEvent">PickEvent</span></li>';
				links+='<li><span onclick="loadEditApp(\'specLocality\')" class="likeLink" id="BTN_specLocality">Locality</span></li>';
				links+='<li><span onclick="loadEditApp(\'editColls\')" class="likeLink" id="BTN_editColls">Agents</span></li>';
				links+='<li><span onclick="loadEditApp(\'editRelationship\')" class="likeLink" id="BTN_editRelationship">Relations</span></li>';
				links+='<li><span onclick="loadEditApp(\'editParts\')" class="likeLink" id="BTN_editParts">Parts</span></li>';
				links+='<li><span onclick="loadEditApp(\'findContainer\')" class="likeLink" id="BTN_findContainer">PartLocn</span></li>';
				links+='<li><span onclick="loadEditApp(\'editBiolIndiv\')" class="likeLink" id="BTN_editBiolIndiv">Attributes</span></li>';
				links+='<li><span onclick="loadEditApp(\'editIdentifiers\')" class="likeLink" id="BTN_editIdentifiers">OtherID</span></li>';
				links+='<li><span onclick="loadEditApp(\'MediaSearch\')" class="likeLink" id="BTN_MediaSearch">Media</span></li>';
				links+='<li><span onclick="loadEditApp(\'Encumbrances\')" class="likeLink" id="BTN_Encumbrances">Encumbrance</span></li>';
				links+='<li><span onclick="loadEditApp(\'catalog\')" class="likeLink" id="BTN_catalog">Catalog</span></li>';
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
						<cfif isdefined("session.collObjIdList") and len(session.collObjIdList) gt 0>
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
						<cfelse>
							<cfset isNext="">
							<cfset isPrev="">
						</cfif>
						<ul id="navbar">
							<cfif isPrev is "yes">
								<img src="/images/first.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#firstID#'" alt="[ First Record ]">
								<img src="/images/previous.gif" class="likeLink"  onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#prevID#'" alt="[ Previous Record ]">
							<cfelse>
								<img src="/images/no_first.gif" alt="[ inactive button ]">
								<img src="/images/no_previous.gif" alt="[ inactive button ]">
							</cfif>		
							<li><span onclick="loadEditApp('editIdentification')" class="likeLink" id="BTN_editIdentification">Taxa</span></li>
							<li>
								<span onclick="loadEditApp('addAccn')"	class="likeLink" id="BTN_addAccn">Accn</span>
							</li>
							<li>
								<span onclick="loadEditApp('changeCollEvent')" class="likeLink" id="BTN_changeCollEvent">Pick New Coll Event</span>
							</li>
							<li>
								<span onclick="loadEditApp('specLocality')" class="likeLink" id="BTN_specLocality">Locality</span>
							</li>
							<li>
								<span onclick="loadEditApp('editColls')" class="likeLink" id="BTN_editColls">Agents</span>
							</li>
							<li>
								<span onclick="loadEditApp('editRelationship')" class="likeLink" id="BTN_editRelationship">Relations</span>
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
								<span onclick="loadEditApp('MediaSearch')"	class="likeLink" id="BTN_MediaSearch">Media</span>
							</li>
							<li>
								<span onclick="loadEditApp('Encumbrances')" class="likeLink" id="BTN_Encumbrances">Encumbrances</span>
							</li>
							<li>
								<span onclick="loadEditApp('catalog')" class="likeLink" id="BTN_catalog">Catalog</span>
							</li>
							<cfif isNext is "yes">
								<img src="/images/next.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#nextID#'" alt="[ Next Record ]">
								<img src="/images/last.gif" class="likeLink" onclick="document.location='/SpecimenDetail.cfm?collection_object_id=#lastID#'" alt="[ Last Record ]">
							<cfelse>
								<img src="/images/no_next.gif" alt="[ inactive button ]">
								<img src="/images/no_last.gif" alt="[ inactive button ]">
							</cfif>
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