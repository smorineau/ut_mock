create or replace package body ut_mock as

   procedure use_mock(mock_package_name in varchar2, mock_name in varchar2)
   is
      mock                     mock_details;
      mockable_package_source  clob;
   begin
      mock := find_mock(get_source_of(mock_package_name), mock_name);
      mockable_package_source := get_source_of(mock.mockable_package);
      backup_package_source(mock.mockable_package, mockable_package_source);
      recompile(replace_mockable(mockable_package_source, mock.mockable_name, mock.mock_code));
   end;

   procedure reset_mock
   is
   begin
      for to_be_recompiled in (select package_source from ut_mockable_packages)
      loop
         recompile(to_be_recompiled.package_source);
      end loop;
      execute immediate 'truncate table ut_mockable_packages';
   end;

   function find_mock(mock_package_source in clob, mock_name in varchar2) return mock_details
   is
      start_mock_pattern      constant varchar2(100) := '--\s*@Mock\s*\[' || mock_name || '\]';
      end_mock_pattern        constant varchar2(100) := '--\s*@Endmock';
      mock_pattern            constant varchar2(100) := '--\s*@Mock\s*\[' || mock_name || '\].*?--\s*@Endmock';
      target_package_pattern  constant varchar2(100) := '--\s*@Mock\s*\[' || mock_name || '\]\s*::\s*(\w+)\s*.*';
      target_entity_pattern   constant varchar2(100) := '--\s*@Mock\s*\[' || mock_name || '\]\s*::\s*\w+\s*\.\s*(\w+).*';
      mock_code_pattern       constant varchar2(100) := '--\s*@Mock\s*\[' || mock_name || '\]\s*::\s*\w+\s*\.\s*\w+\s*(.*).--\s*@Endmock';
      mock_code               clob;
      result                  mock_details;
      extract                 clob;
   begin
      extract := regexp_substr(mock_package_source, mock_pattern, 1, 1, 'ni');
      result.mockable_package := regexp_replace(extract, target_package_pattern, '\1', 1, 1, 'ni');
      result.mockable_name := regexp_replace(extract, target_entity_pattern, '\1', 1, 1, 'ni');
      mock_code := regexp_replace(extract, mock_code_pattern, '\1', 1, 1, 'ni');
      result.mock_code := replace(mock_code, mock_name, result.mockable_name);
      return result;
   end;

   function replace_mockable(mockable_package_source in clob, mockable_name in varchar2, mock_code in clob) return clob
   is
      mockable_pattern        constant varchar2(100) := '--\s*@Mockable\s*\[' || mockable_name || '\].*--\s*@EndMockable';
   begin
      return regexp_replace(mockable_package_source, mockable_pattern, mock_code, 1, 1, 'ni');
   end;

   function get_source_of(package_name in varchar2) return clob
   is
   begin
      -- dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'BODY', false);
      return dbms_metadata.get_ddl('PACKAGE_BODY', upper(package_name));
   end;

   procedure recompile(package_source in clob)
   is
      a number;
   begin
--      commit;
--      dbms_output.put_line(source);
--      dbms_job.submit(a, 'begin execute immediate ''' || package_source || '''; end;');
--      commit;
--dbms_output.put_line(package_source);
      commit;
      execute immediate package_source;
      commit;
      execute immediate ('alter package action compile package');
--      null;
   end;

   procedure backup_package_source(package_name in varchar2, package_source in clob)
   is
   begin
      /*
      merge into ut_mockable_packages target
      using (select package_name, package_source from ut_mockable_packages) source
      on (source.package_name = backup_package_source.package_name)
      when not matched then
         insert values (backup_package_source.package_name, backup_package_source.package_source);
      */
      insert into ut_mockable_packages values (backup_package_source.package_name, backup_package_source.package_source);
   exception
      when dup_val_on_index then
         null;
   end;

end;
/
show err