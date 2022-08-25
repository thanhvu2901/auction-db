USE `auction-dev`;


/*********************************************************/
/* TIME ZONE */
/*********************************************************/
SET time_zone = '+7:00';


/*********************************************************/
/* REGISTER A NEW BIDDER */
/*********************************************************/
DELIMITER //
DROP PROCEDURE IF EXISTS `RegisterBidder`; //
CREATE PROCEDURE `RegisterBidder`
(
	_username			VARCHAR(128),
    _email				VARCHAR(128),
    _password			VARCHAR(512),
    _firstName			VARCHAR(64) CHARACTER SET utf8mb4,
    _lastName			VARCHAR(64) CHARACTER SET utf8mb4,
    _address            VARCHAR(256),
    _dateOfBirth		DATE
)
BEGIN
    DECLARE _id INT;
    
	START TRANSACTION;
	
    -- Register new bidder
    INSERT INTO `User`(`username`, `password`, `firstName`, `lastName`, `email`, `dateOfBirth`)
    VALUE (_username, _password, _firstName, _lastName, _email, _dateOfBirth);

    SET _id = (SELECT `id` FROM `User` U WHERE U.`username` = _username);

	INSERT INTO `Bidder`(`id`, `address`)
	VALUE (_id, _address);    

    COMMIT;
END; //
DELIMITER ;


/*********************************************************/
/* SEARCH_PRODUCT_CONTAIN_KEYWORD + SEARCH_PRODUCT*/
/*********************************************************/
DELIMITER //
DROP PROCEDURE IF EXISTS `SearchProductContainKeyword`; //
CREATE PROCEDURE `SearchProductContainKeyword`
(
    _keyword			VARCHAR(256) CHARACTER SET utf8mb4,
    _offset				INT,
	_count				INT
)
BEGIN
	SELECT	*
	FROM	QueryProductView
	WHERE	`name` LIKE CONCAT('%', _keyword, '%')
    LIMIT	_offset, _count;
END; //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS `SearchProduct`; //
CREATE PROCEDURE `SearchProduct`
(
    _keyword			VARCHAR(256) CHARACTER SET utf8mb4,
    _page				INT,	-- Start at 1
	_count				INT
)
BEGIN
	DECLARE _resultCount INT DEFAULT 0;
	DECLARE _offset INT DEFAULT (_page - 1) * _count;
    
    IF LENGTH(_keyword) < 4 THEN
		CALL SearchProductContainKeyword(_keyword, _offset, _count);
    ELSE
		SELECT	COUNT(*) INTO _resultCount
        FROM	QueryProductView
		WHERE	MATCH(`name`) AGAINST(_keyword IN BOOLEAN MODE);
        
		IF _resultCount = 0 THEN
			CALL SearchProductContainKeyword(_keyword, _offset, _count);
		ELSE
			SELECT	*
			FROM	QueryProductView
			WHERE	MATCH(`name`) AGAINST(_keyword IN BOOLEAN MODE)
            LIMIT	_offset, _count;
		END IF;
	END IF;
END; //
DELIMITER ;


/*********************************************************/
/* ToggleFavoriteProduct
	Return if the product is still availiable
 */
/*********************************************************/
DELIMITER //
DROP PROCEDURE IF EXISTS `ToggleFavoriteProduct`; //
CREATE PROCEDURE`ToggleFavoriteProduct`
(
		_bidderId			BIGINT,
	IN	_productId			BIGINT,
    OUT isFavoriteDeleted	BOOL
)
BEGIN
	START TRANSACTION;
    
    SELECT	WL.isDeleted INTO isFavoriteDeleted
	FROM	WatchList WL
	WHERE	_bidderId = WL.bidderId AND _productId = WL.productId
    LIMIT	1;
    
    IF (isFavoriteDeleted IS NULL) THEN
		INSERT INTO WatchList(bidderId, productId)
		VALUE (_bidderId, _productId);
    ELSE
		UPDATE	WatchList WL
		SET		WL.isDeleted = NOT isFavoriteDeleted,
				WL.createdAt = IF(isFavoriteDeleted, NOW(), WL.createdAt)
		WHERE	_bidderId = WL.bidderId AND _productId = WL.productId;
    END IF;
    
    COMMIT;
END; //
DELIMITER ;


/*********************************************************/
/* CalculateMinPrice
	Return if the product is still availiable
 */
/*********************************************************/
DELIMITER //
DROP FUNCTION IF EXISTS `CalculateMinPrice`; //
CREATE FUNCTION `CalculateMinPrice`
(
	_reservedPrice			FLOAT,
	_currentPrice			FLOAT
)
RETURNS FLOAT
DETERMINISTIC
BEGIN
	RETURN IF(_currentPrice IS NULL, _reservedPrice, _currentPrice);
END; //
DELIMITER ;


