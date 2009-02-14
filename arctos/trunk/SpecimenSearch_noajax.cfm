<cfif not isdefined("institution_appearance")>
	<cfset institution_appearance = "">
</cfif>
<cfinclude template="/includes/_header.cfm">

<script language="javascript" type="text/javascript">
self.name='SpecimenSearch';

function changeTarget(id,tvalue) {
	//alert('id:' + id);
	//alert('tvalue: ' + tvalue);
	//alert('len: ' +tvalue.length);
	if(tvalue.length == 0) {
		tvalue='SpecimenResults.cfm';
		//alert('tvalue manually set:' + tvalue);
	}
	if (id =='tgtForm1') {
		var otherForm = document.getElementById('tgtForm');
	} else {
		var otherForm = document.getElementById('tgtForm1');
	}
	otherForm.value =  tvalue;
	if (tvalue == 'SpecimenResultsSummary.cfm') {
		document.getElementById('groupByDiv').style.display='';
		document.getElementById('groupByDiv1').style.display='';
	} else {
		document.getElementById('groupByDiv').style.display='none';
		document.getElementById('groupByDiv1').style.display='none';
	}
	document.SpecData.action = tvalue;
}
function changeGrp(tid) {
	if (tid == 'groupBy') {
		var oid = 'groupBy1';
	} else {
		var oid = 'groupBy';
	}
	var mList = document.getElementById(tid);
	var sList = document.getElementById(oid);
	var len = mList.length;
	// uncheck everything in the other box
	for (i = 0; i < len; i++) {
		sList.options[i].selected = false;
	}
	// make em match
	for (i = 0; i < len; i++) {
		if (mList.options[i].selected) {
			sList.options[i].selected = true;
		}
	}
}
</script>
<cfset title="Specimen Search">




<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(collection_object_id) as cnt from cataloged_item
	<cfif len(#exclusive_collection_id#) gt 0>
		,collection
		WHERE cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_id = #exclusive_collection_id#
	</cfif>
</cfquery>
<!---
<span class="infoLink pageHelp" onclick="pageHelp('searching');">Page Help</span>			
--->		
	   <table width="75%" cellpadding="0" cellspacing="0">
	   	<tr><td colspan="4">
		 <p> <font size="+1">Access to
		<a href="javascript: void(0);" 
			onClick="getHelp('CollStats'); return false;"
			onMouseOver="self.status='Click for holdings detail.';return true;"
			onmouseout="self.status='';return true;"
			><cfoutput>#getCount.cnt#</cfoutput>
			</a> 
			</font>
			<cfif len(#exclusive_collection_id#) gt 0>
				<cfquery name="coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select collection,institution_acronym,collection_cde
					from collection where
					collection_id=#exclusive_collection_id#
				</cfquery>
				<cfoutput>#coll.collection#</cfoutput>
			records, or <a href="searchAll.cfm">all collections</a>.
			<cfelse>
			records.
			</cfif>
<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select SEARCH_NAME,URL
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username='#session.username#'
	order by search_name
</cfquery>
<cfif #hasCanned.recordcount# gt 0>
	<label for="goCanned">Saved Searches:</label>
	<select name="goCanned" id="goCanned" size="1" onchange="document.location=this.value;">
		<option value=""></option>
		<option value="saveSearch.cfm?action=manage">[ Manage ]</option>
		<cfoutput query="hasCanned">
			<option value="#url#">#SEARCH_NAME#</option><br />
		</cfoutput>
	</select>
</cfif>
		 
		 
		 
		 
		 

			
			
			
			
				
<cfif #action# is "dispCollObj">
	<p><font color="#FF0000" size="+2">You are searching for items to add to a loan.</font></p>
<cfelseif #action# is "encumber">
	<p><font color="#FF0000" size="+2">You are searching for items to encumber.</font></p>
<cfelseif #action# is "collEvent">
	<p><font color="#FF0000" size="+2">You are searching for items to change collecting event.</font></p>
<cfelseif #action# is "identification">
	<p><font color="#FF0000" size="+2">You are searching for items to reidentify.</font></p>
<cfelseif #action# is "addAccn">
	<p><font color="#FF0000" size="+2">You are searching for items to reaccession.</font></p>
</cfif>
		</td></tr>
</table>
<cfif #len(session.username)# is 0>
	<form name="logIn" method="post" action="/login.cfm">
	<input type="hidden" name="action" value="signIn">
	<input type="hidden" name="gotopage" value="SpecimenSearch.cfm">
	<div style="float:right; border: 2px solid ##0066FF; padding:2px; width:25%; ">
	<table cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td align="right">
				Username:&nbsp;
			</td>
			<td>
				<input type="text" name="username">
			</td>
		</tr>
		<tr>
			<td align="right">
				Password:&nbsp;
			</td>
			<td>
				 <input type="password" name="password">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" value="Log In" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
				<input type="button" value="Create Account" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
					onClick="logIn.action.value='newUser';submit();">
					<span class="infoLink" 
						onclick="pageHelp('customize');">What's this?</span>
			</td>
		</tr>
		<tr>
			
			<td colspan="2">
				<div class="infoBox">
					Logging in enables you to turn on, turn off, or otherwise customize many features of this database. To create an account and log in, simply supply a username and password here and click Create Account.
				</div>
			</td>
		</tr>
	</table>
	</div>
	</form>
</cfif>
<form method="post" action="SpecimenResults.cfm" name="SpecData">
<cfoutput>
<table border="0">
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn"
				onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">	
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td align="right" valign="top">
			<b>See results as:</b>
		</td>
		<td valign="top">
		 	<select name="tgtForm1" id="tgtForm1" size="1"  onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
				<cfif isdefined("session.username") AND (#session.username# is "link" OR #session.username# is "dusty")>
				<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("session.username") AND (#session.username# is "cindy" OR #session.username# is "dusty")>
				<option  value="/CustomPages/CindyBats.cfm">Cindy's Form</option>
				</cfif>
			</select>
		</td>
		<td align="left">
			<div id="groupByDiv1" style="display:none ">
				<font size="-1"><em><strong>Group by:</strong></em></font><br>
				<select name="groupBy1" id="groupBy1" multiple size="4" onchange="changeGrp(this.id)">
					<option value="">Scientific Name</option>
					<option value="continent_ocean">Continent</option>
					<option value="country">Country</option>
					<option value="state_prov">State</option>
					<option value="county">County</option>
					<option value="quad">Map Name</option>
					<option value="feature">Feature</option>
					<option value="island">Island</option>
					<option value="island_group">Island Group</option>
					<option value="sea">Sea</option>
					<option value="spec_locality">Specific Locality</option>
					<option value="yr">Year</option>
				</select>
			</div>
		</td>
	</tr>
</table>			
<input type="hidden" name="Action" value="#Action#">
<input type="hidden" name="institution_appearance" value="#institution_appearance#">
<input type="hidden" name="exclusive_collection_id" value="#exclusive_collection_id#">

</cfoutput>
<cfquery name="collections" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde from ctCollection_Cde order by collection_cde
</cfquery>
<table width="75%" cellspacing="2" cellpadding="4"><!--- outer table --->
		<tr>
			<td>
			<table>
				 <cfif #session.showObservations# is not 1>
				<tr>
					<td><strong>Show 
					<a href="javascript:void(0);" 
						onClick="getHelp('show_observations'); return false;"
						onMouseOver="self.status='Click for Observations help.';return true;"
						onmouseout="self.status='';return true;">Observations</a>?</strong>
						<input type="checkbox" 
							name="showObservations" 
							value="true">
					</td>
				</tr>
				</cfif>
				<tr>
					<td>
						<a href="javascript:alert('This \'tissues only\' flag is an 
								MVZ phenomenon; checking this box will preclude returning any 
								data from institutions other than the MVZ. Checking the box 
								will return all MVZ specimen records with a part designated as 
								tissue, which typically is a part collected for destructive sampling. 
								This may include \'tissue\' parts that no longer exist in the 
								collection (e.g., they have been used up).');">Tissues Only?</a>
					<input type="checkbox" 
							name="is_tissue" 
							value="1">
					</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td>
				<div class="group" align="left">
				<table cellpadding="0" cellspacing="0" width="100%">
					<tr>
					<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						SELECT institution_acronym, collection, collection_id FROM collection
						<cfif len(#exclusive_collection_id#) gt 0>
							WHERE collection_id = #exclusive_collection_id#
						</cfif>
						order by collection
					</cfquery>
			
					<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
						<cfset thisCollId = #collection_id#>
					<cfelse>
						<cfset thisCollId = "">
					</cfif>
					<td align="right" width="250" nowrap>
						<a href="javascript:void(0);" 
							onClick="pageHelp('SpecimenSearchFldDef','cat_num');">
							Institutional Catalog:
						</a>&nbsp;
					</td>
					<td>
						<select name="collection_id" size="1">
							<cfif len(#exclusive_collection_id#) is 0>
								<option value="">All</option>
							</cfif>
							<cfoutput query="ctInst">
								<option <cfif #thisCollId# is #ctInst.collection_id#>
							 		selected </cfif>
									value="#ctInst.collection_id#">
									#ctInst.collection#</option>
							</cfoutput>
						</select>				
					</td>
				</tr>
				<tr>
					<td align="right">
						Catalog Number:&nbsp;
					</td>
					<td align="left">
						<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
							<textarea name="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
						<cfelse>
							<input type="text" name="listcatnum" size="21">
						</cfif>
					</td>
				</tr>	
				<cfif len(#session.CustomOtherIdentifier#) gt 0>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);" 
								onClick="pageHelp('SpecimenSearchFldDef','custom_identifier');">
								<cfoutput>#session.CustomOtherIdentifier#:</cfoutput>
							</a>&nbsp;
							</td>
							<td align="left">
								<label for="CustomOidOper">Display Value</label>
								<select name="CustomOidOper" size="1">
							<option value="IS">is</option>
							<option value="" selected="selected">contains</option>
							<option value="LIST">in list</option>
							<option value="BETWEEN">in range</option>								
						  </select><input type="text" name="CustomIdentifierValue" size="50">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								&nbsp;
							</td>
							<td align="left">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td>
											<label for="custom_id_prefix">OR: Prefix</label>
											<input type="text" name="custom_id_prefix" id="custom_id_prefix" size="12">
										</td>
										<td>
											<label for="custom_id_number">Number</label>
											<input type="text" name="custom_id_number" id="custom_id_number" size="24">
										</td>
										<td>
											<label for="custom_id_suffix">Suffix</label>
											<input type="text" name="custom_id_suffix" id="custom_id_suffix" size="12">
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</cfif>
					<cfif len(#exclusive_collection_id#) gt 0>
						<cfset oidTable = "cCTCOLL_OTHER_ID_TYPE#exclusive_collection_id#">
					<cfelse>
						<cfset oidTable = "CTCOLL_OTHER_ID_TYPE">
					</cfif>
					<cfoutput>
					<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(other_id_type) FROM #oidTable# ORDER BY other_Id_Type
					</cfquery>
					</cfoutput>
					<tr>					
						<td align="right" width="250">
							<a href="javascript:void(0);" 
						<!--- onClick="getHelp('other_id_type'); return false;" --->
						onClick="pageHelp('other_id_type',''); return false;"
						onMouseOver="self.status='Click for Other ID help.';return true;" 
						onmouseout="self.status='';return true;">Other&nbsp;Identifier&nbsp;Type:</a>&nbsp;
						</td>
						<td align="left" nowrap="nowrap">
							<select name="OIDType" size="1"
								<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
									class="reqdClr" </cfif>>
								<option value=""></option>
								<cfoutput query="OtherIdType">
									<option 
										<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
											<cfif #OIDType# is #OtherIdType.other_id_type#>
												selected
											</cfif>
										</cfif>
										value="#OtherIdType.other_id_type#">#OtherIdType.other_id_type#</option>
								</cfoutput> 
					  		</select><span class="infoLink" 
					  				onclick="getCtDoc('ctcoll_other_id_type',SpecData.OIDType.value);">Define</span>
						</td>
					</tr>
					<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
					</cfquery>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);"
								onClick="pageHelp('other_id_number'); return false;"
								onMouseOver="self.status='Click for Other ID help.';return true;"
								onmouseout="self.status='';return true;">Other&nbsp;Identifying&nbsp;Number:</a>&nbsp;
						</td>
						<td align="left" valign="middle">
							<select name="oidOper" size="1">
							<option value="" selected="selected">contains</option>
							<option value="IS">is</option>
						  </select>
							<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
								<textarea name="OIDNum" rows="6" cols="30" wrap="soft"></textarea>
							<cfelse>
								<input type="text" name="OIDNum" size="34">
							</cfif>
						</td>
					</tr>
					<cfif #ListContains(session.searchBy, 'accn_num')# gt 0>	
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
									onClick="pageHelp('SpecimenSearchFldDef','accession');">
										Accession:
								</a>&nbsp;
							</td>
							<td align="left">
									<input type="text" name="accn_number" >
									<span class="smaller">&nbsp;Exact Match?</span> <input type="checkbox" name="exactAccnNumMatch" value="1">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								Accn. Agency:&nbsp;
							</td>
							<td>
								<input type="text" name="accn_agency" size="50" />
							</td>
						</tr>
					</cfif>
				</table>
				</div>
			</td>
		</tr>
		<tr>
			<td>
				<div class="group">
				<table cellpadding="0" cellspacing="0" width="100%">
					<tr>
						<td align="right" width="250">
							Any Taxonomic Element:&nbsp;
						</td>
						<td align="left">
							<input type="text" name="any_taxa_term" size="28">
						</td>
					</tr>
					<cfif #ListContains(session.searchBy, 'scientific_name')# gt 0>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);" 
										onClick="getHelp('scientific_name'); return false;"
										onMouseOver="self.status='Click for Scientific Name help.';return true;"
										onmouseout="self.status='';return true;">Scientific&nbsp;Name:&nbsp;
				  			</a>
						</td>
						<td align="left">
							<cfif #ListContains(session.searchBy, 'scinameoperator')# gt 0>
								<select name="sciNameOper" size="1">
									<option value="">contains</option>
									<option value="NOT LIKE">does not contain</option>
									<option value="=">is exactly</option>
									<option value="was">is/was/cited/related</option>
							  </select>
							</cfif>
							<input type="text" name="scientific_name" size="28">
						</td>
					</tr>
					</cfif>
					<cfif #ListContains(session.searchBy, 'scinameoperator')# gt 0>
					<tr>
						<td align="right"  width="250"><a href="javascript:void(0);" 
								onClick="getHelp('higher_taxa'); return false;"
								onMouseOver="self.status='Click for Taxonomy help.';return true;" 
								onmouseout="self.status='';return true;">Taxonomy:&nbsp;</a></td>
						<td align="left"><input type="text" name="HighTaxa" size="50"></td>
					</tr>
						<cfquery name="ctClass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							SELECT DISTINCT(phylclass) FROM ctclass ORDER BY phylclass
						</cfquery>
					<tr>
						<td align="right" width="250">
								Class:&nbsp;
						</td>
						<td align="left">
						 	<select name="phylclass" size="1">
									<option value=""></option>
									<cfoutput query="ctClass">
										<option value="#ctClass.phylclass#">#ctClass.phylclass#</option>
									</cfoutput>
								</select><span class="infoLink" 
					  				onclick="getCtDoc('ctclass',SpecData.phylclass.value);">Define</span>
						</td>
					</tr>
					<tr>
						<td align="right" width="250">
								<a href="javascript:void(0);"
									onClick="getHelp('common_name'); return false;"
									onMouseOver="self.status='Click for Common Name help.';return true;"
									onmouseout="self.status='';return true;">Common Name:&nbsp;
				  				</a>
						</td>
						<td align="left">
							<input name="Common_Name" type="text" size="50">
						</td>
					</tr>
						<cfquery name="ctNatureOfId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							SELECT DISTINCT(nature_of_id) FROM ctnature_of_id ORDER BY nature_of_id
						</cfquery>
					<tr>
						<td align="right" width="250">
								<a href="javascript:void(0);"
									onClick="getHelp('nature_of_id');">Nature of ID:&nbsp;
				  				</a>
						</td>
						<td align="left">
							<select name="nature_of_id" size="1">
									<option value=""></option>
									<cfoutput query="ctNatureOfId">
										<option value="#ctNatureOfId.nature_of_id#">#ctNatureOfId.nature_of_id#</option>
									</cfoutput>
								</select><span class="infoLink" 
					  				onclick="getCtDoc('ctnature_of_id',SpecData.nature_of_id.value);">Define</span>
						</td>
					</tr>
					</cfif>
					<cfif #ListContains(session.searchBy, 'identifier')# gt 0>
					<tr>
						<td align="right" width="250">
								<a href="javascript:void(0);" 
								onClick="getHelp('identifier'); return false;"
								onMouseOver="self.status='Click for Identifier help.';return true;" 
								onmouseout="self.status='';return true;">Identifier:&nbsp;</a>
								
						</td>
						<td align="left">
						 	<input type="text" name="identified_agent">
						</td>
					</tr>
					
					</cfif>
					
				</table>
				</div>
			</td>
		</tr>
		<tr>
			<td>
				<div class="group">
				<table cellpadding="0" cellspacing="0" width="100%">
					<cfif #ListContains(session.searchBy, 'locality')# gt 0>
						<cfquery name="ContOcean" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select continent_ocean from ctContinent ORDER BY continent_ocean
						</cfquery>
						<tr>
							<td align="right" width="250">
								Continent/Ocean:&nbsp;
							</td>
							<td align="left">
								<select name="continent_ocean" size="1">
										  <option value=""></option>
										  <cfoutput query="ContOcean"> 
											<option value="#ContOcean.continent_ocean#">#ContOcean.continent_ocean#</option>
										  </cfoutput> </select>
							</td>
						</tr>
						
						<cfquery name="Country" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(country) from geog_auth_rec order by country
						</cfquery>
						<tr>
							<td align="right" width="250">
								Country:&nbsp;
							</td>
							<td align="left">
								<select name="Country" size="1">
											<option value=""></option>
											<cfoutput query="Country">
												<option value="#Country.Country#">#Country.Country#</option>
											</cfoutput>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('state_prov'); return false;"
												onMouseOver="self.status='Click for State/Province help.';return true;"
												onmouseout="self.status='';return true;">State/Province:</a>&nbsp;
							</td>
							<td align="left">
								<input type="text" name="state_prov" size="50">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
								onClick="getHelp('quad'); return false;"
								onMouseOver="self.status='Click for Quad help.';return true;" 
								onmouseout="self.status='';return true;">Map Name:</a>&nbsp;
							</td>
							<td align="left" nowrap>
								<input type="text" name="Quad" size="50">
								<span class="infoLink" 
					  				onclick="getQuadHelp();">Choose</span>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
							onClick="getHelp('county'); return false;"
							onMouseOver="self.status='Click for County help.';return true;" 
							onmouseout="self.status='';return true;">County:</a>&nbsp;
							</td>
							<td align="left">
								<input type="text" name="County" size="50">
							</td>
						</tr>
						<cfquery name="IslGrp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select island_group from ctIsland_Group order by Island_Group
						</cfquery>
						<tr>
							<td align="right" width="250">
								Island Group:&nbsp;
							</td>
							<td align="left">
								<select name="island_group" size="1">
									  <option value=""></option>
									  <cfoutput query="IslGrp"> 
										<option value="#IslGrp.Island_Group#">#IslGrp.Island_Group#</option>
									  </cfoutput> 
								</select>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
										onClick="getHelp('island'); return false;"
										onMouseOver="self.status='Click for Island help.';return true;"
										onmouseout="self.status='';return true;">Island:</a>&nbsp;
							</td>
							<td align="left">
								<input type="text" name="Island" size="50">
							</td>
						</tr>
						<cfquery name="Feature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(Feature) from geog_auth_rec order by Feature
						</cfquery>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
									onClick="getHelp('feature'); return false;"
									onMouseOver="self.status='Click for Feature help.';return true;" 
									onmouseout="self.status='';return true;">Geographic Feature:&nbsp;</a>
							</td>
							<td align="left">
								<select name="Feature" size="1">
									<option value=""></option>
									<cfoutput query="Feature">
										<option value="#Feature.Feature#">#Feature.Feature#</option>
									</cfoutput>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
							onClick="getHelp('spec_locality'); return false;"
							onMouseOver="self.status='Click for Specific Locality help.';return true;" 
							onmouseout="self.status='';return true;">Specific&nbsp;Locality:</a>&nbsp;
							</td>
							<td align="left">
								<input type="text" name="spec_locality" size="50">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								Elevation:&nbsp;
							</td>
							<td align="left">
								<cfquery name="ctElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select orig_elev_units from CTORIG_ELEV_UNITS
								</cfquery>
								<input type="text" name="minimum_elevation" size="5"> - 
								<input type="text" name="maximum_elevation" size="5">
								<select name="orig_elev_units" size="1">
									<option value=""></option>
									<cfoutput query="ctElevUnits">
										<option value="#ctElevUnits.orig_elev_units#">#ctElevUnits.orig_elev_units#</option>
									</cfoutput>
								</select>
							</td>
						</tr>
					</cfif>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);" 
									onClick="getHelp('geog'); return false;"
									onMouseOver="self.status='Click for Geographic Element help.';return true;" 
									onmouseout="self.status='';return true;">Any&nbsp;Geographic&nbsp;Element:</a>&nbsp;
						</td>
						<td align="left">
							<input type="text" name="any_geog" size="50">
						</td>
					</tr>
						
					<cfif #ListContains(session.searchBy, 'collecting_source')# gt 0>	
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
										onClick="getHelp('collecting_source'); return false;"
										onMouseOver="self.status='Click for Collecting Source help.';return true;" 
										onmouseout="self.status='';return true;">Collecting Source:&nbsp;</a>									
							</td>
							<td align="left">
								<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select collecting_source from ctcollecting_source
								</cfquery>
								<select name="collecting_source" size="1">
									<option value=""></option>
									<cfoutput query="ctcollecting_source">
										<option value="#ctcollecting_source.collecting_source#">
											#ctcollecting_source.collecting_source#</option>
									</cfoutput>
								</select>
							</td>
						</tr>
					</cfif>
					<cfif #ListContains(session.searchBy, 'max_error_in_meters')# gt 0>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
										onClick="getHelp('max_error_in_meters'); return false;"
										onMouseOver="self.status='Click for Coordinate Error help.';return true;" 
										onmouseout="self.status='';return true;">Coordinate Error (meters):&nbsp;</a>					
							</td>
							<td align="left">
								<input type="text" name="max_error_in_meters">
							</td>
						</tr>
					</cfif>
				</table>
				</div>
			</td>
		</tr>
		<cfif #ListContains(session.searchBy, 'boundingbox')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="left" width="250" colspan="2">
									Bounding Box <font size="-1"><em>(You must provide coordinates for each corner in
									decimal latitude format.)</em></font>
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Northwest Corner:&nbsp;
								</td>
								<td align="left" nowrap>
									<strong><em>Latitude:</em></strong> <input type="text" name="nwLat" size="8">
									<strong><em>Longitude:</em></strong> <input type="text" name="nwlong" size="8">
									
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Southeast Corner:&nbsp;
								</td>
								<td align="left" nowrap>
									
									<strong><em>Latitude:</em></strong> <input type="text" name="selat" size="8">
									<strong><em>Longitude:</em></strong> <input type="text" name="selong" size="8">
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		<tr>
			<td>
				<div class="group">
					<table cellpadding="0" cellspacing="0" width="100%">
						<cfif #ListContains(session.searchBy, 'colls')# gt 0>			
							<tr>
								<td align="right" width="250">
										<a href="javascript:void(0);" 
											onClick="getHelp('collector'); return false;"
											onMouseOver="self.status='Click for Collector help.';return true;"
											onmouseout="self.status='';return true;">
												<img src="images/info.gif" border="0" alt="Help"></a>&nbsp;
										<select name="coll_role" size="1">
											<option value="" selected>Collector</option>
											<option value="p">Preparator</option>
										</select>&nbsp;
								</td>
								<td align="left">
									<input type="text" name="coll" size="50">
								</td>
							</tr>
						</cfif>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('year_collected'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Year Collected:</a>&nbsp;
							</td>
							<td align="left">
								<table  width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<input name="begYear" type="text" size="6">
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endYear.value=SpecData.begYear.value">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<input name="endYear" type="text" size="6">
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<cfif #ListContains(session.searchBy, 'dates')# gt 0>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('incl_date'); return false;"
												onMouseOver="self.status='Click for Date Search help.';return true;"
												onmouseout="self.status='';return true;">Inclusive Date Search?</a>&nbsp;
							</td>
							<td align="left">
								<input type="checkbox" name="inclDateSearch" value="yes">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('month_collected'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Month Collected:</a>&nbsp;
							</td>
							<td align="left">
								<table width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<select name="begMon" size="1">
												<option value=""></option>
												<option value="01">January</option>
												<option value="02">February</option>
												<option value="03">March</option>
												<option value="04">April</option>
												<option value="05">May</option>
												<option value="06">June</option>
												<option value="07">July</option>
												<option value="08">August</option>
												<option value="09">September</option>
												<option value="10">October</option>
												<option value="11">November</option>
												<option value="12">December</option>						
											</select>
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endMon.value=SpecData.begMon.value;">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<select name="endMon" size="1">
									<option value=""></option>
									<option value="01">January</option>
									<option value="02">February</option>
									<option value="03">March</option>
									<option value="04">April</option>
									<option value="05">May</option>
									<option value="06">June</option>
									<option value="07">July</option>
									<option value="08">August</option>
									<option value="09">September</option>
									<option value="10">October</option>
									<option value="11">November</option>
									<option value="12">December</option>						
								</select>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('day_collected'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Day Collected:</a>&nbsp;
							</td>
							<td align="left">
								<table width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<select name="begDay" size="1">
									<option value=""></option>
									<cfoutput>
										<cfloop from="1" to="31" index="day">
											<option value="#day#">#day#</option>
										</cfloop>
									</cfoutput>
								</select>
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endDay.value=SpecData.begDay.value;">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<select name="endDay" size="1">
									<option value=""></option>
									<cfoutput>
										<cfloop from="1" to="31" index="day">
											<option value="#day#">#day#</option>
										</cfloop>
									</cfoutput>
								</select>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('fulldate_collected'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Full Date Collected:</a>&nbsp;
							</td>
							<td align="left">
								<table width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<input name="begDate" type="text" size="15">
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endDate.value=SpecData.begDate.value;">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<input name="endDate" type="text" size="15">
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('month_in'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Month:</a>&nbsp;
							</td>
							<td align="left">
								<select name="inMon" size="4" multiple>
									<option value=""></option>
									<option value="'01'">January</option>
									<option value="'02'">February</option>
									<option value="'03'">March</option>
									<option value="'04'">April</option>
									<option value="'05'">May</option>
									<option value="'06'">June</option>
									<option value="'07'">July</option>
									<option value="'08'">August</option>
									<option value="'09'">September</option>
									<option value="'10'">October</option>
									<option value="'11'">November</option>
									<option value="'12'">December</option>						
					</select>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);"
												onClick="getHelp('verbatim_date'); return false;"
												onMouseOver="self.status='Click for Year Collected help.';return true;"
												onmouseout="self.status='';return true;">Verbatim Date:</a>&nbsp;
							</td>
							<td align="left">
								<input type="text" name="verbatim_date" size="50">		
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
										onClick="getHelp('chronological_extent'); return false;"
										onMouseOver="self.status='Click for Chronological Extent help.';return true;" 
										onmouseout="self.status='';return true;">Chronological Extent:&nbsp;</a>					
							</td>
							<td align="left">
								<input type="text" name="chronological_extent">
							</td>
						</tr>
						</cfif>						
					</table>
				</div>
			</td>
		</tr>
		
		
		<cfif #ListContains(session.searchBy, 'parts')# gt 0>
			<cfif len(#exclusive_collection_id#) gt 0>
				<cfset partTable = "cctspecimen_part_name#exclusive_collection_id#">
				<cfset presTable = "cCTSPECIMEN_PRESERV_METHOD#exclusive_collection_id#">
				<cfset pmodTable = "cCTSPECIMEN_PART_MODIFIER#exclusive_collection_id#">
			<cfelse>
				<cfset partTable = "ctspecimen_part_name">
				<cfset presTable = "CTSPECIMEN_PRESERV_METHOD">
				<cfset pmodTable = "CTSPECIMEN_PART_MODIFIER">
			</cfif>
			
			<cfoutput>
			<cfquery name="Part" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select part_name from #partTable# group by part_name order by part_name
			</cfquery>
			
			<cfquery name="pres" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select distinct(preserve_method) from #presTable#
				ORDER BY preserve_method
			</cfquery>
			<cfquery name="ctpart_mod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select distinct part_modifier from #pmodTable# order by part_modifier
			</cfquery>
			</cfoutput>
		<tr>
			<td>
				<div class="group">
					<table cellpadding="0" cellspacing="0" width="100%">
						<cfif isdefined("session.username") and (#session.username# is "dlm" OR #session.username# is "gordon")>
							<tr>
								<td align="right" width="250">
									Secret Part Searcher Thingy
								</td>
								<td align="left">
									<input type="text" name="srchParts" id="srchParts" />
								</td>
							</tr>
						</cfif>
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
							onClick="getHelp('parts'); return false;"
							onMouseOver="self.status='Click for Parts help.';return true;" 
							onmouseout="self.status='';return true;">Part:</a>&nbsp;
							</td>
							<td align="left">
								<select name="part_name"  
									<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
										multiple="multiple" size="5"
									<cfelse>
										size="1"
									</cfif>>
								  <option value=""></option>
								  <cfoutput query="Part"> 
									<option value="#Part.Part_Name#">#Part.Part_Name#</option>
								  </cfoutput> </select>
							<a class="info" href="javascript:void(0);">
								<span class="infoLink" 
					  				onclick="getCtDoc('ctspecimen_part_name',SpecData.part_name.value);">Define</span>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								 Preservation Method:&nbsp;
							</td>
							<td align="left">
								<select name="preserv_method" size="1">
							  <option value=""></option>
							  <cfoutput query="pres"> 
								<option value="#pres.preserve_method#">#pres.preserve_method#</option>
							  </cfoutput> </select>
							  <span class="infoLink" 
					  				onclick="getCtDoc('ctspecimen_preserv_method',SpecData.preserv_method.value);">Define</span>
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								 Part Modifier:&nbsp;
							</td>
							<td align="left">
								<select name="part_modifier" size="1">
							  <option value=""></option>
							  <cfoutput query="ctpart_mod"> 
								<option value="#ctpart_mod.part_modifier#">#ctpart_mod.part_modifier#</option>
							  </cfoutput> </select>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		</cfif>
		<cfif #ListContains(session.searchBy, 'images')# gt 0>
			<cfquery name="ctSubject" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select subject from ctbin_obj_subject
			</cfquery>
		<tr>
			<td>
			<div class="group">
				<table cellpadding="0" cellspacing="0" width="100%">
					<tr>
						<td align="right" width="250">
							Find items with images:&nbsp;
						</td>
						<td align="left">
							<input type="checkbox" name="onlyImages" value="yes">
						</td>
					</tr>
					<tr>
						<td align="right" width="250">
							 Image Subject:&nbsp;
						</td>
						<td align="left">
							<select name="subject" size="1">
							<option value=""></option>
							<cfoutput query="ctSubject">
								<option value="#ctSubject.subject#">#ctSubject.subject#</option>
							</cfoutput>
					  </select>
					   <span class="infoLink" 
					  		onclick="getCtDoc('ctbin_obj_subject',SpecData.subject.value);">Define</span>
						</td>
					</tr>
					<tr>
						<td align="right" width="250">
							 Image Description:&nbsp;
						</td>
						<td align="left">
							<input type="text" name="imgDescription" size="50">
						</td>
					</tr>
				</table>
			</div>
		</cfif>
		<!----
		<cfif #ListContains(session.searchBy, 'permit')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									 Permit Issued By:&nbsp;
								</td>
								<td align="left">
									<input name="permit_issued_by" type="text" size="50">
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									 Permit Issued To:&nbsp;
								</td>
								<td align="left">
									<input name="permit_issued_to" type="text" size="50">
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Permit Type:&nbsp;
								</td>
								<td align="left">
									<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
												select * from ctpermit_type
											</cfquery>
											<select name="permit_Type" size="1">
														<option value=""></option>
														<cfoutput query="ctPermitType">
															<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
														 </cfoutput>
													
										  </select>
									 
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Permit Number:&nbsp;
								</td>
								<td align="left">
									<input type="text" name="permit_num" size="50">
									 <span class="infoLink" 
					  					onclick="getHelp('get_permit_number');">Pick</span>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		---->
		<cfif #ListContains(session.searchBy, 'citation')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									Type Status:&nbsp;
								</td>
								<td align="left">
									<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
										select type_status from ctcitation_type_status
									</cfquery>
									<select name="type_status" size="1">
										<option value=""></option>
										<option value="any">Any</option>
										<option value="type">Any TYPE</option>
										<cfoutput query="ctTypeStatus">
											<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
										</cfoutput>
									</select>
									<span class="infoLink" 
					  					onclick="getCtDoc('ctcitation_type_status',SpecData.phylclass.value);">Define</span>									
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		<cfif #ListContains(session.searchBy, 'miscellaneous')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									Relationship:&nbsp;
								</td>
								<td align="left">
									<cfquery name="ctbiol_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
										select biol_indiv_relationship  from ctbiol_relations
									</cfquery>
									<select name="relationship" size="1">
										<option value=""></option>
										<cfoutput query="ctbiol_relations">
											<option value="#ctbiol_relations.biol_indiv_relationship#">
												#ctbiol_relations.biol_indiv_relationship#</option>
										</cfoutput>
									</select>								
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Derived Relationship:&nbsp;
								</td>
								<td align="left">
									<select name="derived_relationship" size="1">
										<option value=""></option>
											<option value="offspring of">
												offspring of</option>
									</select>								
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		<cfif #ListContains(session.searchBy, 'project')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									Accessioned By Project Name:&nbsp;
								</td>
								<td align="left" nowrap>
									<input type="text" name="project_name" size="50">									
									<span class="infoLink" 
					  					onclick="getHelp('get_proj_name');">Pick</span>	
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Loaned To Project Name:&nbsp;
								</td>
								<td align="left" nowrap>
									<input type="text" name="loan_project_name" size="50">
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Project Sponsor:&nbsp;
								</td>
								<td align="left" nowrap>
									<input type="text" name="project_sponsor" size="50">
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		<cfif #ListContains(session.searchBy, 'curatorial_stuff')# gt 0>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									 Permit Issued By:&nbsp;
								</td>
								<td align="left">
									<input name="permit_issued_by" type="text" size="50">
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									 Permit Issued To:&nbsp;
								</td>
								<td align="left">
									<input name="permit_issued_to" type="text" size="50">
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Permit Type:&nbsp;
								</td>
								<td align="left">
									<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
												select * from ctpermit_type
											</cfquery>
											<select name="permit_Type" size="1">
														<option value=""></option>
														<cfoutput query="ctPermitType">
															<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
														 </cfoutput>
													
										  </select>
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Permit Number:&nbsp;
								</td>
								<td align="left">
									<input type="text" name="permit_num" size="50">
									 <span class="infoLink" 
					  					onclick="getHelp('get_permit_number');">Pick</span>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="group">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td align="right" width="250">
									Barcode:&nbsp;
								</td>
								<td align="left" nowrap>
									<input type="text" name="barcode" size="50">
						
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Entered By:&nbsp;
								</td>
								<td align="left" nowrap>
									<input type="text" name="entered_by" size="50">
						
								</td>
							</tr>
							<tr>
								<td align="right" width="250">
									Disposition:&nbsp;
								</td>
								<cfquery name="ctCollObjDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select coll_obj_disposition from ctcoll_obj_disp
								</cfquery>
								<td align="left" nowrap>
									<select name="coll_obj_disposition" size="1">
										<option value=""></option>
										<cfoutput query="ctCollObjDisp">
											<option value="#ctCollObjDisp.coll_obj_disposition#">#ctCollObjDisp.coll_obj_disposition#</option>
										</cfoutput>									</select>
									
						
								</td>
							</tr>
							<tr>
								<td align="right" width="250">Print Flag:&nbsp;</td>
								<td>
									<select name="print_fg" size="1">
										<option value=""></option>
										<option value="1">Box</option>
										<option value="2">Vial</option>
									</select>
								</td>
							</tr>
							<tr>
								<td align="right" width="250">Entered Date:&nbsp;</td>
								<td>
									<input type="text" name="beg_entered_date" size="10" />-
									<input type="text" name="end_entered_date" size="10" />
								</td>
							</tr>
							<tr>
								<td align="right" width="250">Remarks:&nbsp;</td>
								<td>
									<input type="text" name="remark" size="50" />
								</td>
							</tr>
							<tr>
								<td align="right" width="250">Missing:&nbsp;</td>
								<td>
									<cfquery name="ctFlags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
										select flags from ctflags
									</cfquery>
									<select name="coll_obj_flags" size="1">
										<option value=""></option>
										<cfoutput>
										<cfloop query="ctFlags">
											<option value="#flags#">#flags#</option>
										</cfloop>
										</cfoutput>
									</select>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		</cfif>
		<cfif #ListContains(session.searchBy, 'attributes')# gt 0>
			<tr>
				<td align="center">
				<div class="group">
					<table border>
							<tr>
								<td>
								 <a href="javascript:void(0);" 
							onClick="windowOpener('/info/attributeHelpPick.cfm?attribute='+SpecData.attribute_type_1.value,'attPick','width=600,height=600, resizable,scrollbars'); return false;"
							onMouseOver="self.status='Click for Attributes help.';return true;" 
							onmouseout="self.status='';return true;">Attribute</a>
								</td>
								<td>Operator</td>
								<td>Value</td>
								<td>Units</td>
							</tr>
							<tr>
						  
						  <cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(attribute_type) from ctattribute_type order by attribute_type
						  </cfquery>
						  <td>
						  <select name="attribute_type_1" size="1">
							<option selected value=""></option>
								<cfoutput query="ctAttributeType">
									<option value="#ctAttributeType.attribute_type#">#ctAttributeType.attribute_type#</option>
								</cfoutput>
							
						  </select>
						  </td>
						  <td>
							<select name="attOper_1" size="1">
								<option selected value="">equals</option>
								<option value="like">contains</option>
								<option value="greater">greater than</option>
								<option value="less">less than</option>
							</select>
						  </td>
						  <td>
								<input type="text" name="attribute_value_1" size="20">
							  	<span class="infoLink" 
					  				onclick="windowOpener('/info/attributeHelpPick.cfm?attNum=1&attribute='+SpecData.attribute_type_1.value,'attPick','width=600,height=600, resizable,scrollbars');">
						  				Pick
								</span>		 
						 	</td>
						  
						  <td> <input type="text" name="attribute_units_1" size="6"></td>
						  </tr>
						  <tr>
							 <td>
							  <select name="attribute_type_2" size="1">
								<option selected value=""></option>
									<cfoutput query="ctAttributeType">
										<option value="#ctAttributeType.attribute_type#">#ctAttributeType.attribute_type#</option>
									</cfoutput>
								
							  </select>
						  </td>
						  <td>
							<select name="attOper_2" size="1">
								<option selected value="">equals</option>
								<option value="like">contains</option>
								<option value="greater">greater than</option>
								<option value="less">less than</option>
							</select>
						  </td>
						  <td> <input type="text" name="attribute_value_2" size="20">
						  <span class="infoLink" 
					  			onclick="windowOpener('/info/attributeHelpPick.cfm?attNum=2&attribute='+SpecData.attribute_type_2.value,'attPick','width=600,height=600, resizable,scrollbars');">
						  			Pick
							</span>
							</td>
						  <td> <input type="text" name="attribute_units_2" size="6"></td>
						
						 </tr>
						 <tr>
							 <td>
							  <select name="attribute_type_3" size="1">
								<option selected value=""></option>
									<cfoutput query="ctAttributeType">
										<option value="#ctAttributeType.attribute_type#">#ctAttributeType.attribute_type#</option>
									</cfoutput>
								
							  </select>
						  </td>
						  <td>
							<select name="attOper_3" size="1">
								<option selected value="">equals</option>
								<option value="like">contains</option>
								<option value="greater">greater than</option>
								<option value="less">less than</option>
							</select>
						  </td>
						  <td> <input type="text" name="attribute_value_3" size="20">
						  <span class="infoLink" 
					  			onclick="windowOpener('/info/attributeHelpPick.cfm?attNum=3&attribute='+SpecData.attribute_type_3.value,'attPick','width=600,height=600, resizable,scrollbars');">
						  			Pick
							</span>
							</td>
						  <td> <input type="text" name="attribute_units_3" size="6"></td>
						
						 </tr>
						 
						  </tr>
						   </table>
						   </div>
				</td>
			</tr>
			</cfif>
			<tr>
				<td align="left">
				
<table>
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn"
   				onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td valign="top" align="right">
			<b>See results as:</b>
		</td>
		<td align="left" colspan="2" valign="top">
			<select name="tgtForm" id="tgtForm" size="1" onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
				<cfif isdefined("session.username") AND (#session.username# is "link" OR #session.username# is "dusty")>
				<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("session.username") AND (#session.username# is "cindy" OR #session.username# is "dusty")>
				<option  value="/CustomPages/CindyBats.cfm">Cindy's Form</option>
				</cfif>
			</select>
		</td>
		<td align="left">
			<div id="groupByDiv" style="display:none ">
			<font size="-1"><em><strong>Group by:</strong></em></font><br>
			<select name="groupBy" id="groupBy" multiple size="4" onchange="changeGrp(this.id)">
				<option value="">Scientific Name</option>
				<option value="continent_ocean">Continent</option>
				<option value="country">Country</option>
				<option value="state_prov">State</option>
				<option value="county">County</option>
				<option value="quad">Map Name</option>
				<option value="feature">Feature</option>
				<option value="island">Island</option>
				<option value="island_group">Island Group</option>
				<option value="sea">Sea</option>
				<option value="spec_locality">Specific Locality</option>
				<option value="yr">Year</option>
			</select>
			</div>
		</td>
</tr>
</table>
		</td>
			</tr>
			</table>
		
			
 
  <cfif isdefined("transaction_id") and len(#transaction_id#) gt 0>
		 <cfoutput><input type="hidden" name="transaction_id" value="#transaction_id#">
		   </cfoutput> 
	</cfif>


	
  <input type="hidden" name="newQuery" value="1"><!--- pass this to the next form so we clear the cache and run the proper queries--->
</form>
<script type='text/javascript' language='javascript'>
	var tval = document.getElementById('tgtForm').value;
	changeTarget('tgtForm',tval);
	changeGrp('groupBy');
</script>

<cfif len(#institution_appearance#) gt 0>
	<cf_get_footer institution="#institution_appearance#">
<cfelse>
	<cfinclude template = "includes/_footer.cfm">
</cfif>

