CREATE OR REPLACE FUNCTION CONCATIDRBYIDID (p_key_val  in number )
return varchar2
as
type rc is ref cursor;
l_str    varchar2(4000);
l_sep    varchar2(3);
l_val    varchar2(4000);
l_cur    rc;
begin
open l_cur for 'select agent_name
from
    preferred_agent_name,identification_agent
where
identification_agent.agent_id=preferred_agent_name.agent_id AND
identification_agent.identification_id= :x
order by identifier_order'
using p_key_val;
loop
fetch l_cur into l_val;
exit when l_cur%notfound;
l_str := l_str || l_sep || l_val;
l_sep := ', ';
end loop;
close l_cur;
       return l_str;
  end;
/
show err
create or replace public synonym CONCATIDRBYIDID for CONCATIDRBYIDID;
grant execute on CONCATIDRBYIDID to public;