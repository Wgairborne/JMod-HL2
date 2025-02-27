SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = false
SWEP.Category = "ArcCW - Half-Life" -- edit this if you like
SWEP.AdminOnly = false
SWEP.PrintName = "Crowbar"
SWEP.Slot = 1
SWEP.EZdroppable = true

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"--"models/weapons/crowbar/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV = 60
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos = Vector(4, 2, -4),
    ang = Angle(-90, 182, 0)
}
SWEP.DefaultBodygroups = "00000000000"

SWEP.MeleeDamage = 25
SWEP.MeleeDamageBackstab = nil -- If not exists, use multiplier on standard damage
SWEP.MeleeRange = 32
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeTime = 0.4
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MeleeAttackTime = 0.1

SWEP.Melee2 = true
SWEP.Melee2Damage = 0
SWEP.Melee2DamageBackstab = nil -- If not exists, use multiplier on standard damage
SWEP.Melee2Range = 16
SWEP.Melee2Time = 0.5
SWEP.Melee2Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.Melee2AttackTime = 0.2

SWEP.Lunge = false

SWEP.Backstab = false
SWEP.BackstabMultiplier = 2

SWEP.CanBash = true
SWEP.PrimaryBash = true -- primary attack triggers melee attack

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "MELEE"
    },
}
SWEP.NotForNPCs = true

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee"

SWEP.ActivePos = Vector(0,0,0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.CrouchPos = Vector(-1, -2, -1)
SWEP.CrouchAng = Angle(0, 0, -15)

SWEP.HolsterPos = Vector(3, 3, 0)
SWEP.HolsterAng = Angle(-7.036, 30.016, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.NoHideLeftHandInCustomization = true
SWEP.CustomizePos = Vector(17, -12, 1)
SWEP.CustomizeAng = Angle(10, 50, 30)

SWEP.SprintPos = Vector( -0.0637, 0, 0.1897 )
SWEP.SprintAng = Angle( -11.0898, 9.5787, -10.7118 )

SWEP.BarrelLength = 0

SWEP.MeleeSwingSound = "Weapon_HEV.Crowbar_Swing"
SWEP.MeleeMissSound = "Weapon_Crowbar.Melee_Miss2"
SWEP.MeleeHitSound = "Weapon_Crowbar.Melee_Hit2"
SWEP.MeleeHitNPCSound = "Weapon_Crowbar.Melee_Hit2"

SWEP.IronSightStruct = false

SWEP.Animations = {
    ["idle"] = {
        Source = "idle01",
    },
    ["draw"] = {
        Source = "draw",
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.5,
    },
    ["holster"] = {
        Source = "holster",
    },
    ["bash"] = {
        Source = {"misscenter1","misscenter2"},
		
    },
}

SWEP.Hook_PostBash = function(wep, data)
	if data.dmg ~= 0 then return end
	local Alt = wep.Owner:KeyDown(JMod.Config.General.AltFunctionKey)
	local Task = "loosen"
	local Tr = util.QuickTrace(wep.Owner:GetShootPos(), wep.Owner:GetAimVector() * 80, {wep.Owner})
	local Ent, Pos = Tr.Entity, Tr.HitPos

	if IsValid(Ent) then
		if Ent ~= wep.TaskEntity or Task ~= wep.CurTask then
			wep:SetNW2Float("EZtaskProgress", 0)
			wep.TaskEntity = Ent
			wep.CurTask = Task
		elseif IsValid(Ent:GetPhysicsObject()) then
			local Message = JMod.EZprogressTask(Ent, Pos, wep.Owner, Task)

			if Message then
				wep.Owner:PrintMessage(HUD_PRINTCENTER, Message)
			else
				wep.TaskEntity = Ent
				--sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 60, math.random(50, 70))
				--sound.Play("snds_jack_gmod/ez_dismantling/" .. math.random(1, 10) .. ".wav", Pos, 65, math.random(90, 110))
				if SERVER then
					JMod.Hint(wep.Owner, "work spread")
					wep:SetNW2Float("EZtaskProgress", Ent:GetNW2Float("EZ"..Task.."Progress", 0))
				end
			end 
		end
	else
		wep:SetNW2Float("EZtaskProgress", 0)
	end
end

function SWEP:OnDrop()
	local Specs = JMod.WeaponTable[self.PrintName]

	if Specs then
		local Ent = ents.Create(Specs.ent)
		Ent:SetPos(self:GetPos())
		Ent:SetAngles(self:GetAngles())
		Ent.MagRounds = self:Clip1()
		Ent:Spawn()
		Ent:Activate()
		local Phys = Ent:GetPhysicsObject()

		if Phys and self and IsValid(Phys) and IsValid(self) and IsValid(self:GetPhysicsObject()) then
			Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
		end

		self:Remove()
	end
end

if CLIENT then
	local LastProg = 0

	SWEP.Hook_DrawHUD = function(self)
		if GetConVar("cl_drawhud"):GetBool() == false then return end
		local Ply = self.Owner
		if Ply:ShouldDrawLocalPlayer() then return end
		local Prog = self:GetNW2Float("EZtaskProgress", 0)
		local W, H, Build = ScrW(), ScrH()

		if Prog > 0 then
			draw.SimpleTextOutlined("Loosening...", "Trebuchet24", W * .5, H * .45, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
			draw.RoundedBox(10, W * .3, H * .5, W * .4, H * .05, Color(0, 0, 0, 100))
			draw.RoundedBox(10, W * .3 + 5, H * .5 + 5, W * .4 * LastProg / 100 - 10, H * .05 - 10, Color(255, 255, 255, 100))
		end
		LastProg = Lerp(FrameTime() * 5, LastProg, Prog)
	end
end

function SWEP:MeleeAttack(melee2)
    local reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.MeleeRange
    local dmg = self:GetBuff_Override("Override_MeleeDamage", self.MeleeDamage) or 20

    if melee2 then
        reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.Melee2Range
        dmg = self:GetBuff_Override("Override_MeleeDamage", self.Melee2Damage) or 20
    end

    dmg = dmg * self:GetBuff_Mult("Mult_MeleeDamage")

    self:GetOwner():LagCompensation(true)

    local filter = {self:GetOwner()}

    table.Add(filter, self.Shields)

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
        filter = filter,
        mask = MASK_SHOT_HULL
    })

    if (!IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = filter,
            mins = Vector(-16, -16, -8),
            maxs = Vector(16, 16, 8),
            mask = MASK_SHOT_HULL
        })
    end

    -- We need the second part for single player because SWEP:Think is ran shared in SP
    if !(game.SinglePlayer() and CLIENT) then
        if tr.Hit then
            if tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsPlayer() then
                self:MyEmitSound(self.MeleeHitNPCSound, 75, 100, 1, CHAN_USER_BASE + 2)
            else
                self:MyEmitSound(self.MeleeHitSound, 75, 100, 1, CHAN_USER_BASE + 2)
            end

            if tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_BLOODYFLESH then
                local fx = EffectData()
                fx:SetOrigin(tr.HitPos)

                util.Effect("BloodImpact", fx)
            end
        else
            self:MyEmitSound(self.MeleeMissSound, 75, 100, 1, CHAN_USER_BASE + 3)
        end
    end

    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        local dmginfo = DamageInfo()

        local attacker = self:GetOwner()
        if !IsValid(attacker) then attacker = self end
        dmginfo:SetAttacker(attacker)

        local relspeed = (tr.Entity:GetVelocity() - self:GetOwner():GetAbsVelocity()):Length()

        relspeed = relspeed / 225

        relspeed = math.Clamp(relspeed, 1, 1.5)

        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(dmg * relspeed)
        dmginfo:SetDamageType(self:GetBuff_Override("Override_MeleeDamageType") or self.MeleeDamageType or DMG_CLUB)

        dmginfo:SetDamageForce(self:GetOwner():GetRight() * -200 + self:GetOwner():GetForward() * 50)

        SuppressHostEvents(NULL)
        tr.Entity:TakeDamageInfo(dmginfo)
        SuppressHostEvents(self:GetOwner())

        if tr.Entity:GetClass() == "func_breakable_surf" then
            tr.Entity:Fire("Shatter", "0.5 0.5 256")
        end

    end

    if SERVER and IsValid(tr.Entity) then
        local phys = tr.Entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 60, tr.HitPos)
        end
    end

    self:GetBuff_Hook("Hook_PostBash", {tr = tr, dmg = dmg})

    self:GetOwner():LagCompensation(false)
end

sound.Add({
	name = "Weapon_Crowbar.Melee_Miss2",
	channel = CHAN_WEAPON,
	level = 79,
	volume = 0.6,
	pitch = {97, 103},
	sound = {
		"weapon/crowbar/crowbar_swing1.wav",
		"weapon/crowbar/crowbar_swing2.wav",
		"weapon/crowbar/crowbar_swing3.wav"
	}
})
sound.Add({
	name = "Weapon_Crowbar.Melee_Hit2",
	channel = CHAN_STATIC,
	level = 60,
	volume = 0.75,
	pitch = {97, 103},
	sound = {
		")weapon/crowbar/crowbar_hit_world01.wav",
		")weapon/crowbar/crowbar_hit_world02.wav",
		")weapon/crowbar/crowbar_hit_world03.wav",
		")weapon/crowbar/crowbar_hit_world04.wav",
		")weapon/crowbar/crowbar_hit_world05.wav",
		")weapon/crowbar/crowbar_hit_world06.wav"
	}
})

sound.Add({
	name = "Weapon_HEV.Crowbar_Draw",
	channel = CHAN_STATIC,
	level = 60,
	volume = 0.75,
	sound = {
		"fx/hev_suit/hev_draw_crowbar_01.wav",
		"fx/hev_suit/hev_draw_crowbar_02.wav",
		"fx/hev_suit/hev_draw_crowbar_03.wav"
	}
})
sound.Add({
	name = "Weapon_HEV.Crowbar_Swing",
	channel = CHAN_WEAPON,
	level = 79,
	volume = 0.6,
	pitch = {97, 103},
	sound = {
		"fx/hev_suit/hev_swing_crowbar_01.wav",
		"fx/hev_suit/hev_swing_crowbar_02.wav",
		"fx/hev_suit/hev_swing_crowbar_03.wav"
	}
})
