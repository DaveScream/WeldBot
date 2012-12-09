//================================================================================
// KFARGChatIcon
//================================================================================
class WeldBotSetupIcon extends Actor;

function PostBeginPlay ()
{
	Texture = Texture'WeldBot.SetupIcon';
}

defaultproperties
{
     Texture=Texture'WeldBot.SetupIcon'
     DrawScale=0.500000
     Style=STY_Masked
}
