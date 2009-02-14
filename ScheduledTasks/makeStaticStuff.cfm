<!--- 
	make some static HTML pages that can be accessed by Google 
	Run at initial setup
	
--->
<!----------------- define stuff to use throughout these pages --------------------->
<cfset header = '
<html>
<head>
<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
<meta name="keywords" content="boreal biodiversity, arctic biodiversity, northern biodiversity,
                                                boreal biota, arctic biota, northern biota,
                                                boreal flora, arctic flora, northern flora,
                                                boreal fauna, arctic fauna, northern fauna,
												museum database, specimen data, data access, 
												museum, mammal collection, bird collection,
												herp collection, herbarium">
<meta name="description" content="Arctos is a biological specimen database at the University of Alaska''s Museum of the North.">			
</head>			
<body>
'>
<cfset footer = '
<center>
<table ALIGN="center" >
	<tr>
		<td align="center" valign="top">
		  <a href="/home.cfm">
			<img SRC="/images/arctos.gif" BORDER=0 ALT="[ Link to home page. ]">
			<br>
			<font size="-2">home</font></a>
		</td>
		<td>
			<a href="/Collections/index.cfm">Data Providers</a>
		</td>
		<td align="left">
			<a href="/info/bugs.cfm">
			<img SRC="/images/bug.gif" width="50" height="50" BORDER=0 ALT="[ Report a bug. ]"><br>
			<font size="-2">bug report</font></a>
		</td>
	</tr>
	<tr>
		<td align="center" valign="top" colspan="3">
			<font SIZE=-2>System Administrator is
			<a HREF="mailto:fndlm@uaf.edu"><i>Dusty McDonald</i></a>.</font>
		</td>
	</tr>
</table>
</center>
</body>
</html>

'>
<cfset thisPath = "/var/www/html/Static/">
<cfset thisDate = #dateformat(now(),"dd mmmm yyyy")#>
<!----------     end global stuff ---------->

<!--------------- publications ------------------------->
<cfset thisFile = "UAM_Publications.html">
<cfquery name="pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select formatted_publication,publication_id from formatted_publication where format_style='full citation'
	order by formatted_publication
</cfquery>

<cffile action="write" file="#thisPath##thisFile#" addnewline="no" output="#header#" nameconflict="overwrite">

<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="<p>
Static list of publications in <a href=""http://arctos.database.museum/home.cfm"">Arctos</a>, the database of the <a href=""http://www.uaf.edu/museum/main.html"">University of Alaska Museum of the North</a>
<p>Click <a href=""http://arctos.database.museum/PublicationSearch.cfm"">here</a> to search Arctos for these publications.
<p>Last updated #thisDate#
">

<cfoutput query="pub">
	<cffile 
		action="append" 
		file="#thisPath##thisFile#" 
		addnewline="yes" 
		output="<p><a href=""http://arctos.database.museum/PublicationResults.cfm?publication_id=#publication_id#"">#formatted_publication#</a>">
</cfoutput>
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#footer#">

<!---------------- taxonomy ---------------------->
<cfset thisFile = "UAM_Taxonomy.html">
<cfquery name="taxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		taxonomy.taxon_name_id, 
		taxonomy.scientific_name, 
		full_taxon_name, 
		author_text,
		concatCommonName(taxonomy.taxon_name_id) common_name
	 from 
	 	taxonomy,
		identification_taxonomy
	WHERE taxonomy.taxon_name_id = identification_taxonomy.taxon_name_id
	GROUP BY
		taxonomy.taxon_name_id, 
		taxonomy.scientific_name, 
		full_taxon_name, 
		author_text,
		concatCommonName(taxonomy.taxon_name_id)
	 order by scientific_name
</cfquery>

<cffile action="write" file="#thisPath##thisFile#" addnewline="no" output="#header#" nameconflict="overwrite">

<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="<p>
Static list of taxonomy in <a href=""http://arctos.database.museum/home.cfm"">Arctos</a>, the database of the <a href=""http://www.uaf.edu/museum/main.html"">University of Alaska Museum of the North</a>
<p>Click <a href=""http://arctos.database.museum/TaxonomySearch.cfm"">here</a> to search Arctos for these taxa.
<p>Last updated #thisDate#
<table border=""1"">
<tr><td>Scientific Name</td><td>Author</td><td>Full Taxon Name</td><td>Common Name(s)</td></tr>
">

<cfoutput query="taxa">
<cfif len(#common_name#) is 0>
	<cfset commonName = "none recorded">
<cfelse>
	<cfset commonName = "#common_name#">
</cfif>

	<cffile 
		action="append" 
		file="#thisPath##thisFile#" 
		addnewline="yes" 
		output="<tr><td><a href=""http://arctos.database.museum/TaxonomyDetails.cfm?taxon_name_id=#taxon_name_id#""><i>#scientific_name#</i></a></td><td>#author_text#&nbsp;</td><td>#full_taxon_name#</td><td>#CommonName#</td></tr>">
</cfoutput>
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="</table>">
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#footer#">

<!------------------- images ------------------------->
<cfquery name="images" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cat_num, 
		cataloged_item.collection_object_id,
		binary_object.collection_object_id imageID,
		collection.collection_cde, 
		institution_acronym,
		agent_name,
		scientific_name,
		subject,
		aspect,
		description,
		binary_object.made_date,
		full_url
	FROM
		binary_object,
		cataloged_item,
		collection,
		identification,
		preferred_agent_name,
		viewer
	WHERE
		binary_object.derived_from_cat_item = cataloged_item.collection_object_id AND
		cataloged_item.collection_id = collection.collection_id AND
		binary_object.made_agent_id = preferred_agent_name.agent_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		binary_object.viewer_id = viewer.viewer_id AND
		viewer = 'None/Browser'
	ORDER BY scientific_name,cat_num
</cfquery>

<cfoutput query="images">
<cfset madeData = #dateformat(made_date,"dd mmm yyyy")#>
<cfset thisFile = "#replace(scientific_name," ","_","all")#_image_#imageID#.html">
<cfset thisFile = replace(thisFile,"?","_","all")>
<cffile action="write" file="#thisPath##thisFile#" addnewline="no" output="#header#" nameconflict="overwrite">

<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="<p>
Images from <a href=""http://arctos.database.museum/home.cfm"">Arctos</a>, the database of the <a href=""http://www.uaf.edu/museum/main.html"">University of Alaska Museum of the North</a>.
<p>Click <a href=""http://arctos.database.museum/SpecimenSearch.cfm"">here</a> to search Arctos for specimen images.
<p>Last updated #thisDate#

	<table border=""1"">
		<tr>
			<td align=""right"">Catalog Number:</td>
			<td><a href=""http://arctos.database.museum/SpecimenDetail.cfm?collection_object_id=#collection_object_id#"">#institution_acronym# #collection_cde# #cat_num#</a></td>
		</tr>
		<tr>
			<td align=""right"">Scientific Name:</td>
			<td>#scientific_name#</td>
		</tr>
		<tr>
			<td align=""right"">Made by:</td>
			<td>#agent_name#</td>
		</tr>
		<tr>
			<td align=""right"">Made date:</td>
			<td>#madeData#</td>
		</tr>
		<tr>
			<td align=""right"">Subject:</td>
			<td>#Subject#</td>
		</tr>
		<tr>
			<td align=""right"">Aspect:</td>
			<td>#aspect#</td>
		</tr>
		<tr>
			<td align=""right"">Description:</td>
			<td>#description#</td>
		</tr>
		<tr>
			<td colspan=""2"" align=""center"">
				<i><font size=""-1"">Click image for full-size view</i></font>
			</td>
		</tr>
		<tr>
			<td colspan=""2"">
				<a href=""#full_url#""><img src=""#full_url#"" width=""600""></a>
			</td>
		</tr>
	</table>
	
">
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#footer#">
</cfoutput>

<!--- list of images ---->

<cfset thisFile = "UAM_Images.html">
<cffile action="write" file="#thisPath##thisFile#" addnewline="no" output="#header#" nameconflict="overwrite">

<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="<p>
Static list of images from <a href=""http://arctos.database.museum/home.cfm"">Arctos</a>, the database of the <a href=""http://www.uaf.edu/museum/main.html"">University of Alaska Museum of the North</a>.
<p>Click <a href=""http://arctos.database.museum/SpecimenSearch.cfm"">here</a> to search Arctos for specimen images.
<p>Last updated #thisDate#
<table border><tr><td>Scientific Name</td><td>Catalog Number</td><td>Subject</td><td>Description</td></tr>">



<cfoutput query="images">
<cfset madeData = #dateformat(made_date,"dd mmm yyyy")#>
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="
<tr>
<td><i>#scientific_name#</i></td>
<td><a href=""http://arctos.database.museum/SpecimenDetail.cfm?collection_object_id=#collection_object_id#"">#institution_acronym# #collection_cde# #cat_num#</a></td>
<td>#Subject#</td>
<td><a href=""#full_url#"">#description#</a></td></tr>
">
</cfoutput>
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="</table>">
<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#footer#">
<!--- now make an index page that lists all these and provides links --->
<cfset thisFile = "index.html">
<cffile action="write" file="#thisPath##thisFile#" addnewline="no" output="#header#" nameconflict="overwrite">
<cfdirectory action="list" directory="/var/www/html/Static" name="d" sort="name ASC">
<cfoutput>
	<cfloop query="d">
		<cfset thisLine = '<a href="#name#">#name#</a><br>'>
		<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#thisLine#">
	</cfloop>
	<cffile action="append" file="#thisPath##thisFile#" addnewline="yes" output="#footer#">
</cfoutput>