//  ENUMERACIONES
//==============================================================================
enum E_PLAYER
{
    bool:pOnline,
    bool:pRegistrado,
    bool:pStats,
    pPass[17],
    pEmail[46],
    pAdmin,
    bool:pDuty,
    pSkin,
    pMoney,
    pBank,
    pScore,
    pXP,
    pStyle,
    Float:pHealth,
    Float:pArmour,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInt,
    pVW,
    pWanted,
    bool:pJail,
    pJailTime,
    bool:pDead,
    bool:pMuted,
    pMuteTime,
    bool:pBaneado,
    pTiempo,
    pHoras,
    pJob,
    pJobExp[MAX_TRABAJOS],
    bool:pRuta,
    pRutaPaso,
    pJobVeh,
    pFaccion,
    pRango,
    bool:pServicio,
    pItem[MAX_ITEMS],
    pArma[13],
    pMunicion[13],
    pTelefono,
    pSaldo,
    bool:pLlamada,
    pLlamadaCon,
    pContacto[MAX_CONTACTOS],
    pCasa,
    pNegocio,
    pMuertes,
    pArrestos,
    pMultas,
    pRutas,
    pVIP,
    pHambre,
    pSed,
    pLastCmd,
    pReporte,
    pDuda,
    pDlg[6],
    pEspectando,
    bool:pCongelado,
    pRegistro[26],
    pLogin[26],
    pColor,
    bool:pEnCasa,
    bool:pEsposado,
    pRadio,

    //--- Sistema de habilidades (skills) ---
    pSkill[MAX_SKILLS],

    //--- Sistema de companero IA (novia, amigo, guardaespaldas, mascota) ---
    pCompTipo,          // 0 = sin companero
    pCompAfin,          // 0-100
    pCompMood,          // animo actual
    pCompNombre,        // id del nombre elegido
    pCompNivel,         // nivel de relacion
    pCompEstado,        // 0 inactivo, 1 activo, 2 descansando
    pCompActor,         // id del actor (NPC) en el servidor
    pCompTiempo,        // segundos desde la ultima interaccion
    pCompCitas,         // citas concedidas
    pCompRegalo,        // ultimo regalo recibido

    //--- Sistema de combustible y mecanica ---
    Float:pGasolina,
    bool:pMotorDa,
    pKm,

    //--- Casino y apuestas ---
    pFichas,
    pGanadas,
    pPerdidas,

    //--- Misiones, logros y recompensas ---
    pMision,
    pMisionPaso,
    pLogros,
    pRachaDias,
    pUltimoDia,

    //--- Matrimonio ---
    pConyuge,
    pAnillo,

    //--- Suscripciones y economia avanzada ---
    pSeguro,
    pPrestamo,
    pDeuda,
    pBolsa,
    pAcciones
};

enum E_VEH
{
    vModelo,
    Float:vX,
    Float:vY,
    Float:vZ,
    Float:vA,
    vC1,
    vC2,
    vID
};

enum
{
    D_REG = 1000,
    D_LOG,
    D_MAIL,
    D_GEN,
    D_AYUDA_1,
    D_AYUDA_2,
    D_AYUDA_3,
    D_AYUDA_4,
    D_AYUDA_5,
    D_AYUDA_6,
    D_AYUDA_7,
    D_AYUDA_8,
    D_STATS,
    D_STATS_OTRO,
    D_TRABAJOS,
    D_TRABAJO_CONF,
    D_INVENTARIO,
    D_ITEM_USAR,
    D_ITEM_DAR,
    D_ITEM_TIRAR,
    D_TIENDA,
    D_TIENDA_CANT,
    D_ARMAS,
    D_BANCO,
    D_BANCO_CANT,
    D_TRANSFERIR,
    D_CASAS,
    D_CASA_INFO,
    D_CASA_CONF,
    D_CONCES,
    D_VEHS,
    D_VEH_CONF,
    D_NEGOCIOS,
    D_NEGOCIO_INFO,
    D_NEGOCIO_CANT,
    D_TELEFONO,
    D_SMS_NUM,
    D_SMS_TXT,
    D_CONTACTOS,
    D_CONTACTO_ADD,
    D_FACCION,
    D_FACCION_RANGOS,
    D_FACCION_INVITAR,
    D_ANIMS,
    D_ANUNCIO,
    D_VIP,
    D_JUGADORES,
    D_ADMIN,
    D_ADMIN_NIVEL,
    D_CANTIDAD,
    D_ZONA,

    //--- Sistemas nuevos ---
    D_COMP_PANEL,
    D_COMP_NOMBRE,
    D_COMP_HABLAR,
    D_COMP_REGALO,
    D_COMP_CITA,
    D_LOCAL,
    D_LOCAL_COMPRA,
    D_LOCAL_CANT,
    D_CASINO,
    D_CASINO_APUESTA,
    D_SKILLS,
    D_MISIONES,
    D_LOGROS,
    D_DIARIO,
    D_BODA,
    D_PRESTAMO,
    D_BOLSA,
    D_GASOLINERA,
    D_TALLER,
    D_SEGURO,
    D_HOTEL,
    D_ALQUILER
};

//==============================================================================
//  VARIABLES GLOBALES
//==============================================================================
new Player[MAX_PLAYERS][E_PLAYER];
new VehJug[MAX_PLAYERS][MAX_VEH_JUG][E_VEH];

// Textdraws
new PlayerText:TD_Mensaje[MAX_PLAYERS];
new PlayerText:TD_Aviso[MAX_PLAYERS];
new PlayerText:TD_HUD_Nombre[MAX_PLAYERS];
new PlayerText:TD_HUD_Info[MAX_PLAYERS];
new PlayerText:TD_HUD_Dinero[MAX_PLAYERS];
new Text:TD_Login[8];

// Mapa GPS
new bool:MapaAbierto[MAX_PLAYERS];
new PlayerText:TD_Mapa[5];
new Float:CP_Mapa[MAX_PLAYERS][3];

// Casas y negocios
new CasaDueno[MAX_CASAS][MAX_PLAYER_NAME];
new CasaPickup[MAX_CASAS];
new Text3D:CasaLabel[MAX_CASAS];
new NegocioDueno[MAX_NEGOCIOS][MAX_PLAYER_NAME];
new NegocioPickup[MAX_NEGOCIOS];
new Text3D:NegocioLabel[MAX_NEGOCIOS];
new NegocioCaja[MAX_NEGOCIOS];

// Estado global
new AP_Hora = 12;
new AP_Clima = 1;
new AP_TiempoPayday = 0;
new ContadorReportes = 0;
new ContadorDudas = 0;
new ServidorIniciado = false;
new IntentosLogin[MAX_PLAYERS];
new Text3D:LabelTrabajo[MAX_TRABAJOS];
new PickupTrabajo[MAX_TRABAJOS];

// Buffers globales
new szString[600];
new szString2[600];
new INI_Lineas[MAX_LOGLINEAS][INI_LINEA_LEN];

//==============================================================================
//  FORWARDS
//==============================================================================
forward AP_TimerGeneral();
forward AP_Payday();
forward AP_Unjail(playerid);
forward AP_FinLlamada(playerid);
forward AP_Cosecha(playerid, item);
forward AP_GuardarCuenta(playerid);
forward AP_CargarCuenta(playerid);
forward AP_RegistrarCuenta(playerid);
forward AP_KickInmediato(playerid);
forward AP_Tutorial1(playerid);
forward AP_Tutorial2(playerid);
forward AP_Tutorial3(playerid);
forward AP_Tutorial4(playerid);
forward AP_Tutorial5(playerid);
forward AP_Tutorial6(playerid);
forward AP_Tutorial7(playerid);
forward AP_Tutorial8(playerid);
forward AP_OcultarAviso(playerid);
forward AP_OcultarMensaje(playerid);
forward AP_FinMute(playerid);
forward AP_Reaparecer(playerid);
forward AP_AvisoTrabajo(playerid, trabajo);
forward AP_ActualizarHUD(playerid);
forward AP_MostrarAviso(playerid, const texto[], segundos);
forward AP_MostrarMensaje(playerid, const texto[], segundos);
forward LimpiarChat(playerid);

//==============================================================================
