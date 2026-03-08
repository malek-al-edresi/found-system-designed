SET SERVEROUTPUT ON;

DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := AuthZ_pkg.AuthZadmin('admin');

    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('AUTHORIZED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOT AUTHORIZED');
    END IF;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := AuthZ_pkg.AuthZsecurity('admin');

    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('AUTHORIZED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOT AUTHORIZED');
    END IF;
END;
/


return AuthZ_pkg.AuthZadmin(:APP_USER);
return AuthZ_pkg.AuthZsecurity(:APP_USER);



