
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rixxa Fluxflame", 1594, 2115)
if not mod then return end
mod:RegisterEnableMob(129231)
mod.engageId = 2107

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		270042, -- Agent Azerite
		259853, -- Chemical Burn
		{260669, "SAY", "FLASH"}, -- Propellant Blast
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "AgentAzerite", 270042)
	self:Log("SPELL_CAST_SUCCESS", "ChemicalBurnSuccess", 259856)
	self:Log("SPELL_AURA_APPLIED", "ChemicalBurnApplied", 259853)
	self:Log("SPELL_CAST_START", "PropellantBlast", 260669)
end

function mod:OnEngage()
	self:Bar(270042, 8) -- Agent Azerite
	self:Bar(260669, 31) -- Propellant Blast
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:AgentAzerite(args)
	self:Message2(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "long", "watchstep")
	self:CDBar(args.spellId, 8)
end

do
	local prev = 0
	local count = 0
	function mod:ChemicalBurnSuccess(args)
		local t = args.time
		if t-prev > 2 then -- Ignore second cast
			prev = t
			count = count + 1
			-- Cooldown alternates between 15 and 27, starting with 15
			self:Bar(259853, count % 2 == 1 and 15 or 27)
		end
	end
end

do
	local playerList = mod:NewTargetList()
	function mod:ChemicalBurnApplied(args)
		playerList[#playerList+1] = args.destName
		if self:Me(args.destGUID) or self:Dispeller("magic") then
			self:PlaySound(args.spellId, "alarm", self:Dispeller("magic") and "dispel")
		end
		self:TargetsMessage(args.spellId, "orange", playerList)
	end
end

do
	local prev = 0
	local function printTarget(self, player, guid)
		if self:Me(guid) then
			self:Say(260669)
			self:Flash(260669)
		end
		self:TargetMessage2(260669, "yellow", player)
	end
	
	function mod:PropellantBlast(args)
		local t = args.time
		if t-prev > 10 then
			prev = t
			self:CastBar(args.spellId, 6)
			self:Bar(args.spellId, 42)
		end
		self:PlaySound(args.spellId, "alert", "watchstep")
		self:GetBossTarget(printTarget, 0.5, args.sourceGUID)
	end
end
