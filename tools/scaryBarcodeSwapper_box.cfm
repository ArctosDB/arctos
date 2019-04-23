<!----



drop table cf_temp_scaryswapper;

Position	Barcode	Label	box_barcode


CREATE TABLE cf_temp_scaryswapper (
	position  NUMBER NOT NULL,
	donor_barcode VARCHAR2(60) not null,
	receiving_label VARCHAR2(60) not null,
	box_barcode VARCHAR2(60) not null,
	donor_id number,
	tube_id number,
	position_id number,
	box_id number,
	status VARCHAR2(255) not null
);

---->

<cfinclude template="/includes/_header.cfm">


<cfset title="Scary Barcode Swapper">


<cfif action is "makeTemplate">
	<cfset thecolumns="position,donor_barcode,receiving_label,box_barcode">
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/scaryswapper.csv"
	    output = "#thecolumns#"
	    addNewLine = "no">
	<cflocation url="/download.cfm?file=scaryswapper.csv" addtoken="false">
</cfif>
<cfif action is "nothing">

	<table>
		<tr>
			<th>Column</th>
			<th>Wutsitdo?</th>
		</tr>
		<tr>
			<td>box_barcode</td>
			<td>Barcode of the box which contains positions which contains cryovials with labels {receiving_label}</td>
		</tr>
		<tr>
			<td>position</td>
			<td>Position between {box_barcode} and  {receiving_label}.</td>
		</tr>
		<tr>
			<td>receiving_label</td>
			<td>Label of the cryovial which needs a barcode.</td>
		</tr>
		<tr>
			<td>donor_barcode</td>
			<td>Barcode of an unused %label container which will be assigned to {receiving_label}'s container. The original container will be deleted.</td>
		</tr>
	</table>
	<label for="atts">Upload CSV</label>
	<form name="atts" method="post" enctype="multipart/form-data" action="scaryBarcodeSwapper_box.cfm">
		<input type="hidden" name="action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<cfif action is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_scaryswapper (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="scaryBarcodeSwapper_box.cfm?action=verify" addtoken="false">
</cfoutput>
</cfif>
<cfif action is "verify">
	<cfquery name="bx" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set box_id=(select container_id from container where container.barcode=cf_temp_scaryswapper.box_barcode)
	</cfquery>
	<cfquery name="bxv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set status='box_not_found' where box_id is null
	</cfquery>

	<cfquery name="dnr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set donor_id=(
			select container_id from container where container.barcode=cf_temp_scaryswapper.donor_barcode
		) where status is null
	</cfquery>
	<cfquery name="dnrv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set status='donor_not_found' where status is null and donor_id is null
	</cfquery>
	<cfquery name="dnrvd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set status='donor_duplicate' where status is null and donor_id in (
			select donor_id from cf_temp_scaryswapper having count(*) > 1 group by donor_id
		)
	</cfquery>


	<cfquery name="posn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set position_id=(
			select container_id from container where
				container.LABEL=cf_temp_scaryswapper.position and
				container.parent_container_id=cf_temp_scaryswapper.box_id
			)
	</cfquery>
	<cfquery name="posnv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set status='position_not_found' where status is null and position_id is null
	</cfquery>



	<cfquery name="tb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set tube_id=(
			select container_id from container where
				container.LABEL=cf_temp_scaryswapper.receiving_label and
				container.parent_container_id=cf_temp_scaryswapper.position_id
			)
	</cfquery>
	<cfquery name="posnv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_scaryswapper set status='tube_not_found' where status is null and tube_id is null
	</cfquery>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_scaryswapper
	</cfquery>
	<cfdump var=#d#>

</cfif>

scaryBarcodeSwapper_box.cfm