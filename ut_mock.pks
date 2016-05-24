create or replace package ut_mock as

   type mock_details is record (mock_code clob, target_package varchar2(30), target_entity varchar2(100));

   procedure use_mock(to_be_mocked in varchar2);
   procedure reset_mock;
   function  get_source_of(name in varchar2) return clob;
   procedure recompile(source in clob);
   function  find_mock(content in clob, mock_entity in varchar2) return mock_details;
   function replace_mockable(source in clob, target_entity in varchar2, mock in clob) return clob;

end;
/
show error