<cfinclude template="/includes/_header.cfm">
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

	<cfset bucket="testing.mctesty/mai_bukkit">
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
	<cfset bucket="">

	<cfset stringToSignParts = [
	    "GET",
	    "",
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

	<cfhttp method="GET" url="#d.s3_endpoint#/#bucket#" charset="utf-8">
		<cfhttpparam type="header" name="Authorization" value="AWS #d.s3_accesskey#:#signature#">
	    <cfhttpparam type="header" name="Date" value="#currentTime#">
	</cfhttp>

<cfdump var=#cfhttp#>
</cfif>





<cfif action is "makebucket">
	<cfset currentTime = getHttpTimeString( now() ) />

	<cfset contentType = "text/html" />
	<cfset bucket="maitoplevelbucket/maisecondlevelbucket">

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