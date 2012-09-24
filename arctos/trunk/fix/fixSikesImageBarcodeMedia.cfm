<cfoutput>
<cfhttp url="http://goodnight.corral.tacc.utexas.edu/UAF/uam_ento/" charset="utf-8" method="get">
</cfhttp>
<cfif isXML(cfhttp.FileContent)>
	ok
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>	
	<table border>
		<tr>
			<td>url</td>
			<td>date</td>
			<td>barcode</td>
			<td>guid</td>
			<td>sciname</td>
			
			
		<cfset variables.encoding="UTF-8">
		<cfset fname = "uambugblmedia.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfset ac="MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license,media_label_1,media_label_value_1,media_label_2,media_label_value_2,media_relationship_1,media_related_term_1">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(ac); 
		</cfscript>
			
	
<cfloop index="i" from="1" to="#arrayLen(dir)#">
	<tr>
	<cfset folder = dir[i].XmlChildren[1].xmlText>
	<cfif right(folder,4) is ".jpg">
		<td>http://goodnight.corral.tacc.utexas.edu/UAF/uam_ento/#folder#</td>
		
	
		<cfset datetaken=replace(left(folder,10),"_","-","all")>
		<td>#datetaken#</td>
		
		<cfquery name="d" datasource="uam_god">
			select 
				GUID,
				flat.collection_object_id,
				flat.scientific_name
			from 
				flat,
				specimen_part,
				coll_obj_cont_hist,
				container p,
				container c 
			where 
				flat.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=p.container_id and
				p.parent_container_id=c.container_id and
				c.barcode = '#mid(folder,12,12)#'
		</cfquery>
		<td>#mid(folder,12,12)#</td>
		<td>#d.guid#</td>
		<td>#d.scientific_name#</td>
		<cfset thisRow='"http://goodnight.corral.tacc.utexas.edu/UAF/uam_ento/#folder#","image/jpeg","image","http://goodnight.corral.tacc.utexas.edu/UAF/uam_ento/tn/tn_#folder#","CC BY-NC-ND","description","#d.guid# - #d.scientific_name#","made date","#datetaken#","shows cataloged_item","#d.guid#"'>
		<cfscript>
			variables.joFileWriter.writeLine(thisRow);
		</cfscript>
		
		<cfelse>
			<td>ignoring #folder#</td>
		</cfif>
		</tr>
		
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	</table>
</cfif>

</cfoutput>
	
	
	
	
	
	 