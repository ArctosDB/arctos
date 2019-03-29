<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfif not isdefined("session.header_color")>
		<cfset setDbUser()>
	</cfif>

	<!----
	cachedwithin="#createtimespan(0,0,60,0)#"
	---->
	<cfquery name="g_a_t" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select announcement_text from cf_global_settings where  announcement_expires>=trunc(sysdate)
	</cfquery>

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
	    });
	</script>


	<style>
		.collectionCell {vertical-align:text-bottom;padding:0px 0px 7px 0px;}
		.headerImageCell {padding:.3em 1em .3em .3em;text-align:right;}
		@media (max-width: 600px) {
		  #headerLoginDiv{display:none;}
		}

.newsDefault{
			background:#f9f7f7;
			border:1px solid red;
			width:250px;
			max-height:1em;
			overflow:hidden;
			margin-left:3em;
			margin-bottom:.5em;
			padding:10px;
			white-space: nowrap;
			text-overflow: ellipsis;
			transition: .2s;
			border-radius: 5px;
		}
.newsDefault:hover{
			background:bisque;
			 max-height:unset;
			 max-width:unset;
			width:100%;
			 white-space: normal;
			 position:relative;
			 margin-left: auto;
			 margin-top: 0;
			 margin-right: auto;
			 left: 0;
			 right: 0;
			 z-index: 100000;
		}

		#headerTable {
			display:table;
			width:100%;
		}
		#header-table-row {
			display:table-row;
		}
		#header-img-cell {
			display:table-cell;
			padding:0;
		}
		#header-link-cell {
			display:table-cell;
			vertical-align: bottom;
		}
		#header-news-cell {
			display:table-cell;
			vertical-align: bottom;
		}
		#header-login-cell {
			display:table-cell;
			text-align: right;
			vertical-align: top;
		}

		#header-login-inner{
			display: flex;
			justify-content: flex-end;
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
			<div id="headerTable">
				<div id="header-table-row">
					<div id="header-img-cell">
						<a target="_top" href="#session.collection_url#">
							<img src="#session.header_image#" alt="Arctos" border="0">
						</a>
					</div>
					<div id="header-link-cell">
						<div id="collectionTextCell" class="headerCollectionText">
							<cfif len(session.collection_link_text) gt 0>
								<a target="_top" href="#session.collection_url#" class="novisit">
									#session.collection_link_text#
								</a>
							</cfif>
						</div>
						<div id="headerInstitutionText" class="headerInstitutionText">
							<a target="_top" href="#session.institution_url#" class="novisit">
								#session.institution_link_text#
							</a>
						</div>
						<div id="creditCell"></div>
					</div>
					<cfif len(g_a_t.announcement_text) gt 0>
						<div id="header-news-cell">
							<div class="newsDefault">
								#g_a_t.announcement_text#
							</div>
						</div>
					</cfif>
					<div id="header-login-cell">
						<div id="header-login-inner">
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
					</div>
				</div>
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
											<li><a target="_top" href="/Bulkloader/loaded_specimen_extras.cfm">Extras For Loaded Specimens</a></li>
										</cfif>
										<cfif listfind(formList,"/Bulkloader/browseBulk.cfm")>
											<li><a target="_top" href="/Bulkloader/browseBulk.cfm">Browse and Edit</a></li>
										</cfif>
									</ul>
								</li>
								<cfif listfind(formList,"/tools/BulkloadParts.cfm")>
									<li><a target="_top" href="##">Batch Tools</a>
										<ul>

											<li><a target="_top" href="/tools/BulkloadAccn.cfm">Bulkload Accessions</a></li>
											<li><a target="_top" href="/DataServices/agents.cfm">Bulkload Agents</a></li>
											<li><a target="_top" href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>


											<li><a target="_top" href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
											<li><a target="_top" href="/tools/BulkloadCollector.cfm">Bulkload Collector</a></li>

											<cfif listfind(formList,"/tools/BulkloadContainerEnvironment.cfm")>
												<li><a target="_top" href="/tools/BulkloadContainerEnvironment.cfm">Bulkload Container Environment</a></li>
											</cfif>


											<li><a target="_top" href="/tools/BulkloadParts.cfm">Bulkload Parts</a></li>
											<li><a target="_top" href="/tools/BulkloadSpecimenPartAttribute.cfm">Bulkload Part Attributes</a></li>
											<li><a target="_top" href="/tools/BulkPartSample.cfm">Bulkload Part Subsamples (Lots)</a></li>
											<li><a target="_top" href="/tools/BulkloadPartContainer.cfm">Parts>>Containers</a></li>

											<li><a target="_top" href="/tools/BulkloadIdentification.cfm">Bulkload Identifications</a></li>


											<li><a target="_top" href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers/Relationships</a></li>
											<li><a target="_top" href="/tools/BulkDeleteOtherId.cfm">Bulk Delete Identifiers/Relationships</a></li>


											<li><a target="_top" href="/tools/BulkloadLoan.cfm">Bulkload Loans</a></li>
											<li><a target="_top" href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
											<li><a target="_top" href="/tools/DataLoanBulkload.cfm">Bulkload DataLoan Items</a></li>


											<li><a target="_top" href="/tools/BulkloadMedia.cfm">Bulkload Media Metadata</a></li>
											<li><a target="_top" href="/tools/uploadMedia.cfm">Upload Images</a></li>

											<li><a target="_top" href="/tools/BulkloadRedirect.cfm">Bulkload Redirects</a></li>

											<li><a target="_top" href="/tools/BulkloadSpecimenEvent.cfm">Bulkload Specimen-Events</a></li>

											<cfif listfind(formList,"/tools/BulkloadTaxonomy.cfm")>
												<li><a target="_top" href="/tools/BulkloadClassification.cfm">Bulkload Taxonomy Classifications</a></li>
												<li><a target="_top" href="/tools/BulkloadTaxonomy.cfm">Bulkload Taxonomy Names</a></li>
												<li><a target="_top" href="/tools/taxonomyTree.cfm">Manage Classifications Hierarchically</a></li>
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
											<li><a target="_top" href="/info/localityArchive.cfm">Locality Edit History</a></li>
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
											<cfif listfind(formList,"/Admin/CodeTableEditor.cfm")>
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
											<li><a target="_top" href="/Admin/generate_ct_log.cfm">Generate CT logs</a></li>

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
											<li><a target="_top" href="/Admin/user_report.cfm">All User Statistics</a></li>
											<li><a target="_top" href="/Admin/manage_user_loan_request.cfm">User Loan</a></li>
										</ul>
									</li>
								</cfif>
							</ul>
						</li>
						<cfif listfind(formList,"/Admin/ActivityLog.cfm")>
							<li><a target="_top" href="##">Reports/Services</a>
								<ul>
									<!---- why is this here??
									<li><a target="_top" href="##">Administrative Tools</a></li>
									--->
									<li><a target="_top" href="##">Labels and Reports</a>
										<ul>
											<li><a target="_top" href="/Reports/reporter.cfm">Reporter</a></li>
											<li><a target="_top" href="/Admin/ActivityLog.cfm">Audit SQL</a></li>
											<li><a target="_top" href="/Admin/errorLogViewer.cfm">Error Logs</a></li>
											<li><a target="_top" href="/tools/access_report.cfm">Oracle Roles</a></li>
											<li><a target="_top" href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
										</ul>
									</li>

									<li><a target="_top" href="##">Data Services</a>
										<ul>
											<li><a target="_top" href="/DataServices/agent_splitter.cfm">Agent Deconcatenator</a></li>
											<li><a target="_top" href="/DataServices/split_agent_namestring.cfm">Agent Namestring Formatter</a></li>
											<li><a target="_top" href="/DataServices/agentNameSplitter.cfm">Agent Name Splitter</a></li>
											<li><a target="_top" href="/DataServices/wktomaticifier.cfm">Convert KML to WKT</a></li>
											<li><a target="_top" href="/DataServices/coordinate_splitter.cfm">Coordinate Formatter</a></li>
											<li><a target="_top" href="/DataServices/dateSplit.cfm">Date Formatter</a></li>
											<li><a target="_top" href="/tools/barcode2guid.cfm">Find GUID from Barcode</a></li>
											<li><a target="_top" href="/DataServices/getGeogFromSpecloc.cfm">Find Higher Geography from Specific Locality</a></li>
											<li><a target="_top" href="/DataServices/findNonprintingCharacters.cfm">Find/Replace Nonprinting Characters</a></li>
											<li><a target="_top" href="/DataServices/geog_lookup.cfm">Higher Geog Lookup</a></li>
											<li><a target="_top" href="/DataServices/listerizer.cfm">Make Comma-list from anything</a></li>



											<li><a target="_top" href="/tools/genbank_submit.cfm">Package GenBank Data</a></li>

											<li><a target="_top" href="/DataServices/SciNameCheck.cfm">Scientific Name Checker</a></li>
											<li><a target="_top" href="/DataServices/taxonNameValidator.cfm">Taxon Name Validator</a></li>
										</ul>
									</li>
									 <li><a target="_top" href="##">Find Low-Quality Data</a>
										<ul>
											<li><a target="_top" href="/Reports/dashboard.cfm">Dashboard</a></li>
											<li><a target="_top" href="/info/dispVRemark.cfm">Disposition vs. Remark</a></li>
											<li><a target="_top" href="/info/dupAgent.cfm">Duplicate Agents</a></li>
											<li><a target="_top" href="/info/mia_in_genbank.cfm">GenBank Discovery Tool</a></li>
											<li><a target="_top" href="/Reports/partusage.cfm">Part Usage</a></li>
											<li><a target="_top" href="/info/noParts.cfm">Partless Specimens</a></li>
											<li><a target="_top" href="/info/slacker.cfm">Publication/Loan/Project/Citation Problems</a></li>
											<li><a target="_top" href="/info/undocumentedCitations.cfm">Undocumented Citations</a></li>
										</ul>
									</li>
									<li><a target="_top" href="/info/reviewAnnotation.cfm">Review Annotations</a></li>
									<li><a target="_top" href="##">View Statistics</a>
										<ul>
											<li><a target="_top" href="/info/flat_status.cfm">FLAT status</a></li>
											<li><a target="_top" href="/Reports/dataentry.cfm">Data Entry Statistics</a></li>
											<li><a target="_top" href="/Admin/download.cfm">Download Statistics</a></li>
											<li><a target="_top" href="/Admin/exit_links.cfm">Exit Links</a></li>
											<li><a target="_top" href="/Reports/georef.cfm">Georeference Statistics</a></li>
											<li><a target="_top" href="/info/ipt.cfm">IPT/Collection Metadata Report</a></li>
											<li><a target="_top" href="/info/collectionContacts.cfm">All Collection Contact Report</a></li>
											<li><a target="_top" href="/info/collection_report.cfm">Collection Contact/Operator Report</a></li>
											<li><a target="_top" href="/info/loanStats.cfm">Loan/Citation Statistics</a></li>
											<li><a target="_top" href="/info/localityStats.cfm">Locality Statistics</a></li>
											<li><a target="_top" href="/info/Citations.cfm">More Citation Statistics</a></li>
											<li><a target="_top" href="/info/queryStats.cfm">Query Statistics</a></li>
											<li><a target="_top" href="/info/sysstats.cfm">System Statistics</a></li>
											<li><a target="_top" href="/info/MoreCitationStats.cfm">Usage Statistics</a></li>
										</ul>
									</li>
									<cfif listfind(formList,"/tools/userSQL.cfm")>
									    <li><a target="_top" href="/tools/userSQL.cfm">Write SQL</a></li>
				                    </cfif>
									   <li><a target="_top" href="/new_collection.cfm">Prospective Collection Request</a></li>
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
				</ul>
			</div>
		</div><!--- end header div --->
		<cf_rolecheck>
	</cfoutput>
<br><br>