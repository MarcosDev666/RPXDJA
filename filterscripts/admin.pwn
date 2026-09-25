/*
    ===================================================================
    SISTEMA DE ADMINISTRACION COMPLETO POR RANGOS (FILTERSCRIPT)
    Versión Corregida (Sin errores de compilación / Sin dependencia de sscanf)
    Guardado: DOF2 (scriptfiles/Administradores/)
    Comandos: ZCMD
    ===================================================================
*/

#define FILTERSCRIPT

#include <a_samp>
#include <dof2>
#include <zcmd>

// Configuración de Rangos Administrativos
#define RANGO_MODERADOR     1
#define RANGO_ADMIN_JUNIOR  2
#define RANGO_ADMIN_SENIOR  3
#define RANGO_ADMIN_MASTER  4
#define RANGO_SUB_DIRECTOR  5
#define RANGO_DIRECTOR      6

// Colores del Sistema
#define COLOR_ADMIN         0xFF5555FF // Rojo claro
#define COLOR_AVISO         0xFFFF00FF // Amarillo
#define COLOR_ERROR         0xFF0000FF // Rojo error
#define COLOR_INFO          0x33AAFFFF // Azul claro

// Variable global para almacenar el rango del jugador
new PlayerAdminNivel[MAX_PLAYERS];
new EnServicio[MAX_PLAYERS];

// Stocks e Interfaz con nombres
stock AdminNombre(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock AdminRuta(playerid)
{
    new ruta[128];
    format(ruta, sizeof(ruta), "Administradores/%s.ini", AdminNombre(playerid));
    return ruta;
}

stock ObtenerRangoNombre(nivel)
{
    new rNombre[32];
    switch(nivel)
    {
        case 1: rNombre = "Moderador";
        case 2: rNombre = "Admin Junior";
        case 3: rNombre = "Admin Senior";
        case 4: rNombre = "Admin Master";
        case 5: rNombre = "Sub-Director";
        case 6: rNombre = "Director/Fundador";
        default: rNombre = "Usuario";
    }
    return rNombre;
}

// ==========================================
// CALLBACKS NATIVOS
// ==========================================

public OnFilterScriptInit()
{
    print("\n------------------------------------------------");
    print("  >> Sistema de Admin por Rangos Cargado <<     ");
    print("  >> Compatible con Proxy RP - Guardado DOF2 <<");
    print("------------------------------------------------\n");
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            GuardarAdminStats(i);
        }
    }
    DOF2_Exit();
    print(">> Sistema de Admin por Rangos Descargado Corectamente <<");
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerAdminNivel[playerid] = 0;
    EnServicio[playerid] = 0;

    if(DOF2_FileExists(AdminRuta(playerid)))
    {
        PlayerAdminNivel[playerid] = DOF2_GetInt(AdminRuta(playerid), "NivelAdmin");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    GuardarAdminStats(playerid);
    return 1;
}

forward GuardarAdminStats(playerid);
public GuardarAdminStats(playerid)
{
    if(PlayerAdminNivel[playerid] > 0)
    {
        if(!DOF2_FileExists(AdminRuta(playerid)))
        {
            DOF2_CreateFile(AdminRuta(playerid));
        }
        DOF2_SetInt(AdminRuta(playerid), "NivelAdmin", PlayerAdminNivel[playerid]);
        DOF2_SaveFile();
    }
    else
    {
        if(DOF2_FileExists(AdminRuta(playerid)))
        {
            DOF2_RemoveFile(AdminRuta(playerid));
        }
    }
    return 1;
}

stock EnviarChatAdmin(color, const texto[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerAdminNivel[i] > 0)
        {
            SendClientMessage(i, color, texto);
        }
    }
    return 1;
}

// ==========================================
// COMANDOS DE RANGO 6 (DIRECTOR / EXCLUSIVOS DESDE RCON)
// ==========================================

CMD:daradmin(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_DIRECTOR && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No tienes permiso para usar este comando.");

    new targetid, nivel;
    // Remplazo de sscanf usando tokens nativos
    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /daradmin [ID_Jugador] [Nivel (0-6)]");

    new pos = strfind(params, " ", true);
    new str_target[32], str_nivel[32];
    strmid(str_target, params, 0, pos);
    strmid(str_nivel, params, pos + 1, strlen(params));
    
    targetid = strval(str_target);
    nivel = strval(str_nivel);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] El jugador seleccionado no está conectado.");

    if(nivel < 0 || nivel > 6) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Rango inválido. Elige un nivel del 0 al 6.");

    PlayerAdminNivel[targetid] = nivel;
    GuardarAdminStats(targetid);

    new str[144];
    format(str, sizeof(str), "[ADMIN] El Director %s te ha asignado el rango: %s (Nivel %d).", AdminNombre(playerid), ObtenerRangoNombre(nivel), nivel);
    SendClientMessage(targetid, COLOR_INFO, str);

    format(str, sizeof(str), "[ADMIN] Le diste el rango %s a %s.", ObtenerRangoNombre(nivel), AdminNombre(targetid));
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}

// ==========================================
// COMANDOS GENERALES DE ADMIN (RANGO 1 EN ADELANTE)
// ==========================================

CMD:a(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_MODERADOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No eres parte del Staff.");

    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /a [Texto del mensaje]");

    new str[144];
    format(str, sizeof(str), "* [Chat Staff] (%s) %s: %s", ObtenerRangoNombre(PlayerAdminNivel[playerid]), AdminNombre(playerid), params);
    EnviarChatAdmin(COLOR_ADMIN, str);
    return 1;
}

CMD:duty(playerid)
{
    if(PlayerAdminNivel[playerid] < RANGO_MODERADOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No eres parte del Staff.");

    new str[144];
    if(EnServicio[playerid] == 0)
    {
        EnServicio[playerid] = 1;
        SetPlayerColor(playerid, COLOR_ADMIN); 
        format(str, sizeof(str), "[Staff] El %s %s ahora está EN SERVICIO (/ayuda staff).", ObtenerRangoNombre(PlayerAdminNivel[playerid]), AdminNombre(playerid));
        SendClientMessageToAll(COLOR_ADMIN, str);
    }
    else
    {
        EnServicio[playerid] = 0;
        SetPlayerColor(playerid, -1); 
        format(str, sizeof(str), "[Staff] El %s %s ahora está FUERA DE SERVICIO.", ObtenerRangoNombre(PlayerAdminNivel[playerid]), AdminNombre(playerid));
        SendClientMessageToAll(COLOR_AVISO, str);
    }
    return 1;
}

CMD:kick(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_MODERADOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No tienes permiso para usar este comando.");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /kick [ID] [Razon]");

    new pos = strfind(params, " ", true);
    new str_target[32], razon[64];
    strmid(str_target, params, 0, pos);
    strmid(razon, params, pos + 1, strlen(params));

    new targetid = strval(str_target);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    if(PlayerAdminNivel[targetid] >= PlayerAdminNivel[playerid] && playerid != targetid)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No puedes expulsar a un administrador de tu mismo rango o superior.");

    new str[144];
    format(str, sizeof(str), "[KICK] %s ha sido expulsado por el Administrador %s. Razón: %s", AdminNombre(targetid), AdminNombre(playerid), razon);
    SendClientMessageToAll(COLOR_ERROR, str);
    
    Kick(targetid);
    return 1;
}

// ==========================================
// COMANDOS DE RANGO 2 (ADMIN JUNIOR EN ADELANTE)
// ==========================================

CMD:goto(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_JUNIOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 2 (Admin Junior) o superior.");

    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /goto [ID_Jugador]");

    new targetid = strval(params);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    new Float:x, Float:y, Float:z, intid, vwid;
    GetPlayerPos(targetid, x, y, z);
    intid = GetPlayerInterior(targetid);
    vwid = GetPlayerVirtualWorld(targetid);

    SetPlayerPos(playerid, x + 1.0, y, z); 
    SetPlayerInterior(playerid, intid);
    SetPlayerVirtualWorld(playerid, vwid);
    
    new str[128];
    format(str, sizeof(str), "Te has teletransportado hacia el jugador %s.", AdminNombre(targetid));
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}

CMD:gethere(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_JUNIOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 2 (Admin Junior) o superior.");

    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /gethere [ID_Jugador]");

    new targetid = strval(params);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    new Float:x, Float:y, Float:z, intid, vwid;
    GetPlayerPos(playerid, x, y, z);
    intid = GetPlayerInterior(playerid);
    vwid = GetPlayerVirtualWorld(playerid);

    SetPlayerPos(targetid, x + 1.0, y, z);
    SetPlayerInterior(targetid, intid);
    SetPlayerVirtualWorld(targetid, vwid);

    new str[128];
    format(str, sizeof(str), "Has traído al jugador %s hacia tu posición actual.", AdminNombre(targetid));
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}

// ==========================================
// COMANDOS DE RANGO 3 (ADMIN SENIOR EN ADELANTE)
// ==========================================

CMD:ban(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_SENIOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 3 (Admin Senior) o superior.");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /ban [ID] [Razon]");

    new pos = strfind(params, " ", true);
    new str_target[32], razon[64];
    strmid(str_target, params, 0, pos);
    strmid(razon, params, pos + 1, strlen(params));

    new targetid = strval(str_target);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    if(PlayerAdminNivel[targetid] >= PlayerAdminNivel[playerid])
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No puedes banear a miembros del Staff superiores o iguales.");

    new str[144];
    format(str, sizeof(str), "[BAN] %s ha sido BANEA-DO del servidor por %s. Razón: %s", AdminNombre(targetid), AdminNombre(playerid), razon);
    SendClientMessageToAll(COLOR_ERROR, str);

    BanEx(targetid, razon);
    return 1;
}

CMD:veh(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_SENIOR) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 3 (Admin Senior) o superior.");

    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /veh [ID_Modelo_Vehiculo (400-611)]");

    new modelid = strval(params);

    if(modelid < 400 || modelid > 611) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] ID de vehículo inválido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new carid = CreateVehicle(modelid, x, y, z + 1.0, a, -1, -1, 60000);
    PutPlayerInVehicle(playerid, carid, 0); 
    LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
    SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid));

    SendClientMessage(playerid, COLOR_INFO, "Vehículo administrativo creado con éxito.");
    return 1;
}

// ==========================================
// COMANDOS DE RANGO 4 Y 5 (ADMIN MASTER / SUB-DIRECTOR)
// ==========================================

CMD:destruirveh(playerid)
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_MASTER) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 4 (Admin Master) o superior.");

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Debes estar dentro del vehículo que quieres eliminar.");

    new carid = GetPlayerVehicleID(playerid);
    DestroyVehicle(carid);
    SendClientMessage(playerid, COLOR_INFO, "Vehículo destruido.");
    return 1;
}

CMD:setskin(playerid, params[])
{
    if(PlayerAdminNivel[playerid] < RANGO_ADMIN_MASTER) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Requieres Rango 4 (Admin Master) o superior.");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /setskin [ID] [ID_Skin]");

    new pos = strfind(params, " ", true);
    new str_target[32], str_skin[32];
    strmid(str_target, params, 0, pos);
    strmid(str_skin, params, pos + 1, strlen(params));

    new targetid = strval(str_target);
    new skinid = strval(str_skin);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    if(skinid < 0 || skinid > 311) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] ID de Skin inválido.");

    SetPlayerSkin(targetid, skinid);
    
    new str[128];
    format(str, sizeof(str), "El administrador %s ha cambiado tu skin a la ID: %d.", AdminNombre(playerid), skinid);
    SendClientMessage(targetid, COLOR_INFO, str);
    return 1;
}

// ==========================================
// COMANDO DE INFORMACION DE COMANDOS STAFF
// ==========================================
CMD:admins(playerid)
{
    new count = 0, str[128];
    SendClientMessage(playerid, COLOR_INFO, "======== STAFF EN LINEA ========");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerAdminNivel[i] > 0)
        {
            format(str, sizeof(str), "* %s (ID: %d) - Rango: %s [%s]", AdminNombre(i), i, ObtenerRangoNombre(PlayerAdminNivel[i]), (EnServicio[i] == 1) ? ("{00FF00}En Servicio{33AAFF}") : ("{FF0000}Fuera de Servicio{33AAFF}"));
            SendClientMessage(playerid, COLOR_INFO, str);
            count++;
        }
    }
    if(count == 0) SendClientMessage(playerid, -1, "No hay administradores conectados en este momento.");
    SendClientMessage(playerid, COLOR_INFO, "================================");
    return 1;
}