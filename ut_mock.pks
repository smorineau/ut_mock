create or replace package ut_mock as

   type mock_details is record (mock_code clob, mockable_package varchar2(30), mockable_name varchar2(100));

   procedure use_mock(mock_package_name in varchar2, mock_name in varchar2);
   procedure reset_mock;
   function  find_mock(mock_package_source in clob, mock_name in varchar2) return mock_details;
   function replace_mockable(mockable_package_source in clob, mockable_name in varchar2, mock_code in clob) return clob;

   function  get_source_of(package_name in varchar2) return clob;
   procedure recompile(package_source in clob);
   procedure backup_package_source(package_name in varchar2, package_source in clob);

end;
/
show error