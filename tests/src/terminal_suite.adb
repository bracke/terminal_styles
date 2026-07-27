with Terminal_Styles.Decorations.Tests;
with AUnit.Test_Cases;

package body Terminal_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite
         := AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (AUnit.Test_Cases.Test_Case_Access'(new Terminal_Styles.Decorations.Tests.Terminal_Format_Test));

      return Result;
   end Suite;

end Terminal_Suite;