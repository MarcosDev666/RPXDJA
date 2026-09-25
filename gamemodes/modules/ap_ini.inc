//  MOTOR INI PROPIO (sin plugins externos)
//  Todos los datos se guardan en scriptfiles/...
//==============================================================================
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

//------------------------------------------------------------------------------
//  ESCRITURA POR LOTES
//  Acumula todas las claves en memoria y escribe el archivo UNA sola vez.
//  Es mucho mas rapido que llamar a AP_Ini_Escribir por cada clave (que
//  reescribia el archivo completo en cada llamada).
//------------------------------------------------------------------------------
#define MAX_CLAVES        180

new Ini_LoteClave[MAX_CLAVES][40];
new Ini_LoteValor[MAX_CLAVES][64];
new Ini_LoteTotal = 0;

// Empieza un lote nuevo para un archivo
stock AP_Ini_LoteInicio()
{
    Ini_LoteTotal = 0;
    return 1;
}

// Anade (o reemplaza) una clave al lote en memoria
stock AP_Ini_LoteSet(const clave[], const valor[])
{
    for(new i = 0; i < Ini_LoteTotal; i++)
    {
        if(strcmp(Ini_LoteClave[i], clave) == 0)
        {
            format(Ini_LoteValor[i], 64, "%s", valor);
            return 1;
        }
    }
    if(Ini_LoteTotal >= MAX_CLAVES) return 0;
    format(Ini_LoteClave[Ini_LoteTotal], 40, "%s", clave);
    format(Ini_LoteValor[Ini_LoteTotal], 64, "%s", valor);
    Ini_LoteTotal++;
    return 1;
}

stock AP_Ini_LoteInt(const clave[], valor)
{
    new v[24];
    format(v, sizeof(v), "%d", valor);
    return AP_Ini_LoteSet(clave, v);
}

stock AP_Ini_LoteFloat(const clave[], Float:valor)
{
    new v[40];
    format(v, sizeof(v), "%.4f", valor);
    return AP_Ini_LoteSet(clave, v);
}

// Escribe el lote completo al archivo (una sola apertura)
stock AP_Ini_LoteFin(const archivo[])
{
    if(Ini_LoteTotal <= 0) return 0;
    new File:w = fopen(archivo, io_write);
    if(!w) return 0;
    for(new i = 0; i < Ini_LoteTotal; i++)
    {
        new linea[128];
        format(linea, sizeof(linea), "%s = %s", Ini_LoteClave[i], Ini_LoteValor[i]);
        AP_EscribirLinea(w, linea);
    }
    fclose(w);
    Ini_LoteTotal = 0;
    return 1;
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
