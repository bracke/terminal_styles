with Ada.Environment_Variables;
with Interfaces.C_Streams;

package body Terminal_Styles is

   Escape : constant String := Character'Val (27) & "[";
   Reset  : constant String := Escape & "0m";

   Current_Policy : Color_Policy := Color_Auto;

   function Stdout_Is_TTY return Boolean is
      Stdout_File_Descriptor : constant Interfaces.C_Streams.int := 1;
   begin
      return Interfaces.C_Streams.isatty (Stdout_File_Descriptor) = 1;
   exception
      when others =>
         return False;
   end Stdout_Is_TTY;

   procedure Set_Color_Policy (Policy : Color_Policy) is
   begin
      Current_Policy := Policy;
   end Set_Color_Policy;

   function Current_Color_Policy return Color_Policy is
   begin
      return Current_Policy;
   end Current_Color_Policy;

   function Color_Enabled_For
     (Policy       : Color_Policy;
      No_Color_Set : Boolean;
      Terminal_TTY : Boolean) return Boolean
     with SPARK_Mode => On
   is
   begin
      case Policy is
         when Color_Always =>
            return True;
         when Color_Never =>
            return False;
         when Color_Auto =>
            return not No_Color_Set and then Terminal_TTY;
      end case;
   end Color_Enabled_For;

   function Color_Enabled return Boolean is
   begin
      return Color_Enabled_For
        (Current_Policy,
         Ada.Environment_Variables.Exists ("NO_COLOR"),
         Stdout_Is_TTY);
   exception
      when others =>
         return False;
   end Color_Enabled;

   function Color_Enabled (Destination_Is_Terminal : Boolean) return Boolean is
   begin
      return Color_Enabled_For
        (Current_Policy,
         Ada.Environment_Variables.Exists ("NO_COLOR"),
         Destination_Is_Terminal);
   exception
      when others =>
         return False;
   end Color_Enabled;

   function SGR_Code (Item : String; Code : String) return String
     with
       SPARK_Mode => On,
       Pre => Code'Length <= Natural'Last - Escape'Length
         and then Code'Length + Escape'Length <= Natural'Last - 1
         and then Code'Length + Escape'Length + 1 <= Natural'Last - Item'Length
         and then Code'Length + Escape'Length + 1 + Item'Length
           <= Natural'Last - Reset'Length
   is
   begin
      return Escape & Code & "m" & Item & Reset;
   end SGR_Code;

   function With_Code (Item : String; Code : String) return String is
   begin
      if Color_Enabled then
         return SGR_Code (Item, Code);
      else
         return Item;
      end if;
   end With_Code;

   function With_Code
     (Item : String;
      Code : String;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      if Color_Enabled (Destination_Is_Terminal) then
         return SGR_Code (Item, Code);
      else
         return Item;
      end if;
   end With_Code;

   function Code_For (Decoration : Text_Decoration) return String
     with SPARK_Mode => On
   is
   begin
      case Decoration is
         when Decoration_Reset =>
            return "0";
         when Decoration_Bold =>
            return "1";
         when Decoration_Faint =>
            return "2";
         when Decoration_Italic =>
            return "3";
         when Decoration_Underline =>
            return "4";
         when Decoration_Double_Underline =>
            return "21";
         when Decoration_Slow_Blink =>
            return "5";
         when Decoration_Rapid_Blink =>
            return "6";
         when Decoration_Reverse =>
            return "7";
         when Decoration_Conceal =>
            return "8";
         when Decoration_Crossed_Out =>
            return "9";
         when Decoration_Framed =>
            return "51";
         when Decoration_Encircled =>
            return "52";
         when Decoration_Overlined =>
            return "53";
         when Decoration_Not_Bold_Or_Faint =>
            return "22";
         when Decoration_Not_Italic =>
            return "23";
         when Decoration_Not_Underlined =>
            return "24";
         when Decoration_Not_Blinking =>
            return "25";
         when Decoration_Not_Reversed =>
            return "27";
         when Decoration_Reveal =>
            return "28";
         when Decoration_Not_Crossed_Out =>
            return "29";
         when Decoration_Not_Framed_Or_Encircled =>
            return "54";
         when Decoration_Not_Overlined =>
            return "55";
      end case;
   end Code_For;

   function Foreground_Code (Color : Terminal_Color) return String
     with SPARK_Mode => On
   is
   begin
      case Color is
         when Color_Default => return "39";
         when Color_Black => return "30";
         when Color_Red => return "31";
         when Color_Green => return "32";
         when Color_Yellow => return "33";
         when Color_Blue => return "34";
         when Color_Magenta => return "35";
         when Color_Cyan => return "36";
         when Color_White => return "37";
         when Color_Bright_Black => return "90";
         when Color_Bright_Red => return "91";
         when Color_Bright_Green => return "92";
         when Color_Bright_Yellow => return "93";
         when Color_Bright_Blue => return "94";
         when Color_Bright_Magenta => return "95";
         when Color_Bright_Cyan => return "96";
         when Color_Bright_White => return "97";
      end case;
   end Foreground_Code;

   function Background_Code (Color : Terminal_Color) return String
     with SPARK_Mode => On
   is
   begin
      case Color is
         when Color_Default => return "49";
         when Color_Black => return "40";
         when Color_Red => return "41";
         when Color_Green => return "42";
         when Color_Yellow => return "43";
         when Color_Blue => return "44";
         when Color_Magenta => return "45";
         when Color_Cyan => return "46";
         when Color_White => return "47";
         when Color_Bright_Black => return "100";
         when Color_Bright_Red => return "101";
         when Color_Bright_Green => return "102";
         when Color_Bright_Yellow => return "103";
         when Color_Bright_Blue => return "104";
         when Color_Bright_Magenta => return "105";
         when Color_Bright_Cyan => return "106";
         when Color_Bright_White => return "107";
      end case;
   end Background_Code;

   function Code_For (Role : Style_Role) return String
     with SPARK_Mode => On
   is
   begin
      case Role is
         when Role_Info =>
            return "36";
         when Role_Success =>
            return "32;1";
         when Role_Error =>
            return "31;1";
         when Role_Warning =>
            return "33";
         when Role_Muted =>
            return "2";
         when Role_Header =>
            return "35;1";
      end case;
   end Code_For;

   function Decorate
     (Item : String;
      Role : Style_Role) return String
   is
   begin
      return With_Code (Item, Code_For (Role));
   end Decorate;

   function Decorate
     (Item : String;
      Role : Style_Role;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      return With_Code (Item, Code_For (Role), Destination_Is_Terminal);
   end Decorate;

   function Decorate
     (Item       : String;
      Decoration : Text_Decoration) return String
   is
   begin
      return With_Code (Item, Code_For (Decoration));
   end Decorate;

   function Decorate
     (Item       : String;
      Decoration : Text_Decoration;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      return With_Code (Item, Code_For (Decoration), Destination_Is_Terminal);
   end Decorate;

   function Decorate
     (Item       : String;
      Foreground : Terminal_Color;
      Background : Terminal_Color := Color_Default) return String
   is
   begin
      return With_Code (Item, Foreground_Code (Foreground) & ";" & Background_Code (Background));
   end Decorate;

   function Decorate
     (Item       : String;
      Foreground : Terminal_Color;
      Background : Terminal_Color;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      return With_Code
        (Item,
         Foreground_Code (Foreground) & ";" & Background_Code (Background),
         Destination_Is_Terminal);
   end Decorate;

   function Decorate
     (Item       : String;
      Decoration : Text_Decoration;
      Foreground : Terminal_Color;
      Background : Terminal_Color := Color_Default) return String
   is
   begin
      return With_Code
        (Item,
         Code_For (Decoration) & ";"
         & Foreground_Code (Foreground) & ";"
         & Background_Code (Background));
   end Decorate;

   function Decorate
     (Item       : String;
      Decoration : Text_Decoration;
      Foreground : Terminal_Color;
      Background : Terminal_Color;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      return With_Code
        (Item,
         Code_For (Decoration) & ";"
         & Foreground_Code (Foreground) & ";"
         & Background_Code (Background),
         Destination_Is_Terminal);
   end Decorate;

   function Marker (Role : Style_Role) return String
     with SPARK_Mode => On
   is
   begin
      case Role is
         when Role_Info =>
            return "[*]";
         when Role_Success =>
            return "[+]";
         when Role_Error =>
            return "[!]";
         when Role_Warning =>
            return "[-]";
         when Role_Muted =>
            return "[.]";
         when Role_Header =>
            return "[=]";
      end case;
   end Marker;

   function Line
     (Item : String;
      Role : Style_Role) return String
   is
   begin
      return Decorate (Marker (Role), Role) & " " & Decorate (Item, Role);
   end Line;

   function Line
     (Item : String;
      Role : Style_Role;
      Destination_Is_Terminal : Boolean) return String
   is
   begin
      return Decorate (Marker (Role), Role, Destination_Is_Terminal)
        & " " & Decorate (Item, Role, Destination_Is_Terminal);
   end Line;
end Terminal_Styles;
