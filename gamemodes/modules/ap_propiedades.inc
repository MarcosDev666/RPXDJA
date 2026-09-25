//  SISTEMA DE PROPIEDADES (CASAS)
//==============================================================================
#define POS_CONCES   2131.0000, -1150.0000, 24.0000

stock AP_CasaCercana(playerid)
{
    for(new i = 0; i < MAX_CASAS; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, CasaExt[i][0], CasaExt[i][1], CasaExt[i][2])) return i;
    }
    return -1;
}

stock AP_EsDuenoCasa(playerid, casa)
{
    if(casa < 0 || casa >= MAX_CASAS) return 0;
    if(!strcmp(CasaDueno[casa], NombreJugador(playerid), true)) return 1;
    return 0;
}

CMD:casas(playerid)
{
    new lista[1400], linea[200];
    for(new i = 0; i < MAX_CASAS; i++)
    {
        new estado[32];
        if(AP_EsDuenoCasa(playerid, i)) format(estado, sizeof(estado), "{2ECC71}Tuya");
        else if(!strcmp(CasaDueno[i], "Nadie", true)) format(estado, sizeof(estado), "{FFFF00}En venta");
        else format(estado, sizeof(estado), "{FF0000}Ocupada");
        format(linea, sizeof(linea), "%d)\t%s\t$%d\tNivel %d\t%s\n", i + 1, CasaBarrio[i], CasaPrecio[i], CasaNivel[i], estado);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_CASAS, DIALOG_STYLE_TABLIST, "{00FF00}"SERVER_SHORTCUT" - MERCADO INMOBILIARIO", lista, "Ver", "Salir");
    return 1;
}

CMD:casa(playerid)
{
    new casa = AP_CasaCercana(playerid);
    if(casa == -1)
    {
        if(Player[playerid][pCasa] >= 0 && AP_EsDuenoCasa(playerid, Player[playerid][pCasa]))
        {
            if(Player[playerid][pEnCasa])
            {
                AP_SalirCasa(playerid);
                return 1;
            }
            AP_EntrarCasa(playerid, Player[playerid][pCasa]);
            return 1;
        }
        return AP_Msg(playerid, C_ROJO, "[CASA]: No estas frente a ninguna propiedad.");
    }
    if(AP_EsDuenoCasa(playerid, casa))
    {
        if(Player[playerid][pEnCasa])
        {
            format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nEres el propietario de esta vivienda.\n\nQue deseas hacer?", CasaBarrio[casa]);
            ShowPlayerDialog(playerid, D_CASA_INFO, DIALOG_STYLE_LIST, "{00FF00}TU PROPIEDAD", "Salir de la casa\nVender propiedad (50 por ciento)\nInformacion\nMarcar en el mapa", "Elegir", "Cerrar");
            Player[playerid][pDlg][0] = casa;
            return 1;
        }
        AP_EntrarCasa(playerid, casa);
        return 1;
    }
    if(!strcmp(CasaDueno[casa], "Nadie", true))
    {
        format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nPrecio: {2ECC71}$%d{FFFFFF}\nNivel requerido: {FFFF00}%d{FFFFFF}\n\nDeseas comprar esta propiedad?", CasaBarrio[casa], CasaPrecio[casa], CasaNivel[casa]);
        ShowPlayerDialog(playerid, D_CASA_CONF, DIALOG_STYLE_MSGBOX, "{00FF00}PROPIEDAD EN VENTA", szString, "Comprar", "Cancelar");
        Player[playerid][pDlg][0] = casa;
        return 1;
    }
    format(szString, sizeof(szString), "[CASA]: Esta propiedad pertenece a %s.", CasaDueno[casa]);
    AP_Msg(playerid, C_ROJO, szString);
    return 1;
}

stock AP_EntrarCasa(playerid, casa)
{
    if(casa < 0 || casa >= MAX_CASAS) return 0;
    if(!AP_EsDuenoCasa(playerid, casa)) return AP_Msg(playerid, C_ROJO, "[CASA]: No tienes las llaves de esta casa.");
    SetPlayerPos(playerid, CasaIntPos[casa][0], CasaIntPos[casa][1], CasaIntPos[casa][2]);
    SetPlayerInterior(playerid, CasaIntID[casa]);
    SetPlayerVirtualWorld(playerid, casa + 100);
    Player[playerid][pEnCasa] = true;
    Player[playerid][pInt] = CasaIntID[casa];
    Player[playerid][pVW] = casa + 100;
    GetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, Player[playerid][pPosA]);
    AP_MostrarAviso(playerid, "Bienvenido a tu casa. Usa /casa para salir.", 5);
    AP_GuardarCuenta(playerid);
    return 1;
}

stock AP_SalirCasa(playerid)
{
    new casa = Player[playerid][pCasa];
    if(casa < 0 || casa >= MAX_CASAS) casa = AP_CasaCercana(playerid);
    if(casa < 0)
    {
        SetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Player[playerid][pEnCasa] = false;
        return 1;
    }
    SetPlayerPos(playerid, CasaExt[casa][0] + 2.0, CasaExt[casa][1], CasaExt[casa][2]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player[playerid][pEnCasa] = false;
    Player[playerid][pInt] = 0;
    Player[playerid][pVW] = 0;
    GetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, Player[playerid][pPosA]);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:vendercasa(playerid)
{
    new casa = Player[playerid][pCasa];
    if(casa < 0) return AP_Msg(playerid, C_ROJO, "[CASA]: No tienes ninguna propiedad.");
    if(!AP_EsDuenoCasa(playerid, casa)) return AP_Msg(playerid, C_ROJO, "[CASA]: No eres el propietario.");
    new precio = CasaPrecio[casa] / 2;
    AP_DarDinero(playerid, precio);
    format(CasaDueno[casa], MAX_PLAYER_NAME, "Nadie");
    Player[playerid][pCasa] = -1;
    Player[playerid][pEnCasa] = false;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    AP_SalirCasa(playerid);
    format(szString, sizeof(szString), "[CASA]: Has vendido tu propiedad por $%d.", precio);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

//==============================================================================
//  SISTEMA DE VEHICULOS PERSONALES
//==============================================================================
stock AP_NombreModelo(modelo, destino[], maxlen = sizeof(destino))
{
    for(new i = 0; i < MAX_CONCES; i++)
    {
        if(VehConcesID[i] == modelo)
        {
            format(destino, maxlen, "%s", VehConcesNombre[i]);
            return 1;
        }
    }
    format(destino, maxlen, "Vehiculo %d", modelo);
    return 0;
}

stock AP_PrecioModelo(modelo)
{
    for(new i = 0; i < MAX_CONCES; i++)
    {
        if(VehConcesID[i] == modelo) return VehConcesPrecio[i];
    }
    return 0;
}

stock AP_SlotLibre(playerid)
{
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        if(VehJug[playerid][v][vModelo] == 0) return v;
    }
    return -1;
}

CMD:veh(playerid)
{
    new lista[400], linea[128], total = 0;
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        if(VehJug[playerid][v][vModelo] == 0) continue;
        total++;
        AP_NombreModelo(VehJug[playerid][v][vModelo], szString2, sizeof(szString2));
        format(linea, sizeof(linea), "%d) %s\t%s\n", total, szString2, (VehJug[playerid][v][vID] > 0) ? "{2ECC71}En la calle" : "{FFFF00}En el garaje");
        strcat(lista, linea, sizeof(lista));
    }
    if(total == 0)
    {
        AP_Msg(playerid, C_ROJO, "[GARAJE]: No tienes vehiculos. Compra uno en el concesionario (/concesionario).");
        return 1;
    }
    ShowPlayerDialog(playerid, D_VEHS, DIALOG_STYLE_TABLIST, "{00FF00}TU GARAJE", lista, "Sacar", "Salir");
    return 1;
}

CMD:concesionario(playerid)
{
    if(!IsPlayerInRangeOfPoint(playerid, 12.0, POS_CONCES))
        return AP_Msg(playerid, C_ROJO, "[CONCESIONARIO]: Debes estar en el concesionario (marcado en el mapa).");
    new lista[900], linea[128];
    for(new i = 0; i < MAX_CONCES; i++)
    {
        format(linea, sizeof(linea), "%d) %s\t$%d\tNivel %d\n", i + 1, VehConcesNombre[i], VehConcesPrecio[i], VehConcesNivel[i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_CONCES, DIALOG_STYLE_TABLIST, "{00FF00}CONCESIONARIO "SERVER_SHORTCUT, lista, "Comprar", "Salir");
    return 1;
}

stock AP_CrearVehiculoJugador(playerid, slot)
{
    if(slot < 0 || slot >= MAX_VEH_JUG) return 0;
    if(VehJug[playerid][slot][vModelo] == 0) return 0;
    if(VehJug[playerid][slot][vID] > 0 && IsValidVehicle(VehJug[playerid][slot][vID]))
    {
        AP_Msg(playerid, C_ROJO, "[GARAJE]: Ese vehiculo ya esta en la calle. Usa /estacionar para guardarlo.");
        return 0;
    }
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    new vid = CreateVehicle(VehJug[playerid][slot][vModelo], px + 3.0, py, pz + 1.0, pa, VehJug[playerid][slot][vC1], VehJug[playerid][slot][vC2], 60000);
    if(!vid) return 0;
    VehJug[playerid][slot][vID] = vid;
    PutPlayerInVehicle(playerid, vid, 0);
    AP_NombreModelo(VehJug[playerid][slot][vModelo], szString2, sizeof(szString2));
    format(szString, sizeof(szString), "[GARAJE]: Has sacado tu %s.", szString2);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:estacionar(playerid)
{
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[GARAJE]: Debes estar dentro del vehiculo que quieres guardar.");
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        if(VehJug[playerid][v][vID] == vid)
        {
            new Float:px, Float:py, Float:pz, Float:pa;
            GetVehiclePos(vid, px, py, pz);
            GetVehicleZAngle(vid, pa);
            VehJug[playerid][v][vX] = px;
            VehJug[playerid][v][vY] = py;
            VehJug[playerid][v][vZ] = pz;
            VehJug[playerid][v][vA] = pa;
            DestroyVehicle(vid);
            VehJug[playerid][v][vID] = 0;
            RemovePlayerFromVehicle(playerid);
            AP_Msg(playerid, C_VERDE, "[GARAJE]: Vehiculo guardado en tu garaje.");
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[GARAJE]: Este vehiculo no es tuyo.");
    return 1;
}

CMD:venderveh(playerid)
{
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[GARAJE]: Debes estar dentro del vehiculo que quieres vender.");
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        if(VehJug[playerid][v][vID] == vid)
        {
            new precio = AP_PrecioModelo(VehJug[playerid][v][vModelo]) / 2;
            if(precio < 10000) precio = 10000;
            AP_DarDinero(playerid, precio);
            DestroyVehicle(vid);
            VehJug[playerid][v][vModelo] = 0;
            VehJug[playerid][v][vID] = 0;
            RemovePlayerFromVehicle(playerid);
            format(szString, sizeof(szString), "[GARAJE]: Vehiculo vendido por $%d.", precio);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[GARAJE]: Este vehiculo no es tuyo.");
    return 1;
}

CMD:repararveh(playerid, params[])
{
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[TALLER]: Debes estar dentro de un vehiculo.");
    if(AP_QuitarDinero(playerid, 500))
    {
        RepairVehicle(vid);
        SetVehicleHealth(vid, 1000.0);
        AP_Msg(playerid, C_VERDE, "[TALLER]: Vehiculo reparado por $500.");
    }
    else AP_Msg(playerid, C_ROJO, "[TALLER]: No tienes suficiente dinero ($500).");
    return 1;
}

//==============================================================================
