CREATE OR REPLACE Procedure parse_other_id (
	collection_object_id IN number,
	other_id_num IN varchar2,
	other_id_type IN varchar2)
IS
    part_one varchar2(255);
    part_two varchar2(255);
    part_three varchar2(255);
	remainder varchar2(255);
	hasHyp number;
BEGIN
	
	-- split input at hyphens into three (possibly null) strings
	hasHyp := instr(other_id_num,'-');
	if hasHyp = 0 OR hasHyp = 1 then
		part_one := other_id_num;
	else
		part_one := substr(other_id_num,1,hasHyp-1);
		remainder := substr(other_id_num,hasHyp+1);
		hasHyp := instr(remainder,'-');
		if hasHyp = 0 then
			part_two := remainder;
		elsif  hasHyp = 1 then
			part_one := other_id_num;
		else
			part_two := substr(remainder,1,hasHyp-1);
			part_three := substr(remainder,hasHyp+1);
		end if;
	end if;
	-- now see if we can sort out what should be where
	if part_one is not null and part_two is not null and part_three is not null then
		-- all three; is one or three are integers it probably should not be split
		if is_number(part_one) = 1 OR is_number(part_three) = 1 then
			part_one := other_id_num;
			part_two := NULL;
			part_three := NULL;
		end if;		
	elsif part_one is not null and part_two is null and part_three is null and is_number(part_one) = 1 then
		-- supplied an integer
		part_two := part_one;
		part_one := NULL;
	elsif part_one is not null and part_two is NOT null and part_three is null then
		-- two parts, see if one is an integer and should be stored as other_id_number
		if is_number(part_one) = 1 and is_number(part_two) = 0 then
			-- number and suffix
			part_three := part_two;
			part_two := part_one;
			part_one := NULL;
		end if;
	else
		-- something unexpected - throw everything into part_one
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	end if;
	
	-- doublecheck that two is an integer
	if is_number(part_two) = 0 then
		-- must be integer; revert to everything in prefix
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	end if;
	INSERT INTO coll_obj_other_id_num (
		COLLECTION_OBJECT_ID,
		OTHER_ID_TYPE,
		OTHER_ID_PREFIX,
		OTHER_ID_NUMBER,
		OTHER_ID_SUFFIX
	) values (
		collection_object_id,
		other_id_type,
		part_one,
		part_two,
		part_three
	);
	 create public synonym parse_other_id for parse_other_id;

	grant execute on parse_other_id to uam_update;

Grant succeeded.
	--dbms_output.put_line('part_one: ' || part_one);
	--dbms_output.put_line('part_two: ' || part_two);
	--dbms_output.put_line('part_three: ' || part_three);
end;
/
sho err

    
    