with AUnit; use AUnit;
with AUnit.Test_Suites; use AUnit.Test_Suites;

--  Root AUnit suite provider for the terminal test executable.
package All_Suites is

   --  Return the complete AUnit test suite.
   --
   --  @return Access to the root test suite.
   function Suite return Access_Test_Suite;

end All_Suites;
