-- オプション
-- Off/On選択のオプションは多々あるので共通化
local onOffList = {THEME:GetString('OptionNames','Off'), THEME:GetString('OptionNames','On')}

-- よくある選択肢
local function OptionTemplate(name, choiceList, ...)
	local configName = ...
	configName = configName or name
	return {
		Name = name,
		LayoutType = 'ShowAllInRow',
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = choiceList,
		LoadSelections = function(self, list, pn)
			local configValue = W_PLAYER:ReadPref(pn, configName)
			if configValue ~= nil then
				local val = 1
				for k,v in pairs(choiceList) do
					if v == configValue then
						val = k
						break
					end
				end
				list[val] = true
			else
				W_PLAYER:SavePref(pn, configName, 0)
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
            for i=1, #list do
                if list[i] then
					value = choiceList[i]
					W_PLAYER:SavePref(pn, configName, value)
					break
				end
			end
		end,
	}
end

-- 難易度一覧を作成
-- return 難易度名の一覧, Stepsの一覧
local function GetDifficultyList()
    local song = GAMESTATE:GetCurrentSong()
    local difList = {}
    local stepList = {}
    local steps = song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())
    for k,dif in pairs({'Difficulty_Beginner', 'Difficulty_Easy', 'Difficulty_Medium', 'Difficulty_Hard', 'Difficulty_Challenge'}) do
        for k,step in pairs(steps) do
            if step:GetDifficulty() == dif then
                difList[#difList+1] = W_DIF:Name(dif)..' '..step:GetMeter()
                stepList[#stepList+1] = step
                break
            end
        end
    end
    for k,step in pairs(steps) do
        if step:GetDifficulty() == 'Difficulty_Edit' then
            difList[#difList+1] = string.upper(W_DIF:Name('Difficulty_Edit', step))..' '..step:GetMeter()
            stepList[#stepList+1] = step
        end
    end
    return difList, stepList
end

-- 難易度
local function OptionRowDifficulty(self, ...)
	return {
		Name = 'WAIEIDifficulty',
		LayoutType = (#GetDifficultyList() <=5) and 'ShowAllInRow' or 'ShowOneInRow',
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = GetDifficultyList(),
		LoadSelections = function(self, list, pn)
            local difList, stepList = GetDifficultyList()
            local step = GAMESTATE:GetCurrentSteps(pn)
            local difName = string.upper(W_DIF:Name(step:GetDifficulty(), step))..' '..step:GetMeter()
            local hash = step:GetHash()
            for i=1, #difList do
                if (not W:Is53() and hash ~= 0 and hash == stepList[i]:GetHash()) or difName == difList[i] then
                    list[i] = true
                    break
                end
            end
		end,
		SaveSelections = function(self, list, pn)
            local difList, stepList = GetDifficultyList()
            for i=1, #list do
                if list[i] then
                    GAMESTATE:SetCurrentSteps(pn, stepList[i]);
                end
            end
		end,
	}
end

-- パーセントスコア（デフォルト：On）
local function OptionHighScoreType(displayList)
	return {
		Name = 'HighScoreType',
		LayoutType = 'ShowAllInRow',
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = displayList,
		LoadSelections = function(self, list)
			if not PREFSMAN:GetPreference('PercentageScoring') or tobool(PREFSMAN:GetPreference('PercentageScoring')) then
                list[2] = true
				W_OPTION:SavePref('HighScoreType', true)
			else
				list[1] = true
				W_OPTION:SavePref('HighScoreType', false)
			end
		end,
		SaveSelections = function(self, list)
			if list[1] then
				PREFSMAN:SetPreference('PercentageScoring', false)
				W_OPTION:SavePref('HighScoreType', false)
			else
				PREFSMAN:SetPreference('PercentageScoring', true)
				W_OPTION:SavePref('HighScoreType', true)
			end;
		end
	}
end

local function OptionRowGlobalSelectOne(name, selList, layout)
	return {
		Name = name,
		LayoutType = layout,
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = selList.Display,
		LoadSelections = function(self, list)
			local value = W_OPTION:ReadPref(name)
			if value ~= nil then
				local val = 1
				for k,v in pairs(selList.List) do
					if v == value then
						val = k
						break
					end
				end
				list[val] = true
			else
				local i = selList.Default or 1
				W_OPTION:SavePref(name, selList.List[i])
				list[i] = true
			end
		end,
		SaveSelections = function(self, list)
			local value
			for i=1, #list do
				if list[i] then
					value = selList.List[i]
					W_OPTION:SavePref(name, value)
					break
				end
			end
			if value then
				if name == 'DifficultyColor' then
					W_DIF:ColorType(value)
				end
				if name == 'DifficultyLabel' then
					W_DIF:NameType(value)
				end
			end
			THEME:ReloadMetrics()
		end,
	}
end

local option
local function LoadOption()
	option = dofile(THEME:GetPathO('', 'Options.lua'))
	return option
end
-- 共通かつ1つのみ選択できるオプション
local function ExtraOption(self, _name)
	local params = split('-', _name)
	local name = params[1]
	local layout = params[2] or 'ShowAllInRow'
	option = option or LoadOption()
	local selList = option.OptionList[name]
	-- コンボ継続最低判定のラベルは設定次第で変わるので読みこみなおす
	if name == 'ContinueCombo' then
		W_JUDGMENT:Set(W_OPTION:ReadPref('JudgmentMode'))
		selList.Display = {
			string.upper(W_JUDGMENT:Name('TapNoteScore_W1')),
			string.upper(W_JUDGMENT:Name('TapNoteScore_W2')),
			string.upper(W_JUDGMENT:Name('TapNoteScore_W3')),
			string.upper(W_JUDGMENT:Name('TapNoteScore_W4')),
		}
	end
	if name == 'HighScoreType' then
		return OptionHighScoreType(selList.Display)
	else
		return OptionRowGlobalSelectOne(name, selList, layout)
	end
end

-- screen filter
local screenFilterList = {onOffList[1], '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'}
local function OptionRowScreenFilter()
	return OptionTemplate('ScreenFilter', screenFilterList)
end

-- note graph
local function OptionRowNoteGraph()
	return OptionTemplate('NoteGraph', onOffList)
end

-- Speed Assist
local function OptionRowSpeedAssist()
	return OptionTemplate('SpeedAssist', onOffList)
end

-- Target
local function OptionRowEnableTarget()
	return OptionTemplate('Target', onOffList, 'EnableTarget')
end

-- Fast And Slow
local function OptionRowFastAndSlow()
	return OptionTemplate('FastAndSlow', onOffList, 'ShowFastAndSlow')
end

-- Mini
local miniList = {
	THEME:GetString('OptionNames', 'Mini100'),
	THEME:GetString('OptionNames', 'Mini80'),
	THEME:GetString('OptionNames', 'Mini60'),
	THEME:GetString('OptionNames', 'Mini40'),
	THEME:GetString('OptionNames', 'Mini20'),
	THEME:GetString('OptionNames', 'Default'),
	THEME:GetString('OptionNames', 'Mini-20'),
	THEME:GetString('OptionNames', 'Mini-40'),
	THEME:GetString('OptionNames', 'Mini-60'),
	THEME:GetString('OptionNames', 'Mini-80'),
	THEME:GetString('OptionNames', 'Mini-100'),
}
local function OptionRowMini()
	return OptionTemplate('Mini', miniList, 'ReceptorScale')
end

-- ステージ
local function OptionRowStage()
	local stageList = {onOffList[1], 'Random'}
	local stageDisplay = {onOffList[1], 'Random'}
	for _,v in pairs(W_DANCER:StageList()) do
		stageList[#stageList+1] = v.Name
		stageDisplay[#stageDisplay+1] = v.Name
	end
	return OptionRowGlobalSelectOne('Stage', {Default = 1, List = stageList, Display = stageDisplay}, 'ShowAllInRow')
end

-- OutFox用SoundEffect
local function OptionRowSoundEffect(self)
	local valueList = {}
	local nameList = {}
	for k,v in pairs(SoundEffectType) do
		valueList[k] = v
		nameList[k] = ToEnumShortString(v)
	end
	return {
		Name = 'SoundEffect',
		LayoutType = 'ShowAllInRow',
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = nameList,
		LoadSelections = function(self, list)
			local value = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):SoundEffectSetting()
			local index = 1
			if value ~= nil then
				for k,v in pairs(valueList) do
					if v == value then
						index = k
						break
					end
				end
			end
			list[index] = true
		end,
		SaveSelections = function(self, list)
			local value
			for i=1, #list do
				if list[i] then
					value = valueList[i]
					if value == 'SoundEffectType_Off' then
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):SoundEffectSetting('SoundEffectType_Off')
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):PitchRate(1.0)
					else
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):SoundEffectSetting(value)
						local currentRate = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):PitchRate(currentRate)
					end
					-- Hasteの場合は初期値が1.0
					if GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):Haste() ~= 0.0 then
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):PitchRate(1.0)
					end
					break
				end
			end
		end,
	}
end

-- 追加オプション一覧
local function GetOptionList(self, optType)
	option = option or LoadOption()
	if optType == 'GlobalOne' then
		local optList = {}
		for k,v in pairs(option.Menu) do
			if option.OptionList[v].Type == 'Machine' then
				optList[#optList+1] = v
			end
		end
		return join(',', optList)
	end
	return ''
end

local function GetPlayerOptionsList(self)
	if GAMESTATE:IsCourseMode() then
		if GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
			return 'Mini,8,16,FastAndSlow,Target,NoteGraph,17,Stage'
		end
		return '1,Mini,2,3A,3B,4,5,6,R1,R2,7,8,9,12,13,14,SF,16,FastAndSlow,Target,NoteGraph,SpeedAssist,17,Stage'
	else
		return '1,Mini,2,3A,3B,4,5,6,R1,R2,7,8,9,12,13,14,SF,FastAndSlow,Target,NoteGraph,SpeedAssist,Dif,17,Stage'
	end
end

-- SongOptions
local function GetSongOptionsList(self)
--[[
	Line1="list,LifeType"
	Line2="list,BarDrain"
	Line3="list,BatLives"
	Line4="list,Fail"
	Line5="list,Assist"
	Line6="list,Rate"
	Line7="list,SoundEffect"
	Line8="list,AutoAdjust"
	Line9="list,Background"
	Line10="list,SaveScores"
	Line11="list,SaveReplays"
--]]
	return W:Is53() and '1,2,3,4,5,6,SoundEffect,8,9,10' or '1,2,3,4,5,6,7,8,9,10'
end

local stringCache = {}
local function GetOptionName(self, key)
	if not stringCache[key] then
		stringCache[key] = THEME:GetString('OptionNames', key)
	end
	return stringCache[key]
end

-- グローバル設定の保存
local function SavePref(self, key, value)
	W_PLAYER:SavePref(nil, key, value)
end

-- グローバル設定の読み込み
local function ReadPref(self, key, ...)
	local def = ...
	local ret = W_PLAYER:ReadPref(nil, key)
	if ret == nil and def ~= nil then
		return def
	end
	return ret
end

return {
    Name          = GetOptionName,
    Mini          = OptionRowMini,
    Difficulty    = OptionRowDifficulty,
    ScreenFilter  = OptionRowScreenFilter,
    NoteGraph     = OptionRowNoteGraph,
    SpeedAssist   = OptionRowSpeedAssist,
    FastAndSlow   = OptionRowFastAndSlow,
    EnableTarget  = OptionRowEnableTarget,
    SoundEffect   = OptionRowSoundEffect,
    Stage         = OptionRowStage,
    OptionList    = GetOptionList,
	PlayerOptions = GetPlayerOptionsList,
	SongOptions   = GetSongOptionsList,
    ExtraOption   = ExtraOption,
    SavePref      = SavePref,
    ReadPref      = ReadPref,
}

--[[
Option.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://opensource.org/licenses/mit-license.php
--]]
