create or replace FUNCTION AUTHENTICATE_USER (  
        P_USERNAME IN VARCHAR2,  
        P_PASSWORD IN VARCHAR2  
) RETURN BOOLEAN IS  
        L_USERNAME        VARCHAR2(4000) := UPPER(P_USERNAME);  
        L_PASSWORD        VARCHAR2(4000);  
        L_HASHED_PASSWORD VARCHAR2(4000);  
        L_COUNT           NUMBER;  
        L_CHK_ACTIVE_USER USERS.ACTIVE_USER%TYPE;  
BEGIN  
        SELECT COUNT(*) INTO L_COUNT FROM USERS WHERE UPPER(USER_NAME) = L_USERNAME;  
          
        IF L_COUNT > 0 THEN  
            SELECT ACTIVE_USER INTO L_CHK_ACTIVE_USER FROM USERS WHERE UPPER(USER_NAME) = L_USERNAME;  
              
            IF L_CHK_ACTIVE_USER = 0 THEN  
                APEX_UTIL.SET_AUTHENTICATION_RESULT(2);  
                RETURN FALSE;  
            END IF;  
              
            L_HASHED_PASSWORD := HASH_PASSWORD(P_USERNAME, P_PASSWORD);  
            SELECT PASSWORD_HASH INTO L_PASSWORD FROM USERS WHERE UPPER(USER_NAME) = L_USERNAME;  
              
            IF L_HASHED_PASSWORD = L_PASSWORD THEN  
                APEX_UTIL.SET_AUTHENTICATION_RESULT(0);  
                RETURN TRUE;  
            ELSE  
                APEX_UTIL.SET_AUTHENTICATION_RESULT(4);  
                RETURN FALSE;  
            END IF;  
        ELSE  
            APEX_UTIL.SET_AUTHENTICATION_RESULT(1);  
            RETURN FALSE;  
        END IF;  
    EXCEPTION  
        WHEN OTHERS THEN  
            RETURN FALSE;  
    END AUTHENTICATE_USER;
/
create or replace FUNCTION get_current_app_user RETURN VARCHAR2 IS  
BEGIN  
        RETURN COALESCE(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), USER);  
END;
/
create or replace FUNCTION HASH_PASSWORD ( 
        P_USER_NAME IN VARCHAR2, 
        P_PASSWORD  IN VARCHAR2 
) RETURN VARCHAR2 IS 
        v_user_name_upper VARCHAR2(255) := UPPER(P_USER_NAME); 
        L_PASSWORD VARCHAR2(255); 
    BEGIN 
        -- Hash password with username as salt 
        SELECT STANDARD_HASH(v_user_name_upper || P_PASSWORD, 'SHA512') 
        INTO L_PASSWORD FROM DUAL; 
         
        -- Return hashed password 
        RETURN L_PASSWORD; 
EXCEPTION 
    WHEN OTHERS THEN 
        RETURN NULL; 
END HASH_PASSWORD;
/
create or replace FUNCTION JWT RETURN BOOLEAN IS  
        V_X01      VARCHAR2(32767) := V('APP_AJAX_X01');  
        L_JWT      APEX_JWT.T_TOKEN;  
        L_JWT_USER VARCHAR2(255);  
    BEGIN  
        IF V_X01 LIKE '%.%.%' THEN  
            L_JWT := APEX_JWT.DECODE(  
                P_VALUE => V_X01,  
                P_SIGNATURE_KEY => SYS.UTL_RAW.CAST_TO_RAW('secretKey')  
            );  
              
            APEX_JWT.VALIDATE(  
                P_TOKEN => L_JWT,  
                P_ISS => 'TokenProvider',  
                P_AUD => 'Admins'  
            );  
              
            APEX_JSON.PARSE(P_SOURCE => L_JWT.PAYLOAD);  
            L_JWT_USER := APEX_JSON.GET_VARCHAR2('sub');  
        END IF;  
          
        IF APEX_AUTHENTICATION.IS_PUBLIC_USER THEN  
            IF L_JWT_USER IS NOT NULL THEN  
                APEX_AUTHENTICATION.POST_LOGIN(  
                    P_USERNAME => L_JWT_USER,  
                    P_PASSWORD => NULL  
                );  
            ELSE  
                RETURN FALSE;  
            END IF;  
        ELSIF APEX_APPLICATION.G_USER <> L_JWT_USER THEN  
            RETURN FALSE;  
        END IF;  
          
        RETURN TRUE;  
    EXCEPTION  
        WHEN OTHERS THEN  
            RETURN FALSE;  
END JWT;
/
create or replace FUNCTION NEED_MFA 
( 
    P_USERNAME VARCHAR2 
) 
RETURN NUMBER 
IS 
    V_COUNT NUMBER; 
BEGIN 
 
    SELECT LOGIN_COUNT 
    INTO V_COUNT 
    FROM USERS 
    WHERE USER_NAME = P_USERNAME; 
 
    IF V_COUNT >= 5 THEN 
        RETURN 1; 
    ELSE 
        RETURN 0; 
    END IF; 
 
END;
/
create or replace FUNCTION NEED_OTP 
( 
    P_USERNAME VARCHAR2 
) 
RETURN NUMBER 
IS 
    V_LAST DATE; 
    V_USER VARCHAR2(100); 
BEGIN 
 
    V_USER := UPPER(P_USERNAME); 
 
    SELECT LAST_VERIFIED 
    INTO V_LAST 
    FROM USER_MFA 
    WHERE UPPER(USER_NAME) = V_USER; 
 
    IF V_LAST < SYSDATE - 10 THEN 
        RETURN 1; 
    ELSE 
        RETURN 0; 
    END IF; 
 
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
    RETURN 1; 
 
END;
/
create or replace FUNCTION USER_EXISTS
(
    P_USERNAME VARCHAR2
)
RETURN NUMBER
IS
    V_COUNT NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO V_COUNT
    FROM USERS
    WHERE UPPER(USER_NAME) = UPPER(P_USERNAME)
    AND ACTIVE_USER = 1;

    RETURN V_COUNT;

END;
/
create or replace FUNCTION VERIFY_OTP 
( 
    P_USERNAME VARCHAR2, 
    P_OTP VARCHAR2 
) 
RETURN NUMBER 
IS 
    V_COUNT NUMBER; 
    V_USER  VARCHAR2(100); 
BEGIN 
 
    V_USER := UPPER(P_USERNAME); 
 
    SELECT COUNT(*) 
    INTO V_COUNT 
    FROM ADMIN_OTP 
    WHERE UPPER(USER_NAME) = V_USER 
    AND OTP_CODE = P_OTP 
    AND EXPIRES_AT > SYSTIMESTAMP; 
 
    IF V_COUNT = 1 THEN 
 
        MERGE INTO USER_MFA T 
        USING (SELECT V_USER U FROM DUAL) S 
        ON (UPPER(T.USER_NAME) = S.U) 
 
        WHEN MATCHED THEN 
        UPDATE SET LAST_VERIFIED = SYSDATE 
 
        WHEN NOT MATCHED THEN 
        INSERT (USER_NAME, LAST_VERIFIED) 
        VALUES (V_USER, SYSDATE); 
 
    END IF; 
 
    RETURN V_COUNT; 
 
END;
/
