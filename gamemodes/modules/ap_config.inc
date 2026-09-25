//==============================================================================
//  CONFIGURACION GENERAL DEL SERVIDOR
//==============================================================================
#define SERVER_NAME       "AltaPrevia Roleplay"
#define SERVER_SHORTCUT   "APRP"
#define SERVER_VERSION    "2.0.0"
#define SERVER_HOSTNAME   "AltaPrevia Roleplay | Espanol | Roleplay serio"
#define SERVER_WEBSITE    "discord.gg/altaprevia"
#define SERVER_MAPNAME    "AltaPrevia Roleplay v2.0.0"
#define SERVER_GAMEMODE   "RP - ESP"
#define SERVER_LANGUAGE   "Espanol - Spanish"

// CLAVE MAESTRA para el comando /dameadmin (CAMBIALA ANTES DE ABRIR EL SERVER)
#define ADMIN_KEY         "altaprevia2025"

//------------------------------------------------------------------------------
//  SISTEMA DE NOMBRES
//  1 = se acepta CUALQUIER nombre de jugador de SA-MP (por defecto)
//  0 = se exige el formato de rol Nombre_Apellido y se expulsa al que no lo cumpla
//------------------------------------------------------------------------------
#define NOMBRE_LIBRE      1

// Limites
#undef  MAX_PLAYERS
#define MAX_PLAYERS       50

#define MAX_TRABAJOS      12
#define MAX_CASAS         26
#define MAX_NEGOCIOS      10
#define MAX_ITEMS         16
#define MAX_VEH_JUG       3
#define MAX_CONCES        12
#define MAX_FACCIONES     7
#define MAX_RANGOS        6
#define MAX_CONTACTOS     8
#define MAX_LOGLINEAS     220
#define INI_LINEA_LEN     96

// Tiempos (milisegundos)
#define TIEMPO_PAYDAY    3600000
#define TIEMPO_GUARDAR   300000
#define TIEMPO_HAMBRE    180000

//==============================================================================
//  MACROS Y COLORES
//==============================================================================
#define Loop(%0,%1)          for(new %0 = 0; %0 < %1; ++%0)
#define EOS                 '\0'

#define C_BLANCO        0xFFFFFFFF
#define C_ROJO          0xFF0000FF
#define C_VERDE         0x2ECC71FF
#define C_AZUL          0x33AAFFFF
#define C_AMARILLO      0xFFFF00FF
#define C_NARANJA       0xFF8C00FF
#define C_GRIS          0xBBBBBBFF
#define C_ROSA          0xC2A2DAFF
#define C_MORADO        0xD29BFDFF
#define C_OOC           0xE0E0E0FF
#define C_RADIO         0x9ACD32FF
#define C_DEP                     0x00BFFFFF
#define C_FAC           0xFF69B4FF
#define C_ROSADO        0xFF1493FF

// Comprobacion de nivel de administrador (se usa en todos los modulos)
#define REQ_ADMIN(%0) if(Player[playerid][pAdmin] < %0) { format(szString, sizeof(szString), "[ADMIN]: Necesitas ser %s para usar este comando.", NombreAdmin[%0]); AP_Msg(playerid, C_ROJO, szString); return 1; }

// Niveles de administracion
#define ADM_AYUDANTE    1
#define ADM_MODERADOR   2
#define ADM_ADMIN       3
#define ADM_SUPER       4
#define ADM_DIRECTOR    5
#define ADM_DUENO       6

// Tipos de trabajo
#define TJ_NORMAL       0
#define TJ_TAXI         1
#define TJ_MECANICO     2

// Identificadores de objetos del inventario
enum
{
    ITEM_BOTIQUIN,
    ITEM_MEDICAMENTO,
    ITEM_MARIHUANA,
    ITEM_SEMILLA_MED,
    ITEM_SEMILLA_MAR,
    ITEM_PIEZAS,
    ITEM_REPUESTOS,
    ITEM_MINERALES,
    ITEM_MADERA,
    ITEM_COSECHA,
    ITEM_DROGA,
    ITEM_CERVEZA,
    ITEM_TELEFONO,
    ITEM_RADIO,
    ITEM_ESPOSAS,
    ITEM_LLANTA
};

//==============================================================================

//--- Sistema de companero IA ---
#define COMP_NADA          0
#define COMP_NOVIA         1
#define COMP_AMIGO         2
#define COMP_GUARDA        3
#define COMP_MASCOTA       4

// Estados de animo
#define MOOD_FELIZ         0
#define MOOD_NEUTRAL       1
#define MOOD_TRISTE        2
#define MOOD_ENFADADA      3
#define MOOD_CELOSA        4

// Niveles de relacion
#define REL_CONOCIDOS      0
#define REL_AMIGOS         1
#define REL_NOVIOS         2
#define REL_PAREJA         3
#define REL_ALMAS          4

// Estados del companero
#define CEST_INACTIVO      0
#define CEST_ACTIVO        1
#define CEST_DESCANSANDO   2

#define MAX_COMP_NOMBRES   12
#define COMP_PRECIO        25000
#define COMP_SEGUIMIENTO   6.0

//--- Sistema de habilidades (skills) ---
#define MAX_SKILLS        8
#define SK_CONDUCCION     0
#define SK_PESCA          1
#define SK_DISPARO        2
#define SK_FUERZA         3
#define SK_COCINA         4
#define SK_MECANICA       5
#define SK_NEGOCIOS       6
#define SK_SIGILO         7
