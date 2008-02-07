/* Original
CREATE OR REPLACE FUNCTION function getLabelName(collobjid IN number, retval OUT varchar2(100))
declare n number;
begin
  select
      count(*) into n
  from
      collector,
      agent_name
  where
      collobjid = collector.collection_object_id AND
      collector.agent_id = agent_name.agent_id AND
      agent_name.agent_name_type = 'labels' AND
      collector_order = 1;
  if n=0 then
      select
          agent_name into retval
       from
          collector,
          preferred_agent_name
      where
          collobjid = collector.collection_object_id AND
          collector.agent_id = preferred_agent_name.agent_id AND
          collector_order = 1;
  else
      select
          agent_name into retval
      from
          collector,
          agent_name
      where
          collobjid = collector.collection_object_id AND
          collector.agent_id = agent_name.agent_id AND
          agent_name.agent_name_type = 'labels' AND
          collector_order = 1;
  endif;
  return retval;
end;
create public synonym getLabelName for getLabelName;
grant execute on getLabelName to public;
*/

/* Edited by LKV */
CREATE OR REPLACE FUNCTION getLabelName(collobjid IN number)
RETURN varchar2
AS
    n number;
    retval VARCHAR2(100);
BEGIN
    SELECT count(*) INTO n
    FROM collector, agent_name
    WHERE collobjid = collector.collection_object_id
    AND collector.agent_id = agent_name.agent_id
    AND agent_name.agent_name_type = 'labels'
    AND collector.coll_order = 1;
    IF n = 0 THEN
        SELECT agent_name INTO retval
        FROM collector, preferred_agent_name
        WHERE collobjid = collector.collection_object_id 
        AND collector.agent_id = preferred_agent_name.agent_id 
        AND collector.coll_order = 1;
    ELSE
        SELECT agent_name INTO retval
        FROM collector, agent_name
        WHERE collobjid = collector.collection_object_id
        AND collector.agent_id = agent_name.agent_id 
        AND agent_name.agent_name_type = 'labels' 
        AND collector.coll_order = 1;
    END IF;
    RETURN retval;
END;

CREATE PUBLIC SYNONYM getLabelName FOR getLabelName;
GRANT EXECUTE ON getLabelName TO PUBLIC;