<!----
	drop table specimen_annotations;
	create table specimen_annotations (
		annotation_id number not null,
		annotate_date date,
		cf_username varchar2(255),
		collection_object_id number not null,
		scientific_name varchar2(255),
		higher_geography varchar2(255),
		specific_locality varchar2(255),
		annotation_remarks varchar2(255)
	);
	create or replace public synonym specimen_annotations for specimen_annotations;
	grant select,insert on specimen_annotations to uam_query;

	
	 CREATE OR REPLACE TRIGGER specimen_annotations_key                                         
	 before insert  ON specimen_annotations  
	 for each row 
	    begin     
	    	if :NEW.annotation_id is null then                                                                                      
	    		select specimen_annotations_seq.nextval into :new.annotation_id from dual;
	    	end if; 
	    	if :NEW.annotate_date is null then
	    		:NEW.annotate_date := sysdate;
	    	end if;                               
	    end;                                                                                            
	/
	sho err	
	create sequence specimen_annotations_seq;
	---->
		<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">

<link rel="stylesheet" type="text/css" href="/includes/annotate.css">

		
		

<span onclick="closeAnnotation()" class="windowCloser">Close Annotation Window</span>
<cfquery name="hasEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select email from cf_user_data,cf_users
	where cf_user_data.user_id = cf_users.user_id and
	cf_users.username='#session.username#'
</cfquery>
<cfif #hasEmail.recordcount# is 0 OR #len(hasEmail.email)# is 0>
	<div class="error">
		You must provide an email address to annotate specimens.
		<br>
		Update <a href="/myArctos.cfm" target="_blank">your profile</a> (opens in new window) to proceed.
		<br>
		<span class="likeLink" onclick="closeAnnotation()">Close this window</span>
	</div>
	<cfabort>
</cfif>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cataloged_item.collection_object_id,
		cat_num,
		institution_acronym,
		collection.collection_cde,
		scientific_name,
		higher_geog higher_geography,
		spec_locality specific_locality,
		NULL annotation_remarks
	from 
		cataloged_item,
		identification,
		collection,
		collecting_event,
		locality,
		geog_auth_rec
	where 
		cataloged_item.collection_object_id = identification.collection_object_id AND
		accepted_id_fg=1 AND
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		cataloged_item.collection_object_id=#collection_object_id#
</cfquery>
<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from specimen_annotations where collection_object_id=#collection_object_id#
</cfquery>
<cfloop list="#prevAnn.columnlist#" index="cname">
	<cfquery name="p#cname#" dbtype="query">
		select #cname# AS prev_data from prevAnn where #cname# is not null group by #cname# order by #cname#
	</cfquery>
</cfloop>

<cfoutput>
Create Annotations for #d.institution_acronym# #d.collection_cde# #d.cat_num#

<!--- build the form dynamically using the table elements, with the stuff we don't want stripped out --->
<cfset theList = prevAnn.columnList>
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"annotation_id"))>
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"cf_username"))>
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"collection_object_id"))>	
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"annotate_date"))>	
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"reviewer_agent_id"))>	
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"reviewed_fg"))>	
<cfset theList = ListDeleteAt(theList, ListFindNoCase(theList,"reviewer_comment"))>	
<cfset theList = lcase(theList)	>

<form name="annotate" method="post" action="/info/annotateSpecimen.cfm">
	<input type="hidden" name="action" value="insert">
	<input type="hidden" name="collection_object_id" id="collection_object_id" value="#collection_object_id#">
	<table border="0">
	<cfloop list="#theList#" index="element">
		<cfset thisDisplayName = replace(element,"_"," ","all")>
		<cfset thisDisplayName = toProperCase(thisDisplayName)>
		<cfset numAnnotations = evaluate("p" & element).recordcount>
		<cfset prevQueryName = evaluate("p" & element)>
		<tr>
			<td>
				<label for="#element#">#thisDisplayName#
				(<span class="currData">Currently: <strong>#evaluate("d." & element)#</strong></span>)</label>
				<input type="text" class="seed beThere" name="#element#" id="#element#" size="60" 
					value="Annotate" onfocus="if (this.value=='Annotate'){this.value='';this.className='beThere'};">
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				<span id="show_#element#" class="infoLink doShow" onclick="showPrevious(this.id);">Show #numAnnotations# Previous Annotations:</span>
				<span id="hide_#element#" class="noShow" onclick="hidePrevious(this.id);">Hide Previous Annotations:</span>
			</td>
		</tr>
		<tr>
			<td>
				<div id="p_#element#" class="noShow prevAnnList">
					<cfloop query="prevQueryName">
						#prev_data#<br>
					</cfloop>
				</div>&nbsp;
			</td>
		</tr>
	</cfloop>

	<!----
	
	
	<tr>
		<td>
			<label for="higher_geog">Geography 
			(<span class="currData">Currently: <strong>#d.higher_geog#</strong></span>)</label>
			<input type="text" class="seed beThere" name="higher_geog" id="higher_geog" 
				value="Annotate" onfocus="if (this.value=='Annotate'){this.value='';this.className='beThere'};">
		</td>
	</tr>
	<tr>
		<td nowrap="nowrap">
			<span id="show_higher_geog" class="infoLink doShow" onclick="showPrevious(this.id);">
				Show #phigher_geog.recordcount# Previous Annotations:
			</span>
			<span id="hide_higher_geog" class="noShow" onclick="hidePrevious(this.id);">
				Hide #phigher_geog.recordcount# Previous Annotations:
			</span>
		</td>
	</tr>
	<tr>
		<td>
			<div id="p_higher_geog" class="noshow prevAnnList">
				<cfloop query="phigher_geog">
					#prev_data#<br>
				</cfloop>
			</div>&nbsp;
		</td>
	</tr>
	<tr>
		<td>
			<label for="spec_locality">Specific Locality 
			(<span class="currData">Currently: <strong>#d.higher_geog#</strong></span>)</label>
			<input type="text" class="seed beThere" name="higher_geog" id="higher_geog" 
				value="Annotate" onfocus="if (this.value=='Annotate'){this.value='';this.className='beThere'};">
		</td>
	</tr>
	<tr>
		<td nowrap="nowrap">
			<span id="show_higher_geog" class="infoLink doShow" onclick="showPrevious(this.id);">
				Show #phigher_geog.recordcount# Previous Annotations:
			</span>
			<span id="hide_higher_geog" class="noShow" onclick="hidePrevious(this.id);">
				Hide #phigher_geog.recordcount# Previous Annotations:
			</span>
		</td>
	</tr>
	<tr>
		<td>
			<div id="p_higher_geog" class="noshow prevAnnList">
				<cfloop query="phigher_geog">
					#prev_data#<br>
				</cfloop>
			</div>&nbsp;
		</td>
	</tr>

---->
	<input type="button" 
		class="qutBtn"
		onmouseover="this.className='qutBtn btnhov'" 
		onmouseout="this.className='qutBtn'"
		value="Quit without Saving"
		onclick="closeAnnotation()">
		
		<input type="button" 
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'"
		value="Save Annotations"
		onclick="saveThisAnnotation()">
	
</form>

	


</table>
</cfoutput>
</cfif>
<cfif #action# is "insert">
<cfoutput>
	<cfquery name="insAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	insert into specimen_annotations (
		collection_object_id,
		scientific_name)
	values (
		#collection_object_id#,
		'#scientific_name#')
	</cfquery>
	<cflocation url="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#&showAnnotation=true">
</cfoutput>
</cfif>