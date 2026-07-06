with AUnit.Test_Suites; use AUnit.Test_Suites;

--  AUnit suite provider for terminal_styles-specific tests.
package Terminal_Suite is

   --  Return the terminal_styles-specific AUnit test suite.
   --
   --  @return Access to the terminal_styles test suite.
   function Suite return Access_Test_Suite;

end Terminal_Suite;
