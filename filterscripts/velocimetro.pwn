/*
    ===================================================================
    FILTERSCRIPT: VELOCÍMETRO TEXTDRAW REALISTA
    Creado para: Proxy Roleplay
    Cálculo: Magnitud de Vector 3D -> KM/H Realistas
    ===================================================================
*/

#define FILTERSCRIPT

#include <a_samp>

// Colores del sistema de strings
#define COLOR_ERROR         0xFF0000FF

// Variables de los TextDraws por jugador
new PlayerText:TD_VelocimetroFondo[MAX_PLAYERS];
new PlayerText:TD_VelocimetroDatos[MAX_PLAYERS];
new PlayerText:TD_VelocimetroEstado[MAX_PLAYERS];

// Timer de actualización
new TimerVelocimetro[MAX_PLAYERS];

// Forward para el temporizador
forward ActualizarVelocimetro(playerid);

public OnFilterScriptInit()
{
    print("\n------------------------------------------------");
    print("  >> FS Velocímetro Realista TD Cargado <<     ");
    print("  >> Cálculo de velocidad vectorial 3D Activo <<");
    print("------------------------------------------------\n");
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            OcultarVelocimetro(i);
        }
    }
    return 1;
}

// ==========================================
// DETECCIÓN DE ESTADO DEL JUGADOR
// ==========================================

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // Si el jugador entra a un vehículo como CONDUCTOR (State 1)
    if(newstate == PLAYER_STATE_DRIVER)
    {
        MostrarVelocimetro(playerid);
        // Crear un timer de alta precisión (actualiza cada 150 milisegundos para suavidad)
        TimerVelocimetro[playerid] = SetTimerEx("ActualizarVelocimetro", 150, true, "i", playerid);
    }
    
    // Si sale del vehículo o pasa a ser pasajero
    if(oldstate == PLAYER_STATE_DRIVER)
    {
        KillTimer(TimerVelocimetro[playerid]);
        OcultarVelocimetro(playerid);
    }
    return 1;
}

// ==========================================
// CÁLCULO REALISTA Y ACTUALIZACIÓN
// ==========================================

public ActualizarVelocimetro(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        KillTimer(TimerVelocimetro[playerid]);
        OcultarVelocimetro(playerid);
        return 1;
    }

    new vehid = GetPlayerVehicleID(playerid);
    
    // 1. CÁLCULO DE VELOCIDAD REALISTA (Vectores de velocidad de SA-MP)
    new Float:vx, Float:vy, Float:vz, Float:velocidadReal;
    GetVehicleVelocity(vehid, vx, vy, vz);
    
    // Fórmula física: Magnitud del vector multiplicada por el factor de escala SA-MP para KM/H (136.66)
    velocidadReal = floatsqroot((vx*vx) + (vy*vy) + (vz*vz)) * 136.66;

    // 2. OBTENER SALUD DEL VEHÍCULO
    new Float:vSalud, estadoSalud;
    GetVehicleHealth(vehid, vSalud);
    // SA-MP maneja la vida de 0.0 a 1000.0. Lo convertimos a porcentaje (0-100%)
    estadoSalud = floatround(vSalud / 10.0);
    if(estadoSalud > 100) estadoSalud = 100;
    if(estadoSalud < 0) estadoSalud = 0;

    // 3. DETECTAR SI EL MOTOR ESTÁ ENCENDIDO
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);

    // 4. FORMATEAR TEXTDRAWS CON COLORES DINÁMICOS
    new strDatos[64], strEstado[64];
    
    // Color de velocidad (Se pone rojo si va muy rápido)
    if(velocidadReal < 60.0) {
        format(strDatos, sizeof(strDatos), "~w~%03d ~b~KM/H", floatround(velocidadReal));
    } else if(velocidadReal >= 60.0 && velocidadReal < 120.0) {
        format(strDatos, sizeof(strDatos), "~y~%03d ~b~KM/H", floatround(velocidadReal));
    } else {
        format(strDatos, sizeof(strDatos), "~r~%03d ~b~KM/H", floatround(velocidadReal));
    }

    // Color del estado del motor y daño
    new strMotor[16], strColorSalud[8];
    if(engine == VEHICLE_PARAMS_ON) strMotor = "~g~ENCENDIDO";
    else strMotor = "~r~APAGADO";

    if(estadoSalud > 60) strColorSalud = "~g~";
    else if(estadoSalud > 30) strColorSalud = "~y~";
    else strColorSalud = "~r~";

    format(strEstado, sizeof(strEstado), "MOTOR: %s_~w~CHASIS: %s%d%%", strMotor, strColorSalud, estadoSalud);

    // Actualizar strings en pantalla
    PlayerTextDrawSetString(playerid, TD_VelocimetroDatos[playerid], strDatos);
    PlayerTextDrawSetString(playerid, TD_VelocimetroEstado[playerid], strEstado);
    return 1;
}

// ==========================================
// CREACIÓN Y CONTROL DE TEXTDRAWS (INTERFAZ)
// ==========================================

stock MostrarVelocimetro(playerid)
{
    // Fondo Negro Translúcido
    TD_VelocimetroFondo[playerid] = CreatePlayerTextDraw(playerid, 500.000000, 360.000000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, TD_VelocimetroFondo[playerid], 125.000000, 65.000000);
    PlayerTextDrawAlignment(playerid, TD_VelocimetroFondo[playerid], 1);
    PlayerTextDrawColor(playerid, TD_VelocimetroFondo[playerid], 150); // Opacidad media
    PlayerTextDrawSetShadow(playerid, TD_VelocimetroFondo[playerid], 0);
    PlayerTextDrawSetOutline(playerid, TD_VelocimetroFondo[playerid], 0);
    PlayerTextDrawFont(playerid, TD_VelocimetroFondo[playerid], 4); // Textura de recuadro

    // Marcador de Velocidad (KM/H)
    TD_VelocimetroDatos[playerid] = CreatePlayerTextDraw(playerid, 505.000000, 365.000000, "000 KM/H");
    PlayerTextDrawLetterSize(playerid, TD_VelocimetroDatos[playerid], 0.550000, 2.200000);
    PlayerTextDrawAlignment(playerid, TD_VelocimetroDatos[playerid], 1);
    PlayerTextDrawColor(playerid, TD_VelocimetroDatos[playerid], -1);
    PlayerTextDrawSetShadow(playerid, TD_VelocimetroDatos[playerid], 1);
    PlayerTextDrawSetOutline(playerid, TD_VelocimetroDatos[playerid], 0);
    PlayerTextDrawFont(playerid, TD_VelocimetroDatos[playerid], 3); // Fuente estilizada sa-mp

    // Estado mecánico (Motor e Integridad del coche)
    TD_VelocimetroEstado[playerid] = CreatePlayerTextDraw(playerid, 505.000000, 395.000000, "MOTOR: ~r~APAGADO_~w~CHASIS: ~g~100%");
    PlayerTextDrawLetterSize(playerid, TD_VelocimetroEstado[playerid], 0.220000, 1.100000);
    PlayerTextDrawAlignment(playerid, TD_VelocimetroEstado[playerid], 1);
    PlayerTextDrawColor(playerid, TD_VelocimetroEstado[playerid], -1);
    PlayerTextDrawSetShadow(playerid, TD_VelocimetroEstado[playerid], 1);
    PlayerTextDrawSetOutline(playerid, TD_VelocimetroEstado[playerid], 0);
    PlayerTextDrawFont(playerid, TD_VelocimetroEstado[playerid], 1);

    // Mostrar todo al usuario
    PlayerTextDrawShow(playerid, TD_VelocimetroFondo[playerid]);
    PlayerTextDrawShow(playerid, TD_VelocimetroDatos[playerid]);
    PlayerTextDrawShow(playerid, TD_VelocimetroEstado[playerid]);
    return 1;
}

stock OcultarVelocimetro(playerid)
{
    // Destruir los elementos de la interfaz para liberar memoria de TextDraws
    if(TD_VelocimetroFondo[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, TD_VelocimetroFondo[playerid]);
        PlayerTextDrawDestroy(playerid, TD_VelocimetroDatos[playerid]);
        PlayerTextDrawDestroy(playerid, TD_VelocimetroEstado[playerid]);
        
        TD_VelocimetroFondo[playerid] = PlayerText:INVALID_TEXT_DRAW;
        TD_VelocimetroDatos[playerid] = PlayerText:INVALID_TEXT_DRAW;
        TD_VelocimetroEstado[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
    return 1;
}