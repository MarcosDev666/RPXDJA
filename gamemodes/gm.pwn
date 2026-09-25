#include <a_samp>
#include <streamer>
#include <dof2>
#include <zcmd>
#include <zones>

// Configuracion basica del servidor
#define SERVER_VERSION  "1 . 0 . 0"
#define VERSION_DATE    "31/08/2025"
#define SERVER_SHORTCUT "PXYRP"
#define SERVER_NAME     "Proxy Roleplay"
#define SERVER_HOSTNAME "Proxy Roleplay en español"
#define SERVER_WEBSITE  "discord.gg/qEC4vBhW"
#define SERVER_MAPNAME  "1 . 0 . 0  f e n i x"
#define SERVER_GAMEMODE "RP - ESP [PC/Android]"
#define SERVER_LANGUAGE "Español - Spanish"

#define SERVER_BANK_NAME "BBVA"
#define SERVER_COIN      "Diamantes"

// Configuracion del servidor
#undef      MAX_PLAYERS
#define     MAX_PLAYERS     50
#define     MAX_BAD_LOGIN_ATTEMPS 3

// 1 hora minutos para obtener reputacion
#define     TIME_FOR_REP 3600000 
#define     REP_FOR_PAYDAY 1

// Macros del servidor
#define     Funcion%0(%1)   forward %0(%1); public %0(%1)
#define     Loop(%0,%1)     for(new %0 = 0; %0 < %1; ++%0)
#define     GiveMoney(%0,%1) ResetPlayerMoney(%0) && GivePlayerMoney(%0,%1)

/* TEXTDRAWS y MAPA*/
new PlayerText:ptextdraw_MESSAGE;
new PlayerText:ptextdraw_NOTIFY;
new PlayerText:Textdraws_GPS_MAP[5];

// NUEVOS TEXTDRAWS PARA EL HUD
new PlayerText:HUD_ServerName[MAX_PLAYERS];
new PlayerText:HUD_PlayerInfo[MAX_PLAYERS];

// Jugador (Posiciones Map)
#define map_td_X 484.919342
#define map_td_Y 207.666656
#define map_td_SIZE_X 144.304565
#define map_td_SIZE_Y 161.583358

// Checkpoint (Posiciones Map)
#define map_tde_X 484.919342
#define map_tde_Y 207.666656
#define map_tde_SIZE_X 144.304565
#define map_tde_SIZE_Y 161.583358

new bool:Mapa[MAX_PLAYERS];
new Float:CP_Mapa[MAX_PLAYERS][3];

// Dialogos del servidor
enum
{
    DIALOG_REG,
    DIALOG_LOG,
    DIALOG_MAIL,
    DIALOG_GEN,
    DIALOG_HELP,
    DIALOG_HELP_1,
    DIALOG_HELP_2,
    DIALOG_HELP_3,
    DIALOG_HELP_4,
    DIALOG_HELP_5,
    DIALOG_HELP_6,
    DIALOG_HELP_7,
    DIALOG_HELP_8,
    DIALOG_HELP_9,
    DIALOG_STATS
}

new BAD_LOGIN_ATTEMPS[MAX_PLAYERS];
new Text:Login[6];

// Variables del jugador
enum pInfo
{
    bool:Online,
    bool:Stats,
    bool:Baned,
    bool:Muted,
    bool:Jail,
    bool:Dead,
    pSkin,
    pMoney,
    pScore,
    pStyle,
    pWanted,
    Float:pHealth,
    Float:pArmour,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInt,
    pVW
};

new Player[MAX_PLAYERS][pInfo];

// Declaraciones de funciones locales
forward minconnecttime();
forward Unjail(playerid);
forward Congelar(playerid);
forward Descongelar(playerid);
forward Tutorial1(playerid);
forward Tutorial2(playerid);
forward Tutorial3(playerid);
forward Tutorial4(playerid);
forward Tutorial5(playerid);
forward Tutorial6(playerid);
forward Tutorial7(playerid);
forward Tutorial8(playerid);
forward Tutorial9(playerid);
forward Tutorial10(playerid);
forward Tutorial11(playerid);
forward Tutorial12(playerid);
forward UpdatePlayer_GPS_Map(playerid);
forward UpdateCp_GPS_Map(playerid);
forward HidePlayerMessageNotification(playerid);
forward HidePlayerMessage(playerid);

// Forwards y Stocks Nativos Requeridos
forward IsPlayerLogged(playerid);
forward ShowPlayerGpsMap(playerid);
forward HidePlayerGpsMap(playerid);
forward SetPlayerPoint_GPS_Map(playerid, icon[], color, Float:icon_size_X, Float:icon_size_Y, Float:x, Float:y);
forward SetPlayerCp_GPS_Map(playerid, icon[], color, Float:icon_size_X, Float:icon_size_Y, Float:x, Float:y);
forward TD_GPS_MAP(playerid);
forward TD_MSG_NTF(playerid);
forward ShowPlayerMessageNotification(playerid, message[], seconds);
forward ShowPlayerMessage(playerid, message[], seconds);
forward Kickear(playerid);
forward ActualizarHUD(playerid);

stock Nombre(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock Cuenta(playerid)
{
    new string[100];
    format(string, sizeof(string), "Cuentas/%s.ini", Nombre(playerid));
    return string;
}

// Validación de Nombre con Formato de Rol (Nombre_Apellido)
stock TieneNombreRol(const name[])
{
    new len = strlen(name);
    new juest_underscore = 0;
    
    if(len < 4) return 0;
    
    for(new i = 0; i < len; i++)
    {
        if(name[i] == '_')
        {
            juest_underscore++;
            if(i == 0 || i == len - 1) return 0; // No puede empezar ni terminar con '_'
        }
    }
    if(juest_underscore == 1) return 1;
    return 0;
}

// Validación básica de estructura de correo electrónico
stock IsValidEmail(const email[])
{
    new len = strlen(email);
    new has_at = 0, has_dot = 0;
    if(len < 5) return 0;
    
    for(new i = 0; i < len; i++)
    {
        if(email[i] == '@') has_at++;
        if(email[i] == '.' && has_at == 1) has_dot++;
    }
    if(has_at == 1 && has_dot >= 1) return 1;
    return 0;
}

//*****************************************************************************
main()
{
    print("--- > "SERVER_NAME" < --- ");
}
//*****************************************************************************

public minconnecttime()
{
    SendRconCommand("minconnectiontime 0");
    return 1;
}

public OnGameModeInit()
{
    SetGameModeText(SERVER_GAMEMODE);
    SendRconCommand("hostname "SERVER_HOSTNAME"");
    SendRconCommand("language "SERVER_LANGUAGE"");
    SendRconCommand("weburl "SERVER_WEBSITE"");
    SendRconCommand("mapname "SERVER_MAPNAME"");
    SendRconCommand("minconnectiontime 0");
    SendRconCommand("ackslimit 8000");
    SendRconCommand("messageslimit 100");
    SendRconCommand("conncookies 1");
    SendRconCommand("cookielogging 0");
    SendRconCommand("chatlogging 0");
    SendRconCommand("sleep 1");
    SetTimer("minconnecttime", 60000, 0);
    
    SetWorldTime(2);
    SetWeather(3);
    
    UsePlayerPedAnims();
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);

    ShowNameTags(1);
    SetNameTagDrawDistance(100.0);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    
    // Login textdraws
    Login[0] = TextDrawCreate(-10.000000, 0.000000, "tela");
    TextDrawBackgroundColor(Login[0], 0);
    TextDrawFont(Login[0], 5);
    TextDrawLetterSize(Login[0], 0.500000, 1.000000);
    TextDrawColor(Login[0], -11184641);
    TextDrawSetOutline(Login[0], 0);
    TextDrawSetProportional(Login[0], 1);
    TextDrawSetShadow(Login[0], 1);
    TextDrawUseBox(Login[0], 1);
    TextDrawBoxColor(Login[0], 0);
    TextDrawTextSize(Login[0], 660.000000, 450.000000);
    TextDrawSetSelectable(Login[0], 0);
    TextDrawSetPreviewModel(Login[0], 19128);
    TextDrawSetPreviewRot(Login[0],  30.000000, -1.000000, 44.000000, 0.000000);

    Login[1] = TextDrawCreate(225.000000, 56.000000, "pro xyrp");
    TextDrawBackgroundColor(Login[1], 255);
    TextDrawFont(Login[1], 1);
    TextDrawLetterSize(Login[1], 1.129999, 3.799999);
    TextDrawColor(Login[1], 255);
    TextDrawSetOutline(Login[1], 0);
    TextDrawSetProportional(Login[1], 1);
    TextDrawSetShadow(Login[1], 0);
    TextDrawSetSelectable(Login[1], 0);

    Login[2] = TextDrawCreate(287.000000, 71.000000, "hud:radar_triads");
    TextDrawBackgroundColor(Login[2], 0);
    TextDrawFont(Login[2], 4);
    TextDrawLetterSize(Login[2], 0.289999, 1.000000);
    TextDrawColor(Login[2], -1);
    TextDrawSetOutline(Login[2], 0);
    TextDrawSetProportional(Login[2], 0);
    TextDrawSetShadow(Login[2], 1);
    TextDrawUseBox(Login[2], 1);
    TextDrawBoxColor(Login[2], 0);
    TextDrawTextSize(Login[2], 17.000000, 14.000000);
    TextDrawSetSelectable(Login[2], 0);

    Login[3] = TextDrawCreate(390.000000, 74.000000, "0.3.7");
    TextDrawBackgroundColor(Login[3], 255);
    TextDrawFont(Login[3], 1);
    TextDrawLetterSize(Login[3], 0.289997, 0.999997);
    TextDrawColor(Login[3], 255);
    TextDrawSetOutline(Login[3], 0);
    TextDrawSetProportional(Login[3], 0);
    TextDrawSetShadow(Login[3], 0);
    TextDrawSetSelectable(Login[3], 0);

    Login[4] = TextDrawCreate(285.000000, 99.000000, SERVER_MAPNAME);
    TextDrawBackgroundColor(Login[4], 255);
    TextDrawFont(Login[4], 1);
    TextDrawLetterSize(Login[4], 0.189999, 1.599998);
    TextDrawColor(Login[4], 255);
    TextDrawSetOutline(Login[4], 0);
    TextDrawSetProportional(Login[4], 0);
    TextDrawSetShadow(Login[4], 0);
    TextDrawSetSelectable(Login[4], 0);

    Login[5] = TextDrawCreate(227.000000, 96.000000, "-line-");
    TextDrawBackgroundColor(Login[5], 255);
    TextDrawFont(Login[5], 5);
    TextDrawLetterSize(Login[5], 0.500000, 1.000000);
    TextDrawColor(Login[5], -1);
    TextDrawSetOutline(Login[5], 0);
    TextDrawSetProportional(Login[5], 1);
    TextDrawSetShadow(Login[5], 1);
    TextDrawUseBox(Login[5], 1);
    TextDrawBoxColor(Login[5], 0);
    TextDrawTextSize(Login[5], 189.000000, 1.000000);
    TextDrawSetSelectable(Login[5], 0);
    TextDrawSetPreviewModel(Login[5], 0);
    TextDrawSetPreviewRot(Login[5],  0.000000, 0.000000, 0.000000, -1.000000);

    return 1;
}

public OnGameModeExit()
{
    DOF2_Exit();
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    IsPlayerLogged(playerid);
    return 0;
}

public OnPlayerRequestSpawn(playerid) return IsPlayerLogged(playerid);

public IsPlayerLogged(playerid)
{
    if(Player[playerid][Online] == true)
    {
        SetSpawnInfo(playerid, -1, Player[playerid][pSkin], Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ], Player[playerid][pPosA], 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        SetPlayerInterior(playerid, Player[playerid][pInt]);
        SetPlayerVirtualWorld(playerid, Player[playerid][pVW]);
        SetCameraBehindPlayer(playerid);
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    // 1. CONTROL DE REALISMO: Validar si el apodo cumple los requisitos de Rol
    if(!TieneNombreRol(Nombre(playerid)))
    {
        SendClientMessage(playerid, 0xFF0000FF, "[ERROR OOC]: Tu nombre no cumple el formato exigido: Nombre_Apellido.");
        SendClientMessage(playerid, -1, "Ejemplo correcto: Carlos_Mendoza, Jessica_Taylor. No uses apodos de internet.");
        SetTimerEx("KickearInmediato", 500, false, "i", playerid);
        return 1;
    }

    // Resetear variables locales de conexion
    Mapa[playerid] = false;
    BAD_LOGIN_ATTEMPS[playerid] = 0;
    Player[playerid][Online] = false;

    LimpiarChat(playerid);
    TD_GPS_MAP(playerid);
    TD_MSG_NTF(playerid);
    
    // 2. AMBIENTACIÓN REALISTA: Posicionar cámara cinemática de fondo
    SetPlayerCameraPos(playerid, 1457.7153, -1004.9754, 92.5113);
    SetPlayerCameraLookAt(playerid, 1314.1849, -1371.3732, 11.5645);
    TogglePlayerControllable(playerid, false);

    // CREACIÓN DEL TEXTDRAW DEL HUD PERSONALIZADO
    HUD_ServerName[playerid] = CreatePlayerTextDraw(playerid, 495.000000, 10.000000, SERVER_NAME);
    PlayerTextDrawLetterSize(playerid, HUD_ServerName[playerid], 0.380000, 1.400000);
    PlayerTextDrawAlignment(playerid, HUD_ServerName[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_ServerName[playerid], 0x33AAFFFF); 
    PlayerTextDrawSetShadow(playerid, HUD_ServerName[playerid], 1);
    PlayerTextDrawSetOutline(playerid, HUD_ServerName[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_ServerName[playerid], 150);
    PlayerTextDrawFont(playerid, HUD_ServerName[playerid], 3);
    PlayerTextDrawSetProportional(playerid, HUD_ServerName[playerid], 1);

    HUD_PlayerInfo[playerid] = CreatePlayerTextDraw(playerid, 495.000000, 24.000000, "_");
    PlayerTextDrawLetterSize(playerid, HUD_PlayerInfo[playerid], 0.240000, 1.100000);
    PlayerTextDrawAlignment(playerid, HUD_PlayerInfo[playerid], 1);
    PlayerTextDrawColor(playerid, HUD_PlayerInfo[playerid], -1); 
    PlayerTextDrawSetShadow(playerid, HUD_PlayerInfo[playerid], 1);
    PlayerTextDrawSetOutline(playerid, HUD_PlayerInfo[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, HUD_PlayerInfo[playerid], 150);
    PlayerTextDrawFont(playerid, HUD_PlayerInfo[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUD_PlayerInfo[playerid], 1);
    
    Loop(i, sizeof(Login))
    {
        TextDrawShowForPlayer(playerid, Login[i]);
    }
    
    if(!DOF2_FileExists(Cuenta(playerid))) 
    {
        return ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, 
            "{00ff00}"SERVER_SHORTCUT" - REGISTRAR PERSONAJE", 
            "{ffffff}Bienvenido a la oficina de inmigración.\n\nIntroduce una clave segura de acceso (NIP/Contraseña).\n{FFCC00}Requisito: Entre 4 y 16 caracteres.","Registrar","Salir");
    }
    else 
    {
        new stringLog[180];
        format(stringLog, sizeof(stringLog), "{ffffff}Hola de nuevo, {00ff00}%s.\n\n{ffffff}Esta identidad está registrada en el sistema del Estado.\nPor favor, introduce tu contraseña de seguridad:", Nombre(playerid));
        return ShowPlayerDialog(playerid, DIALOG_LOG, DIALOG_STYLE_PASSWORD, "{00ff00}"SERVER_SHORTCUT" - CONTROL DE ACCESO", stringLog, "Conectar", "Salir");
    }
}

// Forwards temporales de seguridad
forward KickearInmediato(playerid);
public KickearInmediato(playerid) return Kick(playerid);

// Forwards de stocks de guardado
forward Reg_Player_Stats(playerid);
forward Save_Player_Stats(playerid);
forward Load_Player_Stats(playerid);
forward LimpiarChat(playerid);
forward Formato(playerid, color, form[], {Float, _}: ...);

public OnPlayerDisconnect(playerid, reason)
{
    if(Player[playerid][Online] == true) Save_Player_Stats(playerid);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success) ShowPlayerMessage(playerid, "Comando incorrecto, lea ~r~~h~/ayuda~w~.", 5);
    return 1;
}

CMD:mapa(playerid)
{
    if(Mapa[playerid] == true) return HidePlayerGpsMap(playerid);

    ShowPlayerGpsMap(playerid);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return 1;
}

CMD:prueba(playerid)
{
    CP_Mapa[playerid][0] = 1371.0349;
    CP_Mapa[playerid][1] = -1890.0956;
    CP_Mapa[playerid][2] = 13.5728;
    SetPlayerCheckpoint(playerid, CP_Mapa[playerid][0], CP_Mapa[playerid][1], CP_Mapa[playerid][2], 3);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    for(new i = 0; i < sizeof(Login); i++)
    {
        TextDrawHideForPlayer(playerid, Login[i]);
    }
    
    if(Player[playerid][Jail] == true)
    {
        SetPlayerHealth(playerid, 100);
        Descongelar(playerid);
        SetPlayerPos(playerid, 1533.6067, -1638.8525, 2024.4063);
        SetPlayerFacingAngle(playerid, 359.1107);
        GameTextForPlayer(playerid, "~r~Estas preso!", 5000, 3);
        SetTimerEx("Unjail", 60000 * Player[playerid][pWanted], false, "i", playerid);
    }
    GiveMoney(playerid, Player[playerid][pMoney]);
    ActualizarHUD(playerid);
    return 1;
}

public Unjail(playerid)
{
    Player[playerid][pWanted] = 0;
    SetPlayerWantedLevel(playerid, 0);
    Player[playerid][Jail] = false;
    SetPlayerHealth(playerid, 100);
    Descongelar(playerid);
    SetPlayerPos(playerid, 1541.6305, -1675.1818, 13.5529);
    SetPlayerFacingAngle(playerid, 89.6651);
    return 1;
}

CMD:recibir(playerid)
{
    if(Player[playerid][Stats] == true) return GameTextForPlayer(playerid, "~r~Ya recibiste stats", 3500, 3);
    
    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "{00FF00}STATS DE INICIO",
    "{FFFFFF}De parte del equipo del servidor,se decidió regalar stats diarios.\n\n\
    {FFFFFF}Dinero: {41f48f}+$100.000\n\
    {D29BFD}Diamantes: {f44242}+3\n\
    {FFFFFF}Medicamentos: {00FF00}+5g\n\
    {FFFFFF}Marihuana: {00FF00}+5g\n\
    {FFFFFF}Piezas de arma: {00FF00}+25\n\
    {FFFFFF}Repuestos de mecanico: {00FF00}+25\n\
    {FFFFFF}Semillas de medicamento: {00FF00}+10\n\
    {FFFFFF}Semillas de marihuana: {00FF00}+10", "Salir", "");

    Player[playerid][Stats] = true;
    GivePlayerMoney(playerid, 100000);
    ActualizarHUD(playerid);
    return 1;
}

CMD:reglas(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_HELP_1, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" Pag.1",
    "{FFFFFF}Un modo de juego donde vamos a crear nuestro\n\
    {FFFFFF}propio personaje, y hacernos un hueco en el\n\
    {FFFFFF}juego, donde serás conocido por tus acciones,\n\
    {FFFFFF}mentalidad, forma de actuar y mucho más.\n\n\
    {FFFFFF}Teniendo esto en cuenta vamos a explicarte\n\
    {FFFFFF}los conceptos básicos de "SERVER_NAME".", "Siguiente", "Salir");
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    SpawnPlayer(playerid);
    SetPlayerHealth(playerid, 100);
    Congelar(playerid);
    GameTextForPlayer(playerid, "~r~Estas herido!", 5000, 3);

    if(killerid != INVALID_PLAYER_ID)
    {
        Player[killerid][Jail] = true;
        Player[killerid][pWanted] += 1;
        SetPlayerWantedLevel(killerid, Player[killerid][pWanted]);
        ActualizarHUD(killerid);
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(CP_Mapa[playerid][0] != 0.0 && CP_Mapa[playerid][1] != 0.0)
    {
        HidePlayerGpsMap(playerid);
        DisablePlayerCheckpoint(playerid);
        ShowPlayerMessage(playerid, "Has llegado a tú destino.", 5);
        CP_Mapa[playerid][0] = 0.0;
        CP_Mapa[playerid][1] = 0.0;
        CP_Mapa[playerid][2] = 0.0;
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_REG:
        {
            if(!response) return Kick(playerid);
            // Longitud realista de clave de seguridad extendida a un máximo de 16
            if(strlen(inputtext) < 4 || strlen(inputtext) > 16) 
            {
                return ShowPlayerDialog(playerid, DIALOG_REG, DIALOG_STYLE_INPUT, "{FF0000}"SERVER_SHORTCUT" - ERROR DE REGISTRO", 
                    "{ffffff}La contraseña introducida no es válida.\n{FF3333}Debe contener obligatoriamente entre 4 y 16 caracteres.","Registrar","Salir");
            }
            
            DOF2_CreateFile(Cuenta(playerid));
            DOF2_SetString(Cuenta(playerid), "Clave", inputtext);
            
            return ShowPlayerDialog(playerid, DIALOG_MAIL, DIALOG_STYLE_INPUT, "{00ff00}"SERVER_SHORTCUT" - CORREO ELECTRÓNICO", 
                "{FFFFFF}Ingresa una dirección de correo electrónico válida.\n\nEs fundamental para la vinculación ciudadana y la recuperación de credenciales de tu personaje.\n{FFFF00}Ejemplo: tunombre@gmail.com", "Continuar", "Salir");
        }
        case DIALOG_MAIL:
        {
            if(!response) return DOF2_RemoveFile(Cuenta(playerid)), Kick(playerid);
            
            // Verificación realista del string de Email
            if(!strlen(inputtext) || !IsValidEmail(inputtext))
            {
                return ShowPlayerDialog(playerid, DIALOG_MAIL, DIALOG_STYLE_INPUT, "{FF0000}"SERVER_SHORTCUT" - CORREO NO VÁLIDO", 
                    "{FFFFFF}El formato de correo ingresado es incorrecto o inexistente.\n\n{FF3333}Asegúrate de incluir el '@' y un dominio válido (punto).\n{FFFF00}Ejemplo: ciudadano@correo.com", "Continuar", "Salir");
            }
            
            DOF2_SetString(Cuenta(playerid), "Email", inputtext);
            return ShowPlayerDialog(playerid, DIALOG_GEN, DIALOG_STYLE_MSGBOX, "{00ff00}"SERVER_SHORTCUT" - GÉNERO DEL PERSONAJE", "{ffffff}Selecciona los rasgos y el sexo biológico inicial para tu personaje en la ciudad:", "Hombre", "Mujer");
        }
        case DIALOG_GEN:
        {
            // Restablecer cámara detrás del jugador antes de iniciar
            TogglePlayerControllable(playerid, true);
            SetCameraBehindPlayer(playerid);

            if(!response) // Mujer
            {
                SetPlayerSkin(playerid, 226);
                Reg_Player_Stats(playerid);
                Load_Player_Stats(playerid);
                ActualizarHUD(playerid);
                SetTimerEx("Tutorial1", 1000, false, "i", playerid);
            }
            else // Hombre
            {
                SetPlayerSkin(playerid, 188);
                Reg_Player_Stats(playerid);
                Load_Player_Stats(playerid);
                ActualizarHUD(playerid);
                SetTimerEx("Tutorial1", 1000, false, "i", playerid);
            }
        }
        case DIALOG_LOG:
        {
            if(!response) return Kick(playerid);
            
            if(!strlen(inputtext))
            {
                return ShowPlayerDialog(playerid, DIALOG_LOG, DIALOG_STYLE_PASSWORD, "{FF0000}"SERVER_SHORTCUT" - INTRODUZCA CLAVE", "{ffffff}El campo no puede estar vacío.\nPor favor introduce tu clave de acceso correspondiente:", "Conectar", "Salir");
            }
            
            if(strcmp(inputtext, DOF2_GetString(Cuenta(playerid), "Clave"), false) != 0)
            {
                BAD_LOGIN_ATTEMPS[playerid]++;
                Formato(playerid, -1, "{FF0000}[SEGURIDAD]:{FFFFFF} Contraseña errónea. Intentos: %d/%d", BAD_LOGIN_ATTEMPS[playerid], MAX_BAD_LOGIN_ATTEMPS);
                
                if(BAD_LOGIN_ATTEMPS[playerid] >= MAX_BAD_LOGIN_ATTEMPS)
                {
                    SendClientMessage(playerid, 0xFF0000FF, "[SISTEMA]: Has superado el límite de intentos de acceso. Conexión cerrada.");
                    return Kickear(playerid);
                }
                
                return ShowPlayerDialog(playerid, DIALOG_LOG, DIALOG_STYLE_PASSWORD, "{FF0000}"SERVER_SHORTCUT" - ACCESO INCORRECTO", "{ffffff}Contraseña incorrecta.\nIntroduce el código de acceso exacto asignado a esta cuenta:", "Conectar", "Salir");
            }
            else 
            {
                // Login correcto: activar control, resetear cámara e importar variables
                TogglePlayerControllable(playerid, true);
                SetCameraBehindPlayer(playerid);
                return Load_Player_Stats(playerid);
            }
        }
        case DIALOG_HELP_1:
        {
            if(!response) return 1;
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_2, DIALOG_STYLE_MSGBOX, "{00FF00}PowerGaming(PG) Pag.2",
                "{FFFFFF}Se conoce como realizar acciones que son imposibles de realizar en la vida real.\n\
                {FFFFFF}Un ejemplo de PowerGaming sería empujar un camion siendo una sola persona.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_2:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_1, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" Pag.1",
                "{FFFFFF}Un modo de juego donde vamos a crear nuestro\n\
                {FFFFFF}propio personaje, y hacernos un hueco en el\n\
                {FFFFFF}juego, donde serás conocido por tus acciones,\n\
                {FFFFFF}mentalidad, forma de actuar y mucho más.\n\n\
                {FFFFFF}Teniendo esto en cuenta vamos a explicarte\n\
                {FFFFFF}los conceptos básicos de "SERVER_NAME".", "Siguiente", "Salir");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_3, DIALOG_STYLE_MSGBOX, "{00FF00}DeathMatch(DM) y FreeKill(FK) Pag.3",
                "{FFFFFF}Consiste en realizar daño a otro jugador sin razones que justifiquen la agresión.\n\
                {FFFFFF}Realizar DM a un gran número de jugadores se conoce como FreeKill(FK).\n\
                {FFFFFF}"SERVER_NAME" no es el sitio para realizar DM.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_3:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_2, DIALOG_STYLE_MSGBOX, "{00FF00}PowerGaming(PG) Pag.2",
                "{FFFFFF}Se conoce como realizar acciones que son imposibles de realizar en la vida real.\n\
                {FFFFFF}Un ejemplo de PowerGaming sería empujar un camion siendo una sola persona.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_4, DIALOG_STYLE_MSGBOX, "{00FF00}InCharacter(IC) y OutOfCharacter(OOC) Pag.4",
                "{FFFFFF}IC is la información o charla obtenida por el personaje dentro del juego.\n\
                {FFFFFF}OOC es la información obtenida fuera del juego o por canales OOC del servidor.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_4:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_3, DIALOG_STYLE_MSGBOX, "{00FF00}DeathMatch(DM) y FreeKill(FK) Pag.3",
                "{FFFFFF}Consiste en realizar daño a otro jugador sin razones que justifiquen la agresión.\n\
                {FFFFFF}Realizar DM a un gran número de jugadores se conoce como FreeKill(FK).\n\
                {FFFFFF}"SERVER_NAME" no es el sitio para realizar DM.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_5, DIALOG_STYLE_MSGBOX, "{00FF00}MetaGaming(MG) Pag.5",
                "{FFFFFF}Este término aplica al obtener información de un medio Out of Channel\n\
                {FFFFFF}para beneficiarse de ella de manera InCharacter.\n\
                {FFFFFF}Además se considera MG gran al uso de información obtenida de modo Out of Channel.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_5:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_4, DIALOG_STYLE_MSGBOX, "{00FF00}InCharacter(IC) y OutOfCharacter(OOC) Pag.4",
                "{FFFFFF}IC es la información o charla obtenida por el personaje dentro del juego.\n\
                {FFFFFF}OOC es la información obtenida fuera del juego o por canales OOC del servidor.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_6, DIALOG_STYLE_MSGBOX, "{00FF00}CarJack(CJ) e InsultosOOC(IOOC) Pag.6",
                "{FFFFFF}CJ hace referencia a robar vehículos sin  rol previo.\n\
                {FFFFFF}IOOC es insultar a un usuario por canales OOC del servidor.\n\
                {FFFFFF}Esto está totalmente prohíbido.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_6:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_5, DIALOG_STYLE_MSGBOX, "{00FF00}MetaGaming(MG) Pag.5",
                "{FFFFFF}Este término aplica al obtener información de un medio Out of Channel\n\
                {FFFFFF}para beneficiarse de ella de manera InCharacter.\n\
                {FFFFFF}Además se considera MG gran al uso de información obtenida de modo Out of Channel.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_7, DIALOG_STYLE_MSGBOX, "{00FF00}Spam(SPAMER) y Flood(MG) Pag.7",
                "{FFFFFF}Spam es mencionar una comunidad externa a "SERVER_NAME",\n\
                {FFFFFF}un programa que de ventajas ante otros usuarios.\n\
                {FFFFFF}Flood hace referencia a mandar el mismo texto repetidas veces.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_7:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_6, DIALOG_STYLE_MSGBOX, "{00FF00}CarJack(CJ) e InsultosOOC(IOOC) Pag.6",
                "{FFFFFF}CJ hace referencia a robar vehículos sin  rol previo.\n\
                {FFFFFF}IOOC es insultar a un usuario por canales OOC del servidor.\n\
                {FFFFFF}Esto está totalmente prohíbido.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_8, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" "SERVER_VERSION" Pag.8",
                "{FFFFFF}Para más conceptos para así no tener problemas\n\
                {FFFFFF}en algun un futuro te recomendamos visitar\n\
                {FFFFFF}en nuestro discord (discord.gg/qEC4vBhW) la sección guías.\n\
                {FFFFFF}Ahí te informas todo al respecto del GM y las reglas.", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_8:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_7, DIALOG_STYLE_MSGBOX, "{00FF00}Spam(SPAMER) y Flood(MG) Pag.7",
                "{FFFFFF}Spam es mencionar una comunidad externa a "SERVER_NAME",\n\
                {FFFFFF}un programa que de ventajas ante otros usuarios.\n\
                {FFFFFF}Flood hace referencia a mandar el mismo texto repetidas veces.", "Siguiente", "Atras");
            }
            if(response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_9, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" Pag.9",
                "{FFFFFF}Servidor: "SERVER_NAME"\n\
                {FFFFFF}Web/foro: "SERVER_WEBSITE"\n\
                {FFFFFF}Versión: "SERVER_VERSION"\n\
                {FFFFFF}Fecha versión: "VERSION_DATE"\n\n\
                {FFFFFF}"SERVER_NAME" es un servidor Roleplay nuevo por lo que actualmente\n\
                {FFFFFF}se encuentra desarrollo, puedes dejar tus sugerencias en el foro.\n\
                {FFFFFF}Actualmente al ser una versión inicial puede contener fallos.\n\n\
                {FFFFFF}Programación: dani_mcfly", "Siguiente", "Atras");
            }
        }
        case DIALOG_HELP_9:
        {
            if(!response)
            {
                ShowPlayerDialog(playerid, DIALOG_HELP_8, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" "SERVER_VERSION" Pag.8",
                "{FFFFFF}Para más conceptos para así no tener problemas\n\
                {FFFFFF}en algun un futuro te recomendamos visitar\n\
                {FFFFFF}en nuestro discord (discord.gg/qEC4vBhW) la sección guías.\n\
                {FFFFFF}Ahí te informas todo al respecto del GM y las reglas.", "Siguiente", "Atras");
            }
            if(response)
            {
                Descongelar(playerid);
            }
        }
    }
    return 1;
}

public Kickear(playerid)
{
    if(BAD_LOGIN_ATTEMPS[playerid] >= MAX_BAD_LOGIN_ATTEMPS) return Kick(playerid);
    return 0;
}

public Reg_Player_Stats(playerid)
{
    new str[256], d, m, a, h, mi, s;
    gettime(h, mi, s);
    getdate(a, m, d);
    format(str, sizeof(str), "%02d/%02d/%02d %02d:%02d:%02d", d, m, a, h, mi, s);
    DOF2_SetString(Cuenta(playerid), "Regin", str);
    DOF2_SetString(Cuenta(playerid), "Login", str);
    DOF2_SetInt(Cuenta(playerid), "Stats", 0);
    DOF2_SetInt(Cuenta(playerid), "Baned", 0);
    DOF2_SetInt(Cuenta(playerid), "Muted", 0);
    DOF2_SetInt(Cuenta(playerid), "Jail", 0);
    DOF2_SetInt(Cuenta(playerid), "Dead", 0);
    
    // Al iniciar, le damos Score (Nivel) 1
    DOF2_SetInt(Cuenta(playerid), "pSkin", GetPlayerSkin(playerid));
    DOF2_SetInt(Cuenta(playerid), "pMoney", 25000);
    DOF2_SetInt(Cuenta(playerid), "pScore", 1); 
    DOF2_SetInt(Cuenta(playerid), "pStyle", 4);
    DOF2_SetInt(Cuenta(playerid), "pWanted", 0);
    DOF2_SetFloat(Cuenta(playerid), "pHealth", 100.0);
    DOF2_SetFloat(Cuenta(playerid), "pArmour", 0.0);
    DOF2_SetFloat(Cuenta(playerid), "pPosX", 1759.4958);
    DOF2_SetFloat(Cuenta(playerid), "pPosY", -1895.7516);
    DOF2_SetFloat(Cuenta(playerid), "pPosZ", 13.5612);
    DOF2_SetFloat(Cuenta(playerid), "pPosA", 269.4692);
    DOF2_SetInt(Cuenta(playerid), "pInt", 0);
    DOF2_SetInt(Cuenta(playerid), "pVW", 0);

    DOF2_SaveFile();
    return 1;
}

public Save_Player_Stats(playerid)
{
    new str[256], d, m, a, h, mi, s;
    gettime(h, mi, s);
    getdate(a, m, d);
    format(str, sizeof(str), "%02d/%02d/%02d %02d:%02d:%02d", d, m, a, h, mi, s);
    DOF2_SetString(Cuenta(playerid), "Login", str);

    DOF2_SetInt(Cuenta(playerid), "Stats", Player[playerid][Stats]);
    DOF2_SetInt(Cuenta(playerid), "Baned", Player[playerid][Baned]);
    DOF2_SetInt(Cuenta(playerid), "Muted", Player[playerid][Muted]);
    DOF2_SetInt(Cuenta(playerid), "Jail", Player[playerid][Jail]);
    DOF2_SetInt(Cuenta(playerid), "Dead", Player[playerid][Dead]);
    
    DOF2_SetInt(Cuenta(playerid), "pSkin", GetPlayerSkin(playerid));
    DOF2_SetInt(Cuenta(playerid), "pMoney", GetPlayerMoney(playerid));
    DOF2_SetInt(Cuenta(playerid), "pScore", GetPlayerScore(playerid));
    DOF2_SetInt(Cuenta(playerid), "pStyle", GetPlayerFightingStyle(playerid));
    DOF2_SetInt(Cuenta(playerid), "pWanted", GetPlayerWantedLevel(playerid));
    
    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida); GetPlayerArmour(playerid, chaleco);
    DOF2_SetFloat(Cuenta(playerid), "pHealth", vida);
    DOF2_SetFloat(Cuenta(playerid), "pArmour", chaleco);
    
    new Float:X, Float:Y, Float:Z, Float:A;
    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, A);
    DOF2_SetFloat(Cuenta(playerid), "pPosX", X);
    DOF2_SetFloat(Cuenta(playerid), "pPosY", Y);
    DOF2_SetFloat(Cuenta(playerid), "pPosZ", Z);
    DOF2_SetFloat(Cuenta(playerid), "pPosA", A);
    DOF2_SetInt(Cuenta(playerid), "pInt", GetPlayerInterior(playerid));
    DOF2_SetInt(Cuenta(playerid), "pVW", GetPlayerVirtualWorld(playerid));

    DOF2_SaveFile();
    return 1;
}

public Load_Player_Stats(playerid)
{
    Player[playerid][Stats] = DOF2_GetBool(Cuenta(playerid), "Stats");
    Player[playerid][Baned] = DOF2_GetBool(Cuenta(playerid), "Baned");
    Player[playerid][Muted] = DOF2_GetBool(Cuenta(playerid), "Muted");
    Player[playerid][Jail] = DOF2_GetBool(Cuenta(playerid), "Jail");
    Player[playerid][Dead] = DOF2_GetBool(Cuenta(playerid), "Dead");
    
    Player[playerid][pSkin] = DOF2_GetInt(Cuenta(playerid), "pSkin");
    Player[playerid][pMoney] = DOF2_GetInt(Cuenta(playerid), "pMoney");
    Player[playerid][pScore] = DOF2_GetInt(Cuenta(playerid), "pScore");
    Player[playerid][pStyle] = DOF2_GetInt(Cuenta(playerid), "pStyle");
    Player[playerid][pWanted] = DOF2_GetInt(Cuenta(playerid), "pWanted");
    Player[playerid][pHealth] = DOF2_GetFloat(Cuenta(playerid), "pHealth");
    Player[playerid][pArmour] = DOF2_GetFloat(Cuenta(playerid), "pArmour");
    Player[playerid][pPosX] = DOF2_GetFloat(Cuenta(playerid), "pPosX");
    Player[playerid][pPosY] = DOF2_GetFloat(Cuenta(playerid), "pPosY");
    Player[playerid][pPosZ] = DOF2_GetFloat(Cuenta(playerid), "pPosZ");
    Player[playerid][pPosA] = DOF2_GetFloat(Cuenta(playerid), "pPosA");
    Player[playerid][pInt] = DOF2_GetInt(Cuenta(playerid), "pInt");
    Player[playerid][pVW] = DOF2_GetInt(Cuenta(playerid), "pVW");
    Player[playerid][Online] = true;
    
    SetPlayerSkin(playerid, Player[playerid][pSkin]);
    GiveMoney(playerid, Player[playerid][pMoney]);
    SetPlayerScore(playerid, Player[playerid][pScore]);
    SetPlayerFightingStyle(playerid, Player[playerid][pStyle]);
    SetPlayerWantedLevel(playerid, Player[playerid][pWanted]);
    SetPlayerHealth(playerid, Player[playerid][pHealth]);
    SetPlayerArmour(playerid, Player[playerid][pArmour]);
    
    SetSpawnInfo(playerid, -1, Player[playerid][pSkin], Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ], Player[playerid][pPosA], 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    SetPlayerInterior(playerid, Player[playerid][pInt]);
    SetPlayerVirtualWorld(playerid, Player[playerid][pVW]);

    LimpiarChat(playerid);
    SendClientMessage(playerid, 0xCCCCCC00, "||••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••||");
    Formato(playerid, -1, "· Bienvenido(a) {00ff00}%s {ffffff}estas jugando {00ff00}"SERVER_NAME"{ffffff}, usa {00ff00}/recibir {ffffff}si aun no las recibes.", Nombre(playerid));
    SendClientMessage(playerid, -1, "{ffffff}· Te aconcejamos utilizar {ffff00}/ayuda {ffffff}para mas informacion.");
    SendClientMessage(playerid, -1, "{ffffff}· Actualmente seguimos en {00ff00}desarrollo{ffffff}.");
    SendClientMessage(playerid, 0xCCCCCC00, "||••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••||");
    Formato(playerid, -1, "{ffffff}· Ultima conexion: {00ff00}%s", DOF2_GetString(Cuenta(playerid), "Login"));
    Formato(playerid, -1, "· Eres {00ff00}nivel %d{ffffff}.", GetPlayerScore(playerid));

    // MOSTRAR HUD AL LOGUEARSE COMPLETAMENTE
    ActualizarHUD(playerid);
    return 1;
}

public Congelar(playerid)
{
    TogglePlayerControllable(playerid, false);
    return 1;
}

public Descongelar(playerid)
{
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    return 1;
}

stock CheckTimer(time, ref) {
    new seconds = (time - (gettime() - ref));
    if(ref == 0) return -1;
    else if(seconds <= 0) return 0;
    else return seconds;
}

stock IsNumeric(const string[])
{
    if(string[0] == '0')
        return true;

    return !!strval(string);
}

stock RandomEx(min, max)
{
    return random(max - min) + min;
}

stock Cantidad(value, const text[] = ".")
{
    new Var[20];
    format(Var, sizeof(Var), "%d", value);

    for(new X = strlen(Var) - 3; X > 0; X -= 3)
        strins(Var, text, X);

    return Var;
}

public LimpiarChat(playerid)
{
    for(new i = 0; i < 50; i++) SendClientMessage(playerid, -1, "");
    return 1;
}

public Formato(playerid, color, form[], {Float, _}: ...)
{
    #pragma unused form

    static tmp[1000];
    new t1 = playerid, t2 = color;
    const n4 = -4, n16 = -16, size = sizeof tmp;
    
    #emit stack 28
    #emit push.c size
    #emit push.c tmp
    #emit stack n4
    #emit sysreq.c format
    #emit stack n16

    return (t1 == -1 ? (SendClientMessageToAll(t2, tmp)) : (SendClientMessage(t1, t2, tmp)) );
}

public TD_MSG_NTF(playerid)
{
    ptextdraw_MESSAGE = CreatePlayerTextDraw(playerid, 314.823455, 373.916717, "_");
    PlayerTextDrawLetterSize(playerid, ptextdraw_MESSAGE, 0.288116, 1.296666);
    PlayerTextDrawAlignment(playerid, ptextdraw_MESSAGE, 2);
    PlayerTextDrawColor(playerid, ptextdraw_MESSAGE, -1);
    PlayerTextDrawSetShadow(playerid, ptextdraw_MESSAGE, 1);
    PlayerTextDrawSetOutline(playerid, ptextdraw_MESSAGE, 0);
    PlayerTextDrawBackgroundColor(playerid, ptextdraw_MESSAGE, 255);
    PlayerTextDrawFont(playerid, ptextdraw_MESSAGE, 1);
    PlayerTextDrawSetProportional(playerid, ptextdraw_MESSAGE, 1);

    ptextdraw_NOTIFY = CreatePlayerTextDraw(playerid, 488.199157, 131.249969, "_");
    PlayerTextDrawLetterSize(playerid, ptextdraw_NOTIFY, 0.249472, 1.261666);
    PlayerTextDrawTextSize(playerid, ptextdraw_NOTIFY, 626.881469, 181.999984);
    PlayerTextDrawAlignment(playerid, ptextdraw_NOTIFY, 1);
    PlayerTextDrawColor(playerid, ptextdraw_NOTIFY, -1);
    PlayerTextDrawUseBox(playerid, ptextdraw_NOTIFY, true);
    PlayerTextDrawBoxColor(playerid, ptextdraw_NOTIFY, 100);
    PlayerTextDrawSetShadow(playerid, ptextdraw_NOTIFY, 0);
    PlayerTextDrawSetOutline(playerid, ptextdraw_NOTIFY, 1);
    PlayerTextDrawBackgroundColor(playerid, ptextdraw_NOTIFY, 48);
    PlayerTextDrawFont(playerid, ptextdraw_NOTIFY, 1);
    PlayerTextDrawSetProportional(playerid, ptextdraw_NOTIFY, 1);
    return 1;
}

public ShowPlayerMessageNotification(playerid, message[], seconds)
{
    new local_message[256];
    strmid(local_message, message, 0, strlen(message), sizeof(local_message));

    for(new len = strlen(local_message), pos; pos < len; pos ++)
    {
        switch(local_message[pos])
        {
            case 'à': local_message[pos] = 151; case 'á': local_message[pos] = 152; case 'â': local_message[pos] = 153; case 'ä': local_message[pos] = 154;
            case 'À': local_message[pos] = 128; case 'Á': local_message[pos] = 129; case 'Â': local_message[pos] = 130; case 'Ä': local_message[pos] = 131;
            case 'è': local_message[pos] = 157; case 'é': local_message[pos] = 158; case 'ê': local_message[pos] = 159; case 'ë': local_message[pos] = 160;
            case 'È': local_message[pos] = 134; case 'É': local_message[pos] = 135; case 'Ê': local_message[pos] = 136; case 'Ë': local_message[pos] = 137;
            case 'ì': local_message[pos] = 161; case 'í': local_message[pos] = 162; case 'î': local_message[pos] = 163; case 'ï': local_message[pos] = 164;
            case 'Ì': local_message[pos] = 138; case 'Í': local_message[pos] = 139; case 'Î': local_message[pos] = 140; case 'Ï': local_message[pos] = 141;
            case 'ò': local_message[pos] = 165; case 'ó': local_message[pos] = 166; case 'ô': local_message[pos] = 167; case 'ö': local_message[pos] = 168;
            case 'Ò': local_message[pos] = 142; case 'Ó': local_message[pos] = 143; case 'Ô': local_message[pos] = 144; case 'Ö': local_message[pos] = 145;
            case 'ù': local_message[pos] = 169; case 'ú': local_message[pos] = 170; case 'û': local_message[pos] = 171; case 'ü': local_message[pos] = 172;
            case 'Ù': local_message[pos] = 146; case 'Ú': local_message[pos] = 147; case 'Û': local_message[pos] = 148; case 'Ü': local_message[pos] = 149;
            case 'ñ': local_message[pos] = 174; case 'Ñ': local_message[pos] = 173; case '¡': local_message[pos] = 64;  case '¿': local_message[pos] = 175;
            case '`': local_message[pos] = 177; case '&': local_message[pos] = 38;
        }
    }

    PlayerTextDrawSetString(playerid, ptextdraw_NOTIFY, local_message);
    PlayerTextDrawShow(playerid, ptextdraw_NOTIFY);

    if(seconds) SetTimerEx("HidePlayerMessageNotification", seconds * 1000, false, "i", playerid);
    return 1;
}

public HidePlayerMessageNotification(playerid)
{
    PlayerTextDrawSetString(playerid, ptextdraw_NOTIFY, "_");
    PlayerTextDrawHide(playerid, ptextdraw_NOTIFY);
    return 1;
}

public ShowPlayerMessage(playerid, message[], seconds)
{
    new local_message[256];
    strmid(local_message, message, 0, strlen(message), sizeof(local_message));

    for(new len = strlen(local_message), pos; pos < len; pos ++)
    {
        switch(local_message[pos])
        {
            case 'à': local_message[pos] = 151; case 'á': local_message[pos] = 152; case 'â': local_message[pos] = 153; case 'ä': local_message[pos] = 154;
            case 'À': local_message[pos] = 128; case 'Á': local_message[pos] = 129; case 'Â': local_message[pos] = 130; case 'Ä': local_message[pos] = 131;
            case 'è': local_message[pos] = 157; case 'é': local_message[pos] = 158; case 'ê': local_message[pos] = 159; case 'ë': local_message[pos] = 160;
            case 'È': local_message[pos] = 134; case 'É': local_message[pos] = 135; case 'Ê': local_message[pos] = 136; case 'Ë': local_message[pos] = 137;
            case 'ì': local_message[pos] = 161; case 'í': local_message[pos] = 162; case 'î': local_message[pos] = 163; case 'ï': local_message[pos] = 164;
            case 'Ì': local_message[pos] = 138; case 'Í': local_message[pos] = 139; case 'Î': local_message[pos] = 140; case 'Ï': local_message[pos] = 141;
            case 'ò': local_message[pos] = 165; case 'ó': local_message[pos] = 166; case 'ô': local_message[pos] = 167; case 'ö': local_message[pos] = 168;
            case 'Ò': local_message[pos] = 142; case 'Ó': local_message[pos] = 143; case 'Ô': local_message[pos] = 144; case 'Ö': local_message[pos] = 145;
            case 'ù': local_message[pos] = 169; case 'ú': local_message[pos] = 170; case 'û': local_message[pos] = 171; case 'ü': local_message[pos] = 172;
            case 'Ù': local_message[pos] = 146; case 'Ú': local_message[pos] = 147; case 'Û': local_message[pos] = 148; case 'Ü': local_message[pos] = 149;
            case 'ñ': local_message[pos] = 174; case 'Ñ': local_message[pos] = 173; case '¡': local_message[pos] = 64;  case '¿': local_message[pos] = 175;
            case '`': local_message[pos] = 177; case '&': local_message[pos] = 38;
        }
    }

    PlayerTextDrawSetString(playerid, ptextdraw_MESSAGE, local_message);
    PlayerTextDrawShow(playerid, ptextdraw_MESSAGE);

    if(seconds) SetTimerEx("HidePlayerMessage", seconds * 1000, false, "i", playerid);
    return 1;
}

public HidePlayerMessage(playerid)
{
    PlayerTextDrawSetString(playerid, ptextdraw_MESSAGE, "_");
    PlayerTextDrawHide(playerid, ptextdraw_MESSAGE);
    return 1;
}

public Tutorial1(playerid)
{
   ShowPlayerMessageNotification(playerid, "Pero mira quien esta aqui, bienvenido a la ciudad, te explicaré unas cosas antes de continuar...", 8);
   SetTimerEx("Tutorial2", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial2(playerid)
{
   ShowPlayerMessageNotification(playerid, "Tú sed y hambre están debajo del mapa. Puedes guardar comida y la puedes ver con ~y~/alimentos.", 10);
   SetTimerEx("Tutorial3", 11000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial3(playerid)
{
   ShowPlayerMessageNotification(playerid, "Ya habrás notado que eres ~g~~h~nivel 1~w~, sube de nivel llenando la barrita verde de abajo.", 10);
   SetTimerEx("Tutorial4", 11000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial4(playerid)
{
   ShowPlayerMessageNotification(playerid, "Cada hora recibirás tu ~r~~h~payday.~w~~h~ El payday es un pago por vivir en nuestra ciudad, literal.", 7);
   SetTimerEx("Tutorial5", 8000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial5(playerid)
{
   ShowPlayerMessageNotification(playerid, "Usa ~y~/ayuda~w~~h~ para conocer y entender que estás jugando y lo que se viene para tu personaje.", 8);
   SetTimerEx("Tutorial6", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial6(playerid)
{
   ShowPlayerMessageNotification(playerid, "Te he dado un poco de ~g~~h~dinero~w~, úsalo para comprar cosas dentro de 24/7 o para lo que se te ocurra.", 8);
   SetTimerEx("Tutorial7", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial7(playerid)
{
   ShowPlayerMessageNotification(playerid, "Ahora mismo no tienes ~p~cuenta bancaria~w~~h~, te recomiendo abrir una cuenta porque es necesaria.", 8);
   SetTimerEx("Tutorial8", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial8(playerid)
{
   ShowPlayerMessageNotification(playerid, "Bueno, llegará el tiempo de buscar trabajo, usa ~y~/ayuda trabajos~w~~h~ y empieza a generar dinero.", 8);
   SetTimerEx("Tutorial9", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial9(playerid)
{
   ShowPlayerMessageNotification(playerid, "Habrán algunos trabajos dónde necesitarás ~p~aprender experiencia ~w~~h~para ganar más dinero.", 8);
   SetTimerEx("Tutorial10", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial10(playerid)
{
   ShowPlayerMessageNotification(playerid, "Por supuesto, si quieres una ~p~cuenta premium~w~~h~ usa ~y~/ayuda premium~w~~h~ para ver cómo obtenerla.", 8);
   SetTimerEx("Tutorial11", 9000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial11(playerid)
{
   ShowPlayerMessageNotification(playerid, "Ya por último, usa ~y~/duda~w~~h~ para resolver alguna inquietud que te surga.", 6);
   SetTimerEx("Tutorial12", 7000, false, "i", playerid);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public Tutorial12(playerid)
{
   ShowPlayerMessageNotification(playerid, "Verás mis mensajes en sucesos importantes de tu vida, me voy, buena suerte...", 9);
   PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
   return 1;
}

public TD_GPS_MAP(playerid)
{
    Textdraws_GPS_MAP[0] = CreatePlayerTextDraw(playerid, 483.045318, 194.249984, "LD_SPAC:white");
    PlayerTextDrawBackgroundColor(playerid, Textdraws_GPS_MAP[0], 0);
    PlayerTextDrawFont(playerid, Textdraws_GPS_MAP[0], 4);
    PlayerTextDrawLetterSize(playerid, Textdraws_GPS_MAP[0], 0.000000, 0.000000);
    PlayerTextDrawColor(playerid, Textdraws_GPS_MAP[0], 120);
    PlayerTextDrawSetOutline(playerid, Textdraws_GPS_MAP[0], 0);
    PlayerTextDrawSetProportional(playerid, Textdraws_GPS_MAP[0], 1);
    PlayerTextDrawSetShadow(playerid, Textdraws_GPS_MAP[0], 1);
    PlayerTextDrawUseBox(playerid, Textdraws_GPS_MAP[0], 1);
    PlayerTextDrawBoxColor(playerid, Textdraws_GPS_MAP[0], 255);
    PlayerTextDrawTextSize(playerid, Textdraws_GPS_MAP[0], 148.052719, 176.750000);
    PlayerTextDrawSetSelectable(playerid, Textdraws_GPS_MAP[0], 0);

    Textdraws_GPS_MAP[1] = CreatePlayerTextDraw(playerid, map_td_X, map_td_Y, "samaps:map");
    PlayerTextDrawBackgroundColor(playerid, Textdraws_GPS_MAP[1], 255);
    PlayerTextDrawFont(playerid, Textdraws_GPS_MAP[1], 4);
    PlayerTextDrawLetterSize(playerid, Textdraws_GPS_MAP[1],  0.000000, 0.000000);
    PlayerTextDrawColor(playerid, Textdraws_GPS_MAP[1], -1);
    PlayerTextDrawSetOutline(playerid, Textdraws_GPS_MAP[1], 0);
    PlayerTextDrawSetProportional(playerid, Textdraws_GPS_MAP[1], 1);
    PlayerTextDrawSetShadow(playerid, Textdraws_GPS_MAP[1], 1);
    PlayerTextDrawUseBox(playerid, Textdraws_GPS_MAP[1], 1);
    PlayerTextDrawBoxColor(playerid, Textdraws_GPS_MAP[1], 255);
    PlayerTextDrawTextSize(playerid, Textdraws_GPS_MAP[1], map_td_SIZE_X, map_td_SIZE_Y);
    PlayerTextDrawSetSelectable(playerid, Textdraws_GPS_MAP[1], 0);

    Textdraws_GPS_MAP[2] = CreatePlayerTextDraw(playerid, 557.071899, 194.833297, "Use ~y~/mapa ~w~~h~para salir.");
    PlayerTextDrawAlignment(playerid, Textdraws_GPS_MAP[2], 2);
    PlayerTextDrawBackgroundColor(playerid, Textdraws_GPS_MAP[2], 255);
    PlayerTextDrawFont(playerid, Textdraws_GPS_MAP[2], 1);
    PlayerTextDrawLetterSize(playerid, Textdraws_GPS_MAP[2], 0.201214, 1.121665);
    PlayerTextDrawColor(playerid, Textdraws_GPS_MAP[2], -1);
    PlayerTextDrawSetOutline(playerid, Textdraws_GPS_MAP[2], 0);
    PlayerTextDrawSetProportional(playerid, Textdraws_GPS_MAP[2], 1);
    PlayerTextDrawSetShadow(playerid, Textdraws_GPS_MAP[2], 1);
    PlayerTextDrawSetSelectable(playerid, Textdraws_GPS_MAP[2], 0);
    return 1;
}

public ShowPlayerGpsMap(playerid)
{
    Mapa[playerid] = true;
    PlayerTextDrawShow(playerid, Textdraws_GPS_MAP[0]);
    PlayerTextDrawShow(playerid, Textdraws_GPS_MAP[1]);
    PlayerTextDrawShow(playerid, Textdraws_GPS_MAP[2]);
    UpdatePlayer_GPS_Map(playerid);
    UpdateCp_GPS_Map(playerid);
    return 1;
}

public HidePlayerGpsMap(playerid)
{
    Mapa[playerid] = false;
    PlayerTextDrawHide(playerid, Textdraws_GPS_MAP[0]);
    PlayerTextDrawHide(playerid, Textdraws_GPS_MAP[1]);
    PlayerTextDrawHide(playerid, Textdraws_GPS_MAP[2]);
    PlayerTextDrawHide(playerid, Textdraws_GPS_MAP[3]);
    PlayerTextDrawHide(playerid, Textdraws_GPS_MAP[4]);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return 1;
}

public UpdatePlayer_GPS_Map(playerid)
{
    new Float:pos[3];
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    SetPlayerPoint_GPS_Map(playerid, "hud:radar_waypoint", -1, 6.0, 6.0, pos[0], pos[1]);
    return 1;
}

public UpdateCp_GPS_Map(playerid)
{
    if(CP_Mapa[playerid][0] != 0.0 && CP_Mapa[playerid][1] != 0.0)
    {
        SetPlayerCp_GPS_Map(playerid, "hud:radar_light", -1, 10.0, 10.0, CP_Mapa[playerid][0], CP_Mapa[playerid][1]);
    }
    return 1;
}

public SetPlayerPoint_GPS_Map(playerid, icon[], color, Float:icon_size_X, Float:icon_size_Y, Float:x, Float:y)
{
    new Float:td_X, Float:td_Y;

    if(x > 3000.0) x = 3000.0;
    else if(x < -3000.0) x = -3000.0;

    if(y > 3000.0) y = 3000.0;
    else if(y < -3000.0) y = -3000.0;

    new Float:converted_MAP_SIZE_X = floatdiv(map_td_SIZE_X, 2.0),
        Float:converted_MAP_SIZE_Y = floatdiv(map_td_SIZE_Y, 2.0),
        Float:converted_ICON_SIZE_X = floatdiv(icon_size_X, 2.0),
        Float:converted_ICON_SIZE_Y = floatdiv(icon_size_Y, 2.0);

    td_X = map_td_X + floatmul(floatdiv(converted_MAP_SIZE_X, 3000.0), x) + converted_MAP_SIZE_X - converted_ICON_SIZE_X;
    td_Y = map_td_Y + floatmul(floatdiv(-converted_MAP_SIZE_Y, 3000.0), y) + converted_MAP_SIZE_Y - converted_ICON_SIZE_Y;

    Textdraws_GPS_MAP[3] = CreatePlayerTextDraw(playerid, td_X, td_Y, icon);
    PlayerTextDrawLetterSize(playerid, Textdraws_GPS_MAP[3], 0.160333, 1.280592);
    PlayerTextDrawTextSize(playerid, Textdraws_GPS_MAP[3], icon_size_X, icon_size_Y);
    PlayerTextDrawAlignment(playerid, Textdraws_GPS_MAP[3], 1);
    PlayerTextDrawColor(playerid, Textdraws_GPS_MAP[3], color);
    PlayerTextDrawSetShadow(playerid, Textdraws_GPS_MAP[3], 0);
    PlayerTextDrawSetOutline(playerid, Textdraws_GPS_MAP[3], 0);
    PlayerTextDrawBackgroundColor(playerid, Textdraws_GPS_MAP[3], 255);
    PlayerTextDrawFont(playerid, Textdraws_GPS_MAP[3], 4);
    PlayerTextDrawSetProportional(playerid, Textdraws_GPS_MAP[3], 0);
    PlayerTextDrawShow(playerid, Textdraws_GPS_MAP[3]);
    return 1;
}

public SetPlayerCp_GPS_Map(playerid, icon[], color, Float:icon_size_X, Float:icon_size_Y, Float:x, Float:y)
{
    new Float:tde_X, Float:tde_Y;

    if(x > 3000.0) x = 3000.0;
    else if(x < -3000.0) x = -3000.0;

    if(y > 3000.0) y = 3000.0;
    else if(y < -3000.0) y = -3000.0;

    new Float:converted_MAP_SIZE_Xe = floatdiv(map_tde_SIZE_X, 2.0),
        Float:converted_MAP_SIZE_Ye = floatdiv(map_tde_SIZE_Y, 2.0),
        Float:converted_ICON_SIZE_Xe = floatdiv(icon_size_X, 2.0),
        Float:converted_ICON_SIZE_Ye = floatdiv(icon_size_Y, 2.0);

    tde_X = map_tde_X + floatmul(floatdiv(converted_MAP_SIZE_Xe, 3000.0), x) + converted_MAP_SIZE_Xe - converted_ICON_SIZE_Xe;
    tde_Y = map_tde_Y + floatmul(floatdiv(-converted_MAP_SIZE_Ye, 3000.0), y) + converted_MAP_SIZE_Ye - converted_ICON_SIZE_Ye;

    Textdraws_GPS_MAP[4] = CreatePlayerTextDraw(playerid, tde_X, tde_Y, icon);
    PlayerTextDrawLetterSize(playerid, Textdraws_GPS_MAP[4], 0.160333, 1.280592);
    PlayerTextDrawTextSize(playerid, Textdraws_GPS_MAP[4], icon_size_X, icon_size_Y);
    PlayerTextDrawAlignment(playerid, Textdraws_GPS_MAP[4], 1);
    PlayerTextDrawColor(playerid, Textdraws_GPS_MAP[4], color);
    PlayerTextDrawSetShadow(playerid, Textdraws_GPS_MAP[4], 0);
    PlayerTextDrawSetOutline(playerid, Textdraws_GPS_MAP[4], 0);
    PlayerTextDrawBackgroundColor(playerid, Textdraws_GPS_MAP[4], 255);
    PlayerTextDrawFont(playerid, Textdraws_GPS_MAP[4], 4);
    PlayerTextDrawSetProportional(playerid, Textdraws_GPS_MAP[4], 0);
    PlayerTextDrawShow(playerid, Textdraws_GPS_MAP[4]);
    return 1;
}

public ActualizarHUD(playerid)
{
    if(Player[playerid][Online] == true)
    {
        new string[128];
        format(string, sizeof(string), "%s ~w~[ID: ~b~~h~%d~w~]~n~Nivel: ~g~~h~%d", Nombre(playerid), playerid, GetPlayerScore(playerid));
        
        PlayerTextDrawSetString(playerid, HUD_PlayerInfo[playerid], string);
        PlayerTextDrawShow(playerid, HUD_ServerName[playerid]);
        PlayerTextDrawShow(playerid, HUD_PlayerInfo[playerid]);
    }
    return 1;
}

CMD:ayuda(playerid)
{
    SendClientMessage(playerid, 0x33AAFFFF, "--- Comandos Disponibles ---");
    SendClientMessage(playerid, -1, "/reglas - Muestra las normativas básicas.");
    SendClientMessage(playerid, -1, "/mapa - Abre/Cierra el GPS integrado.");
    SendClientMessage(playerid, -1, "/recibir - Solicita los stats de inicio.");
    SendClientMessage(playerid, -1, "Canales de Rol: /me, /do, /b (OOC), /s (Gritar)");
    return 1;
}

CMD:me(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000FF, "Uso: /me [accion]");
    new str[128];
    format(str, sizeof(str), "* %s %s", Nombre(playerid), params);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
        {
            SendClientMessage(i, 0xC2A2DAFF, str);
        }
    }
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000FF, "Uso: /do [entorno/situacion]");
    new str[128];
    format(str, sizeof(str), "* %s (( %s ))", params, Nombre(playerid));
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
        {
            SendClientMessage(i, 0x31AE33FF, str);
        }
    }
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000FF, "Uso: /b [chat fuera de jugador]");
    new str[128];
    format(str, sizeof(str), "(( [OOC] %s: %s ))", Nombre(playerid), params);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 15.0, x, y, z))
        {
            SendClientMessage(i, 0xBBBBBBFF, str);
        }
    }
    return 1;
}

CMD:s(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000FF, "Uso: /s [gritar]");
    new str[128];
    format(str, sizeof(str), "%s grita: %s!!", Nombre(playerid), params);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
        {
            SendClientMessage(i, -1, str);
        }
    }
    return 1;
}
//************************************************
#include "./modules/p.cmd.inc"