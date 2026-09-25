//  SISTEMA DE TELEFONO MOVIL
//==============================================================================
stock AP_TieneTelefono(playerid)
{
    if(Player[playerid][pTelefono] <= 0) return 0;
    return 1;
}

stock AP_JugadorPorTelefono(numero)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pTelefono] == numero) return i;
    }
    return -1;
}

CMD:telefono(playerid)
{
    if(!AP_TieneTelefono(playerid)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes telefono. Compra uno en un 24/7.");
    format(szString, sizeof(szString), "{00FF00}TELEFONO MOVIL{FFFFFF}\nNumero: {33AAF}%d{FFFFFF}\nSaldo: {2ECC71}$%d{FFFFFF}\n\nElige una opcion:", Player[playerid][pTelefono], Player[playerid][pSaldo]);
    ShowPlayerDialog(playerid, D_TELEFONO, DIALOG_STYLE_LIST, "{00FF00}TELEFONO", szString, "Elegir", "Cerrar");
    return 1;
}

CMD:numero(playerid)
{
    if(!AP_TieneTelefono(playerid)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes telefono.");
    format(szString, sizeof(szString), "Tu numero de telefono es %d.", Player[playerid][pTelefono]);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:llamar(playerid, params[])
{
    if(!AP_TieneTelefono(playerid)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes telefono.");
    if(Player[playerid][pLlamada]) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Ya estas en una llamada. Usa /colgar.");
    new num[12];
    new idx = 0;
    if(!AP_Token(params, idx, num, sizeof(num))) return AP_Msg(playerid, C_ROJO, "Uso: /llamar [numero]");
    if(!EsNumerico(num)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Numero invalido.");
    new numero = strval(num);
    new dest = AP_JugadorPorTelefono(numero);
    if(dest == -1) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Ese numero no esta disponible o esta apagado.");
    if(dest == playerid) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No puedes llamarte a ti mismo.");
    Player[playerid][pLlamada] = true;
    Player[playerid][pLlamadaCon] = dest;
    Player[dest][pLlamada] = true;
    Player[dest][pLlamadaCon] = playerid;
    format(szString, sizeof(szString), "[TELEFONO]: Llamada conectada con %s (%d). Usa /colgar para terminar.", NombrePorID(dest), dest);
    AP_Msg(playerid, C_AMARILLO, szString);
    format(szString, sizeof(szString), "[TELEFONO]: Te llama %s (%d). Usa /colgar para terminar.", NombrePorID(playerid), playerid);
    AP_Msg(dest, C_AMARILLO, szString);
    PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
    PlayerPlaySound(dest, 21001, 0.0, 0.0, 0.0);
    return 1;
}

CMD:colgar(playerid)
{
    if(!Player[playerid][pLlamada]) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No estas en ninguna llamada.");
    new dest = Player[playerid][pLlamadaCon];
    if(IsPlayerConnected(dest) && Player[dest][pOnline])
    {
        Player[dest][pLlamada] = false;
        Player[dest][pLlamadaCon] = -1;
        AP_Msg(dest, C_AMARILLO, "[TELEFONO]: La llamada ha terminado.");
    }
    Player[playerid][pLlamada] = false;
    Player[playerid][pLlamadaCon] = -1;
    AP_Msg(playerid, C_AMARILLO, "[TELEFONO]: Llamada finalizada.");
    return 1;
}

CMD:sms(playerid, params[])
{
    if(!AP_TieneTelefono(playerid)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes telefono.");
    new num[12], texto[100];
    new idx = 0;
    if(!AP_Token(params, idx, num, sizeof(num))) return AP_Msg(playerid, C_ROJO, "Uso: /sms [numero] [mensaje]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    if(!strlen(params[resto])) return AP_Msg(playerid, C_ROJO, "Uso: /sms [numero] [mensaje]");
    strmid(texto, params, resto, strlen(params), sizeof(texto));
    if(!EsNumerico(num)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Numero invalido.");
    new dest = AP_JugadorPorTelefono(strval(num));
    if(dest == -1) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Ese numero no esta disponible.");
    format(szString, sizeof(szString), "[SMS para %d]: %s", strval(num), texto);
    AP_Msg(playerid, C_AMARILLO, szString);
    format(szString, sizeof(szString), "[SMS de %d]: %s", Player[playerid][pTelefono], texto);
    AP_Msg(dest, C_AMARILLO, szString);
    return 1;
}

CMD:contactos(playerid)
{
    new lista[500], linea[80], total = 0;
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        if(Player[playerid][pContacto][i] <= 0) continue;
        total++;
        format(linea, sizeof(linea), "%d) %d\n", total, Player[playerid][pContacto][i]);
        strcat(lista, linea, sizeof(lista));
    }
    if(total == 0)
    {
        AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes contactos. Usa /agregarcontacto [numero].");
        return 1;
    }
    ShowPlayerDialog(playerid, D_CONTACTOS, DIALOG_STYLE_LIST, "{00FF00}CONTACTOS", lista, "Cerrar", "");
    return 1;
}

CMD:agregarcontacto(playerid, params[])
{
    new num[12];
    new idx = 0;
    if(!AP_Token(params, idx, num, sizeof(num))) return AP_Msg(playerid, C_ROJO, "Uso: /agregarcontacto [numero]");
    if(!EsNumerico(num)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Numero invalido.");
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        if(Player[playerid][pContacto][i] == 0)
        {
            Player[playerid][pContacto][i] = strval(num);
            AP_Msg(playerid, C_VERDE, "[TELEFONO]: Contacto guardado.");
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[TELEFONO]: Tu agenda esta llena.");
    return 1;
}

CMD:recargar(playerid, params[])
{
    new cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /recargar [cantidad]");
    if(!EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: Cantidad invalida.");
    new monto = strval(cant);
    if(monto < 50) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: La recarga minima es de $50.");
    if(!AP_QuitarDinero(playerid, monto)) return AP_Msg(playerid, C_ROJO, "[TELEFONO]: No tienes suficiente dinero.");
    Player[playerid][pSaldo] += monto;
    format(szString, sizeof(szString), "[TELEFONO]: Recarga de $%d realizada. Saldo: $%d.", monto, Player[playerid][pSaldo]);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:911(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /911 [emergencia]");
    new enviados = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != 1 || !Player[i][pServicio]) continue;
        format(szString, sizeof(szString), "[911] %s (%d): %s", NombrePorID(playerid), playerid, params);
        AP_Msg(i, C_ROJO, szString);
        enviados++;
    }
    if(enviados == 0) return AP_Msg(playerid, C_ROJO, "[911]: No hay policias en servicio.");
    AP_Msg(playerid, C_VERDE, "[911]: Tu emergencia ha sido enviada a la policia.");
    return 1;
}

CMD:medico(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /medico [emergencia]");
    new enviados = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != 2 || !Player[i][pServicio]) continue;
        format(szString, sizeof(szString), "[EMS] %s (%d): %s", NombrePorID(playerid), playerid, params);
        AP_Msg(i, C_ROJO, szString);
        enviados++;
    }
    if(enviados == 0) return AP_Msg(playerid, C_ROJO, "[EMS]: No hay medicos de servicio.");
    AP_Msg(playerid, C_VERDE, "[EMS]: Tu emergencia ha sido enviada a los medicicos.");
    return 1;
}

//==============================================================================
//  SISTEMA DE INVENTARIO Y OBJETOS
//==============================================================================
CMD:inventario(playerid)
{
    new lista[900], linea[128], total = 0;
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(Player[playerid][pItem][i] <= 0) continue;
        total++;
        format(linea, sizeof(linea), "%d) %s\tx%d\n", total, NombreItem[i], Player[playerid][pItem][i]);
        strcat(lista, linea, sizeof(lista));
    }
    if(total == 0)
    {
        AP_Msg(playerid, C_ROJO, "[INVENTARIO]: No tienes ningun objeto.");
        return 1;
    }
    ShowPlayerDialog(playerid, D_INVENTARIO, DIALOG_STYLE_TABLIST, "{00FF00}INVENTARIO", lista, "Cerrar", "");
    return 1;
}

CMD:usar(playerid, params[])
{
    new nombre[40];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /usar [objeto]  (ejemplo: /usar Botiquin)");
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(strfind(NombreItem[i], nombre, true) == 0 && Player[playerid][pItem][i] > 0)
        {
            if(i == ITEM_BOTIQUIN)
            {
                new Float:vida;
                GetPlayerHealth(playerid, vida);
                if(vida >= 100.0) return AP_Msg(playerid, C_ROJO, "[ITEM]: Tu salud ya esta al maximo.");
                SetPlayerHealth(playerid, vida + 40.0);
                Player[playerid][pHealth] = vida + 40.0;
                AP_Msg(playerid, C_VERDE, "[ITEM]: Has usado un botiquin (+40 de salud).");
            }
            else if(i == ITEM_MEDICAMENTO)
            {
                SetPlayerHealth(playerid, 100.0);
                Player[playerid][pHealth] = 100.0;
                Player[playerid][pSed] += 10;
                AP_Msg(playerid, C_VERDE, "[ITEM]: Has tomado un medicamento. Te sientes mejor.");
            }
            else if(i == ITEM_COSECHA)
            {
                Player[playerid][pHambre] += 25;
                if(Player[playerid][pHambre] > 100) Player[playerid][pHambre] = 100;
                AP_Msg(playerid, C_VERDE, "[ITEM]: Has comido algo de cosecha propia.");
            }
            else if(i == ITEM_CERVEZA)
            {
                Player[playerid][pSed] += 20;
                if(Player[playerid][pSed] > 100) Player[playerid][pSed] = 100;
                SetPlayerDrunkLevel(playerid, 3000);
                AP_Msg(playerid, C_VERDE, "[ITEM]: Te has tomado una cerveza. Cuidado con conducir.");
            }
            else if(i == ITEM_MARIHUANA || i == ITEM_DROGA)
            {
                SetPlayerHealth(playerid, 100.0);
                Player[playerid][pHealth] = 100.0;
                SetPlayerDrunkLevel(playerid, 2000);
                AP_Msg(playerid, C_VERDE, "[ITEM]: Te sientes relajado...");
            }
            else if(i == ITEM_TELEFONO)
            {
                if(AP_TieneTelefono(playerid)) return AP_Msg(playerid, C_ROJO, "[ITEM]: Ya tienes telefono.");
                Player[playerid][pTelefono] = 600000 + random(99999);
                AP_Msg(playerid, C_VERDE, "[ITEM]: Telefono activado. Usa /numero para ver tu linea.");
            }
            else if(i == ITEM_RADIO)
            {
                Player[playerid][pRadio] = 1;
                AP_Msg(playerid, C_VERDE, "[ITEM]: Radio portatil encendido. Usa /r para hablar.");
            }
            else
            {
                format(szString, sizeof(szString), "[ITEM]: %s no se puede usar directamente.", NombreItem[i]);
                AP_Msg(playerid, C_AMARILLO, szString);
                return 1;
            }
            Player[playerid][pItem][i]--;
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[ITEM]: No tienes ese objeto.");
    return 1;
}

CMD:dar(playerid, params[])
{
    new idstr[12], nombre[40], cant[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /dar [id] [objeto] [cantidad]");
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /dar [id] [objeto] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) format(cant, sizeof(cant), "1");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ITEM]: ID invalida.");
    new dest = strval(idstr), cantidad = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ITEM]: Ese jugador no esta conectado.");
    if(!IsPlayerInRangeOfPoint(dest, 5.0, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]) && dest != playerid)
        return AP_Msg(playerid, C_ROJO, "[ITEM]: Debes estar cerca del jugador.");
    if(cantidad < 1) cantidad = 1;
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(strfind(NombreItem[i], nombre, true) == 0 && Player[playerid][pItem][i] > 0)
        {
            if(Player[playerid][pItem][i] < cantidad) return AP_Msg(playerid, C_ROJO, "[ITEM]: No tienes esa cantidad.");
            Player[playerid][pItem][i] -= cantidad;
            Player[dest][pItem][i] += cantidad;
            format(szString, sizeof(szString), "[ITEM]: Le has dado %dx %s a %s.", cantidad, NombreItem[i], NombrePorID(dest));
            AP_Msg(playerid, C_VERDE, szString);
            format(szString, sizeof(szString), "[ITEM]: %s te ha dado %dx %s.", NombrePorID(playerid), cantidad, NombreItem[i]);
            AP_Msg(dest, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            AP_GuardarCuenta(dest);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[ITEM]: No tienes ese objeto.");
    return 1;
}

CMD:tirar(playerid, params[])
{
    new nombre[40], cant[8];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /tirar [objeto] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) format(cant, sizeof(cant), "1");
    new cantidad = strval(cant);
    if(cantidad < 1) cantidad = 1;
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(strfind(NombreItem[i], nombre, true) == 0 && Player[playerid][pItem][i] > 0)
        {
            if(Player[playerid][pItem][i] < cantidad) cantidad = Player[playerid][pItem][i];
            Player[playerid][pItem][i] -= cantidad;
            format(szString, sizeof(szString), "[ITEM]: Has tirado %dx %s.", cantidad, NombreItem[i]);
            AP_Msg(playerid, C_AMARILLO, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[ITEM]: No tienes ese objeto.");
    return 1;
}

stock AP_CercaCompraVenta(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 8.0, PosCompraVenta[0], PosCompraVenta[1], PosCompraVenta[2])) return 1;
    return 0;
}

CMD:venderitem(playerid, params[])
{
    new nombre[40];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /venderitem [objeto]");
    if(!AP_CercaCompraVenta(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPRAVENTA]: Debes estar en la compraventa (Willowfield).");
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(strfind(NombreItem[i], nombre, true) == 0 && Player[playerid][pItem][i] > 0)
        {
            new total = Player[playerid][pItem][i];
            new precio = total * PrecioItem[i];
            AP_DarDinero(playerid, precio);
            Player[playerid][pItem][i] = 0;
            format(szString, sizeof(szString), "[COMPRAVENTA]: Has vendido %dx %s por $%d.", total, NombreItem[i], precio);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    AP_Msg(playerid, C_ROJO, "[ITEM]: No tienes ese objeto.");
    return 1;
}

CMD:cultivar(playerid, params[])
{
    new nombre[40];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /cultivar [semilla]");
    if(!IsPlayerInRangeOfPoint(playerid, 25.0, PosCultivo[0], PosCultivo[1], PosCultivo[2]))
        return AP_Msg(playerid, C_ROJO, "[CULTIVO]: Debes estar en la zona de cultivo (campos de Blueberry).");
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(strfind(NombreItem[i], nombre, true) == 0 && Player[playerid][pItem][i] > 0)
        {
            if(i == ITEM_SEMILLA_MED)
            {
                Player[playerid][pItem][i]--;
                SetTimerEx("AP_Cosecha", 45000, false, "ii", playerid, ITEM_MEDICAMENTO);
                AP_Msg(playerid, C_VERDE, "[CULTIVO]: Semilla plantada. Vuelve en unos minutos.");
                return 1;
            }
            if(i == ITEM_SEMILLA_MAR)
            {
                Player[playerid][pItem][i]--;
                SetTimerEx("AP_Cosecha", 45000, false, "ii", playerid, ITEM_MARIHUANA);
                AP_Msg(playerid, C_VERDE, "[CULTIVO]: Semilla plantada. Vuelve en unos minutos.");
                return 1;
            }
        }
    }
    AP_Msg(playerid, C_ROJO, "[CULTIVO]: No tienes semillas. Consiguelas en la tienda.");
    return 1;
}

public AP_Cosecha(playerid, item)
{
    if(!IsPlayerConnected(playerid) || !Player[playerid][pOnline]) return 0;
    if(item < 0 || item >= MAX_ITEMS) return 0;
    new cantidad = 2 + random(3);
    Player[playerid][pItem][item] += cantidad;
    format(szString, sizeof(szString), "[CULTIVO]: Has cosechado %dx %s.", cantidad, NombreItem[item]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:venderdroga(playerid)
{
    if(!IsPlayerInRangeOfPoint(playerid, 30.0, 2480.0000, -1650.0000, 13.5469))
        return AP_Msg(playerid, C_ROJO, "[ILEGAL]: Debes estar en la zona de venta (Ganton).");
    new total = Player[playerid][pItem][ITEM_MARIHUANA] + Player[playerid][pItem][ITEM_DROGA];
    if(total <= 0) return AP_Msg(playerid, C_ROJO, "[ILEGAL]: No tienes droga para vender.");
    new precio = (Player[playerid][pItem][ITEM_MARIHUANA] * 600) + (Player[playerid][pItem][ITEM_DROGA] * 1200);
    Player[playerid][pItem][ITEM_MARIHUANA] = 0;
    Player[playerid][pItem][ITEM_DROGA] = 0;
    AP_DarDinero(playerid, precio);
    format(szString, sizeof(szString), "[ILEGAL]: Has vendido toda tu mercancia por $%d.", precio);
    AP_Msg(playerid, C_VERDE, szString);
    if(random(100) < 25)
    {
        Player[playerid][pWanted]++;
        SetPlayerWantedLevel(playerid, Player[playerid][pWanted]);
        AP_Msg(playerid, C_ROJO, "Un testigo te ha reconocido. Nivel de busqueda aumentado.");
    }
    AP_GuardarCuenta(playerid);
    return 1;
}

//==============================================================================
