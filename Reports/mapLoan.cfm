<cfinclude template="/includes/_header.cfm">
	<!---
		just georeference all shipping addresses
		alter table address add s$coordinates varchar2(255);
		alter table address add s$lastdate date;
	--->

<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select
			ADDRESS_ID,
			ADDRESS
		from
		ADDRESS where
		address_type='shipping' and
		 S$LASTDATE is null and rownum<2
	</cfquery>
	<cfset obj = CreateObject("component","component.functions")>
	<cfloop query="d">
		<cfset signedURL = obj.googleSignURL(
			urlPath="/maps/api/geocode/json",
			urlParams="address=#URLEncodedFormat('#ADDRESS#')#")>
		<cfhttp result="x" method="GET" url="#signedURL#"  timeout="20"/>
		<cfset llresult=DeserializeJSON(x.filecontent)>

		<cfdump var=#llresult#>
		<cfif llresult.status is "OK">
			<!-----
				<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
					<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
						<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
							<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
						</cfif>
						<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
							<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
						</cfif>
					</cfloop>
				</cfloop>
				---->
				<cfset coords=llresult.results[1].geometry.location.lat & "," & llresult.results[1].geometry.location.lng>

		<cfelse
			error...
		</cfif>
		<!---- update cache ---->
		<p>
			update address set
				s$coordinates='#coords#',
				s$lastdate=sysdate
			where ADDRESS_ID=#ADDRESS_ID#
		</p>
		<cfquery name="upEsDollar" datasource="uam_god">
			update address set
				s$coordinates='#coords#',
				s$lastdate=sysdate
			where ADDRESS_ID=#ADDRESS_ID#
		</cfquery>



	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">