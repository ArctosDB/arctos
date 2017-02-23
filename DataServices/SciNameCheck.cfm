<!----
drop table ds_temp_taxcheck;

create table ds_temp_taxcheck (
	key number not null,
	scientific_name varchar2(255)
	);

	alter table ds_temp_taxcheck add status varchar2(255);

	alter table ds_temp_taxcheck add suggested_sci_name varchar2(255);

	alter table ds_temp_taxcheck add genus varchar2(255);


	alter table ds_temp_taxcheck add species varchar2(255);

	alter table ds_temp_taxcheck add inf_rank varchar2(255);

	alter table ds_temp_taxcheck add subspecies varchar2(255);

create public synonym ds_temp_taxcheck for ds_temp_taxcheck;
grant all on ds_temp_taxcheck to coldfusion_user;
grant select on ds_temp_taxcheck to public;

 CREATE OR REPLACE TRIGGER ds_temp_taxcheck_key
 before insert  ON ds_temp_taxcheck
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err

---->
<cfinclude template="/includes/_header.cfm">

<cfif action is "nothing">
	Load scientific name; get back Arctos matches.
	<br>See <span class="likeLink" onclick="getDocs('bulkloader','taxa')">bulkloader taxonomy documentation</span>
			 for the full scoop on taxonomy.

	<br>This form considers only
	namestrings (that is, taxon_name.scientific_name) so will have a high false failure rate for
	data with complex names (Name sp., etc.)

	<br>

	Returned data will be
		<ul>
			<li>SCIENTIFIC_NAME - the name you loaded.</li>
			<li>STATUS - a possibly-useful indication of what might have happened and how we came up with whatever it is that we're suggesting</li>
			<li>SUGGESTED_SCI_NAME - this is what we think you meant. Replace your SCIENTIFIC_NAME with this and Arctos will probably be happy. You might not be though,
			so make sure you know what you're doing.</li>
			<li>GENUS - if we didn't find a scientific name, we'll try to pull the thing that looks like genus out of your data. This might be handy if you decide
				to bulkload names later on, or it might just be confusing. Delete it if it's not useful to you.
			</li>
			<li>SPECIES - if we didn't find a scientific name, we'll try to pull the thing that looks like specific epithet out of your data. This might be handy if you decide
				to bulkload names later on, or it might just be confusing. Delete it if it's not useful to you.
			</li>
			<li>INF_RANK - if we didn't find a scientific name, we'll try to pull the thing that looks like infraspecific rank out of your data. This might be handy if you decide
				to bulkload names later on, or it might just be confusing. Delete it if it's not useful to you.
			</li>
			<li>SUBSPECIES - if we didn't find a scientific name, we'll try to pull the thing that looks like infraspecific epithet out of your data. This might be handy if you decide
				to bulkload names later on, or it might just be confusing. Delete it if it's not useful to you.
			</li>
		</ul>

	<p></p>
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li style="color:red">scientific_name</li>
	</ul>


	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>

<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_taxcheck
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into ds_temp_taxcheck (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="SciNameCheck.cfm?action=validate" addtoken="false">

<!---
---->
</cfif>
<cfif action is "validate">
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_taxcheck
	</cfquery>
	<cfloop query="r">
		<cfset found=false>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select scientific_name from taxon_name where scientific_name='#scientific_name#'
		</cfquery>
		<cfif d.recordcount is 1>
			<cfset found=true>
			<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ds_temp_taxcheck set suggested_sci_name='#d.scientific_name#',status='is_accepted_name' where key=#key#
			</cfquery>
		</cfif>
		<cfif found is false>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					rel.scientific_name
				from
					taxon_name,
					taxon_relations,
					taxon_name rel
				where
					taxon_name.taxon_name_id=taxon_relations.taxon_name_id and
					taxon_relations.related_taxon_name_id=rel.taxon_name_id and
					taxon_name.scientific_name='#scientific_name#'
			</cfquery>
			<cfif d.recordcount is 1>
				<cfset found=true>
				<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update ds_temp_taxcheck set suggested_sci_name='#d.scientific_name#',status='found_related_accepted_name' where key=#key#
				</cfquery>
			</cfif>
		</cfif>
		<cfif found is false>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					taxon_name.scientific_name
				from
					taxon_name,
					taxon_relations,
					taxon_name rel
				where
					taxon_name.taxon_name_id=taxon_relations.taxon_name_id and
					taxon_relations.related_taxon_name_id=rel.taxon_name_id and
					rel.scientific_name='#scientific_name#'
			</cfquery>
			<cfif d.recordcount is 1>
				<cfset found=true>
				<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update ds_temp_taxcheck set suggested_sci_name='#d.scientific_name#',status='found_related_accepted_name' where key=#key#
				</cfquery>
			</cfif>
		</cfif>
		<cfif found is false>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select scientific_name from taxon_name where scientific_name='#scientific_name#'
			</cfquery>
			<cfif d.recordcount is 1>
				<cfset found=true>
				<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update ds_temp_taxcheck set suggested_sci_name='#d.scientific_name#',status='is_unaccepted_name' where key=#key#
				</cfquery>
			</cfif>
		</cfif>

		<cfif found is false>
			<cfset fstTerm="">
			<cfset scndTerm="">
			<cfset thrdTerm="">
			<cfset fortTerm="">
			<cfset ir="">
			<cfset ssp="">

			<cfif listlen(scientific_name," ") gte 1>
				<cfset fstTerm=listgetat(scientific_name,1," ")>
			</cfif>
			<cfif listlen(scientific_name," ") gte 2>
				<cfset scndTerm=listgetat(scientific_name,2," ")>
			</cfif>
			<cfif listlen(scientific_name," ") gte 3>
				<cfset thrdTerm=listgetat(scientific_name,3," ")>
			</cfif>
			<cfif listlen(scientific_name," ") gte 4>
				<cfset fortTerm=listgetat(scientific_name,4," ")>
			</cfif>
			<cfif len(thrdTerm) gt 0 and len(fortTerm) gt 0>
				<cfset ir=thrdTerm>
				<cfset ssp=fortTerm>
			<cfelseif len(thrdTerm) gt 0>
				<cfset ssp=thrdTerm>
			</cfif>
			<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					ds_temp_taxcheck
				set
					status='FAIL',
					genus='#fstTerm#',
					species='#scndTerm#',
					inf_rank='#ir#',
					subspecies='#ssp#'
				where key=#key#
			</cfquery>
		</cfif>
	</cfloop>
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_taxcheck
			order by
			scientific_name
	</cfquery>
	<cfset ac = getData.columnList>
	<!--- strip internal columns --->
	<cfif ListFindNoCase(ac,'KEY')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'KEY'))>
	</cfif>
	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "sciname_lookup.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfset header=trim(ac)>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(header);
	</cfscript>
	<cfloop query="getData">
		<cfset oneLine = "">
		<cfloop list="#ac#" index="c">
			<cfset thisData = evaluate(c)>
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset thisData=replace(thisData,'"','""','all')>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
	<cfoutput>
		<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
	</cfoutput>

</cfif>