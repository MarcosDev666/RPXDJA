//  UTILIDAD: MENSAJE A JUGADORES CERCANOS
//==============================================================================
stock AP_MensajeCercano(playerid, Float:distancia, color, const texto[])
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(!IsPlayerInRangeOfPoint(i, distancia, px, py, pz)) continue;
        SendClientMessage(i, color, texto);
    }
    return 1;
}

//==============================================================================
//  DESTINOS DEL GPS
//==============================================================================
new const Float:GPSDestinos[14][3] =
{
    {1544.0000, -1675.0000, 13.5529},
    {1177.0000, -1323.0000, 14.0740},
    {1414.0000, -1700.0000, 13.5390},
    {2131.0000, -1150.0000, 24.0000},
    {1363.0000, -1279.0000, 13.5469},
    {2166.0000, -1015.0000, 45.0000},
    {2103.5415, -1806.5271, 13.5547},
    {2185.1274, -1974.7554, 13.5512},
    {-77.3621, -1136.2144, 1.0781},
    {371.0000, -2075.0000, 7.0000},
    {250.0000, -300.0000, 1.5000},
    {2495.0000, -1690.0000, 13.5469},
    {1965.0000, -2180.0000, 13.5469},
    {0.0000, 0.0000, 0.0000}
};

new const GPSNombres[14][] =
{
    "Comisaria LSPD", "Hospital General", "Banco de San Andreas", "Concesionario",
    "Ammu-Nation", "24/7 de Idlewood", "Sede Repartidor de Pizza", "Sede Basurero",
    "Sede Camionero", "Sede Pescador", "Zona de cultivo", "Compraventa",
    "Aeropuerto de Los Santos", "Mi casa"
};

//==============================================================================
//  CALLBACK: INICIO Y FIN DEL SERVIDOR
//==============================================================================
main()
{
    print("\n---------------------------------------------");
    print("      A L T A P R E V I A   R O L E P L A Y");
    print("      Gamemode Roleplay en espanol");
    print("---------------------------------------------\n");
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

    UsePlayerPedAnims();
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);
    ShowNameTags(1);
    SetNameTagDrawDistance(100.0);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    SetWorldTime(AP_Hora);
    SetWeather(AP_Clima);

    //-------- Textdraws de la pantalla de acceso --------
    TD_Login[0] = TextDrawCreate(-10.000000, 0.000000, "tela");
    TextDrawBackgroundColor(TD_Login[0], 0);
    TextDrawFont(TD_Login[0], 5);
    TextDrawLetterSize(TD_Login[0], 0.500000, 1.000000);
    TextDrawColor(TD_Login[0], -11184641);
    TextDrawSetOutline(TD_Login[0], 0);
    TextDrawSetProportional(TD_Login[0], 1);
    TextDrawSetShadow(TD_Login[0], 1);
    TextDrawUseBox(TD_Login[0], 1);
    TextDrawBoxColor(TD_Login[0], 0);
    TextDrawTextSize(TD_Login[0], 660.000000, 450.000000);
    TextDrawSetSelectable(TD_Login[0], 0);
    TextDrawSetPreviewModel(TD_Login[0], 19128);
    TextDrawSetPreviewRot(TD_Login[0], 30.000000, -1.000000, 44.000000, 0.000000);

    TD_Login[1] = TextDrawCreate(225.000000, 56.000000, SERVER_NAME);
    TextDrawBackgroundColor(TD_Login[1], 255);
    TextDrawFont(TD_Login[1], 1);
    TextDrawLetterSize(TD_Login[1], 0.420000, 1.700000);
    TextDrawColor(TD_Login[1], 0x33AAFFFF);
    TextDrawSetOutline(TD_Login[1], 0);
    TextDrawSetProportional(TD_Login[1], 1);
    TextDrawSetShadow(TD_Login[1], 0);
    TextDrawSetSelectable(TD_Login[1], 0);

    TD_Login[2] = TextDrawCreate(287.000000, 71.000000, "hud:radar_triads");
    TextDrawBackgroundColor(TD_Login[2], 0);
    TextDrawFont(TD_Login[2], 4);
    TextDrawLetterSize(TD_Login[2], 0.289999, 1.000000);
    TextDrawColor(TD_Login[2], -1);
    TextDrawSetOutline(TD_Login[2], 0);
    TextDrawSetProportional(TD_Login[2], 0);
    TextDrawSetShadow(TD_Login[2], 1);
    TextDrawUseBox(TD_Login[2], 1);
    TextDrawBoxColor(TD_Login[2], 0);
    TextDrawTextSize(TD_Login[2], 17.000000, 14.000000);
    TextDrawSetSelectable(TD_Login[2], 0);

    TD_Login[3] = TextDrawCreate(390.000000, 74.000000, "0.3.7");
    TextDrawBackgroundColor(TD_Login[3], 255);
    TextDrawFont(TD_Login[3], 1);
    TextDrawLetterSize(TD_Login[3], 0.289997, 0.999997);
    TextDrawColor(TD_Login[3], 255);
    TextDrawSetOutline(TD_Login[3], 0);
    TextDrawSetProportional(TD_Login[3], 0);
    TextDrawSetShadow(TD_Login[3], 0);
    TextDrawSetSelectable(TD_Login[3], 0);

    TD_Login[4] = TextDrawCreate(285.000000, 99.000000, SERVER_MAPNAME);
    TextDrawBackgroundColor(TD_Login[4], 255);
    TextDrawFont(TD_Login[4], 1);
    TextDrawLetterSize(TD_Login[4], 0.189999, 1.599998);
    TextDrawColor(TD_Login[4], 255);
    TextDrawSetOutline(TD_Login[4], 0);
    TextDrawSetProportional(TD_Login[4], 0);
    TextDrawSetShadow(TD_Login[4], 0);
    TextDrawSetSelectable(TD_Login[4], 0);

    TD_Login[5] = TextDrawCreate(227.000000, 96.000000, "-line-");
    TextDrawBackgroundColor(TD_Login[5], 255);
    TextDrawFont(TD_Login[5], 5);
    TextDrawLetterSize(TD_Login[5], 0.500000, 1.000000);
    TextDrawColor(TD_Login[5], -1);
    TextDrawSetOutline(TD_Login[5], 0);
    TextDrawSetProportional(TD_Login[5], 1);
    TextDrawSetShadow(TD_Login[5], 1);
    TextDrawUseBox(TD_Login[5], 1);
    TextDrawBoxColor(TD_Login[5], 0);
    TextDrawTextSize(TD_Login[5], 189.000000, 1.000000);
    TextDrawSetSelectable(TD_Login[5], 0);

    TD_Login[6] = TextDrawCreate(227.000000, 330.000000, "Inicia sesion o registra tu personaje para entrar a la ciudad.");
    TextDrawBackgroundColor(TD_Login[6], 255);
    TextDrawFont(TD_Login[6], 1);
    TextDrawLetterSize(TD_Login[6], 0.240000, 1.200000);
    TextDrawColor(TD_Login[6], -1);
    TextDrawSetOutline(TD_Login[6], 0);
    TextDrawSetProportional(TD_Login[6], 1);
    TextDrawSetShadow(TD_Login[6], 1);
    TextDrawSetSelectable(TD_Login[6], 0);

    //-------- Sedes de trabajo --------
    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        PickupTrabajo[i] = CreatePickup(1239, 1, PosTrabajo[i][0], PosTrabajo[i][1], PosTrabajo[i][2], -1);
        if(LegalTrabajo[i])
        {
            format(szString, sizeof(szString), "{2ECC71}[%s]\n{FFFFFF}Usa {FFFF00}/trabajos{FFFFFF} para trabajar aqui.", NombreTrabajo[i]);
            LabelTrabajo[i] = Create3DTextLabel(szString, -1, PosTrabajo[i][0], PosTrabajo[i][1], PosTrabajo[i][2] + 0.6, 20.0, 0, 1);
        }
        else
        {
            format(szString, sizeof(szString), "{FF0000}[%s - ILEGAL]\n{FFFFFF}Usa {FFFF00}/trabajos{FFFFFF} para empezar.", NombreTrabajo[i]);
            LabelTrabajo[i] = Create3DTextLabel(szString, -1, PosTrabajo[i][0], PosTrabajo[i][1], PosTrabajo[i][2] + 0.6, 20.0, 0, 1);
        }
    }

    //-------- Propiedades --------
    for(new i = 0; i < MAX_CASAS; i++)
    {
        format(CasaDueno[i], MAX_PLAYER_NAME, "Nadie");
        CasaPickup[i] = CreatePickup(1273, 1, CasaExt[i][0], CasaExt[i][1], CasaExt[i][2], -1);
        AP_ActualizarCasa(i);
    }

    //-------- Negocios --------
    for(new i = 0; i < MAX_NEGOCIOS; i++)
    {
        format(NegocioDueno[i], MAX_PLAYER_NAME, "Nadie");
        NegocioCaja[i] = 0;
        NegocioPickup[i] = CreatePickup(1274, 1, NegPos[i][0], NegPos[i][1], NegPos[i][2], -1);
        AP_ActualizarNegocio(i);
    }

    //-------- Tiendas, armerias y servicios --------
    for(new i = 0; i < 5; i++)
    {
        CreatePickup(1210, 1, Pos247[i][0], Pos247[i][1], Pos247[i][2], -1);
        Create3DTextLabel("{2ECC71}[Tienda 24/7]\n{FFFFFF}Usa {FFFF00}/tienda", -1, Pos247[i][0], Pos247[i][1], Pos247[i][2] + 0.5, 15.0, 0, 1);
    }
    for(new i = 0; i < 3; i++)
    {
        CreatePickup(1239, 1, PosAmmu[i][0], PosAmmu[i][1], PosAmmu[i][2], -1);
        Create3DTextLabel("{FF0000}[Ammu-Nation]\n{FFFFFF}Usa {FFFF00}/armas", -1, PosAmmu[i][0], PosAmmu[i][1], PosAmmu[i][2] + 0.5, 15.0, 0, 1);
    }
    CreatePickup(1239, 1, PosCompraVenta[0], PosCompraVenta[1], PosCompraVenta[2], -1);
    Create3DTextLabel("{FFFF00}[Compraventa]\n{FFFFFF}Usa {FFFF00}/venderitem", -1, PosCompraVenta[0], PosCompraVenta[1], PosCompraVenta[2] + 0.5, 15.0, 0, 1);
    CreatePickup(1275, 1, PosBanco[0], PosBanco[1], PosBanco[2], -1);
    Create3DTextLabel("{33AAF}[Banco]\n{FFFFFF}Usa {FFFF00}/banco", -1, PosBanco[0], PosBanco[1], PosBanco[2] + 0.5, 15.0, 0, 1);
    CreatePickup(1275, 1, POS_CONCES, -1);
    Create3DTextLabel("{33AAF}[Concesionario]\n{FFFFFF}Usa {FFFF00}/concesionario", -1, POS_CONCES, 15.0, 0, 1);
    Create3DTextLabel("{FFFF00}[Zona de cultivo]\n{FFFFFF}Usa {FFFF00}/cultivar", -1, PosCultivo[0], PosCultivo[1], PosCultivo[2] + 0.5, 20.0, 0, 1);
    Create3DTextLabel("{FF69B4}[Zona de venta ilegal]\n{FFFFFF}Usa {FFFF00}/venderdroga", -1, 2480.0000, -1650.0000, 13.5469 + 0.5, 20.0, 0, 1);

    //-------- Establecimientos (farmacias, bares, gimnasios...) --------
    AP_Local_Iniciar();

    //-------- Temporizadores --------
    SetTimer("AP_TimerGeneral", 1000, true);
    SetTimer("AP_Payday", TIEMPO_PAYDAY, true);

    ServidorIniciado = true;
    AP_Log("Servidor", "Gamemode AltaPrevia Roleplay iniciada correctamente.");
    return 1;
}

public OnGameModeExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(Player[i][pOnline]) AP_GuardarCuenta(i);
    }
    AP_Log("Servidor", "Gamemode detenida. Cuentas guardadas.");
    return 1;
}

//==============================================================================
//  CALLBACKS DE CONEXION
//==============================================================================
public OnPlayerConnect(playerid)
{
    //--------------------------------------------------------------------------
    //  SISTEMA DE NOMBRES: se acepta CUALQUIER nombre de jugador de SA-MP.
    //  No se expulsa a nadie por su nombre; solo se muestra un aviso informativo
    //  si no sigue la convencion de rol Nombre_Apellido.
    //  (Para volver a exigir el formato, pon NOMBRE_LIBRE en 0.)
    //--------------------------------------------------------------------------
    if(!TieneNombreRol(NombreJugador(playerid)))
    {
    #if NOMBRE_LIBRE == 0
        SendClientMessage(playerid, 0xFF0000FF, "[ERROR OOC]: Tu nombre no cumple el formato exigido: Nombre_Apellido.");
        SendClientMessage(playerid, -1, "Ejemplo correcto: Carlos_Mendoza, Jessica_Taylor. No uses apodos de internet.");
        SetTimerEx("AP_KickInmediato", 600, false, "i", playerid);
        return 1;
    #else
        SendClientMessage(playerid, 0xFFFFAAFF, "[INFO]: Puedes entrar con cualquier nombre. En rol lo habitual es usar Nombre_Apellido.");
    #endif
    }

    AP_ResetJugador(playerid);
    IntentosLogin[playerid] = 0;
    MapaAbierto[playerid] = false;
    CP_Mapa[playerid][0] = 0.0;
    CP_Mapa[playerid][1] = 0.0;
    CP_Mapa[playerid][2] = 0.0;

    AP_CrearHUD(playerid);
    AP_CrearAvisos(playerid);
    AP_CrearMapa(playerid);
    LimpiarChat(playerid);

    SetPlayerCameraPos(playerid, 1457.7153, -1004.9754, 92.5113);
    SetPlayerCameraLookAt(playerid, 1314.1849, -1371.3732, 11.5645);
    TogglePlayerControllable(playerid, false);
    SetPlayerColor(playerid, 0xFFFFFFFF);

    for(new i = 0; i < 7; i++) TextDrawShowForPlayer(playerid, TD_Login[i]);

    new file[64];
    AP_NombreArchivo(playerid, file, sizeof(file));

    if(!fexist(file))
    {
        return ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT,
            "{00ff00}"SERVER_SHORTCUT" - REGISTRAR PERSONAJE",
            "{ffffff}Bienvenido a la oficina de inmigracion de "SERVER_NAME".\n\nIntroduce una clave segura de acceso (contrasena).\n{FFCC00}Requisito: entre 4 y 16 caracteres.",
            "Registrar", "Salir");
    }

    if(AP_Ini_Int(file, "Baned", 0) == 1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "[SISTEMA]: Tu cuenta esta baneada de "SERVER_NAME".");
        SetTimerEx("AP_KickInmediato", 600, false, "i", playerid);
        return 1;
    }

    format(szString, sizeof(szString), "{ffffff}Hola de nuevo, {00ff00}%s.\n\n{ffffff}Esta identidad esta registrada en el sistema del Estado.\nIntroduce tu clave de acceso:", NombreJugador(playerid));
    return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_PASSWORD,
        "{00ff00}"SERVER_SHORTCUT" - CONTROL DE ACCESO", szString, "Conectar", "Salir");
}

public OnPlayerDisconnect(playerid, reason)
{
    if(Player[playerid][pOnline])
    {
        AP_TerminarRuta(playerid);
        if(Player[playerid][pLlamada])
        {
            new dest = Player[playerid][pLlamadaCon];
            if(IsPlayerConnected(dest) && Player[dest][pOnline])
            {
                Player[dest][pLlamada] = false;
                Player[dest][pLlamadaCon] = -1;
            }
        }
        for(new v = 0; v < MAX_VEH_JUG; v++)
        {
            if(VehJug[playerid][v][vID] > 0 && IsValidVehicle(VehJug[playerid][v][vID]))
                DestroyVehicle(VehJug[playerid][v][vID]);
            VehJug[playerid][v][vID] = 0;
        }
        AP_GuardarCuenta(playerid);
        if(Player[playerid][pCasa] >= 0 && Player[playerid][pCasa] < MAX_CASAS)
            format(CasaDueno[Player[playerid][pCasa]], MAX_PLAYER_NAME, "Nadie");
        if(Player[playerid][pNegocio] >= 0 && Player[playerid][pNegocio] < MAX_NEGOCIOS)
            format(NegocioDueno[Player[playerid][pNegocio]], MAX_PLAYER_NAME, "Nadie");
    }
    AP_Comp_AlDesconectar(playerid);
    AP_ResetJugador(playerid);
    if(MapaAbierto[playerid]) MapaAbierto[playerid] = false;
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    return 0;
}

public OnPlayerRequestSpawn(playerid)
{
    return 0;
}

//==============================================================================
//  CALLBACKS DE JUEGO
//==============================================================================
public OnPlayerSpawn(playerid)
{
    for(new i = 0; i < 7; i++) TextDrawHideForPlayer(playerid, TD_Login[i]);

    if(!Player[playerid][pOnline]) return 1;

    SetPlayerSkin(playerid, Player[playerid][pSkin]);
    SetPlayerScore(playerid, Player[playerid][pScore]);
    SetPlayerFightingStyle(playerid, Player[playerid][pStyle]);
    SetPlayerWantedLevel(playerid, Player[playerid][pWanted]);

    if(Player[playerid][pJail])
    {
        SetPlayerInterior(playerid, 3);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1533.6067, -1638.8525, 2024.4063);
        SetPlayerFacingAngle(playerid, 359.1107);
        SetPlayerHealth(playerid, 100.0);
        GameTextForPlayer(playerid, "~r~Estas en prision!", 5000, 3);
    }
    else if(Player[playerid][pCasa] >= 0)
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, CasaExt[Player[playerid][pCasa]][0], CasaExt[Player[playerid][pCasa]][1], CasaExt[Player[playerid][pCasa]][2]);
        SetPlayerFacingAngle(playerid, CasaExt[Player[playerid][pCasa]][3]);
        GetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
        GetPlayerFacingAngle(playerid, Player[playerid][pPosA]);
        Player[playerid][pInt] = 0;
        Player[playerid][pVW] = 0;
        Player[playerid][pEnCasa] = false;
    }

    SetPlayerHealth(playerid, Player[playerid][pHealth]);
    SetPlayerArmour(playerid, Player[playerid][pArmour]);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, Player[playerid][pMoney]);
    AP_DarArmas(playerid);
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    SetCameraBehindPlayer(playerid);
    AP_ActualizarHUD(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    Player[playerid][pMuertes]++;
    Player[playerid][pDead] = true;
    Player[playerid][pHealth] = 100.0;

    // Perdida de dinero por costes medicos
    if(Player[playerid][pMoney] > 500)
    {
        new perdida = Player[playerid][pMoney] / 10;
        AP_QuitarDinero(playerid, perdida);
        format(szString, sizeof(szString), "Has perdido $%d en costes medicos.", perdida);
        AP_Msg(playerid, C_ROJO, szString);
    }

    if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid) && killerid != playerid)
    {
        if(Player[killerid][pFaccion] != 1)
        {
            Player[killerid][pWanted]++;
            SetPlayerWantedLevel(killerid, Player[killerid][pWanted]);
            format(szString, sizeof(szString), "Has matado a %s. Nivel de busqueda: %d", NombrePorID(playerid), Player[killerid][pWanted]);
            AP_Msg(killerid, C_ROJO, szString);
        }
    }

    SpawnPlayer(playerid);
    SetPlayerHealth(playerid, 100.0);
    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "PED", "KO_skid_back", 4.0, 0, 0, 0, 1, 0, 1);
    GameTextForPlayer(playerid, "~r~Estas herido!", 5000, 3);
    SetTimerEx("AP_Reaparecer", 6000, false, "i", playerid);
    AP_GuardarCuenta(playerid);
    return 1;
}

public AP_Reaparecer(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    Player[playerid][pDead] = false;
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    SetPlayerHealth(playerid, 100.0);
    AP_Msg(playerid, C_VERDE, "[MEDICO]: Has sido atendido en el hospital.");
    AP_GuardarCuenta(playerid);
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(!ServidorIniciado) return 1;
    if(!Player[playerid][pOnline]) return 1;

    // Anti-cheat de dinero
    if(GetPlayerMoney(playerid) != Player[playerid][pMoney])
    {
        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, Player[playerid][pMoney]);
    }

    // Anti-cheat de vida
    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, chaleco);
    if(vida > 100.0 && chaleco <= 0.0)
    {
        SetPlayerHealth(playerid, 100.0);
        Player[playerid][pHealth] = 100.0;
    }

    // Anti-cheat de jetpack
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
    {
        AP_Msg(playerid, C_ROJO, "[ANTICHEAT]: El jetpack no esta permitido.");
        SetPlayerHealth(playerid, 0.0);
    }

    // Registro de armas persistentes
    AP_RegistrarArmaActual(playerid);

    // Radares de velocidad
    AP_Radar_Comprobar(playerid);

    // Congelado por administracion
    if(Player[playerid][pCongelado]) TogglePlayerControllable(playerid, false);
    if(Player[playerid][pEsposado]) TogglePlayerControllable(playerid, false);
    if(Player[playerid][pDlg][3]) TogglePlayerControllable(playerid, false);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(Player[playerid][pMuted])
    {
        AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado, no puedes escribir.");
        return 0;
    }
    if(strlen(text) > 100)
    {
        AP_Msg(playerid, C_ROJO, "[SISTEMA]: Mensaje demasiado largo.");
        return 0;
    }
    format(szString, sizeof(szString), "[CHAT] %s: %s", NombrePorID(playerid), text);
    AP_Log("Chat", szString);
    return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
    if(!Player[playerid][pOnline])
    {
        AP_Msg(playerid, C_ROJO, "[SISTEMA]: Debes iniciar sesion para usar comandos.");
        return 0;
    }
    new tick = GetTickCount();
    if(tick - Player[playerid][pLastCmd] < 700)
    {
        AP_Msg(playerid, C_ROJO, "[SISTEMA]: Espera un momento entre comandos.");
        return 0;
    }
    Player[playerid][pLastCmd] = tick;
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
    {
        AP_MostrarMensaje(playerid, "Comando incorrecto, usa ~r~~h~/ayuda~w~ o ~r~~h~/comandos~w~.", 5);
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(Player[playerid][pRuta])
    {
        new job = AP_TrabajoActual(playerid);
        if(job == -1) return 1;
        if(TipoTrabajo[job] != TJ_MECANICO)
        {
            if(GetPlayerVehicleID(playerid) != Player[playerid][pJobVeh])
            {
                AP_Msg(playerid, C_ROJO, "[TRABAJO]: Debes ir en el vehiculo de la empresa.");
                return 1;
            }
        }
        AP_AvanzarRuta(playerid);
        return 1;
    }

    if(CP_Mapa[playerid][0] != 0.0 && CP_Mapa[playerid][1] != 0.0)
    {
        DisablePlayerCheckpoint(playerid);
        CP_Mapa[playerid][0] = 0.0;
        CP_Mapa[playerid][1] = 0.0;
        CP_Mapa[playerid][2] = 0.0;
        AP_MostrarMensaje(playerid, "Has llegado a tu destino.", 4);
        if(MapaAbierto[playerid]) AP_PuntoCPMapa(playerid);
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(!Player[playerid][pOnline]) return 1;
    if(Player[playerid][pRuta] && Player[playerid][pJobVeh] > 0)
    {
        if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
        {
            AP_Msg(playerid, C_AMARILLO, "[TRABAJO]: Vuelve al vehiculo de la empresa para continuar la ruta.");
        }
    }
    return 1;
}

//==============================================================================
//  TEMPORIZADORES GLOBALES
//==============================================================================
public AP_TimerGeneral()
{
    AP_TiempoPayday++;

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        Player[i][pTiempo]++;

        if(Player[i][pTiempo] % 180 == 0)
        {
            if(Player[i][pHambre] > 0) Player[i][pHambre]--;
            if(Player[i][pSed] > 0) Player[i][pSed]--;
        }
        if(Player[i][pTiempo] % 600 == 0) AP_GuardarCuenta(i);
        if(Player[i][pTiempo] % 60 == 0) AP_ActualizarHUD(i);

        // Sistema de companero IA (novia, amigo, guardaespaldas, mascota)
        if(AP_Comp_Tiene(i) && Player[i][pTiempo] % 3 == 0) AP_Comp_IA(i);
        // Consumo de gasolina y kilometraje
        if(Player[i][pTiempo] % 2 == 0) AP_Mecanica_Tick(i);

        if((Player[i][pHambre] <= 0 || Player[i][pSed] <= 0) && random(60) == 0)
        {
            new Float:vida;
            GetPlayerHealth(i, vida);
            if(vida > 10.0) SetPlayerHealth(i, vida - 5.0);
            AP_MostrarMensaje(i, "Tienes hambre o sed, busca comida en un 24/7.", 5);
        }
    }

    // Negocios generando
    for(new n = 0; n < MAX_NEGOCIOS; n++)
    {
        if(strcmp(NegocioDueno[n], "Nadie", true) != 0)
            NegocioCaja[n] += NegGanancia[n] / 60;
    }

    // Hora del mundo
    if(AP_TiempoPayday % 600 == 0)
    {
        AP_Hora++;
        if(AP_Hora > 23) AP_Hora = 0;
        SetWorldTime(AP_Hora);
    }

    // Clima
    if(AP_TiempoPayday % 1800 == 0)
    {
        AP_Clima = random(21);
        SetWeather(AP_Clima);
    }
    return 1;
}

public AP_Payday()
{
    new online = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        online++;
        Player[i][pHoras]++;
        AP_SetBanco(i, Player[i][pBank]);

        // Intereses bancarios
        if(Player[i][pBank] > 0)
        {
            new interes = Player[i][pBank] / 100;
            AP_SetBanco(i, Player[i][pBank] + interes);
            format(szString, sizeof(szString), "[BANCO]: Intereses generados: $%d.", interes);
            AP_Msg(i, C_VERDE, szString);
        }

        // Nomina de faccion
        if(Player[i][pFaccion] > 0 && Player[i][pServicio])
        {
            new pago = PagoFaccion[Player[i][pFaccion]] + (Player[i][pRango] * 400);
            AP_DarDinero(i, pago);
            format(szString, sizeof(szString), "[FACCION]: Nomina de servicio: $%d.", pago);
            AP_Msg(i, C_VERDE, szString);
        }

        // Bono VIP
        if(Player[i][pVIP] > 0)
        {
            new bono = 2000 * Player[i][pVIP];
            AP_DarDinero(i, bono);
            format(szString, sizeof(szString), "[VIP]: Bono de cuenta VIP nivel %d: $%d.", Player[i][pVIP], bono);
            AP_Msg(i, C_AMARILLO, szString);
        }

        // Ayuda estatal por desempleo
        if(Player[i][pJob] == -1 && Player[i][pFaccion] == 0 && Player[i][pMoney] < 2000)
        {
            AP_DarDinero(i, 1500);
            AP_Msg(i, C_AMARILLO, "[ESTADO]: Ayuda por desempleo: $1500. Busca trabajo con /trabajos.");
        }

        AP_LogroConseguir(i, 1);
        if(Player[i][pBank] >= 1000000) AP_LogroConseguir(i, 8);
        AP_GuardarCuenta(i);
    }
    format(szString, sizeof(szString), "[PAYDAY]: Se ha pagado la hora a %d jugadores conectados.", online);
    SendClientMessageToAll(C_AZUL, szString);
    return 1;
}

//==============================================================================
//  TUTORIAL DE BIENVENIDA
//==============================================================================
public AP_Tutorial1(playerid)
{
    AP_MostrarAviso(playerid, "Bienvenido a "SERVER_NAME", te explicare unas cosas antes de continuar...", 8);
    SetTimerEx("AP_Tutorial2", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial2(playerid)
{
    AP_MostrarAviso(playerid, "Usa ~y~/ayuda~w~ y ~y~/comandos~w~ para conocer todo lo que puedes hacer.", 8);
    SetTimerEx("AP_Tutorial3", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial3(playerid)
{
    AP_MostrarAviso(playerid, "Tienes ~g~hambre~w~ y ~b~sed~w~, come y bebe en cualquier 24/7 (/tienda).", 8);
    SetTimerEx("AP_Tutorial4", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial4(playerid)
{
    AP_MostrarAviso(playerid, "Empieza en nivel 1. Sube de nivel jugando y trabajando.", 8);
    SetTimerEx("AP_Tutorial5", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial5(playerid)
{
    AP_MostrarAviso(playerid, "Cada hora recibes ~r~payday~w~ con intereses y nominas.", 7);
    SetTimerEx("AP_Tutorial6", 8000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial6(playerid)
{
    AP_MostrarAviso(playerid, "Usa ~y~/trabajos~w~ para elegir entre 12 empleos diferentes.", 8);
    SetTimerEx("AP_Tutorial7", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial7(playerid)
{
    AP_MostrarAviso(playerid, "Abre una ~p~cuenta bancaria~w~ con /banco, es muy recomendable.", 8);
    SetTimerEx("AP_Tutorial8", 9000, false, "i", playerid);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

public AP_Tutorial8(playerid)
{
    AP_MostrarAviso(playerid, "Si tienes dudas usa ~y~/duda~w~, el staff te atendera. Buena suerte!", 8);
    PlayerPlaySound(playerid, 30803, 0.0, 0.0, 0.0);
    return 1;
}

//==============================================================================
//  ACTUALIZACION DE ETIQUETAS DE PROPIEDADES
//==============================================================================
stock AP_ActualizarCasa(casa)
{
    if(casa < 0 || casa >= MAX_CASAS) return 0;
    Delete3DTextLabel(CasaLabel[casa]);
    if(!strcmp(CasaDueno[casa], "Nadie", true))
    {
        format(szString, sizeof(szString), "{FFFF00}[Casa en venta]\n{FFFFFF}%s\nPrecio: {2ECC71}$%d{FFFFFF}\nUsa {FFFF00}/casa", CasaBarrio[casa], CasaPrecio[casa]);
    }
    else
    {
        format(szString, sizeof(szString), "{FF0000}[Casa de %s]\n{FFFFFF}%s", CasaDueno[casa], CasaBarrio[casa]);
    }
    CasaLabel[casa] = Create3DTextLabel(szString, -1, CasaExt[casa][0], CasaExt[casa][1], CasaExt[casa][2] + 0.6, 20.0, 0, 1);
    return 1;
}

stock AP_ActualizarNegocio(neg)
{
    if(neg < 0 || neg >= MAX_NEGOCIOS) return 0;
    Delete3DTextLabel(NegocioLabel[neg]);
    if(!strcmp(NegocioDueno[neg], "Nadie", true))
    {
        format(szString, sizeof(szString), "{FFFF00}[Negocio en venta]\n{FFFFFF}%s\nPrecio: {2ECC71}$%d{FFFFFF}\nUsa {FFFF00}/negocio", NegNombre[neg], NegPrecio[neg]);
    }
    else
    {
        format(szString, sizeof(szString), "{FF69B4}[Negocio de %s]\n{FFFFFF}%s", NegocioDueno[neg], NegNombre[neg]);
    }
    NegocioLabel[neg] = Create3DTextLabel(szString, -1, NegPos[neg][0], NegPos[neg][1], NegPos[neg][2] + 0.6, 20.0, 0, 1);
    return 1;
}

//==============================================================================
//  CALLBACK: RESPUESTA DE DIALOGOS
//==============================================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    //--- Sistemas modulares: cada uno gestiona sus propios dialogos ---
    if(AP_Comp_Dialog(playerid, dialogid, response, listitem, inputtext)) return 1;
    if(AP_Local_Dialog(playerid, dialogid, response, listitem, inputtext)) return 1;
    if(AP_Extra_Dialog(playerid, dialogid, response, listitem, inputtext)) return 1;

    switch(dialogid)
    {
        //----------------------------------------------------------------------
        case D_REG:
        {
            if(!response) return Kick(playerid);
            if(strlen(inputtext) < 4 || strlen(inputtext) > 16)
            {
                return ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT, "{FF0000}"SERVER_SHORTCUT" - ERROR DE REGISTRO",
                    "{ffffff}La clave introducida no es valida.\n{FF3333}Debe tener entre 4 y 16 caracteres.", "Registrar", "Salir");
            }
            format(Player[playerid][pPass], 17, "%s", inputtext);
            return ShowPlayerDialog(playerid, D_MAIL, DIALOG_STYLE_INPUT, "{00ff00}"SERVER_SHORTCUT" - CORREO ELECTRONICO",
                "{FFFFFF}Ingresa una direccion de correo electronico valida.\n\nEs fundamental para la recuperacion de credenciales.\n{FFFF00}Ejemplo: tunombre@gmail.com", "Continuar", "Salir");
        }
        //----------------------------------------------------------------------
        case D_MAIL:
        {
            if(!response) return Kick(playerid);
            if(!EmailValido(inputtext))
            {
                return ShowPlayerDialog(playerid, D_MAIL, DIALOG_STYLE_INPUT, "{FF0000}"SERVER_SHORTCUT" - CORREO NO VALIDO",
                    "{FFFFFF}El formato de correo ingresado es incorrecto.\n\n{FF3333}Asegurate de incluir la '@' y un dominio valido.\n{FFFF00}Ejemplo: ciudadano@correo.com", "Continuar", "Salir");
            }
            format(Player[playerid][pEmail], 46, "%s", inputtext);
            return ShowPlayerDialog(playerid, D_GEN, DIALOG_STYLE_MSGBOX, "{00ff00}"SERVER_SHORTCUT" - GENERO DEL PERSONAJE",
                "{ffffff}Selecciona el sexo biologico inicial de tu personaje:", "Hombre", "Mujer");
        }
        //----------------------------------------------------------------------
        case D_GEN:
        {
            TogglePlayerControllable(playerid, true);
            SetCameraBehindPlayer(playerid);
            if(!response) Player[playerid][pSkin] = 226;
            else Player[playerid][pSkin] = 188;
            AP_RegistrarCuenta(playerid);
            AP_CargarCuenta(playerid);
            AP_AplicarDatos(playerid);
            AP_PrepararSpawn(playerid);
            SpawnPlayer(playerid);
            AP_Msg(playerid, C_VERDE, "[SISTEMA]: Personaje registrado correctamente. Bienvenido a "SERVER_NAME".");
            format(szString, sizeof(szString), "[SISTEMA]: Usa /recibir para obtener tus stats de inicio y /trabajos para buscar empleo.");
            AP_Msg(playerid, C_AMARILLO, szString);
            SetTimerEx("AP_Tutorial1", 1500, false, "i", playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_LOG:
        {
            if(!response) return Kick(playerid);
            if(!strlen(inputtext))
            {
                return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_PASSWORD, "{FF0000}"SERVER_SHORTCUT" - INTRODUZCA CLAVE",
                    "{ffffff}El campo no puede estar vacio.\nIntroduce tu clave de acceso:", "Conectar", "Salir");
            }
            new file[64];
            AP_NombreArchivo(playerid, file, sizeof(file));
            new clave[17];
            AP_Ini_Str(file, "Clave", clave, 17);
            if(strcmp(inputtext, clave, true) != 0)
            {
                IntentosLogin[playerid]++;
                format(szString, sizeof(szString), "{FF0000}[SEGURIDAD]:{FFFFFF} Contrasena erronea. Intentos: %d/3", IntentosLogin[playerid]);
                AP_Msg(playerid, -1, szString);
                if(IntentosLogin[playerid] >= 3)
                {
                    SendClientMessage(playerid, 0xFF0000FF, "[SISTEMA]: Has superado el limite de intentos. Conexion cerrada.");
                    return SetTimerEx("AP_KickInmediato", 600, false, "i", playerid);
                }
                return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_PASSWORD, "{FF0000}"SERVER_SHORTCUT" - ACCESO INCORRECTO",
                    "{ffffff}Contrasena incorrecta.\nIntroduce el codigo de acceso exacto de esta cuenta:", "Conectar", "Salir");
            }
            TogglePlayerControllable(playerid, true);
            SetCameraBehindPlayer(playerid);
            AP_CargarCuenta(playerid);
            AP_AplicarDatos(playerid);
            AP_PrepararSpawn(playerid);
            SpawnPlayer(playerid);
            LimpiarChat(playerid);
            SendClientMessage(playerid, C_AZUL, "||------------------------------------------------||");
            format(szString, sizeof(szString), "| Bienvenido(a) %s a %s.", NombreJugador(playerid), SERVER_NAME);
            AP_Msg(playerid, -1, szString);
            AP_Msg(playerid, -1, "| Usa /recibir si aun no recibes tus stats de inicio.");
            AP_Msg(playerid, -1, "| Usa /ayuda y /comandos para conocer el servidor.");
            format(szString, sizeof(szString), "| Ultima conexion: %s", Player[playerid][pLogin]);
            AP_Msg(playerid, -1, szString);
            format(szString, sizeof(szString), "| Eres nivel %d. Horas jugadas: %d.", Player[playerid][pScore], Player[playerid][pHoras]);
            AP_Msg(playerid, -1, szString);
            SendClientMessage(playerid, C_AZUL, "||------------------------------------------------||");
            if(Player[playerid][pJail])
            {
                AP_Msg(playerid, C_ROJO, "[SISTEMA]: Sigues cumpliendo condena en prision.");
                SetTimerEx("AP_Unjail", Player[playerid][pJailTime] * 60000, false, "i", playerid);
            }
            AP_Log("Conexiones", "Jugador ha iniciado sesion.");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_AYUDA_1:
        {
            if(!response) return 1;
            ShowPlayerDialog(playerid, D_AYUDA_2, DIALOG_STYLE_MSGBOX, "{00FF00}CONCEPTOS DE ROL",
                "{FFFFFF}- PG: forzar acciones sin dar opcion de respuesta.\n- MG: usar informacion obtenida fuera del juego.\n- DM: matar sin motivo rol.\n- RK: volver a atacar despues de morir.\n- CJ: robar vehiculos sin rol.\n- IOOC: insultar por canales fuera de personaje.\n- AA: abusar de animaciones para ventaja.\n- NA: conducir vehiculos imposibles (aviones sin licencia).\n- EH: exagerar heridas o habilidades.\n\n{FFFF00}El incumplimiento conlleva sanciones administrativas.", "Cerrar", "");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TRABAJOS:
        {
            if(!response) return 1;
            Player[playerid][pDlg][0] = listitem;
            format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\n%s\n\nPago por punto: {2ECC71}$%d{FFFFFF}\nNivel requerido: {FFFF00}%d{FFFFFF}\nLegalidad: %s\n\nDeseas aceptar este empleo?",
                NombreTrabajo[listitem], InfoTrabajo[listitem], PagoTrabajo[listitem], NivelTrabajo[listitem],
                LegalTrabajo[listitem] ? "{2ECC71}Legal" : "{FF0000}Ilegal");
            ShowPlayerDialog(playerid, D_TRABAJO_CONF, DIALOG_STYLE_MSGBOX, "{00FF00}CONTRATO LABORAL", szString, "Aceptar", "Cancelar");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TRABAJO_CONF:
        {
            if(!response) return 1;
            new id = Player[playerid][pDlg][0];
            if(Player[playerid][pScore] < NivelTrabajo[id])
            {
                format(szString, sizeof(szString), "[EMPLEO]: Necesitas ser nivel %d para este trabajo.", NivelTrabajo[id]);
                return AP_Msg(playerid, C_ROJO, szString);
            }
            Player[playerid][pJob] = id;
            format(szString, sizeof(szString), "[EMPLEO]: Ahora trabajas de %s. Ve a la sede y usa /iniciarruta.", NombreTrabajo[id]);
            AP_Msg(playerid, C_VERDE, szString);
            CP_Mapa[playerid][0] = PosTrabajo[id][0];
            CP_Mapa[playerid][1] = PosTrabajo[id][1];
            CP_Mapa[playerid][2] = PosTrabajo[id][2];
            SetPlayerCheckpoint(playerid, PosTrabajo[id][0], PosTrabajo[id][1], PosTrabajo[id][2], 4.0);
            AP_ActualizarHUD(playerid);
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TIENDA:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0:
                {
                    if(!AP_QuitarDinero(playerid, 40)) return AP_Msg(playerid, C_ROJO, "[24/7]: No tienes suficiente dinero.");
                    Player[playerid][pHambre] += 30;
                    if(Player[playerid][pHambre] > 100) Player[playerid][pHambre] = 100;
                    AP_Msg(playerid, C_VERDE, "[24/7]: Has comprado comida (+30 de hambre).");
                    return 1;
                }
                case 1:
                {
                    if(!AP_QuitarDinero(playerid, 25)) return AP_Msg(playerid, C_ROJO, "[24/7]: No tienes suficiente dinero.");
                    Player[playerid][pSed] += 30;
                    if(Player[playerid][pSed] > 100) Player[playerid][pSed] = 100;
                    AP_Msg(playerid, C_VERDE, "[24/7]: Has comprado agua (+30 de sed).");
                    return 1;
                }
                case 2: Player[playerid][pDlg][0] = ITEM_CERVEZA;
                case 3: Player[playerid][pDlg][0] = ITEM_BOTIQUIN;
                case 4: Player[playerid][pDlg][0] = ITEM_MEDICAMENTO;
                case 5: Player[playerid][pDlg][0] = ITEM_TELEFONO;
                case 6: Player[playerid][pDlg][0] = ITEM_RADIO;
                case 7: Player[playerid][pDlg][0] = ITEM_ESPOSAS;
                case 8: Player[playerid][pDlg][0] = ITEM_LLANTA;
                case 9: Player[playerid][pDlg][0] = ITEM_SEMILLA_MED;
                case 10: Player[playerid][pDlg][0] = ITEM_SEMILLA_MAR;
                default: return 1;
            }
            Player[playerid][pDlg][1] = 1;
            format(szString, sizeof(szString), "{FFFFFF}Vas a comprar {00FF00}%s{FFFFFF} por {2ECC71}$%d{FFFFFF} cada uno.\n\nEscribe la cantidad que deseas comprar:", NombreItem[Player[playerid][pDlg][0]], PrecioItem[Player[playerid][pDlg][0]]);
            ShowPlayerDialog(playerid, D_TIENDA_CANT, DIALOG_STYLE_INPUT, "{00FF00}24/7 - CANTIDAD", szString, "Comprar", "Cancelar");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TIENDA_CANT:
        {
            if(!response) return 1;
            new item = Player[playerid][pDlg][0];
            if(item < 0 || item >= MAX_ITEMS) return 1;
            if(!EsNumerico(inputtext)) return AP_Msg(playerid, C_ROJO, "[24/7]: Cantidad invalida.");
            new cant = strval(inputtext);
            if(cant < 1) return AP_Msg(playerid, C_ROJO, "[24/7]: Cantidad invalida.");
            if(cant > 100) cant = 100;
            new total = cant * PrecioItem[item];
            if(!AP_QuitarDinero(playerid, total))
            {
                format(szString, sizeof(szString), "[24/7]: Necesitas $%d para esa compra.", total);
                return AP_Msg(playerid, C_ROJO, szString);
            }
            Player[playerid][pItem][item] += cant;
            format(szString, sizeof(szString), "[24/7]: Has comprado %dx %s por $%d.", cant, NombreItem[item], total);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_ARMAS:
        {
            if(!response) return 1;
            new id = listitem;
            if(id < 0 || id >= 8) return 1;
            if(!AP_QuitarDinero(playerid, ArmaPrecio[id])) return AP_Msg(playerid, C_ROJO, "[AMMU]: No tienes suficiente dinero.");
            if(ArmaID[id] == 0)
            {
                SetPlayerArmour(playerid, 100.0);
                Player[playerid][pArmour] = 100.0;
                AP_Msg(playerid, C_VERDE, "[AMMU]: Chaleco antibalas equipado.");
                return 1;
            }
            new slot = AP_SlotArma(ArmaID[id]);
            GivePlayerWeapon(playerid, ArmaID[id], ArmaMunicion[id]);
            Player[playerid][pArma][slot] = ArmaID[id];
            Player[playerid][pMunicion][slot] = ArmaMunicion[id];
            format(szString, sizeof(szString), "[AMMU]: Has comprado %s con %d balas.", ArmaNombre[id], ArmaMunicion[id]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_BANCO:
        {
            if(!response) return 1;
            Player[playerid][pDlg][0] = listitem;
            if(listitem == 0)
            {
                ShowPlayerDialog(playerid, D_BANCO_CANT, DIALOG_STYLE_INPUT, "{00FF33}BANCO - DEPOSITAR",
                    "{FFFFFF}Escribe la cantidad de dinero en efectivo que deseas depositar:", "Depositar", "Cancelar");
            }
            else if(listitem == 1)
            {
                ShowPlayerDialog(playerid, D_BANCO_CANT, DIALOG_STYLE_INPUT, "{00FF33}BANCO - RETIRAR",
                    "{FFFFFF}Escribe la cantidad que deseas retirar de tu cuenta:", "Retirar", "Cancelar");
            }
            else if(listitem == 2)
            {
                ShowPlayerDialog(playerid, D_TRANSFERIR, DIALOG_STYLE_INPUT, "{00FF33}BANCO - TRANSFERIR",
                    "{FFFFFF}Escribe la ID del jugador y la cantidad separadas por un espacio.\n{FFFF00}Ejemplo: 3 5000", "Transferir", "Cancelar");
            }
            return 1;
        }
        //----------------------------------------------------------------------
        case D_BANCO_CANT:
        {
            if(!response) return 1;
            if(!EsNumerico(inputtext)) return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
            new monto = strval(inputtext);
            if(monto < 1) return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
            if(Player[playerid][pDlg][0] == 0)
            {
                if(!AP_QuitarDinero(playerid, monto)) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese dinero en efectivo.");
                AP_SetBanco(playerid, Player[playerid][pBank] + monto);
                format(szString, sizeof(szString), "[BANCO]: Has depositado $%d. Saldo: $%d.", monto, Player[playerid][pBank]);
                AP_Msg(playerid, C_VERDE, szString);
            }
            else
            {
                if(Player[playerid][pBank] < monto) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese saldo.");
                AP_SetBanco(playerid, Player[playerid][pBank] - monto);
                AP_DarDinero(playerid, monto);
                format(szString, sizeof(szString), "[BANCO]: Has retirado $%d. Saldo: $%d.", monto, Player[playerid][pBank]);
                AP_Msg(playerid, C_VERDE, szString);
            }
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TRANSFERIR:
        {
            if(!response) return 1;
            new ids[12], cant[12], idx = 0;
            if(!AP_Token(inputtext, idx, ids, sizeof(ids))) return AP_Msg(playerid, C_ROJO, "[BANCO]: Formato incorrecto.");
            if(!AP_Token(inputtext, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "[BANCO]: Formato incorrecto.");
            if(!EsNumerico(ids) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[BANCO]: Datos invalidos.");
            new dest = strval(ids), monto = strval(cant);
            if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[BANCO]: Ese jugador no esta conectado.");
            if(dest == playerid) return AP_Msg(playerid, C_ROJO, "[BANCO]: No puedes transferirte a ti mismo.");
            if(Player[playerid][pBank] < monto) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese saldo.");
            AP_SetBanco(playerid, Player[playerid][pBank] - monto);
            AP_SetBanco(dest, Player[dest][pBank] + monto);
            format(szString, sizeof(szString), "[BANCO]: Has transferido $%d a %s.", monto, NombrePorID(dest));
            AP_Msg(playerid, C_VERDE, szString);
            format(szString, sizeof(szString), "[BANCO]: %s te ha transferido $%d.", NombrePorID(playerid), monto);
            AP_Msg(dest, C_VERDE, szString);
            AP_Log("Economia", "Transferencia bancaria desde el cajero.");
            AP_GuardarCuenta(playerid);
            AP_GuardarCuenta(dest);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_CASAS:
        {
            if(!response) return 1;
            new casa = listitem;
            if(casa < 0 || casa >= MAX_CASAS) return 1;
            Player[playerid][pDlg][0] = casa;
            new estado[40];
            if(AP_EsDuenoCasa(playerid, casa)) format(estado, sizeof(estado), "{2ECC71}Tuya");
            else if(!strcmp(CasaDueno[casa], "Nadie", true)) format(estado, sizeof(estado), "{FFFF00}En venta");
            else format(estado, sizeof(estado), "{FF0000}Ocupada por %s", CasaDueno[casa]);
            format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nPrecio: {2ECC71}$%d{FFFFFF}\nNivel requerido: {FFFF00}%d{FFFFFF}\nEstado: %s\n\nPulsa {FFFF00}Marcar{FFFFFF} para poner el destino en el mapa.", CasaBarrio[casa], CasaPrecio[casa], CasaNivel[casa], estado);
            ShowPlayerDialog(playerid, D_CASA_INFO, DIALOG_STYLE_MSGBOX, "{00FF00}PROPIEDAD", szString, "Marcar", "Volver");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_CASA_INFO:
        {
            if(!response) return 1;
            new casa = Player[playerid][pDlg][0];
            CP_Mapa[playerid][0] = CasaExt[casa][0];
            CP_Mapa[playerid][1] = CasaExt[casa][1];
            CP_Mapa[playerid][2] = CasaExt[casa][2];
            SetPlayerCheckpoint(playerid, CasaExt[casa][0], CasaExt[casa][1], CasaExt[casa][2], 4.0);
            format(szString, sizeof(szString), "[CASA]: %s marcada en tu mapa.", CasaBarrio[casa]);
            AP_Msg(playerid, C_VERDE, szString);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_CASA_CONF:
        {
            if(!response) return 1;
            new casa = Player[playerid][pDlg][0];
            if(!AP_EsDuenoCasa(playerid, casa) && strcmp(CasaDueno[casa], "Nadie", true) != 0)
                return AP_Msg(playerid, C_ROJO, "[CASA]: Esta propiedad ya tiene dueno.");
            if(Player[playerid][pCasa] != -1) return AP_Msg(playerid, C_ROJO, "[CASA]: Ya tienes una casa. Usa /vendercasa primero.");
            if(Player[playerid][pScore] < CasaNivel[casa]) return AP_Msg(playerid, C_ROJO, "[CASA]: No tienes el nivel suficiente.");
            if(!AP_QuitarDinero(playerid, CasaPrecio[casa])) return AP_Msg(playerid, C_ROJO, "[CASA]: No tienes suficiente dinero.");
            format(CasaDueno[casa], MAX_PLAYER_NAME, "%s", NombreJugador(playerid));
            Player[playerid][pCasa] = casa;
            AP_ActualizarCasa(casa);
            AP_ActualizarHUD(playerid);
            format(szString, sizeof(szString), "[CASA]: Has comprado la casa de %s por $%d. Usa /casa para entrar.", CasaBarrio[casa], CasaPrecio[casa]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_Log("Economia", "Compra de propiedad.");
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_CONCES:
        {
            if(!response) return 1;
            new id = listitem;
            if(id < 0 || id >= MAX_CONCES) return 1;
            if(AP_SlotLibre(playerid) == -1) return AP_Msg(playerid, C_ROJO, "[GARAJE]: No tienes espacio para mas vehiculos (maximo 3).");
            if(Player[playerid][pScore] < VehConcesNivel[id]) return AP_Msg(playerid, C_ROJO, "[GARAJE]: No tienes el nivel suficiente.");
            Player[playerid][pDlg][0] = id;
            format(szString, sizeof(szString), "{FFFFFF}Vas a comprar un {00FF00}%s{FFFFFF} por {2ECC71}$%d{FFFFFF}.\n\nConfirmas la compra?", VehConcesNombre[id], VehConcesPrecio[id]);
            ShowPlayerDialog(playerid, D_VEH_CONF, DIALOG_STYLE_MSGBOX, "{00FF00}CONCESIONARIO", szString, "Comprar", "Cancelar");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_VEH_CONF:
        {
            if(!response) return 1;
            new id = Player[playerid][pDlg][0];
            new slot = AP_SlotLibre(playerid);
            if(slot == -1) return AP_Msg(playerid, C_ROJO, "[GARAJE]: No tienes espacio.");
            if(!AP_QuitarDinero(playerid, VehConcesPrecio[id])) return AP_Msg(playerid, C_ROJO, "[GARAJE]: No tienes suficiente dinero.");
            VehJug[playerid][slot][vModelo] = VehConcesID[id];
            VehJug[playerid][slot][vC1] = random(200);
            VehJug[playerid][slot][vC2] = random(200);
            VehJug[playerid][slot][vX] = 0.0;
            VehJug[playerid][slot][vY] = 0.0;
            VehJug[playerid][slot][vZ] = 0.0;
            VehJug[playerid][slot][vA] = 0.0;
            VehJug[playerid][slot][vID] = 0;
            AP_CrearVehiculoJugador(playerid, slot);
            format(szString, sizeof(szString), "[GARAJE]: Has comprado un %s. Usa /veh para sacarlo del garaje.", VehConcesNombre[id]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_Log("Economia", "Compra de vehiculo en concesionario.");
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_VEHS:
        {
            if(!response) return 1;
            new contador = 0, slot = -1;
            for(new v = 0; v < MAX_VEH_JUG; v++)
            {
                if(VehJug[playerid][v][vModelo] == 0) continue;
                if(contador == listitem) { slot = v; break; }
                contador++;
            }
            if(slot == -1) return 1;
            AP_CrearVehiculoJugador(playerid, slot);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_NEGOCIO_INFO:
        {
            if(!response) return 1;
            new neg = Player[playerid][pDlg][0];
            if(listitem == 0)
            {
                if(NegocioCaja[neg] <= 0) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: Todavia no hay ganancias.");
                AP_DarDinero(playerid, NegocioCaja[neg]);
                format(szString, sizeof(szString), "[NEGOCIO]: Has recaudado $%d.", NegocioCaja[neg]);
                AP_Msg(playerid, C_VERDE, szString);
                NegocioCaja[neg] = 0;
                return 1;
            }
            if(listitem == 1)
            {
                AP_SalirNegocio(playerid);
                return 1;
            }
            if(listitem == 2)
            {
                new precio = NegPrecio[neg] / 2;
                AP_DarDinero(playerid, precio);
                format(NegocioDueno[neg], MAX_PLAYER_NAME, "Nadie");
                Player[playerid][pNegocio] = -1;
                Player[playerid][pEnCasa] = false;
                AP_SalirNegocio(playerid);
                AP_ActualizarNegocio(neg);
                format(szString, sizeof(szString), "[NEGOCIO]: Has vendido tu negocio por $%d.", precio);
                AP_Msg(playerid, C_VERDE, szString);
                AP_GuardarCuenta(playerid);
                return 1;
            }
            return 1;
        }
        //----------------------------------------------------------------------
        case D_NEGOCIO_CANT:
        {
            if(!response) return 1;
            new neg = Player[playerid][pDlg][0];
            if(strcmp(NegocioDueno[neg], "Nadie", true) != 0) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: Ese negocio ya tiene dueno.");
            if(Player[playerid][pNegocio] != -1) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: Ya tienes un negocio.");
            if(Player[playerid][pScore] < NegNivel[neg]) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: No tienes el nivel suficiente.");
            if(!AP_QuitarDinero(playerid, NegPrecio[neg])) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: No tienes suficiente dinero.");
            format(NegocioDueno[neg], MAX_PLAYER_NAME, "%s", NombreJugador(playerid));
            Player[playerid][pNegocio] = neg;
            AP_ActualizarNegocio(neg);
            format(szString, sizeof(szString), "[NEGOCIO]: Has comprado %s por $%d. Genera $%d por hora.", NegNombre[neg], NegPrecio[neg], NegGanancia[neg]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_Log("Economia", "Compra de negocio.");
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_TELEFONO:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0: AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Usa /llamar [numero] para llamar.");
                case 1: AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Usa /sms [numero] [mensaje] para enviar un mensaje.");
                case 2: AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Usa /contactos para ver tu agenda.");
                case 3: AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Usa /agregarcontacto [numero] para guardar un numero.");
                case 4: AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Usa /recargar [cantidad] para anadir saldo.");
                default: return 1;
            }
            return 1;
        }
        //----------------------------------------------------------------------
        case D_FACCION:
        {
            if(!response) return 1;
            if(Player[playerid][pFaccion] > 0)
            {
                if(listitem == 0) return AP_ServicioComando(playerid);
                if(listitem == 1)
                {
                    new fac = Player[playerid][pFaccion];
                    new lista[300], linea[80];
                    for(new i = 0; i < MAX_RANGOS; i++)
                    {
                        format(linea, sizeof(linea), "Rango %d: %s\n", i, RangoFaccion[fac][i]);
                        strcat(lista, linea, sizeof(lista));
                    }
                    ShowPlayerDialog(playerid, D_FACCION_RANGOS, DIALOG_STYLE_LIST, "{00FF00}RANGOS DE FACION", lista, "Cerrar", "");
                    return 1;
                }
                return 1;
            }
            new fac = listitem + 1;
            Player[playerid][pDlg][0] = fac;
            new lista[300], linea[80];
            for(new i = 0; i < MAX_RANGOS; i++)
            {
                format(linea, sizeof(linea), "Rango %d: %s\n", i, RangoFaccion[fac][i]);
                strcat(lista, linea, sizeof(lista));
            }
            format(szString, sizeof(szString), "%s\nNomina por hora: {2ECC71}$%d{FFFFFF}\n\nDeseas solicitar el ingreso a esta faccion?", NombreFaccion[fac], PagoFaccion[fac]);
            ShowPlayerDialog(playerid, D_FACCION_RANGOS, DIALOG_STYLE_LIST, "{00FF00}FACCION", szString, "Solicitar ingreso", "Volver");
            return 1;
        }
        //----------------------------------------------------------------------
        case D_FACCION_RANGOS:
        {
            if(!response) return 1;
            if(Player[playerid][pFaccion] > 0) return 1;
            new fac = Player[playerid][pDlg][0];
            if(fac <= 0 || fac >= MAX_FACCIONES) return 1;
            Player[playerid][pFaccion] = fac;
            Player[playerid][pRango] = 0;
            format(szString, sizeof(szString), "[FACCION]: Has ingresado a %s. Usa /servicio para entrar de servicio.", NombreFaccion[fac]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_ANIMS:
        {
            if(!response) return 1;
            new id = listitem;
            if(id < 0 || id >= 20) return 1;
            ApplyAnimation(playerid, AnimLib[id], AnimNombre2[id], 4.0, 1, 0, 0, 0, 0, 1);
            format(szString, sizeof(szString), "[ANIM]: Animacion '%s' aplicada. Usa /pararanim para detenerla.", AnimNombre[id]);
            AP_Msg(playerid, C_VERDE, szString);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_ZONA:
        {
            if(!response) return 1;
            new id = listitem;
            if(id < 0 || id >= 14) return 1;
            new Float:px, Float:py, Float:pz;
            if(id == 13)
            {
                if(Player[playerid][pCasa] < 0) return AP_Msg(playerid, C_ROJO, "[GPS]: No tienes ninguna casa.");
                px = CasaExt[Player[playerid][pCasa]][0];
                py = CasaExt[Player[playerid][pCasa]][1];
                pz = CasaExt[Player[playerid][pCasa]][2];
            }
            else
            {
                px = GPSDestinos[id][0];
                py = GPSDestinos[id][1];
                pz = GPSDestinos[id][2];
            }
            CP_Mapa[playerid][0] = px;
            CP_Mapa[playerid][1] = py;
            CP_Mapa[playerid][2] = pz;
            SetPlayerCheckpoint(playerid, px, py, pz, 5.0);
            format(szString, sizeof(szString), "[GPS]: Destino marcado: %s.", GPSNombres[id]);
            AP_Msg(playerid, C_VERDE, szString);
            return 1;
        }
        //----------------------------------------------------------------------
        case D_ADMIN:
        {
            if(!response) return 1;
            if(listitem == 0) return AP_ServicioComando(playerid);
            return 1;
        }
    }
    return 1;
}

//==============================================================================
