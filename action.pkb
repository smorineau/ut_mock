create or replace package body action as

   -- @mockable perform_mockable
   function perform return boolean
   is
   begin
     return false;
   end;
   -- @endmockable

end;
/
show err