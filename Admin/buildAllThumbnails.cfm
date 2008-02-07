<cfset imageDirectory = "#Application.webDirectory#/SpecimenImages">
<cfoutput>
<cfset somethingStoopid = "">
<cfdirectory action="list" name="SpecImg" directory="#imageDirectory#">

<cfloop query="SpecImg">
	<cfif #type# is "Dir">
		<cfset thisInstitutionDir = "#imageDirectory#/#name#">
		<cfdirectory action="list" name="InstDir" directory="#thisInstitutionDir#">
		<cfloop query="InstDir">
			<cfif #type# is "Dir">
				<cfset thisSpecDir = "#thisInstitutionDir#/#name#">
				<cfdirectory action="list" name="CatnumDir" directory="#thisSpecDir#">
				<cfloop query="CatnumDir">
					<cfif #type# is "Dir">
						<cfset thisSpecimenFolder = "#thisSpecDir#/#name#">
						<cfdirectory action="list" name="SpecDir" directory="#thisSpecimenFolder#">
						<cfloop query="SpecDir">
							<cfif #type# is "File">
								<cfif left(#name#,3) is not "tn_">
									<cfset thisExtension = #right(name,find(".",reverse(name)))#>
									<cfset thumbnailName = "tn_#name#">
									<cfset thumbnailName = replace(thumbnailName,thisExtension,"","last")>
									<cfset thumbnailName = "#thumbnailName#.jpg">
									<cfquery name="isTn" dbtype="query">
										select name from SpecDir where name = '#thumbnailName#'
									</cfquery>
									<cfif len(#isTn.name#) is 0>
										<cfset thisExtension = #right(name,find(".",reverse(name)))#>
										<cfset thisThumbnailName = "#thisSpecimenFolder#/#thumbnailName#">
										<cfset thisOriginalName = "#thisSpecimenFolder#/#name#">
										<cfexecute name="convert" 
											arguments="-thumbnail 100x100 #thisOriginalName# #thisThumbnailName#">
										</cfexecute>
										------thumbnail 100x100 #thisOriginalName# #thisThumbnailName#-----
										<!--- reset variables just to be sure they aren't recycled ---->
										<cfset thisThumbnailName = "">
										<cfset thisOriginalName = "">
									</cfif>
								</cfif> 
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cfif>
</cfloop>

<cfif len(#somethingStoopid#) gt 0>
	#somethingStoopid#
<cfelse>
	buildAllThumbnails.cfm completed with no errors.
</cfif>
</cfoutput>