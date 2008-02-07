CREATE OR REPLACE function cvsdata(str IN varchar2 )
    -- accepts string containing any characters
    -- returns string enclosed in doublequotes
    -- and stripped of evil CVS things 
    return VARCHAR2 DETERMINISTIC
    as
        mStr  VARCHAR2(4000);
	begin
	    mStr := '"' || REPLACE(str,'"','""') || '"';	    
	return mStr;
  end;
  --create public synonym cvsdata for cvsdata;
  --grant execute on cvsdata to public;
/

