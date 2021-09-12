-- Top list of Countries had the highest cash turnover over a period of time
select p.country,
       sum(gt.realAmount) 
from GameTransaction gt
inner join Player p
on gt.playerID = p.playerID
where gt.txType = 'DEPOSIT'
and gt.transactionDateTime between :1 and :2
group by p.country
order by sum(gt.realAmount) desc;

-- Top list of Players had the highest cash turnover over a period of time
select p.playerID,
       sum(gt.realAmount) 
from GameTransaction gt
inner join Player p
on gt.playerID = p.playerID
where gt.txType = 'DEPOSIT'
and gt.transactionDateTime between :1 and :2
group by p.country
order by sum(gt.realAmount) desc;

-- Top list with the most profitable customers? 
with deposits as (
    select pt.amount as amount,
           pt.playerID as playerID
    from PaymentTransaction pt
    where pt.txType = 'DEPOSIT'
), withdrawals as (
    select pt.amount as amount,
           pt.playerID as playerID
    from PaymentTransaction pt
    where pt.txType = 'WITHDRAWAL'
), profit as (
    select d.amount - w.amount as amount,
            d.playerID as playerID
    from deposits d
    inner join withdrawals w
    on d.playerID = w.playerID
) select * 
from profit
order by amount desc; 

-- The Turnover Development over time (hourly resolution) for customers in Romania ? 
select sum(gt.realAmount + gt.bonusAmount),
       DATE_TRUNC('hour', gt.transactionDateTime)
from GameTransaction gt
inner join Player p
on gt.playerID = p.playerID
where p.country = 'RO'
and gt.txType = 'WAGER'
group by DATE_TRUNC('hour', gt.transactionDateTime);

-- Different Timezones might be needed for the same reports / data, how would you cater for this ?
create or replace function convertTimestampToCET(timestamp) RETURNS TIMESTAMP AS $$ 
    SELECT $1::TIMESTAMP with time zone  AT TIME ZONE 'CET';  -- Change to whatever timezone conversion is needed - can possibly be parameterized.
$$ LANGUAGE SQL;

select sum(gt.realAmount + gt.bonusAmount),
       DATE_TRUNC('hour', convertTimestampToCET(gt.transactionDateTime))
from GameTransaction gt
inner join Player p
on gt.playerID = p.playerID
where p.country = 'RO'
and gt.txType = 'WAGER'
group by DATE_TRUNC('hour', convertTimestampToCET(gt.transactionDateTime));

select sum(gt.realAmount + gt.bonusAmount),
       DATE_TRUNC('hour', convert_timezone_from_to(gt.transactionDateTime,'UTC','CET'))
from GameTransaction gt
inner join Player p
on gt.playerID = p.playerID
where p.country = 'RO'
and gt.txType = 'WAGER'
group by DATE_TRUNC('hour', convert_timezone_from_to(gt.transactionDateTime,'UTC','CET'));

--KPIs (Definitions)
with eur_exchange_rate as (
    select CurrencyDate,
           Currency,
           BaseRate 
    from ExchangeRate
    where Currency = 'EUR'  -- •	Preferably convert local currencies into Euro
), cash_bonus_turnover as (
    select  gt.BetID as BetID,
            sum(gt.realAmount * eer.BaseRate) as cash_bonus_turnover_real_amount_eur,
            sum(gt.bonusAmount * eer.BaseRate) as cash_bonus_turnover_bonus_amount_eur
    from GameTransaction gt
    inner join eur_exchange_rate eer
    on gt.transactionDateTime = eer.CurrencyDate
    and gt.txCurrency = eer.Currency
    where gt.txType = 'WAGER'
    group by BetID
), cash_bonus_winnings as (
    select  gt.BetID as BetID,
            sum(gt.realAmount * eer.BaseRate) as cash_bonus_winnings_real_amount_eur,
            sum(gt.bonusAmount * eer.BaseRate) as cash_bonus_winnings_bonus_amount_eur
    from GameTransaction gt
    inner join eur_exchange_rate eer
    on gt.transactionDateTime = eer.CurrencyDate
    and gt.txCurrency = eer.Currency
    where gt.txType = 'RESULT'
    group by BetID
), turnover as (
    select BetID as BetID,
           cash_bonus_turnover_real_amount_eur + cash_bonus_turnover_bonus_amount_eur as turnover
    from cash_bonus_turnover     
), winnings as (
    select BetID as BetID,
           cash_bonus_winnings_real_amount_eur + cash_bonus_winnings_bonus_amount_eur as winnings
    from cash_bonus_winnings
), cash_bonus_result as (
    select cbw.BetID as BetID,
           cbt.cash_bonus_turnover_real_amount_eur - cbw.cash_bonus_winnings_real_amount_eur as cash_result,
           cbt.cash_bonus_turnover_bonus_amount_eur - cbw.cash_bonus_winnings_bonus_amount_eur as bonus_result
    from cash_bonus_turnover cbt
    inner join cash_bonus_winnings cbw 
    on cbt.BetID = cbw.BetID
), gross_result as (
    select t.BetID as BetID,
           t.turnover - w.winnings as gross_result
    from turnover t
    inner join winnings w
    on t.BetID = w.BetID
), return_to_player as (
    select w.BetID as BetID,
           w.winnings / t.turnover as return_to_player
    from turnover t
    inner join winnings w
    on t.BetID = w.BetID       
), deposits as (
    select gt.BetID as BetID,
           sum(pt.amount * eer.BaseRate) as deposit
    from PaymentTransaction pt
    inner join GameTransaction gt
    on pt.playerID = gt.playerID
    inner join eur_exchange_rate eer
    on pt.txCurrency = eer.Currency
    and pt.transactionDateTime = eer.CurrencyDate
    where pt.txType = 'DEPOSIT'
    group by gt.BetID
), withdrawals as (
    select gt.BetID as BetID,
           sum(pt.amount * eer.BaseRate) as withdrawal
    from PaymentTransaction pt
    inner join GameTransaction gt
    on pt.playerID = gt.playerID
    inner join eur_exchange_rate eer
    on pt.txCurrency = eer.Currency
    and pt.transactionDateTime = eer.CurrencyDate
    where pt.txType = 'WITHDRAWAL'
    group by gt.BetID
), net_deposits as (
    select d.BetID as BetID,
           d.deposit - w.withdrawal as net_deposit
    from deposits d
    inner join withdrawals w
    on d.BetID = w.BetID
) select cbt.cash_bonus_turnover_real_amount_eur,
         cbt.cash_bonus_turnover_bonus_amount_eur,
         cbw.cash_bonus_winnings_real_amount_eur,
         cbw.cash_bonus_winnings_bonus_amount_eur,
         t.turnover,
         w.winnings,
         cbrr.cash_result,
         cbrr.bonus_result,
         gr.gross_result,
         rtp.return_to_player,
         d.deposit,
         ww.withdrawal,
         nd.net_deposit
from cash_bonus_turnover cbt
inner join cash_bonus_winnings cbw
on cbt.BetID = cbw.BetID
inner join turnover t
on cbt.BetID = t.BetID
inner join winnings w
on cbt.BetID = w.BetID
inner join cash_bonus_result cbrr
on cbt.BetID = cbrr.BetID
inner join gross_result gr
on cbt.BetID = gr.BetID
inner join return_to_player rtp
on cbt.BetID = rtp.BetID
inner join deposits d
on cbt.BetID = d.BetID
inner join withdrawals ww
on cbt.BetID = ww.BetID
inner join net_deposits nd
on cbt.BetID = nd.BetID;