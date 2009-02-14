<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/SpecimenImages/" NAME="SpecimenImages"> 
	<cfloop query="SpecimenImages">
		#name#<br>
		<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/SpecimenImages/#SpecimenImages.name#" NAME="level2"> 
		<cfloop query="level2">
			-#name#<br>
			<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/SpecimenImages/#SpecimenImages.name#/#level2.name#" NAME="level3"> 
			<cfloop query="level3">
				--#name# (#type#)<br>
				<CFDIRECTORY ACTION="List" 
					DIRECTORY="#Application.webDirectory#/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#" NAME="level4">
					<cfloop query="level4">
						---#name# (#type#)<br>
						<cfif type is "File">
							<cfquery name="isUsed" datasource="uam_god">
								insert into media_check (
									path,
									in_media_uri,
									in_preview_uri,
									last_check
								) values (
									'/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#',
									select count(*) from media where media_uri='#application.serverRootUrl#/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#/#name#',
									select count(*) from media where preview_uri='#application.serverRootUrl#/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#/#name#',
									sysdate
								)
							</cfquery>
							-------#application.serverRootUrl#/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#/#name# is used #isUsed.c# times.------<br>
						<cfelse>
							<CFDIRECTORY ACTION="List" 
								DIRECTORY="#Application.webDirectory#/SpecimenImages/#SpecimenImages.name#/#level2.name#/#level3.name#/#level4.name#" NAME="level5">
							<cfloop query="level4">
								----#name# (#type#)<br>
							</cfloop> 
						</cfif>
					</cfloop> 
			</cfloop>
		</cfloop>
	</cfloop>
</cfoutput>	 
<cfinclude template="/includes/_footer.cfm">