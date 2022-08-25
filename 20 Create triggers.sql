USE `auction-dev`;


/*********************************************************/
/* TIME ZONE */
/*********************************************************/
SET time_zone = '+7:00';


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterUpdateChangeRoleLog; //
CREATE TRIGGER OnAfterUpdateChangeRoleLog
AFTER UPDATE ON `ChangeRoleLog`
FOR EACH ROW
BEGIN
    -- Block new log in AuctionLog for those who is banned
	IF NEW.`statusCode` = 200 THEN
		IF NOT EXISTS (SELECT * FROM `Seller` S WHERE S.`id` = NEW.`bidderId`) THEN
			INSERT INTO `Seller`(`id`, `expiredTime`)
			VALUE (NEW.`bidderId`, DATE_ADD(NOW(), INTERVAL 7 DAY));
		ELSE
			UPDATE	`Seller` S
			SET		S.`active` = TRUE
			WHERE	S.`id` = NEW.`bidderId`;
		END IF;
    END IF;
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterInsertProduct; //
CREATE TRIGGER OnAfterInsertProduct
AFTER INSERT ON `Product`
FOR EACH ROW
BEGIN
	INSERT INTO BiddedProduct(`id`) VALUE (NEW.id);
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnBeforeInsertAuctionLog; //
CREATE TRIGGER OnBeforeInsertAuctionLog
BEFORE INSERT ON `AuctionLog`
FOR EACH ROW
BEGIN
	DECLARE minPrice FLOAT;

    -- Block new log in AuctionLog for those who is banned
	IF EXISTS (	SELECT	1
				FROM	CurrentBidder CB
				WHERE	CB.productId = NEW.productId AND CB.bidderId = NEW.bidderId AND CB.isBlocked = TRUE) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Bidder is banned';
    END IF;

	SELECT	IF(topBidderID IS NULL, reservedPrice, currentPrice + priceStep)
	INTO	minPrice
	FROM	ProductView
	WHERE	id = NEW.productId
	LIMIT	1;

	IF NEW.price < minPrice THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The bidded price is smaller than the requirement';
	END IF;
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterInsertAuctionLog; //
CREATE TRIGGER OnAfterInsertAuctionLog
AFTER INSERT ON `AuctionLog`
FOR EACH ROW
BEGIN
	DECLARE topBidderId BIGINT;
	DECLARE topPrice FLOAT;

	-- Increase the number of `auctionLogCount` by 1
	-- Count the number of `auctionLogCouut`
	-- Update current price from BiddedProduct
	-- Update top bidder from BiddedProduct
	IF (SELECT BP.currentPrice FROM BiddedProduct BP WHERE BP.id = NEW.productId LIMIT 1) IS NULL THEN
		-- First auction log
		UPDATE	BiddedProduct
		SET		topBidderId = NEW.bidderId,
				currentPrice = NEW.price,
				auctionLogCount = 1,
				bidderCount = 1
		WHERE	id = NEW.productId;
	ELSE
		-- Non-first auction log
		SELECT	MAX(AL.price)
		INTO	topPrice
		FROM	AuctionLog AL
		JOIN	CurrentBidder CB ON AL.bidderId = CB.bidderId
		WHERE	AL.productId = NEW.productId AND CB.productId = NEW.productId;
		
		SELECT	bidderId
		INTO	topPrice
		FROM	AuctionLog
		WHERE	productId = NEW.productId AND price = topPrice
		LIMIT	1;

		UPDATE	BiddedProduct BP
		SET		BP.bidderCount = (SELECT COUNT(bidderId) FROM CurrentBidder WHERE productId = NEW.productId AND isBlocked = FALSE),
				BP.auctionLogCount = BP.auctionLogCount + 1,
				BP.topBidderId = topBidderId,
				BP.currentPrice = topPrice
		WHERE	NEW.productId = BP.id;    
	END IF;

	-- Add a new bidder to the CurrentBidder table
	IF NOT EXISTS (SELECT 1 FROM CurrentBidder WHERE bidderId = NEW.bidderId AND productId = NEW.productId LIMIT 1) THEN
		INSERT INTO CurrentBidder(bidderId, productId)
		VALUE (NEW.bidderId, NEW.productId);
	END IF;
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterUpdateCurrentBidder; //
CREATE TRIGGER OnAfterUpdateCurrentBidder
AFTER INSERT ON `CurrentBidder`
FOR EACH ROW
BEGIN
	DECLARE topBidderId BIGINT;
	DECLARE topPrice FLOAT;

	IF NEW.isBlocked = TRUE THEN
		SELECT	MAX(AL.price)
		INTO	topPrice
		FROM	AuctionLog AL
		JOIN	CurrentBidder CB ON AL.bidderId = CB.bidderId
		WHERE	AL.productId = NEW.productId AND CB.productId = NEW.productId;

		SELECT	bidderId
		INTO	topPrice
		FROM	AuctionLog
		WHERE	productId = NEW.productId AND price = topPrice
		LIMIT	1;

		UPDATE	BiddedProduct BP
		SET		BP.bidderCount = (SELECT COUNT(bidderId) FROM CurrentBidder WHERE productId = NEW.productId AND isBlocked = FALSE),
				BP.auctionLogCount = BP.auctionLogCount + 1,
				BP.topBidderId = topBidderId,
				BP.currentPrice = topPrice
		WHERE	NEW.productId = BP.id;    
	END IF;
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnBeforeInsertMessageToSeller; //
CREATE TRIGGER OnBeforeInsertMessageToSeller
BEFORE INSERT ON `MessageToSeller`
FOR EACH ROW
BEGIN
	-- Reject insert new row to `MessageToSeller` if Seller already reject Bidder
	DECLARE statusCode BIGINT;
	SET statusCode = (
		SELECT	BP.`statusCode`
		FROM	`MessageToSeller` MTS JOIN `BiddedProduct` BP ON MTS.`id` = BP.`id`
    );
    
    IF statusCode = 220 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterInsertMessageToSeller; //
CREATE TRIGGER OnAfterInsertMessageToSeller
BEFORE INSERT ON `MessageToSeller`
FOR EACH ROW
BEGIN
	-- Get sellerId
    DECLARE sellerId BIGINT;
    SET sellerId = (
		SELECT	S.`statusCode`
		FROM	`MessageToSeller` MTS
		JOIN	`BiddedProduct` BP ON MTS.`id` = BP.`id`
		JOIN	`Product` P ON BP.`id` = P.`id`
		JOIN	`Seller` S ON P.`id` = S.`id`
	);
    
    -- Increase the number of `positiveCount` or `negativeCount` for the Seller
    IF (NEW.`score` = 1) THEN
		UPDATE	`Bidder` SB
		SET		SB.`positiveCount` = SB.`positiveCount` + 1
        WHERE	SB.`id` = sellerId;
    ELSEIF (NEW.`score` = -1) THEN
		UPDATE	`Bidder` SB
		SET		SB.`negativeCount` = SB.`negativeCount` + 1
        WHERE	SB.`id` = sellerId;
    END IF;    
END; //
DELIMITER ;


/*********************************************************/
DELIMITER //
DROP TRIGGER IF EXISTS OnAfterInsertMessageToBidder; //
CREATE TRIGGER OnAfterInsertMessageToBidder
BEFORE INSERT ON `MessageToBidder`
FOR EACH ROW
BEGIN
    -- Get bidderId
	DECLARE bidderId BIGINT;
    SET bidderId = (
		SELECT	bidderId = BP.`topBidderId`
		FROM	`MessageToBidder` MTB JOIN `BiddedProduct` BP ON MTB.`id` = BP.`id`
    );
    
    -- Increase the number of `positiveCount` or `negativeCount` for the Bidder
    IF (NEW.`score` = 1) THEN
		UPDATE	`Bidder` B
		SET		B.`positiveCount` = B.`positiveCount` + 1
        WHERE	B.`id` = bidderId;
    ELSEIF (NEW.`score` = -1) THEN
		UPDATE	`Bidder` B
		SET		B.`negativeCount` = B.`negativeCount` + 1
        WHERE	B.`id` = bidderId;
    END IF;    
END; //
DELIMITER ;


