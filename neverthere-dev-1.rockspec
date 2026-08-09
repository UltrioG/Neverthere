package = "Neverthere"
version = "dev-1"
source = {
   url = "git+https://github.com/UltrioG/Neverthere"
}
description = {
   homepage = "https://github.com/UltrioG/Neverthere",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["Library.Globals"] = "Library/Globals.lua",
      ["Library.GuiManager"] = "Library/GuiManager.lua",
      ["Library.Pretty"] = "Library/Pretty.lua",
      ["Library.Prototypes.Gui.Decal"] = "Library/Prototypes/Gui/Decal.lua",
      ["Library.Prototypes.Gui.GUI2D"] = "Library/Prototypes/Gui/GUI2D.lua",
      ["Library.Prototypes.Gui.Rectangle"] = "Library/Prototypes/Gui/Rectangle.lua",
      ["Library.Prototypes.Gui.TextLabel"] = "Library/Prototypes/Gui/TextLabel.lua",
      ["Library.Prototypes.Hierach"] = "Library/Prototypes/Hierach.lua",
      ["Library.Prototypes.Poject"] = "Library/Prototypes/Poject.lua",
      ["Library.Typedef"] = "Library/Typedef.lua",
      ["Library.smpl"] = "Library/smpl.lua",
      basic = "basic.lua",
      conf = "conf.lua",
      main = "main.lua"
   }
}
