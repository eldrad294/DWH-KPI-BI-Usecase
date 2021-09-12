drop table if exists PaymentTransaction;
drop table if exists GameTransaction;
drop table if exists Game;
drop table if exists GameCategory;
drop table if exists GameProviderName;
drop table if exists Player;
drop table if exists ExchangeRate;


create table if not exists ExchangeRate (
    CurrencyDate timestamp not null,
    Currency varchar(3) not null,
    BaseRate int not null,
    primary key (CurrencyDate, Currency)
);

insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('05/06/2015', 'ROM', 0.684088);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('05/06/2015', 'BGN', 0.5113);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('05/06/2015', 'CAD', 0.709774);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('05/06/2015', 'CHF', 0.947777);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('03/20/2017', 'SEK', 0.947777);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('03/09/2105', 'ROM', 0.684088);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('09/03/2105', 'ROM', 0.684088);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('09/21/3326', 'ROM', 0.684088);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('09/24/3326', 'ROM', 0.684088);
insert into ExchangeRate (CurrencyDate, Currency, BaseRate) values ('09/24/3326', 'EUR', 0.684088);

create table if not exists GameCategory(
    ID int not null,
    GameCategory varchar(100) not null,
    primary key (ID)
);

insert into GameCategory (ID, GameCategory) values (4, 'SLOTS');
insert into GameCategory (ID, GameCategory) values (6, 'SLOTS');
insert into GameCategory (ID, GameCategory) values (7, 'SLOTS');
insert into GameCategory (ID, GameCategory) values (8, 'SLOTS');

create table if not exists GameProviderName(
    ID int not null,
    GameProviderName varchar(100) not null,
    primary key (ID)
);

insert into GameProviderName (ID, GameProviderName) values (1, 'Andersson');
insert into GameProviderName (ID, GameProviderName) values (2, 'Johansson');
insert into GameProviderName (ID, GameProviderName) values (3, 'Karlsson');
insert into GameProviderName (ID, GameProviderName) values (4, 'Nilsson');

create table if not exists Game (
    GameName varchar(100) not null,
    ID int not null,
    GameProviderId int not null,
    GameCategoryId int not null,
    primary key (ID),
    foreign key (GameCategoryId) references GameCategory (ID),
    foreign key (GameProviderId) references GameProviderName (ID)
);

insert into Game (GameName, ID, GameProviderId, GameCategoryId) values ('MARY', 1, 1, 4);
insert into Game (GameName, ID, GameProviderId, GameCategoryId) values ('PATRICIA', 2, 2, 6);
insert into Game (GameName, ID, GameProviderId, GameCategoryId) values ('LINDA', 3, 3, 7);
insert into Game (GameName, ID, GameProviderId, GameCategoryId) values ('BARBARA', 4, 4, 8);
insert into Game (GameName, ID, GameProviderId, GameCategoryId) values ('HELEN', 2466, 4, 8);

create table if not exists Player(
    playerID int not null,
    country varchar(2) not null,
    BirthDate timestamp not null,
    gender varchar(20) not null,
    playerState varchar(100),
    primary key (playerID)
);

insert into Player (playerID, country, BirthDate, gender, playerState) values ('116004723', 'MT', '01/02/1987', 'FEMALE', 'SELF EXCLUDED');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116008056', 'RO', '01/05/1987', 'MALE', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116010104', 'MT', '01/02/1987', 'MALE', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116015483', 'RO', '01/02/1987', 'MALE', 'CLOSED');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116018788', 'RO', '01/02/2020', 'FEMALE', 'FROZEN');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116018807', 'RO', '01/02/1957', 'UNSPECIFIED', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116053877', 'RO', '01/02/2020', 'MALE', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116068965', 'RO', '01/02/2020', 'MALE', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116025700', 'RO', '01/02/2020', 'MALE', 'ACTIVE');
insert into Player (playerID, country, BirthDate, gender, playerState) values ('116021116', 'RO', '01/02/2020', 'MALE', 'ACTIVE');



create table if not exists PaymentTransaction (
    ID int not null,
    transactionDateTime timestamp not null,
    amount int not null,
    channelUID varchar(100) not null,
    txCurrency varchar(3) not null,
    playerID int not null,
    txType varchar(100) not null,
    primary key (ID),
    foreign key (transactionDateTime, txCurrency) references ExchangeRate (CurrencyDate, Currency),
    foreign key (playerID) references Player (playerID)
);

insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21659488, to_timestamp(4281401147478/1000)::date, 200, 'ANDROID', 'ROM', 116053877, 'DEPOSIT');
insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21659708, to_timestamp(42814018225509/1000)::date, 200, 'ANDROID', 'ROM', 116053877, 'DEPOSIT');
insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21659988, to_timestamp(42814028593773/1000)::date, 200, 'ANDROID', 'ROM', 116053877, 'DEPOSIT');
insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21664981, to_timestamp(42814272159086/1000)::date, 100, 'IPHONE', 'ROM', 116068965, 'WITHDRAWAL');
insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21665239, to_timestamp(42814280177222/1000)::date, 500, 'IPHONE', 'ROM', 116025700, 'PENDING_WITHDRAWAL');
insert into PaymentTransaction (ID, transactionDateTime, amount, channelUID, txCurrency, playerID, txType) values (21665284, to_timestamp(42814281871435/1000)::date, 55, 'DESKTOP', 'EUR', 116021116, 'WITHDRAWAL');


create table if not exists GameTransaction (
    BetID int not null,
    BetDate timestamp not null,
    transactionDateTime timestamp not null,
    realAmount decimal not null,
    bonusAmount decimal not null,
    channelUID varchar(100) not null,
    txCurrency varchar(3) not null,
    playerID int not null,
    gameID int not null,
    txType varchar(100) not null,
    primary key (BetID),
    foreign key (BetDate, txCurrency) references ExchangeRate (CurrencyDate, Currency),
    foreign key (gameID) references Game (ID),
    foreign key (playerID) references Player (playerID)
);

insert into GameTransaction (BetID, BetDate, transactionDateTime, realAmount, bonusAmount, channelUID, txCurrency, playerID, gameID, txType) values (7183788, '03/20/2017', to_timestamp(42814000127546/1000)::date, 10, 0, 'DESKTOP', 'SEK', 116053877, 2466, 'WAGER');
insert into GameTransaction (BetID, BetDate, transactionDateTime, realAmount, bonusAmount, channelUID, txCurrency, playerID, gameID, txType) values (7183789, '03/20/2017', to_timestamp(42814000134815/1000)::date, 7.5, 0, 'DESKTOP', 'SEK', 116053877, 2466, 'RESULT');
