<div style="padding-left:25px; ">
	<table cellpadding="0" cellspacing="0" border="0" width="95%">
		<tr>
			<td nowrap>		
				<ul id="tabmenu">		
					<li>
						<a href="/SpecimenSearch.cfm" 
						target="_top"
						<cfif 
						#cgi.SCRIPT_NAME# contains "SpecimenSearch.cfm"> class="active"</cfif>
						><span>Specimen Search</span></a>
					</li>
					<li>
						<a href="/SpecimenUsage.cfm" 
						<cfif #cgi.SCRIPT_NAME# contains "SpecimenUsage.cfm"> class="active"</cfif>
						target="_top" ><span>Publication/Project Search</span></a>
					</li>
					<cfif #client.rights# contains "student0">
						<li>
							<a href="/TaxonomySearch.cfm" 
							<cfif #cgi.SCRIPT_NAME# contains "/TaxonomySearch.cfm"> class="active"</cfif>
							target="_top" ><span>Taxonomy Search</span></a>
						</li>
						<li>
							<a href="/transactions.cfm" 
							target="_top" 
							<cfif #cgi.SCRIPT_NAME# contains "transactions.cfm"> class="active"</cfif>
							><span>Transactions</span></a>
						</li>
						<li>
							<!--- this is in a frame, so cgi.script_name just detects _header.cfm---->
							<a href="/agents.cfm" 
							target="_top" 
							<cfif #cgi.SCRIPT_NAME# contains "/_header.cfm"> class="active"</cfif>
							><span>Agents</span></a>
						</li>
						<li>
							<a href="/Locality.cfm" 
							target="_top" 
							c<cfif #cgi.SCRIPT_NAME# contains "/Locality.cfm">  class="active"</cfif>
							><span>Locality</span></a>
						</li>
						<li>
							<a href="/tools/" target="_top" 
							<cfif #cgi.SCRIPT_NAME# contains "/tools/"> class="active"</cfif>
							><span>Tools</span></a>
						</li>
					</cfif>
						<li>
							<a href="/login.cfm" target="_top"
							<cfif #cgi.SCRIPT_NAME# contains "/login.cfm" OR #cgi.SCRIPT_NAME# contains "/myArctos.cfm"> class="active"</cfif>><span>Advanced Features</span></a>
						</li>
					</ul>
			</td>
		</tr>
	</table>
</div><!---- end laft-padding div ---->