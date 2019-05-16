<!----
create table temp_geo_wkt (
	geog_auth_rec_id number,
	media_id number,
	status varchar2(255)
);

insert into temp_geo_wkt (geog_auth_rec_id) (select geog_auth_rec_id from geog_auth_rec where WKT_POLYGON is not null);

select count(*) from geog_auth_rec where WKT_POLYGON like 'MEDIA%';

update temp_geo_wkt set status='is_media' where geog_auth_rec_id in (select geog_auth_rec_id from geog_auth_rec where WKT_POLYGON like 'MEDIA%');

---->
<cfoutput>
<cfquery name="d" datasource='uam_god'>
	select WKT_POLYGON from geog_auth_rec,temp_geo_wkt where geog_auth_rec.geog_auth_rec_id=temp_geo_wkt.geog_auth_rec_id and
	status is null and rownum=1
</cfquery>
<cfloop query="d">
	<cfif len(WKT_POLYGON) gt 0>
		<cfset tempName=createUUID()>
		<br>filename: #tempName#
		<cffile	action = "write" destination = "#Application.sandbox#/#tempName#.tmp" output='#WKT_POLYGON#' addNewLine="false">
		<br>written

	<cfelse>
		<cfquery name="uds" datasource='uam_god'>
			update temp_geo_wkt set status='zero_len_wkt' where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
	</cfif>
</cfloop>

</cfoutput>

<!-----------
	<cfif len(FILETOUPLOAD) gt 0>
				<!---- get the filename as uploaded ---->
			    <cfset tmpPartsArray = Form.getPartsArray() />
			    <cfif IsDefined("tmpPartsArray")>
			        <cfloop array="#tmpPartsArray#" index="tmpPart">
			            <cfif tmpPart.isFile() AND tmpPart.getName() EQ "FILETOUPLOAD"> <!---   --->
			               <cfset fileName=tmpPart.getFileName() >
			            </cfif>
			        </cfloop>
			    </cfif>
				<cfif not isdefined("filename") or len(filename) is 0>
					Didn't get filename<cfabort>
				</cfif>
				<!---- read the file ---->
				<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
				<!---- temporary safe name ---->
				<cfset tempName=createUUID()>
				<!---- stash the file in the sandbox ---->
				<cffile	action = "upload" destination = "#Application.sandbox#/#tempName#.tmp" fileField = "FILETOUPLOAD">
				<!--- send it to S3 ---->
				<cfset utilities = CreateObject("component","component.utilities")>
				<cfset x=utilities.sandboxToS3("#Application.sandbox#/#tempName#.tmp",fileName)>
				<cfif not isjson(x)>
					upload fail<cfdump var=#x#><cfabort>
				</cfif>
				<cfset x=deserializeJson(x)>
				<cfif (not isdefined("x.STATUSCODE")) or (x.STATUSCODE is not 200) or (not isdefined("x.MEDIA_URI")) or (len(x.MEDIA_URI) is 0)>
					upload fail<cfdump var=#x#><cfabort>
				</cfif>
				<cfset preview_uri=x.MEDIA_URI>
			</cfif>

			--------->