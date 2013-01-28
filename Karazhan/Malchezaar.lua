--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Prince Malchezaar", 799)
if not mod then return end
mod:RegisterEnableMob(15690)

local nova = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.wipe_bar = "Respawn"

	L.phase = "Engage"
	L.phase_desc = "Alert when changing phases."
	L.phase1_trigger = "Madness has brought you here to me. I shall be your undoing!"
	L.phase2_trigger = "Simple fools! Time is the fire in which you'll burn!"
	L.phase3_trigger = "How can you hope to stand against such overwhelming power?"
	L.phase1_message = "Phase 1 - Infernal in ~40sec!"
	L.phase2_message = "60% - Phase 2"
	L.phase3_message = "30% - Phase 3 "

	L.infernal = "Infernals"
	L.infernal_desc = "Show cooldown timer for Infernal summons."
	L.infernal_icon = "INV_Stone_05"
	L.infernal_bar = "Incoming Infernal"
	L.infernal_warning = "Infernal incoming in 17sec!"
	L.infernal_message = "Infernal Landed! Hellfire in 5sec!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"phase", 30843, 30852, "infernal", "bosskill"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Enfeeble", 30843)
	self:Log("SPELL_AURA_APPLIED", "SelfEnfeeble", 30843)
	self:Log("SPELL_CAST_START", "Nova", 30852)
	self:Log("SPELL_CAST_SUCCESS", "Infernal", 30834)

	self:Yell("Phase2", L["phase2_trigger"])
	self:Yell("Phase3", L["phase3_trigger"])

	self:Yell("Engage", L["phase1_trigger"])
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:Death("Win", 15690)
end

function mod:OnEngage()
	nova = nil
	self:Message("phase", L["phase1_message"], "Positive", "achievement_boss_princemalchezaar_02")

	local enfeeble = GetSpellInfo(30843)
	self:DelayedMessage(30843, 25, CL["custom_sec"]:format(enfeeble, 5), "Attention")
	self:Bar(30843, enfeeble, 30, 30843)
end

function mod:OnWipe()
	self:Bar("phase", L["wipe_bar"], 60, "achievement_boss_princemalchezaar_02")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Enfeeble(player, spellId, _, _, spellName)
	self:Message(spellId, spellName, "Important", spellId)
	self:DelayedMessage(spellId, 25, CL["custom_sec"]:format(spellName, 5), "Urgent")
	self:Bar(spellId, spellName, 30, spellId)
	self:Bar(30852, GetSpellInfo(30852), 5, 30852)
end

function mod:SelfEnfeeble(player, spellId, _, _, spellName)
	if UnitIsUnit(player, "player") then
		self:LocalMessage(spellId, CL["you"]:format(spellName), "Personal", spellId, "Alarm")
		self:Bar(spellId, CL["you"]:format(spellName), 7, spellId)
	end
end

function mod:Nova(_, spellId, _, _, spellName)
	self:Message(spellId, spellName, "Important", spellId, "Info")
	self:Bar(spellId, "<"..spellName..">", 2, spellId)
	if nova then
		self:Bar(spellId, spellName, 20, spellId)
		self:DelayedMessage(spellId, 15, CL["soon"]:format(spellName), "Attention")
	end
end

function mod:Infernal()
	self:Message("infernal", L["infernal_warning"], "Important", L["infernal_icon"])
	self:DelayedMessage("infernal", 12, L["infernal_message"], "Urgent", nil, "Alert")
	self:Bar("infernal", L["infernal_bar"], 17, L["infernal_icon"])
end

function mod:Phase2()
	self:Message("phase", L["phase2_message"], "Positive", "achievement_boss_princemalchezaar_02")
end

function mod:Phase3()
	self:Message("phase", L["phase3_message"], "Positive", "achievement_boss_princemalchezaar_02")
	local enfeeble = GetSpellInfo(30843)
	self:CancelDelayedMessage(CL["custom_sec"]:format(enfeeble, 5))
	self:SendMessage("BigWigs_StopBar", self, enfeeble)
	nova = true
end

