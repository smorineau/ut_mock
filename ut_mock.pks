create or replace package UT_MOCK as
   procedure USE_MOCK(TO_BE_MOCKED in varchar2);
   procedure reset_mock;
   function get_source_of(name in varchar2) return clob;
   procedure recompile(source in clob);
end;
/