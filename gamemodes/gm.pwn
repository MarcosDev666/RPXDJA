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

        * 105 SISTEMAS completos y funcionales
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
            --- NUEVOS SISTEMAS ---
            37 COMPANERO IA: novia con animo, afinidad y nivel de relacion
            38 COMPANERO IA: conversacion con frases segun el animo
            39 COMPANERO IA: regalos que suben la afinidad
            40 COMPANERO IA: citas y paseos
            41 COMPANERO IA: relacion por niveles (conocidos a almas gemelas)
            42 COMPANERO IA: celos, enfado y tristeza si lo ignoras
            43 COMPANERO IA: tipos novia / amigo / guardaespaldas / mascota
            44 ESTABLECIMIENTOS: farmacias
            45 ESTABLECIMIENTOS: supermercados
            46 ESTABLECIMIENTOS: bares
            47 ESTABLECIMIENTOS: restaurantes
            48 ESTABLECIMIENTOS: gimnasios (suben fuerza)
            49 ESTABLECIMIENTOS: peluquerias (cambio de imagen)
            50 ESTABLECIMIENTOS: estudios de tatuajes
            51 ESTABLECIMIENTOS: tiendas de ropa
            52 ESTABLECIMIENTOS: casinos
            53 ESTABLECIMIENTOS: hoteles (descanso y curacion)
            54 ESTABLECIMIENTOS: gasolineras (repostaje)
            55 ESTABLECIMIENTOS: tiendas de electronica
            56 ESTABLECIMIENTOS: alquiler de vehiculos
            57 ESTABLECIMIENTOS: concesionarios
            58 ESTABLECIMIENTOS: discotecas (baile y copas)
            59 ESTABLECIMIENTOS: talleres (reparacion y tuneo)
            60 CATALOGO de productos data-driven (74 productos)
            61 HABILIDADES: 8 skills con niveles y rangos
            62 CASINO: tragamonedas con simbolos y premios
            63 CASINO: dados contra la casa
            64 CASINO: ruleta (rojo / negro / numero)
            65 CASINO: blackjack simplificado
            66 CASINO: sistema de fichas (comprar y cambiar)
            67 MECANICA: deposito de gasolina y consumo
            68 MECANICA: averia del motor sin combustible
            69 MECANICA: kilometraje del jugador
            70 MISIONES: 8 misiones encadenadas con recompensa
            71 LOGROS: 10 logros conseguibles con XP
            72 RECOMPENSA DIARIA con racha de dias
            73 MATRIMONIO: propuesta, boda y divorcio
            74 MATRIMONIO: anillos de boda
            75 BANCA: prestamos con interes
            76 BANCA: pago de deudas
            77 BOLSA: compra y venta de acciones
            78 BOLSA: precio fluctuante de la accion
            79 SEGUROS: 3 planes para vehiculos
            80 RADARES: multa automatica por exceso de velocidad
            81 PEAIES: pago de peaje
            82 HAMBRE Y SED al comer y beber en locales
            83 SISTEMA DE OBJETOS compartido (dar / quitar / comprobar)
            84 ARQUITECTURA MODULAR (19 archivos .inc)

        * SISTEMA DE ADMINISTRACION POR NIVELES
             Nivel 1  Ayudante         - atiende dudas y reportes
             Nivel 2  Moderador        - kick, mute, slap, congelar, jail
             Nivel 3  Administrador    - ban, veh, skin, armas, dinero
             Nivel 4  Super Admin      - nivel, xp, hora, clima, anuncios
             Nivel 5  Director         - vip, coins, hacer admin, economia
             Nivel 6  Dueno            - control total del servidor

        * 155 COMANDOS FUNCIONALES

        NOTAS TECNICAS
        --------------
        * El guardado de datos usa un motor INI propio (nativo de Pawn), por lo
          que NO depende de ningun plugin externo: todo funciona con el servidor
          limpio. Los archivos se guardan en scriptfiles/Cuentas/<TuNombre>.ini
        * Texto 100% ASCII (sin acentos) para evitar problemas de codificacion.
        * SISTEMA DE NOMBRES: se acepta CUALQUIER nombre de jugador de SA-MP,
          no hace falta usar el formato Nombre_Apellido (ni se expulsa a nadie
          por su nombre). El nombre se sanea automaticamente para poder usarlo
          como archivo .ini. Si algun dia quieres exigir el formato de rol,
          cambia NOMBRE_LIBRE a 0.

================================================================================*/

#include <a_samp>
#include <streamer>
#include <zcmd>
#include <zones>

// Tamano de la pila/memoria dinamica (necesario por los buffers de guardado)
#pragma dynamic 65536

//==============================================================================
//  MODULOS DEL GAMEMODE  (arquitectura modular)
//  Cada sistema vive en su propio archivo dentro de gamemodes/modules/.
//  El orden de inclusion es el de dependencias: los modulos solo usan
//  lo definido en los modulos anteriores.
//==============================================================================
#include "./modules/ap_config.inc"   // Configuracion del servidor, macros y colores
#include "./modules/ap_datos.inc"   // Enumeraciones, variables globales y forwards
#include "./modules/ap_ini.inc"   // Motor INI propio (guardado .ini sin plugins)
#include "./modules/ap_util.inc"   // Utilidades, validaciones, mensajes y logs
#include "./modules/ap_tablas.inc"   // Tablas de datos: trabajos, casas, items, facciones...
#include "./modules/ap_skills.inc"   // Objetos (items) y habilidades (skills)
#include "./modules/ap_hud.inc"   // HUD, textdraws y mapa GPS
#include "./modules/ap_cuentas.inc"   // Reset, guardado, carga y aplicacion de datos
#include "./modules/ap_trabajos.inc"   // Sistema de trabajos
#include "./modules/ap_propiedades.inc"   // Casas y vehiculos personales
#include "./modules/ap_negocios.inc"   // Negocios, tiendas, armeria, banco y stats
#include "./modules/ap_telefono.inc"   // Telefono movil e inventario
#include "./modules/ap_facciones.inc"   // Facciones, policia, animaciones y VIP
#include "./modules/ap_companero.inc"   // Sistema de companero IA (novia, amigo, guardaespaldas, mascota)
#include "./modules/ap_establecimientos.inc"   // Farmacias, bares, gimnasios, concesionarios, hoteles...
#include "./modules/ap_extra.inc"   // Casino, habilidades, combustible, misiones, logros...
#include "./modules/ap_admin.inc"   // Sistema de administracion por niveles
#include "./modules/ap_comandos.inc"   // Comandos generales del jugador
#include "./modules/ap_callbacks.inc"   // Callbacks de SA-MP, temporizadores y dialogos

//  MODULO DE COMANDOS PERSONALES DE ROL
//==============================================================================
#include "./modules/p.cmd.inc"
