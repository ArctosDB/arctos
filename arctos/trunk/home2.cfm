<cfset title="Arctos Home">
<cfset metaDesc="Frequently-asked questions (FAQ), Arctos description, participation guidelines, usage policies, suggestions, and requirements for using Arctos or participating in the Arctos community.">
<cfinclude template="/includes/_header.cfm">
<style>
	.collnTitle {
		font-weight:bold;
	}
	.collnDescr {
		font-style:italic;
	}
	.collnData {
		margin-left:2em;
	}
	.institution {
		font-size:large;
		font-weight:bold;
	}
	ul {list-style:none;}
	#menu {
		position:fixed;
		top:20%;
		left:0; 
		width:3.5em;
		border:1px solid green;
		padding:1em;
		margin:1em;
	}
	#body {
		margin-left:8em;
	}
</style>
<cfoutput>
	<cfquery  name="coll" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			cf_collection.cf_collection_id,
			decode(cf_collection.collection_id,
				null,cf_collection.collection || ' Portal',
				cf_collection.collection || ' Collection') collection,
			collection.collection_id,
			descr,
			web_link,
			web_link_text,
			loan_policy_url,
			portal_name,
			count(cat_num) as cnt
		from 
			cf_collection,
			collection,
			cataloged_item
		where 
			cf_collection.collection_id=collection.collection_id (+) and
			collection.collection_id=cataloged_item.collection_id (+) and
			PUBLIC_PORTAL_FG = 1 
		group by
			cf_collection.cf_collection_id,
			cf_collection.collection,
			collection.collection_id,
			descr,
			web_link,
			web_link_text,
			loan_policy_url,
			portal_name,
			decode(cf_collection.collection_id,
				null,cf_collection.collection || ' Portal',
				cf_collection.collection || ' Collection')
		order by cf_collection.collection
	</cfquery>
	<!--- hard-code some collections in for special treatment, but leave a default "the rest" query too --->
	<cfquery name="uam" dbtype="query">
		select * from coll where collection like 'UAM %' order by collection
	</cfquery>
	<cfset gotem=''>
	<cfset gotem=listappend(gotem,valuelist(uam.cf_collection_id))>
	<cfquery name="msb" dbtype="query">
		select * from coll where collection like 'MSB %' order by collection
	</cfquery>
	<cfset gotem=listappend(gotem,valuelist(msb.cf_collection_id))>
	<cfquery name="mvz" dbtype="query">
		select * from coll where collection like 'MVZ %' order by collection
	</cfquery>
	<cfset gotem=listappend(gotem,valuelist(mvz.cf_collection_id))>
	<cfquery name="mvz_all" dbtype="query">
		select * from coll where collection like 'MVZ %' order by collection
	</cfquery>
	<cfset gotem=listappend(gotem,valuelist(mvz_all.cf_collection_id))>
	<cfquery name="wnmu" dbtype="query">
		select * from coll where collection like 'WNMU %' order by collection
	</cfquery>
	<cfset gotem=listappend(gotem,valuelist(wnmu.cf_collection_id))>
	<cfquery name="dmns" dbtype="query">
		select * from coll where collection like 'DMNS %' order by collection
	</cfquery>
	<cfset gotem=listappend(gotem,valuelist(dmns.cf_collection_id))>
	<cfset gotem=replace(gotem,',,',',','all')>
	<cfquery name="rem" dbtype="query">
		select * from coll where cf_collection_id not in (#gotem#)
	</cfquery>
	<cfquery name="summary" dbtype="query">
		select 
			sum(cnt) total_specimens,
			count(collection) numCollections
		 from coll
	</cfquery>
	<cfdump var=#summary#>
	<div id="menu">
		<a href="##top">top</a>
		<br><a href="##uam">UAM</a>
		<br><a href="##msb">MSB</a>
		<br><a href="##mvz">MVZ</a>
		<br><a href="##dmns">DMNS</a>
		<br><a href="##wnmu">WNMU</a>
		<br><a href="##rem">other</a>
	</div>
	<div id="body">
	<a name="top"></a>
	Arctos is an ongoing effort to integrate access to specimen data, collection-management tools, and external resources on the internet. 
	Read more about Arctos at our <a href="https://arctosdb.wordpress.com/">Documentation Site</a>, explore some <a href="/random.cfm">random content</a>, 
	or use the links in the header to search for specimens, media, taxonomy, projects and publications, and more. Sign in or create an account to save 
	preferences and searches.
	<p>
		Following the search links below will set your preferences to filter by a specific collection or portal. You may click 
		<a href="/all_all">[ search all collections ]</a> at any time to re-set your preferences. 
	</p>
	<ul>
		<cfif isdefined("uam") and uam.recordcount gt 0>
			<a name="uam"></a>
			<li><a href="http://www.uaf.edu/museum/" target="_blank" class="external institution">University of Alaska Museum</a>
				<ul>
					<cfloop query="uam">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("msb") and msb.recordcount gt 0>
			<a name="msb"></a>
			<li><a href="http://www.msb.unm.edu/" target="_blank" class="external institution">Museum of Southwestern Biology</a>
				<ul>
					<cfloop query="msb">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("mvz") and mvz.recordcount gt 0>
			<a name="mvz"></a>
			<li><a href="http://mvz.berkeley.edu/" target="_blank" class="external institution">Museum of Vertebrate Zoology</a>
				<ul>
					<cfloop query="mvz">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("dmns") and dmns.recordcount gt 0>
			<a name="dmns"></a>
			<li><a href="http://www.dmns.org/" target="_blank" class="external institution">Denver Museum of Nature & Science</a>
				<ul>
					<cfloop query="dmns">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("wnmu") and wnmu.recordcount gt 0>
			<a name="wnmu"></a>
			<li><a href="http://www.wnmu.edu/univ/museum.htm" target="_blank" class="external institution">Western New Mexico University</a>
				<ul>
					<cfloop query="wnmu">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("rem") and rem.recordcount gt 0>
			<a name="rem"></a>
			<li><div class="institution">Other Collections</div>
				<ul>
					<cfloop query="rem">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						<li>
							<div class="collnTitle">
								#collection#
							</div>
							<div class="collnData">
								<cfif len(descr) gt 0>
									<div class="collnDescr">
										#descr#
									</div>
								</cfif>
								<cfif listlast(collection,' ') is not 'Portal'>
									<a href="/#coll_dir_name#" target="_top">[ Search #cnt# Specimens ]</a>
								<cfelse>
									<a href="/#coll_dir_name#" target="_top">[ Search Specimens ]</a>
								</cfif>
								<cfif len(web_link) gt 0>
									<br><a href="#web_link#"  class="external" target="_blank">[ Collection Home Page ]</a>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<br><a href="#loan_policy_url#" class="external" target="_blank">[ Collection Loan Policy ]</a>
								</cfif>
							</div>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
	</ul>
	</div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">