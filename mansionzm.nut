// Zombie Mod of Mansion  - 夜幕山庄生化幽灵模式
//(c) Dazai Nerau, 7/23/2018
// Map by JBrody
// 注意，不正确地修改可能导致工作异常

//变量表 - 修改时请注意变量类型

V_HUMAN_SPEED <- 1.0;						//人类的最大速度倍数
V_HUMAN_GRAVITY <- 1.0;						//人类的重力倍数
V_HUMAN_HEALTH <- 1000;						//人类的生命值
V_KNOCKBACK_OFFSET <- 6;					//击退补偿倍数
V_KNOCKBACK_ZAXIS_VELOCITY <- 100;			//Z轴击退速度
V_ROUNDSTART_CD <- 20;						//开局倒计时秒数
V_ZOMBIE_HEALTH_BASE <- 450;				//僵尸生命值基数
V_ZOMBIE_HEALTH_OFFSET <- 2000;				//僵尸生命值补偿
V_ZOMBIE_GRAVITY <- 0.85						//僵尸的重力倍数
V_ZOMBIE_SPEED <- 1.1						//僵尸的最大速度倍数
V_GIF_ZAXIS_OFFSET <- 40					//感染时动态贴图Z坐标补偿
V_LIGHTBALL_ZAXIS_OFFSET <- 100				//感染时光球贴图Z坐标补偿
V_ZOMBIE_REHAB_HEALTH_CD <-	30				//僵尸静止多久能回血一次（单位：百毫秒）
V_ZOMBIE_REHAB_HEALTH_AMT <- 200			//僵尸每次回血量
V_BGM_LENGTH <- 53							//背景音时间长度
V_BGM_RECYCLE_CD <- 54						//循环播放背景音间隔
V_BLINK_REQUIRE_HP <- 600					//触发僵尸闪烁的血量
V_BLINK_COLOR <- "255 0 0"					//僵尸闪烁时的颜色（R G B）

_debug <- true;

LOCALIZEDSTRINGS <- {
	PLAYER_GOT_INFECTED =["\x01 \x04有人被病毒感染了！", "\x01 \x04 Someone was infected by ghost!"],
	YOU_INFECTED_HUMAN =["你感染了—个人类佣兵！", "You infected a soldier!"],
	YOU_GOT_INFECTED_BY_GHOST =["你被感染了！", "You are infected!"],
	FIRST_INFECTOR_COUNTDOWN =["生化幽灵将在%d 秒后出现！", "Ghost will appear in %d second(s)!"],
	YOU_ARE_HOST =["你被选为了生化幽灵母体！", "You were chosen as the first ghost!"],
	GHOST_APPEARED =["生化幽灵出现了！", "Ghost appeared!"],
	GHOST_APPEARED_COLORED =["\x01 \x02 生化幽灵出现了！", "\x01 \x02 Ghost appeared!"],
	HUMAN_LEFT =["人类佣兵剩余%d人\n   %s", "%d Soldiers Left\n   %s"],
	GHOSTS_LEFT =["生化幽灵剩余%d只\n   %s", "%d Ghosts Left\n   %s"],
	OPEN_CAREPACKAGE =["你开启补给箱，后备子弹补满，并获得一些手雷", "Your bullet has been refilled, and got some grenades"],
	OPEN_WEAPONBOX =["你开启武器箱，得到了%s", "Message You got a(n) %s by opening the box"],
	HELP_INFO =["\x01 \x03 指令:\r\n\x01 \x04 !help -\x01 显示可用指令\r\n\x01 \x04 !creator -\x01 显示脚本制作者\r\n\x01 \x04 !lang -\x01 改变语言", "\x01 \x03 Commands: \r\n \x01 \x04 !help -\x01 Show list of commands \r\n \x01 \x04 !creator -\x01 Show creator of script \r\n\x01 \x04 !lang -\x01 Change language"],
	LANG_CMDS =["\x01 \x03Language Commands:\r\n\x01 \x04 !chn -\x01 将语言改成中文\r\n\x01 \x04 !eng -\x01 Change language to English", "\x01 \x03语言命令:\r\n\x01 \x04 !chn -\x01 将语言改成中文\r\n\x01 \x04 !eng -\x01 Change language to English"],
	HUMAN_DAMAGE_UP_VALVE =["人类攻击力提升 %d%%", "Attack Power of Human + %d%%"],
	GET_WEAPON_HERE =["获取武器!", "Get weapons here!"]
};

//说话事件监听
e_player_say <- null;

//预缓存资源
function Precache() {
	e_player_say = Entities.FindByName(null, "e_player_say");
	self.PrecacheModel("models/player/ctm_st6_varianta.mdl");
	self.PrecacheModel("models/player/ctm_st6_variantb.mdl");
	self.PrecacheModel("models/player/ctm_st6_variantc.mdl");
	self.PrecacheModel("models/player/ctm_st6_variantd.mdl");
	self.PrecacheModel("models/player/nanoghost/nanoghost.mdl");

	self.PrecacheScriptSound("zombie_infec1.wav");
	self.PrecacheScriptSound("zombie_infec2.wav");
	self.PrecacheScriptSound("zombie_infec3.wav");
	self.PrecacheScriptSound("GrandTerminatorDie.wav");

	self.PrecacheModel("models/weapons/v_knife_ghost.mdl");
	self.PrecacheModel("models/weapons/v_rif_royal.mdl");
	self.PrecacheModel("models/weapons/v_pist_remake.mdl");
	self.PrecacheModel("models/weapons/w_pist_remake.mdl");
	self.PrecacheModel("models/weapons/w_rif_royal.mdl");
	self.PrecacheModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");
}

//随机模型数组
model <-["models/player/ctm_st6_varianta.mdl", "models/player/ctm_st6_variantb.mdl", "models/player/ctm_st6_variantc.mdl", "models/player/ctm_st6_variantd.mdl"];
//随机感染音效
soundx <-["zombie_infec1.wav", "zombie_infec2.wav", "zombie_infec3.wav"];
//随机开箱武器
weapons <-[
	["weapon_bizon", "PP-19 Bizon"],//0
	["weapon_p90", "FN P90"],
	["weapon_galilar", "AK-47 Knife-Royal Guard"],
	["weapon_m249", "M249 SAW"],
	["weapon_negev", "IWI Negev"],
	["weapon_m249", "M249 SAW"],
	["weapon_negev", "IWI Negev"],
	["weapon_hegrenade", "HE Grenade"],
	["weapon_flashbang", "Flashbang"],
	["weapon_smokegrenade", "Smoke Grenade"],
	["weapon_molotov", "Molotov"]//10
];

//补给箱武器
weapons2 <-[
	["weapon_bizon", "PP-19 Bizon"],
	["weapon_p90", "FN P90"],
	["weapon_m249", "M249 SAW"],
	["weapon_negev", "IWI Negev"],//4
];

RoundStarted <- false;

function StartRound() {
	RoundStarted <- true;
}

function OnPlayerSpawn() {
	local player = activator;

	if (player.GetName() == "" || player.GetName() == null) {
		if (RoundStarted) {
			player.SetTeam(1);  //后进来的先观察者走一波
			return;
		} else if (player.GetTeam() == 1) {
			player.SetTeam(RandomInt(1, 2));
		}

		player.__KeyValueFromString("targetname", UniqueString());
	}

	if (player.ValidateScriptScope()) {
		local fields = player.GetScriptScope();

		if (!RoundStarted) {
			fields.ModeTeam <- 1; //模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
			fields.Speed <- 1; //速度
		}

		if ("PlayerName" in fields) {
			ScriptPrintMessageChatAll(fields.PlayerName);
		}

		fields.LastHurtTime <- 0; //最后一次被击中的时间
		fields.IsHost <- false; //是否宿主
		fields.LastMoveTime <- 0; //最后一次移动的时间

		player.SetMaxHealth(V_HUMAN_HEALTH);
		player.SetHealth(V_HUMAN_HEALTH);
	}

	EntFireByHandle(player, "AddOutput", format("gravity %d", V_HUMAN_GRAVITY), 0.00, player, player);
	EntFire("speeder", "ModifySpeed", V_HUMAN_SPEED.tostring(), 0.00, player);

	EntFireByHandle(player, "AddOutput", "rendermode 1", 0.1, player, player);
	EntFireByHandle(player, "	Color", "255 255 255", 0.1, player, player);

	EntFire("script", "runscriptcode", "StartRound()", 5.0);
}

function ShowMsg(player, resolvedString) {
	local _msg = Entities.CreateByClassname("env_message");
	_msg.__KeyValueFromString("message", resolvedString);
	_msg.SetOwner(player);

	EntFireByHandle(_msg, "showmessage", "", 0.0, player, player);
	EntFireByHandle(_msg, "kill", "", 2.0, player, player);
}

function ShowMsg_Localized(player, localizedstr) {
	local resolvedString = LOCALIZEDSTRINGS[localizedstr][language];
	ShowMsg(player, resolvedString);
}

function PrintToChat_Localized(localizedstr) {
	local resolvedString = LOCALIZEDSTRINGS[localizedstr][language];
	ScriptPrintMessageChatAll(resolvedString);
}

function ResolveString(localizedstr) {
	return LOCALIZEDSTRINGS[localizedstr][language];
}

// foreach player in players yeah
function ForEachPlayer(fun) {
	local player = null;

	while ((player = Entities.FindByClassname(player, "player")) != null) {
		fun(player);
	}
}

ENABLE_INFECT <- true;
//伤害后
function OnHurt(playername, attackername, weapon, damage) {
	local player = Entities.FindByName(null, playername);
	local attacker = Entities.FindByName(null, attackername);

	if (player == null) {
		return;
	}

	if (attacker == null) {
		attacker = player; //fucking bugs;
	}

	local playerScope = player.GetScriptScope();
	local attackerScope = attacker.GetScriptScope();

	if (playerScope.ModeTeam == attackerScope.ModeTeam) {
		player.SetHealth(player.GetHealth() + damage);

		return; //since the team attack won't cause infect.
	}

	//感染功能开关
	if (!ENABLE_INFECT)
		return;

	//感染功能
	if (attackerScope.ModeTeam == 2 && playerScope.ModeTeam == 1 && weapon == "knife") {
		PrintToChat_Localized("PLAYER_GOT_INFECTED");
		EntFire("mainst", "SetText", ResolveString("PLAYER_GOT_INFECTED"), 0.00);

		ShowMsg_Localized(attacker, "YOU_INFECTED_HUMAN");
		ShowMsg_Localized(player, "YOU_GOT_INFECTED_BY_GHOST");

		SetUserZombie(player);

		local gameScore = Entities.FindByName(null, "gamescore");
		EntFireByHandle(gameScore, "ApplyScore", "", 0, attacker, attacker);
		Addhr();
	}
	else if (attackerScope.ModeTeam == 1 && playerScope.ModeTeam == 2) {
		playerScope.LastHurtTime <- 0;
		Knockback(attacker, player, damage);

		if (humanrage > 0.0) {
			local offset = damage * humanrage * 0.1 * 2;
			local hurter = Entities.FindByName(null, "hurt" + shouhaizhe);
			hurter.SetOwner(player);
			EntFire("hurt" + shouhaizhe, "AddOutput", "damage " + offset);
			EntFire("hurt" + shouhaizhe, "enable", "", 0.01);
			EntFire("hurt" + shouhaizhe, "disable", "", 0.02);
		}

	}
}
//击退
function Knockback(attacker, player, damage) {
	local m_attackerOrigin = attacker.GetOrigin();
	local m_playerOrigin = player.GetOrigin();

	local Knockback = player.GetVelocity() + (m_attackerOrigin - m_playerOrigin);

	Knockback *= -1;

	local clamp = function (vec, max) {
		local m = vec.x;
		if (vec.y > m)
			m = vec.y;

		if (vec.z > max)
			m = vec.z;

		if (m < max)
			return vec;

		local scale = max / m;
		vec.x = max;
		vec.y *= scale;
		vec.z *= scale;

		return vec;
	}

	local knockBack_offset = damage * V_KNOCKBACK_OFFSET;
	Knockback.z = V_KNOCKBACK_ZAXIS_VELOCITY;

	clamp(Knockback, knockBack_offset);
	player.SetVelocity(Knockback);

}

function Spd() {
	ForEachPlayer(function (player) {
		if (player.GetName() == "")
			return;

		if (player.ValidateScriptScope()) {
			local playerScope = player.GetScriptScope();

			if (player.IsValid() && playerScope.ModeTeam == 2 && player.GetHealth() > 0 && playerScope.Speed < 1.1) {
				playerScope.Speed += 0.1;

				EntFire("speeder", "ModifySpeed", playerScope.Speed.tostring(), 0.00, player);
			}
		}
	});
}

//复活后
function Refresh() {
	local player = activator;
	local playerScope = player.GetScriptScope();

	if (playerScope.ModeTeam == 2) {
		SetUserZombie(player);
	} else if (playerScope.ModeTeam == 1) {
		player.SetHealth(player.GetMaxHealth());
	}
}

//检测新玩家
only <- 1;
function Refreshx() {
	/*
	if(oa == 0)
	{
		//local rounder = Entities.FindByClassname(null,"point_viewcontrol")
		//EntFireByHandle(rounder,"AddOutput","targetname hello",0,rounder,rounder);
		local starter = Entities.FindByName(null,"scope");
		local rounder = Entities.FindByClassnameNearest("point_viewcontrol", starter.GetOrigin(), 100.0); 
		EntFireByHandle(rounder,"AddOutput","targetname hello",0,rounder,rounder);
	}
	//注册新入玩家
	local hehehe = 0;
	for(local stx = 0; stx <= 9;stx +=1)
	{
		if(uid[stx][1] != null && uid[stx][1].IsValid() && uid[stx][1] == activator)
		{
			hehehe += 1;
			break;
		}
	}
	
	//重启回合
	if(hehehe == 0 && only == 1)
	{
		EntFire("ender","EndRound_Draw",7);
		if(language == 0)
			ScriptPrintMessageChatAll("\x01 \x04 检测到新玩家加入，本回合重新开始");
		else if(language == 1)
			ScriptPrintMessageChatAll("\x01 \x04 New player added, this round restarts");
		only = 0;
	}
	
	//设置玩家为观察者
	if(hehehe == 0 && only == 1)
	{
		activator.SetTeam(1);
	}
*///Maybe not needed.
}

g_roundstart <- 0;
//初始化玩家信息
function Round() {
	EntFire("rage_timer", "enable");

	g_roundstart = 1;

	EntFire("shuijifuhuo", "Command", "sv_cheats 1");
	EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);

	numPlayer <- 0;
	ForEachPlayer(function (player) {
		if (player.IsValid()) {
			EntFire("clcmd", "Command", "r_screenoverlay overlays/power0", 0.00, player);

			numPlayer++;
		}
	});

	if (numPlayer == 0)
		return;

	if ("needRestart" in getroottable()) {
		EntFire("s_timer", "enable");
	} else {
		EntFire("shuijifuhuo", "Command", "bot_kick");
		EntFire("shuijifuhuo", "Command", "bot_add", 0.5);
		EntFire("shuijifuhuo", "Command", "bot_add", 1.0);
		EntFire("shuijifuhuo", "Command", "mp_restartgame 1", 2.0);

		getroottable()["needRestart"] <- 0;
	}


}

//开局倒计时
hox <- 0;
function Countdown() {
	local subt = Entities.FindByName(null, "mainst");

	EntFireByHandle(subt, "SetText", format(ResolveString("FIRST_INFECTOR_COUNTDOWN"), V_ROUNDSTART_CD), 0, subt, subt);
	EntFireByHandle(subt, "Display", "", 0.1, subt, subt);

	V_ROUNDSTART_CD -= 1;

	local haxd = V_ROUNDSTART_CD + 1;
	if (hox == 0) {
		EntFire("op", "PlaySound");
		hox = 1;
		Circ();
	}

	local _equip = Entities.FindByName(null, "equiper");

	//读秒
	if (V_ROUNDSTART_CD >= 0 && V_ROUNDSTART_CD <= 9)
		EntFire("z" + haxd, "playsound");

	//产生第一只生化幽灵
	if (V_ROUNDSTART_CD < 0) {
		EntFire("rage_timer", "enable");

		EntFire("s_timer", "disable");

		GenerateZombie();

		EntFire("p_timer", "enable", 2);
		EntFire("range", "enable");

		if (oa >= 6) {
			GenerateZombie();
		}
	}

	if (haxd == 0) {
		PrintToChat_Localized("GHOST_APPEARED_COLORED");
		EntFireByHandle(subt, "SetText", ResolveString("GHOST_APPEARED"), 0, subt, subt);
		EntFireByHandle(subt, "Display", "", 0.1, subt, subt);

		//EntFire("araware","playsound");
	}
}

function GenerateZombie() {
	local players = [];
	local player = null;
	while ((player = Entities.FindByClassname(player, "player")) != null) {
		if (player.IsValid() && player.GetTeam() != 1) {
			players.push(player);
		}
	}

	local firstZombie;

	for (; ;) {
		firstZombie = players[RandomInt(0, players.len() - 1)];

		if (firstZombie.GetScriptScope().ModeTeam != 2) {
			break;
		}
	}

	SetUserZombie(firstZombie);
}

function CIEOP2(playername) {
	local player = Entities.FindByName(null, playername);
	
	if(player == null) 
		return;

	local infectRing, infectLight, infectModel;

	//while(infectRing == null || infectLight == null || infectModel == null) {
		infectRing = Entities.FindByName(null, "infectRing");
		infectLight = Entities.FindByName(null, "infectLight");
		infectModel = Entities.FindByName(null, "infectModel");
	//}

	local playerOrigin = player.GetOrigin();

	infectRing.__KeyValueFromString("targetname", UniqueString());
	infectLight.__KeyValueFromString("targetname", UniqueString());
	infectModel.__KeyValueFromString("targetname", UniqueString());

	infectRing.SetOrigin(playerOrigin);
	infectModel.SetOrigin(playerOrigin);
	infectLight.SetOrigin(playerOrigin);

	for (local i = -255; i < 255; i += 17 ) {
		local alfa = 255 - abs(i);
		local delay = 0.03 * ((256 + i) / 17);

		ScriptPrintMessageChatAll(alfa.tostring());
		ScriptPrintMessageChatAll(delay.tostring());

		EntFireByHandle(infectLight, "Alpha", alfa.tostring(), delay, player, player);
		EntFireByHandle(infectModel, "Alpha", alfa.tostring(), delay, player, player);
	}

	EntFireByHandle(infectRing, "kill", "", 2.5, player, player);
	EntFireByHandle(infectLight, "kill", "", 2.5, player, player);
	EntFireByHandle(infectModel, "kill", "", 2.5, player, player);
}

function CreateInfectEffectOnPlayer(player) {
	EntFire("fxgen" ,"ForceSpawn", "");

	EntFire("script","RunScriptCode", format("CIEOP2(\"%s\")", player.GetName()), 0.1);
}

//感染玩家
function SetUserZombie(zombie) {
	local _equip = Entities.FindByName(null, "equiper");

	local zombieScope = zombie.GetScriptScope();

	zombieScope.ModeTeam = 2;
	zombie.SetModel("models/player/nanoghost/nanoghost.mdl");

	zombie.SetMaxHealth(oaa * V_ZOMBIE_HEALTH_BASE + V_ZOMBIE_HEALTH_OFFSET);
	zombie.SetHealth(zombie.GetMaxHealth());

	//zombie.SetTeam(2);

	zombieScope.IsHost = true;

	ShowMsg_Localized(zombie, "YOU_ARE_HOST");

	EntFireByHandle(_equip, "TriggerForActivatedPlayer", "weapon_knife", 0, zombie, zombie);
	zombie.EmitSound(soundx[RandomInt(0, 2)]);

	CreateInfectEffectOnPlayer(zombie);

	EntFire("speeder", "ModifySpeed", "" + V_ZOMBIE_SPEED, 0.00, zombie);
	EntFireByHandle(zombie, "AddOutput", format("gravity %d", V_ZOMBIE_GRAVITY), 0.0, zombie, zombie);

	EntFire("shuijifuhuo", "Command", "sv_cheats 1");
	EntFire("clcmd", "Command", "r_screenoverlay overlays/zbeye", 0.01, zombie);
	EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);
}

//人数检测&胜利判断
bouei <- 1;
function Check() {
	local numPlayer = 0;
	local numSoilders = 0;
	local numGhosts = 0;
	local numDeadGhosts = 0;

	local player = null;
	while ((player = Entities.FindByClassname(player, "player")) != null) {
		if (player.IsValid()) {
			numPlayer++;
			local playerScope = player.GetScriptScope();

			if (playerScope.ModeTeam == 1) {
				numSoilders++;

				if (player.GetHealth() <= 0) {
					playerScope.ModeTeam <- 2;
				}
			} else if (playerScope.ModeTeam == 2) {
				numGhosts++;

				if (player.GetHealth() <= 0) {
					numDeadGhosts++;
				}
			}
		}
	}

	if (numGhosts == 0 || numGhosts == numDeadGhosts && bouei == 1) {
		EntFire("ender", "EndRound_CounterTerroristsWin", 8);
		EntFire("humanwin", "playsound");
		bouei = 0;

		if (false)
			PrintToChat_Localized("SOLDIER_WIN");

		EntFire("shuijifuhuo", "Command", "sv_cheats 1", 0);
		EntFire("shuijifuhuo", "Command", "sv_cheats 1", 6.4);

		ForEachPlayer(function (player) {
			EntFire("clcmd", "Command", "r_screenoverlay overlays/soldierwin", 0.1, player);
			EntFire("clcmd", "Command", "r_screenoverlay ....", 6.5, player);
		});

		EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);
		EntFire("shuijifuhuo", "Command", "sv_cheats 0", 6.6);

	} else if (numSoilders == 0 && bouei == 1) {
		EntFire("ender", "EndRound_TerroristsWin", 8);
		EntFire("zombiewin", "playsound");
		bouei = 0;

		EntFire("shuijifuhuo", "Command", "sv_cheats 1", 0);
		EntFire("shuijifuhuo", "Command", "sv_cheats 1", 6.4);

		ForEachPlayer(function (player) {
			EntFire("clcmd", "Command", "r_screenoverlay overlays/ghostwin", 0.1, player);
			EntFire("clcmd", "Command", "r_screenoverlay ....", 6.5, player);
		});

		EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);
		EntFire("shuijifuhuo", "Command", "sv_cheats 0", 6.6);
	}
}

oa <- 0;
oaa <- 0;

//实时检测双方玩家人数
function Score() {
	local alivect = 0;		//剩余存活人类佣兵
	local deadct = 0;		//剩余死亡人类佣兵
	local alivezb = 0;		//剩余存活生化幽灵
	local deadzb = 0;		//剩余死亡生化幽灵

	local player = null;
	while ((player = Entities.FindByClassname(player, "player")) != null) {
		if (player.GetName() == "")
			continue;

		local playerScope = player.GetScriptScope();

		if (playerScope.ModeTeam == 1) {
			if (player.GetHealth() > 0) {
				alivect++;
			} else {
				deadct++;
			}

		} else if (playerScope.ModeTeam == 2) {
			if (player.GetHealth() > 0) {
				alivezb++;
			} else {
				deadzb++;
			}
		}
	}

	//人类佣兵人数UI
	local text1 = Entities.FindByName(null, "ctscore");
	local ctrenshu = "";

	for (local number = alivect; number > 0; number--)
	ctrenshu = ctrenshu + "■ ";
	for (local number = deadct; number > 0; number--)
	ctrenshu = ctrenshu + "□ ";

	local xxx = alivect + deadct;
	local textneirongct = "";
	local textneirongt = "";

	textneirongct = format(ResolveString("HUMAN_LEFT"), xxx, ctrenshu);

	EntFireByHandle(text1, "SetText", textneirongct, 0, text1, text1);
	EntFireByHandle(text1, "Display", "", 0.1, text1, text1);

	//生化幽灵人数UI
	local text2 = Entities.FindByName(null, "tscore");
	local trenshu = "";

	for (local number = alivezb; number > 0; number--)
	trenshu = trenshu + "■ ";
	for (local number = deadzb; number > 0; number--)
	trenshu = trenshu + "□ ";

	local aaa = alivezb + deadzb;

	textneirongt = format(ResolveString("GHOSTS_LEFT"), aaa, trenshu);

	EntFireByHandle(text2, "SetText", "" + textneirongt, 0, text2, text2);
	EntFireByHandle(text2, "Display", "", 0.1, text2, text2);
	oa = alivect + alivezb + deadct + deadzb;
	oaa = alivect + deadct;
}

//回合超时，人类佣兵胜利
function Hwin() {
	EntFire("ender", "EndRound_CounterTerroristsWin", 8);
	EntFire("humanwin", "playsound");

	EntFire("shuijifuhuo", "Command", "sv_cheats 1", 0);
	EntFire("shuijifuhuo", "Command", "sv_cheats 1", 6.4);

	ForEachPlayer(function (player) {
		EntFire("clcmd", "Command", "r_screenoverlay overlays/soldierwin", 0.1, player);
		EntFire("clcmd", "Command", "r_screenoverlay ....", 6.5, player);
	});

	EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);
	EntFire("shuijifuhuo", "Command", "sv_cheats 0", 6.6);

	//EntFire("ed1","playsound",0.8);
}

function Fthink() {
	local worldmodel = null;
	while ((worldmodel = Entities.FindByClassname(worldmodel, "weaponworldmodel")) != null) {
		if (worldmodel.GetModelName() == "models/weapons/ZombiEden/xrole/w_elucidator.mdl") {
			continue;
		}

		local player = worldmodel.GetMoveParent();
		local playerScope = player.GetScriptScope();

		if (playerScope != null && player.GetName() != "") {
			if (playerScope.ModeTeam == 2) {
				worldmodel.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");
			}
		}
	}

	local viewmodel = null;
	while ((viewmodel = Entities.FindByClassname(viewmodel, "predicted_viewmodel")) != null) {
		if (viewmodel.GetModelName() == "models/weapons/v_knife_ghost.mdl") {
			continue;
		}

		local player = viewmodel.GetMoveParent();
		local playerScope = player.GetScriptScope();

		if (playerScope != null && player.GetName() != "") {
			if (playerScope.ModeTeam == 2) {
				viewmodel.SetModel("models/weapons/v_knife_ghost.mdl");
			}
		}
	}
}

//开武器箱
function OpenBox() {
	local player = activator;
	local playerScope = player.GetScriptScope();

	if (playerScope.ModeTeam != 2) {
		local stringx = "";

		if (caller.GetName().find("10") != null || caller.GetName().find("11") != null || caller.GetName().find("12") != null) {
			stringx = caller.GetName().slice(0, 5);
		} else {
			stringx = caller.GetName().slice(0, 4);
		}

		EntFire("" + stringx, "kill");
		EntFire("" + caller.GetName(), "kill", "");
		EntFire("" + stringx + "brush", "kill");

		local _eq = Entities.FindByName(null, "equiper2");

		local nunu = RandomInt(0, 6); //看你是欧洲人还是非洲人
		EntFireByHandle(_eq, "TriggerForActivatedPlayer", weapons[nunu][0], 0, activator, activator);

		ShowMsg(player, format(ResolveString("OPEN_WEAPONBOX"), weapons[nunu][1]));
	}
}

//开补给箱
function OpenBoxA() {
	local player = activator;
	local playerScope = player.GetScriptScope();

	if (playerScope.ModeTeam != 2) {
		local stringx = "";
		stringx = caller.GetName().slice(0, 5);

		EntFire(stringx, "kill");
		EntFire(caller.GetName(), "kill");
		EntFire(stringx + "brush", "kill");

		EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_hegrenade", 0, player, player);
		EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_flashbang", 0, player, player);
		EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_smokegrenade", 0, player, player);
		EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_molotov", 0, player, player);

		local amg = Entities.FindByName(null, "ammo_giver");
		EntFireByHandle(amg, "GiveAmmo", "", 0, player, player);

		ShowMsg_Localized(player, "OPEN_CAREPACKAGE");
	}
}

//第一次补给箱随机坐标
locone <-
	[
		Vector(1083.05, -313.32, -1755), Vector(1268.71, -957.637, -1862.55),
		Vector(44.9298, 546.643, -1768.55), Vector(490.625, 105.339, -1768.55),
		Vector(984.039, -696.038, -1678.55)
	];


loconed <-
	[
		Vector(1083.05, -313.32, -1707), Vector(1268.71, -957.637, -1814.55),
		Vector(44.9298, 546.643, -1720.55), Vector(490.625, 105.339, -1720.55),
		Vector(984.039, -696.038, -1630.55)
	];
//第二次补给箱随机坐标
loctwo <-
	[
		Vector(1316.97, -495.154, -1654.55), Vector(772.461, -75.1684, -1731.55),
		Vector(523.448, -499.567, -1731.55), Vector(1069.67, -1728.94, -1786.55),
		Vector(1306.7, -1362.49, -1826.55)
	];

loctwoh <-
	[
		Vector(1316.97, -495.154, -1606.55), Vector(772.461, -75.1684, -1683.55),
		Vector(523.448, -499.567, -1683.55), Vector(1069.67, -1728.94, -1738.55),
		Vector(1306.7, -1362.49, -1778.55)
	];

//第一次空投补给箱
function Airdrop() {
	local rn = RandomInt(0, 4);
	local adb1 = Entities.FindByName(null, "abox1");
	local adb1bt = Entities.FindByName(null, "abox1bt");
	local abcde = Entities.FindByName(null, "abox1brush");
	EntFire("abox1", "SetGlowEnabled");
	adb1.SetOrigin(locone[rn]);
	adb1bt.SetOrigin(locone[rn]);
	abcde.SetOrigin(loconed[rn]);
	EntFire("boxarrive", "playsound");
	if (language == 0) {
		ScriptPrintMessageChatAll("\x01 \x04 空投补给箱已到达！");
		EntFire("mainst", "SetText", "空投补给箱已到达！", 0);
		EntFire("mainst", "Display", "", 0.1);
	}
	else if (language == 1) {
		ScriptPrintMessageChatAll("\x01 \x04 Airdrop supply box has arrived!");
		EntFire("mainst", "SetText", "Airdrop supply box has arrived!", 0);
		EntFire("mainst", "Display", "", 0.1);
	}
}

//第二次空投补给箱
function Airdrops() {
	local rn = RandomInt(0, 4);
	local adb1 = Entities.FindByName(null, "abox2");
	local adb1bt = Entities.FindByName(null, "abox2bt");
	local abcde = Entities.FindByName(null, "abox2brush");
	EntFire("abox2", "SetGlowEnabled");
	adb1.SetOrigin(loctwo[rn]);
	adb1bt.SetOrigin(loctwo[rn]);
	abcde.SetOrigin(loctwoh[rn]);
	EntFire("boxarrive", "playsound");
	if (language == 0) {
		ScriptPrintMessageChatAll("\x01 \x04 空投补给箱已到达！");
		EntFire("mainst", "SetText", "空投补给箱已到达！", 0);
		EntFire("mainst", "Display", "", 0.1);
	}
	else if (language == 1) {
		ScriptPrintMessageChatAll("\x01 \x04 Airdrop supply box has arrived!");
		EntFire("mainst", "SetText", "Airdrop supply box has arrived!", 0);
		EntFire("mainst", "Display", "", 0.1);
	}
}

function min(x, y) {
	return (x > y) ? y : x;
}

//真·回血
function Readx() {
	ForEachPlayer(function (player) {
		if (!player.ValidateScriptScope())
			return;

		local playerScope = player.GetScriptScope();
		if (player.GetVelocity() == Vector(0, 0, 0)) {
			playerScope.LastMoveTime++;

			if (playerScope.LastMoveTime >= V_ZOMBIE_REHAB_HEALTH_CD) {
				player.SetHealth(min(player.GetMaxHealth(), player.GetHealth() + V_ZOMBIE_REHAB_HEALTH_AMT));

				player.EmitSound("nanoghostbreath5.wav");
			}
		} else {
			playerScope.LastMoveTime <- 0;
		}
	});
}
//语言控制器
language <- 0;

//语言配置检测
function Lg() {
	if ("language" in getroottable()) {
		language = getroottable().language;
	} else {
		getroottable().language <- 0;
	}

	for (local st = 1; st <= 12; st++)
	{
		EntFire("mmdf" + st, "SetMaterialVar", "" + language, 0.1);
	}

	for (local st = 1; st <= 2; st++)
	{
		EntFire("abox" + st + "mdf", "SetMaterialVar", "" + language, 0.1);
	}

	EntFire("eih0", "AddOutput", format("hint_caption %s", ResolveString("GET_WEAPON_HERE")));
	EntFire("eih0", "showhint");
}

function Welcome() {
	ScriptPrintMessageChatAll("Type '!help' to see available commands,");
	ScriptPrintMessageChatAll("type '!lang' to change language.");
	ScriptPrintMessageChatAll(" 	");
	ScriptPrintMessageChatAll("输入'!help'查看可用指令,输入'!lang'改变语言");
}

//说话菜单
function player_say() {
	local txt = e_player_say.GetScriptScope().event_data.text;

	switch (txt.tolower()) {
		case "!creator":
			ScriptPrintMessageChatAll("\x01 Creator of script: \x01 \x03 Dazai Nerau");
			ScriptPrintMessageChatAll("\x01 \x04http://steamcommunity.com/id/utagawashii/");
			printl("http://steamcommunity.com/id/utagawashii/");
			break;
		case "!help":
			PrintToChat_Localized("HELP_INFO");
			break;
		case "!lang":
			PrintToChat_Localized("LANG_CMDS");
			break;
		case "!chn":
			ScriptPrintMessageChatAll("\x01 \x04 语言已被设定为中文");

			getroottable().language <- 0;
			Lg();
			break;
		case "!eng":
			ScriptPrintMessageChatAll("\x01 \x04 Language has been set to English");

			getroottable().language <- 1;
			Lg();
			break;
	}
}

//循环播放背景音
function Circ() {
	EntFire("op", "playsound", "", V_BGM_LENGTH);
	EntFire("script", "runscriptcode", "Circ()", V_BGM_RECYCLE_CD);
}

color <- false;
//闪烁效果
function Blink() {
	color = !color;

	local player = null;
	while ((player = Entities.FindByClassname(player, "player")) != null) {
		if (player.GetName() == "")
			continue;

		local playerScope = player.GetScriptScope();
		if (playerScope.ModeTeam == 2) {
			EntFireByHandle(player, "AddOutput", "rendermode 1", 0.1, player, player);
			if (player.GetHealth() >= V_BLINK_REQUIRE_HP) {
				EntFireByHandle(player, "Color", "255 255 255", 0.1, player, player);
			} else {
				EntFireByHandle(player, "Color", color ? V_BLINK_COLOR : "255 255 255", 0.1, player, player);
			}
		}
	}
}

MODEL_REPLACE_LIST <-[
	["models/weapons/v_rif_galilar.mdl", "models/weapons/v_rif_royal.mdl"],
	["models/weapons/v_pist_deagle.mdl", "models/weapons/v_pist_remake.mdl"],
	["models/weapons/w_pist_deagle.mdl", "models/weapons/w_pist_remake.mdl"],
	["models/weapons/w_rif_galilar.mdl", "models/weapons/w_rif_royal.mdl"]
]

function banana() {
	foreach(item in MODEL_REPLACE_LIST) {
		local model = null;
		while ((model = Entities.FindByModel(model, item[0])) != null) {
			model.SetModel(item[1]);
		}
	}
}

//死亡后
function Dea(playername, attackername) {
	local player = Entities.FindByName(null, playername);
	local attacker = Entities.FindByName(null, attackername);

	if (player == null) {
		return;
	}

	if (attacker == null) {
		attacker = player; //fucking bugs;
	}

	if (player.ValidateScriptScope()) {
		local playerScope = player.GetScriptScope();
		local attackerScope = attacker.GetScriptScope();

		if (playerScope.ModeTeam == 2) {
			player.EmitSound("GrandTerminatorDie.wav");

			if (attackerScope.ModeTeam == 1) {
				Addhr();
			}
		}
	}
}

humanrage <- 0;
cancan <- 1;

//人类怒气倍数
function Addhr() {
	humanrage = min(10, humanrage + 1);
	cancan = humanrage == 10 ? 0 : 1;
	EntFire("shuijifuhuo", "Command", "sv_cheats 1", 0);
	EntFire("shuijifuhuo", "Command", "sv_cheats 0", 0.2);

	ForEachPlayer(function (player) {
		if (player.GetName() != "")
			if (player.GetScriptScope().ModeTeam == 1)
				EntFire("clcmd", "Command", format("r_screenoverlay overlays/power%d", humanrage), 0.1, player);
	});
}

function Ragetext() {
	local color;

	switch (humanrage) {
		case 1:
		case 2:
			color = "70 192 210";
			break;
		case 3:
		case 4:
			color = "228 220 90";
			break;
		case 5:
		case 6:
			color = "228 220 90";
			break;
		case 7:
		case 8:
			color = "229 164 91";
			break;
		case 9:
		case 10:
			color = "209 91 91";
			break;
		default:
			color = "255 255 255";
			break;
	}

	local str = format(ResolveString("HUMAN_DAMAGE_UP_VALVE"), humanrage * 10);
	EntFire("rage", "addoutput", format("color %s", color));
	EntFire("rage", "addoutput", "message " + str);
	EntFire("rage", "display", 0.1);
}

kaiguan <- 1;

function KaiGuan() {
	kaiguan = 0;
}

LastInfectPlayer <- null;

function PostSpawn( entities )
{
	foreach( name, handle in entities )
	{
		if(LastInfectPlayer != null) {
			handle.SetOrigin(LastInfectPlayer.GetOrigin());
		}

		if(handle.GetClassname() != "prop_dynamic") {
			EntFireByHandle(handle, "showsprite", "", 0.00, handle, handle);
		}
		
		for (local i = -255; i < 255; i += 17 ) {
			local alfa = 255 - abs(i);
			local delay = 0.03 * ((256 + i) / 17);

			if(handle.GetName().find("Ring") == null)
				EntFireByHandle(handle, "Alpha", alfa.tostring(), delay, handle, handle);
		}

		EntFireByHandle(handle, "kill", "", 5, handle, handle);
	}
}