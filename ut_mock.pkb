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

   function find_mock(content in clob, mock_entity in varchar2) return mock_details
   is
      mock_pattern      constant varchar2(100) := '--\s*@Mock\s*' || mock_entity || '.*--\s*@Endmock';
      target_package_pattern      constant varchar2(100) := '--\s*@Mock\s*' || mock_entity || '\s*::\s*(\w+)\s*.*';
      target_entity_pattern      constant varchar2(100) := '--\s*@Mock\s*' || mock_entity || '\s*::\s*\w+\s*\.\s*(\w+).*';
      mock_code_pattern      constant varchar2(100) := '--\s*@Mock\s*' || mock_entity || '.*$(.*)\s*--\s*@Endmock';
      result       mock_details;
      extract      clob;
   begin
      extract := regexp_substr(content, mock_pattern, 1, 1, 'ni');
      result.mock_code := extract;
      result.target_package := regexp_replace(extract, target_package_pattern, '\1', 1, 1, 'ni');
      result.target_entity := regexp_replace(extract, target_entity_pattern, '\1', 1, 1, 'ni');
      return result;
   end;

   function get_source_of(name in varchar2) return clob
   is
   begin
      -- dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'BODY', false);
      return dbms_metadata.get_ddl('PACKAGE_BODY', upper(name));
   end;

   procedure recompile(source in clob)
   is
      a number;
   begin
--      commit;
--      dbms_output.put_line(source);
      dbms_job.submit(a, 'begin execute immediate ''' || source || '''; end;');
--      commit;

      execute immediate source;
      null;
   end;

end;
/
show err