//  SISTEMA DE FACCTIONES
//==============================================================================
CMD:faccion(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES)
    {
        new lista[400], linea[100];
        for(new i = 1; i < MAX_FACCIONES; i++)
        {
            format(linea, sizeof(linea), "%d) %s\n", i, NombreFaccion[i]);
            strcat(lista, linea, sizeof(lista));
        }
        ShowPlayerDialog(playerid, D_FACCION, DIALOG_STYLE_LIST, "{00FF00}FACCIONES DE SAN ANDREAS", lista, "Ver rangos", "Salir");
        return 1;
    }
    format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nTu rango: {2ECC71}%s{FFFFFF}\nEstado: %s\nNomina por hora: {2ECC71}$%d{FFFFFF}\n\nOpciones:", NombreFaccion[fac], RangoFaccion[fac][Player[playerid][pRango]], Player[playerid][pServicio] ? "{2ECC71}En servicio" : "{FF0000}Fuera de servicio", PagoFaccion[fac]);
    ShowPlayerDialog(playerid, D_FACCION, DIALOG_STYLE_LIST, "{00FF00}TU FACION", szString, "Elegir", "Cerrar");
    Player[playerid][pDlg][0] = fac;
    return 1;
}

CMD:rangos(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    new lista[300], linea[80];
    for(new i = 0; i < MAX_RANGOS; i++)
    {
        format(linea, sizeof(linea), "Rango %d: %s\n", i, RangoFaccion[fac][i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_FACCION_RANGOS, DIALOG_STYLE_LIST, "{00FF00}RANGOS", lista, "Cerrar", "");
    return 1;
}

stock AP_ServicioComando(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pServicio])
    {
        Player[playerid][pServicio] = false;
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
        AP_Msg(playerid, C_AMARILLO, "[FACCION]: Has salido de servicio.");
    }
    else
    {
        Player[playerid][pServicio] = true;
        SetPlayerSkin(playerid, SkinFaccion[fac]);
        AP_Msg(playerid, C_VERDE, "[FACCION]: Estas en servicio. Usa /f para hablar con tu faccion.");
    }
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:servicio(playerid) return AP_ServicioComando(playerid);

CMD:f(playerid, params[])
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /f [mensaje]");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != fac) continue;
        format(szString, sizeof(szString), "[FACCION] %s %s: %s", RangoFaccion[fac][Player[playerid][pRango]], NombrePorID(playerid), params);
        AP_Msg(i, C_FAC, szString);
    }
    return 1;
}

CMD:r(playerid, params[])
{
    if(Player[playerid][pRadio] <= 0 && Player[playerid][pItem][ITEM_RADIO] <= 0)
        return AP_Msg(playerid, C_ROJO, "[RADIO]: Necesitas una radio portatil (/usar Radio).");
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /r [mensaje por radio]");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != Player[playerid][pFaccion]) continue;
        if(!Player[i][pServicio]) continue;
        format(szString, sizeof(szString), "[RADIO] %s: %s", NombrePorID(playerid), params);
        AP_Msg(i, C_RADIO, szString);
    }
    return 1;
}

CMD:invitar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /invitar [id]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 4) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 4 o superior.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[FACCION]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(!IsPlayerInRangeOfPoint(dest, 8.0, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]))
        return AP_Msg(playerid, C_ROJO, "[FACCION]: El jugador debe estar cerca de ti.");
    if(Player[dest][pFaccion] != 0) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador ya tiene faccion.");
    Player[dest][pFaccion] = fac;
    Player[dest][pRango] = 0;
    format(szString, sizeof(szString), "[FACCION]: Has invitado a %s a %s.", NombrePorID(dest), NombreFaccion[fac]);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[FACCION]: %s te ha invitado a %s. Usa /faccion para mas informacion.", NombrePorID(playerid), NombreFaccion[fac]);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:expulsar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /expulsar [id]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 4) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 4 o superior.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[FACCION]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(Player[dest][pFaccion] != fac) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no es de tu faccion.");
    Player[dest][pFaccion] = 0;
    Player[dest][pRango] = 0;
    Player[dest][pServicio] = false;
    SetPlayerSkin(dest, Player[dest][pSkin]);
    format(szString, sizeof(szString), "[FACCION]: Has expulsado a %s de la faccion.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, "[FACCION]: Has sido expulsado de la faccion.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:faccionrango(playerid, params[])
{
    new idstr[12], rango[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /faccionrango [id] [rango 0-5]");
    if(!AP_Token(params, idx, rango, sizeof(rango))) return AP_Msg(playerid, C_ROJO, "Uso: /faccionrango [id] [rango 0-5]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 5) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 5 (lider).");
    if(!EsNumerico(idstr) || !EsNumerico(rango)) return AP_Msg(playerid, C_ROJO, "[FACCION]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(rango);
    if(nuevo < 0 || nuevo >= MAX_RANGOS) return AP_Msg(playerid, C_ROJO, "[FACCION]: El rango debe estar entre 0 y 5.");
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(Player[dest][pFaccion] != fac) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no es de tu faccion.");
    Player[dest][pRango] = nuevo;
    format(szString, sizeof(szString), "[FACCION]: %s ahora es %s.", NombrePorID(dest), RangoFaccion[fac][nuevo]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

//==============================================================================
//  POLICIA: ESPOSAR, MULTAR, ARRESTAR
//==============================================================================
CMD:esposar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /esposar [id]");
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede esposar.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(!IsPlayerInRangeOfPoint(dest, 6.0, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]))
        return AP_Msg(playerid, C_ROJO, "[POLICIA]: Debes estar cerca del sospechoso.");
    Player[dest][pEsposado] = true;
    TogglePlayerControllable(dest, false);
    ApplyAnimation(dest, "ped", "cower", 4.0, 1, 0, 0, 1, 0, 1);
    format(szString, sizeof(szString), "[POLICIA]: Has esposado a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, "[POLICIA]: Estas esposado. No puedes moverte.");
    return 1;
}

CMD:desesposar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /desesposar [id]");
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede quitar las esposas.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    Player[dest][pEsposado] = false;
    TogglePlayerControllable(dest, true);
    ClearAnimations(dest);
    AP_Msg(dest, C_VERDE, "[POLICIA]: Te han quitado las esposas.");
    return 1;
}

CMD:multar(playerid, params[])
{
    new idstr[12], monto[12], razon[64];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /multar [id] [monto] [razon]");
    if(!AP_Token(params, idx, monto, sizeof(monto))) return AP_Msg(playerid, C_ROJO, "Uso: /multar [id] [monto] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede multar.");
    if(!EsNumerico(idstr) || !EsNumerico(monto)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Datos invalidos.");
    new dest = strval(idstr), valor = strval(monto);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(valor < 1) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Monto invalido.");
    AP_QuitarDinero(dest, valor);
    Player[dest][pMultas]++;
    format(szString, sizeof(szString), "[POLICIA]: Has multado a %s con $%d. Razon: %s", NombrePorID(dest), valor, razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[POLICIA]: El oficial %s te ha multado con $%d. Razon: %s", NombrePorID(playerid), valor, razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Policia", "Multa emitida.");
    return 1;
}

CMD:arrestar(playerid, params[])
{
    new idstr[12], minutos[8], razon[64];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /arrestar [id] [minutos] [razon]");
    if(!AP_Token(params, idx, minutos, sizeof(minutos))) return AP_Msg(playerid, C_ROJO, "Uso: /arrestar [id] [minutos] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede arrestar.");
    if(!EsNumerico(idstr) || !EsNumerico(minutos)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(minutos);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(!Player[dest][pEsposado]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: El sospechoso debe estar esposado.");
    if(tiempo < 1) tiempo = 1;
    if(tiempo > 30) tiempo = 30;
    Player[dest][pJail] = true;
    Player[dest][pJailTime] = tiempo;
    Player[dest][pEsposado] = false;
    Player[dest][pArrestos]++;
    Player[dest][pWanted] = 0;
    SetPlayerWantedLevel(dest, 0);
    SetPlayerPos(dest, 1533.6067, -1638.8525, 2024.4063);
    SetPlayerFacingAngle(dest, 359.1107);
    SetPlayerInterior(dest, 3);
    SetPlayerVirtualWorld(dest, 0);
    Player[dest][pInt] = 3;
    Player[dest][pVW] = 0;
    GetPlayerPos(dest, Player[dest][pPosX], Player[dest][pPosY], Player[dest][pPosZ]);
    GetPlayerFacingAngle(dest, Player[dest][pPosA]);
    TogglePlayerControllable(dest, true);
    SetTimerEx("AP_Unjail", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[POLICIA]: Has arrestado a %s por %d minutos. Razon: %s", NombrePorID(dest), tiempo, razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[POLICIA]: Has sido arrestado %d minutos. Razon: %s", tiempo, razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Policia", "Arresto realizado.");
    AP_GuardarCuenta(dest);
    return 1;
}

public AP_Unjail(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    Player[playerid][pJail] = false;
    Player[playerid][pJailTime] = 0;
    Player[playerid][pWanted] = 0;
    SetPlayerWantedLevel(playerid, 0);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerPos(playerid, 1541.6305, -1675.1818, 13.5529);
    SetPlayerFacingAngle(playerid, 89.6651);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player[playerid][pInt] = 0;
    Player[playerid][pVW] = 0;
    GetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, Player[playerid][pPosA]);
    TogglePlayerControllable(playerid, true);
    AP_Msg(playerid, C_VERDE, "[POLICIA]: Has cumplido tu condena. Quedas en libertad.");
    AP_GuardarCuenta(playerid);
    return 1;
}

//==============================================================================
//  ANIMACIONES
//==============================================================================
CMD:anim(playerid)
{
    new lista[700], linea[80];
    for(new i = 0; i < 20; i++)
    {
        format(linea, sizeof(linea), "%d) %s\n", i + 1, AnimNombre[i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_ANIMS, DIALOG_STYLE_LIST, "{00FF00}ANIMACIONES", lista, "Usar", "Salir");
    return 1;
}

CMD:pararanim(playerid)
{
    ClearAnimations(playerid);
    AP_Msg(playerid, C_VERDE, "[ANIM]: Animacion detenida.");
    return 1;
}

//==============================================================================
//  VIP
//==============================================================================
CMD:vip(playerid)
{
    format(szString, sizeof(szString), "{00FF00}CUENTA VIP{FFFFFF}\n\nTu nivel VIP: {2ECC71}%d{FFFFFF}\n\nBeneficios actuales:\n{FFFF00}- 20 por ciento extra de dinero en el payday\n- Punto de aparicion en tu casa\n- Prioridad en la cola de entrada\n- Etiqueta VIP en el chat{FFFFFF}\n\nConsigue VIP hablando con la administracion.", Player[playerid][pVIP]);
    ShowPlayerDialog(playerid, D_VIP, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_SHORTCUT" VIP", szString, "Cerrar", "");
    return 1;
}

//==============================================================================
