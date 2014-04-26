<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select ATTRIBUTE_TYPE from ctattribute_type group by ATTRIBUTE_TYPE order by ATTRIBUTE_TYPE
		</cfquery>
		
		<cfquery name="fattrorder" datasource="uam_god">
			select min(DISP_ORDER) mdo from ssrch_field_doc where CATEGORY='attribute'
		</cfquery>
		
		<cfset n=fattrorder.mdo>
		
		<cfset variables.encoding="UTF-8">
		<cfset variables.f_srch_field_doc="#Application.webDirectory#/download/srch_field_doc.sql">
		<cfset variables.f_ss_doc="#Application.webDirectory#/download/specsrch.txt">

		<cfscript>
			variables.josrch_field_doc = createObject('Component', '/component.FileWriter').init(variables.f_srch_field_doc, variables.encoding, 32768);
			variables.josrch_field_doc.writeLine("delete from srch_field_doc where CATEGORY='attribute';");
			variables.f_ss_doc = createObject('Component', '/component.FileWriter').init(variables.f_ss_doc, variables.encoding, 32768);

		</cfscript>
		<cfloop query="d">
			<cfquery name="tctl" datasource="uam_god">
				select ATTRIBUTE_TYPE,VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where ATTRIBUTE_TYPE='#ATTRIBUTE_TYPE#' 
			</cfquery>
			<cfset attrvar=replace(replace(replace(ATTRIBUTE_TYPE,' ','_','all'),'-','_','all'),"/","_","all")>
			<cfset x="
				insert into ssrch_field_doc (
					CATEGORY,
					CF_VARIABLE,
					CONTROLLED_VOCABULARY,
					DATA_TYPE,
					DEFINITION,
					DISPLAY_TEXT,
					DOCUMENTATION_LINK,
					PLACEHOLDER_TEXT,
					SEARCH_HINT,
					SQL_ELEMENT,
					SPECIMEN_RESULTS_COL,
					DISP_ORDER,
					SPECIMEN_QUERY_TERM
				) values (
					'attribute',
					'#attrvar#',
					'#tctl.VALUE_CODE_TABLE#',
					'',
					'',
					'#ATTRIBUTE_TYPE#',
					'',
					'#ATTRIBUTE_TYPE#',
					'',
					'concatAttributeValue(flatTableName.collection_object_id,''#ATTRIBUTE_TYPE#''),
					1,
					#n#,
					1
				);">
				
				<cfset n=n+1>
				
				<!----
					sql will accept:
						attribute, with space, dash, slash replaced with underscore, eg, age_class=....
						attribute value as attribute (as above)
					
				---->
				<cfsavecontent variable="ss">
					<cfset x='<cfif isdefined("#attrvar#")>'>
					<cfset x=x & '<cfset mapurl = "##mapurl##&#attrvar#=###attrvar###">'>
					<cfset x=x & '<cfset basJoin = " ##basJoi#n# INNER JOIN v_attributes t_#attrvar# ON (##session.flatTableName##.collection_object_id = t_#attrvar#.collection_object_id)">'>
					<cfset x=x & '<cfset basQual = " #basQual# AND t_#attrvar#.attribute_type = ''#ATTRIBUTE_TYPE#''">'>
					<cfset x=x & '<cfif session.flatTableName is not "flat">'>
					<cfset x=x & '<cfset basQual = " ##basQual## AND t_#attrvar#.is_encumbered = 0">'>
					<cfset x=x & '</cfif>'>
					<cfset x=x & '<cfset extendedErrorMsg=listappend(extendedErrorMsg,''Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.'',";")>'> 
					<cfset x=x & '<cfif len(#attrvar#) gt 0>'>
					<cfset x=x & '<cfif left(#attrvar#,1) is "=">'>
					<cfset x=x & '<cfset oper="=">'>
					<cfset x=x & '<cfset srchval="''##ucase(right(#attrvar#,len(#attrvar#)-1))##''">'>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					<cfset x=x & ''>
					#x#
					
					
					
					
					
		
			<!----
			
		<cfelseif  left(age_class,1) is "!">
			<cfset oper="!=">
			<cfset srchval="'#ucase(right(age_class,len(age_class)-1))#'">
		<cfelseif  left(age_class,1) is "<">
			<cfset oper="<">
			<cfset srchval=right(age_class,len(age_class)-1)>
		<cfelseif  left(age_class,1) is ">">
			<cfset oper=">">
			<cfset srchval=right(age_class,len(age_class)-1)>
		<cfelse>
			<cfset oper="like">
			<cfset srchval="'%#ucase(age_class)#%'">
		</cfif>
		<cfset basQual = " #basQual# AND upper(t_age_class.attribute_value) #oper# #srchval#">'>
	</cfif>
</cfif>



---->
					<!------------
					
					
					
						
					
					<
					<cfif not isdefined("attOper_1") or len(#attOper_1#) is 0>
						<cfset attOper_1 = "equals">
					</cfif>
					<cfset mapurl = "#mapurl#&attOper_1=#attOper_1#">
					<cfif isdefined("attribute_value_1") and len(attribute_value_1) gt 0>
						<cfset mapurl = "#mapurl#&attribute_value_1=#attribute_value_1#">
						<cfset attribute_value_1 = #replace(attribute_value_1,"'","''","all")#>
						<cfif attOper_1 is "like">
							<cfset basQual = " #basQual# AND upper(attributes_1.attribute_value) LIKE '%#ucase(attribute_value_1)#%'">
						<cfelseif attOper_1 is "equals" >
							<cfset basQual = " #basQual# AND attributes_1.attribute_value = '#attribute_value_1#'">
						<cfelseif attOper_1 is "greater" >
							<cfif isnumeric(attribute_value_1)>
								<cfset basQual = " #basQual# AND to_number(attributes_1.attribute_value) > #attribute_value_1#">
							<cfelse>
							  	<div class="error">
									You tried to search for attribute values greater than a non-numeric value.
								</div>
								<script>hidePageLoad();</script>
								<cfabort>
							</cfif>
						<cfelseif attOper_1 is "less" >
							<cfif isnumeric(#attribute_value_1#)>
								<cfset basQual = " #basQual# AND attributes_1.attribute_value < #attribute_value_1#">
							<cfelse>
								<div class="error">
									You tried to search for attribute values less than a non-numeric value.
								</div>
								<script>hidePageLoad();</script>
							</cfif>
						</cfif>
					</cfif>
					<cfif isdefined("attribute_units_1") AND len(attribute_units_1) gt 0>
						<cfset basQual = " #basQual# AND attributes_1.attribute_units = '#attribute_units_1#'">
					</cfif>
					</cfif>




--------------->

					
					
					
					
					
					
				</cfsavecontent>
				
				<cfscript>
					variables.josrch_field_doc.writeLine(x);
					variables.f_ss_doc.writeLine(ss);



				</cfscript>	
				
				
			</cfloop>
			<cfscript>	
				variables.josrch_field_doc.close();
				variables.f_ss_doc.close();
			</cfscript>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
