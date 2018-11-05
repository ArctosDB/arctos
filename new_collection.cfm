<cfinclude template="/includes/_header.cfm">
<cfset title="Prospective Collection Form">
<script>
	jQuery(document).ready(function() {
		$(':input[required]:visible').each(function(e){
		    $(this).addClass('reqdClr');
		});
	});
</script>


<!--- this should probably be a global setting; hard-code for now --->
<cfset mailtol="ccicero@berkeley.edu,campbell@carachupa.org,jegelewicz66@gmail.com,dustymc@gmail.com,lkv@berkeley.edu">


<cfif not isdefined("session.roles") or session.roles does not contain "global_admin">
	<!--- some sections of this form are public; others are restricted ---->
	<cfif
		action is not "pre_create_new_collection" and
		action is not "edit_collection" and
		action is not "manage" and
		action is not "createInstitutionRequest" and
		action is not "nothing" >
		denied<cfabort>
	</cfif>
</cfif>


<cfif len(session.username) is 0>
	You must log in to access the Prospective Collection Form. You may log in above, or create an account here.

	<p>
		Usernames cannot have a period (e.g., carla.cicero is not acceptable).
		Passwords should be at least 8 characters and contain a combination of letters, numbers,
		and at least one symbol (e.g., $ @ !).
	</p>
	<p>
		Accounts not following these rules may not be made into Operators, but you may access the Prospective Collection Form
		with any account.
	</p>
	<p>
		<form name="logIn" method="post" action="/login.cfm">
				<input type="hidden" name="action" value="newUser">
				<input type="hidden" name="gotopage" value="new_collection.cfm">
				<label for="username">Username</label>
				<input type="text" name="username" title="username" size="12" class="loginTxt" placeholder="username" required>
				<label for="Password">Password</label>
				<input type="password" name="password" title="password" placeholder="password" size="12" class="loginTxt" required>
				<br>
				<input type="submit" value="Create Account" class="smallBtn" >
			</form>
	</p>
	<cfabort>
</cfif>
<cfif isdefined("session.roles") and session.roles contains "global_admin">
	<a href="/new_collection.cfm?action=showAllRequests">Show All Requests</a>
</cfif>

<style>
	.infoDiv{
		border:2px solid green;
		font-size:smaller;
		padding:.5em;
		margin:1em;
		background-color:#e3ede5;
	}
	.editColn {
		margin:1em;
		padding:1em;
		border:1px solid green;
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


	alter table pre_new_institution  add institutional_mentor VARCHAR2(255);
	alter table pre_new_institution  add institutional_mentor_email VARCHAR2(255);

	create or replace public synonym pre_new_institution for pre_new_institution;
	grant select, insert, update on pre_new_institution to public;

	create unique index ix_u_pni_instacr_u on pre_new_institution(upper(INSTITUTION_ACRONYM)) tablespace uam_idx_1;


create table temp_old_pre_new_collection as select * from pre_new_collection;




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


<!------------------------------------------------------>
<cfif action is "setColnStatus">
	<cfoutput>
		<cfif old_status is status>
			No changes - request denied<cfabort>
		<cfelseif status is "denied">
			Are you sure you want to set status to DENIED? This can be un-done only by a DBA with the authorization of the Arctos Working Group.
			<p>
				<a href="/new_collection.cfm?action=setColnStatus&scnrm=true&old_status=#old_status#&status=#status#&niid=#niid#">continue to set status</a>
			</p>
			<cfabort>
		<cfelseif old_status is "new" and status is not "administrative_approval_granted">
			Out of order - request denied<cfabort>
		<cfelseif old_status is "administrative_approval_granted" and status is not "approve_to_create_collections">
			Out of order - request denied<cfabort>
		<cfelseif old_status is "approve_to_create_collections" and status is not "complete">
			Out of order - request denied<cfabort>

		<cfelseif status is "administrative_approval_granted">
		<p> status is "administrative_approval_granted"</p>
			<cfif len(institutional_mentor) is 0 or len(institutional_mentor_email) is 0>
				institutional_mentor and institutional_mentor_email are required for status=administrative_approval_granted
				<cfabort>
			</cfif>
			<cfset scnrm="true">
		<cfelseif  status is "approve_to_create_collections">
			<cfquery name="cs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from pre_new_collection where niid=#niid#
			</cfquery>
			<cfif cs.recordcount is 0>
				Denied: no collections.<cfabort>
			</cfif>
			<cfset probs="">
			<cfloop query="cs">
				<cfif
					len(COLLECTION_CDE) is 0 or
					len(DESCR) is 0 or
					len(COLLECTION) is 0 or
					len(LOAN_POLICY_URL) is 0 or
					len(GUID_PREFIX) is 0 or
					len(PREFERRED_TAXONOMY_SOURCE) is 0 or
					len(CATALOG_NUMBER_FORMAT) is 0 or
					len(mentor) is 0 or
					len(mentor_contact) is 0 or
					len(admin_username) is 0 or
					len(use_license_id) is 0 or
					len(contact_email) is 0>
					Denied: Required values are missing for #guid_prefix#

					<p>
						Required:
						<ul>
							<li>COLLECTION_CDE</li>
							<li>DESCR</li>
							<li>COLLECTION</li>
							<li>LOAN_POLICY_URL</li>
							<li>GUID_PREFIX</li>
							<li>PREFERRED_TAXONOMY_SOURCE</li>
							<li>CATALOG_NUMBER_FORMAT</li>
							<li>mentor</li>
							<li>mentor_contact</li>
							<li>admin_username</li>
							<li>use_license_id</li>
							<li>contact_email</li>
						</ul>
					</p>
					<cfabort>
				</cfif>
			</cfloop>
			<cfif len(probs) eq 0>
				<cfset scnrm="true">
			</cfif>
		<cfelse>
			<cfset scnrm="true">
			<br>happy>
		</cfif>
		<cfif isdefined("scnrm") and scnrm is "true">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update pre_new_institution set status='#status#'
				<cfif isdefined("institutional_mentor") and len(institutional_mentor)  gt 0>
					,institutional_mentor='#institutional_mentor#'
				</cfif>
				<cfif isdefined("institutional_mentor_email") and len(institutional_mentor_email)  gt 0>
					,institutional_mentor_email='#institutional_mentor_email#'
				</cfif>
				 where niid ='#niid#'
			</cfquery>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select institution from pre_new_institution  where niid ='#niid#'
			</cfquery>
			<cfmail to="#mailtol#" subject="Arctos Join Request: Status Update" from="joinrequest@#Application.fromEmail#" cc="arctos.database@gmail.com" type="html">
				Status has changed to #status# for pending institution #q.institution#
			</cfmail>
			<cflocation addtoken="false" url="/new_collection.cfm?action=manage&id=#hash(niid)#">
		</cfif>
	</cfoutput>
</cfif>
<!-------------------------------------->
<cfif action is "showAllRequests">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				pre_new_institution.niid,
				pre_new_institution.INSTITUTION,
				pre_new_institution.status istatus,
				pre_new_institution.insert_date,
				pre_new_institution.initiated_by_username,
				pre_new_collection.GUID_PREFIX
			from
				pre_new_institution,
				pre_new_collection
			where
				pre_new_institution.niid=pre_new_collection.niid (+)
			order by
				pre_new_institution.status,
				pre_new_institution.insert_date
		</cfquery>

		<style>
			.sComp{
				font-size:x-small;
				background-color:gray'
			}
			.sRCC{
				font-weight:bold;
			}
		</style>
		<table border>
			<tr>
				<th>INSTITUTION</th>
				<th>Status</th>
				<th>InitDate</th>
				<th>InitBy</th>
				<th>Collection</th>
				<th>Manage</th>
			</tr>
			<cfloop query="d">
				<cfif istatus is "complete">
					<cfset tc='sComp'>
				<cfelseif istatus is "approve_to_create_collections">
					<cfset tc='sRCC'>
				<cfelse>
					<cfset tc="">
				</cfif>
				<tr class="#tc#">
					<td>#INSTITUTION#</td>
					<td>#istatus#</td>
					<td>#insert_date#</td>
					<td>#initiated_by_username#</td>
					<td>#GUID_PREFIX#</td>
					<td>
						<a href="/new_collection.cfm?action=manage&id=#hash(niid)#">Manage</a>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------>
<cfif action is "pre_create_new_collection">
	<cfoutput>
		<cfquery name="mkr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into pre_new_collection (
				niid,
				ncid,
				GUID_PREFIX,
				status,
				insert_date,
				initiated_by_username
			) values (
				#niid#,
				someRandomSequence.nextval,
				'#guid_prefix#',
				'new',
				sysdate,
				'#session.username#'
			)
		</cfquery>

		<p>
			Success!
		</p>
		<p>
			You now must work with the collection to provide collection metadata.
		</p>
		<p>
			<a href="/new_collection.cfm?action=manage&id=#hash(niid)#">Click here to pre-create another collection</a>
		</p>
		<p>
			<a href="/new_collection.cfm?action=manage&id=#hash(niid)####guid_prefix#">Click here to edit this collection</a>
		</p>
		<p>
			Scroll to the bottom of the manage form for collections. The link to this collection is
			<p>
				<code>
					#application.serverRootURL#/new_collection.cfm?action=manage&id=#hash(niid)####guid_prefix#
				</code>
			</p>
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------>
<cfif action is "edit_collection">
	<cfoutput>
		<cfif status is not "approved_to_create_collections">
			Changes are not allowed with the current status.
		</cfif>
		<!--- pre-check this ---->
		<cfif len(LOAN_POLICY_URL) gt 0 and not isvalid('url',LOAN_POLICY_URL)>
			LOAN_POLICY_URL is not a valid URL. Use your back button.<cfabort>
		</cfif>
		<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_new_collection set
				GUID_PREFIX='#GUID_PREFIX#',
				COLLECTION_CDE='#COLLECTION_CDE#',
				DESCR='#escapeQuotes(DESCR)#',
				COLLECTION='#COLLECTION#',
				LOAN_POLICY_URL='#LOAN_POLICY_URL#',
				PREFERRED_TAXONOMY_SOURCE='#PREFERRED_TAXONOMY_SOURCE#',
				CATALOG_NUMBER_FORMAT='#CATALOG_NUMBER_FORMAT#',
				USE_LICENSE_ID=<cfif len(USE_LICENSE_ID) gt 0>#USE_LICENSE_ID#<cfelse>null</cfif>,
				WEB_LINK='#WEB_LINK#',
				WEB_LINK_TEXT='#WEB_LINK_TEXT#',
				mentor='#mentor#',
				mentor_contact='#mentor_contact#',
				contact_email='#contact_email#',
				admin_username='#admin_username#'
			where
				ncid=#ncid#
		</cfquery>
		<cflocation addtoken="false" url="/new_collection.cfm?action=manage&id=#hash(niid)####guid_prefix#">
	</cfoutput>
</cfif>
<!------------------------------------------------------>
<cfif action is "manage">
	<style>
		.qtn{font-weight:bold}
		.asr{margin-left:1em;font-style: italic;}
	</style>
	<cfoutput>
   		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from pre_new_institution where dbms_obfuscation_toolkit.md5(input => UTL_RAW.cast_to_raw(niid)) ='#id#'
		</cfquery>

		<div class="r">
			<div class="qtn">Questionnaire completed by</div>
			<div class="asr">#d.completed_by#</div>
		</div>
		<div class="r">
			<div class="qtn">Arctos Username</div>
			<div class="asr">#d.initiated_by_username#</div>
		</div>
		<div class="r">
			<div class="qtn">Job Title</div>
			<div class="asr">#d.completed_by_title#</div>
		</div>
		<div class="r">
			<div class="qtn">Email</div>
			<div class="asr">#d.completed_by_email#</div>
		</div>
		<div class="r">
			<div class="qtn">Phone</div>
			<div class="asr">#d.completed_by_phone#</div>
		</div>
		<div class="r">
			<div class="qtn">Status</div>
			<div class="asr">#d.status#</div>
		</div>

		<cfif isdefined("session.roles") and session.roles contains "global_admin">
			<div class="infoDiv">
				You have global_admin; you can change the status of this request.
				<p>
					Documentation is
					<a href="http://handbook.arctosdb.org/how_to/new-collection.html" target="_blank" class="external">
						http://handbook.arctosdb.org/how_to/new-collection.html
					</a>
				</p>

				<ul>
					<li>new: new request, neeeds administrative approval</li>
					<li>
						administrative_approval_granted: Administrative approval granted, the organization has at least one Mentor.
						When this is set you will get a new option below. Read is CAREFULLY before proceeding.
					</li>
					<li>
						approve_to_create_collections: ALL Collections have been pre-created and should be created as VPDs.
						Changing this sends DBA email.
					</li>
					<li>
						complete: Collections have been created, Arctos is ready to accept data, these data/this form is no longer useful.
						This should be set only by the person creating the collections.
					</li>
					<li>
						denied: Administrative approval has not been granted and will not be at this time.
					</li>
				</ul>
				<form name="fs" method="post" action="new_collection.cfm">
					<input type="hidden" name="action" value="setColnStatus">
					<input type="hidden" name="niid" value="#d.niid#">
					<input type="hidden" name="old_status" value="#d.status#">
					<label for="status">update status to</label>
					<select name="status" id="status" >
						<option <cfif d.status is "new">selected="selected" </cfif>value="new">new</option>
						<option <cfif d.status is "administrative_approval_granted">selected="selected" </cfif>value="administrative_approval_granted">administrative_approval_granted</option>
						<option <cfif d.status is "approve_to_create_collections">selected="selected" </cfif>value="approve_to_create_collections">approve_to_create_collections</option>
						<option <cfif d.status is "complete">selected="selected" </cfif>value="complete">complete</option>
						<option <cfif d.status is "denied">selected="selected" </cfif>value="denied">denied</option>
					</select>

					<p>
						You must assign an institutional_mentor and accompanying email address before changing status to "Administrative approval granted"
					</p>
					<label for ="institutional_mentor">institutional_mentor (Arctos username is OK; comma-list is OK)</label>
					<input type="text" size="80" name="institutional_mentor" value="#d.institutional_mentor#" required>
					<label for ="institutional_mentor_email">institutional_mentor_email (comma-list is OK)</label>
					<input type="text" size="80" name="institutional_mentor_email" value="#d.institutional_mentor_email#" required>
					<input type="submit" value="change status">
				</form>
			</div>
			<cfif d.status is "administrative_approval_granted">
				<div class="infoDiv">
					This institution is set to administrative_approval_granted so you can use this form to pre-pre-create collections.
					Work with the collection to FIRMLY establish GUID_PREFIX
					before pre-pre-creating collections.
					GUID_PREFIX is traditionally institution_acronym + ":" + collection_cde, but this is not necassary.
					There may be several collections in "Inst" which use "Herb" (=plants) collection code, for example.
					Collection_Cde (controls code table access) will be set in the next step.
					GUID_PREFIX __must__ contain a string, a colon, then another string, or the final request will fail.
					GUID_PREFIX __must__ be unique within Arctos, and GUID_PREFIX _should_ be unique within GRBIO/GBIF/etc.
					The maximum length is 20 characters. Examples:

					<ul>
						<li>MSB:Mamm</li>
						<li>UAM:Herb</li>
						<li>UAM:Crypto</li>
						<li>UAM:Alg</li>
						<li>UNM:ES</li>
					</ul>
					<form name="f" method="post" action="new_collection.cfm">
						<input type="hidden" name="action" value="pre_create_new_collection">
						<input type="hidden" name="niid" value="#d.niid#">

						<label for="guid_prefix">guid_prefix</label>
						<input type="text" name="guid_prefix" id="guid_prefix" class="reqdClr" required>
						<input type="submit" class="insBtn" value="pre-pre-create collection">
					</form>
				</div>
			</cfif>
		</cfif>

		<div class="r">
			<div class="qtn">Link</div>
			<div class="asr">#application.serverRootURL#/new_collection.cfm?action=manage&id=#hash(d.niid)#</div>
		</div>
		<div class="r">
			<div class="qtn">Institution Acronym</div>
			<div class="asr">#d.INSTITUTION_ACRONYM#</div>
		</div>
		<div class="r">
			<div class="qtn">Institution</div>
			<div class="asr">#d.INSTITUTION#</div>
		</div>
		<div class="r">
			<div class="qtn">How many total specimens across all collection(s) are you interested in migrating to Arctos?</div>
			<div class="asr">#d.ttl_spc_cnt#</div>
		</div>
		<div class="r">
			<div class="qtn">Are the data for all of those specimens in digital format?</div>
			<div class="asr">#d.are_all_digitized#</div>
		</div>
		<div class="r">
			<div class="qtn">Which of the following specimen types are you interested in migrating to Arctos (check all that apply)?</div>
			<div class="asr">#d.specimen_types#</div>
		</div>
		<div class="r">
			<div class="qtn">On average, how many specimens have been added to the collection(s) annually over the past 5 years?</div>
			<div class="asr">#d.yearly_add_avg#</div>
		</div>
		<div class="r">
			<div class="qtn">How do you expect this rate of growth to change in the foreseeable future?</div>
			<div class="asr">#d.exp_grth_rate#</div>
		</div>
		<div class="r">
			<div class="qtn">What software do you currently use to manage specimen data (e.g., e.g., Access, Filemaker Pro, Excel, Specify-indicate which version, etc.)?</div>
			<div class="asr">#d.current_software#</div>
		</div>
		<div class="r">
			<div class="qtn">How are your data structured in your current information system (flat table, related tables, disjoined tables, etc.)?</div>
			<div class="asr">#d.current_structure#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you use controlled vocabularies or authority files for the following kinds of data (check all that apply)?</div>
			<div class="asr">#d.vocab_control#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you allow free text data entry for the following kinds of data (check all that apply)?</div>
			<div class="asr">#d.free_text#</div>
		</div>
		<div class="r">
			<div class="qtn">Is it possible to bypass the controlled vocabularies or authority files? Explain</div>
			<div class="asr">#d.vocab_enforcement#</div>
		</div>
		<div class="r">
			<div class="qtn">Please expand on how you deal with agents, taxonomy, geography, and/or specimen parts.</div>
			<div class="asr">#d.vocab_text#</div>
		</div>
		<div class="r">
			<div class="qtn">How do you deal with tissues in your collection?</div>
			<div class="asr">#d.tissues#</div>
		</div>
		<div class="r">
			<div class="qtn">Describe any other details about how you deal with tissues currently, or plan to deal with them in the future.</div>
			<div class="asr">#d.tissue_detail#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you use machine-readable labels (such as barcodes) to digitally track any objects in your collections?</div>
			<div class="asr">#d.barcodes#</div>
		</div>
		<div class="r">
			<div class="qtn">Describe any details about you incorporate barcodes into your current system, or whether you plan to deal with them in the future.</div>
			<div class="asr">#d.barcode_desc#</div>
		</div>
		<div class="r">
			<div class="qtn">Describe how you deal with locality information (including coordinates, if any) in your current collection management system.</div>
			<div class="asr">#d.locality#</div>
		</div>
		<div class="r">
			<div class="qtn">Approximately what proportion of your locality data are georeferenced with latitude/longitude coordinates?</div>
			<div class="asr">#d.georefedpercent#</div>
		</div>
		<div class="r">
			<div class="qtn">Describe the kinds of metadata that you store with your coordinate information (e.g., datum, GPS error, extent, maximum uncertainty, georeferencing method, etc.)</div>
			<div class="asr">#d.metadata#</div>
		</div>
		<div class="r">
			<div class="qtn">For the following transaction types, indicate whether you have digital information that would need to be formatted and imported? (check all that apply)</div>
			<div class="asr">#d.digital_trans#</div>
		</div>
		<div class="r">
			<div class="qtn">Describe generally how you deal with transactions (loans, accessions, permits) in your current system.</div>
			<div class="asr">#d.trans_desc#</div>
		</div>
		<div class="r">
			<div class="qtn">Other than basic “label data” (who/what/when/where), what other kinds of information (if any) is recorded about your specimens (e.g., citations in publications, GenBank numbers, projects, etc.)?</div>
			<div class="asr">#d.more_data#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you have digital media in your current system?</div>
			<div class="asr">#d.digital_media#</div>
		</div>
		<div class="r">
			<div class="qtn">Indicate how you plan to store digital media that are linked to data in Arctos.</div>
			<div class="asr">#d.media_plan#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you have someone familiar with the collection who can assist in migrating data to Arctos?</div>
			<div class="asr">#d.has_help#</div>
		</div>
		<!----
		<div class="r">
			<div class="qtn">Do you want to use Arctos Media storage?</div>
			<div class="asr">#d.want_storage#</div>
		</div>
		---->
		<div class="r">
			<div class="qtn">Please describe any permission or security issues that would prevent us from accessing your data directly if necessary for data migration?</div>
			<div class="asr">#d.security_concern#</div>
		</div>
		<div class="r">
			<div class="qtn">Do you have an annual budget available for database support?</div>
			<div class="asr">#d.budget#</div>
		</div>
		<div class="r">
			<div class="qtn">Please add any other comments or questions that you have re: Arctos or your collection(s).</div>
			<div class="asr">#d.comments#</div>
		</div>

		<cfif d.status is "administrative_approval_granted" or  d.status is "approve_to_create_collections">
			<cfquery name="CTMEDIA_LICENSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select MEDIA_LICENSE_ID,DISPLAY from CTMEDIA_LICENSE order by DISPLAY
			</cfquery>

			<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select source from cttaxonomy_source group by source order by source
			</cfquery>
			<cfquery name="ctcollection_cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select collection_cde from ctcollection_cde  order by collection_cde
			</cfquery>
			<div class="infoDiv">
				Use this form to pre-create collections. This should be done by the person who will manage the collection and their assigned Mentor.
			</div>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from pre_new_collection where niid=#d.niid#
			</cfquery>

			<cfloop query="c">
				<div class="editColn">

				<h3>Editing #c.guid_prefix#</h3>
				<p>
					<a name="#c.guid_prefix#"></a>
				</p>
				<form name="f" method="post" action="new_collection.cfm">
					<input type="hidden" name="action" value="edit_collection">
					<input type="hidden" name="niid" value="#d.niid#">
					<input type="hidden" name="ncid" value="#c.ncid#">
					<input type="hidden" name="status" value="#d.status#">
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
						<input type="text" name="GUID_PREFIX" id="GUID_PREFIX" class="reqdClr" required value="#c.GUID_PREFIX#">
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
						<input type="text" name="COLLECTION" id="COLLECTION" class="reqdClr" required value="#c.COLLECTION#" size="80">
					</div>
					<div class="infoDiv">
						Collection Code controls which code tables your collection will use.
						<ul>
							<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##collection-code">Documentation</a></li>
							<li><a target="_blank" class="external" href="http://arctos.database.museum/info/ctDocumentation.cfm?table=CTCOLLECTION_CDE">Code Table</a></li>
						</ul>

						<label for="COLLECTION_CDE">Collection Code</label>
						<select name="COLLECTION_CDE" id="COLLECTION_CDE" class="reqdClr" required>
							<option value=""></option>
							<cfloop query="ctcollection_cde">
								<option	<cfif c.collection_cde is ctcollection_cde.collection_cde> selected="selected" </cfif>
									value="#collection_cde#">#collection_cde#</option>
							</cfloop>
						</select>
					</div>
					<div class="infoDiv">
						Description of the collection. Maximum length is 4000 characters.
						<ul>
							<li><a target="_blank" class="external" href="http://handbook.arctosdb.org/documentation/catalog.html##description">Documentation</a></li>
						</ul>

						<label for="DESCR">Description</label>
						<textarea class="hugetextarea reqdClr" name="DESCR" id="DESCR" required >#c.DESCR#</textarea>
					</div>
					<div class="infoDiv">
						URL to more information, such as the collection's home page.
						<label for="WEB_LINK">Web Link</label>
						<input type="text" name="WEB_LINK" id="WEB_LINK"  value="#c.WEB_LINK#" size="80">
					</div>
					<div class="infoDiv">
						Clickable text to display with web link.
						<label for="WEB_LINK_TEXT">Web Link Text</label>
						<input type="text" name="WEB_LINK_TEXT" id="WEB_LINK_TEXT" value="#c.WEB_LINK_TEXT#" size="80">
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
								<option	<cfif c.use_license_id is MEDIA_LICENSE_ID> selected="selected" </cfif>
									value="#MEDIA_LICENSE_ID#">#DISPLAY#</option>
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
							<option <cfif c.catalog_number_format is "integer">selected="selected" </cfif>value="integer">integer</option>
							<option <cfif c.catalog_number_format is "prefix-integer-suffix">selected="selected" </cfif>value="prefix-integer-suffix">prefix-integer-suffix</option>
							<option <cfif c.catalog_number_format is "string">selected="selected" </cfif>value="string">string</option>
						</select>
					</div>
					<div class="infoDiv">
						URL to collection's loan policy. A loan policy is required; the contents of the loan policy are entirely up to the data owners.
						File an Issue for assistance in creating or hosting a loan policy.

						<label for="LOAN_POLICY_URL">Loan Policy URL</label>
						<input type="text" name="LOAN_POLICY_URL" id="LOAN_POLICY_URL" class="reqdClr" required value="#c.LOAN_POLICY_URL#" size="80">
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
								<option	<cfif c.preferred_taxonomy_source is cttaxonomy_source.source> selected="selected" </cfif>
									value="#source#">#source#</option>
							</cfloop>
						</select>
					</div>
					<div class="infoDiv">
						Person(s) who will work with the collection during import and initial use.
						<label for="mentor">mentor (Arctos username preferred; comma-list OK)</label>
						<input type="text" name="mentor" id="mentor"  value="#c.mentor#" size="80">
					</div>
					<div class="infoDiv">
						Mentor's email; how can we contact the Mentor?
						<label for="mentor_contact">mentor_contact (email; comma-list OK)</label>
						<input type="text" name="mentor_contact" id="mentor_contact" value="#c.mentor_contact#" size="80">
					</div>
					<div class="infoDiv">
						Arctos username(s) who will receive initial manage_collection access. Comma-separated list OK. These Operators can
						create and manage other collection users. Anyone listed here should already have an Arctos account arranged by the Mentor.

						<ul>
							<li><span class="helpLink" data-helplink="users">User Documentation</span></li>
							<li><span class="helpLink" data-helplink="create_team">Team Documentation</span></li>
						</ul>
						<label for="admin_username">admin_username</label>
						<input type="text" name="admin_username" id="admin_username"  value="#c.admin_username#" size="80">
					</div>

					<div class="infoDiv">
						Primary email contact for collection personell. Comma-list is OK.
						<label for="contact_email">contact_email</label>
						<input type="text" name="contact_email" id="contact_email" value="#c.contact_email#" size="80">
					</div>
					<br><input type="submit" class="lnkBtn" value="Update Collection Request for #c.guid_prefix#">
				</form>
				</div>
			</cfloop>
		</cfif>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
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
				<!----
				want_storage,
				---->
				has_help,
				security_concern,
				budget,
				comments,
				completed_by,
				completed_by_email,
				completed_by_phone,
				completed_by_title,
				status,
				insert_date,
				initiated_by_username
			) values (
				#srs.nid#,
				'#escapeQuotes(INSTITUTION)#',
				'#escapeQuotes(INSTITUTION_ACRONYM)#',
				'#escapeQuotes(ttl_spc_cnt)#',
				'#escapeQuotes(are_all_digitized)#',
				<cfif isdefined("specimen_types") and len(specimen_types) gt 0>
					'#escapeQuotes(specimen_types)#',
				<cfelse>
					'none',
				</cfif>
				'#escapeQuotes(yearly_add_avg)#',
				'#escapeQuotes(exp_grth_rate)#',
				'#escapeQuotes(current_software)#',
				'#escapeQuotes(current_structure)#',
				<cfif isdefined("vocab_control") and len(vocab_control) gt 0>
					'#escapeQuotes(vocab_control)#',
				<cfelse>
					'none',
				</cfif>
				<cfif isdefined("free_text") and len(free_text) gt 0>
					'#escapeQuotes(free_text)#',
				<cfelse>
					'none',
				</cfif>
				'#escapeQuotes(vocab_enforcement)#',
				'#escapeQuotes(vocab_text)#',
				<cfif isdefined("tissues") and len(tissues) gt 0>
					'#escapeQuotes(tissues)#',
				<cfelse>
					'none',
				</cfif>
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
				<cfif isdefined("media_plan") and len(media_plan) gt 0>
					'#escapeQuotes(media_plan)#',
				<cfelse>
					'none',
				</cfif>
				<!----
				'#escapeQuotes(want_storage)#',
				----->
				'#escapeQuotes(has_help)#',
				'#escapeQuotes(security_concern)#',
				'#escapeQuotes(budget)#',
				'#escapeQuotes(comments)#',
				'#escapeQuotes(completed_by)#',
				'#escapeQuotes(completed_by_email)#',
				'#escapeQuotes(completed_by_phone)#',
				'#escapeQuotes(completed_by_title)#',
				'new',
				sysdate,
				'#session.username#'
			)
		</cfquery>
		<cfmail to="#mailtol#" subject="Arctos Join Request" from="joinrequest@#Application.fromEmail#" cc="arctos.database@gmail.com" type="html">
			<p>
				New Collection Request
			</p>
			<p>
				A user has submitted the initial collection creation form. The submission is available at
 				<a href="#application.serverRootURL#/new_collection.cfm?action=manage&id=#hash(srs.nid)#">
					#application.serverRootURL#/new_collection.cfm?action=manage&id=#hash(srs.nid)#
				</a>
			</p>
			<p>
				See http://handbook.arctosdb.org/how_to/new-collection.html for guidance and next steps.
			</p>
			<p>
				SQL: select * from pre_new_institution where niid=#srs.nid#
			</p>
		</cfmail>
		<p>
			Success!
		</p>
		<p>
			A request has been created and the Arctos community will be alerted to this request.
		</p>
		<p>
			Please use the contact link at the bottom of any Arctos page if you wish to revise the submission, or if you have not
			been contacted within 10 working days. Please include the institution acronym you provided in any correspondence.
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------->
<cfif action is "nothing">
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
		Do NOT provide any sensitive information anywhere in this form.
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
				<label for="tissues">How do you deal with tissues in your collection?</label>
				<cfset l= "Tissues are treated as parts of a specimen using a controlled vocabulary or authority file.|Tissues are treated as parts of a specimen, entered in free-form text.|Tissues are cataloged in a separate collection, and cross-linked to voucher specimen.|Tissues are entered as free-form text in a remarks or comment field.|There are no tissues in our collection.|Other.">
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
				<label for="georefedpercent">Approximately what proportion of your locality data are georeferenced with latitude/longitude coordinates?</label>
				<input type="text" name="georefedpercent" id="georefedpercent" class="reqdClr" required  size="80">
			</div>
			<div class="infoDiv">
				<label for="metadata">Describe the kinds of metadata that you store with your coordinate information (e.g., datum, GPS error, extent, maximum uncertainty, georeferencing method, etc.)</label>
				<textarea class="hugetextarea reqdClr" name="metadata" id="metadata" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="digital_trans">For the following transaction types, indicate whether you have digital information that would need to be formatted and imported? (check all that apply)</label>
				<cfset l= "Loans|Accessions|Permits">
				<cfloop list="#l#" delimiters="|" index="i">
					<input type="checkbox" name="digital_trans" value="#i#">#i#<br>
				</cfloop>
   			</div>


			<div class="infoDiv">
				<label for="trans_desc">Describe generally how you deal with transactions (loans, accessions, permits) in your current system.</label>
				<textarea class="hugetextarea reqdClr" name="trans_desc" id="trans_desc" required ></textarea>
			</div>
			<div class="infoDiv">
				<label for="more_data">Other than basic “label data” (who/what/when/where), what other kinds of information (if any) is recorded about your specimens (e.g., citations in publications, GenBank numbers, projects, etc.)?</label>
				<textarea class="hugetextarea reqdClr" name="more_data" id="more_data" required ></textarea>
			</div>

			<div class="infoDiv">
				<label for="digital_media">Do you have digital media in your current system?</label>
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

			<!----
			<div class="infoDiv">
				<label for="want_storage">Do you want to use Arctos Media storage?</label>
				<select name="want_storage" required>
					<option value=""></option>
					<option value="yes" >yes</option>
					<option value="no">no</option>
				</select>
			</div>
			---->
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
				<textarea class="hugetextarea reqdClr" name="comments" id="comments" ></textarea>
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
			<div class="infoDiv">
				<p>
					Please carefully review the above information before submitting. Submitting this form will notify the Arctos Working Group of your request.
				</p>
				<br><input type="submit" class="savBtn" value="Submit Request">
			</div>
		</form>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">