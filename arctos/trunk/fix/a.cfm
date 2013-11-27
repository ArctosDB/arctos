<cfinclude template="/includes/_header.cfm">


<cfset x='<RateV4Request USERID="208ARCTO3771" >
     <Revision/>
     <Package ID="1ST">
          <Service>PRIORITY</Service>
          <ZipOrigination>44106</ZipOrigination>
          <ZipDestination>20770</ZipDestination>
          <Pounds>1</Pounds>
          <Ounces>8</Ounces>
          <Container>NONRECTANGULAR</Container>
          <Size>LARGE</Size>
          <Width>15</Width>
          <Length>30</Length>
          <Height>15</Height>
          <Girth>55</Girth>
     </Package>
</RateV4Request>'>

<cfoutput>
	
				
					<cfhttp method="get" url="http://testing.shippingapis.com/ShippingAPITest.dll??API=RateV4&XML=#x#" timeout="1"></cfhttp>
					<cfdump var=#cfhttp#>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">

