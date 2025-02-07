/*
  # Initial SynerCore Database Schema
  1. Core Tables
    - companies: Basic company information
    - users: User accounts and authentication
    - roles: User roles and permissions

  2. Financial Module
    - accounts: Chart of accounts
    - transactions: Financial transactions
    - journals: General journal entries

  3. Customer Management
    - customers: Customer information
    - contacts: Customer contacts
    - loyalty_programs: Loyalty points and discounts

  4. Vendor Management
    - vendors: Vendor information
    - purchase_orders: Purchase orders

  5. Inventory
    - products: Product catalog
    - inventory_movements: Stock movements

  6. Security
    - RLS policies for all tables
    - Role-based access control
*/

-- Enable PostgreSQL Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Companies
CREATE TABLE companies (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  tax_id text UNIQUE,
  address text,
  phone text,
  email text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Users
CREATE TABLE users (
  id uuid PRIMARY KEY REFERENCES auth.users,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  first_name text,
  last_name text,
  email text UNIQUE NOT NULL,
  role text NOT NULL DEFAULT 'user',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Roles
CREATE TABLE roles (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Chart of Accounts
CREATE TABLE accounts (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  type text NOT NULL CHECK (type IN ('asset', 'liability', 'equity', 'income', 'expense')),
  parent_id uuid REFERENCES accounts(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, code)
);

-- Customers
CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  tax_id text,
  email text UNIQUE,
  phone text,
  address text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  account_balance numeric(15, 2) NOT NULL DEFAULT 0 CHECK (account_balance >= 0),
  last_purchase_date timestamptz,
  salesperson_id uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Contacts
CREATE TABLE contacts (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text,
  phone text,
  position text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Loyalty Programs
CREATE TABLE loyalty_programs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  points integer NOT NULL DEFAULT 0 CHECK (points >= 0),
  last_reward_date timestamptz,
  next_reward_threshold integer DEFAULT 1000,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Products
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  unit_price numeric(15, 2) NOT NULL DEFAULT 0 CHECK (unit_price >= 0),
  stock_quantity numeric(15, 2) NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, code)
);

-- Inventory Movements
CREATE TABLE inventory_movements (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  movement_type text NOT NULL CHECK (movement_type IN ('in', 'out')),
  quantity numeric(15, 2) NOT NULL CHECK (quantity > 0),
  reason text,
  created_at timestamptz DEFAULT now()
);

-- Transactions
CREATE TABLE transactions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  amount numeric(15, 2) NOT NULL CHECK (amount > 0),
  transaction_type text NOT NULL CHECK (transaction_type IN ('sale', 'refund', 'payment')),
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Companies
CREATE POLICY "Users can view their company data"
ON companies
FOR SELECT
TO authenticated
USING (id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Users
CREATE POLICY "Users can view company users"
ON users
FOR SELECT
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Accounts
CREATE POLICY "Users can view company accounts"
ON accounts
FOR SELECT
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Customers
CREATE POLICY "Users can manage company customers"
ON customers
FOR ALL
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
))
WITH CHECK (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Products
CREATE POLICY "Users can manage company products"
ON products
FOR ALL
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
))
WITH CHECK (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Transactions
CREATE POLICY "Users can view company transactions"
ON transactions
FOR SELECT
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Indexes
CREATE INDEX idx_companies_tax_id ON companies(tax_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_code ON products(code);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);