with Ada.Text_IO;
with Terminal_Styles;

procedure Terminal_Styles_Basic_Example is
begin
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("starting", Terminal_Styles.Role_Info));
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("ready", Terminal_Styles.Role_Success));
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("check configuration", Terminal_Styles.Role_Warning));
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("failed", Terminal_Styles.Role_Error));
   Ada.Text_IO.Put_Line
     (Terminal_Styles.Decorate
        ("bold yellow text",
         Terminal_Styles.Decoration_Bold,
         Terminal_Styles.Color_Yellow));

   Terminal_Styles.Set_Color_Policy (Terminal_Styles.Color_Never);
   Ada.Text_IO.Put_Line (Terminal_Styles.Line ("plain fallback", Terminal_Styles.Role_Muted));
end Terminal_Styles_Basic_Example;
