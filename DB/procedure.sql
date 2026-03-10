Schema	
Object Type	
Object Name	
Script
Script
create or replace PROCEDURE API_LF_REPORTS
(
    P_STUDENT_ID IN VARCHAR2,
    P_STUDENT_NAME IN VARCHAR2,
    P_PHONE_NUMBER IN VARCHAR2,
    P_ITEM_TYPE IN VARCHAR2,
    P_DESCRIPTION IN CLOB,
    P_LOCATION_LOST IN VARCHAR2
) AS
BEGIN
    INSERT INTO LF_REPORTS (STUDENT_ID, STUDENT_NAME, PHONE_NUMBER, ITEM_TYPE, DESCRIPTION, LOCATION_LOST)
    VALUES (P_STUDENT_ID, P_STUDENT_NAME, P_PHONE_NUMBER, P_ITEM_TYPE, P_DESCRIPTION, P_LOCATION_LOST);
END;
/
create or replace PROCEDURE GENERATE_OTP 
( 
    P_USERNAME VARCHAR2,
    P_OUT_OTP  OUT VARCHAR2
) 
IS 
    V_OTP VARCHAR2(6); 
    V_USER VARCHAR2(100); 
BEGIN 
 
    V_USER := UPPER(P_USERNAME); 
 
    V_OTP := TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100000,999999))); 

    P_OUT_OTP := V_OTP;
 
    DELETE FROM ADMIN_OTP 
    WHERE UPPER(USER_NAME) = V_USER; 
 
    INSERT INTO ADMIN_OTP 
    ( 
        USER_NAME, 
        OTP_CODE, 
        EXPIRES_AT 
    ) 
    VALUES 
    ( 
        V_USER, 
        V_OTP, 
        SYSTIMESTAMP + INTERVAL '5' MINUTE 
    ); 

    commit;
 
END;
/
create or replace PROCEDURE LOGIN_WITH_OTP
(
    P_USERNAME   IN VARCHAR2,
    P_PASSWORD   IN VARCHAR2,
    P_OTP        IN VARCHAR2
)
IS
    v_otp VARCHAR2;
BEGIN

    IF USER_EXISTS(P_USERNAME) = 1 THEN

        IF P_OTP IS NULL THEN

            IF NEED_OTP(P_USERNAME) = 1 THEN

                GENERATE_OTP(P_USERNAME,v_otp);

                raise_application_error(
                    -20001,
                    'OTP Login : ' ||  v_otp
                );

            END IF;

        ELSE

            IF VERIFY_OTP(P_USERNAME,P_OTP) = 1 THEN

                APEX_AUTHENTICATION.LOGIN(
                    p_username => P_USERNAME,
                    p_password => P_PASSWORD
                );

            ELSE

                raise_application_error(
                    -20002,
                    'Invalid OTP'
                );

            END IF;

        END IF;

    ELSE

        raise_application_error(
            -20003,
            'User not found'
        );

    END IF;

END;
/
create or replace PROCEDURE SEND_LOGIN_OTP
(
    P_USERNAME VARCHAR2
)
IS
    V_OTP VARCHAR2(6);
    V_EMAIL VARCHAR2(100);
BEGIN

    V_OTP := TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100000,999999)));

    DELETE FROM ADMIN_OTP
    WHERE USER_NAME = P_USERNAME;

    INSERT INTO ADMIN_OTP
    VALUES
    (
        P_USERNAME,
        V_OTP,
        SYSTIMESTAMP + INTERVAL '5' MINUTE
    );

    SELECT EMAIL INTO V_EMAIL
    FROM VIEW_USERS  
    WHERE USER_NAME = P_USERNAME; 

    APEX_MAIL.SEND (
        p_to   =>  V_EMAIL,
        p_from => 'noreply@system.com',
        p_subj => 'Your login verification code',
        p_body => 'Your OTP code is: ' || V_OTP
    );

    APEX_MAIL.PUSH_QUEUE;

END;
/
create or replace PROCEDURE SEND_WHATSAPP_MATCH
(
    P_MATCH_ID IN NUMBER
)
IS
    V_PHONE   VARCHAR2(50);
    V_MESSAGE VARCHAR2(4000);
BEGIN

    SELECT 
        REPLACE(PHONE_NUMBER,'+',''),
        MESSAGE
    INTO
        V_PHONE,
        V_MESSAGE
    FROM VIEW_MATCH_MESSAGES
    WHERE MATCH_ID = P_MATCH_ID;


    APEX_UTIL.REDIRECT_URL(
        'javascript:window.open("https://wa.me/' || V_PHONE ||
        '?text=' || UTL_URL.ESCAPE(V_MESSAGE) || '","_blank");'
    );

END SEND_WHATSAPP_MATCH;
/
create or replace PROCEDURE UPDATE_LOGIN_COUNT
(
    P_USERNAME VARCHAR2
)
IS
BEGIN

    UPDATE USERS
    SET LOGIN_COUNT = NVL(LOGIN_COUNT,0) + 1
    WHERE USER_NAME = P_USERNAME;

END;
/