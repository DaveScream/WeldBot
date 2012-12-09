/*
 * This Actor need cause weldbot have usedby function it works only if player touch weldbot. 
 * So WeldBot must have good collision radius for use from far distance. But if collisionradius is
 * big. Bot navigation works bad. So need to make colradius 1. And for usedby use another actor with
 * big ColRadius. This is that actor. When WeldBot spawns, this actor spawns too, and attachtobone.
 *
 */
class WeldBotUseActor extends WeldBotHomeActor;

var WeldBot WeldBot;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	Texture = Texture'WeldBot.SetupIcon';
}
//--------------------------------------------------------------------------------------------------
simulated function UsedBy(Pawn user)
{
	if (WeldBot.bDebug) PlayerController(WeldBot.OwnerPawn.Controller).ClientMessage("WeldBotUseActor UsedBy`");
	WeldBot.UsedBy(user);
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	CollisionHeight = 20;
	CollisionRadius = 80;
	bCollideWorld = True;
	//DrawType=DT_None
	bHidden=false
	RemoteRole=ROLE_SimulatedProxy
	bMovable=True
	bCollideActors=true
	bAlwaysRelevant=true
	
	Texture=Texture'WeldBot.SetupIcon'
	Style=STY_Masked
}