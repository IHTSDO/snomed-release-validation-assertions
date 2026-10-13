DROP PROCEDURE IF EXISTS findAncestors;
CREATE PROCEDURE findAncestors(conceptIdsTable VARCHAR(255), ancestorsTable VARCHAR(255))
BEGIN
    DECLARE root_id BIGINT DEFAULT 0;
    DECLARE fid BIGINT DEFAULT 0;
    DECLARE str VARCHAR(1000) DEFAULT "";
    DECLARE colval BIGINT DEFAULT NULL;
    DECLARE done TINYINT DEFAULT FALSE;

    DECLARE cursor_concept_ids CURSOR FOR
SELECT t1.concept_id FROM temp_find_ancestors_concept_ids t1;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

DROP TEMPORARY TABLE IF EXISTS temp_find_ancestors_concept_ids;
SET @findAncestorsSql = CONCAT('CREATE TEMPORARY TABLE temp_find_ancestors_concept_ids AS SELECT DISTINCT concept_id FROM ', conceptIdsTable, ' WHERE concept_id IS NOT NULL');
PREPARE statement FROM @findAncestorsSql;
EXECUTE statement;
DEALLOCATE PREPARE statement;

SET @findAncestorsSql = CONCAT('DROP TABLE IF EXISTS ', ancestorsTable);
PREPARE statement FROM @findAncestorsSql;
EXECUTE statement;
DEALLOCATE PREPARE statement;

SET @findAncestorsSql = CONCAT('CREATE TABLE ', ancestorsTable, ' (concept_id BIGINT, parents VARCHAR(1000))');
PREPARE statement FROM @findAncestorsSql;
EXECUTE statement;
DEALLOCATE PREPARE statement;

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
            SET @findAncestorsSql = CONCAT('INSERT IGNORE INTO ', ancestorsTable, ' VALUES (', colval, ', ''', str, ''')');
            PREPARE statement FROM @findAncestorsSql;
            EXECUTE statement;
            DEALLOCATE PREPARE statement;
            SET str = "";
END IF;
END LOOP;
CLOSE cursor_concept_ids;

DROP TEMPORARY TABLE IF EXISTS temp_find_ancestors_concept_ids;
END;
