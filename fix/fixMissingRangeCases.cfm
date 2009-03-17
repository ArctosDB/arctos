<!---
drop table cft;

create table cft (
	key number not null,
	CONTAINER_ID number,
	PARENT_CONTAINER_ID number,
	BARCODE varchar2(255),
	LABEL varchar2(255),
	DESCRIPTION varchar2(255),
	CONTAINER_TYPE varchar2(255),
	CONTAINER_REMARKS varchar2(255)
	);

 CREATE OR REPLACE TRIGGER cf_cft_key                                         
 before insert  ON cft
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
--->

<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
	
<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="uam_god">
		delete from cft
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>

	
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <!---
				 <cfdump var="#arrResult[o]#">
				 --->
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
			<!--- Excel randomly and unpredictably whacks values off
				the end when they're NULL. Put NULLs back on as necessary.
				--->
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="uam_god">
				insert into cft (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>

 
	<cflocation url="fixMissingRangeCases.cfm?action=validate">

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
<cfquery name="d" datasource="uam_god">
	select * from cft
</cfquery>
<cfdump var=#d#>

<cftransaction>
<cfloop query="d">
	<cfif len(container_id) is 0>
		<cfquery name="gotOne" datasource="uam_god">
			select container_id from container where LABEL='#LABEL#'
		</cfquery>
		<cfif len(gotOne.container_id) is 0>
			<cfquery name="d" datasource="uam_god">
				insert into container (
					CONTAINER_ID,
					PARENT_CONTAINER_ID,
					BARCODE,
					LABEL,
					DESCRIPTION,
					CONTAINER_TYPE,
					CONTAINER_REMARKS,
					LOCKED_POSITION,
					INSTITUTION_ACRONYM
				) values (
					sq_container_id.nextval,
					0,
					'#BARCODE#',
					'#LABEL#',
					'#DESCRIPTION#',
					'#CONTAINER_TYPE#',
					'#CONTAINER_REMARKS#',
					0,
					'UAM'
					)
			</cfquery>
		</cfif>
	<cfelse>
		<cfquery name="d" datasource="uam_god">
		update container set
			BARCODE='#BARCODE#',
			LABEL='#LABEL#',
			DESCRIPTION='#DESCRIPTION#',
			CONTAINER_TYPE='#CONTAINER_TYPE#',
			CONTAINER_REMARKS='#CONTAINER_REMARKS#'			
			where CONTAINER_ID=#CONTAINER_ID#
			</cfquery>
	</cfif>
</cfloop>
</cftransaction>
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
