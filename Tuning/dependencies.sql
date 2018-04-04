accept ls_REF_name prompt .Enter an object to find references to: . ;

Select
TYPE || ' ' ||
OWNER || '.' || NAME || ' references ' ||
REFERENCED_TYPE || ' ' ||
REFERENCED_OWNER || '.' || REFERENCED_NAME
as DEPENDENCIES
From all_dependencies
Where name = UPPER(LTRIM(RTRIM( '&ls_REF_name' )))
AND (REFERENCED_OWNER <> 'SYS'
AND REFERENCED_OWNER <> 'SYSTEM'
AND REFERENCED_OWNER <> 'PUBLIC'
)
AND (OWNER <> 'SYS'
AND OWNER <> 'SYSTEM'
AND OWNER <> 'PUBLIC'
)
order by OWNER, name,
REFERENCED_TYPE ,
REFERENCED_OWNER ,
REFERENCED_name
/
