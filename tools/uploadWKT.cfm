<!----
	drop table cf_temp_wkt;

	create table cf_temp_wkt (
		temp_id varchar2(255) not null,
		wkt_polygon clob not null,
		media_id number
	);

	create unique index cf_temp_wkt_id on cf_temp_wkt(temp_id) tablespace uam_idx_1;


	create or replace public synonym cf_temp_wkt for cf_temp_wkt;

	grant all on cf_temp_wkt to manage_media;
---->

<cfinclude template="/includes/_header.cfm">
<cfset title="WKT uploader">
<!--- leave this link at the top of the page --->
<!------------------------------------------------------------------------------------------------>
<cfif action is "nothing">
	<script>
		function checkZIP() {
		    var filePath,ext;
		    filePath = $("#FiletoUpload").val();
		    ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
		    if(ext != 'zip') {
		        alert('Only files with the file extension ZIP are allowed');
		        return false;
		    } else {
		        return true;
		    }
		}
	</script>
	<cfoutput>
		<p>
			Upload CSV with two columns:
			<ul>
				<li>WKT_POLYGON: WKT data. Be cautious of various things truncating!</li>
				<li>temp_id: a unique (within this dataset) string that will be used to get back to your data</li>
			</ul>
		</p>
		<p>
			Useful SQL

			<pre>
				alter table TABLE_NAME add temp_id varchar2(255);
				update TABLE_NAME set temp_id=md5hash(WKT_POLYGON);

				create table TEMP_TABLE_NAME as select distinct temp_id,WKT_POLYGON from TABLE_NAME where temp_id is not null;

			</pre>
		</p>
		<form name="mupl" method="post" enctype="multipart/form-data" action="uploadWKT.cfm" onsubmit="return checkCSV();">
			<input type="hidden" name="action" value="getFile">
			<label for="FiletoUpload">Upload a CSV file</label>
			<input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
			<input type="submit" value="Upload this file" class="savBtn">
	  </form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "getFile">
	<cfoutput>
         <cfquery name="c" datasource="uam_god">
			delete from cf_temp_wkt
		</cfquery>

		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into cf_temp_wkt (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "wkt_polygon">
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
		<p>
			Data loaded.
		</p>
		<p>
			CAREFULLY check that nothing was mangled <a href="uploadWKT.cfm?action=tbl">here</a>
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "tbl">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_wkt
		</cfquery>
		<cfdump var=#d#>

		<p>
			Very sure that's all spiffy? <a href="uploadWKT.cfm?action=loads3">click here</a> to create files on the document server.
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "loads3">
	<cfsetting requestTimeOut = "600" >
	<cfset utilities = CreateObject("component","component.utilities")>

	<cfoutput>
		<p>
			You can check progress <a href="uploadWKT.cfm?action=tbl">here</a>. Everything should have a positive media_id; negative indicates something failed.
			<br>Reload this page if it times out, or after 10 minutes if your browser gets confused.
		</p>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_wkt where media_id is null and rownum<2
		</cfquery>
		<cfloop query="d">
				<cfset tempName=createUUID()>
				<cffile	action = "write" file = "#Application.sandbox#/#tempName#.tmp" output='#WKT_POLYGON#' addNewLine="false">
				<cfset x=utilities.sandboxToS3("#Application.sandbox#/#tempName#.tmp","#tempName#.wkt")>
				<cfif not isjson(x)>
					upload fail<cfdump var=#x#>
					<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cf_temp_wkt set media_id=-1 where geog_auth_rec_id=#geog_auth_rec_id#
					</cfquery>
				</cfif>
				<cfset x=deserializeJson(x)>
				<cfif (not isdefined("x.STATUSCODE")) or (x.STATUSCODE is not 200) or (not isdefined("x.MEDIA_URI")) or (len(x.MEDIA_URI) is 0)>
					<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cf_temp_wkt set media_id=-1 where geog_auth_rec_id=#geog_auth_rec_id#
					</cfquery>
				<cfelse>
					<br>upload to #x.media_uri#
					<cfquery name="mid" datasource="uam_god">
						select sq_MEDIA_ID.nextval mid from dual
					</cfquery>
					<br>making media #mid.mid#
					<cfquery name="mm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into media (
							MEDIA_ID,
							MEDIA_URI,
							MIME_TYPE,
							MEDIA_TYPE
						) values (
							#mid.mid#,
							'#x.media_uri#',
							'text/plain',
							'text'
						)
					</cfquery>
					<cfif len(x.md5) gt 0>
						<cfquery name="ml" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							insert into media_labels (
								MEDIA_LABEL_ID,
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID,
								ASSIGNED_ON_DATE
							) values (
								sq_MEDIA_LABEL_ID.nextval,
								#mid.mid#,
								'MD5 checksum',
								'#x.md5#',
								#session.MyAgentID#,
								sysdate
							)
						</cfquery>
					</cfif>
					<br>made media #mid.mid#
					<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cf_temp_wkt set media_id=#mid.mid# where temp_id=#temp_id#
					</cfquery>
					<cfflush>
				</cfif>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">