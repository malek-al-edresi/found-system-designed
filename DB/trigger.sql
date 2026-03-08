-- Create triggers that depend on the function
CREATE OR REPLACE TRIGGER LF_REPORTS_LOG_ACTIVITY_LOG
    AFTER INSERT OR UPDATE OR DELETE ON LF_REPORTS
    FOR EACH ROW
BEGIN
    INSERT INTO LF_ACTIVITY_LOG (USERNAME, ACTION_TYPE)
    VALUES (get_current_app_user, 'LF_REPORTS_MODIFIED');
END;
/

CREATE OR REPLACE TRIGGER LF_FOUND_ITEMS_LOG_ACTIVITY_LOG
    AFTER INSERT OR UPDATE OR DELETE ON LF_FOUND_ITEMS
    FOR EACH ROW
BEGIN
    INSERT INTO LF_ACTIVITY_LOG (USERNAME, ACTION_TYPE)
    VALUES (get_current_app_user, 'LF_FOUND_ITEMS_MODIFIED');
END;
/

CREATE OR REPLACE TRIGGER LF_MATCHES_LOG_ACTIVITY_LOG
    AFTER INSERT OR UPDATE ON LF_MATCHES
    FOR EACH ROW
BEGIN
    INSERT INTO LF_ACTIVITY_LOG (USERNAME, ACTION_TYPE)
    VALUES (get_current_app_user, 'LF_MATCHES_MODIFIED');
END;
/


-- Create the trigger for hashing passwords
CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_OR_UPDATE_HASH_PASSWORD_USERS
BEFORE INSERT OR UPDATE ON USERS
FOR EACH ROW
DECLARE
    v_old_password_hash VARCHAR2(255);
BEGIN
    IF INSERTING THEN
        IF :new.USER_NAME IS NOT NULL AND :new.PASSWORD_HASH IS NOT NULL THEN
            ----------------------------------------------------------------------
            -- Hash the password using the (uppercased) username as salt       --
            ----------------------------------------------------------------------
            :new.PASSWORD_HASH := HASH_PASSWORD (
                P_USER_NAME => :new.USER_NAME,
                P_PASSWORD => :new.PASSWORD_HASH
            );
        END IF;
    ELSIF UPDATING THEN
        --------------------------------------------------------------------------
        -- Handle password update:                                              --
        -- - If a new password is provided, hash and store it.                  --
        -- - If the password field is left blank/null, retain the old password. --
        --------------------------------------------------------------------------
        IF :new.PASSWORD_HASH IS NOT NULL AND :new.PASSWORD_HASH != :old.PASSWORD_HASH THEN
            -- Hash the new password using the (uppercased) username as salt
            :new.PASSWORD_HASH := HASH_PASSWORD (
                 P_USER_NAME => :new.USER_NAME,
                 P_PASSWORD => :new.PASSWORD_HASH
            );
        ELSIF :new.PASSWORD_HASH IS NULL OR :new.PASSWORD_HASH = '' THEN
            -- Retain the old password hash if no new password is provided
            :new.PASSWORD_HASH := :old.PASSWORD_HASH;
        END IF;
    END IF;
END TRG_BEFORE_INSERT_OR_UPDATE_HASH_PASSWORD_USERS;
/