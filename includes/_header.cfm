<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
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
	    });
	</script>
	<cfoutput>
		<meta name="keywords" content="#session.meta_keywords#">
    	<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
    	<meta http-equiv="content-type" content="text/html; charset=utf-8">
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
		<cfif cgi.HTTP_USER_AGENT does not contain "Firefox">
			<div class="browserCheck">
				Some features of this site may not work in your browser. <a href="/home.cfm##requirements">Learn more</a>
			</div>
		</cfif>
		<div id="header_color" style='background-color:#session.header_color#;'>
			<table width="95%" cellpadding="0" cellspacing="0" border="0" id="headerContent">
				<tr>
					<td width="95" nowrap="nowrap" class="headerImageCell" id="headerImageCell">
						<a target="_top" href="#session.collection_url#"><img src="#session.header_image#" alt="Arctos" border="0"></a>
					</td>
					<td align="left">
						<table>
							<tr>
								<td align="left" nowrap="nowrap" id="collectionCell" class="collectionCell">
									<a target="_top" href="#session.collection_url#" class="novisit">
										<span class="headerCollectionText">
												#session.collection_link_text#
										</span>
									</a>
									<br>
									<a target="_top" href="#session.institution_url#" class="novisit">
										<span class="headerInstitutionText">
											#session.institution_link_text#
										</span>
									</a>
								</td>
							</tr>	
							<tr>
								<td colspan="2" id="creditCell">
									<span  class="hdrCredit">
										#session.header_credit#
									</span>
								</td>
							</tr>		 
						</table>
					</td>
				</tr>
			</table>
			<div style="float:right;position:absolute;top:5px;right:5px;clear:both;">
		    	<cfif len(#session.username#) gt 0>
					<a target="_top" href="##" onClick="getDocs('index')">Help</a> ~ 
					<a target="_top" href="/login.cfm?action=signOut">Log out #session.username#</a>
					<cfif isdefined("session.last_login") and len(#session.last_login#) gt 0>
						<span style="font-size:smaller">(Last login: #dateformat(session.last_login, "mmm d yyyy")#)</span>&nbsp;
					</cfif>
					<cfif isdefined("session.needEmailAddr") and session.needEmailAddr is 1>
						<br>
						<span style="color:red;font-size:smaller;">
							You have no email address in your profile. Please correct.
						</span>
					</cfif>
				<cfelse>
					<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
						<cfset gtp=cgi.REDIRECT_URL>
					<cfelse>
						<cfset gtp=cgi.SCRIPT_NAME>
					</cfif>
					
					

					<form name="logIn" method="post" action="/login.cfm">
						<input type="hidden" name="action" value="signIn">
						<input type="hidden" name="gotopage" value="#gtp#">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td rowspan="2" valign="top">
									<a target="_top" href="##" onClick="getDocs('index')">Help</a> ~&nbsp;
								</td>
								<td>
									<input type="text" name="username" title="Username" value="Username" size="12" 
										class="loginTxt" onfocus="if(this.value==this.title){this.value=''};">
								</td>
								<td>
									<input type="password" name="password"title="Password"  size="12" class="loginTxt">
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
				</cfif>
			</div>
			<!---
			<div style="border:2px solid red; text-align:center;margin:2px;padding:2px;background-color:white;font-weight:bold;">
				We're upgrading! Things may be a little goofy until Monday, February 16.
			</div>
			--->
			<div class="sf-mainMenuWrapper">
				<ul class="sf-menu">
					<li>
						<a target="_top" href="/SpecimenSearch.cfm">Search</a>
						<ul>
							<li><a target="_top" href="/SpecimenSearch.cfm">Specimens</a></li>
							<li><a target="_top" href="/SpecimenUsage.cfm">Publications/Projects</a></li>
							<li><a target="_top" href="/TaxonomySearch.cfm">Taxonomy</a></li>
			                <li><a target="_top" href="/MediaSearch.cfm">Media</a></li>
			                <li><a target="_top" href="/showLocality.cfm">Places</a></li>
			                <li><a target="_top" href="/document.cfm">Documents&nbsp;(BETA)</a></li>
							<li><a target="_top" href="/googlesearch.cfm">Google&nbsp;Custom&nbsp;(BETA)</a></li>
						</ul>
					</li>
					<cfif len(session.roles) gt 0 and session.roles is not "public">
						<cfset r = replace(session.roles,",","','","all")>
						<cfset r = "'#r#'">
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
											<li><a target="_top" href="##" onclick="getDocs('Bulkloader/index')">Bulkloader Docs</a></li>
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
											<li><a target="_top" href="/tools/BulkPartSample.cfm">Bulkload Part Subsamples (Lots)</a></li>
											<li><a target="_top" href="/tools/BulkloadAttributes.cfm">Bulkload Attributes</a></li>
											<li><a target="_top" href="/tools/BulkloadCitations.cfm">Bulkload Citations</a></li>
											<li><a target="_top" href="/tools/BulkloadOtherId.cfm">Bulkload Identifiers</a></li>
											<li><a target="_top" href="/tools/loanBulkload.cfm">Bulkload Loan Items</a></li>
											<li><a target="_top" href="/DataServices/agents.cfm">Bulkload Agents</a></li>
											<li><a target="_top" href="/tools/BulkloadPartContainer.cfm">Parts>>Containers</a></li>
											<li><a target="_top" href="/tools/BulkloadIdentification.cfm">Identifications</a></li>
											<li><a target="_top" href="/tools/BulkloadContEditParent.cfm">Bulk Edit Container</a></li>
											<li><a target="_top" href="/tools/BulkloadMedia.cfm">Bulkload Media</a></li>
											<li><a target="_top" href="/tools/BulkloadRelations.cfm">Bulkload Relationships</a></li>
											<li><a target="_top" href="/tools/BulkloadGeoref.cfm">Bulkload Georeference</a></li>
											<cfif listfind(formList,"/tools/BulkloadTaxonomy.cfm")>
												<li><a target="_top" href="/tools/BulkloadTaxonomy.cfm">Bulk Taxonomy</a></li>
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
											<li><a target="_top" href="/Locality.cfm?action=findHG">Find Geography</a></li>
											<li><a target="_top" href="/Locality.cfm?action=newHG">Create Geography</a></li>
											<li><a target="_top" href="/Locality.cfm?action=findLO">Find Locality</a></li>
											<li><a target="_top" href="/Locality.cfm?action=newLocality">Create Locality</a></li>
											<li><a target="_top" href="/Locality.cfm?action=findCO">Find Event</a></li>
											<li><a target="_top" href="/info/geol_hierarchy.cfm">Geology Attributes Hierarchy</a></li>
										</ul>
									</li>			
								</cfif>
									<li><a target="_top" href="##">Agents</a>
										<ul>
											<cfif listfind(formList,"/agents.cfm")>
												<li><a target="_top" href="/agents.cfm">Agents</a></li>
											</cfif>
											<cfif listfind(formList,"/Admin/killBadAgentDups.cfm")>
												<li><a target="_top" href="/Admin/killBadAgentDups.cfm">Merge bad dup agents</a></li>
											</cfif>
										</ul>
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
												<li><a target="_top" href="/labels2containers.cfm">Label>Container</a></li>
												<li><a target="_top" href="/part2container.cfm">Object+BC>>Container</a></li>
											</cfif>	
											<cfif listfind(formList,"/EditContainer.cfm")>
												<li><a target="_top" href="/LoadBarcodes.cfm">Upload Scan File</a></li>
												<li><a target="_top" href="/EditContainer.cfm?action=newContainer">Create Container</a></li>
												<li><a target="_top" href="/CreateContainersForBarcodes.cfm">Create Container Series</a></li>
												<li><a target="_top" href="/SpecimenContainerLabels.cfm">Clear Part Flags</a></li>
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
												<li><a target="_top" href="/CodeTableEditor.cfm">Code Tables</a></li>
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
											<li><a target="_top" href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
											<li><a target="_top" href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
											<cfif listfind(formList,"/tools/sqlTaxonomy.cfm")>
												<li><a target="_top" href="/tools/sqlTaxonomy.cfm">SQL Taxonomy</a></li>
											</cfif>
										</ul>
									</li>
								</cfif>		
							</ul>
						<li><a target="_top" href="##">Manage Arctos</a>
							<ul>
								<cfif listfind(formList,"/info/svn.cfm")>
									<li>
										<a target="_top" href="##">Developer Widgets</a>
										<ul>
											<li><a target="_top" href="/ScheduledTasks/index.cfm">Scheduled Tasks</a></li>
											<li><a target="_top" href="/info/svn.cfm">SVN</a></li>
											<li><a target="_top" href="/Admin/dumpAll.cfm">dump</a></li>
											<li><a target="_top" href="/CFIDE/administrator/">Manage ColdFusion</a></li>
											<li><a target="_top" href="/tools/imageList.cfm">Image List</a></li>
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
									<li><a target="_top" href="/info/MoreCitationStats.cfm">Even More Citation Stats</a></li>
									<li><a target="_top" href="/Admin/download.cfm">Download Stats</a></li>
									<li><a target="_top" href="/info/queryStats.cfm">Query Stats</a></li>
									<li><a target="_top" href="/Admin/ActivityLog.cfm">Audit SQL</a></li>
									<li><a target="_top" href="/tools/downloadData.cfm">Download Tables</a></li>
									<li><a target="_top" href="/tools/access_report.cfm">Oracle Roles</a></li>									
				                    <cfif listfind(formList,"/tools/userSQL.cfm")>
									    <li><a target="_top" href="/tools/userSQL.cfm">Write SQL</a></li>
				                    </cfif>
				                    <li><a target="_top" href="##">Funky Data</a>
										<ul>
											<li><a target="_top" href="/Admin/bad_taxonomy.cfm">Invalid Taxonomy</a></li>
											<li><a target="_top" href="/info/slacker.cfm">Suspect Data</a></li>
											<li><a target="_top" href="/info/noParts.cfm">Partless Specimens</a></li>
											<li><a target="_top" href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
											<li><a target="_top" href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
											<li><a target="_top" href="/info/dupAgent.cfm">Duplicate Agents</a></li>
											<li><a target="_top" href="/Reports/partusage.cfm">Part Usage</a></li>
										</ul>
									</li>
								</ul>
							</li>
					    </cfif>
					</cfif>
				    <li><a target="_top" href="/myArctos.cfm">My Stuff</a>
				   		<ul>
							<cfif len(session.username) gt 0>
								<li><a target="_top" href="/myArctos.cfm">Profile</a></li>
							<cfelse>
								<li><a target="_top" href="/myArctos.cfm">Log In</a></li>
							</cfif>
							<li><a target="_top" href="/home.cfm">About</a></li>
							<li><a target="_top" href="/Collections/index.cfm">Collections (Loans)</a></li>
							<li><a target="_top" href="/saveSearch.cfm?action=manage">Saved Searches</a></li>
							<li><a target="_top" href="/info/api.cfm">API</a></li>
						</ul>
					</li>		
				</ul>
			</div>
		</div><!--- end header div --->
		<cf_rolecheck>
	</cfoutput>
<br><br>