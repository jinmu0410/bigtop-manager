/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *    https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


# delimiter ;

# CREATE DATABASE `bigtop_manager` /*!40100 DEFAULT CHARACTER SET utf8 */;
#
# CREATE USER 'bigtop_manager' IDENTIFIED BY 'bigdata';

# USE @schema;

-- Set default_storage_engine to InnoDB
-- storage_engine variable should be used for versions prior to MySQL 5.6
set @version_short = substring_index(@@version, '.', 2);
set @major = cast(substring_index(@version_short, '.', 1) as SIGNED);
set @minor = cast(substring_index(@version_short, '.', -1) as SIGNED);
set @engine_stmt = IF((@major >= 5 AND @minor>=6) or @major >= 8, 'SET default_storage_engine=INNODB', 'SET storage_engine=INNODB');
prepare statement from @engine_stmt;
execute statement;
DEALLOCATE PREPARE statement;

CREATE TABLE `audit_log`
(
    `id`                BIGINT NOT NULL,
    `args`              LONGTEXT,
    `create_by`         BIGINT,
    `create_time`       DATETIME,
    `operation_desc`    VARCHAR(255),
    `operation_summary` VARCHAR(255),
    `tag_desc`          VARCHAR(255),
    `tag_name`          VARCHAR(255),
    `update_by`         BIGINT,
    `update_time`       DATETIME,
    `uri`               VARCHAR(255),
    `user_id`           BIGINT,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `sequence`
(
    `id`        BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `seq_name`  VARCHAR(100) NOT NULL,
    `seq_count` BIGINT(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_seq_name` (`seq_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `user`
(
    `id`          BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `username`    VARCHAR(32) DEFAULT NULL,
    `password`    VARCHAR(32) DEFAULT NULL,
    `nickname`    VARCHAR(32) DEFAULT NULL,
    `status`      BIT(1)      DEFAULT 1 COMMENT '0-Disable, 1-Enable',
    `create_time` DATETIME    DEFAULT NULL,
    `update_time` DATETIME    DEFAULT NULL,
    `create_by`   BIGINT,
    `update_by`   BIGINT,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `cluster`
(
    `id`            BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `cluster_name`  VARCHAR(255) DEFAULT NULL COMMENT 'Cluster Name',
    `cluster_desc`  VARCHAR(255) DEFAULT NULL COMMENT 'Cluster Description',
    `cluster_type`  SMALLINT UNSIGNED DEFAULT 1 COMMENT '1-Physical Machine, 2-Kubernetes',
    `selected`      BIT(1)       DEFAULT 1 COMMENT '0-Disable, 1-Enable',
    `create_time`   DATETIME     DEFAULT NULL,
    `update_time`   DATETIME     DEFAULT NULL,
    `create_by`     BIGINT,
    `packages`      VARCHAR(255),
    `repo_template` VARCHAR(255),
    `root`          VARCHAR(255),
    `state`         VARCHAR(255),
    `update_by`     BIGINT,
    `user_group`    VARCHAR(255),
    `stack_id`      BIGINT,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_cluster_name` (`cluster_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `component`
(
    `id`              BIGINT NOT NULL,
    `category`        VARCHAR(255),
    `command_script`  VARCHAR(255),
    `component_name`  VARCHAR(255),
    `create_by`       BIGINT,
    `create_time`     DATETIME,
    `custom_commands` LONGTEXT,
    `display_name`    VARCHAR(255),
    `quick_link`      VARCHAR(255),
    `update_by`       BIGINT,
    `update_time`     DATETIME,
    `cluster_id`      BIGINT,
    `service_id`      BIGINT,
    PRIMARY KEY (id),
    KEY               `idx_component_cluster_id` (cluster_id),
    KEY               `idx_component_service_id` (service_id),
    UNIQUE KEY `uk_component_name` (`component_name`, `cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `host_component`
(
    `id`           BIGINT NOT NULL,
    `create_by`    BIGINT,
    `create_time`  DATETIME,
    `state`        VARCHAR(255),
    `update_by`    BIGINT,
    `update_time`  DATETIME,
    `component_id` BIGINT,
    `host_id`      BIGINT,
    PRIMARY KEY (id),
    KEY            `idx_hc_component_id` (component_id),
    KEY            `idx_hc_host_id` (host_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `host`
(
    `id`                   BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `cluster_id`           BIGINT(20) UNSIGNED NOT NULL,
    `hostname`             VARCHAR(255) DEFAULT NULL,
    `ipv4`                 VARCHAR(32)  DEFAULT NULL,
    `ipv6`                 VARCHAR(32)  DEFAULT NULL,
    `arch`                 VARCHAR(32)  DEFAULT NULL,
    `os`                   VARCHAR(32)  DEFAULT NULL,
    `processor_count`      INT          DEFAULT NULL,
    `physical_memory`      BIGINT       DEFAULT NULL COMMENT 'Total Physical Memory(Bytes)',
    `state`                VARCHAR(32)  DEFAULT NULL,
    `create_time`          DATETIME     DEFAULT NULL,
    `update_time`          DATETIME     DEFAULT NULL,
    `available_processors` INTEGER,
    `create_by`            BIGINT,
    `free_disk`            BIGINT,
    `free_memory_size`     BIGINT,
    `total_disk`           BIGINT,
    `total_memory_size`    BIGINT,
    `update_by`            BIGINT,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_hostname` (`hostname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `repo`
(
    `id`          BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `cluster_id`  BIGINT(20) UNSIGNED NOT NULL,
    `os`          VARCHAR(32) DEFAULT NULL,
    `arch`        VARCHAR(32) DEFAULT NULL,
    `base_url`    VARCHAR(64) DEFAULT NULL,
    `repo_id`     VARCHAR(32) DEFAULT NULL,
    `repo_name`   VARCHAR(64) DEFAULT NULL,
    `repo_type`   VARCHAR(64) DEFAULT NULL,
    `create_time` DATETIME    DEFAULT NULL,
    `update_time` DATETIME    DEFAULT NULL,
    `create_by`   BIGINT,
    `update_by`   BIGINT,
    PRIMARY KEY (`id`),
    KEY           `idx_cluster_id` (`cluster_id`),
    UNIQUE KEY `uk_repo_id` (`repo_id`, `os`, `arch`, `cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `stack`
(
    `id`             BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `stack_name`     VARCHAR(32) NOT NULL,
    `stack_version`  VARCHAR(32) NOT NULL,
    `create_time`    DATETIME DEFAULT NULL,
    `update_time`    DATETIME DEFAULT NULL,
    `create_by`      BIGINT,
    `update_by`      BIGINT,
    `component_name` VARCHAR(255),
    `context`        LONGTEXT,
    `order`          INTEGER,
    `service_name`   VARCHAR(255),
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_stack` (`stack_name`, `stack_version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `task`
(
    `id`              BIGINT NOT NULL,
    `command`         VARCHAR(255),
    `component_name`  VARCHAR(255),
    `content`         LONGTEXT,
    `context`         LONGTEXT NOT NULL,
    `create_by`       BIGINT,
    `create_time`     DATETIME,
    `custom_command`  VARCHAR(255),
    `hostname`        VARCHAR(255),
    `name`            VARCHAR(255),
    `service_name`    VARCHAR(255),
    `service_user`    VARCHAR(255),
    `stack_name`      VARCHAR(255),
    `stack_version`   VARCHAR(255),
    `state`           VARCHAR(255),
    `update_by`       BIGINT,
    `update_time`     DATETIME,
    `cluster_id`      BIGINT,
    `job_id`          BIGINT,
    `stage_id`        BIGINT,
    PRIMARY KEY (id),
    KEY               idx_task_cluster_id (cluster_id),
    KEY               idx_task_job_id (job_id),
    KEY               idx_task_stage_id (stage_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `job`
(
    `id`          BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `cluster_id`  BIGINT(20) UNSIGNED DEFAULT NULL,
    `state`       VARCHAR(32) NOT NULL,
    `context`     LONGTEXT    NOT NULL,
    `create_time` DATETIME DEFAULT NULL,
    `update_time` DATETIME DEFAULT NULL,
    `create_by`   BIGINT,
    `name`        VARCHAR(255),
    `update_by`   BIGINT,
    PRIMARY KEY (`id`),
    KEY           `idx_cluster_id` (`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `type_config`
(
    `id`                BIGINT NOT NULL,
    `create_by`         BIGINT,
    `create_time`       DATETIME,
    `properties_json`   LONGTEXT,
    `type_name`         VARCHAR(255),
    `update_by`         BIGINT,
    `update_time`       DATETIME,
    `service_config_id` BIGINT,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `service`
(
    `id`                BIGINT NOT NULL,
    `create_by`         BIGINT,
    `create_time`       DATETIME,
    `display_name`      VARCHAR(255),
    `package_specifics` VARCHAR(1024),
    `required_services` VARCHAR(255),
    `service_desc`      VARCHAR(1024),
    `service_name`      VARCHAR(255),
    `service_user`      VARCHAR(255),
    `service_version`   VARCHAR(255),
    `update_by`         BIGINT,
    `update_time`       DATETIME,
    `cluster_id`        BIGINT,
    PRIMARY KEY (id),
    KEY                 idx_service_cluster_id (cluster_id),
    UNIQUE KEY `uk_service_name` (`service_name`, `cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `service_config`
(
    `id`          BIGINT NOT NULL,
    `config_desc` VARCHAR(255),
    `create_by`   BIGINT,
    `create_time` DATETIME,
    `selected`    TINYINT(1) default 0,
    `update_by`   BIGINT,
    `update_time` DATETIME,
    `version`     INTEGER,
    `cluster_id`  BIGINT,
    `service_id`  BIGINT,
    PRIMARY KEY (id),
    KEY           idx_sc_cluster_id (cluster_id),
    KEY           idx_sc_service_id (service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `setting`
(
    `id`          BIGINT NOT NULL,
    `config_data` LONGTEXT,
    `create_by`   BIGINT,
    `create_time` DATETIME,
    `type_name`   VARCHAR(255),
    `update_by`   BIGINT,
    `update_time` DATETIME,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `stage`
(
    `id`             BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`           VARCHAR(32) NOT NULL,
    `cluster_id`     BIGINT(20) UNSIGNED DEFAULT NULL,
    `job_id`         BIGINT(20) UNSIGNED NOT NULL,
    `state`          VARCHAR(32) NOT NULL,
    `stage_order`    INT UNSIGNED DEFAULT NULL,
    `create_time`    DATETIME DEFAULT NULL,
    `update_time`    DATETIME DEFAULT NULL,
    `component_name` VARCHAR(255),
    `context`        LONGTEXT,
    `create_by`      BIGINT,
    `order`          INTEGER,
    `service_name`   VARCHAR(255),
    `update_by`      BIGINT,
    PRIMARY KEY (`id`),
    KEY              `idx_cluster_id` (`cluster_id`),
    KEY              `idx_job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initialize sequence table.
INSERT INTO sequence(seq_name, seq_count)
VALUES ('audit_log_generator', 0),
       ('cluster_generator', 0),
       ('stack_generator', 0),
       ('service_generator', 0),
       ('task_generator', 0),
       ('host_generator', 0),
       ('user_generator', 0),
       ('repo_generator', 0),
       ('host_component_generator', 0),
       ('service_config_generator', 0),
       ('job_generator', 0),
       ('type_config_generator', 0),
       ('component_generator', 0),
       ('stage_generator', 0),
       ('settings_generator', 0);

-- Adding default admin user
INSERT INTO bigtop_manager.user (id, create_time, update_time, nickname, password, status, username)
VALUES (1, now(), now(), 'Administrator', '21232f297a57a5a743894a0e4a801fc3', true, 'admin');