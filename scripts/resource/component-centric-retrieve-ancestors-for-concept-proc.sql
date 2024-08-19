CREATE PROCEDURE findAncestors()
BEGIN
    DECLARE root_id BIGINT DEFAULT 0;
    DECLARE fid BIGINT DEFAULT 0;
    DECLARE str VARCHAR(1000) DEFAULT "";
    DECLARE colval BIGINT DEFAULT NULL;
    DECLARE done TINYINT DEFAULT FALSE;

    DECLARE cursor_concept_ids CURSOR FOR
SELECT t1.concept_id FROM v_attributedescription_and_attributetype_concept_ids t1;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

DROP TABLE IF EXISTS ancestors;
CREATE TABLE ancestors (
                           concept_id BIGINT,
                           parents VARCHAR(1000)
);

OPEN cursor_concept_ids;
my_loop: LOOP
        FETCH cursor_concept_ids INTO colval;
        IF done THEN
            LEAVE my_loop;
ELSE
            SET root_id = colval;
            WHILE root_id > 0 DO
                SET fid = (SELECT destinationId FROM curr_relationship_s WHERE root_id = sourceid AND active = 1 AND typeid = '116680003');
                IF fid > 0 THEN
                    SET str = CONCAT(str, ',', fid);
                    SET root_id = fid;
ELSE
                    SET root_id = 0;
END IF;
END WHILE;
            INSERT IGNORE INTO ancestors VALUES (colval, str);
            SET str = "";
END IF;
END LOOP;
CLOSE cursor_concept_ids;
END;