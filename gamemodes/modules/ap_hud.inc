//  HUD, TEXTDRAWS Y MAPA GPS
//==============================================================================
stock AP_CrearHUD(playerid)
{
    TD_HUD_Nombre[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 8.000000, SERVER_NAME);
    PlayerTextDrawLetterSize(playerid, TD_HUD_Nombre[playerid], 0.340000, 1.300000);
    PlayerTextDrawAlignment(playerid, TD_HUD_Nombre[playerid], 3);
    PlayerTextDrawColor(playerid, TD_HUD_Nombre[playerid], 0x33AAFFFF);
    PlayerTextDrawSetShadow(playerid, TD_HUD_Nombre[playerid], 1);
    PlayerTextDrawSetOutline(playerid, TD_HUD_Nombre[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, TD_HUD_Nombre[playerid], 150);
    PlayerTextDrawFont(playerid, TD_HUD_Nombre[playerid], 1);
    PlayerTextDrawSetProportional(playerid, TD_HUD_Nombre[playerid], 1);

    TD_HUD_Info[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 21.000000, "_");
    PlayerTextDrawLetterSize(playerid, TD_HUD_Info[playerid], 0.230000, 1.100000);
    PlayerTextDrawAlignment(playerid, TD_HUD_Info[playerid], 3);
    PlayerTextDrawColor(playerid, TD_HUD_Info[playerid], -1);
    PlayerTextDrawSetShadow(playerid, TD_HUD_Info[playerid], 1);
    PlayerTextDrawSetOutline(playerid, TD_HUD_Info[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, TD_HUD_Info[playerid], 150);
    PlayerTextDrawFont(playerid, TD_HUD_Info[playerid], 1);
    PlayerTextDrawSetProportional(playerid, TD_HUD_Info[playerid], 1);

    TD_HUD_Dinero[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 33.000000, "_");
    PlayerTextDrawLetterSize(playerid, TD_HUD_Dinero[playerid], 0.230000, 1.100000);
    PlayerTextDrawAlignment(playerid, TD_HUD_Dinero[playerid], 3);
    PlayerTextDrawColor(playerid, TD_HUD_Dinero[playerid], 0x2ECC71FF);
    PlayerTextDrawSetShadow(playerid, TD_HUD_Dinero[playerid], 1);
    PlayerTextDrawSetOutline(playerid, TD_HUD_Dinero[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, TD_HUD_Dinero[playerid], 150);
    PlayerTextDrawFont(playerid, TD_HUD_Dinero[playerid], 1);
    PlayerTextDrawSetProportional(playerid, TD_HUD_Dinero[playerid], 1);
    return 1;
}

stock AP_CrearAvisos(playerid)
{
    TD_Mensaje[playerid] = CreatePlayerTextDraw(playerid, 317.000000, 380.000000, "_");
    PlayerTextDrawLetterSize(playerid, TD_Mensaje[playerid], 0.260000, 1.200000);
    PlayerTextDrawAlignment(playerid, TD_Mensaje[playerid], 2);
    PlayerTextDrawColor(playerid, TD_Mensaje[playerid], -1);
    PlayerTextDrawSetShadow(playerid, TD_Mensaje[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, TD_Mensaje[playerid], 255);
    PlayerTextDrawFont(playerid, TD_Mensaje[playerid], 1);
    PlayerTextDrawSetProportional(playerid, TD_Mensaje[playerid], 1);

    TD_Aviso[playerid] = CreatePlayerTextDraw(playerid, 500.000000, 130.000000, "_");
    PlayerTextDrawLetterSize(playerid, TD_Aviso[playerid], 0.240000, 1.250000);
    PlayerTextDrawTextSize(playerid, TD_Aviso[playerid], 620.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, TD_Aviso[playerid], 1);
    PlayerTextDrawColor(playerid, TD_Aviso[playerid], -1);
    PlayerTextDrawUseBox(playerid, TD_Aviso[playerid], true);
    PlayerTextDrawBoxColor(playerid, TD_Aviso[playerid], 120);
    PlayerTextDrawSetShadow(playerid, TD_Aviso[playerid], 0);
    PlayerTextDrawSetOutline(playerid, TD_Aviso[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, TD_Aviso[playerid], 48);
    PlayerTextDrawFont(playerid, TD_Aviso[playerid], 1);
    PlayerTextDrawSetProportional(playerid, TD_Aviso[playerid], 1);
    return 1;
}

public AP_MostrarAviso(playerid, const texto[], segundos)
{
    new local[256];
    strmid(local, texto, 0, strlen(texto), sizeof(local));
    PlayerTextDrawSetString(playerid, TD_Aviso[playerid], local);
    PlayerTextDrawShow(playerid, TD_Aviso[playerid]);
    if(segundos > 0) SetTimerEx("AP_OcultarAviso", segundos * 1000, false, "i", playerid);
    return 1;
}

public AP_OcultarAviso(playerid)
{
    PlayerTextDrawSetString(playerid, TD_Aviso[playerid], "_");
    PlayerTextDrawHide(playerid, TD_Aviso[playerid]);
    return 1;
}

public AP_MostrarMensaje(playerid, const texto[], segundos)
{
    new local[256];
    strmid(local, texto, 0, strlen(texto), sizeof(local));
    PlayerTextDrawSetString(playerid, TD_Mensaje[playerid], local);
    PlayerTextDrawShow(playerid, TD_Mensaje[playerid]);
    if(segundos > 0) SetTimerEx("AP_OcultarMensaje", segundos * 1000, false, "i", playerid);
    return 1;
}

public AP_OcultarMensaje(playerid)
{
    PlayerTextDrawSetString(playerid, TD_Mensaje[playerid], "_");
    PlayerTextDrawHide(playerid, TD_Mensaje[playerid]);
    return 1;
}

stock AP_CrearMapa(playerid)
{
    TD_Mapa[0] = CreatePlayerTextDraw(playerid, 483.045318, 194.249984, "LD_SPAC:white");
    PlayerTextDrawBackgroundColor(playerid, TD_Mapa[0], 0);
    PlayerTextDrawFont(playerid, TD_Mapa[0], 4);
    PlayerTextDrawColor(playerid, TD_Mapa[0], 120);
    PlayerTextDrawSetOutline(playerid, TD_Mapa[0], 0);
    PlayerTextDrawSetProportional(playerid, TD_Mapa[0], 1);
    PlayerTextDrawSetShadow(playerid, TD_Mapa[0], 1);
    PlayerTextDrawUseBox(playerid, TD_Mapa[0], 1);
    PlayerTextDrawBoxColor(playerid, TD_Mapa[0], 255);
    PlayerTextDrawTextSize(playerid, TD_Mapa[0], 148.052719, 176.750000);

    TD_Mapa[1] = CreatePlayerTextDraw(playerid, 484.919342, 207.666656, "samaps:map");
    PlayerTextDrawBackgroundColor(playerid, TD_Mapa[1], 255);
    PlayerTextDrawFont(playerid, TD_Mapa[1], 4);
    PlayerTextDrawColor(playerid, TD_Mapa[1], -1);
    PlayerTextDrawSetOutline(playerid, TD_Mapa[1], 0);
    PlayerTextDrawSetProportional(playerid, TD_Mapa[1], 1);
    PlayerTextDrawSetShadow(playerid, TD_Mapa[1], 1);
    PlayerTextDrawUseBox(playerid, TD_Mapa[1], 1);
    PlayerTextDrawBoxColor(playerid, TD_Mapa[1], 255);
    PlayerTextDrawTextSize(playerid, TD_Mapa[1], 144.304565, 161.583358);

    TD_Mapa[2] = CreatePlayerTextDraw(playerid, 557.071899, 194.833297, "Usa ~y~/mapa ~w~para salir.");
    PlayerTextDrawAlignment(playerid, TD_Mapa[2], 2);
    PlayerTextDrawBackgroundColor(playerid, TD_Mapa[2], 255);
    PlayerTextDrawFont(playerid, TD_Mapa[2], 1);
    PlayerTextDrawLetterSize(playerid, TD_Mapa[2], 0.201214, 1.121665);
    PlayerTextDrawColor(playerid, TD_Mapa[2], -1);
    PlayerTextDrawSetOutline(playerid, TD_Mapa[2], 0);
    PlayerTextDrawSetProportional(playerid, TD_Mapa[2], 1);
    PlayerTextDrawSetShadow(playerid, TD_Mapa[2], 1);
    return 1;
}

stock AP_AbrirMapa(playerid)
{
    MapaAbierto[playerid] = true;
    PlayerTextDrawShow(playerid, TD_Mapa[0]);
    PlayerTextDrawShow(playerid, TD_Mapa[1]);
    PlayerTextDrawShow(playerid, TD_Mapa[2]);
    AP_PuntoMapa(playerid);
    AP_PuntoCPMapa(playerid);
    return 1;
}

stock AP_CerrarMapa(playerid)
{
    MapaAbierto[playerid] = false;
    PlayerTextDrawHide(playerid, TD_Mapa[0]);
    PlayerTextDrawHide(playerid, TD_Mapa[1]);
    PlayerTextDrawHide(playerid, TD_Mapa[2]);
    PlayerTextDrawHide(playerid, TD_Mapa[3]);
    PlayerTextDrawHide(playerid, TD_Mapa[4]);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return 1;
}

stock AP_PuntoMapa(playerid)
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    AP_MarcarMapa(playerid, 3, "hud:radar_waypoint", -1, 6.0, 6.0, px, py);
    return 1;
}

stock AP_PuntoCPMapa(playerid)
{
    if(CP_Mapa[playerid][0] != 0.0 && CP_Mapa[playerid][1] != 0.0)
        AP_MarcarMapa(playerid, 4, "hud:radar_light", -1, 10.0, 10.0, CP_Mapa[playerid][0], CP_Mapa[playerid][1]);
    return 1;
}

stock AP_MarcarMapa(playerid, indice, const icono[], color, Float:sx, Float:sy, Float:x, Float:y)
{
    if(x > 3000.0) x = 3000.0; else if(x < -3000.0) x = -3000.0;
    if(y > 3000.0) y = 3000.0; else if(y < -3000.0) y = -3000.0;
    new Float:mx = floatdiv(144.304565, 2.0), Float:my = floatdiv(161.583358, 2.0);
    new Float:ix = floatdiv(sx, 2.0), Float:iy = floatdiv(sy, 2.0);
    new Float:tx = 484.919342 + floatmul(floatdiv(mx, 3000.0), x) + mx - ix;
    new Float:ty = 207.666656 + floatmul(floatdiv(-my, 3000.0), y) + my - iy;
    TD_Mapa[indice] = CreatePlayerTextDraw(playerid, tx, ty, icono);
    PlayerTextDrawLetterSize(playerid, TD_Mapa[indice], 0.160333, 1.280592);
    PlayerTextDrawTextSize(playerid, TD_Mapa[indice], sx, sy);
    PlayerTextDrawAlignment(playerid, TD_Mapa[indice], 1);
    PlayerTextDrawColor(playerid, TD_Mapa[indice], color);
    PlayerTextDrawSetShadow(playerid, TD_Mapa[indice], 0);
    PlayerTextDrawSetOutline(playerid, TD_Mapa[indice], 0);
    PlayerTextDrawBackgroundColor(playerid, TD_Mapa[indice], 255);
    PlayerTextDrawFont(playerid, TD_Mapa[indice], 4);
    PlayerTextDrawSetProportional(playerid, TD_Mapa[indice], 0);
    PlayerTextDrawShow(playerid, TD_Mapa[indice]);
    return 1;
}

public AP_ActualizarHUD(playerid)
{
    if(!Player[playerid][pOnline]) return 0;
    new trabajo[32];
    if(Player[playerid][pJob] == -1) format(trabajo, sizeof(trabajo), "Desempleado");
    else format(trabajo, sizeof(trabajo), "%s", NombreTrabajo[Player[playerid][pJob]]);

    format(szString, sizeof(szString), "%s  ~w~[ID: ~b~~h~%d~w~]  Nivel: ~g~~h~%d", NombreJugador(playerid), playerid, Player[playerid][pScore]);
    PlayerTextDrawSetString(playerid, TD_HUD_Info[playerid], szString);

    new hora[8];
    format(hora, sizeof(hora), "%02d:00", AP_Hora);
    format(szString, sizeof(szString), "Efectivo: ~g~~h~$%d~w~  Banco: ~b~~h~$%d~w~  ~w~%s", Player[playerid][pMoney], Player[playerid][pBank], hora);
    PlayerTextDrawSetString(playerid, TD_HUD_Dinero[playerid], szString);

    PlayerTextDrawShow(playerid, TD_HUD_Nombre[playerid]);
    PlayerTextDrawShow(playerid, TD_HUD_Info[playerid]);
    PlayerTextDrawShow(playerid, TD_HUD_Dinero[playerid]);
    return 1;
}

//==============================================================================
