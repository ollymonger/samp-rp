-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 07, 2020 at 04:19 PM
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
  `pRegion` varchar(32) NOT NULL,
  `pHealth` float NOT NULL,
  `pArmour` float NOT NULL,
  `pGender` int(11) NOT NULL,
  `pSkin` int(11) NOT NULL,
  `pAge` int(11) NOT NULL,
  `pBank` int(64) NOT NULL,
  `pCash` int(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`ID`, `pName`, `pPassword`, `pEmail`, `pRegion`, `pHealth`, `pArmour`, `pGender`, `pSkin`, `pAge`, `pBank`, `pCash`) VALUES
(3, 'Olly', '$2y$12$aCm2PzXMY', 'helloworld@world.com', '', 0, 0, 0, 0, 0, 0, 0),
(4, 'Olly123', '$2y$12$bjHwP0vIM', 'helloworld@world.com', '', 0, 0, 0, 0, 0, 0, 0),
(5, 'Olly1', '$2y$12$PyPsXVbAb', 'helloworld@world.com', '', 0, 0, 0, 0, 0, 0, 0),
(6, 'Olly12', '$2y$12$OhDsThPvZ', 'helloworld@world.com', '', 0, 0, 0, 0, 0, 0, 0),
(7, 'test1', '$2y$12$RDfRRSeuRlDpaVLLaRjkSOgnx3FNJ3nKzrX39w5zMOjY/.9PvQWui', 'helloworld@world.com', '', 42, 0, 0, 0, 0, 0, 80000),
(8, 'testemaildialog', '$2y$12$ZELqcCPMYiTzOiDJRCjxQe7WBZbdvRaBjY8G4ahSzcFHuUEhBNs1u', 'helloworld@world.com', '', 0, 0, 0, 0, 0, 0, 0),
(9, 'testemaildialog2', '$2y$12$Ki3tK0vzWSvpakTkQzfAP.dd559FY6izEk5MI9I8oKOQdktoZCJee', 'hi_there@test.com', '', 0, 0, 0, 0, 0, 0, 0),
(10, 'testemaildialog3', '$2y$12$XCCxREftXyDiKzTyKi7DTu/nVvquj3B2IpAvqWa4TqtkSyeSnojnq', 'notrightemail.com', '', 0, 0, 0, 0, 0, 0, 0),
(11, 'testemaildialog4', '$2y$12$cFTrYEfCWzmxWhCwRVTNQ.gtAMRVqWX2qZ6WwUT8OSri/JyaXOyRu', 'HI.COM', '', 0, 0, 0, 0, 0, 0, 0),
(12, 'testemaildialog5', '$2y$12$Q1PDZRbQYivqZUnfcjmzYOFs2kxwsZ3baXo5gUAWOzsUUI95iFIZ.', 'hello@gmail.com', '', 0, 0, 0, 0, 0, 0, 0),
(13, 'testdialog1', '$2y$12$YizuZSz1KSuxOyPBMVXVQu8hs8LFpsgsT747otZRFhso/b497ZTim', 'olly@yllo.co.uk', 'America', 0, 0, 0, 0, 0, 0, 0),
(14, 'testdialog12', '$2y$12$ayjfOTXLT03OcCLYO0LQL.eoU6gBTipidOWmuwhkM7NZY5HrJVSRO', 'hello@gmail.com', 'NULL', 0, 0, 0, 0, 0, 0, 0),
(15, 'testdialog123', '$2y$12$ZCXXPxTGQTfLZiHJTkzRbeiAxOf6qcpH6VNdo2v7xC1VsNot73hBy', 'hello@gmail.com', 'region', 0, 0, 0, 0, 0, 0, 0),
(16, 'testdialog11', '$2y$12$Kyn0bhTYRTDxbFPNa1fwZeGR2UvPX5iFiOyB4JDLRG5yrLlKnd4cy', 'olly@yllo.co.uk', 'United Kingdom', 0, 0, 0, 0, 0, 0, 0),
(17, 'testdialoga', '$2y$12$OUy1Z0P1RDjhXkr3REDKSOQVsqBHfQDHEqwInPdnjvPEISAK/3OLa', 'gmail@gmail.com', 'America', 0, 0, 0, 0, 0, 0, 0),
(18, 'testdialogb', '$2y$12$TRH0cCrHZVDlRh/uX1LhPOGOzdQD5fIUo/piDreo8/G/n9cdpDU5m', 'example@example.com', 'America', 100, 0, 0, 0, 0, 0, 1000),
(19, 'testdialogc', '$2y$12$QDDrYibDbTblZ1jfPy60butWDkKhIn7fzb6/6qog6cXvLCTYvMbwC', 'example@example.com', 'America', 100, 0, 1, 167, 27, 0, 50);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
