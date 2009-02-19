<!--- no security --->
<cfset title="ALA Imaging">
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfset numberFolders = 40>
<h2>
	ALA Plant Collection Imaging Project
</h2>
<form name="pd" method="post" action="index.cfm">
<input type="hidden" name="action" value="save">
<input type="hidden" name="numberFolders" value="#numberFolders#">
<table width="100%">
	<tr>
		<td valign="top">
			<label for="meta">Folder Data</label>
			<div style="border:1px solid green; padding:10px;" id="meta">
				
				<label for="folder_identification">Identification on Folder</label>
				<input type="text" name="folder_identification" id="folder_identification" size="50" class="reqdClr">
				<br>
				<label for="folder_barcode">Barcode on Folder</label>
				<input type="text" name="folder_barcode" id="folder_barcode" size="20" class="reqdClr">
			</div>
		</td>
		<td>
			<label for="sheets">Sheets in Folder</label>		
			<div style="border:1px solid green; padding:10px;" id="sheets">
				<table border>
					<tr>						
						<th>ID Type</th>
						<th>ID Number</th>
						<th>Barcode</th>
					</tr>
					<cfloop from="1" to="#numberFolders#" index="i">
						<tr>
							<td>
								<select name="idType_#i#" id="" size="1">
									<option value="ALAAC" selected >ALAAC</option>
									<option value="field number">field number</option>
								</select>
							</td>
							<td>
								<input type="text" name="idNum_#i#" id="idNum_#i#" size="20">
							</td>	
							<td>
								<input type="text" name="barcode_#i#" id="barcode_#i#" size="20" class="reqdClr">	
							</td>												
						</tr>
					</cfloop>					
				</table>
			</div>
		</td>
		<td valign="top">
			<label for="control">Controls</label>	
			<div style="border:1px solid green; padding:10px;" id="control">
				<input type="submit" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
	   				onmouseout="this.className='savBtn'"
					value="Save to Database">
				<p>
				<input type="reset" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
	   				onmouseout="this.className='clrBtn'"
					value="Clear Form">
				<p>
				<input type="button" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
	   				onmouseout="this.className='lnkBtn'"
					value="Edit Mode"
					onclick="document.location='ala_edit.cfm';">			
			
			</div>
		</td>
	</tr>
</table>
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #action# is "save">
<!--- 
	create table ala_plant_imaging (
		image_id number not null,
		folder_identification varchar2(255),
		folder_barcode varchar2(255),
		idType varchar2(255),
		idNum varchar2(255),
		barcode varchar2(255),
		whodunit varchar2(255),
		whendunit date
	);
	create public synonym ala_plant_imaging for ala_plant_imaging;
	grant select on ala_plant_imaging to public;
	grant insert on ala_plant_imaging to uam_update;
	create sequence ala_plant_imaging_seq;
	create public synonym ala_plant_imaging_seq for ala_plant_imaging_seq;
	
CREATE OR REPLACE TRIGGER ala_plant_imaging_key                                         
 before insert  ON ala_plant_imaging  
 for each row 
    begin                                                                                       
    	select ala_plant_imaging_seq.nextval into :new.image_id from dual;
   	end;                                                                                            
/
sho err


--->	

	<cfoutput>
		<cfif len(#folder_identification#) is 0 or len(#folder_barcode#) is 0>
			Folder Identification, Folder Barcode and Sheet Barcode are required. Use your back button...
			<cfabort>
		</cfif>
		<cfloop from="1" to ="#numberFolders#" index="i">
			<cfset thisNumType = evaluate("idType_" & i)>
			<cfset thisNum = evaluate("idNum_" & i)>
			<cfset thisBarcode=evaluate("barcode_" & i)>
			<cfif len(#thisBarcode#) gt 0>
			<cfquery name="ins" datasource="uam_god">
				insert into ala_plant_imaging (
					folder_identification,
					folder_barcode,
					idType,
					idNum,
					barcode,
					whodunit,
					whendunit
				) values (
					'#folder_identification#',
					'#folder_barcode#',
					'#thisNumType#',
					'#thisNum#',
					'#thisBarcode#',
					'#session.username#',
					sysdate
				)
			</cfquery>				
			</cfif>	
		</cfloop>
		<cflocation url="index.cfm">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">