create or replace package body ut_mock as

   procedure use_mock(to_be_mocked in varchar2)
   is
   begin
      null;
   end;

   procedure reset_mock
   is
   begin
      null;
   end;

   function get_source_of(name in varchar2) return clob
   is
   begin
      -- dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'BODY', false);
      return dbms_metadata.get_ddl('PACKAGE_BODY', upper(name));
   end;

end;
/
show err