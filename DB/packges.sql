create or replace PACKAGE AuthZ_pkg AS 
    FUNCTION AuthZadmin ( 
        p_username IN VARCHAR2 
    ) RETURN BOOLEAN; 
 
    FUNCTION AuthZsecurity ( 
        p_username IN VARCHAR2 
    ) RETURN BOOLEAN; 
END AuthZ_pkg;
/
create or replace PACKAGE BODY AuthZ_pkg AS 
     
    FUNCTION AuthZadmin ( 
        p_username IN VARCHAR2 
    ) RETURN BOOLEAN IS 
        v_count NUMBER; 
        v_is_admin BOOLEAN; 
    BEGIN 
        SELECT COUNT(*) 
        INTO v_count 
        FROM VIEW_USERS 
        WHERE UPPER(USER_NAME) = UPPER(p_username)  
          AND UPPER(ROLE_TYPE) = UPPER('ADMIN'); 
 
        v_is_admin := CASE WHEN v_count > 0 THEN TRUE ELSE FALSE END; 
        RETURN v_is_admin; 
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            RETURN FALSE; 
        WHEN OTHERS THEN 
            -- Log error using centralized error handling if available 
            RETURN FALSE; 
    END AuthZadmin; 
 
    FUNCTION AuthZsecurity ( 
        p_username IN VARCHAR2 
    ) RETURN BOOLEAN IS 
        v_count NUMBER; 
        v_is_security BOOLEAN; 
    BEGIN 
        SELECT COUNT(*) 
        INTO v_count 
        FROM VIEW_USERS 
        WHERE UPPER(USER_NAME) = UPPER(p_username)  
          AND (UPPER(ROLE_TYPE) = 'ADMIN' OR UPPER(ROLE_TYPE) = 'STAFF'); 
 
        v_is_security := CASE WHEN v_count > 0 THEN TRUE ELSE FALSE END; 
        RETURN v_is_security; 
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            RETURN FALSE; 
        WHEN OTHERS THEN 
            -- Log error using centralized error handling if available 
            RETURN FALSE; 
    END AuthZsecurity; 
 
END AuthZ_pkg;
/