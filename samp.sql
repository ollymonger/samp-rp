-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 14, 2020 at 05:25 AM
-- Server version: 10.1.29-MariaDB
-- PHP Version: 7.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `samp`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `ID` int(11) NOT NULL,
  `pName` varchar(32) NOT NULL,
  `pPassword` varchar(256) NOT NULL,
  `pEmail` varchar(256) NOT NULL,
  `pAdminLevel` int(11) NOT NULL,
  `pLevel` int(11) NOT NULL,
  `pExp` int(11) NOT NULL,
  `pRegion` varchar(32) NOT NULL,
  `pHealth` float NOT NULL,
  `pArmour` float NOT NULL,
  `pGender` int(11) NOT NULL,
  `pSkin` int(11) NOT NULL,
  `pAge` int(11) NOT NULL,
  `pBank` int(64) NOT NULL,
  `pCash` int(64) NOT NULL,
  `pPayTimer` int(11) NOT NULL,
  `pFactionId` int(11) NOT NULL,
  `pFactionRank` int(11) NOT NULL,
  `pFactionRankname` varchar(32) DEFAULT NULL,
  `pJobId` int(11) NOT NULL,
  `pJobPay` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`ID`, `pName`, `pPassword`, `pEmail`, `pAdminLevel`, `pLevel`, `pExp`, `pRegion`, `pHealth`, `pArmour`, `pGender`, `pSkin`, `pAge`, `pBank`, `pCash`, `pPayTimer`, `pFactionId`, `pFactionRank`, `pFactionRankname`, `pJobId`, `pJobPay`) VALUES
(3, 'Olly', '$2y$12$aCm2PzXMY', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(4, 'Olly123', '$2y$12$bjHwP0vIM', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(5, 'Olly1', '$2y$12$PyPsXVbAb', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(6, 'Olly12', '$2y$12$OhDsThPvZ', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(7, 'test1', '$2y$12$RDfRRSeuRlDpaVLLaRjkSOgnx3FNJ3nKzrX39w5zMOjY/.9PvQWui', 'helloworld@world.com', 0, 0, 0, '', 42, 0, 0, 0, 0, 0, 80000, 0, 0, 0, '', 0, 0),
(8, 'testemaildialog', '$2y$12$ZELqcCPMYiTzOiDJRCjxQe7WBZbdvRaBjY8G4ahSzcFHuUEhBNs1u', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(9, 'testemaildialog2', '$2y$12$Ki3tK0vzWSvpakTkQzfAP.dd559FY6izEk5MI9I8oKOQdktoZCJee', 'hi_there@test.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(10, 'testemaildialog3', '$2y$12$XCCxREftXyDiKzTyKi7DTu/nVvquj3B2IpAvqWa4TqtkSyeSnojnq', 'notrightemail.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(11, 'testemaildialog4', '$2y$12$cFTrYEfCWzmxWhCwRVTNQ.gtAMRVqWX2qZ6WwUT8OSri/JyaXOyRu', 'HI.COM', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(12, 'testemaildialog5', '$2y$12$Q1PDZRbQYivqZUnfcjmzYOFs2kxwsZ3baXo5gUAWOzsUUI95iFIZ.', 'hello@gmail.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(13, 'testdialog1', '$2y$12$YizuZSz1KSuxOyPBMVXVQu8hs8LFpsgsT747otZRFhso/b497ZTim', 'olly@yllo.co.uk', 0, 0, 0, 'America', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(14, 'testdialog12', '$2y$12$ayjfOTXLT03OcCLYO0LQL.eoU6gBTipidOWmuwhkM7NZY5HrJVSRO', 'hello@gmail.com', 0, 0, 0, 'NULL', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(15, 'testdialog123', '$2y$12$ZCXXPxTGQTfLZiHJTkzRbeiAxOf6qcpH6VNdo2v7xC1VsNot73hBy', 'hello@gmail.com', 0, 0, 0, 'region', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(16, 'testdialog11', '$2y$12$Kyn0bhTYRTDxbFPNa1fwZeGR2UvPX5iFiOyB4JDLRG5yrLlKnd4cy', 'olly@yllo.co.uk', 0, 0, 0, 'United Kingdom', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(17, 'testdialoga', '$2y$12$OUy1Z0P1RDjhXkr3REDKSOQVsqBHfQDHEqwInPdnjvPEISAK/3OLa', 'gmail@gmail.com', 0, 0, 0, 'America', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0),
(18, 'testdialogb', '$2y$12$TRH0cCrHZVDlRh/uX1LhPOGOzdQD5fIUo/piDreo8/G/n9cdpDU5m', 'example@example.com', 0, 0, 0, 'America', 100, 0, 0, 0, 0, 0, 1000, 0, 0, 0, '', 0, 0),
(19, 'testdialogc', '$2y$12$QDDrYibDbTblZ1jfPy60butWDkKhIn7fzb6/6qog6cXvLCTYvMbwC', 'example@example.com', 0, 0, 0, 'America', 100, 0, 1, 167, 27, 0, 50, 0, 0, 0, '', 0, 0),
(20, 'quiztest1', '$2y$12$cSDOOkf3ThXATj.0XhDDXOd1SS1fz0i/dZ4iuAQYph2EOT1gCtRMu', '@', 0, 0, 0, 'Los Santos', 100, 0, 1, 23, 28, 0, 1000, 0, 0, 0, '', 0, 0),
(21, 'testaccounts_1', '$2y$12$KjjyaDTEQBe1LTTDUUvGaOTqZsuFTWhrHHEa6fv0KiASgtEyJscGG', 'gmail@gmail.com', 0, 0, 0, 'Los Santos', 100, 0, 1, 72, 28, 0, 1000, 0, 0, 0, '', 0, 0),
(22, 'testaccounts_2', '$2y$12$XFDYQjXvbjThLR/xKkjRTOarF5sW7jrTtLDUAQoj5KzHKM/NZ3rRa', 'olly@yllo.co.uk', 6, 2, 8, 'Los Santos', 70, 0, 1, 73, 28, 12983, 0, 52, 1, 7, 'Chief of Police', 3, 700),
(23, 'testaccounts_3', '$2y$12$PEeuZSHTTVnjKDb2UEDWSunyPVyEv7lKRwTEZihlRmQmObQ2NP8n.', '@', 0, 1, 1, 'Los Santos', 100, 0, 1, 170, 28, 0, 1000, 60, 0, 0, '', 1, 0),
(24, 'testaccounts_6', '$2y$12$YzDJSCnlPVH/ShTMXyzwOOEfQvuVt/Ty88apHkAAldDO5rmIFSJvi', '@', 0, 1, 1, 'america', 95, 0, 1, 24, 28, 0, 800, 55, 0, 0, '', 1, 172),
(25, 'testaccount_12', '$2y$12$MUbIMBbtUDjFaTHrSS3sbeR/.2zeCYsrJAsxX95yyYweQUtXfsQRK', '@', 0, 1, 1, 'America', 100, 0, 1, 60, 28, 0, 1000, 59, 0, 0, '', 1, 50);

-- --------------------------------------------------------

--
-- Table structure for table `factions`
--

CREATE TABLE `factions` (
  `fID` int(32) NOT NULL,
  `fName` varchar(32) NOT NULL,
  `fType` int(11) NOT NULL,
  `fRank1Name` varchar(32) NOT NULL,
  `fRank2Name` varchar(32) NOT NULL,
  `fRank3Name` varchar(32) NOT NULL,
  `fRank4Name` varchar(32) NOT NULL,
  `fRank5Name` varchar(32) NOT NULL,
  `fRank6Name` varchar(32) NOT NULL,
  `fRank7Name` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `factions`
--

INSERT INTO `factions` (`fID`, `fName`, `fType`, `fRank1Name`, `fRank2Name`, `fRank3Name`, `fRank4Name`, `fRank5Name`, `fRank6Name`, `fRank7Name`) VALUES
(1, 'Fort Carson Sheriff\'s Office', 2, 'Cadet', 'Sheriff I', 'Sheriff II', 'Sergeant I', 'Sergeant II', 'Commander', 'Chief of Police'),
(2, 'Fort Carson EMS', 2, 'EMS Cadet', 'EMS Responder I', 'EMS Responder II', 'EMS Sergeant I', 'EMS Sergeant II', 'Station Commander', 'Station Chief');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `jID` int(11) NOT NULL,
  `jName` varchar(32) NOT NULL,
  `jPay` int(11) NOT NULL,
  `jobIX` float NOT NULL,
  `jobIY` float NOT NULL,
  `jobIZ` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`jID`, `jName`, `jPay`, `jobIX`, `jobIY`, `jobIZ`) VALUES
(1, 'Postman', 8, -86.6549, 1132.43, 19.5934),
(2, 'Garbageman', 12, 263.49, 1400.43, 10.5003),
(3, 'Busdriver', 500, -240.848, 1210.12, 20.3816);

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vID` int(11) NOT NULL,
  `vModelId` int(11) NOT NULL,
  `vOwner` varchar(32) NOT NULL,
  `vFuel` int(11) NOT NULL,
  `vJobId` int(11) NOT NULL,
  `vFacId` int(11) NOT NULL,
  `vPlate` varchar(32) NOT NULL,
  `vParkedX` float NOT NULL,
  `vParkedY` float NOT NULL,
  `vParkedZ` float NOT NULL,
  `vAngle` float NOT NULL,
  `vRentalState` int(11) NOT NULL,
  `vRentalPrice` int(11) NOT NULL,
  `vColor1` int(11) NOT NULL,
  `vColor2` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`vID`, `vModelId`, `vOwner`, `vFuel`, `vJobId`, `vFacId`, `vPlate`, `vParkedX`, `vParkedY`, `vParkedZ`, `vAngle`, `vRentalState`, `vRentalPrice`, `vColor1`, `vColor2`) VALUES
(1, 462, 'NULL', 100, 1, 0, 'RPOST1R', -80.5683, 1132.52, 19.8, 90, 1, 200, 1, 1),
(2, 462, 'NULL', 100, 1, 0, 'RPOST2R', -80.5683, 1128.49, 19.8, 90, 1, 200, 1, 1),
(3, 462, 'NULL', 100, 1, 0, 'RPOST3R', -80.5683, 1124.51, 19.8, 90, 1, 200, 1, 1),
(4, 462, 'NULL', 100, 1, 0, 'RPOST4R', -80.5683, 1120.42, 19.8, 90, 1, 200, 1, 1),
(5, 462, 'NULL', 100, 1, 0, 'RPOST5R', -80.5683, 1116.56, 19.8, 90, 1, 200, 1, 1),
(6, 462, 'NULL', 100, 0, 0, 'RGARB1R', -80.5683, 1112.7, 19.8, 90, 1, 200, 1, 1),
(7, 408, 'NULL', 100, 2, 0, 'RGARB2R', 282.319, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(8, 408, 'NULL', 100, 2, 0, 'RGARB3R\r\n', 276.352, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(9, 408, 'NULL', 100, 2, 0, 'RGARB4R\r\n', 270.268, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(10, 408, 'NULL', 100, 2, 0, 'RGARB5R\r\n', 264.652, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(11, 431, 'NULL', 100, 3, 0, 'RBUS1R\r\n', 10000, 10000, 10000, 180, 0, 0, 1, 1),
(12, 431, 'NULL', 100, 3, 0, 'RBUS2R\r\n', -235.389, 1217.78, 19.9383, 180, 0, 0, 1, 1),
(13, 431, 'NULL', 100, 3, 0, 'RBUS3R\r\n', -229.89, 1217.78, 19.9383, 180, 0, 0, 1, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `factions`
--
ALTER TABLE `factions`
  ADD PRIMARY KEY (`fID`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`jID`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `factions`
--
ALTER TABLE `factions`
  MODIFY `fID` int(32) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `jID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `vID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
