<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfif not isdefined("session.header_color")>
		<cfset setDbUser()>
	</cfif>
	<script language="javascript" type="text/javascript">
		jQuery(document).ready(function(){
	        jQuery("ul.sf-menu").supersubs({
	            minWidth:    12,
	            maxWidth:    27,
	            extraWidth:  1
	        }).superfish({
	            delay:       600,
	            animation:   {opacity:'show',height:'show'},
	            speed:       0,
	        });
	        if (top.location!=document.location) {
				$("#header_color").hide();
				$("#_footerTable").hide();
			}
			console.log('hi');

			  $("#ancmntDiv").on('mouseenter', function(){
            			alert('mouseover');

        		})
        		.on('mouseleave', function(){
            			alert('mouseout');
		        })​
	    });
	</script>


	<style>
		.collectionCell {vertical-align:text-bottom;padding:0px 0px 7px 0px;}
		.headerImageCell {padding:.3em 1em .3em .3em;text-align:right;}
		@media (max-width: 600px) {
		  #headerLoginDiv{display:none;}
		}

		#ancmntDiv{
			border:1px solid red;
			max-width:65%;
			max-height:1.2em;
			overflow:hidden;
			margin-left:3em;
			padding:10px;


		}
	</style>
	<cfoutput>
		<meta name="keywords" content="#session.meta_keywords#">
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    	<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico?v=5">
		<meta name=viewport content="width=device-width, initial-scale=1">
   		<cfif len(trim(session.stylesheet)) gt 0>
			<cfset ssName = replace(session.stylesheet,".css","","all")>
    		<link rel="alternate stylesheet" type="text/css" href="/includes/css/#trim(session.stylesheet)#" title="#trim(ssName)#">
			<META http-equiv="Default-Style" content="#trim(ssName)#">
		</cfif>
		</head>
		<body>
		<noscript>
			<div class="browserCheck">
				JavaScript is turned off in your web browser. Please turn it on to take full advantage of Arctos, or
				try our <a target="_top" href="/SpecimenSearchHTML.cfm">HTML SpecimenSearch</a> option.
			</div>
		</noscript>
		<!----
		<cfif cgi.HTTP_USER_AGENT does not contain "Firefox">
			<div class="browserCheck">
				Some features of this site may not work in your browser. <a href="/home.cfm##requirements">Learn more</a>
			</div>
		</cfif>
		---->
		<div id="header_color" style='background-color:#session.header_color#;'>
			<table width="95%" cellpadding="0" cellspacing="0" border="0" id="headerContent">
				<tr>
					<td width="95" nowrap="nowrap" class="headerImageCell" id="headerImageCell">
						<a target="_top" href="#session.collection_url#"><img src="#session.header_image#" alt="Arctos" border="0"></a>
					</td>
					<td align="left" valign="bottom" cellpadding="0" cellspacing="0">
						<table cellpadding="0" cellspacing="0">
							<tr>
								<td align="left" valign="bottom" nowrap="nowrap" id="collectionCell" class="collectionCell">
									<cfif len(session.collection_link_text) gt 0>
										<a target="_top" href="#session.collection_url#" class="novisit">
											<span class="headerCollectionText">
													#session.collection_link_text#
											</span>
										</a>
										<br>
									</cfif>
									<a target="_top" href="#session.institution_url#" class="novisit">
										<span class="headerInstitutionText">
											#session.institution_link_text#
										</span>
									</a>
								</td>
								<td>
										<div id="ancmntDiv">
											This is 1111 announcement. It might be about this long. It could tell you things. Bla bla bla. Text goes here. This is 2222 announcement. It might be about this long. It could tell you things. Bla bla bla. Text goes here.240 character limit
										</div>
								</td>
							</tr>
							<cfif len(session.header_credit) gt 0>
								<tr>
									<td colspan="2" id="creditCell">
										<span  class="hdrCredit">
											#session.header_credit#
										</span>
									</td>
								</tr>
							</cfif>
						</table>
					</td>
				</tr>
			</table>
			<div id="headerLinks" style="float:right;position:absolute;top:5px;right:5px;clear:both;">
		    	<cfif len(session.username) gt 0>
					<a target="_top" href="/login.cfm?action=signOut">Log out #session.username#</a>
					<cfif isdefined("session.last_login") and len(session.last_login) gt 0>
						<span style="font-size:smaller">(Last login: #dateformat(session.last_login, "yyyy-mm-dd")#)</span>&nbsp;
					</cfif>
					<cfif isdefined("session.needEmailAddr") and session.needEmailAddr is 1>
						<br>
						<span style="color:red;font-size:smaller;">
							You have no email address in your profile. Please correct.
						</span>
					</cfif>
				<cfelse>
					<cfif isdefined("ref")><!--- passed in by Application.cfc before termination --->
						<cfset gtp=ref>
					<cfelse>
						<cfset gtp="/" & request.rdurl>
					</cfif>
					<!--- run this twice to get /// --->
					<cfset gtp=replace(gtp,"//","/","all")>
					<cfset gtp=replace(gtp,"//","/","all")>
					<div id="headerLoginDiv">
						<form name="logIn" method="post" action="/login.cfm">
							<input type="hidden" name="action" value="signIn">
							<input type="hidden" name="gotopage" value="#gtp#">

							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td>
										<input type="text" name="username" title="username" size="12"
											class="loginTxt" placeholder="username" required>
									</td>
									<td>
										<input type="password" name="password" title="password" placeholder="password" size="12" class="loginTxt" required>
									</td>
								</tr>
								<tr>
									<td colspan="2" align="center">
										<div class="loginTxt" style="padding-top:3px;">
											<input type="submit" value="Log In" class="smallBtn">
											or
											<input type="button" value="Create Account" class="smallBtn"
												onClick="logIn.action.value='newUser';submit();">
										</div>
							    	</td>
								</tr>
							</table>
						</form>
					</div>
				</cfif>
			</div>
			<div class="sf-mainMenuWrapper">
				<ul class="sf-menu">
					<li>
						<a target="_top" href="/SpecimenSearch.cfm">Search</a>
						<ul>
							<li><a target="_top" href="/SpecimenSearch.cfm">Specimens</a></li>
							<li><a target="_top" href="/SpecimenUsage.cfm">Publications/Projects</a></li>
							<li><a target="_top" href="/taxonomy.cfm">Taxonomy</a></li>
			                <li><a target="_top" href="/MediaSearch.cfm">Media/Documents</a></li>
			                <li><a target="_top" href="/geography.cfm">Geography</a></li>
			                <li><a target="_top" href="/showLocality.cfm">Places</a></li>
			                <li><a target="_top" href="/info/ctDocumentation.cfm">Code&nbsp;Tables</a></li>
							<li><a target="_top" href="/googlesearch.cfm">Google&nbsp;Custom&nbsp;(BETA)</a></li>
							<li><a target="_top" href="/spatialBrowse.cfm">Spatial&nbsp;Browse&nbsp;(BETA)</a></li>
							<li><a target="_top" href="/agent.cfm">Agents</a></li>
							<li><a target="_top" href="/info/api.cfm">API</a></li>
						</ul>
					</li>
					<cfif len(session.roles) gt 0 and session.roles is not "public">
						<cfset r = replace(session.roles,",","','","all")>
						<cfset r = "'#r#'">
						<!--- "--->
						<cfquery name="roles" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
							select form_path from cf_form_permissions
							where upper(role_name) IN (#ucase(preservesinglequotes(r))#)
							minus select form_path from cf_form_permissions
							where upper(role_name)  not in (#ucase(preservesinglequotes(r))#)
						</cfquery>
						<cfset formList = valuelist(roles.form_path)>
						<li><a href="##">Enter Data</a>
							<ul>
								<li><a target="_top" href="/DataEntry.cfm">Data Entry</a></li>
								<li><a target="_top" href="##">Bulkloader</a>
									<ul>
										<cfif listfind(formList,"/Bulkloader/bulkloader_status.cfm")>
											<li><a target="_top" href="/Bulkloader/">Bulkload Specimens</a></li>
											<li><a target="_top" href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a></li>
											<li><a target="_top" href="/Bulkloader/bulkloaderBuilder.cfm">Bulkloader Builder</a></li>
											<li><a target="_top" href="##" class="helpLink" data-helplink="bulkloader">Bulkloader Docs</a></li>
											<li><a target="_top" href="/Bulkloader/pre_bulkloader.cfm">Pre-Bulkloader</a></li>
											<li><a target="_top" href="/Bulkloader/sqlldr.cfm">SQLLDR Builder</a></li>
										</cfif>
										<cfif listfind(formList,"/Bulkloader/browseBulk.cfm")>
											<li><a target="_top" href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>
										</cfif>
									</ul>
								</li>
								<cfif listfind(formList,"/tools/BulkloadParts.cfm")>
									<li><a target="_top" href="##">Batch Tools</a>
										<ul>
											<li><a target="_top" href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
											<li><a target="_top" href="/tools/BulkloadSpecimenPartAttribute.cfm">Bulkload Part Attributess</a></li>
											<li><a target="_top" href="/tools/BulkPartSample.cfm">Bulkload Part Subsamples (Lots)</a></li>
											<li><a target="_top" href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
											<li><a target="_top" href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
											<li><a target="_top" href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers/Relationships</a></li>
											<li><a target="_top" href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
											<li><a target="_top" href="/tools/DataLoanBulkload.cfm">Bulkload DataLoan Items</a></li>
											<li><a target="_top" href="/DataServices/agents.cfm">Bulkload Agents</a></li>
											<li><a target="_top" href="/tools/BulkloadCollector.cfm">Bulkload Collector</a></li>
											<li><a target="_top" href="/tools/BulkloadPartContainer.cfm">Parts>>Containers</a></li>
											<li><a target="_top" href="/tools/BulkloadIdentification.cfm">Identifications</a></li>
											<!----
											deprecated 20151013
											<li><a target="_top" href="/tools/BulkloadContEditParent.cfm">Bulk Edit Container</a></li>
											---->
											<li><a target="_top" href="/tools/BulkloadMedia.cfm">Bulkload Media</a></li>
											<li><a target="_top" href="/tools/uploadMedia.cfm">upload images</a></li>
											<li><a target="_top" href="/tools/BulkloadRedirect.cfm">bulkload redirects</a></li>
											<li><a target="_top" href="/tools/BulkloadSpecimenEvent.cfm">bulkload specimen-events</a></li>
											<li><a target="_top" href="/tools/BulkloadAccn.cfm">bulkload accessions</a></li>
											<cfif listfind(formList,"/tools/BulkloadTaxonomy.cfm")>
												<li><a target="_top" href="/tools/BulkloadClassification.cfm">bulkload classifications (taxonomy)</a></li>
												<li><a target="_top" href="/tools/taxonomyTree.cfm">Hierarchical Classifications</a></li>
											</cfif>
											<cfif listfind(formList,"/tools/BulkloadContainerEnvironment.cfm")>
												<li><a target="_top" href="/tools/BulkloadContainerEnvironment.cfm">bulkload container environment</a></li>
											</cfif>
										</ul>
									</li>
								</cfif>
							</ul>
						</li>
						<li><a target="_top" href="##">Manage Data</a>
							<ul>
								<cfif listfind(formList,"/Locality.cfm")>
									<li><a target="_top" href="##">Location</a>
										<ul>
											<li><a target="_top" href="/geography.cfm">Find Geography</a></li>
											<li><a target="_top" href="/Locality.cfm?action=newHG">Create Geography</a></li>
											<li><a target="_top" href="/Locality.cfm?action=findLO">Find Locality</a></li>
											<li><a target="_top" href="/Locality.cfm?action=newLocality">Create Locality</a></li>
											<li><a target="_top" href="/Locality.cfm?action=findCO">Find Event</a></li>
										</ul>
									</li>
								</cfif>
									<li><a target="_top" href="/agents.cfm">Agents</a>
									</li>
								<cfif listfind(formList,"/EditContainer.cfm") OR listfind(formList,"/tools/dgr_locator.cfm")>
									<li><a target="_top" href="##">Object Tracking</a>
										<ul>
											<cfif listfind(formList,"/tools/dgr_locator.cfm")>
												<li><a target="_top" href="/tools/dgr_locator.cfm">DGR Locator</a></li>
											</cfif>
											<cfif listfind(formList,"/moveContainer.cfm")>
												<li><a target="_top" href="/findContainer.cfm">Find Container</a></li>
												<li><a target="_top" href="/moveContainer.cfm">Move Container</a></li>
												<li><a target="_top" href="/batchScan.cfm">Batch Scan</a></li>
												<li><a target="_top" href="/part2container.cfm">Object+BC>>Container</a></li>
											</cfif>
											<cfif listfind(formList,"/EditContainer.cfm")>
												<!----
												<li><a target="_top" href="/LoadBarcodes.cfm">Upload Scan File</a></li>
												---->
												<li><a target="_top" href="/EditContainer.cfm?action=newContainer">Create Container</a></li>
												<li><a target="_top" href="/CreateContainersForBarcodes.cfm">Create Container Series</a></li>
												<li><a target="_top" href="/tools/bulkEditContainer.cfm">Bulk Edit Container</a></li>
												<li><a target="_top" href="/info/barcodeseries.cfm">Barcode Series</a></li>
											</cfif>

										</ul>
									</li>
								</cfif>
								<cfif listfind(formList,"/Loan.cfm")>
									<li><a target="_top" href="##">Transactions</a>
										<ul>
											<li><a target="_top" href="/newAccn.cfm">Create Accession</a></li>
											<li><a target="_top" href="/editAccn.cfm">Find Accession</a></li>
											<li><a target="_top" href="/Loan.cfm?Action=newLoan">Create Loan</a></li>
											<li><a target="_top" href="/Loan.cfm?Action=addItems">Find Loan</a></li>
											<li><a target="_top" href="/borrow.cfm?action=new">Create Borrow</a></li>
											<li><a target="_top" href="/borrow.cfm">Find Borrow</a></li>
											<li><a target="_top" href="/Permit.cfm?action=newPermit">Create Permit</a></li>
											<li><a target="_top" href="/Permit.cfm">Find Permit</a></li>
										</ul>
									</li>
								</cfif>
								<cfif listfind(formList,"/Encumbrances.cfm")>
									<li><a target="_top" href="##">Metadata</a>
										<ul>
											<cfif listfind(formList,"/Encumbrances.cfm")>
												<li><a target="_top" href="/Encumbrances.cfm">Encumbrances</a></li>
											</cfif>
											<cfif listfind(formList,"/CodeTableEditor.cfm")>
												<li><a target="_top" href="/Admin/CodeTableEditor.cfm">Code Tables</a></li>
											</cfif>
											<cfif listfind(formList,"/Admin/global_settings.cfm")>
												<li><a target="_top" href="/Admin/global_settings.cfm">Global Settings</a></li>
											</cfif>
											<cfif listfind(formList,"/Admin/Collection.cfm")>
												<li><a target="_top" href="/Admin/Collection.cfm">Manage Collection</a></li>
											</cfif>
										</ul>
									</li>
								</cfif>
								<cfif listfind(formList,"/info/reviewAnnotation.cfm")>
									<li><a target="_top" href="##">Tools</a>
										<ul>
											<li><a target="_top" href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
											<li><a target="_top" href="/Admin/redirect.cfm">Redirects</a></li>
										</ul>
									</li>
								</cfif>
								<cfif listfind(formList,"/doc/field_documentation.cfm")>
									<li><a target="_top" href="/doc/field_documentation.cfm">Field-level Documentation</a></li>
								</cfif>
							</ul>
						<li><a target="_top" href="##">Manage Arctos</a>
							<ul>
								<cfif listfind(formList,"/Admin/CSVAnyTable.cfm")>
									<li>
										<a target="_top" href="##">Developer Tools</a>
										<ul>
											<li><a target="_top" href="/Admin/CSVAnyTable.cfm">CSVFromTable</a></li>
											<li><a target="_top" href="/tools/loadToTable.cfm">CSVToTable</a></li>
											<li><a target="_top" href="/tblbrowse.cfm">Table Browser</a></li>
											<li><a target="_top" href="/Admin/getDDL.cfm">Table DDL</a></li>
											<li><a target="_top" href="/Admin/scheduler.cfm">Scheduled Tasks</a></li>
											<li><a target="_top" href="/Admin/dumpAll.cfm">dump</a></li>
											<li><a target="_top" href="/tools/imageList.cfm">Image List</a></li>
											<li><a target="_top" href="/tools/makeGitIgnore.cfm">build .gitignore</a></li>
											<li><a target="_top" href="/Admin/buildAttributeSearchByNameCode.cfm">Get Attributes Code</a></li>
										</ul>
									</li>
								</cfif>
								<cfif listfind(formList,"/AdminUsers.cfm")>
									<li><a target="_top" href="##">Roles/Permissions</a>
										<ul>
											<li><a target="_top" href="/Admin/form_roles.cfm">Form Permissions</a></li>
											<li><a target="_top" href="/tools/uncontrolledPages.cfm">See Form Permissions</a></li>
											<li><a target="_top" href="/Admin/blacklist.cfm">Blacklist IP</a></li>
											<li><a target="_top" href="/AdminUsers.cfm">Arctos Users</a></li>
											<li><a target="_top" href="/Admin/user_roles.cfm">Database Roles</a></li>
											<li><a target="_top" href="/Admin/user_report.cfm">All User Stats</a></li>
											<li><a target="_top" href="/Admin/manage_user_loan_request.cfm">User Loan</a></li>
										</ul>
									</li>
								</cfif>
							</ul>
						</li>
						<cfif listfind(formList,"/Admin/ActivityLog.cfm")>
							<li><a target="_top" href="##">Reports</a>
								<ul>
									<li><a target="_top" href="/Reports/reporter.cfm">Reporter</a></li>
									<li><a target="_top" href="/info/mia_in_genbank.cfm">GenBank MIA</a></li>
									<li><a target="_top" href="/info/reviewAnnotation.cfm">Annotations</a></li>
									<li><a target="_top" href="/info/loanStats.cfm">Loan/Citation Stats</a></li>
									<li><a target="_top" href="/info/Citations.cfm">More Citation Stats</a></li>
									<li><a target="_top" href="/info/undocumentedCitations.cfm">Undocumented Citations</a></li>
									<li><a target="_top" href="/info/MoreCitationStats.cfm">Usage Stats</a></li>
									<li><a target="_top" href="/Admin/download.cfm">Download Stats</a></li>
									<li><a target="_top" href="/info/queryStats.cfm">Query Stats</a></li>
									<li><a target="_top" href="/Admin/ActivityLog.cfm">Audit SQL</a></li>
									<li><a target="_top" href="/tools/access_report.cfm">Oracle Roles</a></li>
									<li><a target="_top" href="/info/ipt.cfm">IPT/collection metadata report</a></li>
									<li><a target="_top" href="/info/localityStats.cfm">Locality Statistics</a></li>
									<li><a target="_top" href="/info/sysstats.cfm">System Statistics</a></li>
									<li><a target="_top" href="/Admin/exit_links.cfm">Exit Links</a></li>
									<li><a target="_top" href="/Admin/errorLogViewer.cfm">Error Logs</a></li>
									<li><a target="_top" href="/Reports/dataentry.cfm">Data Entry Stats</a></li>
						            <cfif listfind(formList,"/tools/userSQL.cfm")>
									    <li><a target="_top" href="/tools/userSQL.cfm">Write SQL</a></li>
				                    </cfif>


				                    <li><a target="_top" href="##">Funky Data</a>
										<ul>
											<li><a target="_top" href="/info/slacker.cfm">Suspect Data</a></li>
											<li><a target="_top" href="/info/noParts.cfm">Partless Specimens</a></li>
											<li><a target="_top" href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
											<li><a target="_top" href="/info/dupAgent.cfm">Duplicate Agents</a></li>
											<li><a target="_top" href="/Reports/partusage.cfm">Part Usage</a></li>
											<li><a target="_top" href="/info/dispVRemark.cfm">Disposition vs. Remark</a></li>
											<li><a target="_top" href="/Reports/georef.cfm">Georeference Statistics</a></li>
										</ul>
									</li>
									 <li><a target="_top" href="##">Data Services</a>
										<ul>
											<li><a target="_top" href="/tools/barcode2guid.cfm">Find GUID from Barcode</a></li>
											<li><a target="_top" href="/DataServices/getGeogFromSpecloc.cfm">Find higher_geog from specloc</a></li>
											<li><a target="_top" href="/DataServices/SciNameCheck.cfm">Taxon Name Checker</a></li>
											<li><a target="_top" href="/DataServices/geog_lookup.cfm">Higher Geog Lookup</a></li>
											<li><a target="_top" href="/DataServices/dateSplit.cfm">Date Formatter</a></li>
											<li><a target="_top" href="/DataServices/coordinate_splitter.cfm">Coordinate Formatter</a></li>
											<li><a target="_top" href="/DataServices/agent_splitter.cfm">Agent Deconcatenator</a></li>
											<li><a target="_top" href="/DataServices/split_agent_namestring.cfm">Agent Namestring Formatter</a></li>
											<li><a target="_top" href="/DataServices/findNonprintingCharacters.cfm">Find and replace nonprinting characters</a></li>
											<li><a target="_top" href="/DataServices/wktomaticifier.cfm">Convert KML to WKT</a></li>
										</ul>
									</li>
								</ul>
							</li>
					    </cfif>
					</cfif>
					<li><a target="_top" href="/home.cfm">Portals</a></li>
				    <li><a target="_top" href="/myArctos.cfm">My Stuff</a>
				   		<ul>
							<cfif len(session.username) gt 0>
								<li><a target="_top" href="/myArctos.cfm">Profile</a></li>
							<cfelse>
								<li><a target="_top" href="/myArctos.cfm">Log In</a></li>
							</cfif>
							<li><a target="_top" href="/saveSearch.cfm?action=manage">Saved Searches</a></li>
						</ul>
					</li>
					<li><a target="_blank" href="http://arctosdb.org/">About/Help</a>
						<ul>
							<li><a target="_blank" class="external" href="http://arctosdb.org/">About</a></li>
							<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/">Help</a></li>
							<li><a target="_top" href="/info/mentor.cfm">Find a Mentor</a></li>
						</ul>
					</li>
					<!----
					<li>
						New! Something short here...
					</li>
					---->
				</ul>
			</div>
		</div><!--- end header div --->
		<cf_rolecheck>
	</cfoutput>
<br><br>