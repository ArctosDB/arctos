<cfinclude template="/includes/_header.cfm">
	<script>
		jQuery(document).ready(function() {
			$.each($("div[id^='mapgohere-']"), function() {
				var theElemID=this.id;
				var theIDType=this.id.split('-')[1];
				var theID=this.id.split('-')[2];
			  	var ptl='/component/functions.cfc?method=getMap&showCaption=false&returnformat=plain&size=150x150&' + theIDType + '=' + theID;
			    jQuery.get(ptl, function(data){
					jQuery("#" + theElemID).html(data);
				});
			});
		});
	</script>
<style>
	#annotateSpace {
		font-size:small;
		padding-left:1em;
	}
	#SDheaderCollCatNum {
		font-size:x-large;
		font-weight:bold;
	}
	#SDheaderCustID {
		font-size:large;
		font-weight:bold;
		padding-left:.5em;
	}
	#SDheaderSciName {
		font-size:larger;
		font-weight:bold;
		font-style:italic;
		padding-left:.5em;
	}
	#SDheaderSpecLoc {
		font-weight:bold;
	}
	#SDheaderGeog {
	}
	#SDheaderDate {
	}
	#navSpace {
		border:1px solid green;
		text-align:center;
		max-width:10em;
	}
	#SDheaderMap {
		padding-left:1em;
	}
	#SDheaderPart {
		padding-left:.5em;
		font-size:small;
	}
	#SDCollCatBlk {
		padding-right:.5em;
	}
	#SDheaderGoBakBtn {
border:0px solid red;
font-size:smaller;
font-weight:bold;

}
</style>
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
			<cfset sql="select collection_object_id from
					#session.flatTableName#
				WHERE
					upper(guid)='#ucase(guid)#'">
			<cfset checkSql(sql)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	SELECT
		#session.flatTableName#.collection,
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
									#detail.collection#&nbsp;#detail.cat_num#
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
		    <td valign="top" align="right">
		        <div id="annotateSpace">
					<cfif len(session.username) gt 0>
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
					<cfelse>
						<a href="/login.cfm">Login&nbsp;or&nbsp;Create&nbsp;Account</a>
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
				links+='<li><span onclick="loadEditApp(\'MediaSearch\')" class="likeLink" id="BTN_MediaSearch">Media</span></li>';
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
							<li><span onclick="loadEditApp('editIdentification')" class="likeLink" id="BTN_editIdentification">Taxa</span></li>
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
								<span onclick="loadEditApp('MediaSearch')"	class="likeLink" id="BTN_MediaSearch">Media</span>
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