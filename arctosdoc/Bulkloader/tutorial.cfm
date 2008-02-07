<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Bulk-loading Tutorial">

<ul>
	<li>Export Data from your desktop bulkloading application as a Tab-delimited Text File
	<ol>
	<li>Enter data in Access, or any other program you choose. This tutorial is written for Access 2002. <strong><font color="#FF0000">Excel is not recommended.</font> </strong></li>
	<li>Make sure you have a field labeled "collection_object_id" that is unique, non-null integer datatype. Setting collection_object_id as primary key will ensure this.</li>
	<li>
		When you're sure the data are ready to load, export the file as tab-delimited.
		<br /><img src="../images/bulk_delimited.jpg" />
	</li>
	<li>
		Include headers.
		<br />Tab-delimited.
		<br />No text qualifier.
		<br /><img src="../images/bulk_s2.jpg" />
	</li>
	<li>
		Open the txt file you just made in a text editor. It should looks something like
		<br /><img src="../images/bulk_check.jpg" />
		<br />Microsoft products commonly do not export correctly. Check for linebreaks. Make sure the file includes headers. Make sure text is not enclosed in quotes. If anything looks suspicous, delete the text file and re-export.
	</li>
	
</ol>
	</li>


<li>
Once you're relatively sure that you have a good text file, load it to the server using the Bulkloader Loader link from the Bulkloader.
<ol>
	<li>
		Browse to the text file you made in the steps above and Upload the file
	</li>
	<li>
		You should get, after the data are loaded, a results page. Follow ALL of the links on the page and carefully check the contents.
	</li>
	<li>
		The logfile is the most important.
		<blockquote>
			SQL*Loader: Release 10.2.0.1.0 - Production on <strong><font color="#FF0000">Sun Jan 29 11:24:30 2006</font></strong> 	
			<br />
			<strong><em>Check date carefully</em></strong>
			<br />Table "UAM"."BULKLOADER", loaded from every logical record.
			<br />Insert option in effect for this table: INSERT

<br />   Column Name                  Position   Len  Term Encl Datatype
<br />------------------------------ ---------- ----- ---- ---- ---------------------
<br />COLLECTION_OBJECT_ID                FIRST     *   |       CHARACTER            
<br />CAT_NUM                              NEXT     *   |       CHARACTER            
<br /><em><strong>This is just summary data and can generally be ignored. There should be a column for every column you've uploaded here <p />(big snip)</strong></em>

<br />Table "UAM"."BULKLOADER":
<br />  
<strong><font color="#FF0000">50 Rows successfully loaded.
  <br />0 Rows not loaded due to data errors.
  <br />0 Rows not loaded because all WHEN clauses were failed.
  <br />0 Rows not loaded because all fields were null.</font></strong>
  <br /><strong><em>Check that these counts match what you expected</em></strong>
  <br />
   Space allocated for bind array:                 223944 bytes(4 rows)
<br />Read   buffer bytes: 1048576

<br />Total logical records skipped:          0
<br />Total logical records read:            50
<br />Total logical records rejected:         0
<br />Total logical records discarded:        0
<br /><strong><em>Again, check that these counts match what you expected</em></strong>
<br />Run began on Sun Jan 29 11:24:30 2006
<br /><strong><em>Again, check date and time</em></strong>
<br />(SNIP)
</blockquote>
	</li>
	<li>
		Check the bad file. It should say "blank" and nothing else. If there were problems, it should contain the bad records. Note that tabs have been replaced by pipes ( | ) in this file.
		<blockquote>
			<strong><font color="#FF0000">394notaninteger</font></strong>| |24 Aug 2005|24 Aug 2005|24 Aug 2005| |North America, United States, Alaska, <em><strong>{snip}</strong></em>
<br />393| |25 Aug 2005|25 Aug 2005|25 Aug 2005| |North America, United States, Alaska, Kenai Quad, <em><strong>{snip}</strong></em>
</blockquote>
	</li>
	<li>
		Original data before they were parsed out by SQLLDR are available and sometimes are the best clue why a load failed. Microsoft export errors are often apparent here.
	</li>
	<li>
		The control file may be useful to track down otherwise inexplicable errors.
		<blockquote>
			<br />load data
			<br />infile *
			<br />insert into table bulkloader
			<br />fields terminated by "|"
			<br />TRAILING NULLCOLS 
			<br />(COLLECTION_OBJECT_ID,CAT_NUM, <em><strong>{SNIP}</strong></em>) 
			<br />begindata 
			<br />394| |24 Aug 2005|<em><strong>{SNIP}</strong></em>
			<br />393| |25 Aug 2005|25 Aug 2005|25 Aug 2005| |North America, <em><strong>{SNIP}</strong></em>

		</blockquote>
	</li>
</ol>
</li>
<li>If all the above appears as it should, you are ready for the actual bulkloading process, where data are parsed out to individual tables and made available through Arctos.</li>
<li>If there are errors in the Bulkloading process, you may retrieve the unloaded data using the Get Unloaded Records link from Bulkloader
<ol>
	<li>
		Click the link to build a text file. Once it's completely loaded, click the link to download the text file.
		<ul>
		<li>You MUST click the Get Unloaded Records link from Bulkloader to refresh the downloadable text file. It remains on the server and may not be current if you do not follow the above instructions.</li>
		<li>The link returns all records that have not been successfully loaded. This includes records where loaded is null (have not been processed by the bulkloader) and records where Loaded contains and error.</li>
		</ul>
	</li>
	<li>Save the text file to your hard drive using File --> Save As in your browser</li>
	<li>Import the unloaded records to Access and edit them.
		<ol>
			<li>
				Tables
			</li>
			<li>New</li>
			<li>Import</li>
			<img src="../images/bulk_imp.jpg" />
			<li>Select Text and Import</li>
			<img src="../images/bulk_textimp.jpg" />
			<li>Import as Delimited</li>
			<img src="../images/bulk_delimp.jpg" />
			<li>Tab-Delimited, Includes headers, no text qualifier.</li>
			<img src="../images/bulk_imp2.jpg" />
			<li>This step is painful and critical. Access will try to import many fields incorrectly. Everything except collection_object_id should be imported as TEXT. Primary culprits include dates and part conditions, but every field is suspect. </li>
			<img src="../images/bulk_datatype.jpg" />
			<br />If you miss something, you'll get a warning
			<br /><img src="../images/bulk_badimp.jpg" />
			<br />and Access will create a new table tableName_ImportErrors. 
			<br /><img src="../images/bulk_badrecs.jpg" />
			<br />Carefully review this table, then begin the import process over paying special attention to anything you've already fixed in addition to these columns.
			<li>Once you get a successful import with no errors, use collection_object_id as the primary key
			<br /><img src="../images/bulk_pkey.jpg" />
			</li>
			<li>
				Edit the file to fix errors. Error messages should be in column Loaded. After data is fixed, begin the bulkloading process again.
			</li>
		</ol>
	</li>
</ol>
</li>
</ul>
<cfinclude template="/includes/_helpFooter.cfm">