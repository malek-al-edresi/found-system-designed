    select 'admin' as value_display,
            1      as value_return
    from dual
    union all
    select 'security' as value_display,
            2      as value_return
    from dual;

    
-- REPORT STATUS LOV
SELECT 'Pending' display_value, 'PENDING' return_value FROM dual
UNION ALL
SELECT 'Matched', 'MATCHED' FROM dual
UNION ALL
SELECT 'Claimed', 'CLAIMED' FROM dual
    

-- FOUND ITEM STATUS LOV
SELECT 'Available' display_value, 'AVAILABLE' return_value FROM dual
UNION ALL
SELECT 'Claimed', 'CLAIMED' FROM dual

-- MATCH STATUS LOV
SELECT 'Under Review' display_value, 'UNDER_REVIEW' return_value FROM dual
UNION ALL
SELECT 'Verified', 'VERIFIED' FROM dual
UNION ALL
SELECT 'Rejected', 'REJECTED' FROM dual
UNION ALL
SELECT 'Claimed', 'CLAIMED' FROM dual

-- ACTIVE USER LOV
SELECT 'Active' display_value, 1 return_value FROM dual
UNION ALL
SELECT 'Inactive', 0 FROM dual

-- FOUND ITEM LIST LOV
SELECT ITEM_TYPE || ' - ' || STORAGE_LOCATION display_value,
       ITEM_ID return_value
FROM LF_FOUND_ITEMS
ORDER BY CREATED_AT DESC;

-- ITEM TYPE LOV
SELECT 'Wallet' DISPLAY_VALUE,'Wallet' RETURN_VALUE FROM dual
UNION ALL
SELECT 'Mobile Phone','Mobile Phone' FROM dual
UNION ALL
SELECT 'Laptop','Laptop' FROM dual
UNION ALL
SELECT 'Backpack','Backpack' FROM dual
UNION ALL
SELECT 'Keys','Keys' FROM dual
UNION ALL
SELECT 'Water Bottle','Water Bottle' FROM dual
UNION ALL
SELECT 'Sunglasses','Sunglasses' FROM dual;