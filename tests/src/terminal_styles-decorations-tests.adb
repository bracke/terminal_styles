with AUnit.Assertions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Environment_Variables;

with Project_Tools.Files;

package body Terminal_Styles.Decorations.Tests is

   use AUnit.Assertions;
   overriding
   function Name (Item : Terminal_Format_Test) return AUnit.Message_String is
      pragma Unreferenced (Item);
   begin
      return AUnit.Format ("Terminal_Styles formatting");
   end Name;

   procedure Save_Environment
     (Name  : String;
      Found : out Boolean;
      Value : out Unbounded_String)
   is
   begin
      Found := Ada.Environment_Variables.Exists (Name);
      if Found then
         Value := To_Unbounded_String (Ada.Environment_Variables.Value (Name));
      else
         Value := Null_Unbounded_String;
      end if;
   end Save_Environment;

   procedure Restore_Environment
     (Name  : String;
      Found : Boolean;
      Value : Unbounded_String)
   is
   begin
      if Found then
         Ada.Environment_Variables.Set (Name, To_String (Value));
      else
         Ada.Environment_Variables.Clear (Name);
      end if;
   end Restore_Environment;

   Escape : constant String := Character'Val (27) & "[";
   Reset  : constant String := Escape & "0m";

   procedure Assert_Decoration
     (Decoration : Terminal_Styles.Text_Decoration; Code : String) is
   begin
      Assert
        (Terminal_Styles.Decorate ("x", Decoration) = Escape & Code & "mx" & Reset,
         "decoration code " & Code);
   end Assert_Decoration;

   procedure Assert_Color
     (Color           : Terminal_Styles.Terminal_Color;
      Foreground_Code : String;
      Background_Code : String) is
   begin
      Assert
        (Terminal_Styles.Decorate ("x", Color)
         = Escape & Foreground_Code & ";49mx" & Reset,
         "foreground color code " & Foreground_Code);
      Assert
        (Terminal_Styles.Decorate ("x", Terminal_Styles.Color_Default, Color)
         = Escape & "39;" & Background_Code & "mx" & Reset,
         "background color code " & Background_Code);
   end Assert_Color;

   procedure Assert_Role
     (Role   : Terminal_Styles.Style_Role;
      Marker : String;
      Code   : String) is
   begin
      Assert
        (Terminal_Styles.Decorate ("x", Role) = Escape & Code & "mx" & Reset,
         "role code " & Code);
      Assert
        (Terminal_Styles.Line ("x", Role)
         = Escape & Code & "m" & Marker & Reset & " "
           & Escape & Code & "mx" & Reset,
         "line output for role code " & Code);
   end Assert_Role;

   procedure Test_Markers (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
   begin
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Info) = "[*]", "info marker");
      Assert
        (Terminal_Styles.Marker (Terminal_Styles.Role_Success) = "[+]", "success marker");
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Error) = "[!]", "error marker");
      Assert
        (Terminal_Styles.Marker (Terminal_Styles.Role_Warning) = "[-]", "warning marker");
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Muted) = "[.]", "muted marker");
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Header) = "[=]", "header marker");
      Assert
        (Project_Tools.Files.File_Contains
           ("README.md", "alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check")
         or else Project_Tools.Files.File_Contains
           ("../README.md", "alr exec -- gnatprove -P terminal_styles.gpr --level=0 --mode=check"),
         "release verification documents the GNATprove check");
      Assert
        (Project_Tools.Files.File_Contains ("README.md", "check_terminal_styles")
         or else Project_Tools.Files.File_Contains ("../README.md", "check_terminal_styles"),
         "release verification documents the check_terminal_styles release checker");
   end Test_Markers;

   procedure Test_Color_Policy (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Never);
         Assert
           (Terminal_Styles.Current_Color_Policy = Terminal_Styles.Color_Never,
            "policy getter returns Color_Never");
         Assert (not Terminal_Styles.Color_Enabled, "Color_Never disables ANSI color");
         Assert
           (Terminal_Styles.Decorate ("text", Terminal_Styles.Role_Error) = "text",
            "disabled color leaves text unchanged");
         Assert
           (Terminal_Styles.Line ("failed", Terminal_Styles.Role_Error) = "[!] failed",
            "disabled color keeps marker and text");
         Assert
           (Terminal_Styles.Decorate ("text", Terminal_Styles.Decoration_Bold) = "text",
            "disabled color leaves decorated text unchanged");
         Assert
           (Terminal_Styles.Decorate ("text", Terminal_Styles.Color_Red, Terminal_Styles.Color_Blue)
            = "text",
            "disabled color leaves colored text unchanged");
         Assert
           (Terminal_Styles.Decorate
              ("text",
               Terminal_Styles.Decoration_Underline,
               Terminal_Styles.Color_Red,
               Terminal_Styles.Color_Blue)
            = "text",
            "disabled color leaves combined styling unchanged");

         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);
         Ada.Environment_Variables.Set ("NO_COLOR", "1");
         Assert
           (Terminal_Styles.Current_Color_Policy = Terminal_Styles.Color_Always,
            "policy getter returns Color_Always");
         Assert
           (Terminal_Styles.Color_Enabled,
            "Color_Always emits ANSI color even when NO_COLOR is set");

         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Auto);
         Assert
           (Terminal_Styles.Current_Color_Policy = Terminal_Styles.Color_Auto,
            "policy getter returns Color_Auto");
         Assert
           (not Terminal_Styles.Color_Enabled,
            "Color_Auto honors NO_COLOR");

         Ada.Environment_Variables.Clear ("NO_COLOR");
         Assert
           (not Terminal_Styles.Color_Enabled,
            "Color_Auto suppresses ANSI color when stdout is not a TTY");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;

      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Color_Policy;

   procedure Test_Decorations (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);
         Assert
           (Terminal_Styles.Color_Enabled, "Color_Always enables ANSI color");

         Assert_Decoration (Terminal_Styles.Decoration_Reset, "0");
         Assert_Decoration (Terminal_Styles.Decoration_Bold, "1");
         Assert_Decoration (Terminal_Styles.Decoration_Faint, "2");
         Assert_Decoration (Terminal_Styles.Decoration_Italic, "3");
         Assert_Decoration (Terminal_Styles.Decoration_Underline, "4");
         Assert_Decoration (Terminal_Styles.Decoration_Double_Underline, "21");
         Assert_Decoration (Terminal_Styles.Decoration_Slow_Blink, "5");
         Assert_Decoration (Terminal_Styles.Decoration_Rapid_Blink, "6");
         Assert_Decoration (Terminal_Styles.Decoration_Reverse, "7");
         Assert_Decoration (Terminal_Styles.Decoration_Conceal, "8");
         Assert_Decoration (Terminal_Styles.Decoration_Crossed_Out, "9");
         Assert_Decoration (Terminal_Styles.Decoration_Framed, "51");
         Assert_Decoration (Terminal_Styles.Decoration_Encircled, "52");
         Assert_Decoration (Terminal_Styles.Decoration_Overlined, "53");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Bold_Or_Faint, "22");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Italic, "23");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Underlined, "24");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Blinking, "25");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Reversed, "27");
         Assert_Decoration (Terminal_Styles.Decoration_Reveal, "28");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Crossed_Out, "29");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Framed_Or_Encircled, "54");
         Assert_Decoration (Terminal_Styles.Decoration_Not_Overlined, "55");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;

      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Decorations;

   procedure Test_Colors (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);

         Assert_Color (Terminal_Styles.Color_Default, "39", "49");
         Assert_Color (Terminal_Styles.Color_Black, "30", "40");
         Assert_Color (Terminal_Styles.Color_Red, "31", "41");
         Assert_Color (Terminal_Styles.Color_Green, "32", "42");
         Assert_Color (Terminal_Styles.Color_Yellow, "33", "43");
         Assert_Color (Terminal_Styles.Color_Blue, "34", "44");
         Assert_Color (Terminal_Styles.Color_Magenta, "35", "45");
         Assert_Color (Terminal_Styles.Color_Cyan, "36", "46");
         Assert_Color (Terminal_Styles.Color_White, "37", "47");
         Assert_Color (Terminal_Styles.Color_Bright_Black, "90", "100");
         Assert_Color (Terminal_Styles.Color_Bright_Red, "91", "101");
         Assert_Color (Terminal_Styles.Color_Bright_Green, "92", "102");
         Assert_Color (Terminal_Styles.Color_Bright_Yellow, "93", "103");
         Assert_Color (Terminal_Styles.Color_Bright_Blue, "94", "104");
         Assert_Color (Terminal_Styles.Color_Bright_Magenta, "95", "105");
         Assert_Color (Terminal_Styles.Color_Bright_Cyan, "96", "106");
         Assert_Color (Terminal_Styles.Color_Bright_White, "97", "107");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;

      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Colors;

   procedure Test_Combined_Styling (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);

         Assert_Role (Terminal_Styles.Role_Info, "[*]", "36");
         Assert_Role (Terminal_Styles.Role_Success, "[+]", "32;1");
         Assert_Role (Terminal_Styles.Role_Error, "[!]", "31;1");
         Assert_Role (Terminal_Styles.Role_Warning, "[-]", "33");
         Assert_Role (Terminal_Styles.Role_Muted, "[.]", "2");
         Assert_Role (Terminal_Styles.Role_Header, "[=]", "35;1");

         Assert
           (Terminal_Styles.Decorate
              ("x",
               Terminal_Styles.Decoration_Bold,
               Terminal_Styles.Color_Red,
               Terminal_Styles.Color_Blue)
            = Escape & "1;31;44mx" & Reset,
            "combined decoration and colors are emitted in one SGR sequence");
         Assert
           (Terminal_Styles.Decorate ("", Terminal_Styles.Role_Info)
            = Escape & "36m" & Reset,
            "empty strings are still wrapped when color is forced");

         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Never);
         Assert
           (Terminal_Styles.Decorate ("", Terminal_Styles.Role_Info) = "",
            "empty strings remain empty when color is disabled");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;

      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Combined_Styling;

   procedure Test_Info_Marker (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
   begin
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Info) = "[*]", "focused info marker");
   end Test_Info_Marker;

   procedure Test_Error_Marker (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
   begin
      Assert (Terminal_Styles.Marker (Terminal_Styles.Role_Error) = "[!]", "focused error marker");
   end Test_Error_Marker;

   procedure Test_Color_Never_Disables_Output (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      Saved_Policy : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Never);
      begin
         Assert (not Terminal_Styles.Color_Enabled, "focused color never disables color");
         Assert (Terminal_Styles.Decorate ("text", Terminal_Styles.Role_Error) = "text", "focused color never plain text");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            raise;
      end;
      Terminal_Styles.Set_Color_Policy (Saved_Policy);
   end Test_Color_Never_Disables_Output;

   procedure Test_Color_Always_Emits_Bold (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);
         Assert (Terminal_Styles.Decorate ("x", Terminal_Styles.Decoration_Bold) = Escape & "1mx" & Reset, "focused bold code");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;
      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Color_Always_Emits_Bold;

   procedure Test_Red_Foreground (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);
         Assert (Terminal_Styles.Decorate ("x", Terminal_Styles.Color_Red) = Escape & "31;49mx" & Reset, "focused red foreground");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;
      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Red_Foreground;

   procedure Test_Error_Role_Line (Item : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (Item);
      No_Color_Found : Boolean;
      No_Color_Value : Unbounded_String;
      Saved_Policy   : constant Terminal_Styles.Color_Policy := Terminal_Styles.Current_Color_Policy;
   begin
      Save_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
      begin
         Ada.Environment_Variables.Clear ("NO_COLOR");
         Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Always);
         Assert
           (Terminal_Styles.Line ("failed", Terminal_Styles.Role_Error)
            = Escape & "31;1m[!]" & Reset & " " & Escape & "31;1mfailed" & Reset,
            "focused error role line");
      exception
         when others =>
            Terminal_Styles.Set_Color_Policy (Saved_Policy);
            Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
            raise;
      end;
      Terminal_Styles.Set_Color_Policy (Saved_Policy);
      Restore_Environment ("NO_COLOR", No_Color_Found, No_Color_Value);
   end Test_Error_Role_Line;

   overriding
   procedure Register_Tests (Item : in out Terminal_Format_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (Item, Test_Markers'Access, "markers for semantic roles");
      Register_Routine (Item, Test_Info_Marker'Access, "focused info marker");
      Register_Routine (Item, Test_Error_Marker'Access, "focused error marker");
      Register_Routine (Item, Test_Color_Policy'Access, "color policy controls ANSI output");
      Register_Routine (Item, Test_Color_Never_Disables_Output'Access, "focused Color_Never policy");
      Register_Routine (Item, Test_Color_Always_Emits_Bold'Access, "focused bold decoration");
      Register_Routine (Item, Test_Decorations'Access, "ANSI decoration codes");
      Register_Routine (Item, Test_Colors'Access, "ANSI foreground/background colors");
      Register_Routine (Item, Test_Red_Foreground'Access, "focused red foreground");
      Register_Routine (Item, Test_Combined_Styling'Access, "combined styling and lines");
      Register_Routine (Item, Test_Error_Role_Line'Access, "focused error role line");
   end Register_Tests;

end Terminal_Styles.Decorations.Tests;
