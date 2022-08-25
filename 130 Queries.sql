USE `auction-dev`;


-- Time zone
SET time_zone = '+7:00';


-- Get all category types
SELECT		C.section, JSON_ARRAYAGG(JSON_OBJECT(
                'id', C.id,
                'name', C.`name`,
                'path', C.`path`)
            ) AS categories
FROM		Category C
GROUP BY	C.section;


-- Search product
SELECT	*
FROM	  	QueryProductView
WHERE		MATCH(name) AGAINST('điện thoại' IN BOOLEAN MODE) AND categoryPath = 'laptop'
ORDER BY	timeExpired ASC, currentPrice DESC
LIMIT		0, 20;

-- Get watch list
SELECT		PV.*, WLV.createdAt AS dateFavorited
FROM		WatchListView WLV
JOIN 		ProductView PV ON PV.id = WLV.productId
WHERE 		WLV.bidderId = 1000001
ORDER BY	PV.id DESC;

-- Top 5 product with most auction log
SELECT		DISTINCT PV.id
FROM	  	QueryProductView PV
ORDER BY	PV.auctionLogCount DESC
LIMIT 		8;


-- Top 5 product nearest to close
SELECT		DISTINCT id, PV.*
FROM		QueryProductView PV
ORDER BY	TIME_TO_SEC(TIMEDIFF(NOW(), NOW() - INTERVAL 1 MONTH)) ASC
LIMIT 		5;


-- Top 5 product with the highest price
SELECT		DISTINCT id, PV.*
FROM	  	QueryProductView PV
ORDER BY	IF(PV.currentPrice IS NULL, PV.reservedPrice, PV.currentPrice) DESC
LIMIT 		5;


-- CREATE EVENT ScheduleTimeOutForProduct10000010
-- ON SCHEDULE AT timeExpired
-- DO
-- 	UPDATE  BiddedProduct
-- 	SET     statusCode = 200
-- 	WHERE   id = productId;


-- Check if the seller is the owner of a product
SELECT	1
FROM	Sellerview S
JOIN	Product P ON P.sellerId = S.id
WHERE	S.id = 1000104 AND P.id = 1000124
LIMIT	1;


-- Get detail current bidder
SELECT	1
FROM	Seller S
JOIN	Product P ON P.sellerId = S.id
WHERE	P.id = 1000004 AND S.id = 1000104
LIMIT	1;















