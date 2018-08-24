// Zombie Mod of Mansion  - 夜幕山庄生化幽灵模式
//(c) Dazai Nerau, 7/23/2018
// Map by JBrody
// 注意，不正确地修改可能导致工作异常

//变量表 - 修改时请注意变量类型

V_HUMAN_SPEED <- 1.0;						//人类的最大速度倍数
V_HUMAN_GRAVITY <- 1.0;						//人类的重力倍数
V_HUMAN_HEALTH <- 1000;						//人类的生命值
V_KNOCKBACK_OFFSET <- 6;					//击退补偿倍数
V_KNOCKBACK_ZAXIS_VELOCITY <- 5			//Z轴击退速度
V_ROUNDSTART_CD <- 20;						//开局倒计时秒数
V_ZOMBIE_HEALTH_BASE <- 450;				//僵尸生命值基数
V_ZOMBIE_HEALTH_OFFSET <- 1900;				//僵尸生命值补偿
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

//显示HUD消息util(不可用)
function ShowMsg(player, message)
{
	if(_msg == null)	
		_msg <- Entities.CreateByClassname("env_message");	
	_msg.__KeyValueFromString("message", message);
	_msg.SetOwner(player);
	EntFireByHandle(_msg, "showmessage", "", 0, player, player);
}

//说话事件监听
e_player_say <- null;

//预缓存资源
function Precache()
{
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
	
	//self.PrecacheScriptSound("zombie_pain_1.wav");
	//self.PrecacheScriptSound("zombie_pain_2.wav");
	self.PrecacheModel("models/weapons/v_knife_ghost.mdl");
	//self.PrecacheModel("models/weapons/w_knife_push_dropped.mdl");
	self.PrecacheModel("models/weapons/v_rif_royal.mdl");
	self.PrecacheModel("models/weapons/v_pist_remake.mdl");
	self.PrecacheModel("models/weapons/w_pist_remake.mdl");
	self.PrecacheModel("models/weapons/w_rif_royal.mdl");
	self.PrecacheModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");





}

//随机模型数组
model <- ["models/player/ctm_st6_varianta.mdl","models/player/ctm_st6_variantb.mdl","models/player/ctm_st6_variantc.mdl","models/player/ctm_st6_variantd.mdl"]; 
//随机感染音效
soundx <- ["zombie_infec1.wav","zombie_infec2.wav","zombie_infec3.wav"];
//随机开箱武器
weapons <- [
["weapon_bizon","PP-19 Bizon"],//0
["weapon_p90","FN P90"],
["weapon_galilar","AK-47 Knife-Royal Guard"],
["weapon_m249","M249 SAW"],
["weapon_negev","IWI Negev"],
["weapon_m249","M249 SAW"],
["weapon_negev","IWI Negev"],
["weapon_hegrenade","HE Grenade"],
["weapon_flashbang","Flashbang"],
["weapon_smokegrenade","Smoke Grenade"],
["weapon_molotov","Molotov"]//10
];

//补给箱武器
weapons2 <- [
["weapon_bizon","PP-19 Bizon"],
["weapon_p90","FN P90"],
["weapon_m249","M249 SAW"],
["weapon_negev","IWI Negev"],//4
];

//玩家信息数组
uid <-
[
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//0
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//1
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//2
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//3
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//4
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//5
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//6
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//7
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//8
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//9
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//10
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//11
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//12
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//13
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//14
[null,null,null,null,0,"|none|","|none|","|none|",0,0],		//15
];

//注册玩家信息
function SetId0()
{

	uid[0][1] = activator;				//句柄
	uid[0][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[0][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[0][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 0");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId1()
{

	uid[1][1] = activator;				//句柄
	uid[1][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[1][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[1][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 1");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId2()
{

	uid[2][1] = activator;				//句柄
	uid[2][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[2][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[2][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 2");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId3()
{

	uid[3][1] = activator;				//句柄
	uid[3][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[3][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[3][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 3");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId4()
{

	uid[4][1] = activator;				//句柄
	uid[4][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[4][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[4][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 4");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId5()
{

	uid[5][1] = activator;				//句柄
	uid[5][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[5][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[5][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 5");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	local mmm = RandomInt(0,3);
	activator.SetModel(model[mmm]);
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId6()
{

	uid[6][1] = activator;				//句柄
	uid[6][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[6][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[6][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 6");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	local mmm = RandomInt(0,3);
	activator.SetModel(model[mmm]);
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId7()
{

	uid[7][1] = activator;				//句柄
	uid[7][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[7][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[7][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 7");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	local mmm = RandomInt(0,3);
	activator.SetModel(model[mmm]);
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId8()
{

	uid[8][1] = activator;				//句柄
	uid[8][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[8][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[8][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 8");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	local mmm = RandomInt(0,3);
	activator.SetModel(model[mmm]);
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

function SetId9()
{
	uid[9][1] = activator;				//句柄
	uid[9][2] = 1;						//模式队伍 1 = 人类佣兵 | 2 = 生化幽灵
	if (activator.GetTeam() == 3)
		uid[9][3] = 3;					//实际队伍 2 = T | 3 = CT
	if (activator.GetTeam() == 2)
		uid[9][3] = 2;
	//ScriptPrintMessageChatAll("初始化信息成功 玩家 9");
	activator.SetMaxHealth(V_HUMAN_HEALTH);
	activator.SetHealth(activator.GetMaxHealth());
	local mmm = RandomInt(0,3);
	activator.SetModel(model[mmm]);
	EntFireByHandle(activator,"AddOutput","gravity " + V_HUMAN_GRAVITY,0.0,activator,activator);
	EntFire( "speeder", "ModifySpeed", "" + V_HUMAN_SPEED, 0.00, activator);
	EntFireByHandle(activator, "AddOutput", "rendermode 1", 0.1, activator, activator);
	EntFireByHandle(activator, "Color", "255 255 255", 0.1, activator, activator);
}

//lisswitcher
kaiguan <- 1;
//伤害后
function Lis(vic,atk,wpn,dmg)
{
	//防止友军伤害
	//ScriptPrintMessageChatAll("" + vic + atk + wpn);
	local shouhaizhe = 0;
	local gongjizhe = 0;
	for (local st = 0; st <= 9 ; st ++)
	{
		if(uid[st][1] == null || !(uid[st][1].IsValid()))
			continue;
		if (uid[st][1].GetName() == vic.tostring())
		{
			shouhaizhe = st;
			break;
		}
	}
	for (local st2 = 0; st2 <= 9 ; st2 ++)
	{
		if(uid[st2][1] == null || !(uid[st2][1].IsValid()))
			continue;
		if (uid[st2][1].GetName() == atk.tostring())
		{
			gongjizhe = st2;
			break;
		}
	}
	if(uid[shouhaizhe][2] == uid[gongjizhe][2])
		uid[shouhaizhe][1].SetHealth(uid[shouhaizhe][1].GetHealth() + dmg);
	
	//感染功能开关
	if(kaiguan == 0)
		return;
	
	//感染功能
	if(uid[gongjizhe][2] == 2 && uid[shouhaizhe][2] == 1 && wpn == 1)
	{
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x04有人被病毒感染了！");
			EntFire("mainst","SetText","有人被感染了！", 0);
			EntFire("mainst","Display","", 0.1);
			DoEntFire("txt" + gongjizhe,"AddOutput","message 你感染了—个人类佣兵！",0.0,uid[gongjizhe][1],uid[gongjizhe][1]);
			DoEntFire("txt" + shouhaizhe,"AddOutput","message 你被感染了！",0.0,uid[shouhaizhe][1],uid[shouhaizhe][1]);
			DoEntFire("txt" + gongjizhe,"showmessage","",0.2,uid[gongjizhe][1],uid[gongjizhe][1]);
			DoEntFire("txt" + shouhaizhe,"showmessage","",0.2,uid[shouhaizhe][1],uid[shouhaizhe][1]);
			//EntFire("eih1","AddOutput","hint_caption  有人被病毒感染了！");
			//EntFire("eih1","showhint");
		}
		else if (language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x04 Someone was infected by ghost!");
			EntFire("mainst","SetText","Someone was infected by ghost!", 0);
			EntFire("mainst","Display","", 0.1);
			DoEntFire("txt" + gongjizhe,"AddOutput","message You infected a soldier!",0.0,uid[gongjizhe][1],uid[gongjizhe][1]);
			DoEntFire("txt" + shouhaizhe,"AddOutput","message You are infected!",0.0,uid[shouhaizhe][1],uid[shouhaizhe][1]);
			DoEntFire("txt" + gongjizhe,"showmessage","",0.2,uid[gongjizhe][1],uid[gongjizhe][1]);
			DoEntFire("txt" + shouhaizhe,"showmessage","",0.2,uid[shouhaizhe][1],uid[shouhaizhe][1]);
			//EntFire("eih1","AddOutput","hint_caption  Someone was infected by ghost!");
			//EntFire("eih1","showhint");
		}
		SetUserZombie(shouhaizhe);
		local sss = Entities.FindByName(null,"gamescore");
		EntFireByHandle(sss,"ApplyScore","",0,uid[gongjizhe][1],uid[gongjizhe][1]);
		//EntFire("ips" + shouhaizhe,"start");
		//EntFire("ips" + shouhaizhe,"stop","",1);
		Addhr();
	}
	else if(uid[gongjizhe][2] == 1 && uid[shouhaizhe][2] == 2)
	{
		uid[shouhaizhe][9] = 0;
		Knockback(gongjizhe,shouhaizhe,dmg);
		if(humanrage > 0.0)
		{
			local offset = dmg * humanrage * 0.1 * 2;
			local hurter = Entities.FindByName(null,"hurt" + shouhaizhe);
			hurter.SetOwner(uid[gongjizhe][1]);
			EntFire("hurt" + shouhaizhe,"AddOutput","damage " + offset);
			EntFire("hurt" + shouhaizhe,"enable","",0.01);
			EntFire("hurt" + shouhaizhe,"disable","",0.02);
		}

	}
	//僵尸被击中后减速
	//else if(uid[gongjizhe][2] == 1 && uid[shouhaizhe][2] == 2)
	//{
	//	EntFire( "speeder", "ModifySpeed", ""+0.5, 0.00, uid[shouhaizhe][1]);
	//	uid[shouhaizhe][4] = 0.5;
	//	//Knockback(gongjizhe,shouhaizhe,dmg);
	//
	//}
	/*
	//受伤害音效
	else if(uid[gongjizhe][2] == 1 && uid[shouhaizhe][2] == 2)
	{
		local rate = RandomInt(0,5);
		if(rate == 5)
		{
			local proba = RandomInt(1,2);
			uid[shouhaizhe][1].EmitSound("zombie_pain_" + proba + ".wav");
		}
	}
	*/

}
//击退
function Knockback(atk,vic,dmg)
{

	local attacker = uid[atk][1];
	local player = uid[vic][1];
	local damage = dmg;

	local m_attackerOrigin = attacker.GetOrigin();
    local m_playerOrigin = player.GetOrigin();

    local m_dir = m_attackerOrigin - m_playerOrigin;

	local UCSX = sqrt(pow(m_dir.x,2)+pow(m_dir.y,2));
    local pitch = asin(m_dir.z / sqrt( pow(UCSX,2) + pow(m_dir.z,2) )); //* 180 / PI * -1;
    local yaw = asin(m_dir.y / sqrt( pow(m_dir.x,2) + pow(m_dir.y,2) ));// * 180 / PI;

    if(m_dir.x < 0)
        yaw = 1 - yaw;

	local knockBack_offset = damage * V_KNOCKBACK_OFFSET;

	local x = knockBack_offset * cos(yaw * PI) * -1;
	local y = knockBack_offset * sin(yaw * PI);
	local z = V_KNOCKBACK_ZAXIS_VELOCITY ;

	local Knockback = Vector(x,y,z);

	player.SetVelocity(Knockback);
}

function Spd()
{
	for(local st = 0; st <= 9 ; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2 && uid[st][1].GetHealth() > 0 && uid[st][4] < 1.1)
		{
			uid[st][4] += 0.1;
			EntFire( "speeder", "ModifySpeed", ""+ uid[st][4], 0.00, uid[st][1]);
		}
	}
}
//复活后
function Refresh()
{
	for(local stx = 0; stx <= 9 ; stx += 1)
	{
		//如果是生化幽灵
		if (uid[stx][1] != null && uid[stx][1].IsValid() && uid[stx][1] == activator && uid[stx][2] == 2)
		{
			SetUserZombie(stx);
		}
		//如果是人类佣兵
		if (uid[stx][1] != null && uid[stx][1].IsValid() && uid[stx][1] == activator && uid[stx][2] == 1)
		{
			uid[stx][1].SetHealth(uid[stx][1].GetMaxHealth());
		}
	}
}
//检测新玩家
only <- 1;
function Refreshx()
{
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
	//if(hehehe == 0 && only == 1)
	//{
	//	activator.SetTeam(1);
	//}

}
g_roundstart <- 0;
//初始化玩家信息
function Round()
{
	EntFire("shuijifuhuo","Command","sv_cheats 1",0);
	EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
	EntFire("rage_timer","enable");
	for(local st = 0;st <= 9; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid())
		{
			EntFire("clcmd","Command","r_screenoverlay overlays/power0",0.1,uid[st][1]);
		}
	}
	g_roundstart = 1;
	//local rounder = Entities.FindByClassname(null,"point_viewcontrol")
	local starter = Entities.FindByName(null,"scope");
	local rounder = Entities.FindByClassnameNearest("point_viewcontrol", starter.GetOrigin(), 100.0); 

	local defen = 0;
	for(local stx = 0; stx <= 9 ; stx += 1)
	{
		if (uid[stx][1] != null && uid[stx][1].IsValid())
		{
			defen += 1;
		}
	}
	if(defen == 0)
		return;
	if(rounder.GetName() == "hello")
	{
		EntFireByHandle(rounder,"AddOutput","targetname hoho",0,rounder,rounder);
		/*
		EntFire("shuijifuhuo","Command","bot_kick");
		EntFire("shuijifuhuo","Command","bot_add",0.1);
		EntFire("shuijifuhuo","Command","bot_add",0.7);
		EntFire("shuijifuhuo","Command","bot_add",1.4);
		EntFire("shuijifuhuo","Command","bot_add",2.0);
		EntFire("shuijifuhuo","Command","bot_add",2.8);
		EntFire("shuijifuhuo","Command","bot_add",3.6);
		EntFire("shuijifuhuo","Command","bot_add",4.2);
		EntFire("shuijifuhuo","Command","bot_add",5.0);
		EntFire("shuijifuhuo","Command","bot_add",6.0);
		EntFire("shuijifuhuo","Command","bot_add",6.55);
		*/
		EntFire("shuijifuhuo","Command","bot_kick");
		EntFire("shuijifuhuo","Command","bot_add",0.5);
		EntFire("shuijifuhuo","Command","bot_add",1.0);
		EntFire("shuijifuhuo","Command","mp_restartgame 1",2.0);
		EntFire("script","RunScriptCode","Tip()",1.0);
	}
	else
	{
		EntFire("s_timer","enable");
	}
}

function Tip()
{
	if(language == 0)
		ScriptPrintMessageChatAll("\x01 \x04初始化玩家信息，请稍候...");
	else if (language == 1)
		ScriptPrintMessageChatAll("\x01 \x04 Initializing players' info, please wait...");
}

//开局倒计时
hox <- 0;
function Countdown()
{
	local subt = Entities.FindByName(null,"mainst");
	if(language == 0)
	{
		//ScriptPrintMessageChatAll("生化幽灵将在\x01 \x04 " + V_ROUNDSTART_CD + "秒 \x01后出现！");
		EntFireByHandle(subt,"SetText","生化幽灵将在 " + V_ROUNDSTART_CD + " 秒后出现！", 0, subt,subt);
		EntFireByHandle(subt,"Display","", 0.1, subt,subt);
	}
	else if (language == 1)
	{
		//ScriptPrintMessageChatAll("Ghost will appear in\x01 \x04 " + V_ROUNDSTART_CD + " second(s)!");
		EntFireByHandle(subt,"SetText","Ghost will appear in " + V_ROUNDSTART_CD + " second(s)!", 0, subt,subt);
		EntFireByHandle(subt,"Display","", 0.1, subt,subt);
	}
	V_ROUNDSTART_CD -= 1;
	local haxd = V_ROUNDSTART_CD + 1;
	if(hox == 0)
	{
		EntFire("op","PlaySound");
		hox = 1;
		Circ();
	}
	local _equip = Entities.FindByName(null, "equiper");
	
	//读秒
	if(V_ROUNDSTART_CD >= 0 && V_ROUNDSTART_CD <= 9)
		EntFire("z" + haxd,"playsound");
	//产生第一只生化幽灵
	if(V_ROUNDSTART_CD < 0)
	{

		EntFire("rage_timer","enable");

		EntFire("s_timer","disable");
		local zb = 0;
		for (zb = RandomInt(0,9); (uid[zb][1] == null) || !(uid[zb][1].IsValid()) ; zb = RandomInt(0,9))
		{
			zb = zb + 0;
		}
		//local zb = RandomInt(0,9);//BUG
		uid[zb][2] = 2;
		uid[zb][1].SetModel("models/player/nanoghost/nanoghost.mdl");
		uid[zb][1].SetMaxHealth((oaa * V_ZOMBIE_HEALTH_BASE) + V_ZOMBIE_HEALTH_OFFSET);
		uid[zb][1].SetHealth(uid[zb][1].GetMaxHealth());
		uid[zb][8] = 1;
		if(language == 0)
		{
			DoEntFire("txt" + zb,"AddOutput","message 你被选为了生化幽灵母体！",0.0,uid[zb][1],uid[zb][1]);
			DoEntFire("txt" + zb,"showmessage","",0.2,uid[zb][1],uid[zb][1]);
		}
		else if (language == 1)
		{
			DoEntFire("txt" + zb,"AddOutput","message You were chosen as the first ghost!",0.0,uid[zb][1],uid[zb][1]);
			DoEntFire("txt" + zb,"showmessage","",0.2,uid[zb][1],uid[zb][1]);
		}
		local act = uid[zb][1];
		EntFireByHandle(_equip, "TriggerForActivatedPlayer", "weapon_knife", 0, act, act);
		EntFire("p_timer","enable",2);
		EntFire("range","enable");
		uid[zb][1].EmitSound("zombie_infec1.wav");
		//EntFire("ips" + zb,"start");
		//EntFire("ips" + zb,"stop","",1);
		EntFire("spr" + zb,"showsprite","",0.3);
		EntFire("sprx" + zb,"alpha","0",0.2);
		EntFire("sprx" + zb,"showsprite","",0.3);
		EntFire("sprx" + zb,"hidesprite","",1.2);
		Setalpha(zb);
		EntFire( "speeder", "ModifySpeed", "" + V_ZOMBIE_SPEED, 0.00, uid[zb][1]);
		EntFireByHandle(uid[zb][1],"AddOutput","gravity " + V_ZOMBIE_GRAVITY,0.0,uid[zb][1],uid[zb][1]);
		EntFire("script","RunScriptCode","Setclaw()",0.5);
		EntFire("script","RunScriptCode","Setclaw()",0.6);
		EntFire("script","RunScriptCode","Setclaw()",0.7);
		EntFire("shuijifuhuo","Command","sv_cheats 1");
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		EntFire("clcmd","Command","r_screenoverlay overlays/zbeye",0.01,uid[zb][1]);
		uid[zb][4] = 1.1;


		if(oa >= 6)
		{
			SecondZb();
		}

	}
	if(haxd == 0)
	{
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x02生化幽灵出现了！");
			EntFireByHandle(subt,"SetText","生化幽灵出现了！", 0, subt,subt);
			EntFireByHandle(subt,"Display","", 0.1, subt,subt);
		}
		else if (language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x02 Ghost appeared!");
			EntFireByHandle(subt,"SetText","Ghost appeared!", 0, subt,subt);
			EntFireByHandle(subt,"Display","", 0.1, subt,subt);
		}
		//EntFire("araware","playsound");
	}
}

function SecondZb()
{
	local zb = 0;
	for (zb = RandomInt(0,9); (uid[zb][1] == null) || !(uid[zb][1].IsValid()) || (uid[zb][2] == 2) ; zb = RandomInt(0,9))
	{
		zb = zb + 0;
	}
	uid[zb][2] = 2;
	uid[zb][1].SetModel("models/player/nanoghost/nanoghost.mdl");
	uid[zb][1].SetMaxHealth((oaa * V_ZOMBIE_HEALTH_BASE) + V_ZOMBIE_HEALTH_OFFSET);
	uid[zb][1].SetHealth(uid[zb][1].GetMaxHealth());
	uid[zb][8] = 1;
	if(language == 0)
	{
		DoEntFire("txt" + zb,"AddOutput","message 你被选为了生化幽灵母体！",0.0,uid[zb][1],uid[zb][1]);
		DoEntFire("txt" + zb,"showmessage","",0.2,uid[zb][1],uid[zb][1]);
	}
	else if (language == 1)
	{
		DoEntFire("txt" + zb,"AddOutput","message You were chosen as the first ghost!",0.0,uid[zb][1],uid[zb][1]);
		DoEntFire("txt" + zb,"showmessage","",0.2,uid[zb][1],uid[zb][1]);
	}
	local act = uid[zb][1];
	EntFireByHandle(_equip, "TriggerForActivatedPlayer", "weapon_knife", 0, act, act);
	uid[zb][1].EmitSound("zombie_infec1.wav");
	//EntFire("ips" + zb,"start");
	//EntFire("ips" + zb,"stop","",1);
	EntFire("spr" + zb,"showsprite","",0.3);
	EntFire("sprx" + zb,"alpha","0",0.2);
	EntFire("sprx" + zb,"showsprite","",0.3);
	EntFire("sprx" + zb,"hidesprite","",1.2);
	Setalpha(zb);
	EntFire( "speeder", "ModifySpeed", "" + V_ZOMBIE_SPEED, 0.00, uid[zb][1]);
	EntFireByHandle(uid[zb][1],"AddOutput","gravity " + V_ZOMBIE_GRAVITY,0.0,uid[zb][1],uid[zb][1]);
	EntFire("script","RunScriptCode","Setclaw()",0.5);
	EntFire("script","RunScriptCode","Setclaw()",0.6);
	EntFire("script","RunScriptCode","Setclaw()",0.7);
	EntFire("shuijifuhuo","Command","sv_cheats 1");
	EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
	EntFire("clcmd","Command","r_screenoverlay overlays/zbeye",0.01,uid[zb][1]);
	uid[zb][4] = 1.1;

}

//感染玩家
function SetUserZombie(id)
{
	local _equip = Entities.FindByName(null, "equiper");
	uid[id][2] = 2;
	uid[id][1].SetModel("models/player/nanoghost/nanoghost.mdl");
	uid[id][1].SetMaxHealth((oaa * V_ZOMBIE_HEALTH_BASE) + V_ZOMBIE_HEALTH_OFFSET);
	uid[id][1].SetHealth(uid[id][1].GetMaxHealth());
	local act = uid[id][1];
	EntFireByHandle(_equip, "TriggerForActivatedPlayer", "weapon_knife", 0, act, act);
	local rn = RandomInt(0,2);
	uid[id][1].EmitSound(soundx[rn]);
	//EntFire("ips" + id,"start","",0.5);
	//EntFire("ips" + id,"stop","",1.5);
	EntFire("spr" + id,"showsprite","",0.3);
	EntFire("sprx" + id,"alpha","0",0.2);
	EntFire("sprx" + id,"showsprite","",0.3);
	EntFire("sprx" + id,"hidesprite","",1.2);
	Setalpha(id);
	EntFireByHandle(uid[id][1],"AddOutput","gravity " + V_ZOMBIE_GRAVITY,0.0,uid[id][1],uid[id][1]);
	EntFire( "speeder", "ModifySpeed", "" + V_ZOMBIE_SPEED, 0.00, uid[id][1]);
	EntFire("script","RunScriptCode","Setclaw()",0.5);
	EntFire("script","RunScriptCode","Setclaw()",0.6);
	EntFire("script","RunScriptCode","Setclaw()",0.7);
	uid[id][4] = 1.1;
	if(uid[id][8] == 1)
	{
		uid[id][1].SetMaxHealth((oaa * V_ZOMBIE_HEALTH_BASE) + V_ZOMBIE_HEALTH_OFFSET);
		uid[id][1].SetHealth(uid[id][1].GetMaxHealth());
		uid[id][8] = 0;
	}
	
	EntFire("shuijifuhuo","Command","sv_cheats 1");
	EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
	EntFire("clcmd","Command","r_screenoverlay overlays/zbeye",0.01,uid[id][1]);
	
}

//人数检测&胜利判断
bouei <- 1;
function Check()
{
	local aa = 0; 
	local bb = 0;
	local cc = 0;
	local dd = 0;

	for(local st = 0; st <= 9 ; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid())
		{
			aa += 1;
		}
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 1)
		{
			bb += 1;
		}
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2)
		{
			cc += 1;
		}
	}
	if(bb == 0 && bouei == 1)
	{
		EntFire("ender","EndRound_TerroristsWin",8);
		EntFire("zombiewin","playsound");
		bouei = 0;
		//EntFire("ed2","playsound",0.8);
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x02回合结束，生化幽灵胜利！");
			EntFire("eih1","AddOutput","hint_caption  生化幽灵胜利！");
			EntFire("eih1","showhint");
		}
		else if(language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x02 Round ended, GHOST WIN!");
			EntFire("eih1","AddOutput","hint_caption  GHOST WIN!");
			EntFire("eih1","showhint");
		}
		
		EntFire("shuijifuhuo","Command","sv_cheats 1",0);
		EntFire("shuijifuhuo","Command","sv_cheats 1",6.4);
		for(local st = 0;st <= 9; st ++)
		{
			if(uid[st][1] != null && uid[st][1].IsValid())
			{
				EntFire("clcmd","Command","r_screenoverlay overlays/ghostwin",0.1,uid[st][1]);
				EntFire("clcmd","Command","r_screenoverlay ....",6.5,uid[st][1]);
			}
		}
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		EntFire("shuijifuhuo","Command","sv_cheats 0",6.6);

	}
	if(cc == 0 && bouei == 1)
	{
		EntFire("ender","EndRound_CounterTerroristsWin",8);
		EntFire("humanwin","playsound");
		bouei == 0;
		//EntFire("ed1","playsound",0.8);
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x0b回合结束，人类佣兵胜利！");
			EntFire("eih1","AddOutput","hint_caption  人类佣兵胜利！");
			EntFire("eih1","showhint");
		}

		else if(language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x0bRound ended, SOLDIER WIN!");
			EntFire("eih1","AddOutput","hint_caption  SOLDIER WIN");
			EntFire("eih1","showhint");
		}
		EntFire("shuijifuhuo","Command","sv_cheats 1",0);
		EntFire("shuijifuhuo","Command","sv_cheats 1",6.4);
		for(local st = 0;st <= 9; st ++)
		{
			if(uid[st][1] != null && uid[st][1].IsValid())
			{
				EntFire("clcmd","Command","r_screenoverlay overlays/soldierwin",0.1,uid[st][1]);
				EntFire("clcmd","Command","r_screenoverlay ....",6.5,uid[st][1]);
			}
		}
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		EntFire("shuijifuhuo","Command","sv_cheats 0",6.6);
	}
	for(local st = 0; st <= 9; st ++)
	{
		if(uid[st][1] == null || !(uid[st][1].IsValid()))
			continue;
		if(uid[st][2] == 2 && uid[st][1].GetHealth() <= 0)
		{
			dd += 1;
		}
		if(uid[st][2] == 1 && uid[st][1].GetHealth() == 0)
		{
			uid[st][2] = 2;
		}
	}
	if(cc == dd && bouei == 1)
	{
		EntFire("ender","EndRound_CounterTerroristsWin",8);
		EntFire("humanwin","playsound");
		bouei = 0;
		//EntFire("ed1","playsound",0.8);
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x0b回合结束，人类佣兵胜利！");
			EntFire("eih1","AddOutput","hint_caption  人类佣兵胜利！");
			EntFire("eih1","showhint");
		}

		else if(language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x0bRound ended, SOLDIER WIN!");
			EntFire("eih1","AddOutput","hint_caption  SOLDIER WIN!");
			EntFire("eih1","showhint");
		}
		EntFire("shuijifuhuo","Command","sv_cheats 1",0);
		EntFire("shuijifuhuo","Command","sv_cheats 1",6.4);
		for(local st = 0;st <= 9; st ++)
		{
			if(uid[st][1] != null && uid[st][1].IsValid())
			{
				EntFire("clcmd","Command","r_screenoverlay overlays/soldierwin",0.1,uid[st][1]);
				EntFire("clcmd","Command","r_screenoverlay ....",6.5,uid[st][1]);
			}
		}
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		EntFire("shuijifuhuo","Command","sv_cheats 0",6.6);
	}
}
oa <- 0;
oaa <- 0;

//实时检测双方玩家人数
function Score()
{
	local alivect = 0;		//剩余存活人类佣兵
	local deadct = 0;		//剩余死亡人类佣兵
	local alivezb = 0;		//剩余存活生化幽灵
	local deadzb = 0;		//剩余死亡生化幽灵
	for(local st = 0; st <= 9; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 1 && uid[st][1].GetHealth() > 0)
			alivect += 1;
		else if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 1 && uid[st][1].GetHealth() == 0)
			deadct += 1;
		else if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2 && uid[st][1].GetHealth() > 0)
			alivezb += 1;
		else if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2 && uid[st][1].GetHealth() == 0)
			deadzb += 1;
	}
	//人类佣兵人数UI
	local text1 = Entities.FindByName(null,"ctscore");
	local ctrenshu = "";
	for (local number = alivect ; number > 0; number --)
		ctrenshu = ctrenshu + "●";
	for (local number = deadct ; number > 0; number --)
		ctrenshu = ctrenshu + "○";
	local xxx = alivect + deadct;
	local textneirongct = "";
	local textneirongt = "";
	if(language == 0)
		textneirongct = "人类佣兵剩余" + xxx  + "人\n   " + ctrenshu;
	else if(language == 1)
		textneirongct = "" + xxx  + " Soldiers Left\n   " + ctrenshu;
	EntFireByHandle(text1,"SetText","" + textneirongct, 0, text1,text1);
	EntFireByHandle(text1,"Display","", 0.1, text1,text1);
	//生化幽灵人数UI
	local text2 = Entities.FindByName(null,"tscore");
	local trenshu = "";
	for (local number = alivezb ; number > 0; number --)
		trenshu = trenshu + "●";
	for (local number = deadzb ; number > 0; number --)
		trenshu = trenshu + "○";
	
	local aaa = alivezb + deadzb;
	if(language == 0)
		textneirongt = "生化幽灵剩余" + aaa + "只\n   " + trenshu;
	else if (language == 1)
		textneirongt = "" + aaa + " Ghosts Left\n   " + trenshu;
	EntFireByHandle(text2,"SetText","" + textneirongt, 0, text2,text2);
	EntFireByHandle(text2,"Display","", 0.1, text2,text2);
	oa = alivect + alivezb + deadct + deadzb;
	oaa = alivect + deadct;
}

//回合超时，人类佣兵胜利
function Hwin()
{
	if(language == 0)
	{
		ScriptPrintMessageChatAll("\x01 \x0b回合结束，人类佣兵胜利！");
		EntFire("eih1","AddOutput","hint_caption  人类佣兵胜利！");
		EntFire("eih1","showhint");
	}
	else if(language == 1)
	{
		ScriptPrintMessageChatAll("\x01 \x0bRound ended, SOLDIER WIN!");
		EntFire("eih1","AddOutput","hint_caption  SOLDIER WIN!");
		EntFire("eih1","showhint");
	}
	EntFire("ender","EndRound_CounterTerroristsWin",8);
	EntFire("humanwin","playsound");
	EntFire("shuijifuhuo","Command","sv_cheats 1",0);
	EntFire("shuijifuhuo","Command","sv_cheats 1",6.4);
	for(local st = 0;st <= 9; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid())
		{
			EntFire("clcmd","Command","r_screenoverlay overlays/soldierwin",0.1,uid[st][1]);
			EntFire("clcmd","Command","r_screenoverlay ....",6.5,uid[st][1]);
		}
	}
	EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
	EntFire("shuijifuhuo","Command","sv_cheats 0",6.6);
	//EntFire("ed1","playsound",0.8);
}
//玩家定位（用于放置感染粒子）
function Fthink()
{
	for (local st = 0; st <= 9; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid())
		{
			local ips = Entities.FindByName(null,"ips" + st);
			ips.SetOrigin(uid[st][1].GetOrigin());
			local spr = Entities.FindByName(null,"spr" + st);
			spr.SetOrigin(Vector(uid[st][1].GetOrigin().x,uid[st][1].GetOrigin().y,uid[st][1].GetOrigin().z + V_GIF_ZAXIS_OFFSET));
			local sprx = Entities.FindByName(null,"sprx" + st);
			sprx.SetOrigin(Vector(uid[st][1].GetOrigin().x,uid[st][1].GetOrigin().y,uid[st][1].GetOrigin().z + V_LIGHTBALL_ZAXIS_OFFSET));
			if(g_roundstart == 1)
			{
				local gz = Entities.FindByName(null,"gz" + st);
				gz.SetOrigin(Vector(uid[st][1].GetOrigin().x,uid[st][1].GetOrigin().y,uid[st][1].GetOrigin().z));
			}
			if(g_roundstart == 1)
			{
				local gz = Entities.FindByName(null,"hurt" + st);
				gz.SetOrigin(Vector(uid[st][1].GetOrigin().x,uid[st][1].GetOrigin().y,uid[st][1].GetOrigin().z));
			}
		}
	}
	local knife = null;
	//删除w刀模

	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_default_t.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_default_ct.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_bayonet.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_batterfly.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_falchion_advanced.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_flip.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_gg.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_gut.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");
	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_karam.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_m9_bay.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_push.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_survival_bowie.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/w_knife_tactical.mdl"))
	{
		knife.SetModel("models/weapons/ZombiEden/xrole/w_elucidator.mdl");

	}

}
//修改刀模
function Setclaw()
{

	local knife = null;
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_default_t.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_default_ct.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_karam.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_m9_bay.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}	
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_tactical.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_butterfly.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_gut.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_bayonet.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_flip.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_falchion_advanced.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_gg.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_survival_bowie.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}
	while(knife = Entities.FindByModel(knife, "models/weapons/v_knife_push.mdl"))
	{
		knife.SetModel("models/weapons/v_knife_ghost.mdl");

	}

	
}
//开武器箱
function OpenBox()
{
	for(local st = 0; st <= 9 ;st ++)
	{
		if(uid[st][1] == activator && uid[st][2] != 2)
		{
			local stringx = "";
			if(caller.GetName().find("10") != null || caller.GetName().find("11") != null || caller.GetName().find("12") != null)
				stringx = caller.GetName().slice(0,5);
			else
				stringx = caller.GetName().slice(0,4);
			EntFire("" + stringx,"kill");
			EntFire("" + caller.GetName(),"kill","");
			EntFire("" + stringx + "brush","kill");
			local _eq = Entities.FindByName(null, "equiper2");
			local nunu = RandomInt(0,6);
			EntFireByHandle(_eq, "TriggerForActivatedPlayer", "" + weapons[nunu][0], 0, activator, activator);
			if(language == 0)
			{
				EntFire("txt" + st,"AddOutput","message 你开启武器箱，得到了" + weapons[nunu][1],0.0);
				EntFire("txt" + st,"showmessage","",0.5,uid[st][1]);
			}
			else if (language == 1)
			{
				EntFire("txt" + st,"AddOutput","message You got a(n) " + weapons[nunu][1] + " by opening the box",0.0);
				EntFire("txt" + st,"showmessage","",0.5,uid[st][1]);
			}
			break;
		}
	}

}

//开补给箱
function OpenBoxA()
{
	for(local st = 0; st <= 9 ;st ++)
	{
		if(uid[st][1] == activator && uid[st][2] != 2)
		{
			local stringx = "";
			stringx = caller.GetName().slice(0,5);
			EntFire("" + stringx,"kill");
			EntFire("" + caller.GetName(),"kill","");
			EntFire("" + stringx + "brush","kill");
			
			local _eq = Entities.FindByName(null, "equiper2");
			//local nunu = RandomInt(0,3);
			//local nunu2 = RandomInt(23,25);
			//EntFireByHandle(_eq, "TriggerForActivatedPlayer", "" + weapons2[nunu][0], 0, activator, activator);
			//EntFireByHandle(_eq, "TriggerForActivatedPlayer", "" + weapons[nunu2][0], 0, activator, activator);
			EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_hegrenade", 0, activator, activator);
			EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_flashbang", 0, activator, activator);
			EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_smokegrenade", 0, activator, activator);
			EntFireByHandle(_eq, "TriggerForActivatedPlayer", "weapon_molotov", 0, activator, activator);
			local amg = Entities.FindByName(null,"ammo_giver");
			EntFireByHandle(amg,"GiveAmmo","",0,activator,activator);
			if(language == 0)
			{
				EntFire("txt" + st,"AddOutput","message 你开启补给箱，后备子弹补满，并获得一些手雷",0.0);
				EntFire("txt" + st,"showmessage","",0.5,uid[st][1]);
			}
			else if (language == 1)
			{
				EntFire("txt" + st,"AddOutput","message Your bullet has been refilled, and got some grenades",0.0);
				EntFire("txt" + st,"showmessage","",0.5,uid[st][1]);
			}
			break;
		}
	}

}
//第一次补给箱随机坐标
locone <- 
[
Vector(1083.05,-313.32,-1755),
Vector(1268.71,-957.637,-1862.55),
Vector(44.9298,546.643,-1768.55),
Vector(490.625,105.339,-1768.55),
Vector(984.039,-696.038,-1678.55)
];


loconed <- 
[
Vector(1083.05,-313.32,-1707),
Vector(1268.71,-957.637,-1814.55),
Vector(44.9298,546.643,-1720.55),
Vector(490.625,105.339,-1720.55),
Vector(984.039,-696.038,-1630.55)
];
//第二次补给箱随机坐标
loctwo <- 
[
Vector(1316.97,-495.154,-1654.55),
Vector(772.461,-75.1684,-1731.55),
Vector(523.448,-499.567,-1731.55),
Vector(1069.67,-1728.94,-1786.55),
Vector(1306.7,-1362.49,-1826.55)
];

loctwoh <- 
[
Vector(1316.97,-495.154,-1606.55),
Vector(772.461,-75.1684,-1683.55),
Vector(523.448,-499.567,-1683.55),
Vector(1069.67,-1728.94,-1738.55),
Vector(1306.7,-1362.49,-1778.55)
];

//第一次空投补给箱
function Airdrop()
{
	local rn = RandomInt(0,4);
	local adb1 = Entities.FindByName(null,"abox1");
	local adb1bt = Entities.FindByName(null,"abox1bt");
	local abcde = Entities.FindByName(null,"abox1brush");
	EntFire("abox1","SetGlowEnabled");
	adb1.SetOrigin(locone[rn]);
	adb1bt.SetOrigin(locone[rn]);
	abcde.SetOrigin(loconed[rn]);
	EntFire("boxarrive","playsound");
	if(language == 0)
	{
		ScriptPrintMessageChatAll("\x01 \x04 空投补给箱已到达！");
		EntFire("mainst","SetText","空投补给箱已到达！", 0);
		EntFire("mainst","Display","", 0.1);
	}
	else if(language == 1)
	{
		ScriptPrintMessageChatAll("\x01 \x04 Airdrop supply box has arrived!");
		EntFire("mainst","SetText","Airdrop supply box has arrived!", 0);
		EntFire("mainst","Display","", 0.1);
	}
}

//第二次空投补给箱
function Airdrops()
{
	local rn = RandomInt(0,4);
	local adb1 = Entities.FindByName(null,"abox2");
	local adb1bt = Entities.FindByName(null,"abox2bt");
	local abcde = Entities.FindByName(null,"abox2brush");
	EntFire("abox2","SetGlowEnabled");
	adb1.SetOrigin(loctwo[rn]);
	adb1bt.SetOrigin(loctwo[rn]);
	abcde.SetOrigin(loctwoh[rn]);
	EntFire("boxarrive","playsound");
	if(language == 0)
	{
		ScriptPrintMessageChatAll("\x01 \x04 空投补给箱已到达！");
		EntFire("mainst","SetText","空投补给箱已到达！", 0);
		EntFire("mainst","Display","", 0.1);
	}
	else if(language == 1)
	{
		ScriptPrintMessageChatAll("\x01 \x04 Airdrop supply box has arrived!");
		EntFire("mainst","SetText","Airdrop supply box has arrived!", 0);
		EntFire("mainst","Display","", 0.1);
	}
}
//开关控制
function KaiGuan()
{
	kaiguan = 0;
}

//生化幽灵每秒钟回血
/*
function Addhp()
{
	for(local st = 0; st <= 9 ;st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2 && uid[st][1].GetHealth() > 0)
		{
			if(uid[st][1].GetHealth() + 50 >= uid[st][1].GetMaxHealth())
				uid[st][1].SetHealth(uid[st][1].GetMaxHealth());
			else
				uid[st][1].SetHealth(uid[st][1].GetHealth() + 50);
		}
	}
}
*/


//真·回血
function Readx()
{
	for(local st = 0; st <= 9 ;st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 2 && uid[st][1].GetHealth() > 0)
		{
			if(uid[st][1].GetVelocity().Length() == Vector(0,0,0).Length())
				uid[st][9] += 1;
			else
				uid[st][9] = 0;
		
			if(uid[st][9] >= V_ZOMBIE_REHAB_HEALTH_CD)
			{
				uid[st][9] = 0;
				if(uid[st][1].GetHealth() + V_ZOMBIE_REHAB_HEALTH_AMT >= uid[st][1].GetMaxHealth())
				{
					uid[st][1].SetHealth(uid[st][1].GetMaxHealth());
				}
				else
				{
					uid[st][1].SetHealth(uid[st][1].GetHealth() + V_ZOMBIE_REHAB_HEALTH_AMT);
					EntFire("brea" + st,"playsound");
				}
			}
		}
	}
}
//语言控制器
language <- 0;

//语言配置检测
function Lg()
{
	local ent = Entities.FindByClassname(null,"point_viewcontrol_multiplayer");
	if(ent.GetName().find("0") != null)
		language = 0;
	else if (ent.GetName().find("1") != null)
		language = 1;
	for(local st = 1; st <= 12; st ++)
	{
		EntFire("mmdf" + st,"SetMaterialVar","" + language,0.1);
	}
	for(local st = 1; st <= 2; st ++)
	{
		EntFire("abox" + st + "mdf","SetMaterialVar","" + language,0.1);
	}
	if (language == 0)
	{
		EntFire("eih0","AddOutput","hint_caption  获取武器!");
		EntFire("eih0","showhint");
	}
	else if (language == 1)
	{
		EntFire("eih0","AddOutput","hint_caption  Get weapons here!");
		EntFire("eih0","showhint");
	}
}

function Welcome()
{
	ScriptPrintMessageChatAll("Type '!help' to see available commands,");
	ScriptPrintMessageChatAll("type '!lang' to change language.");
	ScriptPrintMessageChatAll(" 	");
	ScriptPrintMessageChatAll("输入'!help'查看可用指令,输入'!lang'改变语言");
}

//说话菜单
function player_say() 
{
    local txt = e_player_say.GetScriptScope().event_data.text;
/*
    if (txt.tolower() == "!nobgm") {
		if(canbgm == 0)
			ScriptPrintMessageChatAll("BGM has been disabled.");
		else
		{
			canbgm = 0;
			EntFire("bgm1","volume","0");
			EntFire("bgm2","volume","0");
			EntFire("bgm3","volume","0");
			EntFire("bgm4","volume","0");
			EntFire("bgm5","volume","0");
			EntFire("bgm6","volume","0");
			EntFire("bgm7","volume","0");
			ScriptPrintMessageChatAll("BGM is disabled.");
		}
    }
*/
    if (txt.tolower() == "!creator") {
		ScriptPrintMessageChatAll("\x01 Creator of script: \x01 \x03 Dazai Nerau");
		ScriptPrintMessageChatAll("\x01 \x04http://steamcommunity.com/id/utagawashii/");
		print("http://steamcommunity.com/id/utagawashii/\n");
    }
    if (txt.tolower() == "!help") {
		if(language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x03 Commands:");
			ScriptPrintMessageChatAll("\x01 \x04 !help -\x01 Show list of commands");
			ScriptPrintMessageChatAll("\x01 \x04 !creator -\x01 Show creator of script");
			ScriptPrintMessageChatAll("\x01 \x04 !lang -\x01 Change language");		
		}
		else if (language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x03 指令:");
			ScriptPrintMessageChatAll("\x01 \x04 !help -\x01 显示可用指令");
			ScriptPrintMessageChatAll("\x01 \x04 !creator -\x01 显示脚本制作者");
			ScriptPrintMessageChatAll("\x01 \x04 !lang -\x01 改变语言");		
		}
    }

	if(txt.tolower() == "!lang")
	{
		if(language == 0)
		{
			ScriptPrintMessageChatAll("\x01 \x03 Language Commands:");
			ScriptPrintMessageChatAll("\x01 \x04 !chn -\x01 Change language to Chinese");
			ScriptPrintMessageChatAll("\x01 \x04 !eng -\x01 Change language to English");
		}
		else if (language == 1)
		{
			ScriptPrintMessageChatAll("\x01 \x03语言命令:");
			ScriptPrintMessageChatAll("\x01 \x04 !chn -\x01 将语言改成中文");
			ScriptPrintMessageChatAll("\x01 \x04 !eng -\x01 将语言改成英语");
		}
	}
	if(txt.tolower() == "!chn")
	{
		ScriptPrintMessageChatAll("\x01 \x04 语言已被设定为中文");
		language = 0;
		local ent = Entities.FindByClassname(null,"point_viewcontrol_multiplayer");
		EntFireByHandle(ent,"AddOutput","targetname 0" + ent.GetName().slice(1),0,ent,ent);
		for(local st = 1; st <= 12; st ++)
		{
			EntFire("mmdf" + st,"SetMaterialVar","" + language);
		}
		for(local st = 1; st <= 2; st ++)
		{
			EntFire("abox" + st + "mdf","SetMaterialVar","" + language);
		}

	}
	if(txt.tolower() == "!eng")
	{
		ScriptPrintMessageChatAll("\x01 \x04 Language has been set to English");
		language = 1;
		local ent = Entities.FindByClassname(null,"point_viewcontrol_multiplayer");
		EntFireByHandle(ent,"AddOutput","targetname 1" + ent.GetName().slice(1),0,ent,ent);
		for(local st = 1; st <= 12; st ++)
		{
			EntFire("mmdf" + st,"SetMaterialVar","" + language);
		}
		for(local st = 1; st <= 2; st ++)
		{
			EntFire("abox" + st + "mdf","SetMaterialVar","" + language);
		}

	}
}

//循环播放背景音
function Circ()
{
	EntFire("op","playsound","",V_BGM_LENGTH);
	EntFire("script","runscriptcode","Circ()",V_BGM_RECYCLE_CD);
}

color <- 0;
//闪烁效果
function Blink()
{
	if(color == 0)
		color = 1;
	else
		color = 0;
	for(local st = 0; st <= 9; st ++)
	{
		if(uid[st][1] != null && uid[st][1].IsValid())
		{
			if(uid[st][2] == 2 && uid[st][1].GetHealth() >= V_BLINK_REQUIRE_HP)
			{
				EntFireByHandle(uid[st][1], "AddOutput", "rendermode 1", 0.1, uid[st][1], uid[st][1]);
				EntFireByHandle(uid[st][1], "Color", "255 255 255", 0.1, uid[st][1], uid[st][1]);
			}
		}
		if(uid[st][1] == null || !(uid[st][1].IsValid()) || uid[st][2] != 2 || uid[st][1].GetHealth() <= 0 || uid[st][1].GetHealth() > V_BLINK_REQUIRE_HP)
			continue;
		EntFireByHandle(uid[st][1], "AddOutput", "rendermode 1", 0.1, uid[st][1], uid[st][1]);
		if (color == 0)
			EntFireByHandle(uid[st][1], "Color", V_BLINK_COLOR, 0.1, uid[st][1], uid[st][1]);
		else
			EntFireByHandle(uid[st][1], "Color", "255 255 255", 0.1, uid[st][1], uid[st][1]);
		
	}
}



function banana()
{
    local knife = null;      
    while (knife = Entities.FindByModel(knife, "models/weapons/v_rif_galilar.mdl"))
    {              
        knife.SetModel("models/weapons/v_rif_royal.mdl");
    }
    while (knife = Entities.FindByModel(knife, "models/weapons/v_pist_deagle.mdl"))
    {              
        knife.SetModel("models/weapons/v_pist_remake.mdl");
    }
    while (knife = Entities.FindByModel(knife, "models/weapons/w_pist_deagle.mdl"))
    {              
        knife.SetModel("models/weapons/w_pist_remake.mdl");
    }
    while (knife = Entities.FindByModel(knife, "models/weapons/w_rif_galilar.mdl"))
    {              
        knife.SetModel("models/weapons/w_rif_royal.mdl");
    }

}


function Setalpha(st)
{
	EntFire("sprx" + st,"Alpha","0",0.2);
	EntFire("sprx" + st,"Alpha","17",0.3);
	EntFire("sprx" + st,"Alpha","34",0.33);	
	EntFire("sprx" + st,"Alpha","51",0.36);	
	EntFire("sprx" + st,"Alpha","68",0.39);
	EntFire("sprx" + st,"Alpha","85",0.41);
	EntFire("sprx" + st,"Alpha","102",0.44);
	EntFire("sprx" + st,"Alpha","119",0.47);
	EntFire("sprx" + st,"Alpha","136",0.5);
	EntFire("sprx" + st,"Alpha","153",0.53);
	EntFire("sprx" + st,"Alpha","170",0.56);
	EntFire("sprx" + st,"Alpha","187",0.59);
	EntFire("sprx" + st,"Alpha","204",0.62);
	EntFire("sprx" + st,"Alpha","221",0.65);
	EntFire("sprx" + st,"Alpha","238",0.68);
	EntFire("sprx" + st,"Alpha","255",0.71);
	
	EntFire("sprx" + st,"Alpha","238",0.74);
	EntFire("sprx" + st,"Alpha","221",0.77);	
	EntFire("sprx" + st,"Alpha","204",0.8);	
	EntFire("sprx" + st,"Alpha","187",0.83);
	EntFire("sprx" + st,"Alpha","170",0.86);
	EntFire("sprx" + st,"Alpha","153",0.89);
	EntFire("sprx" + st,"Alpha","136",0.92);
	EntFire("sprx" + st,"Alpha","119",0.95);
	EntFire("sprx" + st,"Alpha","102",0.98);
	EntFire("sprx" + st,"Alpha","85",1.01);
	EntFire("sprx" + st,"Alpha","68",1.04);
	EntFire("sprx" + st,"Alpha","51",1.07);
	EntFire("sprx" + st,"Alpha","34",1.1);
	EntFire("sprx" + st,"Alpha","17",1.13);
	EntFire("sprx" + st,"Alpha","0",1.16);

	EntFire("gz" + st,"Alpha","0",0.2);
	EntFire("gz" + st,"Alpha","17",0.3);
	EntFire("gz" + st,"Alpha","34",0.32);	
	EntFire("gz" + st,"Alpha","51",0.34);	
	EntFire("gz" + st,"Alpha","68",0.36);
	EntFire("gz" + st,"Alpha","85",0.38);
	EntFire("gz" + st,"Alpha","102",0.40);
	EntFire("gz" + st,"Alpha","119",0.42);
	EntFire("gz" + st,"Alpha","136",0.44);
	EntFire("gz" + st,"Alpha","153",0.46);
	EntFire("gz" + st,"Alpha","170",0.48);
	EntFire("gz" + st,"Alpha","187",0.5);
	EntFire("gz" + st,"Alpha","204",0.52);
	EntFire("gz" + st,"Alpha","221",0.54);
	EntFire("gz" + st,"Alpha","238",0.56);
	EntFire("gz" + st,"Alpha","255",0.58);
		
	EntFire("gz" + st,"Alpha","238",0.6);
	EntFire("gz" + st,"Alpha","221",0.62);	
	EntFire("gz" + st,"Alpha","204",0.64);	
	EntFire("gz" + st,"Alpha","187",0.66);
	EntFire("gz" + st,"Alpha","170",0.68);
	EntFire("gz" + st,"Alpha","153",0.7);
	EntFire("gz" + st,"Alpha","136",0.72);
	EntFire("gz" + st,"Alpha","119",0.74);
	EntFire("gz" + st,"Alpha","102",0.76);
	EntFire("gz" + st,"Alpha","85",0.78);
	EntFire("gz" + st,"Alpha","68",0.8);
	EntFire("gz" + st,"Alpha","51",0.82);
	EntFire("gz" + st,"Alpha","34",0.84);
	EntFire("gz" + st,"Alpha","17",0.86);
	EntFire("gz" + st,"Alpha","0",0.9);
	
}


//死亡后
function Dea(vic,atk)
{

	local shouhaizhe = 0;
	local gongjizhe = 0;
	for (local st = 0; st <= 9 ; st ++)
	{
		if(uid[st][1] == null || !(uid[st][1].IsValid()))
			continue;
		if (uid[st][1].GetName() == vic.tostring())
		{
			shouhaizhe = st;
			break;
		}
	}
	for (local st2 = 0; st2 <= 9 ; st2 ++)
	{
		if(uid[st2][1] == null || !(uid[st2][1].IsValid()))
			continue;
		if (uid[st2][1].GetName() == atk.tostring())
		{
			gongjizhe = st2;
			break;
		}
	}

	
	if(uid[shouhaizhe][2] == 2)
	{
		uid[shouhaizhe][1].EmitSound("GrandTerminatorDie.wav");
	}
	if(uid[shouhaizhe][2] == 2 && uid[gongjizhe][2] == 1)
	{
		Addhr();
	}
}

humanrage <- 0;
cancan <- 1;
//人类怒气倍数
function Addhr()
{
	if(humanrage + 1 > 10 && cancan == 1)
	{
		humanrage = 10;
		cancan = 0;
		EntFire("shuijifuhuo","Command","sv_cheats 1",0);
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		for(local st = 0;st <= 9; st ++)
		{
			if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 1)
			{
				EntFire("clcmd","Command","r_screenoverlay overlays/power" + humanrage,0.1,uid[st][1]);

			}
		}

	}
	else if(humanrage + 1 <= 10)
	{
		humanrage = humanrage + 1;

		EntFire("shuijifuhuo","Command","sv_cheats 1",0);
		EntFire("shuijifuhuo","Command","sv_cheats 0",0.2);
		for(local st = 0;st <= 9; st ++)
		{
			if(uid[st][1] != null && uid[st][1].IsValid() && uid[st][2] == 1)
			{
				EntFire("clcmd","Command","r_screenoverlay overlays/power" + humanrage,0.1,uid[st][1]);

			}
		}
	}
}

function Ragetext()
{

	
	if(humanrage == 0)
	{
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 0%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 0%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 1)
	{
		EntFire("rage","addoutput","color 70 192 210");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 10%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 10%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 2)
	{
		EntFire("rage","addoutput","color 70 192 210");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 20%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 20%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 3)
	{
		EntFire("rage","addoutput","color 228 220 90");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 30%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 30%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 4)
	{
		EntFire("rage","addoutput","color 228 220 90");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 40%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 40%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 5)
	{
		EntFire("rage","addoutput","color 228 220 90");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 50%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 50%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 6)
	{
		EntFire("rage","addoutput","color 228 220 90");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 60%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 60%");
		EntFire("rage","display",0.1);

	}
	
	else if(humanrage == 7)
	{
		EntFire("rage","addoutput","color 229 164 91");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 70%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 70%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 8)
	{
		EntFire("rage","addoutput","color 229 164 91");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 80%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 80%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 9)
	{
		EntFire("rage","addoutput","color 209 91 91");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 90%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 90%");
		EntFire("rage","display",0.1);

	}
	else if(humanrage == 10)
	{
		EntFire("rage","addoutput","color 209 91 91");
		if(language == 0)
			EntFire("rage","addoutput","message 人类攻击力提升 100%");
		else
			EntFire("rage","addoutput","message Attack Power of Human + 100%");
		EntFire("rage","display",0.1);

	}

}