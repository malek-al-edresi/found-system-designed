SELECT
    'sales'                            AS card_id,
    (SELECT COUNT(*) FROM LF_REPORTS)  AS card_value,
    'Total Reports'                    AS card_label,
    'fa fa-file-text'                  AS card_icon,
    '#3498db'                          AS bg_color,
    '#ffffff'                          AS text_color,
    'f?p=&APP_ID.:2:&SESSION.'         AS link
FROM dual

UNION ALL

SELECT
    'items',
    (SELECT COUNT(*) FROM LF_FOUND_ITEMS),
    'Total Found Items',
    'fa fa-cube',
    '#d34c34',
    '#ffffff',
    NULL
FROM dual;