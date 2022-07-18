local MascotEnabled = LoadModule("Config.Load.lua")("ShowMascotCharacter","Save/OutFoxPrefs.ini")
return Def.ActorFrame{
	InitCommand=function(self) self:fov(70):zoom(0.5):x(SCREEN_CENTER_X) end,
	Def.Sprite{
		Texture= THEME:GetPathG("ScreenTitleMenu","logo/_text"),
	},
	LoadActor("_mascot") .. {
		InitCommand=function(self) self:x(-250):y(30):zoom(1):diffusealpha(0) end,
		OnCommand=function(self) self:queuecommand("Animate") end,
		AnimateCommand=function(self) 
			if MascotEnabled then
				self:diffusealpha(0):addy(40):decelerate(1):diffusealpha(1):addx(-40)
			end
		end
	}
}
