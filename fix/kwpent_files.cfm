<!---- get taxonomy as list



create table temp_kwp_tax as select * from dlm.my_temp_cf;
alter table temp_kwp_tax add taxa varchar2(4000);


--->
<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from temp_kwp_tax where taxa is null and rownum=1
		</cfquery>
		<cfloop query="d">
			<cfquery name="t" datasource="uam_god">
			select distinct FULL_TAXON_NAME from
			flat,
			specimen_part,
			coll_obj_cont_hist,
			container p,
			container t,
			container d,
			temp_kwp_tax
	where
		flat.collection_object_id=specimen_part.derived_from_cat_item and
		specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_obj_cont_hist.container_id=p.container_id and
		p.parent_container_id=t.container_id and
		t.parent_container_id=d.container_id and
		d.barcode=temp_kwp_tax.barcode
		</cfquery>
		<cfdump var=#t#>
		</cfloop>

</cfoutput>


<!----

	alter table temp_kwp_exp add cid number;
	update temp_kwp_exp set cid=(
		select
			cataloged_item.collection_object_id
		from
			cataloged_item,
			specimen_part,
			coll_obj_cont_hist,
			container p,
			container b
		where
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=p.container_id and
			p.container_id=b.parent_container_id and
			b.barcode=temp_kwp_exp.barcode
	);

	select count(*) from temp_kwp_exp where cid is null;

	bah, nevermind

	-- too slow
	alter table temp_kwp_exp add gotit number;

	--- bah part many

	drop table temp_kwp_all_data;

	create table temp_kwp_all_data as select
		temp_kwp_exp.barcode drawer_barcode,
		IMAGE_,
		DRAWER_,
		t.barcode tag_barcode,
		USE_LICENSE_URL,
		GUID,
		SCIENTIFIC_NAME,
		TYPESTATUS CITATIONS,
		PHYLORDER,
		FAMILY,
		SUBFAMILY,
		OTHERCATALOGNUMBERS,
		COLLECTORS,
		LOCALITY_NAME,
		GEOREFERENCE_SOURCE,
		COORDINATEUNCERTAINTYINMETERS,
		COUNTRY,
		STATE_PROV,
		FEATURE,
		HABITAT,
		MIN_ELEV_IN_M,
		MAX_ELEV_IN_M,
		SPEC_LOCALITY,
		VERBATIM_LOCALITY,
		COLLECTING_METHOD,
		VERBATIM_DATE,
		BEGAN_DATE,
		ENDED_DATE,
		PARTDETAIL,
		DEC_LAT,
		DEC_LONG,
		SEX,
		AGE_CLASS,
		MADE_DATE,
		month MONTH_COLLECTED,
		DAY DAY_COLLECTED,
		IDENTIFIEDBY IDENTIFIED_AGENT,
		INDIVIDUALCOUNT,
		year YEAR_COLLECTED
	from
		flat,
		specimen_part,
		coll_obj_cont_hist,
		container p,
		container t,
		container d,
		temp_kwp_exp
	where
		flat.collection_object_id=specimen_part.derived_from_cat_item and
		specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_obj_cont_hist.container_id=p.container_id and
		p.parent_container_id=t.container_id and
		t.parent_container_id=d.container_id and
		d.barcode=temp_kwp_exp.barcode
	;

	collection_object_id in (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				specimen_part,
				coll_obj_cont_hist,
				container p,
				container t,
				container d
			where
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=p.container_id and
				p.parent_container_id=t.container_id and
				t.parent_container_id=d.container_id and
				d.barcode in (
					select barcode from temp_kwp_exp
				)
		);


 select count(*) from temp_kwp_exp;
	401
	select count(distinct(drawer_barcode)) from temp_kwp_all_data;

	select distinct barcode from temp_kwp_exp where barcode not in (select drawer_barcode from temp_kwp_all_data);



	update temp_kwp_exp set gotit=null;
		update temp_kwp_exp set gotit=0 where barcode in ('UAM100456416','UAM100456417');

	select gotit,count(*) from temp_kwp_exp group by gotit;

<cfsetting requestTimeOut = "6000">
<cfoutput>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfquery name="d" datasource="uam_god">
		select * from temp_kwp_exp where gotit is null and rownum<50
	</cfquery>
	<cfloop query="d">
		<br>#d.barcode#
		<cfquery name="s" datasource="uam_god">
			select * from temp_kwp_all_data where drawer_barcode='#d.barcode#'
		</cfquery>
		<cfset csv = util.QueryToCSV2(Query=s,Fields=s.columnlist)>
		<cffile action = "write" file = "#Application.webDirectory#/download/kwp_files/#d.barcode#.csv" output = "#csv#">
		<cfquery name="git" datasource="uam_god">
			update temp_kwp_exp set gotit=1 where barcode='#d.barcode#'
		</cfquery>
	</cfloop>

</cfoutput>
--->
