DROP PROCEDURE IF EXISTS findAncestors;
CREATE PROCEDURE findAncestors()
BEGIN
	DECLARE root_id bigint(20) DEFAULT 0;
	DECLARE fid bigint(20) DEFAULT 0;
	DECLARE str VARCHAR(1000) DEFAULT "";
	DECLARE colval bigint(20) DEFAULT null;
	DECLARE done TINYINT DEFAULT false;
	DECLARE cursor_concept_ids CURSOR FOR select t1.concept_id from v_attributedescription_and_attributetype_concept_ids t1;
	DECLARE continue handler for not found set done = true;

	DROP TABLE IF EXISTS ancestors;
	CREATE TABLE ancestors (
		concept_id bigint(20),
		parents VARCHAR(1000)
	);
	
	OPEN cursor_concept_ids;
		my_loop: loop
			fetch next from cursor_concept_ids into colval;
			set root_id = colval;
			IF done then 
				leave my_loop;
			ELSE
				WHILE root_id > 0 DO
					SET fid = (SELECT destinationId FROM relationship_s WHERE root_id = sourceid and active = 1 and typeid = '116680003');
					IF fid > 0 THEN
						SET str = concat(str,',',fid);
						SET root_id = fid;
					ELSE
						SET root_id = fid;
					END IF;
				END WHILE;
				INSERT IGNORE INTO ancestors VALUES (colval, str);
				SET str = "";
			END IF;
		END loop;
	CLOSE cursor_concept_ids;
END;