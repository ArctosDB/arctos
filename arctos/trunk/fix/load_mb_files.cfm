<cfoutput>
	
<!--- do this a few records at a time in an attempt to not break stuff.... --->
starting....
<cfquery name="mb" datasource="uam_god">
	select * from mbreport where status is null and rownum<100
</cfquery>

got #mb.recordcount# records....
<cfloop query="mb">
	<cftransaction>
	<!--- get the cataloged item --->
	<cfquery name="ci" datasource="uam_god">
		select * from cataloged_item where cat_num=#mb.catnum# and collection_id=6
	</cfquery>
	<cfif ci.recordcount is not 1>
		<cfquery name="bad" datasource="uam_god">
			update mbreport set status='cat item not found' where mbid=#mb.mbid#
		</cfquery>
	<cfelse>
		<!--- see if there's already a (potential) image --->
		<cfquery name="img" datasource="uam_god">
			select * from media_relations where MEDIA_RELATIONSHIP='shows cataloged_item' and 
			RELATED_PRIMARY_KEY=#ci.collection_object_id#
		</cfquery>
		<cfif img.recordcount is not 0>
			<cfquery name="bad" datasource="uam_god">
				update mbreport set status='image exists' where mbid=#mb.mbid#
			</cfquery>
		<cfelse>
			<!--- there is a cataloged item, there is no image, spiffy! --->
			<!--- build a directory if one doesn't already exist --->
			<cfset tnName="tn_#mb.mbid#.jpg">
			<cfset rPath="/SpecimenImages/UAM/Herb/#ci.cat_num#">
			<cfset fPath="#application.webDirectory##rPath#">
			<cftry>
				<cfdirectory action="create" directory="#fPath#">
				<cfcatch>
					<!--- it already exists, do nothing--->
				</cfcatch>
			</cftry>
			<!--- see if we can get a thumbnail --->
			<cfhttp method="Get"
				url="http://www.morphbank.net/?id=364499&imgType=thumb"
   				path="#fPath#"
   				file="#tnName#">
			<!--- make sure it's there --->
			<cfdirectory action="list" directory="#fPath#" filter="#tnName#" name="fetchedFile">
			<cfif fetchedFile.size is 0>
				<cfquery name="bad" datasource="uam_god">
					update mbreport set status='image not fetched' where mbid=#mb.mbid#
				</cfquery>
			<cfelse>
				<!--- get image data from the ala table --->
				<cfset theBarcode=replace(mb.imgfile,".dng","","all")>
				<cfset theBarcode=replace(theBarcode,".tiff","","all")>
				<cfquery name="imgMeta" datasource="uam_god">
					select
						agent_id,
						WHENDUNIT
					from
						agent_name,
						ala_plant_imaging
					where
						ala_plant_imaging.whodunit=agent_name.agent_name and
						ala_plant_imaging.barcode='#theBarcode#'
				</cfquery>
				<cfif len(imgMeta.agent_id) is 0>
					<cfset who=0>
				<cfelse>
					<cfset who=imgMeta.agent_id>					
				</cfif>
				<cfif len(imgMeta.WHENDUNIT) is 0>
					<cfset when=dateformat(now(),"dd mmmm yyyy")>
				<cfelse>
					<cfset when=dateformat(imgMeta.WHENDUNIT,"dd mmmm yyyy")>
				</cfif>
				<!--- make the Media --->
				<cfquery name="ms" datasource="uam_god">
					select seq_media.nextval nv from dual
				</cfquery>
				<cfset mid=ms.nv + 1>
				<cfquery name="nm" datasource="uam_god">
					insert into media (
						media_id,
						media_uri,
						mime_type,
						media_type,
						preview_uri
					) values (
						#mid#,
						'http://www.morphbank.net/?id=#mb.mbid#',
						'text/html',
						'image',
						'#application.serverRootUrl##rPath#/#tnName#')
				</cfquery>
				<cfquery name="r1" datasource="uam_god">
					insert into media_relations (
			    		media_id,
						media_relationship,
						created_by_agent_id,
						related_primary_key
					) values (
						#mid#,
						'shows cataloged_item',
						2072,
						#ci.collection_object_id#
					)
				</cfquery>
				<cfquery name="r2" datasource="uam_god">
					insert into media_relations (
			    		media_id,
						media_relationship,
						created_by_agent_id,
						related_primary_key
					) values (
						#mid#,
						'created by agent',
						2072,
						#who#
					)
				</cfquery>
				<cfquery name="l1" datasource="uam_god">
					insert into media_labels (
			    		media_id,
						media_label,
						label_value,
						assigned_by_agent_id
					) values (
						#mid#,
						'made date',
						'#when#',
						2072
					)
				</cfquery>
				<cfquery name="l3" datasource="uam_god">
					insert into media_labels (
			    		media_id,
						media_label,
						label_value,
						assigned_by_agent_id
					) values (
						#mid#,
						'description',
						'ALA Accession #mb.ala# herbarium sheet',
						2072
					)
				</cfquery>
				<cfquery name="yay" datasource="uam_god">
					update mbreport set status='success' where mbid=#mb.mbid#
				</cfquery>
				<br>loaded #mb.catnum#<br>
			</cfif>
		</cfif>
	</cfif>
	</cftransaction>
</cfloop>
</cfoutput>