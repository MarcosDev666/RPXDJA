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
