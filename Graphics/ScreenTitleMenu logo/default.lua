return Def.ActorFrame{
	InitCommand=function(self) self:fov(70):zoom(0.5):x(SCREEN_CENTER_X) end,
	Def.Sprite{
		Texture= THEME:GetPathG("ScreenTitleMenu","logo/_text"),
	},
	InitCommand=function(self) self:fov(70):zoom(0.5):x(SCREEN_CENTER_X) end,
	Def.Sprite{
		Texture= THEME:GetPathG("ScreenTitleMenu","logo/_update"),
	},
}
