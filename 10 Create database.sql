/*********************************************************/
/* CREATE DATABASE */
/*********************************************************/
DROP DATABASE IF EXISTS `auction-dev`;
CREATE DATABASE IF NOT EXISTS `auction-dev`;
USE `auction-dev`;


/*********************************************************/
/* TIME ZONE */
/*********************************************************/
SET time_zone = '+7:00';


/*********************************************************/
/* CREATE TABLES */
/*********************************************************/
CREATE TABLE IF NOT EXISTS `User`
(
	`id`				BIGINT AUTO_INCREMENT,
    `username`			VARCHAR(128) UNIQUE NOT NULL,
    `password`			VARCHAR(512) NOT NULL,
    `firstName`			VARCHAR(64) CHARACTER SET utf8mb4 NOT NULL,
    `lastName`			VARCHAR(64) CHARACTER SET utf8mb4 NOT NULL,
    `email`				VARCHAR(128) UNIQUE NOT NULL,
    `dateOfBirth`		DATE NOT NULL,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    `updatedAt`			TIMESTAMP,
    `rfToken`			VARCHAR(512),
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `Admin`
(
	`id`				BIGINT,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `Bidder`
(
	`id`				BIGINT,
    `address`			VARCHAR(256) NOT NULL,
    `verifed`			BOOL NOT NULL DEFAULT FALSE,
    `positiveCount`     INT NOT NULL DEFAULT 0,
    `negativeCount`     INT NOT NULL DEFAULT 0,
    `isDeleted`			BOOL NOT NULL DEFAULT FALSE,
	`refreshToken`		VARCHAR(512),

    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `Seller`
(
	`id`				BIGINT,
    `expiredTime`		TIMESTAMP NOT NULL,
    `active`			BOOL NOT NULL DEFAULT TRUE,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `Product`
(
	`id`				BIGINT AUTO_INCREMENT,
    `sellerId`			BIGINT NOT NULL,
    `name`				VARCHAR(256) CHARACTER SET utf8mb4 NOT NULL,
    `description`		TEXT CHARACTER SET utf8mb4 NOT NULL,
    `reservedPrice`		FLOAT NOT NULL,
    `priceStep`			FLOAT NOT NULL,
    `instantPrice`		FLOAT NOT NULL,
    `isRenewal`			BOOL NOT NULL,
    `coverImageUrl`		VARCHAR(2048) NOT NULL,
    `timeExpired`		TIMESTAMP NOT NULL,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    `isDeleted`			BOOL NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `BiddedProduct`
(
	`id`				BIGINT,
    `topBidderId`		BIGINT,
    `currentPrice`		FLOAT,
    `auctionLogCount`	INT NOT NULL DEFAULT 0,
    `bidderCount`		INT NOT NULL DEFAULT 0,
    `statusCode`		BIGINT NOT NULL DEFAULT 100,
    `remainingTime`		TIMESTAMP,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `Category`
(
	`id`				BIGINT AUTO_INCREMENT,
    `section`			VARCHAR(64) CHARACTER SET utf8mb4 NOT NULL,
    `name`				VARCHAR(64) CHARACTER SET utf8mb4 NOT NULL,
    `path`				VARCHAR(64) UNIQUE NOT NULL,
	`isDeleted`			BOOL NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `ProductCategory`
(
	`productId`			BIGINT,
    `categoryId`		BIGINT,
    
    PRIMARY KEY(`productId`, `categoryId`)
);

CREATE TABLE IF NOT EXISTS `BiddedProductStatus`
(
	`id`				BIGINT,
	`name`				VARCHAR(256) NOT NULL,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `ProductImage`
(
	`id`				BIGINT AUTO_INCREMENT,
	`productId`			BIGINT NOT NULL,
    `url`				VARCHAR(2048) NOT NULL,
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT exists `AcceptBidder`
(
	`productId`		 	bigint not null,
    `bidderId` 			bigint not null,
    `createdAt`			timestamp not null default now() ,
    `status`			boolean not null default 1,
    
    PRIMARY KEY(`bidderId`,`productId`)  
);

CREATE TABLE IF NOT EXISTS `MessageToSeller`
(
	`id`				BIGINT,
    `message`			VARCHAR(1024) CHARACTER SET utf8mb4,
    `score`				BIGINT NOT NULL DEFAULT 0,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `MessageToBidder`
(
	`id`				BIGINT,
    `message`			VARCHAR(1024) CHARACTER SET utf8mb4,
    `score`				BIGINT NOT NULL DEFAULT 0,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `WatchList`
(
	`bidderId`			BIGINT,
	`productId`			BIGINT,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    `isDeleted`			BOOL NOT NULL DEFAULT FALSE,
    
    PRIMARY KEY(`bidderId`, `productId`)
);

CREATE TABLE IF NOT EXISTS `AuctionLog`
(
	`id`				BIGINT AUTO_INCREMENT,
	`bidderId`			BIGINT NOT NULL,
	`productId`			BIGINT NOT NULL,
    `price`				FLOAT NOT NULL,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `CurrentBidder`
(
	`productId`			BIGINT,
	`bidderId`			BIGINT,
    `isBlocked`         BOOLEAN NOT NULL DEFAULT FALSE,

	`createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY(`bidderId`, `productId`)
);

CREATE TABLE IF NOT EXISTS `ChangeRoleLog`
(
	`id`				BIGINT AUTO_INCREMENT,
	`bidderId`			BIGINT NOT NULL,
	`message`			VARCHAR(1024) CHARACTER SET utf8mb4,
    `statusCode`		BIGINT DEFAULT 100,
    `adminId`			BIGINT,
    `timeReplied`		TIMESTAMP,
    `createdAt`			TIMESTAMP NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY(`id`)
);

CREATE TABLE IF NOT EXISTS `ChangeRoleStatus`
(
	`id`				BIGINT,
	`name`				VARCHAR(256) NOT NULL,
    
    PRIMARY KEY(`id`)
);


/*********************************************************/
/* SET UP AUTO_INCREMENT VALUE */
/*********************************************************/
ALTER TABLE `User` AUTO_INCREMENT = 1000001;
ALTER TABLE `ChangeRoleLog` AUTO_INCREMENT = 1000001;
ALTER TABLE `Product` AUTO_INCREMENT = 1000001;
ALTER TABLE `ProductImage` AUTO_INCREMENT = 1000001;
ALTER TABLE `Category` AUTO_INCREMENT = 1;
ALTER TABLE `AuctionLog` AUTO_INCREMENT = 1000001;


/*********************************************************/
/* ADD FOREIGN KEYS */
/*********************************************************/
ALTER TABLE `Admin`
ADD FOREIGN KEY `FK_A_U`(`id`)
	REFERENCES `User`(`id`);

ALTER TABLE `Bidder`
ADD FOREIGN KEY `FK_B_U`(`id`)
	REFERENCES `User`(`id`);

ALTER TABLE `ChangeRoleLog`
ADD FOREIGN KEY `FK_CRL_B`(`bidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_CRL_SC`(`statusCode`)
	REFERENCES `ChangeRoleStatus`(`id`),
ADD FOREIGN KEY `FK_CRL_A`(`adminId`)
	REFERENCES `Admin`(`id`);
    
ALTER TABLE `Seller`
ADD FOREIGN KEY `FK_S_B`(`id`)
	REFERENCES `Bidder`(`id`);

ALTER TABLE `Product`
ADD FOREIGN KEY `FK_P_S`(`sellerId`)
	REFERENCES `Seller`(`id`);

ALTER TABLE `ProductCategory`
ADD FOREIGN KEY `FK_PC_C`(`productId`)
	REFERENCES `Product`(`id`),
ADD FOREIGN KEY `FK_PC_P`(`categoryId`)
	REFERENCES `Category`(`id`);
    
ALTER TABLE `ProductImage`
ADD FOREIGN KEY `FK_PI_P`(`productId`)
	REFERENCES `Product`(`id`);    

ALTER TABLE `BiddedProduct`
ADD FOREIGN KEY `FK_BD_P`(`id`)
	REFERENCES `Product`(`id`),
ADD FOREIGN KEY `FK_BD_B`(`topBidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_BD_BPS`(`statusCode`)
	REFERENCES `BiddedProductStatus`(`id`);
    
ALTER TABLE `WatchList`
ADD FOREIGN KEY `FK_WL_B`(`bidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_WL_BP`(`productId`)
	REFERENCES `BiddedProduct`(`id`);
    
ALTER TABLE `AuctionLog`
ADD FOREIGN KEY `FK_AL_B`(`bidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_AL_BP`(`productId`)
	REFERENCES `BiddedProduct`(`id`);
    
ALTER TABLE `CurrentBidder`
ADD FOREIGN KEY `FK_BB_B`(`bidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_BB_BP`(`productId`)
	REFERENCES `BiddedProduct`(`id`);

ALTER TABLE `MessageToSeller`
ADD FOREIGN KEY `FK_MTS_BP`(`id`)
	REFERENCES `BiddedProduct`(`id`);    
    
ALTER TABLE `MessageToBidder`
ADD FOREIGN KEY `FK_MTB_BP`(`id`)
	REFERENCES `BiddedProduct`(`id`);    
   
ALTER TABLE `AcceptBidder`
ADD FOREIGN KEY `FK_AB_B`(`bidderId`)
	REFERENCES `Bidder`(`id`),
ADD FOREIGN KEY `FK_AB_BP`(`productId`)
	REFERENCES `BiddedProduct`(`id`);
    
    
