<!----
	create table cf_temp_wkt (
		temp_id varchar2(255) not null,
		wkt_polygon clob not null
	);

	create unique index cf_temp_wkt_id on cf_temp_wkt(temp_id) tablespace uam_idx_1;
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
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "preview">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where username='#session.username#' order by submitted_date desc
		</cfquery>
		<cfif d.recordcount is 0>
			You have no jobs.<cfabort>
		</cfif>
		<a name="top"></a>
		<p>
			Summary
		</p>
		<cfloop query="d">
			<blockquote>
				<br>Job Name: #JOBNAME#
				<br>Submitted Date: #submitted_date#
				<br>Status: #STATUS#
				<br><a href="###d.zid#">Scroll To</a>
			</blockquote>
		</cfloop>
		<cfloop query="d">
			<hr>
			<a name="#d.zid#" href="##top">Scroll Top</a>
			<br>Job Name: #JOBNAME#
			<br>Submitted Date: #submitted_date#
			<br>Status: #STATUS#
			<br><a href="uploadMedia.cfm?action=regen_download&zid=#d.zid#">Regenerate Download File</a>
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<table border>
				<tr>
					<th>STATUS</th>
					<th>FILENAME</th>
					<th>NEW_FILENAME</th>
					<th>PREVIEW_FILENAME</th>
					<th>REMOTEPATH</th>
					<th>REMOTE_PREVIEW</th>
					<th>MIME_TYPE</th>
					<th>MEDIA_TYPE</th>
					<th>MD5</th>
				</tr>
				<cfloop query="f">
					<tr>
						<td>#STATUS#</td>
						<td>#FILENAME#</td>
						<td>#NEW_FILENAME#</td>
						<td>#PREVIEW_FILENAME#</td>
						<td>
							<a href="#REMOTEPATH#" target="_blank">#REMOTEPATH#</a>
						</td>
						<td>
							<a href="#REMOTE_PREVIEW#" target="_blank">#REMOTE_PREVIEW#</a>
						</td>
						<td>#MIME_TYPE#</td>
						<td>#MEDIA_TYPE#</td>
						<td>#MD5#</td>
					</tr>
				</cfloop>
			</table>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">