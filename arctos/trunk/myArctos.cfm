<cfif len(#client.username#) is 0>
	<cflocation url="login.cfm">
</cfif>


<cfinclude template = "includes/_header.cfm">
<script type='text/javascript' src='/includes/_myArctos.js'></script>
<!--- no security required to access this page --->
<!---
<span class="pageHelp">
	<a href="javascript:void(0);" 
		onClick="pageHelp('customize'); return false;"
		onMouseOver="self.status='Click for Customization help.';return true;"
		onmouseout="self.status='';return true;"><img src="/images/what.gif" border="0">
	</a>					
</span>
--->
<!------------------------------------------------------>
	<cfif #action# is "update">
	<!---- clear client settings --->
	<cfset client.target = "">
	<cfset client.displayrows = "">
	<cfset client.mapSize = "">
	<cfset client.searchBy="">
	<cfset client.killrow="">
	<cfset client.showObservations="">
	<cfset client.active_loan_id="">
	<cfset client.customOtherIdentifier="">
	<cfset client.exclusive_collection_id="">
	
	<!--- update user_prefs then re-query to get fresh data for display --->
		<cfoutput>
			<cfquery name="updateUserPrefs" datasource="#Application.web_user#">
				UPDATE cf_users SET
					username = '#username#'
					<cfif isdefined("target")>
						,target = '#target#'
					<cfelse>
						,target=null
					</cfif>
					<cfif isdefined("displayrows")>
						,displayrows = #displayrows#
					<cfelse>
						,displayrows=null
					</cfif>
					<cfif isdefined("mapsize")>
						,mapsize = '#mapsize#'
					<cfelse>
						,mapsize=null
					</cfif>
					<cfif isdefined("active_loan_id")>
						,active_loan_id = '#active_loan_id#'
					<cfelse>
						,active_loan_id=null
					</cfif>
					<cfif isdefined("Parts")>
						,parts = #Parts#
					<cfelse>
						,parts=null
					</cfif>
					<cfif isdefined("images")>
						,images = #images#
					<cfelse>
						,images=null
					</cfif>
					<cfif isdefined("locality")>
						,locality = #locality#
					<cfelse>
						,locality=null
					</cfif>
					<cfif isdefined("Accn_Num")>
						,Accn_Num = #Accn_Num#
					<cfelse>
						,Accn_Num=null
					</cfif>
					<cfif isdefined("Higher_Taxa")>
						,Higher_Taxa = #Higher_Taxa#
					<cfelse>
						,Higher_Taxa=null
					</cfif>
					<!---
					<cfif isdefined("permit")>
							,permit = '#permit#'
					<cfelse>
						,permit=null
					</cfif>
					---->
					<cfif isdefined("miscellaneous")>
							,miscellaneous = '#miscellaneous#'
					<cfelse>
						,miscellaneous=null
					</cfif>
					<cfif isdefined("citation")>
							,citation = '#citation#'
					<cfelse>
						,citation=null
					</cfif>
					<cfif isdefined("project")>
							,project = '#project#'
					<cfelse>
						,project=null
					</cfif>
					<cfif isdefined("attributes")>
							,attributes = '#attributes#'
					<cfelse>
						,attributes=null
					</cfif>		
					<cfif isdefined("phylclass")>
							,phylclass = '#phylclass#'
					<cfelse>
						,phylclass=null
					</cfif>							
					<cfif isdefined("scinameoperator")>
							,scinameoperator = '#scinameoperator#'
					<cfelse>
						,scinameoperator=null
					</cfif>		
					<cfif isdefined("dates")>
							,dates = '#dates#'
					<cfelse>
						,dates=null
					</cfif>			
					<cfif isdefined("detail_level")>
							,detail_level = '#detail_level#'
					<cfelse>
						,detail_level=null
					</cfif>
					<cfif isdefined("curatorial_stuff")>
							,curatorial_stuff = '#curatorial_stuff#'
					<cfelse>
						,curatorial_stuff=null
					</cfif>	
					<cfif isdefined("identifier")>
							,identifier = '#identifier#'
					<cfelse>
						,identifier=null
					</cfif>		
					<cfif isdefined("boundingbox")>
							,boundingbox = '#boundingbox#'
					<cfelse>
						,boundingbox=null
					</cfif>	
					<cfif isdefined("bigsearchbox")>
							,bigsearchbox = '#bigsearchbox#'
					<cfelse>
						,bigsearchbox=null
					</cfif>	
					<cfif isdefined("killrow")>
							,killrow = '#killrow#'
					<cfelse>
						,killrow=null
					</cfif>
					<cfif isdefined("collecting_source")>
						,collecting_source = #collecting_source#
					<cfelse>
						,collecting_source=null
					</cfif>
					<cfif isdefined("scientific_name")>
						,scientific_name = #scientific_name#
					<cfelse>
						,scientific_name=null
					</cfif>	
					<cfif isdefined("customOtherIdentifier")>
						,customOtherIdentifier = '#Client.CustomOtherIdentifier#'
					<cfelse>
						,customOtherIdentifier=null
					</cfif>	
					<cfif isdefined("max_error_in_meters")>
						,max_error_in_meters = '#max_error_in_meters#'
					<cfelse>
						,max_error_in_meters=null
					</cfif>	
					<cfif isdefined("showObservations")>
						,showObservations = '#showObservations#'
					<cfelse>
						,showObservations=null
					</cfif>	
					<cfif isdefined("exclusive_collection_id")>
						,exclusive_collection_id = '#exclusive_collection_id#'
					<cfelse>
						,exclusive_collection_id=null
					</cfif>									
				WHERE username = '#username#'
			</cfquery>
		</cfoutput>
		
		<cfinclude template="/includes/setPrefs.cfm">
	
		<cfif not isdefined("gotopage")>
			<cfset gotopage = "/myArctos.cfm">
		</cfif>
		<cflocation url="#gotopage#">
</cfif>
<!------------------------------------------------------------>
<span class="infoLink pageHelp" onclick="pageHelp('customize');">Page Help</span>
	<cfif #action# is "nothing">
	
		<cfquery name="getPrefs" datasource="#Application.web_user#">
		select * from cf_users, user_loan_request
		 where  cf_users.user_id = user_loan_request.user_id (+) and
		 username = '#username#' order by cf_users.user_id
	</cfquery>
	<cfif getPrefs.recordcount is 0>
		<cflocation url="login.cfm?action=signOut">
	</cfif>
<!---- set preferences --->
<cfinclude template="/includes/setPrefs.cfm">
<cfquery name="isInv" datasource="#Application.uam_dbo#">
	select allow from temp_allow_cf_user where user_id=#getPrefs.user_id#
</cfquery>
	<cfoutput query="getPrefs" group="user_id">
	<h2>Welcome back, <b>#getPrefs.username#</b>!</h2>
				<ul>
					<li>
						<a href="ChangePassword.cfm">Change your password</a>
						<cfset pwtime =  round(now() - getPrefs.pw_change_date)>
						<cfset pwage = Application.max_pw_age - pwtime>
						<cfif pwage lte 0>
							<cfset client.force_password_change = "yes">
							<cflocation url="ChangePassword.cfm">
						<cfelseif pwage lte 10>
							<span style="color:red;font-weight:bold;">
								Your password expires in #pwage# days.
							</span>
						</cfif>
						
					</li>
					<li>
						Review some <a href="http://curator.museum.uaf.edu/UAM/" target="_blank">sample searches</a> to learn about the power of Arctos.
					</li>
				</ul>
				
				<cfif #isInv.allow# is 1>
				<div style="background-color:##FF0000; border:2px solid black; width:75%;">
					<strong>Attention Power User:</strong>
					<br />
					The Arctos security model has changed. You must <a href="user/db_user_setup.cfm?unm=#username#">follow this link</a>
					and complete the registration process to retain your curatorial role. You may be required to change your password.
					Once you complete <a href="/user/db_user_setup.cfm?unm=#username#">the form</a>, you will be redirected here. This box will not
					 appear if you've successfully authenticated.
					 <p>
					 This process is necessary to improve Arctos security. We apologize for the inconvenience.
					 </p>
				</div>
				<cfelseif #isInv.allow# is 2>
					<div style="background-color:##00FF00; border:2px solid black; width:75%;">
						You have successfully authenticated your Arctos username. We'll take care of the rest. Thank you!
					</div>
					<cfmail to="dustymc@gmail.com" from="oracleuser@#Application.fromEmail#" subject="account needed">
						#client.username# has set up an Oracle account and awaits blessings.
					</cfmail>			
				</cfif>
	
	<br>Changing values on this form will affect your search screen, results, and how data are presented.
			
			<!----
				<a href="/user/user_project.cfm">loans</a>
			</li>
			---->
			
	<table cellspacing="0" cellpadding="0">
		<tr>
			<td>
			
				

<table style="border:2px solid black; padding:2px;"><!--- outer table --->

		
<form action="myArctos.cfm" method="post" name="globals">
	<input name="action" type="hidden" value="update">
	<input type="hidden" value="#username#" name="username">
	<input type="hidden" value="#password#" name="password">
	

<tr>
	<td colspan="3"><!--- upper cell --->
	
	
		<table>
			<tr>
				<td align="right">
					<strong>Links:</strong>
				</td>
				 <td> 
				 	<select name="target" id="target" 
				 		size="1" onchange="this.className='red';changeTarget(this.value);">
					  <option 
						<cfif #target# is "_blank"> selected </cfif>value="_blank">Open some links in a new window</option>
					  <option <cfif #target# is "_top"> selected </cfif>value="_top">Open everything in the same window</option>
					</select> 
				</td>
			</tr>
			<tr> 
				<td><div align="right">Records per page:</div></td>
				<td> <select name="displayRows" id="displayRows" 
						onchange="this.className='red';changedisplayRows(this.value);" size="1">
						  <option  <cfif #displayRows# is "10"> selected </cfif> value="10">10</option>
						  <option  <cfif #displayRows# is "20"> selected </cfif> value="20" >20</option>
						  <option  <cfif #displayRows# is "50"> selected </cfif> value="50">50</option>
						  <option  <cfif #displayRows# is "100"> selected </cfif> value="100">100</option>
						</select> 
				</td>
			</tr>
			<cfquery name="collections" datasource="#Application.web_user#">
					select collection_id,institution_acronym || ' ' || collection_cde as coll from collection
					 order by institution_acronym,collection_cde
				</cfquery>
			
			<tr>
				<td><div align="right"><a href="javascript:void(0);" 
									onClick="getHelp('collection'); return false;">
									Collection:</a> </div></td>
				<cfquery name="collid" datasource="#Application.web_user#">
					select collection_id,institution_acronym || ' ' || collection_cde as coll from collection
					 order by institution_acronym,collection_cde
				</cfquery>
				<cfset allCollections = "#valuelist(collections.coll,",")#">
			   <cfif len(#getPrefs.exclusive_collection_id#) gt 0>
			   		<cfset thisCollId = #getPrefs.exclusive_collection_id#>
				<cfelseif len(#client.exclusive_collection_id#) gt 0>
					<cfset thisCollId = #client.exclusive_collection_id#>
				<cfelse>
					<cfset thisCollId = "">
			   </cfif>
				<td><select name="exclusive_collection_id" id="exclusive_collection_id"
						onchange="this.className='red';changeexclusive_collection_id(this.value);" size="1">
			  <option value="">All</option>
			  <cfloop query="collid"> 
				<option <cfif #thisCollId# is "#collid.collection_id#"> selected </cfif> value="#collid.collection_id#">#collid.coll#</option>
			  </cfloop> 
			</select>
				</td>
			</tr>
			<tr>
				<td><div align="right">Show Observations?</div></td>
				<td>  
					<input type="checkbox" style="margin:5px solid red;"
						name="showObservations" 
						onchange="changeshowObservations(this.checked);"
						value="1"<cfif #showObservations# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr> 
				<td><div align="right">
				<a href="javascript:void(0);" 
									onClick="getHelp('customOtherIdentifier'); return false;"
									onMouseOver="self.status='Click for help.';return true;" 
									onmouseout="self.status='';return true;">
									Your Other Identifier:</a>
									</div></td>
				<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
					select distinct(other_id_type) from ctColl_other_id_type order by other_id_type
				</cfquery>
				
				<td> <select name="customOtherIdentifier" id="customOtherIdentifier"
						onchange="this.className='red';changecustomOtherIdentifier(this.value);" size="1">
			  			<option value="">None</option>
						 <cfloop query="ctOtherIdType">
						 	<option 
								<cfif #Client.CustomOtherIdentifier# is #other_id_type#>
									selected 
								</cfif>value="#other_id_type#">#other_id_type#</option>
						 </cfloop>
					</select>
				</td>
			</tr>
			<tr> 
				<td><div align="right"><a href="javascript:void(0);" 
										class="novisit"
										onClick="getHelp('detail_level'); return false;"
										onMouseOver="self.status='Click for Detail Level help.';return true;" 
										onmouseout="self.status='';return true;">Default Detail Level</a>: </div></td>
				<td colspan="2" align="left">
				<table>
							<tr>
								<td><font size="-1">Less Detail</font></td>
								<td>
									<input type="radio" name="detail_level" value="1" 
											onclick="changedetail_level(this.value)"
									<cfif #detail_level# is 1>
										checked
									</cfif>>
								 
								</td>
								<td>
									<input type="radio" name="detail_level" value="2"
											onclick="changedetail_level(this.value)"
									<cfif #detail_level# is 2>
										checked
									</cfif>>
								</td>
								<td>
									<input type="radio" name="detail_level" value="3"
											onclick="changedetail_level(this.value)"
									<cfif #detail_level# is 3>
										checked
									</cfif>>
								</td>
								<td>
									<input type="radio" name="detail_level" value="4"
											onclick="changedetail_level(this.value)"
									<cfif #detail_level# is 4>
										checked
									</cfif>>
								</td>
								<td><font size="-1">More Detail</font></td>
							</tr>
					  </table>
		 
				</td>
			</tr>
			
			
	</table>
	</td>
	
</tr>
<tr>
	<td><!---- bottom left table ---->
		<div style="background-color:##EFEFEF; border: 3px solid ##999999">
		<strong>Geography</strong>
		<table>
			
			
			<tr>
				<td align="right">
					 Locality
				</td>
				<td>
				  <input type="checkbox" name="locality" id="locality"
				  	onclick="setSrchVal(this.id, this.checked)" value="1"<cfif #locality# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Collecting Source
				</td>
				<td>
				  <input type="checkbox" 
				  		onclick="setSrchVal(this.id, this.checked)"
				  		id = "collecting_source" name="collecting_source" value="1"<cfif #collecting_source# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);"
						class="novisit" 
						onClick="getHelp('bounding_box'); return false;"
						onMouseOver="self.status='Click for Bounding Box help.';return true;" 
						onmouseout="self.status='';return true;">Bounding&nbsp;Box</a>
				</td>
				<td>
				  <input type="checkbox" 
				  		onclick="setSrchVal(this.id, this.checked)"
				  		id="boundingbox"
				  		name="boundingbox" value="1"<cfif #boundingbox# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);"
						class="novisit" 
						onClick="getHelp('max_error_in_meters'); return false;"
						onMouseOver="self.status='Click for Maximum Error help.';return true;" 
						onmouseout="self.status='';return true;">Maximum Error:&nbsp;</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="max_error_in_meters"
				  	name="max_error_in_meters" value="1"<cfif #max_error_in_meters# eq 1> CHECKED </cfif> >
				</td>
			</tr>
		</table>
		</div>
	</td>
	<td valign="top">
		<div style="background-color:##EFEFEF; border: 3px solid ##999999">
		<strong>Taxonomy&nbsp;and&nbsp;Identification</strong>
		<table>
			<!---
			<tr>
				<td align="right">
					<a href="javascript:void(0);"
						class="novisit" 
								onClick="getHelp('higher_taxa'); return false;"
								onMouseOver="self.status='Click for Taxonomy help.';return true;" 
								onmouseout="self.status='';return true;">Full&nbsp;Taxonomy</a>
				</td>
				<td>
				  <input type="checkbox" name="Higher_Taxa" value="1"<cfif #Higher_Taxa# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Class
				</td>
				<td>
				  <input type="checkbox" name="Phylclass" value="1"<cfif #Phylclass# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			--->
			<tr>
				<td align="right">
					 <a href="javascript:void(0);"
						class="novisit" 
										onClick="getHelp('scientific_name'); return false;"
										onMouseOver="self.status='Click for Scientific Name help.';return true;"
										onmouseout="self.status='';return true;">Scientific Name&nbsp;
				  			</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="scientific_name"
				  	name="scientific_name" value="1"<cfif #scientific_name# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					 <a href="javascript:void(0);" 					 
						class="novisit" 
										onClick="getHelp('scientific_name'); return false;"
										onMouseOver="self.status='Click for Scientific Name help.';return true;"
										onmouseout="self.status='';return true;">Advanced Taxonomy&nbsp;
				  			</a>
				</td>
				<td>
				  <input 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="scinameoperator"
				  	type="checkbox" name="scinameoperator" value="1"<cfif #scinameoperator# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					 Identifier
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="identifier"
				  	name="identifier" value="1"<cfif #identifier# eq 1> CHECKED </cfif> >
				</td>
			</tr>
		</table>
		</div>
		<p>&nbsp;
			
		</p>
		
		<div style="background-color:##EFEFEF; border: 3px solid ##999999">
		<strong>Identifiers</strong>
		<table>
			<tr>
				<td align="right">
					<a href="javascript:void(0);" 
						class="novisit" 
						onClick="getHelp('accn_number'); return false;"
						onMouseOver="self.status='Click for Accession Number help.';return true;" 
						onmouseout="self.status='';return true;">Accession&nbsp;Number</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="accn_num"
				  	name="Accn_Num" value="1"<cfif #Accn_Num# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			
		</table>
		</div>
	</td>
	
	<td valign="top"><!---- bottom right column ---->
		<div style="background-color:##EFEFEF; border: 3px solid ##999999">
		<strong>Other&nbsp;Options</strong>
		
		<table>
			<tr>
				<td align="right">
					Miscellaneous: 
				</td>
				<td>
				  <input type="checkbox"
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="miscellaneous"
				  	name="miscellaneous" value="1"<cfif #miscellaneous# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Advanced Date Search
				</td>
				<td>
				  <input type="checkbox"
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="dates"
				  	name="dates" value="1"<cfif #dates# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);" 
						class="novisit" 
								onClick="getHelp('kill_row'); return false;"
								onMouseOver="self.status='Click for Remove Records help.';return true;" 
								onmouseout="self.status='';return true;">Remove&nbsp;Results</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="killrow"
				  	name="killrow" value="1"<cfif #killrow# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Big&nbsp;Search&nbsp;Boxes
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="bigsearchbox"
				  	name="bigsearchbox" value="1"<cfif #bigsearchbox# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);" 
						class="novisit" 
													onClick="getHelp('collector'); return false;"
													onMouseOver="self.status='Click for Collector help.';return true;"
													onmouseout="self.status='';return true;">Collector</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="colls"
				  	name="colls" value="1"<cfif #colls# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);" 
						class="novisit" 
							onClick="getHelp('parts'); return false;"
							onMouseOver="self.status='Click for Parts help.';return true;" 
							onmouseout="self.status='';return true;">Parts</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="Parts"
				  	name="Parts" value="1"<cfif #Parts# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Images
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="Images"
				  	name="Images" value="1"<cfif #Images# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<!----
			<tr>
				<td align="right">
					Permits
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="permit"
				  	name="permit" value="1"<cfif #permit# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			---->
			<tr>
				<td align="right">
					Citations
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="citation"
				  	name="citation" value="1"<cfif #citation# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					Projects
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="project"
				  	name="project" value="1"<cfif #project# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<tr>
				<td align="right">
					<a href="javascript:void(0);" 
						class="novisit" 
							onClick="windowOpener('/info/attributeHelpPick.cfm','','width=600,height=600, resizable,scrollbars'); return false;"
							onMouseOver="self.status='Click for Attributes help.';return true;" 
							onmouseout="self.status='';return true;">Attribute</a>
				</td>
				<td>
				  <input type="checkbox" 
				  	onclick="setSrchVal(this.id, this.checked)"
				  	id="attributes"
				  	name="attributes" value="1"<cfif #attributes# eq 1> CHECKED </cfif> >
				</td>
			</tr>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
				<tr>
					<td align="right">
						Curatorial Stuff
					</td>
					<td>
					  <input type="checkbox" 
					  	onclick="setSrchVal(this.id, this.checked)"
				  		id="curatorial_stuff"
				  		name="curatorial_stuff" value="1"<cfif #curatorial_stuff# eq 1> CHECKED </cfif> >
					</td>
				</tr>
			</cfif>
		</table>
		</div>
		</form>
	</td>
</tr>
</table>
</td>
<td valign="top">
<cfquery name="getUserData" datasource="#Application.web_user#">
	SELECT   
		cf_users.user_id,
		first_name,
        middle_name,
        last_name,
        affiliation,
		email
	FROM 
		cf_user_data,
		cf_users
	WHERE
		cf_users.user_id = cf_user_data.user_id (+) AND
		username = '#client.username#'
</cfquery>
<form method="post" action="myArctos.cfm" name="dlForm">
	<input type="hidden" name="user_id" value="#getUserData.user_id#">
	<input type="hidden" name="action" value="saveProfile">

<table style="border:2px solid black; margin:10px;">
<!------>
	<tr>
		
		<td colspan="2">
		<strong>Personal Profile:</strong>
		<img src="/images/info.gif" class="likeLink" onclick="alert('A profile is required to download data. \n You cannot recover a lost password unless you enter an email address. \n These data will never be shared with anyone.');" />
		
		<span style="font-size:small;">
			<br>
			To download data, please tell us more about yourself. 
			This information will not be shared with others.
		</span>
		</td>
		
	</tr>
	
	<tr>
		<td align="right">First Name</td>
		<td> <input type="text" name="first_name" value="#getUserData.first_name#" class="reqdClr"></td>
	</tr>
	
	<tr>
		<td align="right">Middle Name</td>
		<td><input type="text" name="middle_name" value="#getUserData.middle_name#"></td>
	</tr>
	<tr>
		<td align="right">Last Name</td>
		<td><input type="text" name="last_name" value="#getUserData.last_name#" class="reqdClr"></td>
	</tr>
	
	<tr>
		<td align="right">Affiliation</td>
		<td><input type="text" name="affiliation" value="#getUserData.affiliation#" class="reqdClr"></td>
	</tr>
	
	<tr>
		<td align="right">Email</td>
		<td><input type="text" name="email" value="#getUserData.email#"></td>
	</tr>
	
	
	
	<tr>
		<td colspan="2" align="center">
		<input type="submit" value="Save" 
			class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
		</td>
		
	</tr>
</form>

</table>
<cfquery name="loan" datasource="#Application.web_user#">
	select * from cf_user_loan
	inner join cf_users on (cf_user_loan.user_id = cf_users.user_id)
	where username='#client.username#'
	order by IS_ACTIVE DESC
</cfquery>

<table style="border:2px solid black; margin:10px;">
	<tr>
		<td>
			<a href="user_loan_request.cfm"><strong>Loans</strong></a>
			
			<ul>
			<cfif #loan.recordcount# gt 0>
				<cfloop query="loan">
					<li>
						<cfif #IS_ACTIVE# is 1>
							<span>
						<cfelse>
							<span style="color:##666666">
						</cfif>
							#PROJECT_TITLE#
						</span>
					</li>
					
				</cfloop>
			<cfelse>
				<li>None</li>
			</cfif>
			</ul>
			
		</td>
	</tr>
</table>
</td>
</tr>
</table>
         
           

</cfoutput>


</cfif>
<!----------------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------------------->
<cfif #action# is "saveProfile">
	<!--- get the values they filled in --->
	<cfif len(#first_name#) is 0 OR
		len(#last_name#) is 0 OR
		len(#affiliation#) is 0>
		You haven't filled in all required values! Please use your browser's back button to try again.
		<cfabort>
	</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	
	<cfquery name="isUser" datasource="#Application.web_user#">
		select * from cf_user_data where user_id=#user_id#
	</cfquery>
		<!---- already have a user_data entry --->
		<cfif #isUser.recordcount# is 1>
			<cfquery name="upUser" datasource="#Application.uam_dbo#">
				UPDATE cf_user_data SET
					first_name = '#first_name#',
					last_name = '#last_name#',
					affiliation = '#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,middle_name = '#middle_name#'
					<cfelse>
						,middle_name = NULL
					</cfif>
					<cfif len(#email#) gt 0>
						,email = '#email#'
					<cfelse>
						,email = NULL
					</cfif>
				WHERE
					user_id = #user_id#
			</cfquery>
		</cfif>
		<cfif #isUser.recordcount# is not 1>
			<cfquery name="newUser" datasource="#Application.uam_dbo#">
				INSERT INTO cf_user_data (
					user_id,
					first_name,
					last_name,
					affiliation
					<cfif len(#middle_name#) gt 0>
						,middle_name
					</cfif>
					<cfif len(#email#) gt 0>
						,email
					</cfif>
					)
				VALUES (
					#user_id#,
					'#first_name#',
					'#last_name#',
					'#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,'#middle_name#'
					</cfif>
					<cfif len(#email#) gt 0>
						,'#email#'
					</cfif>
					)
			</cfquery>
		</cfif>
	<cflocation url="/myArctos.cfm">
</cfif>
<!---------------------------------------------------------------------->
<cfif isdefined("redir") AND #redir# is "true">

	<!---<cflocation url="#startApp#">--->
	<cfoutput>
	<!---- 
		replace cflocation with JavaScript below so I'll always break
		out of frames (ie, agents) when using the nav button 
	--->
	<script language="JavaScript">
		parent.location.href="#startApp#"
	</script>
	</cfoutput>
</cfif>

<cfinclude template = "includes/_footer.cfm">