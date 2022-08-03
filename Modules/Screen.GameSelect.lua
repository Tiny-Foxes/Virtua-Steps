return function()

    local Info = {
        "Dance\nThe game we all know and love.\n\nSingle (4 panels)\nSolo (6 panels)\nThree (3 panels)\nDouble (8 panels)\nSolo Double (12 panels)\nThree Double (6 panels)",
        "Pump\nA familiar game that uses diagonal panels.\n\nSingle (5 panels)\nHalfDouble (6 panels)\nDouble (10 panels)",
        "SMX\nThe hottest new dance game from Step Revolution.\n\nSingle (5 panels)\nDual (6 panels)\nDouble (10 panels)",
        "Techno\nWhat happens when you mix Dance and Pump together.\n\nCross (4 panels)\nDiagonal (5 panels)\nSquare (8 panels)\nSquare+ (9 panels)\nCross Double (8 panels)\nDiagonal Double (10 panels)\nSquare Double (16 panels)\nSquare+ Double (18 panels)",
        "Be-Mu\nPlay all your BMS files here.\n\nSingle 5 (5 buttons, 1 turntable)\nSingle 7 (7 buttons, 1 turntable)\nDouble 10 (10 buttons, 2 turntables)\nDouble 14 (14 buttons, 2 turntables)",
        "Po-Mu\nPlay all your PMS files here.\n\n3 buttons\n4 buttons\n5 buttons\n7 buttons\n9 buttons\n18 buttons",
        "GDDM\nSimulate being a real drummer!\n\n10-piece (8 drums, bass pedal, hi-hat pedal)\n9-piece (7 drums, bass pedal, hi-hat pedal)\n6-piece (5 drums, bass pedal)",
        "GDGF\nPlay the game that inspired GH in the first place.\n\nGuitar 5 (5 frets)\nBass 5 (5 frets, open strum)\nGuitar 6 (6 frets)\nGuitar 3 (3 frets)\nBass 3 (3 frets, open strum)",
        "GH\nThe game that took America by storm in the early 2000s.\n\nSolo, Bass, Rhythm (5 frets)",
        "Taiko\nPlay the simple yet addictive Taiko game.\n\nSingle (drumhead/red, rim/blue)",
        "Para\nAccurately simulates the ParaPara dance style.\n\nSingle (5 sensors)\nDouble (10 sensors)",
        "KBX\nPlay all your favorite keyboard files here.\n\n1 to 19 buttons",
        "EZ2Dancer\nUse panels and your hands to dance up a storm!\n\nSingle (3 panels, 2 sensors)\nReal (3 panels, 2 upper sensors, 2 lower sensors)\nDouble (6 panels, 4 sensors)",
        "3DDX\nThink of it as a spiritual successor to EZ2Dancer.\n\nSingle (4 panels, 4 sensors)\nSingle (5 panels, 4 sensors)\nDual (8 panels, 8 sensors)\nDual (10 panels, 8 sensors)",
        "DanceManiax\nSwipe your hands above and below the sensors\nto some awesome eurobeat songs!\n\nSingle (4 sensors)\nDouble (8 sensors)",
        "StepStage\nUh... what?\n\nTwin (3 panel rows)\nSingle (6 panels)",
        --"lights",
        "KickBox\nEver wanted to get fit using 4 dancepads?\n\nHuman\nQuadarm\nInsect\nArachnid"
    }


    local Choices = {
        "dance",
        "pump",
        "smx",
        "techno",
        "be-mu",
        "po-mu",
        "gddm",
        "gdgf",
        "gh",
        "taiko",
        "para",
        "kbx",
        "ez2",
        "ds3ddx",
        "maniax",
        "stepstage",
        --"lights", -- should change this to another screen option.
        "kickbox"
    }

    local choice = 1
    for i,v in ipairs(Choices) do
        if v == GAMESTATE:GetCurrentGame():GetName() then choice = i end
    end

    local function MoveOption(self,offset)

        choice = choice + offset
        
        if choice < 1 then choice = 1 return end
        if choice > #Choices then choice = #Choices return end

        for i = 1,#Choices do
            self:GetChild("Container"):GetChild("Selection"..i):y(-40+(40*(i-(choice-1))))

            if i == choice then
                self:GetChild("Container"):GetChild("Selection"..i):GetChild("Text"):stoptweening():linear(.08):diffusealpha(1)
                self:GetChild("Container"):GetChild("Selection"..i):GetChild("Bars"):stoptweening():linear(.16):diffusealpha(1):zoomx(1)
            else
                self:GetChild("Container"):GetChild("Selection"..i):GetChild("Text"):stoptweening():linear(.08):diffusealpha(0.3)           
                self:GetChild("Container"):GetChild("Selection"..i):GetChild("Bars"):stoptweening():linear(.16):diffusealpha(0):zoomx(0)
            end
            self:GetChild("Previews"):GetChild("Preview_"..Choices[i]):visible(0)
        end

        self:GetChild("Info"):settext(Info[choice])
        self:GetChild("Previews"):GetChild("Preview_"..Choices[choice]):visible(1)

        self:GetChild("Change"):set_is_action(true)
        self:GetChild("Change"):play()
    end

    local Container = Def.ActorFrame{Name="Container"}
    local Previews = Def.ActorFrame{Name="Previews"}

    for i,v in ipairs(Choices) do
        Container[#Container+1] = Def.ActorFrame{
            Name="Selection"..i,
            OnCommand=function(self)
                self:xy(-220,-40+(40*(i-(choice-1))))
            end,
            Def.Quad {
                OnCommand=function(self) self:zoomto(260,36):diffuse(color("#003132")):diffusealpha(0.75) end
            },
            Def.BitmapText{
                Name="Text",
                Text=v,
                Font="_open sans semibold",
                OnCommand=function(self)
                    self:maxwidth(320):skewx(-0.15):zoom(0.5):strokecolor(Color.Black)
                    if choice == i then
                        self:diffusealpha(1)
                    else
                        self:diffusealpha(0.3)
                    end
                end
            },
            Def.ActorFrame {
                Name="Bars",
                OnCommand=function(self)
                    self:diffusealpha(0):zoomx(0)
                    if i == choice then
                        self:diffusealpha(1):zoomx(1)
                    end
                end,
                Def.Quad {
                    OnCommand=function(self) 
                        self:zoomto(260,4):vertalign(top):y(-36/2) 
                    end
                },	
                Def.Quad {
                    OnCommand=function(self) 
                        self:zoomto(260,4):vertalign(bottom):y(36/2) 
                    end
                }
            }
        }

        Previews[#Previews+1] = Def.Sprite{
            Name="Preview_"..v,
            Texture=THEME:GetPathG("ScreenSelectGame","Types/"..v),
            OnCommand=function(self)
                self:zoom(.3):texcoordvelocity(.1,0):xy(160,120):visible(0):SetTextureFiltering(false)
                if i == choice then
                    self:visible(1)
                end
            end
        }
    end

    return Def.ActorFrame{
        OnCommand=function(self)
            self:Center()
            SCREENMAN:GetTopScreen():AddInputCallback(LoadModule("Lua.InputSystem.lua")(self))
        end,

        MenuUpCommand=function(self) MoveOption(self,-1) end,

        MenuDownCommand=function(self) MoveOption(self,1) end,

        MenuLeftCommand=function(self) MoveOption(self,-1) end,

        MenuRightCommand=function(self) MoveOption(self,1) end,

        BackCommand=function(self) 
            if GAMESTATE:GetCurrentGame():GetName() ~= "SelectGameMode" then
                SOUND:PlayOnce(THEME:GetPathS("Common","Cancel"), true)
                SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen")
            end
        end,

        StartCommand=function(self)
            SOUND:PlayOnce(THEME:GetPathS("Common","start"), true)
            GAMEMAN:SetGame(Choices[choice])
        end,

        Def.Sound{
            Name="Change",
            File=THEME:GetPathS("ScreenOptions","change")
        },

        Def.Quad{
            OnCommand=function(self)
                self:zoomto(1024,512):x(-512):MaskSource()
            end
        },
        Def.Quad{
            OnCommand=function(self)
                self:zoomto(1024,512):x(512+320):MaskSource()
            end
        },
        Previews..{
            OnCommand=function(self)
                self:MaskDest()
            end
        },
        Def.BitmapText{
            Name="Info",
            Text=Info[choice],
            Font="_open sans semibold",
            OnCommand=function(self)
                self:y(-175):halign(0):valign(0):zoom(0.3):strokecolor(Color.Black):strokelength(1)
            end
        },
        Container
    }
end
