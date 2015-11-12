<cfinclude template="/includes/_header.cfm">
<cfparam name="headers" default="">
<cfparam name="tablename" default="mytablename">
<cfparam name="ctlname" default="control.ctl">
<cfparam name="badname" default="bads.bad">
<cfparam name="csvname" default="data.csv">
<cfoutput>
<form name="f" method="post" action="sqlldr.cfm">
	<label for="headers">Paste CSV header row here</label>
	<textarea name="headers" class="hugetextarea">#headers#</textarea>
	<label for="tablename">tablename</label>
	<input type="text" name="tablename" size="80" value="#tablename#">
	<label for="ctlname">ctlname</label>
	<input type="text" name="ctlname" size="80" value="#ctlname#">
	<label for="badname">badname</label>
	<input type="text" name="badname" size="80" value="#badname#">
	<label for="csvname">csvname</label>
	<input type="text" name="csvname" size="80" value="#csvname#">
	<br><input type="submit" value="build .ctl">
</form>
<cfif isdefined("headers") and len(headers) gt 0>
	<p>
		HOW TO SQLLDR
	</p>
	Basic requirements
	<ul>
		<li>
			Access to Oracle
		</li>
		<li>
			Access to SQLLDR
		</li>
	</ul>
	<ol>
		<li>
			Get the data into valid CSV. Don't let Excel eat your junk.
		</li>
		<li>
			Build or find an empty table. pre_bulkloader often works.
			<cfscript>
				ctl="create table " & tablename & " (" & chr(10);
				for (i = 1; i lte listlen(headers); i = i + 1) {
					ctl = ctl & chr(9) & listgetat(headers,i);
					if (ucase(listgetat(headers,i)) is "WKT_POLYGON"){
						ctl = ctl &" VARCHAR2(100000000000)";
					} else {
						ctl = ctl &" VARCHAR2(4000)";
					}
					if (i lt listlen(headers)){
						 ctl = ctl & ",";
					}
					ctl = ctl & chr(10);
				}
				ctl = ctl & ");";
			</cfscript>
			<br><textarea name="ctl" class="hugetextarea">#ctl#</textarea>
		</li>
		<li>
			Build a control file
			<p>
				<code>
					vi #ctlname#
				</code>
			</p>
			<cfscript>
				ctl='load data' & chr(10);
				ctl = ctl & "infile '" & csvname & "'" & chr(10);
				ctl = ctl & "badfile '" & badname & "'" & chr(10);
				ctl = ctl & "into table " & tablename  & chr(10);
				ctl = ctl & "fields terminated by ',' optionally enclosed by '""'" & chr(10);
				ctl = ctl & "trailing nullcols" & chr(10);
				ctl = ctl & "(" & chr(10);

				for (i = 1; i lte listlen(headers); i = i + 1) {
					ctl = ctl & chr(9) & listgetat(headers,i) & " CHAR(4000)";
					if (i lt listlen(headers)){
						 ctl = ctl & ",";
					}
					ctl = ctl & chr(10);
				}
				ctl = ctl & ")";
			</cfscript>
			<br>
			<textarea name="ctl" class="hugetextarea">#ctl#</textarea>
		</li>
		<li>
			Get the CSV data to a server with SQLLDR
			<p>
				<code>
					scp #csvname# user@host:~/#csvname#
				</code>
			</p>
		</li>
		<li>
			Make sure the CSV works. Linefeed characters are often lobbed off, fix with:
			<p>
				<code>vi #csvname#</code>
			</p>
			then type (you cannot copypasta)
			<p>
				<code>
					:%/[CTL-v][ENTER]/[CTL-v][ENTER]/g
				</code>
			</p>
			to replace linefeeds with - uhh, linefeeds. Because, uhh, stuff....
		</li>
		<li>
			Load the data
			<p>
				<code>
					$ORACLE_HOME/bin/sqlldr username/password control=#ctlname#
				</code>
			</p>
			Don't forget to escape special characters in password - my.password ==> my\.password

		</li>
		<li>
			CAREFULLY examine:
			<ul>
				<li>The logfile, probably #replace(ctlname,".ctl",".log")#</li>
			</ul>
		</li>
		<li>
			Use dblinks to move data to production server
			<p>
				<code>
					insert into #tablename#@DB_production (select * from #tablename#);
				</code>
			</p>
		</li>
	</ol>

</cfif>
</cfoutput>

<!----



				fldAry = listToArray (headers);
				for( fieldName in fldAry ){
				   ctl = ctl & chr(9) & fieldName & " CHAR(4000)";
				   if fieldName is arrayLast(fldAry)
				    & chr(10);
				}

load data
 infile 'uamarchdata.csv'
 badfile 'arcbad.bad'
 into table uam_arc_orig
fields terminated by ',' optionally enclosed by '"'
 trailing nullcols
 (
 	GUID_PREFIX CHAR(4000),
	ACCN CHAR(4000),
	HIGHER_GEOG CHAR(4000),
	SPEC_LOCALITY CHAR(4000),
	VERBATIM_LOCALITY CHAR(4000),
	CAT_NUM CHAR(4000),
	OTHER_ID_NUM_1 CHAR(4000),
	OTHER_ID_NUM_TYPE_1 CHAR(4000),
	OTHER_ID_NUM_2 CHAR(4000),
	OTHER_ID_NUM_TYPE_2 CHAR(4000),
	OTHER_ID_NUM_3 CHAR(4000),
	OTHER_ID_NUM_TYPE_3 CHAR(4000),
	OTHER_ID_NUM_4 CHAR(4000),
	OTHER_ID_NUM_TYPE_4 CHAR(4000),
	TAXON_NAME CHAR(4000),
	NATURE_OF_ID CHAR(4000),
	ID_MADE_BY_AGENT CHAR(4000),
	MADE_DATE CHAR(4000),
	IDENTIFICATION_REMARKS CHAR(4000),
	COLLECTOR_AGENT_1 CHAR(4000),
	COLLECTOR_ROLE_1 CHAR(4000),
	COLLECTOR_AGENT_2 CHAR(4000),
	COLLECTOR_ROLE_2 CHAR(4000),
	COLLECTOR_AGENT_3 CHAR(4000),
	COLLECTOR_ROLE_3 CHAR(4000),
	COLLECTOR_AGENT_4 CHAR(4000),
	COLLECTOR_ROLE_4 CHAR(4000),
	COLLECTOR_AGENT_5 CHAR(4000),
	COLLECTOR_ROLE_5 CHAR(4000),
	COLLECTOR_AGENT_6 CHAR(4000),
	COLLECTOR_ROLE_6 CHAR(4000),
	COLLECTOR_AGENT_7 CHAR(4000),
	COLLECTOR_ROLE_7 CHAR(4000),
	VERBATIM_DATE CHAR(4000),
	MADE_DATE_1 CHAR(4000),
	COLL_OBJECT_REMARKS CHAR(4000),
	PART_NAME_1 CHAR(4000),
	PART_CONDITION_1 CHAR(4000),
	PART_BARCODE_1 CHAR(4000),
	PART_CONTAINER_LABEL_1 CHAR(4000),
	PART_ATTRIBUTE_LOCATION_1 CHAR(4000),
	PART_LOT_COUNT_1 CHAR(4000),
	PART_DISPOSITION_1 CHAR(4000),
	PART_REMARK_1 CHAR(4000),
	ATTRIBUTE_1 CHAR(4000),
	ATTRIBUTE_VALUE_1 CHAR(4000),
	ATTRIBUTE_UNITS_1 CHAR(4000),
	ATTRIBUTE_REMARKS_1 CHAR(4000),
	ATTRIBUTE_DATE_1 CHAR(4000),
	ATTRIBUTE_DET_METH_1 CHAR(4000),
	ATTRIBUTE_DETERMINER_1 CHAR(4000),
	ATTRIBUTE_2 CHAR(4000),
	ATTRIBUTE_VALUE_2 CHAR(4000),
	ATTRIBUTE_UNITS_2 CHAR(4000),
	ATTRIBUTE_REMARKS_2 CHAR(4000),
	ATTRIBUTE_DATE_2 CHAR(4000),
	ATTRIBUTE_DET_METH_2 CHAR(4000),
	ATTRIBUTE_DETERMINER_2 CHAR(4000),
	ATTRIBUTE_3 CHAR(4000),
	ATTRIBUTE_VALUE_3 CHAR(4000),
	ATTRIBUTE_UNITS_3 CHAR(4000),
	ATTRIBUTE_REMARKS_3 CHAR(4000),
	ATTRIBUTE_DATE_3 CHAR(4000),
	ATTRIBUTE_DET_METH_3 CHAR(4000),
	ATTRIBUTE_DETERMINER_3 CHAR(4000),
	ATTRIBUTE_4 CHAR(4000),
	ATTRIBUTE_VALUE_4 CHAR(4000),
	ATTRIBUTE_UNITS_4 CHAR(4000),
	ATTRIBUTE_REMARKS_4  CHAR(4000),
	ATTRIBUTE_DATE_4  CHAR(4000),
	ATTRIBUTE_DET_METH_4 CHAR(4000),
	ATTRIBUTE_DETERMINER_4 CHAR(4000),
	ATTRIBUTE_5 CHAR(4000),
	ATTRIBUTE_VALUE_5 CHAR(4000),
	ATTRIBUTE_UNITS_5 CHAR(4000),
	ATTRIBUTE_REMARKS_5 CHAR(4000),
	ATTRIBUTE_DATE_5 CHAR(4000),
	ATTRIBUTE_DET_METH_5 CHAR(4000),
	ATTRIBUTE_DETERMINER_5 CHAR(4000),
	ATTRIBUTE_6 CHAR(4000),
	ATTRIBUTE_VALUE_6 CHAR(4000),
	ATTRIBUTE_UNITS_6 CHAR(4000),
	ATTRIBUTE_REMARKS_6 CHAR(4000),
	ATTRIBUTE_DATE_6 CHAR(4000),
	ATTRIBUTE_DET_METH_6 CHAR(4000),
	ATTRIBUTE_DETERMINER_6 CHAR(4000),
	ATTRIBUTE_7 CHAR(4000),
	ATTRIBUTE_VALUE_7 CHAR(4000),
	ATTRIBUTE_UNITS_7 CHAR(4000),
	ATTRIBUTE_REMARKS_7 CHAR(4000),
	ATTRIBUTE_DATE_7 CHAR(4000),
	ATTRIBUTE_DET_METH_7 CHAR(4000),
	ATTRIBUTE_DETERMINER_7 CHAR(4000),
	ATTRIBUTE_8 CHAR(4000),
	ATTRIBUTE_VALUE_8 CHAR(4000),
	ATTRIBUTE_UNITS_8 CHAR(4000),
	ATTRIBUTE_REMARKS_8 CHAR(4000),
	ATTRIBUTE_DATE_8 CHAR(4000),
	ATTRIBUTE_DET_METH_8 CHAR(4000),
	ATTRIBUTE_DETERMINER_8 CHAR(4000),
	ATTRIBUTE_9 CHAR(4000),
	ATTRIBUTE_VALUE_9 CHAR(4000),
	ATTRIBUTE_UNITS_9 CHAR(4000),
	ATTRIBUTE_REMARKS_9 CHAR(4000),
	ATTRIBUTE_DATE_9 CHAR(4000),
	TTRIBUTE_DET_METH_9 CHAR(4000),
	ATTRIBUTE_DETERMINER_9 CHAR(4000),
	ATTRIBUTE_10 CHAR(4000),
	ATTRIBUTE_VALUE_10 CHAR(4000),
	ATTRIBUTE_UNITS_10 CHAR(4000),
	ATTRIBUTE_REMARKS_10 CHAR(4000),
	ATTRIBUTE_DATE_10 CHAR(4000),
	ATTRIBUTE_DET_METH_10 CHAR(4000),
	ATTRIBUTE_DETERMINER_10 CHAR(4000),
	ATTRIBUTE_11 CHAR(4000),
	ATTRIBUTE_VALUE_11 CHAR(4000),
	ATTRIBUTE_UNITS_11 CHAR(4000),
	ATTRIBUTE_REMARKS_11 CHAR(4000),
	ATTRIBUTE_DATE_11 CHAR(4000),
	ATTRIBUTE_DET_METH_11 CHAR(4000),
	ATTRIBUTE_DETERMINER_11 CHAR(4000),
	PUBLICATIONS_FULL_CITATION CHAR(4000),
	EVENT_ASSIGNED_DATE CHAR(4000)
 )


---->

<cfinclude template="/includes/_footer.cfm">