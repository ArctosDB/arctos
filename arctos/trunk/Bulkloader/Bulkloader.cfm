<cfinclude template="../includes/_header.cfm">
<!---- this is an internal use page and needs a security wrapper --->

	
<table>
	<tr>
		<td valign="top">
		<ul>
			<li>
				<a href="bulkloader_status.cfm">Bulkloader&nbsp;Status</a>
			</li>
			<li>
				<a href="bulkloaderLoader.cfm">Bulkloader&nbsp;Loader</a>
			</li>
			<li>
				<a href="accessBL.cfm">Bulkloader&nbsp;Builder</a>
			</li>
			<li>
				<a href="getUnBulked.cfm">Get Unloaded Records</a>
			</li>
			<li>
				<a href="/DataEntry.cfm">Online Entry Form</a>
			</li>
			<li>
				<a href="javascript:void(0);" onclick="getDocs('Bulkloader/index')">Documentation</a>
			</li>
		</ul>
		</td>
		<td>


		
		<p>There is no standard method for moving data into table Bulkloader. 
		You may import data from any file format, type the data into the table, write your own data entry screen, 
		or use any other method you choose. We appreciate documentation - you, the user, know what works and 
		doesn't work better than anyone else. Please send documentation, in HTML format, to 
		<a href="mailto: dustymc@gmail.com">Dusty</a> if you would like them linked from here.
		<p>The bulkloader will load data from any collection. You may mix accessions, collections, or anything else
			in a single load.
		<p>The Bulkloader will not handle every eventuality that may ever occur while entering data. 
		Talk to your friendly local Arctos development team if you hit a snag.
		<p>Error messages should include more than enough information to allow 
		you to locate and correct the problem. If that isn't the case, contact 
		the Arctos development team with the error message and a description of the 
		action that caused the error message. 
		<p>
		To load data, just NULLify the LOADED column of the records you want to load. The Bulkloader runs
		periodically. The status of records in the bulkloader is available at 
		<a href="bulkloader_status.cfm">Bulkloader&nbsp;Status</a>
		</p>
		<p>
		The web-based applications may not work well for very large loads. Contact an Arctos DBA if you're having 
		problems. 
		</p>
		
		</td>
	</tr>
</table>
<cfinclude template="../includes/_footer.cfm">