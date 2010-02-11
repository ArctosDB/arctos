<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table 

drop table cf_temp_taxonomy;

create table cf_temp_taxonomy (
	key number,
	force_load number,
	status varchar2(255),
	taxon_name_id number,
 	PHYLCLASS                                                      VARCHAR2(20),
	 PHYLORDER                                                      VARCHAR2(30),
	 SUBORDER                                                       VARCHAR2(30),
	 FAMILY                                                         VARCHAR2(30),
	 SUBFAMILY                                                      VARCHAR2(30),
	 GENUS                                                          VARCHAR2(30),
	 SUBGENUS                                                       VARCHAR2(20),
	 SPECIES                                                        VARCHAR2(40),
	 SUBSPECIES                                                     VARCHAR2(40),
	 VALID_CATALOG_TERM_FG                                NUMBER not null,
	 SOURCE_AUTHORITY                                     VARCHAR2(45) not null,
	 SCIENTIFIC_NAME                                      VARCHAR2(255),
	 AUTHOR_TEXT                                                    VARCHAR2(255),
	 TRIBE                                                          VARCHAR2(30),
	 INFRASPECIFIC_RANK                                             VARCHAR2(20),
	 TAXON_REMARKS                                                  VARCHAR2(255),
	 PHYLUM                                                         VARCHAR2(30),
	 KINGDOM                                                        VARCHAR2(255),
	 NOMENCLATURAL_CODE                                             VARCHAR2(255),
	 INFRASPECIFIC_AUTHOR                                           VARCHAR2(255)
	);

	create or replace public synonym cf_temp_taxonomy for cf_temp_taxonomy;
	grant select,insert,update,delete on cf_temp_taxonomy to coldfusion_user;
	grant select on cf_temp_taxonomy to public;
	
	 CREATE OR REPLACE TRIGGER cf_temp_taxonomy_key                                         
 before insert  ON cf_temp_taxonomy
 for each row 
DECLARE
	nsn varchar2(4000);  
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;    
		IF :NEW.subspecies IS NOT null THEN
			nsn := :NEW.subspecies;
		END IF;
		IF :NEW.infraspecific_rank IS NOT null THEN
			nsn := :NEW.infraspecIFic_rank || ' ' || nsn;
		END IF;
		IF :NEW.species IS NOT null THEN
			nsn := :NEW.species || ' ' || nsn;
		END IF;
		IF :NEW.genus IS NOT null THEN
			nsn := :NEW.genus || ' ' || nsn;
		END IF;
		IF :NEW.tribe IS NOT null THEN
			IF nsn IS null THEN
			    nsn := :NEW.tribe;
			END IF;
		END IF;
		IF :NEW.subfamily IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.subfamily;
			END IF;
		END IF;
		IF :NEW.family IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.family;
			END IF;
		END IF;
		IF :NEW.suborder IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.suborder;
			END IF;
		END IF;
		IF :NEW.phylorder IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.phylorder;
			END IF;
		END IF;
		IF :NEW.phylclass IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.phylclass;
			END IF;
		END IF;
		IF :NEW.phylum IS NOT null THEN
			IF nsn IS null THEN
				nsn := :NEW.phylum;
			END IF;
		END IF;
		:NEW.scientific_name := trim(nsn);                    
    end;                                                                                            
/
sho err
------>
<cfif #action# is "nothing">
<cfoutput>
Step 1: Upload a comma-delimited text file (csv). 

Include column headings, spelled exactly as below.
<cfset colList = "PHYLCLASS,PHYLORDER,SUBORDER,FAMILY,SUBFAMILY,GENUS,SUBGENUS,SPECIES,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,AUTHOR_TEXT,TRIBE,INFRASPECIFIC_RANK,TAXON_REMARKS,PHYLUM,KINGDOM,NOMENCLATURAL_CODE,INFRASPECIFIC_AUTHOR">
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the following code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">#colList#</textarea>
	</div> 
<p></p>

<ul>
	<cfloop list="#colList#" index="i">
		<li>#i#</li>
	</cfloop>
</ul>


<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			  <input type="submit" value="Upload this file">
  </cfform>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>


	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_taxonomy
	</cfquery>

	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">



	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />	

	<cfset numberOfColumns = arraylen(arrResult[1])>	
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_taxonomy (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadTaxonomy.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>	
	<cfquery name="reset" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = null
	</cfquery>

	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = 'Invalid source_authority'
		where source_authority NOT IN (
			select SOURCE_AUTHORITY from CTTAXONOMIC_AUTHORITY
			)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = 'Invalid VALID_CATALOG_TERM_FG'
		where VALID_CATALOG_TERM_FG NOT IN (0,1)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = 'already exists'
		where scientific_name IN (select scientific_name from taxonomy)
	</cfquery>
	<!---
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_taxonomy where status is null
	</cfquery>
	<cfloop query="data">
		<cfset problem="">
			
		<cfif len(#problem#) gt 0>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_taxonomy SET status = '#problem#' where
				key = #key#
			</cfquery>
		</cfif>
	</cfloop>
	--->
	
		<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_temp_taxonomy
		</cfquery>
		<cfquery name="isProb" dbtype="query">
			select count(*) c from valData where status is not null
		</cfquery>
		<cfif #isProb.c# is 0 or isprob.c is "">
			Data validated. Carefully check the table below, then
			<a href="BulkloadTaxonomy.cfm?action=loadData">continue to load</a>.
		<cfelse>
			The data you loaded do not validate. See STATUS column below. If there are duplicates in the data you are trying to load, 
			you may delete them from your file (use the existing values), or 
			<a href="BulkloadTaxonomy.cfm?action=fixDups">merge them now</a>.
		</cfif>
		<table border>
			<tr>
				<th>KEY</th>
				<th>FORCE_LOAD</th>
				<th>STATUS</th>
				<th>PHYLCLASS</th>
				<th>PHYLORDER</th>
				<th>SUBORDER</th>
				<th>FAMILY</th>
				<th>SUBFAMILY</th>
				<th>GENUS</th>
				<th>SUBGENUS</th>
				<th>SPECIES</th>
				<th>SUBSPECIES</th>
				<th>VALID_CATALOG_TERM_FG</th>
				<th>SOURCE_AUTHORITY</th>
				<th>SCIENTIFIC_NAME</th>
				<th>AUTHOR_TEXT</th>
				<th>TRIBE</th>
				<th>INFRASPECIFIC_RANK</th>
				<th>PHYLUM</th>
				<th>KINGDOM</th>
				<th>NOMENCLATURAL_CODE</th>
				<th>INFRASPECIFIC_AUTHOR</th>
				<th>TAXON_REMARKS</th>
				<th>TAXON_NAME_ID</th>
			</tr>
			<cfloop query="valData">
				<tr>
					<td>#KEY#</td>
					<td>#FORCE_LOAD#</td>
					<td>#STATUS#</td>
					<td>#PHYLCLASS#</td>
					<td>#PHYLORDER#</td>
					<td>#SUBORDER#</td>
					<td>#FAMILY#</td>
					<td>#SUBFAMILY#</td>
					<td>#GENUS#</td>
					<td>#SUBGENUS#</td>
					<td>#SPECIES#</td>
					<td>#SUBSPECIES#</td>
					<td>#VALID_CATALOG_TERM_FG#</td>
					<td>#SOURCE_AUTHORITY#</td>
					<td>#SCIENTIFIC_NAME#</td>
					<td>#AUTHOR_TEXT#</td>
					<td>#TRIBE#</td>
					<td>#INFRASPECIFIC_RANK#</td>
					<td>#PHYLUM#</td>
					<td>#KINGDOM#</td>
					<td>#NOMENCLATURAL_CODE#</td>
					<td>#INFRASPECIFIC_AUTHOR#</td>
					<td>#TAXON_REMARKS#</td>
					<td>#TAXON_NAME_ID#</td>
				</tr>
			</cfloop>
		</table>
		<!---
	<cflocation url="BulkloadCitations.cfm?action=loadData">
	---->
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "fixDups">
<cfoutput>
	<a href="BulkloadTaxonomy.cfm?action=validate">Back to Loader</a>
	<p></p>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_taxonomy where status='already exists'
	</cfquery>
	Found #data.recordcount# duplicates.
	<br>
	The table below contains records which have existing matching scientific names.
	<br>You must choose to overwrite the existing data with the data you just loaded
	or to keep existing data where there is a conflict. This form is not a replacement for edit taxonomy. Delete, re-upload, 
	and edit taxonomy to deal with anything that you can't here.
	<br>NULLS ("(new)" or "(old)" in the dropdown) will 
	<blockquote>
		update taxonomy set {term} = NULL
	</blockquote>
	That's probably not ever a good idea.
	<br>
	Many taxonomy tools exist. Not all of them are available to all users.
	 If this form seems awkward or repetitive, you're probably using the wrong tool.
	<br>
	<br>Clicking "save" will:
	<ul>
		<li>Update Arctos taxonomy</li>
		<li>Delete the temp record</li>
	</ul>
	Re-uploading your file without cleaning up things you fix here will re-load those records and lead you back to this form.
	<p>
	<cfset colList = "PHYLCLASS,PHYLORDER,SUBORDER,FAMILY,SUBFAMILY,GENUS,SUBGENUS,SPECIES,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,AUTHOR_TEXT,TRIBE,INFRASPECIFIC_RANK,TAXON_REMARKS,PHYLUM,KINGDOM,NOMENCLATURAL_CODE,INFRASPECIFIC_AUTHOR">
	
		<table border>
		<tr>
			<cfloop list="#colList#" index="i">
				<td>#i#</td>
			</cfloop>
		</tr>
		<cfloop query="data">
				<form name="d)#key#" method="post" action="BulkloadTaxonomy.cfm">
					<input type="hidden" name="action" value="saveDupChange">
					<input type='hidden' name="scientific_name"
							 value="#scientific_name#">
			<cfquery name="current" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from taxonomy where scientific_name='#scientific_name#'
			</cfquery>
				<tr>
				<cfloop list="#colList#" index="i">
					<cfset newTerm = evaluate("data." & i)>
					<cfset existTerm = evaluate("current." & i)>
					
					<td>
						<cfif #newTerm# is not #existTerm#>
						
							<select name="#i#" size="1">
								<option selected="selected" value="#newTerm#">#newTerm# (new)</option>
								<option value="#existTerm#">#existTerm# (old)</option>
							</select>
						<cfelse>
							#existTerm#
							<input type="hidden" name="#i#" value="#existTerm#">
						</cfif>
					</td>
				</cfloop>
				<td>
					<input type="submit" value="Update Taxonomy" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
		</form>
				</td>
			</tr>
		</cfloop>
		</table>
		
	</form>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "saveDupChange">
	<cfdump var=#form#>
	<cfquery name="edTaxa" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
	UPDATE taxonomy SET 
		valid_catalog_term_fg=#valid_catalog_term_fg#
		,source_authority = '#source_authority#'
		<cfif len(#author_text#) gt 0>
			,author_text='#author_text#'
		<cfelse>
			,author_text=null			
		</cfif>
		<cfif len(#tribe#) gt 0>
			,tribe = '#tribe#'
		<cfelse>
			,tribe = null			
		</cfif>
		<cfif len(#infraspecific_rank#) gt 0>
			,infraspecific_rank = '#infraspecific_rank#'
		<cfelse>
			,infraspecific_rank = null			
		</cfif>
		<cfif len(#phylclass#) gt 0>
			,phylclass = '#phylclass#'
		<cfelse>
			,phylclass = null			
		</cfif>
		<cfif len(#phylorder#) gt 0>
			,phylorder = '#phylorder#'
		<cfelse>
			,phylorder = null			
		</cfif>
		<cfif len(#suborder#) gt 0>
			,suborder = '#suborder#'
		<cfelse>
			,suborder = null			
		</cfif>
		<cfif len(#family#) gt 0>
			,family = '#family#'
		<cfelse>
			,family = null			
		</cfif>
		<cfif len(#subfamily#) gt 0>
			,subfamily = '#subfamily#'
		<cfelse>
			,subfamily = null			
		</cfif>
		<cfif len(#genus#) gt 0>
			,genus = '#genus#'
		<cfelse>
			,genus = null			
		</cfif>
		<cfif len(#subgenus#) gt 0>
			,subgenus = '#subgenus#'
		<cfelse>
			,subgenus = null			
		</cfif>
		<cfif len(#species#) gt 0>
			,species = '#species#'
		<cfelse>
			,species = null			
		</cfif>
		<cfif len(#subspecies#) gt 0>
			,subspecies = '#subspecies#'
		<cfelse>
			,subspecies = null			
		</cfif>		
		<cfif len(#phylum#) gt 0>
			,phylum = '#phylum#'
		<cfelse>
			,phylum = null			
		</cfif>		
		<cfif len(#taxon_remarks#) gt 0>
			,taxon_remarks = '#taxon_remarks#'
		<cfelse>
			,taxon_remarks = null			
		</cfif>
		<cfif len(#kingdom#) gt 0>
			,kingdom = '#kingdom#'
		<cfelse>
			,kingdom = null			
		</cfif>
		<cfif len(#nomenclatural_code#) gt 0>
			,nomenclatural_code = '#nomenclatural_code#'
		<cfelse>
			,nomenclatural_code = null			
		</cfif>
		<cfif len(#infraspecific_author#) gt 0>
			,infraspecific_author = '#infraspecific_author#'
		<cfelse>
			,infraspecific_author = null			
		</cfif>	
	WHERE scientific_name='#scientific_name#'
	</cfquery>
	<cfquery name="killTemp" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_taxonomy WHERE scientific_name='#scientific_name#'
	</cfquery>
	<cflocation url="BulkloadTaxonomy.cfm?action=fixDups" addtoken="false">
</cfif>

<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	<cfquery name="data" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cftransaction>
	<cfloop query="data">
		<cfquery name="nid" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
			select sq_taxon_name_id.nextval nid from dual
		</cfquery>
		<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO taxonomy (
				taxon_name_id
				,valid_catalog_term_fg
				,source_authority
				<cfif len(#author_text#) gt 0>
					,author_text		
				</cfif>
				<cfif len(#tribe#) gt 0>
					,tribe			
				</cfif>
				<cfif len(#infraspecific_rank#) gt 0>
					,infraspecific_rank			
				</cfif>
				<cfif len(#phylclass#) gt 0>
					,phylclass			
				</cfif>
				<cfif len(#phylorder#) gt 0>
					,phylorder		
				</cfif>
				<cfif len(#suborder#) gt 0>
					,suborder		
				</cfif>
				<cfif len(#family#) gt 0>
					,family	
				</cfif>
				<cfif len(#subfamily#) gt 0>
					,subfamily	
				</cfif>
				<cfif len(#genus#) gt 0>
					,genus			
				</cfif>
				<cfif len(#subgenus#) gt 0>
					,subgenus		
				</cfif>
				<cfif len(#species#) gt 0>
					,species			
				</cfif>
				<cfif len(#subspecies#) gt 0>
					,subspecies		
				</cfif>	
				<cfif len(#taxon_remarks#) gt 0>
					,taxon_remarks		
				</cfif>	
				<cfif len(#phylum#) gt 0>
					,phylum		
				</cfif>
				<cfif len(#infraspecific_author#) gt 0>
					,infraspecific_author		
				</cfif>
				<cfif len(#kingdom#) gt 0>
					,kingdom		
				</cfif>
				<cfif len(#nomenclatural_code#) gt 0>
					,nomenclatural_code		
				</cfif>		
				)	
			VALUES (
				#nid.nid#
				,#valid_catalog_term_fg#
				,'#source_authority#'
				<cfif len(#author_text#) gt 0>
					,'#author_text#'
				</cfif>
				<cfif len(#tribe#) gt 0>
					,'#tribe#'
				</cfif>
				<cfif len(#infraspecific_rank#) gt 0>
					,'#infraspecific_rank#'
				</cfif>
				<cfif len(#phylclass#) gt 0>
					,'#phylclass#'			
				</cfif>
				<cfif len(#phylorder#) gt 0>
					,'#phylorder#'
				</cfif>
				<cfif len(#suborder#) gt 0>
					,'#suborder#'		
				</cfif>
				<cfif len(#family#) gt 0>
					,'#family#'
				</cfif>
				<cfif len(#subfamily#) gt 0>
					,'#subfamily#'	
				</cfif>
				<cfif len(#genus#) gt 0>
					,'#genus#'
				</cfif>
				<cfif len(#subgenus#) gt 0>
					,'#subgenus#'		
				</cfif>
				<cfif len(#species#) gt 0>
					,'#species#'
				</cfif>
				<cfif len(#subspecies#) gt 0>
					,'#subspecies#'		
				</cfif>
				<cfif len(#taxon_remarks#) gt 0>
					,'#taxon_remarks#'		
				</cfif>	
				<cfif len(#phylum#) gt 0>
					,'#phylum#'		
				</cfif>
				<cfif len(#infraspecific_author#) gt 0>
					,'#infraspecific_author#'		
				</cfif>
				<cfif len(#kingdom#) gt 0>
					,'#kingdom#'
				</cfif>
				<cfif len(#nomenclatural_code#) gt 0>
					,'#nomenclatural_code#'		
				</cfif>		
					)
		</cfquery>
		</cfloop>
	</cftransaction>
		

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
