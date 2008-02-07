ALTER TABLE identification_agent
add CONSTRAINT fk_identification_id
  FOREIGN KEY (identification_id)
  REFERENCES identification(identification_id);

ALTER TABLE identification_agent
add CONSTRAINT fk_id_agent_id
  FOREIGN KEY (agent_id)
  REFERENCES agent(agent_id);

create index id_agnt_agnt_id on identification_agent(agent_id);
create index id_agnt_ident_id on identification_agent(identification_id);