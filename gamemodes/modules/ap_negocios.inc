//  SISTEMA DE NEGOCIOS
//==============================================================================
stock AP_NegocioCercano(playerid)
{
    for(new i = 0; i < MAX_NEGOCIOS; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 6.0, NegPos[i][0], NegPos[i][1], NegPos[i][2])) return i;
    }
    return -1;
}

CMD:negocio(playerid)
{
    new neg = AP_NegocioCercano(playerid);
    if(neg == -1)
    {
        if(Player[playerid][pNegocio] >= 0)
        {
            if(Player[playerid][pEnCasa])
            {
                AP_SalirNegocio(playerid);
                return 1;
            }
            AP_EntrarNegocio(playerid, Player[playerid][pNegocio]);
            return 1;
        }
        return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: No estas frente a ningun negocio.");
    }
    if(!strcmp(NegocioDueno[neg], NombreJugador(playerid), true))
    {
        format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nCaja acumulada: {2ECC71}$%d{FFFFFF}\nGanancia por hora: {2ECC71}$%d{FFFFFF}\n\nQue deseas hacer?", NegNombre[neg], NegocioCaja[neg], NegGanancia[neg]);
        ShowPlayerDialog(playerid, D_NEGOCIO_INFO, DIALOG_STYLE_LIST, "{00FF00}TU NEGOCIO", "Recaudar ganancias\nSalir del negocio\nVender negocio (50 por ciento)", "Elegir", "Cerrar");
        Player[playerid][pDlg][0] = neg;
        return 1;
    }
    if(!strcmp(NegocioDueno[neg], "Nadie", true))
    {
        format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nPrecio: {2ECC71}$%d{FFFFFF}\nNivel requerido: {FFFF00}%d{FFFFFF}\nGanancia por hora: {2ECC71}$%d{FFFFFF}\n\nDeseas comprar este negocio?", NegNombre[neg], NegPrecio[neg], NegNivel[neg], NegGanancia[neg]);
        ShowPlayerDialog(playerid, D_NEGOCIO_CANT, DIALOG_STYLE_MSGBOX, "{00FF00}NEGOCIO EN VENTA", szString, "Comprar", "Cancelar");
        Player[playerid][pDlg][0] = neg;
        return 1;
    }
    format(szString, sizeof(szString), "[NEGOCIO]: Este negocio pertenece a %s.", NegocioDueno[neg]);
    AP_Msg(playerid, C_ROJO, szString);
    return 1;
}

CMD:recaudar(playerid)
{
    if(Player[playerid][pNegocio] < 0) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: No tienes ningun negocio.");
    new neg = Player[playerid][pNegocio];
    if(NegocioCaja[neg] <= 0) return AP_Msg(playerid, C_ROJO, "[NEGOCIO]: Todavia no hay ganancias para recaudar.");
    AP_DarDinero(playerid, NegocioCaja[neg]);
    format(szString, sizeof(szString), "[NEGOCIO]: Has recaudado $%d de tu negocio.", NegocioCaja[neg]);
    AP_Msg(playerid, C_VERDE, szString);
    NegocioCaja[neg] = 0;
    return 1;
}

stock AP_EntrarNegocio(playerid, neg)
{
    if(neg < 0 || neg >= MAX_NEGOCIOS) return 0;
    SetPlayerPos(playerid, NegIntPos[neg][0], NegIntPos[neg][1], NegIntPos[neg][2]);
    SetPlayerInterior(playerid, NegIntID[neg]);
    SetPlayerVirtualWorld(playerid, neg + 200);
    Player[playerid][pEnCasa] = true;
    AP_MostrarAviso(playerid, "Bienvenido a tu negocio. Usa /negocio para salir.", 5);
    return 1;
}

stock AP_SalirNegocio(playerid)
{
    new neg = Player[playerid][pNegocio];
    if(neg >= 0 && neg < MAX_NEGOCIOS)
    {
        SetPlayerPos(playerid, NegPos[neg][0] + 2.0, NegPos[neg][1], NegPos[neg][2]);
    }
    else
    {
        SetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
    }
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player[playerid][pEnCasa] = false;
    return 1;
}

//==============================================================================
//  TIENDA 24/7
//==============================================================================
stock AP_Cerca247(playerid)
{
    for(new i = 0; i < 5; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 6.0, Pos247[i][0], Pos247[i][1], Pos247[i][2])) return 1;
    }
    return 0;
}

CMD:tienda(playerid)
{
    if(!AP_Cerca247(playerid)) return AP_Msg(playerid, C_ROJO, "[24/7]: No estas en una tienda (iconos verdes del mapa).");
    ShowPlayerDialog(playerid, D_TIENDA, DIALOG_STYLE_LIST, "{00FF00}TIENDA 24/7",
        "Comida ($40) - Reduce el hambre\nAgua ($25) - Reduce la sed\nCerveza ($60)\nBotiquin ($500)\nMedicamento ($250)\nTelefono Movil ($800)\nRadio Portatil ($400)\nEsposas ($300)\nLlanta ($200)\nSemilla de Medicamento ($200)\nSemilla de Marihuana ($200)",
        "Comprar", "Salir");
    return 1;
}

//==============================================================================
//  AMMU-NATION
//==============================================================================
stock AP_CercaAmmu(playerid)
{
    for(new i = 0; i < 3; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 6.0, PosAmmu[i][0], PosAmmu[i][1], PosAmmu[i][2])) return 1;
    }
    return 0;
}

CMD:armas(playerid)
{
    if(!AP_CercaAmmu(playerid)) return AP_Msg(playerid, C_ROJO, "[AMMU-NATION]: No estas en una armeria (iconos rojos del mapa).");
    new lista[600], linea[128];
    for(new i = 0; i < 8; i++)
    {
        format(linea, sizeof(linea), "%d) %s\t$%d\n", i + 1, ArmaNombre[i], ArmaPrecio[i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_ARMAS, DIALOG_STYLE_TABLIST, "{00FF00}AMMU-NATION", lista, "Comprar", "Salir");
    return 1;
}

//==============================================================================
//  BANCO
//==============================================================================
CMD:banco(playerid)
{
    format(szString, sizeof(szString), "{00FF00}BANCO DE SAN ANDREAS{FFFFFF}\n\nEfectivo: {2ECC71}$%d{FFFFFF}\nCuenta bancaria: {33AAF}$%d{FFFFFF}\n\nElige una operacion:", Player[playerid][pMoney], Player[playerid][pBank]);
    ShowPlayerDialog(playerid, D_BANCO, DIALOG_STYLE_LIST, "{00FF00}BANCO", szString, "Elegir", "Salir");
    return 1;
}

CMD:depositar(playerid, params[])
{
    new cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /depositar [cantidad]");
    if(!EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[BANCO]: La cantidad debe ser numerica.");
    new monto = strval(cant);
    if(monto < 1) return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
    if(!AP_QuitarDinero(playerid, monto)) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese dinero en efectivo.");
    AP_SetBanco(playerid, Player[playerid][pBank] + monto);
    format(szString, sizeof(szString), "[BANCO]: Has depositado $%d. Nuevo saldo: $%d.", monto, Player[playerid][pBank]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:retirar(playerid, params[])
{
    new cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /retirar [cantidad]");
    if(!EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[BANCO]: La cantidad debe ser numerica.");
    new monto = strval(cant);
    if(monto < 1) return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
    if(Player[playerid][pBank] < monto) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese saldo en el banco.");
    AP_SetBanco(playerid, Player[playerid][pBank] - monto);
    AP_DarDinero(playerid, monto);
    format(szString, sizeof(szString), "[BANCO]: Has retirado $%d. Nuevo saldo: $%d.", monto, Player[playerid][pBank]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:transferir(playerid, params[])
{
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /transferir [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /transferir [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[BANCO]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline])
        return AP_Msg(playerid, C_ROJO, "[BANCO]: Ese jugador no esta conectado o no ha iniciado sesion.");
    if(dest == playerid) return AP_Msg(playerid, C_ROJO, "[BANCO]: No puedes transferirte a ti mismo.");
    if(monto < 1) return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
    if(Player[playerid][pBank] < monto) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes ese saldo.");
    AP_SetBanco(playerid, Player[playerid][pBank] - monto);
    AP_SetBanco(dest, Player[dest][pBank] + monto);
    format(szString, sizeof(szString), "[BANCO]: Has transferido $%d a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[BANCO]: %s te ha transferido $%d.", NombrePorID(playerid), monto);
    AP_Msg(dest, C_VERDE, szString);
    AP_Log("Economia", "Transferencia bancaria realizada.");
    AP_GuardarCuenta(playerid);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:balance(playerid)
{
    format(szString, sizeof(szString), "Efectivo: $%d | Banco: $%d", Player[playerid][pMoney], Player[playerid][pBank]);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

//==============================================================================
//  STATS DE INICIO
//==============================================================================
CMD:recibir(playerid)
{
    if(Player[playerid][pStats]) return AP_Msg(playerid, C_ROJO, "[STATS]: Ya recibiste tus stats de inicio.");
    Player[playerid][pStats] = true;
    AP_DarDinero(playerid, 100000);
    AP_SetBanco(playerid, Player[playerid][pBank] + 5000);
    Player[playerid][pItem][ITEM_BOTIQUIN] += 5;
    Player[playerid][pItem][ITEM_MEDICAMENTO] += 5;
    Player[playerid][pItem][ITEM_SEMILLA_MED] += 10;
    Player[playerid][pItem][ITEM_SEMILLA_MAR] += 10;
    Player[playerid][pItem][ITEM_PIEZAS] += 25;
    Player[playerid][pItem][ITEM_REPUESTOS] += 25;
    ShowPlayerDialog(playerid, D_STATS, DIALOG_STYLE_MSGBOX, "{00FF00}STATS DE INICIO",
        "{FFFFFF}El servidor te ha hecho entrega de tus stats iniciales.\n\n{FFFFFF}Dinero: {41f48f}+$100.000\n{FFFFFF}Banco: {41f48f}+$5.000\n{FFFFFF}Botiquines: {00FF00}+5\n{FFFFFF}Medicamentos: {00FF00}+5\n{FFFFFF}Semillas: {00FF00}+20\n{FFFFFF}Piezas de arma: {00FF00}+25\n{FFFFFF}Repuestos: {00FF00}+25", "Salir", "");
    AP_Msg(playerid, C_VERDE, "[STATS]: Has recibido tus stats de inicio. Usa /inventario para verlos.");
    AP_GuardarCuenta(playerid);
    return 1;
}

//==============================================================================
