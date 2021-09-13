# DWH-KPI-BI-Usecase

This usecase mimicks a BI usecase scenario, with table design, data populance, and KPI reporting.

## Running the samples

1) Install docker and launch the docker-compose file.
  - This will boot up a postgres and adminer container.
2) Run 'ddl.sql'.
  - This will create the schema for this usecase, and populate the tables with data.
3) 'KPIs.sql' contains all the queries used to satisfy the requested KPIs, compiled/executed against the tables setup in 2.

## Assumptions

- Added a new dimension to table Game.csv called 'GameCategoryId', which is a foreign key column tying the table to 'GameCategory.csv'.
- BetID in GameTransaction.csv has duplicate BetID values. Since this dimension is the most likely primary key candidate, I changed one of the values to 7183789 to respect value uniqueness.
- GameTransaction.csv & PaymentTransaction.csv  utilizes transactionDateTime with no specified instruction what this value denotes. I am treating this value as an epoch milliseconds and saving it as a timestamp dimension.
- I have added data in addition to the given assigned data samples so as to enable Foreign Key placement, since the given data does not match in order to establish FK constraints
