Class WeldBotLangSetup extends Object	Abstract;var string RussianText;
var byte bChecked;var bool bChecked2;
// WeldBot
var localized string	DefaultBotName,
						OwnerText,
						MSG_ModeStay,
						MSG_ModeWeldDoors;
// WeldBotGun
var localized string	Description,
						ItemName;
var array<localized string> RCStringStay, RCStringFollow, RCStringWeld;
// WeldBotGunPickup
var localized string	//Description,
						//ItemName,
						ItemShortName,
						AmmoItemName,
						PickupMessage;
// WeldBotMenu
var localized string	ExitBtn,
						FollowHint,
						FollowBtn,
						StayHint,
						StayBtn,
						WeldHint,
						WeldBtn,
						DistanceHint,
						Distance,
						MenuCaption,
						BotNameLabel;
// WeldBotMessage
var array<localized string> Message;//--------------------------------------------------------------------------------------------------//--------------------------------------------------------------------------------------------------static final function bool IsRussia(){	if( Default.bChecked==0 )	{		if( Localize("Errors","Unknown","Core")~=Default.RussianText )			Default.bChecked = 2;		else Default.bChecked = 1;	}	return (Default.bChecked==2);}//--------------------------------------------------------------------------------------------------static final function InitRussia(){	if( !Default.bChecked2 )	{		Default.bChecked2 = true;		if( Localize("Errors","Unknown","Core")~=Default.RussianText )		{			Class'WeldBot'.Default.DefaultBotName	= Default.DefaultBotName;/*			Class'WeldBot'.Default.MSG_Follow		= Default.MSG_Follow;
			Class'WeldBot'.Default.MSG_Stay			= Default.MSG_Stay;
			Class'WeldBot'.Default.MSG_WeldDoors	= Default.MSG_WeldDoors;
			Class'WeldBot'.Default.MSG_NotOwner		= Default.MSG_NotOwner;
			Class'WeldBot'.Default.MSG_YouReNewOwner= Default.MSG_YouReNewOwner;*/
			Class'WeldBot'.Default.MSG_ModeStay		= Default.MSG_ModeStay;
			Class'WeldBot'.Default.MSG_ModeWeldDoors= Default.MSG_ModeWeldDoors;
			Class'WeldBot'.Default.OwnerText		= Default.OwnerText;
			Class'WeldBotGun'.Default.Description	= Default.Description;
			Class'WeldBotGun'.Default.ItemName		= Default.ItemName;
			Class'WeldBotGun'.Default.RCStringStay[0]	= Default.RCStringStay[0];
			Class'WeldBotGun'.Default.RCStringStay[1]	= Default.RCStringStay[1];
			Class'WeldBotGun'.Default.RCStringFollow[0]	= Default.RCStringFollow[0];
			Class'WeldBotGun'.Default.RCStringFollow[1]	= Default.RCStringFollow[1];
			Class'WeldBotGun'.Default.RCStringWeld[0]	= Default.RCStringWeld[0];
			Class'WeldBotGun'.Default.RCStringWeld[1]	= Default.RCStringWeld[1];
			Class'WeldBotGunPickup'.Default.Description		= Default.Description;
			Class'WeldBotGunPickup'.Default.ItemName		= Default.ItemName;
			Class'WeldBotGunPickup'.Default.ItemShortName	= Default.ItemShortName;
			Class'WeldBotGunPickup'.Default.AmmoItemName	= Default.AmmoItemName;
			Class'WeldBotGunPickup'.Default.PickupMessage	= Default.PickupMessage;
			Class'WeldBotMenu'.Default.bExit.Caption		= Default.ExitBtn;
			Class'WeldBotMenu'.Default.cFollowMe.Hint		= Default.FollowHint;
			Class'WeldBotMenu'.Default.bFollowMe.Hint		= Default.FollowHint;
			Class'WeldBotMenu'.Default.cStay.Hint			= Default.StayHint;
			Class'WeldBotMenu'.Default.bStay.Hint			= Default.StayHint;
			Class'WeldBotMenu'.Default.cWeldDoors.Hint		= Default.WeldHint;
			Class'WeldBotMenu'.Default.bWeldDoors.Hint		= Default.WeldHint;
			Class'WeldBotMenu'.Default.bFollowMe.Caption	= Default.FollowBtn;
			Class'WeldBotMenu'.Default.bStay.Caption		= Default.StayBtn;
			Class'WeldBotMenu'.Default.bWeldDoors.Caption	= Default.WeldBtn;
			Class'WeldBotMenu'.Default.sDistance.Hint		= Default.DistanceHint;
			Class'WeldBotMenu'.Default.lDist.Caption		= Default.Distance;
			Class'WeldBotMenu'.Default.Caption				= Default.MenuCaption;
			Class'WeldBotMenu'.Default.lBotName.Caption		= Default.BotNameLabel;
			Class'WeldBotMessage'.Default.Message[0]		= Default.Message[0];
			Class'WeldBotMessage'.Default.Message[1]		= Default.Message[1];
			Class'WeldBotMessage'.Default.Message[2]		= Default.Message[2];
			Class'WeldBotMessage'.Default.Message[3]		= Default.Message[3];
			Class'WeldBotMessage'.Default.Message[4]		= Default.Message[4];
			Class'WeldBotMessage'.Default.Message[5]		= Default.Message[5];
			Class'WeldBotMessage'.Default.Message[6]		= Default.Message[6];
			Class'WeldBotMessage'.Default.Message[7]		= Default.Message[7];		}	}}//--------------------------------------------------------------------------------------------------//--------------------------------------------------------------------------------------------------defaultproperties{	RussianText="Неизвестная ошибка"
	// WeldBot
	DefaultBotName="Сварочный бот"
	MSG_ModeStay="Стою"
	MSG_ModeWeldDoors="Держу двери"
	OwnerText="Хозяин"
	// WeldBotGun
	//Description="Бот сварщик"
	ItemName="Сварочный бот"
	// WeldBotGunPickup
	Description="Сварочный бот. Варит броню и двери."
	//ItemName="Бот сварщик"
	ItemShortName="Сварочный бот"
	AmmoItemName="Сварочный бот"
	PickupMessage="Вы получили сварочного бота"
	// WeldBotMenu
	ExitBtn="Выход"
	FollowHint="Бот будет следовать за вами"
	FollowBtn="За мной"
	StayHint="Бот будет стоять на месте"
	StayBtn="Стоять"
	WeldHint="Бот будет заваривать ближайшие двери"
	WeldBtn="Держи двери"
	DistanceHint="Максимальное расстояние на которое боту разрешено отходить"
	Distance="Дальность:"
	MenuCaption="Консоль управления ботом"
	BotNameLabel="Имя бота"
	// WeldBotMessage
	Message(0)="Здесь поставить не получится"
	Message(1)="Сварочный бот развернут"
	Message(2)="Сварочный бот разрушен"
	Message(3)="Следую за вами"
	Message(4)="Остаюсь здесь"
	Message(5)="Держу двери здесь"
	Message(6)="Вы не мой хозяин!"
	Message(7)="Вы мой новый хозяин!"

	RCStringStay(0)="СТОЙ"
	RCStringStay(1)="ЗДЕСЬ"
	RCStringFollow(0)="ЗА"
	RCStringFollow(1)="МНОЙ"
	RCStringWeld(0)="ДЕРЖИ"
	RCStringWeld(1)="ДВЕРИ"
}