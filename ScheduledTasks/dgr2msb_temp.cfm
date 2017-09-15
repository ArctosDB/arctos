<!---
	processing table

	create table temp_dgr_box as select distinct freezer, rack, box from dgr_locator;

	delete from temp_dgr_box where freezer='2';

	alter table temp_dgr_box add status varchar2(255);

	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=1;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;


	select status, count(*) from temp_dgr_box group by status;
	select * from temp_dgr_box where status='box_create_success';

--->

<cfoutput>
	<cfif action is "confirm_freezers_exist">
		<cfquery datasource='uam_god' name='d'>
			select distinct freezer from temp_dgr_box
		</cfquery>
		<cfloop query="d">
			<cfquery datasource='uam_god' name='f'>
				select * from container where label='DGR-#freezer#'
			</cfquery>
			<cfif f.recordcount is 1>
				<br>DGR-#freezer# is happy...
			<cfelse>
				<br>BAD!!!!!!!!!!!!!!!!!!<cfdump var=#f#>
			</cfif>
			<cfquery datasource='uam_god' name='fc'>
				select container_type, label from container where parent_container_id=#f.container_id#
			</cfquery>
			<cfif fc.recordcount gt 0>
				<br>!!!!! bad <cfdump var=#fc#>
			<cfelse>
				<br>happy - no contents
			</cfif>


		</cfloop>
	</cfif>


	<cfif action is "dgr_to_objecttracking">

		<cfquery datasource='uam_god' name='srcbx'>
			select * from temp_dgr_box where status is null and rownum <2
		</cfquery>

		<cfloop query="srcbx">
			<cfquery name="d" datasource="uam_god">
				select * from dgr_locator where freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
			</cfquery>
			<cftransaction>
				<cfquery name="box" dbtype="query">
					select freezer, rack, box from d group by freezer, rack, box
				</cfquery>
				<cfquery name="isbox" datasource="uam_god">
					select * from container where label='DGR-#box.freezer#-#box.rack#-#box.box#'
				</cfquery>
				<cfif len(isbox.container_id) gt 0>
					box DGR-#box.freezer#-#box.rack#-#box.box# already exists - aborting
					<cfquery name="ss" datasource="uam_god">
						update temp_dgrbox set status=status || 'box_already_exists' where box='#box.box#' and rack='#rack.rack#' and freezer='#freezer.freezer#'
					</cfquery>
					<cfabort>
				</cfif>
				<cfquery name="cid" datasource="uam_god">
					select sq_container_id.nextval id from dual
				</cfquery>
				<cfquery name="mkbox" datasource="uam_god">
					insert into container (
						container_id,
						parent_container_id,
						container_type,
						label,
						institution_acronym,
						NUMBER_POSITIONS
					) values (
						#cid.id#,
						15300802,
						'freezer box',
						'DGR-#box.freezer#-#box.rack#-#box.box#',
						'MSB',
						100
					)
				</cfquery>
				<cfset boxid=cid.id>
				<p>
					make box with label DGR-#box.freezer#-#box.rack#-#box.box#
				</p>

				<!---
					Mariel can we make these all 100-position boxes, even if that's not quite true??
					Yes, approved, they prefer this
				--->
				<cfloop from ="1" to="100" index="p">
					<p>
						 insert into new box position #p#
					</p>
					<cfquery name="cid" datasource="uam_god">
						select sq_container_id.nextval id from dual
					</cfquery>
					<cfquery name="mkbp" datasource="uam_god">
						insert into container (
							container_id,
							parent_container_id,
							container_type,
							label,
							institution_acronym
						) values (
							#cid.id#,
							#boxid#,
							'position',
							'#p#',
							'MSB'
						)
					</cfquery>
					<cfset lpid=cid.id>
					<!--- if and only if there's a tissue, make a cryovial ---->
					<cfquery name="ist" dbtype="query">
						select * from d where place=#p#
					</cfquery>
					<cfif len(ist.nk) gt 0>
						<cfquery name="cid" datasource="uam_god">
							select sq_container_id.nextval id from dual
						</cfquery>
						<cfquery name="mkbp" datasource="uam_god">
							insert into container (
								container_id,
								parent_container_id,
								container_type,
								label,
								institution_acronym,
								CONTAINER_REMARKS
							) values (
								#cid.id#,
								#lpid#,
								'cryovial',
								'NK #ist.nk# #ist.tissue_type#',
								'MSB',
								'autocreated from DGR Locator data'
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfquery name="ss" datasource="uam_god">
					update temp_dgr_box set status=status || 'box_create_success' where box='#box.box#' and rack='#box.rack#' and freezer='#box.freezer#'
				</cfquery>
			</cftransaction>
		</cfloop>
	</cfif>
</cfoutput>