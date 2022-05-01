-- Project 2
SELECT * FROM base;
SELECT * FROM call_record;
SELECT * FROM change_record;
SELECT * FROM decision;
SELECT * FROM letter;
SELECT COUNT(*) FROM base;
SELECT COUNT(*) FROM call_record;
SELECT COUNT(*) FROM decision;
SELECT COUNT(*) FROM letter;
SELECT COUNT(*) FROM change_record;

-- 1. Check how many people call in and respond every day
SELECT COUNT(DISTINCT acct_num),call_date FROM call_record
GROUP BY call_date
ORDER BY call_date;

SELECT COUNT(*) FROM call_record;
SELECT COUNT(DISTINCT acct_num) FROM call_record; -- value 一样 963

-- 2. What is the overall approval rate and decline rate? The base population should be the total responders
Select count(distinct acct_decision_id) from decision;
Select count(*) from decision; --  value 一样  963

Select count(distinct acct_num) from base;
Select count(*) from base; -- value 一样  5400

Select count(acct_decision_id), decision_status from decision
group by 2;

-- A better and professional way to avoid manual work
SELECT 
SUM(CASE WHEN decision_status = 'AP' THEN 1 ELSE 0 END) / COUNT(acct_decision_id) AS approval_rate,
SUM(CASE WHEN decision_status = 'DL' THEN 1 ELSE 0 END) / COUNT(acct_decision_id) AS decline_rate
FROM decision;

-- 3. for approved accounts, check whether their credit limit has been changed correctly based on the offer amount 
-- write the query to output the customers with mismatched credit limit increase (use derived table
Select account_number,(credit_limit_after-credit_limit_before) as change_amount from change_record;
Select count(distinct account_number) from change_record; -- 753 match decision offer 的人
Select count(*) from decision; 

SELECT 
    b.acct_num,
    b.credit_limit_before,
    b.credit_limit_after,
    b.offer_amount,
    b.offer_amount - b.change_amount AS mismatch
FROM
    (SELECT 
        cr.change_amount,
            base.acct_num,
            cr.credit_limit_before,
            cr.credit_limit_after,
            base.offer_amount
    FROM
        (SELECT *,
            (credit_limit_after - credit_limit_before) AS change_amount
    FROM
        change_record) AS cr
    LEFT JOIN base ON cr.account_number = base.acct_num
    GROUP BY 2) AS b
WHERE
    b.offer_amount - b.change_amount != 0
ORDER BY mismatch DESC;



SELECT A.* FROM
(select base.acct_num, 
base.credit_limit,base.offer_amount, 
d.decision_status,
c.credit_limit_after,
base.credit_limit+base.offer_amount-credit_limit_after as mismatch
from
base 
left join
decision d
on base.acct_num=d.acct_decision_id
left join
change_record as c
on
base.acct_num=c.account_number
where decision_status='AP') A
WHERE A.MISMATCH <> 0;

-- 4.1 Check whether letter has been sent out for each approved or declined customers.
-- Output the customers without receiving any letter. Usually, if the letter trigger date >=
-- decision date, we consider that the letter has been sent out

Select count(*) from decision;
select count(*) from letter; -- 963 same 

Select *,
case when c.Letter_trigger_date >= c.decision_date then 'letter sent'
when c.Letter_trigger_date < c.decision_date then 'letter not sent'
else 'invalid' end as letter_status
from 
(select de.*, le.Letter_trigger_date from decision as de
left join letter as le
on le.account_number=de.acct_decision_id) as c
group by acct_decision_id
having letter_status='letter not sent';


SELECT 
    *
FROM
    (SELECT 
        base.acct_num,
            d.decision_status,
            d.decision_date,
            l.letter_code,
            l.Letter_trigger_date,
            DATEDIFF(decision_date, Letter_trigger_date) AS letter_mis
    FROM
        base
    LEFT JOIN decision d ON base.acct_num = d.acct_decision_id
    LEFT JOIN letter l ON base.acct_num = l.account_number
    WHERE
        decision_status IS NOT NULL) A
WHERE
    letter_mis > 0
        OR letter_trigger_date IS NULL;


-- 4.2 Check whether the letter is correctly sent out to each customer based on language and
-- decision. Output the customers with wrong letter code
Select * from
(Select *,
case when c.language='English' and c.decision_status ='AP' then 'AE001'
when c.language='English' and c.decision_status ='DL' then 'RE001'
when c.language='French' and c.decision_status ='AP' then 'AE002'
when c.language='French' and c.decision_status ='DL' then 'RE002'
else 'invalid' end as correct_code 
from
(Select de.acct_decision_id,de.decision_status,le.letter_code,le.language
from letter as le
left join decision as de
on le.account_number=de.acct_decision_id) as c) as d
where letter_code != correct_code
group by acct_decision_id;


-- 5. Create a final monitoring report which includes

SELECT 
    b.*,
    de.decision_status,
    de.decision_date,
    le.Letter_trigger_date,
    le.letter_code,
    le.language,
    cr.credit_limit_after,
    CASE
        WHEN
            de.decision_status = 'AP'
                AND cr.credit_limit_after - cr.credit_limit_before - b.offer_amount <> 0
        THEN
            1
        ELSE 0
    END AS mismatch_flag,
    CASE
        WHEN le.Letter_trigger_date >= de.decision_date THEN 0
        ELSE 0
    END AS missing_letter_flag,
    CASE
        WHEN
            decision_status = 'DL'
                AND language = 'French'
                AND le.letter_code <> 'RE002'
        THEN
            1
        WHEN
            decision_status = 'AP'
                AND language = 'French'
                AND le.letter_code <> 'AE002'
        THEN
            1
        WHEN
            decision_status = 'DL'
                AND language = 'English'
                AND le.letter_code <> 'RE001'
        THEN
            1
        WHEN
            decision_status = 'AP'
                AND language = 'English'
                AND le.letter_code <> 'AE001'
        THEN
            1
        ELSE 0
    END AS wrong_letter_flag
FROM
    base AS b
        LEFT JOIN
    decision AS de ON de.acct_decision_id = b.acct_num
        LEFT JOIN
    letter AS le ON le.account_number = b.acct_num
        LEFT JOIN
    change_record AS cr ON b.acct_num = cr.account_number
WHERE
    decision_status IS NOT NULL;


SELECT 
    base.acct_num,
    base.credit_limit,
    base.offer_amount,
    d.decision_status,
    d.decision_date,
    l.Letter_trigger_date,
    l.letter_code,
    l.language,
    c.credit_limit_after,
    CASE
        WHEN
            decision_status = 'AP'
                AND base.credit_limit + base.offer_amount - credit_limit_after <> 0
        THEN
            1
        ELSE 0
    END AS mismatch_flag,
    CASE
        WHEN DATEDIFF(decision_date, Letter_trigger_date) > 0 THEN 1
        ELSE 0
    END AS missing_letter_flag,
    CASE
        WHEN
            decision_status = 'DL'
                AND language = 'French'
                AND l.letter_code <> 'RE002'
        THEN
            1
        WHEN
            decision_status = 'AP'
                AND language = 'French'
                AND l.letter_code <> 'AE002'
        THEN
            1
        WHEN
            decision_status = 'DL'
                AND language = 'English'
                AND l.letter_code <> 'RE001'
        THEN
            1
        WHEN
            decision_status = 'AP'
                AND language = 'English'
                AND l.letter_code <> 'AE001'
        THEN
            1
        ELSE 0
    END AS wrong_letter_flag
FROM
    base
        LEFT JOIN
    decision d ON base.acct_num = d.acct_decision_id
        LEFT JOIN
    change_record c ON base.acct_num = c.account_number
        LEFT JOIN
    letter l ON base.acct_num = l.account_number
WHERE
    decision_status IS NOT NULL;
