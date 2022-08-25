USE `auction-dev`;


/*********************************************************/
/* TIME ZONE */
/*********************************************************/
SET time_zone = '+7:00';


/*********************************************************/
/* USER + ADMIN (admin, system@123password) (DO NOT CHANGE) */
/*********************************************************/
INSERT INTO `User`(`id`, `username`, `password`, `firstName`, `lastName`, `email`, `dateOfBirth`)
VALUE (100, 'admin', '$2a$12$fVrTHxy/D.zJR35BQtPsPeG.nI.E2AaqNPsEx4LTKyBo8V3zIViQO', 'KTT', 'admin', 'admin@auction.com', '2000-01-01');
-- SELECT * FROM `User`;

INSERT INTO `Admin`(`id`)
VALUE (100);
-- SELECT * FROM `Admin`;


/*********************************************************/
/* CHANGE_ROLE_STATUS (DO NOT CHANGE)*/
/*********************************************************/
INSERT INTO `ChangeRoleStatus`(`id`, `name`)
VALUES
    (100, 'Request to be a seller'),
    (200, 'Approve upgrade to seller'),
    (201, 'Decline update to seller'),
    (300, 'Bidder cancel request'),
    (400, 'Downgrade from seller to bidder');
-- SELECT * FROM `ChangeRoleStatus`;


/*********************************************************/
/* BIDDED PRODUCT STATUS (DO NOT CHANGE) */
/*********************************************************/
INSERT INTO `BiddedProductStatus`(`id`, `name`)
VALUES
    (100, 'Currently bidding'),
    (200, 'Time out'),
    (210, 'Product sold'),
    (220, 'Reject bidding'),
    (201,'sent email bidder'),
    (202,'sent email seller');
-- SELECT * FROM `BiddedProductStatus`;


/*********************************************************/
/* CATEGORY */
/*********************************************************/
INSERT INTO `Category`(`section`, `name`, `path`)
VALUES
    ('Electronics', 'Laptop', 'laptop'),
    ('Electronics', 'Mobie phone', 'mobile-phone'),
    ('Electronics', 'Camera', 'camera'),
    ('Styles', 'Dress', 'dress'),
    ('Styles', 'Boot', 'boot'),
    ('Styles', 'Pant', 'pant'),
    ('Styles', 'Shirt', 'shirt'),
    ('Styles', 'Leggings', 'leggings'),
    ('Styles', 'Sock', 'sock');
-- SELECT * FROM `Category`;


