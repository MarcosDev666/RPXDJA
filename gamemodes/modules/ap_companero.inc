//==============================================================================
//  SISTEMA DE COMPANERO IA
//  Novia, mejor amigo, guardaespaldas o mascota. Un actor (NPC) que acompana
//  al jugador, tiene animo, afinidad, nivel de relacion y conversacion.
//==============================================================================

// Tipos de companero

// Nombres por tipo de companero
new const CompNombreNovia[MAX_COMP_NOMBRES][] =
{
    "Valentina", "Camila", "Isabella", "Sofia", "Martina", "Lucia",
    "Emma", "Olivia", "Mia", "Abril", "Elena", "Daniela"
};
new const CompNombreAmigo[MAX_COMP_NOMBRES][] =
{
    "Mateo", "Lucas", "Santiago", "Nicolas", "Tomas", "Joaquin",
    "Bruno", "Diego", "Facundo", "Lautaro", "Simon", "Agustin"
};
new const CompNombreGuarda[MAX_COMP_NOMBRES][] =
{
    "Ramon", "Hector", "Victor", "Elias", "Roman", "Ivan",
    "Marcos", "Dario", "Ulises", "Geronimo", "Braian", "Kevin"
};
new const CompNombreMascota[MAX_COMP_NOMBRES][] =
{
    "Rocky", "Bobby", "Max", "Nina", "Luna", "Toby",
    "Kira", "Zeus", "Chispa", "Pelusa", "Duke", "Canela"
};

// Skins por tipo
new const CompSkinNovia[6] = { 56, 65, 93, 148, 169, 198 };
new const CompSkinAmigo[6] = { 20, 23, 25, 29, 46, 96 };
new const CompSkinGuarda[6] = { 46, 111, 122, 127, 169, 294 };
new const CompSkinMascota[6] = { 168, 188, 189, 190, 191, 223 };

// Frases de conversacion segun el animo
new const CompFraseFeliz[6][] =
{
    "Me encanta cuando pasamos tiempo juntos, en serio.",
    "Hoy me siento genial, ¿salimos a dar una vuelta?",
    "Eres lo mejor que me ha pasado en esta ciudad.",
    "¿Viste mi sonrisa? Es por ti, obvio.",
    "Podria quedarme hablando contigo toda la noche.",
    "Te ves muy bien hoy, ¿lo sabias?"
};
new const CompFraseNeutral[6][] =
{
    "Todo tranquilo por aca, ¿y tu que tal?",
    "Estaba pensando en salir a caminar un rato.",
    "¿Trabajaste mucho hoy? Se te nota cansado.",
    "A veces esta ciudad me parece enorme.",
    "¿Tienes planes para mas tarde?",
    "Me gusta cuando me cuentas tus cosas."
};
new const CompFraseTriste[6][] =
{
    "Ultimamente te veo poco... me haces falta.",
    "Creo que estamos dejando de hablar, ¿no?",
    "Solo queria que supiertas que estoy aqui.",
    "Me senti un poco sola estos dias.",
    "¿Te acuerdas cuando saliamos mas seguido?",
    "No estoy enojada, solo un poco triste."
};
new const CompFraseEnfadada[6][] =
{
    "¿En serio? No me gusta como me hablas.",
    "Necesito que me prestes mas atencion.",
    "Asi no vamos a llegar a ningun lado.",
    "Estoy molesta, pero todavia se puede arreglar.",
    "Piensa un poco en mi, no solo en ti.",
    "Hablamos cuando estes de mejor humor."
};
new const CompFraseCelosa[6][] =
{
    "¿Y esa con la que estabas hablando?",
    "No me digas que no la vi, te conozco.",
    "¿Yo ya no te parezco suficiente?",
    "Cuidado, que mi paciencia tambien se acaba.",
    "Si quieres andar con otras, dimelo claro.",
    "Me molesta que me escondas de la gente."
};

//------------------------------------------------------------------------------
//  TEXTOS AUXILIARES
//------------------------------------------------------------------------------
stock AP_Comp_Tiene(playerid) { return (Player[playerid][pCompTipo] != COMP_NADA); }

stock AP_Comp_NombreTipo(tipo)
{
    new t[24];
    switch(tipo)
    {
        case COMP_NOVIA:    format(t, sizeof(t), "Novia");
        case COMP_AMIGO:    format(t, sizeof(t), "Mejor amigo");
        case COMP_GUARDA:   format(t, sizeof(t), "Guardaespaldas");
        case COMP_MASCOTA:  format(t, sizeof(t), "Mascota");
        default:            format(t, sizeof(t), "Sin companero");
    }
    return t;
}

stock AP_Comp_MoodTexto(mood)
{
    new t[24];
    switch(mood)
    {
        case MOOD_FELIZ:    format(t, sizeof(t), "Feliz");
        case MOOD_NEUTRAL:  format(t, sizeof(t), "Neutral");
        case MOOD_TRISTE:   format(t, sizeof(t), "Triste");
        case MOOD_ENFADADA: format(t, sizeof(t), "Enfadada");
        case MOOD_CELOSA:   format(t, sizeof(t), "Celosa");
        default:            format(t, sizeof(t), "Neutral");
    }
    return t;
}

stock AP_Comp_RelTexto(nivel)
{
    new t[24];
    switch(nivel)
    {
        case REL_CONOCIDOS: format(t, sizeof(t), "Conocidos");
        case REL_AMIGOS:    format(t, sizeof(t), "Amistad");
        case REL_NOVIOS:    format(t, sizeof(t), "Novios");
        case REL_PAREJA:    format(t, sizeof(t), "Pareja");
        case REL_ALMAS:     format(t, sizeof(t), "Almas gemelas");
        default:            format(t, sizeof(t), "Conocidos");
    }
    return t;
}

stock AP_Comp_NombreActual(playerid, destino[], maxlen)
{
    new nom[24];
    switch(Player[playerid][pCompTipo])
    {
        case COMP_NOVIA:    format(nom, sizeof(nom), "%s", CompNombreNovia[Player[playerid][pCompNombre]]);
        case COMP_AMIGO:    format(nom, sizeof(nom), "%s", CompNombreAmigo[Player[playerid][pCompNombre]]);
        case COMP_GUARDA:   format(nom, sizeof(nom), "%s", CompNombreGuarda[Player[playerid][pCompNombre]]);
        case COMP_MASCOTA:  format(nom, sizeof(nom), "%s", CompNombreMascota[Player[playerid][pCompNombre]]);
        default:            format(nom, sizeof(nom), "Nadie");
    }
    format(destino, maxlen, "%s", nom);
    return 1;
}

//------------------------------------------------------------------------------
//  CREACION Y DESTRUCCION DEL ACTOR
//------------------------------------------------------------------------------
stock AP_Comp_SpawnActor(playerid)
{
    if(Player[playerid][pCompActor] != INVALID_ACTOR_ID && IsValidActor(Player[playerid][pCompActor]))
        DestroyActor(Player[playerid][pCompActor]);

    new skin = 0;
    switch(Player[playerid][pCompTipo])
    {
        case COMP_NOVIA:    skin = CompSkinNovia[Player[playerid][pCompNombre] % 6];
        case COMP_AMIGO:    skin = CompSkinAmigo[Player[playerid][pCompNombre] % 6];
        case COMP_GUARDA:   skin = CompSkinGuarda[Player[playerid][pCompNombre] % 6];
        case COMP_MASCOTA:  skin = CompSkinMascota[Player[playerid][pCompNombre] % 6];
    }
    if(skin == 0) return 0;

    new Float:x, Float:y, Float:z, Float:a;
    if(IsPlayerConnected(playerid))
    {
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
    }
    else { x = 0.0; y = 0.0; z = 0.0; a = 0.0; }

    new actorid = CreateActor(skin, x + 1.5, y + 1.5, z, a);
    if(actorid == INVALID_ACTOR_ID) return 0;

    Player[playerid][pCompActor] = actorid;
    Player[playerid][pCompEstado] = CEST_ACTIVO;
    if(IsPlayerConnected(playerid)) SetActorVirtualWorld(actorid, GetPlayerVirtualWorld(playerid));
    return 1;
}

stock AP_Comp_Destruir(playerid)
{
    if(Player[playerid][pCompActor] != INVALID_ACTOR_ID && IsValidActor(Player[playerid][pCompActor]))
        DestroyActor(Player[playerid][pCompActor]);
    Player[playerid][pCompActor] = INVALID_ACTOR_ID;
    Player[playerid][pCompEstado] = CEST_INACTIVO;
    Player[playerid][pCompTipo] = COMP_NADA;
    Player[playerid][pCompAfin] = 0;
    Player[playerid][pCompMood] = MOOD_NEUTRAL;
    Player[playerid][pCompNivel] = REL_CONOCIDOS;
    Player[playerid][pCompCitas] = 0;
    return 1;
}

// Recoloca el actor junto al jugador si se aleja mucho
stock AP_Comp_Seguir(playerid)
{
    new actorid = Player[playerid][pCompActor];
    if(actorid == INVALID_ACTOR_ID || !IsValidActor(actorid)) return 0;
    if(!IsPlayerConnected(playerid) || !Player[playerid][pOnline]) return 0;
    if(Player[playerid][pCompEstado] != CEST_ACTIVO) return 0;
    if(!IsPlayerInAnyVehicle(playerid)) return 0;

    new Float:px, Float:py, Float:pz, Float:ax, Float:ay, Float:az;
    GetPlayerPos(playerid, px, py, pz);
    GetActorPos(actorid, ax, ay, az);
    if(AP_Distancia(px, py, pz, ax, ay, az) > COMP_SEGUIMIENTO)
    {
        new Float:ang;
        GetPlayerFacingAngle(playerid, ang);
        SetActorPos(actorid, px + (1.6 * floatsin(-ang, degrees)), py + (1.6 * floatcos(-ang, degrees)), pz);
        SetActorVirtualWorld(actorid, GetPlayerVirtualWorld(playerid));
    }
    return 1;
}

//------------------------------------------------------------------------------
//  AFINIDAD Y ANIMO
//------------------------------------------------------------------------------
stock AP_Comp_SumarAfin(playerid, cantidad)
{
    if(!AP_Comp_Tiene(playerid)) return 0;
    Player[playerid][pCompAfin] += cantidad;
    if(Player[playerid][pCompAfin] > 100) Player[playerid][pCompAfin] = 100;
    if(Player[playerid][pCompAfin] < 0)   Player[playerid][pCompAfin] = 0;

    // Subida de nivel de relacion
    new nivel = Player[playerid][pCompNivel];
    if(Player[playerid][pCompAfin] >= 90 && nivel < REL_ALMAS)        Player[playerid][pCompNivel] = REL_ALMAS;
    else if(Player[playerid][pCompAfin] >= 70 && nivel < REL_PAREJA)  Player[playerid][pCompNivel] = REL_PAREJA;
    else if(Player[playerid][pCompAfin] >= 45 && nivel < REL_NOVIOS)  Player[playerid][pCompNivel] = REL_NOVIOS;
    else if(Player[playerid][pCompAfin] >= 20 && nivel < REL_AMIGOS)  Player[playerid][pCompNivel] = REL_AMIGOS;
    return 1;
}

stock AP_Comp_Frase(playerid, destino[], maxlen)
{
    new idx = random(6), frase[128];
    switch(Player[playerid][pCompMood])
    {
        case MOOD_FELIZ:    format(frase, sizeof(frase), "%s", CompFraseFeliz[idx]);
        case MOOD_TRISTE:   format(frase, sizeof(frase), "%s", CompFraseTriste[idx]);
        case MOOD_ENFADADA: format(frase, sizeof(frase), "%s", CompFraseEnfadada[idx]);
        case MOOD_CELOSA:   format(frase, sizeof(frase), "%s", CompFraseCelosa[idx]);
        default:            format(frase, sizeof(frase), "%s", CompFraseNeutral[idx]);
    }
    format(destino, maxlen, "%s", frase);
    return 1;
}

//------------------------------------------------------------------------------
//  INTERACCIONES
//------------------------------------------------------------------------------
CMD:companero(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid))
        return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero. Usa /novia para conseguir uno.");

    new nom[24], txt[400];
    AP_Comp_NombreActual(playerid, nom, sizeof(nom));
    format(txt, sizeof(txt),
        "{FFFFFF}Tu companero: {00FF00}%s{FFFFFF} (%s)\n\n{FFFFFF}Afinidad: {FFD700}%d/100\n{FFFFFF}Relacion: {FF69B4}%s\n{FFFFFF}Animo: {00FFFF}%s\n{FFFFFF}Citas: {FFFF00}%d\n\n{AAAAAA}Usa /hablar, /regalar, /cita, /paseo o /romper",
        nom, AP_Comp_NombreTipo(Player[playerid][pCompTipo]), Player[playerid][pCompAfin],
        AP_Comp_RelTexto(Player[playerid][pCompNivel]), AP_Comp_MoodTexto(Player[playerid][pCompMood]),
        Player[playerid][pCompCitas]);
    return ShowPlayerDialog(playerid, D_COMP_PANEL, DIALOG_STYLE_MSGBOX,
        "{00FF00}PANEL DE COMPANERO", txt, "Cerrar", "");
}

CMD:novia(playerid, params[])
{
    if(AP_Comp_Tiene(playerid))
    {
        new nom[24];
        AP_Comp_NombreActual(playerid, nom, sizeof(nom));
        format(szString, sizeof(szString), "[COMPANERO]: Ya tienes companero: %s. Usa /romper para terminar la relacion.", nom);
        return AP_Msg(playerid, C_AMARILLO, szString);
    }
    new lista[256];
    format(lista, sizeof(lista),
        "{FFFFFF}Elige el tipo de companero que quieres:\n\n{FF69B4}Novia{FFFFFF} - Te acompana, conversa y tiene citas contigo\n{00BFFF}Mejor amigo{FFFFFF} - Te apoya y sube el animo\n{FF0000}Guardaespaldas{FFFFFF} - Te defiende de los ataques\n{FFFF00}Mascota{FFFFFF} - Te sigue a todos lados\n\n{2ECC71}Precio: $%d", COMP_PRECIO);
    return ShowPlayerDialog(playerid, D_COMP_NOMBRE, DIALOG_STYLE_LIST,
        "{00FF00}AGENCIA DE ACOMPANANTES", lista, "Elegir", "Salir");
}

CMD:hablar(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero.");
    if(!IsPlayerConnected(playerid)) return 0;

    new nom[24], frase[128];
    AP_Comp_NombreActual(playerid, nom, sizeof(nom));
    AP_Comp_Frase(playerid, frase, sizeof(frase));

    ApplyAnimation(playerid, "PED", "IDLE_chat", 4.0, 0, 0, 0, 0, 0, 1);
    if(Player[playerid][pCompActor] != INVALID_ACTOR_ID && IsValidActor(Player[playerid][pCompActor]))
        ApplyActorAnimation(Player[playerid][pCompActor], "PED", "IDLE_chat", 4.0, 1, 0, 0, 0, 0);

    format(szString, sizeof(szString), "[%s]: %s", nom, frase);
    AP_Msg(playerid, C_ROSADO, szString);
    AP_Comp_SumarAfin(playerid, 2);
    Player[playerid][pCompTiempo] = 0;

    // Hablar mejora el animo si estaba triste o enfadada
    if(Player[playerid][pCompMood] == MOOD_TRISTE || Player[playerid][pCompMood] == MOOD_ENFADADA)
    {
        if(random(3) == 0)
        {
            Player[playerid][pCompMood] = MOOD_NEUTRAL;
            AP_Msg(playerid, C_VERDE, "[COMPANERO]: Gracias por escucharme, me siento mejor.");
        }
    }
    return 1;
}

CMD:regalar(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero.");
    new itemstr[12], idx = 0;
    if(!AP_Token(params, idx, itemstr, sizeof(itemstr))) return AP_Msg(playerid, C_ROJO, "Uso: /regalar [id de item]");

    new item = strval(itemstr);
    if(item < 0 || item >= MAX_ITEMS) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: Item invalido.");
    if(Player[playerid][pItem][item] <= 0) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes ese item.");

    Player[playerid][pItem][item]--;
    AP_Comp_SumarAfin(playerid, 8);
    Player[playerid][pCompRegalo] = item;
    if(Player[playerid][pCompMood] != MOOD_FELIZ) Player[playerid][pCompMood] = MOOD_FELIZ;

    new nom[24];
    AP_Comp_NombreActual(playerid, nom, sizeof(nom));
    format(szString, sizeof(szString), "[COMPANERO]: Le diste %s a %s. ¡Le encanto!", NombreItem[item], nom);
    AP_Msg(playerid, C_VERDE, szString);
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:cita(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero.");
    if(Player[playerid][pCompAfin] < 30) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: Todavia no hay suficiente confianza (minimo 30 de afinidad).");
    if(Player[playerid][pCompCitas] >= 5)
        return AP_Msg(playerid, C_ROJO, "[COMPANERO]: Hoy ya tuvimos demasiadas citas, descansa un poco.");

    Player[playerid][pCompCitas]++;
    AP_Comp_SumarAfin(playerid, 12);
    Player[playerid][pCompMood] = MOOD_FELIZ;
    Player[playerid][pCompTiempo] = 0;

    new nom[24];
    AP_Comp_NombreActual(playerid, nom, sizeof(nom));
    format(szString, sizeof(szString), "[COMPANERO]: %s acepto tu cita. Pasean juntos por la ciudad (+12 afinidad).", nom);
    AP_Msg(playerid, C_ROSADO, szString);

    if(Player[playerid][pCompActor] != INVALID_ACTOR_ID && IsValidActor(Player[playerid][pCompActor]))
    {
        ApplyActorAnimation(Player[playerid][pCompActor], "PED", "WALK_civi", 4.0, 1, 0, 0, 0, 0);
        AP_Comp_Seguir(playerid);
    }
    AP_GuardarCuenta(playerid);
    return 1;
}

CMD:paseo(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero.");
    if(Player[playerid][pCompActor] == INVALID_ACTOR_ID || !IsValidActor(Player[playerid][pCompActor]))
        AP_Comp_SpawnActor(playerid);
    if(Player[playerid][pCompActor] == INVALID_ACTOR_ID) return 0;

    Player[playerid][pCompEstado] = CEST_ACTIVO;
    ApplyActorAnimation(Player[playerid][pCompActor], "PED", "WALK_civi", 4.0, 1, 0, 0, 0, 0);
    AP_Msg(playerid, C_VERDE, "[COMPANERO]: Tu companero te acompana a donde vayas.");
    return 1;
}

CMD:romper(playerid, params[])
{
    if(!AP_Comp_Tiene(playerid)) return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes companero.");
    new nom[24];
    AP_Comp_NombreActual(playerid, nom, sizeof(nom));
    format(szString, sizeof(szString), "[COMPANERO]: Terminaste la relacion con %s. Se fue sin decir nada.", nom);
    AP_Msg(playerid, C_ROJO, szString);
    AP_Comp_Destruir(playerid);
    AP_GuardarCuenta(playerid);
    return 1;
}

//------------------------------------------------------------------------------
//  IA: se ejecuta cada pocos segundos desde el temporizador global
//------------------------------------------------------------------------------
stock AP_Comp_IA(playerid)
{
    if(!AP_Comp_Tiene(playerid)) return 0;
    if(!IsPlayerConnected(playerid) || !Player[playerid][pOnline]) return 0;
    if(Player[playerid][pCompEstado] == CEST_INACTIVO) return 0;

    // Si el actor se perdio, lo recreamos
    if(Player[playerid][pCompActor] == INVALID_ACTOR_ID || !IsValidActor(Player[playerid][pCompActor]))
        AP_Comp_SpawnActor(playerid);
    else
        AP_Comp_Seguir(playerid);

    // La afinidad baja con el tiempo sin interactuar
    Player[playerid][pCompTiempo]++;
    if(Player[playerid][pCompTiempo] > 300)
    {
        if(random(120) == 0)
        {
            AP_Comp_SumarAfin(playerid, -3);
            Player[playerid][pCompTiempo] = 0;
            if(Player[playerid][pCompMood] == MOOD_FELIZ) Player[playerid][pCompMood] = MOOD_NEUTRAL;
            else if(Player[playerid][pCompMood] == MOOD_NEUTRAL) Player[playerid][pCompMood] = MOOD_TRISTE;
        }
    }

    // Reacciones puntuales
    if(Player[playerid][pCompAfin] < 15 && Player[playerid][pCompMood] != MOOD_ENFADADA && random(200) == 0)
    {
        Player[playerid][pCompMood] = MOOD_ENFADADA;
        AP_Msg(playerid, C_ROJO, "[COMPANERO]: Estoy harta de que me ignores. Hablame o me voy.");
    }
    return 1;
}

// Limpieza al desconectar
stock AP_Comp_AlDesconectar(playerid)
{
    if(Player[playerid][pCompActor] != INVALID_ACTOR_ID && IsValidActor(Player[playerid][pCompActor]))
        DestroyActor(Player[playerid][pCompActor]);
    Player[playerid][pCompActor] = INVALID_ACTOR_ID;
    Player[playerid][pCompEstado] = CEST_INACTIVO;
    return 1;
}

//------------------------------------------------------------------------------
//  RESPUESTA AL DIALOGO DE ELECCION DE COMPANERO
//------------------------------------------------------------------------------
stock AP_Comp_Dialog(playerid, dialogid, response, listitem, const inputtext[])
{
    #pragma unused inputtext
    if(dialogid == D_COMP_NOMBRE)
    {
        if(!response) return 1;
        if(Player[playerid][pMoney] < COMP_PRECIO)
            return AP_Msg(playerid, C_ROJO, "[COMPANERO]: No tienes suficiente dinero.");

        AP_QuitarDinero(playerid, COMP_PRECIO);
        switch(listitem)
        {
            case 0: Player[playerid][pCompTipo] = COMP_NOVIA;
            case 1: Player[playerid][pCompTipo] = COMP_AMIGO;
            case 2: Player[playerid][pCompTipo] = COMP_GUARDA;
            case 3: Player[playerid][pCompTipo] = COMP_MASCOTA;
            default: Player[playerid][pCompTipo] = COMP_NOVIA;
        }
        Player[playerid][pCompNombre] = random(MAX_COMP_NOMBRES);
        Player[playerid][pCompAfin] = 20;
        Player[playerid][pCompNivel] = REL_CONOCIDOS;
        Player[playerid][pCompMood] = MOOD_NEUTRAL;
        Player[playerid][pCompCitas] = 0;
        Player[playerid][pCompTiempo] = 0;
        Player[playerid][pCompActor] = INVALID_ACTOR_ID;
        AP_Comp_SpawnActor(playerid);

        new nom[24];
        AP_Comp_NombreActual(playerid, nom, sizeof(nom));
        format(szString, sizeof(szString),
            "[COMPANERO]: Contrataste a %s (%s) por $%d. Usa /hablar para empezar a conocerla.",
            nom, AP_Comp_NombreTipo(Player[playerid][pCompTipo]), COMP_PRECIO);
        AP_Msg(playerid, C_VERDE, szString);
        AP_GuardarCuenta(playerid);
        return 1;
    }
    return 0;
}
