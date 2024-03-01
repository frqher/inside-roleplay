-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 137.74.6.118:3306
-- Czas generowania: 06 Sty 2022, 14:52
-- Wersja serwera: 10.5.12-MariaDB-0+deb11u1
-- Wersja PHP: 7.4.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `db_77540`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_accounts`
--

CREATE TABLE `tr_accounts` (
  `UID` int(11) NOT NULL,
  `login` varchar(40) NOT NULL,
  `username` varchar(22) DEFAULT NULL,
  `usernameRP` varchar(64) DEFAULT NULL,
  `password` varchar(128) NOT NULL,
  `email` varchar(60) NOT NULL,
  `serial` varchar(32) NOT NULL,
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `gold` datetime DEFAULT NULL,
  `diamond` datetime DEFAULT NULL,
  `skin` varchar(32) NOT NULL DEFAULT '0',
  `health` int(11) NOT NULL DEFAULT 100,
  `stamina` int(11) NOT NULL DEFAULT 100,
  `position` varchar(32) DEFAULT NULL,
  `money` varchar(32) NOT NULL DEFAULT '0',
  `bankmoney` varchar(32) NOT NULL DEFAULT '0',
  `bankcode` int(11) DEFAULT NULL,
  `casinoChips` int(11) NOT NULL DEFAULT 0,
  `phone` varchar(6) NOT NULL DEFAULT '1,1',
  `phoneBlocked` text NOT NULL,
  `licenceTheory` varchar(100) DEFAULT NULL,
  `features` varchar(40) NOT NULL DEFAULT '0,0,0,0,0,0,0,0,0,0',
  `licence` varchar(100) DEFAULT NULL,
  `licenceCreated` date DEFAULT NULL,
  `jobPoints` int(11) NOT NULL DEFAULT 0,
  `ticketPrice` varchar(12) DEFAULT NULL,
  `createIP` varchar(256) DEFAULT NULL,
  `ip` varchar(256) DEFAULT NULL,
  `tutorial` int(11) DEFAULT 1,
  `online` varchar(32) NOT NULL DEFAULT '0',
  `lastOnline` datetime NOT NULL DEFAULT current_timestamp(),
  `isOnline` tinyint(1) DEFAULT NULL,
  `bwTime` int(11) DEFAULT NULL,
  `cardPlay` datetime NOT NULL DEFAULT current_timestamp(),
  `cardPlays` int(11) DEFAULT 0,
  `houseLimit` int(11) NOT NULL DEFAULT 1,
  `vehicleLimit` int(11) NOT NULL DEFAULT 3,
  `referenced` int(11) NOT NULL DEFAULT 0,
  `referencedPlayer` int(11) DEFAULT NULL,
  `passwordResetCode` int(11) DEFAULT NULL,
  `personalToken` text DEFAULT NULL,
  `raceWin` int(11) NOT NULL DEFAULT 0,
  `prisonData` text DEFAULT NULL,
  `voiceWL` tinyint(1) DEFAULT NULL,
  `lastNameChange` datetime DEFAULT NULL,
  `lastRPNameChange` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_accountsBackup`
--

CREATE TABLE `tr_accountsBackup` (
  `UID` int(11) NOT NULL,
  `login` varchar(40) NOT NULL,
  `username` varchar(22) DEFAULT NULL,
  `usernameRP` varchar(64) DEFAULT NULL,
  `password` varchar(128) NOT NULL,
  `email` varchar(60) NOT NULL,
  `serial` varchar(32) NOT NULL,
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `gold` datetime DEFAULT NULL,
  `diamond` datetime DEFAULT NULL,
  `skin` int(11) NOT NULL DEFAULT 0,
  `health` int(11) NOT NULL DEFAULT 100,
  `stamina` int(11) NOT NULL DEFAULT 100,
  `position` varchar(32) DEFAULT NULL,
  `money` varchar(11) NOT NULL DEFAULT '0',
  `bankmoney` varchar(11) NOT NULL DEFAULT '0',
  `bankcode` int(11) DEFAULT NULL,
  `casinoChips` int(11) NOT NULL DEFAULT 0,
  `phone` varchar(6) NOT NULL DEFAULT '1,1',
  `phoneBlocked` text NOT NULL,
  `licenceTheory` varchar(100) DEFAULT NULL,
  `features` varchar(40) NOT NULL DEFAULT '0,0,0,0,0,0,0,0,0,0',
  `licence` varchar(100) DEFAULT NULL,
  `licenceCreated` date DEFAULT NULL,
  `jobPoints` int(11) NOT NULL DEFAULT 0,
  `ticketPrice` varchar(12) DEFAULT NULL,
  `createIP` varchar(256) DEFAULT NULL,
  `ip` varchar(256) DEFAULT NULL,
  `tutorial` int(11) DEFAULT 1,
  `online` varchar(32) NOT NULL DEFAULT '0',
  `lastOnline` datetime NOT NULL DEFAULT current_timestamp(),
  `isOnline` tinyint(1) DEFAULT NULL,
  `bwTime` int(11) DEFAULT NULL,
  `cardPlay` datetime NOT NULL DEFAULT current_timestamp(),
  `cardPlays` int(11) DEFAULT 0,
  `houseLimit` int(11) NOT NULL DEFAULT 1,
  `vehicleLimit` int(11) NOT NULL DEFAULT 3,
  `referenced` int(11) NOT NULL DEFAULT 0,
  `referencedPlayer` int(11) DEFAULT NULL,
  `passwordResetCode` int(11) DEFAULT NULL,
  `personalToken` text DEFAULT NULL,
  `raceWin` int(11) NOT NULL DEFAULT 0,
  `prisonData` text DEFAULT NULL,
  `lastNameChange` datetime DEFAULT NULL,
  `lastRPNameChange` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_achievements`
--

CREATE TABLE `tr_achievements` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `achievement` varchar(32) NOT NULL,
  `achieved` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_admin`
--

CREATE TABLE `tr_admin` (
  `ID` int(11) NOT NULL,
  `uid` int(11) DEFAULT NULL,
  `serial` varchar(32) NOT NULL,
  `rankName` varchar(32) DEFAULT NULL,
  `isDev` tinyint(1) DEFAULT NULL,
  `clearChat` tinyint(1) DEFAULT NULL,
  `ban` tinyint(1) DEFAULT NULL,
  `kick` tinyint(1) DEFAULT NULL,
  `tpl` int(11) DEFAULT NULL,
  `bwOff` int(11) DEFAULT NULL,
  `heal` int(11) NOT NULL DEFAULT 1,
  `playerTp` tinyint(1) DEFAULT NULL,
  `vehicleTp` tinyint(1) DEFAULT NULL,
  `vehicleFuel` int(11) DEFAULT NULL,
  `orgLogos` int(11) DEFAULT NULL,
  `air` int(11) NOT NULL DEFAULT 1,
  `allReports` int(11) DEFAULT NULL,
  `itemCreate` int(11) DEFAULT NULL,
  `resetMail` int(11) DEFAULT NULL,
  `editAdmin` int(11) DEFAULT NULL,
  `editOrg` int(11) DEFAULT NULL,
  `dutyTime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_collectibles`
--

CREATE TABLE `tr_collectibles` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `collectibleID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_computerLogs`
--

CREATE TABLE `tr_computerLogs` (
  `ID` int(11) NOT NULL,
  `text` text NOT NULL,
  `name` varchar(32) NOT NULL,
  `owner` int(11) NOT NULL,
  `type` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_darkweb`
--

CREATE TABLE `tr_darkweb` (
  `ID` int(11) NOT NULL,
  `text` varchar(200) NOT NULL,
  `location` varchar(200) NOT NULL,
  `type` varchar(16) NOT NULL,
  `hour` varchar(5) NOT NULL,
  `added` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_flowers`
--

CREATE TABLE `tr_flowers` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `womanID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_fractions`
--

CREATE TABLE `tr_fractions` (
  `ID` int(11) NOT NULL,
  `fractionID` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `type` varchar(12) NOT NULL,
  `color` varchar(11) NOT NULL,
  `pos` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Zrzut danych tabeli `tr_fractions`
--

INSERT INTO `tr_fractions` (`ID`, `fractionID`, `name`, `type`, `color`, `pos`) VALUES
(1, 1, 'San Andreas Police Department', 'police', '0,0,255', '2818.20, -2439.80, 82.30, 2, 6'),
(2, 2, 'Emergency Medical Services', 'medic', '0,144,255', '2561.46, -2022.25, 99.18, 0, 17'),
(3, 3, 'San Andreas Fire Department', 'fire', '220,0,0', '2752.06, -1959.85, 67.19, 2, 2'),
(5, 5, 'Emergency Road Services', 'ers', '255,215,0', '-53.34, -256.40, 6.61, 0, 0');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_fractionsDutyTimes`
--

CREATE TABLE `tr_fractionsDutyTimes` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `minutes` int(11) NOT NULL,
  `count` varchar(32) NOT NULL,
  `day` date NOT NULL,
  `takenMoney` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_fractionsPlayers`
--

CREATE TABLE `tr_fractionsPlayers` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) DEFAULT NULL,
  `fractionID` int(11) DEFAULT NULL,
  `rankID` int(11) DEFAULT NULL,
  `added` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_fractionsRanks`
--

CREATE TABLE `tr_fractionsRanks` (
  `ID` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `fractionID` int(11) NOT NULL,
  `rankName` varchar(32) NOT NULL,
  `canManage` smallint(6) DEFAULT NULL,
  `veh1` int(11) DEFAULT NULL,
  `veh2` int(11) DEFAULT NULL,
  `veh3` int(11) DEFAULT NULL,
  `veh4` int(11) DEFAULT NULL,
  `veh5` int(11) DEFAULT NULL,
  `veh6` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_friends`
--

CREATE TABLE `tr_friends` (
  `ID` int(11) NOT NULL,
  `sender` int(11) NOT NULL,
  `target` int(11) NOT NULL,
  `friendsFor` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_gangCorners`
--

CREATE TABLE `tr_gangCorners` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `zoneID` int(11) DEFAULT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Zrzut danych tabeli `tr_gangCorners`
--

INSERT INTO `tr_gangCorners` (`ID`, `plrUID`, `zoneID`, `date`) VALUES
(1, 24, 47, '2021-12-10 19:40:55'),
(2, 10, 19, '2021-12-10 19:56:52'),
(3, 272, 19, '2021-12-10 19:57:20'),
(4, 546, 36, '2021-12-10 20:05:21'),
(5, 27, 36, '2021-12-10 20:05:54'),
(6, 180, 36, '2021-12-10 20:06:09'),
(7, 79, 36, '2021-12-10 20:08:19'),
(8, 79, 40, '2021-12-10 20:12:52'),
(9, 67, 36, '2021-12-10 20:47:18'),
(10, 67, 16, '2021-12-10 20:49:24'),
(11, 67, 40, '2021-12-10 21:01:36'),
(12, 27, 16, '2021-12-10 22:06:47'),
(13, 180, 16, '2021-12-10 22:06:53'),
(14, 27, 40, '2021-12-10 22:15:04'),
(15, 180, 40, '2021-12-10 22:15:52'),
(16, 112, 21, '2021-12-12 12:49:41'),
(17, 10, 21, '2021-12-12 12:49:45'),
(18, 112, 19, '2021-12-12 13:15:03'),
(19, 112, 18, '2021-12-12 13:34:42'),
(20, 112, 17, '2021-12-12 14:14:28'),
(21, 546, 36, '2021-12-12 15:48:54'),
(22, 546, 16, '2021-12-12 16:24:17'),
(23, 546, 40, '2021-12-12 16:57:26'),
(24, 546, 41, '2021-12-12 17:29:12'),
(25, 79, 36, '2021-12-12 17:36:26'),
(26, 27, 41, '2021-12-13 01:28:34'),
(27, 13, 19, '2021-12-13 21:23:23'),
(28, 10, 19, '2021-12-13 21:23:25'),
(29, 502, 19, '2021-12-13 21:23:34'),
(30, 112, 19, '2021-12-13 21:23:44'),
(31, 258, 19, '2021-12-13 21:24:31'),
(32, 13, 21, '2021-12-13 21:54:31'),
(33, 502, 21, '2021-12-13 21:54:37'),
(34, 10, 21, '2021-12-13 21:57:14'),
(35, 258, 21, '2021-12-13 21:58:20'),
(36, 112, 21, '2021-12-13 22:02:20'),
(37, 546, 36, '2021-12-14 11:52:59'),
(38, 652, 41, '2021-12-14 23:56:25'),
(39, 112, 19, '2021-12-16 19:07:57'),
(40, 112, 21, '2021-12-16 19:39:10'),
(41, 112, 18, '2021-12-16 19:49:45'),
(42, 13, 19, '2021-12-16 21:51:37'),
(43, 13, 21, '2021-12-16 22:22:06'),
(44, 13, 18, '2021-12-16 22:26:56'),
(45, 13, 17, '2021-12-16 22:45:44'),
(46, 180, 36, '2021-12-18 11:02:56'),
(47, 27, 36, '2021-12-19 00:12:54'),
(48, 272, 19, '2021-12-19 20:05:18'),
(49, 272, 19, '2021-12-20 00:21:18'),
(50, 272, 18, '2021-12-20 00:29:41'),
(51, 681, 48, '2021-12-20 00:50:32'),
(52, 680, 48, '2021-12-20 00:50:40'),
(53, 680, 49, '2021-12-20 01:20:27'),
(54, 681, 49, '2021-12-20 01:26:43'),
(55, 867, 47, '2021-12-21 00:48:13'),
(56, 680, 47, '2021-12-21 00:48:18'),
(57, 867, 51, '2021-12-21 01:15:38'),
(58, 867, 48, '2021-12-21 09:12:04'),
(59, 867, 50, '2021-12-21 10:44:06'),
(60, 680, 50, '2021-12-21 10:44:36'),
(61, 786, 50, '2021-12-21 10:44:42'),
(62, 786, 47, '2021-12-21 11:19:14'),
(63, 680, 51, '2021-12-21 11:19:59'),
(64, 867, 49, '2021-12-21 11:21:29'),
(65, 680, 48, '2021-12-21 14:18:33'),
(66, 708, 48, '2021-12-21 14:20:32'),
(67, 731, 48, '2021-12-21 14:20:46'),
(68, 731, 47, '2021-12-21 14:31:05'),
(69, 708, 47, '2021-12-21 14:46:17'),
(70, 680, 49, '2021-12-22 00:40:06'),
(71, 867, 49, '2021-12-22 00:40:06'),
(72, 867, 47, '2021-12-22 01:14:48'),
(73, 680, 47, '2021-12-22 01:14:51'),
(74, 272, 19, '2021-12-22 11:35:25'),
(75, 680, 48, '2021-12-22 11:49:45'),
(76, 786, 48, '2021-12-22 11:49:51'),
(77, 708, 47, '2021-12-22 11:56:07'),
(78, 786, 50, '2021-12-22 11:58:24'),
(79, 867, 50, '2021-12-22 14:31:40'),
(80, 680, 50, '2021-12-22 14:31:56'),
(81, 1063, 19, '2021-12-25 15:38:32'),
(82, 1073, 19, '2021-12-25 15:38:34'),
(83, 258, 19, '2021-12-25 15:46:11'),
(84, 1073, 18, '2021-12-25 16:12:20'),
(85, 1063, 18, '2021-12-25 16:12:44'),
(86, 258, 18, '2021-12-25 16:32:46'),
(87, 1073, 21, '2021-12-25 16:50:10'),
(88, 1063, 21, '2021-12-25 16:50:15'),
(89, 1073, 14, '2021-12-25 17:20:53'),
(90, 1063, 14, '2021-12-25 17:23:03'),
(91, 1073, 13, '2021-12-25 17:43:10'),
(92, 1063, 13, '2021-12-25 18:07:29'),
(93, 1073, 19, '2021-12-26 10:00:26');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_gangHouseDrugs`
--

CREATE TABLE `tr_gangHouseDrugs` (
  `ID` int(11) NOT NULL,
  `homeID` int(11) NOT NULL,
  `objectIndex` int(11) NOT NULL,
  `fertilizer` datetime NOT NULL,
  `growth` datetime NOT NULL,
  `plantType` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_gangOrders`
--

CREATE TABLE `tr_gangOrders` (
  `ID` int(11) NOT NULL,
  `orgID` int(11) NOT NULL,
  `orderHour` int(11) NOT NULL,
  `orderDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_gangZones`
--

CREATE TABLE `tr_gangZones` (
  `ID` int(11) NOT NULL,
  `ownedGang` text DEFAULT NULL,
  `protectTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Zrzut danych tabeli `tr_gangZones`
--

INSERT INTO `tr_gangZones` (`ID`, `ownedGang`, `protectTime`) VALUES
(1, NULL, '2021-12-10 18:15:22'),
(2, NULL, '2021-12-10 18:15:22'),
(3, NULL, '2021-12-10 18:15:22'),
(4, NULL, '2021-12-10 18:15:22'),
(5, NULL, '2021-12-10 18:15:22'),
(6, NULL, '2021-12-10 18:15:22'),
(9, NULL, '2021-12-10 18:15:22'),
(10, NULL, '2021-12-10 18:15:22'),
(11, NULL, '2021-12-10 18:15:22'),
(12, NULL, '2021-12-10 18:15:22'),
(13, '18', '2021-12-20 02:52:40'),
(14, '18', '2021-12-30 21:51:48'),
(15, NULL, '2021-12-10 18:15:22'),
(16, '15', '2021-12-30 01:49:55'),
(17, '18', '2021-12-30 23:31:34'),
(18, '18', '2021-12-30 22:52:47'),
(19, '18', '2021-12-11 01:13:30'),
(20, '18', '2021-12-29 01:52:58'),
(21, '18', '2021-12-12 05:43:15'),
(22, NULL, '2021-12-10 18:15:22'),
(23, '18', '2021-12-29 01:43:52'),
(24, NULL, '2021-12-10 18:15:22'),
(25, NULL, '2021-12-10 18:15:22'),
(26, NULL, '2021-12-10 18:15:22'),
(27, NULL, '2021-12-10 18:15:22'),
(28, NULL, '2021-12-10 18:15:22'),
(30, NULL, '2021-12-10 18:15:22'),
(31, NULL, '2021-12-10 18:15:22'),
(32, NULL, '2021-12-10 18:15:22'),
(33, NULL, '2021-12-10 18:15:22'),
(34, NULL, '2021-12-10 18:15:22'),
(36, '15', '2021-12-11 01:16:08'),
(37, NULL, '2021-12-10 18:15:22'),
(38, '15', '2021-12-22 02:56:45'),
(39, NULL, '2021-12-10 18:15:22'),
(40, '15', '2021-12-11 01:51:18'),
(41, '15', '2021-12-12 06:10:39'),
(42, NULL, '2021-12-10 18:15:22'),
(46, NULL, '2021-12-10 18:15:22'),
(48, '27', '2021-12-20 06:38:38'),
(49, '27', '2021-12-20 07:12:45'),
(50, '27', '2021-12-21 16:43:38'),
(51, '27', '2021-12-20 20:49:26'),
(47, '27', '2021-12-21 06:22:05');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_govJobs`
--

CREATE TABLE `tr_govJobs` (
  `ID` int(11) NOT NULL,
  `govID` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `type` varchar(32) NOT NULL,
  `description` text NOT NULL,
  `place` varchar(32) NOT NULL,
  `slots` int(11) NOT NULL DEFAULT 0,
  `payment` varchar(32) NOT NULL,
  `requirements` varchar(64) DEFAULT NULL,
  `position` varchar(40) DEFAULT NULL,
  `distanceLimit` int(11) DEFAULT NULL,
  `int` int(11) NOT NULL,
  `dim` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Zrzut danych tabeli `tr_govJobs`
--

INSERT INTO `tr_govJobs` (`ID`, `govID`, `name`, `type`, `description`, `place`, `slots`, `payment`, `requirements`, `position`, `distanceLimit`, `int`, `dim`) VALUES
(1, 1, 'Lakiernik pojazdów', 'mechanic', 'Praca lakiernika', '0', 1, '100', 'Brak', '-1679.0068359375, 436.4931640625, 10.179', 100, 0, 0),
(2, 2, 'Lakiernik pojazdów', 'mechanic', 'Praca lakiernika', '0', 2, '100', 'Brak', '2496.0380859375, 910.9228515625, 10.8203', 100, 0, 0),
(3, 3, 'Lakiernik pojazdów', 'mechanic', 'Praca lakiernika', '0', 1, '100', 'Brak', '996.6064453125, -1602.0009765625, 13.529', 100, 0, 0),
(4, 4, 'Kierowca taksówki', 'taxi', 'Praca polega na wożeniu klientów po stanie San Andreas', '0', 9, '2300', 'Brak', '876.912109375, -1529.404296875, 155.0854', NULL, 0, 4);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_govJobsPlayers`
--

CREATE TABLE `tr_govJobsPlayers` (
  `ID` int(11) NOT NULL,
  `jobID` int(11) NOT NULL,
  `plrUID` varchar(11) DEFAULT NULL,
  `start` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_houses`
--

CREATE TABLE `tr_houses` (
  `ID` int(11) NOT NULL,
  `date` datetime DEFAULT NULL,
  `price` varchar(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `ownedOrg` int(11) DEFAULT NULL,
  `interiorFloor` text DEFAULT NULL,
  `interiorWalls` text DEFAULT NULL,
  `interiorObjects` text DEFAULT NULL,
  `interiorSize` varchar(256) DEFAULT NULL,
  `pos` varchar(256) DEFAULT NULL,
  `locked` tinyint(1) DEFAULT NULL,
  `premium` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_housesGarage`
--

CREATE TABLE `tr_housesGarage` (
  `ID` int(11) NOT NULL,
  `homeID` int(11) NOT NULL,
  `garageSize` int(11) NOT NULL,
  `pos` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_housesRent`
--

CREATE TABLE `tr_housesRent` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `houseID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_items`
--

CREATE TABLE `tr_items` (
  `ID` int(11) NOT NULL,
  `owner` int(11) DEFAULT NULL,
  `ownedType` int(11) NOT NULL DEFAULT 0,
  `type` int(11) DEFAULT NULL,
  `variant` int(11) DEFAULT NULL,
  `variant2` int(11) DEFAULT NULL,
  `value` varchar(32) DEFAULT NULL,
  `value2` int(11) NOT NULL DEFAULT 1,
  `durability` float NOT NULL DEFAULT 100,
  `used` int(11) DEFAULT NULL,
  `favourite` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_jobsPlayers`
--

CREATE TABLE `tr_jobsPlayers` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `jobID` varchar(32) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `totalPoints` int(11) NOT NULL DEFAULT 0,
  `upgrades` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_jobsPlayersPrizes`
--

CREATE TABLE `tr_jobsPlayersPrizes` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `jobID` varchar(32) NOT NULL,
  `amount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_logs`
--

CREATE TABLE `tr_logs` (
  `ID` int(11) NOT NULL,
  `player` int(11) NOT NULL,
  `text` varchar(128) NOT NULL,
  `serial` varchar(32) DEFAULT NULL,
  `ip` varchar(16) DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `type` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_mdtPlayers`
--

CREATE TABLE `tr_mdtPlayers` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `text` text NOT NULL,
  `policeUID` int(11) NOT NULL,
  `added` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_mdtWanted`
--

CREATE TABLE `tr_mdtWanted` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `wantedTime` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_organizations`
--

CREATE TABLE `tr_organizations` (
  `ID` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `type` varchar(16) NOT NULL,
  `interior` int(11) NOT NULL DEFAULT 1,
  `img` varchar(128) DEFAULT NULL,
  `logoRequest` text DEFAULT NULL,
  `zoneColor` varchar(12) DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT current_timestamp(),
  `rent` date DEFAULT NULL,
  `owner` varchar(32) NOT NULL,
  `money` varchar(16) NOT NULL DEFAULT '0',
  `players` int(11) NOT NULL DEFAULT 1,
  `vehicles` int(11) NOT NULL DEFAULT 1,
  `moneyBonus` int(11) NOT NULL DEFAULT 0,
  `lastPayment` datetime NOT NULL DEFAULT current_timestamp(),
  `orgType` varchar(16) DEFAULT NULL,
  `removed` int(11) DEFAULT NULL,
  `verifedRP` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_organizationsEarnings`
--

CREATE TABLE `tr_organizationsEarnings` (
  `ID` int(11) NOT NULL,
  `orgID` int(11) NOT NULL,
  `totalEarn` varchar(32) NOT NULL,
  `day` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_organizationsPlayers`
--

CREATE TABLE `tr_organizationsPlayers` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) DEFAULT NULL,
  `orgID` int(11) DEFAULT NULL,
  `rankID` int(11) DEFAULT NULL,
  `added` datetime NOT NULL DEFAULT current_timestamp(),
  `toPay` varchar(12) NOT NULL DEFAULT '0',
  `allEarn` varchar(12) NOT NULL DEFAULT '0',
  `allPaid` varchar(32) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_organizationsRanks`
--

CREATE TABLE `tr_organizationsRanks` (
  `ID` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `orgID` int(11) NOT NULL,
  `rankName` varchar(32) NOT NULL,
  `canManage` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_penalties`
--

CREATE TABLE `tr_penalties` (
  `ID` int(11) NOT NULL,
  `username` varchar(22) DEFAULT NULL,
  `plrUID` int(11) DEFAULT NULL,
  `serial` varchar(32) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  `timeEnd` datetime DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `admin` varchar(22) DEFAULT NULL,
  `takenBy` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_premiumoptions`
--

CREATE TABLE `tr_premiumoptions` (
  `option_id` int(11) NOT NULL,
  `option_days` int(11) NOT NULL,
  `option_price` varchar(6) NOT NULL,
  `option_price_now` varchar(6) NOT NULL,
  `option_shop` int(11) NOT NULL,
  `option_smsCode` varchar(45) DEFAULT NULL,
  `option_smsNumber` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_raceTimes`
--

CREATE TABLE `tr_raceTimes` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `playerTime` int(11) NOT NULL,
  `trackID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_raceTracks`
--

CREATE TABLE `tr_raceTracks` (
  `ID` int(11) NOT NULL,
  `createdPlayer` int(11) NOT NULL,
  `track` text CHARACTER SET utf8 NOT NULL,
  `type` varchar(11) CHARACTER SET utf8 DEFAULT NULL,
  `laps` int(11) DEFAULT NULL,
  `vehicleType` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `vehicleSpeed` varchar(16) CHARACTER SET utf8 DEFAULT NULL,
  `created` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_reports`
--

CREATE TABLE `tr_reports` (
  `ID` int(11) NOT NULL,
  `reporter` varchar(22) DEFAULT NULL,
  `reported` varchar(22) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `admin` varchar(22) DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_santaGifts`
--

CREATE TABLE `tr_santaGifts` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `serial` varchar(32) NOT NULL,
  `money` int(11) NOT NULL DEFAULT 0,
  `gold` int(11) NOT NULL DEFAULT 0,
  `diamond` int(11) NOT NULL DEFAULT 0,
  `vehicle` int(11) NOT NULL DEFAULT 0,
  `house` int(11) NOT NULL DEFAULT 0,
  `takenTime` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_santaQuests`
--

CREATE TABLE `tr_santaQuests` (
  `ID` int(11) NOT NULL,
  `playerUID` int(11) NOT NULL,
  `stage` int(11) NOT NULL,
  `completed` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_shop`
--

CREATE TABLE `tr_shop` (
  `shop_id` int(11) NOT NULL,
  `shop_value` int(11) DEFAULT NULL,
  `shop_item_name` varchar(64) DEFAULT NULL,
  `shop_item_category` int(11) DEFAULT NULL,
  `shop_price_stripe` int(11) DEFAULT NULL,
  `shop_price_hotpay` int(11) DEFAULT NULL,
  `shop_number_hotpay` int(11) DEFAULT NULL,
  `shop_price_cashbill` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_sweepers`
--

CREATE TABLE `tr_sweepers` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `count` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_sweepersSorting`
--

CREATE TABLE `tr_sweepersSorting` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) DEFAULT NULL,
  `money` int(11) DEFAULT NULL,
  `takeoutTime` datetime NOT NULL,
  `taken` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_updates`
--

CREATE TABLE `tr_updates` (
  `ID` int(11) NOT NULL,
  `text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_vehicles`
--

CREATE TABLE `tr_vehicles` (
  `ID` int(11) NOT NULL,
  `model` int(11) DEFAULT NULL,
  `pos` varchar(256) DEFAULT NULL,
  `health` int(11) DEFAULT 1000,
  `fuel` float DEFAULT NULL,
  `mileage` float DEFAULT NULL,
  `color` varchar(256) DEFAULT NULL,
  `engineCapacity` varchar(32) DEFAULT NULL,
  `engineType` varchar(1) DEFAULT NULL,
  `tuning` varchar(64) DEFAULT NULL,
  `visualTuning` text DEFAULT NULL,
  `performanceTuning` text DEFAULT NULL,
  `paintjob` tinyint(1) DEFAULT NULL,
  `variant` varchar(8) NOT NULL DEFAULT '0,0',
  `panelstates` varchar(17) DEFAULT '0,0,0,0,0,0,0,0,0',
  `doorstates` varchar(11) DEFAULT '0,0,0,0,0,0',
  `vehicleDirt` int(11) NOT NULL DEFAULT 0,
  `plateText` varchar(64) DEFAULT NULL,
  `ownedPlayer` int(11) DEFAULT NULL,
  `ownedOrg` int(11) DEFAULT NULL,
  `requestOrg` int(11) DEFAULT NULL,
  `rent` varchar(100) DEFAULT NULL,
  `parking` int(11) DEFAULT NULL,
  `policeParkingInfo` varchar(150) DEFAULT NULL,
  `wheelBlock` int(11) DEFAULT NULL,
  `boughtDate` datetime NOT NULL DEFAULT current_timestamp(),
  `exchangePrice` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_vehiclesDrivers`
--

CREATE TABLE `tr_vehiclesDrivers` (
  `ID` int(11) NOT NULL,
  `vehID` int(11) NOT NULL,
  `driverUID` int(11) NOT NULL,
  `driveDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_vehiclesRent`
--

CREATE TABLE `tr_vehiclesRent` (
  `ID` int(11) NOT NULL,
  `plrUID` int(11) NOT NULL,
  `vehID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tr_weather`
--

CREATE TABLE `tr_weather` (
  `weather_id` int(11) NOT NULL,
  `weather_zone` varchar(64) DEFAULT NULL,
  `weather_value` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `tr_accounts`
--
ALTER TABLE `tr_accounts`
  ADD PRIMARY KEY (`UID`);

--
-- Indeksy dla tabeli `tr_achievements`
--
ALTER TABLE `tr_achievements`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_admin`
--
ALTER TABLE `tr_admin`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_collectibles`
--
ALTER TABLE `tr_collectibles`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_computerLogs`
--
ALTER TABLE `tr_computerLogs`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_darkweb`
--
ALTER TABLE `tr_darkweb`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_flowers`
--
ALTER TABLE `tr_flowers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_fractions`
--
ALTER TABLE `tr_fractions`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_fractionsDutyTimes`
--
ALTER TABLE `tr_fractionsDutyTimes`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_fractionsPlayers`
--
ALTER TABLE `tr_fractionsPlayers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_fractionsRanks`
--
ALTER TABLE `tr_fractionsRanks`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_friends`
--
ALTER TABLE `tr_friends`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_gangCorners`
--
ALTER TABLE `tr_gangCorners`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_gangHouseDrugs`
--
ALTER TABLE `tr_gangHouseDrugs`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_gangOrders`
--
ALTER TABLE `tr_gangOrders`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_govJobs`
--
ALTER TABLE `tr_govJobs`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_govJobsPlayers`
--
ALTER TABLE `tr_govJobsPlayers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_houses`
--
ALTER TABLE `tr_houses`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_housesGarage`
--
ALTER TABLE `tr_housesGarage`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_housesRent`
--
ALTER TABLE `tr_housesRent`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_items`
--
ALTER TABLE `tr_items`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_jobsPlayers`
--
ALTER TABLE `tr_jobsPlayers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_jobsPlayersPrizes`
--
ALTER TABLE `tr_jobsPlayersPrizes`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_logs`
--
ALTER TABLE `tr_logs`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_mdtPlayers`
--
ALTER TABLE `tr_mdtPlayers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_mdtWanted`
--
ALTER TABLE `tr_mdtWanted`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_organizations`
--
ALTER TABLE `tr_organizations`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_organizationsEarnings`
--
ALTER TABLE `tr_organizationsEarnings`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `OrganizationEarnings` (`orgID`,`day`);

--
-- Indeksy dla tabeli `tr_organizationsPlayers`
--
ALTER TABLE `tr_organizationsPlayers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_organizationsRanks`
--
ALTER TABLE `tr_organizationsRanks`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_penalties`
--
ALTER TABLE `tr_penalties`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_premiumoptions`
--
ALTER TABLE `tr_premiumoptions`
  ADD PRIMARY KEY (`option_id`);

--
-- Indeksy dla tabeli `tr_raceTimes`
--
ALTER TABLE `tr_raceTimes`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_raceTracks`
--
ALTER TABLE `tr_raceTracks`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_reports`
--
ALTER TABLE `tr_reports`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_santaGifts`
--
ALTER TABLE `tr_santaGifts`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_santaQuests`
--
ALTER TABLE `tr_santaQuests`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_shop`
--
ALTER TABLE `tr_shop`
  ADD PRIMARY KEY (`shop_id`);

--
-- Indeksy dla tabeli `tr_sweepers`
--
ALTER TABLE `tr_sweepers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_sweepersSorting`
--
ALTER TABLE `tr_sweepersSorting`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_updates`
--
ALTER TABLE `tr_updates`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_vehicles`
--
ALTER TABLE `tr_vehicles`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_vehiclesDrivers`
--
ALTER TABLE `tr_vehiclesDrivers`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_vehiclesRent`
--
ALTER TABLE `tr_vehiclesRent`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `tr_weather`
--
ALTER TABLE `tr_weather`
  ADD PRIMARY KEY (`weather_id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `tr_accounts`
--
ALTER TABLE `tr_accounts`
  MODIFY `UID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_achievements`
--
ALTER TABLE `tr_achievements`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_admin`
--
ALTER TABLE `tr_admin`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_collectibles`
--
ALTER TABLE `tr_collectibles`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_computerLogs`
--
ALTER TABLE `tr_computerLogs`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_darkweb`
--
ALTER TABLE `tr_darkweb`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_flowers`
--
ALTER TABLE `tr_flowers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_fractions`
--
ALTER TABLE `tr_fractions`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT dla tabeli `tr_fractionsDutyTimes`
--
ALTER TABLE `tr_fractionsDutyTimes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_fractionsPlayers`
--
ALTER TABLE `tr_fractionsPlayers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_fractionsRanks`
--
ALTER TABLE `tr_fractionsRanks`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_friends`
--
ALTER TABLE `tr_friends`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_gangCorners`
--
ALTER TABLE `tr_gangCorners`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT dla tabeli `tr_gangHouseDrugs`
--
ALTER TABLE `tr_gangHouseDrugs`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_gangOrders`
--
ALTER TABLE `tr_gangOrders`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_govJobs`
--
ALTER TABLE `tr_govJobs`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT dla tabeli `tr_govJobsPlayers`
--
ALTER TABLE `tr_govJobsPlayers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_houses`
--
ALTER TABLE `tr_houses`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_housesGarage`
--
ALTER TABLE `tr_housesGarage`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_housesRent`
--
ALTER TABLE `tr_housesRent`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_items`
--
ALTER TABLE `tr_items`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_jobsPlayers`
--
ALTER TABLE `tr_jobsPlayers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_jobsPlayersPrizes`
--
ALTER TABLE `tr_jobsPlayersPrizes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_logs`
--
ALTER TABLE `tr_logs`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_mdtPlayers`
--
ALTER TABLE `tr_mdtPlayers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_mdtWanted`
--
ALTER TABLE `tr_mdtWanted`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_organizations`
--
ALTER TABLE `tr_organizations`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_organizationsEarnings`
--
ALTER TABLE `tr_organizationsEarnings`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_organizationsPlayers`
--
ALTER TABLE `tr_organizationsPlayers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_organizationsRanks`
--
ALTER TABLE `tr_organizationsRanks`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_penalties`
--
ALTER TABLE `tr_penalties`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_premiumoptions`
--
ALTER TABLE `tr_premiumoptions`
  MODIFY `option_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_raceTimes`
--
ALTER TABLE `tr_raceTimes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_raceTracks`
--
ALTER TABLE `tr_raceTracks`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_reports`
--
ALTER TABLE `tr_reports`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_santaGifts`
--
ALTER TABLE `tr_santaGifts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_santaQuests`
--
ALTER TABLE `tr_santaQuests`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_shop`
--
ALTER TABLE `tr_shop`
  MODIFY `shop_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_sweepers`
--
ALTER TABLE `tr_sweepers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_sweepersSorting`
--
ALTER TABLE `tr_sweepersSorting`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_updates`
--
ALTER TABLE `tr_updates`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_vehicles`
--
ALTER TABLE `tr_vehicles`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_vehiclesDrivers`
--
ALTER TABLE `tr_vehiclesDrivers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_vehiclesRent`
--
ALTER TABLE `tr_vehiclesRent`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `tr_weather`
--
ALTER TABLE `tr_weather`
  MODIFY `weather_id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
