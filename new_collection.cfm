<cfinclude template="/includes/_header.cfm">
<cfset title="New Collection Portal">
<style>
	.infoDiv{
		border:2px solid green;
		font-size:smaller;
		padding:.5em;
		margin:1em;
		background-color:#e3ede5;
	}
</style>
<!----

	drop table pre_new_institution;

	create table pre_new_institution (
		niid number  NOT NULL,
		INSTITUTION VARCHAR2(255),
		INSTITUTION_ACRONYM VARCHAR2(20),
		ttl_spc_cnt VARCHAR2(4000),
		are_all_digitized VARCHAR2(4000),
		specimen_types  VARCHAR2(4000),
		yearly_add_avg  VARCHAR2(4000),
		exp_grth_rate VARCHAR2(4000),
		current_software VARCHAR2(4000),
		current_structure VARCHAR2(4000),
		vocab_control  VARCHAR2(4000),
		free_text VARCHAR2(4000),
		vocab_enforcement  VARCHAR2(4000),
		vocab_text VARCHAR2(4000),
		tissues VARCHAR2(4000),
		tissue_detail VARCHAR2(4000),
		barcodes VARCHAR2(4000),
		barcode_desc VARCHAR2(4000),
		locality VARCHAR2(4000),
		georefedpercent VARCHAR2(4000),
		metadata VARCHAR2(4000),
		digital_trans VARCHAR2(4000),
		trans_desc VARCHAR2(4000),
		more_data VARCHAR2(4000),
		digital_media VARCHAR2(4000),
		media_plan VARCHAR2(4000),
		want_storage VARCHAR2(4000),
		has_help VARCHAR2(4000),
		security_concern VARCHAR2(4000),
		budget VARCHAR2(4000),
		comments VARCHAR2(4000),
		completed_by VARCHAR2(4000),
		completed_by_email VARCHAR2(4000),
		completed_by_phone VARCHAR2(4000),
		completed_by_title VARCHAR2(4000),
		status varchar2(255),
		insert_date date,
		CONSTRAINT PK_pre_new_inst PRIMARY KEY (niid) USING INDEX TABLESPACE UAM_IDX_1
	) TABLESPACE UAM_DAT_1;

	alter table pre_new_institution  add initiated_by_username VARCHAR2(255);

	create or replace public synonym pre_new_institution for pre_new_institution;
	grant select, insert, update on pre_new_institution to public;

	create unique index ix_u_pni_instacr_u on pre_new_institution(upper(INSTITUTION_ACRONYM)) tablespace uam_idx_1;


	drop table pre_new_collection;

	create table pre_new_collection (
		ncid number not null,
		niid number not null,
		COLLECTION_CDE varchar2(5),
		DESCR VARCHAR2(4000),
		COLLECTION VARCHAR2(50),
		WEB_LINK  VARCHAR2(4000),
		WEB_LINK_TEXT  VARCHAR2(50),
		LOAN_POLICY_URL VARCHAR2(255),
		GUID_PREFIX VARCHAR2(20),
		PREFERRED_TAXONOMY_SOURCE VARCHAR2(255),
		CATALOG_NUMBER_FORMAT  VARCHAR2(21),
		mentor varchar2(4000),
		mentor_contact varchar2(4000),
		admin_username VARCHAR2(255),
		status varchar2(255),
		use_license_id number,
		final_message VARCHAR2(4000),
		contact_email VARCHAR2(4000),
		initiated_by_username VARCHAR2(255),
		insert_date date,
		CONSTRAINT PK_pre_new_coln PRIMARY KEY (ncid) USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_p_n_c FOREIGN KEY (niid)	REFERENCES pre_new_institution (niid)
	) TABLESPACE UAM_DAT_1;


	create or replace public synonym pre_new_collection for pre_new_collection;

	grant select, insert, update on pre_new_collection to public;

	drop index ix_u_pnc_GUID_PREFIX;

	create unique index ix_u_pnc_GUID_PREFIX_u on pre_new_collection(upper(GUID_PREFIX)) tablespace uam_idx_1;



	<cfquery name="CTMEDIA_LICENSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select MEDIA_LICENSE_ID,DISPLAY from CTMEDIA_LICENSE order by DISPLAY
	</cfquery>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source group by source order by source
	</cfquery>
	<cfquery name="ctcollection_cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_cde from ctcollection_cde  order by collection_cde
	</cfquery>


	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from pre_new_institution where institution_acronym='#institution_acronym#' and
		<cfif isdefined('user_pwd') and len('user_pwd') gt 0>
			user_pwd='#escapeQuotes(user_pwd)#'
		<cfelseif isdefined('pwhash') and len('pwhash') gt 0>
			dbms_obfuscation_toolkit.md5(input => UTL_RAW.cast_to_raw(user_pwd)) ='#pwhash#'
		<cfelse>
			1=2
		</cfif>
	</cfquery>
	<cfif d.recordcount is not 1>
		Failure<cfabort>
	</cfif>
	<p>
			<ul>
				<li>Request Date: #dateformat(d.insert_date,'yyyy-mm-dd')#</li>
				<li>Initiated By: #d.initiated_by_username#</li>
				<li>Status: #d.status#</li>
				<li>Password: #d.user_pwd#</li>
				<li>
					Sharable link to this form. CAUTION: This provides edit access to anyone with an Arcto account.
					<br>
					<code>
						#application.serverRootURL#/new_collection.cfm?action=manage&pwhash=#hash(d.user_pwd)#&institution_acronym=#d.institution_acronym#
					</code>
				</li>
				<cfif not isdefined("session.roles") or session.roles does not contain "global_admin">
					<cfif d.status is not "new">
						<div class="importantNotification">
							You may not edit this request. Contact your Mentor if you need to make revisions.
						</div>
					</cfif>
				</cfif>
			</ul>
		</p>

---->
<cfif action is "default">
	denied<cfabort>
</cfif>
<cfif len(session.username) is 0>
	You must log in to use this form.
	<cfabort>
</cfif>
<cfif action is "createInstitutionRequest">
	<cfoutput>
   		<cfquery name="srs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select someRandomSequence.nextval nid from dual
		</cfquery>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into pre_new_institution (
				niid,
				INSTITUTION,
				INSTITUTION_ACRONYM,
				ttl_spc_cnt,
				are_all_digitized,
				specimen_types,
				yearly_add_avg,
				exp_grth_rate,
				current_software,
				current_structure,
				vocab_control,
				free_text,
				vocab_enforcement,
				vocab_text,
				tissues,
				tissue_detail,
				barcodes,
				barcode_desc,
				locality,
				georefedpercent,
				metadata,
				digital_trans,
				trans_desc,
				more_data,
				digital_media,
				media_plan,
				want_storage,
				has_help,
				security_concern,
				budget,
				comments,
				completed_by,
				completed_by_email,
				completed_by_phone,
				completed_by_title,
				status,
				insert_date
			) values (
				#srs.nid#,
				'#escapeQuotes(INSTITUTION)#',
				'#escapeQuotes(INSTITUTION_ACRONYM)#',
				'#escapeQuotes(ttl_spc_cnt)#',
				'#escapeQuotes(are_all_digitized)#',
				'#escapeQuotes(specimen_types)#',
				'#escapeQuotes(yearly_add_avg)#',
				'#escapeQuotes(exp_grth_rate)#',
				'#escapeQuotes(current_software)#',
				'#escapeQuotes(current_structure)#',
				'#escapeQuotes(vocab_control)#',
				<cfif isdefined("free_text") and len(free_text) gt 0>
					'#escapeQuotes(free_text)#',
				<cfelse>
					'none',
				</cfif>
				'#escapeQuotes(vocab_enforcement)#',
				'#escapeQuotes(vocab_text)#',
				'#escapeQuotes(tissues)#',
				'#escapeQuotes(tissue_detail)#',
				'#escapeQuotes(barcodes)#',
				'#escapeQuotes(barcode_desc)#',
				'#escapeQuotes(locality)#',
				'#escapeQuotes(georefedpercent)#',
				'#escapeQuotes(metadata)#',
				<cfif isdefined("digital_trans") and len(digital_trans) gt 0>
					'#escapeQuotes(digital_trans)#',
				<cfelse>
					'none',
				</cfif>
				'#escapeQuotes(trans_desc)#',
				'#escapeQuotes(more_data)#',
				'#escapeQuotes(digital_media)#',
				'#escapeQuotes(media_plan)#',
				'#escapeQuotes(want_storage)#',
				'#escapeQuotes(has_help)#',
				'#escapeQuotes(security_concern)#',
				'#escapeQuotes(budget)#',
				'#escapeQuotes(comments)#',
				'#escapeQuotes(completed_by)#',
				'#escapeQuotes(completed_by_email)#',
				'#escapeQuotes(completed_by_phone)#',
				'#escapeQuotes(completed_by_title)#',
				'new',
				sysdate
			)
		</cfquery>
		<p>
			Success!
		</p>
		<p>
			A request has been created and the Arctos community will be alerted to this request.
		</p>
		The link to review your submission is:


		<code>
			#application.serverRootURL#/new_collection.cfm?action=manage_institution&&iid=#hash(srs.nid)#
		</code>

		<p>
			You may view your submission by <a href="/new_collection.cfm?action=manage_institution&iid=#hash(srs.nid)#">clicking this link</a>
		</p>
		<p>
			Please use the contact link at the bottom of any Arctos page if you wish to revise the submission, or if you have not
			been contacted within 10 working days. Please include the link above in any correspondence.
		</p>

	</cfoutput>

</cfif>










<cfif action is "nothing">
	<script>
		jQuery(document).ready(function() {

			$(':input[required]:visible').each(function(e){
			    $(this).addClass('reqdClr');
			});



		});

	</script>
	<h2>New Collection Request</h2>
	<p>
		Use this form to initiate a request to join Arctos. Please fill out this form as accurately and completely as possible.
		This form is intended to provide general information about collection(s) that you are interested in migrating to Arctos.
		Once we receive this information, we will follow-up with additional discussion or questions as needed.
	</p>
	<p>
		This information should cover your entire institution or organization. Follow-up questions will include information
		about specific collections.
	</p>
	<p>
		Useful Links:
		<ul>
			<li><a target="_blank" class="external" href="https://arctosdb.org/faq/">Arctos FAQ </a></li>
			<li>
				<a target="_blank" class="external" href="https://www.tacc.utexas.edu/">TACC</a>
				handles all of our data storage and security on their
				<a target="_blank" class="external" href="https://www.tacc.utexas.edu/systems/corral">Corral</a> system.
			</li>
			<li><a target="_blank" class="external" href="https://arctosdb.org/join-arctos/costs/">current pricing structure</a></li>
			<li><a target="_blank" class="external" href="https://arctosdb.org/learn/webinars/">webinars</a></li>
			<li><a target="_blank" class="external" href="http://handbook.arctosdb.org">Arctos Handbook</a></li>
			<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Manage-a-Collection-in-Arctos.html">How-To: Manage Collection</a></li>
		</ul>
	</p>
	<cfoutput>
		<form name="f" id="f" action="new_collection.cfm" method="post">
			<input type="hidden" name="action" value="createInstitutionRequest">
			<h3>Institution Information</h3>
			<div class="infoDiv">
				Institution Acronym is a short, standardized identifier for your institution. Maximum length is 20 characters.
				<p>
					Examples:
					<ul>
						<li>UAM</li>
						<li>MSB</li>
						<li>MVZ</li>
					</ul>
				</p>
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##institution-acronym">Documentation</a></li>
				</ul>
				<label for="INSTITUTION_ACRONYM">Institution Acronym</label>
				<input type="text" name="INSTITUTION_ACRONYM" id="INSTITUTION_ACRONYM" class="reqdClr" required >
			</div>


			<div class="infoDiv">
				Institution is a standardized expansion of Institution Acronym, and should end with Institution Acronym is parentheses.
				 It should be the same for all collections in
				an institution. Examples:
				<ul>
					<li>Chicago Academy of Sciences (CHAS)</li>
					<li>Museum of Southwestern Biology (MSB)</li>
				</ul>

				<label for="INSTITUTION">Institution</label>
				<input type="text" name="INSTITUTION" id="INSTITUTION" class="reqdClr" required  size="80">
			</div>

			<div class="infoDiv">
				<label for="ttl_spc_cnt">How many total specimens across all collection(s) are you interested in migrating to Arctos?</label>
				<input type="text" name="ttl_spc_cnt" id="ttl_spc_cnt" class="reqdClr" required  size="80">
			</div>
			<div class="infoDiv">
				<label for="are_all_digitized">Are the data for all of those specimens in digital format?</label>
				<select name="are_all_digitized" required>
					<option value=""></option>
					<option value="yes">yes</option>
					<option value="no">no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="specimen_types">Which of the following specimen types are you interested in migrating to Arctos (check all that apply)?</label>
				<cfset l= "Amphibians Reptiles Fishes Birds Mammals Insects Invertebrates Parasites Tissues Herbarium Earth Sciences Art History Ethnology Archaeology Other">
				<cfloop list="#l#" delimiters=" " index="i">
					<input type="checkbox" name="specimen_types" value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="yearly_add_avg">On average, how many specimens have been added to the collection(s) annually over the past 5 years?</label>
				<input type="text" name="yearly_add_avg" id="yearly_add_avg" class="reqdClr" required size="80">
			</div>
			<div class="infoDiv">
				<label for="exp_grth_rate">How do you expect this rate of growth to change in the foreseeable future?</label>
				<select name="exp_grth_rate" required>
					<option value=""></option>
					<option value="Increase" >Increase</option>
					<option value="Remain the same" >Remain the same</option>
					<option value="Decrease" >Decrease</option>
					<option value="Not sure" >Not sure</option>
				</select>
			</div>

			<h3>Data Structure</h3>
			<p>
				The following questions are intended to provide basic information about how your data are managed currently.
				Controlled vocabularies are text strings in a pick list. Authority files contain controlled information with
				metadata and some complexity (e.g., relationships such as synonymies); they are often stored in at least one table with
				more than one column.
			</p>



			<div class="infoDiv">
				<label for="current_software">What software do you currently use to manage specimen data (e.g., e.g., Access, Filemaker Pro, Excel, Specify-indicate which version, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="current_software" id="current_software" required ></textarea>
			</div>


			<div class="infoDiv">
				<label for="current_software">How are your data structured in your current information system (flat table, related tables, disjoined tables, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="current_structure" id="current_structure" required ></textarea>
			</div>



			<div class="infoDiv">
				<label for="vocab_control">Do you use controlled vocabularies or authority files for the following kinds of data (check all that apply)?</label>
				<cfset l= "Agents,Taxonomy,Geography,Specimen Parts">
				<cfloop list="#l#" delimiters="," index="i">
					<input type="checkbox" name="vocab_control" value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="free_text">Do you allow free text data entry for the following kinds of data (check all that apply)?</label>
				<cfset l= "Agents,Taxonomy,Geography,Specimen Parts">
				<cfloop list="#l#" delimiters="," index="i">
					<input type="checkbox" name="free_text" value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="vocab_enforcement">Is it possible to bypass the controlled vocabularies or authority files? Explain.</label>
				<textarea class="hugetextarea reqdClr" name="vocab_enforcement" id="vocab_enforcement" required ></textarea>
			</div>


			<div class="infoDiv">
				<label for="vocab_text">Please expand on how you deal with agents, taxonomy, geography, and/or specimen parts.</label>
				<textarea class="hugetextarea reqdClr" name="vocab_text" id="vocab_text" required ></textarea>
			</div>


			<div class="infoDiv">
				<label for="tissues">Do you allow free text data entry for the following kinds of data (check all that apply)?</label>
				<cfset l= "	Tissues are treated as parts of a specimen using a controlled vocabulary or authority file.|Tissues are treated as parts of a specimen, entered in free-form text.|Tissues are cataloged in a separate collection, and cross-linked to voucher specimen.|Tissues are entered as free-form text in a remarks or comment field.|There are no tissues in our collection.|Other.">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="tissues" value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="tissue_detail">Describe any other details about how you deal with tissues currently, or plan to deal with them in the future.</label>
				<textarea class="hugetextarea reqdClr" name="tissue_detail" id="tissue_detail" required ></textarea>
			</div>


			<div class="infoDiv">
				<label for="barcodes">Do you use machine-readable labels (such as barcodes) to digitally track any objects in your collections?</label>
				<select name="barcodes" required>
					<option value=""></option>
					<option value="yes"  >yes</option>
					<option value="no" >no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="barcode_desc">Describe any details about you incorporate barcodes into your current system, or whether you plan to deal with them in the future.</label>
				<textarea class="hugetextarea reqdClr" name="barcode_desc" id="barcode_desc" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="locality">Describe how you deal with locality information (including coordinates, if any) in your current collection management system.</label>
				<textarea class="hugetextarea reqdClr" name="locality" id="locality" required ></textarea>
			</div>
			<div class="infoDiv">
				<label for="georefedpercent">Approximately what proportion of your locality data are georeferenced with latitude/longitude coordinates? * </label>
				<input type="text" name="georefedpercent" id="georefedpercent" class="reqdClr" required  size="80">
			</div>
			<div class="infoDiv">
				<label for="metadata">Describe the kinds of metadata that you store with your coordinate information (e.g., datum, GPS error, extent, maximum uncertainty, georeferencing method, etc.)</label>
				<textarea class="hugetextarea reqdClr" name="metadata" id="metadata" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="tissues">For the following transaction types, indicate whether you have digital information that would need to be formatted and imported? (check all that apply)</label>
				<cfset l= "Loans|Accessions|Permits">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="digital_trans" value="#i#">#i#<br>
				</cfloop>
   			</div>


			<div class="infoDiv">
				<label for="metadata">Describe generally how you deal with transactions (loans, accessions, permits) in your current system.</label>
				<textarea class="hugetextarea reqdClr" name="trans_desc" id="trans_desc" required ></textarea>
			</div>
			<div class="infoDiv">
				<label for="more_data">Other than basic “label data” (who/what/when/where), what other kinds of information (if any) is recorded about your specimens (e.g., citations in publications, GenBank numbers, projects, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="more_data" id="more_data" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="digital_media"> Do you have digital media in your current system? </label>
				<select name="digital_media" required>
					<option value=""></option>
					<option value="yes"  >yes</option>
					<option value="no">no</option>
				</select>
			</div>


			<div class="infoDiv">
				<label for="media_plan">Indicate how you plan to store digital media that are linked to data in Arctos.</label>
				<cfset l= "We need storage for digital media through Arctos.|We have our own web-accessible storage for digital media.|Our digital media are stored and accessible via an external web service.|We do not plan to have digital media in Arctos at this time.">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="media_plan" value="#i#">#i#<br>
				</cfloop>
   			</div>

			<h3>Putting your data in Arctos</h3>



			<div class="infoDiv">
				<label for="has_help">Do you have someone familiar with the collection who can assist in migrating data to Arctos?</label>
				<select name="has_help" required>
					<option value=""></option>
					<option value="yes" >yes</option>
					<option value="no">no</option>
				</select>
			</div>


			<div class="infoDiv">
				<label for="want_storage"> Do you have digital media in your current system? </label>
				<select name="want_storage" required>
					<option value=""></option>
					<option value="yes" >yes</option>
					<option value="no">no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="security_concern">Please describe any permission or security issues that would prevent us from accessing your data directly if necessary for data migration?</label>
				<textarea class="hugetextarea reqdClr" name="security_concern" id="security_concern" required ></textarea>
			</div>



			<div class="infoDiv">
				<label for="budget">Do you have an annual budget available for database support?</label>
				<select name="budget" required>
					<option value=""></option>
					<option value="yes"  >yes</option>
					<option value="no" >no</option>
				</select>
			</div>



			<div class="infoDiv">
				<label for="comments">Please add any other comments or questions that you have re: Arctos or your collection(s).</label>
				<textarea class="hugetextarea reqdClr" name="comments" id="comments" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="completed_by">Questionnaire completed by</label>
				<input type="text" name="completed_by" id="completed_by" class="reqdClr" required >
			</div>


			<div class="infoDiv">
				<label for="completed_by_title">Job Title</label>
				<input type="text" name="completed_by_title" id="completed_by_title" class="reqdClr" required >
			</div>


			<div class="infoDiv">
				<label for="completed_by_email">Email</label>
				<input type="email" name="completed_by_email" id="completed_by_email" class="reqdClr" required>
			</div>

			<div class="infoDiv">
				<label for="completed_by_phone">Phone</label>
				<input type="tel" name="completed_by_phone" id="completed_by_phone" class="reqdClr" required >
			</div>

			<!----















			<div class="infoDiv">
				Collection is displayed as a child of institution in the Collection search box on SpecimenSearch.
				It should be the same for all collections of similar type across institutions. Examples:

				<ul>
					<li>Amphibian and reptile specimens</li>
					<li>Insect specimens</li>
					<li>Mammal observations</li>
				</ul>



				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##collection">Documentation</a></li>
				</ul>

				<label for="COLLECTION">Collection</label>
				<input type="text" name="COLLECTION" id="COLLECTION" class="reqdClr" required value="#d.COLLECTION#" size="80">
			</div>




			<div class="infoDiv">
				Description of the collection. Maximum length is 4000 characters.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##description">Documentation</a></li>
				</ul>

				<label for="DESCR">Description</label>
				<textarea class="hugetextarea reqdClr" name="DESCR" id="DESCR" required >#d.DESCR#</textarea>
			</div>

			<div class="infoDiv">
				URL to collection's loan policy. A loan policy is required; the contents of the loan policy are entirely up to the data owners.
				File an Issue for assistance in creating or hosting a loan policy.

				<label for="LOAN_POLICY_URL">Loan Policy URL</label>
				<input type="text" name="LOAN_POLICY_URL" id="LOAN_POLICY_URL" class="reqdClr" required value="#d.LOAN_POLICY_URL#" size="80">
			</div>


			<div class="infoDiv">
				Taxonomy Source is "your" classification. Choose an existing source, or file an Issue to import data or use an external
				source through GlobalNames.org.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/taxonomy.html##source-arctos">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-manage-taxonomic-classifications.html">How-To</a></li>
				</ul>

				<label for="PREFERRED_TAXONOMY_SOURCE">Taxonomy Source</label>
				<select name="preferred_taxonomy_source" id="preferred_taxonomy_source" class="reqdClr" required>
					<cfloop query="cttaxonomy_source">
						<option	<cfif d.preferred_taxonomy_source is cttaxonomy_source.source> selected="selected" </cfif>
							value="#source#">#source#</option>
					</cfloop>
				</select>

			</div>



			<div class="infoDiv">
				Allowable format of catalog number. Integer provides more functionality and is preferred. Please discuss with your Mentor
				if you are considering anything else.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##catalog-number">Documentation</a></li>
				</ul>
				<label for="CATALOG_NUMBER_FORMAT">Catalog Number Format</label>
				<select name="catalog_number_format" id="catalog_number_format" class="reqdClr" required >
					<option <cfif d.catalog_number_format is "integer">selected="selected" </cfif>value="integer">integer</option>
					<option <cfif d.catalog_number_format is "prefix-integer-suffix">selected="selected" </cfif>value="prefix-integer-suffix">prefix-integer-suffix</option>
					<option <cfif d.catalog_number_format is "string">selected="selected" </cfif>value="string">string</option>
				</select>

			</div>



			<div class="infoDiv">
				License to govern the usage of your data in Arctos. File an Issue if you need a new license. Note that data shared via DWC
				may be licensed differently, and Media are individually licensed.

				<ul>
					<li><a target="_blank" class="external" href="/info/ctDocumentation.cfm?table=CTMEDIA_LICENSE">Code Table</a></li>
				</ul>
				<label for="USE_LICENSE_ID">License</label>
				<select name="use_license_id" id="use_license_id" >
					<option value="NULL">-none-</option>
					<cfloop query="CTMEDIA_LICENSE">
						<option	<cfif d.use_license_id is MEDIA_LICENSE_ID> selected="selected" </cfif>
							value="#MEDIA_LICENSE_ID#">#DISPLAY#</option>
					</cfloop>
				</select>
			</div>



			<div class="infoDiv">
				URL to more information, such as the collection's home page.
				<label for="WEB_LINK">Web Link</label>
				<input type="text" name="WEB_LINK" id="WEB_LINK"  value="#d.WEB_LINK#" size="80">
			</div>

			<div class="infoDiv">
				Clickable text to display with web link.
				<label for="WEB_LINK_TEXT">Web Link Text</label>
				<input type="text" name="WEB_LINK_TEXT" id="WEB_LINK_TEXT" value="#d.WEB_LINK_TEXT#" size="80">
			</div>


			<div class="infoDiv">
				If you do not yet have a Mentor, you should discuss mentoring with a volunteer from
				<a href="/info/mentor.cfm">the list</a>. You may contact a potential Mentor directly,
				 use the contact form at the bottom of any Arctos page,
				file an Issue, or contact anyone involved in the administration of Arctos for help.
				<label for="mentor">mentor</label>
				<input type="text" name="mentor" id="mentor"  value="#d.mentor#" size="80">
			</div>


			<div class="infoDiv">
				Mentor's email. This is required to finalize this request.
				<label for="mentor_contact">mentor_contact</label>
				<input type="text" name="mentor_contact" id="mentor_contact" value="#d.mentor_contact#" size="80">
			</div>


			<div class="infoDiv">
				Contact Email is your email address. This is required to finalize this request. Comma-list is OK.
				<label for="contact_email">contact_email</label>
				<input type="text" name="contact_email" id="contact_email" value="#d.contact_email#" size="80">
			</div>

			<div class="infoDiv">
				Arctos username(s) who will receive initial manage_collection access. Comma-separated list OK. These Operators can
				create and manage other collection users. Anyone listed here should already have an Arctos account; contact your Mentor
				for an invitation.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/users.html">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Create-a-New-User-Account-for-Operators.html">How-To</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Invite-an-Operator.html">How-To</a></li>
				</ul>
				<label for="admin_username">admin_username</label>
				<input type="text" name="admin_username" id="admin_username"  value="#d.admin_username#" size="80">
			</div>
			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. This message will be included
				in that notification.
				<cfif d.status is "new">
					<label for="final_message">Message to include</label>
					<textarea class="hugetextarea reqdClr" name="final_message" id="final_message" required >#d.final_message#</textarea>
				<cfelse>
					<input type="hidden" name="final_message" id="final_message" value="#d.final_message#">
					<p>
						This request has already been submitted with message:
						<blockquote>
							#d.final_message#
						</blockquote>
					</p>
				</cfif>
			</div>


			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. Choosing "finalize" in this control will
				<ul>
					<li>LOCK existing data</li>
					<li>Notify Arctos staff of the request</li>
				</ul>

				<cfif d.status is "new">
					<label for="sfs">Request Finalization</label>
					<select name="sfs" id="sfs" >
						<option value="">not yet</option>
						<option value="yes_plz">Finalize these data; alert Arctos staff</option>
					</select>
				<cfelse>
					<p>
						This request has already been submitted. Contact your Mentor to revise.
					</p>
				</cfif>
			</div>

			<cfif isdefined("session.roles") and session.roles contains "global_admin">
				<div class="infoDiv">
					You have global_admin; you can change the status of this request.
					<ul>
						<li>new: unreviewed request</li>
						<li>submit for review: request is ready for consideration by Arctos staff</li>
						<li>ready to create: request is approved by Arctos staff and ready for DBA action</li>
						<li>created: collection is created and ready for use</li>
					</ul>
					The save and request will fail if mentor_contact does not contain an email address.
					<label for="status">status</label>
						<select name="status" id="status" class="reqdClr" required >
							<option <cfif d.status is "new">selected="selected" </cfif>value="new">new</option>
							<option <cfif d.status is "submit for review">selected="selected" </cfif>value="submit for review">submit for review</option>
							<option <cfif d.status is "ready to create">selected="selected" </cfif>value="ready to create">ready to create</option>
							<option <cfif d.status is "created">selected="selected" </cfif>value="created">created</option>
					</select>
				</div>
			</cfif>
			---->
			<div class="infoDiv">
				<p>
					Please carefully review the above information before submitting.
				</p>
				<p>
					You will be provided a link to this information if the submission is successful. Please save this link. Use the Contact
					link at the bottom of any form if you need to amend the submission.
				</p>
				<br><input type="submit" class="savBtn" value="Submit Request">
			</div>
		</form>




</cfoutput>

</cfif>




















<cfif action is "nothxxxxxxxxxxxing">
	<h2>New Collection Request</h2>
	<p>
		Use this form to initiate a request to join Arctos. Please fill out this form as accurately and completely as possible.
		This form is intended to provide general information about collection(s) that you are interested in migrating to Arctos.
		Once we receive this information, we will follow-up with additional discussion or questions as needed.
	</p>
	<p>
		This information should cover your entire institution or organization. Follow-up questions will include information
		about specific collections.
	</p>
	<p>
		Useful Links:
		<ul>
			<li><a target="_blank" class="external" href="https://arctosdb.org/faq/">Arctos FAQ </a></li>
			<li>
				<a target="_blank" class="external" href="https://www.tacc.utexas.edu/">TACC</a>
				handles all of our data storage and security on their
				<a target="_blank" class="external" href="https://www.tacc.utexas.edu/systems/corral">Corral</a> system.
			</li>
			<li><a target="_blank" class="external" href="https://arctosdb.org/join-arctos/costs/">current pricing structure</a></li>
			<li><a target="_blank" class="external" href="https://arctosdb.org/learn/webinars/">webinars</a></li>
			<li><a target="_blank" class="external" href="http://handbook.arctosdb.org">Arctos Handbook</a></li>
			<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Manage-a-Collection-in-Arctos.html">How-To: Manage Collection</a></li>
		</ul>
	</p>
	<cfoutput>
		<form name="f" id="f" action="new_collection.cfm" method="post">
			<input type="hidden" name="action" value="createInstitutionRequest">
			<h3>Institution Information</h3>
			<div class="infoDiv">
				Institution Acronym is a short, standardized identifier for your institution. Maximum length is 20 characters.
				<p>
					Examples:
					<ul>
						<li>UAM</li>
						<li>MSB</li>
						<li>MVZ</li>
					</ul>
				</p>
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##institution-acronym">Documentation</a></li>
				</ul>
				<label for="INSTITUTION_ACRONYM">Institution Acronym</label>
				<input type="text" name="INSTITUTION_ACRONYM" id="INSTITUTION_ACRONYM" class="reqdClr" required value="#d.INSTITUTION_ACRONYM#">
			</div>


			<div class="infoDiv">
				Institution is a standardized expansion of Institution Acronym, and should end with Institution Acronym is parentheses.
				 It should be the same for all collections in
				an institution. Examples:
				<ul>
					<li>Chicago Academy of Sciences (CHAS)</li>
					<li>Museum of Southwestern Biology (MSB)</li>
				</ul>

				<label for="INSTITUTION">Institution</label>
				<input type="text" name="INSTITUTION" id="INSTITUTION" class="reqdClr" required value="#d.INSTITUTION#" size="80">
			</div>

			<div class="infoDiv">
				<label for="ttl_spc_cnt"> How many total specimens across all collection(s) are you interested in migrating to Arctos?</label>
				<input type="text" name="ttl_spc_cnt" id="ttl_spc_cnt" class="reqdClr" required value="#d.ttl_spc_cnt#" size="80">
			</div>
			<div class="infoDiv">
				<label for="are_all_digitized">Are the data for all of those specimens in digital format?</label>
				<select name="are_all_digitized">
					<option value=""></option>
					<option value="yes" <cfif d.are_all_digitized is "yes"> selected="selected"</cfif> >yes</option>
					<option value="no" <cfif d.are_all_digitized is "no"> selected="selected"</cfif> >no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="specimen_types">Which of the following specimen types are you interested in migrating to Arctos (check all that apply)?</label>
				<cfset l= "Amphibians Reptiles Fishes Birds Mammals Insects Invertebrates Parasites Tissues Herbarium Earth Sciences Art History Ethnology Archaeology Other">
				<cfloop list="#l#" delimiters=" " index="i">
					<input type="checkbox" name="specimen_types"
						<cfif d.specimen_types contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="yearly_add_avg">On average, how many specimens have been added to the collection(s) annually over the past 5 years?</label>
				<input type="text" name="yearly_add_avg" id="yearly_add_avg" class="reqdClr" required value="#d.yearly_add_avg#" size="80">
			</div>
			<div class="infoDiv">
				<label for="exp_grth_rate">How do you expect this rate of growth to change in the foreseeable future?</label>
				<select name="exp_grth_rate">
					<option value=""></option>
					<option value="Increase" <cfif d.are_all_digitized is "Increase"> selected="selected"</cfif> >Increase</option>
					<option value="Remain the same" <cfif d.are_all_digitized is "Remain the same"> selected="selected"</cfif> >Remain the same</option>
					<option value="Decrease" <cfif d.are_all_digitized is "Decrease"> selected="selected"</cfif> >Decrease</option>
					<option value="Not sure" <cfif d.are_all_digitized is "Not sure"> selected="selected"</cfif> >Not sure</option>
				</select>
			</div>

			<h3>Data Structure</h3>
			<p>
				The following questions are intended to provide basic information about how your data are managed currently.
				Controlled vocabularies are text strings in a pick list. Authority files contain controlled information with
				metadata and some complexity (e.g., relationships such as synonymies); they are often stored in at least one table with
				more than one column.
			</p>



			<div class="infoDiv">
				<label for="current_software">What software do you currently use to manage specimen data (e.g., e.g., Access, Filemaker Pro, Excel, Specify-indicate which version, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="current_software" id="current_software" required >#d.current_software#</textarea>
			</div>


			<div class="infoDiv">
				<label for="current_software">How are your data structured in your current information system (flat table, related tables, disjoined tables, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="current_structure" id="current_structure" required >#d.current_structure#</textarea>
			</div>



			<div class="infoDiv">
				<label for="vocab_control">Do you use controlled vocabularies or authority files for the following kinds of data (check all that apply)?</label>
				<cfset l= "Agents,Taxonomy,Geography,Specimen Parts, Not Used">
				<cfloop list="#l#" delimiters="," index="i">
					<input type="checkbox" name="vocab_control"
						<cfif d.vocab_control contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="free_text">Do you allow free text data entry for the following kinds of data (check all that apply)?</label>
				<cfset l= "Agents,Taxonomy,Geography,Specimen Parts, Not Used">
				<cfloop list="#l#" delimiters="," index="i">
					<input type="checkbox" name="free_text"
						<cfif d.free_text contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="vocab_enforcement">Is it possible to bypass the controlled vocabularies or authority files? Explain.</label>
				<textarea class="hugetextarea reqdClr" name="vocab_enforcement" id="vocab_enforcement" required >#d.vocab_enforcement#</textarea>
			</div>


			<div class="infoDiv">
				<label for="vocab_text">Please expand on how you deal with agents, taxonomy, geography, and/or specimen parts.</label>
				<textarea class="hugetextarea reqdClr" name="vocab_text" id="vocab_text" required >#d.vocab_text#</textarea>
			</div>


			<div class="infoDiv">
				<label for="tissues">Do you allow free text data entry for the following kinds of data (check all that apply)?</label>
				<cfset l= "	Tissues are treated as parts of a specimen using a controlled vocabulary or authority file.|Tissues are treated as parts of a specimen, entered in free-form text.|Tissues are cataloged in a separate collection, and cross-linked to voucher specimen.|Tissues are entered as free-form text in a remarks or comment field.|There are no tissues in our collection.|Other.">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="tissues"
						<cfif d.free_text contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>

			<div class="infoDiv">
				<label for="tissue_detail">Describe any other details about how you deal with tissues currently, or plan to deal with them in the future.</label>
				<textarea class="hugetextarea reqdClr" name="tissue_detail" id="tissue_detail" required >#d.tissue_detail#</textarea>
			</div>


			<div class="infoDiv">
				<label for="barcodes">Do you use machine-readable labels (such as barcodes) to digitally track any objects in your collections?</label>
				<select name="barcodes">
					<option value=""></option>
					<option value="yes" <cfif d.barcodes is "yes"> selected="selected"</cfif> >yes</option>
					<option value="no" <cfif d.barcodes is "no"> selected="selected"</cfif> >no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="barcode_desc">Describe any details about you incorporate barcodes into your current system, or whether you plan to deal with them in the future.</label>
				<textarea class="hugetextarea reqdClr" name="barcode_desc" id="barcode_desc" required >#d.barcode_desc#</textarea>
			</div>

			<div class="infoDiv">
				<label for="locality">Describe how you deal with locality information (including coordinates, if any) in your current collection management system.</label>
				<textarea class="hugetextarea reqdClr" name="locality" id="locality" required >#d.locality#</textarea>
			</div>
			<div class="infoDiv">
				<label for="georefedpercent">Approximately what proportion of your locality data are georeferenced with latitude/longitude coordinates? * </label>
				<input type="text" name="georefedpercent" id="georefedpercent" class="reqdClr" required value="#d.georefedpercent#" size="80">
			</div>
			<div class="infoDiv">
				<label for="metadata">Describe the kinds of metadata that you store with your coordinate information (e.g., datum, GPS error, extent, maximum uncertainty, georeferencing method, etc.)</label>
				<textarea class="hugetextarea reqdClr" name="metadata" id="metadata" required >#d.metadata#</textarea>
			</div>

			<div class="infoDiv">
				<label for="tissues">For the following transaction types, indicate whether you have digital information that would need to be formatted and imported? (check all that apply)</label>
				<cfset l= "Loans|Accessions|Permits|We do not track transactions digitally">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="digital_trans"
						<cfif d.digital_trans contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>


			<div class="infoDiv">
				<label for="metadata">Describe generally how you deal with transactions (loans, accessions, permits) in your current system.</label>
				<textarea class="hugetextarea reqdClr" name="trans_desc" id="trans_desc" required >#d.trans_desc#</textarea>
			</div>
			<div class="infoDiv">
				<label for="more_data">Other than basic “label data” (who/what/when/where), what other kinds of information (if any) is recorded about your specimens (e.g., citations in publications, GenBank numbers, projects, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="more_data" id="more_data" required >#d.more_data#</textarea>
			</div>

			<div class="infoDiv">
				<label for="digital_media"> Do you have digital media in your current system? </label>
				<select name="digital_media">
					<option value=""></option>
					<option value="yes" <cfif d.digital_media is "yes"> selected="selected"</cfif> >yes</option>
					<option value="no" <cfif d.digital_media is "no"> selected="selected"</cfif> >no</option>
				</select>
			</div>


			<div class="infoDiv">
				<label for="media_plan">Indicate how you plan to store digital media that are linked to data in Arctos.</label>
				<cfset l= "We need storage for digital media through Arctos.|We have our own web-accessible storage for digital media.|Our digital media are stored and accessible via an external web service.|We do not plan to have digital media in Arctos at this time.">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="media_plan"
						<cfif d.media_plan contains "#i#">checked="checked"</cfif> value="#i#">#i#<br>
				</cfloop>
   			</div>

			<h3>Putting your data in Arctos</h3>


			<div class="infoDiv">
				<label for="want_storage"> Do you have digital media in your current system? </label>
				<select name="want_storage">
					<option value=""></option>
					<option value="yes" <cfif d.want_storage is "yes"> selected="selected"</cfif> >yes</option>
					<option value="no" <cfif d.want_storage is "no"> selected="selected"</cfif> >no</option>
				</select>
			</div>

			<div class="infoDiv">
				<label for="security_concern">Please describe any permission or security issues that would prevent us from accessing your data directly if necessary for data migration?</label>
				<textarea class="hugetextarea reqdClr" name="security_concern" id="security_concern" required >#d.security_concern#</textarea>
			</div>



			<div class="infoDiv">
				<label for="budget">Do you have an annual budget available for database support?</label>
				<select name="budget">
					<option value=""></option>
					<option value="yes" <cfif d.budget is "yes"> selected="selected"</cfif> >yes</option>
					<option value="no" <cfif d.budget is "no"> selected="selected"</cfif> >no</option>
				</select>
			</div>



			<div class="infoDiv">
				<label for="comments">Please add any other comments or questions that you have re: Arctos or your collection(s).</label>
				<textarea class="hugetextarea reqdClr" name="comments" id="comments" required >#d.comments#</textarea>
			</div>

			<div class="infoDiv">
				<label for="completed_by">Questionnaire completed by</label>
				<input type="text" name="completed_by" id="completed_by" class="reqdClr" required value="#d.completed_by#">
			</div>


			<div class="infoDiv">
				<label for="completed_by_title">Job Title</label>
				<input type="text" name="completed_by_title" id="completed_by_title" class="reqdClr" required value="#d.completed_by_title#">
			</div>


			<div class="infoDiv">
				<label for="completed_by_email">Email</label>
				<input type="email" name="completed_by_email" id="completed_by_email" class="reqdClr" required value="#d.completed_by_email#">
			</div>

			<div class="infoDiv">
				<label for="completed_by_phone">Phone</label>
				<input type="phone" name="completed_by_phone" id="completed_by_phone" class="reqdClr" required value="#d.completed_by_phone#">
			</div>

			<!----















			<div class="infoDiv">
				Collection is displayed as a child of institution in the Collection search box on SpecimenSearch.
				It should be the same for all collections of similar type across institutions. Examples:

				<ul>
					<li>Amphibian and reptile specimens</li>
					<li>Insect specimens</li>
					<li>Mammal observations</li>
				</ul>



				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##collection">Documentation</a></li>
				</ul>

				<label for="COLLECTION">Collection</label>
				<input type="text" name="COLLECTION" id="COLLECTION" class="reqdClr" required value="#d.COLLECTION#" size="80">
			</div>




			<div class="infoDiv">
				Description of the collection. Maximum length is 4000 characters.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##description">Documentation</a></li>
				</ul>

				<label for="DESCR">Description</label>
				<textarea class="hugetextarea reqdClr" name="DESCR" id="DESCR" required >#d.DESCR#</textarea>
			</div>

			<div class="infoDiv">
				URL to collection's loan policy. A loan policy is required; the contents of the loan policy are entirely up to the data owners.
				File an Issue for assistance in creating or hosting a loan policy.

				<label for="LOAN_POLICY_URL">Loan Policy URL</label>
				<input type="text" name="LOAN_POLICY_URL" id="LOAN_POLICY_URL" class="reqdClr" required value="#d.LOAN_POLICY_URL#" size="80">
			</div>


			<div class="infoDiv">
				Taxonomy Source is "your" classification. Choose an existing source, or file an Issue to import data or use an external
				source through GlobalNames.org.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/taxonomy.html##source-arctos">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-manage-taxonomic-classifications.html">How-To</a></li>
				</ul>

				<label for="PREFERRED_TAXONOMY_SOURCE">Taxonomy Source</label>
				<select name="preferred_taxonomy_source" id="preferred_taxonomy_source" class="reqdClr" required>
					<cfloop query="cttaxonomy_source">
						<option	<cfif d.preferred_taxonomy_source is cttaxonomy_source.source> selected="selected" </cfif>
							value="#source#">#source#</option>
					</cfloop>
				</select>

			</div>



			<div class="infoDiv">
				Allowable format of catalog number. Integer provides more functionality and is preferred. Please discuss with your Mentor
				if you are considering anything else.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##catalog-number">Documentation</a></li>
				</ul>
				<label for="CATALOG_NUMBER_FORMAT">Catalog Number Format</label>
				<select name="catalog_number_format" id="catalog_number_format" class="reqdClr" required >
					<option <cfif d.catalog_number_format is "integer">selected="selected" </cfif>value="integer">integer</option>
					<option <cfif d.catalog_number_format is "prefix-integer-suffix">selected="selected" </cfif>value="prefix-integer-suffix">prefix-integer-suffix</option>
					<option <cfif d.catalog_number_format is "string">selected="selected" </cfif>value="string">string</option>
				</select>

			</div>



			<div class="infoDiv">
				License to govern the usage of your data in Arctos. File an Issue if you need a new license. Note that data shared via DWC
				may be licensed differently, and Media are individually licensed.

				<ul>
					<li><a target="_blank" class="external" href="/info/ctDocumentation.cfm?table=CTMEDIA_LICENSE">Code Table</a></li>
				</ul>
				<label for="USE_LICENSE_ID">License</label>
				<select name="use_license_id" id="use_license_id" >
					<option value="NULL">-none-</option>
					<cfloop query="CTMEDIA_LICENSE">
						<option	<cfif d.use_license_id is MEDIA_LICENSE_ID> selected="selected" </cfif>
							value="#MEDIA_LICENSE_ID#">#DISPLAY#</option>
					</cfloop>
				</select>
			</div>



			<div class="infoDiv">
				URL to more information, such as the collection's home page.
				<label for="WEB_LINK">Web Link</label>
				<input type="text" name="WEB_LINK" id="WEB_LINK"  value="#d.WEB_LINK#" size="80">
			</div>

			<div class="infoDiv">
				Clickable text to display with web link.
				<label for="WEB_LINK_TEXT">Web Link Text</label>
				<input type="text" name="WEB_LINK_TEXT" id="WEB_LINK_TEXT" value="#d.WEB_LINK_TEXT#" size="80">
			</div>


			<div class="infoDiv">
				If you do not yet have a Mentor, you should discuss mentoring with a volunteer from
				<a href="/info/mentor.cfm">the list</a>. You may contact a potential Mentor directly,
				 use the contact form at the bottom of any Arctos page,
				file an Issue, or contact anyone involved in the administration of Arctos for help.
				<label for="mentor">mentor</label>
				<input type="text" name="mentor" id="mentor"  value="#d.mentor#" size="80">
			</div>


			<div class="infoDiv">
				Mentor's email. This is required to finalize this request.
				<label for="mentor_contact">mentor_contact</label>
				<input type="text" name="mentor_contact" id="mentor_contact" value="#d.mentor_contact#" size="80">
			</div>


			<div class="infoDiv">
				Contact Email is your email address. This is required to finalize this request. Comma-list is OK.
				<label for="contact_email">contact_email</label>
				<input type="text" name="contact_email" id="contact_email" value="#d.contact_email#" size="80">
			</div>

			<div class="infoDiv">
				Arctos username(s) who will receive initial manage_collection access. Comma-separated list OK. These Operators can
				create and manage other collection users. Anyone listed here should already have an Arctos account; contact your Mentor
				for an invitation.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/users.html">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Create-a-New-User-Account-for-Operators.html">How-To</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Invite-an-Operator.html">How-To</a></li>
				</ul>
				<label for="admin_username">admin_username</label>
				<input type="text" name="admin_username" id="admin_username"  value="#d.admin_username#" size="80">
			</div>
			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. This message will be included
				in that notification.
				<cfif d.status is "new">
					<label for="final_message">Message to include</label>
					<textarea class="hugetextarea reqdClr" name="final_message" id="final_message" required >#d.final_message#</textarea>
				<cfelse>
					<input type="hidden" name="final_message" id="final_message" value="#d.final_message#">
					<p>
						This request has already been submitted with message:
						<blockquote>
							#d.final_message#
						</blockquote>
					</p>
				</cfif>
			</div>


			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. Choosing "finalize" in this control will
				<ul>
					<li>LOCK existing data</li>
					<li>Notify Arctos staff of the request</li>
				</ul>

				<cfif d.status is "new">
					<label for="sfs">Request Finalization</label>
					<select name="sfs" id="sfs" >
						<option value="">not yet</option>
						<option value="yes_plz">Finalize these data; alert Arctos staff</option>
					</select>
				<cfelse>
					<p>
						This request has already been submitted. Contact your Mentor to revise.
					</p>
				</cfif>
			</div>

			<cfif isdefined("session.roles") and session.roles contains "global_admin">
				<div class="infoDiv">
					You have global_admin; you can change the status of this request.
					<ul>
						<li>new: unreviewed request</li>
						<li>submit for review: request is ready for consideration by Arctos staff</li>
						<li>ready to create: request is approved by Arctos staff and ready for DBA action</li>
						<li>created: collection is created and ready for use</li>
					</ul>
					The save and request will fail if mentor_contact does not contain an email address.
					<label for="status">status</label>
						<select name="status" id="status" class="reqdClr" required >
							<option <cfif d.status is "new">selected="selected" </cfif>value="new">new</option>
							<option <cfif d.status is "submit for review">selected="selected" </cfif>value="submit for review">submit for review</option>
							<option <cfif d.status is "ready to create">selected="selected" </cfif>value="ready to create">ready to create</option>
							<option <cfif d.status is "created">selected="selected" </cfif>value="created">created</option>
					</select>
				</div>
			</cfif>
			---->
			<div class="infoDiv">
				<p>
					Please carefully review the above information before submitting.
				</p>
				<p>
					You will be provided a link to this information if the submission is successful. Please save this link. Use the Contact
					link at the bottom of any form if you need to amend the submission.
				</p>
				<br><input type="submit" class="savBtn" value="Submit Request">
			</div>
		</form>




</cfoutput>

</cfif>

















<cfif action is "nothxxxxxing">
	<p>
		This form facilitates new collection creation in Arctos. This is a request only; you cannot create a collection with this form.
	</p>
	<h2>Initiate a Request</h2>

	<form name="f" id="f" method="post" action="new_collection.cfm">
		<input type="hidden" name="action" value="new_request">
		<div class="infoDiv">
			Institution Acronym is a short, standardized identifier for your institution. Maximum length is 20 characters.
			<p>
				Examples:
				<ul>
					<li>UAM</li>
					<li>MSB</li>
					<li>MVZ</li>
				</ul>
			</p>
			<ul>
				<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##institution-acronym">Documentation</a></li>
			</ul>
			<label for="INSTITUTION_ACRONYM">Institution Acronym</label>
			<input type="text" name="INSTITUTION_ACRONYM" id="INSTITUTION_ACRONYM" class="reqdClr" required >
		</div>
		<cfoutput>
		<div class="infoDiv">
			Password used for managing this request. This password is NOT secure and should be used nowhere except in this form.
			The password must be at least one character in length.	DO NOT re-use your password to any site, including Arctos.
			This password provides light obfuscation of the collection creation process, but is no guarantee of security. Do not provide any
			confidential information in this form. A password has been suggested; you may change it.
		    <cfscript>
			    chrz = "23456789ABCDEFGHJKMNPQRS";
			    length = randRange(4,7);
			    i = "";
			    char = "";
			    pwd="";
			    for(i=1; i <= length; i++) {
			        char = mid(chrz, randRange(1, len(chrz)),1);
			        pwd=pwd & char;
			    }
		    </cfscript>

			<label for="user_pwd">Password</label>
			<input type="text" name="user_pwd" id="user_pwd" class="reqdClr" required value="#pwd#">
		</div>
		<input type="submit" value="submit request" class="insBtn">
		</cfoutput>
	</form>

	<hr>

	<h2>Existing Requests</h2>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from pre_new_institution order by insert_date desc
	</cfquery>
		<cfoutput>
			<table border>
				<tr>
					<th>Institutiton Acronym</th>
					<th>CreateDate</th>
					<th>Status</th>
					<th>Manage</th>
				</tr>
				<cfloop query="d">
					<tr>
						<td>#institution_acronym#</td>
						<td>#dateformat(insert_date,'yyyy-mm-dd')#</td>
						<td>#status#</td>
						<td>
							<form action="new_collection.cfm">
								<input type="hidden" name="action" value="manage">
								<label for="password">
									Enter the password provided when you created this request
									<cfif isdefined("session.roles") and session.roles contains "global_admin">
									 You're admin; no password necessary.
									</cfif>
								</label>
								<input type="password" name="tpwd"
									<cfif isdefined("session.roles") and session.roles contains "global_admin">
										value="#user_pwd#"
									</cfif>
								>
								<input type="submit" value="go">
							</form>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
<!----

	If you have created a request, fill in the form with the password and Institution Acronym you used in the initial request and click "manage existing request."
	<p>
	<form name="f" id="f" method="post" action="new_collection.cfm">
		<input type="hidden" name="action" value="edit">
		<label for="institution_acronym">Institution Acronym</label>
		<input type="text" name="guid_prefix" id="guid_prefix" class="reqdClr" required>
		<label for="user_pwd">Password</label>
		<input type="text" name="user_pwd" id="user_pwd" class="reqdClr" required>
		<br><input type="button" class="insBtn" onclick="document.f.action.value='newCollectionRequest';document.f.submit();" value="create collection request">
		<br><input type="button" class="lnkBtn" onclick="document.f.action.value='mgCollectionRequest';document.f.submit();" value="manage existing request">
	</form>



	<h2>Request a new collection</h2>
	If this is a new request, first
	<a href="http://handbook.arctosdb.org/documentation/catalog.html#guid-prefix">CAREFULLY review the GUID_prefix documentation</a>,
	enter your desired guid_prefix and a temporary password in the form below, and click "create collection request."
	This password is NOT secure and should be used nowhere except in this form. The password must be at least one character in length.
	DO NOT re-use your password to any site, including Arctos. (It's fine to re-use
	the temporary password when requesting multiple collections.) This password provides light obfuscation of the collection creation process,
	but is no guarantee of security. Do not provide any
	confidential information in this form. Discuss any concerns with your Mentor.

	<h2>Manage an existing request</h2>
	If you have created a request, fill in the form with the password and GUID_Prefix you used in the initial request and click
	"manage existing request."
	<p>
	<form name="f" id="f" method="post" action="new_collection.cfm">
		<input type="hidden" name="action" value="default">
		<label for="guid_prefix">GUID Prefix</label>
		<input type="text" name="guid_prefix" id="guid_prefix" class="reqdClr" required>
		<label for="user_pwd">Password</label>
		<input type="text" name="user_pwd" id="user_pwd" class="reqdClr" required>
		<br><input type="button" class="insBtn" onclick="document.f.action.value='newCollectionRequest';document.f.submit();" value="create collection request">
		<br><input type="button" class="lnkBtn" onclick="document.f.action.value='mgCollectionRequest';document.f.submit();" value="manage existing request">
	</form>

	<cfif isdefined("session.roles") and session.roles contains "global_admin">
		you are admin; manage existing
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from pre_new_collection order by insert_date desc
		</cfquery>
		<cfoutput>
			<table border>
				<tr>
					<th>GUID Prefix</th>
					<th>CreateDate</th>
					<th>Status</th>
					<th>Manage</th>
				</tr>
				<cfloop query="d">
					<tr>
						<td>#GUID_PREFIX#</td>
						<td>#dateformat(insert_date,'yyyy-mm-dd')#</td>
						<td>#status#</td>
						<td><a href="new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(user_pwd)#&GUID_PREFIX=#GUID_PREFIX#">clicky</a></td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
--->
</cfif>

<cfif action is "new_request">
	<cfquery name="mkr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into pre_new_institution (
			niid,
			user_pwd,
			INSTITUTION_ACRONYM,
			status,
			insert_date,
			initiated_by_username
		) values (
			someRandomSequence.nextval,
			'#escapeQuotes(user_pwd)#',
			'#escapeQuotes(INSTITUTION_ACRONYM)#',
			'new',
			sysdate,
			'#session.username#'
		)
	</cfquery>
	<cflocation url="new_collection.cfm?action=manage&pwhash=#hash(user_pwd)#&INSTITUTION_ACRONYM=#INSTITUTION_ACRONYM#">
</cfif>


















<cfif action is "newCollectionRequest">
	<cfquery name="mkr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into pre_new_collection (
			ncid,
			user_pwd,
			GUID_PREFIX,
			status,
			insert_date,
			initiated_by_username
		) values (
			someRandomSequence.nextval,
			'#escapeQuotes(user_pwd)#',
			'#escapeQuotes(guid_prefix)#',
			'new',
			sysdate,
			'#session.username#'
		)
	</cfquery>
	<cflocation url="new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(user_pwd)#&GUID_PREFIX=#GUID_PREFIX#">
</cfif>

<cfif action is "mgCollectionRequest">


	<cfquery name="CTMEDIA_LICENSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select MEDIA_LICENSE_ID,DISPLAY from CTMEDIA_LICENSE order by DISPLAY
	</cfquery>

	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source group by source order by source
	</cfquery>
	<cfquery name="ctcollection_cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_cde from ctcollection_cde  order by collection_cde
	</cfquery>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from pre_new_collection where guid_prefix='#guid_prefix#' and
		<cfif isdefined('user_pwd') and len('user_pwd') gt 0>
			user_pwd='#escapeQuotes(user_pwd)#'
		<cfelseif isdefined('pwhash') and len('pwhash') gt 0>
			dbms_obfuscation_toolkit.md5(input => UTL_RAW.cast_to_raw(user_pwd)) ='#pwhash#'
		<cfelse>
			1=2
		</cfif>
	</cfquery>
	<cfoutput>
		<h2>New Collection Request</h2>
		<p>
			<ul>
				<li>Request Date: #dateformat(d.insert_date,'yyyy-mm-dd')#</li>
				<li>Initiated By: #d.initiated_by_username#</li>
				<li>Status: #d.status#</li>
				<li>Password: #d.user_pwd#</li>
				<li>
					Sharable link to this form. CAUTION: This provides edit access to anyone with an Arcto account.
					<br>
					<code>
						#application.serverRootURL#/new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(d.user_pwd)#&GUID_PREFIX=#d.GUID_PREFIX#
					</code>
				</li>
				<cfif not isdefined("session.roles") or session.roles does not contain "global_admin">
					<cfif d.status is not "new">
						<div class="importantNotification">
							You may not edit this request. Contact your Mentor if you need to make revisions.
						</div>
					</cfif>
				</cfif>
			</ul>
		</p>
		<p>
			Useful Links:
			<ul>
				<li><a target="_blank" class="external" href="https://arctosdb.org/faq/">Arctos FAQ </a></li>
				<li>
					<a target="_blank" class="external" href="https://www.tacc.utexas.edu/">TACC</a>
					handles all of our data storage and security on their
					<a target="_blank" class="external" href="https://www.tacc.utexas.edu/systems/corral">Corral</a> system.
				</li>
				<li><a target="_blank" class="external" href="https://arctosdb.org/join-arctos/costs/">current pricing structure</a></li>
				<li><a target="_blank" class="external" href="https://arctosdb.org/learn/webinars/">webinars</a></li>
				<li><a target="_blank" class="external" href="http://handbook.arctosdb.org">Arctos Handbook</a></li>
				<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Manage-a-Collection-in-Arctos.html">How-To: Manage Collection</a></li>
			</ul>
		</p>
		<p>
			Make sure to save if you change anything! Scroll down for options.
		</p>

		<form name="f" id="f" action="new_collection.cfm" method="post">

			<br><input type="submit" class="savBtn" value="save changes">

			<input type="hidden" name="ncid" value="#d.ncid#">

			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="user_pwd" value="#d.user_pwd#">
			<input type="hidden" name="old_status" value="#d.status#">
			<!----
			<div class="infoDiv">
				This password is NOT secure and comes with no restrictions. DO NOT re-use your password to any site, including Arctos.
				This prevents public browsing of these data, but is no guarantee of security. You will need this password to
				edit or finalize your request. Do not provide any
				confidential information in this form. Discuss any concerns with your Mentor.
				<label for="user_pwd">Password</label>
				<input type="text" name="user_pwd" id="user_pwd" class="reqdClr" required value="#d.user_pwd#">

			</div>


			---->

			<div class="infoDiv">
				GUID_Prefix is the core of the primary specimen identifier. It is combined with catalog number and Arctos' URL to
				produce a resolvable globally-unique specimen identifier. This must be unique across all Arctos collections.
				The format MUST be {string}:{string}. GUID_Prefix cannot be changed without breaking all links to specimens; choose carefully.
				The traditional format is {institution_acronym}:{collection_cde}, but this is not a requirement. Maximum length is 20 characters.
				You may wish to register your collection in <a href="http://grbio.org" target="_blank" class="external">GRBIO</a>.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##guid-prefix">Documentation</a></li>
				</ul>
				<label for="GUID_PREFIX">GUID_Prefix</label>
				<input type="text" name="GUID_PREFIX" id="GUID_PREFIX" class="reqdClr" required value="#d.GUID_PREFIX#">
			</div>


			<div class="infoDiv">
				Collection Code controls which code tables your collection will use.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##collection-code">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://arctos.database.museum/info/ctDocumentation.cfm?table=CTCOLLECTION_CDE">Code Table</a></li>
				</ul>

				<label for="COLLECTION_CDE">Collection Code</label>
				<select name="COLLECTION_CDE" id="COLLECTION_CDE" class="reqdClr" required>
					<cfloop query="ctcollection_cde">
						<option	<cfif d.collection_cde is ctcollection_cde.collection_cde> selected="selected" </cfif>
							value="#collection_cde#">#collection_cde#</option>
					</cfloop>
				</select>
			</div>


			<div class="infoDiv">
				Institution Acronym is typically the first component of GUID_Prefix. Maximum length is 20 characters.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##institution-acronym">Documentation</a></li>
				</ul>

				<label for="INSTITUTION_ACRONYM">Institution Acronym</label>
				<input type="text" name="INSTITUTION_ACRONYM" id="INSTITUTION_ACRONYM" class="reqdClr" required value="#d.INSTITUTION_ACRONYM#">

			</div>

			<div class="infoDiv">
				Institution is displayed as "section header" in the Collection search box on SpecimenSearch. It should be the same for all collections in
				an institution, and end with Institution Acronym in parentheses. Examples:
				<ul>
					<li>Chicago Academy of Sciences (CHAS)</li>
					<li>Museum of Southwestern Biology (MSB)</li>
				</ul>

				<label for="INSTITUTION">Institution</label>
				<input type="text" name="INSTITUTION" id="INSTITUTION" class="reqdClr" required value="#d.INSTITUTION#" size="80">
			</div>

			<div class="infoDiv">
				Collection is displayed as a child of institution in the Collection search box on SpecimenSearch.
				It should be the same for all collections of similar type across institutions. Examples:

				<ul>
					<li>Amphibian and reptile specimens</li>
					<li>Insect specimens</li>
					<li>Mammal observations</li>
				</ul>



				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##collection">Documentation</a></li>
				</ul>

				<label for="COLLECTION">Collection</label>
				<input type="text" name="COLLECTION" id="COLLECTION" class="reqdClr" required value="#d.COLLECTION#" size="80">
			</div>




			<div class="infoDiv">
				Description of the collection. Maximum length is 4000 characters.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##description">Documentation</a></li>
				</ul>

				<label for="DESCR">Description</label>
				<textarea class="hugetextarea reqdClr" name="DESCR" id="DESCR" required >#d.DESCR#</textarea>
			</div>

			<div class="infoDiv">
				URL to collection's loan policy. A loan policy is required; the contents of the loan policy are entirely up to the data owners.
				File an Issue for assistance in creating or hosting a loan policy.

				<label for="LOAN_POLICY_URL">Loan Policy URL</label>
				<input type="text" name="LOAN_POLICY_URL" id="LOAN_POLICY_URL" class="reqdClr" required value="#d.LOAN_POLICY_URL#" size="80">
			</div>


			<div class="infoDiv">
				Taxonomy Source is "your" classification. Choose an existing source, or file an Issue to import data or use an external
				source through GlobalNames.org.
				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/taxonomy.html##source-arctos">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-manage-taxonomic-classifications.html">How-To</a></li>
				</ul>

				<label for="PREFERRED_TAXONOMY_SOURCE">Taxonomy Source</label>
				<select name="preferred_taxonomy_source" id="preferred_taxonomy_source" class="reqdClr" required>
					<cfloop query="cttaxonomy_source">
						<option	<cfif d.preferred_taxonomy_source is cttaxonomy_source.source> selected="selected" </cfif>
							value="#source#">#source#</option>
					</cfloop>
				</select>

			</div>



			<div class="infoDiv">
				Allowable format of catalog number. Integer provides more functionality and is preferred. Please discuss with your Mentor
				if you are considering anything else.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##catalog-number">Documentation</a></li>
				</ul>
				<label for="CATALOG_NUMBER_FORMAT">Catalog Number Format</label>
				<select name="catalog_number_format" id="catalog_number_format" class="reqdClr" required >
					<option <cfif d.catalog_number_format is "integer">selected="selected" </cfif>value="integer">integer</option>
					<option <cfif d.catalog_number_format is "prefix-integer-suffix">selected="selected" </cfif>value="prefix-integer-suffix">prefix-integer-suffix</option>
					<option <cfif d.catalog_number_format is "string">selected="selected" </cfif>value="string">string</option>
				</select>

			</div>



			<div class="infoDiv">
				License to govern the usage of your data in Arctos. File an Issue if you need a new license. Note that data shared via DWC
				may be licensed differently, and Media are individually licensed.

				<ul>
					<li><a target="_blank" class="external" href="/info/ctDocumentation.cfm?table=CTMEDIA_LICENSE">Code Table</a></li>
				</ul>
				<label for="USE_LICENSE_ID">License</label>
				<select name="use_license_id" id="use_license_id" >
					<option value="NULL">-none-</option>
					<cfloop query="CTMEDIA_LICENSE">
						<option	<cfif d.use_license_id is MEDIA_LICENSE_ID> selected="selected" </cfif>
							value="#MEDIA_LICENSE_ID#">#DISPLAY#</option>
					</cfloop>
				</select>
			</div>



			<div class="infoDiv">
				URL to more information, such as the collection's home page.
				<label for="WEB_LINK">Web Link</label>
				<input type="text" name="WEB_LINK" id="WEB_LINK"  value="#d.WEB_LINK#" size="80">
			</div>

			<div class="infoDiv">
				Clickable text to display with web link.
				<label for="WEB_LINK_TEXT">Web Link Text</label>
				<input type="text" name="WEB_LINK_TEXT" id="WEB_LINK_TEXT" value="#d.WEB_LINK_TEXT#" size="80">
			</div>


			<div class="infoDiv">
				If you do not yet have a Mentor, you should discuss mentoring with a volunteer from
				<a href="/info/mentor.cfm">the list</a>. You may contact a potential Mentor directly,
				 use the contact form at the bottom of any Arctos page,
				file an Issue, or contact anyone involved in the administration of Arctos for help.
				<label for="mentor">mentor</label>
				<input type="text" name="mentor" id="mentor"  value="#d.mentor#" size="80">
			</div>


			<div class="infoDiv">
				Mentor's email. This is required to finalize this request.
				<label for="mentor_contact">mentor_contact</label>
				<input type="text" name="mentor_contact" id="mentor_contact" value="#d.mentor_contact#" size="80">
			</div>


			<div class="infoDiv">
				Contact Email is your email address. This is required to finalize this request. Comma-list is OK.
				<label for="contact_email">contact_email</label>
				<input type="text" name="contact_email" id="contact_email" value="#d.contact_email#" size="80">
			</div>

			<div class="infoDiv">
				Arctos username(s) who will receive initial manage_collection access. Comma-separated list OK. These Operators can
				create and manage other collection users. Anyone listed here should already have an Arctos account; contact your Mentor
				for an invitation.

				<ul>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/users.html">Documentation</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Create-a-New-User-Account-for-Operators.html">How-To</a></li>
					<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/how_to/How-to-Invite-an-Operator.html">How-To</a></li>
				</ul>
				<label for="admin_username">admin_username</label>
				<input type="text" name="admin_username" id="admin_username"  value="#d.admin_username#" size="80">
			</div>
			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. This message will be included
				in that notification.
				<cfif d.status is "new">
					<label for="final_message">Message to include</label>
					<textarea class="hugetextarea reqdClr" name="final_message" id="final_message" required >#d.final_message#</textarea>
				<cfelse>
					<input type="hidden" name="final_message" id="final_message" value="#d.final_message#">
					<p>
						This request has already been submitted with message:
						<blockquote>
							#d.final_message#
						</blockquote>
					</p>
				</cfif>
			</div>


			<div class="infoDiv">
				Once everything in this form is to your satisfaction, you may finalize this request. Choosing "finalize" in this control will
				<ul>
					<li>LOCK existing data</li>
					<li>Notify Arctos staff of the request</li>
				</ul>

				<cfif d.status is "new">
					<label for="sfs">Request Finalization</label>
					<select name="sfs" id="sfs" >
						<option value="">not yet</option>
						<option value="yes_plz">Finalize these data; alert Arctos staff</option>
					</select>
				<cfelse>
					<p>
						This request has already been submitted. Contact your Mentor to revise.
					</p>
				</cfif>
			</div>

			<cfif isdefined("session.roles") and session.roles contains "global_admin">
				<div class="infoDiv">
					You have global_admin; you can change the status of this request.
					<ul>
						<li>new: unreviewed request</li>
						<li>submit for review: request is ready for consideration by Arctos staff</li>
						<li>ready to create: request is approved by Arctos staff and ready for DBA action</li>
						<li>created: collection is created and ready for use</li>
					</ul>
					The save and request will fail if mentor_contact does not contain an email address.
					<label for="status">status</label>
						<select name="status" id="status" class="reqdClr" required >
							<option <cfif d.status is "new">selected="selected" </cfif>value="new">new</option>
							<option <cfif d.status is "submit for review">selected="selected" </cfif>value="submit for review">submit for review</option>
							<option <cfif d.status is "ready to create">selected="selected" </cfif>value="ready to create">ready to create</option>
							<option <cfif d.status is "created">selected="selected" </cfif>value="created">created</option>
					</select>
				</div>
			</cfif>
			<br><input type="submit" class="savBtn" value="save changes">
		</form>

	</cfoutput>
</cfif>
<cfif action is "saveEdits">
	<cfoutput>
		<cfif not isdefined("session.roles") or session.roles does not contain "global_admin">
			<cfif old_status is not "new">
				You may not edit this request.<cfabort>
			</cfif>
		</cfif>
		<!--- pre-check this ---->
		<cfif len(LOAN_POLICY_URL) gt 0 and not isvalid('url',LOAN_POLICY_URL)>
			LOAN_POLICY_URL is not a valid URL. Use your back button.<cfabort>
		</cfif>


		<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_new_collection set
				GUID_PREFIX='#GUID_PREFIX#',
				COLLECTION_CDE='#COLLECTION_CDE#',
				INSTITUTION_ACRONYM='#INSTITUTION_ACRONYM#',
				DESCR='#escapeQuotes(DESCR)#',
				COLLECTION='#COLLECTION#',
				LOAN_POLICY_URL='#LOAN_POLICY_URL#',
				INSTITUTION='#INSTITUTION#',
				PREFERRED_TAXONOMY_SOURCE='#PREFERRED_TAXONOMY_SOURCE#',
				CATALOG_NUMBER_FORMAT='#CATALOG_NUMBER_FORMAT#',
				USE_LICENSE_ID=<cfif len(USE_LICENSE_ID) gt 0>#USE_LICENSE_ID#<cfelse>null</cfif>,
				WEB_LINK='#WEB_LINK#',
				WEB_LINK_TEXT='#WEB_LINK_TEXT#',
				mentor='#mentor#',
				mentor_contact='#mentor_contact#',
				contact_email='#contact_email#',
				admin_username='#admin_username#',
				final_message='#escapeQuotes(final_message)#'
				<cfif isdefined("sfs") and sfs is "yes_plz">
					,status='submit for review'
				</cfif>
			where
				ncid=#ncid#
		</cfquery>

		<cfif isdefined("sfs") and sfs is "yes_plz">
			<cfif len(mentor_contact) is 0 or len(contact_email) is 0>
				Mentor contact email and contact_email is required for this operation. Use your back button to fix.<cfabort>
			</cfif>
			<cfloop list="#mentor_contact#" delimiters="," index="i">
				<cfif not isValid('email',i)>
					Mentor contact email #i# is not valid. Use your back button to fix.<cfabort>
				</cfif>
			</cfloop>
			<cfloop list="#contact_email#" delimiters="," index="i">
				<cfif not isValid('email',i)>
					Contact email #i# is not valid.. Use your back button to fix.<cfabort>
				</cfif>
			</cfloop>
			<cfmail to="#mentor_contact#, #contact_email#, arctos.database@gmail.com, lkv@berkeley.edu" subject="collection creation request" from="newcollection@#Application.fromEmail#" type="html">
				<p>
					New Collection Request
				</p>
				<p>
					A user has finalized a collection creation request. Confirm that the data in the link below are accurate and that
					administrative needs have been met before proceeding.
				</p>
				<p>
					Make sure to change the status (from the link below) after taking action.
				</p>
				<p>
					Message from requestor: #final_message#
				</p>
				<p>
					LINK: #application.serverRootURL#/new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(user_pwd)#&GUID_PREFIX=#GUID_PREFIX#
				</p>
				<p>
					SQL: select * from pre_new_collection where ncid=#ncid#
				</p>
			</cfmail>

			Your request has been submitted.

			<a href="new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(user_pwd)#&GUID_PREFIX=#GUID_PREFIX#">continue editing</a>
			<cfabort>
		</cfif>

		<cflocation url="new_collection.cfm?action=mgCollectionRequest&pwhash=#hash(user_pwd)#&GUID_PREFIX=#GUID_PREFIX#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
