# auction-db

### Overview
This is a smaller part of the full project called Aution Only. Auction Only is an online system where sellers and bidders meet. The sellers publish their product for the bidder to bid. The one with the highest bidding price owns the product.

For the full solution, visit:
- Front end: https://github.com/NickMark028/auction-fe
- Back end: https://github.com/NickMark028/auction-be
- Database: https://github.com/NickMark028/auction-db

### Prerequisite
- MySQL v8.0.22 or higher.

### Installation
Run these following script in order:
1. `10 Create database.sql`: Create database, tables, initialize auto increment value, foreign keys.
2. `11 Update database.sql`: Alter database to match the requirements.
3. `20 Create triggers.sql`: Create some trigger events when CRUD operation happens.
4. `30 Create views.sql`: Create a virtual views.
5. `40 Create stored procedures & functions.sql`: Provide some procedures and functions to ease complex query in the BE.
6. `50 Insert data.sql`: Insert base data for the systems.
7. `51 Insert test data.sql`: This script is not mandatory to run. It's only served for some sample testing data.
8. `60 Create index.sql`: Create full text search index.
9. `90 Create users.sql`: Secure DB with access control.
