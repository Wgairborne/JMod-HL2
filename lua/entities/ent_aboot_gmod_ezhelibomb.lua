﻿-- AdventureBoots 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "AdventureBoots"
ENT.Category = "JMod - EZ HL:2"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Helicopter Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZguidable = false
ENT.EZbombBaySize = 6
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Bool", 0, "Guided")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 10
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(150)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"-1 broken \n 0 off \n 1 armed"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			if (data.Speed > 500) and (self:GetState() == STATE_ARMED) then
				self:Detonate()

				return
			end

			if data.Speed > 2000 then
				self:Break()
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		SafeRemoveEntityDelayed(self, 10)
	end

	function ENT:OnTakeDamage(dmginfo)
		if IsValid(self.DropOwner) then
			local Att = dmginfo:GetAttacker()
			if IsValid(Att) and (self.DropOwner == Att) then return end
		end

		self.Entity:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 70, 150) then
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Detonate()
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav", 70, 110)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "impactdet")
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 70, 110)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 150)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 4000)
		local Eff = "500lb_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "500lb_air"
		end

		for i = 1, 3 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---
		for k, ply in pairs(player.GetAll()) do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 250) and (Dist < 4000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav", 55, 110)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 3, 1, 100)
				end)
			end
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 350, 100)

		timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 800, 100)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 250)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 7)
		JMod.BlastDoors(self, SelfPos, 7)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end

		local Phys, UseAeroDrag = self:GetPhysicsObject(), true
		--JMod.AeroDrag(self, -self:GetRight(), 6)
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	--[[function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jailure/wwii/wwii.mdl")
		self.Mdl:SetSubMaterial(0, "models/jmod/explosives/bombs/he_bomb")
		self.Mdl:SetModelScale(.8, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		--self.Guided=false
	end

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(), -90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos + Ang:Right() * 6 + Ang:Forward() * 15)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end]]--

	language.Add("ent_jack_gmod_ezhebomb", "EZ Thin-Skinned Bomb")
end
