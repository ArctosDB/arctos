<cfinclude template="/includes/_header.cfm">
<cfset title="New Collection Portal">

<!----
	create table pre_new_collection (
		ncid number,
		user_pwd VARCHAR2(255),
		COLLECTION_CDE varchar2(5),
		INSTITUTION_ACRONYM VARCHAR2(20),
		DESCR VARCHAR2(4000),
		COLLECTION VARCHAR2(50),
		WEB_LINK  VARCHAR2(4000),
		WEB_LINK_TEXT  VARCHAR2(50),
		LOAN_POLICY_URL VARCHAR2(255),
		INSTITUTION VARCHAR2(255),
		GUID_PREFIX VARCHAR2(20),
		PREFERRED_TAXONOMY_SOURCE VARCHAR2(255),
		CATALOG_NUMBER_FORMAT  VARCHAR2(21),
		mentor varchar2(4000),
		mentor_contact varchar2(4000),
		admin_username VARCHAR2(255),
		status varchar2(255),
		insert_date date
	);

	create public synonym pre_new_collection for pre_new_collection;

	grant select, insert, update on pre_new_collection to public;
---->
<cfif action is "default">
	denied<cfabort>
</cfif>
<cfif action is "nothing">

	<cfif isdefined("session.roles") and session.roles contains "global_admin">
		you are admin
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from pre_new_collection order by insert_date
		</cfquery>
		<cfdump var=#d#>
	<cfelse>
		<cfif len(session.username) is 0>
			You must log in to use this form.
			<cfabort>
		</cfif>
		<p>
			This form facilitates new collection creation in Arctos. This is a request only; you cannot create a collection with this form.
		</p>
		<p>
			If you do not yet have a Mentor, you should <a href="/info/mentor.cfm">choose one</a> before proceeding.
		</p>
		<h2>Request a new collection</h2>
		If this is a new request, first
		<a href="http://handbook.arctosdb.org/documentation/catalog.html#guid-prefix">CAREFULLY review the GUID_prefix documentation</a>,
		enter your desired guid_prefix and a temporary password in the form below, and click "create collection request."
		This password is NOT secure and comes with no restrictions. DO NOT re-use your to any site, including Arctos.
		This prevents public browsing of the data you'll enter in the next step, but is no guarantee of security. Do not provide any
		confidential information in this form. Discuss any concerns with your Mentor.

		<h2>Mange an existing request</h2>
		If you have created a request, fill in the form with the password and GUID_Prefix you used in the initial request and click
		"manage existing request."
		<p>


		<form name="f" method="post" action="new_collection.cfm">
			<input type="hidden" name="action" value="default">
			<label for="guid_prefix">GUID Prefix</label>
			<input type="text" name="guid_prefix" id="guid_prefix" class="reqdClr" required>
			<label for="pwd">Password</label>
			<input type="text" name="pwd" id="pwd" class="reqdClr" required>
			<input type="button" class="insBtn" onclick="f.action.value='newCollectionRequest';f.submit;" value="create collection request">
			<input type="button" class="lnkBtn" onclick="f.action.value='mgCollectionRequest';f.submit;" value="manage existing request">
		</form>
	</cfif>
</cfif>
<cfif action is "newCollectionRequest">

newCollectionRequest
</cfif>

<cfif action is "mgCollectionRequest">

mgCollectionRequest
</cfif>

.0.1.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

UAM@ARCTOS> desc collection
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTION_CDE 						   NOT NULL VARCHAR2(5)
 INSTITUTION_ACRONYM							    VARCHAR2(20)
 DESCR									    VARCHAR2(4000)
 COLLECTION							   NOT NULL VARCHAR2(50)
 COLLECTION_ID							   NOT NULL NUMBER
 WEB_LINK								    VARCHAR2(4000)
 WEB_LINK_TEXT								    VARCHAR2(50)
 GENBANK_PRID								    NUMBER
 GENBANK_USERNAME							    VARCHAR2(20)
 GENBANK_PWD								    VARCHAR2(20)
 LOAN_POLICY_URL						   NOT NULL VARCHAR2(255)
 INSTITUTION								    VARCHAR2(255)
 GUID_PREFIX							   NOT NULL VARCHAR2(20)
 USE_LICENSE_ID 							    NUMBER
 CITATION								    VARCHAR2(255)
 PREFERRED_TAXONOMY_SOURCE					   NOT NULL VARCHAR2(255)
 CATALOG_NUMBER_FORMAT						   NOT NULL VARCHAR2(21)





To create collections, we'll need

* COLLECTION_CDE - https://arctos.database.museum/info/ctDocumentation.cfm?table=CTCOLLECTION_CDE



  DESCRIPTION

 COLLECTION

* LOAN_POLICY_URL

 INSTITUTION

* GUID_PREFIX ("UAM:Mamm" or similar)

* PREFERRED_TAXONOMY_SOURCE - https://arctos.database.museum/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE

* CATALOG_NUMBER_FORMAT - http://handbook.arctosdb.org/documentation/catalog.html#catalog

USE_LICENSE_ID - https://arctos.database.museum/info/ctDocumentation.cfm?table=CTMEDIA_LICENSE




