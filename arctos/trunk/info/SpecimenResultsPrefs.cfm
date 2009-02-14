<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
<!----
create table cf_spec_res_cols (
	column_name varchar2(38),
	sql_element varchar2(255)
	);
	create or replace public synonym cf_spec_res_cols for cf_spec_res_cols;
	grant select on cf_spec_res_cols to public;
	
	insert into cf_spec_res_cols (column_name,sql_element) values ('sex','#flatTableName#.sex');
	insert into cf_spec_res_cols (column_name,sql_element) values ('collection_object_id','#flatTableName#.collection_object_id');
	insert into cf_spec_res_cols (column_name,sql_element) values ('cat_num','#flatTableName#.cat_num');
	insert into cf_spec_res_cols (column_name,sql_element) values ('institution_acronym','#flatTableName#.institution_acronym');
	insert into cf_spec_res_cols (column_name,sql_element) values ('collection_cde','#flatTableName#.collection_cde');
	insert into cf_spec_res_cols (column_name,sql_element) values ('collection_id','#flatTableName#.collection_id');
	insert into cf_spec_res_cols (column_name,sql_element) values ('parts','#flatTableName#.parts');
	insert into cf_spec_res_cols (column_name,sql_element) values ('scientific_name','#flatTableName#.scientific_name');
	insert into cf_spec_res_cols (column_name,sql_element) values ('country','#flatTableName#.country');
	insert into cf_spec_res_cols (column_name,sql_element) values ('state_prov','#flatTableName#.state_prov');
	insert into cf_spec_res_cols (column_name,sql_element) values ('spec_locality','#flatTableName#.spec_locality');
	insert into cf_spec_res_cols (column_name,sql_element) values ('verbatim_date','#flatTableName#.verbatim_date');
	insert into cf_spec_res_cols (column_name,sql_element) values ('accession','#flatTableName#.accession');
	insert into cf_spec_res_cols (column_name,sql_element) values ('coll_obj_disposition','#flatTableName#.coll_obj_disposition');
	insert into cf_spec_res_cols (column_name,sql_element) values ('county','#flatTableName#.county');
	insert into cf_spec_res_cols (column_name,sql_element) values ('feature','#flatTableName#.feature');
	insert into cf_spec_res_cols (column_name,sql_element) values ('quad','#flatTableName#.quad');
	insert into cf_spec_res_cols (column_name,sql_element) values ('remarks','#flatTableName#.remarks');
	insert into cf_spec_res_cols (column_name,sql_element) values ('is','#flatTableName#.island');
	insert into cf_spec_res_cols (column_name,sql_element) values ('island_group','#flatTableName#.island_group');
	insert into cf_spec_res_cols (column_name,sql_element) values ('associated_species','#flatTableName#.associated_species');
	insert into cf_spec_res_cols (column_name,sql_element) values ('habitat','#flatTableName#.habitat');
	insert into cf_spec_res_cols (column_name,sql_element) values ('min_elev_in_m','round(min_elev_in_m)');
	insert into cf_spec_res_cols (column_name,sql_element) values ('max_elev_in_m','round(max_elev_in_m)');	
	
	insert into cf_spec_res_cols (column_name,sql_element) values ('SNV_results','ConcatAttributeValue(#flatTableName#.collection_object_id,''SNV results'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('age','ConcatAttributeValue(#flatTableName#.collection_object_id,''age'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('age_class','ConcatAttributeValue(#flatTableName#.collection_object_id,''age class'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('axillary_girth','ConcatAttributeValue(#flatTableName#.collection_object_id,''axillary girth'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('body_condition','ConcatAttributeValue(#flatTableName#.collection_object_id,''body condition'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('breadth','ConcatAttributeValue(#flatTableName#.collection_object_id,''breadth'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('bursa','ConcatAttributeValue(#flatTableName#.collection_object_id,''bursa'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('caste','ConcatAttributeValue(#flatTableName#.collection_object_id,''caste'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('colors','ConcatAttributeValue(#flatTableName#.collection_object_id,''colors'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('crown_rump_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''crown-rump length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('curvilinear_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''curvilinear length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('diploid_number','ConcatAttributeValue(#flatTableName#.collection_object_id,''diploid number'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('ear_from_crown','ConcatAttributeValue(#flatTableName#.collection_object_id,''ear from crown'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('ear_from_notch','ConcatAttributeValue(#flatTableName#.collection_object_id,''ear from notch'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('egg_content_weight','ConcatAttributeValue(#flatTableName#.collection_object_id,''egg content weight'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('eggshell_thickness','ConcatAttributeValue(#flatTableName#.collection_object_id,''eggshell thickness'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('embryo_weight','ConcatAttributeValue(#flatTableName#.collection_object_id,''embryo weight'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('extension','ConcatAttributeValue(#flatTableName#.collection_object_id,''extension'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('fat_deposition','ConcatAttributeValue(#flatTableName#.collection_object_id,''fat deposition'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('forearm_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''forearm length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('gonad','ConcatAttributeValue(#flatTableName#.collection_object_id,''gonad'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('hind_foot_with_claw','ConcatAttributeValue(#flatTableName#.collection_object_id,''hind foot with claw'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('hind_foot_without_claw','ConcatAttributeValue(#flatTableName#.collection_object_id,''hind foot without claw'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('molt_condition','ConcatAttributeValue(#flatTableName#.collection_object_id,''molt condition'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('number_of_labels','ConcatAttributeValue(#flatTableName#.collection_object_id,''number of labels'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('numeric_age','ConcatAttributeValue(#flatTableName#.collection_object_id,''numeric age'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('ovum','ConcatAttributeValue(#flatTableName#.collection_object_id,''ovum'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('reproductive_condition','ConcatAttributeValue(#flatTableName#.collection_object_id,''reproductive condition'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('reproductive_data','ConcatAttributeValue(#flatTableName#.collection_object_id,''reproductive data'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('sex','ConcatAttributeValue(#flatTableName#.collection_object_id,''sex'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('skull_ossification','ConcatAttributeValue(#flatTableName#.collection_object_id,''skull ossification'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('snout_vent_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''snout-vent length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('soft_parts','ConcatAttributeValue(#flatTableName#.collection_object_id,''soft parts'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('stomach_contents','ConcatAttributeValue(#flatTableName#.collection_object_id,''stomach contents'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('tail_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''tail length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('total_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''total length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('tragus_length','ConcatAttributeValue(#flatTableName#.collection_object_id,''tragus length'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('unformatted_measurements','ConcatAttributeValue(#flatTableName#.collection_object_id,''unformatted measurements'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('verbatim_preservation_date','ConcatAttributeValue(#flatTableName#.collection_object_id,''verbatim preservation date'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('weight','ConcatAttributeValue(#flatTableName#.collection_object_id,''weight'')' );
insert into cf_spec_res_cols (column_name,sql_element) values ('began_date','#flatTableName#.began_date');
insert into cf_spec_res_cols (column_name,sql_element) values ('ended_date','#flatTableName#.ended_date');
insert into cf_spec_res_cols (column_name,sql_element) values ('sci_name_with_auth','get_scientific_name_auths(#flatTableName#.collection_object_id)');
insert into cf_spec_res_cols (column_name,sql_element) values ('identified_by','concatAcceptedIdentifyingAgent(#flatTableName#.collection_object_id)');
insert into cf_spec_res_cols (column_name,sql_element) values ('datum','#flatTableName#.datum');
insert into cf_spec_res_cols (column_name,sql_element) values ('orig_lat_long_units','#flatTableName#.orig_lat_long_units');
insert into cf_spec_res_cols (column_name,sql_element) values ('lat_long_determiner','#flatTableName#.lat_long_determiner');
insert into cf_spec_res_cols (column_name,sql_element) values ('lat_long_ref_source','#flatTableName#.lat_long_ref_source');
insert into cf_spec_res_cols (column_name,sql_element) values ('lat_long_remarks','#flatTableName#.lat_long_remarks');
insert into cf_spec_res_cols (column_name,sql_element) values ('coordinateuncertaintyinmeters','#flatTableName#.coordinateuncertaintyinmeters');
insert into cf_spec_res_cols (column_name,sql_element) values ('continent_ocean','#flatTableName#.continent_ocean');
insert into cf_spec_res_cols (column_name,sql_element) values ('sea','#flatTableName#.sea');
insert into cf_spec_res_cols (column_name,sql_element) values ('family','get_taxonomy(cataloged_item.collection_object_id,''family'')');
insert into cf_spec_res_cols (column_name,sql_element) values ('phylorder','get_taxonomy(cataloged_item.collection_object_id,''phylorder'')');
insert into cf_spec_res_cols (column_name,sql_element) values ('collectors','#flatTableName#.collectors');
insert into cf_spec_res_cols (column_name,sql_element) values ('verbatimlatitude','#flatTableName#.verbatimlatitude');
insert into cf_spec_res_cols (column_name,sql_element) values ('verbatimlongitude','#flatTableName#.verbatimlongitude');
insert into cf_spec_res_cols (column_name,sql_element) values ('othercatalognumbers','#flatTableName#.othercatalognumbers');

insert into cf_spec_res_cols (column_name,sql_element) values ('dec_lat','#flatTableName#.dec_lat');
insert into cf_spec_res_cols (column_name,sql_element) values ('dec_long','#flatTableName#.dec_long');
			

alter table cf_spec_res_cols add category varchar2(255);
update cf_spec_res_cols set category='attribute' where sql_element like '%ConcatAttributeValue%';
update cf_spec_res_cols set category='attribute' where column_name ='sex';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='cat_num';
update cf_spec_res_cols set category='required' where column_name ='institution_acronym';
update cf_spec_res_cols set category='required' where column_name ='collection_cde';
update cf_spec_res_cols set category='required' where column_name ='collection_id';

update cf_spec_res_cols set category='specimen' where column_name ='parts';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';

update cf_spec_res_cols set category='required' where column_name ='scientific_name';

update cf_spec_res_cols set category='required' where column_name ='spec_locality';
update cf_spec_res_cols set category='required' where column_name ='verbatim_date';
update cf_spec_res_cols set category='specimen' where column_name ='sci_name_with_auth';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';
update cf_spec_res_cols set category='required' where column_name ='collection_object_id';

update cf_spec_res_cols set category='locality' where column_name ='country';
update cf_spec_res_cols set category='locality' where column_name ='state_prov';
update cf_spec_res_cols set category='locality' where column_name ='county';
update cf_spec_res_cols set category='locality' where column_name ='quad';
update cf_spec_res_cols set category='specimen' where column_name ='remarks';
update cf_spec_res_cols set category='locality',column_name='island' where column_name ='is';
update cf_spec_res_cols set category='locality' where column_name ='island_group';
update cf_spec_res_cols set category='locality' where column_name ='habitat';
update cf_spec_res_cols set category='locality' where column_name ='min_elev_in_m';
update cf_spec_res_cols set category='locality' where column_name ='max_elev_in_m';
update cf_spec_res_cols set category='specimen' where column_name ='began_date';
update cf_spec_res_cols set category='specimen' where column_name ='ended_date';
update cf_spec_res_cols set category='locality' where column_name ='habitat';
update cf_spec_res_cols set category='specimen' where column_name ='identified_by';
update cf_spec_res_cols set category='locality' where column_name ='datum';
update cf_spec_res_cols set category='locality' where column_name ='orig_lat_long_units';
update cf_spec_res_cols set category='locality' where column_name ='habitat';

update cf_spec_res_cols set category='curatorial' where column_name ='accession';
update cf_spec_res_cols set category='curatorial' where column_name ='coll_obj_disposition';
update cf_spec_res_cols set category='curatorial' where column_name ='accession';
update cf_spec_res_cols set category='curatorial' where column_name ='accession';
update cf_spec_res_cols set category='curatorial' where column_name ='accession';


update cf_spec_res_cols set category='locality' where column_name ='lat_long_determiner';
update cf_spec_res_cols set category='locality' where column_name ='lat_long_ref_source';
update cf_spec_res_cols set category='locality' where column_name ='lat_long_remarks';
update cf_spec_res_cols set category='locality' where column_name ='coordinateuncertaintyinmeters';
update cf_spec_res_cols set category='locality' where column_name ='continent_ocean';
update cf_spec_res_cols set category='locality' where column_name ='sea';
update cf_spec_res_cols set category='specimen' where column_name ='family';
update cf_spec_res_cols set category='specimen' where column_name ='phylorder';
update cf_spec_res_cols set category='specimen' where column_name ='collectors';
update cf_spec_res_cols set category='locality' where column_name ='verbatimlatitude';
update cf_spec_res_cols set category='locality' where column_name ='verbatimlongitude';
update cf_spec_res_cols set category='specimen' where column_name ='othercatalognumbers';
update cf_spec_res_cols set category='locality' where column_name ='verbatimlatitude';
update cf_spec_res_cols set category='locality' where column_name ='verbatimlatitude';

---->





	<script type='text/javascript' src='/includes/_specimenResults.js'></script>
<!---
<div style="border:1px solid red;">
	

<span onclick="closeCustom()" class="windowCloser"></span>
<br><span onclick="()" class="windowCloser"></span>
</div>
--->
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td rowspan="2" valign="top"><span style="font-size:.85em;font-style:italic;">Check fields to show them in your results and downloads. Uncheck to remove. Adding too much here will adversely affect performance.</span></td>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustom()">Close and Refresh Data</span>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustomNoRefresh()">Close Without Refresh</span>
		</td>
	</tr>
</table>
	
<cfquery name="poss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_spec_res_cols order by column_name
</cfquery>
<cfquery name="attribute" dbtype="query">
	select * from poss where category='attribute'
</cfquery>

<cfquery name="locality" dbtype="query">
	select * from poss where category='locality'
</cfquery>
<cfquery name="curatorial" dbtype="query">
	select * from poss where category IN ('curatorial','specimen')
</cfquery>
<cffunction name="displayColumn">
	<cfargument name="column_name">
	<cfargument name="resultColList">
	<cfset retval = "<tr><td nowrap='nowrap'>">
	<cfif left(column_name,1) is "_">
		<cfset retval = "#retval##right(column_name,len(column_name)-1)#">
	<cfelse>
		<cfset retval = "#retval##column_name#">
	</cfif>
	<cfset retval = '#retval#<input type="checkbox" 
			name="#column_name#"
			id="#lcase(column_name)#"'>
	<cfif listfindnocase(resultColList,column_name)> 
		<cfset retval = '#retval#checked="checked"'>
	</cfif>
	<cfset retval = '#retval#onchange="if(this.checked==true){crcloo(this.name,''in'')}else{crcloo(this.name,''out'')};"></td></tr>'>
	<cfreturn retval>
</cffunction>
<cfoutput>


<div align="right" style="width:100%;">
<form name="setPrefs" method="post" action="SpecimenResultsPrefs.cfm">
	<input type="hidden" name="action" value="set">

	<table border>
		<tr>
			<td align="center" valign="top">
				Locality
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(locality.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(locality.column_name))#')">[check none]</span>
			</td>
			<td align="center">
				Random
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(curatorial.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(curatorial.column_name))#')">[check none]</span>
			</td>
			<td align="center">
				Attributes
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(attribute.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(attribute.column_name))#')">[check none]</span>
			</td>
		</tr>
		<tr>
			<td valign="top" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:scroll;position:relative;">
			<table cellpadding="0" cellspacing="0">
				<cfloop query="locality">
					#displayColumn(column_name,session.resultColumnList)#
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:scroll;position:relative;">
			<table cellpadding="0" cellspacing="0">
				<cfloop query="curatorial">
					#displayColumn(column_name,session.resultColumnList)#					
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:scroll;position:relative;">
			<table cellpadding="0" cellspacing="0">
				<cfloop query="attribute">	
					#displayColumn(column_name,session.resultColumnList)#			
				</cfloop>
			</table>
				</div>
			</td>
		</tr>
	</table>

</form>

</div>
</cfoutput>
			 
			 
			 
</cfif>