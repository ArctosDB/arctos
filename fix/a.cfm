<cfoutput>

<!----

create table temp_c_t (
	id varchar2(255),
	p_id varchar2(255),
	e_trm varchar2(255),
	f_trm varchar2(255),
	alt_trm varchar2(255)
);

	http://nomenclature.info/nom/291


	---->

<cffile action = "read"
file = "/usr/local/httpd/htdocs/wwwarctos/temp/ctax.jsonld"
variable = "x">


<cfset j=DeserializeJSON(x)>


<!--- outer array and struct are meaningless --->
<cfset ar=j[1]["@graph"]>

<!----
<cfdump var=#ar#>
---->
<cftransaction>
<cfloop from ="1" to="10" index="i">
	<cfset thisrec=ar[i]>

	<cfdump var=#thisrec#>
	<cfset thisID=thisrec["@id"]>
	<br>thisID::#thisID#

	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##broader")>
		<cfset thisPID=thisrec["http://www.w3.org/2004/02/skos/core##broader"][1]["@id"]>
	<cfelse>
		<cfset thisPID='NOEXIST'>
	</cfif>

	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##altLabel")>
		<cfset thisAL=thisrec["http://www.w3.org/2004/02/skos/core##altLabel"][1]["@value"]>
	<br>thisAL::#thisAL#

	<cfelse>
		<cfset thisAL='NOEXIST'>
	</cfif>

			<cfset thisET="">

			<cfset thisFT="">
	<cfif structkeyexists(thisrec,"http://www.w3.org/2004/02/skos/core##prefLabel")>
		<cfset tary=thisrec["http://www.w3.org/2004/02/skos/core##prefLabel"]>
		<cfdump var=#tary#>
		<cfloop from="1" to="#ArrayLen(tary)#" index="idx">
			<cfset thisLG=tary[idx]["@language"]>
			<br>thisLG::#thisLG#
			<cfif thisLG is 'en'>
				#tary[idx]["@value"]#
				<cfset thisET=tary[idx]["@value"]>
			<cfelseif thisLG is 'fr'>
				<cfset thisFT=tary[idx]["@value"]>
			</cfif>
		</cfloop>

	</cfif>

	<br>thisET::#thisET#
	<br>thisFT::#thisFT#


	<br>thisPID::#thisPID#


	create table temp_c_t (
	id varchar2(255),
	p_id varchar2(255),
	e_trm varchar2(255),
	f_trm varchar2(255),
	alt_trm varchar2(255)
);



	<cfquery name="ist" datasource="uam_god">
		insert into temp_c_t (id,p_id,e_trm ,f_trm ,alt_trm) values ('#thisID#','#thisPID#','#thisET#','#thisFT#','#thisAL#')
	</cfquery>

</cfloop>
</cftransaction>
</cfoutput>

<cfabort>










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











						<!---


						-------->



						<cfset formList="">



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
											<li><a target="_top" href="/DataServices/wktomaticifier.cfm">Convert KML to WKT</a></li>
											<li><a target="_top" href="/DataServices/coordinate_splitter.cfm">Coordinate Formatter</a></li>
											<li><a target="_top" href="/DataServices/dateSplit.cfm">Date Formatter</a></li>
											<li><a target="_top" href="/tools/barcode2guid.cfm">Find GUID from Barcode</a></li>
											<li><a target="_top" href="/DataServices/getGeogFromSpecloc.cfm">Find Higher Geography from Specific Locality</a></li>
											<li><a target="_top" href="/DataServices/findNonprintingCharacters.cfm">Find/Replace Nonprinting Characters</a></li>
											<li><a target="_top" href="/DataServices/geog_lookup.cfm">Higher Geog Lookup</a></li>

											<li><a target="_top" href="/tools/genbank_submit.cfm">Package GenBank Data</a></li>

											<li><a target="_top" href="/DataServices/SciNameCheck.cfm">Scientific Name Checker</a></li>
											<li><a target="_top" href="/DataServices/taxonNameValidator.cfm">Taxon Name Validator</a></li>
										</ul>
									</li>
									 <li><a target="_top" href="##">Find Low-Quality Data</a>
										<ul>
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

		<!--------


	<cfquery name="d" datasource="uam_god">
		select * from cataloged_item where rownum<20
	</cfquery>
	<cfdump var=#d#>

		---->
	</cfoutput>
<br><br>








---->












<cfabort>


















<cfinclude template="/includes/_header.cfm">



<cfset Application.serverrooturl='http://arctos-test.tacc.utexas.edu'>

<cfoutput>#CreateObject("java", "java.lang.System").getProperty("java.version")#



	<cfquery name="d" datasource="uam_god">
		select getJsonMediaClob(collection_object_id) x from flat where guid='#guid#'
	</cfquery>

	<cfset j=DeserializeJSON(d.x)>
	<cfdump var=#j#>

</cfoutput>
			<cfabort>




<!---

create table temp_cd_nodef (
	table_name varchar2(255),
	column_name varchar2(255),
	we_have_no_idea_what_this_means varcahr2(255)
);
---->

<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from cf_global_settings
	</cfquery>

 S3_ENDPOINT								    VARCHAR2(4000)
 S3_ACCESSKEY								    VARCHAR2(4000)
 S3_SECRETKEY								    VARCHAR2(4000)



<cfif action is "fupl">


</cfif>


<cfif action is "ziptest">

	<cfset expDate = DateConvert("local2utc", now())>
	<cfset expDate = DateAdd("n", 15, expDate)><!--- policy expires in 15 minutes --->
	<cfset fileName = CreateUUID() & ".jpg">
	<cfsavecontent variable="jsonPolicy">
	{ "expiration": "#DateFormat(expDate, "yyyy-mm-dd")#T#TimeFormat(expDate, "HH:mm")#:00.000Z",
	  "conditions": [
	    {"bucket": "testing.mctesty" },
	    ["eq", "$key", "#JSStringFormat(fileName)#"],
	    {"acl": "public-read" },
	    {"redirect": "https://example.com/upload-complete.cfm" },
	    ["content-length-range", 1, 1048576],
	    ["starts-with", "$Content-Type", "image/"]
	  ]
	}
	</cfsavecontent>
	<cfset b64Policy = toBase64(Trim(jsonPolicy), "utf-8")>
	<cfset signature = HMac(b64Policy, d.S3_SECRETKEY, "HMACSHA1", "utf-8")>
	<!--- convert signature from hex to base64 --->
	<cfset signature = binaryEncode( binaryDecode( signature, "hex" ), "base64")>
	<form action="http://129.114.52.101:9003/minio/testing.mctesty/" method="post" enctype="multipart/form-data">
	    <input type="hidden" name="key" value="#EncodeForHTMLAttribute(fileName)#" />
	    <input type="hidden" name="acl" value="public-read" />
	    <input type="hidden" name="redirect" value="https://example.com/upload-complete.cfm" >
	    <input type="hidden" name="AWSAccessKeyId " value="#EncodeForHTMLAttribute(d.S3_ACCESSKEY)#" />
	    <input type="hidden" name="Policy" value="#b64Policy#" />
	    <input type="hidden" name="Signature" value="#signature#" />
	    File: <input type="file" name="file" />
	    <input type="submit" name="submit" value="Upload to Amazon S3" />
	</form>

</cfif>



<cfif action is "putfile">
	<cfset lclfile="/images/Arctos_schema.gif">

	<br>lclfile: #lclfile#
	<cfset resource = listlast(lclfile,"/")>
	<br>resource: #resource#
	<cfset fPath=replace(lclfile,resource,"","last")>
	<br>fPath: #fPath#

	<cfset content = fileReadBinary( expandPath( "#lclfile#" ) ) />

	<cfset bucket="dlm/bla/date">
	<cfset currentTime = getHttpTimeString( now() ) />
	<cfset contentType = "image/gif" />
	<cfset contentLength=arrayLen( content )>

	<cfset stringToSignParts = [
	    "PUT",
	    "",
	    contentType,
	    currentTime,
	    "/" & bucket & "/" & resource
	] />

	<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />

	<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, d.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>


	<cfhttp
	    result="put"
	    method="put"
	    url="#d.s3_endpoint#/#bucket#/#resource#">

		<cfhttpparam
	        type="header"
	        name="Authorization"
	        value="AWS #d.s3_accesskey#:#signature#"
		/>




	    <cfhttpparam
	        type="header"
	        name="Content-Length"
	        value="#contentLength#"
	        />

	    <cfhttpparam
	        type="header"
	        name="Content-Type"
	        value="#contentType#"
	        />

	    <cfhttpparam
	        type="header"
	        name="Date"
	        value="#currentTime#"
	        />

	    <cfhttpparam
	        type="body"
	        value="#content#"
	        />
	</cfhttp>


	<!--- Dump out the Amazon S3 response. --->
<cfdump
    var="#put#"
    label="S3 Response"
/>

</cfif>



<cfif action is "list">


	<cfset currentTime = getHttpTimeString( now() ) />
	<cfset contentType = "text/html" />
	<!--- leave blank to list all --->
	<cfset bucket="testing.mctesty">

	<cfset stringToSignParts = [
	    "GET",
	    "",
	    "",
	    currentTime,
	    "/" &  bucket
	] />
	<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />

	<cfset dsts=replace(stringToSign,chr(10),"\n","all")>
	<br>stringToSign: #stringToSign#
	<br>dsts: #dsts#
	<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, d.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>

	<cfhttp method="GET" url="#d.s3_endpoint#/#bucket#" charset="utf-8">
	    <cfhttpparam type="header" name="Date" value="#currentTime#">
		<cfhttpparam type="header" name="Authorization" value="AWS #d.s3_accesskey#:#signature#">
	    <cfhttpparam type="header" name="prefix" value="/mai_bukkit/">
	    <cfhttpparam type="header" name="list-type" value="2">
	</cfhttp>

<cfdump var=#cfhttp#>
<cfset x=xmlparse(cfhttp.Filecontent)>
<cfdump var=#x#>
</cfif>





<cfif action is "makebucket">
	<cfset currentTime = getHttpTimeString( now() ) />

	<cfset contentType = "text/html" />
	<cfset bucket="usernaaame/dddaaatteee">

<cfset stringToSignParts = [
	    "PUT",
	    "",
	    contentType,
	    currentTime,
	    "/" & bucket
	] />

	<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />

	<br>stringToSign: #stringToSign#
	<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, d.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>





<cfhttp
    result="put"
    method="put"
    url="#d.s3_endpoint#/#bucket#">

	<cfhttpparam
	        type="header"
	        name="Authorization"
	        value="AWS #d.s3_accesskey#:#signature#"
		/>


	    <cfhttpparam
	        type="header"
	        name="Content-Type"
	        value="#contentType#"
	        />
	    <cfhttpparam
	        type="header"
	        name="Date"
	        value="#currentTime#"
	        />


		<!----
    <cfhttpparam
        type="header"
        name="x-amz-acl"
        value="bucket-owner-full-control"
        />
    <cfhttpparam
        type="header"
        name="Content-Length"
        value="#arrayLen( content )#"
        />

    <cfhttpparam
        type="header"
        name="Content-Type"
        value="#contentType#"
        />

    <cfhttpparam
        type="header"
        name="Date"
        value="#currentTime#"
        />

    <cfhttpparam
        type="body"
        value="#content#"
        />
------->
</cfhttp>

<!--- Dump out the Amazon S3 response. --->
<cfdump
    var="#put#"
    label="S3 Response"
/>

</cfif>



</cfoutput>



		<!----









<!--- This example shows how to retrieve the EXIF header information from a
JPEG file. --->
<!--- Create a ColdFusion image from an existing JPEG file. --->
<cfimage source="https://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads/20170607/UA98_010_0001C.jpg" name="myImage">
<!--- Retrieve the metadata associated with the image. --->
<cfset data =ImageGetEXIFMetadata(myImage)>
<!--- Display the ColdFusion image parameters. --->
<cfdump var="#myImage#">
<!--- Display the EXIF header information associated with the image
(creation date, software, and so on). --->
<cfdump var="#data#"><cfoutput>




</cfoutput>




<script>
	$(document).ready(function() {

	jQuery.ajax({
      type: 'GET',
      url: 'http://arctos.database.museum/demo'
    });
    	});

</script>






<cfquery name="d" datasource="uam_god">
	select * from user_tab_cols where table_name like 'CT%'
</cfquery>
<cfquery name="tabl" dbtype="query">
	select table_name from d group by table_name
</cfquery>

	<cfloop query="tabl">
		<cfquery name="cols" dbtype="query">
			select * from d where table_name='#table_name#'
		</cfquery>

		<cfset thisSQL="drop table log_#tabl.table_name#">
		<cftry>
			<cfquery name="drop" datasource="uam_god">
				#thisSQL#
			</cfquery>
			<br>#thisSQL#
		<cfcatch>
			<br>FAIL: could not #thisSQL#
			<!----
			<cfdump var=#cfcatch#>
			------>
		</cfcatch>
		</cftry>

		<cfset thisSQL="create table log_#tabl.table_name# (
		username varchar2(60),
		when date default sysdate,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "n_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "o_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfset thisSQL=thisSQL & ")">
		<cfset thisSQL=replace(thisSQL,',)',')')>
		#thisSQL#
		<cfquery name="buildtable" datasource="uam_god">
			#thisSQL#
		</cfquery>
		<cfquery name="buildps" datasource="uam_god">
			create or replace public synonym log_#tabl.table_name# for log_#tabl.table_name#
		</cfquery>
		<cfquery name="grantps" datasource="uam_god">
			grant select on log_#tabl.table_name# to coldfusion_user
		</cfquery>

		<cfset thisSQL="CREATE OR REPLACE TRIGGER TR_log_#table_name# AFTER INSERT or update or delete ON #table_name# FOR EACH ROW BEGIN insert into log_#table_name# ( username, when,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "n_#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "o_#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & ") values ( SYS_CONTEXT('USERENV','SESSION_USER'),	sysdate,">
		<cfset thisSQL=replace(thisSQL,',)',')','all')>

		<cfloop query="cols">
			<cfset thisSQL=thisSQL & ":NEW.#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & ":OLD.#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & ");">

		<cfset thisSQL=replace(thisSQL,',);',');','all')>

		<cfset thisSQL=thisSQL & "  END;">
		<p>
			#thisSQL#
		</p>
		<cfquery name="buildtr" datasource="uam_god">#thisSQL#</cfquery>


		<cfquery name="hastbl" datasource="uam_god">
			select count(*) c from all_objects where object_name='LOG_#tabl.table_name#'
		</cfquery>
		<cfif hastbl.c gte 1>
			<br>log_#tabl.table_name# exists
		<cfelse>
			<br>log_#tabl.table_name# NOTFOUND!!
		</cfif>

		<cfset thisSQL="create table log_#tabl.table_name# (
		<br>username varchar2(60),
		<br>when date default sysdate,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>n_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>o_#COLUMN_NAME# #DATA_TYPE#(#DATA_LENGTH#),">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>);">
		<cfset thisSQL=replace(thisSQL,',<br>);','<br>);')>
		<p>
			#thisSQL#
		</p>
		<p>
			create or replace public synonym log_#tabl.table_name# for log_#tabl.table_name#;
		</p>
		<p>
			grant select on log_#tabl.table_name# to coldfusion_user;
		</p>


		<cfquery name="hastbl" datasource="uam_god">
			select count(*) c from all_objects where object_name='TR_LOG_#tabl.table_name#'
		</cfquery>
		<cfif hastbl.c gte 1>
			<br>TR_LOG_#tabl.table_name# exists
		<cfelse>
			<br>TR_LOG_#tabl.table_name# NOTFOUND!!
		</cfif>



		<cfset thisSQL="CREATE OR REPLACE TRIGGER TR_log_#table_name# AFTER INSERT or update or delete ON #table_name#
			<br>FOR EACH ROW
			<br>BEGIN
    		<br>  insert into log_#table_name# (
			<br>username,
			<br>when,">
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>n_#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>o_#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>) values (
			<br>SYS_CONTEXT('USERENV','SESSION_USER'),
			<br>sysdate,">
		<cfset thisSQL=replace(thisSQL,',<br>)','<br>)','all')>

		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>:NEW.#COLUMN_NAME#,">
		</cfloop>
		<cfloop query="cols">
			<cfset thisSQL=thisSQL & "<br>:OLD.#COLUMN_NAME#,">
		</cfloop>
		<cfset thisSQL=thisSQL & "<br>);">

		<cfset thisSQL=replace(thisSQL,',<br>);','<br>);','all')>

		<cfset thisSQL=thisSQL & "  <br>END;<br>
			/">
		<p>
			#thisSQL#
		</p>




</cfloop>

</cfoutput>



		---->


<!----------------





















<!--- take a list of names
see if they're used
delete if safe
---->

<cfset x="
Haliotis assimilus - misspelling of Haliotis assimilis
Haliotis cracherodi - misspelling of Haliotis cracherodii
Haliotis kamtschatks and kamtschatkuna  - misspellings of Haliotis kamtschatkana
Haliotis kamtschatkuna  - misspellings of Haliotis kamtschatkana
Haliotis ovine - misspelling of Haliotis ovina
Haliotis sorensoni - misspelling of Haliotis sorenseni
Haliotis wallatensis - misspelling of Haliotis walallensis
Haliotis maria - misspelling of Haliotis mariae
Hippopus hippoeus - misspelling of Hippopus hippopus
Hippopus hippopuss - misspelling of Hippopus hippopus
Clyptemoda - looks like a misspelling of Glyptemoda
Cloristellidae - misspelling of Choristellidae
Haliotididae - misspelling of Haliotidae
Vivipariidae - misspelling of Viviparidae
Nerita albieilla - misspelling of Nerita albicilla
Neritina tahitensis - misspelling of Neritina taitensis (now Neripteron taitense) which we'll add when we need it.
Smaragdia viridus - misspelling of Smaragdia viridis
Volutidae cassidula - creative combination of a family and a species - not used - delete.  Accepted as Lyria cassidula which is in Arctos
Eutrochaetella - misspelling of Eutrochatella
Radula barreti (and Radula) should be in Limidae (bivalve), though unaccepted, but are showing up in Neritopsidae (gastropod).  No one is using them so I would delete them.  Radula IS used by Arctos Plants.
Neretina neglecta and Neretina (IDK) - misspelling of Neritina but not an accepted species either.  Not being used.
Muricanthus rigritus - a misspelling of Muricanthus nigritus (which is no longer accepted anyway)
Aspella prodcta pea - Must be a cat joke.  The species is Aspella producta (Pease, 1861)
Chicoreus rossitei - misspelling of Chicoreus rossiteri
Chicoreus rubinginosis - misspelling of Chicoreus rubiginosis
Dermomurex paupercula - misspelling of Dermomurex pauperculus
Haustellum bellegladeense - misspelling of Haustellum bellegladeensis - unaccepted - now Vokesimurex bellegladeensis
Haustellum hastellum - misspelling of Haustellum haustellum
Hexaplex chichoreus - misspelling of Hexaplex cichoreum
Hexaplex chicoreus - misspelling of Hexaplex cichoreum
Hexaplex cichoveum - more creative misspelling Hexaplex cichoreum
Hexaplex erythrostoma - misspelling of Hexaplex erythrostomus
Hexaplex kusterianus - misspelling of  Hexaplex kuesterianus
Poirieria nutlingi - misspelling of Poirieria nuttingi
Pterynotus martinetana - misspelling of Pterynotus martinetanus
Colubrarca obscura - misspelling of Colubraria obscura
Eburnea valentiniana and Eburnea zeylanica - misspelling of Eburna - fossil species
Hastula gnomen - misspelling of Hastula gnomon
Heterozona cariosa - misspelling of Heterozona cariosus
Hexaplex anuglaris - misspelling of Hexaplex angularis
Hindsia magnifca - misspelling of Hindsia magnifica which is unaccepted
Hydatina amplustrum - misspelling of Hydatina amplustre which is unaccepted anyway
Iphigenia altier - misspelling of Iphigenia altior
Isognomon costellotum - misspelling of Isognomon costellatum
Lambis artitica - misspelling of Lambis arthritica accepted as Harpago arthriticus
Latirus polygonnus - misspelling of Latirus polygonus
Leucozonia ceratus - Leucozonia cerata
Leucozonia tuberculate - misspelling of Leucozonia tuberculata
Leucozonia tuberculatus - misspelling of Leucozonia tuberculata
Luria cinera - misspelling of Luria cinerea
Lyropecten sunnodosus - misspelling of Lyropecten subnodosus which is unaccepted anyway
Macros aethipos - misspelling of Macron aethiops
Metula clarthata - misspelling of Metula clathrata
Mitra ruepelli - misspelling of Mitra rueppellii
Mitra ruepellii - closer but stiill a misspelling of Mitra rueppellii
Mitra stricta - misspelling of Mitra stictica
Molopophorus anglonanus - misspelling of Molopophorus anglonana
Morum cancellata - misspelling of Morum cancellatum
Smaragdia viridus - misspelling of Smaragdia viridis
Lucina colombiana - probably a misspelling of Lucina colombiana
Chedvillia stewarti - misspelling of fossil Chedevillia.  None in Arctos.
Marinauris - unaccepted - accepted as Haliotis per WoRMS
Marinauris roei - unaccepted - accepted as Haliotis roei
Smaragdiinae - unaccepted - accepted as Neritidae
Tanzaniella - the only thing I can find is in Arthropoda.  No children and not in use.
Anabathronidae - unaccepted.  Should be Anabathridae
Muricanthus callindinus - the only reference on the internet is our Arctos entry.
Muricanthus saharieus - the only reference on the internet is our Arctos entry.  Probably a misspelling of Hexaplex saharicus
">

<cftransaction>
 <cfloop list="#x#" index="i" delimiters="#chr(10)#">

	<cfset theName=trim(listgetat(i,1,'-'))>
	<hr>
	<br><a href="http://arctos.database.museum/name/#theName#">#theName#</a>
	 <cfquery datasource='prod' name='d'>
		select taxon_name_id from taxon_name where scientific_name='#theName#'
	</cfquery>
	<cfif d.recordcount is 1>
		<br>isname
		 <cfquery datasource='prod' name='hasr'>
			select count(*) c from taxon_relations where TAXON_NAME_ID=#d.TAXON_NAME_ID# or RELATED_TAXON_NAME_ID=#d.TAXON_NAME_ID#
		</cfquery>
		<cfif hasr.c is 0>
			<br>no relationships
			 <cfquery datasource='prod' name='hasid'>
				select count(*) c from identification_taxonomy where TAXON_NAME_ID=#d.TAXON_NAME_ID#
			</cfquery>

			<cfif hasid.c is 0>
				<br>no IDs
			 	<cfquery datasource='prod' name='src'>
					select distinct source from taxon_term where TAXON_NAME_ID=#d.TAXON_NAME_ID#
				</cfquery>
				<cfif src.recordcount gt 1>
					<br>multiple source probably real::#valuelist(src.source)#
				<cfelse>
					<br>0/1 source
			 		<cfquery datasource='prod' name='deleteTerms'>
						delete from taxon_term where  TAXON_NAME_ID=#d.TAXON_NAME_ID#
					</cfquery>
			 		<cfquery datasource='prod' name='deleteName'>
						delete from taxon_name where  TAXON_NAME_ID=#d.TAXON_NAME_ID#
					</cfquery>
					<br>deleted
				</cfif>

			<cfelse>
				<br>-----has IDs
			</cfif>
		<cfelse>
			<br>----has relationships
		</cfif>
	<cfelse>
		<br>----notfound
	</cfif>





</cfloop>
</cftransaction>






















 <cfquery datasource='prod' name='d'>
		select higher_geog from geog_auth_rec
		-- where higher_geog like '%Australia%'
		order by higher_geog
	</cfquery>
	<cfloop query="d">
		<cfset gns=replace(higher_geog,", ",",","all")>
		<cfset ulist=ListRemoveDuplicates(gns)>
		<cfif ulist neq gns>
			<br>#higher_geog#
		</cfif>
	</cfloop>




permit
 -----------------------------------------------------------------
 PERMIT_ID		     NOT NULL PKEY
 ISSUED_DATE             NOT NULL DATE
 EXP_DATE                   NOT NULL DATE
 PERMIT_NUM	             NOT NULL VARCHAR2(25)
 PERMIT_REMARKS    VARCHAR2(4000)

new table permit_type
---------------------------------------------------
permit_type_id             NOT NULL PKEY
permit_id                      NOT NULL FKEK(permit)
PERMIT_TYPE               NOT NULL FKEY(ctpermit_type)
regulation                     FKEY(ctpermit_regulation)

permit_agent
-------------------------------
permit_agent_id            NOT NULL PKEY
permit_id                       NOT NULL FKEY(permit)
agent_id                        NOT NULL FKEY(agent)
agent_role                     NOT NULL FKEY(ctpermit_agent_role)



<h2>
	Example Create/Edit Permits Form
</h2>
<h3>Normal Stuff</h3>
<label>
	ISSUED_DATE
</label>
<input type="text" placeholder="datepicker">
<label>
	EXP_DATE
</label>
<input type="text" placeholder="datepicker">
<label>
	PERMIT_NUM
</label>
<input type="text" placeholder="this is required">
<label>
	PERMIT_REMARKS
</label>
<input type="text" placeholder="this is optional">

<h3>Permit Type</h3>
These will all be single-value selects, pretend they're "expanded" here
<table border>
	<tr>
		<td>Permit Type</td>
		<td>Regulation</td>
	</tr>
	<tr>
		<td>
			<select multiple>
				<option>collect</option>
				<option>export</option>
				<option>import</option>
				<option>research</option>
				<option>salvage</option>
				<option>transport</option>
			</select>
		</td>

		<td>
			<select multiple>
				<option>CITES</option>
				<option>BGEPA</option>
				<option>ESA</option>
				<option>MBTA</option>
				<option>WBCA</option>
				<option>MMPA</option>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			Click to add a row or etc. - you can have as many of these as you need.
		</td>
	</tr>
</table>

<h3>Permit Agent</h3>
These will all be single-value selects, pretend they're "expanded" here
<table border>
	<tr>
		<td>Agent</td>
		<td>Role</td>
	</tr>
	<tr>
		<td>
			<input type="text" placeholder="agent-picker">

		</td>

		<td>
			<select multiple>
				<option>issued by</option>
				<option>issued to</option>
				<option>contact</option>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			Click to add a row or etc. - you can have as many of these as you need.
		</td>
	</tr>
</table>









	<cffunction
	    name="ISOToDateTime"
	    access="public"
	    returntype="string"
	    output="false"
	    hint="Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.">

	    <!--- Define arguments. --->
	    <cfargument
	    name="Date"
	    type="string"
	    required="true"
	    hint="ISO 8601 date/time stamp."
	    />

	    <!---
	    When returning the converted date/time stamp,
	    allow for optional dashes.
	    --->
	    <cfreturn ARGUMENTS.Date.ReplaceFirst(
	    "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
	    "$1-$2-$3 $4"
	    ) />
</cffunction>



<cfexecute
	 timeout="10"
	 name = "/usr/bin/tail"
	 errorVariable="errorOut"
	 variable="exrslt"
	 arguments = "-5000 #Application.requestlog#" />

<cfset x=queryNew("ts,ip,rqst,usrname")>
<cfloop list="#exrslt#" delimiters="#chr(10)#" index="i">
	<cfset t=listgetat(i,1,"|","yes")>
	<cfset ipa=listgetat(i,5,"|","yes")>
	<cfset r=listgetat(i,7,"|","yes")>
	<cfset u=listgetat(i,3,"|","yes")>
	<cfset queryAddRow(x,{ts=t,ip=ipa,rqst=r,usrname=u})>
</cfloop>

<!--- don't care about scheduled tasks ---->
<cf_qoq>
	delete from x where ip='0.0.0.0'
</cf_qoq>
<!--- for now, ignore cfc request ---->
<cfquery name="x" dbtype="query">
	select * from x where rqst not like '%.cfc%'
</cfquery>

<cfquery name="dip" dbtype="query">
	select distinct(ip) from x
</cfquery>

<cfset maybeBad="">
<cfloop query="dip">
	<br>running for #ip#
	<cfquery name="thisRequests" dbtype="query">
		select * from x where ip='#ip#' order by ts
	</cfquery>
	<cfif thisrequests.recordcount gte 10>
		<!--- IPs making 10 or fewer requests just get ignored ---->
		<cfset lastTime=ISOToDateTime("2000-11-08T12:36:0")>
		<cfset nrq=0>
		<cfloop query="thisRequests">
			<cfset thisTime=ISOToDateTime(ts)>
			<cfset ttl=DateDiff("s", lastTime, thisTime)>
			<cfif ttl lte 10>
				<cfset nrq=nrq+1>
			</cfif>
			<cfset lastTime=thisTime>
		</cfloop>
		<cfif nrq gt 10>
			<cfset maybeBad=listappend(maybeBad,'#ip#|#nrq#',",")>
		</cfif>
	</cfif>
</cfloop>

mailing to #application.logemail#....

	<cfloop list="#maybeBad#" index="o" delimiters=",">
		<cfset thisIP=listgetat(o,1,"|")>
		<cfset cfcnt=listgetat(o,2,"|")>
		<p>IP #thisIP# made #cfcnt# flood-like requests in the last 5000 overall requests.</p>

		<a href="http://whatismyipaddress.com/ip/#thisIP#">[ lookup #thisIP# @whatismyipaddress ]</a>
		<br><a href="https://www.ipalyzer.com/#thisIP#">[ lookup #thisIP# @ipalyzer ]</a>
		<br><a href="https://gwhois.org/#thisIP#">[ lookup #thisIP# @gwhois ]</a>
		<p>
			<a href="#Application.serverRootURL#/Admin/blacklist.cfm?action=ins&ip=#thisIP#">[ blacklist #thisIP# ]</a>
			<br><a href="#Application.serverRootURL#/Admin/blacklist.cfm?ipstartswith=#thisIP#">[ manage IP and subnet restrictions ]</a>
		</p>



		<cfquery name="thisIPR" dbtype="query">
			select * from x where ip='#thisIP#' order by ts
		</cfquery>
		<cfloop query="thisIPR">
			<br>#usrname#|#ts#|#rqst#|#ip#
		</cfloop>
	</cfloop>

<cfmail to="#application.logemail#" subject="click flood detection" from="clickflood@#Application.fromEmail#" type="html">


	<cfloop list="#maybeBad#" index="o" delimiters=",">
		<cfset thisIP=listgetat(o,1,"|")>
		<cfset cfcnt=listgetat(o,2,"|")>
		<p>IP #thisIP# made #cfcnt# flood-like requests in the last 5000 overall requests.</p>

		<br><a href="http://whatismyipaddress.com/ip/#thisIP#">[ lookup #thisIP# @whatismyipaddress ]</a>
		<br><a href="https://www.ipalyzer.com/#thisIP#">[ lookup #thisIP# @ipalyzer ]</a>
		<br><a href="https://gwhois.org/#thisIP#">[ lookup #thisIP# @gwhois ]</a>
		<p>
			<a href="#Application.serverRootURL#/Admin/blacklist.cfm?action=ins&ip=#thisIP#">[ blacklist #thisIP# ]</a>
			<br><a href="#Application.serverRootURL#/Admin/blacklist.cfm?ipstartswith=#thisIP#">[ manage IP and subnet restrictions ]</a>
		</p>
		<cfquery name="thisIPR" dbtype="query">
			select * from x where ip='#thisIP#' order by ts
		</cfquery>
		<cfloop query="thisIPR">
			<br>#usrname#|#ts#|#rqst#|#ip#
		</cfloop>
	</cfloop>
</cfmail>







<cfdump var=#x#>


#Application.logfile#
<!---
create table temp_test (u varchar2(255), p varchar2(255));
insert into temp_test (u,p) values ('dustylee','xxxxx');
---->


    <cfquery datasource='uam_god' name='p'>
		select
		higher_geog,
		spec_locality
			from flat where guid='CHAS:Egg:569'
	</cfquery>
	<cfdump var=#p#>
<cfloop query="p">
	<cfset x= IIf(spec_locality EQ ""),DE(""),IIf(spec_locality) EQ "no specific locality recorded"),DE(""),DE(", " & de(spec_locality))))) >
</cfloop>
	<cfoutput>
	#x#
	</cfoutput>
<!----------------------------

 IIf((higher_geog EQ "no higher geography recorded"),DE(""),
DE(REPLACE(higher_geog,"North America, United States","USA","all"))) &
IIf((spec_locality EQ ""),
DE(""),
DE(IIf((spec_locality EQ "no specific locality recorded"),DE(""),DE(", " & spec_locality)))) is not a valid ColdFusion expression.

 &
				IIf(
					p.spec_locality EQ "",
					"",
					IIf(
						p.spec_locality EQ "no specific locality recorded",
						"",
						", " & p.spec_locality
					)
				)>



<cfoutput>


    <cfquery datasource='uam_god' name='p'>
        select * from temp_test
    </cfquery>


    <cfhttp
        method="post"
        username="#p.u#"
        password="#p.p#"
        result="pr"
        url="https://web.corral.tacc.utexas.edu/irods-rest/rest/fileContents/corralZ/web/UAF/arctos/mediaUploads/cfUpload/chas.jpeg">
            <cfhttpparam type="header" name="accept" value="multipart/form-data">
            <cfhttpparam type="file" name="chas.jpeg" file="/usr/local/httpd/htdocs/wwwarctos/images/chas.jpeg">
    </cfhttp>

    <cfdump var=#pr#>
</cfoutput>


drop table temp_dnametest;

create table temp_dnametest (
	taxon_name_id number,
	scientific_name varchar2(255),
	display_name varchar2(255),
	gdisplay_name varchar2(255),
	cid varchar2(255)
);

-- data
-- only get stuff with display name
-- for stuff that doesn't match, figure out why


delete from temp_dnametest where gdisplay_name is null;


insert into temp_dnametest (
	taxon_name_id,
	scientific_name,
	display_name,
	cid
) (
	select distinct
		taxon_term.taxon_name_id,
		taxon_name.scientific_name,
		taxon_term.term display_name,
		taxon_term.classification_id
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		taxon_term.term_type='display_name'
	);


select
	'"' || display_name || '"' || chr(9) || chr(9) || chr(9) || '"' || gdisplay_name || '"'
from
	temp_dnametest where
	gdisplay_name not like 'ERROR%' and gdisplay_name is not null and display_name!=gdisplay_name;

update temp_dnametest set gdisplay_name=null where gdisplay_name not like 'ERROR%' and gdisplay_name!=display_name;


create index ix_temp_junk on temp_dnametest (taxon_name_id) tablespace uam_idx_1;


<cfset utilities = CreateObject("component","component.utilities")>
<cfquery name="d" datasource="uam_god">
	select * from temp_dnametest where gdisplay_name is null and rownum<1000
</cfquery>
<cfoutput>
	<cftransaction>
	<cfloop query="d">

		<cfset x=utilities.generateDisplayName(cid)>
		<cfif len(x) is 0>
			<cfset x='NORETURN'>
		</cfif>
	<!----
		<br>scientific_name=#scientific_name#
		<br>display_name=<pre>#display_name#</pre>
		<br>x=<pre>#x#</pre>
			<cfif x is not display_name>
			<br>NOMATCH!!
		</cfif>
		--->

		<cfquery name="b" datasource="uam_god">
			update temp_dnametest set gdisplay_name='#x#' where taxon_name_id=#taxon_name_id#
		</cfquery>

	</cfloop>
	</cftransaction>
</cfoutput>

<cfabort>



	<cfset Application.docURL = 'http://handbook.arctosdb.org/documentation'>





<cfquery name="d" datasource="prod">
	select * from temp_dl_up where status is null
</cfquery>

<cfoutput>
	<cfloop query="d">
		<cfset nl=newlink>
		<hr>
		<br>#newlink#
		<cfif newlink contains "##">
			<cfset anchor=listgetat(newlink,2,'##')>
		<cfelse>
			<cfset anchor=''>
			<cfset as='noanchor'>
		</cfif>


		<cfhttp url="#newlink#" method="GET"></cfhttp>

			<cfdump var=#cfhttp#>


		<cfset s=left(cfhttp.statuscode,3)>
		<cfif len(anchor) gt 0>
			<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>

			<br>cfhttp.fileContent does not contain 'id="#anchor#"'



				<cfset as='anchor_notfound'>
				<cfif anchor contains "_">
					<br>gonna try anchor magic....
					<cfset anchor=replace(anchor,"_","-","all")>
					<cfset nl=listdeleteat(nl,2,'##')>
					<cfset nl=nl & '##' & anchor>
					<br>nl is now #nl#
					<cfhttp url="#nl#" method="GET"></cfhttp>


					<cfdump var=#cfhttp#>

					<cfif cfhttp.fileContent contains 'id="#anchor#"'>
						happy!!
						<cfset as='anchor_mod'>
					</cfif>

				</cfif>
			<cfelse>
				<cfset as='anchorhappy'>
			</cfif>
		</cfif>

		<cfquery name="ud" datasource="prod">
			update temp_dl_up set status='#s#',anchorstatus='#as#' where newlink='#newlink#'
		</cfquery>

		<br>update temp_dl_up set newlink='#nl#',status='#s#',anchorstatus='#as#' where newlink='#newlink#'
	</cfloop>
</cfoutput>




<cfquery name="d" datasource="uam_god">
with rws as (
SELECT SYS_CONNECT_BY_PATH(t || '##' || level , ',') || ',' pth
FROM test
where t like 'Sorex%'
START WITH pid is null
CONNECT BY PRIOR id = pid
), vals as (
  select
  substr(pth,
    instr(pth, '##', 1, column_value) + 2,
    ( instr(pth, ',', 1, column_value + 1) - instr(pth, '##', 1, column_value) - 2 )
  ) - 1 levl,
  substr(pth,
    instr(pth, ',', 1, column_value) + 1,
    ( instr(pth, '##', 1, column_value) - instr(pth, ',', 1, column_value) - 1 )
  ) valv
  from rws, table ( cast ( multiset (
    select level l
    from   dual
    connect by level <= length(pth) - length(replace(pth, ','))
  ) as sys.odcinumberlist)) t
)
  select distinct lpad(' ', levl * 2) || valv valv, levl
  from   vals
  where  valv is not null
  order  by levl

</cfquery>

<cfoutput>
<cfloop query="d">
	<br>#valv#
</cfloop>

Upload state CSV:
	<form name="getFile" method="post" action="a.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getfish2">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
	create table temp_geostate (
	name varchar2(4000),
	id varchar2(4000),
	geometry clob
	);


<cfif action is "getfish2">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<br>x.recordcount: #x.recordcount#
		<cfflush>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into temp_geostate (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "geometry">
		            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
		                <cfelse>
		            		'#escapeQuotes(evaluate(i))#'
		            	</cfif>
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to temp_geostate go go gadget sql
	</cfoutput>
</cfif>



Upload county CSV:
	<form name="getFile" method="post" action="a.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getfish">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
<cfif action is "getfish">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<br>x.recordcount: #x.recordcount#
		<cfflush>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into temp_geocounty (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "geometry">
		            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
		                <cfelse>
		            		'#escapeQuotes(evaluate(i))#'
		            	</cfif>
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to temp_geocounty go go gadget sql
	</cfoutput>
</cfif>

create table temp_geocounty (
	CountyName varchar2(4000),
	StateCounty varchar2(4000),
	stateabbr varchar2(4000),
	StateAbbrToo varchar2(4000),
	geometry clob,
	value varchar2(4000),
	GEO_ID varchar2(4000),
	GEO_ID2 varchar2(4000),
	GeographicName varchar2(4000),
	STATEnum varchar2(4000),
	COUNTYnum varchar2(4000),
	FIPSformula varchar2(4000),
	Haserror varchar2(4000)
	);
</cfoutput>
<!--------------------


<cfhttp method="post" url="https://api.opentreeoflife.org/v2/tnrs/match_names">

	<cfhttpparam type="header"
        name ="application/json"
       value ="content-type">

	<cfhttpparam type="Formfield"
        value="Annona cherimola"
        name="names">
	<cfhttpparam type="Formfield"
        value="Aberemoa dioica"
        name="names">
	<cfhttpparam type="Formfield"
        value="Annona acuminata"
        name="names">


</cfhttp>

<cfdump var=#cfhttp#>


<cfset jr=DeserializeJSON(cfhttp.filecontent)>

<cfdump var=#jr#>

?names=Annona cherimola" \
-H "" -d \
'{"names":["Aster","Symphyotrichum","Erigeron","Barnadesia"]}'



https://api.opentreeoflife.org/v2/tnrs/match_names?names=

clobs suck
move tehm

create table temp_mc_log (cn varchar2(255));



<cfquery name="td" datasource="UAM_GOD">
	select * from (select * from chas where cat_num not in (select cn from temp_mc_log)) where rownum<500
</cfquery>
<cfloop query="td">
	<cfquery name="insthis" datasource="prod">
		insert into temp_chas_mamm (#td.columnlist#) values (
		<cfloop list="#td.columnlist#" index="i">
            <cfif i is "wkt_polygon">
           		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
            <cfelse>
           		'#escapeQuotes(evaluate(i))#'
           	</cfif>
           	<cfif i is not listlast(td.columnlist)>
           		,
           	</cfif>
		</cfloop>
		)
	</cfquery>
	<cfquery name="l" datasource="UAM_GOD">
		insert into temp_mc_log (cn) values ('#td.cat_num#')
	</cfquery>
</cfloop>
<!---------------------------------------------------------------------------------------------------->

--------->
--------->
--------->

<cfinclude template="/includes/_footer.cfm">