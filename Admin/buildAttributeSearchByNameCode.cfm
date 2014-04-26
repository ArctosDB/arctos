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
			<cfset v="insert into ssrch_field_doc (
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
				);
			">
			
			<cfset n=n+1>
			<cfset x='<cfif isdefined("#attrvar#")>'>
			<cfset x=x & chr(10) & '    <cfset mapurl = "##mapurl##&#attrvar#=###attrvar###">'>
			<cfset x=x & chr(10) & '    <cfset basJoin = " ##basJoi#n# INNER JOIN v_attributes t_#attrvar# ON (##session.flatTableName##.collection_object_id = t_#attrvar#.collection_object_id)">'>
			<cfset x=x & chr(10) & '    <cfset basQual = " ##basQual## AND t_#attrvar#.attribute_type = ''#ATTRIBUTE_TYPE#''">'>
			<cfset x=x & chr(10) & '    <cfif session.flatTableName is not "flat">'>
			<cfset x=x & chr(10) & '        <cfset basQual = " ##basQual## AND t_#attrvar#.is_encumbered = 0">'>
			<cfset x=x & chr(10) & '    </cfif>'>
			<cfset x=x & chr(10) & '    <cfset extendedErrorMsg=listappend(extendedErrorMsg,''Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.'',";")>'> 
			<cfset x=x & chr(10) & '    <cfif len(#attrvar#) gt 0>'>
			<cfset x=x & chr(10) & '        <cfif left(#attrvar#,1) is "=">'>
			<cfset x=x & chr(10) & '            <cfset oper="=">'>
			<cfset x=x & chr(10) & '            <cfset srchval="''##ucase(right(#attrvar#,len(#attrvar#)-1))##''">'>
			<cfset x=x & chr(10) & '        <cfelseif  left(#attrvar#,1) is "!">'>				
			<cfset x=x & chr(10) & '            <cfset oper="!=">'>	
			
						p
			<cfset x=x & chr(10) & '            <cfset srchval="''##ucase(right(#attrvar#,len(#attrvar#)-1))##''">'>
			<cfset x=x & chr(10) & '        <cfelseif  left(#attrvar#,1) is "<">'>
			<cfset x=x & chr(10) & '            <cfset oper="<">'>
			<cfset x=x & chr(10) & '            <cfset srchval=right(#attrvar#,len(#attrvar#)-1)>'>
			<cfset x=x & chr(10) & '        <cfelseif  left(#attrvar#,1) is ">">'>
			<cfset x=x & chr(10) & '            <cfset oper=">">'>
			
			q
			
			
			<cfset x=x & chr(10) & '            <cfset srchval=right(#attrvar#,len(#attrvar#)-1)>'>
			<cfset x=x & chr(10) & '        <cfelse>'>
			<cfset x=x & chr(10) & '            <cfset oper="like">'>
			<cfset x=x & chr(10) & '            <cfset srchval="''%##ucase((#attrvar#)##%''">'>
			<cfset x=x & chr(10) & '         </cfif>'>
			<cfset x=x & chr(10) & '        <cfset basQual = " ##basQual## AND upper(t_#attrvar#.attribute_value) ##oper## ##srchval##">'>'>
			<cfset x=x & chr(10) & '    </cfif>'>
			<cfset x=x & chr(10) &  '</cfif>'>
			<cfset x=x & chr(10)>
			
			z
			
			
			<cfscript>
				variables.josrch_field_doc.writeLine(v);
				variables.f_ss_doc.writeLine(x);
			</cfscript>
		</cfloop>
		<cfscript>	
			variables.josrch_field_doc.close();
			variables.f_ss_doc.close();
		</cfscript>
		This app just builds text.
		<p>
			Get the SQL to update ssrch_field_doc <a href="/download/srch_field_doc.sql">here</a>
		</p>
		
		<p>
			Get the CFML to update specimen search <a href="/download/specsrch.txt">here</a>
		</p>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
