SWEP.Base = "arccw_base"
SWEP.Spawnable = false
SWEP.Category = "ArcCW - Half-Life" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "SMG2"

SWEP.Slot = 2

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/smg1/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/smg1/w_smg1.mdl"
SWEP.ViewModelFOV = 60
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos = Vector(10, 0.5, -4),
    ang = Angle(-10, 1, 180)
}

SWEP.DefaultBodygroups = "00000000000"

SWEP.Damage = 10
SWEP.DamageMin = 6

SWEP.Range = 45 -- in METRES
SWEP.RangeMin = 30
SWEP.Penetration = 4
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 1050 -- projectile or phys bullet muzzle velocity
-- IN M/S
SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 30 -- DefaultClip is automatically set.
SWEP.ExtendedClipSize = 45
SWEP.ReducedClipSize = 24

SWEP.PhysBulletMuzzleVelocity = 700


SWEP.Recoil = 0.1
SWEP.RecoilSide = 0.1
SWEP.RecoilRise = 0.3
SWEP.MaxRecoilBlowback = -1
SWEP.VisualRecoilMult = 1.5
SWEP.RecoilPunch = 1.5
SWEP.RecoilPunchBackMax = 2
SWEP.RecoilPunchBackMaxSights = nil -- may clip with scopes
SWEP.RecoilVMShake = 1.0 -- random viewmodel offset when shooty

SWEP.Delay = 60 / 1000 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = -3,
		RunawayBurst = true,
		AutoBurst = true,
		PostBurstDelay = 0.2,
    },
    {
        Mode = 0
    }
}

SWEP.NPCWeaponType = "weapon_smg1"
SWEP.NPCWeight = 100

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 400 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 100
SWEP.SightsDispersion = 50

SWEP.Primary.Ammo = "smg1" -- what ammo type the gun uses
SWEP.MagID = "smg1" -- the magazine pool this gun draws from

SWEP.ShootVol = 80 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "Weapon_SMG1.Fire"
SWEP.DistantShootSound = "Weapon_SMG1.NPC"

SWEP.MirrorVMWM = false -- Copy the viewmodel, along with all its attachments, to the worldmodel. Super convenient!
SWEP.MirrorWorldModel = true -- Use this to set the mirrored viewmodel to a different model, without any floating speedloaders or cartridges you may have. Needs MirrorVMWM


SWEP.MuzzleEffect = "muzzleflash_smg"
SWEP.ShellModel = "models/shells/shell_9mm.mdl"
SWEP.ShellScale = 1.5
SWEP.ShellMaterial = nil
SWEP.MuzzleFlashColor = Color(255, 150, 0)
SWEP.GMMuzzleEffect = false


SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = 0.7
SWEP.SightTime = 0.33

SWEP.FreeAimAngle = nil -- defaults to HipDispersion / 80. overwrite here
SWEP.NeverFreeAim = nil
SWEP.AlwaysFreeAim = nil

SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerFinalMag = 0 -- the last X bullets in a magazine are all tracers
SWEP.Tracer = "arccw_tracer" -- override tracer (hitscan) effect
SWEP.HullSize = 0 -- HullSize used by FireBullets

SWEP.BodyDamageMults = {
    [HITGROUP_HEAD] = 1.3,
 }

SWEP.Force = 5

SWEP.IronSightStruct = {
    Pos = Vector(-6.5, -6, 0.65),
    Ang = Angle(0.472, 0.017, 0),
    Magnification = 1.3,
    SwitchToSound = "", -- sound that plays when switching to this sight
    CrosshairInSights = false
}

SWEP.ProceduralIronFire = true

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "smg"
SWEP.HoldtypeSights = "rpg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0,0,0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.CrouchPos = Vector(-1, -2, -1)
SWEP.CrouchAng = Angle(0, 0, -15)

SWEP.HolsterPos = Vector(3, 3, 0)
SWEP.HolsterAng = Angle(-7.036, 30.016, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.CustomizePos = Vector(8, 0, 1)
SWEP.CustomizeAng = Angle(5, 30, 30)

SWEP.BarrelLength = 24

SWEP.AttachmentElements = {
}

SWEP.ExtraSightDist = 10

SWEP.Attachments = {

}

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
    ["fire"] = {
        Source = {"fire01","fire02","fire03","fire04"},
		ShellEjectAt = 0,
		
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
    },
}

sound.Add({
	name = "Weapon_SMG1.Fire",
	channel = CHAN_WEAPON,
	volume = 0.8,
	level = 60,
	pitch = {97, 103},
	sound = {
		"weapon/smg1/smg1_fire_player_01.wav",
		"weapon/smg1/smg1_fire_player_02.wav",
		"weapon/smg1/smg1_fire_player_03.wav",
		"weapon/smg1/smg1_fire_player_04.wav",
		"weapon/smg1/smg1_fire_player_05.wav",
		"weapon/smg1/smg1_fire_player_06.wav"
	}
})

sound.Add({
	name = "Weapon_SMG1.NPC",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 140,
	pitch = {50, 70},
	sound = {
		")weapon/smg1/smg1_fire_player_01.wav",
		")weapon/smg1/smg1_fire_player_02.wav",
		")weapon/smg1/smg1_fire_player_03.wav",
		")weapon/smg1/smg1_fire_player_04.wav",
		")weapon/smg1/smg1_fire_player_05.wav",
		")weapon/smg1/smg1_fire_player_06.wav",
		")weapon/smg1/smg1_fire_player_07.wav",
		")weapon/smg1/smg1_fire_player_08.wav",
		")weapon/smg1/smg1_fire_player_09.wav",
		")weapon/smg1/smg1_fire_player_10.wav",
		")weapon/smg1/smg1_fire_player_11.wav",
		")weapon/smg1/smg1_fire_player_12.wav"
	}
})

sound.Add({
	name = "Weapon_SMG1.Mag_Out",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 60,
	pitch = {97, 103},
	sound = "weapon/smg1/handling/smg1_mag_out_01.wav"
})
sound.Add({
	name = "Weapon_SMG1.Mag_Futz",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 60,
	pitch = {97, 103},
	sound = "weapon/smg1/handling/smg1_mag_futz_01.wav"
})
sound.Add({
	name = "Weapon_SMG1.Mag_In",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 60,
	pitch = {97, 103},
	sound = "weapon/smg1/handling/smg1_mag_in_01.wav"
})
sound.Add({
	name = "Weapon_SMG1.Grip_Grab",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 60,
	pitch = {97, 103},
	sound = "weapon/smg1/handling/smg1_grip_grab_01.wav"
})

sound.Add({
	name = "Weapon_HEV.SMG_Draw",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 60,
	sound = {
		"fx/hev_suit/hev_draw_smg_01.wav",
		"fx/hev_suit/hev_draw_smg_02.wav",
		"fx/hev_suit/hev_draw_smg_03.wav"
	}
})
