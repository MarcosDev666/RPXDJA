/*
    ===================================================================
    FILTERSCRIPT DE TRABAJOS SECUNDARIOS (PIZZERO, BASURERO, CAMIONERO)
    Creado para: Proxy Roleplay
    Comandos: ZCMD
    Interfaz: Diálogos nativos
    ===================================================================
*/

#define FILTERSCRIPT

#include <a_samp>
#include <zcmd>

// Identificadores de Trabajos
#define TRABAJO_NINGUNO     0
#define TRABAJO_PIZZERO     1
#define TRABAJO_BASURERO    2
#define TRABAJO_CAMIONERO   3

// ID del Diálogo Principal
#define DIALOG_TRABAJOS     8540

// Colores del Sistema
#define COLOR_TRABAJO       0x2ECC71FF // Verde Esmeralda
#define COLOR_INFO          0x33AAFFFF // Azul
#define COLOR_ERROR         0xFF0000FF // Rojo
#define COLOR_AVISO         0xFFFF00FF // Amarillo

// Variables de Estado de los Jugadores
new PlayerTrabajo[MAX_PLAYERS];
new EnRutaTrabajo[MAX_PLAYERS];
new CheckpointPaso[MAX_PLAYERS];
new VehiculoTrabajo[MAX_PLAYERS];

// Coordenadas de las Agencias de Empleo (Donde se toman los trabajos)
new const Float:PosPizzaria[3]  = {2103.5415, -1806.5271, 13.5547}; // Idlewood Pizza
new const Float:PosBasureros[3] = {2185.1274, -1974.7554, 13.5512}; // Cerca de la estación del sur
new const Float:PosCamiones[3]  = {-77.3621, -1136.2144, 1.0781};   // Depósito cerca de las muelles

// ==========================================
// CALLBACKS PRINCIPALES
// ==========================================

public OnFilterScriptInit()
{
    print("\n------------------------------------------------");
    print("  >> Sistema de Trabajos Secundarios Cargado << ");
    print("  >> Pizzero, Basurero y Camionero Activos  << ");
    print("------------------------------------------------\n");

    // Creamos Pickups visuales e hilos de texto (3D Text Labels) en las sedes
    CreatePickup(1239, 1, PosPizzaria[0], PosPizzaria[1], PosPizzaria[2], -1);
    Create3DTextLabel("{2ECC71}[Sede Pizzero]\n{FFFFFF}Usa {FFFF00}/trabajar", -1, PosPizzaria[0], PosPizzaria[1], PosPizzaria[2] + 0.5, 20.0, 0, 1);

    CreatePickup(1239, 1, PosBasureros[0], PosBasureros[1], PosBasureros[2], -1);
    Create3DTextLabel("{2ECC71}[Sede Basurero]\n{FFFFFF}Usa {FFFF00}/trabajar", -1, PosBasureros[0], PosBasureros[1], PosBasureros[2] + 0.5, 20.0, 0, 1);

    CreatePickup(1239, 1, PosCamiones[0], PosCamiones[1], PosCamiones[2], -1);
    Create3DTextLabel("{2ECC71}[Sede Camionero]\n{FFFFFF}Usa {FFFF00}/trabajar", -1, PosCamiones[0], PosCamiones[1], PosCamiones[2] + 0.5, 20.0, 0, 1);
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            LimpiarTrabajo(i);
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerTrabajo[playerid] = TRABAJO_NINGUNO;
    EnRutaTrabajo[playerid] = 0;
    CheckpointPaso[playerid] = 0;
    VehiculoTrabajo[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    LimpiarTrabajo(playerid);
    return 1;
}

// ==========================================
// COMANDOS DE ENTRADA / MENÚ
// ==========================================

CMD:trabajar(playerid)
{
    // Verificar si está cerca de alguna de las 3 sedes
    if(IsPlayerInRangeOfPoint(playerid, 4.0, PosPizzaria[0], PosPizzaria[1], PosPizzaria[2]))
    {
        ShowPlayerDialog(playerid, DIALOG_TRABAJOS, DIALOG_STYLE_MSGBOX, "Sede: Repartidor de Pizza", "¿Deseas ingresar a este empleo y comenzar a repartir pizzas?", "Aceptar", "Cancelar");
        SetPVarInt(playerid, "SedeID", TRABAJO_PIZZERO);
    }
    else if(IsPlayerInRangeOfPoint(playerid, 4.0, PosBasureros[0], PosBasureros[1], PosBasureros[2]))
    {
        ShowPlayerDialog(playerid, DIALOG_TRABAJOS, DIALOG_STYLE_MSGBOX, "Sede: Basurero Municipal", "¿Deseas ingresar a este empleo y limpiar las calles de Los Santos?", "Aceptar", "Cancelar");
        SetPVarInt(playerid, "SedeID", TRABAJO_BASURERO);
    }
    else if(IsPlayerInRangeOfPoint(playerid, 4.0, PosCamiones[0], PosCamiones[1], PosCamiones[2]))
    {
        ShowPlayerDialog(playerid, DIALOG_TRABAJOS, DIALOG_STYLE_MSGBOX, "Sede: Logística de Camioneros", "¿Deseas ingresar a este empleo y transportar cargas pesadas?", "Aceptar", "Cancelar");
        SetPVarInt(playerid, "SedeID", TRABAJO_CAMIONERO);
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "[Error] No estás en ninguna sede de empleo secundario (Iconos de la i).");
    }
    return 1;
}

CMD:renunciar(playerid)
{
    if(PlayerTrabajo[playerid] == TRABAJO_NINGUNO)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Actualmente estás desempleado.");

    LimpiarTrabajo(playerid);
    PlayerTrabajo[playerid] = TRABAJO_NINGUNO;
    SendClientMessage(playerid, COLOR_AVISO, "Has renunciado a tu empleo actual exitosamente.");
    return 1;
}

CMD:iniciarruta(playerid)
{
    if(PlayerTrabajo[playerid] == TRABAJO_NINGUNO)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No tienes ningún trabajo.");

    if(EnRutaTrabajo[playerid] == 1)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] Ya estás en medio de una ruta de reparto.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    switch(PlayerTrabajo[playerid])
    {
        case TRABAJO_PIZZERO:
        {
            VehiculoTrabajo[playerid] = CreateVehicle(448, x + 2.0, y, z + 1.0, a, 3, 3, 60000); // Faggio Pizza
            SendClientMessage(playerid, COLOR_TRABAJO, "[Pizzero] Súbete a la moto de reparto. Ve al punto rojo marcado en el minimapa.");
            SetPlayerCheckpoint(playerid, 2112.9856, -1614.9751, 13.3828, 3.5); // Checkpoint 1: Cerca del hospital
        }
        case TRABAJO_BASURERO:
        {
            VehiculoTrabajo[playerid] = CreateVehicle(408, x + 3.0, y, z + 1.0, a, 1, 1, 60000); // Trashmaster
            SendClientMessage(playerid, COLOR_TRABAJO, "[Basurero] Súbete al camión de basura y recolecta las bolsas en los vecindarios.");
            SetPlayerCheckpoint(playerid, 2379.0305, -1892.4933, 13.3828, 4.0); // Checkpoint 1: Casas de Ganton
        }
        case TRABAJO_CAMIONERO:
        {
            VehiculoTrabajo[playerid] = CreateVehicle(403, x + 4.0, y, z + 1.0, a, 0, 0, 60000); // Linerunner
            SendClientMessage(playerid, COLOR_TRABAJO, "[Camionero] Conduce el camión de carga industrial hacia los contenedores externos.");
            SetPlayerCheckpoint(playerid, 2769.3459, -2441.9741, 13.6358, 5.0); // Checkpoint 1: Muelles de carga externa
        }
    }

    PutPlayerInVehicle(playerid, VehiculoTrabajo[playerid], 0);
    EnRutaTrabajo[playerid] = 1;
    CheckpointPaso[playerid] = 1;
    return 1;
}

CMD:terminarruta(playerid)
{
    if(EnRutaTrabajo[playerid] == 0)
        return SendClientMessage(playerid, COLOR_ERROR, "[Error] No estás realizando ninguna ruta activa.");

    LimpiarTrabajo(playerid);
    SendClientMessage(playerid, COLOR_AVISO, "Has cancelado la ruta y regresado las herramientas de trabajo.");
    return 1;
}

// ==========================================
// CONTROL DE DIÁLOGOS (ACEPTACIÓN DE EMPLEO)
// ==========================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_TRABAJOS)
    {
        if(!response) return DeletePVar(playerid, "SedeID");

        new tID = GetPVarInt(playerid, "SedeID");
        PlayerTrabajo[playerid] = tID;
        DeletePVar(playerid, "SedeID");

        new str[128];
        format(str, sizeof(str), "[Empleo] ¡Felicidades! Ahora estás contratado. Usa {FFFF00}/iniciarruta {2ECC71}para comenzar.");
        SendClientMessage(playerid, COLOR_TRABAJO, str);
        return 1;
    }
    return 0;
}

// ==========================================
// RUTA DINÁMICA DE CHECKPOINTS (PROGRESO)
// ==========================================

public OnPlayerEnterCheckpoint(playerid)
{
    if(EnRutaTrabajo[playerid] == 0) return DisablePlayerCheckpoint(playerid);

    // Si el jugador baja del vehículo asignado, no avanza el trabajo
    if(GetPlayerVehicleID(playerid) != VehiculoTrabajo[playerid])
    {
        return SendClientMessage(playerid, COLOR_ERROR, "[Trabajo] ¡Debes estar conduciendo el vehículo laboral asignado!");
    }

    new str[128];
    switch(PlayerTrabajo[playerid])
    {
        case TRABAJO_PIZZERO:
        {
            if(CheckpointPaso[playerid] == 1)
            {
                DisablePlayerCheckpoint(playerid);
                SendClientMessage(playerid, COLOR_INFO, "[Pizzero] Primera pizza entregada. Dirígete al siguiente domicilio residencial.");
                SetPlayerCheckpoint(playerid, 2244.6970, -1434.6212, 23.8281, 3.5); // Checkpoint 2: Jefferson
                CheckpointPaso[playerid] = 2;
            }
            else if(CheckpointPaso[playerid] == 2)
            {
                DisablePlayerCheckpoint(playerid);
                // Fin del trabajo, pago en efectivo
                GivePlayerMoney(playerid, 450);
                format(str, sizeof(str), "[Pizzero] ¡Ruta Completada! Has recibido un pago de: {00FF00}$450.");
                SendClientMessage(playerid, COLOR_TRABAJO, str);
                LimpiarTrabajo(playerid);
            }
        }
        case TRABAJO_BASURERO:
        {
            if(CheckpointPaso[playerid] == 1)
            {
                DisablePlayerCheckpoint(playerid);
                SendClientMessage(playerid, COLOR_INFO, "[Basurero] Contenedor vaciado. Avanza a la siguiente esquina.");
                SetPlayerCheckpoint(playerid, 2486.2949, -2012.3551, 13.5469, 4.0); // Checkpoint 2: Willowfield
                CheckpointPaso[playerid] = 2;
            }
            else if(CheckpointPaso[playerid] == 2)
            {
                DisablePlayerCheckpoint(playerid);
                GivePlayerMoney(playerid, 600);
                format(str, sizeof(str), "[Basurero] ¡Camión lleno! Has depositado el desecho y ganado: {00FF00}$600.");
                SendClientMessage(playerid, COLOR_TRABAJO, str);
                LimpiarTrabajo(playerid);
            }
        }
        case TRABAJO_CAMIONERO:
        {
            if(CheckpointPaso[playerid] == 1)
            {
                DisablePlayerCheckpoint(playerid);
                SendClientMessage(playerid, COLOR_INFO, "[Camionero] Remolque inspeccionado. Entrega la mercancía en el centro urbano.");
                SetPlayerCheckpoint(playerid, 1424.3168, -1320.1075, 13.5421, 5.0); // Checkpoint 2: Depósito comercial Downtown
                CheckpointPaso[playerid] = 2;
            }
            else if(CheckpointPaso[playerid] == 2)
            {
                DisablePlayerCheckpoint(playerid);
                GivePlayerMoney(playerid, 1200);
                format(str, sizeof(str), "[Camionero] ¡Flete asegurado y entregado! Ganancia: {00FF00}$1,200.");
                SendClientMessage(playerid, COLOR_TRABAJO, str);
                LimpiarTrabajo(playerid);
            }
        }
    }
    return 1;
}

// ==========================================
// FUNCIONES INTERNAS (STOCKS)
// ==========================================

stock LimpiarTrabajo(playerid)
{
    DisablePlayerCheckpoint(playerid);
    EnRutaTrabajo[playerid] = 0;
    CheckpointPaso[playerid] = 0;
    
    if(VehiculoTrabajo[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(VehiculoTrabajo[playerid]);
        VehiculoTrabajo[playerid] = INVALID_VEHICLE_ID;
    }
    return 1;
}