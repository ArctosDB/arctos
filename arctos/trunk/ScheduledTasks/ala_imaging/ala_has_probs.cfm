<!----

create or replace procedure set_ala_status IS
begin
	update ala_plant_imaging set status = 'processing'
	 where status is null;
	 
	update ala_plant_imaging set status = 'bad_folder_id'
	 where FOLDER_IDENTIFICATION
	not in (select scientific_name from taxonomy)
	and status = 'processing';
	
update ala_plant_imaging set status = 'bad_entered_by'
	 where whodunit
	not in (select agent_name from agent_name where agent_name_type='login')
	and status = 'processing';
	
update ala_plant_imaging set status = 'bad_barcode'
	 where barcode
	not in (select barcode from container)
	and status = 'processing';
	
	update ala_plant_imaging set status = 'bad_folder_barcode'
	 where folder_barcode
	not in (select folder_barcode from container)
	and status = 'processing';


	
	
END;
/
sho err




         3


       654




uam> 
---->
<cfoutput>
<cfquery name="p" datasource="#uam_dbo#">
		select distinct(status) status from ala_plant_imaging where status NOT IN (
			'processing','loaded','loaded_containerized','pre_existing_containerized','pre_existing')
	UNION
		select 'stuck_in_bulk' status from bulkloader where loaded is not null and collection_cde='Herb' and 
			collection_object_id > 50
</cfquery>

<cfset probList = valuelist(p.status) >

<cfif len(#probList#) gt 0>	
<!------>	
	<cfmail to="dustymc@gmail.com,ALA_Imaging@googlegroups.com" from="ala_data_checker@#Application.fromEmail#" subject="ALA Imaging Data Problems" type="html">
		There are problems with the ALA plant data that require your attention.
		<cfif #probList# contains "bad_alaac_number">
			<br>
			Bad ALAAC Number(s):
			<br>
			<cfquery name="link" datasource="#uam_dbo#">
				select image_id from ala_plant_imaging where status='bad_alaac_number'
			</cfquery>
			<cfloop query="link">
				<a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#">
					#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#
				</a><br>
			</cfloop>
		</cfif>
		<cfif #probList# contains "bad_folder_id">
			<br>
			Folder Identification missing. Make corrections at 
			<a href="#Application.ServerRootUrl#/ALA_Imaging/folder_id.cfm">#Application.ServerRootUrl#/ALA_Imaging/folder_id.cfm</a>
		</cfif>
		<cfif #probList# contains "bad_entered_by">
			<cfquery name="link" datasource="#uam_dbo#">
				select distinct whodunit from ala_plant_imaging where status='bad_entered_by'
			</cfquery>
			<br>
			Entered Person not recognized:
			<br>
			<cfloop query="link">
				#whodunit#<br>
			</cfloop>
			
		</cfif>
		<cfif #probList# contains "bad_barcode">
			<br>
			Barcode not recognized:
			<cfquery name="link" datasource="#uam_dbo#">
				select image_id from ala_plant_imaging where status='bad_barcode'
			</cfquery>
			<cfloop query="link">
				<a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#">
					#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#
				</a><br>
			</cfloop>
		</cfif>
		<cfif #probList# contains "bad_folder_barcode">
			<br>
			Folder Barcode not recognized:
			<cfquery name="link" datasource="#uam_dbo#">
				select image_id from ala_plant_imaging where status='bad_folder_barcode'
			</cfquery>
			<cfloop query="link">
				<a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#">
					#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#
				</a><br>
			</cfloop>
		</cfif>
		<cfif #probList# contains "folder_barcode_is_barcode">
			<br>
			Folder Barcode and sheet barcode are identical:
			<cfquery name="link" datasource="#uam_dbo#">
				select image_id from ala_plant_imaging where status='folder_barcode_is_barcode'
			</cfquery>
			<cfloop query="link">
				<a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#">
					#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#
				</a><br>
			</cfloop>
		</cfif>
		<cfif #probList# contains "dup_ala_num">
			<br>
			Duplicate ALA Numbers:
			<cfquery name="link" datasource="#uam_dbo#">
				select image_id from ala_plant_imaging where status='dup_ala_num'
			</cfquery>
			<cfloop query="link">
				<a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#">
					#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=editRecord&image_id=#image_id#
				</a><br>
			</cfloop>
		</cfif>
	</cfmail>
<cfelse>
	<cfmail to="dustymc@gmail.com" from="nothing_broke@#Application.fromEmail#" subject="ala is NOT broken">
		no body
	</cfmail>
</cfif>
</cfoutput>
