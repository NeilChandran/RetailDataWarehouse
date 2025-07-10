-- Schema for StockFlowDB

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE stocks (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) UNIQUE,
    name VARCHAR(100),
    price DECIMAL(10, 2)
);

CREATE TABLE portfolio (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    stock_id INT REFERENCES stocks(id),
    quantity INT,
    purchase_price DECIMAL(10, 2)
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    stock_id INT REFERENCES stocks(id),
    transaction_type VARCHAR(10), -- 'BUY' or 'SELL'
    quantity INT,
    transaction_price DECIMAL(10, 2),
    transaction_date DATE
);
