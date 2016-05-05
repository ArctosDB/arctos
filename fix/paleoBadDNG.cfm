<!---


	create table temp_es_folder (
		folder varchar2(255)
	);

	alter table temp_es_folder add gotit number;


	create table temp_es_toosmall (
		folder varchar2(255),
		filename varchar2(255),
		fsize number
	);











select * from temp_es_toosmall;
select count(*) from temp_es_folder;

select count(*) from temp_es_folder where gotit is null;






--->
<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfoutput>
	#action#
	<cfif action is "nothing">
		<br><a href="paleoBadDNG.cfm?action=getDir">getDir</a>
		<br><a href="paleoBadDNG.cfm?action=getSileSize">getSileSize</a>
	</cfif>


	<cfif action is "getDir">
		<br>grab all directories in the http://web.corral.tacc.utexas.edu/UAF/es directory...
		<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/es" charset="utf-8" method="get">
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
				<cfif len(folder) is 10 and listlen(folder,"_") is 3><!--- probably a yyyy_mm_dd folder --->
					<cfquery name="gotFolder" datasource="uam_god">
						select count(*) c from temp_es_folder where folder='#folder#'
					</cfquery>
					<!---
					<cfquery name="gotFile" datasource="uam_god">
						select count(distinct(imgname)) cbc from es_img where folder='#folder#'
					</cfquery>
					--->
					<cfif gotFolder.c is 0><!--- been here? --->
						<cfquery name="upFile" datasource="uam_god">
							insert into temp_es_folder (
								folder
							) values (
								'#folder#'
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	</cfif><!--- end getDir --->



	<cfif action is "getSileSize">
		<!---- read reported file sizes ---->
		<cfquery name="f" datasource="uam_god">
			select folder from temp_es_folder where gotit is null and rownum<101
		</cfquery>
		<cfloop query="f">

			<br>fetching http://web.corral.tacc.utexas.edu/UAF/es/#f.folder#
			<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/es/#f.folder#" charset="utf-8" method="get"></cfhttp>
			<!----
					<cfdump var=#cfhttp#>
			---->
			<cfset ximgStr=cfhttp.FileContent>
			<!--- goddamned xmlns bug in CF --->
			<cfset ximgStr = replace(ximgStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
			<cfset xImgAll=xmlparse(ximgStr)>
			<!-----
					<cfdump var=#xImgAll#>
			----->
			<cfset ds=xImgAll.html.body.div.table.tbody.xmlchildren>
			<!-----
				ds: <cfdump var=#ds#>
			----->
			<cfloop index="i" from="1" to="#arrayLen(ds)#">
				<cfset thisone=ds[i].xmlchildren>
				<!-----
					<cfdump var=#thisone#>
				---->
				<cfset theFileName=thisone[1].xmlchildren[1].xmltext>
				<cfif right(theFileName,3) is "dng">
					<cfset fsize=thisone[3].xmltext>
					<cfif right(fsize,1) is "K">
						<cfset fsb=left(fsize,len(fsize)-1) * 1000>
					<cfelseif right(fsize,1) is "M">
						<cfset fsb=left(fsize,len(fsize)-1) * 1000000>
					<cfelse>
						<cfset fsb="ERROR CALCULATING@@@@">
					</cfif>
					<cfif fsb lt 18000000>
						<br>TOOSMALL!! #theFileName#=#fsb#
						<cfquery name="ts" datasource="uam_god">
							insert into temp_es_toosmall (folder,filename,fsize) values ('#f.folder#','#theFileName#','#fsb#')
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
			<cfquery name="fg" datasource="uam_god">
				update temp_es_folder set gotit=1 where folder='#f.folder#'
			</cfquery>
		</cfloop>
	</cfif>
</cfoutput>