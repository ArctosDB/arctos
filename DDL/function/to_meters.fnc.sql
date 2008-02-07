CREATE OR REPLACE function to_meters(meas IN number, unit in varchar2 )
    return number DETERMINISTIC
    as
        in_m  number;
	begin
	if meas is null or unit is null then
		in_m := null;
	else	
		if upper(unit) = 'M' OR upper(unit) = 'METERS' OR upper(unit) = 'METER' then
			in_m := meas;
		elsif upper(unit) = 'FT' OR upper(unit) = 'FEET' OR upper(unit) = 'FOOT' then
			in_m := meas * .3048;
		elsif upper(unit) = 'KM' OR upper(unit) = 'KILOMETER' OR upper(unit) = 'KILOMETERS' then
			in_m := meas * 1000;
		elsif upper(unit) = 'MI' OR upper(unit) = 'MILE' OR upper(unit) = 'MILES' then
			in_m := meas * 1609.344;
		elsif upper(unit) = 'YD' OR upper(unit) = 'YARD' OR upper(unit) = 'YARDS' then
			in_m := meas * .9144;
		elsif upper(unit) = 'FM' OR upper(unit) = 'FATHOM' OR upper(unit) = 'FATHOMS' then
			in_m := meas * 1.8288;		
		else
			in_m := null;
		end if;
	end if;
	
	return in_m;
  end;
  --create public synonym to_meters for to_meters;
  --grant execute on to_meters to public;
/

