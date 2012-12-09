class WeldBotMenu extends LargeWindow/*GUIPage*/
	dependson(WeldBot);

var automated GUIButton bFollowMe, bStay, bWeldDoors, bExit;
var automated GUICheckBoxButton cFollowMe, cWeldDoors, cStay;
var automated GUISlider		sDistance;
var automated GUILabel		lDist, lBotName;
var automated GUIEditBox	eBotName;
var localized string Caption;

var WeldBot.EState selectedState;
var WeldBotReplicationInfo RepInfo;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function SetupStateBtns(WeldBot.EState State)
{
	if (State==Follow)
	{
		cFollowMe.bChecked=true;
		bFollowMe.DisableMe();
		bStay.EnableMe();
		bWeldDoors.EnableMe();
		cStay.bChecked=false;
		cWeldDoors.bChecked=false;
	}
	else if (State==Stay)
	{
		cStay.bChecked=true;
		bStay.DisableMe();
		bFollowMe.EnableMe();
		bWeldDoors.EnableMe();
		cFollowMe.bChecked=false;
		cWeldDoors.bChecked=false;
	}
	else if (State==WeldDoors)
	{
		cWeldDoors.bChecked=true;
		bWeldDoors.DisableMe();
		bFollowMe.EnableMe();
		bStay.EnableMe();
		cFollowMe.bChecked=false;
		cStay.bChecked=false;
	}
}
//--------------------------------------------------------------------------------------------------
event HandleParameters(string Param1, string Param2)
{
	foreach PlayerOwner().DynamicActors(class'WeldBotReplicationInfo',RepInfo)
	{
		if (RepInfo.OwnerPC == PlayerOwner())
		{
			selectedState	= RepInfo.BotState;
			SetupStateBtns(selectedState);
			sDistance.SetValue(RepInfo.Distance);
			break;
		}
	}
	if (RepInfo == none)
	{
		PlayerOwner().ClientMessage("Error: Cant find WeldBot.RepInfo, so exit GUI");
		PlayerOwner().ClientCloseMenu(true, false); //CloseAll(false,true);
	}
}
//--------------------------------------------------------------------------------------------------
function OnOpen()
{
	t_WindowTitle.SetCaption(Caption);
	Super.OnOpen();
}
//--------------------------------------------------------------------------------------------------
function OnClose(optional Bool bCancelled)
{
	// Отправляем новые настройки через консоль mutate (а мутатор WeldBotMut должен их поймать)
	RepInfo.SetParams(selectedState, sDistance.value, eBotName.TextStr);
	//PlayerOwner().ConsoleCommand("mutate WeldBot"@StateToString(selectedState)@sDistance.Value,false);
	Super.OnClose(bCancelled);
}
//--------------------------------------------------------------------------------------------------
function bool InternalOnClick(GUIComponent Sender)
{
	local PlayerController PC;
	PC = PlayerOwner();
	
	switch (GUIButton(Sender))
	{
		case bFollowMe:
			selectedState=Follow;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bStay:
			selectedState=Stay;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bWeldDoors:
			selectedState=WeldDoors;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bExit:
			PC.ClientCloseMenu(True,False); //CloseAll(false,true);
			break;
	}
    return false;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	Begin Object Class=GUIButton Name=obExit
      Caption="Exit"
      OnClick=InternalOnClick
      TabOrder=1
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.938479
		WinHeight=0.250866
		WinLeft=0.031564
		WinTop=0.702259
	End Object
	bExit=obExit
	
	// Чекбокс "За мой"
	Begin Object Class=GUICheckBoxButton Name=ocFollowMe
      Hint="Bot will follow you"
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.081720
		WinHeight=0.140587
		WinLeft=0.139200
		WinTop=0.110756
	bAcceptsInput=false
	bCaptureMouse=false
	bNeverFocus=true
	bTabStop=false
	bMouseOverSound=false
	End Object
	cFollowMe=ocFollowMe

	// Чекбокс "Стоять"
	Begin Object Class=GUICheckBoxButton Name=ocStay
      Hint="Bot will stay"
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.081720
		WinHeight=0.140587
		WinLeft=0.466965
		WinTop=0.110756
	bAcceptsInput=false
	bCaptureMouse=false
	bNeverFocus=true
	bTabStop=false
	bMouseOverSound=false
	End Object
	cStay=ocStay
	
	// Чекбокс "Держи двери"
	Begin Object Class=GUICheckBoxButton Name=ocWeldDoors
      Hint="Bot will weld near doors"
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.081720
		WinHeight=0.140587
		WinLeft=0.776964
		WinTop=0.110756
	bAcceptsInput=false
	bCaptureMouse=false
	bNeverFocus=true
	bTabStop=false
	bMouseOverSound=false
	End Object
	cWeldDoors=ocWeldDoors
	
	// Кнопка "За мой"
	Begin Object Class=GUIButton Name=obFollowMe
      Caption="Follow me"
      Hint="Bot will follow you"
      OnClick=InternalOnClick
      TabOrder=2
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.300000
		WinHeight=0.289493
		WinLeft=0.031200
		WinTop=0.262151
	End Object
	bFollowMe=obFollowMe
	
	// Кнопка "Стоять"
	Begin Object Class=GUIButton Name=obStay
      Caption="Stay here"
      Hint="Bot will stay"
      OnClick=InternalOnClick
      TabOrder=3
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.300000
		WinHeight=0.289493
		WinLeft=0.352068
		WinTop=0.262151
	End Object
	bStay=obStay
	
	// Кнопка "Держи двери"
	Begin Object Class=GUIButton Name=obWeldDoors
      Caption="Hold doors"
      Hint="Bot will weld near doors"
      OnClick=InternalOnClick
      TabOrder=4
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.300000
		WinHeight=0.289493
		WinLeft=0.672068
		WinTop=0.262151
	End Object
	bWeldDoors=obWeldDoors

	// Слайдер дальности
	Begin Object Class=GUISlider Name=osDistance
      Hint="Maximum bot distance"
	  bIntSlider=false
	  MinValue=50000.00
	  MaxValue=600000.00
      TabOrder=5
      bBoundToParent=true
      bScaleToParent=true
		WinWidth=0.660323
		WinHeight=0.118925
		WinLeft=0.294765
		WinTop=0.570598
	End Object	
	sDistance=osDistance
	
	// Метка "Дальность"
	Begin Object Class=GUILabel Name=lDistance
		TextColor=(R=255,G=255,B=255,A=255)
		//Caption="Макс.радиус"
		Caption="Range:"//"Дальность:"
		VertAlign=TXTA_Center
		bAcceptsInput=false
		bCaptureMouse=false
		bNeverFocus=true
		bTabStop=false
		bMouseOverSound=false
		bBoundToParent=true
		bScaleToParent=true
		WinWidth=0.230324
		WinHeight=0.118925
		WinLeft=0.054765
		WinTop=0.570598
	End Object
	lDist=lDistance
	
	// Метка "Имя бота"
	Begin Object Class=GUILabel Name=lBname
		TextColor=(R=255,G=255,B=255,A=255)
		Caption="Bot name:"
		VertAlign=TXTA_Center
		bAcceptsInput=false
		bCaptureMouse=false
		bNeverFocus=true
		bTabStop=false
		bMouseOverSound=false
		bBoundToParent=true
		bScaleToParent=true
		WinWidth=0.230324
		WinHeight=0.118925
		WinLeft=0.054765
		WinTop=0.570598
	End Object
	lBotName=lBName
	
	Begin Object Class=GUIEditBox Name=clEditBox
		bAcceptsInput=true
		bCaptureMouse=true
		bNeverFocus=false
		bTabStop=true
		bMouseOverSound=false
		bBoundToParent=true
		bScaleToParent=true
		WinWidth=0.230324
		WinHeight=0.118925
		WinLeft=0.054765
		WinTop=0.570598
	End Object
	eBotName = clEditBox

	Caption="Bot control console"
	bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=True
    DefaultLeft=0.110313
    DefaultTop=0.057916
    DefaultWidth=0.779688
    DefaultHeight=0.847083
    bRequire640x480=False
    WinTop=0.057916
    WinLeft=0.110313
    WinWidth=500
    WinHeight=250
	bAllowedAsLast=True // If this is true, closing this page will not bring up the main menu if last on the stack.	
    bPersistent=False // If set in defprops, page is kept in memory across open/close/reopen
	bRestorable=False // When the GUIController receives a call to CloseAll(), should it reopen this page the next time main is opened?
}