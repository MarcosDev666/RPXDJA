/*
    ===================================================================
    FILTERSCRIPT DE COMANDOS COMUNITARIOS (DUDA, REPORTAR, TWITTER, ETC)
    Creado para: Proxy Roleplay
    Comandos: ZCMD
    ===================================================================
*/

#define FILTERSCRIPT

#include <a_samp>
#include <zcmd>

// Colores del Sistema
#define COLOR_DUDA          0x00FF00FF // Verde
#define COLOR_REPORTAR      0xFFFF00FF // Amarillo
#define COLOR_TWITTER       0x00ACEEFF // Azul Twitter
#define COLOR_ANUNCIO       0xFF9900FF // Naranja Anuncio
#define COLOR_OOC           0xBBBBBBFF // Gris Chat Local OOC
#define COLOR_ERROR         0xFF0000FF // Rojo Error
#define COLOR_INFO          0x33AAFFFF // Azul Informativo

// Variables remotas del sistema de administración (Compatibilidad)
// Nota: Usamos "import" de manera lógica compartiendo la lectura del nivel de admin
// Si usas PVars (Player Variables) es más fácil conectar ambos FS.
#define PVAR_ADMIN_NIVEL    "NivelAdmin"
#define PVAR_ADMIN_DUTY     "EnServicio"

// Stock para obtener el nombre del jugador rápido
stock UserNombre(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

// Enviar un mensaje a todos los administradores en servicio
stock EnviarAStaff(color, const texto[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            // Detecta si es admin leyendo la PVar o la variable del otro FS si están integrados
            if(GetPVarInt(i, PVAR_ADMIN_NIVEL) > 0)
            {
                SendClientMessage(i, color, texto);
            }
        }
    }
    return 1;
}

public OnFilterScriptInit()
{
    print("\n------------------------------------------------");
    print("  >> FS Comandos Comunitarios Cargado <<        ");
    print("  >> (/duda, /reportar, /twitter, /b, /an) <<   ");
    print("------------------------------------------------\n");
    return 1;
}

// ==========================================
// COMANDO: /DUDA (Para canales de soporte)
// ==========================================
CMD:duda(playerid, params[])
{
    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /duda [Escribe aquí tu pregunta o inquietud]");

    new str[144];
    // Mensaje para el jugador
    format(str, sizeof(str), "[DUDA] Enviada: %s. Espera a que un Moderador responda.", params);
    SendClientMessage(playerid, COLOR_INFO, str);

    // Mensaje para el Staff en línea
    format(str, sizeof(str), "[SOPORTE] %s (ID: %d) duda: %s", UserNombre(playerid), playerid, params);
    EnviarAStaff(COLOR_DUDA, str);
    return 1;
}

// ==========================================
// COMANDO: /REPORTAR (Para denunciar antirrol o cheats)
// ==========================================
CMD:reportar(playerid, params[])
{
    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /reportar [ID/Nombre] [Razón del reporte]");

    new pos = strfind(params, " ", true);
    new str_target[32], razon[96];
    strmid(str_target, params, 0, pos);
    strmid(razon, params, pos + 1, strlen(params));

    new targetid = strval(str_target);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] El jugador que intentas reportar no está en línea.");

    new str[144];
    // Confirmación al usuario
    format(str, sizeof(str), "[REPORTE] Has reportado a %s. El staff evaluará la situación.", UserNombre(targetid));
    SendClientMessage(playerid, COLOR_INFO, str);

    // Alerta roja/amarilla para los administradores
    format(str, sizeof(str), "[REPORTE] (%d) %s reportó a (%d) %s. Razón: %s", playerid, UserNombre(playerid), targetid, UserNombre(targetid), razon);
    EnviarAStaff(COLOR_REPORTAR, str);
    return 1;
}

// ==========================================
// COMANDO: /TWITTER (Red Social Global IC/OOC)
// ==========================================
CMD:twitter(playerid, params[])
{
    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /twitter [Escribe tu tweet]");

    new str[144];
    // Formato estilo red social moderna [Twitter] @Nombre_Apellido: Mensaje
    format(str, sizeof(str), "[Twitter] @%s: %s", UserNombre(playerid), params);
    SendClientMessageToAll(COLOR_TWITTER, str);
    return 1;
}

// ==========================================
// COMANDO: /ANUNCIO (Exclusivo para avisos importantes)
// ==========================================
CMD:anuncio(playerid, params[])
{
    // Solo permitimos usarlo si tiene nivel administrativo guardado en la PVar
    if(GetPVarInt(playerid, PVAR_ADMIN_NIVEL) < 1 && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Solo el Staff o usuarios autorizados pueden lanzar anuncios globales.");

    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /anuncio [Texto del aviso gubernamental/administrativo]");

    new str[144];
    format(str, sizeof(str), "[ANUNCIO] %s: %s", UserNombre(playerid), params);
    SendClientMessageToAll(COLOR_ANUNCIO, str);
    return 1;
}

// Alias corto para /anuncio -> /an
CMD:an(playerid, params[])
{
    return cmd_anuncio(playerid, params);
}

// ==========================================
// COMANDO: /B (Chat Local Fuera de Jugador - OOC)
// ==========================================
CMD:b(playerid, params[])
{
    if(isnull(params)) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /b [Texto fuera de jugador / OOC]");

    new str[144];
    format(str, sizeof(str), "(( [OOC] %s: %s ))", UserNombre(playerid), params);
    
    // Obtener la posición del jugador para enviarlo solo a los que estén cerca (Chat Local - Rango 20 metros)
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
        {
            // Comprobamos que estén en el mismo mundo virtual e interior
            if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i))
            {
                SendClientMessage(i, COLOR_OOC, str);
            }
        }
    }
    return 1;
}

// ==========================================
// COMANDO ADICIONAL: /RE (Para que el staff responda dudas)
// ==========================================
CMD:re(playerid, params[])
{
    if(GetPVarInt(playerid, PVAR_ADMIN_NIVEL) < 1 && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No eres parte del Staff.");

    if(strfind(params, " ", true) == -1) 
        return SendClientMessage(playerid, COLOR_ERROR, "Uso: /re [ID_Jugador] [Respuesta a su duda]");

    new pos = strfind(params, " ", true);
    new str_target[32], respuesta[96];
    strmid(str_target, params, 0, pos);
    strmid(respuesta, params, pos + 1, strlen(params));

    new targetid = strval(str_target);

    if(!IsPlayerConnected(targetid)) 
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] El jugador ya no está conectado.");

    new str[144];
    // Mensaje directo al usuario que preguntó
    format(str, sizeof(str), "[SOPORTE] El Administrador %s te responde: %s", UserNombre(playerid), respuesta);
    SendClientMessage(targetid, COLOR_DUDA, str);

    // Feedback al administrador
    format(str, sizeof(str), "[SOPORTE] Le respondiste a %s: %s", UserNombre(targetid), respuesta);
    SendClientMessage(playerid, COLOR_INFO, str);
    return 1;
}