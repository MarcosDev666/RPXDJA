//  SISTEMA DE ADMINISTRACION POR NIVELES
//==============================================================================
CMD:admin(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    format(szString, sizeof(szString), "{00FF00}PANEL DE ADMINISTRACION{FFFFFF}\nRango: {2ECC71}%s{FFFFFF}\nDeber: %s\n\nEscribe los comandos de moderacion en el chat.\nUsa /admins para ver el staff conectado.", NombreAdmin[Player[playerid][pAdmin]], Player[playerid][pDuty] ? "{2ECC71}En servicio" : "{FF0000}Fuera de servicio");
    ShowPlayerDialog(playerid, D_ADMIN, DIALOG_STYLE_MSGBOX, "{00FF00}PANEL ADMIN", szString, "Cerrar", "");
    return 1;
}

CMD:dameadmin(playerid, params[])
{
    new clave[32];
    new idx = 0;
    if(!AP_Token(params, idx, clave, sizeof(clave))) return AP_Msg(playerid, C_ROJO, "Uso: /dameadmin [clave maestra]");
    if(strcmp(clave, ADMIN_KEY, true) != 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Clave incorrecta.");
    if(!Player[playerid][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes iniciar sesion primero.");
    Player[playerid][pAdmin] = ADM_DUENO;
    new file[64];
    AP_NombreArchivo(playerid, file, sizeof(file));
    AP_Ini_IntSet(file, "Admin", ADM_DUENO);
    AP_Msg(playerid, C_AMARILLO, "[ADMIN]: Ahora eres Dueno del servidor. Cambia la clave maestra en el codigo.");
    AP_Log("Admin", "Auto-ascenso a Dueno con clave maestra.");
    return 1;
}

CMD:haceradmin(playerid, params[])
{
    REQ_ADMIN(ADM_DIRECTOR)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /haceradmin [id] [nivel 0-6]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /haceradmin [id] [nivel 0-6]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 0 || nuevo > ADM_DUENO) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El nivel debe estar entre 0 y 6.");
    if(nuevo >= Player[playerid][pAdmin] && Player[playerid][pAdmin] < ADM_DUENO) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes dar un rango igual o superior al tuyo.");
    Player[dest][pAdmin] = nuevo;
    new file[64];
    AP_NombreArchivo(dest, file, sizeof(file));
    AP_Ini_IntSet(file, "Admin", nuevo);
    format(szString, sizeof(szString), "[ADMIN]: %s ahora es %s.", NombrePorID(dest), NombreAdmin[nuevo]);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[ADMIN]: %s te ha nombrado %s.", NombrePorID(playerid), NombreAdmin[nuevo]);
    AP_Msg(dest, C_VERDE, szString);
    AP_Log("Admin", "Nivel de administrador cambiado.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:adminduty(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(Player[playerid][pDuty])
    {
        Player[playerid][pDuty] = false;
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
        SetPlayerHealth(playerid, 100.0);
        AP_Msg(playerid, C_AMARILLO, "[ADMIN]: Has salido de servicio administrativo.");
    }
    else
    {
        Player[playerid][pDuty] = true;
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        AP_Msg(playerid, C_VERDE, "[ADMIN]: Estas en servicio administrativo.");
    }
    AP_ActualizarHUD(playerid);
    return 1;
}

CMD:admins(playerid)
{
    new total = 0, enlinea[MAX_PLAYERS], n = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        total++;
        enlinea[n++] = i;
    }
    if(total == 0) return AP_Msg(playerid, C_AMARILLO, "[STAFF]: No hay administradores conectados.");
    AP_Msg(playerid, C_AZUL, "--- ADMINISTRACION CONECTADA ---");
    for(new i = 0; i < n; i++)
    {
        format(szString, sizeof(szString), "%s (%d) - %s - %s", NombrePorID(enlinea[i]), enlinea[i], NombreAdmin[Player[enlinea[i]][pAdmin]], Player[enlinea[i]][pDuty] ? "En servicio" : "Fuera de servicio");
        AP_Msg(playerid, -1, szString);
    }
    return 1;
}

CMD:staff(playerid)
{
    new total = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] >= 1) total++;
    }
    format(szString, sizeof(szString), "[STAFF]: Hay %d miembros del staff conectados. Usa /reportar o /duda si necesitas ayuda.", total);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:ir(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ir [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz, Float:pa, interior, vw;
    GetPlayerPos(dest, px, py, pz);
    GetPlayerFacingAngle(dest, pa);
    interior = GetPlayerInterior(dest);
    vw = GetPlayerVirtualWorld(dest);
    if(GetPlayerState(dest) == PLAYER_STATE_DRIVER || GetPlayerState(dest) == PLAYER_STATE_PASSENGER)
    {
        new vid = GetPlayerVehicleID(dest);
        GetVehiclePos(vid, px, py, pz);
        GetVehicleZAngle(vid, pa);
    }
    SetPlayerPos(playerid, px + 1.5, py, pz);
    SetPlayerFacingAngle(playerid, pa);
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);
    format(szString, sizeof(szString), "[ADMIN]: Te has teletransportado con %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:traer(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /traer [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    SetPlayerPos(dest, px + 1.5, py, pz);
    SetPlayerFacingAngle(dest, pa);
    SetPlayerInterior(dest, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(dest, GetPlayerVirtualWorld(playerid));
    format(szString, sizeof(szString), "[ADMIN]: Has traido a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_AMARILLO, "[ADMIN]: Un administrador te ha traido con el.");
    AP_Log("Admin", "Uso de /traer.");
    return 1;
}

CMD:ira(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new xs[16], ys[16], zs[16];
    new idx = 0;
    if(!AP_Token(params, idx, xs, sizeof(xs))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!AP_Token(params, idx, ys, sizeof(ys))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!AP_Token(params, idx, zs, sizeof(zs))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!EsNumerico(xs) || !EsNumerico(ys) || !EsNumerico(zs)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Coordenadas invalidas.");
    SetPlayerPos(playerid, floatstr(xs), floatstr(ys), floatstr(zs));
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Teletransportado.");
    return 1;
}

CMD:kick(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], razon[80];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /kick [id] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[dest][pAdmin] >= Player[playerid][pAdmin]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes expulsar a un rango igual o superior.");
    format(szString, sizeof(szString), "[ADMIN]: Has expulsado a %s. Razon: %s", NombrePorID(dest), razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "Has sido expulsado por %s. Razon: %s", NombrePorID(playerid), razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador expulsado.");
    SetTimerEx("AP_KickInmediato", 800, false, "i", dest);
    return 1;
}

public AP_KickInmediato(playerid) return Kick(playerid);

CMD:ban(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], razon[80];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ban [id] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[dest][pAdmin] >= Player[playerid][pAdmin]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes banear a un rango igual o superior.");
    Player[dest][pBaneado] = true;
    AP_GuardarCuenta(dest);
    format(szString, sizeof(szString), "[ADMIN]: Has baneado a %s. Razon: %s", NombrePorID(dest), razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "Has sido baneado por %s. Razon: %s", NombrePorID(playerid), razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador baneado.");
    SetTimerEx("AP_KickInmediato", 800, false, "i", dest);
    return 1;
}

CMD:desban(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new nombre[MAX_PLAYER_NAME];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /desban [nombre]");
    new file[64];
    AP_NombreRuta(nombre, file, sizeof(file));
    if(!fexist(file)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Esa cuenta no existe.");
    AP_Ini_IntSet(file, "Baned", 0);
    format(szString, sizeof(szString), "[ADMIN]: Cuenta %s desbaneada.", nombre);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Cuenta desbaneada.");
    return 1;
}

CMD:congelar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /congelar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    TogglePlayerControllable(dest, false);
    Player[dest][pCongelado] = true;
    AP_Msg(dest, C_ROJO, "[ADMIN]: Has sido congelado por un administrador.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador congelado.");
    return 1;
}

CMD:descongelar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /descongelar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    TogglePlayerControllable(dest, true);
    Player[dest][pCongelado] = false;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido descongelado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador descongelado.");
    return 1;
}

CMD:matar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /matar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    SetPlayerHealth(dest, 0.0);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador eliminado.");
    return 1;
}

CMD:curar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /curar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    SetPlayerHealth(dest, 100.0);
    SetPlayerArmour(dest, 100.0);
    Player[dest][pHealth] = 100.0;
    Player[dest][pArmour] = 100.0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido curado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador curado.");
    return 1;
}

CMD:revivir(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /revivir [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pDead] = false;
    TogglePlayerControllable(dest, true);
    ClearAnimations(dest);
    SetPlayerHealth(dest, 100.0);
    Player[dest][pHealth] = 100.0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido reanimado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador reanimado.");
    return 1;
}

CMD:slap(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /slap [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(dest, px, py, pz);
    SetPlayerPos(dest, px, py, pz + 12.0);
    PlayerPlaySound(dest, 1190, 0.0, 0.0, 0.0);
    AP_Msg(dest, C_ROJO, "[ADMIN]: Un administrador te ha lanzado por los aires.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador lanzado.");
    return 1;
}

CMD:mute(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], mins[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /mute [id] [minutos]");
    if(!AP_Token(params, idx, mins, sizeof(mins))) format(mins, sizeof(mins), "5");
    if(!EsNumerico(idstr) || !EsNumerico(mins)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(mins);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pMuted] = true;
    Player[dest][pMuteTime] = tiempo;
    SetTimerEx("AP_FinMute", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[ADMIN]: Has silenciado a %s por %d minutos.", NombrePorID(dest), tiempo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

public AP_FinMute(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    Player[playerid][pMuted] = false;
    Player[playerid][pMuteTime] = 0;
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Tu silencio ha terminado.");
    return 1;
}

CMD:desmute(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /desmute [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pMuted] = false;
    Player[dest][pMuteTime] = 0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Puedes volver a escribir.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Silencio retirado.");
    return 1;
}

CMD:carcel(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], mins[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /carcel [id] [minutos]");
    if(!AP_Token(params, idx, mins, sizeof(mins))) format(mins, sizeof(mins), "5");
    if(!EsNumerico(idstr) || !EsNumerico(mins)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(mins);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(tiempo < 1) tiempo = 1;
    Player[dest][pJail] = true;
    Player[dest][pJailTime] = tiempo;
    SetPlayerPos(dest, 1533.6067, -1638.8525, 2024.4063);
    SetPlayerFacingAngle(dest, 359.1107);
    SetPlayerInterior(dest, 3);
    Player[dest][pInt] = 3;
    GetPlayerPos(dest, Player[dest][pPosX], Player[dest][pPosY], Player[dest][pPosZ]);
    GetPlayerFacingAngle(dest, Player[dest][pPosA]);
    SetTimerEx("AP_Unjail", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[ADMIN]: Has encarcelado a %s por %d minutos.", NombrePorID(dest), tiempo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador encarcelado.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:liberar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /liberar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_Unjail(dest);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador liberado.");
    return 1;
}

CMD:dardinero(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /dardinero [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /dardinero [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_DarDinero(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has dado $%d a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Dinero entregado por administracion.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:quitardinero(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /quitardinero [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /quitardinero [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_QuitarDinero(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has quitado $%d a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Dinero retirado por administracion.");
    return 1;
}

CMD:setnivel(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /setnivel [id] [nivel]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /setnivel [id] [nivel]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 1) nuevo = 1;
    Player[dest][pScore] = nuevo;
    SetPlayerScore(dest, nuevo);
    AP_ActualizarHUD(dest);
    format(szString, sizeof(szString), "[ADMIN]: %s ahora es nivel %d.", NombrePorID(dest), nuevo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:darxp(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /darxp [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /darxp [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_DarExperiencia(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has dado %d de experiencia a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:darvip(playerid, params[])
{
    REQ_ADMIN(ADM_DIRECTOR)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /darvip [id] [nivel 0-3]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /darvip [id] [nivel 0-3]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 0 || nuevo > 3) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El nivel VIP debe estar entre 0 y 3.");
    Player[dest][pVIP] = nuevo;
    format(szString, sizeof(szString), "[ADMIN]: %s ahora tiene VIP nivel %d.", NombrePorID(dest), nuevo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:setskin(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], skin[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /setskin [id] [skin]");
    if(!AP_Token(params, idx, skin, sizeof(skin))) return AP_Msg(playerid, C_ROJO, "Uso: /setskin [id] [skin]");
    if(!EsNumerico(idstr) || !EsNumerico(skin)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(skin);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 1 || nuevo > 311) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Skin invalido (1-311).");
    Player[dest][pSkin] = nuevo;
    SetPlayerSkin(dest, nuevo);
    format(szString, sizeof(szString), "[ADMIN]: Has cambiado el skin de %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:dveh(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new modelo[8];
    new idx = 0;
    if(!AP_Token(params, idx, modelo, sizeof(modelo))) return AP_Msg(playerid, C_ROJO, "Uso: /veh [modelo]  (ejemplo: /veh 411)");
    if(!EsNumerico(modelo)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Modelo invalido.");
    new id = strval(modelo);
    if(id < 400 || id > 611) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El modelo debe estar entre 400 y 611.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    new vid = CreateVehicle(id, px + 3.0, py, pz + 1.0, pa, 0, 0, 60000);
    PutPlayerInVehicle(playerid, vid, 0);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo creado.");
    AP_Log("Admin", "Vehiculo administrativo creado.");
    return 1;
}

CMD:destruirveh(playerid)
{
    REQ_ADMIN(ADM_ADMIN)
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes estar en un vehiculo.");
    DestroyVehicle(vid);
    RemovePlayerFromVehicle(playerid);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo destruido.");
    return 1;
}

CMD:flipveh(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes estar en un vehiculo.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetVehiclePos(vid, px, py, pz);
    GetVehicleZAngle(vid, pa);
    SetVehiclePos(vid, px, py, pz + 1.0);
    SetVehicleZAngle(vid, pa);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo enderezado.");
    return 1;
}

CMD:hora(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new h[8];
    new idx = 0;
    if(!AP_Token(params, idx, h, sizeof(h))) return AP_Msg(playerid, C_ROJO, "Uso: /hora [0-23]");
    if(!EsNumerico(h)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Hora invalida.");
    new hora = strval(h);
    if(hora < 0 || hora > 23) return AP_Msg(playerid, C_ROJO, "[ADMIN]: La hora debe estar entre 0 y 23.");
    AP_Hora = hora;
    SetWorldTime(hora);
    format(szString, sizeof(szString), "[ADMIN]: Hora del servidor cambiada a %d:00.", hora);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:clima(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new c[8];
    new idx = 0;
    if(!AP_Token(params, idx, c, sizeof(c))) return AP_Msg(playerid, C_ROJO, "Uso: /clima [0-20]");
    if(!EsNumerico(c)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Clima invalido.");
    new clima = strval(c);
    if(clima < 0 || clima > 20) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El clima debe estar entre 0 y 20.");
    AP_Clima = clima;
    SetWeather(clima);
    format(szString, sizeof(szString), "[ADMIN]: Clima cambiado a %d.", clima);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:anuncio(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /anuncio [texto]");
    format(szString, sizeof(szString), "~b~~h~ANUNCIO OFICIAL~n~~w~%s", params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        GameTextForPlayer(i, szString, 6000, 3);
    }
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Anuncio enviado a todos los jugadores.");
    AP_Log("Admin", "Anuncio global enviado.");
    return 1;
}

CMD:limpiarchat(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        LimpiarChat(i);
    }
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Chat limpiado.");
    return 1;
}

CMD:espectar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /espectar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[playerid][pEspectando] != -1) TogglePlayerSpectating(playerid, false);
    Player[playerid][pEspectando] = dest;
    TogglePlayerSpectating(playerid, true);
    PlayerSpectatePlayer(playerid, dest);
    format(szString, sizeof(szString), "[ADMIN]: Estas especteando a %s. Usa /dejardeespectar.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:dejardeespectar(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    if(Player[playerid][pEspectando] == -1) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No estas especteando a nadie.");
    TogglePlayerSpectating(playerid, false);
    Player[playerid][pEspectando] = -1;
    AP_PrepararSpawn(playerid);
    SpawnPlayer(playerid);
    AP_AplicarDatos(playerid);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Has vuelto a tu cuerpo.");
    return 1;
}

CMD:ver(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ver [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    format(szString, sizeof(szString), "Nombre: %s | Nivel: %d | Dinero: $%d | Banco: $%d | Admin: %s | Faccion: %s | Trabajo: %s",
        NombrePorID(dest), Player[dest][pScore], Player[dest][pMoney], Player[dest][pBank], NombreAdmin[Player[dest][pAdmin]],
        (Player[dest][pFaccion] > 0) ? NombreFaccion[Player[dest][pFaccion]] : "Ninguna",
        (Player[dest][pJob] >= 0) ? NombreTrabajo[Player[dest][pJob]] : "Desempleado");
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:reportes(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(ContadorReportes == 0) return AP_Msg(playerid, C_VERDE, "[STAFF]: No hay reportes pendientes.");
    format(szString, sizeof(szString), "[STAFF]: Hay %d reportes sin responder. Usa /responder [id] [texto].", ContadorReportes);
    AP_Msg(playerid, C_AMARILLO, szString);
    return 1;
}

CMD:dudas(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(ContadorDudas == 0) return AP_Msg(playerid, C_VERDE, "[STAFF]: No hay dudas pendientes.");
    format(szString, sizeof(szString), "[STAFF]: Hay %d dudas sin responder. Usa /responder [id] [texto].", ContadorDudas);
    AP_Msg(playerid, C_AMARILLO, szString);
    return 1;
}

CMD:responder(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12], texto[120];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /responder [id] [texto]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(texto, params, resto, strlen(params), sizeof(texto));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[STAFF]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[STAFF]: Ese jugador no esta conectado.");
    format(szString, sizeof(szString), "[STAFF] %s te responde: %s", NombrePorID(playerid), texto);
    AP_Msg(dest, C_VERDE, szString);
    format(szString, sizeof(szString), "[STAFF]: Has respondido a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    if(Player[dest][pReporte] >= 0) ContadorReportes--;
    if(Player[dest][pDuda] >= 0) ContadorDudas--;
    Player[dest][pReporte] = -1;
    Player[dest][pDuda] = -1;
    if(ContadorReportes < 0) ContadorReportes = 0;
    if(ContadorDudas < 0) ContadorDudas = 0;
    return 1;
}

CMD:borrarcuenta(playerid, params[])
{
    REQ_ADMIN(ADM_DUENO)
    new nombre[MAX_PLAYER_NAME];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /borrarcuenta [nombre]");
    new file[64];
    AP_NombreRuta(nombre, file, sizeof(file));
    if(!fexist(file)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Esa cuenta no existe.");
    fremove(file);
    format(szString, sizeof(szString), "[ADMIN]: Cuenta %s eliminada del servidor.", nombre);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Cuenta eliminada.");
    return 1;
}

CMD:guardar(playerid)
{
    AP_GuardarCuenta(playerid);
    AP_Msg(playerid, C_VERDE, "[SISTEMA]: Tu cuenta ha sido guardada.");
    return 1;
}
