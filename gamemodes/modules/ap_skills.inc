//==============================================================================
//  SISTEMA DE OBJETOS (ITEMS) Y HABILIDADES (SKILLS)
//  Funciones compartidas por el inventario, los establecimientos y los trabajos.
//==============================================================================

// Nombres de las habilidades
new const SkillNombre[MAX_SKILLS][] =
{
    "Conduccion", "Pesca", "Punteria", "Fuerza",
    "Cocina", "Mecanica", "Negocios", "Sigilo"
};

//------------------------------------------------------------------------------
//  OBJETOS
//------------------------------------------------------------------------------

// Comprueba si el jugador tiene una cantidad de un objeto
stock AP_TieneItem(playerid, item, cantidad = 1)
{
    if(item < 0 || item >= MAX_ITEMS) return 0;
    return (Player[playerid][pItem][item] >= cantidad);
}

// Da objetos al jugador
stock AP_DarItem(playerid, item, cantidad = 1)
{
    if(item < 0 || item >= MAX_ITEMS) return 0;
    if(cantidad <= 0) return 0;
    Player[playerid][pItem][item] += cantidad;
    return 1;
}

// Quita objetos al jugador (devuelve 1 si pudo)
stock AP_QuitarItem(playerid, item, cantidad = 1)
{
    if(item < 0 || item >= MAX_ITEMS) return 0;
    if(Player[playerid][pItem][item] < cantidad) return 0;
    Player[playerid][pItem][item] -= cantidad;
    return 1;
}

// Cantidad actual de un objeto
stock AP_CantidadItem(playerid, item)
{
    if(item < 0 || item >= MAX_ITEMS) return 0;
    return Player[playerid][pItem][item];
}

//------------------------------------------------------------------------------
//  HABILIDADES
//------------------------------------------------------------------------------

// Sube una habilidad. Devuelve el nivel nuevo.
stock AP_SubirSkill(playerid, skill, cantidad = 1)
{
    if(skill < 0 || skill >= MAX_SKILLS) return 0;
    Player[playerid][pSkill][skill] += cantidad;
    if(Player[playerid][pSkill][skill] > 100) Player[playerid][pSkill][skill] = 100;

    // Aviso al subir de rango (cada 25 puntos)
    if(Player[playerid][pSkill][skill] % 25 == 0)
    {
        format(szString, sizeof(szString), "[HABILIDAD]: %s subio a nivel %d.",
            SkillNombre[skill], Player[playerid][pSkill][skill] / 25);
        AP_Msg(playerid, C_VERDE, szString);
    }
    return Player[playerid][pSkill][skill];
}

// Nivel de rango (0-4) de una habilidad
stock AP_SkillRango(playerid, skill)
{
    if(skill < 0 || skill >= MAX_SKILLS) return 0;
    new v = Player[playerid][pSkill][skill];
    if(v >= 100) return 4;
    if(v >= 75)  return 3;
    if(v >= 50)  return 2;
    if(v >= 25)  return 1;
    return 0;
}

stock AP_SkillRangoTexto(rango, destino[], maxlen)
{
    switch(rango)
    {
        case 4: format(destino, maxlen, "Maestro");
        case 3: format(destino, maxlen, "Experto");
        case 2: format(destino, maxlen, "Avanzado");
        case 1: format(destino, maxlen, "Aprendiz");
        default: format(destino, maxlen, "Novato");
    }
    return 1;
}

// Panel de habilidades
CMD:skills(playerid, params[])
{
    if(!Player[playerid][pOnline]) return AP_Msg(playerid, C_ROJO, "[SISTEMA]: Debes iniciar sesion.");
    new lista[700];
    lista[0] = EOS;
    for(new i = 0; i < MAX_SKILLS; i++)
    {
        new rango[16];
        AP_SkillRangoTexto(AP_SkillRango(playerid, i), rango, sizeof(rango));
        format(szString, sizeof(szString), "{FFFFFF}%s\t{2ECC71}%d/100\t{FFFF00}%s\n",
            SkillNombre[i], Player[playerid][pSkill][i], rango);
        strcat(lista, szString, sizeof(lista));
    }
    return ShowPlayerDialog(playerid, D_SKILLS, DIALOG_STYLE_TABLIST,
        "{00FF00}TUS HABILIDADES", lista, "Cerrar", "");
}
