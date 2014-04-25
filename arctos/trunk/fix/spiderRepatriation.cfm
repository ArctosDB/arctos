<cfabort>



<!----


---- the aside


create table temp_bcid as select
  pc.barcode,
  flat.scientific_name,
  flat.guid
From
  flat,
  specimen_part,
  coll_obj_cont_hist,
  container p,
  container pc
where
  flat.collection_object_id=specimen_part.derived_from_cat_item and
  specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
  coll_obj_cont_hist.container_id=p.container_id and
  p.parent_container_id=pc.container_id and
  collection_id=4
;




select barcode || ': ' || scientific_name from temp_bcid having count(*) > 1 group by barcode,scientific_name;






------- end aside

upload CSV then

drop table temp_spider_rep;

create table temp_spider_rep as select * from dlm.my_temp_cf 

select count(*) from temp_spider_rep;

create table temp_unspider as select * from temp_spider_rep where 1=2;


 GUID									    VARCHAR2(4000)
 UAM_BARCODE								    VARCHAR2(4000)
 SPECIES								    VARCHAR2(4000)
 M									    VARCHAR2(4000)
 F									    VARCHAR2(4000)
 J									    VARCHAR2(4000)
 PARTLOTCOUNT								    VARCHAR2(4000)
 NOTES									    VARCHAR2(4000)
 ID_BY									    VARCHAR2(4000)
 ID_DATE								    VARCHAR2(4000)
 NATURE_OF_ID								    VARCHAR2(4000)


create table temp_spider_rep_bu as select * from temp_spider_rep;

-- rollback

drop table temp_unspider;
drop table temp_spider_rep;
create table temp_spider_rep  as select * from temp_spider_rep_bu;
create table temp_unspider as select * from temp_spider_rep where guid not like '%,%' and notes like '%Opiliones%';

delete from temp_spider_rep  where guid not like '%,%' and notes like '%Opiliones%';


declare
	g1 varchar2(255);
	g2 varchar2(255);
	g1i varchar2(255);
	g2i varchar2(255);
	usg varchar2(255);

begin
	for r in (select * from temp_spider_rep where guid like '%,%' and notes like '%Opiliones%') loop
		dbms_output.put_line(r.notes);
		g1:= regexp_substr(r.guid, '[^,]+', 1, 1);
		g2:= regexp_substr(r.guid, '[^,]+', 1, 2);
		select scientific_name into g1i from flat where guid=g1;
		select scientific_name into g2i from flat where guid=g2;

		dbms_output.put_line(g1 || ': ' || g1i);
		dbms_output.put_line(g2 || ': ' || g2i);

		if g1i='Opiliones' then
			usg:=g1;
		elsif g2i='Opiliones' then
			usg:=g2;
		else
			dbms_output.put_line('------------------------------------------------------------------ fail ---------------------');
		end if;
		-- grab the notspider
		insert into temp_unspider (
			GUID,
			UAM_BARCODE,
			SPECIES,
			M,
			F,
			J,
			PARTLOTCOUNT,
			NOTES,
			ID_BY,
			ID_DATE,
			NATURE_OF_ID
		) values (
			usg,
			r.UAM_BARCODE,
			r.SPECIES,
			r.M,
			r.F,
			r.J,
			r.PARTLOTCOUNT,
			r.NOTES,
			r.ID_BY,
			r.ID_DATE,
			r.NATURE_OF_ID
		);
		
		-- delete from the original data where the GUID is of the nonspider
		delete from temp_spider_rep where trim(guid)=usg;
		
		-- and delete "half-guids" of the non-spider
		-- get both first-item and last-item, and kill now-extraneous commas while we're in there
		
		update temp_spider_rep set guid=replace(guid,',' || usg);
		update temp_spider_rep set guid=replace(guid,usg || ',');	
	end loop;
end;
/

	
update temp_spider_rep set SPECIES='Araneidae' where SPECIES='Araneid';


alter table temp_unspider add newguid varchar2(255);

update temp_unspider set newguid=null;

alter table temp_unspider add done number;




delete from temp_spider_rep where notes='Opiliones';


create table temp_spider_rep_nounspider as select * from temp_spider_rep;



alter table temp_spider_rep add key varchar2(255);

begin
	for x in (select rowid from temp_spider_rep) loop
		update temp_spider_rep set key=rowid where rowid=x.rowid;
	end loop;
end;
/

-- make sure...

select guid from temp_spider_rep where guid not in (select guid from flat);



alter table temp_spider_rep add newguid varchar2(255);


alter table temp_spider_rep add done number;


create table temp_spider_rep_aftrsplit as select * from temp_spider_rep;



 select species || ': ' || count(*) from temp_spider_rep where species not in (select scientific_name from taxon_name) group by species;
Araenidae: 12
Centromerus helsdingen: 132
Ceratinella innominabilis: 7
Emblyna {Emblyna peragrata group}: 1
Eularia arctoa: 9
Hilaira {Hilaira sp 33243}: 3
Hilaria herniosa: 1
Incestophantes {Incestophantes nr. washingtoni}: 1
Linyphiidae {Linyphiidae Buckle BC#11}: 2
Linyphiidae {Linyphiidae Buckle Erigonine "Flathead"}: 2
Linyphiidae {Linyphiidae Dall Is Erigonine #2}: 1
Linyphiidae {Linyphiidae Dall Is Erigonine #3}: 1
Linyphiidae {Linyphiidae Etolin Is Erigonine #1}: 1
Linyphiidae {Linyphiidae UAM Misc. Agyneta Sp1}: 1
Linyphiidae {Linyphiidae UAM Misc. Erigonine sp3}: 1
Linyphiidae {Linyphiidae UAM Misc. Erigonine sp5}: 1
Linyphiidae {Linyphiidae UAM Misc. Erigonine sp6}: 1
Linyphiidae {Linyphiidae UAM Misc. Erigonine sp7}: 1
Linyphiidae {Linyphiidae UAM Misc. Erigonine sp9}: 1
Linyphiidae {Linyphiidae UAM Misc. Linyphiiinae sp2}: 1
Linyphiidae {Linyphiidae UAM Misc. Styloctetor sp1}: 1
Linyphiidae {Linyphiidae UAM POW Erigonine sp2}: 1
Linyphiidae {Linyphiidae UAM POW Erigonine sp3}: 1
Linyphiidae {Linyphiidae UAM POW Erigonine sp4}: 1
Linyphiidae {Linyphiidae Wosnesenski Is 2}: 3
Phantyna {Phantyna sp1}: 1
Philodromus rufus pacificus: 3
Philodromus rufus quartus: 3
Scotinotylus monoceros: 2



Centromerus helsdingen = Oreonetides helsdingeni
Ceratinella innominabilis = Ceraticelus innominabilis
Scotinotylus monoceros = Coreorgonal monoceros

all of the latter names are already in Arctos.

Can you also update these with ID remarks that include the first name in quotes?

alter table temp_spider_rep add idremk varchar2(255);
update temp_spider_rep set species='Oreonetides helsdingeni', idremk='"Centromerus helsdingen"' where species='Centromerus helsdingen';
update temp_spider_rep set species='Ceraticelus innominabilis', idremk='"Ceratinella innominabilis"' where species='Ceratinella innominabilis';
update temp_spider_rep set species='Coreorgonal monoceros', idremk='"Scotinotylus monoceros"' where species='Scotinotylus monoceros';

alter table temp_spider_rep add tax varchar2(255);
update temp_spider_rep set tax=species;

update temp_spider_rep set species='Araneidae', tax='Araneidae' where species='Araenidae';
update temp_spider_rep set species='Hilaira herniosa', tax='Hilaira herniosa' where species='Hilaria herniosa';


update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Erigonine sp6}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Dall Is Erigonine #2}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM POW Erigonine sp2}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Agyneta Sp1}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM POW Erigonine sp3}';
update temp_spider_rep set tax='Phantyna' where species='Phantyna {Phantyna sp1}';
update temp_spider_rep set tax='Hilaira' where species='Hilaira {Hilaira sp 33243}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Erigonine sp5}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Styloctetor sp1}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Erigonine sp9}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Etolin Is Erigonine #1}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM POW Erigonine sp4}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Erigonine sp3}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Linyphiiinae sp2}';
update temp_spider_rep set tax='Emblyna' where species='Emblyna {Emblyna peragrata group}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Wosnesenski Is 2}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Buckle BC#11}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae UAM Misc. Erigonine sp7}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Dall Is Erigonine #3}';
update temp_spider_rep set tax='Linyphiidae' where species='Linyphiidae {Linyphiidae Buckle Erigonine "Flathead"}';
update temp_spider_rep set tax='Incestophantes' where species='Incestophantes {Incestophantes nr. washingtoni}';


select tax from temp_spider_rep where tax not in (select scientific_name from taxon_name);

create table temp_spider_rep_btaxu as select * from temp_spider_rep;

update temp_spider_rep set species=replace(species,tax) where species like '%{%';
update temp_spider_rep set species=replace(species,'{') where species like '%{%';
update temp_spider_rep set species=replace(species,'}') where species like '%}%';
update temp_spider_rep set species=trim(species);


update temp_spider_rep set tax=species where tax is null;





















update 
select tax from temp_spider_rep where tax not in (select scientific_name from taxon_name) group by tax;




dammit forgot to splice in NOTES!!

select count(*) from temp_spider_rep where notes is not null;
--->


<cfinclude template="/includes/_header.cfm">


<cfsetting requestTimeOut = "600">
	
	
<cfoutput>




		<cfquery name="d" datasource="uam_god">
			select newguid from temp_spider_rep_aftrsplit where species like '%{%'
		</cfquery>
		<cfloop query="d">
			<cfquery name="cid" datasource="uam_god">
				select 
					flat.collection_object_id,
					identification.identification_id,
					identification.scientific_name idsciname,
					taxon_name.scientific_name,
					flat.collection_object_id 
				from 
					flat,
					identification,
					identification_taxonomy,
					taxon_name
				where 
					guid='#newguid#' and
					flat.collection_object_id=identification.collection_object_id and
					accepted_id_fg=1 and
					identification.identification_id=identification_taxonomy.identification_id and
					identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id
			</cfquery>
			
						<cfquery name="cup" datasource="uam_god">
						update identification set scientific_name='#cid.scientific_name# #cid.idsciname#' where identification_id=#cid.identification_id#
						</cfquery>

			<br>#newguid#: 
		</cfloop>


<!---- fix a-string ID hosery ---->

<!----- repatriate notes
	
		<cfquery name="d" datasource="uam_god">
		select * from temp_spider_rep where done < 5 and notes is not null
	</cfquery>
	<cftransaction>
	<cfloop query="d">
	<hr>#newguid#
	<BR>#NOTES#
		<cfquery name="corm" datasource="uam_god">
			select * from coll_object_remark where collection_object_id=(select collection_object_id from flat where guid='#newguid#')
		</cfquery>
		<cfif corm.recordcount is 0>
		<br>new
			<cfquery name="irm" datasource="uam_god">
				insert into coll_object_remark (collection_object_id,COLL_OBJECT_REMARKS) values (
					(select collection_object_id from flat where guid='#newguid#'),
					'#notes#'
				)
			</cfquery>
		<cfelseif len(corm.COLL_OBJECT_REMARKS) is 0>
		<br>upnorem
			<cfquery name="urmn" datasource="uam_god">
				update coll_object_remark set COLL_OBJECT_REMARKS='#notes#' where collection_object_id=
				(select collection_object_id from flat where guid='#newguid#')
			</cfquery>
		<cfelse>
			<br>append
			<cfquery name="urma" datasource="uam_god">
				update coll_object_remark set COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; #notes#' where collection_object_id=
				(select collection_object_id from flat where guid='#newguid#')
			</cfquery>
		
		</cfif>
		<cfquery name="dn" datasource="uam_god">
			update temp_spider_rep set done=184 where newguid='#newguid#'
		</cfquery>
	</cfloop>
	</cftransaction>
	
	
	
	
	
	------------->
	<!----
	
	
	
		add attributes n IDs for spiders

	<cfquery name="d" datasource="uam_god">
		select * from temp_spider_rep where done is null and rownum<500
	</cfquery>
	
	<cftransaction>
	<cfloop query="d">
		<hr>running for #newguid#
		<cfquery name="thisCOID" datasource="uam_god">
			select collection_object_id from flat where guid='#newguid#'
		</cfquery>
		<cfquery name="remoldID" datasource="uam_god">
			update identification set accepted_id_fg=0 where collection_object_id=#thisCOID.collection_object_id#
		</cfquery>
		<cfif species is tax>
			<cfset ttf='A'>
		<cfelse>
			<cfset ttf='A {string}'>
		</cfif>
		
		<cfquery name="insNewID" datasource="uam_god">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				TAXA_FORMULA,
				SCIENTIFIC_NAME,
				IDENTIFICATION_REMARKS
			) values (
				sq_identification_id.nextval,
				#thisCOID.collection_object_id#,
				'#ID_DATE#',
				'#NATURE_OF_ID#',
				1,
				'#ttf#',
				'#SPECIES#',
				'#IDREMK#'
			)		
		</cfquery>
		
		<cfquery name="insNewIDT" datasource="uam_god">
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				(select taxon_name_id from taxon_name where scientific_name='#tax#'),
				'A'
			)
		</cfquery>
		<cfquery name="insNewIDA" datasource="uam_god">
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				getAgentID('#ID_BY#'),
				1
			)
		</cfquery>
		<cfquery name="roa" datasource="uam_god">
			delete from attributes where collection_object_id=#thisCOID.collection_object_id#
		</cfquery>
		<cfif len(f) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'sex',
					'female',
					'#f# females',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		
		<cfif len(m) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'sex',
					'male',
					'#m# males',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		
		<cfif len(j) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'age class',
					'juvenile',
					'#j# juveniles',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		<cfif len(PARTLOTCOUNT) gt 0>
			<cfquery name="splc" datasource="uam_god">
				update coll_object set lot_count=#PARTLOTCOUNT# where
				collection_object_id=(
					select collection_object_id from specimen_part where 
					derived_from_cat_item=#thisCOID.collection_object_id# and
					part_name like '%whole%'
				)
			</cfquery>
		</cfif>
		
		
		
		
		<p>
			running for #NEWGUID#
			<br>SPECIES: #SPECIES#
			<br>m: #m#
			<br>F: #F#
			<br>J: #J#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
			<br>NOTES: #NOTES#
			<br>ID_BY: #ID_BY#
			<br>ID_DATE: #ID_DATE#
			<br>NATURE_OF_ID: #NATURE_OF_ID#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
		</p>
		
		
		
	</cfloop>
</cftransaction>





 ---->
	<!----
	
	
	
	split lots as necessary - after this has all ran, should be a matter of updating rows
	
	
	
	
	<cfquery name="d" datasource="uam_god">
		select * from (select GUID,COUNT(*) C from temp_spider_rep where newguid is null GROUP BY GUID) where rownum<100
	</cfquery>
	<CFLOOP QUERY="D">
		<hr>
		<BR>#GUID#: #C#
		<cfif c is 1>
			<br>update newguid...
			
			<cfquery name="udg" datasource="uam_god">
				update temp_spider_rep set newguid=guid where guid='#guid#'
			</cfquery>

		<cfelse>
			<br>update newquid for ONE row, make some clones for the other c-1.....
			<cfquery name="thisguid" datasource="uam_god">
				select * from temp_spider_rep where guid='#guid#'
			</cfquery>
			
			<cfset lnum=1>
			<cfloop query ="thisguid">			
				<cfif lnum is 1>
					<br>update newguid for ONE row....
					<cfquery name="udg" datasource="uam_god">
						update temp_spider_rep set newguid=guid where key='#key#'
					</cfquery>
				<cfelse>
					<br>not row1 - make a clone and update newguid with a NEW guid.....
					<cfstoredproc RESULT="theproc" procedure="clone_cataloged_item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#"> 
						<cfprocparam cfsqltype="cf_sql_varchar" value="#guid#"> 
						<cfprocparam cfsqltype="cf_sql_varchar" type="out" variable="justmadethis"> 
					</cfstoredproc>
					<br>made new guid #justmadethis#
					<cfquery name="udg" datasource="uam_god">
						update temp_spider_rep set newguid='#justmadethis#' where key='#key#'
					</cfquery>
					<br>... and updated
				</cfif>
				<cfset lnum=lnum+1>
			</cfloop>
		</cfif>
	</CFLOOP>
	
	
	
	----->
	
	
<!----


split paired quids into individual rows


run this, then delete the paired now-redundant paired guid rows


delete from temp_spider_rep where guid like '%,%';

and some cleanup

uam@ARCTOSNEW> delete from temp_spider_rep where guid not like '%:%';

4 rows deleted.

Elapsed: 00:00:00.01
uam@ARCTOSNEW> delete from temp_spider_rep where guid is null;





	<cfquery name="d" datasource="uam_god">
		select * from temp_spider_rep where guid like '%,%'
	</cfquery>
	<cfloop query="d">
		<br>#guid#
		<cfset g1=listgetat(guid,1)>
		<cfset g2=listgetat(guid,2)>
		
		<cfquery name="new1" datasource="uam_god">
			insert into temp_spider_rep (
				GUID,
				UAM_BARCODE,
				SPECIES,
				M,
				F,
				J,
				PARTLOTCOUNT,
				NOTES,
				ID_BY,
				ID_DATE,
				NATURE_OF_ID
			) values (
				'#g1#',
				'#UAM_BARCODE#',
				'#SPECIES#',
				'#M#',
				'#F#',
				'#J#',
				'#PARTLOTCOUNT#',
				'#NOTES#',
				'#ID_BY#',
				'#ID_DATE#',
				'#NATURE_OF_ID#'
			)
		</cfquery>
		<cfquery name="new2" datasource="uam_god">
			insert into temp_spider_rep (
				GUID,
				UAM_BARCODE,
				SPECIES,
				M,
				F,
				J,
				PARTLOTCOUNT,
				NOTES,
				ID_BY,
				ID_DATE,
				NATURE_OF_ID
			) values (
				'#g2#',
				'#UAM_BARCODE#',
				'#SPECIES#',
				'#M#',
				'#F#',
				'#J#',
				'#PARTLOTCOUNT#',
				'#NOTES#',
				'#ID_BY#',
				'#ID_DATE#',
				'#NATURE_OF_ID#'
			)
		</cfquery>
		
	</cfloop>

---->

	<!---- 
	
	
	
	add attributes n IDs for unspiders 

	<cfquery name="d" datasource="uam_god">
		select * from temp_unspider where done is null
	</cfquery>
	
	<cftransaction>
	<cfloop query="d">
		<hr>running for #newguid#
		<cfquery name="thisCOID" datasource="uam_god">
			select collection_object_id from flat where guid='#newguid#'
		</cfquery>
		<cfquery name="remoldID" datasource="uam_god">
			update identification set accepted_id_fg=0 where collection_object_id=#thisCOID.collection_object_id#
		</cfquery>
		
		
		<cfquery name="insNewID" datasource="uam_god">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				TAXA_FORMULA,
				SCIENTIFIC_NAME
			) values (
				sq_identification_id.nextval,
				#thisCOID.collection_object_id#,
				'#ID_DATE#',
				'#NATURE_OF_ID#',
				1,
				'A',
				'#SPECIES#'
			)		
		</cfquery>
		<cfquery name="insNewIDT" datasource="uam_god">
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				(select taxon_name_id from taxon_name where scientific_name='#SPECIES#'),
				'A'
			)
		</cfquery>
		<cfquery name="insNewIDA" datasource="uam_god">
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				getAgentID('#ID_BY#'),
				1
			)
		</cfquery>
		<cfquery name="roa" datasource="uam_god">
			delete from attributes where collection_object_id=#thisCOID.collection_object_id#
		</cfquery>
		<cfif len(f) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'sex',
					'female',
					'#f# females',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		
		<cfif len(m) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'sex',
					'male',
					'#m# males',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		
		<cfif len(j) gt 0>
			<cfquery name="inf" datasource="uam_god">
				insert into attributes (
					ATTRIBUTE_ID,
					COLLECTION_OBJECT_ID,
					DETERMINED_BY_AGENT_ID,
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_REMARK,
					DETERMINED_DATE
				) values (
					sq_ATTRIBUTE_ID.nextval,
					#thisCOID.collection_object_id#,
					getAgentID('#ID_BY#'),
					'age class',
					'juvenile',
					'#j# juveniles',
					'#ID_DATE#'
				)
			</cfquery>
		</cfif>
		<cfif len(PARTLOTCOUNT) gt 0>
			<cfquery name="splc" datasource="uam_god">
				update coll_object set lot_count=#PARTLOTCOUNT# where
				collection_object_id=(select collection_object_id from specimen_part where derived_from_cat_item=#thisCOID.collection_object_id#)
			</cfquery>
		</cfif>
		
		
		
		
		<p>
			running for #NEWGUID#
			<br>SPECIES: #SPECIES#
			<br>m: #m#
			<br>F: #F#
			<br>J: #J#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
			<br>NOTES: #NOTES#
			<br>ID_BY: #ID_BY#
			<br>ID_DATE: #ID_DATE#
			<br>NATURE_OF_ID: #NATURE_OF_ID#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
			<br>PARTLOTCOUNT: #PARTLOTCOUNT#
		</p>
		
		
		<cfquery name="dn" datasource="uam_god">
		update temp_unspider set done=1 where newguid='#newguid#'
	</cfquery>
	</cfloop>
</cftransaction>


-------------->
	<!-----
	
	
	clone the spider-unspiders
	
	
	<cfquery name="d" datasource="uam_god">
		select * from temp_unspider where newguid is null and rownum<20
	</cfquery>
	
	<cfloop query="d">
		<br>#GUID#
		<cfquery name="isop" datasource="uam_god">
			select scientific_name from flat where guid='#guid#'
		</cfquery>
		<cfif isop.scientific_name is "Opiliones">
			<p>just add an ID</p>
			<cfquery name="ng" datasource="uam_god">
				update temp_unspider set newguid='#guid#' where guid='#guid#'
			</cfquery>

		<cfelse>
		
			<cftransaction>
			
			
			<cfstoredproc RESULT="theproc" procedure="clone_cataloged_item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#"> 
				<cfprocparam cfsqltype="cf_sql_varchar" value="#guid#"> 
				<cfprocparam cfsqltype="cf_sql_varchar" type="out" variable="justmadethis"> 
			</cfstoredproc>
			
			
			<cfdump var=#theproc#>
			<cfdump var=#justmadethis#>
			
			<cfif len(justmadethis) is 0>
				<cftransaction action="rollback">
				
				rolled back transaction because did not get justmadethis
			</cfif>
		
		
			</cftransaction>
			
			
			
			<cfquery name="ng" datasource="uam_god">
				update temp_unspider set newguid='#justmadethis#' where guid='#guid#'
			</cfquery>
			
			<p>
				made #justmadethis#
			</p>
			
				<p>#isop.scientific_name# - need to clone into new GUID, THEN add ID to the NEW guid - this guid can be ignored after the cloning</p>
		
		</cfif>

	</cfloop>
	
	
	----->
</cfoutput>