
<cfinclude template="/includes/_header.cfm">
<style>
	ul.nothing {
		list-style-type:none;
		}
	a.whatThe{
		position:relative; /*this is the key*/
		z-index:1;
		color:blue;
		text-decoration:none;}
	
	a.whatThe:hover{z-index:20;
		background-color: transparent;
		}
	
	a.whatThe span{display: none}
	
	a.whatThe:hover span{ /*the span will display just on :hover state*/
		display:block;
		position:absolute;
		top:1px; left:100px;
		border:1px solid #0cf;
		background:white;
		color:blue;
		text-align: center;
		text-decoration:none;
		padding:3px;}
</style>
<cfoutput>
Use this form to browse Arctos taxonomy. All taxa are not represented by specimens. Click <img src="/images/this.gif" border="0">
to expand a taxon, <img src="/images/down.gif" border="0"> to collapse, and click the links to search Arctos.
<cfparam name="thisURL" default="browseTaxonomy.cfm?">
<cfparam name="selectedClass" default="">
<cfparam name="selectedOrder" default="">
<cfparam name="selectedSuborder" default="">
<cfparam name="selectedFamily" default="">
<cfparam name="selectedSubfamily" default="">
<cfparam name="selectedGenus" default="">
<cfparam name="selectedSpecies" default="">
<cfparam name="selectedSubspecies" default="">

<cfquery name="class" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(phylclass) phylclass from taxonomy
	order by phylclass
</cfquery>
<ul class="nothing">
<cfloop query="class">
	<cfif len(#phylclass#) gt 0>
		<cfset currentClass = #phylclass#>
	<cfelse>
		<cfset currentClass = "NOT RECORDED">
	</cfif>
	
	<cfif #selectedClass# is not "#currentClass#">
	<li>
	<a href="browseTaxonomy.cfm?selectedClass=#currentClass####currentClass#" name="#currentClass#">
		<img src="/images/this.gif" border="0" class="likeLink">
	</a> 
	<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentClass#" target="_blank">
	#currentClass#
	<span>Rank: Class
		<cfif #currentClass# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentClass#</font>
		</cfif>
	</span></a>
	
	</li>
	<cfelse>
	<li>
	<a href="browseTaxonomy.cfm###currentClass#" name="#currentClass#">
		<img src="/images/down.gif" border="0" class="likeLink">
	</a> 
	<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentClass#" target="_blank">
	#currentClass#
	<span>
		Rank: Class
		<cfif #currentClass# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentClass#</font>
		</cfif>
		</span></a>
	 </li>
		<!--- expand children ---->
			<cfquery name="order" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select distinct(phylorder) from taxonomy
				where 
				<cfif #currentClass# is "NOT RECORDED">
					phylclass is null
				<cfelse>
					phylclass = '#currentClass#'
				</cfif>				
				order by phylorder
			</cfquery>
			<ul class="nothing">
		<cfloop query="order">
			<cfif len(#phylorder#) gt 0>
				<cfset currentOrder = #phylorder#>
				<cfset srchOrder = "'#phylorder#'">
			<cfelse>
				<cfset currentOrder = "NOT RECORDED">
			</cfif>
			
				
				<cfif #selectedOrder# is not "#currentOrder#">
					<li>
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder####currentClass#" name="#currentOrder#">
					<img src="/images/this.gif" border="0" class="likeLink">
					</a>
					<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentOrder#" target="_blank">
	#currentOrder#
	<span>
		Rank: Order
		<cfif #currentOrder# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentOrder#</font>
		</cfif>
		</span></a>
		 
					</li>
				<cfelse>
					<li>
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass####currentClass#" name="#currentOrder#">
					<img src="/images/down.gif" border="0" class="likeLink">
					</a>
					<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentOrder#" target="_blank">
	#currentOrder#
	<span>
		Rank: Order
		<cfif #currentOrder# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentOrder#</font>
		</cfif>
		</span></a>
					</li>
						<cfquery name="suborder" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(suborder) from taxonomy
								where 
								<cfif #currentOrder# is "NOT RECORDED">
									phylorder is null
								<cfelse>
									phylorder = '#currentOrder#'
								</cfif>
								AND
								<cfif #currentClass# is "NOT RECORDED">
									phylclass is null
								<cfelse>
									phylclass = '#currentClass#'
								</cfif>
							order by suborder
						</cfquery>			
					<ul class="nothing">
					<cfloop query="suborder">
					<cfif len(#suborder#) gt 0>
						<cfset currentSuborder = #suborder#>
					<cfelse>
						<cfset currentSuborder = "NOT RECORDED">
					</cfif>
			
			<li>
						<cfif #selectedSuborder# is not "#currentSuborder#">
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder####currentOrder#" name="#currentSuborder#">
					<img src="/images/this.gif" border="0" class="likeLink">
					</a>
					<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentSuborder#" target="_blank">
	#currentSuborder#
	<span>
		Rank: Suborder
		<cfif #currentSuborder# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentSuborder#</font>
		</cfif>
		</span></a>
		
						</li>
						
				<cfelse>
				<li>
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder####currentOrder#" name="#currentSuborder#">
					<img src="/images/down.gif" border="0" class="likeLink">
					</a>
					<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentSuborder#" target="_blank">
	#currentSuborder#
	<span>
		Rank: Suborder
		<cfif #currentSuborder# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentSuborder#</font>
		</cfif>
		</span></a>
											</li>
						
						<cfquery name="family" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(family) from taxonomy
								where 
								<cfif #currentSuborder# is "NOT RECORDED">
									suborder is null 
								<cfelse>
									suborder = '#currentSuborder#'
								</cfif>
								AND
								<cfif #currentClass# is "NOT RECORDED">
									phylclass is null
								<cfelse>
									phylclass = '#currentClass#'
								</cfif>
								AND
								<cfif #currentOrder# is "NOT RECORDED">
									phylorder is null
								<cfelse>
									phylorder = '#currentOrder#'
								</cfif>
							order by family
						</cfquery>
						<ul class="nothing">
					<cfloop query="family">
								<cfif len(#family#) gt 0>
									<cfset currentFamily = #family#>
								<cfelse>
									<cfset currentFamily = "NOT RECORDED">
								</cfif>
								
								
								<cfif #selectedFamily# is not "#currentFamily#">
					<li>
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily####currentSuborder#" name="#currentFamily#"><img src="/images/this.gif" border="0" class="likeLink"></a>
								<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentFamily#" target="_blank">
	#currentFamily#
	<span>
		Rank: Family
		<cfif #currentFamily# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentFamily#</font>
		</cfif>
		</span></a>
		
								
					
					</li>
						
				<cfelse>
				<li>
					<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder####currentSuborder#" name="#currentFamily#"><img src="/images/down.gif" border="0" class="likeLink"></a><a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentFamily#" target="_blank">
	#currentFamily#
	<span>
		Rank: Family
		<cfif #currentFamily# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentFamily#</font>
		</cfif>
		</span></a>
								</li>
						
						<cfquery name="subfamily" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select distinct(subfamily) from taxonomy
								where 
								<cfif #currentFamily# is "NOT RECORDED">
									family is null
								<cfelse>
									family = '#currentFamily#'
								</cfif>
								AND
								<cfif #currentSuborder# is "NOT RECORDED">
									suborder is null
								<cfelse>
									suborder = '#currentSuborder#'
								</cfif>
								AND
								<cfif #currentClass# is "NOT RECORDED">
									phylclass is null
								<cfelse>
									phylclass = '#currentClass#'
								</cfif>
								AND
								<cfif #currentOrder# is "NOT RECORDED">
									phylorder is null
								<cfelse>
									phylorder = '#currentOrder#'
								</cfif>
							order by subfamily
						</cfquery>
						<ul class="nothing">
					<cfloop query="subfamily">
										<cfif len(#subfamily#) gt 0>
											<cfset currentSubfamily = #subfamily#>
										<cfelse>
											<cfset currentSubfamily = "NOT RECORDED">
										</cfif>
										
										<cfif #selectedSubfamily# is not "#currentSubfamily#">
										<li>
										<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily#&selectedSubfamily=#currentSubfamily####currentFamily#" name="#currentSubfamily#"><img src="/images/this.gif" border="0" class="likeLink"></a>
										<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentSubfamily#" target="_blank">
	#currentSubfamily#
	<span>
		Rank: Subfamily
		<cfif #currentSubfamily# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentSubfamily#</font>
		</cfif>
		</span></a>
		</li>
										<cfelse>
				<li>
				<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily####currentFamily#"  name="#currentSubfamily#"><img src="/images/down.gif" border="0" class="likeLink"></a>
										<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentSubfamily#" target="_blank">
	#currentSubfamily#
	<span>
		Rank: Subfamily
		<cfif #currentSubfamily# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentSubfamily#</font>
		</cfif>
		</span></a></li>
										
										
											<cfquery name="genus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
												SELECT distinct(genus) FROM taxonomy WHERE
												<cfif #currentSubfamily# is "NOT RECORDED">
													subfamily is null
												<cfelse>
													subfamily = '#currentSubfamily#'
												</cfif>
												AND
												<cfif #currentFamily# is "NOT RECORDED">
													family is null
												<cfelse>
													family = '#currentFamily#'
												</cfif>
												AND
												<cfif #currentSuborder# is "NOT RECORDED">
													suborder is null
												<cfelse>
													suborder = '#currentSuborder#'
												</cfif>
												AND
												<cfif #currentClass# is "NOT RECORDED">
													phylclass is null
												<cfelse>
													phylclass = '#currentClass#'
												</cfif>
												AND
												<cfif #currentOrder# is "NOT RECORDED">
													phylorder is null
												<cfelse>
													phylorder = '#currentOrder#'
												</cfif>
												ORDER BY genus
											</cfquery>
											<ul class="nothing">
											<cfloop query="genus">
												<cfif len(#genus#) gt 0>
													<cfset currentGenus = #genus#>
												<cfelse>
													<cfset currentGenus = "NOT RECORDED">
												</cfif>
												
												<cfif #selectedGenus# is not "#currentGenus#">
										<li>
										<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily#&selectedSubfamily=#currentSubfamily#&selectedGenus=#currentGenus####currentSubfamily#" name="#currentGenus#"><img src="/images/this.gif" border="0" class="likeLink"></a>
										<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentGenus#" target="_blank">
	#currentGenus#
	<span>
		Rank: Genus
		<cfif #currentGenus# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentGenus#</font>
		</cfif>
		</span></a>
		
										</li>
										<cfelse>
				<li><a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily#&selectedSubfamily=#currentSubfamily####currentSubfamily#" name="#currentGenus#"><img src="/images/down.gif" border="0" class="likeLink"></a>
				<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentGenus#" target="_blank">
	#currentGenus#
	<span>
		Rank: Genus
		<cfif #currentGenus# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for #currentGenus#</font>
		</cfif>
		</span></a></li>
				
										
													<cfquery name="species" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
														SELECT distinct(species) FROM taxonomy WHERE
														<cfif #currentGenus# is "NOT RECORDED">
															genus is null
														<cfelse>
															genus = '#currentGenus#'
														</cfif>
														AND
														<cfif #currentSubfamily# is "NOT RECORDED">
															subfamily is null
														<cfelse>
															subfamily = '#currentSubfamily#'
														</cfif>
														AND
														<cfif #currentFamily# is "NOT RECORDED">
															family is null
														<cfelse>
															family = '#currentFamily#'
														</cfif>
														AND
														<cfif #currentSuborder# is "NOT RECORDED">
															suborder is null
														<cfelse>
															suborder = '#currentSuborder#'
														</cfif>
														AND
														<cfif #currentClass# is "NOT RECORDED">
															phylclass is null
														<cfelse>
															phylclass = '#currentClass#'
														</cfif>
														AND
														<cfif #currentOrder# is "NOT RECORDED">
															phylorder is null
														<cfelse>
															phylorder = '#currentOrder#'
														</cfif>
														ORDER BY species
													</cfquery>
													<ul class="nothing">
													<cfloop query="species">
														<cfif len(#species#) gt 0>
															<cfset currentSpecies = #species#>
														<cfelse>
															<cfset currentSpecies = "NOT RECORDED">
														</cfif>
														
														<cfif #selectedSpecies# is not "#currentSpecies#">
										<li>
										<a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily#&selectedSubfamily=#currentSubfamily#&selectedGenus=#currentGenus#&selectedSpecies=#currentSpecies####currentGenus#" name="#currentSpecies#">
										<img src="/images/this.gif" border="0" class="likeLink">
										</a>
														<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentGenus# #currentSpecies#" target="_blank">
	#currentSpecies#
	<span>
		Rank: Specific epithet
		<cfif #currentSpecies# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for <i>#currentGenus# #currentSpecies#</i></font>
		</cfif>
		</span></a>
		
		</li>
														
														
										<cfelse>
										<li><a href="browseTaxonomy.cfm?selectedClass=#currentClass#&selectedOrder=#currentOrder#&selectedSuborder=#currentSuborder#&selectedFamily=#currentFamily#&selectedSubfamily=#currentSubfamily#&selectedGenus=#currentGenus####currentGenus#" name="#currentSpecies#">
										<img src="/images/down.gif" border="0" class="likeLink">
										</a>
														<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentGenus# #currentSpecies#" target="_blank">
	#currentSpecies#
	<span>
		Rank: Specific epithet
		<cfif #currentSpecies# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for <i>#currentGenus# #currentSpecies#</i></font>
		</cfif>
		</span></a>
		</li>
														
															<cfquery name="subspecies" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
																SELECT distinct(subspecies) FROM taxonomy WHERE
																<cfif #currentSpecies# is "NOT RECORDED">
																	species is null
																<cfelse>
																	species = '#currentSpecies#'
																</cfif>
																AND
																<cfif #currentGenus# is "NOT RECORDED">
																	genus is null
																<cfelse>
																	genus = '#currentGenus#'
																</cfif>
																AND
																<cfif #currentSubfamily# is "NOT RECORDED">
																	subfamily is null
																<cfelse>
																	subfamily = '#currentSubfamily#'
																</cfif>
																AND
																<cfif #currentFamily# is "NOT RECORDED">
																	family is null
																<cfelse>
																	family = '#currentFamily#'
																</cfif>
																AND
																<cfif #currentSuborder# is "NOT RECORDED">
																	suborder is null
																<cfelse>
																	suborder = '#currentSuborder#'
																</cfif>
																AND
																<cfif #currentClass# is "NOT RECORDED">
																	phylclass is null
																<cfelse>
																	phylclass = '#currentClass#'
																</cfif>
																AND
																<cfif #currentOrder# is "NOT RECORDED">
																	phylorder is null
																<cfelse>
																	phylorder = '#currentOrder#'
																</cfif>
																ORDER BY subspecies
															</cfquery>
															<ul class="nothing">
															<cfloop query="subspecies">
																<cfif len(#subspecies#) gt 0>
																		<cfset currentsubspecies = #subspecies#>
																	<cfelse>
																		<cfset currentsubspecies = "NOT RECORDED">
																	</cfif>
																	<li>
																	<img src="/images/this.gif" border="0">
																	
																	<a class="whatThe" href="/SpecimenResults.cfm?HighTaxa=#currentGenus# #currentSpecies# #currentsubspecies#" target="_blank">
	#currentsubspecies#
	<span>
		Rank: Subspecific epithet
		<cfif #currentsubspecies# is not "NOT RECORDED">
			<br><font size="-2">Click to search Arctos for <i>#currentGenus# #currentSpecies# #currentsubspecies#</i></font>
		</cfif>
		</span></a>
																	</li>
															</cfloop>
															</ul>
														</cfif>
													</cfloop>
													</ul>
												</cfif>
											</cfloop>
											</ul>
										</cfif>
									</cfloop>
									</ul>
								</cfif>
							</cfloop>
							</ul>
						</cfif>
					</cfloop>
					</ul>
				</cfif>
			</cfloop>
			</ul>
	</cfif>
</cfloop>
</ul>
</cfoutput>