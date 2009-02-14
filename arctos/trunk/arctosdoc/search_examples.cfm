<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Examples of Searches on Arctos">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="search_examples_TOC.cfm">Examples of Searches on Arctos (Index)</a> >> <strong>Examples of Searches on Arctos</strong></font><br />
<font size="+2">Examples of Searchs on Arctos</font>

These examples are given to show the capabilities of the database 
and the strengths of the data.
The data are uneven, with some groups better represented than others, 
and with some records more complete (<i>e.g.</i>, georeferencing) than others.</p>
<p>Some simple searches using default settings:</p>
<p><a name="polar_bear"><strong>Map polar bears from Alaska.</strong></a></i>
		<ol>
			<li>Go to the Specimen Search tab at top of page.</li>
			<li>Type "polar bear" in Common Name, and "Alaska" in State/Province.</li>
			<li>From the dropdown at the bottom of the page, "Return result as,"
			select "BerkeleyMapper Map."</li>
			<li>Click the search button and a wait a minute while BerkeleyMapper does its stuff.</li>
		</ol></p>
<p><a name="collared_lemming"><strong>Collared lemmings for which there is DNA sequence.</strong></a></i>
		<ol>
			<li>Go to the Specimen Search tab at top of page.</li>
			<li>Type &quot;collared lemming&quot; in Common Name.</li>
			<li>From the dropdown for &quot;Other Identifier Type,&quot; select &quot;GenBank sequence accession.&quot;</li>
			<li>Click the search button and get a list. Click on one of the catalog numbers to see
			the individual specimen record. From there, click on the GenBank sequence accession 
			number to see the sequence in GenBank.</li>
		</ol></p>
<p><a name="kessel"><strong>Find birds cited in Kessel's <i>Birds of the Seward Peninsula</i>.</strong></a></li>
		<ol>
			<li>Go to the Publication/Project Search tab at top of page.</li>
			<li>Type &quot;<code>kessel</code>&quot; in Participant.</li>
			<li>Click the search button and get a list of publications authored by Dr. Brina Kessel. 
			Find &quot;Birds of the Seward Peninsula&quot; and click on the &quot;Cited Specimens&quot; button.
			Click on one of the catalog numbers to see an individual specimen record
			(which includes a link to the publication).</li>
		</ol></p>
		
<p><a name="harbor_seal"><strong>Find how specimens contributed by the Alaska Native
		Harbor Seal Commission have been used.</strong></a></li>
		<ol>
			<li>Go to the Publication/Project Search tab at top of page.</li>
			<li>Type &quot;<code>harbor seal commission</code>&quot; in Title.</li>
			<li>Click the search button and get a list of (one) items matching the search. 
			Click on the title of the project to get a description of the project.</li>
			<li>Click on &quot;Projects using contribute specimens&quot; in the table on the left
			side of the Project Description page.
			You should now have a list of projects, any one of which you can click on for a full description.</li>
		</ol></p>
	
<p>Some searches that use Advanced Features:</p>

<p><a name="brown_lemming"><strong>How many brown lemming specimens include frozen tissues?</strong></a> 
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Parts&quot;
			then save your settings with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search tab  at the top of the page; 
			this form should now include a &quot;Parts&quot; box.</li>
			<li>Select the Preservation Method of &quot;frozen&quot; from within the parts box.</li>
			<li>Type &quot;<code>brown lemming</code>&quot; in Common Name (near the top of the Specimen Search form)</li>
			<li>Click on the search button; you should now have a list of all brown lemmings
			with frozen parts, irrespective of which part is frozen.</li>
		</ol></p>
	
<p><a name="sea_lion"><strong>Sea lions that include photographs.</strong></a> 
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Images&quot;
			then save your settings with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search   tab at the top of the page; this form should now include an "Find items with images" checkbox. Check it.</li>
			<li>Type "<code>sea lion</code>" in Common Name (near the top of the Search Form)</li>
			<li>Click on the search button; you should now have a list of sea lions with images.
			Click on a catalog number to go an individual record. 
			The record will contain links to one or more images.</li>
		</ol></p>
	
	
	
	
<p><a name="least_weasel"><strong>Map least weasels from the USGS 1:250,000 map, "Fairbanks."</strong></a></li>
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Geography, click the checkbox for &quot;Map Name&quot;
			then save your preferences with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search form tab and 
			this form should now include a Map Name box with an 
			<img src="images/pick.gif" width="17" height="14">-icon to the right of it.</li>
			<li>Click on the <img src="images/pick.gif" width="17" height="14">-icon  
			at the right end of the row to get a map of interior Alaska divided into USGS
			1:250,000 quadrangles. 
			</li>Click on &quot;Fairbanks&quot; and close the pop-up window.</li>
			<li>Type &quot;<code>mustela nivalis</code>&quot; in Scientific Name (near the top of the page).</li>
			<li>From the dropdown at the bottom of the page, &quot;Return result as,&quot;
			select &quot;BerkeleyMapper Map.&quot;</li>
			<li>Click on the search button; you should soon get a map of the localities of least weasels 
			(<i>Mustela nivalis</i>) from around Fairbanks, Alaska, exclusive of animals for which no 
			latitude and longitude has been determined.</li>	
		</ol></p>
		
		
<p><a name="willow"><strong>Are there willows that were collected between mid July and the end of August?</strong></a></li>
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Advanced Date Search&quot;
			then save your preferences with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search  tab  and 
			this form should now include six additional possiblities just below "Year Collected."</li>
			<li>In &quot;Month Collected,&quot; select July (left dropdown) and August (right dropdown).</li>
			<li>In &quot;Day Collected,&quot; select 15 (left dropdown) and 31 (right dropdown).</li>
			<li>Type "<code>salix</code>" in Scientific Name (near the top of the Search Form)</li>
			<li>Click on the search button; you should now have list of all willows (<i>Salix</i> sp.)
			collected from 15 July to 31 August, irrespective of the year.</li>
		</ol></p>
<p><a name="big_bull_lemming"><strong>Find male brown lemmings heavier than 40 grams.</strong></a></li>
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Attributes&quot;
			then save your preferences with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search form (&quot;Specimen&quot; tab at top of page) and 
			this form should now include an Attribute box with three rows in which you
			can specify characteristics of an individual organism.</li>
			<li>In one of the rows, use the &quot;Attribute&quot; dropdown to select &quot;sex&quot;.
			Click on the <img src="images/pick.gif" width="17" height="14" border="0" align="baseline">-icon 
			at the right end of the row to get a selection of values for sex. Select &quot;male.&quot;
			The &quot;Operator&quot; should be set to &quot;equals.&quot;
			</li>
			<li>In another of the rows, use the &quot;Attribute&quot; dropdown to select &quot;weight.&quot;
			Click on the <img src="images/pick.gif" width="17" height="14">-icon 
			at the right end of the row to get a selection weight units and then select "g" for grams.
			From the &quot;Operator&quot; dropdown, select &quot;greater than,&quot; and in the &quot;Value&quot; box type "<code>40</code>."
			</li>
			<li>Type &quot;<code>lemmus tri</code>&quot; in Scientific Name (near the top of the Search Form)</li>
			<li>Click on the search button; you should now have list of all male brown lemmings (<i>Lemmus trimucronatus</i>)
			with a weight of 40 or more grams, exclusive of animals for which no weight was recorded.</li>	
		</ol></p>
		
<p><a name="download_attributes"><strong>Download measurements of specimens for external analysis. 
	(<i>e.g.</i>, total length and tail length of least weasels) </strong></a></li>
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Attributes&quot;
			then save your preferences with the yellow button at the top and bottom of the form.</li>
			<li>Go to the &quot;Specimen Search&quot; tab at the top of page. 
			This form should now include an Attribute box with three rows in which you
			can specify characteristics of an individual organism.</li>
			<li>In one of the rows, use the &quot;Attribute&quot; dropdown to select &quot;total length&quot;.</li>
			<li>In another of the rows, use the &quot;Attribute&quot; dropdown to select &quot;tail length.&quot;</li>
			<li>Type &quot;<code>mustela nivalis</code>&quot; in Scientific Name (near the top of the Search Form)</li>
			<li>Click on the search button; you should now have a form listing all least weasels (<i>Mustela nivalis</i>)
			for which total length and tail length have been recorded.</li>
			<li>At the bottom of this form, click on &quot;Detail Level 3&quot; to expand the amount of information per specimen. 
			(If you have selected a large data set, the session may be timed-out.
			In this case, you will have to create more stringent queries and combine the separate data sets for analysis.)</li>
			<li>Click on the &quot;Download&quot; button at the bottom of the form. 
			You will be asked for more information about yourself and your intended use of the data,
			and you must agree to the terms for using this data.
			When you have done this, click on the &quot;Continue&quot; button.
			You will get a tab-delimited text version of the data in &quot;Detail Level 3.&quot;</li>
			<li>You can now save this text file to your system.
			Your browser probably includes an option like &quot;Save this page as...&quot; from its &quot;File&quot; dropdown.
			Unless you rename the file, it will be called something like &quot;UAMData_8804295584999.&quot;</li>
			<li>Open the file in the editor of your choice, (MS Excel works fine.), and proceed to 
			delete the many columns that you won't need.
			(This procedure works for all four detail levels.
			You will have even more columns to delete at Level 4, but this may be necessary for 
			a few kinds of information.</li>
		</ol></p>
		
		
			
<p><a name="yukonicus"><strong>Find paratype specimens of the Alaska tiny shrew, <i>Sorex yukonicus.</i>.</strong></a></li>
		<ol>
			<li>You must be <a href="pageHelp/customize.cfm">logged in</a>.</li>
			<li>On the Advanced Features tab, in Other Options, click the checkbox for &quot;Citations&quot;
			then save your preferences with the yellow button at the top and bottom of the form.</li>
			<li>Go to the Specimen Search form; 
			this form should now include a box that says "Find cited specimens" with a dropdown 
			for &quot;Type status.&quot;</li>
			<li>From the dropdown, select &quot;paratype.&quot;</li>
			<li>Type "<code>yukonicus</code>" in Scientific Name (near top of Specimen Search form).</li>
			<li>Click on the search button; you should get a list of three Alaska tiny shrews
			(<i>Sorex yukonicus</i>) cited in the original description of this species.
			(Go further: Click on one of the catalog numbers to open an indvidual specimen record. Click on the 
			abbreviated publication, &quot;Dokuchaev, 1997,&quot; to see the full publication details. 
			From there, click on &quot;Specimens cited&quot;: the additional (first of four) specimen
			is the holotype.)</li>	
		</ol>
		</p>
	<!-- <p><a name="groupDelYear"><strong>View a summary of beluga holdings by year collected</strong></a></li>
		<ol>
			<li>Go to the <strong>Specimen Search</strong> tab and select "<strong>Specimen Summary</strong>" in the "<strong>Return Results as</strong>" menu	
			</li>
			<li>
				Select "year" in the <strong>Group by</strong> box that appears, enter "Delphinapterus leucas" in the <strong>Scientific Name</strong> search box, and submit the query.
				<blockquote>
					<em>Note: Year is from began_date. There may be additional data in verbatim_date or ended_date. You must examine individual records before drawing conclusions from these summary data.</em>
				</blockquote>
			</li>
		</ol> -->
			
		
		
		
<cfinclude template="/includes/_helpFooter.cfm">