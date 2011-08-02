<!---
	These scripts create Arctos data from data created from the imager and
	files @tacc. Assumptions:
	
	Everything is in http://web.corral.tacc.utexas.edu/UAF/es/yyyy_mm_dd folders
	The folder and all it's contents will be created at once, and will not be subsequently
	modified. Folder contents are:
		xxxxx.dng
		jpegs
			xxxxx.jpg
			tn_xxxx.jpg
	
	And a table for the actual files. "imgname" is one of:
		barcode.[dng|jpg]
		barcode_[1-99].[dng|jpg]
		
	create table es_img (
		imgname varchar2(255),
		folder varchar2(255),
		status varchar2(255),
		chkdate date default sysdate
	);
	
	delete from es_img;
	
	create unique index ui_es_img_imgname on es_img(imgname) tablespace uam_idx_1;
	alter table es_img modify imgname not null;
	

--->
<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfoutput>
	#action#
	<cfif action is "nothing">
		<br><a href="es_tacc.cfm?action=getDir">getDir</a>
		<br><a href="es_tacc.cfm?action=accn_card_media">accn_card_media</a>
		<br><a href="es_tacc.cfm?action=loc_card_media">loc_card_media</a>
		<br><a href="es_tacc.cfm?action=spec_media">spec_media</a>
		<br><a href="es_tacc.cfm?action=status">status</a>
		
	</cfif>
	<!---------------------------------------------------------------------------------------->
	<cfif action is "spec_media">
		<!--- grab everything --->
		<cfquery name="d" datasource="uam_god">
			select * from es_img where status is null and rownum<2
		</cfquery>
		<cfloop query="d">
			<br>imgname: #imgname#
			<cfset barcode=listgetat(imgname,1,"_")>
			<br>barcode: #barcode#
			<cfquery name="acn" datasource="uam_god">
				select * from spec_scan where barcode='#barcode#'
			</cfquery>
			<cfif acn.recordcount gt 0>
				<cftransaction>
					<!--- create media --->
					<cfset d_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/#imgname#.dng'>
					<cfset j_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/#imgname#.jpg'>
					<cfset t_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/tn_#imgname#.jpg'>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset dng_id=nid.media_id>
					<!--- create the following media/etc:
						DNG
						JPG
						JPG "derived from media" DNG relationship
						JPG "documents accn" relationship
						DNG "created by agent" relationship
						JPG "bla bla locality ID" label
					--->
					<cfquery name="dmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#dng_id#,
							'#d_uri#',
							'#t_uri#',
							'image/dng',
							'image',
							7
						)
					</cfquery>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset jpg_id=nid.media_id>
					<cfquery name="jmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#jpg_id#,
							'#j_uri#',
							'#t_uri#',
							'image/jpeg',
							'image',
							7
						)
					</cfquery>
					<cfquery name="mr_mder" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'derived from media',
							2072,
							#dng_id#
						)
					</cfquery>
					<cfquery name="mr_macn" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'shows cataloged_item',
							2072,
							#acn.collection_object_id#
						)
					</cfquery>
					<cfquery name="mr_dcr" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#dng_id#,
							'created by agent',
							2072,
							21253238
						)
					</cfquery>
					<cfquery name="lbl_b" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#jpg_id#,
							'barcode',
							'#barcode#',
							2072
						)
					</cfquery>
					
					<cfif left(acn.idnum,7) is "UAM:ES:">
						<cfquery name="drn" datasource="uam_god">
							select scientific_name from flat where guid='#acn.idnum#'
						</cfquery>
						<cfset descr='#acn.idnum#: #drn.scientific_name#'>
					<cfelse>
						<cfset descr='UAM ES #acn.idnum#: #acn.taxon_name#'>
					</cfif>
					<cfquery name="lbl_b" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#jpg_id#,
							'description',
							'#descr#',
							2072
						)
					</cfquery>
					<cfquery name="fg" datasource="uam_god">
						update es_img set status='created_media' where imgname='#imgname#'
					</cfquery>
				</cftransaction>			
			</cfif>			
		</cfloop>
	</cfif>
	<!---------------------------------------------------------------------------------------->
	<cfif action is "loc_card_media">
		<!--- grab everything --->
		<cfquery name="d" datasource="uam_god">
			select * from es_img where status is null and rownum<1000
		</cfquery>
		<cfloop query="d">
			<br>#imgname#
			<cfset barcode=listgetat(imgname,1,"_")>
			<br>#barcode#
			<cfquery name="acn" datasource="uam_god">
				select * from loc_card_scan where barcode='#barcode#'
			</cfquery>
			<cfif acn.recordcount gt 0>
				<cftransaction>
					<!--- create media --->
					<cfset d_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/#imgname#.dng'>
					<cfset j_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/#imgname#.jpg'>
					<cfset t_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/tn_#imgname#.jpg'>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset dng_id=nid.media_id>
					<!--- create the following media/etc:
						DNG
						JPG
						JPG "derived from media" DNG relationship
						JPG "documents accn" relationship
						DNG "created by agent" relationship
						JPG "bla bla locality ID" label
					--->
					<cfquery name="dmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#dng_id#,
							'#d_uri#',
							'#t_uri#',
							'image/dng',
							'image',
							7
						)
					</cfquery>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset jpg_id=nid.media_id>
					<cfquery name="jmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#jpg_id#,
							'#j_uri#',
							'#t_uri#',
							'image/jpeg',
							'image',
							7
						)
					</cfquery>
					<cfquery name="mr_mder" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'derived from media',
							2072,
							#dng_id#
						)
					</cfquery>
					<cfquery name="mr_macn" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'documents accn',
							2072,
							#acn.accn_id#
						)
					</cfquery>
					<cfquery name="mr_dcr" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#dng_id#,
							'created by agent',
							2072,
							21253238
						)
					</cfquery>
					<cfif len(acn.localityID) gt 0>
						<cfquery name="lbl_d" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#jpg_id#,
								'description',
								'UAM/AK LocalityID #acn.localityID# Locality card',
								2072
							)
						</cfquery>
					</cfif>
					<cfif len(acn.age) gt 0>
						<cfquery name="lbl_d" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#jpg_id#,
								'Stage/Age',
								'#acn.age#',
								2072
							)
						</cfquery>
					</cfif>
					<cfif len(acn.formation) gt 0>
						<cfquery name="lbl_d" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#jpg_id#,
								'Formation',
								'#acn.formation#',
								2072
							)
						</cfquery>
					</cfif>
					<cfif len(acn.SeriesEpoch) gt 0>
						<cfquery name="lbl_d" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#jpg_id#,
								'Series/Epoch',
								'#acn.SeriesEpoch#',
								2072
							)
						</cfquery>
					</cfif>
					<cfif len(acn.SystemPeriod) gt 0>
						<cfquery name="lbl_d" datasource="uam_god">
							insert into  media_labels (
								MEDIA_ID,
								MEDIA_LABEL,
								LABEL_VALUE,
								ASSIGNED_BY_AGENT_ID
							) values (
								#jpg_id#,
								'System/Period',
								'#acn.SystemPeriod#',
								2072
							)
						</cfquery>
					</cfif>
					<cfquery name="lbl_b" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#jpg_id#,
							'barcode',
							'#barcode#',
							2072
						)
					</cfquery>
					<cfquery name="fg" datasource="uam_god">
						update es_img set status='created_media' where imgname='#imgname#'
					</cfquery>
				</cftransaction>			
			</cfif>			
		</cfloop>
	</cfif>
	<!---------------------------------------------------------------------------------------->
	<cfif action is "accn_card_media">
		<!--- grab everything --->
		<cfquery name="d" datasource="uam_god">
			select * from es_img where status is null and rownum<1000
		</cfquery>
		<cfloop query="d">
			<br>#imgname#
			<cfset barcode=listgetat(imgname,1,"_")>
			<br>#barcode#
			<cfquery name="acn" datasource="uam_god">
				select * from accn_scan where barcode='#barcode#'
			</cfquery>
			<cfif acn.recordcount gt 0>
				<cftransaction>
					<cftry>
					<!--- create media --->
					<cfset d_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/#imgname#.dng'>
					<cfset j_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/#imgname#.jpg'>
					<cfset t_uri='http://web.corral.tacc.utexas.edu/UAF/es/#folder#/jpegs/tn_#imgname#.jpg'>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset dng_id=nid.media_id>
					<!--- create the following media/etc:
						DNG
						JPG
						JPG "derived from media" DNG relationship
						JPG "documents accn" relationship
						DNG "created by agent" relationship
						JPG "bla bla accn_number" label
					--->
					<cfquery name="dmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#dng_id#,
							'#d_uri#',
							'#t_uri#',
							'image/dng',
							'image',
							7
						)
					</cfquery>
					<cfquery name="nid" datasource="uam_god">
						select sq_media_id.nextval media_id from dual
					</cfquery>
					<cfset jpg_id=nid.media_id>
					<cfquery name="jmedia" datasource="uam_god">
						insert into media (
							media_id,
							media_uri,
							preview_uri,
							mime_type,
							media_type,
							media_license_id
						) values (
							#jpg_id#,
							'#j_uri#',
							'#t_uri#',
							'image/jpeg',
							'image',
							7
						)
					</cfquery>
					<cfquery name="mr_mder" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'derived from media',
							2072,
							#dng_id#
						)
					</cfquery>
					<cfquery name="mr_macn" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#jpg_id#,
							'documents accn',
							2072,
							#acn.accn_id#
						)
					</cfquery>
					<cfquery name="mr_dcr" datasource="uam_god">
						insert into media_relations (
							MEDIA_ID,
							MEDIA_RELATIONSHIP,
							CREATED_BY_AGENT_ID,
							RELATED_PRIMARY_KEY
						) values (
							#dng_id#,
							'created by agent',
							2072,
							21253238
						)
					</cfquery>
					<cfquery name="lbl_d" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#jpg_id#,
							'description',
							'UAM ES accession #acn.accn_number# accession card',
							2072
						)
					</cfquery>
					<cfquery name="lbl_b" datasource="uam_god">
						insert into  media_labels (
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							#jpg_id#,
							'barcode',
							'#barcode#',
							2072
						)
					</cfquery>
					<cfquery name="fg" datasource="uam_god">
						update es_img set status='created_media' where imgname='#imgname#'
					</cfquery>
					<cfcatch>
						<cftransaction action="rollback">
						<cfquery name="fg" datasource="uam_god">
							update es_img set status='#cfcatch.detail#' where imgname='#imgname#'
						</cfquery>
					</cfcatch>
					</cftry>
				</cftransaction>			
			</cfif>			
		</cfloop>
	</cfif>
	<!---------------------------------------------------------------------------------------->
	<cfif action is "getDir">
		<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/es" charset="utf-8" method="get">
		</cfhttp>
		<cfif isXML(cfhttp.FileContent)>
			<cfset xStr=cfhttp.FileContent>
			<!--- goddamned xmlns bug in CF --->
			<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
			<cfset xdir=xmlparse(xStr)>
			<cfset dir = xmlsearch(xdir, "//td[@class='n']")>	
			<cfloop index="i" from="1" to="#arrayLen(dir)#">
				<cfset folder = dir[i].XmlChildren[1].xmlText>
				<br>folder: #folder#
				<cfif len(folder) is 10 and listlen(folder,"_") is 3><!--- probably a yyyy_mm_dd folder --->
					<cfquery name="gotFolder" datasource="uam_god">
						select count(*) c from es_img where folder='#folder#'		
					</cfquery>
					<!---
					<cfquery name="gotFile" datasource="uam_god">
						select count(distinct(imgname)) cbc from es_img where folder='#folder#'			
					</cfquery>
					--->
					<cfif gotFolder.c is 0><!--- been here? --->
						<br>fetching http://web.corral.tacc.utexas.edu/UAF/es/#folder#
						<cfhttp url="http://web.corral.tacc.utexas.edu/UAF/es/#folder#" charset="utf-8" method="get"></cfhttp>
						<cfset ximgStr=cfhttp.FileContent>
						<!--- goddamned xmlns bug in CF --->
						<cfset ximgStr = replace(ximgStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
						<cfset xImgAll=xmlparse(ximgStr)>
						<cfset xImage = xmlsearch(xImgAll, "//td[@class='n']")>
						<cfloop index="i" from="1" to="#arrayLen(xImage)#">
							<cfset fname = xImage[i].XmlChildren[1].xmlText>
							<br>fname: #fname#
							<cfif right(fname,4) is ".dng">
								<cfset imgname=replace(fname,".dng","")>
								<cfquery name="upFile" datasource="uam_god">
									insert into es_img (
										imgname,
										folder
									) values (
										'#imgname#',
										'#folder#'
									)	
								</cfquery>
							</cfif> 
						</cfloop>
					</cfif> <!--- end not been here --->
				</cfif>		
			</cfloop>
		</cfif>
	</cfif><!--- end getDir --->
	<cfif action is "status">
		<cfquery name="d" datasource="uam_god">
			select status,count(*) c from es_img group by status
		</cfquery>
		<cfdump var=#d#>
	</cfif>
</cfoutput>