DROP TABLE IF EXISTS message;
CREATE TABLE message (
    created TIMESTAMP NOT NULL,
    id VARCHAR(256) NOT NULL,
    int_id VARCHAR(16) NOT NULL,
    str VARCHAR(600) NOT NULL,
    status BOOL,
    CONSTRAINT message_id_pk PRIMARY KEY(id)
);
CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);


DROP TABLE IF EXISTS log;
CREATE TABLE log (
    created TIMESTAMP NOT NULL,
    int_id VARCHAR(16) NOT NULL,
    str VARCHAR(600),
    address VARCHAR(256)
);
CREATE INDEX log_address_idx ON log (address);
