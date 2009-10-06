<cfcache action="clientcache">
I'm new
<div class="sf-mainMenuWrapper">
	<ul class="sf-menu">
		<li>
			<a target="_top" href="/SpecimenSearch.cfm">Search</a>
			<ul>
				<li><a target="_top" href="/SpecimenSearch.cfm">Specimens</a></li>
				<li><a target="_top" href="/SpecimenUsage.cfm">Publications/Projects</a></li>
				<li><a target="_top" href="/TaxonomySearch.cfm">Taxonomy</a></li>
                <li><a target="_top" href="/MediaSearch.cfm">Media</a></li>
                <li><a target="_top" href="/document.cfm">Documents&nbsp;(BETA)</a></li>
                <li><a target="_top" href="/SpecimenSearchHTML.cfm">Specimens&nbsp;(no&nbsp;JavaScript)</a></li>
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
								<li><a target="_top" href="/tools/BulkloadAgents.cfm">Bulkload Agents</a></li>
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
					<cfif listfind(formList,"/info/reviewAnnotation.cfm")>
						<li><a target="_top" href="##">Tools</a>
							<ul>
								<li><a target="_top" href="/tools/PublicationStatus.cfm">Publication Staging</a></li>
								<li><a target="_top" href="/tools/parent_child_taxonomy.cfm">Sync parent/child taxonomy</a></li>
								<cfif listfind(formList,"/CodeTableEditor.cfm")>
									<li><a target="_top" href="/CodeTableEditor.cfm">Code tables</a></li>
								</cfif>
								<li><a target="_top" href="/info/geol_hierarchy.cfm">Geol. Att. Hierarchy</a></li>
								<li><a target="_top" href="/tools/pendingRelations.cfm">Pending Relationships</a></li>
								<li><a target="_top" href="/Admin/Collection.cfm">Manage Collection</a></li>
								<li><a target="_top" href="/Encumbrances.cfm">Encumbrances</a></li>
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
						<li><a target="_top" href="/Admin/download.cfm">Download Stats</a></li>
						<li><a target="_top" href="/info/queryStats.cfm">Query Stats</a></li>
						<li><a target="_top" href="/info/Citations.cfm">Citation Stats</a></li>
						<li><a target="_top" href="/Admin/ActivityLog.cfm">Audit SQL</a></li>
						<li><a target="_top" href="/tools/downloadData.cfm">Download Tables</a></li>
						<li><a target="_top" href="/tools/access_report.cfm">Oracle Roles</a></li>
	                           <cfif listfind(formList,"/tools/userSQL.cfm")>
						    <li><a target="_top" href="/tools/userSQL.cfm">Write SQL</a></li>
	                    </cfif>
	                    <li><a target="_top" href="##">Funky Data</a>
							<ul>
								<li><a target="_top" href="/info/slacker.cfm">Suspect Data</a></li>
								<li><a target="_top" href="/info/noParts.cfm">Partless Specimens</a></li>
								<li><a target="_top" href="/tools/TaxonomyGaps.cfm">Messy Taxonomy</a></li>
								<li><a target="_top" href="/tools/findGap.cfm">Catalog Number Gaps</a></li>
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
				<li><a target="_top" href="/home.cfm">Home</a></li>
				<li><a target="_top" href="/Collections/index.cfm">Collections (Loans)</a></li>
				<li><a target="_top" href="/saveSearch.cfm?action=manage">Saved Searches</a></li>
				<li><a target="_top" href="/info/api.cfm">API</a></li>
			</ul>
		</li>		
	</ul>
</div>