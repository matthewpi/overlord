/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

// overlord_servers - Stores all servers.
#define TABLE_SERVERS "\
CREATE TABLE IF NOT EXISTS `overlord_servers` ( \
    `id`        INT(11)     AUTO_INCREMENT, \
    `name`      VARCHAR(64) NOT NULL, \
    `ipAddress` VARCHAR(16) NOT NULL, \
    `port`      VARCHAR(5)  NOT NULL, \
    `rconPass`  VARCHAR(64) NOT NULL, \
    PRIMARY KEY (`id`, `name`, `ipAddress`, `port`), \
    CONSTRAINT `overlord_servers_id_uindex` UNIQUE (`id`), \
    CONSTRAINT `overlord_servers_name_uindex` UNIQUE (`name`), \
    CONSTRAINT `overlord_servers_ipAddress_port_uindex` UNIQUE (`ipAddress`, `port`) \
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

// overlord_groups - Stores all admin groups.
#define TABLE_GROUPS "\
CREATE TABLE IF NOT EXISTS `overlord_groups` ( \
    `id`       INT(11)     AUTO_INCREMENT, \
    `name`     VARCHAR(32) DEFAULT 'Default' NOT NULL, \
    `tag`      VARCHAR(12) DEFAULT ''        NOT NULL, \
    `immunity` INT(4)      DEFAULT 0         NOT NULL, \
    `flags`    VARCHAR(26) DEFAULT ''        NOT NULL, \
    PRIMARY KEY (`id`, `name`, `tag`), \
    CONSTRAINT `overlord_groups_id_uindex` UNIQUE (`id`), \
    CONSTRAINT `overlord_groups_name_uindex` UNIQUE (`name`), \
    CONSTRAINT `overlord_groups_tag_uindex` UNIQUE (`tag`) \
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

// overlord_admins - Stores all active admins.
#define TABLE_ADMINS "\
CREATE TABLE IF NOT EXISTS `overlord_admins` ( \
    `id`        INT(11)     AUTO_INCREMENT, \
    `name`      VARCHAR(32) NOT NULL, \
    `steamId`   VARCHAR(64) NOT NULL, \
    `groupId`   INT(11)     DEFAULT NULL, \
    `hidden`    TINYINT(1)  DEFAULT 0 NOT NULL, \
    `active`    TINYINT(1)  DEFAULT 1 NOT NULL, \
    `createdAt` TIMESTAMP   DEFAULT CURRENT_TIMESTAMP() NOT NULL, \
    `updatedAt` TIMESTAMP   DEFAULT CURRENT_TIMESTAMP() NOT NULL ON UPDATE CURRENT_TIMESTAMP(), \
    PRIMARY KEY (`id`, `name`, `steamId`), \
    CONSTRAINT `overlord_admins_id_uindex` UNIQUE (`id`), \
    CONSTRAINT `overlord_admins_name_uindex` UNIQUE (`name`), \
    CONSTRAINT `overlord_admins_steamId_uindex` UNIQUE (`steamId`) \
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

// overlord_admin_groups - Stores adminId, groupId, serverId relation.
#define TABLE_ADMIN_GROUPS "\
CREATE TABLE IF NOT EXISTS `overlord_admin_groups` (\
    `adminId`   INT(11)   NOT NULL, \
    `groupId`   INT(11)   NOT NULL, \
    `serverId`  INT(11)   NOT NULL, \
    `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL, \
    `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL ON UPDATE CURRENT_TIMESTAMP(), \
    PRIMARY KEY (`adminId`, `groupId`, `serverId`), \
    CONSTRAINT `overlord_admin_groups_id_uindex` UNIQUE (`id`), \
    CONSTRAINT `overlord_admin_groups_adminId_serverId_uindex` UNIQUE (`adminId`, `serverId`), \
    FOREIGN KEY `overlord_admin_groups_overlord_admins_id_fk` (`adminId`) REFERENCES `overlord_admins` (`id`) ON UPDATE CASCADE, \
    FOREIGN KEY `overlord_admin_groups_overlord_groups_id_fk` (`groupId`) REFERENCES `overlord_groups` (`id`) ON UPDATE CASCADE, \
    FOREIGN KEY `overlord_admin_groups_overlord_servers_id_fk` (`serverId`) REFERENCES `overlord_servers` (`id`) ON UPDATE CASCADE \
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

// Selects an existing server.
#define GET_SERVER "\
SELECT `overlord_servers`.`id` FROM `overlord_servers` WHERE `overlord_servers`.`ipAddress` = '%s' AND `overlord_servers`.`port` = '%s' LIMIT 1;\
"

// Inserts a new server.
#define INSERT_SERVER "\
INSERT INTO `overlord_servers` (`name`, `ipAddress`, `port`, `rconPass`) VALUES ('%s', '%s', '%s', '%s');\
"

// Selects all groups.
#define GET_GROUPS "\
SELECT `overlord_groups`.`id`, `overlord_groups`.`name`, `overlord_groups`.`tag`, `overlord_groups`.`immunity`, `overlord_groups`.`flags` FROM `overlord_groups`;\
"

// Updates a group's information.
#define UPDATE_GROUP "\
UPDATE `overlord_groups` SET \
    `overlord_groups`.`name` = '%s', `overlord_groups`.`tag` = '%s', `overlord_groups`.`immunity` = %i, `overlord_groups`.`flags` = '%s' \
WHERE \
    `overlord_groups`.`id` = %i \
LIMIT 1;\
"

// Selects an admin and their group id for this server.
#define GET_ADMIN  "\
SELECT `overlord_admins`.`id`, `overlord_admins`.`name`, `overlord_admins`.`steamId`, `overlord_admins`.`hidden`, \
    `overlord_admins`.`active`, UNIX_TIMESTAMP(`overlord_admins`.`createdAt`) AS `createdAt`, `overlord_admins`.`groupId`, \
    `overlord_admin_groups`.`groupId` AS `serverGroupId` \
FROM `overlord_admins` \
    LEFT OUTER JOIN `overlord_admin_groups` ON `overlord_admins`.`id` = `overlord_admin_groups`.`adminId` \
                                           AND `overlord_admin_groups`.`serverId` = %i \
WHERE `overlord_admins`.`steamId` LIKE '%%:%s' LIMIT 1;\
"

// Inserts an admin's information.
#define INSERT_ADMIN "\
INSERT INTO `overlord_admins` (`name`, `steamId`) VALUES ('%s', '%s');\
"

// Updates an admin's information.
#define UPDATE_ADMIN "\
UPDATE `overlord_admins` SET `overlord_admins`.`name` = '%s', `overlord_admins`.`groupId` = %i, `overlord_admins`.`hidden` = %i WHERE `overlord_admins`.`steamId` = '%s' LIMIT 1;\
"

// Update an admin's server group.
#define UPDATE_ADMIN_SERVER_GROUP "\
INSERT INTO `overlord_admin_groups` (`adminId`, `groupId`, `serverId`) VALUES (%i, %i, %i) ON DUPLICATE KEY UPDATE `overlord_admin_groups`.`groupId` = %i;\
"

// Deletes an admin's database entry.
#define DELETE_ADMIN "\
DELETE FROM `overlord_admins` WHERE `overlord_admins`.`steamId` = '%s';\
"
