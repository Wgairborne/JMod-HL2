-- AdventureBoots 2022
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "AdventureBoots"
ENT.Category = "JMod - EZ HL:2"
ENT.Information = "Magnum Opus"
ENT.PrintName = "EZ Hopper Mine"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModGUIcolorable = false
ENT.JModEZstorable = true
ENT.EZscannerDanger = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZhopperMine = true

ENT.BlacklistedNPCs = {"bullseye_strider_focus", "npc_turret_floor", "npc_turret_ceiling", "npc_turret_ground"}

ENT.WhitelistedNPCs = {"npc_rollermine"}

---
local STATE_BROKEN, STATE_OFF, STATE_ARMING, STATE_ARMED, STATE_LAUNCHED, STATE_HELD = -1, 0, 1, 2, 3, 4

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Entity", 0, "Target")
	self:NetworkVar("Bool", 0, "Ally")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 2
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		JMod.Colorify(ent)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_mine01.mdl")
		self:SetMaterial("models/aboot/ezcombine_mine.vmt")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01, function()
			--self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		---
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken \n 2 is arming \n 3 is warning"})
		end
		---
		self.ArmAttempts = 0
		self.StillTicks = 0
		--self.AutoArm = false

		if self.AutoArm then
			self:NextThink(CurTime() + .3)
		end
		self.WarningSnd = CreateSound(self, "NPC_CombineMine.ActiveLoop")
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:Arm(self.EZowner or game.GetWorld())
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 100, 1000) then
			local Pos, State = self:GetPos(), self:GetState()

			--if State == STATE_LAUNCHED then
				self:Detonate()
			--[[elseif not (State == STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)]]--
			--end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		self.AutoArm = false
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				JMod.Colorify(self)
				self:EmitSound("snd_jack_minearm.wav", 60, 110)
				self:Arm(self.activator)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		elseif not (activator.KeyDown and activator:KeyDown(IN_SPEED)) then
			self:EmitSound("snd_jack_minearm.wav", 60, 70)
			self:Disarm()
			JMod.SetEZowner(self, activator)
			JMod.Colorify(self)
			self:DrawShadow(true)
			if IsValid(self.Weld) then
				SafeRemoveEntity(self.Weld)
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 10 then
				if self:GetState() == STATE_LAUNCHED then
					timer.Simple(0.01, function()
						if IsValid(self) then
							self:Detonate()
						end
					end)
				else
					self:EmitSound("SolidMetal.ImpactSoft")
				end
			end
		end
	end

	function ENT:Launch(targetPos)
		self:SetState(STATE_LAUNCHED)
		timer.Simple(0.2 * JMod.Config.Explosives.Mine.Delay, function()
			if IsValid(self) then
				self:EmitSound("NPC_CombineMine.Hop")
				local SelfPos = self:GetPos()
				local ToVec = targetPos - SelfPos
				ToVec.z = 0
				local ToDir = ToVec:GetNormalized()
				local ToAng = ToDir:Angle()
				local Dist = SelfPos:Distance(targetPos)
				local LaunchAngle = 60
				ToAng:RotateAroundAxis(ToAng:Right(), LaunchAngle)
				ToDir = ToAng:Forward() 
				-----
				local Speed = math.sqrt((600 * Dist) / math.sin(2 * math.rad(LaunchAngle))) -- Fancy math
				-----
				constraint.RemoveAll(self)

				local Phys = self:GetPhysicsObject()
				timer.Simple(0, function()
					if IsValid(Phys) then
						Phys:EnableMotion(true)
						Phys:SetDragCoefficient(0)
						Phys:AddVelocity((ToDir * Speed) + VectorRand(-1, 1))
					end
				end)
			end
		end)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Up = Vector(0, 0, 1)
		--[[local EffectType = 1
		local Traec = util.QuickTrace(self:GetPos(), Vector(0, 0, -5), self)

		if Traec.Hit then
			if (Traec.MatType == MAT_DIRT) or (Traec.MatType == MAT_SAND) then
				EffectType = 1
			elseif (Traec.MatType == MAT_CONCRETE) or (Traec.MatType == MAT_TILE) then
				EffectType = 2
			elseif (Traec.MatType == MAT_METAL) or (Traec.MatType == MAT_GRATE) then
				EffectType = 3
			elseif Traec.MatType == MAT_WOOD then
				EffectType = 4
			end
		else
			EffectType = 5
		end

		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(1)
		plooie:SetRadius(EffectType)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode", plooie, true, true)]]--
		util.ScreenShake(SelfPos, 99999, 99999, 1, 500)
		self:EmitSound("snd_jack_fragsplodeclose.wav", 90, 100)
		JMod.Sploom(JMod.GetEZowner(self), SelfPos, 150, 125)
		JMod.FragSplosion(self, SelfPos, 500, 20 * JMod.Config.Explosives.Mine.Power, 500, JMod.GetEZowner(self), Up, 1.3, 15)
		SafeRemoveEntity(self)
	end

	function ENT:Arm(armer)
		local State = self:GetState()

		if IsValid(self:GetParent()) then return end
		if State ~= STATE_OFF then return end
		if IsValid(armer) then
			JMod.Hint(armer, "mine friends")
			JMod.SetEZowner(self, armer)
			JMod.Colorify(self)
		end
		self:SetState(STATE_ARMING)

		timer.Simple(1, function()
			if IsValid(self) then
				if self:GetState() == STATE_ARMING then
					local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -2), self)
					local IsUp = self:GetUp().z > 0.3

					if (Tr.Hit) and not(Tr.Entity:IsNPC() or Tr.Entity:IsPlayer()) and (IsUp) then
						self.Weld = constraint.Weld(Tr.Entity, self, Tr.PhysicsBone, 0, 50000, false, false)
						if self.Weld then
							self.Weld:Activate()
							self:EmitSound("NPC_CombineMine.CloseHooks")
							self:SetState(STATE_ARMED)
							self:DrawShadow(false)
							self.ArmAttempts = 0
						end
					else
						self:Jump()
						--JPrint("ArmAttempts: " .. self.ArmAttempts )
					end
					self:NextThink(CurTime() + .5)
				end
			end
		end)
	end

	function ENT:Disarm()
		self.WarningSnd:Stop()
		self:EmitSound("NPC_CombineMine.TurnOff")
		self:SetState(STATE_OFF)
	end

	function ENT:Jump(extraVelocity)
		extraVelocity = extraVelocity or Vector(0, 0, 0)
		local Phys = self:GetPhysicsObject()

		if Phys:IsMotionEnabled() then
			self:EmitSound("NPC_CombineMine.FlipOver")
			Phys:ApplyForceOffset(Vector(0, 0, 3000) + extraVelocity, self:LocalToWorld(Vector(math.random()*2, math.random()*2, 0)))
		end
		timer.Simple(1, function()
			if IsValid(self) and (self:GetState() == STATE_ARMING) and (self.ArmAttempts < 5) then
				self.ArmAttempts = self.ArmAttempts + 1
				self:SetState(STATE_OFF)
				self:Arm(JMod.GetEZowner(self))
			else
				self:SetState(STATE_OFF)
			end
		end)
	end

	local LerpedMove = 0
	local AttackDist = 300 --245
	function ENT:Think()
		local SelfPos, State, Time = self:GetPos(), self:GetState(), CurTime()

		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", State)
		end

		if State == STATE_ARMED then
			if not(IsValid(self.Weld)) then
				self:Disarm()

				return true
			end
			--jprint(tostring(self:GetTarget()) .. " \t " .. tostring(self:GetAlly()))

			for k, targ in pairs(ents.FindInSphere(SelfPos, AttackDist)) do
				if not (targ == self) and (targ:IsPlayer() or targ:IsNPC() or targ:IsVehicle()) and JMod.ClearLoS(self, targ, true) then
					
					local targPos = targ:GetPos()

					if not(IsValid(self:GetTarget())) or SelfPos:Distance(self:GetTarget():GetPos()) > SelfPos:Distance(targPos) then
						self:SetTarget(targ)
					end

					if IsValid(self:GetTarget()) and JMod.ShouldAttack(self, self:GetTarget()) then
						self.WarningSnd:Play()
						self:SetAlly(false)
					else
						self.WarningSnd:Stop()
						self:SetAlly(true)
					end
				end
			end

			if IsValid(self:GetTarget()) then
				local Target, TargetPos = self:GetTarget(), self:GetTarget():GetPos()

				if SelfPos:Distance(TargetPos) < AttackDist * 0.75 then
					if not(self:GetAlly()) then
						self.WarningSnd:Stop()
						self:EmitSound("NPC_CombineMine.OpenHooks")
						local LaunchPos = Target:LocalToWorld(Target:OBBCenter() + Vector(0, 0, math.random(0, 10))) + Target:GetVelocity()
						self:Launch(LaunchPos)
					end
				elseif SelfPos:Distance(TargetPos) > AttackDist then
					self:SetTarget(nil)
					self:SetAlly(false)
					if self.WarningSnd:IsPlaying() then
						self.WarningSnd:Stop()
						self:EmitSound("NPC_CombineMine.TurnOff")
					end
				end
			end

			self:NextThink(Time + .3)

			return true
		elseif self.AutoArm then
			local Vel = self:GetPhysicsObject():GetVelocity()

			if Vel:Length() < 1 then
				self.StillTicks = self.StillTicks + 1
			else
				self.StillTicks = 0
			end

			if self.StillTicks > 4 then
				self:Arm(JMod.GetEZowner(self))
			end

			self:NextThink(Time + .1)

			return true
		end
	end

	local LastGravGunGrabTime = 0
	function ENT:GravGunPunt(ply)
		--print("We got punted")
		if self:GetState() == STATE_HELD then
			self:SetState(STATE_LAUNCHED)
			self:EmitSound("npc/roller/mine/rmine_predetonate.wav")

			return true
		else
			ply:DropObject()
		end
	end

	hook.Remove("GravGunOnDropped", "ABootGravGunHopperGrab")
	hook.Add("GravGunOnPickedUp", "ABootGravGunHopperGrab", function(ply, ent)
		if ent.EZhopperMine then 
			local State = ent:GetState()
			LastGravGunGrabTime = CurTime()

			if State == STATE_ARMED then
				ent:GetPhysicsObject():ApplyForceCenter(VectorRand() * 20)
				timer.Simple(1.5, function()
					if IsValid(ent) and ent:IsPlayerHolding() then
						if IsValid(ent.Weld) then
							SafeRemoveEntity(ent.Weld)
						end
						JMod.SetEZowner(ent, ply)
						JMod.Colorify(ent)
						ent:SetState(STATE_HELD)
					end
				end)
			else
				JMod.SetEZowner(ent, ply)
				JMod.Colorify(ent)
				ent:SetState(STATE_HELD)
			end
		end
	end)

	hook.Remove("GravGunOnDropped", "ABootGravGunHopperDrop")
	hook.Add("GravGunOnDropped", "ABootGravGunHopperDrop", function(ply, ent)
		if ent.EZhopperMine then
			if ent:GetState() == STATE_HELD then
				ent:SetState(STATE_OFF)
				if ply:KeyDown(JMod.Config.General.AltFunctionKey) then
					ent:Arm(ply)
				end
			end
		end
	end)

	function ENT:OnRemove()
		if self.WarningSnd then
			self.WarningSnd:Stop()
		end
	end

elseif CLIENT then
	function ENT:Initialize()
		self:SetLegs(70)
		self:SetClaws(-70)

		local LerpedMove, LastState = 0, 0
		self:AddCallback("BuildBonePositions", function(ent, numbones)
			local State = ent:GetState()
			if (State == STATE_ARMED) and (LastState ~= State) then
				ent:SetLegs(0)
				ent:SetClaws(0)
			elseif (State == STATE_OFF or STATE_ARMING) and (LastState ~= State) then
				ent:SetLegs(70)
				ent:SetClaws(-70)
			elseif (State == STATE_LAUNCHED) and (LastState ~= State) then 
				ent:SetLegs(70)
				ent:SetClaws(-70)
			elseif State == STATE_HELD then
				local Vary = math.sin(CurTime() * 5)/2 + .5
				ent:SetLegs(70 * LerpedMove)
				ent:SetClaws(-70 * LerpedMove)
				LerpedMove = Lerp(math.ease.InOutExpo(FrameTime() * 100), LerpedMove, Vary)
			end

			LastState = State
		end)
	end

	function ENT:SetLegs(angle)
		self:ManipulateBoneAngles(1,Angle(0,0,angle))
		self:ManipulateBoneAngles(3,Angle(0,0,angle))
		self:ManipulateBoneAngles(5,Angle(0,0,angle))
	end

	function ENT:SetClaws(angle)
		self:ManipulateBoneAngles(2,Angle(0,angle,0))
		self:ManipulateBoneAngles(4,Angle(0,angle,0))
		self:ManipulateBoneAngles(6,Angle(0,angle,0))
	end
	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local Up = self:GetUp()
		local State= self:GetState()

		if State == STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Up * 10, 20, 20, Color(0, 0, 255))
			render.DrawSprite(self:GetPos() + Up * 10, 10, 10, Color(0, 0, 255))
		elseif State == STATE_ARMED then
			if IsValid(self:GetTarget()) and self:GetAlly() then
				render.SetMaterial(GlowSprite)
				render.DrawSprite(self:GetPos() + Up * 10, 20, 20, Color(0, 255, 0))
				render.DrawSprite(self:GetPos() + Up * 10, 15, 15, Color(0, 255, 0))
			elseif IsValid(self:GetTarget()) and (self:GetAlly() == false) then
				render.SetMaterial(GlowSprite)
				render.DrawSprite(self:GetPos() + Up * 10, 20, 20, Color(255, 0, 0))
				render.DrawSprite(self:GetPos() + Up * 10, 15, 15, Color(255, 0, 0))
			end
		elseif State == STATE_LAUNCHED then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Up * 10, 20, 20, Color(255, 0, 0))
			render.DrawSprite(self:GetPos() + Up * 10, 15, 15, Color(255, 0, 0))
		elseif State == STATE_HELD then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Up * 10, 20, 20, Color(0, 0, 255))
			render.DrawSprite(self:GetPos() + Up * 10, 15, 15, Color(0, 0, 255))
		end
	end

	language.Add("ent_jack_gmod_ezhoppermine", "EZ Hopper Mine")
end



--[[
	----Combine mine behavior, for refrence----
	1)Start arming (about 1 sec delay)
	2)Trace downward
	2a)If hit, grab with claws and arm like normal
	2b)If not hit, jump, and go to step 2
	3)If applicible entity comes into range and sight, set as target
	3a)If target is enemy, turn red and start warning
	3b)If target ally, turn green and give no indicative sound
	3c)If there are no applicible targets in range, set target to nil and go to step 3
	4)If target gets to close and is enemy, disengage from the ground (about .5 delay)
	5)Blip and jump towards target
	
	----Below are rules for whatever state the mine is in----

	Rule 1)If picked up with the grav-gun, turn yellow (about 1 sec delay) 'disarm' and set to players side
	Rule 1a)While being held, turn light blue and actuate claws
	Rule 2)If dropped, go to step 1
	Rule 3)If thrown at any great speed, explode
]]--