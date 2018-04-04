--------------------------------------------------------------------------------
--
-- File name:   9i_swa.sql
-- Purpose:     Shortcut for 9i_sw for displaying info of active user sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sw <sid>
--              @sw 52,110,225
--              @sw "select sid from v$session where username = 'XYZ'"
--              @sw &mysid
--              @sw.sql "select sid from v$session where type != 'BACKGROUND'"
--		@sw.sql "select sid from v$session where type != 'BACKGROUND' and status='ACTIVE'"
--------------------------------------------------------------------------------

@9i_sw "select sid from v$session where type != 'BACKGROUND' and status='ACTIVE'"

