deprecated<cfabort>


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

<cfsetting requesttimeout="600"> 



<cfoutput>
	
	
	
<!----------------------- and do it all over again for the ala/subfolders    ---------------->

<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/ala" charset="utf-8" method="get">
</cfhttp>
<cfif isXML(cfhttp.FileContent)>
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>	
	<cfloop index="i" from="1" to="#arrayLen(dir)#">
		<cfset folder = dir[i].XmlChildren[1].xmlText>
		<br>folder: #folder#
		<cfif left(folder,3) is "201"><!--- the old ALA stuff is in 200y_mm_dd folders --->
			<cfquery name="gotFolder" datasource="uam_god">
				select count(*) c, file_count from tacc_folder where folder='ala/#folder#' group by file_count		
			</cfquery>
			<cfquery name="gotFile" datasource="uam_god">
				select count(distinct(barcode)) cbc from tacc_check where folder='ala/#folder#'			
			</cfquery>
			<cfif len(gotFolder.file_count) is 0><!--- been here? --->
				<cfif (len(gotFolder.file_count) gt 0 and (gotFolder.file_count is not gotFile.cbc)) or gotFolder.file_count is not gotFolder.c>
					<cfquery name="dammit" datasource="uam_god">
						delete from tacc_folder where folder='ala/#folder#'
					</cfquery>
					<cfquery name="dammit2" datasource="uam_god">
						delete from tacc_check where folder='ala/#folder#'
					</cfquery>
				</cfif>
				<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/ala/#folder#" charset="utf-8" method="get">
				</cfhttp>
				<hr>got #folder#....
				<cfset ximgStr=cfhttp.FileContent>
				<!--- goddamned xmlns bug in CF --->
				<cfset ximgStr = replace(ximgStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
				<cfset xImgAll=xmlparse(ximgStr)>
				<cfset xImage = xmlsearch(xImgAll, "//td[@class='n']")>
				<cftransaction>
					<cfloop index="i" from="1" to="#arrayLen(xImage)#">
						<cfset fname = xImage[i].XmlChildren[1].xmlText>
						<br>fname: #fname#
						<cfif #right(fname,4)# is ".dng">
							<cfset barcode=replace(fname,".dng","")>
							<cfquery name="upFile" datasource="uam_god">
								insert into tacc_check (
									barcode,
									folder
								) values (
									'#barcode#',
									'ala/#folder#'
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
							'ala/#folder#',
							#arrayLen(xImage)#
						)
					</cfquery>
				</cftransaction>
			</cfif> <!--- end not been here --->			
		</cfif><!--- end 2008..... name --->
	</cfloop>
</cfif>
</cfoutput>