--  terminal text decoration helpers.
--
--  This package formats strings with ANSI SGR escape sequences and stable
--  ASCII status markers for command-line output. Color emission is controlled
--  by a process-wide color policy.
package Terminal_Styles is
   --  Semantic roles for status-style terminal output.
   type Style_Role is
     (Role_Info,
      Role_Success,
      Role_Error,
      Role_Warning,
      Role_Muted,
      Role_Header);

   --  ANSI text decorations supported by Decorate.
   type Text_Decoration is
     (Decoration_Reset,
      Decoration_Bold,
      Decoration_Faint,
      Decoration_Italic,
      Decoration_Underline,
      Decoration_Double_Underline,
      Decoration_Slow_Blink,
      Decoration_Rapid_Blink,
      Decoration_Reverse,
      Decoration_Conceal,
      Decoration_Crossed_Out,
      Decoration_Framed,
      Decoration_Encircled,
      Decoration_Overlined,
      Decoration_Not_Bold_Or_Faint,
      Decoration_Not_Italic,
      Decoration_Not_Underlined,
      Decoration_Not_Blinking,
      Decoration_Not_Reversed,
      Decoration_Reveal,
      Decoration_Not_Crossed_Out,
      Decoration_Not_Framed_Or_Encircled,
      Decoration_Not_Overlined);

   --  ANSI foreground and background colors supported by Decorate.
   type Terminal_Color is
     (Color_Default,
      Color_Black,
      Color_Red,
      Color_Green,
      Color_Yellow,
      Color_Blue,
      Color_Magenta,
      Color_Cyan,
      Color_White,
      Color_Bright_Black,
      Color_Bright_Red,
      Color_Bright_Green,
      Color_Bright_Yellow,
      Color_Bright_Blue,
      Color_Bright_Magenta,
      Color_Bright_Cyan,
      Color_Bright_White);

   --  Process-wide ANSI color emission policy.
   type Color_Policy is
     (Color_Auto,
      Color_Always,
      Color_Never);

   --  Set the process-wide ANSI color policy.
   --
   --  Color_Auto emits ANSI styling only when NO_COLOR is not set and stdout
   --  is a terminal. Color_Always ignores NO_COLOR and terminal detection.
   --  Color_Never always suppresses ANSI styling.
   --
   --  @param Policy Color policy to use for subsequent formatting calls.
   procedure Set_Color_Policy (Policy : Color_Policy);

   --  Return the current process-wide ANSI color policy.
   --
   --  @return Active color policy.
   function Current_Color_Policy return Color_Policy;

   --  Return whether ANSI color output is enabled by the current policy.
   --
   --  @return True when ANSI color output should be emitted.
   function Color_Enabled return Boolean;

   --  Return Item decorated for the requested terminal role.
   --
   --  @param Item Text to decorate.
   --  @param Role Semantic role used to choose terminal styling.
   --  @return Item with ANSI styling when color is enabled; otherwise Item.
   function Decorate
     (Item : String;
      Role : Style_Role) return String;

   --  Return Item decorated with the requested ANSI text decoration.
   --
   --  @param Item Text to decorate.
   --  @param Decoration ANSI text decoration to apply.
   --  @return Item with ANSI styling when color is enabled; otherwise Item.
   function Decorate
     (Item       : String;
      Decoration : Text_Decoration) return String;

   --  Return Item decorated with ANSI foreground and background colors.
   --
   --  @param Item Text to decorate.
   --  @param Foreground ANSI foreground color to apply.
   --  @param Background ANSI background color to apply.
   --  @return Item with ANSI styling when color is enabled; otherwise Item.
   function Decorate
     (Item       : String;
      Foreground : Terminal_Color;
      Background : Terminal_Color := Color_Default) return String;

   --  Return Item decorated with ANSI text decoration and colors.
   --
   --  @param Item Text to decorate.
   --  @param Decoration ANSI text decoration to apply.
   --  @param Foreground ANSI foreground color to apply.
   --  @param Background ANSI background color to apply.
   --  @return Item with ANSI styling when color is enabled; otherwise Item.
   function Decorate
     (Item       : String;
      Decoration : Text_Decoration;
      Foreground : Terminal_Color;
      Background : Terminal_Color := Color_Default) return String;

   --  Return an ASCII status marker for Role.
   --
   --  @param Role Semantic role used to choose the marker.
   --  @return Short ASCII status marker.
   function Marker (Role : Style_Role) return String
     with SPARK_Mode => On;

   --  Return a marked and decorated terminal line.
   --
   --  @param Item Text to decorate.
   --  @param Role Semantic role used to choose marker and terminal styling.
   --  @return Marked terminal line with optional ANSI styling.
   function Line
     (Item : String;
      Role : Style_Role) return String;
end Terminal_Styles;
