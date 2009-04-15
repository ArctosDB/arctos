<!---
create table tacc_folder (
	folder varchar2(255),
	file_count number
	);
	
create table tacc_check (
	collection_object_id number,
	barcode varchar2(255),
	folder varchar2(255),
	chkdate date default sysdate)
	;
	
	
	select folder ||chr(9) || barcode from tacc_check where barcode in ( select barcode from tacc_check having count(barcode) > 1 group by barcode)
	order by barcode;

--->

<cfoutput>
<cfhttp url="http://goodnight.corral.tacc.utexas.edu/UAF" charset="utf-8" method="get">
</cfhttp>
<cfif isXML(cfhttp.FileContent)>
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>	
	<cfloop index="i" from="1" to="#arrayLen(dir)#">
		<cfset folder = dir[i].XmlChildren[1].xmlText>
		<cfif folder is not "Parent Directory">
			<!--- recurse into these folders to get filenames --->
			<cfquery name="gotFolder" datasource="uam_god">
				select count(*) c, file_count from tacc_folder where folder='#folder#' group by file_count		
			</cfquery>
			<cfquery name="gotFile" datasource="uam_god">
				select count(distinct(barcode)) cbc from tacc_check where folder='#folder#'			
			</cfquery>
			<cfif len(gotFolder.file_count) is 0><!--- been here? --->
				<cfif (len(gotFolder.file_count) gt 0 and (gotFolder.file_count is not gotFile.cbc)) or gotFolder.file_count is not gotFolder.c>
					<cfquery name="dammit" datasource="uam_god">
						delete from tacc_folder where folder='#folder#'
					</cfquery>
					<cfquery name="dammit2" datasource="uam_god">
						delete from tacc_check where folder='#folder#'
					</cfquery>
				</cfif>
				<cfhttp url="http://goodnight.corral.tacc.utexas.edu/UAF/#folder#" charset="utf-8" method="get">
				</cfhttp>
				<cfset ximgStr=cfhttp.FileContent>
				<!--- goddamned xmlns bug in CF --->
				<cfset ximgStr = replace(ximgStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
				<cfset xImgAll=xmlparse(ximgStr)>
				<cfset xImage = xmlsearch(xImgAll, "//td[@class='n']")>
				<cfloop index="i" from="1" to="#arrayLen(xImage)#">
					<cfset fname = xImage[i].XmlChildren[1].xmlText>
					<cfif #right(fname,4)# is ".dng">
						<cfset barcode=replace(fname,".dng","")>
						<cfquery name="upFile" datasource="uam_god">
							insert into tacc_check (
								barcode,
								folder
							) values (
								'#barcode#',
								'#folder#'
							)	
						</cfquery>
					</cfif> 
				</cfloop>
				<!--- made it thru the files, update the folder --->
				<cfquery name="upFolder" datasource="uam_god">
					insert into tacc_folder (
						folder,
						file_count
					) values (
						'#folder#',
						#arrayLen(xImage)#
					)
				</cfquery>
			</cfif> <!--- end not been here --->
		</cfif><!--- end 2008..... name --->
	</cfloop>
</cfif>
</cfoutput>