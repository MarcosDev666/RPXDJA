//  RESET DE DATOS Y GUARDADO / CARGA
//==============================================================================
stock AP_ResetJugador(playerid)
{
    Player[playerid][pOnline] = false;
    Player[playerid][pRegistrado] = false;
    Player[playerid][pStats] = false;
    Player[playerid][pPass][0] = EOS;
    Player[playerid][pEmail][0] = EOS;
    Player[playerid][pAdmin] = 0;
    Player[playerid][pDuty] = false;
    Player[playerid][pSkin] = 26;
    Player[playerid][pMoney] = 0;
    Player[playerid][pBank] = 0;
    Player[playerid][pScore] = 1;
    Player[playerid][pXP] = 0;
    Player[playerid][pStyle] = 4;
    Player[playerid][pHealth] = 100.0;
    Player[playerid][pArmour] = 0.0;
    Player[playerid][pPosX] = 1759.4958;
    Player[playerid][pPosY] = -1895.7516;
    Player[playerid][pPosZ] = 13.5612;
    Player[playerid][pPosA] = 269.4692;
    Player[playerid][pInt] = 0;
    Player[playerid][pVW] = 0;
    Player[playerid][pWanted] = 0;
    Player[playerid][pJail] = false;
    Player[playerid][pJailTime] = 0;
    Player[playerid][pDead] = false;
    Player[playerid][pMuted] = false;
    Player[playerid][pMuteTime] = 0;
    Player[playerid][pBaneado] = false;
    Player[playerid][pTiempo] = 0;
    Player[playerid][pHoras] = 0;
    Player[playerid][pJob] = -1;
    Player[playerid][pRuta] = false;
    Player[playerid][pRutaPaso] = 0;
    Player[playerid][pJobVeh] = 0;
    Player[playerid][pFaccion] = 0;
    Player[playerid][pRango] = 0;
    Player[playerid][pServicio] = false;
    Player[playerid][pTelefono] = 0;
    Player[playerid][pSaldo] = 0;
    Player[playerid][pLlamada] = false;
    Player[playerid][pLlamadaCon] = -1;
    Player[playerid][pCasa] = -1;
    Player[playerid][pNegocio] = -1;
    Player[playerid][pMuertes] = 0;
    Player[playerid][pArrestos] = 0;
    Player[playerid][pMultas] = 0;
    Player[playerid][pRutas] = 0;
    Player[playerid][pVIP] = 0;
    Player[playerid][pHambre] = 100;
    Player[playerid][pSed] = 100;
    Player[playerid][pReporte] = -1;
    Player[playerid][pDuda] = -1;
    Player[playerid][pEspectando] = -1;
    Player[playerid][pCongelado] = false;
    Player[playerid][pEsposado] = false;
    Player[playerid][pRadio] = 0;
    Player[playerid][pEnCasa] = false;

    //--- Sistemas nuevos ---
    for(new i = 0; i < MAX_SKILLS; i++) Player[playerid][pSkill][i] = 0;
    Player[playerid][pCompTipo] = COMP_NADA;
    Player[playerid][pCompAfin] = 0;
    Player[playerid][pCompMood] = MOOD_NEUTRAL;
    Player[playerid][pCompNivel] = REL_CONOCIDOS;
    Player[playerid][pCompEstado] = CEST_INACTIVO;
    Player[playerid][pCompActor] = INVALID_ACTOR_ID;
    Player[playerid][pCompTiempo] = 0;
    Player[playerid][pCompCitas] = 0;
    Player[playerid][pCompRegalo] = 0;
    Player[playerid][pGasolina] = 100.0;
    Player[playerid][pMotorDa] = false;
    Player[playerid][pKm] = 0;
    Player[playerid][pFichas] = 0;
    Player[playerid][pGanadas] = 0;
    Player[playerid][pPerdidas] = 0;
    Player[playerid][pMision] = 0;
    Player[playerid][pMisionPaso] = 0;
    Player[playerid][pLogros] = 0;
    Player[playerid][pRachaDias] = 0;
    Player[playerid][pUltimoDia] = 0;
    Player[playerid][pConyuge] = -1;
    Player[playerid][pAnillo] = 0;
    Player[playerid][pSeguro] = 0;
    Player[playerid][pPrestamo] = 0;
    Player[playerid][pDeuda] = 0;
    Player[playerid][pBolsa] = 0;
    Player[playerid][pAcciones] = 0;
    for(new i = 0; i < 6; i++) Player[playerid][pDlg][i] = 0;
    for(new i = 0; i < MAX_TRABAJOS; i++) Player[playerid][pJobExp][i] = 0;
    for(new i = 0; i < MAX_ITEMS; i++) Player[playerid][pItem][i] = 0;
    for(new i = 0; i < 13; i++) { Player[playerid][pArma][i] = 0; Player[playerid][pMunicion][i] = 0; }
    for(new i = 0; i < MAX_CONTACTOS; i++) Player[playerid][pContacto][i] = 0;
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        VehJug[playerid][v][vModelo] = 0;
        VehJug[playerid][v][vID] = 0;
    }
    ResetPlayerMoney(playerid);
    return 1;
}

public AP_GuardarCuenta(playerid)
{
    if(!Player[playerid][pOnline]) return 0;
    new file[64], clave[24];
    AP_NombreArchivo(playerid, file, sizeof(file));

    // Todas las claves se acumulan en memoria y se escriben de una sola vez
    AP_Ini_LoteInicio();

    AP_Ini_LoteSet("Clave",  Player[playerid][pPass]);
    AP_Ini_LoteSet("Email",  Player[playerid][pEmail]);
    AP_Ini_LoteSet("Login",  Player[playerid][pLogin]);
    AP_Ini_LoteInt("Stats",  Player[playerid][pStats] ? 1 : 0);
    AP_Ini_LoteInt("Admin",  Player[playerid][pAdmin]);
    AP_Ini_LoteInt("Skin",   Player[playerid][pSkin]);
    AP_Ini_LoteInt("Money",  Player[playerid][pMoney]);
    AP_Ini_LoteInt("Bank",   Player[playerid][pBank]);
    AP_Ini_LoteInt("Score",  Player[playerid][pScore]);
    AP_Ini_LoteInt("XP",     Player[playerid][pXP]);
    AP_Ini_LoteInt("Style",  Player[playerid][pStyle]);
    AP_Ini_LoteFloat("Health", Player[playerid][pHealth]);
    AP_Ini_LoteFloat("Armour", Player[playerid][pArmour]);
    AP_Ini_LoteFloat("PosX", Player[playerid][pPosX]);
    AP_Ini_LoteFloat("PosY", Player[playerid][pPosY]);
    AP_Ini_LoteFloat("PosZ", Player[playerid][pPosZ]);
    AP_Ini_LoteFloat("PosA", Player[playerid][pPosA]);
    AP_Ini_LoteInt("Int",    Player[playerid][pInt]);
    AP_Ini_LoteInt("VW",     Player[playerid][pVW]);
    AP_Ini_LoteInt("Wanted", Player[playerid][pWanted]);
    AP_Ini_LoteInt("Jail",   Player[playerid][pJail] ? 1 : 0);
    AP_Ini_LoteInt("JailTime", Player[playerid][pJailTime]);
    AP_Ini_LoteInt("Dead",   Player[playerid][pDead] ? 1 : 0);
    AP_Ini_LoteInt("Muted",  Player[playerid][pMuted] ? 1 : 0);
    AP_Ini_LoteInt("MuteTime", Player[playerid][pMuteTime]);
    AP_Ini_LoteInt("Baned",  Player[playerid][pBaneado] ? 1 : 0);
    AP_Ini_LoteInt("Tiempo", Player[playerid][pTiempo]);
    AP_Ini_LoteInt("Horas",  Player[playerid][pHoras]);
    AP_Ini_LoteInt("Job",    Player[playerid][pJob]);
    AP_Ini_LoteInt("Faccion", Player[playerid][pFaccion]);
    AP_Ini_LoteInt("Rango",  Player[playerid][pRango]);
    AP_Ini_LoteInt("Telefono", Player[playerid][pTelefono]);
    AP_Ini_LoteInt("Saldo",  Player[playerid][pSaldo]);
    AP_Ini_LoteInt("Casa",   Player[playerid][pCasa]);
    AP_Ini_LoteInt("Negocio", Player[playerid][pNegocio]);
    AP_Ini_LoteInt("Muertes", Player[playerid][pMuertes]);
    AP_Ini_LoteInt("Arrestos", Player[playerid][pArrestos]);
    AP_Ini_LoteInt("Multas", Player[playerid][pMultas]);
    AP_Ini_LoteInt("Rutas",  Player[playerid][pRutas]);
    AP_Ini_LoteInt("VIP",    Player[playerid][pVIP]);
    AP_Ini_LoteInt("Hambre", Player[playerid][pHambre]);
    AP_Ini_LoteInt("Sed",    Player[playerid][pSed]);

    // Habilidades (sistema de skills)
    for(new i = 0; i < MAX_SKILLS; i++)
    {
        format(clave, sizeof(clave), "Skill%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pSkill][i]);
    }

    // Experiencia de cada trabajo
    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        format(clave, sizeof(clave), "JobExp%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pJobExp][i]);
    }
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        format(clave, sizeof(clave), "Item%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pItem][i]);
    }
    for(new i = 0; i < 13; i++)
    {
        format(clave, sizeof(clave), "Arma%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pArma][i]);
        format(clave, sizeof(clave), "Municion%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pMunicion][i]);
    }
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        format(clave, sizeof(clave), "Contacto%d", i);
        AP_Ini_LoteInt(clave, Player[playerid][pContacto][i]);
    }
    // Vehiculos personales
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        format(clave, sizeof(clave), "Veh%d", v);
        if(VehJug[playerid][v][vModelo] == 0)
        {
            AP_Ini_LoteSet(clave, "0");
            continue;
        }
        new dato[80];
        format(dato, sizeof(dato), "%d %.2f %.2f %.2f %.2f %d %d",
            VehJug[playerid][v][vModelo], VehJug[playerid][v][vX], VehJug[playerid][v][vY],
            VehJug[playerid][v][vZ], VehJug[playerid][v][vA], VehJug[playerid][v][vC1], VehJug[playerid][v][vC2]);
        AP_Ini_LoteSet(clave, dato);
    }
    // Companero (novia IA / amigo / guardaespaldas / mascota)
    format(clave, sizeof(clave), "CompTipo");
    AP_Ini_LoteInt(clave, Player[playerid][pCompTipo]);
    AP_Ini_LoteInt("CompAfin", Player[playerid][pCompAfin]);
    AP_Ini_LoteInt("CompMood", Player[playerid][pCompMood]);
    AP_Ini_LoteInt("CompNombre", Player[playerid][pCompNombre]);
    AP_Ini_LoteInt("CompNivel", Player[playerid][pCompNivel]);
    AP_Ini_LoteInt("CompEstado", Player[playerid][pCompEstado]);

    return AP_Ini_LoteFin(file);
}

public AP_CargarCuenta(playerid)
{
    new file[64], clave[24], valor[96];
    AP_NombreArchivo(playerid, file, sizeof(file));
    if(!fexist(file)) return 0;

    AP_Ini_Str(file, "Clave", Player[playerid][pPass], 17);
    AP_Ini_Str(file, "Email", Player[playerid][pEmail], 46);
    AP_Ini_Str(file, "Login", Player[playerid][pLogin], 26);

    Player[playerid][pStats]        = AP_Ini_Int(file, "Stats", 0) ? true : false;
    Player[playerid][pAdmin]       = AP_Ini_Int(file, "Admin", 0);
    // Compatibilidad: los niveles del sistema anterior estaban en
    // scriptfiles/Administradores/Nombre.ini con la clave NivelAdmin
    if(!AP_Ini_Leer(file, "Admin", szString))
    {
        new adminfile[64];
        AP_NombreAdminArchivo(playerid, adminfile, sizeof(adminfile));
        if(AP_Ini_Leer(adminfile, "NivelAdmin", szString))
            Player[playerid][pAdmin] = strval(szString);
    }
    Player[playerid][pSkin]        = AP_Ini_IntL(file, "Skin", "pSkin", 26);
    Player[playerid][pMoney]       = AP_Ini_IntL(file, "Money", "pMoney", 25000);
    Player[playerid][pBank]        = AP_Ini_Int(file, "Bank", 0);
    Player[playerid][pScore]       = AP_Ini_IntL(file, "Score", "pScore", 1);
    Player[playerid][pXP]          = AP_Ini_Int(file, "XP", 0);
    Player[playerid][pStyle]       = AP_Ini_IntL(file, "Style", "pStyle", 4);
    Player[playerid][pHealth]      = AP_Ini_FloatL(file, "Health", "pHealth", 100.0);
    Player[playerid][pArmour]      = AP_Ini_FloatL(file, "Armour", "pArmour", 0.0);
    Player[playerid][pPosX]        = AP_Ini_FloatL(file, "PosX", "pPosX", 1759.4958);
    Player[playerid][pPosY]        = AP_Ini_FloatL(file, "PosY", "pPosY", -1895.7516);
    Player[playerid][pPosZ]        = AP_Ini_FloatL(file, "PosZ", "pPosZ", 13.5612);
    Player[playerid][pPosA]        = AP_Ini_FloatL(file, "PosA", "pPosA", 269.4692);
    Player[playerid][pInt]         = AP_Ini_IntL(file, "Int", "pInt", 0);
    Player[playerid][pVW]          = AP_Ini_IntL(file, "VW", "pVW", 0);
    Player[playerid][pWanted]      = AP_Ini_IntL(file, "Wanted", "pWanted", 0);
    Player[playerid][pJail]        = AP_Ini_Int(file, "Jail", 0) ? true : false;
    Player[playerid][pJailTime]    = AP_Ini_Int(file, "JailTime", 0);
    Player[playerid][pDead]        = AP_Ini_Int(file, "Dead", 0) ? true : false;
    Player[playerid][pMuted]       = AP_Ini_Int(file, "Muted", 0) ? true : false;
    Player[playerid][pMuteTime]    = AP_Ini_Int(file, "MuteTime", 0);
    Player[playerid][pBaneado]     = AP_Ini_Int(file, "Baned", 0) ? true : false;
    Player[playerid][pTiempo]      = AP_Ini_Int(file, "Tiempo", 0);
    Player[playerid][pHoras]       = AP_Ini_Int(file, "Horas", 0);
    Player[playerid][pJob]         = AP_Ini_Int(file, "Job", -1);
    Player[playerid][pFaccion]     = AP_Ini_Int(file, "Faccion", 0);
    Player[playerid][pRango]       = AP_Ini_Int(file, "Rango", 0);
    Player[playerid][pTelefono]    = AP_Ini_Int(file, "Telefono", 0);
    Player[playerid][pSaldo]       = AP_Ini_Int(file, "Saldo", 0);
    Player[playerid][pCasa]        = AP_Ini_Int(file, "Casa", -1);
    Player[playerid][pNegocio]     = AP_Ini_Int(file, "Negocio", -1);
    Player[playerid][pMuertes]     = AP_Ini_Int(file, "Muertes", 0);
    Player[playerid][pArrestos]    = AP_Ini_Int(file, "Arrestos", 0);
    Player[playerid][pMultas]      = AP_Ini_Int(file, "Multas", 0);
    Player[playerid][pRutas]       = AP_Ini_Int(file, "Rutas", 0);
    Player[playerid][pVIP]         = AP_Ini_Int(file, "VIP", 0);
    Player[playerid][pHambre]      = AP_Ini_Int(file, "Hambre", 100);
    Player[playerid][pSed]         = AP_Ini_Int(file, "Sed", 100);

    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        format(clave, sizeof(clave), "JobExp%d", i);
        Player[playerid][pJobExp][i] = AP_Ini_Int(file, clave, 0);
    }
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        format(clave, sizeof(clave), "Item%d", i);
        Player[playerid][pItem][i] = AP_Ini_Int(file, clave, 0);
    }
    for(new i = 0; i < 13; i++)
    {
        format(clave, sizeof(clave), "Arma%d", i);
        Player[playerid][pArma][i] = AP_Ini_Int(file, clave, 0);
        format(clave, sizeof(clave), "Municion%d", i);
        Player[playerid][pMunicion][i] = AP_Ini_Int(file, clave, 0);
    }
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        format(clave, sizeof(clave), "Contacto%d", i);
        Player[playerid][pContacto][i] = AP_Ini_Int(file, clave, 0);
    }
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        format(clave, sizeof(clave), "Veh%d", v);
        AP_Ini_Str(file, clave, valor);
        VehJug[playerid][v][vModelo] = 0;
        VehJug[playerid][v][vID] = 0;
        if(strlen(valor) < 3) continue;
        new idx = 0, tok[24];
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vModelo] = strval(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vX] = floatstr(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vY] = floatstr(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vZ] = floatstr(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vA] = floatstr(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vC1] = strval(tok);
        AP_Token(valor, idx, tok, sizeof(tok)); VehJug[playerid][v][vC2] = strval(tok);
    }

    // Duenos fijos del servidor
    for(new i = 0; i < sizeof(DuenosFijos); i++)
    {
        if(!strcmp(NombreJugador(playerid), DuenosFijos[i], true))
        {
            Player[playerid][pAdmin] = ADM_DUENO;
            AP_Ini_IntSet(file, "Admin", ADM_DUENO);
        }
    }

    //--- Sistemas nuevos ---
    for(new i = 0; i < MAX_SKILLS; i++)
    {
        format(clave, sizeof(clave), "Skill%d", i);
        Player[playerid][pSkill][i] = AP_Ini_Int(file, clave, 0);
    }
    Player[playerid][pCompTipo]   = AP_Ini_Int(file, "CompTipo", COMP_NADA);
    Player[playerid][pCompAfin]   = AP_Ini_Int(file, "CompAfin", 0);
    Player[playerid][pCompMood]   = AP_Ini_Int(file, "CompMood", MOOD_NEUTRAL);
    Player[playerid][pCompNombre] = AP_Ini_Int(file, "CompNombre", 0);
    Player[playerid][pCompNivel]  = AP_Ini_Int(file, "CompNivel", REL_CONOCIDOS);
    Player[playerid][pCompEstado] = AP_Ini_Int(file, "CompEstado", CEST_INACTIVO);
    Player[playerid][pCompCitas]  = AP_Ini_Int(file, "CompCitas", 0);
    Player[playerid][pCompActor]  = INVALID_ACTOR_ID;
    Player[playerid][pFichas]     = AP_Ini_Int(file, "Fichas", 0);
    Player[playerid][pGanadas]    = AP_Ini_Int(file, "Ganadas", 0);
    Player[playerid][pPerdidas]   = AP_Ini_Int(file, "Perdidas", 0);
    Player[playerid][pMision]     = AP_Ini_Int(file, "Mision", 0);
    Player[playerid][pMisionPaso] = AP_Ini_Int(file, "MisionPaso", 0);
    Player[playerid][pLogros]     = AP_Ini_Int(file, "Logros", 0);
    Player[playerid][pRachaDias]  = AP_Ini_Int(file, "RachaDias", 0);
    Player[playerid][pUltimoDia]  = AP_Ini_Int(file, "UltimoDia", 0);
    Player[playerid][pConyuge]    = AP_Ini_Int(file, "Conyuge", -1);
    Player[playerid][pAnillo]     = AP_Ini_Int(file, "Anillo", 0);
    Player[playerid][pSeguro]     = AP_Ini_Int(file, "Seguro", 0);
    Player[playerid][pPrestamo]   = AP_Ini_Int(file, "Prestamo", 0);
    Player[playerid][pDeuda]      = AP_Ini_Int(file, "Deuda", 0);
    Player[playerid][pBolsa]      = AP_Ini_Int(file, "Bolsa", 0);
    Player[playerid][pAcciones]   = AP_Ini_Int(file, "Acciones", 0);
    if(Player[playerid][pCompTipo] != COMP_NADA && Player[playerid][pCompEstado] == CEST_ACTIVO)
        AP_Comp_SpawnActor(playerid);

    // La casa pasa a estar ocupada por este jugador
    if(Player[playerid][pCasa] >= 0 && Player[playerid][pCasa] < MAX_CASAS)
        format(CasaDueno[Player[playerid][pCasa]], MAX_PLAYER_NAME, "%s", NombreJugador(playerid));
    if(Player[playerid][pNegocio] >= 0 && Player[playerid][pNegocio] < MAX_NEGOCIOS)
        format(NegocioDueno[Player[playerid][pNegocio]], MAX_PLAYER_NAME, "%s", NombreJugador(playerid));

    Player[playerid][pOnline] = true;
    Player[playerid][pRegistrado] = true;
    return 1;
}

public AP_RegistrarCuenta(playerid)
{
    new file[64], str[64], d, m, a, h, mi, s;
    AP_NombreArchivo(playerid, file, sizeof(file));
    getdate(a, m, d);
    gettime(h, mi, s);
    format(str, sizeof(str), "%02d/%02d/%04d %02d:%02d:%02d", d, m, a, h, mi, s);

    AP_Ini_StrSet(file, "Clave", Player[playerid][pPass]);
    AP_Ini_StrSet(file, "Email", Player[playerid][pEmail]);
    AP_Ini_StrSet(file, "Regin", str);
    AP_Ini_StrSet(file, "Login", str);
    AP_Ini_IntSet(file, "Stats", 0);
    AP_Ini_IntSet(file, "Admin", 0);
    AP_Ini_IntSet(file, "Skin", Player[playerid][pSkin]);
    AP_Ini_IntSet(file, "Money", 25000);
    AP_Ini_IntSet(file, "Bank", 2500);
    AP_Ini_IntSet(file, "Score", 1);
    AP_Ini_IntSet(file, "XP", 0);
    AP_Ini_IntSet(file, "Style", 4);
    AP_Ini_FloatSet(file, "Health", 100.0);
    AP_Ini_FloatSet(file, "Armour", 0.0);
    AP_Ini_FloatSet(file, "PosX", 1759.4958);
    AP_Ini_FloatSet(file, "PosY", -1895.7516);
    AP_Ini_FloatSet(file, "PosZ", 13.5612);
    AP_Ini_FloatSet(file, "PosA", 269.4692);
    AP_Ini_IntSet(file, "Int", 0);
    AP_Ini_IntSet(file, "VW", 0);
    AP_Ini_IntSet(file, "Wanted", 0);
    AP_Ini_IntSet(file, "Jail", 0);
    AP_Ini_IntSet(file, "JailTime", 0);
    AP_Ini_IntSet(file, "Dead", 0);
    AP_Ini_IntSet(file, "Muted", 0);
    AP_Ini_IntSet(file, "MuteTime", 0);
    AP_Ini_IntSet(file, "Baned", 0);
    AP_Ini_IntSet(file, "Tiempo", 0);
    AP_Ini_IntSet(file, "Horas", 0);
    AP_Ini_IntSet(file, "Job", -1);
    AP_Ini_IntSet(file, "Faccion", 0);
    AP_Ini_IntSet(file, "Rango", 0);
    AP_Ini_IntSet(file, "Telefono", 0);
    AP_Ini_IntSet(file, "Saldo", 0);
    AP_Ini_IntSet(file, "Casa", -1);
    AP_Ini_IntSet(file, "Negocio", -1);
    AP_Ini_IntSet(file, "Muertes", 0);
    AP_Ini_IntSet(file, "Arrestos", 0);
    AP_Ini_IntSet(file, "Multas", 0);
    AP_Ini_IntSet(file, "Rutas", 0);
    AP_Ini_IntSet(file, "VIP", 0);
    AP_Ini_IntSet(file, "Hambre", 100);
    AP_Ini_IntSet(file, "Sed", 100);
    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        format(str, sizeof(str), "JobExp%d", i);
        AP_Ini_IntSet(file, str, 0);
    }
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        format(str, sizeof(str), "Item%d", i);
        AP_Ini_IntSet(file, str, 0);
    }
    for(new i = 0; i < 13; i++)
    {
        format(str, sizeof(str), "Arma%d", i);
        AP_Ini_IntSet(file, str, 0);
        format(str, sizeof(str), "Municion%d", i);
        AP_Ini_IntSet(file, str, 0);
    }
    for(new i = 0; i < MAX_VEH_JUG; i++)
    {
        format(str, sizeof(str), "Veh%d", i);
        AP_Ini_StrSet(file, str, "0");
    }
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        format(str, sizeof(str), "Contacto%d", i);
        AP_Ini_IntSet(file, str, 0);
    }
    AP_Log("Registros", "Nueva cuenta registrada en el sistema.");
    return 1;
}

//==============================================================================
//  APLICAR DATOS AL SPAWN
//==============================================================================
stock AP_AplicarDatos(playerid)
{
    SetPlayerSkin(playerid, Player[playerid][pSkin]);
    SetPlayerScore(playerid, Player[playerid][pScore]);
    SetPlayerFightingStyle(playerid, Player[playerid][pStyle]);
    SetPlayerWantedLevel(playerid, Player[playerid][pWanted]);
    SetPlayerHealth(playerid, Player[playerid][pHealth]);
    SetPlayerArmour(playerid, Player[playerid][pArmour]);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, Player[playerid][pMoney]);
    AP_DarArmas(playerid);
    AP_ActualizarHUD(playerid);
    return 1;
}

stock AP_PrepararSpawn(playerid)
{
    if(Player[playerid][pJail])
    {
        SetSpawnInfo(playerid, -1, Player[playerid][pSkin], 1533.6067, -1638.8525, 2024.4063, 359.1107, 0, 0, 0, 0, 0, 0);
        Player[playerid][pInt] = 3;
        Player[playerid][pVW] = 0;
        Player[playerid][pPosX] = 1533.6067;
        Player[playerid][pPosY] = -1638.8525;
        Player[playerid][pPosZ] = 2024.4063;
        Player[playerid][pPosA] = 359.1107;
    }
    else if(Player[playerid][pCasa] >= 0)
    {
        SetSpawnInfo(playerid, -1, Player[playerid][pSkin], CasaExt[Player[playerid][pCasa]][0], CasaExt[Player[playerid][pCasa]][1], CasaExt[Player[playerid][pCasa]][2], CasaExt[Player[playerid][pCasa]][3], 0, 0, 0, 0, 0, 0);
        Player[playerid][pPosX] = CasaExt[Player[playerid][pCasa]][0];
        Player[playerid][pPosY] = CasaExt[Player[playerid][pCasa]][1];
        Player[playerid][pPosZ] = CasaExt[Player[playerid][pCasa]][2];
        Player[playerid][pPosA] = CasaExt[Player[playerid][pCasa]][3];
        Player[playerid][pInt] = 0;
        Player[playerid][pVW] = 0;
    }
    else
    {
        SetSpawnInfo(playerid, -1, Player[playerid][pSkin], Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ], Player[playerid][pPosA], 0, 0, 0, 0, 0, 0);
    }
    return 1;
}

//==============================================================================
//  ARMAS PERSISTENTES
//==============================================================================
stock AP_SlotArma(armaid)
{
    switch(armaid)
    {
        case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15: return 0;
        case 22, 23, 24: return 1;
        case 25, 26, 27: return 2;
        case 28, 29, 32: return 3;
        case 30, 31: return 4;
        case 33, 34: return 5;
        case 35, 36, 37, 38: return 6;
        case 16, 17, 18, 39: return 7;
        case 41, 42, 43: return 8;
        case 44, 45, 46: return 10;
        case 40: return 11;
    }
    return 12;
}

stock AP_DarArmas(playerid)
{
    for(new s = 0; s < 13; s++)
    {
        if(Player[playerid][pArma][s] > 0 && Player[playerid][pArma][s] != 0 && Player[playerid][pMunicion][s] > 0)
            GivePlayerWeapon(playerid, Player[playerid][pArma][s], Player[playerid][pMunicion][s]);
    }
    return 1;
}

stock AP_QuitarArmas(playerid)
{
    ResetPlayerWeapons(playerid);
    for(new s = 0; s < 13; s++)
    {
        Player[playerid][pArma][s] = 0;
        Player[playerid][pMunicion][s] = 0;
    }
    return 1;
}

// Registra el arma que el jugador lleva en las manos (llamar en OnPlayerUpdate)
stock AP_RegistrarArmaActual(playerid)
{
    new arma = GetPlayerWeapon(playerid);
    if(arma <= 0 || arma >= 47) return 0;
    new slot = AP_SlotArma(arma);
    Player[playerid][pArma][slot] = arma;
    Player[playerid][pMunicion][slot] = GetPlayerAmmo(playerid);
    return 1;
}

//==============================================================================
//  DINERO
//==============================================================================
stock AP_SetDinero(playerid, monto)
{
    if(monto < 0) monto = 0;
    if(monto > 99999999) monto = 99999999;
    Player[playerid][pMoney] = monto;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, monto);
    AP_ActualizarHUD(playerid);
    return 1;
}

stock AP_DarDinero(playerid, monto)
{
    return AP_SetDinero(playerid, Player[playerid][pMoney] + monto);
}

stock AP_QuitarDinero(playerid, monto)
{
    if(monto < 0) return 0;
    if(Player[playerid][pMoney] < monto) return 0;
    return AP_SetDinero(playerid, Player[playerid][pMoney] - monto);
}

stock AP_SetBanco(playerid, monto)
{
    if(monto < 0) monto = 0;
    if(monto > 99999999) monto = 99999999;
    Player[playerid][pBank] = monto;
    AP_ActualizarHUD(playerid);
    return 1;
}

//==============================================================================
//  EXPERIENCIA Y NIVELES
//==============================================================================
stock AP_DarExperiencia(playerid, cantidad)
{
    Player[playerid][pXP] += cantidad;
    while(Player[playerid][pXP] >= Player[playerid][pScore] * 100)
    {
        Player[playerid][pXP] -= Player[playerid][pScore] * 100;
        Player[playerid][pScore]++;
        SetPlayerScore(playerid, Player[playerid][pScore]);
        format(szString, sizeof(szString), "~g~~h~NIVEL %d~w~~h~ Has subido de nivel. Sigue jugando para crecer.", Player[playerid][pScore]);
        AP_MostrarAviso(playerid, szString, 6);
        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
        SetPlayerHealth(playerid, 100.0);
    }
    AP_ActualizarHUD(playerid);
    if(Player[playerid][pScore] >= 100) AP_LogroConseguir(playerid, 9);
    return 1;
}

stock AP_DarExperienciaTrabajo(playerid, trabajo, cantidad)
{
    if(trabajo < 0 || trabajo >= MAX_TRABAJOS) return 0;
    Player[playerid][pJobExp][trabajo] += cantidad;
    format(szString, sizeof(szString), "Experiencia en %s: %d", NombreTrabajo[trabajo], Player[playerid][pJobExp][trabajo]);
    AP_MostrarMensaje(playerid, szString, 4);
    AP_DarExperiencia(playerid, 2);
    return 1;
}

//==============================================================================
