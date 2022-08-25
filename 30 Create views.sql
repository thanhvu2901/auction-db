USE `auction-dev`;


DROP VIEW IF EXISTS UserView;
CREATE VIEW UserView
AS
	SELECT	id, username, firstName, lastName, email, dateOfBirth, createdAt, updatedAt
	FROM	`User`;
-- SELECT * FROM UserView;


DROP VIEW IF EXISTS AdminView;
CREATE VIEW AdminView
AS
	SELECT	UV.*
	FROM	`Admin` A JOIN UserView UV ON A.id = UV.id;
-- SELECT * FROM AdminView;


DROP VIEW IF EXISTS BidderView;
CREATE VIEW BidderView
AS
	SELECT	UV.*, B.address, B.verifed, B.positiveCount, B.negativeCount
	FROM	Bidder B JOIN UserView UV ON B.id = UV.id
    WHERE	B.isDeleted = FALSE;
-- SELECT * FROM BidderView;


DROP VIEW IF EXISTS SellerView;
CREATE VIEW SellerView
AS
	SELECT	BV.*, S.expiredTime, S.`active`
	FROM	Seller S JOIN BidderView BV ON S.id = BV.id;
-- SELECT * FROM SellerView;


DROP VIEW IF EXISTS ProductView;
CREATE VIEW ProductView
AS
	SELECT	P.id, P.sellerId, P.`name`, P.`description`, P.reservedPrice, P.priceStep, P.instantPrice,
			P.isRenewal, P.coverImageUrl, P.timeExpired, P.createdAt,
            BP.topBidderId, BP.currentPrice, BP.auctionLogCount, BP.bidderCount
	FROM	Product P
    JOIN	BiddedProduct BP ON P.id = BP.id
    WHERE	P.isDeleted = FALSE;
-- SELECT * FROM ProductView;
    
    
DROP VIEW IF EXISTS WatchListView;
CREATE VIEW WatchListView
AS
	SELECT	WL.bidderId, WL.productId, WL.createdAt
	FROM	WatchList WL
    WHERE	WL.isDeleted = FALSE;
-- SELECT * FROM WatchListView;


DROP VIEW IF EXISTS BidHistoryView;
CREATE VIEW BidHistoryView
AS
	SELECT		AL.*,BV.firstName,BV.lastName
	FROM		auctionlog AL
    JOIN		user BV ON Al.bidderId = BV.id;
-- SELECT * FROM BidHistoryView;

    
/* ---------------------------------------------------------------------------------------- */

DROP VIEW IF EXISTS QueryProductView;
CREATE VIEW QueryProductView
AS
	SELECT		PV.*,
				JSON_OBJECT('firstName', SV.firstName, 'lastName', SV.lastName) AS seller,
				C.section, C.`name` AS categoryName, C.`path` AS categoryPath,
				IF (PV.topBidderId IS NULL, NULL, JSON_OBJECT('firstName', BV.firstName, 'lastName', BV.lastName)) AS topBidder
	FROM		ProductView PV
	LEFT JOIN	ProductCategory PC ON PV.id = PC.productId
	LEFT JOIN	BidderView BV ON BV.id = PV.topBidderId
	JOIN		SellerView SV ON SV.id = PV.sellerId
	JOIN		Category C ON PC.categoryId = C.id;
-- SELECT * FROM QueryProductView;


DROP VIEW IF EXISTS QueryProductDetailView;
CREATE VIEW QueryProductDetailView
AS
	SELECT		QPV.*, JSON_ARRAYAGG(I.url) as urls, B.positiveCount, B.negativeCount
	FROM		QueryProductView QPV
    JOIN		ProductImage I ON QPV.id = I.productId
	JOIN		Bidder B ON B.id = QPV.sellerId
    GROUP BY 	QPV.id;
-- SELECT * FROM QueryProductDetailView;


