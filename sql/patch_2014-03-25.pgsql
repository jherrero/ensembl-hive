
-- initially duplicate 'meta' table with 'pipeline_wide_parameters'

CREATE TABLE pipeline_wide_parameters (
    param_name              VARCHAR(255) NOT NULL PRIMARY KEY,
    param_value             TEXT

);
CREATE        INDEX ON pipeline_wide_parameters (param_value);

INSERT INTO pipeline_wide_parameters(param_name, param_value) SELECT meta_key, meta_value FROM meta;

    -- UPDATE hive_sql_schema_version
UPDATE hive_meta SET meta_value=57 WHERE meta_key='hive_sql_schema_version' AND meta_value='56';

