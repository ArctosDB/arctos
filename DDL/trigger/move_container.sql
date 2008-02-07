CREATE OR REPLACE TRIGGER MOVE_CONTAINER
before UPDATE or INSERT ON container
--------------------------------------------------------------------------------------------------
-- this trigger checks that container movements are valid. The following rules are enforced:
-- 1) a container may not be moved to itself
-- 2) positions must be locked
	-- note: needs rewitten in forms so positions are simply dfined as locked;
	-- then, we can get rid of the locked_position column in the table
-- 3) collections objects cannot be parent containers
-- 4) labels (=upper(container_type) like '%LABEL%') cannot be parent or child containers
-- 5) child  width,height,length must all be less than or equal to parent  width,height,length, respectively
-- 6) locked containers (positions - see above comment) may not be moved to a new parent
--------------------------------------------------------------------------------------------------
for each row
declare
ct varchar2(60);
cw number;
ch number;
cd number;
 pt varchar2(60);
 pw number;
 ph number;
 pd number;
 cl number;
pragma autonomous_transaction;
BEGIN
if :new.container_id = :new.parent_container_id then
	 raise_application_error(
              -20000,
              'You cannot put a container into itself!'
            );
end if;

--if :new.container_type = 'position' AND :new.LOCKED_POSITION != 1 then
--	raise_application_error(
--              -20000,
--              'Positions must be locked.'
--            );
--end if;
if :new.parent_container_id != :old.parent_container_id then
/* they moved a container - run this trigger */
-- get data into local vars
select
container_type, width,height,length,locked_position into ct,cw,ch,cd,cl
 FROM container WHERE container_id=:new.container_id;
select
container_type,width,height,length into pt,pw,ph,pd
 FROM container WHERE container_id=:new.parent_container_id;
 -- see if they've done anything stoopid
         if pt = 'collection object' then
                 raise_application_error(
              -20000,
              'You cannot put anything in a collection object!'
            );
         end if;
         if pt LIKE '%label%' then
          raise_application_error(
              -20000,
              'You cannot put anything in a label! (container_id:' || :NEW.container_id || '; parent_container_id: ' || :NEW.parent_container_id
            );
         end if;
          if ct LIKE '%label%' then
          raise_application_error(
              -20000,
              'A label cannot have a parent!'
            );
         end if;
         if ch >= ph then
          raise_application_error(
              -20000,
              'The child won''t fit into the parent (check height)!'
            );
         end if;
          if cd >= pd then
          raise_application_error(
              -20000,
              'The child won''t fit into the parent (check length)!'
            );
         end if;
          if cw >= pw then
          raise_application_error(
              -20000,
              'The child won''t fit into the parent (check width)!'
            );
         end if;
          if cl = 1 then
          raise_application_error(
              -20000,
              'The position you are trying to move is locked.'
            );
         end if;
end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   -- ColdFusion hasn't commited yet - ignore and move right along....
   NULL;
END move_container;
--ALTER TRIGGER "UAM"."MOVE_CONTAINER" ENABLE
/

