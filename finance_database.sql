-- drop statements

drop database Finance;

-- drop tables register, record, earning, expense, movement,credit_card, bank_account;

-- drop function get_account_balance;

-- drop function get_record_balance;

-- drop view Bank;

-- create tables

create database Finance;

use finance;

create table bank_account (
	account_number int,
    first_name varchar(30) not null,
    last_name varchar(30) not null,
    bank varchar(30) not null,
    opening_date date not null,
    account_type varchar(20) not null,
    primary key (account_number)
);

create table credit_card (
	card_number int,
    security_code numeric(4) not null,
    card_type varchar(20) not null,
    first_name varchar(30),
    last_name varchar(30),
    expiration_date date not null,
    my_account int,
    primary key (card_number),
    foreign key (my_account) references bank_account(account_number) on delete set null on update cascade
);

create table movement (
	movement_id int auto_increment,
    amount numeric(20,2) not null,
    movement_date date not null,
    my_account int,
    primary key (movement_id),
    foreign key (my_account) references bank_account(account_number) on delete set null on update cascade
);

create table expense (
	expense_id int auto_increment,
    expense_type varchar(20) not null,
    my_card int,
    primary key (expense_id),
    foreign key (my_card) references credit_card(card_number) on delete set null on update cascade
);

create table earning (
	earning_id int auto_increment,
    earning_type varchar(20) not null,
    primary key (earning_id)
);

create table record (
	record_id int auto_increment,
	record_name varchar(30) not null unique,
    start_date date not null,
    primary key(record_id)
);

create table register (
	my_movement int,
    my_record int,
    foreign key (my_movement) references movement(movement_id) on delete cascade on update cascade,
    foreign key (my_record) references record(record_id) on delete cascade on update cascade,
    primary key (my_movement, my_record)
);

-- definition of functions

DELIMITER $$

CREATE FUNCTION get_account_balance(account_number INT)
RETURNS DECIMAL(20,2)
DETERMINISTIC
BEGIN
    DECLARE total_balance DECIMAL(20,2);

    SELECT COALESCE(SUM(amount), 0) INTO total_balance
    FROM movement
    WHERE my_account = account_number;

    RETURN total_balance;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION get_record_balance(name_record VARCHAR(30))
RETURNS DECIMAL(20,2)
DETERMINISTIC
BEGIN
    DECLARE total_balance DECIMAL(20,2);

    SELECT COALESCE(SUM(amount), 0) INTO total_balance
    FROM movement
    WHERE (SELECT record_id FROM record WHERE record_name = name_record ORDER BY record_id) IN (SELECT my_record FROM register WHERE my_movement = movement_id ORDER BY my_record);

    RETURN total_balance;
END$$

DELIMITER ;

-- insert examples

INSERT INTO bank_account VALUES 
(1, 'John', 'Doe', 'Chase Bank', '2024-10-21', 'Savings'), 
(2, 'Jane', 'Smith', 'Bank of America', '2024-10-22', 'Savings'), 
(3, 'Alice', 'Johnson', 'Wells Fargo', '2024-10-24', 'Checking'),
(4, 'Michael', 'Brown', 'Citibank', '2024-09-15', 'Savings'),
(5, 'Emma', 'Davis', 'Chase Bank', '2024-08-30', 'Savings'),
(6, 'Liam', 'Garcia', 'Bank of America', '2024-07-14', 'Checking'),
(7, 'Olivia', 'Martinez', 'Wells Fargo', '2024-06-18', 'Savings'),
(8, 'Noah', 'Lee', 'Citibank', '2024-05-25', 'Savings'),
(9, 'Sophia', 'Taylor', 'Chase Bank', '2024-04-10', 'Checking'),
(10, 'James', 'Anderson', 'Bank of America', '2024-03-05', 'Savings');

-- Inserting examples for credit_card with real names
INSERT INTO credit_card VALUES
(1, 1234, 'Credit', 'John', 'Doe', '2028-09-01', 1),
(2, 5678, 'Credit', 'Jane', 'Smith', '2029-10-01', 2),
(3, 9101, 'Debit', 'Alice', 'Johnson', '2027-12-01', 3),
(4, 1112, 'Credit', 'Michael', 'Brown', '2026-11-15', 4),
(5, 1314, 'Credit', 'Emma', 'Davis', '2027-10-18', 5),
(6, 1516, 'Debit', 'Liam', 'Garcia', '2026-09-21', 6),
(7, 1718, 'Credit', 'Olivia', 'Martinez', '2028-08-12', 7),
(8, 1920, 'Debit', 'Noah', 'Lee', '2027-07-07', 8),
(9, 2122, 'Credit', 'Sophia', 'Taylor', '2029-06-05', 9),
(10, 2324, 'Debit', 'James', 'Anderson', '2027-05-03', 10);

-- SELECT get_account_balance(1);

insert into movement values
(1,21.21,'2024-10-04',1);

insert into earning values
(last_insert_id(),'Test');

insert into movement values
(2,-2,'2024-10-04',1);

insert into expense values
(last_insert_id(), 'Test', 1);

insert into record values
(1,'Test','2024-10-04');

insert into register values
(1,1);

insert into register values
(2,1);

-- SELECT get_record_balance('Test');

-- Deleting specific entries from bank_account and credit_card tables
-- Deleting based off account_number
DELETE FROM bank_account WHERE account_number = 3;  
DELETE FROM bank_account WHERE account_number = 8; 

-- Deleting based off card_number
DELETE FROM credit_card WHERE card_number = 2;     
DELETE FROM credit_card WHERE card_number = 7;     

-- Deleting based off movement_id
DELETE FROM movement WHERE movement_id = 2;        

-- Deleting an entry from the bank_account table using the person's name
DELETE FROM bank_account WHERE first_name = 'Emma' AND last_name = 'Davis';

-- Deleting an entry from the credit_card table using the person's name
DELETE FROM credit_card WHERE first_name = 'John' AND last_name = 'Doe';

-- Verify remaining records by querying the tables
SELECT * FROM bank_account;
SELECT * FROM credit_card;

-- Update example, change every Citibank account into a Checking account
UPDATE bank_account SET account_type = 'Checking' WHERE bank = 'Citibank';

-- join examples

SELECT * from bank_account inner join credit_card on credit_card.my_account = bank_account.account_number; -- inner join bank credit

SELECT * from bank_account left join credit_card on credit_card.my_account = bank_account.account_number; -- left join

SELECT * from bank_account right join credit_card on credit_card.my_account = bank_account.account_number; -- right join

SELECT * from bank_account left join credit_card on credit_card.my_account = bank_account.account_number
UNION
SELECT * from bank_account right join credit_card on credit_card.my_account = bank_account.account_number; -- full join

SELECT * from register inner join movement on register.my_movement = movement.movement_id; -- inner join register movement

SELECT * from register, movement, record where register.my_movement = movement.movement_id and register.my_record = record.record_id; -- everything register

-- get name of people with bank accounts with debit cards associated to them
SELECT first_name, last_name from bank_account where account_number in (SELECT my_account from credit_card where card_type = 'Debit');

-- bank_account index
CREATE index account_numbers on bank_account(account_number);

-- credit_card index
CREATE index card_numbers on credit_card(card_number);

-- View that shows what bank the people have
CREATE VIEW Bank AS select bank from bank_account;
