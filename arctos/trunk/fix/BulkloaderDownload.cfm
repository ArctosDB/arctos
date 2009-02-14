<cfinclude template="/includes/_header.cfm">

		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from bulkloader where enteredby in ('pepe82','mmcguire')
		</cfquery>
		<cfset ac = #getData.columnList#>
		
		
		
		<cfset fileDir = "#Application.webDirectory#">
		
		<cfoutput>

				<cfset fileName = "/download/ArctosData.csv">
				<cfset header=#trim(ac)#>
				<cffile action="write" file="#fileDir##fileName#" addnewline="yes" output="#header#">
				<cfloop query="getData">
					<cfset oneLine = "">
					<cfloop list="#ac#" index="c">
						<cfset thisData = #evaluate(c)#>
						<cfif len(#oneLine#) is 0>
							<cfset oneLine = '"#thisData#"'>
						<cfelse>
							<cfset oneLine = '#oneLine#,"#thisData#"'>
						</cfif>
					</cfloop>
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#fileDir##fileName#" addnewline="yes" output="#oneLine#">
				</cfloop>
				<a href="#Application.ServerRootUrl#/#fileName#">Right-click to save your download.</a>
				
			
		</cfoutput>

<cfinclude template="/includes/_footer.cfm">