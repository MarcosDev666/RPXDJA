//==============================================================================
//  SISTEMAS EXTRA
//  Casino y apuestas, combustible, misiones, logros, recompensa diaria,
//  matrimonio, prestamos, bolsa de valores, seguros, radares y peajes.
//==============================================================================

//------------------------------------------------------------------------------
//  1. CASINO Y APUESTAS
//------------------------------------------------------------------------------
#define CASINO_MIN         100
#define CASINO_MAX         100000

// Simbolos de la tragamonedas
new const SlotSimbolo[6][] = { "Cereza", "Limon", "Campana", "7", "Diamante", "BAR" };
new const SlotValor[6]    = { 2, 2, 3, 5, 10, 4 };

CMD:casino(playerid, params[])
{
    new txt[500];
    format(txt, sizeof(txt),
        "{FFFFFF}Bienvenido al casino de "SERVER_NAME".\n\n{2ECC71}Fichas: {FFFFFF}%d\n\n{FFFF00}1) Tragamonedas {FFFFFF}(apuesta y prueba suerte)\n{FFFF00}2) Dados {FFFFFF}(el numero mas alto gana)\n{FFFF00}3) Ruleta {FFFFFF}(rojo, negro o numero)\n{FFFF00}4) Blackjack {FFFFFF}(acercate a 21)\n{FFFF00}5) Comprar fichas\n{FFFF00}6) Cambiar fichas por dinero\n\n{AAAAAA}Apuesta minima $%d, maxima $%d",
        Player[playerid][pFichas], CASINO_MIN, CASINO_MAX);
    return ShowPlayerDialog(playerid, D_CASINO, DIALOG_STYLE_LIST,
        "{FF0000}CASINO ALTA PREVIA", txt, "Jugar", "Salir");
}

// Tragamonedas: devuelve la ganancia (0 = pierde)
stock AP_SlotJugar(playerid, apuesta)
{
    new a = random(6), b = random(6), c = random(6);
    format(szString, sizeof(szString),
        "[CASINO]: Tragamonedas: [%s] [%s] [%s]", SlotSimbolo[a], SlotSimbolo[b], SlotSimbolo[c]);
    AP_Msg(playerid, C_AMARILLO, szString);

    if(a == b && b == c)
    {
        new gana = apuesta * SlotValor[a];
        format(szString, sizeof(szString), "[CASINO]: TRIPLE! Ganaste $%d.", gana);
        AP_Msg(playerid, C_VERDE, szString);
        return gana;
    }
    if(a == b || b == c || a == c)
    {
        new gana = apuesta / 2;
        if(gana > 0)
        {
            format(szString, sizeof(szString), "[CASINO]: Pareja! Recuperas $%d.", gana);
            AP_Msg(playerid, C_VERDE, szString);
            return gana;
        }
    }
    AP_Msg(playerid, C_ROJO, "[CASINO]: Mala suerte, vuelve a intentarlo.");
    return 0;
}

// Dados: 1 = gana el jugador, 0 = gana la casa
stock AP_DadosJugar(playerid, apuesta)
{
    new mio = 1 + random(6), casa = 1 + random(6);
    format(szString, sizeof(szString), "[CASINO]: Dados: tu %d vs casa %d.", mio, casa);
    AP_Msg(playerid, C_AMARILLO, szString);
    if(mio > casa)
    {
        format(szString, sizeof(szString), "[CASINO]: Ganaste $%d.", apuesta * 2);
        AP_Msg(playerid, C_VERDE, szString);
        return 1;
    }
    AP_Msg(playerid, C_ROJO, "[CASINO]: La casa gana esta vez.");
    return 0;
}

// Ruleta: tipo 0 = rojo, 1 = negro, 2 = numero concreto
stock AP_RuletaJugar(playerid, apuesta, tipo, numero)
{
    new resultado = random(37);
    new rojo = (resultado != 0 && (resultado % 2) == 1);
    format(szString, sizeof(szString), "[CASINO]: La ruleta cae en %d (%s).",
        resultado, (resultado == 0) ? "verde" : (rojo ? "rojo" : "negro"));
    AP_Msg(playerid, C_AMARILLO, szString);

    if(tipo == 2 && resultado == numero)
    {
        new gana = apuesta * 35;
        format(szString, sizeof(szString), "[CASINO]: Numero exacto! Ganaste $%d.", gana);
        AP_Msg(playerid, C_VERDE, szString);
        return gana;
    }
    if(tipo == 0 && rojo)
    {
        format(szString, sizeof(szString), "[CASINO]: Rojo! Ganaste $%d.", apuesta * 2);
        AP_Msg(playerid, C_VERDE, szString);
        return apuesta * 2;
    }
    if(tipo == 1 && resultado != 0 && !rojo)
    {
        format(szString, sizeof(szString), "[CASINO]: Negro! Ganaste $%d.", apuesta * 2);
        AP_Msg(playerid, C_VERDE, szString);
        return apuesta * 2;
    }
    AP_Msg(playerid, C_ROJO, "[CASINO]: No hubo suerte.");
    return 0;
}

// Blackjack simplificado
stock AP_BlackjackJugar(playerid, apuesta)
{
    new j1 = 1 + random(10), j2 = 1 + random(10);
    new total = j1 + j2;
    new casa = 14 + random(8);
    format(szString, sizeof(szString), "[CASINO]: Tus cartas suman %d. La casa tiene %d.", total, casa);
    AP_Msg(playerid, C_AMARILLO, szString);
    if(total > 21)
    {
        AP_Msg(playerid, C_ROJO, "[CASINO]: Te pasaste de 21.");
        return 0;
    }
    if(casa > 21 || total > casa)
    {
        format(szString, sizeof(szString), "[CASINO]: Ganaste $%d.", apuesta * 2);
        AP_Msg(playerid, C_VERDE, szString);
        return apuesta * 2;
    }
    if(total == casa)
    {
        AP_Msg(playerid, C_AMARILLO, "[CASINO]: Empate, recuperas tu apuesta.");
        return apuesta;
    }
    AP_Msg(playerid, C_ROJO, "[CASINO]: La casa gana.");
    return 0;
}

// Comprar fichas con dinero
CMD:fichas(playerid, params[])
{
    new cantstr[12], idx = 0;
    if(!AP_Token(params, idx, cantstr, sizeof(cantstr))) return AP_Msg(playerid, C_ROJO, "Uso: /fichas [cantidad en pesos]");
    if(!EsNumerico(cantstr)) return AP_Msg(playerid, C_ROJO, "[CASINO]: Cantidad invalida.");

    new cant = strval(cantstr);
    if(cant < 100 || cant > 500000) return AP_Msg(playerid, C_ROJO, "[CASINO]: Entre $100 y $500000.");
    if(Player[playerid][pMoney] < cant) return AP_Msg(playerid, C_ROJO, "[CASINO]: No tienes ese dinero.");

    AP_QuitarDinero(playerid, cant);
    Player[playerid][pFichas] += cant;
    format(szString, sizeof(szString), "[CASINO]: Compraste %d fichas.", cant);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

// Cambiar fichas por dinero
CMD:cambiarfichas(playerid, params[])
{
    if(Player[playerid][pFichas] <= 0) return AP_Msg(playerid, C_ROJO, "[CASINO]: No tienes fichas.");
    new cant = Player[playerid][pFichas];
    Player[playerid][pFichas] = 0;
    AP_DarDinero(playerid, cant);
    format(szString, sizeof(szString), "[CASINO]: Cambiaste %d fichas por $%d.", cant, cant);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  2. COMBUSTIBLE Y MECANICA
//------------------------------------------------------------------------------
CMD:gasolina(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return AP_Msg(playerid, C_ROJO, "[MECANICA]: Sube a un vehiculo.");
    if(Player[playerid][pGasolina] >= 100.0)
        return AP_Msg(playerid, C_AMARILLO, "[MECANICA]: El deposito ya esta lleno.");

    // 100 pesos por punto de gasolina
    new falta = 100 - floatround(Player[playerid][pGasolina]);
    new coste = falta * 10;
    if(Player[playerid][pMoney] < coste)
        return AP_Msg(playerid, C_ROJO, "[MECANICA]: No tienes dinero para llenar el deposito.");

    AP_QuitarDinero(playerid, coste);
    Player[playerid][pGasolina] = 100.0;
    format(szString, sizeof(szString), "[MECANICA]: Deposito lleno por $%d.", coste);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

// Consumo de gasolina y kilometraje (se llama desde el temporizador)
stock AP_Mecanica_Tick(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 0;

    new veh = GetPlayerVehicleID(playerid);
    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(veh, vx, vy, vz);
    new Float:vel = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0;
    if(vel < 5.0) return 0;

    // Consumo: 1 punto cada ~4 segundos a velocidad alta
    if(Player[playerid][pGasolina] > 0.0)
    {
        Player[playerid][pGasolina] -= 0.25;
        Player[playerid][pKm] += 1;
    }
    else
    {
        // Sin gasolina el motor se apaga
        if(random(20) == 0)
        {
            SetVehicleHealth(veh, 250.0);
            Player[playerid][pMotorDa] = true;
            AP_MostrarMensaje(playerid, "Te quedaste sin gasolina, busca una ~r~~h~gasolinera~w~.", 5);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------
//  3. MISIONES
//------------------------------------------------------------------------------
#define MAX_MISIONES       8

new const MisionNombre[MAX_MISIONES][] =
{
    "Primer dia en la ciudad",
    "Busca trabajo",
    "Abre una cuenta bancaria",
    "Compra tu primera casa",
    "Consigue un vehiculo",
    "Gana dinero respetando la ley",
    "Conoce a alguien especial",
    "Conviertete en leyenda"
};

new const MisionPremio[MAX_MISIONES] = { 5000, 10000, 15000, 50000, 40000, 60000, 30000, 250000 };
new const MisionTexto[MAX_MISIONES][] =
{
    "Registrate y entra al servidor por primera vez.",
    "Usa /trabajos y toma un trabajo legal.",
    "Ve al banco y deposita dinero con /banco.",
    "Usa /casas y compra una propiedad.",
    "Compra un vehiculo en /concesionario o /veh.",
    "Acumula 100.000 pesos sin trabajar en algo ilegal.",
    "Consigue un companero con /novia.",
    "Alcanza el nivel maximo de una habilidad."
};

CMD:misiones(playerid, params[])
{
    new actual = Player[playerid][pMision];
    new txt[700];
    if(actual >= MAX_MISIONES)
    {
        format(txt, sizeof(txt), "{2ECC71}Has completado todas las misiones.\n{FFFFFF}Enhorabuena, eres parte de la historia de "SERVER_NAME".");
        return ShowPlayerDialog(playerid, D_MISIONES, DIALOG_STYLE_MSGBOX,
            "{00FF00}MISIONES", txt, "Cerrar", "");
    }
    format(txt, sizeof(txt),
        "{FFFFFF}Mision actual: {00FF00}%s\n\n{FFFFFF}%s\n\n{2ECC71}Recompensa: {FFFFFF}$%d\n{FFFF00}Misiones completadas: {FFFFFF}%d de %d",
        MisionNombre[actual], MisionTexto[actual], MisionPremio[actual], actual, MAX_MISIONES);
    return ShowPlayerDialog(playerid, D_MISIONES, DIALOG_STYLE_MSGBOX,
        "{00FF00}MISIONES", txt, "Cerrar", "");
}

// Marca la mision actual como completada (la llaman los sistemas)
stock AP_MisionCompletar(playerid)
{
    new actual = Player[playerid][pMision];
    if(actual >= MAX_MISIONES) return 0;

    Player[playerid][pMision]++;
    AP_DarDinero(playerid, MisionPremio[actual]);
    AP_DarExperiencia(playerid, 25);
    format(szString, sizeof(szString), "[MISION]: Completaste '%s'. Recompensa: $%d.",
        MisionNombre[actual], MisionPremio[actual]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  4. LOGROS
//------------------------------------------------------------------------------
#define MAX_LOGROS        10

new const LogroNombre[MAX_LOGROS][] =
{
    "Bienvenido", "Primer sueldo", "Duena de tu casa", "Al volante",
    "En pareja", "Apostador", "Pescador", "Mecanico", "Millonario", "Leyenda"
};
new const LogroTexto[MAX_LOGROS][] =
{
    "Entra al servidor por primera vez.",
    "Cobra tu primer payday.",
    "Compra una casa.",
    "Compra un vehiculo.",
    "Consigue un companero.",
    "Gana una apuesta en el casino.",
    "Completa una ruta de pescador.",
    "Repara un vehiculo en el taller.",
    "Ten 1.000.000 en el banco.",
    "Alcanza 100 de nivel."
};

CMD:logros(playerid, params[])
{
    new lista[700];
    lista[0] = EOS;
    for(new i = 0; i < MAX_LOGROS; i++)
    {
        new hecho = (Player[playerid][pLogros] & (1 << i)) ? 1 : 0;
        format(szString, sizeof(szString), "{FFFFFF}%s\t{%06x}%s\t{AAAAAA}%s\n",
            LogroNombre[i], hecho ? 0x2ECC71 : 0xAA0000, hecho ? "CONSEGUIDO" : "Pendiente", LogroTexto[i]);
        strcat(lista, szString, sizeof(lista));
    }
    return ShowPlayerDialog(playerid, D_LOGROS, DIALOG_STYLE_TABLIST,
        "{00FF00}TUS LOGROS", lista, "Cerrar", "");
}

stock AP_LogroConseguir(playerid, indice)
{
    if(indice < 0 || indice >= MAX_LOGROS) return 0;
    if(Player[playerid][pLogros] & (1 << indice)) return 0;
    Player[playerid][pLogros] |= (1 << indice);
    format(szString, sizeof(szString), "[LOGRO]: Has conseguido '%s'.", LogroNombre[indice]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_DarExperiencia(playerid, 15);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  5. RECOMPENSA DIARIA
//------------------------------------------------------------------------------
CMD:diario(playerid, params[])
{
    new dia = getdate();
    if(Player[playerid][pUltimoDia] == dia)
    {
        new falta = 86400 - (gettime() % 86400);
        new horas = falta / 3600, mins = (falta % 3600) / 60;
        format(szString, sizeof(szString), "[DIARIO]: Ya cobraste hoy. Vuelve en %d h %d min.", horas, mins);
        return AP_Msg(playerid, C_AMARILLO, szString);
    }
    if(Player[playerid][pUltimoDia] == dia - 1) Player[playerid][pRachaDias]++;
    else Player[playerid][pRachaDias] = 1;

    Player[playerid][pUltimoDia] = dia;
    if(Player[playerid][pRachaDias] > 7) Player[playerid][pRachaDias] = 7;

    new premio = 3000 + (Player[playerid][pRachaDias] * 1500);
    AP_DarDinero(playerid, premio);
    format(szString, sizeof(szString), "[DIARIO]: Recompensa diaria de $%d. Racha: %d dia(s).", premio, Player[playerid][pRachaDias]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_LogroConseguir(playerid, 0);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  6. MATRIMONIO
//------------------------------------------------------------------------------
CMD:proponer(playerid, params[])
{
    new idstr[8], idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /proponer [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[BODA]: Id invalido.");

    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[BODA]: Ese jugador no esta conectado.");
    if(dest == playerid) return AP_Msg(playerid, C_ROJO, "[BODA]: No puedes casarte contigo mismo.");
    if(Player[playerid][pConyuge] != -1) return AP_Msg(playerid, C_ROJO, "[BODA]: Ya estas casado.");
    if(Player[dest][pConyuge] != -1) return AP_Msg(playerid, C_ROJO, "[BODA]: Esa persona ya esta casada.");
    if(Player[playerid][pMoney] < 50000) return AP_Msg(playerid, C_ROJO, "[BODA]: La boda cuesta $50000.");

    // Guardamos en el ACEPTANTE quien le propuso matrimonio, ya que el
    // dialogo se muestra al aceptante y ahi se resuelve la respuesta
    Player[dest][pDlg][2] = playerid;
    format(szString, sizeof(szString), "{FFFFFF}%s te pide matrimonio.\n\n{FF69B4}La boda cuesta $50000 y les dara acceso a beneficios de pareja.\n\nAceptas?",
        NombrePorID(playerid));
    ShowPlayerDialog(dest, D_BODA, DIALOG_STYLE_MSGBOX, "{FF69B4}PROPUESTA DE MATRIMONIO", szString, "Aceptar", "Rechazar");
    format(szString, sizeof(szString), "[BODA]: Le propusiste matrimonio a %s. Espera su respuesta.", NombrePorID(dest));
    return AP_Msg(playerid, C_AMARILLO, szString);
}

CMD:divorcio(playerid, params[])
{
    if(Player[playerid][pConyuge] == -1) return AP_Msg(playerid, C_ROJO, "[BODA]: No estas casado.");
    new dest = Player[playerid][pConyuge];
    if(IsPlayerConnected(dest) && Player[dest][pOnline])
    {
        Player[dest][pConyuge] = -1;
        AP_Msg(dest, C_ROJO, "[BODA]: Tu pareja pidio el divorcio.");
    }
    Player[playerid][pConyuge] = -1;
    Player[playerid][pAnillo] = 0;
    AP_Msg(playerid, C_ROJO, "[BODA]: Divorcio tramitado.");
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:anillo(playerid, params[])
{
    if(Player[playerid][pConyuge] == -1) return AP_Msg(playerid, C_ROJO, "[BODA]: No estas casado.");
    if(Player[playerid][pAnillo]) return AP_Msg(playerid, C_AMARILLO, "[BODA]: Ya tienes un anillo.");
    if(Player[playerid][pMoney] < 25000) return AP_Msg(playerid, C_ROJO, "[BODA]: El anillo cuesta $25000.");
    AP_QuitarDinero(playerid, 25000);
    Player[playerid][pAnillo] = 1;
    AP_Msg(playerid, C_ROSADO, "[BODA]: Compraste un anillo de boda. Usalo con orgullo.");
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  7. PRESTAMOS Y BOLSA
//------------------------------------------------------------------------------
#define PRESTAMO_MAX       500000
#define INTERES_PRESTAMO   10

CMD:prestamo(playerid, params[])
{
    if(Player[playerid][pPrestamo] > 0)
    {
        format(szString, sizeof(szString), "[BANCO]: Tienes una deuda de $%d. Usa /pagardeuda para saldarla.", Player[playerid][pDeuda]);
        return AP_Msg(playerid, C_ROJO, szString);
    }
    new txt[300];
    format(txt, sizeof(txt),
        "{FFFFFF}Pide un prestamo al banco. Se devuelve con un %d%% de interes en el siguiente payday.\n\n{2ECC71}Maximo: {FFFFFF}$%d\n\nEscribe la cantidad que necesitas:",
        INTERES_PRESTAMO, PRESTAMO_MAX);
    return ShowPlayerDialog(playerid, D_PRESTAMO, DIALOG_STYLE_INPUT,
        "{00FF00}PRESTAMO BANCARIO", txt, "Pedir", "Salir");
}

CMD:pagardeuda(playerid, params[])
{
    if(Player[playerid][pDeuda] <= 0) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes deudas.");
    if(Player[playerid][pMoney] < Player[playerid][pDeuda]) return AP_Msg(playerid, C_ROJO, "[BANCO]: No tienes suficiente dinero.");
    AP_QuitarDinero(playerid, Player[playerid][pDeuda]);
    format(szString, sizeof(szString), "[BANCO]: Pagaste tu deuda de $%d.", Player[playerid][pDeuda]);
    AP_Msg(playerid, C_VERDE, szString);
    Player[playerid][pDeuda] = 0;
    Player[playerid][pPrestamo] = 0;
    AP_GuardarCuenta(playerid);
    return 1;
}

// Valor actual de la accion (fluye con el tiempo)
stock AP_BolsaPrecio()
{
    new base = 100 + (gettime() / 60) % 40;
    return base + random(15);
}

CMD:bolsa(playerid, params[])
{
    new precio = AP_BolsaPrecio();
    new txt[500];
    format(txt, sizeof(txt),
        "{FFFFFF}Bolsa de valores de "SERVER_NAME".\n\n{2ECC71}Valor actual de la accion: {FFFFFF}$%d\n{FFFF00}Tus acciones: {FFFFFF}%d\n{FFFF00}Dinero invertido: {FFFFFF}$%d\n\n{AAAAAA}El precio sube y baja cada minuto. Usa /compraraccion [cantidad] y /venderaccion [cantidad].",
        precio, Player[playerid][pAcciones], Player[playerid][pBolsa]);
    return ShowPlayerDialog(playerid, D_BOLSA, DIALOG_STYLE_MSGBOX,
        "{00FF00}BOLSA DE VALORES", txt, "Cerrar", "");
}

CMD:compraraccion(playerid, params[])
{
    new cantstr[10], idx = 0;
    if(!AP_Token(params, idx, cantstr, sizeof(cantstr))) return AP_Msg(playerid, C_ROJO, "Uso: /compraraccion [cantidad]");
    if(!EsNumerico(cantstr)) return AP_Msg(playerid, C_ROJO, "[BOLSA]: Cantidad invalida.");
    new cant = strval(cantstr);
    if(cant < 1 || cant > 1000) return AP_Msg(playerid, C_ROJO, "[BOLSA]: Entre 1 y 1000 acciones.");

    new precio = AP_BolsaPrecio();
    new total = cant * precio;
    if(Player[playerid][pMoney] < total)
    {
        format(szString, sizeof(szString), "[BOLSA]: Necesitas $%d para %d acciones.", total, cant);
        return AP_Msg(playerid, C_ROJO, szString);
    }
    AP_QuitarDinero(playerid, total);
    Player[playerid][pAcciones] += cant;
    Player[playerid][pBolsa] += total;
    format(szString, sizeof(szString), "[BOLSA]: Compraste %d acciones por $%d.", cant, total);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:venderaccion(playerid, params[])
{
    new cantstr[10], idx = 0;
    if(!AP_Token(params, idx, cantstr, sizeof(cantstr))) return AP_Msg(playerid, C_ROJO, "Uso: /venderaccion [cantidad]");
    if(!EsNumerico(cantstr)) return AP_Msg(playerid, C_ROJO, "[BOLSA]: Cantidad invalida.");
    new cant = strval(cantstr);
    if(cant < 1 || cant > Player[playerid][pAcciones]) return AP_Msg(playerid, C_ROJO, "[BOLSA]: No tienes tantas acciones.");

    new precio = AP_BolsaPrecio();
    new total = cant * precio;
    Player[playerid][pAcciones] -= cant;
    Player[playerid][pBolsa] -= (Player[playerid][pBolsa] * cant) / (Player[playerid][pAcciones] + cant);
    AP_DarDinero(playerid, total);
    format(szString, sizeof(szString), "[BOLSA]: Vendiste %d acciones por $%d.", cant, total);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  8. SEGUROS
//------------------------------------------------------------------------------
CMD:seguro(playerid, params[])
{
    new txt[500];
    format(txt, sizeof(txt),
        "{FFFFFF}Contrata un seguro para tus vehiculos.\n\n{2ECC71}Seguro actual: {FFFFFF}%s\n\n{FFFF00}1) Basico {FFFFFF}$20000 - cubre danos leves\n{FFFF00}2) Completo {FFFFFF}$60000 - cubre cualquier dano\n{FFFF00}3) Premium {FFFFFF}$120000 - cubre todo y robo",
        Player[playerid][pSeguro] == 0 ? "Ninguno" : (Player[playerid][pSeguro] == 1 ? "Basico" : (Player[playerid][pSeguro] == 2 ? "Completo" : "Premium")));
    return ShowPlayerDialog(playerid, D_SEGURO, DIALOG_STYLE_LIST,
        "{00FF00}ASEGURADORA", txt, "Contratar", "Salir");
}

//------------------------------------------------------------------------------
//  9. RADARES Y PEAIES
//------------------------------------------------------------------------------
#define RADAR_VEL_MAX      140.0
#define RADAR_MULTA        2500

// Se llama desde OnPlayerUpdate: multa por exceso de velocidad
stock AP_Radar_Comprobar(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 0;
    if(Player[playerid][pFaccion] == 1) return 0;   // la policia no se multa a si misma
    if(Player[playerid][pServicio]) return 0;

    new veh = GetPlayerVehicleID(playerid);
    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(veh, vx, vy, vz);
    new Float:vel = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0;
    if(vel < RADAR_VEL_MAX) return 0;

    if(Player[playerid][pTiempo] % 10 != 0) return 0;
    if(Player[playerid][pMoney] < RADAR_MULTA) return 0;

    AP_QuitarDinero(playerid, RADAR_MULTA);
    Player[playerid][pMultas] += RADAR_MULTA;
    format(szString, sizeof(szString), "[RADAR]: Exceso de velocidad (%.0f km/h). Multa de $%d.", vel, RADAR_MULTA);
    AP_Msg(playerid, C_ROJO, szString);
    return 1;
}

CMD:peaje(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return AP_Msg(playerid, C_ROJO, "[PEAJE]: Acercate con un vehiculo.");
    if(Player[playerid][pMoney] < 200) return AP_Msg(playerid, C_ROJO, "[PEAJE]: Necesitas $200.");
    AP_QuitarDinero(playerid, 200);
    AP_Msg(playerid, C_AMARILLO, "[PEAJE]: Peaje pagado ($200). Buen viaje.");
    return 1;
}

//------------------------------------------------------------------------------
//  10. HOTELES (alquiler de habitacion como punto de reaparicion)
//------------------------------------------------------------------------------
CMD:hotel(playerid, params[])
{
    new idx = AP_Local_Cercano(playerid);
    if(idx == -1 || Locales[idx][lTipo] != LOC_HOTEL)
        return AP_Msg(playerid, C_ROJO, "[HOTEL]: Debes estar en la recepcion de un hotel.");
    if(Player[playerid][pMoney] < 4500) return AP_Msg(playerid, C_ROJO, "[HOTEL]: La noche cuesta $4500.");

    AP_QuitarDinero(playerid, 4500);
    SetPlayerHealth(playerid, 100.0);
    Player[playerid][pHealth] = 100.0;
    Player[playerid][pHambre] = 100;
    Player[playerid][pSed] = 100;
    AP_Msg(playerid, C_VERDE, "[HOTEL]: Pasaste la noche en el hotel. Vida, hambre y sed restauradas.");
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  DIALOGOS
//------------------------------------------------------------------------------
stock AP_Extra_Dialog(playerid, dialogid, response, listitem, const inputtext[])
{
    switch(dialogid)
    {
        case D_CASINO:
        {
            if(!response) return 1;
            if(Player[playerid][pFichas] <= 0)
                return AP_Msg(playerid, C_ROJO, "[CASINO]: No tienes fichas. Usa /fichas [cantidad].");
            Player[playerid][pDlg][1] = listitem;
            new txt[300];
            format(txt, sizeof(txt), "{FFFFFF}Escribe la cantidad de fichas que quieres apostar:\n{2ECC71}Fichas disponibles: {FFFFFF}%d\n\n{AAAAAA}Minimo %d, maximo %d",
                Player[playerid][pFichas], CASINO_MIN, CASINO_MAX);
            return ShowPlayerDialog(playerid, D_CASINO_APUESTA, DIALOG_STYLE_INPUT,
                "{FF0000}CASINO - APUESTA", txt, "Apostar", "Salir");
        }
        case D_CASINO_APUESTA:
        {
            if(!response) return 1;
            if(strlen(inputtext) < 1 || !EsNumerico(inputtext))
                return AP_Msg(playerid, C_ROJO, "[CASINO]: Apuesta invalida.");

            new apuesta = strval(inputtext);
            if(apuesta < CASINO_MIN || apuesta > CASINO_MAX)
            {
                format(szString, sizeof(szString), "[CASINO]: La apuesta debe estar entre $%d y $%d.", CASINO_MIN, CASINO_MAX);
                return AP_Msg(playerid, C_ROJO, szString);
            }
            if(apuesta > Player[playerid][pFichas])
                return AP_Msg(playerid, C_ROJO, "[CASINO]: No tienes tantas fichas.");

            Player[playerid][pFichas] -= apuesta;
            new juego = Player[playerid][pDlg][1];
            new gana = 0;
            switch(juego)
            {
                case 0: gana = AP_SlotJugar(playerid, apuesta);
                case 1: if(AP_DadosJugar(playerid, apuesta)) gana = apuesta * 2;
                case 2: gana = AP_RuletaJugar(playerid, apuesta, 0, 0);
                case 3: gana = AP_BlackjackJugar(playerid, apuesta);
                default: gana = 0;
            }
            if(gana > 0)
            {
                Player[playerid][pFichas] += gana;
                Player[playerid][pGanadas] += gana;
                AP_LogroConseguir(playerid, 5);
            }
            else Player[playerid][pPerdidas] += apuesta;
            AP_GuardarCuenta(playerid);
            return 1;
        }
        case D_BODA:
        {
            new otro = Player[playerid][pDlg][2];
            if(!response)
            {
                if(IsPlayerConnected(otro) && Player[otro][pOnline])
                    AP_Msg(otro, C_ROJO, "[BODA]: Rechazaron tu propuesta.");
                return 1;
            }
            if(otro == playerid || !IsPlayerConnected(otro) || !Player[otro][pOnline])
                return AP_Msg(playerid, C_ROJO, "[BODA]: Quien te propuso matrimonio ya no esta.");
            if(Player[otro][pMoney] < 50000) return AP_Msg(playerid, C_ROJO, "[BODA]: El otro no tiene el dinero.");

            AP_QuitarDinero(otro, 50000);
            Player[playerid][pConyuge] = otro;
            Player[otro][pConyuge] = playerid;
            AP_MsgAll(C_ROSADO, "[BODA]: Se celebro una boda en el servidor. Enhorabuena a la pareja.");
            AP_LogroConseguir(playerid, 4);
            AP_LogroConseguir(otro, 4);
            AP_GuardarCuenta(playerid);
            AP_GuardarCuenta(otro);
            return 1;
        }
        case D_PRESTAMO:
        {
            if(!response) return 1;
            if(strlen(inputtext) < 1 || !EsNumerico(inputtext))
                return AP_Msg(playerid, C_ROJO, "[BANCO]: Cantidad invalida.");
            new cant = strval(inputtext);
            if(cant < 1000 || cant > PRESTAMO_MAX)
            {
                format(szString, sizeof(szString), "[BANCO]: Entre $1000 y $%d.", PRESTAMO_MAX);
                return AP_Msg(playerid, C_ROJO, szString);
            }
            Player[playerid][pPrestamo] = cant;
            Player[playerid][pDeuda] = cant + (cant * INTERES_PRESTAMO / 100);
            AP_DarDinero(playerid, cant);
            format(szString, sizeof(szString), "[BANCO]: Prestamo concedido. Deuda total: $%d.", Player[playerid][pDeuda]);
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
        case D_SEGURO:
        {
            if(!response) return 1;
            new precios[3] = { 20000, 60000, 120000 };
            if(listitem < 0 || listitem > 2) return 1;
            if(Player[playerid][pMoney] < precios[listitem])
                return AP_Msg(playerid, C_ROJO, "[SEGURO]: No tienes suficiente dinero.");
            AP_QuitarDinero(playerid, precios[listitem]);
            Player[playerid][pSeguro] = listitem + 1;
            format(szString, sizeof(szString), "[SEGURO]: Contrataste el plan %s.", (listitem == 0) ? "Basico" : ((listitem == 1) ? "Completo" : "Premium"));
            AP_Msg(playerid, C_VERDE, szString);
            AP_GuardarCuenta(playerid);
            return 1;
        }
    }
    return 0;
}
