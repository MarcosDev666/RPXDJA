/*================================================================================

        A L T A P R E V I A   R O L E P L A Y
        ================================

        Gamemode Roleplay en espanol para SA-MP 0.3.7 (Windows / Linux)

        CONTENIDO
        --------
        * 12 TRABAJOS completos y funcionales (10 legales + 2 ilegales)
             1) Repartidor de Pizza      6) Minero
             2) Basurero                 7) Lenador
             3) Camionero                8) Granjero
             4) Lechero                  9) Taxista
             5) Pescador                10) Mecanico
                                       11) Ladron de Vehiculos   (ilegal)
                                       12) Contrabandista        (ilegal)

        * 36 SISTEMAS completos y funcionales
             01 Cuentas .ini (registro / login / email)
             02 Guardado automatico y manual
             03 Sistema de administracion por 6 niveles
             04 Anti-flood de comandos y de chat
             05 Anti-cheat basico (dinero, vida, jetpack)
             06 HUD personalizado
             07 GPS / mapa con destino
             08 Chat IC (/me /do /b /s /susurrar /gritar)
             09 Chat OOC (/ooc /n /duda /reportar)
             10 Telefono movil (llamadas, SMS, contactos, saldo)
             11 Cuenta bancaria (depositar, retirar, transferir, intereses)
             12 Tiendas 24/7
             13 Ammu-Nation (armas y chalecos)
             14 Inventario de items (usar / dar / tirar / vender)
             15 Drogas, semillas, cultivo y cosecha
             16 Armas y municion persistentes
             17 Propiedades (casas con interior propio)
             18 Vehiculos personales (compra, spawn, guardado, venta)
             19 Negocios / empresas con recaudacion
             20 Facciones con 6 rangos y nomina
             21 Sistema de trabajos por checkpoints
             22 Experiencia, niveles y sueldo
             23 Payday cada hora (sueldo, intereses, impuestos, nomina)
             24 Hambre y sed
             25 Carcel, wanted level, multas y arrestos
             26 Muerte RP, heridos y reanimacion (EMS)
             27 Animaciones
             28 Skins / vestimenta
             29 Estadisticas del jugador
             30 Reportes y dudas para el staff
             31 Logs del servidor (admin, economia, chat)
             32 Clima y hora dinamicos
             33 Espectador para administradores
             34 Sistema VIP (3 niveles con beneficios)
             35 Tutorial de bienvenida
             36 Control de vehiculos (reparar, Flip, gasolina visual)

        * SISTEMA DE ADMINISTRACION POR NIVELES
             Nivel 1  Ayudante         - atiende dudas y reportes
             Nivel 2  Moderador        - kick, mute, slap, congelar, jail
             Nivel 3  Administrador    - ban, veh, skin, armas, dinero
             Nivel 4  Super Admin      - nivel, xp, hora, clima, anuncios
             Nivel 5  Director         - vip, coins, hacer admin, economia
             Nivel 6  Dueno            - control total del servidor

        * 127 COMANDOS FUNCIONALES

        NOTAS TECNICAS
        --------------
        * El guardado de datos usa un motor INI propio (nativo de Pawn), por lo
          que NO depende de ningun plugin externo: todo funciona con el servidor
          limpio. Los archivos se guardan en scriptfiles/Cuentas/Nombre_Apellido.ini
        * Texto 100% ASCII (sin acentos) para evitar problemas de codificacion.

================================================================================*/

#include <a_samp>
#include <streamer>
#include <zcmd>
#include <zones>

// Tamano de la pila/memoria dinamica (necesario por los buffers de guardado)
#pragma dynamic 65536

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
    pRadio
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
    D_ZONA
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
//  MOTOR INI PROPIO (sin plugins externos)
//  Todos los datos se guardan en scriptfiles/...
//==============================================================================
stock AP_RutaCuenta(playerid)
{
    new ruta[64];
    format(ruta, sizeof(ruta), "Cuentas/%s.ini", NombreJugador(playerid));
    return ruta;
}

stock AP_RutaAdmin(playerid)
{
    new ruta[64];
    format(ruta, sizeof(ruta), "Administradores/%s.ini", NombreJugador(playerid));
    return ruta;
}

// Lee una linea completa de un archivo (devuelve 0 al finalizar)
stock AP_LeerLinea(File:f, buffer[], maxlen)
{
    new c = fgetchar(f), len = 0;
    while(c != -1 && c != '\n' && len < maxlen - 1)
    {
        if(c != '\r' && c != '\t') buffer[len++] = c;
        c = fgetchar(f);
    }
    buffer[len] = EOS;
    if(len == 0 && c == -1) return 0;
    return 1;
}

stock AP_EscribirLinea(File:f, const texto[])
{
    for(new i = 0; texto[i] != EOS; i++) fputchar(f, texto[i]);
    fputchar(f, '\r');
    fputchar(f, '\n');
    return 1;
}

// Comprueba si "clave" coincide con el principio de la linea (hasta el '=')
stock AP_ClaveCoincide(const linea[], const clave[])
{
    new eq = -1, len = strlen(linea), klen = strlen(clave);
    for(new i = 0; i < len; i++)
    {
        if(linea[i] == '=') { eq = i; break; }
        if(linea[i] == ' ' && i == 0) continue;
    }
    if(eq < 1) return 0;
    new s = 0;
    while(s < eq && linea[s] == ' ') s++;
    new e = eq;
    while(e > s && linea[e - 1] == ' ') e--;
    if((e - s) != klen) return 0;
    for(new i = 0; i < klen; i++) if(linea[s + i] != clave[i]) return 0;
    return 1;
}

// Lee el valor de una clave. Devuelve 1 si existe.
stock AP_Ini_Leer(const archivo[], const clave[], resultado[], maxlen = sizeof(resultado))
{
    resultado[0] = EOS;
    new File:f = fopen(archivo, io_read);
    if(!f) return 0;
    new linea[256];
    while(AP_LeerLinea(f, linea, sizeof(linea)))
    {
        if(!AP_ClaveCoincide(linea, clave)) continue;
        new eq = strfind(linea, "=");
        if(eq < 0) { fclose(f); return 0; }
        new vs = eq + 1;
        while(linea[vs] == ' ') vs++;
        strmid(resultado, linea, vs, strlen(linea), maxlen);
        fclose(f);
        return 1;
    }
    fclose(f);
    return 0;
}

// Escribe (o actualiza) una clave en el archivo
stock AP_Ini_Escribir(const archivo[], const clave[], const valor[])
{
    new total = 0, encontrado = 0;
    new File:f = fopen(archivo, io_read);
    if(f)
    {
        new linea[256];
        while(total < MAX_LOGLINEAS && AP_LeerLinea(f, linea, sizeof(linea)))
        {
            if(strlen(linea) < 1) continue;
            if(AP_ClaveCoincide(linea, clave))
            {
                format(INI_Lineas[total], INI_LINEA_LEN, "%s = %s", clave, valor);
                encontrado = 1;
                total++;
                continue;
            }
            format(INI_Lineas[total], INI_LINEA_LEN, "%s", linea);
            total++;
        }
        fclose(f);
    }
    if(!encontrado && total < MAX_LOGLINEAS)
    {
        format(INI_Lineas[total], INI_LINEA_LEN, "%s = %s", clave, valor);
        total++;
    }
    new File:w = fopen(archivo, io_write);
    if(!w) return 0;
    for(new i = 0; i < total; i++) AP_EscribirLinea(w, INI_Lineas[i]);
    fclose(w);
    return 1;
}

stock AP_Ini_IntSet(const archivo[], const clave[], valor)
{
    new v[16];
    format(v, sizeof(v), "%d", valor);
    return AP_Ini_Escribir(archivo, clave, v);
}

stock AP_Ini_Int(const archivo[], const clave[], defecto = 0)
{
    new v[24];
    if(!AP_Ini_Leer(archivo, clave, v)) return defecto;
    return strval(v);
}

stock AP_Ini_FloatSet(const archivo[], const clave[], Float:valor)
{
    new v[32];
    format(v, sizeof(v), "%.4f", valor);
    return AP_Ini_Escribir(archivo, clave, v);
}

stock Float:AP_Ini_Float(const archivo[], const clave[], Float:defecto = 0.0)
{
    new v[32];
    if(!AP_Ini_Leer(archivo, clave, v)) return defecto;
    return floatstr(v);
}

stock AP_Ini_StrSet(const archivo[], const clave[], const valor[])
{
    return AP_Ini_Escribir(archivo, clave, valor);
}

stock AP_Ini_Str(const archivo[], const clave[], resultado[], maxlen = sizeof(resultado))
{
    return AP_Ini_Leer(archivo, clave, resultado, maxlen);
}

//--- Lectura con compatibilidad para cuentas antiguas (formato DOF2 con "p") ---
stock AP_Ini_IntL(const archivo[], const clave[], const antigua[], defecto = 0)
{
    if(AP_Ini_Leer(archivo, clave, szString)) return strval(szString);
    if(AP_Ini_Leer(archivo, antigua, szString)) return strval(szString);
    return defecto;
}

stock Float:AP_Ini_FloatL(const archivo[], const clave[], const antigua[], Float:defecto = 0.0)
{
    if(AP_Ini_Leer(archivo, clave, szString)) return floatstr(szString);
    if(AP_Ini_Leer(archivo, antigua, szString)) return floatstr(szString);
    return defecto;
}

//==============================================================================
//  UTILIDADES GENERALES
//==============================================================================
stock NombreJugador(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock NombrePorID(id)
{
    new name[MAX_PLAYER_NAME];
    name[0] = EOS;
    if(IsPlayerConnected(id)) GetPlayerName(id, name, sizeof(name));
    else format(name, sizeof(name), "Desconectado");
    return name;
}

// Formato de rol: Nombre_Apellido
stock TieneNombreRol(const name[])
{
    new len = strlen(name), guiones = 0;
    if(len < 4 || len > 20) return 0;
    for(new i = 0; i < len; i++)
    {
        if(name[i] == '_')
        {
            guiones++;
            if(i == 0 || i == len - 1) return 0;
        }
        if(name[i] < 'A' || name[i] > 'z' || (name[i] > 'Z' && name[i] < 'a')) return 0;
    }
    if(guiones != 1) return 0;
    return 1;
}

stock EmailValido(const email[])
{
    new len = strlen(email), arrobas = 0, puntos = 0;
    if(len < 6 || len > 40) return 0;
    for(new i = 0; i < len; i++)
    {
        if(email[i] == '@') { arrobas++; if(puntos > 0) return 0; }
        if(email[i] == '.' && arrobas == 1) puntos++;
    }
    if(arrobas != 1 || puntos < 1) return 0;
    return 1;
}

stock EsNumerico(const texto[])
{
    new len = strlen(texto);
    if(len < 1) return 0;
    for(new i = 0; i < len; i++)
    {
        if(texto[i] < '0' || texto[i] > '9') return 0;
    }
    return 1;
}

stock AP_FormatoDinero(valor)
{
    new v[20], out[24];
    format(v, sizeof(v), "%d", valor);
    new len = strlen(v), pos = 0;
    if(valor < 0) { out[pos++] = '-'; len--; }
    new inicio = (valor < 0) ? 1 : 0;
    new digitos = 0;
    for(new i = inicio; i < strlen(v); i++)
    {
        out[pos++] = v[i];
        digitos++;
        if(digitos < (strlen(v) - inicio) && (strlen(v) - inicio - digitos) % 3 == 0) out[pos++] = '.';
    }
    out[pos] = EOS;
    return out;
}

// Tokenizador simple (separa por espacios)
stock AP_Token(const texto[], &indice, destino[], maxlen)
{
    new len = strlen(texto), inicio = indice, fin = 0;
    while(inicio < len && texto[inicio] == ' ') inicio++;
    fin = inicio;
    while(fin < len && texto[fin] != ' ') fin++;
    if(inicio == fin) { destino[0] = EOS; indice = len; return 0; }
    strmid(destino, texto, inicio, fin, maxlen);
    indice = fin;
    return 1;
}

stock AP_Distancia(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return floatround(floatsqroot(floatpower(floatabs(x1 - x2), 2.0) + floatpower(floatabs(y1 - y2), 2.0) + floatpower(floatabs(z1 - z2), 2.0)));
}

//==============================================================================
//  MENSAJES Y LOGS
//==============================================================================
public LimpiarChat(playerid)
{
    for(new i = 0; i < 50; i++) SendClientMessage(playerid, -1, " ");
    return 1;
}

//==============================================================================
//  MENSAJES Y LOGS
//==============================================================================
// Fecha y hora actual en formato texto
stock AP_FechaActual(destino[], maxlen = sizeof(destino))
{
    new d, m, a, h, mi, s;
    getdate(a, m, d);
    gettime(h, mi, s);
    format(destino, maxlen, "%02d/%02d/%04d %02d:%02d:%02d", d, m, a, h, mi, s);
    return 1;
}

// Escribe una linea en un log del servidor (scriptfiles/Logs/)
stock AP_Log(const archivo[], const texto[])
{
    new ruta[128], linea[400], fecha[40];
    format(ruta, sizeof(ruta), "Logs/%s.log", archivo);
    AP_FechaActual(fecha);
    format(linea, sizeof(linea), "[%s] %s", fecha, texto);
    new File:f = fopen(ruta, io_append);
    if(!f) return 0;
    AP_EscribirLinea(f, linea);
    fclose(f);
    return 1;
}

// Envia un mensaje simple
stock AP_Msg(playerid, color, const texto[])
{
    SendClientMessage(playerid, color, texto);
    return 1;
}

stock AP_MsgAll(color, const texto[])
{
    SendClientMessageToAll(color, texto);
    return 1;
}

//==============================================================================
//  TABLA DE DATOS: TRABAJOS (12)
//==============================================================================
new const NombreTrabajo[MAX_TRABAJOS][] =
{
    "Repartidor de Pizza",
    "Basurero Municipal",
    "Camionero de Carga",
    "Lechero",
    "Pescador",
    "Minero",
    "Lenador",
    "Granjero",
    "Taxista",
    "Mecanico",
    "Ladron de Vehiculos",
    "Contrabandista"
};

new const InfoTrabajo[MAX_TRABAJOS][] =
{
    "Reparte pizzas en moto por Idlewood. Pago por entrega.",
    "Recolecta la basura de los barrios del sur de Los Santos.",
    "Transporta cargas pesadas entre Los Santos, San Fierro y muelles.",
    "Distribuye lacteos por las zonas residenciales.",
    "Pesca en alta mar y vuelve a puerto con la carga.",
    "Extrae mineral en la cantera del condado de Bone.",
    "Tala arboles en los bosques del condado de Flint.",
    "Cosecha los campos de Blueberry con tu tractor.",
    "Lleva pasajeros por la ciudad. Cobras por distancia.",
    "Atiende averias de vehiculos por toda la ciudad.",
    "Roba vehiculos y entregalos en el desguace. ILEGAL.",
    "Mueve mercancia prohibida entre muelles. ILEGAL."
};

new const Float:PosTrabajo[MAX_TRABAJOS][3] =
{
    {2103.5415, -1806.5271, 13.5547},
    {2185.1274, -1974.7554, 13.5512},
    {-77.3621, -1136.2144, 1.0781},
    {2419.0000, -1975.0000, 13.5469},
    {371.0000, -2075.0000, 7.0000},
    {585.0000, 865.0000, -42.0000},
    {-1915.0000, -2680.0000, 44.0000},
    {250.0000, -300.0000, 1.5000},
    {1812.0000, -1860.0000, 13.5469},
    {2071.0000, -1831.0000, 13.5469},
    {2495.0000, -1690.0000, 13.5469},
    {2787.0000, -1617.0000, 10.9219}
};

new const VehTrabajo[MAX_TRABAJOS] = {448, 408, 403, 498, 454, 422, 532, 531, 420, 525, 400, 413};
new const PagoTrabajo[MAX_TRABAJOS] = {350, 420, 950, 500, 850, 700, 650, 560, 250, 700, 1600, 1300};
new const XPTrabajo[MAX_TRABAJOS] = {5, 5, 9, 6, 8, 7, 7, 6, 4, 7, 12, 10};
new const NivelTrabajo[MAX_TRABAJOS] = {1, 1, 3, 2, 2, 4, 4, 3, 2, 5, 6, 7};
new const LegalTrabajo[MAX_TRABAJOS] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0};
new const TipoTrabajo[MAX_TRABAJOS] = {TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_NORMAL, TJ_TAXI, TJ_MECANICO, TJ_NORMAL, TJ_NORMAL};
new const ItemTrabajo[MAX_TRABAJOS] = {ITEM_BOTIQUIN, ITEM_REPUESTOS, ITEM_PIEZAS, ITEM_COSECHA, ITEM_COSECHA, ITEM_MINERALES, ITEM_MADERA, ITEM_COSECHA, ITEM_RADIO, ITEM_REPUESTOS, ITEM_LLANTA, ITEM_DROGA};

new const Float:CPTrabajo[MAX_TRABAJOS][6][3] =
{
    {{2112.9856, -1614.9751, 13.3828}, {2244.6970, -1434.6212, 23.8281}, {2194.4863, -1989.8516, 13.5469}, {2036.9114, -1722.7335, 13.5469}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2379.0305, -1892.4933, 13.3828}, {2486.2949, -2012.3551, 13.5469}, {2298.5542, -1648.5000, 13.5469}, {2143.4000, -1789.5000, 13.5469}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2769.3459, -2441.9741, 13.6358}, {1424.3168, -1320.1075, 13.5421}, {2787.0000, -1617.0000, 10.9219}, {96.0000, -220.0000, 1.5000}, {-77.0000, -1136.0000, 1.0781}, {0.0, 0.0, 0.0}},
    {{2379.0305, -1892.4933, 13.3828}, {2486.2949, -2012.3551, 13.5469}, {2298.5542, -1648.5000, 13.5469}, {2419.0000, -1975.0000, 13.5469}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2200.0000, -2200.0000, 0.0000}, {2600.0000, -2500.0000, 0.0000}, {1800.0000, -2600.0000, 0.0000}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{698.0000, 867.0000, -30.0000}, {600.0000, 940.0000, -30.0000}, {520.0000, 870.0000, -30.0000}, {650.0000, 780.0000, -30.0000}, {590.0000, 1000.0000, -30.0000}, {0.0, 0.0, 0.0}},
    {{-1935.0000, -2680.0000, 44.0000}, {-2010.0000, -2760.0000, 40.0000}, {-1850.0000, -2800.0000, 45.0000}, {-1950.0000, -2600.0000, 42.0000}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{250.0000, -300.0000, 1.5000}, {180.0000, -260.0000, 1.5000}, {320.0000, -380.0000, 1.5000}, {150.0000, -400.0000, 1.5000}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2175.0000, -1010.0000, 45.0000}, {2480.0000, -1650.0000, 13.5469}, {1786.0000, -1904.0000, 13.5469}, {1100.0000, -1600.0000, 20.0000}, {1480.0000, -1770.0000, 18.0000}, {2210.0000, -1150.0000, 25.0000}},
    {{2175.5000, -1012.0000, 45.0000}, {2480.0000, -1650.0000, 13.5469}, {1786.0000, -1904.0000, 13.5469}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2495.0000, -1690.0000, 13.5469}, {2787.0000, -1617.0000, 10.9219}, {-77.0000, -1136.0000, 1.0781}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}},
    {{2787.0000, -1617.0000, 10.9219}, {2769.0000, -2441.0000, 13.6358}, {96.0000, -220.0000, 1.5000}, {1424.3168, -1320.1075, 13.5421}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}}
};

new const NumCPTrabajo[MAX_TRABAJOS] = {4, 4, 5, 4, 3, 5, 4, 4, 6, 3, 3, 4};

//==============================================================================
//  TABLA DE DATOS: PROPIEDADES (CASAS)
//==============================================================================
new const CasaBarrio[MAX_CASAS][] =
{
    "Glen Park", "Idlewood", "Willowfield", "Ganton", "Jefferson",
    "East Beach", "Verona Beach", "Santa Maria", "Rodeo", "Mulholland",
    "Vinewood", "Marina", "Commerce", "Pershing", "Ocean Docks",
    "Temple", "Market", "Idlewood Este", "Willowfield Sur", "East Los Santos",
    "Playa Norte", "Colina Verde", "Centro", "Barrio Oeste", "Las Colinas",
    "Riverside"
};

new const Float:CasaExt[MAX_CASAS][4] =
{
    {2463.0000, -1657.0000, 13.4000, 90.0},
    {2104.0000, -1804.0000, 13.5000, 180.0},
    {2386.0000, -1972.0000, 13.5000, 0.0},
    {2286.0000, -1737.0000, 13.5000, 270.0},
    {2211.0000, -1351.0000, 24.0000, 90.0},
    {2537.0000, -1363.0000, 24.0000, 180.0},
    {2803.0000, -1367.0000, 22.0000, 90.0},
    {385.0000, -2070.0000, 7.5000, 0.0},
    {550.0000, -1090.0000, 44.0000, 90.0},
    {1265.0000, -880.0000, 42.8000, 180.0},
    {1094.0000, -1690.0000, 13.6000, 90.0},
    {1568.0000, -1898.0000, 13.5000, 270.0},
    {1745.0000, -1463.0000, 13.5000, 0.0},
    {1444.0000, -626.0000, 14.5000, 90.0},
    {2210.0000, -1149.0000, 25.8000, 0.0},
    {1155.0000, -2034.0000, 69.0000, 180.0},
    {933.0000, -1340.0000, 13.4000, 90.0},
    {2178.0000, -1789.0000, 13.4000, 270.0},
    {2412.0000, -2021.0000, 13.5000, 90.0},
    {2600.0000, -1389.0000, 30.0000, 0.0},
    {2974.0000, -1748.0000, 12.0000, 90.0},
    {487.0000, -27.0000, 19.0000, 180.0},
    {1348.0000, -1756.0000, 13.5000, 90.0},
    {2222.0000, -1179.0000, 25.8000, 180.0},
    {2547.0000, -1296.0000, 34.0000, 90.0},
    {690.0000, -1600.0000, 15.2000, 0.0}
};

new const Float:CasaIntPos[MAX_CASAS][3] =
{
    {2215.2000, -1148.1000, 1029.8000},
    {2233.6000, -1115.2000, 1051.0000},
    {2350.6000, -1181.3000, 1028.0000},
    {2495.5000, -1692.5000, 1014.7000},
    {226.4000, -1241.4000, 1034.0000},
    {-262.1000, 1456.5000, 1084.4000},
    {2324.3000, -1149.0000, 1050.7000},
    {2215.2000, -1148.1000, 1029.8000},
    {2233.6000, -1115.2000, 1051.0000},
    {2350.6000, -1181.3000, 1028.0000},
    {2495.5000, -1692.5000, 1014.7000},
    {226.4000, -1241.4000, 1034.0000},
    {-262.1000, 1456.5000, 1084.4000},
    {2324.3000, -1149.0000, 1050.7000},
    {2215.2000, -1148.1000, 1029.8000},
    {2233.6000, -1115.2000, 1051.0000},
    {2350.6000, -1181.3000, 1028.0000},
    {2495.5000, -1692.5000, 1014.7000},
    {226.4000, -1241.4000, 1034.0000},
    {-262.1000, 1456.5000, 1084.4000},
    {2324.3000, -1149.0000, 1050.7000},
    {2215.2000, -1148.1000, 1029.8000},
    {2233.6000, -1115.2000, 1051.0000},
    {2350.6000, -1181.3000, 1028.0000},
    {2495.5000, -1692.5000, 1014.7000},
    {226.4000, -1241.4000, 1034.0000}
};

new const CasaIntID[MAX_CASAS] =
{
    1,
    2,
    3,
    3,
    5,
    4,
    12,
    1,
    2,
    3,
    3,
    5,
    4,
    12,
    1,
    2,
    3,
    3,
    5,
    4,
    12,
    1,
    2,
    3,
    3,
    5
};

new const CasaPrecio[MAX_CASAS] =
{
    250000, 180000, 150000, 320000, 200000, 450000, 380000, 120000,
    600000, 900000, 1500000, 2200000, 500000, 750000, 130000, 280000,
    340000, 160000, 140000, 400000, 520000, 1100000, 700000, 170000,
    260000, 210000
};

new const CasaNivel[MAX_CASAS] =
{
    2, 1, 1, 3, 2, 4, 4, 1,
    5, 6, 8, 10, 4, 5, 1, 3,
    3, 1, 1, 3, 4, 7, 5, 2,
    2, 2
};

//==============================================================================
//  TABLA DE DATOS: NEGOCIOS
//==============================================================================
new const NegNombre[MAX_NEGOCIOS][] =
{
    "24/7 de Idlewood", "Bar El Sombrero", "Casino Caligula", "Gasolinera Norte",
    "Taller Mecanico LS", "Discoteca Alhambra", "Burger Shot Centro", "Aeropuerto LS",
    "Restaurante Marina", "Tienda de Ropa"
};

new const Float:NegPos[MAX_NEGOCIOS][3] =
{
    {2166.0000, -1015.0000, 45.0000},
    {2226.0000, -1221.0000, 25.7000},
    {2233.0000, 1289.0000, 10.5000},
    {1944.0000, -1772.0000, 13.4000},
    {2071.0000, -1831.0000, 13.5000},
    {1836.0000, -1682.0000, 13.4000},
    {1199.0000, -918.0000, 42.9000},
    {1965.0000, -2180.0000, 13.5000},
    {411.0000, -1800.0000, 8.0000},
    {1458.0000, -1010.0000, 25.0000}
};

new const Float:NegIntPos[MAX_NEGOCIOS][3] =
{
    {5.0000, -30.0000, 1003.5000},
    {493.0000, -24.0000, 1000.0000},
    {2234.0000, 1288.0000, 10.0000},
    {-25.0000, -140.0000, 1003.5000},
    {-100.0000, -220.0000, 1000.0000},
    {501.0000, -20.0000, 1000.0000},
    {363.0000, -75.0000, 1001.5000},
    {-1827.0000, 15.0000, 20.0000},
    {460.0000, -88.0000, 999.5000},
    {207.0000, -110.0000, 1005.2000}
};

new const NegIntID[MAX_NEGOCIOS] =
{
    10,
    17,
    1,
    16,
    3,
    11,
    10,
    0,
    4,
    15
};

new const NegPrecio[MAX_NEGOCIOS] = {300000, 500000, 2500000, 800000, 900000, 1200000, 650000, 3000000, 700000, 450000};
new const NegGanancia[MAX_NEGOCIOS] = {2500, 4000, 18000, 6000, 7000, 9000, 5000, 20000, 5500, 3500};
new const NegNivel[MAX_NEGOCIOS] = {2, 3, 8, 4, 4, 5, 3, 9, 3, 2};

//==============================================================================
//  TABLA DE DATOS: ITEMS
//==============================================================================
new const NombreItem[MAX_ITEMS][] =
{
    "Botiquin", "Medicamento", "Marihuana", "Semilla de Medicamento",
    "Semilla de Marihuana", "Piezas de Arma", "Repuestos", "Minerales",
    "Madera", "Cosecha", "Droga", "Cerveza",
    "Telefono Movil", "Radio Portatil", "Esposas", "Llanta"
};

new const PrecioItem[MAX_ITEMS] = {500, 250, 400, 200, 200, 900, 350, 300, 300, 150, 900, 60, 800, 400, 300, 200};

//==============================================================================
//  TABLA DE DATOS: TIENDA 24/7 Y AMMU-NATION
//==============================================================================
new const Float:Pos247[5][3] =
{
    {2166.0000, -1015.0000, 45.0000},
    {1928.0000, -1776.0000, 13.4000},
    {1315.0000, -898.0000, 39.6000},
    {838.0000, -1750.0000, 14.0000},
    {493.0000, -24.0000, 1000.0000}
};

new const Float:PosAmmu[3][3] =
{
    {1363.0000, -1279.0000, 13.5000},
    {2400.0000, -1981.0000, 13.5000},
    {2159.0000, -1018.0000, 45.0000}
};

new const Float:PosCompraVenta[3] = {2495.0000, -1690.0000, 13.5000};
new const Float:PosBanco[3] = {1414.0000, -1700.0000, 13.5000};
new const Float:PosCultivo[3] = {250.0000, -300.0000, 1.5000};

// Armas del Ammu-Nation
new const ArmaNombre[8][] = {"Pistola 9mm", "Desert Eagle", "Escopeta", "Micro SMG", "AK-47", "Rifle", "Chaleco Antibalas", "Silenciador"};
new const ArmaID[8] = {24, 23, 25, 28, 30, 33, 0, 23};
new const ArmaMunicion[8] = {100, 60, 50, 150, 150, 50, 0, 0};
new const ArmaPrecio[8] = {1500, 3000, 3800, 5200, 6800, 8500, 900, 1200};

//==============================================================================
//  TABLA DE DATOS: CONCESIONARIO
//==============================================================================
new const VehConcesNombre[MAX_CONCES][] =
{
    "Sentinel", "Sabre", "Elegant", "Blista Compact", "Sunrise",
    "Clover", "Tampa", "Banshee", "Huntley", "Bandito",
    "Turismo", "Infernus"
};
new const VehConcesID[MAX_CONCES] = {405, 438, 507, 496, 418, 542, 549, 429, 579, 424, 451, 411};
new const VehConcesPrecio[MAX_CONCES] = {120000, 95000, 160000, 85000, 140000, 110000, 130000, 450000, 320000, 200000, 500000, 750000};
new const VehConcesNivel[MAX_CONCES] = {2, 2, 3, 2, 2, 2, 3, 6, 5, 3, 7, 8};

//==============================================================================
//  TABLA DE DATOS: FACCTIONES
//==============================================================================
new const NombreFaccion[MAX_FACCIONES][] =
{
    "Sin Faccion", "LSPD", "EMS", "Gobierno",
    "Mecanicos LS", "Taxis Unidos", "Noticiero SA"
};

new const RangoFaccion[MAX_FACCIONES][MAX_RANGOS][28] =
{
    {"Civil", "Civil", "Civil", "Civil", "Civil", "Civil"},
    {"Cadete", "Oficial", "Sargento", "Teniente", "Capitan", "Jefe de Policia"},
    {"Paramedico", "Enfermero", "Medico", "Medico Jefe", "Director Medico", "Comisario"},
    {"Asistente", "Secretario", "Asesor", "Ministro", "Alcalde", "Presidente"},
    {"Aprendiz", "Mecanico", "Mecanico Senior", "Supervisor", "Gerente", "Dueno"},
    {"Aprendiz", "Taxista", "Taxista Senior", "Coordinador", "Gerente", "Dueno"},
    {"Reportero", "Periodista", "Editor", "Presentador", "Director", "Dueno"}
};

new const PagoFaccion[MAX_FACCIONES] = {0, 4500, 4000, 6000, 3500, 3000, 3200};
new const SkinFaccion[MAX_FACCIONES] = {0, 265, 274, 295, 50, 61, 171};

//==============================================================================
//  TABLA DE DATOS: ANIMACIONES
//==============================================================================
new const AnimNombre[20][] =
{
    "Saludar", "Sentarse", "Fumar", "Bailar 1", "Bailar 2",
    "Rendirse", "Herido", "Hablar por radio", "Aplaudir", "Reir",
    "Llorar", "Pensar", "Senalar", "Paz", "Rock",
    "Empujar", "Dormir", "Cachetear", "Rendirse 2", "Bravo"
};

new const AnimLib[20][] =
{
    "GANGS", "PED", "SMOKING", "DANCING", "DANCING",
    "ROB_BANK", "SWEET", "PED", "RIOT", "RAPPING",
    "GRAVEYARD", "COP_AMBIENT", "GRENADE", "RIOT", "DANCING",
    "GANGS", "CRACK", "MISC", "ROB_BANK", "RIOT"
};

new const AnimNombre2[20][] =
{
    "hndshkba", "SEAT_idle", "M_smklean_loop", "dnce_M_a", "dnce_M_b",
    "SHP_HandsUp_Scr", "Sweet_injuredloop", "IDLE_chat", "RIOT_ANGRY", "Laugh_01",
    "mrnM_loop", "Coplook_loop", "INBORED", "RIOT_ANGRY", "dnce_M_c",
    "shake_cara", "crckidle4", "BITCH_SLAP", "SHP_HandsUp_Scr", "RIOT_CHANT"
};

//==============================================================================
//  TABLA DE DATOS: NIVELES DE ADMINISTRACION
//==============================================================================
new const NombreAdmin[7][] =
{
    "Usuario", "Ayudante", "Moderador", "Administrador",
    "Super Administrador", "Director", "Dueno"
};

// Duenos fijos del servidor (editables)
new const DuenosFijos[3][] = { "Dani_Mcfly", "Brian_Lopez", "Nicho_Lopez" };

//==============================================================================
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
    new file[64];
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));

    AP_Ini_StrSet(file, "Clave", Player[playerid][pPass]);
    AP_Ini_StrSet(file, "Email", Player[playerid][pEmail]);
    AP_Ini_StrSet(file, "Login", Player[playerid][pLogin]);
    AP_Ini_IntSet(file, "Stats", Player[playerid][pStats] ? 1 : 0);
    AP_Ini_IntSet(file, "Admin", Player[playerid][pAdmin]);
    AP_Ini_IntSet(file, "Skin", Player[playerid][pSkin]);
    AP_Ini_IntSet(file, "Money", Player[playerid][pMoney]);
    AP_Ini_IntSet(file, "Bank", Player[playerid][pBank]);
    AP_Ini_IntSet(file, "Score", Player[playerid][pScore]);
    AP_Ini_IntSet(file, "XP", Player[playerid][pXP]);
    AP_Ini_IntSet(file, "Style", Player[playerid][pStyle]);
    AP_Ini_FloatSet(file, "Health", Player[playerid][pHealth]);
    AP_Ini_FloatSet(file, "Armour", Player[playerid][pArmour]);
    AP_Ini_FloatSet(file, "PosX", Player[playerid][pPosX]);
    AP_Ini_FloatSet(file, "PosY", Player[playerid][pPosY]);
    AP_Ini_FloatSet(file, "PosZ", Player[playerid][pPosZ]);
    AP_Ini_FloatSet(file, "PosA", Player[playerid][pPosA]);
    AP_Ini_IntSet(file, "Int", Player[playerid][pInt]);
    AP_Ini_IntSet(file, "VW", Player[playerid][pVW]);
    AP_Ini_IntSet(file, "Wanted", Player[playerid][pWanted]);
    AP_Ini_IntSet(file, "Jail", Player[playerid][pJail] ? 1 : 0);
    AP_Ini_IntSet(file, "JailTime", Player[playerid][pJailTime]);
    AP_Ini_IntSet(file, "Dead", Player[playerid][pDead] ? 1 : 0);
    AP_Ini_IntSet(file, "Muted", Player[playerid][pMuted] ? 1 : 0);
    AP_Ini_IntSet(file, "MuteTime", Player[playerid][pMuteTime]);
    AP_Ini_IntSet(file, "Baned", Player[playerid][pBaneado] ? 1 : 0);
    AP_Ini_IntSet(file, "Tiempo", Player[playerid][pTiempo]);
    AP_Ini_IntSet(file, "Horas", Player[playerid][pHoras]);
    AP_Ini_IntSet(file, "Job", Player[playerid][pJob]);
    AP_Ini_IntSet(file, "Faccion", Player[playerid][pFaccion]);
    AP_Ini_IntSet(file, "Rango", Player[playerid][pRango]);
    AP_Ini_IntSet(file, "Telefono", Player[playerid][pTelefono]);
    AP_Ini_IntSet(file, "Saldo", Player[playerid][pSaldo]);
    AP_Ini_IntSet(file, "Casa", Player[playerid][pCasa]);
    AP_Ini_IntSet(file, "Negocio", Player[playerid][pNegocio]);
    AP_Ini_IntSet(file, "Muertes", Player[playerid][pMuertes]);
    AP_Ini_IntSet(file, "Arrestos", Player[playerid][pArrestos]);
    AP_Ini_IntSet(file, "Multas", Player[playerid][pMultas]);
    AP_Ini_IntSet(file, "Rutas", Player[playerid][pRutas]);
    AP_Ini_IntSet(file, "VIP", Player[playerid][pVIP]);
    AP_Ini_IntSet(file, "Hambre", Player[playerid][pHambre]);
    AP_Ini_IntSet(file, "Sed", Player[playerid][pSed]);

    for(new i = 0; i < MAX_TRABAJOS; i++)
    {
        format(szString2, sizeof(szString2), "JobExp%d", i);
        AP_Ini_IntSet(file, szString2, Player[playerid][pJobExp][i]);
    }
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        format(szString2, sizeof(szString2), "Item%d", i);
        AP_Ini_IntSet(file, szString2, Player[playerid][pItem][i]);
    }
    for(new i = 0; i < 13; i++)
    {
        format(szString2, sizeof(szString2), "Arma%d", i);
        AP_Ini_IntSet(file, szString2, Player[playerid][pArma][i]);
        format(szString2, sizeof(szString2), "Municion%d", i);
        AP_Ini_IntSet(file, szString2, Player[playerid][pMunicion][i]);
    }
    for(new i = 0; i < MAX_CONTACTOS; i++)
    {
        format(szString2, sizeof(szString2), "Contacto%d", i);
        AP_Ini_IntSet(file, szString2, Player[playerid][pContacto][i]);
    }
    for(new v = 0; v < MAX_VEH_JUG; v++)
    {
        new clave[16];
        format(clave, sizeof(clave), "Veh%d", v);
        if(VehJug[playerid][v][vModelo] == 0)
        {
            AP_Ini_StrSet(file, clave, "0");
            continue;
        }
        new dato[80];
        format(dato, sizeof(dato), "%d %.2f %.2f %.2f %.2f %d %d", VehJug[playerid][v][vModelo], VehJug[playerid][v][vX], VehJug[playerid][v][vY], VehJug[playerid][v][vZ], VehJug[playerid][v][vA], VehJug[playerid][v][vC1], VehJug[playerid][v][vC2]);
        AP_Ini_StrSet(file, clave, dato);
    }
    return 1;
}

public AP_CargarCuenta(playerid)
{
    new file[64], clave[24], valor[96];
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));
    if(!fexist(file)) return 0;

    AP_Ini_Str(file, "Clave", Player[playerid][pPass], 17);
    AP_Ini_Str(file, "Email", Player[playerid][pEmail], 46);
    AP_Ini_Str(file, "Login", Player[playerid][pLogin], 26);

    Player[playerid][pStats]        = AP_Ini_Int(file, "Stats", 0) ? true : false;
    Player[playerid][pAdmin]       = AP_Ini_Int(file, "Admin", 0);
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
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));
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
//  SISTEMA DE FACCTIONES
//==============================================================================
CMD:faccion(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES)
    {
        new lista[400], linea[100];
        for(new i = 1; i < MAX_FACCIONES; i++)
        {
            format(linea, sizeof(linea), "%d) %s\n", i, NombreFaccion[i]);
            strcat(lista, linea, sizeof(lista));
        }
        ShowPlayerDialog(playerid, D_FACCION, DIALOG_STYLE_LIST, "{00FF00}FACCIONES DE SAN ANDREAS", lista, "Ver rangos", "Salir");
        return 1;
    }
    format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nTu rango: {2ECC71}%s{FFFFFF}\nEstado: %s\nNomina por hora: {2ECC71}$%d{FFFFFF}\n\nOpciones:", NombreFaccion[fac], RangoFaccion[fac][Player[playerid][pRango]], Player[playerid][pServicio] ? "{2ECC71}En servicio" : "{FF0000}Fuera de servicio", PagoFaccion[fac]);
    ShowPlayerDialog(playerid, D_FACCION, DIALOG_STYLE_LIST, "{00FF00}TU FACION", szString, "Elegir", "Cerrar");
    Player[playerid][pDlg][0] = fac;
    return 1;
}

CMD:rangos(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    new lista[300], linea[80];
    for(new i = 0; i < MAX_RANGOS; i++)
    {
        format(linea, sizeof(linea), "Rango %d: %s\n", i, RangoFaccion[fac][i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_FACCION_RANGOS, DIALOG_STYLE_LIST, "{00FF00}RANGOS", lista, "Cerrar", "");
    return 1;
}

stock AP_ServicioComando(playerid)
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pServicio])
    {
        Player[playerid][pServicio] = false;
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
        AP_Msg(playerid, C_AMARILLO, "[FACCION]: Has salido de servicio.");
    }
    else
    {
        Player[playerid][pServicio] = true;
        SetPlayerSkin(playerid, SkinFaccion[fac]);
        AP_Msg(playerid, C_VERDE, "[FACCION]: Estas en servicio. Usa /f para hablar con tu faccion.");
    }
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:servicio(playerid) return AP_ServicioComando(playerid);

CMD:f(playerid, params[])
{
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /f [mensaje]");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != fac) continue;
        format(szString, sizeof(szString), "[FACCION] %s %s: %s", RangoFaccion[fac][Player[playerid][pRango]], NombrePorID(playerid), params);
        AP_Msg(i, C_FAC, szString);
    }
    return 1;
}

CMD:r(playerid, params[])
{
    if(Player[playerid][pRadio] <= 0 && Player[playerid][pItem][ITEM_RADIO] <= 0)
        return AP_Msg(playerid, C_ROJO, "[RADIO]: Necesitas una radio portatil (/usar Radio).");
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /r [mensaje por radio]");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pFaccion] != Player[playerid][pFaccion]) continue;
        if(!Player[i][pServicio]) continue;
        format(szString, sizeof(szString), "[RADIO] %s: %s", NombrePorID(playerid), params);
        AP_Msg(i, C_RADIO, szString);
    }
    return 1;
}

CMD:invitar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /invitar [id]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 4) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 4 o superior.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[FACCION]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(!IsPlayerInRangeOfPoint(dest, 8.0, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]))
        return AP_Msg(playerid, C_ROJO, "[FACCION]: El jugador debe estar cerca de ti.");
    if(Player[dest][pFaccion] != 0) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador ya tiene faccion.");
    Player[dest][pFaccion] = fac;
    Player[dest][pRango] = 0;
    format(szString, sizeof(szString), "[FACCION]: Has invitado a %s a %s.", NombrePorID(dest), NombreFaccion[fac]);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[FACCION]: %s te ha invitado a %s. Usa /faccion para mas informacion.", NombrePorID(playerid), NombreFaccion[fac]);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:expulsar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /expulsar [id]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 4) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 4 o superior.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[FACCION]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(Player[dest][pFaccion] != fac) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no es de tu faccion.");
    Player[dest][pFaccion] = 0;
    Player[dest][pRango] = 0;
    Player[dest][pServicio] = false;
    SetPlayerSkin(dest, Player[dest][pSkin]);
    format(szString, sizeof(szString), "[FACCION]: Has expulsado a %s de la faccion.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, "[FACCION]: Has sido expulsado de la faccion.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:faccionrango(playerid, params[])
{
    new idstr[12], rango[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /faccionrango [id] [rango 0-5]");
    if(!AP_Token(params, idx, rango, sizeof(rango))) return AP_Msg(playerid, C_ROJO, "Uso: /faccionrango [id] [rango 0-5]");
    new fac = Player[playerid][pFaccion];
    if(fac <= 0 || fac >= MAX_FACCIONES) return AP_Msg(playerid, C_ROJO, "[FACCION]: No perteneces a ninguna faccion.");
    if(Player[playerid][pRango] < 5) return AP_Msg(playerid, C_ROJO, "[FACCION]: Necesitas ser rango 5 (lider).");
    if(!EsNumerico(idstr) || !EsNumerico(rango)) return AP_Msg(playerid, C_ROJO, "[FACCION]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(rango);
    if(nuevo < 0 || nuevo >= MAX_RANGOS) return AP_Msg(playerid, C_ROJO, "[FACCION]: El rango debe estar entre 0 y 5.");
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no esta conectado.");
    if(Player[dest][pFaccion] != fac) return AP_Msg(playerid, C_ROJO, "[FACCION]: Ese jugador no es de tu faccion.");
    Player[dest][pRango] = nuevo;
    format(szString, sizeof(szString), "[FACCION]: %s ahora es %s.", NombrePorID(dest), RangoFaccion[fac][nuevo]);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

//==============================================================================
//  POLICIA: ESPOSAR, MULTAR, ARRESTAR
//==============================================================================
CMD:esposar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /esposar [id]");
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede esposar.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(!IsPlayerInRangeOfPoint(dest, 6.0, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]))
        return AP_Msg(playerid, C_ROJO, "[POLICIA]: Debes estar cerca del sospechoso.");
    Player[dest][pEsposado] = true;
    TogglePlayerControllable(dest, false);
    ApplyAnimation(dest, "ped", "cower", 4.0, 1, 0, 0, 1, 0, 1);
    format(szString, sizeof(szString), "[POLICIA]: Has esposado a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, "[POLICIA]: Estas esposado. No puedes moverte.");
    return 1;
}

CMD:desesposar(playerid, params[])
{
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /desesposar [id]");
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede quitar las esposas.");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    Player[dest][pEsposado] = false;
    TogglePlayerControllable(dest, true);
    ClearAnimations(dest);
    AP_Msg(dest, C_VERDE, "[POLICIA]: Te han quitado las esposas.");
    return 1;
}

CMD:multar(playerid, params[])
{
    new idstr[12], monto[12], razon[64];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /multar [id] [monto] [razon]");
    if(!AP_Token(params, idx, monto, sizeof(monto))) return AP_Msg(playerid, C_ROJO, "Uso: /multar [id] [monto] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede multar.");
    if(!EsNumerico(idstr) || !EsNumerico(monto)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Datos invalidos.");
    new dest = strval(idstr), valor = strval(monto);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(valor < 1) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Monto invalido.");
    AP_QuitarDinero(dest, valor);
    Player[dest][pMultas]++;
    format(szString, sizeof(szString), "[POLICIA]: Has multado a %s con $%d. Razon: %s", NombrePorID(dest), valor, razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[POLICIA]: El oficial %s te ha multado con $%d. Razon: %s", NombrePorID(playerid), valor, razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Policia", "Multa emitida.");
    return 1;
}

CMD:arrestar(playerid, params[])
{
    new idstr[12], minutos[8], razon[64];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /arrestar [id] [minutos] [razon]");
    if(!AP_Token(params, idx, minutos, sizeof(minutos))) return AP_Msg(playerid, C_ROJO, "Uso: /arrestar [id] [minutos] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(Player[playerid][pFaccion] != 1 && Player[playerid][pAdmin] < ADM_ADMIN) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Solo la policia puede arrestar.");
    if(!EsNumerico(idstr) || !EsNumerico(minutos)) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(minutos);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: Ese jugador no esta conectado.");
    if(!Player[dest][pEsposado]) return AP_Msg(playerid, C_ROJO, "[POLICIA]: El sospechoso debe estar esposado.");
    if(tiempo < 1) tiempo = 1;
    if(tiempo > 30) tiempo = 30;
    Player[dest][pJail] = true;
    Player[dest][pJailTime] = tiempo;
    Player[dest][pEsposado] = false;
    Player[dest][pArrestos]++;
    Player[dest][pWanted] = 0;
    SetPlayerWantedLevel(dest, 0);
    SetPlayerPos(dest, 1533.6067, -1638.8525, 2024.4063);
    SetPlayerFacingAngle(dest, 359.1107);
    SetPlayerInterior(dest, 3);
    SetPlayerVirtualWorld(dest, 0);
    Player[dest][pInt] = 3;
    Player[dest][pVW] = 0;
    GetPlayerPos(dest, Player[dest][pPosX], Player[dest][pPosY], Player[dest][pPosZ]);
    GetPlayerFacingAngle(dest, Player[dest][pPosA]);
    TogglePlayerControllable(dest, true);
    SetTimerEx("AP_Unjail", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[POLICIA]: Has arrestado a %s por %d minutos. Razon: %s", NombrePorID(dest), tiempo, razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[POLICIA]: Has sido arrestado %d minutos. Razon: %s", tiempo, razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Policia", "Arresto realizado.");
    AP_GuardarCuenta(dest);
    return 1;
}

public AP_Unjail(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    Player[playerid][pJail] = false;
    Player[playerid][pJailTime] = 0;
    Player[playerid][pWanted] = 0;
    SetPlayerWantedLevel(playerid, 0);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerPos(playerid, 1541.6305, -1675.1818, 13.5529);
    SetPlayerFacingAngle(playerid, 89.6651);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player[playerid][pInt] = 0;
    Player[playerid][pVW] = 0;
    GetPlayerPos(playerid, Player[playerid][pPosX], Player[playerid][pPosY], Player[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, Player[playerid][pPosA]);
    TogglePlayerControllable(playerid, true);
    AP_Msg(playerid, C_VERDE, "[POLICIA]: Has cumplido tu condena. Quedas en libertad.");
    AP_GuardarCuenta(playerid);
    return 1;
}

//==============================================================================
//  ANIMACIONES
//==============================================================================
CMD:anim(playerid)
{
    new lista[700], linea[80];
    for(new i = 0; i < 20; i++)
    {
        format(linea, sizeof(linea), "%d) %s\n", i + 1, AnimNombre[i]);
        strcat(lista, linea, sizeof(lista));
    }
    ShowPlayerDialog(playerid, D_ANIMS, DIALOG_STYLE_LIST, "{00FF00}ANIMACIONES", lista, "Usar", "Salir");
    return 1;
}

CMD:pararanim(playerid)
{
    ClearAnimations(playerid);
    AP_Msg(playerid, C_VERDE, "[ANIM]: Animacion detenida.");
    return 1;
}

//==============================================================================
//  VIP
//==============================================================================
CMD:vip(playerid)
{
    format(szString, sizeof(szString), "{00FF00}CUENTA VIP{FFFFFF}\n\nTu nivel VIP: {2ECC71}%d{FFFFFF}\n\nBeneficios actuales:\n{FFFF00}- 20 por ciento extra de dinero en el payday\n- Punto de aparicion en tu casa\n- Prioridad en la cola de entrada\n- Etiqueta VIP en el chat{FFFFFF}\n\nConsigue VIP hablando con la administracion.", Player[playerid][pVIP]);
    ShowPlayerDialog(playerid, D_VIP, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_SHORTCUT" VIP", szString, "Cerrar", "");
    return 1;
}

//==============================================================================
//  SISTEMA DE ADMINISTRACION POR NIVELES
//==============================================================================
#define REQ_ADMIN(%0) if(Player[playerid][pAdmin] < %0) { format(szString, sizeof(szString), "[ADMIN]: Necesitas ser %s para usar este comando.", NombreAdmin[%0]); AP_Msg(playerid, C_ROJO, szString); return 1; }

CMD:admin(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    format(szString, sizeof(szString), "{00FF00}PANEL DE ADMINISTRACION{FFFFFF}\nRango: {2ECC71}%s{FFFFFF}\nDeber: %s\n\nEscribe los comandos de moderacion en el chat.\nUsa /admins para ver el staff conectado.", NombreAdmin[Player[playerid][pAdmin]], Player[playerid][pDuty] ? "{2ECC71}En servicio" : "{FF0000}Fuera de servicio");
    ShowPlayerDialog(playerid, D_ADMIN, DIALOG_STYLE_MSGBOX, "{00FF00}PANEL ADMIN", szString, "Cerrar", "");
    return 1;
}

CMD:dameadmin(playerid, params[])
{
    new clave[32];
    new idx = 0;
    if(!AP_Token(params, idx, clave, sizeof(clave))) return AP_Msg(playerid, C_ROJO, "Uso: /dameadmin [clave maestra]");
    if(strcmp(clave, ADMIN_KEY, true) != 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Clave incorrecta.");
    if(!Player[playerid][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes iniciar sesion primero.");
    Player[playerid][pAdmin] = ADM_DUENO;
    new file[64];
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));
    AP_Ini_IntSet(file, "Admin", ADM_DUENO);
    AP_Msg(playerid, C_AMARILLO, "[ADMIN]: Ahora eres Dueno del servidor. Cambia la clave maestra en el codigo.");
    AP_Log("Admin", "Auto-ascenso a Dueno con clave maestra.");
    return 1;
}

CMD:haceradmin(playerid, params[])
{
    REQ_ADMIN(ADM_DIRECTOR)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /haceradmin [id] [nivel 0-6]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /haceradmin [id] [nivel 0-6]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 0 || nuevo > ADM_DUENO) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El nivel debe estar entre 0 y 6.");
    if(nuevo >= Player[playerid][pAdmin] && Player[playerid][pAdmin] < ADM_DUENO) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes dar un rango igual o superior al tuyo.");
    Player[dest][pAdmin] = nuevo;
    new file[64];
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(dest));
    AP_Ini_IntSet(file, "Admin", nuevo);
    format(szString, sizeof(szString), "[ADMIN]: %s ahora es %s.", NombrePorID(dest), NombreAdmin[nuevo]);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "[ADMIN]: %s te ha nombrado %s.", NombrePorID(playerid), NombreAdmin[nuevo]);
    AP_Msg(dest, C_VERDE, szString);
    AP_Log("Admin", "Nivel de administrador cambiado.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:adminduty(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(Player[playerid][pDuty])
    {
        Player[playerid][pDuty] = false;
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
        SetPlayerHealth(playerid, 100.0);
        AP_Msg(playerid, C_AMARILLO, "[ADMIN]: Has salido de servicio administrativo.");
    }
    else
    {
        Player[playerid][pDuty] = true;
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        AP_Msg(playerid, C_VERDE, "[ADMIN]: Estas en servicio administrativo.");
    }
    AP_ActualizarHUD(playerid);
    return 1;
}

CMD:admins(playerid)
{
    new total = 0, enlinea[MAX_PLAYERS], n = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        total++;
        enlinea[n++] = i;
    }
    if(total == 0) return AP_Msg(playerid, C_AMARILLO, "[STAFF]: No hay administradores conectados.");
    AP_Msg(playerid, C_AZUL, "--- ADMINISTRACION CONECTADA ---");
    for(new i = 0; i < n; i++)
    {
        format(szString, sizeof(szString), "%s (%d) - %s - %s", NombrePorID(enlinea[i]), enlinea[i], NombreAdmin[Player[enlinea[i]][pAdmin]], Player[enlinea[i]][pDuty] ? "En servicio" : "Fuera de servicio");
        AP_Msg(playerid, -1, szString);
    }
    return 1;
}

CMD:staff(playerid)
{
    new total = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] >= 1) total++;
    }
    format(szString, sizeof(szString), "[STAFF]: Hay %d miembros del staff conectados. Usa /reportar o /duda si necesitas ayuda.", total);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:ir(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ir [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz, Float:pa, interior, vw;
    GetPlayerPos(dest, px, py, pz);
    GetPlayerFacingAngle(dest, pa);
    interior = GetPlayerInterior(dest);
    vw = GetPlayerVirtualWorld(dest);
    if(GetPlayerState(dest) == PLAYER_STATE_DRIVER || GetPlayerState(dest) == PLAYER_STATE_PASSENGER)
    {
        new vid = GetPlayerVehicleID(dest);
        GetVehiclePos(vid, px, py, pz);
        GetVehicleZAngle(vid, pa);
    }
    SetPlayerPos(playerid, px + 1.5, py, pz);
    SetPlayerFacingAngle(playerid, pa);
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);
    format(szString, sizeof(szString), "[ADMIN]: Te has teletransportado con %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:traer(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /traer [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    SetPlayerPos(dest, px + 1.5, py, pz);
    SetPlayerFacingAngle(dest, pa);
    SetPlayerInterior(dest, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(dest, GetPlayerVirtualWorld(playerid));
    format(szString, sizeof(szString), "[ADMIN]: Has traido a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_AMARILLO, "[ADMIN]: Un administrador te ha traido con el.");
    AP_Log("Admin", "Uso de /traer.");
    return 1;
}

CMD:ira(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new xs[16], ys[16], zs[16];
    new idx = 0;
    if(!AP_Token(params, idx, xs, sizeof(xs))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!AP_Token(params, idx, ys, sizeof(ys))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!AP_Token(params, idx, zs, sizeof(zs))) return AP_Msg(playerid, C_ROJO, "Uso: /ira [x] [y] [z]");
    if(!EsNumerico(xs) || !EsNumerico(ys) || !EsNumerico(zs)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Coordenadas invalidas.");
    SetPlayerPos(playerid, floatstr(xs), floatstr(ys), floatstr(zs));
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Teletransportado.");
    return 1;
}

CMD:kick(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], razon[80];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /kick [id] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[dest][pAdmin] >= Player[playerid][pAdmin]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes expulsar a un rango igual o superior.");
    format(szString, sizeof(szString), "[ADMIN]: Has expulsado a %s. Razon: %s", NombrePorID(dest), razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "Has sido expulsado por %s. Razon: %s", NombrePorID(playerid), razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador expulsado.");
    SetTimerEx("AP_KickInmediato", 800, false, "i", dest);
    return 1;
}

public AP_KickInmediato(playerid) return Kick(playerid);

CMD:ban(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], razon[80];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ban [id] [razon]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(razon, params, resto, strlen(params), sizeof(razon));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[dest][pAdmin] >= Player[playerid][pAdmin]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No puedes banear a un rango igual o superior.");
    Player[dest][pBaneado] = true;
    AP_GuardarCuenta(dest);
    format(szString, sizeof(szString), "[ADMIN]: Has baneado a %s. Razon: %s", NombrePorID(dest), razon);
    AP_Msg(playerid, C_VERDE, szString);
    format(szString, sizeof(szString), "Has sido baneado por %s. Razon: %s", NombrePorID(playerid), razon);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador baneado.");
    SetTimerEx("AP_KickInmediato", 800, false, "i", dest);
    return 1;
}

CMD:desban(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new nombre[MAX_PLAYER_NAME];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /desban [Nombre_Apellido]");
    new file[64];
    format(file, sizeof(file), "Cuentas/%s.ini", nombre);
    if(!fexist(file)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Esa cuenta no existe.");
    AP_Ini_IntSet(file, "Baned", 0);
    format(szString, sizeof(szString), "[ADMIN]: Cuenta %s desbaneada.", nombre);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Cuenta desbaneada.");
    return 1;
}

CMD:congelar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /congelar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    TogglePlayerControllable(dest, false);
    Player[dest][pCongelado] = true;
    AP_Msg(dest, C_ROJO, "[ADMIN]: Has sido congelado por un administrador.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador congelado.");
    return 1;
}

CMD:descongelar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /descongelar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    TogglePlayerControllable(dest, true);
    Player[dest][pCongelado] = false;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido descongelado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador descongelado.");
    return 1;
}

CMD:matar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /matar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    SetPlayerHealth(dest, 0.0);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador eliminado.");
    return 1;
}

CMD:curar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /curar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    SetPlayerHealth(dest, 100.0);
    SetPlayerArmour(dest, 100.0);
    Player[dest][pHealth] = 100.0;
    Player[dest][pArmour] = 100.0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido curado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador curado.");
    return 1;
}

CMD:revivir(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /revivir [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pDead] = false;
    TogglePlayerControllable(dest, true);
    ClearAnimations(dest);
    SetPlayerHealth(dest, 100.0);
    Player[dest][pHealth] = 100.0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Has sido reanimado.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador reanimado.");
    return 1;
}

CMD:slap(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /slap [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(dest, px, py, pz);
    SetPlayerPos(dest, px, py, pz + 12.0);
    PlayerPlaySound(dest, 1190, 0.0, 0.0, 0.0);
    AP_Msg(dest, C_ROJO, "[ADMIN]: Un administrador te ha lanzado por los aires.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador lanzado.");
    return 1;
}

CMD:mute(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], mins[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /mute [id] [minutos]");
    if(!AP_Token(params, idx, mins, sizeof(mins))) format(mins, sizeof(mins), "5");
    if(!EsNumerico(idstr) || !EsNumerico(mins)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(mins);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pMuted] = true;
    Player[dest][pMuteTime] = tiempo;
    SetTimerEx("AP_FinMute", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[ADMIN]: Has silenciado a %s por %d minutos.", NombrePorID(dest), tiempo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

public AP_FinMute(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    Player[playerid][pMuted] = false;
    Player[playerid][pMuteTime] = 0;
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Tu silencio ha terminado.");
    return 1;
}

CMD:desmute(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /desmute [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    Player[dest][pMuted] = false;
    Player[dest][pMuteTime] = 0;
    AP_Msg(dest, C_VERDE, "[ADMIN]: Puedes volver a escribir.");
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Silencio retirado.");
    return 1;
}

CMD:carcel(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12], mins[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /carcel [id] [minutos]");
    if(!AP_Token(params, idx, mins, sizeof(mins))) format(mins, sizeof(mins), "5");
    if(!EsNumerico(idstr) || !EsNumerico(mins)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), tiempo = strval(mins);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(tiempo < 1) tiempo = 1;
    Player[dest][pJail] = true;
    Player[dest][pJailTime] = tiempo;
    SetPlayerPos(dest, 1533.6067, -1638.8525, 2024.4063);
    SetPlayerFacingAngle(dest, 359.1107);
    SetPlayerInterior(dest, 3);
    Player[dest][pInt] = 3;
    GetPlayerPos(dest, Player[dest][pPosX], Player[dest][pPosY], Player[dest][pPosZ]);
    GetPlayerFacingAngle(dest, Player[dest][pPosA]);
    SetTimerEx("AP_Unjail", tiempo * 60000, false, "i", dest);
    format(szString, sizeof(szString), "[ADMIN]: Has encarcelado a %s por %d minutos.", NombrePorID(dest), tiempo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_ROJO, szString);
    AP_Log("Admin", "Jugador encarcelado.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:liberar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /liberar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_Unjail(dest);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Jugador liberado.");
    return 1;
}

CMD:dardinero(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /dardinero [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /dardinero [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_DarDinero(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has dado $%d a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Dinero entregado por administracion.");
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:quitardinero(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /quitardinero [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /quitardinero [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_QuitarDinero(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has quitado $%d a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Dinero retirado por administracion.");
    return 1;
}

CMD:setnivel(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /setnivel [id] [nivel]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /setnivel [id] [nivel]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 1) nuevo = 1;
    Player[dest][pScore] = nuevo;
    SetPlayerScore(dest, nuevo);
    AP_ActualizarHUD(dest);
    format(szString, sizeof(szString), "[ADMIN]: %s ahora es nivel %d.", NombrePorID(dest), nuevo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:darxp(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new idstr[12], cant[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /darxp [id] [cantidad]");
    if(!AP_Token(params, idx, cant, sizeof(cant))) return AP_Msg(playerid, C_ROJO, "Uso: /darxp [id] [cantidad]");
    if(!EsNumerico(idstr) || !EsNumerico(cant)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), monto = strval(cant);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    AP_DarExperiencia(dest, monto);
    format(szString, sizeof(szString), "[ADMIN]: Has dado %d de experiencia a %s.", monto, NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:darvip(playerid, params[])
{
    REQ_ADMIN(ADM_DIRECTOR)
    new idstr[12], nivel[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /darvip [id] [nivel 0-3]");
    if(!AP_Token(params, idx, nivel, sizeof(nivel))) return AP_Msg(playerid, C_ROJO, "Uso: /darvip [id] [nivel 0-3]");
    if(!EsNumerico(idstr) || !EsNumerico(nivel)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(nivel);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 0 || nuevo > 3) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El nivel VIP debe estar entre 0 y 3.");
    Player[dest][pVIP] = nuevo;
    format(szString, sizeof(szString), "[ADMIN]: %s ahora tiene VIP nivel %d.", NombrePorID(dest), nuevo);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Msg(dest, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:setskin(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new idstr[12], skin[8];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /setskin [id] [skin]");
    if(!AP_Token(params, idx, skin, sizeof(skin))) return AP_Msg(playerid, C_ROJO, "Uso: /setskin [id] [skin]");
    if(!EsNumerico(idstr) || !EsNumerico(skin)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Datos invalidos.");
    new dest = strval(idstr), nuevo = strval(skin);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(nuevo < 1 || nuevo > 311) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Skin invalido (1-311).");
    Player[dest][pSkin] = nuevo;
    SetPlayerSkin(dest, nuevo);
    format(szString, sizeof(szString), "[ADMIN]: Has cambiado el skin de %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(dest);
    return 1;
}

CMD:dveh(playerid, params[])
{
    REQ_ADMIN(ADM_ADMIN)
    new modelo[8];
    new idx = 0;
    if(!AP_Token(params, idx, modelo, sizeof(modelo))) return AP_Msg(playerid, C_ROJO, "Uso: /veh [modelo]  (ejemplo: /veh 411)");
    if(!EsNumerico(modelo)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Modelo invalido.");
    new id = strval(modelo);
    if(id < 400 || id > 611) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El modelo debe estar entre 400 y 611.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    new vid = CreateVehicle(id, px + 3.0, py, pz + 1.0, pa, 0, 0, 60000);
    PutPlayerInVehicle(playerid, vid, 0);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo creado.");
    AP_Log("Admin", "Vehiculo administrativo creado.");
    return 1;
}

CMD:destruirveh(playerid)
{
    REQ_ADMIN(ADM_ADMIN)
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes estar en un vehiculo.");
    DestroyVehicle(vid);
    RemovePlayerFromVehicle(playerid);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo destruido.");
    return 1;
}

CMD:flipveh(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    new vid = GetPlayerVehicleID(playerid);
    if(vid == 0) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Debes estar en un vehiculo.");
    new Float:px, Float:py, Float:pz, Float:pa;
    GetVehiclePos(vid, px, py, pz);
    GetVehicleZAngle(vid, pa);
    SetVehiclePos(vid, px, py, pz + 1.0);
    SetVehicleZAngle(vid, pa);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Vehiculo enderezado.");
    return 1;
}

CMD:hora(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new h[8];
    new idx = 0;
    if(!AP_Token(params, idx, h, sizeof(h))) return AP_Msg(playerid, C_ROJO, "Uso: /hora [0-23]");
    if(!EsNumerico(h)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Hora invalida.");
    new hora = strval(h);
    if(hora < 0 || hora > 23) return AP_Msg(playerid, C_ROJO, "[ADMIN]: La hora debe estar entre 0 y 23.");
    AP_Hora = hora;
    SetWorldTime(hora);
    format(szString, sizeof(szString), "[ADMIN]: Hora del servidor cambiada a %d:00.", hora);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:clima(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    new c[8];
    new idx = 0;
    if(!AP_Token(params, idx, c, sizeof(c))) return AP_Msg(playerid, C_ROJO, "Uso: /clima [0-20]");
    if(!EsNumerico(c)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Clima invalido.");
    new clima = strval(c);
    if(clima < 0 || clima > 20) return AP_Msg(playerid, C_ROJO, "[ADMIN]: El clima debe estar entre 0 y 20.");
    AP_Clima = clima;
    SetWeather(clima);
    format(szString, sizeof(szString), "[ADMIN]: Clima cambiado a %d.", clima);
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:anuncio(playerid, params[])
{
    REQ_ADMIN(ADM_SUPER)
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /anuncio [texto]");
    format(szString, sizeof(szString), "~b~~h~ANUNCIO OFICIAL~n~~w~%s", params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        GameTextForPlayer(i, szString, 6000, 3);
    }
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Anuncio enviado a todos los jugadores.");
    AP_Log("Admin", "Anuncio global enviado.");
    return 1;
}

CMD:limpiarchat(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        LimpiarChat(i);
    }
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Chat limpiado.");
    return 1;
}

CMD:espectar(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /espectar [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    if(Player[playerid][pEspectando] != -1) TogglePlayerSpectating(playerid, false);
    Player[playerid][pEspectando] = dest;
    TogglePlayerSpectating(playerid, true);
    PlayerSpectatePlayer(playerid, dest);
    format(szString, sizeof(szString), "[ADMIN]: Estas especteando a %s. Usa /dejardeespectar.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    return 1;
}

CMD:dejardeespectar(playerid)
{
    REQ_ADMIN(ADM_MODERADOR)
    if(Player[playerid][pEspectando] == -1) return AP_Msg(playerid, C_ROJO, "[ADMIN]: No estas especteando a nadie.");
    TogglePlayerSpectating(playerid, false);
    Player[playerid][pEspectando] = -1;
    AP_PrepararSpawn(playerid);
    SpawnPlayer(playerid);
    AP_AplicarDatos(playerid);
    AP_Msg(playerid, C_VERDE, "[ADMIN]: Has vuelto a tu cuerpo.");
    return 1;
}

CMD:ver(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /ver [id]");
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Ese jugador no esta conectado.");
    format(szString, sizeof(szString), "Nombre: %s | Nivel: %d | Dinero: $%d | Banco: $%d | Admin: %s | Faccion: %s | Trabajo: %s",
        NombrePorID(dest), Player[dest][pScore], Player[dest][pMoney], Player[dest][pBank], NombreAdmin[Player[dest][pAdmin]],
        (Player[dest][pFaccion] > 0) ? NombreFaccion[Player[dest][pFaccion]] : "Ninguna",
        (Player[dest][pJob] >= 0) ? NombreTrabajo[Player[dest][pJob]] : "Desempleado");
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:reportes(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(ContadorReportes == 0) return AP_Msg(playerid, C_VERDE, "[STAFF]: No hay reportes pendientes.");
    format(szString, sizeof(szString), "[STAFF]: Hay %d reportes sin responder. Usa /responder [id] [texto].", ContadorReportes);
    AP_Msg(playerid, C_AMARILLO, szString);
    return 1;
}

CMD:dudas(playerid)
{
    REQ_ADMIN(ADM_AYUDANTE)
    if(ContadorDudas == 0) return AP_Msg(playerid, C_VERDE, "[STAFF]: No hay dudas pendientes.");
    format(szString, sizeof(szString), "[STAFF]: Hay %d dudas sin responder. Usa /responder [id] [texto].", ContadorDudas);
    AP_Msg(playerid, C_AMARILLO, szString);
    return 1;
}

CMD:responder(playerid, params[])
{
    REQ_ADMIN(ADM_AYUDANTE)
    new idstr[12], texto[120];
    new idx = 0;
    if(!AP_Token(params, idx, idstr, sizeof(idstr))) return AP_Msg(playerid, C_ROJO, "Uso: /responder [id] [texto]");
    new resto = idx;
    while(params[resto] == ' ') resto++;
    strmid(texto, params, resto, strlen(params), sizeof(texto));
    if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[STAFF]: ID invalida.");
    new dest = strval(idstr);
    if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[STAFF]: Ese jugador no esta conectado.");
    format(szString, sizeof(szString), "[STAFF] %s te responde: %s", NombrePorID(playerid), texto);
    AP_Msg(dest, C_VERDE, szString);
    format(szString, sizeof(szString), "[STAFF]: Has respondido a %s.", NombrePorID(dest));
    AP_Msg(playerid, C_VERDE, szString);
    if(Player[dest][pReporte] >= 0) ContadorReportes--;
    if(Player[dest][pDuda] >= 0) ContadorDudas--;
    Player[dest][pReporte] = -1;
    Player[dest][pDuda] = -1;
    if(ContadorReportes < 0) ContadorReportes = 0;
    if(ContadorDudas < 0) ContadorDudas = 0;
    return 1;
}

CMD:borrarcuenta(playerid, params[])
{
    REQ_ADMIN(ADM_DUENO)
    new nombre[MAX_PLAYER_NAME];
    new idx = 0;
    if(!AP_Token(params, idx, nombre, sizeof(nombre))) return AP_Msg(playerid, C_ROJO, "Uso: /borrarcuenta [Nombre_Apellido]");
    new file[64];
    format(file, sizeof(file), "Cuentas/%s.ini", nombre);
    if(!fexist(file)) return AP_Msg(playerid, C_ROJO, "[ADMIN]: Esa cuenta no existe.");
    fremove(file);
    format(szString, sizeof(szString), "[ADMIN]: Cuenta %s eliminada del servidor.", nombre);
    AP_Msg(playerid, C_VERDE, szString);
    AP_Log("Admin", "Cuenta eliminada.");
    return 1;
}

CMD:guardar(playerid)
{
    AP_GuardarCuenta(playerid);
    AP_Msg(playerid, C_VERDE, "[SISTEMA]: Tu cuenta ha sido guardada.");
    return 1;
}

//==============================================================================
//  COMANDOS GENERALES DEL JUGADOR
//==============================================================================
CMD:ayuda(playerid)
{
    AP_Msg(playerid, C_AZUL, "--- "SERVER_NAME" | AYUDA ---");
    AP_Msg(playerid, -1, "/reglas - Normativas y conceptos de rol.");
    AP_Msg(playerid, -1, "/comandos - Lista completa de comandos.");
    AP_Msg(playerid, -1, "/trabajos - Agencia de empleo (12 trabajos).");
    AP_Msg(playerid, -1, "/infotrabajo - Informacion de tu empleo actual.");
    AP_Msg(playerid, -1, "/banco - Operaciones bancarias.");
    AP_Msg(playerid, -1, "/tienda - Tiendas 24/7 (comida, agua, objetos).");
    AP_Msg(playerid, -1, "/armas - Ammu-Nation.");
    AP_Msg(playerid, -1, "/casas - Mercado inmobiliario.");
    AP_Msg(playerid, -1, "/concesionario - Compra de vehiculos.");
    AP_Msg(playerid, -1, "/faccion - Facciones y rangos.");
    AP_Msg(playerid, -1, "/telefono - Telefono movil.");
    AP_Msg(playerid, -1, "/inventario - Tus objetos.");
    AP_Msg(playerid, -1, "/gps - Marcar un destino en el mapa.");
    AP_Msg(playerid, -1, "/stats - Tus estadisticas.");
    AP_Msg(playerid, -1, "/reportar [texto] - Contactar con el staff.");
    AP_Msg(playerid, -1, "/duda [texto] - Preguntar al staff.");
    return 1;
}

CMD:comandos(playerid)
{
    AP_Msg(playerid, C_AZUL, "--- COMANDOS DISPONIBLES ---");
    AP_Msg(playerid, -1, "ROL: /me /do /b /s /susurrar /gritar /ooc /n /anim /pararanim /rendirse /desmayarse");
    AP_Msg(playerid, -1, "TRABAJO: /trabajos /infotrabajo /tomartrabajo /renunciar /iniciarruta /terminarruta");
    AP_Msg(playerid, -1, "DINERO: /banco /depositar /retirar /transferir /balance /recaudar /venderitem /venderdroga");
    AP_Msg(playerid, -1, "PROPIEDADES: /casas /casa /vendercasa /negocio /veh /estacionar /venderveh /repararveh");
    AP_Msg(playerid, -1, "OBJETOS: /inventario /usar /dar /tirar /cultivar /cosecha");
    AP_Msg(playerid, -1, "TELEFONO: /telefono /numero /llamar /colgar /sms /contactos /agregarcontacto /recargar /911 /medico");
    AP_Msg(playerid, -1, "FACCION: /faccion /rangos /servicio /f /r /invitar /expulsar /faccionrango");
    AP_Msg(playerid, -1, "POLICIA: /esposar /desesposar /multar /arrestar /liberar");
    AP_Msg(playerid, -1, "GENERAL: /id /jugadores /staff /stats /zona /mapa /gps /skin /afk /volver /reloj /vip /guardar");
    if(Player[playerid][pAdmin] >= 1)
    {
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /admin /admins /adminduty /ir /traer /ira /kick /ban /desban /mute /desmute /slap");
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /congelar /descongelar /carcel /liberar /matar /curar /revivir /espectar /dejardeespectar");
        AP_Msg(playerid, C_AMARILLO, "ADMIN: /ver /reportes /dudas /responder /limpiarchat /dveh /destruirveh /flipveh");
        if(Player[playerid][pAdmin] >= ADM_ADMIN)
        {
            AP_Msg(playerid, C_AMARILLO, "ADMIN AVANZADO: /dardinero /quitardinero /setskin /hora /clima /anuncio");
        }
        if(Player[playerid][pAdmin] >= ADM_DIRECTOR)
        {
            AP_Msg(playerid, C_AMARILLO, "DIRECCION: /darvip /haceradmin /borrarcuenta");
        }
    }
    return 1;
}

CMD:reglas(playerid)
{
    ShowPlayerDialog(playerid, D_AYUDA_1, DIALOG_STYLE_MSGBOX, "{00FF00}"SERVER_NAME" - NORMATIVA",
        "{FFFFFF}Bienvenido a {00FF00}"SERVER_NAME"{FFFFFF}, un servidor de rol serio.\n\n{FFFF00}Conceptos basicos:\n{FFFFFF}- IC: informacion dentro del personaje.\n- OOC: informacion fuera del personaje.\n- PG: acciones imposibles en la vida real.\n- MG: usar informacion fuera del juego para beneficiarte.\n- DM: matar sin motivo de rol.\n- CJ: robar vehiculos sin rol previo.\n- RK: vengarse despues de morir.\n- ZZ: huir haciendo zig-zag para evitar balas.",
        "Siguiente", "Salir");
    return 1;
}

CMD:id(playerid, params[])
{
    if(isnull(params))
    {
        format(szString, sizeof(szString), "Tu ID es %d.", playerid);
        return AP_Msg(playerid, C_AZUL, szString);
    }
    new encontrados = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(strfind(NombrePorID(i), params, true) == 0)
        {
            format(szString, sizeof(szString), "%s (ID %d) - Nivel %d", NombrePorID(i), i, Player[i][pScore]);
            AP_Msg(playerid, -1, szString);
            encontrados++;
        }
    }
    if(encontrados == 0) AP_Msg(playerid, C_ROJO, "[ID]: No se encontro ningun jugador con ese nombre.");
    return 1;
}

CMD:jugadores(playerid)
{
    new total = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        total++;
        format(szString, sizeof(szString), "%d) %s - Nivel %d - %s", i, NombrePorID(i), Player[i][pScore],
            (Player[i][pJob] >= 0) ? NombreTrabajo[Player[i][pJob]] : "Desempleado");
        AP_Msg(playerid, -1, szString);
    }
    format(szString2, sizeof(szString2), "[SERVIDOR]: %d jugadores conectados.", total);
    AP_Msg(playerid, C_AZUL, szString2);
    return 1;
}

CMD:stats(playerid, params[])
{
    new dest = playerid;
    new idstr[12];
    new idx = 0;
    if(AP_Token(params, idx, idstr, sizeof(idstr)))
    {
        if(!EsNumerico(idstr)) return AP_Msg(playerid, C_ROJO, "[STATS]: ID invalida.");
        dest = strval(idstr);
        if(!IsPlayerConnected(dest) || !Player[dest][pOnline]) return AP_Msg(playerid, C_ROJO, "[STATS]: Ese jugador no esta conectado.");
    }
    new fac[32], job[32];
    if(Player[dest][pFaccion] > 0) format(fac, sizeof(fac), "%s (%s)", NombreFaccion[Player[dest][pFaccion]], RangoFaccion[Player[dest][pFaccion]][Player[dest][pRango]]);
    else format(fac, sizeof(fac), "Ninguna");
    if(Player[dest][pJob] >= 0) format(job, sizeof(job), "%s", NombreTrabajo[Player[dest][pJob]]);
    else format(job, sizeof(job), "Desempleado");
    format(szString, sizeof(szString), "{00FF00}%s{FFFFFF}\nNivel: {2ECC71}%d{FFFFFF} (XP %d)\nDinero: {2ECC71}$%d{FFFFFF} | Banco: {33AAF}$%d{FFFFFF}\nTrabajo: {FFFF00}%s{FFFFFF}\nFaccion: {FFFF00}%s{FFFFFF}\nHoras jugadas: {2ECC71}%d{FFFFFF}\nMuertes: %d | Arrestos: %d | Multas: %d | Rutas: %d\nVIP: %d | Telefono: %d",
        NombrePorID(dest), Player[dest][pScore], Player[dest][pXP], Player[dest][pMoney], Player[dest][pBank],
        job, fac, Player[dest][pHoras], Player[dest][pMuertes], Player[dest][pArrestos], Player[dest][pMultas],
        Player[dest][pRutas], Player[dest][pVIP], Player[dest][pTelefono]);
    ShowPlayerDialog(playerid, D_STATS_OTRO, DIALOG_STYLE_MSGBOX, "{00FF00}ESTADISTICAS", szString, "Cerrar", "");
    return 1;
}

CMD:me(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /me [accion]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "* %s %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 20.0, C_ROSA, szString);
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /do [entorno o situacion]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "* %s (( %s ))", params, NombrePorID(playerid));
    AP_MensajeCercano(playerid, 20.0, C_VERDE, szString);
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /b [chat fuera de personaje]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "(( [OOC] %s: %s ))", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 15.0, C_GRIS, szString);
    return 1;
}

CMD:s(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /s [gritar]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s grita: %s!!", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 40.0, -1, szString);
    return 1;
}

CMD:susurrar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /susurrar [texto]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s susurra: %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 6.0, C_GRIS, szString);
    return 1;
}

CMD:gritar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /gritar [texto]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s grita: %s!!", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 50.0, -1, szString);
    return 1;
}

CMD:ooc(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /ooc [mensaje global]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "(( [OOC] %s: %s ))", NombrePorID(playerid), params);
    SendClientMessageToAll(C_OOC, szString);
    return 1;
}

CMD:n(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /n [mensaje cercano]");
    if(Player[playerid][pMuted]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Estas silenciado.");
    format(szString, sizeof(szString), "%s: %s", NombrePorID(playerid), params);
    AP_MensajeCercano(playerid, 18.0, -1, szString);
    return 1;
}

CMD:reportar(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /reportar [texto]");
    if(Player[playerid][pReporte] >= 0) return AP_Msg(playerid, C_ROJO, "[REPORTE]: Ya tienes un reporte abierto. Espera la respuesta.");
    ContadorReportes++;
    Player[playerid][pReporte] = ContadorReportes;
    format(szString, sizeof(szString), "[REPORTE] %s (%d): %s", NombrePorID(playerid), playerid, params);
    AP_Msg(playerid, C_AMARILLO, "[REPORTE]: Tu reporte ha sido enviado al staff. Espera la respuesta.");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        AP_Msg(i, C_ROJO, szString);
    }
    AP_Log("Reportes", szString);
    return 1;
}

CMD:duda(playerid, params[])
{
    if(isnull(params)) return AP_Msg(playerid, C_ROJO, "Uso: /duda [texto]");
    if(Player[playerid][pDuda] >= 0) return AP_Msg(playerid, C_ROJO, "[DUDA]: Ya tienes una duda abierta. Espera la respuesta.");
    ContadorDudas++;
    Player[playerid][pDuda] = ContadorDudas;
    format(szString, sizeof(szString), "[DUDA] %s (%d): %s", NombrePorID(playerid), playerid, params);
    AP_Msg(playerid, C_AMARILLO, "[DUDA]: Tu duda ha sido enviada al staff. Espera la respuesta.");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || !Player[i][pOnline]) continue;
        if(Player[i][pAdmin] < 1) continue;
        AP_Msg(i, C_AZUL, szString);
    }
    AP_Log("Dudas", szString);
    return 1;
}

CMD:zona(playerid)
{
    new MapZone:zona = GetPlayerMapZone2D(playerid);
    new nombre[32];
    GetMapZoneName(zona, nombre, sizeof(nombre));
    format(szString, sizeof(szString), "[ZONA]: Estas en %s.", nombre);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:reloj(playerid)
{
    new h, m, s;
    gettime(h, m, s);
    format(szString, sizeof(szString), "[SERVIDOR]: Hora local %02d:%02d:%02d | Hora del juego %02d:00 | Clima %d", h, m, s, AP_Hora, AP_Clima);
    AP_Msg(playerid, C_AZUL, szString);
    return 1;
}

CMD:mapa(playerid)
{
    if(MapaAbierto[playerid]) return AP_CerrarMapa(playerid);
    AP_AbrirMapa(playerid);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return 1;
}

CMD:gps(playerid)
{
    new lista[900];
    strcat(lista, "1) Comisaria de Los Santos\n", sizeof(lista));
    strcat(lista, "2) Hospital General\n", sizeof(lista));
    strcat(lista, "3) Banco de San Andreas\n", sizeof(lista));
    strcat(lista, "4) Concesionario\n", sizeof(lista));
    strcat(lista, "5) Ammu-Nation\n", sizeof(lista));
    strcat(lista, "6) 24/7 de Idlewood\n", sizeof(lista));
    strcat(lista, "7) Sede Pizzero\n", sizeof(lista));
    strcat(lista, "8) Sede Basurero\n", sizeof(lista));
    strcat(lista, "9) Sede Camionero\n", sizeof(lista));
    strcat(lista, "10) Sede Pescador\n", sizeof(lista));
    strcat(lista, "11) Zona de cultivo\n", sizeof(lista));
    strcat(lista, "12) Compraventa\n", sizeof(lista));
    strcat(lista, "13) Aeropuerto de Los Santos\n", sizeof(lista));
    strcat(lista, "14) Mi casa\n", sizeof(lista));
    ShowPlayerDialog(playerid, D_ZONA, DIALOG_STYLE_LIST, "{00FF00}GPS - DESTINOS", lista, "Marcar", "Salir");
    return 1;
}

CMD:skin(playerid, params[])
{
    new skin[8];
    new idx = 0;
    if(!AP_Token(params, idx, skin, sizeof(skin))) return AP_Msg(playerid, C_ROJO, "Uso: /skin [id del skin 1-311]");
    if(!EsNumerico(skin)) return AP_Msg(playerid, C_ROJO, "[SKIN]: Skin invalido.");
    new id = strval(skin);
    if(id < 1 || id > 311) return AP_Msg(playerid, C_ROJO, "[SKIN]: El skin debe estar entre 1 y 311.");
    Player[playerid][pSkin] = id;
    SetPlayerSkin(playerid, id);
    AP_Msg(playerid, C_VERDE, "[SKIN]: Apariencia actualizada.");
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:afk(playerid, params[])
{
    if(Player[playerid][pDlg][3]) return AP_Msg(playerid, C_ROJO, "[AFK]: Ya estas en modo ausente.");
    Player[playerid][pDlg][3] = 1;
    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "PED", "IDLE_chat", 4.0, 1, 0, 0, 0, 0, 1);
    if(isnull(params)) format(szString, sizeof(szString), "~y~~h~%s esta ausente (AFK).", NombrePorID(playerid));
    else format(szString, sizeof(szString), "~y~~h~%s esta ausente: %s", NombrePorID(playerid), params);
    AP_MostrarMensaje(playerid, "Estas en modo ausente. Usa /volver para reactivarte.", 6);
    AP_Msg(playerid, C_AMARILLO, "[AFK]: Modo ausente activado. Usa /volver para volver.");
    return 1;
}

CMD:volver(playerid)
{
    if(!Player[playerid][pDlg][3]) return AP_Msg(playerid, C_ROJO, "[AFK]: No estas en modo ausente.");
    Player[playerid][pDlg][3] = 0;
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    AP_Msg(playerid, C_VERDE, "[AFK]: Bienvenido de vuelta.");
    return 1;
}

//==============================================================================
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
    // Control de realismo: el nombre debe tener formato Nombre_Apellido
    if(!TieneNombreRol(NombreJugador(playerid)))
    {
        SendClientMessage(playerid, 0xFF0000FF, "[ERROR OOC]: Tu nombre no cumple el formato exigido: Nombre_Apellido.");
        SendClientMessage(playerid, -1, "Ejemplo correcto: Carlos_Mendoza, Jessica_Taylor. No uses apodos de internet.");
        SetTimerEx("AP_KickInmediato", 600, false, "i", playerid);
        return 1;
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
    format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));

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
            format(file, sizeof(file), "Cuentas/%s.ini", NombreJugador(playerid));
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
//  MODULO DE COMANDOS PERSONALES DE ROL
//==============================================================================
#include "./modules/p.cmd.inc"
