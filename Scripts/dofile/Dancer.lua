-- ダンスキャラクター・ステージ

-- ステージ一覧を取得
-- return Stage情報のテーブル
local function GetStageList(self)
    local function GetStage(targetPath)
        local returnList = {}
        local fileList = FILEMAN:GetDirListing(targetPath, true, false)
        for _,name in pairs(fileList) do
            local folder = string.format('%s%s/', targetPath, name)
            -- LoaderXを読み込む
            local file
            for _,v in pairs({'LoaderA', 'LoaderB'}) do	-- 先に記載した方が優先される
                if FILEMAN:DoesFileExist(folder..v..'.lua') then
                    file = folder..v
                    break
                end
            end
            local hasStage = false
            -- LoaderXが存在する場合はencisoシステム
            if not hasStage and file then
                returnList[#returnList+1] = {Name = name, Type = 'enciso', File = file}
                hasStage = true
            end
            -- model.txtがあればOutFoxシステム
            if not hasStage and FILEMAN:DoesFileExist(folder..'model.txt') then
                returnList[#returnList+1] = {Name = name, Type = 'outfox', File = folder}
                hasStage = true
            end
        end
        return returnList
    end
    local function HaveNotKeyInTable(tab, name)
        for _,v in pairs(tab) do
            if v.Name == name then
                return false
            end
        end
        return true
    end
    -- まずここにあるステージは全部取得
    local stageList = GetStage('/Appearance/DanceStages/')
    -- ここにあるステージでリストと同名のステージは無視する
    for k,v in pairs(GetStage('/DanceStages/')) do
        if HaveNotKeyInTable(stageList, v.Name) then
            stageList[#stageList+1] = v
        end
    end
    table.sort(stageList, function(a, b) return a.Name < b.Name end)
    return stageList
end

-- 指定した名前からステージ情報を取得
-- Offや存在しない場合はnil
local function NameToSgate(self, _name)
    --local name = GAMESTATE:IsDemonstration() and ((_name ~= 'Off') and 'Random' or 'Off') or _name
    local name = _name
    if name and name ~= 'Off' then
        local stageList = GetStageList(self)
        if name == 'Random' then
            return (#stageList > 0) and stageList[math.random(#stageList)] or nil
        end
        for _,v in pairs(stageList) do
            if v.Name == name then
                return v
            end
        end
    end
    return nil
end

-- ステージのActor
-- p1: Stage情報
-- return Actor
local function ActorStage(self, ...)
    local stage = ...
    if stage then
        if stage == 'Random' then
            local stageList = W_DANCER:StageList()
            stage = stageList[math.random(#stageList)]
        end
        if stage.Type == 'outfox' or stage.Type == 'enciso' then
            return LoadActor(THEME:GetPathG('', 'ScreenGamePlay/dancer/stage/'..stage.Type), stage.File)
        end
    end
    return Def.Actor({})
end

-- キャラクターのActor
-- p1: Dancer情報
-- return Actor
local function ActorCharacter(self, dancer)
    local width = 30 + math.max(#dancer-2, 0)*10 -- 最低30、人数が3人以上の時はもうちょっと横幅を増やす
    local actors = Def.ActorFrame({})
    local charaBpm = {}
    local timing = {}
    for i=1, #dancer do
        actors[#actors+1] = LoadActor(THEME:GetPathG('', 'ScreenGamePlay/dancer/character/'..dancer[i].Type), dancer[i].Chara)..{
            InitCommand = function(self)
                charaBpm[i] = -1
                self:x((#dancer > 1) and (width/2 - (width*(i-1)/(#dancer-1))) or 0)
            end,
            -- カメラ操作
            ChangedGameplaySongMessageCommand = function(self, params)
                timing[i] = params.Timing[dancer[i].Id] or nil
            end,
            -- 速度変更
            ScreenUpdateMessageCommand = function(self, params)
                local idIsPlayer = (dancer[i].Id == PLAYER_1 or dancer[i].Id == PLAYER_2)
                local bpm = (timing[i] and idIsPlayer)
                    and timing[i]:GetBPMAtBeat(params.PnBeat[dancer[i].Id])
                    or GAMESTATE:GetSongBPS()*60
                if (idIsPlayer and params.PnStop[dancer[i].Id]) or (not idIsPlayer and params.Stop) then
                    bpm = 0
                end
                if charaBpm[i] ~= bpm then
                    self:playcommand('ChangedBpm', {Bpm = bpm})
                    charaBpm[i] = bpm
                end
            end,
        }
    end
    return actors
end

-- キャラクターの種別を取得
-- p1: Character
-- return classic / enciso
local function GetCharacterType(self, character)
    if character then
        -- 3Dキャラかどうか(何故かencisoのNoneは落ちるので表示しないようにする)
        if character:GetModelPath() ~= '' and character:GetDisplayName() ~= 'None' and character:GetDisplayName() ~= 'default' then
            local charaType = 'classic'
            local f = RageFileUtil.CreateRageFile()
            f:Open(character:GetModelPath(), 1)
            -- enciso判定
            while(not f:AtEOF()) do
                if f:GetLine() == '"12.joint_HipMaster"' then
                    charaType = 'enciso'
                    break
                end
            end
            f:Close()
            f:destroy()
            return charaType
        end
    end
    return nil
end

return {
    Stage     = ActorStage,
    GetStage  = NameToSgate,
    StageList = GetStageList,
    Character = ActorCharacter,
    CharaType = GetCharacterType,
}

--[[
Dancer.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://opensource.org/licenses/mit-license.php
--]]
