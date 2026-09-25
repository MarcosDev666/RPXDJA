//==============================================================================
//  SISTEMA DE ESTABLECIMIENTOS
//  Farmacias, supermercados, bares, restaurantes, gimnasios, peluquerias,
//  tatuajes, tiendas de ropa, casinos, hoteles, gasolineras, electronicas,
//  alquiler de vehiculos, concesionarios, discotecas y talleres.
//  Todo el catalogo es data-driven: se anaden locales y productos sin tocar
//  la logica.
//==============================================================================

// Tipos de establecimiento
#define LOC_FARMACIA       1
#define LOC_SUPER          2
#define LOC_BAR            3
#define LOC_RESTAURANTE    4
#define LOC_GIMNASIO       5
#define LOC_PELUQUERIA     6
#define LOC_TATUAJES       7
#define LOC_ROPA           8
#define LOC_CASINO         9
#define LOC_HOTEL          10
#define LOC_GASOLINERA     11
#define LOC_ELECTRONICA    12
#define LOC_ALQUILER       13
#define LOC_CONCESIONARIO  14
#define LOC_DISCO          15
#define LOC_TALLER         16

#define MAX_LOCALES        56
#define MAX_PRODS         80

// Nombres de los tipos (para etiquetas y dialogos)
new const LocTipoNombre[17][] =
{
    "Desconocido", "Farmacia", "Supermercado", "Bar", "Restaurante", "Gimnasio",
    "Peluqueria", "Estudio de tatuajes", "Tienda de ropa", "Casino", "Hotel",
    "Gasolinera", "Tienda de electronica", "Alquiler de vehiculos",
    "Concesionario", "Discoteca", "Taller mecanico"
};

// Colores de etiqueta por tipo
new const LocTipoColor[17] =
{
    0xFFFFFFFF, 0xFF2ECC71FF, 0xFF2ECC71FF, 0xFFFF8C00FF, 0xFFFF8C00FF, 0xFF00FFFFFF,
    0xFFFF69B4FF, 0xFFFF69B4FF, 0xFFFFD700FF, 0xFFFF0000FF, 0xFF33AAAFFF, 0xFFBBBBBBFF,
    0xFF00BFFFFF, 0xFF00BFFFFF, 0xFF9ACD32FF, 0xFFFF1493FF, 0xFFAAAAAAFF
};

//------------------------------------------------------------------------------
//  CATALOGO DE PRODUCTOS
//  Cada producto pertenece a un tipo de local. prodItem = -1 significa que
//  no entrega objeto (es un servicio).
//------------------------------------------------------------------------------
enum E_PROD
{
    prodTipo,
    prodNombre[26],
    prodPrecio,
    prodItem,
    prodCant,
    prodSkill
}

new const Productos[][E_PROD] =
{
    //--- FARMACIA ---
    {LOC_FARMACIA, "Botiquin",            800,  ITEM_BOTIQUIN,    1, -1},
    {LOC_FARMACIA, "Medicamento",         450,  ITEM_MEDICAMENTO, 1, -1},
    {LOC_FARMACIA, "Vendas",              150,  -1,               1, -1},
    {LOC_FARMACIA, "Jarabe para la tos",  220,  -1,               1, -1},
    {LOC_FARMACIA, "Vitaminas",           300,  -1,               3, -1},
    {LOC_FARMACIA, "Analgesico fuerte",   500,  -1,               1, -1},
    {LOC_FARMACIA, "Mascarilla",          90,   -1,               5, -1},

    //--- SUPERMERCADO ---
    {LOC_SUPER,    "Comida rapida",       250,  -1,               1, SK_COCINA},
    {LOC_SUPER,    "Agua mineral",        120,  -1,               3, -1},
    {LOC_SUPER,    "Leche",               100,  -1,               2, -1},
    {LOC_SUPER,    "Pan",                 80,   -1,               3, -1},
    {LOC_SUPER,    "Bolsa de comida",     900,  -1,               1, -1},

    //--- BAR ---
    {LOC_BAR,      "Cerveza",             350,  ITEM_CERVEZA,     1, -1},
    {LOC_BAR,      "Vino tinto",          600,  -1,               1, -1},
    {LOC_BAR,      "Whisky",              950,  -1,               1, -1},
    {LOC_BAR,      "Trago de tequila",    700,  -1,               1, -1},
    {LOC_BAR,      "Coctel de la casa",   850,  -1,               1, SK_COCINA},

    //--- RESTAURANTE ---
    {LOC_RESTAURANTE, "Hamburguesa",      400,  -1,               1, SK_COCINA},
    {LOC_RESTAURANTE, "Pizza completa",   750,  -1,               1, SK_COCINA},
    {LOC_RESTAURANTE, "Ensalada",         300,  -1,               1, SK_COCINA},
    {LOC_RESTAURANTE, "Sopa del dia",     280,  -1,               1, SK_COCINA},
    {LOC_RESTAURANTE, "Cafe expreso",     150,  -1,               2, -1},
    {LOC_RESTAURANTE, "Menu ejecutivo",   1200, -1,               1, SK_COCINA},

    //--- GIMNASIO ---
    {LOC_GIMNASIO, "Membresia mensual",   5000, -1,               1, -1},
    {LOC_GIMNASIO, "Rutina de fuerza",    900,  -1,               1, SK_FUERZA},
    {LOC_GIMNASIO, "Proteina en polvo",   700,  -1,               2, SK_FUERZA},
    {LOC_GIMNASIO, "Clase de boxeo",      1100, -1,               1, SK_DISPARO},
    {LOC_GIMNASIO, "Sesion de cardio",    600,  -1,               1, -1},

    //--- PELUQUERIA ---
    {LOC_PELUQUERIA, "Corte de pelo",     400,  -1,               1, -1},
    {LOC_PELUQUERIA, "Tinte",             900,  -1,               1, -1},
    {LOC_PELUQUERIA, "Arreglo de barba",  350,  -1,               1, -1},
    {LOC_PELUQUERIA, "Cambio de imagen",  1500, -1,               1, -1},

    //--- TATUAAJES ---
    {LOC_TATUAJES, "Tatuaje pequeno",     2500, -1,               1, -1},
    {LOC_TATUAJES, "Tatuaje mediano",     6000, -1,               1, -1},
    {LOC_TATUAJES, "Tatuaje completo",    15000,-1,               1, -1},
    {LOC_TATUAJES, "Piercing",            1800, -1,               1, -1},

    //--- ROPA ---
    {LOC_ROPA,     "Ropa casual",         600,  -1,               1, -1},
    {LOC_ROPA,     "Ropa formal",         1800, -1,               1, -1},
    {LOC_ROPA,     "Ropa deportiva",      900,  -1,               1, -1},
    {LOC_ROPA,     "Traje de gala",       4500, -1,               1, -1},
    {LOC_ROPA,     "Chaqueta de cuero",   2200, -1,               1, -1},

    //--- CASINO ---
    {LOC_CASINO,   "Fichas (10)",         1000, -1,               10, -1},
    {LOC_CASINO,   "Fichas (50)",         4500, -1,               50, -1},
    {LOC_CASINO,   "Mesa VIP",            20000,-1,               1, -1},

    //--- HOTEL ---
    {LOC_HOTEL,    "Habitacion por hora", 1200, -1,               1, -1},
    {LOC_HOTEL,    "Habitacion por noche",4500, -1,               1, -1},
    {LOC_HOTEL,    "Suite presidencial",  18000,-1,               1, -1},

    //--- GASOLINERA ---
    {LOC_GASOLINERA, "Llenar deposito",   600,  -1,               1, -1},
    {LOC_GASOLINERA, "Gasoil premium",    900,  -1,               1, -1},
    {LOC_GASOLINERA, "Aceite de motor",   450,  -1,               1, SK_MECANICA},
    {LOC_GASOLINERA, "Reparacion rapida", 1500, -1,               1, SK_MECANICA},

    //--- ELECTRONICA ---
    {LOC_ELECTRONICA, "Telefono movil",   1500, ITEM_TELEFONO,    1, -1},
    {LOC_ELECTRONICA, "Radio portatil",   900,  ITEM_RADIO,       1, -1},
    {LOC_ELECTRONICA, "Bateria externa",  500,  -1,               1, -1},
    {LOC_ELECTRONICA, "Camara de fotos",  2200, -1,               1, -1},
    {LOC_ELECTRONICA, "Cargador",         300,  -1,               2, -1},

    //--- ALQUILER DE VEHICULOS ---
    {LOC_ALQUILER, "Coche por 1 hora",    3000, -1,               1, SK_CONDUCCION},
    {LOC_ALQUILER, "Moto por 1 hora",     1800, -1,               1, SK_CONDUCCION},
    {LOC_ALQUILER, "Furgoneta por 1 hora",4200, -1,               1, SK_CONDUCCION},
    {LOC_ALQUILER, "Deportivo por 1 hora",9000, -1,               1, SK_CONDUCCION},

    //--- CONCESIONARIO ---
    {LOC_CONCESIONARIO, "Coche economico",     95000,  -1, 1, SK_CONDUCCION},
    {LOC_CONCESIONARIO, "Sedan familiar",      140000, -1, 1, SK_CONDUCCION},
    {LOC_CONCESIONARIO, "Deportivo",           450000, -1, 1, SK_CONDUCCION},
    {LOC_CONCESIONARIO, "Camioneta 4x4",       200000, -1, 1, SK_CONDUCCION},
    {LOC_CONCESIONARIO, "Moto deportiva",      110000, -1, 1, SK_CONDUCCION},

    //--- DISCOTECA ---
    {LOC_DISCO,    "Entrada",             500,  -1,               1, -1},
    {LOC_DISCO,    "Copa",                700,  -1,               1, -1},
    {LOC_DISCO,    "Botella VIP",         6000, -1,               1, -1},
    {LOC_DISCO,    "Clase de baile",      800,  -1,               1, -1},

    //--- TALLER ---
    {LOC_TALLER,   "Reparacion completa", 2500, -1,               1, SK_MECANICA},
    {LOC_TALLER,   "Cambio de pintura",   3500, -1,               1, SK_MECANICA},
    {LOC_TALLER,   "Tuneo de motor",      12000,-1,               1, SK_MECANICA},
    {LOC_TALLER,   "Llanta nueva",        300,  ITEM_LLANTA,      1, SK_MECANICA}
};

//------------------------------------------------------------------------------
//  DATOS DE LOS LOCALES
//------------------------------------------------------------------------------
enum E_LOCAL
{
    lTipo,
    lPrecio,
    Float:lX,
    Float:lY,
    Float:lZ,
    lPickup,
    Text3D:lLabel
}

new Locales[MAX_LOCALES][E_LOCAL];
new TotalLocales = 0;

// Tabla de posiciones: tipo, x, y, z
new const LocPosTipo[57] =
{
    LOC_FARMACIA,
    LOC_FARMACIA,
    LOC_FARMACIA,
    LOC_FARMACIA,
    LOC_SUPER,
    LOC_SUPER,
    LOC_SUPER,
    LOC_SUPER,
    LOC_BAR,
    LOC_BAR,
    LOC_BAR,
    LOC_BAR,
    LOC_RESTAURANTE,
    LOC_RESTAURANTE,
    LOC_RESTAURANTE,
    LOC_RESTAURANTE,
    LOC_GIMNASIO,
    LOC_GIMNASIO,
    LOC_GIMNASIO,
    LOC_PELUQUERIA,
    LOC_PELUQUERIA,
    LOC_PELUQUERIA,
    LOC_TATUAJES,
    LOC_TATUAJES,
    LOC_TATUAJES,
    LOC_ROPA,
    LOC_ROPA,
    LOC_ROPA,
    LOC_ROPA,
    LOC_CASINO,
    LOC_CASINO,
    LOC_CASINO,
    LOC_HOTEL,
    LOC_HOTEL,
    LOC_HOTEL,
    LOC_HOTEL,
    LOC_GASOLINERA,
    LOC_GASOLINERA,
    LOC_GASOLINERA,
    LOC_GASOLINERA,
    LOC_GASOLINERA,
    LOC_ELECTRONICA,
    LOC_ELECTRONICA,
    LOC_ELECTRONICA,
    LOC_ALQUILER,
    LOC_ALQUILER,
    LOC_ALQUILER,
    LOC_CONCESIONARIO,
    LOC_CONCESIONARIO,
    LOC_CONCESIONARIO,
    LOC_DISCO,
    LOC_DISCO,
    LOC_DISCO,
    LOC_TALLER,
    LOC_TALLER,
    LOC_TALLER,
    LOC_TALLER,
};

new const Float:LocPosXYZ[57][3] =
{
    {1481.2000, -1770.9000, 18.8000},
    {2319.5000, -89.6000, 26.5000},
    {-2243.9000, 128.7000, 35.3000},
    {1367.4000, 248.6000, 19.6000},
    {1352.1000, -1757.6000, 13.5000},
    {1928.4000, -1776.5000, 13.5000},
    {-78.9000, -1170.4000, 2.1000},
    {2472.3000, -1542.6000, 25.2000},
    {2226.8000, -1334.1000, 23.9000},
    {498.6000, -76.2000, 998.8000},
    {-2671.7000, 257.4000, 4.6000},
    {1836.2000, -1684.3000, 13.3000},
    {2105.4000, -1806.4000, 13.6000},
    {800.6000, -1630.3000, 13.9000},
    {-2335.2000, -166.2000, 35.6000},
    {1215.9000, -13.4000, 15.1000},
    {2229.9000, -1721.4000, 13.6000},
    {1968.2000, -1985.1000, 13.6000},
    {-2266.5000, -155.2000, 35.2000},
    {2074.2000, -1798.1000, 13.6000},
    {411.6000, -52.8000, 1001.9000},
    {-2760.1000, 375.6000, 6.2000},
    {2077.5000, -1789.4000, 13.6000},
    {-1904.6000, 280.7000, 41.1000},
    {1234.7000, -1013.6000, 15.2000},
    {2072.7000, -1793.2000, 13.6000},
    {461.1000, -1500.9000, 31.0000},
    {-2374.3000, -63.2000, 35.3000},
    {1457.4000, -1004.9000, 92.5000},
    {1139.2000, -4.2000, 1000.7000},
    {2016.8000, 1017.0000, 99.0000},
    {-2168.6000, 643.2000, 1052.4000},
    {2233.9000, 1281.4000, 10.8000},
    {2214.6000, 1291.3000, 10.8000},
    {-2731.5000, 71.6000, 4.3000},
    {1298.4000, -793.4000, 1084.0000},
    {1944.2000, -1773.6000, 13.6000},
    {1004.6000, -939.1000, 42.2000},
    {-91.7000, -1169.1000, 2.5000},
    {-2409.3000, 976.4000, 45.3000},
    {1596.6000, 2198.2000, 10.8000},
    {2166.3000, -1675.2000, 15.1000},
    {-2089.4000, 68.9000, 35.1000},
    {915.6000, -1236.4000, 16.2000},
    {1624.3000, -1896.1000, 13.5000},
    {-1962.5000, 293.6000, 35.2000},
    {2495.6000, -1690.4000, 13.5000},
    {2131.0000, -1150.0000, 24.0000},
    {-1974.1000, 278.4000, 35.2000},
    {557.3000, -1225.6000, 44.5000},
    {2518.6000, -1036.7000, 70.1000},
    {488.3000, -88.6000, 998.8000},
    {-2241.5000, 132.8000, 35.3000},
    {2074.1000, -1831.3000, 13.6000},
    {616.5000, -74.2000, 998.5000},
    {-1935.6000, 238.7000, 34.3000},
    {2644.2000, -2044.3000, 13.4000}
};

//------------------------------------------------------------------------------
//  INICIALIZACION
//------------------------------------------------------------------------------
stock AP_Local_Iniciar()
{
    new total = sizeof(LocPosTipo);
    if(total > MAX_LOCALES) total = MAX_LOCALES;
    TotalLocales = total;

    for(new i = 0; i < total; i++)
    {
        Locales[i][lTipo]  = LocPosTipo[i];
        Locales[i][lPrecio] = 0;
        Locales[i][lX]     = LocPosXYZ[i][0];
        Locales[i][lY]     = LocPosXYZ[i][1];
        Locales[i][lZ]     = LocPosXYZ[i][2];

        new tipo = Locales[i][lTipo];
        new etiqueta[96];
        format(etiqueta, sizeof(etiqueta), "{%06x}[%s]\n{FFFFFF}Usa {FFFF00}/local{FFFFFF} para ver el catalogo",
            (LocTipoColor[tipo] >>> 8) & 0xFFFFFF, LocTipoNombre[tipo]);

        Locales[i][lPickup] = CreatePickup(1239, 1, Locales[i][lX], Locales[i][lY], Locales[i][lZ], -1);
        Locales[i][lLabel]  = Create3DTextLabel(etiqueta, LocTipoColor[tipo],
            Locales[i][lX], Locales[i][lY], Locales[i][lZ] + 0.45, 15.0, 0, 1);
    }
    return total;
}

// Devuelve el indice del local mas cercano, o -1
stock AP_Local_Cercano(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < TotalLocales; i++)
    {
        if(AP_Distancia(x, y, z, Locales[i][lX], Locales[i][lY], Locales[i][lZ]) < 3.0)
            return i;
    }
    return -1;
}

//------------------------------------------------------------------------------
//  COMANDO PRINCIPAL
//------------------------------------------------------------------------------
CMD:local(playerid, params[])
{
    new idx = AP_Local_Cercano(playerid);
    if(idx == -1) return AP_Msg(playerid, C_ROJO, "[LOCAL]: No estas cerca de ningun establecimiento.");

    new tipo = Locales[idx][lTipo];
    Player[playerid][pDlg][0] = idx;
    Player[playerid][pDlg][4] = 0;

    // Algunos locales tienen una accion especial directa
    if(tipo == LOC_CASINO)
    {
        AP_Msg(playerid, C_VERDE, "[CASINO]: Bienvenido. Usa /casino para jugar.");
        return 1;
    }
    if(tipo == LOC_CONCESIONARIO)
    {
        AP_Msg(playerid, C_AMARILLO, "[CONCESIONARIO]: Usa /concesionario para ver los vehiculos a la venta.");
        return 1;
    }

    new lista[700], cabecera[80];
    format(cabecera, sizeof(cabecera), "{00FF00}%s", LocTipoNombre[tipo]);
    lista[0] = EOS;
    new n = 0;
    for(new i = 0; i < MAX_PRODS; i++)
    {
        if(Productos[i][prodTipo] != tipo) continue;
        if(n >= 10) break;
        format(szString, sizeof(szString), "{FFFFFF}%s\t{2ECC71}$%d\n", Productos[i][prodNombre], Productos[i][prodPrecio]);
        strcat(lista, szString, sizeof(lista));
        n++;
    }
    if(n == 0) format(lista, sizeof(lista), "{FF0000}Este local no tiene productos disponibles.");
    return ShowPlayerDialog(playerid, D_LOCAL, DIALOG_STYLE_TABLIST, cabecera, lista, "Comprar", "Salir");
}

//------------------------------------------------------------------------------
//  COMPRA
//------------------------------------------------------------------------------
stock AP_Local_Comprar(playerid, indice)
{
    new idx = Player[playerid][pDlg][0];
    if(idx < 0 || idx >= TotalLocales) return 1;
    new tipo = Locales[idx][lTipo];

    // Buscar el n-esimo producto de este tipo
    new contador = -1, encontrado = -1;
    for(new i = 0; i < MAX_PRODS; i++)
    {
        if(Productos[i][prodTipo] != tipo) continue;
        contador++;
        if(contador == indice) { encontrado = i; break; }
    }
    if(encontrado == -1) return 1;

    new precio = Productos[encontrado][prodPrecio];
    if(Player[playerid][pMoney] < precio)
        return AP_Msg(playerid, C_ROJO, "[LOCAL]: No tienes suficiente dinero.");

    AP_QuitarDinero(playerid, precio);
    AP_DarItem(playerid, Productos[encontrado][prodItem], Productos[encontrado][prodCant]);

    format(szString, sizeof(szString), "[LOCAL]: Compraste %s por $%d.",
        Productos[encontrado][prodNombre], precio);
    AP_Msg(playerid, C_VERDE, szString);

    // Efectos especiales por tipo de local
    AP_Local_Efecto(playerid, tipo, encontrado);
    AP_GuardarCuenta(playerid);
    return 1;
}

stock AP_Local_Efecto(playerid, tipo, producto)
{
    new nombre[26];
    format(nombre, sizeof(nombre), "%s", Productos[producto][prodNombre]);

    // Subida de habilidad
    if(Productos[producto][prodSkill] >= 0)
        AP_SubirSkill(playerid, Productos[producto][prodSkill], 1);

    switch(tipo)
    {
        case LOC_PELUQUERIA:
        {
            // Cambia la piel por una del mismo genero aproximado
            new nueva = Player[playerid][pSkin] + 1 + random(6);
            SetPlayerSkin(playerid, nueva);
            Player[playerid][pSkin] = nueva;
            AP_Msg(playerid, C_VERDE, "[PELUQUERIA]: Tu imagen ha sido renovada.");
        }
        case LOC_GIMNASIO:
        {
            new Float:vida;
            GetPlayerHealth(playerid, vida);
            if(vida < 100.0) SetPlayerHealth(playerid, vida + 10.0);
            ApplyAnimation(playerid, "GYMNASIUM", "gym_walk_fallback", 4.0, 0, 0, 0, 0, 0, 1);
            AP_Msg(playerid, C_VERDE, "[GIMNASIO]: Entrenamiento completado, te sientes mas fuerte.");
        }
        case LOC_HOTEL:
        {
            SetPlayerHealth(playerid, 100.0);
            Player[playerid][pHealth] = 100.0;
            AP_Msg(playerid, C_VERDE, "[HOTEL]: Descansaste, vida restaurada.");
        }
        case LOC_GASOLINERA:
        {
            if(IsPlayerInAnyVehicle(playerid))
            {
                Player[playerid][pGasolina] = 100.0;
                AP_Msg(playerid, C_VERDE, "[GASOLINERA]: Deposito lleno.");
            }
            else AP_Msg(playerid, C_AMARILLO, "[GASOLINERA]: Vuelve con un vehiculo para llenar el deposito.");
        }
        case LOC_TALLER:
        {
            if(IsPlayerInAnyVehicle(playerid))
            {
                new veh = GetPlayerVehicleID(playerid);
                SetVehicleHealth(veh, 1000.0);
                Player[playerid][pMotorDa] = false;
                AP_LogroConseguir(playerid, 7);
                AP_Msg(playerid, C_VERDE, "[TALLER]: Vehiculo reparado.");
            }
            else AP_Msg(playerid, C_AMARILLO, "[TALLER]: Sube a un vehiculo para repararlo.");
        }
        case LOC_TATUAJES:
        {
            AP_Msg(playerid, C_ROSADO, "[TATUAJES]: El tatuador termino su trabajo.");
        }
        case LOC_RESTAURANTE, LOC_BAR, LOC_SUPER:
        {
            if(Player[playerid][pHambre] < 100) Player[playerid][pHambre] += 20;
            if(Player[playerid][pSed] < 100) Player[playerid][pSed] += 20;
            if(Player[playerid][pHambre] > 100) Player[playerid][pHambre] = 100;
            if(Player[playerid][pSed] > 100) Player[playerid][pSed] = 100;
        }
        case LOC_ALQUILER:
        {
            AP_Msg(playerid, C_AMARILLO, "[ALQUILER]: El vehiculo estara disponible un rato. Disfruta.");
        }
        case LOC_DISCO:
        {
            ApplyAnimation(playerid, "DANCING", "dnce_M_a", 4.0, 1, 0, 0, 0, 0, 1);
            AP_Msg(playerid, C_ROSADO, "[DISCO]: La musica suena, a bailar.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------
//  DIALOGOS
//------------------------------------------------------------------------------
stock AP_Local_Dialog(playerid, dialogid, response, listitem, const inputtext[])
{
    #pragma unused inputtext
    switch(dialogid)
    {
        case D_LOCAL:
        {
            // pDlg[4] = 1 significa que es el listado informativo de admin
            if(!response || Player[playerid][pDlg][4] == 1) return 1;
            AP_Local_Comprar(playerid, listitem);
            return 1;
        }
    }
    return 0;
}

//------------------------------------------------------------------------------
//  LISTADO PARA ADMINISTRADORES
//------------------------------------------------------------------------------
CMD:locales(playerid, params[])
{
    REQ_ADMIN(ADM_MODERADOR)
    new lista[700], n = 0;
    lista[0] = EOS;
    for(new i = 0; i < TotalLocales && n < 40; i++)
    {
        format(szString, sizeof(szString), "%d\t%s\t%.1f, %.1f\n", i, LocTipoNombre[Locales[i][lTipo]], Locales[i][lX], Locales[i][lY]);
        strcat(lista, szString, sizeof(lista));
        n++;
    }
    Player[playerid][pDlg][4] = 1;
    return ShowPlayerDialog(playerid, D_LOCAL, DIALOG_STYLE_TABLIST, "{00FF00}LOCALES DEL SERVIDOR", lista, "Cerrar", "");
}
