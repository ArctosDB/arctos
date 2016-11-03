<cfinclude template="/includes/_header.cfm">
<cfparam name="headers" default="">
<cfparam name="tablename" default="mytablename">
<cfparam name="ctlname" default="control.ctl">
<cfparam name="badname" default="bads.bad">
<cfparam name="csvname" default="data.csv">
<cfset title="SQLLDR helper">
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
				<cfset headers=replace(headers,'"','','all')>
				<cfset headers=replace(headers,chr(10),'','all')>
				<cfset headers=replace(headers,chr(9),'','all')>
				<cfset headers=replace(headers,chr(13),'','all')>

				Build or find an empty table. pre_bulkloader often works.
				<cfscript>
					ctl="create table " & tablename & " (" & chr(10);
					for (i = 1; i lte listlen(headers); i = i + 1) {
						ctl = ctl & chr(9) & listgetat(headers,i);
						if (ucase(listgetat(headers,i)) is "WKT_POLYGON"){
							ctl = ctl &" CLOB";
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
						if (ucase(listgetat(headers,i)) is "WKT_POLYGON"){
							ctl = ctl & chr(9) & listgetat(headers,i) & " CHAR(100000000000)";
						} else {
							ctl = ctl & chr(9) & listgetat(headers,i) & " CHAR(4000)";
						}
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
				Make sure the CSV works. Linefeed characters are often lopped off, fix with:
				<p>
					<code>vi #csvname#</code>
				</p>
				then type (you cannot copypasta)
				<p>
					<code>
						:%s/[CTL-v][ENTER]/[CTL-v][ENTER]/g
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
					<li>The badfile, probably #badname#</li>
					<li>Anything else that's popped up in the directory</li>
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
<cfinclude template="/includes/_footer.cfm">