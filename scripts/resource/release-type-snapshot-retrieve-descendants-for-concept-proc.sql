DROP PROCEDURE IF EXISTS findDescendants;
CREATE PROCEDURE findDescendants(conceptIds varchar(1000)) 
BEGIN
  DECLARE conceptId VARCHAR(20);  
  drop table if exists descendants;
  drop table if exists children;
  CREATE TABLE descendants (
    sourceid bigint(20),
    destinationid bigint(20)
  );
  CREATE TEMPORARY TABLE children LIKE descendants;
 
  WHILE conceptIds != '' DO
    SET conceptId = SUBSTRING_INDEX(conceptIds, ',', 1);      
    INSERT INTO descendants(sourceid) VALUES (conceptId);
    
    IF LOCATE(',', conceptIds) > 0 THEN
      SET conceptIds = SUBSTRING(conceptIds, LOCATE(',', conceptIds) + 1);
    ELSE
      SET conceptIds = '';
    END IF;
  END WHILE;  

  iter: LOOP
    INSERT INTO children (sourceid, destinationid)
      SELECT t.sourceid, t.destinationid FROM curr_stated_relationship_s t
        JOIN descendants d ON t.destinationid = d.sourceid
      WHERE t.typeid = '116680003';
    DELETE FROM children WHERE sourceid IN (SELECT sourceid FROM descendants);
    IF (SELECT count(*) FROM children) > 0 THEN
      INSERT INTO descendants (sourceid, destinationid) SELECT c.sourceid, c.destinationid FROM children c;
    ELSE
      LEAVE iter;
    END IF;
  END LOOP;

  DROP TABLE children;
END;