<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<cfset s="">
	<cfloop from ="1" to="10" index="i">
		<cfset s=s & chr(10) & "IF rec.ATTRIBUTE_#i# is not null and rec.ATTRIBUTE_VALUE_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & 'select isValidAttribute(rec.ATTRIBUTE_#i#,rec.ATTRIBUTE_VALUE_#i#,rec.ATTRIBUTE_UNITS_#i#,r_collection_cde) INTO STRICT numRecs;'>
		<cfset s=s & chr(10) & chr(9) & 'if numRecs = 0 then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_#i# is not valid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.ATTRIBUTE_DATE_#i# is null or is_iso8601(rec.ATTRIBUTE_DATE_#i#,1) != 'valid' then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DATE_#i# is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_#i#);">

		 <cfset s=s & chr(10) & chr(9) & "if numRecs !=1 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DETERMINER_#i# [ ' || coalesce(rec.ATTRIBUTE_DETERMINER_#i#,'NULL') || ' ] matches ' || numRecs || ' agents';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
   		<cfset s=s & chr(10)  & 'end if;'>
	</cfloop>


	<textarea rows="100" cols="150">#s#</textarea>


	<cfset s="">
	<cfloop from ="1" to="12" index="i">
		<cfset s=s & chr(10) & "if rec.PART_NAME_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_#i# AND collection_cde = r_collection_cde;">
		<cfset s=s & chr(10) & chr(9) & "IF numRecs = 0 THEN">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_NAME_#i# [ ' || coalesce(rec.PART_NAME_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.PART_CONDITION_#i# is null then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_CONDITION_#i# [ ' || coalesce(rec.PART_CONDITION_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.PART_BARCODE_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM container WHERE barcode = rec.PART_BARCODE_#i#;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "if numRecs = 0 then">
    	<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "thisError :=  'PART_BARCODE_#i# [ ' || coalesce(rec.PART_BARCODE_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "END IF;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_#i#;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "if numRecs != 0 then">
    	<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "thisError :=  'PART_BARCODE_#i# [ ' || coalesce(rec.PART_BARCODE_#i#,'NULL') || ' ] is a label';">
    	<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
    	<cfset s=s & chr(10) & chr(9) & chr(9) & "END IF;">
   		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & 'if rec.PART_LOT_COUNT_#i# is null or is_number(rec.PART_LOT_COUNT_#i#) = 0 then'>
   		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_LOT_COUNT_#i# [ ' || coalesce(rec.PART_LOT_COUNT_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
	    <cfset s=s & chr(10) & chr(9) & 'end if;'>
	    <cfset s=s & chr(10) & chr(9) & 'SELECT count(*) INTO STRICT numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_#i#;'>
		<cfset s=s & chr(10) & chr(9) & 'if numRecs = 0 then'>
    	<cfset s=s & chr(10) & chr(9) & chr(9)  & "thisError := 'PART_DISPOSITION_#i# [ ' || coalesce(rec.PART_DISPOSITION_#i#,'NULL') || ' ] is invalid;'">
    	<cfset s=s & chr(10) & chr(9) & chr(9)  & "allError:=concat_ws('; ',allError,thisError);">
    	<cfset s=s & chr(10) & chr(9) &  "END IF;">
   		<cfset s=s & chr(10) & 'end if;'>
	</cfloop>

	<textarea rows="100" cols="150">#s#</textarea>

</cfoutput>

<cfinclude template="/includes/_footer.cfm">
