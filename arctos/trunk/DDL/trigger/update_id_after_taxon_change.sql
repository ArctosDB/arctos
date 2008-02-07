CREATE OR REPLACE TRIGGER update_id_after_taxon_change
after UPDATE ON taxonomy
for each row
BEGIN
if :new.scientific_name != :OLD.scientific_name then
    update identification SET
    scientific_name = replace(scientific_name,:OLD.scientific_name,:NEW.scientific_name)
     where identification_id IN (select identification_id from identification_taxonomy where taxon_name_id=:NEW.taxon_name_id)
     ;
end if;
END;
/
