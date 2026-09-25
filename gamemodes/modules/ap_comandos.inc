//==============================================================================
//  COMANDOS GENERALES DEL JUGADOR
//==============================================================================
CMD:ayuda(playerid)
{
    AP_Msg(playerid, C_AZUL, "--- "SERVER_NAME" | AYUDA ---");
    AP_Msg(playerid, -1, "/reglas - Normativas y conceptos de rol.");
    AP_Msg(playerid, -1, "/comandos - Lista completa de comandos.");
    AP_Msg(playerid, -1, "/trabajos - Agencia de empleo (12 trabajos).");
    AP_Msg(playerid, -1, "/infotrabajo - Informacion de tu empleo actual.");
    AP_Msg(playerid, -1, "/banco - Operaciones bancarias.");
    AP_Msg(playerid, -1, "/tienda - Tiendas 24/7 (comida, agua, objetos).");
    AP_Msg(playerid, -1, "/armas - Ammu-Nation.");
    AP_Msg(playerid, -1, "/casas - Mercado inmobiliario.");
    AP_Msg(playerid, -1, "/concesionario - Compra de vehiculos.");
    AP_Msg(playerid, -1, "/faccion - Facciones y rangos.");
    AP_Msg(playerid, -1, "/telefono - Telefono movil.");
    AP_Msg(playerid, -1, "/inventario - Tus objetos.");
    AP_Msg(playerid, -1, "/gps - Marcar un destino en el mapa.");
    AP_Msg(playerid, -1, "/stats - Tus estadisticas.");
    AP_Msg(playerid, -1, "/reportar [texto] - Contactar con el staff.");
    AP_Msg(playerid, -1, "/duda [texto] - Preguntar al staff.");
    return 1;
}

CMD:comandos(playerid)
{
    AP_Msg(playerid, C_AZUL, "--- COMANDOS DISPONIBLES ---");
    AP_Msg(playerid, -1, "ROL: /me /do /b /s /susurrar /gritar /ooc /n /anim /pararanim /rendirse /desmayarse");
    AP_Msg(playerid, -1, "TRABAJO: /trabajos /infotrabajo /tomartrabajo /renunciar /iniciarruta /terminarruta");
    AP_Msg(playerid, -1, "DINERO: /banco /depositar /retirar /transferir /balance /recaudar /venderitem /venderdroga");
    AP_Msg(playerid, -1, "PROPIEDADES: /casas /casa /vendercasa /negocio /veh /estacionar /venderveh /repararveh");
    AP_Msg(playerid, -1, "OBJETOS: /inventario /usar /dar /tirar /cultivar /cosecha");
    AP_Msg(playerid, -1, "TELEFONO: /telefono /numero /llamar /colgar /sms /contactos /agregarcontacto /recargar /911 /medico");
    AP_Msg(playerid, -1, "FACCION: /faccion /rangos /servicio /f /r /invitar /expulsar /faccionrango");
    AP_Msg(playerid, -1, "POLICIA: /esposar /desesposar /multar /arrestar /liberar");
    AP_Msg(playerid, -1, "GENERAL: /id /jugadores /staff /stats /zona /mapa /gps /skin /afk /volver /reloj /vip /guardar");
    AP_Msg(playerid, -1, "LOCALES: /local /skills /hotel /gasolina /seguro /peaje (farmacias, bares, gimnasios, talleres...)");
    AP_Msg(playerid, -1, "COMPANERO: /novia /companero /hablar /regalar /cita /paseo /romper");
    AP_Msg(playerid, -1, "OCIO: /casino /fichas /cambiarfichas /misiones /logros /diario /bolsa /compraraccion /venderaccion");
    AP_Msg(playerid, -1, "PAREJA: /proponer /anillo /divorcio");
    AP_Msg(playerid, -1, "BANCA: /prestamo /pagardeuda");
    if(Player[playerid][pAdmin] >= 1)
    {
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /admin /admins /adminduty /ir /traer /ira /kick /ban /desban /mute /desmute /slap");
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /congelar /descongelar /carcel /liberar /matar /curar /revivir /espectar /dejardeespectar");
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /ver /reportes /dudas /responder /limpiarchat /dveh /destruirveh /flipveh");
        if(Player[playerid][pAdmin] >= ADM_ADMIN)
        {
            AP_Msg(playerid, C_AMARILLO, "ADMIN AVANZADO: /dardinero /quitardinero /setskin /hora /clima /anuncio");
        }
        if(Player[playerid][pAdmin] >= ADM_DIRECTOR)
        {
            AP_Msg(playerid, C_AMARILLO, "DIRECCION: /darvip /haceradmin /borrarcuenta");
        }
    }
    return 1;
}

CMD:reglas(playerid)
{
    ShowPlayerDialog(playerid, D_AYUDA_1, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" - NORMATIVA",
        "{FFFFFF}Bienvenido a {00FF00}"SERVER_NAME"{FFFFFF}, un servidor de rol serio.\n\n{FFFF00}Conceptos basicos:\n{FFFFFF}- IC: informacion dentro del personaje.\n- OOC: informacion fuera del personaje.\n- PG: acciones imposibles en la vida real.\n- MG: usar informacion fuera del juego para beneficiarte.\n- DM: matar sin motivo de rol.\n- CJ: robar vehiculos sin rol previo.\n- RK: vengarse despues de morir.\n- ZZ: huir haciendo zig-zag para evitar balas.",
        "Siguiente", "Salir");
    return 1;
}

CMD:id(playerid, params[])
{
    if(isnull(params))
    {
        format(szString, sizeof(szString), "Tu ID es %d.", playerid);
        return AP_Msg(playerid, C_AZUL, szString);
    }
    new encontrados = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(strfind(NombrePorID(i), params, true) == 0)
        {
            format(szString, sizeof(szString), "%s (ID %d) - Nivel %d", NombrePorID(i), i, Player[i][pScore]);
            AP_Msg(playerid, -1, szString);
            encontrados++;
        }
    }
    if(encontrados == 0) AP_Msg(playerid, C_ROJO, "[ID]: No se encontro ningun jugador con ese nombre.");
    return 1;
}

CMD:jugadores(playerid)
{
    new total = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        total++;
        format(szString, sizeof(szString), "%d) %s - Nivel %d - %s", i, NombrePorID(i), Player[i][pScore],
            (Player[i][pJob] >= 0) ? NombreTrabajo[Player[i][pJob]] : "Desempleado");
        AP_Msg(playerid, -1, szString);
    }
    format(szString2, sizeof(szString2), "[SERVIDOR]: %d jugadores conectados.", total);
    AP_Msg(playerid, C_AZUL, szString2);
    return 1;
}

CMD:stats(playerid, params[])
{
    new dest = playerid;
    new idstr[12];
    new idx = 0;
    if(AP_Token(params, idx, idstr, sizeof(idstr)))
    {
        if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[STATS]: ID invalida.");
        dest = strval(idstr);
        if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[STATS]: Ese jugador no esta conectado.");
    }
    new fac[32], job[32];
    if(Player[dest][pFaccion] > 0) format(fac, sizeof(fac), "%s (%s)", NombreFaccion[Player[dest][pFaccion]], RangoFaccion[Player[dest][pFaccion]][Player[dest][pRango]]);
    else format(fac, sizeof(fac), "Ninguna");
    if(Player[dest][pJob] >= 0) format(job, sizeof(job), "%s", NombreTrabajo[Player[dest][pJob]]);
    else format(job, sizeof(job), "Desempleado");
    format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nNivel: {2ECC71}%d{FFFFFF} (XP %d)\nDinero: {2ECC71}$%d{FFFFFF} | Banco: {33AAF}$%d{FFFFFF}\nTrabajo: {FFFF00}%s{FFFFFF}\nFaccion: {FFFF00}%s{FFFFFF}\nHoras jugadas: {2ECC71}%d{FFFFFF}\nMuertes: %d | Arrestos: %d | Multas: %d | Rutas: %d\nVIP: %d | Telefono: %d",
        NombrePorID(dest), Player[dest][pScore], Player[dest][pXP], Player[dest][pMoney], Player[dest][pBank],
        job, fac, Player[dest][pHoras], Player[dest][pMuertes], Player[dest][pArrestos], Player[dest][pMultas],
        Player[dest][pRutas], Player[dest][pVIP], Player[dest][pTelefono]);
    ShowPlayerDialog(playerid, D_STATS_OTRO, DIALOG_STYLE_MSGBOX, "{00FF00}ESTADISTICAS", szString, "Cerrar", "");
    return 1;
}

CMD:me(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /me [accion]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "* %s %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 20.0, C_ROSA, szString);
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /do [entorno o situacion]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "* %s (( %s ))", params, NombrePorID(playerid));
    AP_MensajeCercano(playerid, 20.0, C_VERDE, szString);
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /b [chat fuera de personaje]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "(( [OOC] %s: %s ))", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 15.0, C_GRIS, szString);
    return 1;
}

CMD:s(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /s [gritar]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s grita: %s!!", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 40.0, -1, szString);
    return 1;
}

CMD:susurrar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /susurrar [texto]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s susurra: %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 6.0, C_GRIS, szString);
    return 1;
}

CMD:gritar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /gritar [texto]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s grita: %s!!", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 50.0, -1, szString);
    return 1;
}

CMD:ooc(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /ooc [mensaje global]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "(( [OOC] %s: %s ))", NombrePorID(playerid), params);
    SendClientMessageToAll(C_OOC, szString);
    return 1;
}

CMD:n(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /n [mensaje cercano]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s: %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 18.0, -1, szString);
    return 1;
}

CMD:reportar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /reportar [texto]");
    if(Player[playerid][pReporte] >= 0) return AP_Msg(playerid, C_ROJO, "[REPORTE]: Ya tienes un reporte abierto. Espera la respuesta.");
    ContadorReportes++;
    Player[playerid][pReporte] = ContadorReportes;
    format(szString, sizeof(szString), "[REPORTE] %s (%d): %s", NombrePorID(playerid), playerid, params);
    AP_Msg(playerid, C_AMARILLO, "[REPORTE]: Tu reporte ha sido enviado al staff. Espera la respuesta.");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        AP_Msg(i, C_ROJO, szString);
    }
    AP_Log("Reportes", szString);
    return 1;
}

CMD:duda(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /duda [texto]");
    if(Player[playerid][pDuda] >= 0) return AP_Msg(playerid, C_ROJO, "[DUDA]: Ya tienes una duda abierta. Espera la respuesta.");
    ContadorDudas++;
    Player[playerid][pDuda] = ContadorDudas;
    format(szString, sizeof(szString), "[DUDA] %s (%d): %s", NombrePorID(playerid), playerid, params);
    AP_Msg(playerid, C_AMARILLO, "[DUDA]: Tu duda ha sido enviada al staff. Espera la respuesta.");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        AP_Msg(i, C_AZUL, szString);
    }
    AP_Log("Dudas", szString);
    return 1;
}

CMD:zona(playerid)
{
    new MapZone:zona = GetPlayerMapZone2D(playerid);
    new nombre[32];
    GetMapZoneName(zona, nombre, sizeof(nombre));
    format(szString, sizeof(szString), "[ZONA]: Estas en %s.", nombre);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:reloj(playerid)
{
    new h, m, s;
    gettime(h, m, s);
    format(szString, sizeof(szString), "[SERVIDOR]: Hora local %02d:%02d:%02d | Hora del juego %02d:00 | Clima %d", h, m, s, AP_Hora, AP_Clima);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:mapa(playerid)
{
    if(MapaAbierto[playerid]) return AP_CerrarMapa(playerid);
    AP_AbrirMapa(playerid);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return 1;
}

CMD:gps(playerid)
{
    new lista[900];
    strcat(lista, "1) Comisaria de Los Santos\n", sizeof(lista));
    strcat(lista, "2) Hospital General\n", sizeof(lista));
    strcat(lista, "3) Banco de San Andreas\n", sizeof(lista));
    strcat(lista, "4) Concesionario\n", sizeof(lista));
    strcat(lista, "5) Ammu-Nation\n", sizeof(lista));
    strcat(lista, "6) 24/7 de Idlewood\n", sizeof(lista));
    strcat(lista, "7) Sede Pizzero\n", sizeof(lista));
    strcat(lista, "8) Sede Basurero\n", sizeof(lista));
    strcat(lista, "9) Sede Camionero\n", sizeof(lista));
    strcat(lista, "10) Sede Pescador\n", sizeof(lista));
    strcat(lista, "11) Zona de cultivo\n", sizeof(lista));
    strcat(lista, "12) Compraventa\n", sizeof(lista));
    strcat(lista, "13) Aeropuerto de Los Santos\n", sizeof(lista));
    strcat(lista, "14) Mi casa\n", sizeof(lista));
    ShowPlayerDialog(playerid, D_ZONA, DIALOG_STYLE_LIST, "{00FF00}GPS - DESTINOS", lista, "Marcar", "Salir");
    return 1;
}

CMD:skin(playerid, params[])
{
    new skin[8];
    new idx = 0;
    if(!AP_Token(params, idx, skin, sizeof(skin))) return AP_Msg(playerid, C_ROJO, "Uso: /skin [id del skin 1-311]");
    if(!EsNumerico(skin)) return AP_Msg(playerid, C_ROJO, "[SKIN]: Skin invalido.");
    new id = strval(skin);
    if(id < 1 || id > 311) return AP_Msg(playerid, C_ROJO, "[SKIN]: El skin debe estar entre 1 y 311.");
    Player[playerid][pSkin] = id;
    SetPlayerSkin(playerid, id);
    AP_Msg(playerid, C_VERDE, "[SKIN]: Apariencia actualizada.");
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:afk(playerid, params[])
{
    if(Player[playerid][pDlg][3]) return AP_Msg(playerid, C_ROJO, "[AFK]: Ya estas en modo ausente.");
    Player[playerid][pDlg][3] = 1;
    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "PED", "IDLE_chat", 4.0, 1, 0, 0, 0, 0, 1);
    if(isnull(params)) format(szString, sizeof(szString), "~y~~h~%s esta ausente (AFK).", NombrePorID(playerid));
    else format(szString, sizeof(szString), "~y~~h~%s esta ausente: %s", NombrePorID(playerid), params);
    AP_MostrarMensaje(playerid, "Estas en modo ausente. Usa /volver para reactivarte.", 6);
    AP_Msg(playerid, C_AMARILLO, "[AFK]: Modo ausente activado. Usa /volver para volver.");
    return 1;
}

CMD:volver(playerid)
{
    if(!Player[playerid][pDlg][3]) return AP_Msg(playerid, C_ROJO, "[AFK]: No estas en modo ausente.");
    Player[playerid][pDlg][3] = 0;
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    AP_Msg(playerid, C_VERDE, "[AFK]: Bienvenido de vuelta.");
    return 1;
}

//==============================================================================
