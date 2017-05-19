SWEP.Category               = "Arcadium";
SWEP.PrintName              = "Heavy Nomad";
SWEP.Author                 = "Arcadium Software (Modified by MikuMikuCookie)";
SWEP.Contact                = "cakemixcore@gmail.com";
SWEP.Purpose                = "Fires energy rounds at a faster, more powerful rate.";
SWEP.Instructions           = "Aim, Brace Yourself, Fire, Fall Over, Victory!";

SWEP.UseHands               = true;

SWEP.ViewModel              = "models/weapons/c_irifle.mdl";
SWEP.WorldModel             = "models/weapons/w_irifle.mdl";
SWEP.ViewModelFOV           = 52;

SWEP.Slot                   = 4;
SWEP.SlotPos                = 1;
SWEP.Weight                 = 5;
SWEP.AutoSwitchTo           = true;
SWEP.AutoSwitchFrom         = false;

SWEP.SwayScale              = 2.0;
SWEP.BobScale               = 2.0;

SWEP.Primary.ClipSize       = -1;
SWEP.Primary.DefaultClip    = -1;
SWEP.Primary.Automatic      = true;
SWEP.Primary.Ammo           = "none";

SWEP.Secondary.ClipSize     = -1;
SWEP.Secondary.DefaultClip  = -1;
SWEP.Secondary.Automatic    = false;
SWEP.Secondary.Ammo         = "none";

SWEP.Spawnable              = true;
SWEP.AdminOnly              = false;

SWEP.IronSightsAng          = Vector( 0, 0, 0 );
SWEP.IronSightsPos          = Vector( -6.45, -8, 2.55 );

local EmptySound            = Sound( "buttons/combine_button3.wav" );
local ShootSound            = Sound( "npc/strider/fire.wav" );

local KillIconInitialized   = false;


function SWEP:SetupDataTables()

    self:NetworkVar( "Int", 0, "Energy" );
    self:NetworkVar( "Bool", 0, "IronSights" );

end

/*------------------------------------
    Initialize()
------------------------------------*/
function SWEP:Initialize()

    self:SetWeaponHoldType( "smg" );
    
    if( CLIENT ) then
    
        self.LastIronSights = false;
        self.IronSightsTime = 0;
        
        // initialize the kill icon for toybox entities
        if( !KillIconInitialized ) then
        
            KillIconInitialized = true;
            killicon.AddFont( self:GetClass(), "HL2MPTypeDeath", "8", Color( 255, 128, 128, 255 ) );

        end
    
    end
    
    if( SERVER ) then
    
        // setup some npc attributes
        self:SetNPCMinBurst( 1 );
        self:SetNPCMaxBurst( 1 );
        self:SetNPCFireRate( 0.105 );
        
        self:SetEnergy( 40 );
        self:SetIronSights( false );
        
        self.NextAmmoRegeneration = CurTime();
        self.NextIdleTime = CurTime();
        
    end

end


/*------------------------------------
    DoImpactEffect()
------------------------------------*/
function SWEP:DoImpactEffect( tr, dmgtype )

    // having the impact effect on the sky looks strange, ditch it
    if( tr.Hit && !tr.HitSky ) then
    
        local effect = EffectData();
            effect:SetOrigin( tr.HitPos );
            effect:SetNormal( tr.HitNormal );
        util.Effect( "NomadImpact", effect );
        
    end

    return true;

end


/*------------------------------------
    CanPrimaryAttack()
------------------------------------*/
function SWEP:CanPrimaryAttack()

    // npcs have unlimited ammo
    if( self.Owner:IsNPC() ) then
        return true;
    end
    
    // have enough energy to fire?
    if( self:GetEnergy() >= 1 ) then
        return true;
    end
    
    return false;
    
end


/*------------------------------------
    PrimaryAttack()
------------------------------------*/
function SWEP:PrimaryAttack()

    // bail if we can't fire
    if( !self:CanPrimaryAttack() ) then
    
        self:EmitSound( EmptySound );
        
        self:SetNextPrimaryFire( CurTime() + 0.2 );
        
        if( SERVER ) then
        
            // delay ammo regeneration so we don't have
            // infinite ammo while shooting
            self.NextAmmoRegeneration = CurTime() + 0.85;
            
        end
        
        return;
        
    end
    
    if( SERVER ) then
    
        self:TakePrimaryAmmo( 1 );
        
        // delay ammo regeneration so we don't have
        // infinite ammo while shooting
        self.NextAmmoRegeneration = CurTime() + 0.85;

    end

    // fire the bullet
    local bullet = {
        Num        = 1,
        Src        = self.Owner:GetShootPos(),
        Dir        = self.Owner:GetAimVector(),
        Spread     = Vector( 0.02, 0.02, 0 ),
        Tracer     = 1,
        Force      = 10,
        Damage     = 15,
        AmmoType   = "pistol",
        TracerName = "NomadTracer",
        Attacker   = self.Owner,
        Inflictor  = self,
        Hull       = HULL_TINY_CENTERED,
    };
    self.Weapon:FireBullets( bullet );
    
    // sound & animation
    self:EmitSound( ShootSound, 100, math.random( 200, 250 ) );
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
    self.Owner:SetAnimation( PLAYER_ATTACK1 );
    
    // handle weapon idle times
    if( SERVER ) then
    
        self.NextIdleTime = CurTime() + self:SequenceDuration();
    
    end
    
    // some view punching to make it not so static.
    if( self.Owner:IsPlayer() ) then
    
        self.Owner:ViewPunch( Angle( math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ) ) );
        
    end

    local effect = EffectData();
        effect:SetOrigin( self.Owner:GetShootPos() );
        effect:SetEntity( self.Weapon );
        effect:SetAttachment( 1 );
    util.Effect( "NomadMuzzle", effect );
    
    // we're an automatic weapon
    // have a decent fire rate
    self:SetNextPrimaryFire( CurTime() + 0.1 );

end


/*------------------------------------
    CanSecondaryAttack()
------------------------------------*/
function SWEP:CanSecondaryAttack()

    return false;
    
end


/*------------------------------------
    SecondaryAttack()
------------------------------------*/
function SWEP:SecondaryAttack()

    return false;
    
end


/*------------------------------------
    Reload()
------------------------------------*/
function SWEP:Reload()
end


/*------------------------------------
    Think()
------------------------------------*/
function SWEP:Think()

    if( SERVER ) then
    
        // do idle
        if( self.NextIdleTime <= CurTime() ) then
        
            self:SendWeaponAnim( ACT_VM_IDLE );
            self.NextIdleTime = CurTime() + self:SequenceDuration();
        
        end
    
        // regenerate energy
        if( self.NextAmmoRegeneration <= CurTime() ) then
        
            self:SetEnergy(math.min( 40, self:GetEnergy() + 1 ));
            self.NextAmmoRegeneration = CurTime() + 0.2;
        
        end
    
    end
    
end


/*------------------------------------
    Deploy()
------------------------------------*/
function SWEP:Deploy()

    if( SERVER ) then
    
        self:SetIronSights(false);
        
    end
    
end


/*------------------------------------
    Holster()
------------------------------------*/
function SWEP:Holster()

    if( SERVER ) then
    
        self.Owner:CrosshairEnable();
        
    end
    
    return true;

end


if( CLIENT ) then

    local AmmoDisplay = {};

    /*------------------------------------
        CustomAmmoDisplay()
    ------------------------------------*/
    function SWEP:CustomAmmoDisplay()
    
        AmmoDisplay.Draw            = true;
        AmmoDisplay.PrimaryClip     = self:GetEnergy();
        AmmoDisplay.PrimaryAmmo     = -1;
        AmmoDisplay.SecondaryClip   = -1;
        AmmoDisplay.SecondaryAmmo   = -1;
        
        return AmmoDisplay;
        
    end
    
    
    /*------------------------------------
        GetTracerOrigin()
    ------------------------------------*/
    function SWEP:GetTracerOrigin()
    
        local pos, ang = GetMuzzlePosition( self );
        return pos;
    
    end
    
    
    /*------------------------------------
        GetViewModelPosition()
    ------------------------------------*/
    function SWEP:GetViewModelPosition( pos, ang )

        local ironsights = self:GetIronSights();
        
        // just changed
        if( self.LastIronSights != ironsights ) then
        
            self.LastIronSights = ironsights;
            self.IronSightsTime = CurTime();
            
            // modify sway/bob scales
            if( ironsights ) then
            
                self.SwayScale = 0.1;
                self.BobScale = 0.15;
                
            else
            
                self.SwayScale = 2;
                self.BobScale = 2;
                
            end
        
        end
        
        local ironTime = self.IronSightsTime;
        local time = CurTime() - 0.25;
        
        // not in ironsights, return default position
        if( !ironsights && ironTime < time ) then
        
            return pos, ang;
            
        end
        
        // figure out the fraction for transitioning
        local frac = 1;
        if( ironTime > time ) then
            
            frac = math.Clamp( ( CurTime() - ironTime ) / 0.25, 0, 1 );
            
            if( !ironsights ) then
                frac = 1 - frac;
            end
        
        end
        
        local offset = self.IronSightsPos;
        
        if( self.IronSightsAng ) then
        
            ang = ang * 1;
            ang:RotateAroundAxis( ang:Right(), self.IronSightsAng.x * frac );
            ang:RotateAroundAxis( ang:Up(), self.IronSightsAng.y * frac );
            ang:RotateAroundAxis( ang:Forward(), self.IronSightsAng.z * frac );
        
        end
        
        pos = pos + offset.x * ang:Right() * frac;
        pos = pos + offset.y * ang:Forward() * frac;
        pos = pos + offset.z * ang:Up() * frac;

        return pos, ang
        
    end

end


if( SERVER ) then

    /*------------------------------------
        ToggleIronSights()
    ------------------------------------*/
    function SWEP:ToggleIronSights()

        self:SetIronSights(not self:GetIronSights());
        
        // enable/disable crosshair
        if( self:GetIronSights() ) then
            self.Owner:CrosshairDisable();
        else
            self.Owner:CrosshairEnable();
        end

    end

    /*------------------------------------
        TakePrimaryAmmo()
    ------------------------------------*/
    function SWEP:TakePrimaryAmmo( amt )

       self:SetEnergy(math.max( 0, self:GetEnergy() - amt ));

    end

    
    /*------------------------------------
        GetCapabilities()
    ------------------------------------*/
    function SWEP:GetCapabilities()

        return bit.bor(CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1);
        
    end
    

    /*------------------------------------
        NPCShoot_Secondary()
    ------------------------------------*/
    function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )

        if( IsValid( self.Owner ) ) then
            self:SecondaryAttack();
        end
        
    end
    

    /*------------------------------------
        NPCShoot_Primary()
    ------------------------------------*/
    function SWEP:NPCShoot_Primary( ShootPos, ShootDir )

        if( IsValid( self.Owner ) ) then
            self:PrimaryAttack();
        end

    end

end


AccessorFunc( SWEP, "fNPCMinBurst", "NPCMinBurst" );
AccessorFunc( SWEP, "fNPCMaxBurst", "NPCMaxBurst" );
AccessorFunc( SWEP, "fNPCFireRate", "NPCFireRate" );
AccessorFunc( SWEP, "fNPCMinRestTime", "NPCMinRest" );
AccessorFunc( SWEP, "fNPCMaxRestTime", "NPCMaxRest" );


/*------------------------------------
    GetMuzzlePosition()
------------------------------------*/
local function GetMuzzlePosition( weapon, attachment )

    if( !IsValid( weapon ) ) then
        return vector_origin, Angle( 0, 0, 0 );
    end

    local origin = weapon:GetPos();
    local angle = weapon:GetAngles();
    
    // if we're not in a camera and we're being carried by the local player
    // use their view model instead.
    if( weapon:IsWeapon() && weapon:IsCarriedByLocalPlayer() ) then
    
        local owner = weapon:GetOwner();
        if( IsValid( owner ) && GetViewEntity() == owner ) then
        
            local viewmodel = owner:GetViewModel();
            if( IsValid( viewmodel ) ) then
                weapon = viewmodel;
            end
            
        end
    
    end

    // get the attachment
    local attachment = weapon:GetAttachment( attachment or 1 );
    if( !attachment ) then
        return origin, angle;
    end
    
    return attachment.Pos, attachment.Ang;

end


if( CLIENT ) then

    local GlowMaterial = CreateMaterial( "arcadiumsoft/glow", "UnlitGeneric", {
        [ "$basetexture" ]    = "sprites/light_glow01",
        [ "$additive" ]        = "1",
        [ "$vertexcolor" ]    = "1",
        [ "$vertexalpha" ]    = "1",
    } );
    
    local EFFECT = {};
    
    
    /*------------------------------------
        Init()
    ------------------------------------*/
    function EFFECT:Init( data )
    
        self.Weapon = data:GetEntity();
        
        self.Entity:SetRenderBounds( Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) );
        self.Entity:SetParent( self.Weapon );
        
        self.LifeTime = math.Rand( 0.25, 0.35 );
        self.DieTime = CurTime() + self.LifeTime;
        self.Size = math.Rand( 16, 24 );
        
        local pos, ang = GetMuzzlePosition( self.Weapon );
        
        // emit a burst of light
        local light = DynamicLight( self.Weapon:EntIndex() );
            light.Pos            = pos;
            light.Size            = 200;
            light.Decay            = 400;
            light.R                = 255;
            light.G                = 128;
            light.B                = 128;
            light.Brightness    = 2;
            light.DieTime        = CurTime() + 0.35;
    
    end
    
    
    /*------------------------------------
        Think()
    ------------------------------------*/
    function EFFECT:Think()
    
        return IsValid( self.Weapon ) && self.DieTime >= CurTime();
        
    end
    
    
    /*------------------------------------
        Render()
    ------------------------------------*/
    function EFFECT:Render()
    
        // how'd this happen?
        if( !IsValid( self.Weapon ) ) then
            return;
        end
    
        local pos, ang = GetMuzzlePosition( self.Weapon );
        
        local percent = math.Clamp( ( self.DieTime - CurTime() ) / self.LifeTime, 0, 1 );
        local alpha = 255 * percent;
        
        render.SetMaterial( GlowMaterial );
        
        // draw it twice to double the brightness D:
        for i = 1, 2 do
            render.DrawSprite( pos, self.Size, self.Size, Color( 255, 128, 255, alpha ) );
            render.StartBeam( 2 );
                render.AddBeam( pos - ang:Forward() * 48, 16, 0, Color( 255, 128, 255, alpha ) );
                render.AddBeam( pos + ang:Forward() * 64, 16, 1, Color( 255, 128, 255, 0 ) );
            render.EndBeam();
        end
    
    end
    
    effects.Register( EFFECT, "NomadMuzzle" );
    
end


if( CLIENT ) then

    local GlowMaterial = CreateMaterial( "arcadiumsoft/glow", "UnlitGeneric", {
        [ "$basetexture" ]    = "sprites/light_glow01",
        [ "$additive" ]        = "1",
        [ "$vertexcolor" ]    = "1",
        [ "$vertexalpha" ]    = "1",
    } );
    
    local EFFECT = {};
    
    
    /*------------------------------------
        Init()
    ------------------------------------*/
    function EFFECT:Init( data )
        
        local pos = data:GetOrigin();
        local normal = data:GetNormal();
        
        self.Position = pos;
        self.Normal = normal;
        
        self.LifeTime = math.Rand( 0.25, 0.35 );    // 0.25, 0.35
        self.DieTime = CurTime() + self.LifeTime;
        self.Size = math.Rand( 32, 48 );
        
        // impact particles
        local emitter = ParticleEmitter( pos );
        for i = 1, 32 do
        
            local particle = emitter:Add( "sprites/glow04_noz", pos + normal * 2 );
            particle:SetVelocity( ( normal + VectorRand() * 0.75 ):GetNormal() * math.Rand( 75, 125 ) );
            particle:SetDieTime( math.Rand( 0.5, 1.25 ) );
            particle:SetStartAlpha( 255 );
            particle:SetEndAlpha( 0 );
            particle:SetStartSize( math.Rand( 1, 2 ) );
            particle:SetEndSize( 0 );
            particle:SetRoll( 0 );
            particle:SetColor( 255, 128, 255 );
            particle:SetGravity( Vector( 0, 0, -250 ) );
            particle:SetCollide( true );
            particle:SetBounce( 0.3 );
            particle:SetAirResistance( 5 );

        end
        emitter:Finish();
    
        // emit a burst of light
        local light = DynamicLight( 0 );
            light.Pos            = pos;
            light.Size            = 64;
            light.Decay            = 256;
            light.R                = 255;
            light.G                = 128;
            light.B                = 255;
            light.Brightness    = 2;
            light.DieTime        = CurTime() + 0.35;
            
    end
    
    
    /*------------------------------------
        Think()
    ------------------------------------*/
    function EFFECT:Think()
    
        return self.DieTime >= CurTime();
        
    end
    
    
    /*------------------------------------
        Render()
    ------------------------------------*/
    function EFFECT:Render()
    
        local pos, normal = self.Position, self.Normal;
        
        local percent = math.Clamp( ( self.DieTime - CurTime() ) / self.LifeTime, 0, 1 );
        local alpha = 255 * percent;
        
        // draw the muzzle flash as a series of sprites
        render.SetMaterial( GlowMaterial );
        render.DrawQuadEasy( pos + normal, normal, self.Size, self.Size, Color( 255, 128, 255, alpha ) );
    
    end
    
    effects.Register( EFFECT, "NomadImpact" );
    
end


if( CLIENT ) then

    local SparkMaterial = CreateMaterial( "arcadiumsoft/spark", "UnlitGeneric", {
        [ "$basetexture" ]    = "effects/spark",
        [ "$brightness" ]    = "effects/spark_brightness",
        [ "$additive" ]        = "1",
        [ "$vertexcolor" ]    = "1",
        [ "$vertexalpha" ]    = "1",
    } );
    
    local EFFECT = {};
    
    
    /*------------------------------------
        Init()
    ------------------------------------*/
    function EFFECT:Init( data )
    
        local weapon = data:GetEntity();
        local attachment = data:GetAttachment();
                
        local startPos = GetMuzzlePosition( weapon, attachment );
        local endPos = data:GetOrigin();
        local distance = ( startPos - endPos ):Length();
        
        self.StartPos = startPos;
        self.EndPos = endPos;
        self.Normal = ( endPos - startPos ):GetNormal();
        self.Length = math.random( 128, 500 );
        self.StartTime = CurTime();
        self.DieTime = CurTime() + ( distance + self.Length ) / 15000;
        
    end
    
    
    /*------------------------------------
        Think()
    ------------------------------------*/
    function EFFECT:Think()
        
        return self.DieTime >= CurTime();
        
    end
    
    
    /*------------------------------------
        Render()
    ------------------------------------*/
    function EFFECT:Render()
    
        local time = CurTime() - self.StartTime;
    
        local endDistance = 15000 * time;
        local startDistance = endDistance - self.Length;
        
        // clamp the start distance so we don't extend behind the weapon
        startDistance = math.max( 0, startDistance );
        
        local startPos = self.StartPos + self.Normal * startDistance;
        local endPos = self.StartPos + self.Normal * endDistance;
        
        // draw the beam
        render.SetMaterial( SparkMaterial );
        render.DrawBeam( startPos, endPos, 8, 0, 1, Color( 255, 128, 128, 255 ) );
    
    end
    
    effects.Register( EFFECT, "NomadTracer" );
    
end
