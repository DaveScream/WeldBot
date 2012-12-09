//================================================================================
// WeldBotGunAttachment.
//================================================================================
class WeldBotGunAttachment extends PipeBombAttachment;

replication
{
	reliable if( Role==ROLE_Authority )
		bIsDeployed;
}

var() Mesh DeployedMesh;
var bool bIsDeployed,bClientDeployed;

simulated function PostNetReceive()
{
	Super.PostNetReceive();
	if( bClientDeployed!=bIsDeployed )
	{
		bClientDeployed = bIsDeployed;
		if( bIsDeployed )
			SetDeployed();
		else SetUndeployed();
	}
}
simulated final function SetDeployed()
{
	bIsDeployed = true;
	NetUpdateTime = Level.TimeSeconds-1.f;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		LinkMesh(DeployedMesh);
		//bHidden=false;
		// Change other attributes here if needed, such as relativerotation.
	}
}
simulated final function SetUndeployed()
{
	bIsDeployed = false;
	NetUpdateTime = Level.TimeSeconds-1.f;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		LinkMesh(Default.Mesh);
		//bHidden=false;
	}
}

defaultproperties
{
	Mesh=SkeletalMesh'chippoDT_A.chippoDTMesh3rd' // SENTRY BOT MODEL
	DeployedMesh=SkeletalMesh'chippoDT_A.PDUDTMesh3rd' // RC CONTROLLER MODEL
	bNetNotify=true
}