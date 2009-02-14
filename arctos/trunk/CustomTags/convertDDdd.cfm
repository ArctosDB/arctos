<!---
Take a decimal degree for latitude (dlat) and longitude (dlon) and
create values for DD MM.mmmm and DD MM SS.ss formats and directions.
Returns:
LatitudeDirection
LatitudeDegrees
LatitudeMinutes
LatitudeSeconds
DecimalLatitudeMinutes
LongitudeDirection
LongitudeDegrees
LongitudeMinutes
LongitudeSeconds
DecimalLongitudeMinutes
--->
<cfsetting enablecfoutputonly="yes">
<!--- get the passed in attributes and set them as local variables --->
<cfset dec_lat = Attributes.dlat>
<cfset dec_long = Attributes.dlon>
<cfif dec_lat gt 0>
						<cfset LatitudeDirection='N'>
				<cfelseif dec_lat lt 0>
						<cfset LatitudeDirection='S'>
				</cfif>
					<cfif #dec_lat# eq round(#dec_lat#)>
						<cfset LatitudeDegrees=#Dec_Lat#>
						<cfset LatitudeMinutes=0>
						<cfset LatitudeSeconds=0>
						<cfset DecimalLatitudeMinutes=0>
					<cfelse> 
						<cfset adl=#abs(dec_lat)#>
						<cfset cpos=#find('.',adl)#>
						<cfset ldl=#len(adl)#>
						<cfset LatitudeDegrees=#left(adl,cpos-1)#>
						<cfset rcom=#right(adl, ldl-(cpos-1))#>
						<cfset DecimalLatitudeMinutes=#rcom# * 60>
							<cfif #DecimalLatitudeMinutes# eq round(#DecimalLatitudeMinutes#)>
									<cfset LatitudeMinutes=#DecimalLatitudeMinutes#>
									<cfset LatitudeSeconds=0>
							<cfelse> 
									<cfset LatitudeMinutes=#left(DecimalLatitudeMinutes, find('.',DecimalLatitudeMinutes) -1)#>
									<cfset nrmin=#len(DecimalLatitudeMinutes)# - #find('.',DecimalLatitudeMinutes)#>
									<cfset LatitudeSeconds=#right(DecimalLatitudeMinutes, nrmin + 1)# * 60>
							</cfif>
					</cfif>
				
					<cfif dec_long gt 0>
						<cfset LongitudeDirection='E'>
					<cfelseif dec_long lt 0>
						<cfset LongitudeDirection='W'>
					</cfif>
					<cfif #dec_long# eq round(#dec_long#)>
						<cfset LongitudeDegrees=#dec_long#>
						<cfset LongitudeMinutes=0>
						<cfset LongitudeSeconds=0>
						<cfset DecimalLongitudeMinutes=0>
					<cfelse> 
						<cfset ladl=#abs(dec_long)#>
						<cfset lcpos=#find('.',ladl)#>
						<cfset lldl=#len(ladl)#>
						<cfset LongitudeDegrees=#left(ladl,lcpos-1)#>
						<cfset lrcom=#right(ladl, lldl-(lcpos-1))#>
						<cfset DecimalLongitudeMinutes=#lrcom# * 60>
							<cfif #DecimalLongitudeMinutes# eq round(#DecimalLongitudeMinutes#)>
									<cfset LongitudeMinutes=#DecimalLongitudeMinutes#>
									<cfset LongitudeSeconds=0>
							<cfelse> 
								<cfset LongitudeMinutes=#left(DecimalLongitudeMinutes, find('.',DecimalLongitudeMinutes) -1)#>
								<cfset lnrmin=#len(DecimalLongitudeMinutes)# - #find('.',DecimalLongitudeMinutes)#>
								<cfset LongitudeSeconds=#right(DecimalLongitudeMinutes, lnrmin + 1)# * 60>
							</cfif>
					</cfif>
<!--- take what we did and pass it back to the calling form as useful variables --->
<cfset caller.LatitudeDirection = LatitudeDirection>
<cfset caller.LatitudeDegrees = LatitudeDegrees>
<cfset caller.LatitudeMinutes = LatitudeMinutes>
<cfset caller.LatitudeSeconds = LatitudeSeconds>
<cfset caller.DecimalLatitudeMinutes = DecimalLatitudeMinutes>
<cfset caller.LongitudeDirection = LongitudeDirection>
<cfset caller.LongitudeDegrees = LongitudeDegrees>
<cfset caller.LongitudeMinutes = LongitudeMinutes>
<cfset caller.LongitudeSeconds = LongitudeSeconds>
<cfset caller.DecimalLongitudeMinutes = DecimalLongitudeMinutes>
					
<cfsetting enablecfoutputonly="no">