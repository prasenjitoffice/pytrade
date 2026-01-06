-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 06, 2026 at 06:06 AM
-- Server version: 8.0.42-0ubuntu0.20.04.1
-- PHP Version: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pytrade`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLongTermFibboLevels` (IN `startDate` DATE, IN `endDate` DATE, IN `equityId` INT)   BEGIN
    SELECT 
        low_point AS "L000",
        low_point + ((high_point - low_point) * 0.236) AS "L236",
        low_point + ((high_point - low_point) * 0.382) AS "L382",
        low_point + ((high_point - low_point) * 0.5) AS "L500",
        low_point + ((high_point - low_point) * 0.618) AS "L618",
        low_point + ((high_point - low_point) * 0.786) AS "L786",
        high_point AS "L1000",
        low_point + ((high_point - low_point) * 1.236) AS "L1236",
        low_point + ((high_point - low_point) * 1.618) AS "L1618", 
        low_point + ((high_point - low_point) * 2.618) AS "L2618" 
    FROM (
        SELECT 
            lt_main.equity_id,
            MIN(CASE WHEN lt_main.position = 'low' THEN lt_main.value END) AS low_point,
            MAX(CASE WHEN lt_main.position = 'high' THEN lt_main.value END) AS high_point
        FROM lt_top_down_position lt_main 
        WHERE DATE_FORMAT(lt_main.created_at, "%Y-%m-%d") BETWEEN startDate AND endDate
        AND (lt_main.equity_id = equityId OR equityId = 0)
        GROUP BY lt_main.equity_id
    ) AS t;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `percentage` (`ivalue` FLOAT, `x` FLOAT) RETURNS FLOAT DETERMINISTIC BEGIN
		DECLARE result FLOAT;
        SET result = TRUNCATE(ivalue * x/100,2);
        RETURN result;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `api_logs`
--

CREATE TABLE `api_logs` (
  `id` bigint NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `user_api_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `http_status` int NOT NULL,
  `response_time_ms` int DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_group`
--

INSERT INTO `auth_group` (`id`, `name`) VALUES
(1, 'Trader');

-- --------------------------------------------------------

--
-- Table structure for table `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_group_permissions`
--

INSERT INTO `auth_group_permissions` (`id`, `group_id`, `permission_id`) VALUES
(2, 1, 21),
(3, 1, 22),
(4, 1, 23),
(1, 1, 24);

-- --------------------------------------------------------

--
-- Table structure for table `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session');

-- --------------------------------------------------------

--
-- Table structure for table `auth_user`
--

CREATE TABLE `auth_user` (
  `id` int NOT NULL,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `first_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `last_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_user`
--

INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`) VALUES
(2, 'pbkdf2_sha256$1000000$pvZHKyzwtLcOHaPXaxIXtI$MqVKa5duFoSj3kMIPTnBN4dvXNwLL4FvNl7/8joY1KE=', '2026-01-04 06:29:01.318207', 1, 'admin', 'Prasenjit', 'Banik', 'admin@123', 1, 1, '2026-01-01 14:57:52.615357'),
(3, 'pbkdf2_sha256$1000000$EItQo1I8EAzPwDLTAVKUG2$C6kxWQNMfryWPEd79dCjO47yL+kOybtVzP025tB0Yoc=', '2026-01-05 04:48:56.890467', 0, 'pbanik', 'Prasenjit', 'Banik', 'trader@gmail.com', 1, 1, '2026-01-01 15:03:17.000000');

-- --------------------------------------------------------

--
-- Table structure for table `auth_user_groups`
--

CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_user_groups`
--

INSERT INTO `auth_user_groups` (`id`, `user_id`, `group_id`) VALUES
(1, 3, 1);

-- --------------------------------------------------------

--
-- Table structure for table `auth_user_user_permissions`
--

CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `object_repr` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2026-01-01 15:06:50.366132', '4', 'pytrade', 1, '[{\"added\": {}}]', 4, 2),
(2, '2026-01-01 15:09:59.701596', '1', 'Trader', 1, '[{\"added\": {}}]', 3, 2),
(3, '2026-01-01 15:11:10.220488', '3', 'trader', 2, '[{\"changed\": {\"fields\": [\"Email address\", \"Groups\"]}}]', 4, 2),
(4, '2026-01-01 15:11:33.630235', '3', 'pbanik', 2, '[{\"changed\": {\"fields\": [\"Username\"]}}]', 4, 2),
(5, '2026-01-04 06:25:51.100335', '3', 'pbanik', 2, '[{\"changed\": {\"fields\": [\"password\"]}}]', 4, 2),
(6, '2026-01-04 06:27:21.187657', '3', 'pbanik', 2, '[{\"changed\": {\"fields\": [\"password\"]}}]', 4, 2),
(7, '2026-01-04 06:29:27.467061', '3', 'pbanik', 2, '[{\"changed\": {\"fields\": [\"Staff status\"]}}]', 4, 2),
(8, '2026-01-04 06:29:49.424352', '4', 'pytrade', 3, '', 4, 2);

-- --------------------------------------------------------

--
-- Table structure for table `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int NOT NULL,
  `app_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Table structure for table `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL,
  `app` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2026-01-01 14:47:38.992484'),
(2, 'auth', '0001_initial', '2026-01-01 14:47:57.136966'),
(3, 'admin', '0001_initial', '2026-01-01 14:48:01.226720'),
(4, 'admin', '0002_logentry_remove_auto_add', '2026-01-01 14:48:01.344958'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2026-01-01 14:48:01.456335'),
(6, 'contenttypes', '0002_remove_content_type_name', '2026-01-01 14:48:04.991517'),
(7, 'auth', '0002_alter_permission_name_max_length', '2026-01-01 14:48:06.492982'),
(8, 'auth', '0003_alter_user_email_max_length', '2026-01-01 14:48:06.704219'),
(9, 'auth', '0004_alter_user_username_opts', '2026-01-01 14:48:06.797240'),
(10, 'auth', '0005_alter_user_last_login_null', '2026-01-01 14:48:08.460121'),
(11, 'auth', '0006_require_contenttypes_0002', '2026-01-01 14:48:08.524215'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2026-01-01 14:48:08.630394'),
(13, 'auth', '0008_alter_user_username_max_length', '2026-01-01 14:48:10.804641'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2026-01-01 14:48:12.728212'),
(15, 'auth', '0010_alter_group_name_max_length', '2026-01-01 14:48:12.948957'),
(16, 'auth', '0011_update_proxy_permissions', '2026-01-01 14:48:13.054172'),
(17, 'auth', '0012_alter_user_first_name_max_length', '2026-01-01 14:48:14.939231'),
(18, 'sessions', '0001_initial', '2026-01-01 14:48:17.422486');

-- --------------------------------------------------------

--
-- Table structure for table `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('5pim39he8egv3vrnc9gha89js7lbki2x', '.eJxVjMsOwiAQRf-FtSGFkYG6dN9vaGZgkKqBpI-V8d-1SRe6veec-1IjbWsZt0XmcUrqokCdfjem-JC6g3Snems6trrOE-td0Qdd9NCSPK-H-3dQaCnfWqgDQnZIaCwHdhLOwQhblyAmdAG99UyuB88AFnMAjph9b8h0YrN6fwDf7Tej:1vcHfU:G0xXM-qdmh1wHFc9f1uno0p0o28LODmYfbR6q4jABFk', '2026-01-18 06:32:48.697535'),
('n79euft53a708ltkp2v0yzgjqg5e9ice', '.eJxVjMsOwiAQRf-FtSGFkYG6dN9vaGZgkKqBpI-V8d-1SRe6veec-1IjbWsZt0XmcUrqokCdfjem-JC6g3Snems6trrOE-td0Qdd9NCSPK-H-3dQaCnfWqgDQnZIaCwHdhLOwQhblyAmdAG99UyuB88AFnMAjph9b8h0YrN6fwDf7Tej:1vccWW:c_JF4z0uQcEd_GQxMAH_dokrvq7YA1BITS-PZJKt6E8', '2026-01-19 04:48:56.969698'),
('o825xn0plner1didj8donuej03iwng3h', 'e30:1vbNx0:G-n9DWbJ-FwWDMeR6K89OfZpn6KjO7JZMGQ39G2ZOSc', '2026-01-15 19:03:10.920550');

-- --------------------------------------------------------

--
-- Table structure for table `equity`
--

CREATE TABLE `equity` (
  `id` int NOT NULL,
  `instrument_key` varchar(50) NOT NULL,
  `exchange_token` varchar(20) NOT NULL,
  `tradingsymbol` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `last_price` float DEFAULT NULL,
  `expiry` int DEFAULT NULL,
  `strike` varchar(10) DEFAULT NULL,
  `tick_size` int DEFAULT NULL,
  `lot_size` int DEFAULT NULL,
  `instrument_type` varchar(20) DEFAULT NULL,
  `option_type` varchar(20) DEFAULT NULL,
  `exchange` varchar(20) DEFAULT NULL,
  `is_active` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `equity`
--

INSERT INTO `equity` (`id`, `instrument_key`, `exchange_token`, `tradingsymbol`, `name`, `last_price`, `expiry`, `strike`, `tick_size`, `lot_size`, `instrument_type`, `option_type`, `exchange`, `is_active`) VALUES
(118, 'NSE_EQ|INE466L01038', '13061', '360ONE', '360 ONE WAM LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(172, 'NSE_EQ|INE470A01017', '474', '3MINDIA', '3M INDIA LIMITED', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(2351, 'NSE_EQ|INE767A01016', '4481', 'AARTIDRUGS', 'AARTI DRUGS LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2352, 'NSE_EQ|INE769A01020', '7', 'AARTIIND', 'AARTI INDUSTRIES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2359, 'NSE_EQ|INE216P01012', '5385', 'AAVAS', 'AAVAS FINANCIERS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2361, 'NSE_EQ|INE117A01022', '13', 'ABB', 'ABB INDIA LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2362, 'NSE_EQ|INE358A01014', '17903', 'ABBOTINDIA', 'ABBOTT INDIA LIMITED', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(2363, 'NSE_EQ|INE674K01013', '21614', 'ABCAPITAL', 'ADITYA BIRLA CAPITAL LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2365, 'NSE_EQ|INE647O01011', '30108', 'ABFRL', 'ADITYA BIRLA FASHION & RT', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2396, 'NSE_EQ|INE012A01025', '22', 'ACC', 'ACC LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2402, 'NSE_EQ|INE128X01021', '12024', 'ACI', 'ARCHEAN CHEMICAL IND LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2404, 'NSE_EQ|INE423A01024', '25', 'ADANIENT', 'ADANI ENTERPRISES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2405, 'NSE_EQ|INE364U01010', '3563', 'ADANIGREEN', 'ADANI GREEN ENERGY LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2406, 'NSE_EQ|INE742F01042', '15083', 'ADANIPORTS', 'ADANI PORT & SEZ LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2407, 'NSE_EQ|INE814H01029', '17388', 'ADANIPOWER', 'ADANI POWER LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2417, 'NSE_EQ|INE0BWX01014', '9810', 'AETHER', 'AETHER INDUSTRIES LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2418, 'NSE_EQ|INE00WC01027', '11343', 'AFFLE', 'AFFLE 3I LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2432, 'NSE_EQ|INE212H01026', '13086', 'AIAENG', 'AIA ENGINEERING LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2438, 'NSE_EQ|INE031B01049', '8124', 'AJANTPHARM', 'AJANTA PHARMA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2454, 'NSE_EQ|INE540L01014', '11703', 'ALKEM', 'ALKEM LABORATORIES LTD.', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2455, 'NSE_EQ|INE150B01039', '4487', 'ALKYLAMINE', 'ALKYL AMINES CHEM. LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2466, 'NSE_EQ|INE371P01015', '1185', 'AMBER', 'AMBER ENTERPRISES (I) LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2469, 'NSE_EQ|INE079A01024', '1270', 'AMBUJACEM', 'AMBUJA CEMENTS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2481, 'NSE_EQ|INE732I01013', '324', 'ANGELONE', 'ANGEL ONE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2490, 'NSE_EQ|INE930P01018', '2829', 'ANURAS', 'ANUPAM RASAYAN INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2492, 'NSE_EQ|INE372A01015', '11491', 'APARINDS', 'APAR INDUSTRIES LTD.', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2496, 'NSE_EQ|INE702C01027', '25780', 'APLAPOLLO', 'APL APOLLO TUBES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2497, 'NSE_EQ|INE901L01018', '25328', 'APLLTD', 'ALEMBIC PHARMA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2499, 'NSE_EQ|INE437A01024', '157', 'APOLLOHOSP', 'APOLLO HOSPITALS ENTER. L', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2501, 'NSE_EQ|INE438A01022', '163', 'APOLLOTYRE', 'APOLLO TYRES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2504, 'NSE_EQ|INE852O01025', '5435', 'APTUS', 'APTUS VALUE HSG FIN I LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2525, 'NSE_EQ|INE439A01020', '5378', 'ASAHIINDIA', 'ASAHI INDIA GLASS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2534, 'NSE_EQ|INE208A01029', '212', 'ASHOKLEY', 'ASHOK LEYLAND LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2537, 'NSE_EQ|INE021A01026', '236', 'ASIANPAINT', 'ASIAN PAINTS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2543, 'NSE_EQ|INE914M01019', '1508', 'ASTERDM', 'ASTER DM HEALTHCARE LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2544, 'NSE_EQ|INE006I01046', '14418', 'ASTRAL', 'ASTRAL LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2551, 'NSE_EQ|INE399L01023', '6066', 'ATGL', 'ADANI TOTAL GAS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2553, 'NSE_EQ|INE100A01010', '263', 'ATUL', 'ATUL LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2555, 'NSE_EQ|INE949L01017', '21238', 'AUBANK', 'AU SMALL FINANCE BANK LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2558, 'NSE_EQ|INE406A01037', '275', 'AUROPHARMA', 'AUROBINDO PHARMA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2567, 'NSE_EQ|INE871C01038', '7936', 'AVANTIFEED', 'AVANTI FEEDS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2574, 'NSE_EQ|INE699H01024', '8110', 'AWL', 'AWL AGRI BUSINESS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2575, 'NSE_EQ|INE238A01034', '5900', 'AXISBANK', 'AXIS BANK LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2592, 'NSE_EQ|INE917I01010', '16669', 'BAJAJ-AUTO', 'BAJAJ AUTO LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2595, 'NSE_EQ|INE918I01026', '16675', 'BAJAJFINSV', 'BAJAJ FINSERV LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2598, 'NSE_EQ|INE118A01012', '305', 'BAJAJHLDNG', 'BAJAJ HOLDINGS & INVS LTD', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(2599, 'NSE_EQ|INE296A01032', '317', 'BAJFINANCE', 'BAJAJ FINANCE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2601, 'NSE_EQ|INE050E01027', '14501', 'BALAMINES', 'BALAJI AMINES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2604, 'NSE_EQ|INE787D01026', '335', 'BALKRISIND', 'BALKRISHNA IND. LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2608, 'NSE_EQ|INE119A01028', '341', 'BALRAMCHIN', 'BALRAMPUR CHINI MILLS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2612, 'NSE_EQ|INE545U01014', '2263', 'BANDHANBNK', 'BANDHAN BANK LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2615, 'NSE_EQ|INE028A01039', '4668', 'BANKBARODA', 'BANK OF BARODA', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2617, 'NSE_EQ|INE084A01016', '4745', 'BANKINDIA', 'BANK OF INDIA', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2620, 'NSE_EQ|INE373A01013', '368', 'BASF', 'BASF INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2622, 'NSE_EQ|INE176A01028', '371', 'BATAINDIA', 'BATA INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2623, 'NSE_EQ|INE462A01022', '17927', 'BAYERCROP', 'BAYER CROPSCIENCE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2627, 'NSE_EQ|INE050A01025', '380', 'BBTC', 'BOMBAY BURMAH TRADING COR', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2629, 'NSE_EQ|INE425B01027', '8833', 'BCG', 'BRIGHTCOM GROUP LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2632, 'NSE_EQ|INE171Z01026', '2144', 'BDL', 'BHARAT DYNAMICS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2637, 'NSE_EQ|INE263A01024', '383', 'BEL', 'BHARAT ELECTRONICS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2638, 'NSE_EQ|INE258A01024', '395', 'BEML', 'BEML LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2640, 'NSE_EQ|INE463A01038', '404', 'BERGEPAINT', 'BERGER PAINTS (I) LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2653, 'NSE_EQ|INE465A01025', '422', 'BHARATFORG', 'BHARAT FORGE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2657, 'NSE_EQ|INE397D01024', '10604', 'BHARTIARTL', 'BHARTI AIRTEL LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2658, 'NSE_EQ|INE257A01026', '438', 'BHEL', 'BHEL', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2660, 'NSE_EQ|INE00E101023', '11966', 'BIKAJI', 'BIKAJI FOODS INTERN LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2664, 'NSE_EQ|INE376G01013', '11373', 'BIOCON', 'BIOCON LIMITED.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2668, 'NSE_EQ|INE340A01012', '480', 'BIRLACORPN', 'BIRLA CORPORATION LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2676, 'NSE_EQ|INE153T01027', '17279', 'BLS', 'BLS INTL SERVS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2679, 'NSE_EQ|INE233B01017', '495', 'BLUEDART', 'BLUE DART EXPRESS LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2680, 'NSE_EQ|INE472A01039', '8311', 'BLUESTARCO', 'BLUE STAR LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2686, 'NSE_EQ|INE666D01022', '3149', 'BORORENEW', 'BOROSIL RENEWABLES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2687, 'NSE_EQ|INE323A01026', '2181', 'BOSCHLTD', 'BOSCH LIMITED', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(2688, 'NSE_EQ|INE029A01011', '526', 'BPCL', 'BHARAT PETROLEUM CORP  LT', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2719, 'NSE_EQ|INE791I01019', '15184', 'BRIGADE', 'BRIGADE ENTER. LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2721, 'NSE_EQ|INE216A01030', '547', 'BRITANNIA', 'BRITANNIA INDUSTRIES LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2725, 'NSE_EQ|INE118H01025', '19585', 'BSE', 'BSE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2735, 'NSE_EQ|INE836A01035', '6994', 'BSOFT', 'BIRLASOFT LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2744, 'NSE_EQ|INE278Y01022', '9362', 'CAMPUS', 'CAMPUS ACTIVEWEAR LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2745, 'NSE_EQ|INE596I01020', '342', 'CAMS', 'COMPUTER AGE MNGT SER LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2746, 'NSE_EQ|INE476A01022', '10794', 'CANBK', 'CANARA BANK', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2747, 'NSE_EQ|INE477A01020', '583', 'CANFINHOME', 'CAN FIN HOMES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2752, 'NSE_EQ|INE120A01034', '595', 'CARBORUNIV', 'CARBORUNDUM UNIVERSAL LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2757, 'NSE_EQ|INE172A01027', '1250', 'CASTROLIND', 'CASTROL INDIA LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2760, 'NSE_EQ|INE421D01022', '11452', 'CCL', 'CCL PRODUCTS (I) LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2761, 'NSE_EQ|INE736A01011', '21174', 'CDSL', 'CENTRAL DEPO SER (I) LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2762, 'NSE_EQ|INE482A01020', '15254', 'CEATLTD', 'CEAT LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2766, 'NSE_EQ|INE483A01010', '14894', 'CENTRALBK', 'CENTRAL BANK OF INDIA', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2769, 'NSE_EQ|INE348B01021', '13305', 'CENTURYPLY', 'CENTURY PLYBOARDS (I) LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2771, 'NSE_EQ|INE739E01017', '15039', 'CERA', 'CERA SANITARYWARE LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2773, 'NSE_EQ|INE486A01021', '628', 'CESC', 'CESC LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2774, 'NSE_EQ|INE180C01042', '20329', 'CGCL', 'CAPRI GLOBAL CAPITAL LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2775, 'NSE_EQ|INE067A01029', '760', 'CGPOWER', 'CG POWER AND IND SOL LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2776, 'NSE_EQ|INE427F01016', '8546', 'CHALET', 'CHALET HOTELS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2777, 'NSE_EQ|INE085A01013', '637', 'CHAMBLFERT', 'CHAMBAL FERTILIZERS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2781, 'NSE_EQ|INE488A01050', '5449', 'CHEMPLASTS', 'CHEMPLAST SANMAR LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2785, 'NSE_EQ|INE121A01024', '685', 'CHOLAFIN', 'CHOLAMANDALAM IN & FIN CO', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2792, 'NSE_EQ|INE149A01033', '21740', 'CHOLAHLDNG', 'CHOLAMANDALAM FIN HOL LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2796, 'NSE_EQ|INE059A01026', '694', 'CIPLA', 'CIPLA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2797, 'NSE_EQ|INE227W01023', '5049', 'CLEAN', 'CLEAN SCIENCE & TECH LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2805, 'NSE_EQ|INE522F01014', '20374', 'COALINDIA', 'COAL INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2808, 'NSE_EQ|INE704P01025', '21508', 'COCHINSHIP', 'COCHIN SHIPYARD LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2810, 'NSE_EQ|INE591G01025', '11543', 'COFORGE', 'COFORGE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2811, 'NSE_EQ|INE259A01022', '15141', 'COLPAL', 'COLGATE PALMOLIVE LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2814, 'NSE_EQ|INE111A01025', '4749', 'CONCOR', 'CONTAINER CORP OF IND LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2823, 'NSE_EQ|INE169A01031', '739', 'COROMANDEL', 'COROMANDEL INTERNTL. LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2827, 'NSE_EQ|INE00LO01017', '2854', 'CRAFTSMAN', 'CRAFTSMAN AUTOMATION LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2830, 'NSE_EQ|INE741K01010', '4421', 'CREDITACC', 'CREDITACCESS GRAMEEN LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2838, 'NSE_EQ|INE007A01025', '757', 'CRISIL', 'CRISIL LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2839, 'NSE_EQ|INE299U01018', '17094', 'CROMPTON', 'CROMPT GREA CON ELEC LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2841, 'NSE_EQ|INE679A01013', '14966', 'CSBBANK', 'CSB BANK LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2844, 'NSE_EQ|INE491A01021', '5701', 'CUB', 'CITY UNION BANK LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2847, 'NSE_EQ|INE298A01020', '1901', 'CUMMINSIND', 'CUMMINS INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2851, 'NSE_EQ|INE136B01020', '5748', 'CYIENT', 'CYIENT LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2853, 'NSE_EQ|INE016A01026', '772', 'DABUR', 'DABUR INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2854, 'NSE_EQ|INE00R701025', '8075', 'DALBHARAT', 'DALMIA BHARAT LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2859, 'NSE_EQ|INE0IX101010', '7358', 'DATAPATTNS', 'DATA PATTERNS INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2871, 'NSE_EQ|INE499A01024', '811', 'DCMSHRIRAM', 'DCM SHRIRAM LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2876, 'NSE_EQ|INE501A01019', '827', 'DEEPAKFERT', 'DEEPAK FERTILIZERS & PETR', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2877, 'NSE_EQ|INE288B01029', '19943', 'DEEPAKNTR', 'DEEPAK NITRITE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2880, 'NSE_EQ|INE148O01028', '9599', 'DELHIVERY', 'DELHIVERY LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2882, 'NSE_EQ|INE124G01033', '15044', 'DELTACORP', 'DELTA CORP LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2889, 'NSE_EQ|INE872J01023', '5373', 'DEVYANI', 'DEVYANI INTERNATIONAL LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2927, 'NSE_EQ|INE361B01024', '10940', 'DIVISLAB', 'DIVI S LABORATORIES LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(2929, 'NSE_EQ|INE935N01020', '21690', 'DIXON', 'DIXON TECHNO (INDIA) LTD', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(2932, 'NSE_EQ|INE271C01023', '14732', 'DLF', 'DLF LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(2934, 'NSE_EQ|INE192R01011', '19913', 'DMART', 'AVENUE SUPERMARTS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2949, 'NSE_EQ|INE089A01031', '881', 'DRREDDY', 'DR. REDDY S LABORATORIES', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(2969, 'NSE_EQ|INE07O001026', '2792', 'EASEMYTRIP', 'EASY TRIP PLANNERS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(2992, 'NSE_EQ|INE738I01010', '15179', 'ECLERX', 'ECLERX SERVICES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3008, 'NSE_EQ|INE066A01021', '910', 'EICHERMOT', 'EICHER MOTORS LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(3009, 'NSE_EQ|INE126A01031', '916', 'EIDPARRY', 'EID PARRY INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3012, 'NSE_EQ|INE230A01023', '919', 'EIHOTEL', 'EIH LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3020, 'NSE_EQ|INE285A01027', '937', 'ELGIEQUIP', 'ELGI EQUIPMENTS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3023, 'NSE_EQ|INE548C01032', '13517', 'EMAMILTD', 'EMAMI LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3033, 'NSE_EQ|INE913H01037', '18822', 'ENDURANCE', 'ENDURANCE TECHNO. LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3035, 'NSE_EQ|INE510A01028', '4907', 'ENGINERSIN', 'ENGINEERS INDIA LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3037, 'NSE_EQ|INE255A01020', '981', 'EPL', 'EPL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3039, 'NSE_EQ|INE063P01018', '913', 'EQUITASBNK', 'EQUITAS SMALL FIN BNK LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3042, 'NSE_EQ|INE406M01024', '21154', 'ERIS', 'ERIS LIFESCIENCES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3045, 'NSE_EQ|INE042A01014', '958', 'ESCORTS', 'ESCORTS KUBOTA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3056, 'NSE_EQ|INE302A01020', '676', 'EXIDEIND', 'EXIDE INDUSTRIES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3062, 'NSE_EQ|INE188A01015', '1008', 'FACT', 'FACT LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3068, 'NSE_EQ|INE258B01022', '4898', 'FDC', 'FDC LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3069, 'NSE_EQ|INE171A01029', '1023', 'FEDERALBNK', 'FEDERAL BANK LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3091, 'NSE_EQ|INE235A01022', '1038', 'FINCABLES', 'FINOLEX CABLES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3092, 'NSE_EQ|INE686Y01026', '3744', 'FINEORG', 'FINE ORGANIC IND. LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3094, 'NSE_EQ|INE183A01024', '1041', 'FINPIPE', 'FINOLEX INDUSTRIES LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3113, 'NSE_EQ|INE128S01021', '12032', 'FIVESTAR', 'FIVE-STAR BUS FIN LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3116, 'NSE_EQ|INE09N301011', '13750', 'FLUOROCHEM', 'GUJARAT FLUOROCHEM LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3123, 'NSE_EQ|INE061F01013', '14592', 'FORTIS', 'FORTIS HEALTHCARE LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3128, 'NSE_EQ|INE684F01012', '14304', 'FSL', 'FIRSTSOURCE SOLU. LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3132, 'NSE_EQ|INE036B01030', '8828', 'GAEL', 'GUJARAT AMBUJA EXPORTS LT', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3133, 'NSE_EQ|INE129A01019', '4717', 'GAIL', 'GAIL (INDIA) LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3135, 'NSE_EQ|INE600K01018', '1315', 'GALAXYSURF', 'GALAXY SURFACTANTS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3144, 'NSE_EQ|INE276A01018', '1100', 'GARFIBRES', 'GARWARE TECH FIBRES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3157, 'NSE_EQ|INE017A01032', '13776', 'GESHIP', 'THE GE SHPG.LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3164, 'NSE_EQ|INE481Y01014', '277', 'GICRE', 'GENERAL INS CORP OF INDIA', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3174, 'NSE_EQ|INE068V01023', '1186', 'GLAND', 'GLAND PHARMA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3175, 'NSE_EQ|INE159A01016', '1153', 'GLAXO', 'GLAXOSMITHKLINE PHARMA LT', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3176, 'NSE_EQ|INE935A01035', '7406', 'GLENMARK', 'GLENMARK PHARMACEUTICALS', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3185, 'NSE_EQ|INE541A01023', '1570', 'GMMPFAUDLR', 'GMM PFAUDLER LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3189, 'NSE_EQ|INE113A01013', '1174', 'GNFC', 'GUJ NAR VAL FER & CHEM L', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3192, 'NSE_EQ|INE0BJS01011', '6964', 'GOCOLORS', 'GO FASHION INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3193, 'NSE_EQ|INE260B01028', '1181', 'GODFRYPHLP', 'GODFREY PHILLIPS INDIA LT', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3195, 'NSE_EQ|INE850D01014', '144', 'GODREJAGRO', 'GODREJ AGROVET LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3196, 'NSE_EQ|INE102D01028', '10099', 'GODREJCP', 'GODREJ CONSUMER PRODUCTS', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3197, 'NSE_EQ|INE233A01035', '10925', 'GODREJIND', 'GODREJ INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3198, 'NSE_EQ|INE484J01027', '17875', 'GODREJPROP', 'GODREJ PROPERTIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3213, 'NSE_EQ|INE517F01014', '19731', 'GPPL', 'GUJARAT PIPAVAV PORT LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3215, 'NSE_EQ|INE101D01020', '11872', 'GRANULES', 'GRANULES INDIA LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3216, 'NSE_EQ|INE371A01025', '592', 'GRAPHITE', 'GRAPHITE INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3217, 'NSE_EQ|INE047A01021', '1232', 'GRASIM', 'GRASIM INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3223, 'NSE_EQ|INE08ZM01014', '13810', 'GREENPANEL', 'GREENPANEL INDUSTRIES LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3227, 'NSE_EQ|INE536A01023', '13560', 'GRINDWELL', 'GRINDWELL NORTON LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3228, 'NSE_EQ|INE201P01022', '5054', 'GRINFRA', 'G R INFRAPROJECTS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3340, 'NSE_EQ|INE026A01025', '1247', 'GSFC', 'GUJ STATE FERT & CHEM LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3342, 'NSE_EQ|INE246F01010', '13197', 'GSPL', 'GUJARAT STATE PETRO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3349, 'NSE_EQ|INE186A01019', '1267', 'GUJALKALI', 'GUJARAT ALKALIES & CHEM', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3351, 'NSE_EQ|INE844O01030', '10599', 'GUJGASLTD', 'GUJARAT GAS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3389, 'NSE_EQ|INE066F01020', '2303', 'HAL', 'HINDUSTAN AERONAUTICS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3390, 'NSE_EQ|INE419U01012', '48', 'HAPPSTMNDS', 'HAPPIEST MINDS TECHNO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3397, 'NSE_EQ|INE176B01034', '9819', 'HAVELLS', 'HAVELLS INDIA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3405, 'NSE_EQ|INE860A01027', '7229', 'HCLTECH', 'HCL TECHNOLOGIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3432, 'NSE_EQ|INE127D01025', '4244', 'HDFCAMC', 'HDFC AMC LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3433, 'NSE_EQ|INE040A01034', '1333', 'HDFCBANK', 'HDFC BANK LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3436, 'NSE_EQ|INE795G01014', '467', 'HDFCLIFE', 'HDFC LIFE INS CO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3455, 'NSE_EQ|INE545A01024', '1336', 'HEG', 'HEG LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3461, 'NSE_EQ|INE158A01026', '1348', 'HEROMOTOCO', 'HERO MOTOCORP LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(3465, 'NSE_EQ|INE548A01028', '21951', 'HFCL', 'HFCL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3473, 'NSE_EQ|INE170I01016', '14712', 'HGS', 'HINDUJA GLOBAL SOLS. LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3475, 'NSE_EQ|INE475B01022', '9668', 'HIKAL', 'HIKAL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3479, 'NSE_EQ|INE038A01020', '1363', 'HINDALCO', 'HINDALCO  INDUSTRIES  LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3482, 'NSE_EQ|INE531E01026', '17939', 'HINDCOPPER', 'HINDUSTAN COPPER LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3486, 'NSE_EQ|INE094A01015', '1406', 'HINDPETRO', 'HINDUSTAN PETROLEUM CORP', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3487, 'NSE_EQ|INE030A01027', '1394', 'HINDUNILVR', 'HINDUSTAN UNILEVER LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3489, 'NSE_EQ|INE267A01025', '1424', 'HINDZINC', 'HINDUSTAN ZINC LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3495, 'NSE_EQ|INE461D01028', '2289', 'HLEGLAS', 'HLE GLASCOAT LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3501, 'NSE_EQ|INE481N01025', '2056', 'HOMEFIRST', 'HOME FIRST FIN CO IND LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3503, 'NSE_EQ|INE671A01010', '3417', 'HONAUT', 'HONEYWELL AUTOMATION IND', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(3512, 'NSE_EQ|INE031A01017', '20825', 'HUDCO', 'HSG & URBAN DEV CORPN LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3676, 'NSE_EQ|INE090A01021', '4963', 'ICICIBANK', 'ICICI BANK LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3683, 'NSE_EQ|INE765G01017', '21770', 'ICICIGI', 'ICICI LOMBARD GIC LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3696, 'NSE_EQ|INE726G01019', '18652', 'ICICIPRULI', 'ICICI PRU LIFE INS CO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3702, 'NSE_EQ|INE008A01015', '1476', 'IDBI', 'IDBI BANK LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3704, 'NSE_EQ|INE669E01016', '14366', 'IDEA', 'VODAFONE IDEA LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3706, 'NSE_EQ|INE092T01019', '11184', 'IDFCFIRSTB', 'IDFC FIRST BANK LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3709, 'NSE_EQ|INE022Q01020', '220', 'IEX', 'INDIAN ENERGY EXC LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3717, 'NSE_EQ|INE559A01017', '1485', 'IFBIND', 'IFB INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3727, 'NSE_EQ|INE203G01027', '11262', 'IGL', 'INDRAPRASTHA GAS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3733, 'NSE_EQ|INE530B01024', '11809', 'IIFL', 'IIFL FINANCE LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3786, 'NSE_EQ|INE053A01029', '1512', 'INDHOTEL', 'THE INDIAN HOTELS CO. LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3787, 'NSE_EQ|INE383A01012', '1515', 'INDIACEM', 'THE INDIA CEMENTS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3789, 'NSE_EQ|INE933S01016', '10726', 'INDIAMART', 'INDIAMART INTERMESH LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3790, 'NSE_EQ|INE562A01011', '14309', 'INDIANB', 'INDIAN BANK', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3793, 'NSE_EQ|INE646L01027', '11195', 'INDIGO', 'INTERGLOBE AVIATION LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(3794, 'NSE_EQ|INE09VQ01012', '2048', 'INDIGOPNTS', 'INDIGO PAINTS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3823, 'NSE_EQ|INE095A01012', '5258', 'INDUSINDBK', 'INDUSIND BANK LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3824, 'NSE_EQ|INE121J01017', '29135', 'INDUSTOWER', 'INDUS TOWERS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3825, 'NSE_EQ|INE483S01020', '16249', 'INFIBEAM', 'INFIBEAM AVENUES LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3830, 'NSE_EQ|INE009A01021', '1594', 'INFY', 'INFOSYS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3831, 'NSE_EQ|INE177A01018', '1597', 'INGERRAND', 'INGERSOLL-RAND INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3838, 'NSE_EQ|INE306R01017', '5926', 'INTELLECT', 'INTELLECT DESIGN ARENA', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3842, 'NSE_EQ|INE565A01014', '9348', 'IOB', 'INDIAN OVERSEAS BANK', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3843, 'NSE_EQ|INE242A01010', '1624', 'IOC', 'INDIAN OIL CORP LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3846, 'NSE_EQ|INE571A01038', '1633', 'IPCALAB', 'IPCA LABORATORIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3853, 'NSE_EQ|INE821I01022', '15313', 'IRB', 'IRB INFRA DEV LTD.', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3857, 'NSE_EQ|INE335Y01020', '13611', 'IRCTC', 'INDIAN RAIL TOUR CORP LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3865, 'NSE_EQ|INE053F01010', '2029', 'IRFC', 'INDIAN RAILWAY FIN CORP L', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3895, 'NSE_EQ|INE154A01025', '1660', 'ITC', 'ITC LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3898, 'NSE_EQ|INE248A01017', '1675', 'ITI', 'ITI LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3914, 'NSE_EQ|INE039C01032', '20778', 'JAMNAAUTO', 'JAMNA AUTO IND LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3920, 'NSE_EQ|INE572A01036', '1726', 'JBCHEPHARM', 'J B CHEMICALS AND PHARMA', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3922, 'NSE_EQ|INE927D01051', '11655', 'JBMA', 'JBM AUTO LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3932, 'NSE_EQ|INE749A01030', '6733', 'JINDALSTEL', 'JINDAL STEEL LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3934, 'NSE_EQ|INE247D01039', '20642', 'JINDWORLD', 'JINDAL WORLDWIDE LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3938, 'NSE_EQ|INE823G01014', '13270', 'JKCEMENT', 'JK CEMENT LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(3940, 'NSE_EQ|INE786A01032', '13491', 'JKLAKSHMI', 'JK LAKSHMI CEMENT LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3941, 'NSE_EQ|INE789E01012', '11860', 'JKPAPER', 'JK PAPER LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3944, 'NSE_EQ|INE780C01023', '13637', 'JMFINANCIL', 'JM FINANCIAL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3949, 'NSE_EQ|INE220G01021', '11236', 'JSL', 'JINDAL STAINLESS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3951, 'NSE_EQ|INE121E01018', '17869', 'JSWENERGY', 'JSW ENERGY LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3954, 'NSE_EQ|INE019A01038', '11723', 'JSWSTEEL', 'JSW STEEL LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3957, 'NSE_EQ|INE797F01020', '18096', 'JUBLFOOD', 'JUBILANT FOODWORKS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3959, 'NSE_EQ|INE0BY001018', '2783', 'JUBLINGREA', 'JUBILANT INGREVIA LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3960, 'NSE_EQ|INE700A01033', '3637', 'JUBLPHARMA', 'JUBILANT PHARMOVA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3962, 'NSE_EQ|INE599M01018', '29962', 'JUSTDIAL', 'JUSTDIAL LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3964, 'NSE_EQ|INE668F01031', '15146', 'JYOTHYLAB', 'JYOTHY LABS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3967, 'NSE_EQ|INE217B01036', '1808', 'KAJARIACER', 'KAJARIA CERAMICS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(3972, 'NSE_EQ|INE303R01014', '2955', 'KALYANKJIL', 'KALYAN JEWELLERS IND LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3980, 'NSE_EQ|INE531A01024', '1196', 'KANSAINER', 'KANSAI NEROLAC PAINTS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3983, 'NSE_EQ|INE036D01028', '1838', 'KARURVYSYA', 'KARUR VYSYA BANK LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(3993, 'NSE_EQ|INE389H01022', '13260', 'KEC', 'KEC INTL. LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(3997, 'NSE_EQ|INE878B01027', '13310', 'KEI', 'KEI INDUSTRIES LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4003, 'NSE_EQ|INE138Y01010', '13359', 'KFINTECH', 'KFIN TECHNOLOGIES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4011, 'NSE_EQ|INE967H01025', '4847', 'KIMS', 'KRISHNA INST OF MED SCI L', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4025, 'NSE_EQ|INE634I01029', '15283', 'KNRCON', 'KNR CONSTRU LTD.', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4032, 'NSE_EQ|INE237A01028', '1922', 'KOTAKBANK', 'KOTAK MAHINDRA BANK LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4051, 'NSE_EQ|INE04I401011', '9683', 'KPITTECH', 'KPIT TECHNOLOGIES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4052, 'NSE_EQ|INE930H01031', '14912', 'KPRMILL', 'KPR MILL LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4053, 'NSE_EQ|INE001B01026', '10577', 'KRBL', 'KRBL LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4063, 'NSE_EQ|INE999A01023', '1949', 'KSB', 'KSB LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4098, 'NSE_EQ|INE600L01024', '11654', 'LALPATHLAB', 'DR. LAL PATH LABS LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4103, 'NSE_EQ|INE0I7C01011', '6818', 'LATENTVIEW', 'LATENT VIEW ANALYTICS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4105, 'NSE_EQ|INE947Q01028', '19234', 'LAURUSLABS', 'LAURUS LABS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4110, 'NSE_EQ|INE970X01018', '2606', 'LEMONTREE', 'LEMON TREE HOTELS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4118, 'NSE_EQ|INE115A01026', '1997', 'LICHSGFIN', 'LIC HOUSING FINANCE LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4119, 'NSE_EQ|INE0J1Y01017', '9480', 'LICI', 'LIFE INSURA CORP OF INDIA', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4127, 'NSE_EQ|INE473A01011', '1627', 'LINDEINDIA', 'LINDE INDIA LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4131, 'NSE_EQ|INE670K01029', '3220', 'LODHA', 'LODHA DEVELOPERS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4139, 'NSE_EQ|INE018A01030', '11483', 'LT', 'LARSEN & TOUBRO LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4141, 'NSE_EQ|INE214T01019', '17818', 'LTIM', 'LTIMINDTREE LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4142, 'NSE_EQ|INE010V01017', '18564', 'LTTS', 'L&T TECHNOLOGY SER. LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4145, 'NSE_EQ|INE326A01037', '10440', 'LUPIN', 'LUPIN LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4146, 'NSE_EQ|INE150G01020', '11301', 'LUXIND', 'LUX INDUSTRIES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4147, 'NSE_EQ|INE576O01020', '2841', 'LXCHEM', 'LAXMI ORGANIC INDUS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4150, 'NSE_EQ|INE101A01026', '2031', 'M&M', 'MAHINDRA & MAHINDRA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4151, 'NSE_EQ|INE774D01024', '13285', 'M&MFIN', 'M&M FIN. SERVICES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4168, 'NSE_EQ|INE457A01014', '11377', 'MAHABANK', 'BANK OF MAHARASHTRA', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4176, 'NSE_EQ|INE813A01018', '8050', 'MAHLIFE', 'MAHINDRA LIFESPACE DEVLTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4177, 'NSE_EQ|INE766P01016', '385', 'MAHLOG', 'MAHINDRA LOGISTIC LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4192, 'NSE_EQ|INE522D01027', '19061', 'MANAPPURAM', 'MANAPPURAM FINANCE LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4206, 'NSE_EQ|INE825V01034', '8167', 'MANYAVAR', 'VEDANT FASHIONS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4207, 'NSE_EQ|INE0BV301023', '7227', 'MAPMYINDIA', 'C.E. INFO SYSTEMS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4210, 'NSE_EQ|INE196A01026', '4067', 'MARICO', 'MARICO LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4214, 'NSE_EQ|INE585B01010', '10999', 'MARUTI', 'MARUTI SUZUKI INDIA LTD.', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(4218, 'NSE_EQ|INE759A01021', '2124', 'MASTEK', 'MASTEK LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4221, 'NSE_EQ|INE027H01010', '22377', 'MAXHEALTH', 'MAX HEALTHCARE INS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4226, 'NSE_EQ|INE249Z01020', '509', 'MAZDOCK', 'MAZAGON DOCK SHIPBUIL LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4242, 'NSE_EQ|INE745G01035', '31181', 'MCX', 'MULTI COMMODITY EXCHANGE', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(4244, 'NSE_EQ|INE474Q01031', '11956', 'MEDANTA', 'GLOBAL HEALTH LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4247, 'NSE_EQ|INE804L01022', '7254', 'MEDPLUS', 'MEDPLUS HEALTH SERV LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4255, 'NSE_EQ|INE317I01021', '7242', 'METROBRAND', 'METRO BRANDS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4256, 'NSE_EQ|INE112L01020', '9581', 'METROPOLIS', 'METROPOLIS HEALTHCARE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4258, 'NSE_EQ|INE180A01020', '2142', 'MFSL', 'MAX FINANCIAL SERV LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4260, 'NSE_EQ|INE002S01010', '17534', 'MGL', 'MAHANAGAR GAS LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4263, 'NSE_EQ|INE998I01010', '17333', 'MHRIL', 'MAHINDRA HOLIDAYS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4283, 'NSE_EQ|INE123F01029', '17957', 'MMTC', 'MMTC LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4308, 'NSE_EQ|INE775A01035', '4204', 'MOTHERSON', 'SAMVRDHNA MTHRSN INTL LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4309, 'NSE_EQ|INE338I01027', '14947', 'MOTILALOFS', 'MOTILAL OSWAL FIN LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4313, 'NSE_EQ|INE356A01018', '4503', 'MPHASIS', 'MPHASIS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4316, 'NSE_EQ|INE883A01011', '2277', 'MRF', 'MRF LTD', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(4319, 'NSE_EQ|INE103A01014', '2283', 'MRPL', 'MRPL', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4322, 'NSE_EQ|INE0FS801015', '8596', 'MSUMI', 'MOTHERSON SUMI WRNG IND L', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4323, 'NSE_EQ|INE864I01014', '2709', 'MTARTECH', 'MTAR TECHNOLOGIES LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4332, 'NSE_EQ|INE414G01012', '23650', 'MUTHOOTFIN', 'MUTHOOT FINANCE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4345, 'NSE_EQ|INE298J01013', '357', 'NAM-INDIA', 'NIPPON L I A M LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4347, 'NSE_EQ|INE987B01026', '3918', 'NATCOPHARM', 'NATCO PHARMA LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4349, 'NSE_EQ|INE139A01034', '6364', 'NATIONALUM', 'NATIONAL ALUMINIUM CO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4351, 'NSE_EQ|INE663F01032', '13751', 'NAUKRI', 'INFO EDGE (I) LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4357, 'NSE_EQ|INE048G01026', '14672', 'NAVINFLUOR', 'NAVIN FLUORINE INT. LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4360, 'NSE_EQ|INE418L01047', '2987', 'NAZARA', 'NAZARA TECHNOLOGIES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4361, 'NSE_EQ|INE095N01031', '31415', 'NBCC', 'NBCC (INDIA) LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4363, 'NSE_EQ|INE868B01028', '2319', 'NCC', 'NCC LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4376, 'NSE_EQ|INE239A01024', '17963', 'NESTLEIND', 'NESTLE INDIA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4378, 'NSE_EQ|INE870H01013', '14111', 'NETWORK18', 'NETWORK18 MEDIA & INV LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4385, 'NSE_EQ|INE410P01011', '11840', 'NH', 'NARAYANA HRUDAYALAYA LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4415, 'NSE_EQ|INE848E01016', '17400', 'NHPC', 'NHPC LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4422, 'NSE_EQ|INE470Y01017', '399', 'NIACL', 'THE NEW INDIA ASSU CO LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4441, 'NSE_EQ|INE589A01014', '8585', 'NLCINDIA', 'NLC INDIA LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4442, 'NSE_EQ|INE584A01023', '15332', 'NMDC', 'NMDC LTD.', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4448, 'NSE_EQ|INE163A01018', '2442', 'NOCIL', 'NOCIL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4458, 'NSE_EQ|INE0NNS01018', '14180', 'NSLNISP', 'NMDC STEEL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4459, 'NSE_EQ|INE733E01010', '11630', 'NTPC', 'NTPC LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4475, 'NSE_EQ|INE118D01016', '5426', 'NUVOCO', 'NUVOCO VISTAS CORP LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4477, 'NSE_EQ|INE388Y01029', '6545', 'NYKAA', 'FSN E COMMERCE VENTURES', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4480, 'NSE_EQ|INE093I01010', '20242', 'OBEROIRLTY', 'OBEROI REALTY LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4482, 'NSE_EQ|INE881D01027', '10738', 'OFSS', 'ORACLE FIN SERV SOFT LTD.', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4483, 'NSE_EQ|INE274J01014', '17438', 'OIL', 'OIL INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4485, 'NSE_EQ|INE260D01016', '10637', 'OLECTRA', 'OLECTRA GREENTECH LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4493, 'NSE_EQ|INE213A01029', '2475', 'ONGC', 'OIL AND NATURAL GAS CORP.', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4504, 'NSE_EQ|INE142Z01019', '2972', 'ORIENTELEC', 'ORIENT ELECTRIC LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4515, 'NSE_EQ|INE761H01022', '14413', 'PAGEIND', 'PAGE INDUSTRIES LTD', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(4534, 'NSE_EQ|INE619A01035', '17029', 'PATANJALI', 'PATANJALI FOODS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4539, 'NSE_EQ|INE982J01020', '6705', 'PAYTM', 'ONE 97 COMMUNICATIONS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4540, 'NSE_EQ|INE602A01031', '2649', 'PCBL', 'PCBL CHEMICAL LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4561, 'NSE_EQ|INE262H01021', '18365', 'PERSISTENT', 'PERSISTENT SYSTEMS LTD', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4562, 'NSE_EQ|INE347G01014', '11351', 'PETRONET', 'PETRONET LNG LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4563, 'NSE_EQ|INE134E01011', '14299', 'PFC', 'POWER FIN CORP LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4571, 'NSE_EQ|INE182A01018', '2643', 'PFIZER', 'PFIZER LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4575, 'NSE_EQ|INE179A01014', '2535', 'PGHH', 'P&G HYGIENE & HEALTH CARE', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(4589, 'NSE_EQ|INE211B01039', '14552', 'PHOENIXLTD', 'THE PHOENIX MILLS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4590, 'NSE_EQ|INE318A01026', '2664', 'PIDILITIND', 'PIDILITE INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4592, 'NSE_EQ|INE603J01030', '24184', 'PIIND', 'PI INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4600, 'NSE_EQ|INE160A01022', '10666', 'PNB', 'PUNJAB NATIONAL BANK', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4602, 'NSE_EQ|INE572E01012', '18908', 'PNBHOUSING', 'PNB HOUSING FIN LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4604, 'NSE_EQ|INE195J01029', '9385', 'PNCINFRA', 'PNC INFRATECH LTD.', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4609, 'NSE_EQ|INE417T01026', '6656', 'POLICYBZR', 'PB FINTECH LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4610, 'NSE_EQ|INE455K01017', '9590', 'POLYCAB', 'POLYCAB INDIA LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(4611, 'NSE_EQ|INE205C01021', '25718', 'POLYMED', 'POLY MEDICURE LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4612, 'NSE_EQ|INE633B01018', '2687', 'POLYPLEX', 'POLYPLEX CORPORATION LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4614, 'NSE_EQ|INE511C01022', '11403', 'POONAWALLA', 'POONAWALLA FINCORP LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4620, 'NSE_EQ|INE752E01010', '14977', 'POWERGRID', 'POWER GRID CORP. LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4621, 'NSE_EQ|INE07Y701011', '18457', 'POWERINDIA', 'HITACHI ENERGY INDIA LTD', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(4625, 'NSE_EQ|INE0DK501011', '11571', 'PPLPHARMA', 'PIRAMAL PHARMA LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4627, 'NSE_EQ|INE074A01025', '2705', 'PRAJIND', 'PRAJ INDUSTRIES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4639, 'NSE_EQ|INE811K01011', '20302', 'PRESTIGE', 'PRESTIGE ESTATE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4642, 'NSE_EQ|INE689W01016', '16045', 'PRINCEPIPE', 'PRINCE PIPES FITTINGS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4650, 'NSE_EQ|INE010A01011', '2739', 'PRSMJOHNSN', 'PRISM JOHNSON LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4662, 'NSE_EQ|INE191H01014', '13147', 'PVRINOX', 'PVR INOX LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4668, 'NSE_EQ|INE615P01015', '17704', 'QUESS', 'QUESS CORP LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4676, 'NSE_EQ|INE944F01028', '10990', 'RADICO', 'RADICO KHAITAN LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4680, 'NSE_EQ|INE855B01025', '15337', 'RAIN', 'RAIN INDUSTRIES LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4681, 'NSE_EQ|INE961O01016', '9408', 'RAINBOW', 'RAINBOW CHILDRENS MED LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4682, 'NSE_EQ|INE343B01030', '7401', 'RAJESHEXPO', 'RAJESH EXPORTS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4689, 'NSE_EQ|INE613A01020', '2816', 'RALLIS', 'RALLIS INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4693, 'NSE_EQ|INE331A01037', '2043', 'RAMCOCEM', 'THE RAMCO CEMENTS LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4702, 'NSE_EQ|INE703B01027', '13451', 'RATNAMANI', 'RATNAMANI MET & TUB LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4703, 'NSE_EQ|INE301A01014', '2859', 'RAYMOND', 'RAYMOND LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4704, 'NSE_EQ|INE07T201019', '1494', 'RBA', 'RESTAURANT BRAND ASIA LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4706, 'NSE_EQ|INE976G01028', '18391', 'RBLBANK', 'RBL BANK LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4708, 'NSE_EQ|INE027A01015', '2866', 'RCF', 'RASHTRIYA CHEMICALS & FER', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4710, 'NSE_EQ|INE020B01018', '15355', 'RECLTD', 'REC LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4727, 'NSE_EQ|INE891D01026', '14255', 'REDINGTON', 'REDINGTON LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4730, 'NSE_EQ|INE131B01039', '24225', 'RELAXO', 'RELAXO FOOT LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4734, 'NSE_EQ|INE002A01018', '2885', 'RELIANCE', 'RELIANCE INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4738, 'NSE_EQ|INE087H01022', '12026', 'RENUKA', 'SHREE RENUKA SUGARS LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4747, 'NSE_EQ|INE743M01012', '31163', 'RHIM', 'RHI MAGNESITA INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4754, 'NSE_EQ|INE320J01015', '3761', 'RITES', 'RITES LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4770, 'NSE_EQ|INE02A801020', '19410', 'ROSSARI', 'ROSSARI BIOTECH LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4773, 'NSE_EQ|INE450U01017', '128', 'ROUTE', 'ROUTE MOBILE LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4782, 'NSE_EQ|INE834M01019', '27297', 'RTNINDIA', 'RATTANINDIA ENT LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4789, 'NSE_EQ|INE263M01029', '12219', 'RUSTOMJEE', 'KEYSTONE REALTORS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4791, 'NSE_EQ|INE415G01027', '9552', 'RVNL', 'RAIL VIKAS NIGAM LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4804, 'NSE_EQ|INE114A01011', '2963', 'SAIL', 'STEEL AUTHORITY OF INDIA', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4821, 'NSE_EQ|INE058A01010', '1442', 'SANOFI', 'SANOFI INDIA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4824, 'NSE_EQ|INE806T01020', '6718', 'SAPPHIRE', 'SAPPHIRE FOODS INDIA LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(4837, 'NSE_EQ|INE018E01016', '17971', 'SBICARD', 'SBI CARDS & PAY SER LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4842, 'NSE_EQ|INE123W01016', '21808', 'SBILIFE', 'SBI LIFE INSURANCE CO LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(4843, 'NSE_EQ|INE062A01020', '3045', 'SBIN', 'STATE BANK OF INDIA', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(4845, 'NSE_EQ|INE513A01022', '1011', 'SCHAEFFLER', 'SCHAEFFLER INDIA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5024, 'NSE_EQ|INE221J01015', '4992', 'SHARDACROP', 'SHARDA CROPCHEM LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5039, 'NSE_EQ|INE498B01024', '11813', 'SHOPERSTOP', 'SHOPPERS STOP LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5042, 'NSE_EQ|INE070A01015', '3103', 'SHREECEM', 'SHREE CEMENT LIMITED', NULL, NULL, NULL, 500, 1, 'EQ', NULL, 'NSE', 1),
(5050, 'NSE_EQ|INE721A01047', '4306', 'SHRIRAMFIN', 'SHRIRAM FINANCE LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5080, 'NSE_EQ|INE810G01011', '4693', 'SHYAMMETL', 'SHYAM METALICS AND ENGY L', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5083, 'NSE_EQ|INE003A01024', '3150', 'SIEMENS', 'SIEMENS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5104, 'NSE_EQ|INE002L01015', '18883', 'SJVN', 'SJVN LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5105, 'NSE_EQ|INE640A01023', '3186', 'SKFINDIA', 'SKF INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5120, 'NSE_EQ|INE671H01015', '13826', 'SOBHA', 'SOBHA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5123, 'NSE_EQ|INE343H01029', '13332', 'SOLARINDS', 'SOLAR INDUSTRIES (I) LTD', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(5128, 'NSE_EQ|INE073K01018', '4684', 'SONACOMS', 'SONA BLW PRECISION FRGS L', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5131, 'NSE_EQ|INE269A01021', '6596', 'SONATSOFTW', 'SONATA SOFTWARE LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5139, 'NSE_EQ|INE232I01014', '14788', 'SPARC', 'SUN PHARMA ADV.RES.CO.LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5164, 'NSE_EQ|INE647A01010', '3273', 'SRF', 'SRF LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5174, 'NSE_EQ|INE575P01011', '7083', 'STARHEALTH', 'STAR HEALTH & AL INS CO L', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5183, 'NSE_EQ|INE089C01029', '9309', 'STLTECH', 'STERLITE TECHNOLOGIES LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5193, 'NSE_EQ|INE258G01013', '17105', 'SUMICHEM', 'SUMITOMO CHEM INDIA LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5198, 'NSE_EQ|INE660A01013', '3339', 'SUNDARMFIN', 'SUNDARAM FINANCE LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5201, 'NSE_EQ|INE387A01021', '3345', 'SUNDRMFAST', 'SUNDRAM FASTENERS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5203, 'NSE_EQ|INE044A01036', '3351', 'SUNPHARMA', 'SUN PHARMACEUTICAL IND L', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5204, 'NSE_EQ|INE805D01034', '17641', 'SUNTECK', 'SUNTECK REALTY LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5205, 'NSE_EQ|INE424H01027', '13404', 'SUNTV', 'SUN TV NETWORK LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5208, 'NSE_EQ|INE399C01030', '11689', 'SUPRAJIT', 'SUPRAJIT ENGINEERING LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5210, 'NSE_EQ|INE195A01028', '3363', 'SUPREMEIND', 'SUPREME INDUSTRIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5224, 'NSE_EQ|INE040H01021', '12018', 'SUZLON', 'SUZLON ENERGY LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5232, 'NSE_EQ|INE00M201021', '12489', 'SWSOLAR', 'STRLNG & WIL REN ENE LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5235, 'NSE_EQ|INE398R01022', '10243', 'SYNGENE', 'SYNGENE INTERNATIONAL LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1);
INSERT INTO `equity` (`id`, `instrument_key`, `exchange_token`, `tradingsymbol`, `name`, `last_price`, `expiry`, `strike`, `tick_size`, `lot_size`, `instrument_type`, `option_type`, `exchange`, `is_active`) VALUES
(5242, 'NSE_EQ|INE483C01032', '13976', 'TANLA', 'TANLA PLATFORMS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5260, 'NSE_EQ|INE092A01019', '3405', 'TATACHEM', 'TATA CHEMICALS LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5262, 'NSE_EQ|INE151A01013', '3721', 'TATACOMM', 'TATA COMMUNICATIONS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5263, 'NSE_EQ|INE192A01025', '3432', 'TATACONSUM', 'TATA CONSUMER PRODUCT LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5264, 'NSE_EQ|INE670A01012', '3411', 'TATAELXSI', 'TATA ELXSI LIMITED', NULL, NULL, NULL, 50, 1, 'EQ', NULL, 'NSE', 1),
(5265, 'NSE_EQ|INE672A01026', '1621', 'TATAINVEST', 'TATA INVESTMENT CORP LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5269, 'NSE_EQ|INE245A01021', '3426', 'TATAPOWER', 'TATA POWER CO LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5270, 'NSE_EQ|INE081A01020', '3499', 'TATASTEEL', 'TATA STEEL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5284, 'NSE_EQ|INE688A01022', '10580', 'TCI', 'TRANSPORT CORPN OF INDIA', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5285, 'NSE_EQ|INE586V01016', '19223', 'TCIEXP', 'TCI EXPRESS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5289, 'NSE_EQ|INE467B01029', '11536', 'TCS', 'TATA CONSULTANCY SERV LT', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5291, 'NSE_EQ|INE985S01024', '12716', 'TEAMLEASE', 'TEAMLEASE SERVICES LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5294, 'NSE_EQ|INE669C01036', '13538', 'TECHM', 'TECH MAHINDRA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5298, 'NSE_EQ|INE010J01012', '21131', 'TEJASNET', 'TEJAS NETWORKS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5311, 'NSE_EQ|INE152A01029', '3475', 'THERMAX', 'THERMAX LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5318, 'NSE_EQ|INE974X01010', '312', 'TIINDIA', 'TUBE INVEST OF INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5324, 'NSE_EQ|INE325A01013', '14198', 'TIMKEN', 'TIMKEN INDIA LTD.', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5331, 'NSE_EQ|INE280A01028', '3506', 'TITAN', 'TITAN COMPANY LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5332, 'NSE_EQ|INE668A01016', '10945', 'TMB', 'TAMILNAD MERCA BANK LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5338, 'NSE_EQ|INE685A01028', '3518', 'TORNTPHARM', 'TORRENT PHARMACEUTICALS L', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5339, 'NSE_EQ|INE813H01021', '13786', 'TORNTPOWER', 'TORRENT POWER LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5347, 'NSE_EQ|INE849A01020', '1964', 'TRENT', 'TRENT LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5349, 'NSE_EQ|INE064C01022', '9685', 'TRIDENT', 'TRIDENT LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5352, 'NSE_EQ|INE152M01016', '25584', 'TRITURBINE', 'TRIVENI TURBINE LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5353, 'NSE_EQ|INE256C01024', '13081', 'TRIVENI', 'TRIVENI ENGG. & INDS. LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5355, 'NSE_EQ|INE690A01028', '3546', 'TTKPRESTIG', 'TTK PRESTIGE LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5357, 'NSE_EQ|INE517B01013', '8954', 'TTML', 'TATA TELESERV(MAHARASTRA)', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5360, 'NSE_EQ|INE494B01023', '8479', 'TVSMOTOR', 'TVS MOTOR COMPANY  LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5365, 'NSE_EQ|INE686F01025', '16713', 'UBL', 'UNITED BREWERIES LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5368, 'NSE_EQ|INE691A01018', '11223', 'UCOBANK', 'UCO BANK', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5384, 'NSE_EQ|INE516A01017', '1053', 'UFLEX', 'UFLEX LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5400, 'NSE_EQ|INE481G01011', '11532', 'ULTRACEMCO', 'ULTRATECH CEMENT LIMITED', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(5409, 'NSE_EQ|INE692A01016', '10753', 'UNIONBANK', 'UNION BANK OF INDIA', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5418, 'NSE_EQ|INE405E01023', '14154', 'UNOMINDA', 'UNO MINDA LIMITED', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5419, 'NSE_EQ|INE628A01036', '11287', 'UPL', 'UPL LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5437, 'NSE_EQ|INE094J01016', '527', 'UTIAMC', 'UTI ASSET MNGMT CO LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5479, 'NSE_EQ|INE884A01027', '11364', 'VAIBHAVGBL', 'VAIBHAV GLOBAL LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5485, 'NSE_EQ|INE665L01035', '3857', 'VARROC', 'VARROC ENGINEERING LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5489, 'NSE_EQ|INE200M01039', '18921', 'VBL', 'VARUN BEVERAGES LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5491, 'NSE_EQ|INE205A01025', '3063', 'VEDL', 'VEDANTA LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5503, 'NSE_EQ|INE951I01027', '15362', 'VGUARD', 'V-GUARD IND LTD.', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5508, 'NSE_EQ|INE043W01024', '5585', 'VIJAYA', 'VIJAYA DIAGNOSTIC CEN LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5513, 'NSE_EQ|INE410B01037', '17364', 'VINATIORGA', 'VINATI ORGANICS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5519, 'NSE_EQ|INE054A01027', '3703', 'VIPIND', 'VIP INDUSTRIES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5536, 'NSE_EQ|INE665J01013', '29284', 'VMART', 'VMART RETAIL LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5538, 'NSE_EQ|INE226A01021', '3718', 'VOLTAS', 'VOLTAS LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5544, 'NSE_EQ|INE825A01020', '2073', 'VTL', 'VARDHMAN TEXTILES LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5554, 'NSE_EQ|INE191B01025', '11821', 'WELCORP', 'WELSPUN CORP LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5559, 'NSE_EQ|INE274F01020', '11580', 'WESTLIFE', 'WESTLIFE FOODWORLD LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5562, 'NSE_EQ|INE716A01013', '18011', 'WHIRLPOOL', 'WHIRLPOOL OF INDIA LTD', NULL, NULL, NULL, 10, 1, 'EQ', NULL, 'NSE', 1),
(5567, 'NSE_EQ|INE075A01022', '3787', 'WIPRO', 'WIPRO LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5577, 'NSE_EQ|INE528G01035', '11915', 'YESBANK', 'YES BANK LIMITED', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5579, 'NSE_EQ|INE256A01028', '3812', 'ZEEL', 'ZEE ENTERTAINMENT ENT LTD', NULL, NULL, NULL, 1, 1, 'EQ', NULL, 'NSE', 1),
(5584, 'NSE_EQ|INE520A01027', '1076', 'ZENSARTECH', 'ZENSAR TECHNOLOGIES  LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5586, 'NSE_EQ|INE342J01019', '16915', 'ZFCVINDIA', 'ZF COM VE CTR SYS IND LTD', NULL, NULL, NULL, 100, 1, 'EQ', NULL, 'NSE', 1),
(5594, 'NSE_EQ|INE010B01027', '7929', 'ZYDUSLIFE', 'ZYDUS LIFESCIENCES LTD', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1),
(5595, 'NSE_EQ|INE768C01028', '17635', 'ZYDUSWELL', 'ZYDUS WELLNESS LIMITED', NULL, NULL, NULL, 5, 1, 'EQ', NULL, 'NSE', 1);

-- --------------------------------------------------------

--
-- Table structure for table `error_log`
--

CREATE TABLE `error_log` (
  `id` int NOT NULL,
  `message` longtext,
  `file` varchar(250) NOT NULL,
  `line` int NOT NULL,
  `trace` longtext,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `historical`
--

CREATE TABLE `historical` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `market_date` date NOT NULL,
  `open` double NOT NULL,
  `high` double NOT NULL,
  `low` double NOT NULL,
  `close` double DEFAULT NULL,
  `ltp` double DEFAULT NULL,
  `volumn` bigint DEFAULT NULL,
  `total_trade` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `holiday`
--

CREATE TABLE `holiday` (
  `id` int NOT NULL,
  `event` varchar(100) NOT NULL,
  `event_date` date NOT NULL,
  `day` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `logger`
--

CREATE TABLE `logger` (
  `id` int NOT NULL,
  `activity` longtext NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `equity_id` int DEFAULT NULL,
  `checked` tinyint NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `long_term_indicator`
--

CREATE TABLE `long_term_indicator` (
  `id` int NOT NULL,
  `trend_history_id` int NOT NULL COMMENT 'ong-term-trend-history',
  `equity_id` int NOT NULL,
  `nearest_ma_uptrend` int DEFAULT NULL,
  `mid_ma_uptrend` int DEFAULT NULL,
  `far_ma_uptrend` tinyint DEFAULT NULL,
  `body_ma_uptrend` int DEFAULT NULL,
  `cross_over_ltp` tinyint DEFAULT NULL COMMENT 'ltp is top of specific indication',
  `supertrend_close` float DEFAULT NULL,
  `supertrend_type` tinyint DEFAULT NULL COMMENT 'Primary Supertrend(10,1)',
  `supertrend_series` mediumint DEFAULT NULL,
  `macd` float DEFAULT NULL,
  `macd_signal` float DEFAULT NULL,
  `macd_hist` float DEFAULT NULL,
  `rsi` float DEFAULT NULL,
  `ema` float DEFAULT NULL,
  `supertrend_three` tinyint DEFAULT NULL COMMENT '10,3',
  `ma_supertrend` float DEFAULT NULL,
  `adx` float DEFAULT NULL,
  `adx_pma` float DEFAULT NULL COMMENT 'ADX Primary MA',
  `adx_sma` float DEFAULT NULL COMMENT 'Secondary ADX MA',
  `obv` bigint DEFAULT NULL,
  `obv_ma` bigint DEFAULT NULL,
  `body_to_near_diff` float DEFAULT NULL,
  `body_to_mid_diff` float DEFAULT NULL,
  `locked` tinyint DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `long_term_trend_history`
--

CREATE TABLE `long_term_trend_history` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `nearest_ma` float DEFAULT NULL COMMENT 'Period: 15',
  `mid_ma` float DEFAULT NULL COMMENT 'Period: 50',
  `far_ma` float DEFAULT NULL COMMENT 'Period: 200',
  `body_ma` float DEFAULT NULL,
  `distance_ratio` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lt_ob_zone`
--

CREATE TABLE `lt_ob_zone` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `zone_low` float NOT NULL,
  `zone_high` float NOT NULL,
  `irl_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lt_td_position`
--

CREATE TABLE `lt_td_position` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `position` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `value` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `metadata`
--

CREATE TABLE `metadata` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `market_date` date NOT NULL,
  `meta_name` varchar(100) NOT NULL,
  `meta_value` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `metadata`
--

INSERT INTO `metadata` (`id`, `equity_id`, `market_date`, `meta_name`, `meta_value`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 5567, '2025-12-18', '_UPTREND_CHECKED', '263.85', '2025-12-18 03:46:41', '2025-12-26 17:08:42', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ohlc`
--

CREATE TABLE `ohlc` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `open` float NOT NULL,
  `high` float NOT NULL,
  `low` float NOT NULL,
  `close` float NOT NULL,
  `volume` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_book`
--

CREATE TABLE `order_book` (
  `id` int NOT NULL,
  `trade_id` int NOT NULL,
  `api_order_id` bigint DEFAULT NULL,
  `strategy` varchar(20) NOT NULL,
  `market_date` date NOT NULL,
  `exchange` varchar(10) NOT NULL,
  `tradingsymbol` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `rsi` float DEFAULT NULL,
  `variety` varchar(50) NOT NULL COMMENT 'ex. bo, co, amo, regular',
  `transaction_type` enum('BUY','SELL') NOT NULL,
  `product` varchar(50) NOT NULL,
  `quantity` int NOT NULL,
  `open_price` float NOT NULL COMMENT 'Daily market open price',
  `price` float NOT NULL,
  `sellprice` float DEFAULT NULL,
  `ltp` float DEFAULT NULL,
  `chngprcnt` float DEFAULT NULL,
  `buy_on_dip` float DEFAULT NULL,
  `order_type` varchar(20) NOT NULL,
  `api_status` varchar(50) DEFAULT NULL,
  `status` varchar(100) NOT NULL,
  `parent_order_id` bigint DEFAULT NULL,
  `final_day` date DEFAULT NULL COMMENT 'Next day it will be sold',
  `info` longtext,
  `locked` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'prevent duplicate API call',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pattern`
--

CREATE TABLE `pattern` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `function_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `priority` smallint NOT NULL,
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `type` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `is_active` tinyint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pattern`
--

INSERT INTO `pattern` (`id`, `name`, `function_key`, `priority`, `description`, `type`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Bullish Abandoned Baby', 'cdlabandonedbaby', 1, NULL, 'bullish', 1, '2025-12-26 17:27:13', '2025-12-26 17:22:46'),
(2, 'Three Inside Up', 'cdl3inside', 2, NULL, 'bullish', 1, '2025-12-26 17:27:13', '2025-12-26 17:22:46'),
(3, 'Three Outside Up', 'cdl3outside', 3, NULL, 'bullish', 0, '2025-12-26 17:39:45', '2025-12-27 08:52:51'),
(4, 'Morning Star', 'cdlmorningstar', 4, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(5, 'Three Advancing White Soldiers', 'cdl3whitesoldiers', 5, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(6, 'Rising Three Methods', 'cdlrisefall3methods', 6, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(7, 'Unique 3 River', 'cdlunique3river', 7, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(8, 'Morning Doji Star', 'cdlmorningdojistar', 8, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(9, 'Tristar Pattern', 'cdltristar', 9, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(10, 'Ladder Bottom', 'cdlladderbottom', 10, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(11, 'Breakaway', 'cdlbreakaway', 11, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(12, 'Stick Sandwich', 'cdlsticksandwich', 12, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(13, 'Advance Block', 'cdladvanceblock', 13, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(14, 'Concealing Baby Swallow', 'cdlconcealbabyswall', 13, NULL, 'bullish', 1, '2025-12-26 17:39:45', '2025-12-26 17:22:46'),
(15, 'Matching Low', 'cdlmatchinglow', 15, NULL, '', 1, '2025-12-27 06:22:31', '2025-12-27 06:20:34'),
(16, 'Counterattack', 'cdlcounterattack', 16, NULL, '', 1, '2025-12-27 06:22:31', '2025-12-27 06:20:34');

-- --------------------------------------------------------

--
-- Table structure for table `script`
--

CREATE TABLE `script` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `command` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `frequency` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sequence` smallint NOT NULL,
  `time` time DEFAULT NULL,
  `description` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `params` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_active` tinyint NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `script`
--

INSERT INTO `script` (`id`, `name`, `command`, `frequency`, `sequence`, `time`, `description`, `params`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Load History', 'stock:load-history', 'dailyAt', 1, '07:00:00', 'This will load daily stock history', NULL, 1, '2023-09-02 14:47:18', '2023-10-30 16:10:07'),
(2, 'Set Indicators', 'stock:indicator', 'dailyAt', 2, '07:20:00', 'Should be called before pick-uptrend. This command will check the historical data and set trading point for long term trading', NULL, 1, '2023-09-02 14:47:18', '2023-10-30 16:10:11'),
(3, 'Pick Uptrend', 'stock:uptrend', 'dailyAt', 3, '07:30:00', 'This will pick uptrend stocks for long and short-term', NULL, 0, '2023-09-02 14:50:02', '2024-05-05 14:32:04'),
(4, 'Prepare Orderbook', 'stock:order', 'dailyAt', 4, '08:00:00', 'This will prepare the order book by taking data from trade', NULL, 0, '2023-09-02 14:53:35', '2024-05-05 14:32:08'),
(5, 'Live Feed', 'stock:live', 'everyMinute', 5, NULL, 'Update live data and place buy or sell order', NULL, 0, '2023-09-02 14:53:35', '2024-05-05 14:32:14'),
(6, 'Update Order Status', 'stock:update-status', 'everyMinute', 6, NULL, 'Frequently update order details with lates status', NULL, 0, '2023-09-02 14:56:56', '2024-05-05 14:32:23'),
(7, 'Market Adjustment', 'stock:market-adjust', 'dailyAt', 8, '08:10:00', 'This is a crucial function to adjust the stop-loss and other data', NULL, 0, '2023-09-02 14:56:56', '2024-05-05 14:32:27'),
(8, 'Reconlilation Work', 'stock:reconcile', 'dailyAt', 7, '08:30:08', 'Reconcile work to adjust weekly data and other work', NULL, 0, '2023-09-02 15:00:42', '2024-04-07 06:24:29');

-- --------------------------------------------------------

--
-- Table structure for table `script_run`
--

CREATE TABLE `script_run` (
  `id` int NOT NULL,
  `script_id` int NOT NULL,
  `ad_hoc` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `completed` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `params` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `output` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `script_run`
--

INSERT INTO `script_run` (`id`, `script_id`, `ad_hoc`, `completed`, `created_at`, `completed_at`, `params`, `output`, `updated_at`) VALUES
(1, 0, NULL, 'Y', '2025-11-08 14:22:40', '2025-01-01 03:46:39', NULL, NULL, '2025-11-08 14:22:40'),
(2, 0, NULL, 'Y', '2025-12-21 08:41:37', '2025-01-01 03:46:52', NULL, NULL, '2025-12-21 08:41:37'),
(3, 1, 'Y', 'N', '2024-11-16 03:46:03', NULL, NULL, NULL, '2025-12-21 08:49:03'),
(4, 0, NULL, 'Y', '2025-12-21 10:34:11', '2025-01-01 03:46:01', NULL, NULL, '2025-12-21 10:34:11'),
(5, 0, NULL, 'Y', '2025-12-21 13:38:10', '2025-01-01 03:46:10', NULL, NULL, '2025-12-21 13:38:10'),
(6, 0, NULL, 'Y', '2025-12-21 13:38:14', '2025-01-01 03:46:14', NULL, NULL, '2025-12-21 13:38:14'),
(7, 0, NULL, 'Y', '2025-12-21 13:38:54', '2025-01-01 03:46:54', NULL, NULL, '2025-12-21 13:38:54'),
(8, 0, NULL, 'Y', '2025-12-21 13:39:28', '2025-01-01 03:46:28', NULL, NULL, '2025-12-21 13:39:28'),
(9, 0, NULL, 'Y', '2025-12-21 13:42:55', '2025-01-01 03:46:55', NULL, NULL, '2025-12-21 13:42:55'),
(10, 0, NULL, 'Y', '2025-12-21 15:08:48', '2025-01-01 03:46:47', NULL, NULL, '2025-12-21 15:08:48'),
(11, 0, NULL, 'Y', '2025-12-21 15:20:03', '2025-01-01 03:46:19', NULL, NULL, '2025-12-21 15:20:03'),
(12, 0, NULL, 'Y', '2025-12-21 15:46:03', '2025-01-01 03:46:30', NULL, NULL, '2025-12-21 15:46:03'),
(13, 0, NULL, 'Y', '2025-12-21 15:51:27', '2025-01-01 03:46:52', NULL, NULL, '2025-12-21 15:51:27'),
(14, 0, NULL, 'Y', '2025-12-21 15:58:21', '2025-01-01 03:46:40', NULL, NULL, '2025-12-21 15:58:21'),
(15, 0, NULL, 'Y', '2025-12-21 16:06:18', '2025-01-01 03:46:35', NULL, NULL, '2025-12-21 16:06:18'),
(16, 0, NULL, 'Y', '2025-12-21 16:26:39', '2025-01-01 03:46:30', NULL, NULL, '2025-12-21 16:26:39'),
(17, 0, NULL, 'Y', '2025-12-21 16:35:01', '2025-01-01 03:46:01', NULL, NULL, '2025-12-21 16:35:01'),
(18, 0, NULL, 'Y', '2025-12-21 16:37:37', '2025-01-01 03:46:51', NULL, NULL, '2025-12-21 16:37:37'),
(19, 0, NULL, 'Y', '2025-12-25 17:19:24', '2025-01-01 03:46:24', NULL, NULL, '2025-12-25 17:19:24'),
(20, 0, NULL, 'Y', '2025-12-25 17:19:27', '2025-01-01 03:46:26', NULL, NULL, '2025-12-25 17:19:27'),
(21, 0, NULL, 'Y', '2025-12-25 17:20:06', '2025-01-01 03:46:05', NULL, NULL, '2025-12-25 17:20:06'),
(22, 0, NULL, 'Y', '2025-12-25 17:24:46', '2025-01-01 03:46:29', NULL, NULL, '2025-12-25 17:24:46'),
(23, 0, NULL, 'Y', '2025-12-25 17:46:15', '2025-01-01 03:46:02', NULL, NULL, '2025-12-25 17:46:15'),
(24, 0, NULL, 'Y', '2025-12-25 17:51:54', '2025-01-01 03:46:33', NULL, NULL, '2025-12-25 17:51:54'),
(25, 0, NULL, 'Y', '2025-12-26 16:21:55', '2025-12-17 03:46:29', NULL, NULL, '2025-12-26 16:21:55');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int NOT NULL,
  `option_name` varchar(100) NOT NULL,
  `option_value` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `option_name`, `option_value`, `created_at`, `updated_at`) VALUES
(1, 'pre_market_open', '1', '2021-06-10 06:43:14', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `short_term_historical`
--

CREATE TABLE `short_term_historical` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `open` double NOT NULL,
  `high` double NOT NULL,
  `low` double NOT NULL,
  `close` double DEFAULT NULL,
  `volume` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `short_term_historical_realtime`
--

CREATE TABLE `short_term_historical_realtime` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `open` double NOT NULL,
  `high` double NOT NULL,
  `low` double NOT NULL,
  `close` double DEFAULT NULL,
  `volume` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `short_term_indicator`
--

CREATE TABLE `short_term_indicator` (
  `id` int NOT NULL,
  `trend_history_id` int NOT NULL COMMENT 'ong-term-trend-history',
  `equity_id` int NOT NULL,
  `supertrend_close` float DEFAULT NULL,
  `supertrend_type` tinyint DEFAULT NULL COMMENT 'Primary Supertrend(10,1)',
  `macd` float DEFAULT NULL,
  `macd_signal` float DEFAULT NULL,
  `macd_hist` float DEFAULT NULL,
  `rsi` float DEFAULT NULL,
  `ema` float DEFAULT NULL,
  `adx` float DEFAULT NULL,
  `adx_pma` float DEFAULT NULL COMMENT 'ADX Primary MA',
  `adx_sma` float DEFAULT NULL COMMENT 'Secondary ADX MA',
  `obv` bigint DEFAULT NULL,
  `obv_ma` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `short_term_trend_history`
--

CREATE TABLE `short_term_trend_history` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `nearest_ma` float DEFAULT NULL COMMENT 'Period: 15',
  `mid_ma` float DEFAULT NULL COMMENT 'Period: 50',
  `far_ma` float DEFAULT NULL COMMENT 'Period: 200',
  `body_ma` float DEFAULT NULL,
  `distance_ratio` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stoploss`
--

CREATE TABLE `stoploss` (
  `id` int NOT NULL,
  `order_id` int NOT NULL,
  `stoploss` float NOT NULL COMMENT 'For sudden drop in a single day',
  `min_stoploss` float DEFAULT NULL,
  `trigger_price` float NOT NULL,
  `sl_type` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sl_hit` smallint NOT NULL DEFAULT '0',
  `trailing_stoploss` float DEFAULT NULL,
  `sl_freeze` tinyint DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `st_top_down_position`
--

CREATE TABLE `st_top_down_position` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `position` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `value` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_lookup`
--

CREATE TABLE `system_lookup` (
  `id` int NOT NULL,
  `field_name` varchar(20) NOT NULL,
  `field_value` longtext NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `system_lookup`
--

INSERT INTO `system_lookup` (`id`, `field_name`, `field_value`, `description`, `created_at`) VALUES
(1, 'TOTP_TOKEN', '866512', NULL, '2023-04-10 11:34:25'),
(2, 'INC_VALUE', '60', NULL, '2023-04-15 11:49:36'),
(3, 'ROW_LIMIT', '0-10', NULL, '2023-04-23 11:13:33'),
(4, 'CASH', '50000', NULL, '2023-04-26 17:25:48'),
(5, 'FEED_TOKEN', 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiJKUzU5MTAiLCJqdGkiOiI2OTQ2NjJmMjA5MDY1MTJhOWY2NWRhNWUiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc2NjIyMDUzMCwiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzY2MjY4MDAwfQ.JOMa7k6Q6haGzdbCCTFaWDFtCkIsNCPIzw9cwc_Ev2I', NULL, '2023-05-08 15:33:58'),
(6, 'INC_TIME', '60', NULL, '2023-06-03 12:40:00'),
(7, 'DAYS_BEFORE1', '0', NULL, '2023-07-22 06:30:09'),
(8, 'LAST_RUN_DATE', '2025-12-12', NULL, '2024-01-11 17:01:13');

-- --------------------------------------------------------

--
-- Table structure for table `trade`
--

CREATE TABLE `trade` (
  `id` int NOT NULL,
  `history_id` int NOT NULL,
  `strategy` varchar(50) NOT NULL,
  `stock_number` int NOT NULL,
  `final_price` double NOT NULL,
  `stoploss` double DEFAULT NULL,
  `meta_info` longtext,
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: not started; 1: sent to order book; 2: completed',
  `is_active` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0= inactive; 1=active; 2=archived',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_app`
--

CREATE TABLE `user_app` (
  `id` char(36) COLLATE utf8mb4_general_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_general_ci NOT NULL,
  `broker` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `client_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `client_secret` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `access_token` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `account_type` varchar(10) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'sandbox',
  `last_used_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_app`
--

INSERT INTO `user_app` (`id`, `user_id`, `broker`, `client_id`, `client_secret`, `access_token`, `is_active`, `account_type`, `last_used_at`, `expires_at`, `revoked_at`, `created_at`) VALUES
('0fe66df4-e98f-11f0-af21-0c84dcb31c07', '3', 'upstox', '1dff1376-b5a3-4fd9-bf64-7848e387e1d3', 'r0unh2a6ct', 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiJKUzU5MTAiLCJqdGkiOiI2OTViNDJjMzQ4ZDQ1YjY3ZDRhOGRiZmUiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc2NzU4ODU0NywiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzY3NjUwNDAwfQ.wHkkb6NZZXkrW0ERXXKodRhfXVFRMOxOW0_ETjNm69M', 1, 'sandbox', '2026-01-05 04:49:07', NULL, NULL, '2026-01-04 22:31:50');

-- --------------------------------------------------------

--
-- Table structure for table `watchlist`
--

CREATE TABLE `watchlist` (
  `id` int NOT NULL,
  `equity_id` int NOT NULL,
  `strategy` varchar(50) NOT NULL,
  `meta_info` longtext,
  `status` int NOT NULL,
  `last_price` float DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1=active; 2=archived',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `api_logs`
--
ALTER TABLE `api_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_logs_user` (`user_id`),
  ADD KEY `idx_logs_user_api` (`user_api_id`);

--
-- Indexes for table `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indexes for table `auth_user`
--
ALTER TABLE `auth_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  ADD KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`);

--
-- Indexes for table `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  ADD KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`);

--
-- Indexes for table `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indexes for table `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indexes for table `equity`
--
ALTER TABLE `equity`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `error_log`
--
ALTER TABLE `error_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `historical`
--
ALTER TABLE `historical`
  ADD PRIMARY KEY (`id`),
  ADD KEY `equity_id` (`equity_id`),
  ADD KEY `created_at` (`created_at`);

--
-- Indexes for table `holiday`
--
ALTER TABLE `holiday`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `logger`
--
ALTER TABLE `logger`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `long_term_indicator`
--
ALTER TABLE `long_term_indicator`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `long_term_trend_history`
--
ALTER TABLE `long_term_trend_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lt_ob_zone`
--
ALTER TABLE `lt_ob_zone`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lt_td_position`
--
ALTER TABLE `lt_td_position`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `metadata`
--
ALTER TABLE `metadata`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ohlc`
--
ALTER TABLE `ohlc`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `order_book`
--
ALTER TABLE `order_book`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pattern`
--
ALTER TABLE `pattern`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `script`
--
ALTER TABLE `script`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `script_run`
--
ALTER TABLE `script_run`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `short_term_historical`
--
ALTER TABLE `short_term_historical`
  ADD PRIMARY KEY (`id`),
  ADD KEY `equity_id` (`equity_id`);

--
-- Indexes for table `short_term_historical_realtime`
--
ALTER TABLE `short_term_historical_realtime`
  ADD PRIMARY KEY (`id`),
  ADD KEY `equity_id` (`equity_id`);

--
-- Indexes for table `short_term_indicator`
--
ALTER TABLE `short_term_indicator`
  ADD PRIMARY KEY (`id`),
  ADD KEY `equity_id` (`equity_id`);

--
-- Indexes for table `short_term_trend_history`
--
ALTER TABLE `short_term_trend_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `equity_id` (`equity_id`);

--
-- Indexes for table `stoploss`
--
ALTER TABLE `stoploss`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `st_top_down_position`
--
ALTER TABLE `st_top_down_position`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `system_lookup`
--
ALTER TABLE `system_lookup`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trade`
--
ALTER TABLE `trade`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_app`
--
ALTER TABLE `user_app`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_broker` (`user_id`,`broker`),
  ADD KEY `idx_trading_user` (`user_id`),
  ADD KEY `idx_trading_active` (`is_active`);

--
-- Indexes for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `api_logs`
--
ALTER TABLE `api_logs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `auth_user`
--
ALTER TABLE `auth_user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `equity`
--
ALTER TABLE `equity`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5596;

--
-- AUTO_INCREMENT for table `error_log`
--
ALTER TABLE `error_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `historical`
--
ALTER TABLE `historical`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday`
--
ALTER TABLE `holiday`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logger`
--
ALTER TABLE `logger`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `long_term_indicator`
--
ALTER TABLE `long_term_indicator`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `long_term_trend_history`
--
ALTER TABLE `long_term_trend_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lt_ob_zone`
--
ALTER TABLE `lt_ob_zone`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lt_td_position`
--
ALTER TABLE `lt_td_position`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `metadata`
--
ALTER TABLE `metadata`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ohlc`
--
ALTER TABLE `ohlc`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_book`
--
ALTER TABLE `order_book`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pattern`
--
ALTER TABLE `pattern`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `script`
--
ALTER TABLE `script`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `script_run`
--
ALTER TABLE `script_run`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `short_term_historical`
--
ALTER TABLE `short_term_historical`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `short_term_historical_realtime`
--
ALTER TABLE `short_term_historical_realtime`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `short_term_indicator`
--
ALTER TABLE `short_term_indicator`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `short_term_trend_history`
--
ALTER TABLE `short_term_trend_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stoploss`
--
ALTER TABLE `stoploss`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `st_top_down_position`
--
ALTER TABLE `st_top_down_position`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_lookup`
--
ALTER TABLE `system_lookup`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `trade`
--
ALTER TABLE `trade`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `watchlist`
--
ALTER TABLE `watchlist`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
