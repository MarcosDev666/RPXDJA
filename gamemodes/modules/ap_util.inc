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

//------------------------------------------------------------------------------
//  SISTEMA DE NOMBRES
//  Se acepta CUALQUIER nombre de jugador de SA-MP. Lo unico que se hace es
//  comprobar si sigue la convencion de rol Nombre_Apellido para mostrar un
//  aviso informativo (nunca se expulsa a nadie por su nombre).
//  Si en el futuro quieres volver a exigir el formato, pon NOMBRE_LIBRE en 0.
//------------------------------------------------------------------------------

// Indica si el nombre sigue la convencion de rol (solo informativo)
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

// Deja el nombre listo para usarlo como nombre de archivo, sustituyendo por
// '_' cualquier caracter que Windows no admita en un nombre de fichero.
// Asi cualquier nombre de SA-MP puede guardar su cuenta.
stock AP_NombreLimpio(const nombre[], destino[], maxlen)
{
    new len = strlen(nombre);
    if(len > maxlen - 1) len = maxlen - 1;
    for(new i = 0; i < len; i++)
    {
        new c = nombre[i];
        if((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
           c == '_' || c == '-' || c == '.' || c == '@' || c == '[' || c == ']' || c == '$')
        {
            destino[i] = c;
        }
        else destino[i] = '_';
    }
    destino[len] = EOS;
    if(destino[0] == EOS) format(destino, maxlen, "Jugador");
    return 1;
}

// Ruta del .ini de la cuenta a partir de un nombre escrito a mano
// (lo usan /desban y /borrarcuenta)
stock AP_NombreRuta(const nombre[], destino[], maxlen)
{
    new limpio[32];
    AP_NombreLimpio(nombre, limpio, sizeof(limpio));
    format(destino, maxlen, "Cuentas/%s.ini", limpio);
    return 1;
}

// Ruta del .ini de la cuenta de un jugador conectado
stock AP_NombreArchivo(playerid, destino[], maxlen)
{
    new nombre[MAX_PLAYER_NAME], limpio[32];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    AP_NombreLimpio(nombre, limpio, sizeof(limpio));
    format(destino, maxlen, "Cuentas/%s.ini", limpio);
    return 1;
}

// Ruta del .ini de administrador de un jugador conectado
stock AP_NombreAdminArchivo(playerid, destino[], maxlen)
{
    new nombre[MAX_PLAYER_NAME], limpio[32];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    AP_NombreLimpio(nombre, limpio, sizeof(limpio));
    format(destino, maxlen, "Administradores/%s.ini", limpio);
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
