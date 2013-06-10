<!---
create table tacc_folder (
	folder varchar2(255),
	file_count number
	);

create table tacc_check (
	collection_object_id number,
	barcode varchar2(255),
	folder varchar2(255),
	chkdate date default sysdate)
	;

create table tacc (
	fullpath varchar2(4000),
	filename varchar2(255),
	filetype varchar2(255),
	lastdate date default sysdate,
	crawled_path_date date,
	collection_object_id number,
	status varchar2(255)
);

create unique index iu_tacc_fullpath on tacc (fullpath) tablespace uam_idx_1;


	select folder ||chr(9) || barcode from tacc_check where barcode in ( select barcode from tacc_check having count(barcode) > 1 group by barcode)
	order by barcode;

--->
<cfsetting requesttimeout="6000">


<!-------------------------- some functions to simplify things ----------------------------------->
<cffunction name="getTnPath">
	<cfargument name="inpStr" type="string" required="yes">
	<cfset filename=listfirst(listlast(inpStr,"/"),".")>
	<cfset tnPath=replace(inpStr,"#filename#.dng","jpegs/tn_#filename#.jpg")>
	<cfreturn "http://web.corral.tacc.utexas.edu/UAF/" & tnPath>
</cffunction>
<cffunction name="getJpgPath">
	<cfargument name="inpStr" type="string" required="yes">
	<cfset filename=listfirst(listlast(inpStr,"/"),".")>
	<cfset jpgPath=replace(inpStr,"#filename#.dng","jpegs/#filename#.jpg")>
	<cfreturn "http://web.corral.tacc.utexas.edu/UAF/" & jpgPath>
</cffunction>
<cffunction name="getFiletype">
	<cfargument name="inpStr" type="string" required="yes">
	<cfset elem=listlast(inpStr,"/")>
	<cfif elem contains ".">
		<cfif left(elem,3) is "tn_">
			<cfreturn "tn">
		<cfelse>
			<cfreturn trim(listlast(elem,"."))>
		</cfif>
	<cfelseif elem is "Parent Directory">
		<cfreturn "j">
	<cfelse>
		<cfreturn "d">
	</cfif>
</cffunction>
<cffunction name="getFileName">
	<cfargument name="inpStr" type="string" required="yes">
	<cfset elem=listlast(inpStr,"/")>
	<cfif elem contains ".">
		<cfreturn trim(listfirst(elem,"."))>
	</cfif>
	<cfreturn "FAIL">
</cffunction>
<cffunction name="getDescr">
	<cfargument name="collection_object_id" required="true" type="numeric">
	<cfquery name="ala" datasource="uam_god">
		 select
			decode(ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC'),
				null,'UAM:Herb:' || cat_num || ' (ALA)',
				'ALA ' || ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC')
			)  || ': ' ||
			get_taxonomy(coll_obj_other_id_num.collection_object_id,'display_name') descr
		from
			coll_obj_other_id_num,
			cataloged_item
		where
			cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
			other_id_type='ALAAC' and
			coll_obj_other_id_num.collection_object_id=#collection_object_id#
	</cfquery>
	<cfif ala.recordcount is not 1>
		<cfquery name="ala" datasource="uam_god">
			select
				decode(ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC'),
					null,'UAM:Herb:' || cat_num || ' (ALA)',
					'ALA ' || ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC')
				)  || ': ' ||
				get_taxonomy(coll_obj_other_id_num.collection_object_id,'display_name') descr
			from
				coll_obj_other_id_num,
				cataloged_item
			where
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				other_id_type='ISC: Ada Hayden Herbarium, Iowa State University' and
				coll_obj_other_id_num.collection_object_id=#collection_object_id#
		</cfquery>
	</cfif>
	<cfif ala.recordcount is 1>
		<cfreturn ala.descr>
	<cfelse>
		<cfreturn "descr_not_found">
	</cfif>
</cffunction>


<!-------------------------- some functions to simplify things ----------------------------------->







<!----------------------------------------- nothing  --------------------------------------------->
<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfif action is "nothing">
	<br><a href="tacc.cfm?action=findAllDirectories">findAllDirectories</a>
	<br><a href="tacc.cfm?action=findFilesOnePath">findFilesOnePath</a>
	<br><a href="tacc.cfm?action=linkToSpecimens">linkToSpecimens</a>
	<br><a href="tacc.cfm?action=makeDNGMedia">makeDNGMedia</a>
	<br><a href="tacc.cfm?action=makeJPGMedia">makeJPGMedia</a>
</cfif>
<!----------------------------------------- findAllDirectories  --------------------------------------------->
<cfif action is "findAllDirectories">
	<cfoutput>
	<cfset dirs=arraynew(1)>
	<cfhttp url="http://web.corral.tacc.utexas.edu/UAF" charset="utf-8" method="get"></cfhttp>
	<cfif left(cfhttp.statuscode,3) is "200" and isXML(cfhttp.FileContent)>
		<cfset xdir=xmlparse(trim(replace(cfhttp.FileContent,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')))>
		<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
		<cfset cPath=replace(xdir.html.head.title.xmlText,"Index of /UAF/","")>
		<cfloop index="i" from="1" to="#arrayLen(dir)#">
			<cfset f = dir[i].XmlChildren[1].xmlText>
			<cfif getFiletype(f) is "d">
				<cfset arrayappend(dirs,"#cPath##f#")>
				<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/#cPath##f#" charset="utf-8" method="get"></cfhttp>
				<cfif left(cfhttp.statuscode,3) is "200" and isXML(cfhttp.FileContent)>
					<cfset xdir2=XMLparse(trim(replace(cfhttp.FileContent,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')))>
					<cfset dir2 = xmlsearch(xdir2, "//td[@class='n']")>
					<cfset cPath2=replace(xdir2.html.head.title.xmlText,"Index of /UAF/","")>
					<cfloop index="i" from="1" to="#arrayLen(dir2)#">
						<cfset f2 = dir2[i].XmlChildren[1].xmlText>
						<cfif getFiletype(f2) is "d">
							<cfset arrayAppend(dirs,"#cPath2##f2#")>
							<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/#cPath2##f2#" charset="utf-8" method="get"></cfhttp>
							
							<cftry>
							
								<cfset xdir3=XMLparse(trim(replace(cfhttp.FileContent,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')))>
								<cfset dir3=xmlsearch(xdir3, "//td[@class='n']")>
								<cfset cPath3=replace(xdir3.html.head.title.xmlText,"Index of /UAF/","")>
								<cfloop index="i" from="1" to="#arrayLen(dir3)#">
									<cfset f3 = dir3[i].XmlChildren[1].xmlText>
									<cfif getFiletype(f3) is "d">
										<cfset arrayAppend(dirs,"#cPath3##f3#")>
										<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/#cPath3##f3#" charset="utf-8" method="get"></cfhttp>
										<cfset xdir4= xmlparse(trim(replace(cfhttp.FileContent,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')))>
										<cfset dir4=xmlsearch(xdir4, "//td[@class='n']")>
										<cfset cPath4=replace(xdir4.html.head.title.xmlText,"Index of /UAF/","")>
										<cfloop index="i" from="1" to="#arrayLen(dir4)#">
											<cfset f4 = dir4[i].XmlChildren[1].xmlText>
											<cfif getFiletype(f4) is "d">
												<cfset arrayAppend(dirs,"#cPath4##f4#")>
											</cfif>
										</cfloop>
									</cfif>
								</cfloop>
								<cfcatch>
									<p>
										Error with http://web.corral.tacc.utexas.edu/UAF/#cPath2##f2#
										
										<cfdump var=#cfcatch#>
										
										<cfdump var=#cfhttp#>
									</p>
								</cfcatch>
							</cftry>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="exist" datasource="uam_god">
		select FULLPATH from tacc where FILETYPE = 'path'
	</cfquery>
	<cfloop query="exist">
		<cfif arrayfind(dirs,#fullpath#)>
			<cfset arrayDeleteAt(dirs,arrayfind(dirs,#fullpath#))>
		</cfif>
	</cfloop>
	<cfloop index="i" from="1" to="#arrayLen(dirs)#">
		<cfquery name="exist" datasource="uam_god">
			insert into tacc (
				fullpath,
				filetype
			) values (
				'#dirs[i]#',
				'path'
			)
		</cfquery>
	</cfloop>
	</cfoutput>
</cfif>
<!----------------------------------------- findFilesOnePath  --------------------------------------------->
<cfif action is "findFilesOnePath">
	<cfoutput>
		#now()#
		<cfquery name="path" datasource="uam_god">
			select fullpath from tacc where
			filetype='path' and
			(
				crawled_path_date is null 
				 --or round(sysdate-crawled_path_date) > 10
			) and
			rownum=1
		</cfquery>
		<cfset files=arraynew(1)>
		<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/#path.fullpath#" charset="utf-8" method="get"></cfhttp>
		<cfif left(cfhttp.statuscode,3) is "200" and isXML(cfhttp.FileContent)>
			<br>isxml
			<cfset xdir=xmlparse(trim(replace(cfhttp.FileContent,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')))>
			<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
			<cfset cPath=replace(xdir.html.head.title.xmlText,"Index of /UAF/","")>
			<cfloop index="i" from="1" to="#arrayLen(dir)#">
				<cfset f = dir[i].XmlChildren[1].xmlText>
				<cfif getFiletype(f) is "dng">
					<cfset arrayAppend(files,"#cPath##f#")>
				</cfif>
			</cfloop>
		</cfif>
		<cfquery name="c" datasource="uam_god">
			select * from tacc where lower(filetype)='dng' and
			fullpath like '#path.fullpath#%'
		</cfquery>
		
		<cfloop query="c">
			<cfif arrayfind(files,#fullpath#)>
				<cfset arrayDeleteAt(files,arrayfind(files,#fullpath#))>
			</cfif>
		</cfloop>
		<cfloop index="i" from="1" to="#arrayLen(files)#">
			<cftry>
			<cfquery name="exist" datasource="uam_god">
				insert into tacc (
					fullpath,
					filename,
					filetype
				) values (
					'#files[i]#',
					trim('#getFileName(files[i])#'),
					'dng'
				)
			</cfquery>
			<cfcatch>
				<cfdump var="#cfcatch#">
			</cfcatch>
			</cftry>
		</cfloop>
		
					update tacc set crawled_path_date=sysdate where fullpath='#path.fullpath#'

		<cfquery name="udcd" datasource="uam_god">
			update tacc set crawled_path_date=sysdate where fullpath='#path.fullpath#'
		</cfquery>
	</cfoutput>
</cfif>
<!----------------------------------------- linkToSpecimens  --------------------------------------------->
<cfif action is "linkToSpecimens">
	<cfoutput>
		<cfquery name="data" datasource="uam_god">
			select
				filename,
				fullpath
			from
				tacc
			where
				filetype='dng' and
				collection_object_id is null and
				status is null
		</cfquery>
		<cfloop query="data">
			<cftransaction >
			<cfquery name="bc" datasource="uam_god">
				select
					cataloged_item.collection_object_id,
					cataloged_item.collection_id
				from
					cataloged_item,
					specimen_part,
					coll_obj_cont_hist,
					container pc,
					container prnt
				where
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id = pc.container_id and
					cataloged_item.collection_id in (6,40) and
					pc.parent_container_id = prnt.container_id and
					prnt.barcode='#listgetat(filename,1,"_")#'
			</cfquery>
			<cfif bc.recordcount is 1 and len(bc.collection_object_id) gt 0>
				<cfquery name="data" datasource="uam_god">
					update tacc set collection_object_id=#bc.collection_object_id# where filename='#filename#'
				</cfquery>
				<cfquery name="ixrel" datasource="uam_god">
					select count(*) c from coll_obj_other_id_num where id_references != 'self' and
					collection_object_id = #bc.collection_object_id#
				</cfquery>
				<cfif ixrel.c neq 0>
					<cfquery name="izaplant" datasource="uam_god">
						update tacc set status='in_relations' where filename='#filename#'
					</cfquery>
				</cfif>
			<cfelseif bc.recordcount gt 1>
				<cfquery name="data" datasource="uam_god">
					update tacc set status='specimencount: #bc.recordcount#' where filename='#filename#'
				</cfquery>
			<cfelse>
				<cfquery name="data" datasource="uam_god">
					update tacc set status='plant_specimen_not_found' where filename='#filename#'
				</cfquery>
			</cfif>
			</cftransaction>
		</cfloop>
	</cfoutput>
</cfif>
<!----------------------------------------- makeDNGMedia  --------------------------------------------->
<cfif action is "makeDNGMedia">
	<cfoutput>
		<cfquery name="data" datasource="uam_god">
			select *
			from
				tacc
			where
				filetype='dng' and
				collection_object_id > 0 and
				status is null and
				rownum<10000
		</cfquery>
		<cfloop query="data">
			<cfset go=true>
			<cfquery name="izadup" datasource="uam_god">
				select count(*) c from media where media_uri like '%#filename#.dng'
			</cfquery>
			<cfif izadup.c neq 0>
				<cfset go=false>
				<cfquery name="izaplant" datasource="uam_god">
					update tacc set status='dng_created' where filename='#filename#'
				</cfquery>
			</cfif>
			<cfset descr=getDescr(collection_object_id)>
			<cfif descr is "descr_not_found">
				<cfset go=false>
				<cfquery name="izaplant" datasource="uam_god">
					update tacc set status='#descr#' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif>
			<cfif go is true>
				<cftransaction>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset muri='http://web.corral.tacc.utexas.edu/UAF/#fullpath#'>
					<cfquery name="media" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type
						) values (
							#nid.media_id#,
							'#muri#',
							'#getTnPath(fullpath)#',
							'image/dng',
							'image'
						)
					</cfquery>
					<cfquery name="mr_cat" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#nid.media_id#,
							'shows cataloged_item',
							2072,
							#collection_object_id#
						)
					</cfquery>
					<cfquery name="mr_agnt" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#nid.media_id#,
							'created by agent',
							2072,
							1016226
						)
					</cfquery>
					<cfquery name="lbl" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#nid.media_id#,
							'description',
							'#ala.descr#',
							2072
						)
					</cfquery>
					<br>made #ala.descr#
					<cfquery name="spiffy" datasource="uam_god">
						update tacc set status='dng_created' where collection_object_id=#collection_object_id#
					</cfquery>
				</cftransaction>
			</cfif>

		</cfloop>
	</cfoutput>
</cfif>
<!----------------------------------------- makeJPGMedia  --------------------------------------------->
<cfif action is "makeJPGMedia">
	<cfoutput>
		<cfquery name="data" datasource="uam_god">
			select *
			from
				tacc
			where
				status='dng_created' and
				rownum<501
		</cfquery>
		<hr>
		<br>data.recordcount: #data.recordcount#
		<cfloop query="data">
			<cfset go=true>
			<cfquery name="dng_id" datasource="uam_god">
				select
					media.media_id
				from
					media,
					media_relations
				where
					media.media_id = media_relations.media_id and
					media_relationship='shows cataloged_item' and
					related_primary_key=#collection_object_id# and
					media_uri='http://web.corral.tacc.utexas.edu/UAF/#fullpath#'
			</cfquery>
			<cfif len(dng_id.media_id) is 0 or dng_id.recordcount is not 1>
				<cfquery name="fail" datasource="uam_god">
					update tacc set status='dng_media_not_found' where collection_object_id=#collection_object_id#
				</cfquery>
				<cfset go=false>
				<br>bad DNG
			</cfif>
			<cfset descr=getDescr(collection_object_id)>
			<cfif descr is "descr_not_found">
				<cfset go=false>
				<cfquery name="izaplant" datasource="uam_god">
					update tacc set status='#descr#' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif>
			<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/#fullpath#" charset="utf-8" method="head"></cfhttp>
			<cfif left(cfhttp.statusCode,3) is not "200">
				<cfset go=false>
				<cfquery name="fail" datasource="uam_god">
					update tacc set status='dng_not_found_for_jpg' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif>
			<cfset jpgPath=getJpgPath(fullpath)>
			<cfhttp url="#jpgPath#" charset="utf-8" method="head"></cfhttp>
			<cfif left(cfhttp.statusCode,3) is not "200">
				<cfset go=false>
				<cfquery name="fail" datasource="uam_god">
					update tacc set status='jpg_not_found_for_jpg' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif>
			<cfset tnPath=getTnPath(fullpath)>
			<cfhttp url="#tnPath#" charset="utf-8" method="head"></cfhttp>
			<cfif left(cfhttp.statusCode,3) is not "200">
				<cfset go=false>
				<cfquery name="fail" datasource="uam_god">
					update tacc set status='tn_not_found_for_jpg' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif>
			<cfif go is true>
				<cftransaction>
					<cftry>
						<cfquery name="nid" datasource="uam_god">
							select sq_media_id.nextval media_id from dual
						</cfquery>
						<cfquery name="media" datasource="uam_god">
							insert into media (
								media_id,
								media_uri,
								preview_uri,
								mime_type,
								media_type
							) values (
								#nid.media_id#,
								'#jpgPath#',
								'#tnPath#',
								'image/jpeg',
								'image'
							)
						</cfquery>
						<cfquery name="mr_cat" datasource="uam_god">
							insert into media_relations (
								MEDIA_ID,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#nid.media_id#,
								'shows cataloged_item',
								2072,
								#collection_object_id#
							)
						</cfquery>
						<cfquery name="mr_agnt" datasource="uam_god">
							insert into media_relations (
								MEDIA_ID,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#nid.media_id#,
								'created by agent',
								2072,
								1016226
							)
						</cfquery>
						<cfquery name="mr_media" datasource="uam_god">
							insert into media_relations (
								MEDIA_ID,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#nid.media_id#,
								'derived from media',
								2072,
								#dng_id.media_id#
							)
						</cfquery>
						<cfquery name="lbl" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#nid.media_id#,
								'description',
								'#descr#',
								2072
							)
						</cfquery>
						<cfquery name="spiffy" datasource="uam_god">
							update tacc set status='all_done' where collection_object_id=#collection_object_id#
						</cfquery>
						<cfcatch>
							<cfquery name="notspiffy" datasource="uam_god">
								update tacc set status='fail_at_jpg: #cfcatch.message#' where collection_object_id=#collection_object_id#
							</cfquery>
						</cfcatch>
					</cftry>
				</cftransaction>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>