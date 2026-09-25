/*================================================================================

    MODULO DE COMANDOS PERSONALES (ROL)
    AltaPrevia Roleplay

    Este archivo se incluye al final de gamemodes/gm.pwn y contiene los comandos
    que el jugador usa sobre su propio personaje (acciones de rol basicas).

    Comandos incluidos:
        /desmayarse  - El personaje cae herido durante 10 segundos.
        /rendirse    - El personaje se entrega (manos en alto).
        /dormir      - El personaje se tumba a descansar.
        /cachearse   - El personaje se cachea a si mismo (rol de cacheo).
        /estado      - Muestra el estado fisico del personaje.

================================================================================*/

CMD:desmayarse(playerid)
{
    if(Player[playerid][pDead]) return AP_Msg(playerid, C_ROJO, "[ROL]: Ya estas herido.");
    if(Player[playerid][pJail]) return AP_Msg(playerid, C_ROJO, "[ROL]: Estas en prision.");

    Player[playerid][pDead] = true;
    SetPlayerHealth(playerid, 40.0);
    Player[playerid][pHealth] = 40.0;
    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "PED", "KO_skid_back", 4.0, 0, 0, 0, 1, 0, 1);
    AP_MostrarMensaje(playerid, "Te has desmayado. Espera a recuperarte.", 6);
    SetTimerEx("AP_Reaparecer", 10000, false, "i", playerid);
    AP_Log("Rol", "Uso de /desmayarse.");
    return 1;
}

CMD:rendirse(playerid)
{
    if(Player[playerid][pEsposado]) return AP_Msg(playerid, C_ROJO, "[ROL]: Ya estas esposado.");
    ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0, 1);
    AP_MensajeCercano(playerid, 20.0, C_ROSA, "* El sujeto levanta las manos y se entrega.");
    AP_MostrarMensaje(playerid, "Te has rendido. Usa /pararanim para bajar las manos.", 5);
    return 1;
}

CMD:dormir(playerid)
{
    ApplyAnimation(playerid, "CRACK", "crckidle4", 4.0, 1, 0, 0, 0, 0, 1);
    AP_MensajeCercano(playerid, 15.0, C_ROSA, "* La persona se tumba en el suelo a descansar.");
    return 1;
}

CMD:cachearse(playerid)
{
    new tiene = 0;
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(Player[playerid][pItem][i] > 0) tiene += Player[playerid][pItem][i];
    }
    new armas = 0;
    for(new i = 0; i < 13; i++)
    {
        if(Player[playerid][pArma][i] > 0 && Player[playerid][pMunicion][i] > 0) armas++;
    }
    format(szString, sizeof(szString), "[CACHEO]: Llevas %d objetos y %d armas encima.", tiene, armas);
    AP_Msg(playerid, C_AZUL, szString);
    ApplyAnimation(playerid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
    return 1;
}

CMD:estado(playerid)
{
    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, chaleco);
    format(szString, sizeof(szString), "[ESTADO] Salud: %.0f | Chaleco: %.0f | Hambre: %d | Sed: %d | Nivel de busqueda: %d",
        vida, chaleco, Player[playerid][pHambre], Player[playerid][pSed], Player[playerid][pWanted]);
    AP_Msg(playerid, C_AZUL, szString);
    if(Player[playerid][pHambre] < 30) AP_Msg(playerid, C_ROJO, "Tienes mucha hambre, ve a un 24/7 (/tienda).");
    if(Player[playerid][pSed] < 30) AP_Msg(playerid, C_ROJO, "Tienes mucha sed, ve a un 24/7 (/tienda).");
    return 1;
}
