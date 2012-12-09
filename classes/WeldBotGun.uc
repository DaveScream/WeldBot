//================================================================================
// WeldBotGun.
//================================================================================
class WeldBotGun extends KFWeapon;

#exec OBJ LOAD FILE=..\Animations\chippoDT_A.ukx

var WeldBot CurrentWeldBot;
var bool bBeingDestroyed;
var bool bSentryDeployed,bClientDeployed;
var bool bNeedSpawnBot;

var() Name FireAnim; // FireAnim есть в WeaponFire FireMode[0] классе, но WeldBot не имеет FireMode, так что придется тут
var float FireAnimRate;
var int FMode;
var bool bFiring;

var SkeletalMesh RCMesh;
var array<Material> RCSkins;

// Screen Scripted Texture
var Texture		RCScreen; // original texture
var ScriptedTexture	ScriptedScreen;
var Shader		ShadedScreen;
var Material	ScriptedScreenBack;
var Color		BackColor;
var Color		TextColor;
var Font		TextFont;
var(DEBUG) array<localized string> RCStringStay[2];
var(DEBUG) array<localized string> RCStringFollow[2];
var(DEBUG) array<localized string> RCStringWeld[2];
var(DEBUG) array<float> LineOffset[2];
var(DEBUG) float MaxLineW, MaxLineH, MaxHPLineH, MaxHPLineW,HPLineOffsetX,HPLineOffsetY;
var (DEBUG) int FontSize;
var (DEBUG)	string FontName;
var (DEBUG)	string FontPackage;
var (DEBUG) array<Font> Fonts[49];
var const float FontSizeState, FontSizeHP;
var bool bFontsPreloaded;
var vector MPlayerViewOffset;

var Weapon OldWpn;

var enum RState
{
	Change,
	Enter,
} RCBtn;

var WeldBot.EState tState, tStateClient, BotState, BotStateClient;
var int Health, HealthClient;

var float BtnPressed;
var() float BtnDelay;

var() bool bRusLangClient;

replication
{
	reliable if(Role==ROLE_Authority && bNetOwner)
		bSentryDeployed, PreloadFonts;
		
	reliable if(Role==ROLE_Authority)
		OldWpn, tState, BotState, Health, SetWeapon, RenderRCScreen/*, ChangeMode, ChangeModeTemp*/;
	
	reliable if(Role<ROLE_Authority)
		ServerFire, bRusLangClient;
}

//--------------------------------------------------------------------------------------------------
simulated function SetBotState(WeldBot.EState s)
{
	BotState = s;
	BotStateClient = s;
	RenderRCScreen();
}
//--------------------------------------------------------------------------------------------------
simulated function SetHealth(int H)
{
	Health = H;
	HealthClient = H;
	RenderRCScreen();
}
//--------------------------------------------------------------------------------------------------
simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	//if (Level.NetMode==NM_Client || Level.NetMode==NM_Standalone)
	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (class'WeldBotLangSetup'.static.IsRussia())
		{
			class'WeldBotLangSetup'.static.InitRussia();
			ItemName			= class'WeldBotLangSetup'.default.ItemName;
			Description			= class'WeldBotLangSetup'.default.Description;
			RCStringStay[0]		= class'WeldBotLangSetup'.default.RCStringStay[0];
			RCStringStay[1]		= class'WeldBotLangSetup'.default.RCStringStay[1];
			RCStringFollow[0]	= class'WeldBotLangSetup'.default.RCStringFollow[0];
			RCStringFollow[1]	= class'WeldBotLangSetup'.default.RCStringFollow[1];
			RCStringWeld[0]		= class'WeldBotLangSetup'.default.RCStringWeld[0];
			RCStringWeld[1]		= class'WeldBotLangSetup'.default.RCStringWeld[1];
			
			bRusLangClient=true;
			
			if (FontInstalled("ROFonts_Rus."$FontName)==false)
				FontPackage="ROFonts.";
			else FontPackage="ROFonts_Rus.";
		}
		else
			FontPackage="ROFonts.";

		PreloadFonts();
	}
}
//--------------------------------------------------------------------------------------------------
simulated function PostNetReceive()
{
	local bool bRender;
	Super.PostNetReceive();
	
	if (tStateClient!=tState)
	{
		tStateClient=tState;
		bRender=true;
	}
	if (BotStateClient!=BotState)
	{
		BotStateClient=BotState;
		bRender=true;
	}
	if (HealthClient!=Health)
	{
		HealthClient=Health;
		bRender=true;
	}
	if (bRender)
		RenderRCScreen();
}
//--------------------------------------------------------------------------------------------------
simulated function PreloadFonts()
{
	local float ExecutionTime;
	if (bFontsPreloaded)
		return;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		Clock(ExecutionTime);
		GetFont(FontSizeState);
		GetFont(FontSizeState-2);
		GetFont(FontSizeState+2);
		GetFont(FontSizeHP);
		GetFont(FontSizeHP-2);
		GetFont(FontSizeHP+2);		
		UnClock(ExecutionTime);
		//Level.GetLocalPlayerController().ClientMessage("Preload fonts at postbegin play took"@ExecutionTime);
		log("Preload fonts at postbegin play took"@ExecutionTime);
	}
	bFontsPreloaded=true;
}
//--------------------------------------------------------------------------------------------------
simulated event RenderOverlays( Canvas Canvas )
{
	PreloadFonts();

	if( bSentryDeployed!=bClientDeployed )
	{
		bClientDeployed = bSentryDeployed;
		SetWeapon();
		
		// проверить
		Instigator.Weapon=none;
		PutDown();
		PlayerController(Instigator.Controller).ClientSetWeapon(self.Class);
		BringUp();
		PlayAnim('Select',0.1);
	}

	if (MPlayerViewOffset!=PlayerViewOffset)
		PlayerViewOffset=MPlayerViewOffset;
	PlayerViewOffset.X+=0.01f;
	
	Super.RenderOverlays(Canvas);
}
//--------------------------------------------------------------------------------------------------
simulated function SetWeapon()
{
	if( bSentryDeployed )
	{
		LinkMesh(RCMesh);
		//Skins[0]=RCSkins[0]; // рукава
		Skins[1]=RCSkins[1];
		PlayerViewOffset.X=4.40;
		PlayerViewOffset.Y=0.0;
		PlayerViewOffset.Z=2.10;
		MPlayerViewOffset = PlayerViewOffset;
		Default.PlayerViewOffset = MPlayerViewOffset;
		DisplayFOV=60.0;
		Default.DisplayFOV=60.0;
		AmbientGlow=0;
		/*PlayerViewOffset.X=7.000000;
		PlayerViewOffset.Y=0.0;
		PlayerViewOffset.Z=2.000000;
		DisplayFOV=75.0;*/
		BobDamping=2.2;
		SelectAnim='Select';
		PutDownAnim = 'PutDown';
		IdleAimAnim = 'Idle';
		FireAnim = 'Fire';
		FireAnimRate = 1.00;
		if (ThirdPersonActor != none)
			WeldBotGunAttachment(ThirdPersonActor).SetDeployed();
	}
	else
	{
		LinkMesh(Default.Mesh);
		//Skins[0]=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb';
		Skins[1]=Shader'chippoDT_A.RPR_SWR_NKD_DIFF_sh';
		PlayerViewOffset.X=40.000000;
		PlayerViewOffset.Y=0;
		PlayerViewOffset.Z=-6.000000;
		MPlayerViewOffset = PlayerViewOffset;
		Default.PlayerViewOffset = MPlayerViewOffset;
		DisplayFOV=30.0;
		Default.DisplayFOV=30.0;
		AmbientGlow=0;
		BobDamping=4.5;
		SelectAnim='Select';
		PutDownAnim='PutDown';
		IdleAimAnim='Idle';
		SelectAnim='Select';
		FireAnim='Fire';
		FireAnimRate=1.00;
		if (ThirdPersonActor != none)
			WeldBotGunAttachment(ThirdPersonActor).SetUnDeployed();
	}
}
//--------------------------------------------------------------------------------------------------
simulated event ClientStartFire (int Mode)
{
	local WeldBot tWB;
	local Rotator R;
	local Vector Spot;
	if (bFiring)
		return;
	bFiring = true;
	
	if ( Pawn(Owner).Controller.IsInState('GameEnded')
		|| Pawn(Owner).Controller.IsInState('RoundEnded') )
		return;
		
	if ( bSentryDeployed )
	{
		if (Mode==0)
			PlayAnim('Enter', 1.f,0.1);
		else if (Mode==1)
			PlayAnim('leaf_through', 1.f,0.1);
		ServerStartFire(Mode);
	}
	else
	{
		if (bNeedSpawnBot==true)
			return;
		R.Yaw = Instigator.Rotation.Yaw;
		Spot = vector(R) * (Instigator.CollisionRadius + 70.0) + Instigator.Location;
		if ( FastTrace(Spot,Instigator.Location) )
		{
			if (Level.NetMode!=NM_DedicatedServer)
			{
				tWB = Spawn(Class'WeldBot',,,Spot,R);
				if ( tWB != None )
				{
					tWB.Destroy();
					bNeedSpawnBot=true;
					FMode=Mode;
					PlayAnim(FireAnim,1.0);
					return;
				}
			}
		}
		// Здесь поставить не получится
		if ( PlayerController(Instigator.Controller) != None && CurrentWeldBot==none)
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'WeldBotMessage',0);
	}
}
//--------------------------------------------------------------------------------------------------
function ServerFire(byte Mode)
{
	ServerStartFire(Mode);
}
//--------------------------------------------------------------------------------------------------
event ServerStartFire(byte Mode)
{
	local Rotator R;
	local Vector Spot;
	
	if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

	if ( bSentryDeployed )
	{
		if (Mode==0)
		{
			RCBtn = Enter;
			BtnPressed = Level.Timeseconds+BtnDelay;
		}
		else if (Mode==1)
		{
			RCBtn = Change;
			BtnPressed = Level.Timeseconds+BtnDelay;
		}
	}
	else
	{
		R.Yaw = Instigator.Rotation.Yaw;
		Spot = vector(R) * (Instigator.CollisionRadius + 70.0) + Instigator.Location;
		if( FastTrace(Spot,Instigator.Location) )
		{
			CurrentWeldBot = Spawn(Class'WeldBot',,,Spot,R);
			if ( CurrentWeldBot != None )
			{
				CurrentWeldBot.SetOwningPlayer(Instigator,self);
				bSentryDeployed = True;
				SellValue = 10;
				if ( ThirdPersonActor != None )
					WeldBotGunAttachment(ThirdPersonActor).SetDeployed();

				if ( PlayerController(Instigator.Controller) != None )
					PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'WeldBotMessage',1);

				tState = Follow; // RC by default show this state text				
				NetUpdateTime = Level.TimeSeconds-1.f;
			}
		}
		// Здесь поставить не получится
		if ( PlayerController(Instigator.Controller) != None && CurrentWeldBot==none)
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'WeldBotMessage',0);
	}
}
//--------------------------------------------------------------------------------------------------
simulated function WeaponTick(float dt)
{
	super.WeaponTick(dt);
	if (BtnPressed!=0 && BtnPressed < Level.Timeseconds)
	{
		BtnPressed=0;
		if (RCBtn==Enter)
			ChangeMode();
		else if (RCBtn==Change)
			ChangeModeTemp();
			
		NetUpdateTime = Level.TimeSeconds-1.f;
	}

	PreloadFonts();
}
//--------------------------------------------------------------------------------------------------
function ChangeModeTemp()
{
	if (tState==Stay) tState=Follow;
	else if (tState==Follow) tState=WeldDoors;
	else if (tState==WeldDoors) tState=Stay;
	
	if (tState==CurrentWeldBot.BotState)
		ChangeModeTemp();
		
	// if NM_Standalone
	tStateClient = tState;
	RenderRCScreen();
}
//---------------------------------------------------
function ChangeMode()
{
	//local string newState;
	if (tState == CurrentWeldBot.BotState)
		return;
	//newState = CurrentWeldBot.StateToString(tState);
	CurrentWeldBot.SetParams(tState);
	RenderRCScreen();
}
//--------------------------------------------------------------------------------------------------
simulated function InitMaterials()
{
	if( ScriptedScreen==None )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        //ScriptedScreen.SetSize(256,256);
		ScriptedScreen.SetSize(RCScreen.USize, RCScreen.VSize);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = Self;
	}

	if( ShadedScreen==None )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScriptedScreen;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		Skins[2] = ShadedScreen; //good
	}
	
	// Font setup
	/*if (TextFont==none)
	{
		TextFont = Font(DynamicLoadObject("ROFonts_Rus.ROArial7",Class'Font'));
		if (TextFont == none)
			TextFont = Font(DynamicLoadObject("ROFonts_Rus.ROBtsrmVr12",Class'Font'));
		if (TextFont == none)
			TextFont = Font'DefaultFont';
	}*/
	
}
//--------------------------------------------------------------------------------------------------
simulated function RenderRCScreen()
{
	if (!bSentryDeployed)
		return; // иначе натянет Skin[2] на бота
	if (ScriptedScreen==None)
		InitMaterials();

	// Redraw scripted texture next frame
	ScriptedScreen.Revision++;
	if( ScriptedScreen.Revision>1000 )
		ScriptedScreen.Revision = 1;
}
//--------------------------------------------------------------------------------------------------
simulated function M(string msg)
{
	if (Pawn(Owner)!=none && Pawn(Owner).Controller != none)
		PlayerController(Pawn(Owner).Controller).ClientMessage(msg);
}
//--------------------------------------------------------------------------------------------------
simulated function Font GetFont(int size)
{
	if (Fonts[size]==none)
	{
		M("loading fontsize"@size);
		Fonts[size]=Font(DynamicLoadObject(FontPackage$FontName$size,Class'Font'));
		if (Fonts[size]==none)
			M("loading fontsize"@size@"Failed!!");
	}
	return Fonts[size];
}
//--------------------------------------------------------------------------------------------------
simulated event RenderTexture(ScriptedTexture T)
{
	local int tX,  tY, curLine, i, n, tempFontSize;
	local string S;
	local Color tColor;
	local float MaxW, MaxH;
	local bool bDec, bInc;

	T.DrawTile(0,0,T.USize,T.VSize,0,0,RCScreen.USize,RCScreen.VSize,RCScreen,BackColor);   // Draws the tile background
	if (tStateClient==BotStateClient)
	{
		tColor.R=255;
		tColor.G=0;
		tColor.B=0;
		tColor.A=255;
	}
	else
		tColor=TextColor;
	
	MaxW = T.USize * MaxLineW;
	MaxH = T.VSize * MaxLineH;
	FontSize = FontSizeState;
	for (curLine=0; curline<2; curLine++)
	{
		if (tStateClient==Stay)
			S = RCStringStay[curLine];
		if (tStateClient==Follow)
			S = RCStringFollow[curLine];
		if (tStateClient==WeldDoors)
			S = RCStringWeld[curLine];

		bInc=false;
		bDec=false;
		while (i < 22)
		{
			TextFont = GetFont(FontSize);
			n=0;
			while (TextFont==none && n<22)
			{
				if (bInc==true)
					FontSize+=2;
				else if (bDec==true)
					FontSize-=2;
				else FontSize+=2;

				if (FontSize>48)
				{
					bInc=false;
					bDec=true;
				}
				else if (FontSize<6)
				{
					bDec=false;
					bInc=true;
				}
				TextFont = GetFont(FontSize);
				n++;
			}
			T.TextSize(S,TextFont,tX,tY); // get the size of the players name
			if (tX > MaxW || tY > MaxH)
			{
				if (bInc==true)
					break;
				bDec=true;
				if (FontSize<=6) // already at minimum
					break;
				FontSize-=2;
			}
			else
			{
				if (bDec==true)
					break;
				bInc=true;
				if (FontSize>=48) // already at maximum
					break;
				FontSize+=2;
			}
			i++;
		}
		
		if (bInc) FontSize-=2;
		if (bDec) FontSize+=2;
		
		if (tempFontSize==0 || FontSize < tempFontSize)
			tempFontSize=FontSize;
	}
	TextFont = GetFont(tempFontSize);
	//M("Calculated state fontsize"@tempFontSize);

	for (curLine=0; curline<2; curLine++)
	{
		if (tStateClient==Stay)
			S = RCStringStay[curLine];
		if (tStateClient==Follow)
			S = RCStringFollow[curLine];
		if (tStateClient==WeldDoors)
			S = RCStringWeld[curLine];
			
		T.TextSize(S,TextFont,tX,tY);
		T.DrawText( (T.USize*0.5f) - (tX*0.5f), T.VSize*LineOffset[curLine] - (tY*0.5f), S, TextFont, tColor);
	}
	
	// Выводим HP
	MaxW = T.USize * MaxHPLineW;
	MaxH = T.VSize * MaxHPLineH;
	S = Max(HealthClient,0)$"%";
	bInc=false;
	bDec=false;
	FontSize = FontSizeHP;
	while (i < 50)
	{
		TextFont = GetFont(FontSize);
		n=0;
		while (TextFont==none && n<22)
		{
			if (bInc==true)
				FontSize+=2;
			else if (bDec==true)
				FontSize-=2;
			else FontSize+=2;

			if (FontSize>48)
			{
				bInc=false;
				bDec=true;
			}
			else if (FontSize<6)
			{
				bDec=false;
				bInc=true;
			}
			TextFont = GetFont(FontSize);
			n++;
		}
		T.TextSize(S,TextFont,tX,tY); // get the size of the players name
		if (tX > MaxW || tY > MaxH)
		{
			if (bInc==true)
				break;
			bDec=true;
			if (FontSize<=6) // already at minimum
				break;
			FontSize-=2;
		}
		else
		{
			if (bDec==true)
				break;
			bInc=true;
			if (FontSize>=48) // already at maximum
				break;
			FontSize+=2;
		}
		i++;
	}
	
	if (bInc) FontSize-=2;
	if (bDec) FontSize+=2;
	
	//M("Calculated HP fontsize"@FontSize);
	
	TextFont = GetFont(FontSize);
	tColor=TextColor;
	T.TextSize(S,TextFont,tX,tY);
	T.DrawText( (T.USize*HPLineOffsetX) - tX, T.VSize*HPLineOffsetY - (tY*0.5f), S, TextFont, tColor);
}
//--------------------------------------------------------------------------------------------------
simulated function bool FontInstalled(string Font)
{
	local int i;
	for (i=40;i<=48;i+=2)
	{
		TextFont = Font(DynamicLoadObject(Font$(i),Class'Font'));
		if (TextFont!=none)
			return true;
	}
	return false;
}
//--------------------------------------------------------------------------------------------------
simulated function UpdatePrecacheMaterials()
{
    Super.UpdatePrecacheMaterials();
	Level.AddPrecacheMaterial(Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb');
	Level.AddPrecacheMaterial(Texture'chippoDT_A.PultDT');
}
//--------------------------------------------------------------------------------------------------
simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);
	if( Level.NetMode!=NM_DedicatedServer )
		SetWeapon();

	if (ThirdPersonActor != none)
	{
		if (bSentryDeployed)
			WeldBotGunAttachment(ThirdPersonActor).SetDeployed();
		else
			WeldBotGunAttachment(ThirdPersonActor).SetUnDeployed();
	}

	// TELO
	RenderRCScreen();
	if (OldWeapon!=none && OldWeapon.Class!=self.Class)
		OldWpn = OldWeapon;
}
//--------------------------------------------------------------------------------------------------
simulated function AnimEnd(int channel)
{
	super.AnimEnd(channel);
	if (bFiring)
		bFiring=false;
	if (bNeedSpawnBot)
	{
		bNeedSpawnBot=false;
		NetUpdateTime = Level.TimeSeconds-1.f;
		ServerFire(0); //ServerStartFire(0);
		// PlayerController(Instigator.Controller).ClientSetWeapon(OldWpn.Class);
		// PlayerController(Instigator.Controller).ClientSetWeapon(OldWeapon.Class);
	}
	if (bBeingDestroyed)
		Destroy();
}
//--------------------------------------------------------------------------------------------------
simulated event ClientStopFire(int Mode)
{
	bFiring=false;
	// ServerStopFire(Mode);
}
//--------------------------------------------------------------------------------------------------
function AttachToPawn(Pawn P)
{
	Super.AttachToPawn(P);
	/*if ( bSentryDeployed && (ThirdPersonActor != None) )
	{
		InventoryAttachment(ThirdPersonActor).bFastAttachmentReplication = False;
		ThirdPersonActor.bHidden = True;
	}*/
}
//--------------------------------------------------------------------------------------------------
simulated function BotDestroyed()
{
	log("BotDestroyed");
	PlayerController(Instigator.Controller).ClientSetWeapon(OldWpn.Class);
	bBeingDestroyed=true;
}
//--------------------------------------------------------------------------------------------------
simulated function Tick(float dt)
{
	super.Tick(dt);
	if (bBeingDestroyed && Pawn(Owner).Weapon.Class != self.Class)
		Destroy();
}
//--------------------------------------------------------------------------------------------------
simulated function bool PutDown()
{
	if (bBeingDestroyed)
	{
		Instigator.ChangedWeapon();
		return true;
	}
	else
		return Super.PutDown();
}
//--------------------------------------------------------------------------------------------------
static function WeldBot.EState StringToState(string input)
{
	if (caps(input)=="FOLLOW") return Follow;
	if (caps(input)=="STAY") return Stay;
	if (caps(input)=="WELDDOORS") return WeldDoors;
	return Stay;
}
//--------------------------------------------------------------------------------------------------
static function string StateToString(WeldBot.EState input)
{
	if (input==Follow) return "FOLLOW";
	if (input==Stay) return "STAY";
	if (input==WeldDoors) return "WELDDOORS";
	return "STAY";
}
//--------------------------------------------------------------------------------------------------
simulated function Destroyed()
{
	local int i;

	if ( CurrentWeldBot!=None )
	{
		CurrentWeldBot.WeaponOwner = None;
		CurrentWeldBot.KilledBy(none);
		CurrentWeldBot = none;
	}
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}
	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[2] = None;
	}
	for (i=6;i<=48;i+=2)
		if (Fonts[i]!=none)
			Level.ObjectPool.FreeObject(Fonts[i]);
	Super.Destroyed();
}
//--------------------------------------------------------------------------------------------------
// Destroy this stuff when the level changes
simulated function PreTravelCleanUp()
{
	local int i;
	if ( CurrentWeldBot!=None )
	{
		CurrentWeldBot.WeaponOwner = None;
		CurrentWeldBot.KilledBy(none);
		CurrentWeldBot = none;
	}
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}
	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[2] = None;
	}
	for (i=6;i<=48;i+=2)
		if (Fonts[i]!=none)
			Level.ObjectPool.FreeObject(Fonts[i]);
	super.PreTravelCleanUp();
}
//--------------------------------------------------------------------------------------------------
/* // не понадобится уже наверно
simulated function float RateSelf()
{
	if ( bBeingDestroyed || bSentryDeployed )
		CurrentRating = -2.0;
	else
		CurrentRating = 50.0;
	return CurrentRating;
}
//--------------------------------------------------------------------------------------------------
simulated function bool HasAmmo()
{
	return !bSentryDeployed;
}
//--------------------------------------------------------------------------------------------------
function bool CanAttack(Actor Other)
{
	return  !bSentryDeployed;
}*/
//--------------------------------------------------------------------------------------------------
/* не понадобится уже наверно
simulated event RenderOverlays( Canvas Canvas )
{
	if( bSentryDeployed )
		return;
	else Super.RenderOverlays(Canvas);
}*/
//--------------------------------------------------------------------------------------------------
function bool BotFire(bool bFinished, optional name FiringMode)
{
	if ( bSentryDeployed )
		return false;
	ServerStartFire(0);
	return true;
}
//--------------------------------------------------------------------------------------------------
simulated function ClientReload();
exec function ReloadMeNow();
//simulated function AnimEnd(int Channel);
//function PlayIdle();
function ServerStopFire (byte Mode);
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

defaultproperties
{
	Description="Robot welder. Can weld armor and doors"
	ItemName="Welding bot"
	MagCapacity=1
	HudImage=Texture'chippoDT_A.ChippoDT_UnSelected'
	SelectedHudImage=Texture'chippoDT_A.ChippoDT_Selected'
	Weight=1.000000
	bModeZeroCanDryFire=True
	TraderInfoTexture=Texture'chippoDT_A.ChippoDT_trader'
	FireModeClass(0)=Class'KFMod.NoFire'
	FireModeClass(1)=Class'KFMod.NoFire'
	SelectForce="SwitchToAssaultRifle"
	AIRating=0.550000
	CurrentRating=0.550000
	bCanThrow=False
	Priority=10
	InventoryGroup=5
	GroupOffset=6
	PickupClass=Class'WeldBot.WeldBotGunPickup'
	AttachmentClass=Class'WeldBot.WeldBotGunAttachment'
	IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
	AmbientGlow=35
	BtnDelay=0.3
	
	Mesh=SkeletalMesh'chippoDT_A.chippo1stDTMesh'
	Skins(1)=Shader'chippoDT_A.RPR_SWR_NKD_DIFF_sh'
	Skins(0)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	SleeveNum=0
	PutDownAnim="PutDown"
	IdleAimAnim="Idle"
	SelectAnim="Select"
	FireAnim="Fire"
	FireAnimRate=1.00
	DisplayFOV=30.0
	PlayerViewOffset=(X=40.000000,Y=0,Z=-6.000000)
	BobDamping=4.5 //6.000000
	
	
	RCMesh=SkeletalMesh'chippoDT_A.PDUDTMesh'
	RCSkins(0) = Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	RCSkins(1) = Texture'chippoDT_A.PultDT'
	
	RCScreen = Texture'chippoDT_A.PultDisplay2DT_3';
	BackColor=(B=128,G=128,R=128,A=255);
	TextColor=(B=0,G=0,R=0,A=255);
	RCStringStay(0)="STAY"
	RCStringStay(1)="HERE"
	RCStringFollow(0)="FOLLOW"
	RCStringFollow(1)="ME"
	RCStringWeld(0)="HOLD"
	RCStringWeld(1)="DOORS"
/*	RCStringStay(0)="СТОЙ"
	RCStringStay(1)="ЗДЕСЬ"
	RCStringFollow(0)="ЗА"
	RCStringFollow(1)="МНОЙ"
	RCStringWeld(0)="ДЕРЖИ"
	RCStringWeld(1)="ДВЕРИ"*/
	
	LineOffset(0) = 0.49 //0.39
	LineOffset(1) = 0.75 //0.63

	FontName="ROArial"
	
	FontSizeState=36
	FontSizeHP=28
	
	MaxLineH=0.21 //0.4
	MaxLineW=0.7
	
	MaxHPLineH=0.16
	MaxHPLineW=0.36
	HPLineOffsetX=0.76
	HPLineOffsetY=0.225
	
	bNetNotify=true
}