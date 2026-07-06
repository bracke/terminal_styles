with Terminal_Styles.Decorations.Tests;

package body Terminal_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite
         := AUnit.Test_Suites.New_Suite;
   begin
      pragma Warnings (Off, "use of an anonymous access type allocator");
      Result.Add_Test (new Terminal_Styles.Decorations.Tests.Terminal_Format_Test);
      pragma Warnings (On, "use of an anonymous access type allocator");

      return Result;
   end Suite;

end Terminal_Suite;