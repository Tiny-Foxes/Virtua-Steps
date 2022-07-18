local stageList = {
	Stage_Final    = 'FINAL STAGE',
	Stage_Extra1   = 'EXTRA STAGE',
	Stage_Extra2   = 'SPECIAL STAGE',
	Stage_Demo     = 'DEMONSTRATION',
	Stage_Nonstop  = 'NONSTOP',
	Stage_Oni      = 'CHALLENGE',
	Stage_Endless  = 'ENDLESS',
	Stage_Survival = 'SURVIVAL',
}
local eventToStage = {
	'Stage_1st',
	'Stage_2nd',
	'Stage_3rd',
	'Stage_4th',
	'Stage_5th',
}
local courseToStage = {
	CourseType_Nonstop  = 'Stage_Nonstop',
	CourseType_Oni      = 'Stage_Oni',
	CourseType_Endless  = 'Stage_Endless',
	CourseType_Survival = 'Stage_Survival',
}

-- ステージとステージ数を返す
local function GetCurrentStage(self, ...)
	local isEvaluation = ...
	if GAMESTATE:IsDemonstration() then
		return 'Stage_Demo', 1
	end
	-- コースモード
	if GAMESTATE:IsCourseMode() then
		local course = GAMESTATE:GetCurrentCourse()
		local stageNumber = isEvaluation and 1 or GAMESTATE:GetCourseSongIndex()+1
		if not isEvaluation and stageNumber == math.floor(TrailUtil.GetNumSongs(GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber()))) then
			return 'Stage_Final', math.max(stageNumber, 1)
		end
		return courseToStage[course:GetCourseType()], math.max(stageNumber, 1)
	end
	--local curStage = stage and stage:GetStage() or nil
	-- Evaluationとそれ以外で挙動が変わる？
	local curStage = isEvaluation and STATSMAN:GetCurStageStats():GetStage() or GAMESTATE:GetCurrentStage()
	local stageNumber = STATSMAN:GetStagesPlayed() + (isEvaluation and 0 or 1)
	-- イベントモード
	if not curStage or curStage == 'Stage_Event' then
		curStage = eventToStage[stageNumber] or nil
	end
	return curStage, stageNumber
end

-- ステージをテキストで取得
local function GetStageString(self, ...)
	local isEvaluation = ...
	local curStage, stageNumber = GetCurrentStage(self, isEvaluation)
	-- 固定的ストなしまたはコースモード（リザルトを除く）
	if not stageList[curStage] or (GAMESTATE:IsCourseMode() and not isEvaluation and curStage ~= 'Stage_Final') then
		return'STAGE '..stageNumber
	end
	return stageList[curStage]
end

-- StageStatsからステージ名を取得
local function GetStageBySS(self, ss)
	return stageList[ss:GetStage()] or ('STAGE '..(ss:GetStageIndex() + 1))
end

-- stageListの配列の文字を返す
local function ConvertStage(self, key)
	return courseToStage[key]
			and stageList[courseToStage[key]]
			or ToEnumShortString(string.upper(key))
end

-- 選択可能なスタイル
local function GetStyleList(self)
    local stList = {}
	local enabledNum = GAMESTATE:GetNumPlayersEnabled()
    local side = string.find(GAMESTATE:GetCurrentStyle():GetStyleType(), 'OnePlayer') and 'OnePlayer' or 'TwoPlayers'
    for k,v in pairs(GAMEMAN:GetStylesForGame(GAMESTATE:GetCurrentGame():GetName())) do
		if not (enabledNum == 1 and string.find(v:GetStepsType(), 'Couple')) then
			if string.find(v:GetStyleType(), side) then
				stList[#stList+1] = v
			end
		end
    end
	return stList
end

return {
	Current   = GetCurrentStage,
	String    = GetStageString,
	BySS      = GetStageBySS,
	Convert   = ConvertStage,
	StyleList = GetStyleList,
}

--[[
Stage.lua

Copyright (c) 2021 A.C

This software is released under the MIT License.
https://opensource.org/licenses/mit-license.php
--]]
