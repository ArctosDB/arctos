<!---
	processing table

	create table temp_dgr_box as select distinct freezer, rack, box from dgr_locator;

	delete from temp_dgr_box where freezer='2';
	delete from temp_dgr_box where freezer='12';
	delete from temp_dgr_box where freezer='10';


	delete from temp_dgrloc where freezer='2';
	delete from temp_dgrloc where freezer='12';
	delete from temp_dgrloc where freezer='10';


	alter table temp_dgr_box add status varchar2(255);

	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=1;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;


	select status, count(*) from temp_dgr_box group by status;
	select * from temp_dgr_box where status='box_create_success';

--->

<cfif isdefined("action") and action is "dgr_to_objecttracking">
	<cfabort>
</cfif>

<cfoutput>


<!--- now loop through and find the tube's contianer_id --->

		<cfquery datasource='uam_god' name='srcbx'>
			select distinct freezer,rack,box from temp_dgrloc where tube_container_id is null and rownum<2000
		</cfquery>
		<cfloop query="srcbx">
			<cftransaction>
				<cfquery datasource='uam_god' name='d'>
					select * from temp_dgrloc where tube_container_id is null and
					 freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
				</cfquery>
				<cfquery datasource='uam_god' name='d_b'>
					select container_id from container where container_type='freezer box' and
					label='DGR-#srcbx.freezer#-#srcbx.rack#-#srcbx.box#'
				</cfquery>
				<cfif d_b.recordcount is not 1>
					<cfthrow message="box_not_found" detail="DGR-#srcbx.freezer#-#srcbx.rack#-#srcbx.box#">
				</cfif>

				<!---
				<cfdump var=#d#>
				--->
				<cfloop query="d">
					<cfquery datasource='uam_god' name='t'>
						select
							t.container_id
						from
							container t,
							container p
						where
							t.container_type='cryovial' and
							p.container_type='position' and
							t.parent_container_id=p.container_id and
							p.parent_container_id=#d_b.container_id# and
							t.label='NK #nk# #tissue_type#' and
							p.label='#place#'
					</cfquery>
					<cfquery datasource='uam_god' name='reup'>
						update temp_dgrloc set TUBE_CONTAINER_ID=#t.container_id# where key=#d.key#
					</cfquery>
				</cfloop>
			</cftransaction>
		</cfloop>





</cfoutput>
<!----









	<cfif action is "dgr_to_objecttracking">
		all done<cfabort>

		<cfquery datasource='uam_god' name='srcbx'>
			select * from temp_dgr_box where status is null and rownum <2
		</cfquery>
		<cfloop query="srcbx">
			<br>freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
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
				<cfquery name="grack" datasource="uam_god">
					select container_id from container where container_type='freezer rack' and label='DGR-#box.freezer#-#box.rack#'
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
						#grack.container_id#,
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






	<cfif action is "make_freezer_racks">

		all done<cfabort>
		<cftransaction>
		<cfquery datasource='uam_god' name='d'>
			select distinct freezer, rack from temp_dgr_box order by freezer,rack
		</cfquery>

		<cfdump var=#d#>

		<cfquery name="f" dbtype="query">
			select freezer from d group by freezer order by freezer
		</cfquery>
		<cfloop query="#f#">
			<cfquery datasource='uam_god' name='fi'>
				select * from container where label='DGR-#freezer#'
			</cfquery>
			<cfdump var=#fi#>
			<cfquery name="rs" dbtype="query">
				select rack from d where freezer=#freezer#
			</cfquery>
			<cfloop query="#rs#">

				<cfquery name="makerack" datasource='uam_god'>
					insert into container (
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						LABEL,
						DESCRIPTION,
						INSTITUTION_ACRONYM
					) values (
						sq_container_id.nextval,
						#fi.container_id#,
						'freezer rack',
						'DGR-#f.freezer#-#rs.rack#',
						'rack autocreated from DGR Locator',
						'MSB'
					)
				</cfquery>
			</cfloop>
		</cfloop>
		</cftransaction>

	</cfif>


	<cfif action is "confirm_freezers_exist">

	all done<cfabort>


		<cfquery datasource='uam_god' name='d'>
			select distinct freezer from temp_dgr_box
		</cfquery>
		<cfloop query="d">
			<cfquery datasource='uam_god' name='f'>
				select * from container where label='DGR-#freezer#'
			</cfquery>
			<cfif f.recordcount is 1>
				<br>DGR-#freezer# is happy...
				<br>update container set parent_container_id=18230103 where container_id=#f.container_id#
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


---->