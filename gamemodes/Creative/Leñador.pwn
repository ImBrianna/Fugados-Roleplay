/*
	Módulo leñador: Creative Roleplay
	Fecha: 09/12/2020
*/

#include <YSI\y_hooks>
//Créditos : Edinson Walker - GC
enum
{
	LUMBER_TREE_STATE_NORMAL,
	LUMBER_TREE_STATE_CUTTING,
	LUMBER_TREE_STATE_CUTTED
}
enum l_info
{
	l_modelo,
	Float:l_posicionX,
	Float:l_posicionY,
	Float:l_posicionZ,
	Float:l_posicionRX,
	Float:l_posicionRY,
	Float:l_posicionRZ,
	l_objeto_id,
	Text3D:l_3dlabel,
	lumber_tree_STATE,
	lumber_tree_GROW_TIMER,
	lumber_tree_GROW_COUNTER
};

new i_Lenador[][l_info] =
{
	{657, -529.44330, -1505.01282, 9.08430,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -526.26917, -1513.71155, 9.11755,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -517.69769, -1506.08667, 9.68410,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -517.04956, -1515.58423, 9.44219,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -531.11359, -1524.87000, 8.28400,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -525.03735, -1521.58667, 8.76343,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -516.05640, -1523.01575, 8.93295,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -511.72879, -1499.74316, 10.34326,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -537.81958, -1520.25293, 8.39722,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -536.45551, -1511.51721, 8.64116,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -520.01074, -1498.74011, 9.82430,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -528.20636, -1494.21863, 9.50600,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -517.45190, -1489.38538, 10.34639,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -507.44806, -1491.24414, 10.91343,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1},
	{657, -509.87573, -1510.29395, 10.01949,   0.00000, 0.00000, 0.00000, INVALID_STREAMER_ID, Text3D:INVALID_3DTEXT_ID, LUMBER_TREE_STATE_NORMAL, -1, -1}
};

new
	area_lenador,
	timer_lenador[MAX_PLAYERS];

hook OnGameModeInit()
{
	//Leñador arboles
	area_lenador = CreateDynamicSphere(-554.0010, -1496.7751, 9.4138, 50.0, 0, 0);
	for(new i = 0; i != sizeof i_Lenador; i ++)
	{
		i_Lenador[i][l_objeto_id] = CreateDynamicObject(i_Lenador[i][l_modelo], i_Lenador[i][l_posicionX], i_Lenador[i][l_posicionY], i_Lenador[i][l_posicionZ], i_Lenador[i][l_posicionRX], i_Lenador[i][l_posicionRY], i_Lenador[i][l_posicionRZ], 0, 0);
		i_Lenador[i][l_3dlabel] = CreateDynamic3DTextLabel("Pulsa {00AE57}~k~~PED_FIREWEAPON~{EBEBEB} para talar el árbol.", 0xEBEBEBFF, i_Lenador[i][l_posicionX], i_Lenador[i][l_posicionY], i_Lenador[i][l_posicionZ] + 1.5, 5.0, .testlos = false, .worldid = 0, .interiorid = 0);
	}
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if (GetPVarInt(playerid, "CheckpointLena") == 1)
	{
		if (IsPlayerInRangeOfPoint(playerid, 5.0, -548.8622, -1496.4225, 8.8761))
		{
			DeletePVar(playerid, "CheckpointLena");
			DisablePlayerCheckpoint(playerid);

			RemovePlayerAttachedObject(playerid, 0);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			ApplyAnimation(playerid, "CARRY", "putdwn05", 4.1, 0, 1, 1, 0, 0, 1);

			InfoPersonaje[playerid][pCargandoMadera] = false;
			new paga = 100;

			//habilidad
			if (InfoCuenta[playerid][jVIP] != 0) InfoPersonaje[playerid][pHabilidad][2] += 2;
			else InfoPersonaje[playerid][pHabilidad][2]++;
			guardar_int_mysql("personajes", "Habilidad3", InfoPersonaje[playerid][pID], InfoPersonaje[playerid][pHabilidad][2]);

			switch (NivelHabilidad(playerid, 2))
			{	
				case 1: paga = Random(10, 50);
				case 2: paga = Random(40, 80);
				case 3: paga = Random(80, 100);
				case 4: paga = Random(90, 115); 
				case 5: paga = Random(110, 140); 
			}

			GivePlayerCash(playerid, paga, "ganancia lenador");
			SendClientMessageEx(playerid, 0xEBEBEBFF, "Has conseguido {00AE57}$%d{EBEBEB} por los troncos.", paga);
		}
		return 1;
	}
	return 1;
}