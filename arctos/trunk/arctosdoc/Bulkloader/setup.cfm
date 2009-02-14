<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Setting Up Data to Bulkload">

<font size="-2"><a href="../">Help</a> >> <a href="index.cfm">Bulk-loading Overview</a> >> <strong>Setting Up Data to Bulkload</strong></font><br />
<font size="+2">Setting Up Data to Bulk-load</font><br/>

<ol>
  <li> <strong>Be sure you are not trying to load bad or incomplete data!</strong></li>
  <ul>
    <li>See requirements and field format <a href="../Bulkloader/bulkloader_fields.cfm">here</a>. 
      Data not meeting these requirements will be rejected. In addition, make 
      sure that: 
      <ul>
        <li>Controlled values are entered correctly.
		Case and spaces are important.
		(If necessary, new values must be entered in appropriate code tables.) </li>
        <li>Agent names are spelled exactly as the preferred name is entered in Arctos.</li>
        <li>Scientific names are spelled correctly, including punctuation.</li>
        <li>Higher Geography exactly matches an existing entry</li>
        <li>All conditional values are filled in where needed 
          <ul>
            <li>All measurements must have units</li>
            <li>All flags have a value (0=false, 1=true)</li>
            <li>Parts and tissues have all required information 
              <ul>
                <li>Click <a href="../Bulkloader/bulkloader_fields.cfm">here</a> 
                  for the complete descriptions</li>
              </ul>
            </li>
          </ul>
        </li>
      </ul>
    </li>
    <li>Excel does not adequately enforce datatype and null rules; be very careful 
      if data are entered through Excel. Bad data will be rejected. 
	  Make sure anything coming from other applications has not changed field length, precision, or other attributes. 
	  <b>Check your data in Access table Bulkloader before you load it.</b></li>
    <li>Access append errors are often due to null or zero-length ambiguities, <i>i.e,</i> 
      Access is stoopid. 
	  There is no difference in these values; 
	  the bulkloader will correctly translate zero-length to null.</li>
    <li>The tool used to create the flat table is not important; feel free to 
      create custom entry applications. The format of the flat table <strong>is</strong> 
      important - field names and datatypes are critical.</li>
  </ul>
  <li> Set up the <a href="../accession.cfm">accession</a> in Arctos. Only accession metadata (recieved from, 
    nature of material, etc.) need be entered.</li>
  <li>Move data into s:\Pubpool\Bulkloader.mdb table Bulkloader 
    for loading.</li>
  <li>Load the data using the Arctos bulk-loader application.</li>
  <li>After data have been bulkloaded, rename Bulkloader to something else (ie, 
    Bulkloader_accn1234_567_Loaded1Jan2003) for archival purposes and create a 
    new Bulkloader table by right-clicking on BulkloaderTemplate and choosing 
    &quot;Save As ...&quot;. Any other method of creating a Bulkloader table (ie, 
    Make Table Query) will cause nasty Microsoftiness to consume your life. <em><strong><font color="#FF0000">Don't 
    mess with table BulkloaderTemplate!</font></strong></em></li>
</ol>
<cfinclude template="/includes/_helpFooter.cfm">
