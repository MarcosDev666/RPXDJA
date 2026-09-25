//  SISTEMA DE TRABAJOS (12 trabajos funcionales)
//==============================================================================
stock AP_EnSedeTrabajo(playerid, trabajo)
{
    if(trabajo < 0 || trabajo >= MAX_TRABAJOS) return 0;
    if(IsPlayerInRangeOfPoint(playerid, 6.0, PosTrabajo[trabajo][0], PosTrabajo[trabajo][1], PosTrabajo[trabajo][2])) return 1;
    return 0;
}

stock AP_TrabajoActual(playerid)
{
    if(Player[playerid][pJob] < 0 || Player[playerid][pJob] >= MAX_TRABAJOS) return -1;
    return Player[playerid][pJob];
}

CMD:trabajos(playerid)
{
    new lista[900], linea[180];
    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        format(linea, sizeof(linea), "%d) %s\tNivel %d\t$%d\n", i + 1, NombreTrabajo[i], NivelTrabajo[i], PagoTrabajo[i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_TRABAJOS, DIALOG_STYLE_TABLIST, "{00FF00}"SERVER_SHORTCUT" - AGENCIA DE EMPLEO",
        lista, "Seleccionar", "Salir");
    return 1;
}

CMD:infotrabajo(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return AP_Msg(playerid, C_ROJO, "[ERROR]: No tienes trabajo. Usa /trabajos para ver la lista.");
    format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\n%s\n\nPago por punto: {2ECC71}$%d{FFFFFF}\nExperiencia: {2ECC71}%d{FFFFFF}\nTu experiencia: {2ECC71}%d{FFFFFF}\nEstado: %s",
        NombreTrabajo[job], InfoTrabajo[job], PagoTrabajo[job], XPTrabajo[job], Player[playerid][pJobExp][job],
        LegalTrabajo[job] ? "{2ECC71}Legal" : "{FF0000}Ilegal");
    ShowPlayerDialog(playerid, D_STATS, DIALOG_STYLE_MSGBOX, "{00FF00}INFORMACION DE EMPLEO", szString, "Volver", "");
    return 1;
}

CMD:tomartrabajo(playerid, params[])
{
    new idx[8];
    if(AP_PrimerParam(params, idx)) return AP_Msg(playerid, C_ROJO, "Uso: /tomartrabajo [1-12]  (o usa /trabajos)");
    new id = strval(idx) - 1;
    if(id < 0 || id >= MAX_TRABAJOS) return AP_Msg(playerid, C_ROJO, "[ERROR]: Numero de trabajo invalido.");
    if(Player[playerid][pScore] < NivelTrabajo[id])
    {
        format(szString, sizeof(szString), "[ERROR]: Necesitas ser nivel %d para este trabajo.", NivelTrabajo[id]);
        return AP_Msg(playerid, C_ROJO, szString);
    }
    Player[playerid][pJob] = id;
    format(szString, sizeof(szString), "[EMPLEO]: Ahora trabajas de %s. Ve a la sede y usa /iniciarruta.", NombreTrabajo[id]);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "Sede marcada en el mapa (punto rojo).");
    AP_Msg(playerid, C_AMARILLO, szString);
    CP_Mapa[playerid][0] = PosTrabajo[id][0];
    CP_Mapa[playerid][1] = PosTrabajo[id][1];
    CP_Mapa[playerid][2] = PosTrabajo[id][2];
    SetPlayerCheckpoint(playerid, PosTrabajo[id][0], PosTrabajo[id][1], PosTrabajo[id][2], 4.0);
    AP_ActualizarHUD(playerid);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:renunciar(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return AP_Msg(playerid, C_ROJO, "[ERROR]: Estas desempleado.");
    AP_TerminarRuta(playerid);
    Player[playerid][pJob] = -1;
    AP_Msg(playerid, C_AMARILLO, "[EMPLEO]: Has renunciado a tu empleo. Suerte en tu busqueda.");
    AP_GuardarCuenta(playerid);
    AP_ActualizarHUD(playerid);
    return 1;
}

stock AP_IniciarRuta(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return AP_Msg(playerid, C_ROJO, "[ERROR]: No tienes trabajo.");
    if(Player[playerid][pRuta]) return AP_Msg(playerid, C_ROJO, "[ERROR]: Ya estas en una ruta. Usa /terminarruta para cancelar.");
    if(!AP_EnSedeTrabajo(playerid, job)) return AP_Msg(playerid, C_ROJO, "[ERROR]: Debes estar en la sede de tu trabajo (icono en el mapa).");
    if(Player[playerid][pJail]) return AP_Msg(playerid, C_ROJO, "[ERROR]: Estas en prision.");

    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);

    Player[playerid][pJobVeh] = CreateVehicle(VehTrabajo[job], px + 3.0, py, pz + 1.0, pa, 0, 0, 60000);
    if(!Player[playerid][pJobVeh])
    {
        AP_Msg(playerid, C_ROJO, "[ERROR]: No se pudo crear el vehiculo de trabajo.");
        return 1;
    }
    PutPlayerInVehicle(playerid, Player[playerid][pJobVeh], 0);
    Player[playerid][pRuta] = true;
    Player[playerid][pRutaPaso] = 0;
    format(szString, sizeof(szString), "[TRABAJO]: Ruta iniciada como %s. Sigue los puntos rojos del mapa.", NombreTrabajo[job]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_SiguienteCheckpoint(playerid);
    return 1;
}

CMD:iniciarruta(playerid) return AP_IniciarRuta(playerid);

stock AP_TerminarRuta(playerid)
{
    if(Player[playerid][pJobVeh] > 0)
    {
        if(IsValidVehicle(Player[playerid][pJobVeh])) DestroyVehicle(Player[playerid][pJobVeh]);
        Player[playerid][pJobVeh] = 0;
    }
    Player[playerid][pRuta] = false;
    Player[playerid][pRutaPaso] = 0;
    DisablePlayerCheckpoint(playerid);
    return 1;
}

CMD:terminarruta(playerid)
{
    if(!Player[playerid][pRuta]) return AP_Msg(playerid, C_ROJO, "[ERROR]: No estas realizando ninguna ruta.");
    AP_TerminarRuta(playerid);
    AP_Msg(playerid, C_AMARILLO, "[TRABAJO]: Ruta cancelada, has devuelto el vehiculo de la empresa.");
    return 1;
}

stock AP_SiguienteCheckpoint(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return 0;
    new paso = Player[playerid][pRutaPaso];
    if(paso >= NumCPTrabajo[job]) return 0;
    SetPlayerCheckpoint(playerid, CPTrabajo[job][paso][0], CPTrabajo[job][paso][1], CPTrabajo[job][paso][2], 5.0);
    if(MapaAbierto[playerid])
    {
        CP_Mapa[playerid][0] = CPTrabajo[job][paso][0];
        CP_Mapa[playerid][1] = CPTrabajo[job][paso][1];
        CP_Mapa[playerid][2] = CPTrabajo[job][paso][2];
        AP_PuntoCPMapa(playerid);
    }
    return 1;
}

stock AP_AvanzarRuta(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return 0;
    new paso = Player[playerid][pRutaPaso];
    new pago = PagoTrabajo[job];
    new item = ItemTrabajo[job];

    // Bonus por experiencia en el trabajo
    pago += (Player[playerid][pJobExp][job] / 20) * 25;

    if(TipoTrabajo[job] == TJ_TAXI)
    {
        if(paso % 2 == 0)
        {
            format(szString, sizeof(szString), "[TAXISTA]: Pasajero a bordo (%s). Lleva el punto rojo al destino.", NombreJugador(playerid));
            AP_Msg(playerid, C_VERDE, "Pasajero recogido. Lleva el destino marcado.");
            AP_DarExperienciaTrabajo(playerid, job, XPTrabajo[job]);
            Player[playerid][pRutaPaso]++;
            AP_SiguienteCheckpoint(playerid);
            return 1;
        }
        // Dejar pasajero: pagar por distancia
        new Float:ox = CPTrabajo[job][paso - 1][0], Float:oy = CPTrabajo[job][paso - 1][1];
        new Float:dx = CPTrabajo[job][paso][0], Float:dy = CPTrabajo[job][paso][1];
        new Float:dist = floatsqroot(floatpower(floatabs(ox - dx), 2.0) + floatpower(floatabs(oy - dy), 2.0));
        pago += floatround(dist) * 3;
        AP_DarDinero(playerid, pago);
        format(szString, sizeof(szString), "[TAXISTA]: Carrera completada. Distancia: %.0f m. Cobraste $%d.", dist, pago);
        AP_Msg(playerid, C_VERDE, szString);
        AP_DarExperienciaTrabajo(playerid, job, XPTrabajo[job] * 2);
        Player[playerid][pRutaPaso]++;
        if(Player[playerid][pRutaPaso] >= NumCPTrabajo[job]) return AP_FinalizarRuta(playerid);
        AP_SiguienteCheckpoint(playerid);
        return 1;
    }

    AP_DarDinero(playerid, pago);
    if(item >= 0 && item < MAX_ITEMS && paso == NumCPTrabajo[job] - 1)
    {
        Player[playerid][pItem][item] += 2;
        format(szString, sizeof(szString), "[TRABAJO]: Recibiste 2x %s como material de la jornada.", NombreItem[item]);
        AP_Msg(playerid, C_AMARILLO, szString);
    }
    format(szString, sizeof(szString), "[TRABAJO]: Punto completado. Cobraste $%d.", pago);
    AP_Msg(playerid, C_VERDE, szString);
    AP_DarExperienciaTrabajo(playerid, job, XPTrabajo[job]);
    Player[playerid][pRutaPaso]++;

    if(Player[playerid][pRutaPaso] >= NumCPTrabajo[job]) return AP_FinalizarRuta(playerid);
    AP_SiguienteCheckpoint(playerid);
    return 1;
}

stock AP_FinalizarRuta(playerid)
{
    new job = AP_TrabajoActual(playerid);
    if(job == -1) return 0;
    new bonus = PagoTrabajo[job] * 2;
    AP_DarDinero(playerid, bonus);
    Player[playerid][pRutas]++;
    AP_DarExperiencia(playerid, 15);
    format(szString, sizeof(szString), "[TRABAJO]: Ruta completada. Bonus de finalizacion: $%d.", bonus);
    AP_Msg(playerid, C_VERDE, szString);
    if(!LegalTrabajo[job] && random(100) < 18)
    {
        Player[playerid][pWanted]++;
        SetPlayerWantedLevel(playerid, Player[playerid][pWanted]);
        AP_Msg(playerid, C_ROJO, "La policia sospecha de tu mercancia. Nivel de busqueda aumentado.");
    }
    AP_TerminarRuta(playerid);
    AP_GuardarCuenta(playerid);
    return 1;
}

// Parser local de parametros (evita depender de sscanf)
stock AP_PrimerParam(const params[], salida[])
{
    new idx = 0;
    if(!AP_Token(params, idx, salida, 32)) return 1;
    return 0;
}

//==============================================================================
