# DWH-KPI-BI-Usecase
Prototype

## Assumptions

- BetID in GameTransaction.csv has duplicate BetID values. Since this dimension is the most likely primary key candidate, I changed one of the values to 7183789 to respect value uniqueness.
- GameTransaction.csv & PaymentTransaction.csv  utilizes transactionDateTime with no specified instruction what this value denotes. I am treating this value as an epoch milliseconds and saving it as a timestamp dimension.
- I have added data in addition to the given assigned data samples so as to enable Foreign Key placement.
