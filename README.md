# Fugados-Roleplay
Vengo a liberar ya una versión más "oficial" de la gamemode, realmente hago esto ya qué mucha gente vende este gm sin mucho sentido ya qué hay varias sueltas pero traern virus, cosas mediocres o realmente no se puede usar ya qué contienen archivos malos...

**EXTRA: Si buscas una GAMEMODE más actualizada, con sistema de niveles y demás cosa; puedes contactarme al privado: BritishMay#2051**

**INFO/CREDITOS: Yo no hice la GAMEMODE, NO LA CREÉ; sólo me ENCARGUÉ de hacerla funcionar con sus versiones (las updates también) excepto la de evolution**

# DOCUMENTACIÓN:
***
Me tomé el tiempo de fixear una supuesta "versión" liberada hace poco pero tenía varios bugs, faltaban includes; cuya persona qué se hace llamar programador.

Vamos por partes; la carpeta **GAMEMODE** tiene el "roleplay.com" qué es una versión de la gamemode original con updates básicos, todo eso no fue hecho por mi.

1.2: La carpeta **fugados-roleplay-main** contiene un .pwn con otra gamemode y tiene todos sus includes funcionando, ya compila sin ningún problema ya qué le agrege todos los includes necesarios y cambié plugins viejos.

## INSTALACIÓN

1.3: Deberás de cambiar lo qué dice "gamemode0" por el nombre de la versión que quieras usar, está por defecto la de "roleplay" pero puedes cambiarla a la otra versión de "fugadosrp".

1.4: Para cambiar la versión sql de ambas deberás cambiar los archivos con el siguiente formato:

Configuración (.pwn de cada gamemode):
```
#define	sql_host "localhost" // HOST SQL
#define	sql_user "root" // Usuario
#define	sql_password "" // contraseña
#define	sql_database "fugados" // nombre de la db
```

1.5: ¿Cómo me doy administrador? fácil, deberás buscar la variable: `"JotoOtaku", InfoCuenta[playerid][jAdmin]);` o sólo `"JotoOtaku"` en el phpmyadmin en la parte de cuentas, colocas "10" y lo mismo para EncFac (sólo deberás poner valor 1, 0 es para quitar).

## BUGS/DATOS

1.6: La gamemode no contiene bugs graves, realmente dandole una mano a todo se puede fixear muy rápido; les recomiendo chequear todos los comandos, probar el sistema de heridas y el típico bug del teléfono (no está bug pero puede tener algo suelto, no sean cómo dicho server con un sistema bugeado).

1.7: No hay mapeos cargados, les recomiendo meter todo a un include y de hay importarlos.

1.8: Si vas a crear facciones cómo LSFD, LSPD y LSSD; recuerda modificar el `if (!member_faccion(playerid, FACCIÓN1, FACCIÓN2, FACCIÓN3))` en los comandos importantes, de lo contrario, crearás una facción cualquiera con esas IDs en la cual tendrá acceso a esos comandos.
