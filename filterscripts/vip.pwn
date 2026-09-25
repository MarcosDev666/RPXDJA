/*
    ===================================================================
    FILTERSCRIPT DE SISTEMA VIP Y COINS PREMIUM
    Creado para: Proxy Roleplay
    Guardado: DOF2 (scriptfiles/VIP/)
    Comandos: ZCMD (Sin sscanf externo para evitar errores)
    ===================================================================
*/

#define FILTERSCRIPT

#include <a_samp>
#include <dof2>
#include <zcmd>

// Configuración de Niveles VIP
#define VIP_NINGUNO         0
#define VIP_BRONCE          1
#define VIP_PLATA           2
#define VIP_ORO             3

// Colores
#define COLOR_VIP           0x00FFCCFF // Turquesa VIP
#define COLOR_COINS         0xF1C40FFF // Dorado Coins
#define COLOR_ERROR         0xFF0000FF 
#define COLOR_INFO          0x33AAFFFF 
#define COLOR_AVISO         0xFFFF00FF

// Variables del Jugador
new PlayerCoins[MAX_PLAYERS];
new PlayerVipNivel[MAX_PLAYERS];

// Variable remota de compatibilidad con tu sistema de Admin
#define PVAR_ADMIN_NIVEL    "NivelAdmin"

// ==========================================
// STOCKS AUXILIARES
// ==========================================

stock VipNombre(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock VipRuta(playerid)
{
    new ruta[128];
    format(ruta, sizeof(ruta), "VIP/%s.ini", VipNombre(playerid));
    return ruta;
}

stock ObtenerVipRango(nivel)
{
    new vNombre[32];
    switch(nivel)
    {
        case 1: vNombre = "{CD7F32}VIP Bronce{00FFCC}";
        case 2: vNombre = "{C0C0C0}VIP Plata{00FFCC}";
        case 3: vNombre = "{FFD700}VIP Oro{00FFCC}";
        default: vNombre = "Ninguno";
    }
    return vNombre;
}

// ==========================================
// CALLBACKS
// ==========================================

public OnFilterScriptInit()
{
    print("\n------------------------------------------------");
    print("  >> Sistema de VIP & Coins Cargado <<          ");
    print("  >> Guardado independiente en scriptfiles/VIP/<<");
    print("------------------------------------------------\n");
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            GuardarVipStats(i);
        }
    }
    DOF2_Exit();
    print(">> Sistema de VIP & Coins Descargado <<");
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerCoins[playerid] = 0;
    PlayerVipNivel[playerid] = VIP_NINGUNO;

    // Cargar datos premium
    if(DOF2_FileExists(VipRuta(playerid)))
    {
        PlayerCoins[playerid] = DOF2_GetInt(VipRuta(playerid), "Coins");
        PlayerVipNivel[playerid] = DOF2_GetInt(VipRuta(playerid), "NivelVip");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    GuardarVipStats(playerid);
    return 1;
}

forward GuardarVipStats(playerid);
public GuardarVipStats(playerid)
{
    if(PlayerCoins[playerid] > 0 || PlayerVipNivel[playerid] > 0)
    {
        if(!DOF2_FileExists(VipRuta(playerid)))
        {
            DOF2_CreateFile(VipRuta(playerid));
        }
        DOF2_SetInt(VipRuta(playerid), "Coins", PlayerCoins[playerid]);
        DOF2_SetInt(VipRuta(playerid), "NivelVip", PlayerVipNivel[playerid]);
        DOF2_SaveFile();
    }
    return 1;
}

// ==========================================
// COMANDOS ADMINISTRATIVOS (DAR COINS / VIP)
// ==========================================

CMD:darcoins(playerid, params[])
{
    // Verifica si es admin desde la PVar compartida o si es RCON
    if(GetPVarInt(playerid, PVAR_ADMIN_NIVEL) < 5 && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No tienes rango administrativo suficiente (Rango 5+).");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /darcoins [ID_Jugador] [Cantidad]");

    new pos = strfind(params, " ", true);
    new str_target[32], str_cantidad[32];
    strmid(str_target, params, 0, pos);
    strmid(str_cantidad, params, pos + 1, strlen(params));

    new targetid = strval(str_target);
    new cantidad = strval(str_cantidad);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    if(cantidad <= 0) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Cantidad inválida.");

    PlayerCoins[targetid] += cantidad;
    GuardarVipStats(targetid);

    new str[144];
    format(str, sizeof(str), "[TIENDA] El Administrador %s te ha otorgado %d Coins Proxy.", VipNombre(playerid), cantidad);
    SendClientMessage(targetid, COLOR_COINS, str);

    format(str, sizeof(str), "[TIENDA] Le diste %d Coins a %s.", cantidad, VipNombre(targetid));
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}

CMD:darvip(playerid, params[])
{
    if(GetPVarInt(playerid, PVAR_ADMIN_NIVEL) < 5 && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No tienes rango administrativo suficiente (Rango 5+).");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /darvip [ID_Jugador] [Nivel VIP (1:Bronce, 2:Plata, 3:Oro)]");

    new pos = strfind(params, " ", true);
    new str_target[32], str_nivel[32];
    strmid(str_target, params, 0, pos);
    strmid(str_nivel, params, pos + 1, strlen(params));

    new targetid = strval(str_target);
    new nivel = strval(str_nivel);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Jugador no conectado.");

    if(nivel < 0 || nivel > 3) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Nivel VIP inválido (0 para quitar, 1-3 para otorgar).");

    PlayerVipNivel[targetid] = nivel;
    GuardarVipStats(targetid);

    new str[144];
    if(nivel > 0)
    {
        format(str, sizeof(str), "[VIP] El Administrador %s te ha otorgado el rango %s.", VipNombre(playerid), ObtenerVipRango(nivel));
        SendClientMessage(targetid, COLOR_VIP, str);
    }
    else
    {
        SendClientMessage(targetid, COLOR_ERROR, "[VIP] Tu membresía VIP ha sido removida por la administración.");
    }

    format(str, sizeof(str), "[VIP] Modificaste el estado VIP de %s a nivel %d.", VipNombre(targetid), nivel);
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}

// ==========================================
// COMANDOS DE USUARIO / SISTEMA PREMIUM
// ==========================================

CMD:misdatos(playerid)
{
    new str[128];
    SendClientMessage(playerid, COLOR_INFO, "========= MIS DATOS PREMIUM =========");
    format(str, sizeof(str), "* Cuenta VIP: %s", ObtenerVipRango(PlayerVipNivel[playerid]));
    SendClientMessage(playerid, -1, str);
    format(str, sizeof(str), "* Coins Disponibles: {F1C40F}%d Coins", PlayerCoins[playerid]);
    SendClientMessage(playerid, -1, str);
    SendClientMessage(playerid, COLOR_INFO, "=====================================");
    return 1;
}

// Chat exclusivo para miembros VIP de cualquier rango
CMD:v(playerid, params[])
{
    if(PlayerVipNivel[playerid] == VIP_NINGUNO)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Este canal es exclusivo para miembros VIP (/tiendavip).");

    if(isnull(params))
        return SendClientMessage(playerid, COLOR_AVISO, "Uso: /v [Mensaje del chat VIP]");

    new str[144];
    format(str, sizeof(str), "* [Chat VIP] %s %s (ID: %d): %s", ObtenerVipRango(PlayerVipNivel[playerid]), VipNombre(playerid), playerid, params);
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && (PlayerVipNivel[i] > 0 || GetPVarInt(i, PVAR_ADMIN_NIVEL) > 0))
        {
            SendClientMessage(i, COLOR_VIP, str); // Lo ven los VIPs y los Admins para moderar
        }
    }
    return 1;
}

// ==========================================
// SISTEMA DE TIENDA POR DIALOGOS (COINS)
// ==========================================

#define DIALOG_TIENDA_VIP 9945

CMD:tiendavip(playerid)
{
    new string[512];
    strcat(string, "Artículo\tPrecio (Coins)\n");
    strcat(string, "{CD7F32}Membresía VIP Bronce{FFFFFF}\t50 Coins\n");
    strcat(string, "{C0C0C0}Membresía VIP Plata{FFFFFF}\t100 Coins\n");
    strcat(string, "{FFD700}Membresía VIP Oro{FFFFFF}\t150 Coins\n");
    strcat(string, "{00FF00}Paquete de Dinero ($50,000){FFFFFF}\t30 Coins\n");
    strcat(string, "{33AAFF}Curación Completa (Vida + Chaleco){FFFFFF}\t5 Coins");

    new titulo[64];
    format(titulo, sizeof(titulo), "Tienda Coins - Tus Coins: %d", PlayerCoins[playerid]);

    ShowPlayerDialog(playerid, DIALOG_TIENDA_VIP, DIALOG_STYLE_TABLIST_HEADERS, titulo, string, "Comprar", "Cerrar");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_TIENDA_VIP)
    {
        if(!response) return 1; // Si cancela o cierra

        switch(listitem)
        {
            case 0: // VIP Bronce
            {
                if(PlayerCoins[playerid] < 50) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] No tienes suficientes Coins (Cuestan 50).");
                if(PlayerVipNivel[playerid] >= VIP_BRONCE) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] Ya tienes este rango o uno superior.");
                
                PlayerCoins[playerid] -= 50;
                PlayerVipNivel[playerid] = VIP_BRONCE;
                SendClientMessage(playerid, COLOR_VIP, "[Compra exitosa] Ahora eres miembro VIP Bronce, gracias por apoyar al servidor.");
            }
            case 1: // VIP Plata
            {
                if(PlayerCoins[playerid] < 100) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] No tienes suficientes Coins (Cuestan 100).");
                if(PlayerVipNivel[playerid] >= VIP_PLATA) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] Ya tienes este rango o uno superior.");
                
                PlayerCoins[playerid] -= 100;
                PlayerVipNivel[playerid] = VIP_PLATA;
                SendClientMessage(playerid, COLOR_VIP, "[Compra exitosa] Ahora eres miembro VIP Plata, gracias por apoyar al servidor.");
            }
            case 2: // VIP Oro
            {
                if(PlayerCoins[playerid] < 150) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] No tienes suficientes Coins (Cuestan 150).");
                if(PlayerVipNivel[playerid] >= VIP_ORO) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] Ya tienes el rango máximo.");
                
                PlayerCoins[playerid] -= 150;
                PlayerVipNivel[playerid] = VIP_ORO;
                SendClientMessage(playerid, COLOR_VIP, "[Compra exitosa] ¡Eres miembro VIP Oro! Disfruta tus máximos beneficios.");
            }
            case 3: // Paquete Dinero
            {
                if(PlayerCoins[playerid] < 30) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] No tienes suficientes Coins (Cuestan 30).");
                
                PlayerCoins[playerid] -= 30;
                GivePlayerMoney(playerid, 50000);
                SendClientMessage(playerid, COLOR_COINS, "[Compra exitosa] Has canjeado 30 Coins por $50,000 en efectivo.");
            }
            case 4: // Kit Curación
            {
                if(PlayerCoins[playerid] < 5) return SendClientMessage(playerid, COLOR_ERROR, "[Tienda] No tienes suficientes Coins (Cuestan 5).");
                
                PlayerCoins[playerid] -= 5;
                SetPlayerHealth(playerid, 100.0);
                SetPlayerArmour(playerid, 100.0);
                SendClientMessage(playerid, COLOR_INFO, "[Compra exitosa] Tu vida y chaleco han sido restaurados al 100%.");
            }
        }
        GuardarVipStats(playerid);
        return 1;
    }
    return 0;
}