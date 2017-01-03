<cfinclude template="/includes/_header.cfm">
<cfset title="labels2containers">
<!------------------------------------------>
<!---
	disabling this form after repeated failures of people to use the
	series functionality.
	last functional version is in v7.0.1.2
---->
<cfif action IS "nothing">
	<p>
		<a href="/tools/bulkEditContainer.cfm">upload CSV</a>
	</p>
	<p>
		Use this form to create CSV, then use the link above to process it.
	</p>
	<cfoutput>
		<cfquery name="ctContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct(container_type) container_type from ctcontainer_type
			where container_type <> 'collection object'
		</cfquery>
		<form name="wtf" method="post" action="labels2containers.cfm">
			<input type="hidden" name="action" value="change">
			<label for="origContType">Original Container Type</label>
			<select name="origContType" id="origContType" size="1" class="reqdClr">
				<cfloop query="ctContainerType">
					<option value="#container_type#">#container_type#</option>
				</cfloop>
			</select>

			<label for="newContType">New Container Type</label>
			<select name="newContType" id="newContType" size="1" class="reqdClr">
				<cfloop query="ctContainerType">
					<option value="#container_type#">#container_type#</option>
				</cfloop>
			</select>

			<label for="barcode_prefix">Barcode Prefix (include spaces, leading zeros if necessary)</label>
			<input type="text" name="barcode_prefix" id="barcode_prefix" size="3">
			<!---
			<label for="barcode_suffix">Barcode Suffix</label>
			<input type="text" name="barcode_suffix" id="barcode_suffix" size="3">
			--->
			<label for="begin_barcode">Low barcode (integer component)</label>
			<input type="text" name="begin_barcode" id="begin_barcode" class="reqdClr">
			<label for="end_barcode">High barcode (integer component)</label>
			<input type="text" name="end_barcode" id="end_barcode" class="reqdClr">

			<p>
				This form will leave LABEL NULL which should IGNORE current values. Edit the CSV if that's not OK.
			</p>

			<label for="description">New Description</label>
			<input type="text" name="description" id="description">
			<label for="container_remarks">New Remark</label>
			<input type="text" name="container_remarks" id="container_remarks">
			<label for="height">New Height</label>
			<input type="text" name="height" id="height">
			<label for="length">New Length</label>
			<input type="text" name="length" id="length">
			<label for="width">New Width</label>
			<input type="text" name="width" id="width">
			<label for="number_positions">New Number of Positions</label>
			<input type="text" name="number_positions" id="number_positions">
			<br><input type="button" value="build CSV" class="savBtn" onclick="wtf.action.value='change';submit();">
		</form>
	</cfoutput>
</cfif>
<cfif action IS "change">
	<cfoutput>
		<cfset header="BARCODE,OLD_CONTAINER_TYPE,CONTAINER_TYPE,LABEL,DESCRIPTION,CONTAINER_REMARKS,HEIGHT,LENGTH,WIDTH,NUMBER_POSITIONS">

		<cfset s = createObject("java","java.lang.StringBuilder")>
		<cfset newString = header>
		<cfset s.append(newString)>
		<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
			<cfset bc = barcode_prefix & i>
			<cfset r='---imalinebreak--"#bc#","#origContType#","#newContType#","","#DESCRIPTION#","#CONTAINER_REMARKS#","#HEIGHT#","#LENGTH#","#WIDTH#","#NUMBER_POSITIONS#"'>
			<cfset s.append(r)>
		</cfloop>


		<cfset x=s.toString()>

		====<cfdump var=#x#>====


		<cffile action="write" addnewline="no" file="#Application.webDirectory#/download/ChangeContainer.csv" output="#s.toString()#">


		<p>header: #header#

		<!----




		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/ChangeContainer.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			//variables.joFileWriter.writeLine(header);
		</cfscript>
		<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
			<cfset bc = barcode_prefix & i>
			<cfset r='"#bc#","#origContType#","#newContType#","","#DESCRIPTION#","#CONTAINER_REMARKS#","#HEIGHT#","#LENGTH#","#WIDTH#","#NUMBER_POSITIONS#"'>
			<cfscript>
				variables.joFileWriter.writeLine(r);
			</cfscript>
			<p>r: #r#
			</p>
		</cfloop>
		-------->


		<!----

			<cfscript>
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=ChangeContainer.csv" addtoken="false">

		---->
		<a href="/download/ChangeContainer.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">