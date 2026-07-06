with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;

with Project_Tools.Alire_Manifests;
with Project_Tools.Files;
with Project_Tools.Processes;
with Project_Tools.Text;
with Project_Tools.Tree_Checks;

procedure Check_Terminal_Styles is
   use Ada.Text_IO;

   Build_Command : constant String := "alr build";
   Test_Command  : constant String := "alr test";
   Gnatprove_Check_Command : constant String :=
     "alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check";
   GNAT_Version_Check_Command : constant String := "alr exec -- gnatls --version";
   Tests_Run_Command : constant String := "alr exec -- ./bin/tests";

   function Root_Directory return String is
      Current : constant String := Ada.Directories.Current_Directory;
   begin
      if Ada.Directories.Exists (Current & "/terminal_styles.gpr") then
         return Current;
      elsif Ada.Directories.Exists (Current & "/../terminal_styles.gpr") then
         return Ada.Directories.Full_Name (Current & "/..");
      else
         Put_Line (Standard_Error, "terminal_styles root not found from " & Current);
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
         raise Program_Error;
      end if;
   end Root_Directory;

   Root   : constant String := Root_Directory;
   Errors : Natural := 0;

   procedure Error (Message : String) is
   begin
      Errors := Errors + 1;
      Put_Line (Standard_Error, "error: " & Message);
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end Error;

   procedure Require_Alire_GNAT_15 is
      Output : constant String :=
        Project_Tools.Processes.Shell_Output
          ("cd " & Project_Tools.Processes.Shell_Quote (Root) & " && " & GNAT_Version_Check_Command);
   begin
      Put_Line ("");
      Put_Line ("==> verify Alire-selected GNAT 15 toolchain");

      if Output = "" then
         Error ("alr exec -- gnatls --version failed");
      elsif Project_Tools.Text.Contains (Output, "GNATLS 15.") = False then
         Error ("terminal_styles must build with Alire-selected GNAT 15, got: " & Output);
      end if;
   end Require_Alire_GNAT_15;

   procedure Require_Text (Relative_Path : String; Pattern : String; Message : String) is
   begin
      Project_Tools.Files.Require_Contains (Root & "/" & Relative_Path, Pattern, Message);
   end Require_Text;

   procedure Require_GNAT_15_Manifest (Relative_Path : String) is
   begin
      Require_Text
        (Relative_Path,
         "gnat_native = ""=15.2.1""",
         Relative_Path & " must pin gnat_native = ""=15.2.1""");
   end Require_GNAT_15_Manifest;

   procedure Run_Command (Label : String; Dir : String; Command : String) is
      Status : Integer;
   begin
      Put_Line ("");
      Put_Line ("==> " & Label);

      Status := Project_Tools.Processes.Run_Shell_In_Directory (Dir, Command);
      if Status /= 0 then
         Error (Label & " failed with status" & Integer'Image (Status));
      end if;
   end Run_Command;

   procedure Check_Generated_Artifacts is
      Hygiene_Errors : Natural := 0;
   begin
      Project_Tools.Tree_Checks.Check_No_Generated_Python (Hygiene_Errors, Root & "/src");
      Project_Tools.Tree_Checks.Check_No_Generated_Python (Hygiene_Errors, Root & "/tests/src");
      Project_Tools.Tree_Checks.Check_No_Generated_Python (Hygiene_Errors, Root & "/examples");
      Errors := Errors + Hygiene_Errors;
   end Check_Generated_Artifacts;

begin
   Project_Tools.Processes.Require_Command ("alr", "alr executable not found on PATH");
   Require_Alire_GNAT_15;

   Project_Tools.Alire_Manifests.Require_Pin_Free_Crate_Manifest
     (Root & "/alire.toml", "terminal_styles");
   Require_GNAT_15_Manifest ("alire.toml");
   Require_GNAT_15_Manifest ("tests/alire.toml");
   Require_GNAT_15_Manifest ("examples/basic/alire.toml");
   Require_GNAT_15_Manifest ("tools/alire.toml");
   Require_GNAT_15_Manifest ("check_terminal_styles/alire.toml");

   Project_Tools.Files.Require_Files
     ([To_Unbounded_String (Root & "/README.md"),
       To_Unbounded_String (Root & "/terminal_styles.gpr"),
       To_Unbounded_String (Root & "/docs/SPARK.md"),
       To_Unbounded_String (Root & "/src/terminal_styles.ads"),
       To_Unbounded_String (Root & "/src/terminal_styles.adb"),
       To_Unbounded_String (Root & "/tests/alire.toml"),
       To_Unbounded_String (Root & "/tests/terminal_styles_tests.gpr"),
       To_Unbounded_String (Root & "/examples/basic/alire.toml"),
       To_Unbounded_String (Root & "/examples/basic/terminal_styles_basic_example.gpr")],
      "required terminal_styles release file missing");

   Require_Text
     ("README.md",
      "Release Verification",
      "README must document release verification");
   Require_Text
     ("README.md",
      "Do not run plain system GNAT",
      "README must forbid system GNAT/GPR tools");
   Require_Text
     ("README.md",
      "alr exec -- gnatls --version",
      "README must document GNAT 15 toolchain verification");
   Require_Text
     ("README.md",
      "alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check",
      "release verification must include GNATprove release check");
   Require_Text
     ("README.md",
      "cd examples/basic",
      "release verification must include example build");
   Require_Text
     ("README.md",
      "SPARK Coverage",
      "README must document SPARK coverage");
   Require_Text
     ("README.md",
      "docs/SPARK.md",
      "README must link SPARK coverage documentation");
   Require_Text
     ("docs/SPARK.md",
      "SGR_Code",
      "SPARK documentation must include deterministic SGR_Code coverage");
   Require_Text
     ("alire.toml",
      "type = ""test""",
      "Alire manifest must define a test action");
   Require_Text
     ("tests/alire.toml",
      "project_tools",
      "terminal_styles tests must use project_tools for shared tooling helpers");

   Check_Generated_Artifacts;

   Run_Command ("build terminal_styles library", Root, Build_Command);
   Run_Command ("run terminal_styles GNATprove release check", Root, Gnatprove_Check_Command);
   Run_Command ("build terminal_styles tests", Root & "/tests", Build_Command);
   Run_Command ("run terminal_styles tests", Root & "/tests", Tests_Run_Command);
   Run_Command ("run terminal_styles Alire test action", Root, Test_Command);
   Run_Command ("build terminal_styles basic example", Root & "/examples/basic", Build_Command);

   if Errors = 0 then
      Put_Line ("terminal_styles release check passed");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Success);
   else
      Put_Line
        (Standard_Error,
         "terminal_styles release check failed:" & Natural'Image (Errors) & " error(s)");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
exception
   when Program_Error =>
      null;
end Check_Terminal_Styles;
