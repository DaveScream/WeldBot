//================================================================================// WeldBotGunPickup.//================================================================================class WeldBotGunPickup extends KFWeaponPickup;simulated function PostBeginPlay (){  Super.PostBeginPlay();  TweenAnim('Idle',1.0); //TweenAnim('Folded',0.01);}defaultproperties{
	Description="Robot welder. Can weld armor and doors"
	ItemName="Welding bot"
	ItemShortName="Welding bot"
	AmmoItemName="Welding bot"
	PickupMessage="You got welding bot."	Weight=1.000000
	CorrespondingPerkIndex=1	cost=7800	AmmoCost=0	BuyClipSize=1	SpeedValue=20	RangeValue=50	showMesh=SkeletalMesh'chippoDT_A.chippoDTMesh3rd' //showMesh=SkeletalMesh'MedSentrybot_turret.SentryMesh'	EquipmentCategoryID=3	InventoryType=Class'WeldBot.WeldBotGun'	PickupSound=Sound'KF_AA12Snd.AA12_Pickup'	PickupForce="AssaultRiflePickup"	DrawType=DT_Mesh
	Mesh=SkeletalMesh'chippoDT_A.chippo1stDTMesh' //SkeletalMesh'MedSentrybot_turret.SentryMesh'	CollisionRadius=22.000000	CollisionHeight=23.000000}