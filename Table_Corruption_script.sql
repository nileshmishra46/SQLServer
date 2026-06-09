
--1. table backup
select * 
into hpsite.FORM_LETTER_TEMPLATES_bkup
from hpsite.FORM_LETTER_TEMPLATES

-------------------------------------------
--2. Fix corruption
ALTER DATABASE emr
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

--DBCC CHECKTABLE ('hpsite.messaging_hubqueue', repair_rebuild);
--GO


DBCC CHECKTABLE ('hpsite.FORM_LETTER_TEMPLATES', REPAIR_ALLOW_DATA_LOSS );
GO


ALTER DATABASE emr
SET MULTI_USER;

---------------------
--3. This should give you the number of rows missing. Should match from DBCC

select [FLT_CODE] from hpsite.FORM_LETTER_TEMPLATES_bkup
except
select [FLT_CODE] from HPSITE.FORM_LETTER_TEMPLATES

--4. Insert missing rows back in

set identity_insert hpsite.FORM_LETTER_TEMPLATES on
insert into HPSITE.FORM_LETTER_TEMPLATES
([FLT_CODE], [FLT_TYPE], [FLT_TYPE_TEXT], [FLT_NAME], [FLT_DATA], [IMREPROV_CODE], [FLT_ORIGIN], [FLT_ORDERED_FLAG], [FLT_SENDTO_FLAG], [TAG_ARCHIVED])
select * from hpsite.FORM_LETTER_TEMPLATES_bkup
where [FLT_CODE] in (select [FLT_CODE] from hpsite.FORM_LETTER_TEMPLATES_bkup
			except
			select [FLT_CODE] from HPSITE.FORM_LETTER_TEMPLATES)
set identity_insert hpsite.FORM_LETTER_TEMPLATES off

------------------------

--5. verify 0 rows returned

select [FLT_CODE] from hpsite.FORM_LETTER_TEMPLATES_bkup
except
select [FLT_CODE] from HPSITE.FORM_LETTER_TEMPLATES

--6. Verify corruption gone from table
dbcc checktable ('hpsite.FORM_LETTER_TEMPLATES')