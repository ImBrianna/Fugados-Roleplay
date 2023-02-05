-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 05-02-2023 a las 05:28:44
-- Versión del servidor: 10.4.25-MariaDB
-- Versión de PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `fugadosrp`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actores`
--

CREATE TABLE `actores` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(24) NOT NULL DEFAULT 'ninguno',
  `Skin` int(11) NOT NULL DEFAULT -1,
  `PosX` float NOT NULL DEFAULT 0,
  `PosY` float NOT NULL DEFAULT 0,
  `PosZ` float NOT NULL DEFAULT 0,
  `PosR` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Animacion` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `baneados`
--

CREATE TABLE `baneados` (
  `BanID` int(11) NOT NULL,
  `BanIP` varchar(32) NOT NULL,
  `BanRazon` varchar(64) NOT NULL,
  `BanEncargado` varchar(24) NOT NULL,
  `BanFecha` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cajeros`
--

CREATE TABLE `cajeros` (
  `ID` int(11) NOT NULL,
  `Modelo` int(11) NOT NULL DEFAULT 19324,
  `BolosUwU` int(11) NOT NULL DEFAULT 5000000,
  `PotX` float NOT NULL DEFAULT 0,
  `PotY` float NOT NULL DEFAULT 0,
  `PotZ` float NOT NULL DEFAULT 0,
  `RotX` float NOT NULL DEFAULT 0,
  `RotY` float NOT NULL DEFAULT 0,
  `RotZ` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `casas`
--

CREATE TABLE `casas` (
  `ID` int(11) NOT NULL,
  `Propietario` varchar(24) NOT NULL DEFAULT 'none',
  `Tipo` int(11) NOT NULL DEFAULT 0,
  `Venta` int(11) NOT NULL DEFAULT 0,
  `Seguro` int(11) NOT NULL DEFAULT 1,
  `Exterior_X` float NOT NULL DEFAULT 0,
  `Exterior_Y` float NOT NULL DEFAULT 0,
  `Exterior_Z` float NOT NULL DEFAULT 0,
  `Exterior_R` float NOT NULL DEFAULT 0,
  `Exterior_Int` int(11) NOT NULL DEFAULT 0,
  `Exterior_VW` int(11) NOT NULL DEFAULT 0,
  `Interior_X` float NOT NULL DEFAULT 0,
  `Interior_Y` float NOT NULL DEFAULT 0,
  `Interior_Z` float NOT NULL DEFAULT 0,
  `Interior_R` float NOT NULL DEFAULT 0,
  `Interior_Int` int(11) NOT NULL DEFAULT 0,
  `Interior_VW` int(11) NOT NULL DEFAULT 0,
  `BolosUwU` int(11) NOT NULL DEFAULT 0,
  `Precio` int(11) NOT NULL DEFAULT 0,
  `Nivel` int(11) NOT NULL DEFAULT 0,
  `Materiales` int(11) NOT NULL DEFAULT 0,
  `Armario1` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant1` int(11) NOT NULL DEFAULT 0,
  `Armario2` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant2` int(11) NOT NULL DEFAULT 0,
  `Armario3` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant3` int(11) NOT NULL DEFAULT 0,
  `Armario4` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant4` int(11) NOT NULL DEFAULT 0,
  `Armario5` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant5` int(11) NOT NULL DEFAULT 0,
  `Armario6` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant6` int(11) NOT NULL DEFAULT 0,
  `Armario7` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant7` int(11) NOT NULL DEFAULT 0,
  `Armario8` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant8` int(11) NOT NULL DEFAULT 0,
  `Armario9` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant9` int(11) NOT NULL DEFAULT 0,
  `Armario10` int(11) NOT NULL DEFAULT 0,
  `ArmarioCant10` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuentas`
--

CREATE TABLE `cuentas` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(24) NOT NULL DEFAULT 'none',
  `Clave` varchar(65) NOT NULL DEFAULT 'none',
  `Salt` varchar(11) NOT NULL DEFAULT 'none',
  `IP` varchar(18) NOT NULL DEFAULT '127.0.0.1',
  `JotoOtaku` int(11) NOT NULL DEFAULT 0,
  `Apodo` varchar(12) NOT NULL DEFAULT 'niub',
  `EncFac` int(11) NOT NULL DEFAULT 0,
  `PreguntaSeguridad` varchar(256) NOT NULL DEFAULT 'ninguna',
  `RespuestaSeguridad` varchar(256) NOT NULL DEFAULT 'ninguna',
  `VIP` int(11) NOT NULL DEFAULT 0,
  `DiaVIP` int(11) NOT NULL DEFAULT 0,
  `MesVIP` int(11) NOT NULL DEFAULT 0,
  `CoinsVIP` int(11) NOT NULL DEFAULT 0,
  `DobleExp` int(11) NOT NULL DEFAULT 0,
  `Multicuenta` int(11) NOT NULL DEFAULT 0,
  `OtakuN_N` int(11) NOT NULL DEFAULT 0,
  `TimeBanUwU` int(11) NOT NULL DEFAULT 0,
  `FueBan` varchar(24) NOT NULL DEFAULT 'server',
  `ReasonBanUwU` varchar(256) NOT NULL DEFAULT 'abuso',
  `MomentBan` varchar(256) NOT NULL DEFAULT 'antes del 07/05/2020',
  `Regalo` int(11) NOT NULL DEFAULT 0,
  `FechaRegistro` varchar(256) NOT NULL DEFAULT 'none',
  `UltimaConexion` varchar(256) NOT NULL DEFAULT 'none',
  `Ranuras` int(11) NOT NULL DEFAULT 3
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facciones`
--

CREATE TABLE `facciones` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(128) NOT NULL DEFAULT 'none',
  `Logo` varchar(8) NOT NULL DEFAULT 'none',
  `Lider` varchar(24) NOT NULL DEFAULT 'none',
  `SubLider` varchar(24) NOT NULL DEFAULT 'none',
  `Mensaje` varchar(256) NOT NULL DEFAULT 'none',
  `Tipo` int(11) NOT NULL DEFAULT 0,
  `Miembros` int(11) NOT NULL DEFAULT 0,
  `BolosUwU` int(11) NOT NULL DEFAULT 0,
  `Salario` int(11) NOT NULL DEFAULT 0,
  `MaxRangos` int(11) NOT NULL DEFAULT 6,
  `Rango1` varchar(32) NOT NULL DEFAULT 'Rank1',
  `Rango2` varchar(32) NOT NULL DEFAULT 'Rank2',
  `Rango3` varchar(32) NOT NULL DEFAULT 'Rank3',
  `Rango4` varchar(32) NOT NULL DEFAULT 'Rank4',
  `Rango5` varchar(32) NOT NULL DEFAULT 'Rank5',
  `Rango6` varchar(32) NOT NULL DEFAULT 'Rank6',
  `Rango7` varchar(32) NOT NULL DEFAULT 'Rank7',
  `Rango8` varchar(32) NOT NULL DEFAULT 'Rank8',
  `Rango9` varchar(32) NOT NULL DEFAULT 'Rank9',
  `Rango10` varchar(32) NOT NULL DEFAULT 'Rank10',
  `Rango11` varchar(32) NOT NULL DEFAULT 'Rank11',
  `Rango12` varchar(32) NOT NULL DEFAULT 'Rank12',
  `Rango13` varchar(32) NOT NULL DEFAULT 'Rank13',
  `Rango14` varchar(32) NOT NULL DEFAULT 'Rank14',
  `Rango15` varchar(32) NOT NULL DEFAULT 'Rank15',
  `SpawnX` float NOT NULL DEFAULT 0,
  `SpawnY` float NOT NULL DEFAULT 0,
  `SpawnZ` float NOT NULL DEFAULT 0,
  `SpawnR` float NOT NULL DEFAULT 0,
  `SpawnInt` int(11) NOT NULL DEFAULT 0,
  `SpawnVW` int(11) NOT NULL DEFAULT 0,
  `ArmarioX` float NOT NULL DEFAULT 0,
  `ArmarioY` float NOT NULL DEFAULT 0,
  `ArmarioZ` float NOT NULL DEFAULT 0,
  `ArmarioInt` int(11) NOT NULL DEFAULT 0,
  `ArmarioVW` int(11) NOT NULL DEFAULT 0,
  `Materiales` int(11) NOT NULL DEFAULT 0,
  `Equipo1` int(11) NOT NULL DEFAULT 0,
  `Equipo2` int(11) NOT NULL DEFAULT 0,
  `Equipo3` int(11) NOT NULL DEFAULT 0,
  `Equipo4` int(11) NOT NULL DEFAULT 0,
  `Equipo5` int(11) NOT NULL DEFAULT 0,
  `Equipo6` int(11) NOT NULL DEFAULT 0,
  `Equipo7` int(11) NOT NULL DEFAULT 0,
  `Equipo8` int(11) NOT NULL DEFAULT 0,
  `Equipo9` int(11) NOT NULL DEFAULT 0,
  `Equipo10` int(11) NOT NULL DEFAULT 0,
  `Equipo11` int(11) NOT NULL DEFAULT 0,
  `Equipo12` int(11) NOT NULL DEFAULT 0,
  `Equipo13` int(11) NOT NULL DEFAULT 0,
  `Equipo14` int(11) NOT NULL DEFAULT 0,
  `Equipo15` int(11) NOT NULL DEFAULT 0,
  `Equipo16` int(11) NOT NULL DEFAULT 0,
  `Equipo17` int(11) NOT NULL DEFAULT 0,
  `Equipo18` int(11) NOT NULL DEFAULT 0,
  `Equipo19` int(11) NOT NULL DEFAULT 0,
  `Equipo20` int(11) NOT NULL DEFAULT 0,
  `Skin1` int(11) NOT NULL DEFAULT 0,
  `Skin2` int(11) NOT NULL DEFAULT 0,
  `Skin3` int(11) NOT NULL DEFAULT 0,
  `Skin4` int(11) NOT NULL DEFAULT 0,
  `Skin5` int(11) NOT NULL DEFAULT 0,
  `Skin6` int(11) NOT NULL DEFAULT 0,
  `Skin7` int(11) NOT NULL DEFAULT 0,
  `Skin8` int(11) NOT NULL DEFAULT 0,
  `Skin9` int(11) NOT NULL DEFAULT 0,
  `Skin10` int(11) NOT NULL DEFAULT 0,
  `Skin11` int(11) NOT NULL DEFAULT 0,
  `Skin12` int(11) NOT NULL DEFAULT 0,
  `Skin13` int(11) NOT NULL DEFAULT 0,
  `Skin14` int(11) NOT NULL DEFAULT 0,
  `Skin15` int(11) NOT NULL DEFAULT 0,
  `Skin16` int(11) NOT NULL DEFAULT 0,
  `Skin17` int(11) NOT NULL DEFAULT 0,
  `Skin18` int(11) NOT NULL DEFAULT 0,
  `Skin19` int(11) NOT NULL DEFAULT 0,
  `Skin20` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `graffitis`
--

CREATE TABLE `graffitis` (
  `ID` int(11) NOT NULL,
  `Mensaje` varchar(256) NOT NULL DEFAULT 'ninguno',
  `Creador` varchar(24) NOT NULL DEFAULT 'ninguno',
  `Fecha` int(11) NOT NULL DEFAULT 0,
  `PotX` float NOT NULL DEFAULT 0,
  `PotY` float NOT NULL DEFAULT 0,
  `PotZ` float NOT NULL DEFAULT 0,
  `RotX` float NOT NULL DEFAULT 0,
  `RotY` float NOT NULL DEFAULT 0,
  `RotZ` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `negocios`
--

CREATE TABLE `negocios` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(32) NOT NULL DEFAULT 'none',
  `Propietario` varchar(24) NOT NULL DEFAULT 'gobielno',
  `Venta` int(11) NOT NULL DEFAULT 0,
  `Tipo` int(11) NOT NULL DEFAULT 0,
  `Empleo` int(11) NOT NULL DEFAULT 0,
  `Precio` int(11) NOT NULL DEFAULT 0,
  `Nivel` int(11) NOT NULL DEFAULT 0,
  `ExteriorX` float NOT NULL DEFAULT 0,
  `ExteriorY` float NOT NULL DEFAULT 0,
  `ExteriorZ` float NOT NULL DEFAULT 0,
  `ExteriorR` float NOT NULL DEFAULT 0,
  `ExteriorInt` int(11) NOT NULL DEFAULT 0,
  `ExteriorVW` int(11) NOT NULL DEFAULT 0,
  `InteriorX` float NOT NULL DEFAULT 0,
  `InteriorY` float NOT NULL DEFAULT 0,
  `InteriorZ` float NOT NULL DEFAULT 0,
  `InteriorR` float NOT NULL DEFAULT 0,
  `InteriorInt` int(11) NOT NULL DEFAULT 0,
  `InteriorVW` int(11) NOT NULL DEFAULT 0,
  `LugarCompraX` float NOT NULL DEFAULT 0,
  `LugarCompraY` float NOT NULL DEFAULT 0,
  `LugarCompraZ` float NOT NULL DEFAULT 0,
  `Seguro` int(11) NOT NULL DEFAULT 0,
  `BolosUwU` int(11) NOT NULL DEFAULT 0,
  `Productos` int(11) NOT NULL DEFAULT 0,
  `MapIcon` int(11) NOT NULL DEFAULT 0,
  `ActorX` float NOT NULL DEFAULT 0,
  `ActorY` float NOT NULL DEFAULT 0,
  `ActorZ` float NOT NULL DEFAULT 0,
  `ActorR` float NOT NULL DEFAULT 0,
  `ActorSkin` int(11) NOT NULL DEFAULT 0,
  `VehicleX` float NOT NULL DEFAULT 0,
  `VehicleY` float NOT NULL DEFAULT 0,
  `VehicleZ` float NOT NULL DEFAULT 0,
  `VehicleR` float NOT NULL DEFAULT 0,
  `ExteriorVehX` float NOT NULL DEFAULT 0,
  `ExteriorVehY` float NOT NULL DEFAULT 0,
  `ExteriorVehZ` float NOT NULL DEFAULT 0,
  `ExteriorVehR` float NOT NULL DEFAULT 0,
  `ExteriorVehX_V` float NOT NULL DEFAULT 0,
  `ExteriorVehY_V` float NOT NULL DEFAULT 0,
  `Empleado1` int(11) NOT NULL DEFAULT 0,
  `Empleado2` int(11) NOT NULL DEFAULT 0,
  `Empleado3` int(11) NOT NULL DEFAULT 0,
  `Empleado4` int(11) NOT NULL DEFAULT 0,
  `Empleado5` int(11) NOT NULL DEFAULT 0,
  `Quimicos` int(11) NOT NULL DEFAULT 0,
  `TimeNecesitaQuimicos` int(11) NOT NULL DEFAULT 0,
  `Cocinando1` int(11) NOT NULL DEFAULT 0,
  `Cocinando2` int(11) NOT NULL DEFAULT 0,
  `Cocinando3` int(11) NOT NULL DEFAULT 0,
  `Cocinando4` int(11) NOT NULL DEFAULT 0,
  `Cocinando5` int(11) NOT NULL DEFAULT 0,
  `TimeCocinando1` int(11) NOT NULL DEFAULT 0,
  `TimeCocinando2` int(11) NOT NULL DEFAULT 0,
  `TimeCocinando3` int(11) NOT NULL DEFAULT 0,
  `TimeCocinando4` int(11) NOT NULL DEFAULT 0,
  `TimeCocinando5` int(11) NOT NULL DEFAULT 0,
  `EntregasListas` int(11) NOT NULL DEFAULT 0,
  `Mecanico` varchar(512) NOT NULL DEFAULT '0|0|0|0|0|0|0|0|'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `objetos_admin`
--

CREATE TABLE `objetos_admin` (
  `ID` int(11) NOT NULL,
  `Modelo` int(11) NOT NULL DEFAULT 0,
  `PotX` float NOT NULL DEFAULT 0,
  `PotY` float NOT NULL DEFAULT 0,
  `PotZ` float NOT NULL DEFAULT 0,
  `RotX` float NOT NULL DEFAULT 0,
  `RotY` float NOT NULL DEFAULT 0,
  `RotZ` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personajes`
--

CREATE TABLE `personajes` (
  `ID` int(11) NOT NULL,
  `Nombre_Apellido` varchar(24) NOT NULL DEFAULT 'none',
  `CuentaID` int(11) NOT NULL DEFAULT -1,
  `PosicionX` float NOT NULL DEFAULT 0,
  `PosicionY` float NOT NULL DEFAULT 0,
  `PosicionZ` float NOT NULL DEFAULT 0,
  `PosicionR` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Vida` float NOT NULL DEFAULT 100,
  `Chaleco` float NOT NULL DEFAULT 0,
  `Skin` int(11) NOT NULL DEFAULT 289,
  `Nivel` int(11) NOT NULL DEFAULT 1,
  `Experiencia` int(11) NOT NULL DEFAULT 0,
  `HorasOn` int(11) NOT NULL DEFAULT 0,
  `Sexo` int(11) NOT NULL DEFAULT 1,
  `Edad` int(11) NOT NULL DEFAULT 16,
  `Ciudad` int(11) NOT NULL DEFAULT 1,
  `Acento` int(11) NOT NULL DEFAULT 1,
  `EstiloPelea` int(11) NOT NULL DEFAULT 4,
  `BolosUwU` int(11) NOT NULL DEFAULT 0,
  `BanescoOwO` int(11) NOT NULL DEFAULT 0,
  `LiderFaccion` int(11) NOT NULL DEFAULT 0,
  `MiembroFaccion` int(11) NOT NULL DEFAULT 0,
  `Rango` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_1` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_1` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_2` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_2` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_3` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_3` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_4` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_4` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_5` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_5` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_6` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_6` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_7` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_7` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_8` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_8` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_9` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_9` int(11) NOT NULL DEFAULT 0,
  `Bolsillo_10` int(11) NOT NULL DEFAULT 0,
  `Cantidad_bolsillo_10` int(11) NOT NULL DEFAULT 0,
  `Mano_derecha` int(11) NOT NULL DEFAULT 0,
  `Cantidad_mano_derecha` int(11) NOT NULL DEFAULT 0,
  `Mano_izquierda` int(11) NOT NULL DEFAULT 0,
  `Cantidad_mano_izquierda` int(11) NOT NULL DEFAULT 0,
  `Espalda` int(11) NOT NULL DEFAULT 0,
  `Cantidad_espalda` int(11) NOT NULL DEFAULT 0,
  `ChatVIP` int(11) NOT NULL DEFAULT 0,
  `Muerto` int(11) NOT NULL DEFAULT 0,
  `Hospital` int(11) NOT NULL DEFAULT 0,
  `BalaCabeza` int(11) NOT NULL DEFAULT 0,
  `Jails` int(11) NOT NULL DEFAULT 0,
  `Arrestos` int(11) NOT NULL DEFAULT 0,
  `Sancionado` int(11) NOT NULL DEFAULT 0,
  `TiempoSancion` int(11) NOT NULL DEFAULT 0,
  `BySancion` varchar(24) NOT NULL DEFAULT 'none',
  `RazonSancion` varchar(128) NOT NULL DEFAULT 'none',
  `Materiales` int(11) NOT NULL DEFAULT 0,
  `Ganzuas` int(11) NOT NULL DEFAULT 0,
  `Telefono` int(11) NOT NULL DEFAULT 0,
  `Velocimetro` int(11) NOT NULL DEFAULT 1,
  `Casa` int(11) NOT NULL DEFAULT -1,
  `Casa2` int(11) NOT NULL DEFAULT -1,
  `Negocio` int(11) NOT NULL DEFAULT -1,
  `Negocio2` int(11) NOT NULL DEFAULT -1,
  `Licencia1` int(11) NOT NULL DEFAULT 0,
  `Licencia2` int(11) NOT NULL DEFAULT 0,
  `Licencia3` int(11) NOT NULL DEFAULT 0,
  `Licencia4` int(11) NOT NULL DEFAULT 0,
  `Licencia5` int(11) NOT NULL DEFAULT 0,
  `Mascara` int(11) NOT NULL DEFAULT 0,
  `UsoMascara` int(11) NOT NULL DEFAULT 0,
  `OtakuN_N` int(11) NOT NULL DEFAULT 0,
  `TimeBanUwU` int(11) NOT NULL DEFAULT 0,
  `FueBan` varchar(24) NOT NULL DEFAULT 'server',
  `ReasonBanUwU` varchar(256) NOT NULL DEFAULT 'abuso',
  `MomentBan` varchar(256) NOT NULL DEFAULT 'antes del 07/05/2020',
  `BlockBug` int(11) NOT NULL DEFAULT 0,
  `BlockG` int(11) NOT NULL DEFAULT 0,
  `Documento` int(11) NOT NULL DEFAULT 0,
  `Habilidad1` int(11) NOT NULL DEFAULT 0,
  `Habilidad2` int(11) NOT NULL DEFAULT 0,
  `Habilidad3` int(11) NOT NULL DEFAULT 0,
  `Habilidad4` int(11) NOT NULL DEFAULT 0,
  `Habilidad5` int(11) NOT NULL DEFAULT 0,
  `YaCobre` int(11) NOT NULL DEFAULT 0,
  `Estrellas` int(11) NOT NULL DEFAULT 0,
  `LimiteRobos` int(11) NOT NULL DEFAULT 0,
  `Frecuencia_radio` int(11) NOT NULL DEFAULT 0,
  `TipoSpawn` int(11) NOT NULL DEFAULT 0,
  `AutoRespuestaSMS` varchar(128) NOT NULL DEFAULT 'none',
  `BlockAD` int(11) NOT NULL DEFAULT 0,
  `AdvAD` int(11) NOT NULL DEFAULT 0,
  `Pescados` int(11) NOT NULL DEFAULT 0,
  `RecordPesoPes` int(11) NOT NULL DEFAULT 0,
  `EstadoYo` varchar(128) NOT NULL DEFAULT '',
  `NombreContacto1` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto1` int(11) NOT NULL DEFAULT 0,
  `NombreContacto2` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto2` int(11) NOT NULL DEFAULT 0,
  `NombreContacto3` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto3` int(11) NOT NULL DEFAULT 0,
  `NombreContacto4` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto4` int(11) NOT NULL DEFAULT 0,
  `NombreContacto5` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto5` int(11) NOT NULL DEFAULT 0,
  `NombreContacto6` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto6` int(11) NOT NULL DEFAULT 0,
  `NombreContacto7` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto7` int(11) NOT NULL DEFAULT 0,
  `NombreContacto8` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto8` int(11) NOT NULL DEFAULT 0,
  `NombreContacto9` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto9` int(11) NOT NULL DEFAULT 0,
  `NombreContacto10` varchar(24) NOT NULL DEFAULT 'none',
  `NumeroContacto10` int(11) NOT NULL DEFAULT 0,
  `JobSkin` int(11) NOT NULL DEFAULT 0,
  `RestriccionRobo` int(11) NOT NULL DEFAULT 0,
  `FalsoDocumento` int(11) NOT NULL DEFAULT 0,
  `FalsoNombre` varchar(24) NOT NULL DEFAULT 'none',
  `FechaRegistro` varchar(256) NOT NULL DEFAULT 'none',
  `UltimaConexion` varchar(256) NOT NULL DEFAULT 'none',
  `CamaraOculta` int(11) NOT NULL DEFAULT 0,
  `Toy1` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy2` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy3` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy4` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy5` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy6` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy7` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy8` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy9` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Toy10` varchar(512) NOT NULL DEFAULT '0|0|0.0|0.0|0.0|0.0|0.0|0.0|1|1|1|0|',
  `Cinturon_1` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_1` int(11) NOT NULL DEFAULT 0,
  `Cinturon_2` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_2` int(11) NOT NULL DEFAULT 0,
  `Cinturon_3` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_3` int(11) NOT NULL DEFAULT 0,
  `Cinturon_4` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_4` int(11) NOT NULL DEFAULT 0,
  `Cinturon_5` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_5` int(11) NOT NULL DEFAULT 0,
  `Cinturon_6` int(11) NOT NULL DEFAULT 0,
  `Cantidad_cinturon_6` int(11) NOT NULL DEFAULT 0,
  `ColorToy1` int(11) NOT NULL DEFAULT -1,
  `ColorToy2` int(11) NOT NULL DEFAULT -1,
  `ColorToy3` int(11) NOT NULL DEFAULT -1,
  `ColorToy4` int(11) NOT NULL DEFAULT -1,
  `ColorToy5` int(11) NOT NULL DEFAULT -1,
  `ColorToy6` int(11) NOT NULL DEFAULT -1,
  `ColorToy7` int(11) NOT NULL DEFAULT -1,
  `ColorToy8` int(11) NOT NULL DEFAULT -1,
  `ColorToy9` int(11) NOT NULL DEFAULT -1,
  `ColorToy10` int(11) NOT NULL DEFAULT -1,
  `Contrato` int(11) NOT NULL DEFAULT -1,
  `Empleo` int(11) NOT NULL DEFAULT 0,
  `Adiccion_1` int(11) NOT NULL DEFAULT 0,
  `Adiccion_2` int(11) NOT NULL DEFAULT 0,
  `Adiccion_3` int(11) NOT NULL DEFAULT 0,
  `Droga_tipo` int(11) NOT NULL DEFAULT 0,
  `Droga_tiempo` int(11) NOT NULL DEFAULT 0,
  `Droga_power` int(11) NOT NULL DEFAULT 0,
  `AbstinenceEffect` int(11) NOT NULL DEFAULT 0,
  `AbstinenceTime` int(11) NOT NULL DEFAULT 0,
  `TogManos` int(11) NOT NULL DEFAULT 1,
  `TogCajero` int(11) NOT NULL DEFAULT 0,
  `TogAnuncios` int(11) NOT NULL DEFAULT 0,
  `TogTelefono` int(11) NOT NULL DEFAULT 1,
  `TimerAnuncios` int(11) NOT NULL DEFAULT 0,
  `TogOOC` int(11) NOT NULL DEFAULT 1,
  `TogMusic` int(11) NOT NULL DEFAULT 1,
  `TogRadio` int(11) NOT NULL DEFAULT 1,
  `TogPortatil` int(11) NOT NULL DEFAULT 1,
  `TogFaccion` int(11) NOT NULL DEFAULT 1,
  `RepartoViajes` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puertas`
--

CREATE TABLE `puertas` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(128) NOT NULL DEFAULT 'none',
  `ExteriorX` float NOT NULL DEFAULT 0,
  `ExteriorY` float NOT NULL DEFAULT 0,
  `ExteriorZ` float NOT NULL DEFAULT 0,
  `ExteriorR` float NOT NULL DEFAULT 0,
  `ExteriorInt` int(11) NOT NULL DEFAULT 0,
  `ExteriorVW` int(11) NOT NULL DEFAULT 0,
  `InteriorX` float NOT NULL DEFAULT 0,
  `InteriorY` float NOT NULL DEFAULT 0,
  `InteriorZ` float NOT NULL DEFAULT 0,
  `InteriorR` float NOT NULL DEFAULT 0,
  `InteriorInt` int(11) NOT NULL DEFAULT 0,
  `InteriorVW` int(11) NOT NULL DEFAULT 0,
  `Modelo` int(11) NOT NULL DEFAULT 0,
  `MapIcon` int(11) NOT NULL DEFAULT 0,
  `Faccion` int(11) NOT NULL DEFAULT 0,
  `Admin` int(11) NOT NULL DEFAULT 0,
  `VIP` int(11) NOT NULL DEFAULT 0,
  `Estrellas` int(11) NOT NULL DEFAULT 0,
  `StatusVehiculo` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(128) NOT NULL DEFAULT 'none',
  `Propietario` varchar(24) NOT NULL DEFAULT 'none',
  `Tipo` int(11) NOT NULL DEFAULT 0,
  `Negocio` int(11) NOT NULL DEFAULT 0,
  `Modelo` int(11) NOT NULL DEFAULT 0,
  `Posicion_X` float NOT NULL DEFAULT 0,
  `Posicion_Y` float NOT NULL DEFAULT 0,
  `Posicion_Z` float NOT NULL DEFAULT 0,
  `Posicion_R` float NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Vida` float NOT NULL DEFAULT 1000,
  `DanioSuperficie` int(11) NOT NULL DEFAULT 0,
  `DanioPuertas` int(11) NOT NULL DEFAULT 0,
  `DanioLuces` int(11) NOT NULL DEFAULT 0,
  `DanioRuedas` int(11) NOT NULL DEFAULT 0,
  `Gasolina` int(11) NOT NULL DEFAULT 200,
  `Color_1` int(11) NOT NULL DEFAULT 1,
  `Color_2` int(11) NOT NULL DEFAULT 1,
  `PaintJob` int(11) NOT NULL DEFAULT -1,
  `ConSeguro` int(11) NOT NULL DEFAULT 0,
  `Precio` int(11) NOT NULL DEFAULT 0,
  `Embargo` int(11) NOT NULL DEFAULT 0,
  `Multa` int(11) NOT NULL DEFAULT 0,
  `Maletero1` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant1` int(11) NOT NULL DEFAULT 0,
  `Maletero2` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant2` int(11) NOT NULL DEFAULT 0,
  `Maletero3` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant3` int(11) NOT NULL DEFAULT 0,
  `Maletero4` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant4` int(11) NOT NULL DEFAULT 0,
  `Maletero5` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant5` int(11) NOT NULL DEFAULT 0,
  `Maletero6` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant6` int(11) NOT NULL DEFAULT 0,
  `Maletero7` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant7` int(11) NOT NULL DEFAULT 0,
  `Maletero8` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant8` int(11) NOT NULL DEFAULT 0,
  `Maletero9` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant9` int(11) NOT NULL DEFAULT 0,
  `Maletero10` int(11) NOT NULL DEFAULT 0,
  `MaleteroCant10` int(11) NOT NULL DEFAULT 0,
  `MaxMaletero` int(11) NOT NULL DEFAULT 5,
  `Modificacion1` int(11) NOT NULL DEFAULT 0,
  `Modificacion2` int(11) NOT NULL DEFAULT 0,
  `Modificacion3` int(11) NOT NULL DEFAULT 0,
  `Modificacion4` int(11) NOT NULL DEFAULT 0,
  `Modificacion5` int(11) NOT NULL DEFAULT 0,
  `Modificacion6` int(11) NOT NULL DEFAULT 0,
  `Modificacion7` int(11) NOT NULL DEFAULT 0,
  `Modificacion8` int(11) NOT NULL DEFAULT 0,
  `Modificacion9` int(11) NOT NULL DEFAULT 0,
  `Modificacion10` int(11) NOT NULL DEFAULT 0,
  `Modificacion11` int(11) NOT NULL DEFAULT 0,
  `Modificacion12` int(11) NOT NULL DEFAULT 0,
  `Modificacion13` int(11) NOT NULL DEFAULT 0,
  `Modificacion14` int(11) NOT NULL DEFAULT 0,
  `Modificacion15` int(11) NOT NULL DEFAULT 0,
  `ModeloNeon` int(11) NOT NULL DEFAULT 0,
  `OnNeon` int(11) NOT NULL DEFAULT 0,
  `CallSign` varchar(40) NOT NULL DEFAULT '',
  `ObjModelo_1` int(11) NOT NULL DEFAULT 0,
  `ObjPosX_1` float NOT NULL DEFAULT 0,
  `ObjPosY_1` float NOT NULL DEFAULT 0,
  `ObjPosZ_1` float NOT NULL DEFAULT 0,
  `ObjRotX_1` float NOT NULL DEFAULT 0,
  `ObjRotY_1` float NOT NULL DEFAULT 0,
  `ObjRotZ_1` float NOT NULL DEFAULT 0,
  `ObjModelo_2` int(11) NOT NULL DEFAULT 0,
  `ObjPosX_2` float NOT NULL DEFAULT 0,
  `ObjPosY_2` float NOT NULL DEFAULT 0,
  `ObjPosZ_2` float NOT NULL DEFAULT 0,
  `ObjRotX_2` float NOT NULL DEFAULT 0,
  `ObjRotY_2` float NOT NULL DEFAULT 0,
  `ObjRotZ_2` float NOT NULL DEFAULT 0,
  `ObjModelo_3` int(11) NOT NULL DEFAULT 0,
  `ObjPosX_3` float NOT NULL DEFAULT 0,
  `ObjPosY_3` float NOT NULL DEFAULT 0,
  `ObjPosZ_3` float NOT NULL DEFAULT 0,
  `ObjRotX_3` float NOT NULL DEFAULT 0,
  `ObjRotY_3` float NOT NULL DEFAULT 0,
  `ObjRotZ_3` float NOT NULL DEFAULT 0,
  `ObjModelo_4` int(11) NOT NULL DEFAULT 0,
  `ObjPosX_4` float NOT NULL DEFAULT 0,
  `ObjPosY_4` float NOT NULL DEFAULT 0,
  `ObjPosZ_4` float NOT NULL DEFAULT 0,
  `ObjRotX_4` float NOT NULL DEFAULT 0,
  `ObjRotY_4` float NOT NULL DEFAULT 0,
  `ObjRotZ_4` float NOT NULL DEFAULT 0,
  `ObjModelo_5` int(11) NOT NULL DEFAULT 0,
  `ObjPosX_5` float NOT NULL DEFAULT 0,
  `ObjPosY_5` float NOT NULL DEFAULT 0,
  `ObjPosZ_5` float NOT NULL DEFAULT 0,
  `ObjRotX_5` float NOT NULL DEFAULT 0,
  `ObjRotY_5` float NOT NULL DEFAULT 0,
  `ObjRotZ_5` float NOT NULL DEFAULT 0,
  `Sirena` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `actores`
--
ALTER TABLE `actores`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `baneados`
--
ALTER TABLE `baneados`
  ADD PRIMARY KEY (`BanID`) USING BTREE;

--
-- Indices de la tabla `cajeros`
--
ALTER TABLE `cajeros`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `casas`
--
ALTER TABLE `casas`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `cuentas`
--
ALTER TABLE `cuentas`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `facciones`
--
ALTER TABLE `facciones`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `graffitis`
--
ALTER TABLE `graffitis`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `negocios`
--
ALTER TABLE `negocios`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `objetos_admin`
--
ALTER TABLE `objetos_admin`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `personajes`
--
ALTER TABLE `personajes`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `puertas`
--
ALTER TABLE `puertas`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- Indices de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD PRIMARY KEY (`ID`) USING BTREE;

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `actores`
--
ALTER TABLE `actores`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `baneados`
--
ALTER TABLE `baneados`
  MODIFY `BanID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cajeros`
--
ALTER TABLE `cajeros`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `casas`
--
ALTER TABLE `casas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cuentas`
--
ALTER TABLE `cuentas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `facciones`
--
ALTER TABLE `facciones`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `graffitis`
--
ALTER TABLE `graffitis`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `negocios`
--
ALTER TABLE `negocios`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `objetos_admin`
--
ALTER TABLE `objetos_admin`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `personajes`
--
ALTER TABLE `personajes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `puertas`
--
ALTER TABLE `puertas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
