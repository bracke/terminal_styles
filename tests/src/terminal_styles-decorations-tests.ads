with AUnit;
with AUnit.Test_Cases;

--  AUnit test case for terminal_styles decoration behavior.
package Terminal_Styles.Decorations.Tests is

   --  Test case type that registers terminal_styles formatting tests.
   type Terminal_Format_Test is new AUnit.Test_Cases.Test_Case with null record;

   --  Return the display name for the terminal_styles formatting test case.
   --
   --  @param Item Test case instance.
   --  @return AUnit display name for the test case.
   overriding function Name (Item : Terminal_Format_Test) return AUnit.Message_String;

   --  Register all terminal_styles formatting test routines with AUnit.
   --
   --  @param Item Test case instance that receives routine registrations.
   overriding procedure Register_Tests (Item : in out Terminal_Format_Test);

end Terminal_Styles.Decorations.Tests;
