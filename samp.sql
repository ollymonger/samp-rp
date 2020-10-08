-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 21, 2020 at 02:19 PM
-- Server version: 10.1.34-MariaDB
-- PHP Version: 7.2.7

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
  `pPhoneModel` int(11) NOT NULL,
  `pPhoneNumber` int(11) NOT NULL,
  `pGpsModel` int(11) NOT NULL,
  `pFactionId` int(11) NOT NULL,
  `pFactionRank` int(11) NOT NULL,
  `pFactionRankname` varchar(32) DEFAULT NULL,
  `pFactionPay` int(11) NOT NULL,
  `pDutyClothes` int(11) NOT NULL,
  `pJobId` int(11) NOT NULL,
  `pJobPay` int(11) NOT NULL,
  `pFines` int(11) NOT NULL,
  `pMostRecentFine` varchar(32) NOT NULL,
  `pWantedLevel` int(11) NOT NULL,
  `pMostRecentWantedReason` varchar(32) NOT NULL,
  `pInPrisonType` int(11) NOT NULL,
  `pPrisonTimer` int(11) NOT NULL,
  `pWeedAmount` int(11) NOT NULL,
  `pCokeAmount` int(11) NOT NULL,
  `pCigAmount` int(11) NOT NULL,
  `pRopeAmount` int(11) NOT NULL,
  `pHasMask` int(11) NOT NULL,
  `pDrivingLicense` int(11) NOT NULL,
  `pHeavyLicense` int(11) NOT NULL,
  `pPilotLicense` int(11) NOT NULL,
  `pGunLicense` int(11) NOT NULL,
  `pWeaponSlot1` int(11) NOT NULL,
  `pWeaponSlot1Ammo` int(11) NOT NULL,
  `pWeaponSlot2` int(11) NOT NULL,
  `pWeaponSlot2Ammo` int(11) NOT NULL,
  `pWeaponSlot3` int(11) NOT NULL,
  `pWeaponSlot3Ammo` int(11) NOT NULL,
  `pVehicleSlots` int(11) NOT NULL,
  `pVehicleSlotsUsed` int(11) NOT NULL,
  `pPreferredSpawn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`ID`, `pName`, `pPassword`, `pEmail`, `pAdminLevel`, `pLevel`, `pExp`, `pRegion`, `pHealth`, `pArmour`, `pGender`, `pSkin`, `pAge`, `pBank`, `pCash`, `pPayTimer`, `pPhoneModel`, `pPhoneNumber`, `pGpsModel`, `pFactionId`, `pFactionRank`, `pFactionRankname`, `pFactionPay`, `pDutyClothes`, `pJobId`, `pJobPay`, `pFines`, `pMostRecentFine`, `pWantedLevel`, `pMostRecentWantedReason`, `pInPrisonType`, `pPrisonTimer`, `pWeedAmount`, `pCokeAmount`, `pCigAmount`, `pRopeAmount`, `pHasMask`, `pDrivingLicense`, `pHeavyLicense`, `pPilotLicense`, `pGunLicense`, `pWeaponSlot1`, `pWeaponSlot1Ammo`, `pWeaponSlot2`, `pWeaponSlot2Ammo`, `pWeaponSlot3`, `pWeaponSlot3Ammo`, `pVehicleSlots`, `pVehicleSlotsUsed`, `pPreferredSpawn`) VALUES
(3, 'Olly', '$2y$12$aCm2PzXMY', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(4, 'Olly123', '$2y$12$bjHwP0vIM', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(5, 'Olly1', '$2y$12$PyPsXVbAb', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(6, 'Olly12', '$2y$12$OhDsThPvZ', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(7, 'test1', '$2y$12$RDfRRSeuRlDpaVLLaRjkSOgnx3FNJ3nKzrX39w5zMOjY/.9PvQWui', 'helloworld@world.com', 0, 0, 0, '', 42, 0, 0, 0, 0, 0, 80000, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(8, 'testemaildialog', '$2y$12$ZELqcCPMYiTzOiDJRCjxQe7WBZbdvRaBjY8G4ahSzcFHuUEhBNs1u', 'helloworld@world.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(9, 'testemaildialog2', '$2y$12$Ki3tK0vzWSvpakTkQzfAP.dd559FY6izEk5MI9I8oKOQdktoZCJee', 'hi_there@test.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(10, 'testemaildialog3', '$2y$12$XCCxREftXyDiKzTyKi7DTu/nVvquj3B2IpAvqWa4TqtkSyeSnojnq', 'notrightemail.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(11, 'testemaildialog4', '$2y$12$cFTrYEfCWzmxWhCwRVTNQ.gtAMRVqWX2qZ6WwUT8OSri/JyaXOyRu', 'HI.COM', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(12, 'testemaildialog5', '$2y$12$Q1PDZRbQYivqZUnfcjmzYOFs2kxwsZ3baXo5gUAWOzsUUI95iFIZ.', 'hello@gmail.com', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(13, 'testdialog1', '$2y$12$YizuZSz1KSuxOyPBMVXVQu8hs8LFpsgsT747otZRFhso/b497ZTim', 'olly@yllo.co.uk', 0, 0, 0, 'America', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(14, 'testdialog12', '$2y$12$ayjfOTXLT03OcCLYO0LQL.eoU6gBTipidOWmuwhkM7NZY5HrJVSRO', 'hello@gmail.com', 0, 0, 0, 'NULL', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(15, 'testdialog123', '$2y$12$ZCXXPxTGQTfLZiHJTkzRbeiAxOf6qcpH6VNdo2v7xC1VsNot73hBy', 'hello@gmail.com', 0, 0, 0, 'region', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(16, 'testdialog11', '$2y$12$Kyn0bhTYRTDxbFPNa1fwZeGR2UvPX5iFiOyB4JDLRG5yrLlKnd4cy', 'olly@yllo.co.uk', 0, 0, 0, 'United Kingdom', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(17, 'testdialoga', '$2y$12$OUy1Z0P1RDjhXkr3REDKSOQVsqBHfQDHEqwInPdnjvPEISAK/3OLa', 'gmail@gmail.com', 0, 0, 0, 'America', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(18, 'testdialogb', '$2y$12$TRH0cCrHZVDlRh/uX1LhPOGOzdQD5fIUo/piDreo8/G/n9cdpDU5m', 'example@example.com', 0, 0, 0, 'America', 100, 0, 0, 0, 0, 0, 1000, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(19, 'testdialogc', '$2y$12$QDDrYibDbTblZ1jfPy60butWDkKhIn7fzb6/6qog6cXvLCTYvMbwC', 'example@example.com', 0, 0, 0, 'America', 100, 0, 1, 167, 27, 0, 50, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(20, 'quiztest1', '$2y$12$cSDOOkf3ThXATj.0XhDDXOd1SS1fz0i/dZ4iuAQYph2EOT1gCtRMu', '@', 0, 0, 0, 'Los Santos', 100, 0, 1, 23, 28, 0, 1000, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(21, 'testaccounts_1', '$2y$12$KjjyaDTEQBe1LTTDUUvGaOTqZsuFTWhrHHEa6fv0KiASgtEyJscGG', 'gmail@gmail.com', 0, 0, 0, 'Los Santos', 100, 0, 1, 72, 28, 0, 1000, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(22, 'testaccounts_2', '$2y$12$XFDYQjXvbjThLR/xKkjRTOarF5sW7jrTtLDUAQoj5KzHKM/NZ3rRa', 'olly@yllo.co.uk', 6, 4, 4, 'Los Santos', 90, 0, 1, 73, 28, 12483, 541190, 46, 1, 125243, 2, 1, 7, 'Chief of Police', 0, 311, 1, 0, 200, 'LOL', 6, 'evading police x2 ', 0, 0, 7, 1, 20, 2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 4, 1, 3100),
(23, 'testaccounts_3', '$2y$12$PEeuZSHTTVnjKDb2UEDWSunyPVyEv7lKRwTEZihlRmQmObQ2NP8n.', '@', 0, 1, 1, 'Los Santos', 100, 0, 1, 170, 28, 0, 1000, 60, 0, 0, 0, 0, 0, '', 0, 0, 1, 0, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(24, 'testaccounts_6', '$2y$12$YzDJSCnlPVH/ShTMXyzwOOEfQvuVt/Ty88apHkAAldDO5rmIFSJvi', '@', 0, 1, 1, 'america', 95, 0, 1, 24, 28, 0, 800, 55, 0, 0, 0, 0, 0, '', 0, 0, 1, 172, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(25, 'testaccount_12', '$2y$12$MUbIMBbtUDjFaTHrSS3sbeR/.2zeCYsrJAsxX95yyYweQUtXfsQRK', '@', 0, 1, 1, 'America', 100, 0, 1, 60, 28, 0, 1000, 59, 0, 0, 0, 0, 0, '', 0, 0, 1, 50, 0, '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(26, 'Jason_McCabe', '$2y$12$ZRDAbEjmahLXQCPALUH1LerUXLKuk1kdrGFdoZEBOzIzuWANiZ3HS', 'olly@yllo.co.uk', 0, 1, 2, 'America', 10, 0, 1, 24, 27, 250, 72, 44, 2, 125242, 0, 0, 0, '', 0, 0, 0, 157, 0, '', 0, '', 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `businesses`
--

CREATE TABLE `businesses` (
  `bId` int(32) NOT NULL,
  `bName` varchar(32) NOT NULL,
  `bAddress` int(255) NOT NULL,
  `bPrice` int(255) NOT NULL,
  `bSalary` int(255) NOT NULL,
  `bOwner` varchar(32) NOT NULL,
  `bType` int(11) NOT NULL,
  `bIntId` int(11) NOT NULL,
  `bInfoX` float NOT NULL,
  `bInfoY` float NOT NULL,
  `bInfoZ` float NOT NULL,
  `bEntX` float NOT NULL,
  `bEntY` float NOT NULL,
  `bEntZ` float NOT NULL,
  `bUseX` float NOT NULL,
  `bUseY` float NOT NULL,
  `bUseZ` float NOT NULL,
  `bExitX` float NOT NULL,
  `bExitY` float NOT NULL,
  `bExitZ` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`bId`, `bName`, `bAddress`, `bPrice`, `bSalary`, `bOwner`, `bType`, `bIntId`, `bInfoX`, `bInfoY`, `bInfoZ`, `bEntX`, `bEntY`, `bEntZ`, `bUseX`, `bUseY`, `bUseZ`, `bExitX`, `bExitY`, `bExitZ`) VALUES
(6, 'Hardware-Store', 3001, 150000, 0, 'NULL', 1, 6, -184.885, 1165.57, 19.7422, -181.408, 1163.18, 19.75, 0, 0, 0, -2240.47, 137.06, 1035.41),
(7, 'Ammunation', 3002, 200000, 0, 'NULL', 3, 6, -310.461, 824.495, 14.2422, -314.651, 830.114, 14.2422, 0, 0, 0, 296.92, -108.072, 1001.52),
(8, '24/7-GENERAL', 3003, 75000, 14, 'NULL', 2, 16, -201.185, 1134.83, 19.7422, -204.132, 1137.61, 19.7422, 0, 0, 0, -25.1326, -139.067, 1003.55),
(9, 'Euro-Cars', 3004, 175000, 0, 'NULL', 4, 0, -72.2459, 1155.31, 19.7422, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `drugprices`
--

CREATE TABLE `drugprices` (
  `drugId` int(32) NOT NULL,
  `drugName` varchar(32) NOT NULL,
  `drugAmount` int(32) NOT NULL,
  `drugPrice` int(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `drugprices`
--

INSERT INTO `drugprices` (`drugId`, `drugName`, `drugAmount`, `drugPrice`) VALUES
(1, 'Weed', 65, 20),
(2, 'Cocaine', 65, 100);

-- --------------------------------------------------------

--
-- Table structure for table `factions`
--

CREATE TABLE `factions` (
  `fID` int(32) NOT NULL,
  `fName` varchar(32) NOT NULL,
  `fAddress` int(11) NOT NULL,
  `fLeader` varchar(32) DEFAULT 'NULL',
  `fType` int(11) NOT NULL,
  `fPrice` int(11) NOT NULL,
  `fRank1Name` varchar(32) NOT NULL,
  `fRank2Name` varchar(32) NOT NULL,
  `fRank3Name` varchar(32) NOT NULL,
  `fRank4Name` varchar(32) NOT NULL,
  `fRank5Name` varchar(32) NOT NULL,
  `fRank6Name` varchar(32) NOT NULL,
  `fRank7Name` varchar(32) NOT NULL,
  `fInfoX` float NOT NULL,
  `fInfoY` float NOT NULL,
  `fInfoZ` float NOT NULL,
  `fDutyX` float NOT NULL,
  `fDutyY` float NOT NULL,
  `fDutyZ` float NOT NULL,
  `fClothesX` float NOT NULL,
  `fClothesY` float NOT NULL,
  `fClothesZ` float NOT NULL,
  `fEntX` float NOT NULL,
  `fEntY` float NOT NULL,
  `fEntZ` float NOT NULL,
  `fExitX` float NOT NULL,
  `fExitY` float NOT NULL,
  `fExitZ` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `factions`
--

INSERT INTO `factions` (`fID`, `fName`, `fAddress`, `fLeader`, `fType`, `fPrice`, `fRank1Name`, `fRank2Name`, `fRank3Name`, `fRank4Name`, `fRank5Name`, `fRank6Name`, `fRank7Name`, `fInfoX`, `fInfoY`, `fInfoZ`, `fDutyX`, `fDutyY`, `fDutyZ`, `fClothesX`, `fClothesY`, `fClothesZ`, `fEntX`, `fEntY`, `fEntZ`, `fExitX`, `fExitY`, `fExitZ`) VALUES
(1, 'Fort Carson Sheriff\'s Office', 2001, 'NULL', 2, 1350000, 'Cadet', 'Sheriff I', 'Sheriff II', 'Sergeant I', 'Sergeant II', 'Commander', 'Chief of Police', -208.158, 973.9, 18.8395, -2692.07, 2637.33, 4087.79, -2695.22, 2636.89, 4087.79, -217.924, 979.2, 19.7869, -2697.2, 2646.27, 4088.08),
(2, 'Fort Carson EMS', 2002, 'NULL', 2, 1350000, 'EMS Cadet', 'EMS Responder I', 'EMS Responder II', 'EMS Sergeant I', 'EMS Sergeant II', 'Station Commander', 'Station Chief', -319.788, 1055.7, 19.3177, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `houses`
--

CREATE TABLE `houses` (
  `hId` int(11) NOT NULL,
  `hAddress` int(11) NOT NULL,
  `hType` int(11) NOT NULL,
  `hOwner` varchar(32) NOT NULL,
  `hPrice` int(11) NOT NULL,
  `hLockedState` int(11) NOT NULL,
  `hInfoX` float NOT NULL,
  `hInfoY` float NOT NULL,
  `hInfoZ` float NOT NULL,
  `hEntX` float NOT NULL,
  `hEntY` float NOT NULL,
  `hEntZ` float NOT NULL,
  `hExitX` float NOT NULL,
  `hExitY` float NOT NULL,
  `hExitZ` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `houses`
--

INSERT INTO `houses` (`hId`, `hAddress`, `hType`, `hOwner`, `hPrice`, `hLockedState`, `hInfoX`, `hInfoY`, `hInfoZ`, `hEntX`, `hEntY`, `hEntZ`, `hExitX`, `hExitY`, `hExitZ`) VALUES
(15, 3100, 2, 'testaccounts_2', 100000, 0, -263.862, 1126.99, 19.9598, -261.214, 1120.77, 20.9399, 2454.72, -1700.87, 1013.52),
(16, 3101, 1, 'NULL', 110000, 0, -251.492, 1087.28, 19.8786, -258.671, 1083.77, 20.9399, 2527.65, -1679.39, 1015.5),
(17, 3102, 5, 'NULL', 105000, 0, -264.37, 1050.31, 19.8238, -259.196, 1043.74, 20.9399, 2350.34, -1181.65, 1027.98);

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
(3, 'Busdriver', 500, -240.848, 1210.12, 20.3816),
(4, 'Drugdealer', 0, 796.615, 1692.96, 5.28125);

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vID` int(11) NOT NULL,
  `vModelId` int(11) NOT NULL,
  `vOwner` varchar(32) NOT NULL,
  `vFuel` int(11) NOT NULL DEFAULT '100',
  `vJobId` int(11) NOT NULL,
  `vFacId` int(11) NOT NULL,
  `vBusId` int(11) NOT NULL,
  `vPlate` varchar(32) NOT NULL,
  `vFines` int(11) NOT NULL,
  `vMostRecentFine` varchar(32) NOT NULL,
  `vImpounded` int(11) NOT NULL,
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

INSERT INTO `vehicles` (`vID`, `vModelId`, `vOwner`, `vFuel`, `vJobId`, `vFacId`, `vBusId`, `vPlate`, `vFines`, `vMostRecentFine`, `vImpounded`, `vParkedX`, `vParkedY`, `vParkedZ`, `vAngle`, `vRentalState`, `vRentalPrice`, `vColor1`, `vColor2`) VALUES
(1, 462, 'NULL', 100, 1, 0, 0, 'RPOST1R', 0, '', 0, -80.5683, 1132.52, 19.8, 90, 1, 200, 1, 1),
(2, 462, 'NULL', 100, 1, 0, 0, 'RPOST2R', 0, '', 0, -80.5683, 1128.49, 19.8, 90, 1, 200, 1, 1),
(3, 462, 'NULL', 100, 1, 0, 0, 'RPOST3R', 0, '', 0, -80.5683, 1124.51, 19.8, 90, 1, 200, 1, 1),
(4, 462, 'NULL', 100, 1, 0, 0, 'RPOST4R', 0, '', 0, -80.5683, 1120.42, 19.8, 90, 1, 200, 1, 1),
(5, 462, 'NULL', 100, 1, 0, 0, 'RPOST5R', 0, '', 0, -80.5683, 1116.56, 19.8, 90, 1, 200, 1, 1),
(6, 462, 'NULL', 100, 0, 0, 0, 'RGARB1R', 0, '', 0, -80.5683, 1112.7, 19.8, 90, 1, 200, 1, 1),
(7, 408, 'NULL', 100, 2, 0, 0, 'RGARB2R', 0, '', 0, 282.319, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(8, 408, 'NULL', 100, 2, 0, 0, 'RGARB3R\r\n', 0, '', 0, 276.352, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(9, 408, 'NULL', 100, 2, 0, 0, 'RGARB4R\r\n', 0, '', 0, 270.268, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(10, 408, 'NULL', 100, 2, 0, 0, 'RGARB5R\r\n', 0, '', 0, 264.652, 1390.42, 11.6413, 0, 1, 70, 1, 1),
(11, 431, 'NULL', 100, 3, 0, 0, 'RBUS1R', 0, '', 0, 10000, 10000, 10000, 180, 0, 0, 1, 1),
(12, 431, 'NULL', 100, 3, 0, 0, 'RBUS2R', 1, 'TEST', 0, -235.389, 1217.78, 19.9383, 180, 0, 0, 1, 1),
(13, 525, 'NULL', 100, 3, 0, 0, 'RBUS3R', 101, 'LOL', 1, -168.93, 1022.76, 19.6167, 180, 1, 150, 1, 1),
(14, 561, 'NULL', 100, 0, 0, 4, '12345', 0, '', 0, -92.5765, 1156.04, 19.7422, 270.717, 1, 0, 0, 0),
(15, 561, 'NULL', 100, 0, 0, 4, 'E38C92R', 0, '', 0, -93.411, 1159.84, 19.7422, 271.343, 1, 400, 77, 77),
(16, 561, 'NULL', 100, 0, 0, 4, 'E64C19R', 0, '', 0, -93.0535, 1163.35, 19.7422, 271.238, 1, 400, 77, 77),
(17, 561, 'NULL', 100, 0, 0, 4, 'E57C21R', 0, '', 0, -85.7865, 1163.45, 19.7422, 268.266, 1, 400, 77, 77),
(18, 400, 'testaccounts_2', 100, 0, 0, 0, 'HFBF', 0, '', 0, -151.409, 1206.33, 19.7422, 90, 2, 0, 0, 0),
(19, 412, 'testaccounts_2', 100, 0, 0, 0, 'CSY-.,/-/', 0, '', 0, -151.409, 1206.33, 19.7422, 90, 2, 0, 0, 0),
(20, 412, 'testaccounts_2', 100, 0, 0, 0, 'AOB2778', 0, '', 0, -151.409, 1206.33, 19.7422, 90, 2, 0, 0, 0),
(21, 598, 'DONOTUSE', 100, 0, 1, 0, 'AOB2771', 0, 'test', 0, 10000, 1000, 100000, 90, 2, 0, 0, 77),
(22, 598, 'NULL', 100, 0, 1, 0, 'PD9182', 0, '', 0, -211.435, 1000.15, 19.6715, 89.6782, 2, 0, 0, 77),
(23, 598, 'NULL', 100, 0, 1, 0, 'PD8529', 0, '', 0, -210.845, 995.489, 19.579, 90.4357, 0, 0, 0, 77),
(24, 598, 'NULL', 100, 0, 1, 0, 'PD8690', 0, '', 0, -210.599, 991.45, 19.4956, 89.9469, 0, 0, 0, 77),
(25, 598, 'NULL', 100, 0, 1, 0, 'PD3921', 0, '', 0, -210.43, 987.44, 19.4165, 86.2595, 0, 0, 0, 77),
(26, 599, 'NULL', 100, 0, 1, 0, 'PDS001', 0, '', 0, -227.349, 999.704, 19.5952, 268.212, 0, 0, 1, 108),
(27, 599, 'NULL', 100, 0, 1, 0, 'PDS002', 0, '', 0, -227.548, 995.911, 19.5551, 269.152, 0, 0, 1, 108),
(28, 599, 'NULL', 100, 0, 1, 0, 'PDS003', 0, '', 0, -227.893, 992.429, 19.5271, 266.958, 0, 0, 1, 108),
(29, 525, 'NULL', 100, 0, 1, 0, 'PDT002', 0, '', 0, -227.997, 988.194, 19.6412, 268.356, 0, 0, 0, 77),
(30, 525, 'NULL', 100, 0, 1, 0, 'PDT001', 0, '', 0, -229.222, 983.478, 19.5781, 6.1457, 0, 0, 0, 77);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
  ADD PRIMARY KEY (`bId`);

--
-- Indexes for table `drugprices`
--
ALTER TABLE `drugprices`
  ADD PRIMARY KEY (`drugId`);

--
-- Indexes for table `factions`
--
ALTER TABLE `factions`
  ADD PRIMARY KEY (`fID`);

--
-- Indexes for table `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`hId`);

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
  MODIFY `bId` int(32) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `drugprices`
--
ALTER TABLE `drugprices`
  MODIFY `drugId` int(32) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `factions`
--
ALTER TABLE `factions`
  MODIFY `fID` int(32) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `houses`
--
ALTER TABLE `houses`
  MODIFY `hId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `jID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `vID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
