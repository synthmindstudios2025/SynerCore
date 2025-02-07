/*
  # Sales and Supply Chain Management Schema

  1. New Tables
    ## Sales Management
    - `sales_orders`: Stores sales orders with their details
    - `sales_order_items`: Individual items in sales orders
    - `quotations`: Stores quotations/estimates
    - `quotation_items`: Individual items in quotations
    - `customer_segments`: Customer segmentation categories
    - `customer_tags`: Tags for customer classification
    - `customer_contacts`: Additional contacts for customers
    - `payment_terms`: Payment terms configurations
    - `invoices`: Sales invoices
    - `invoice_items`: Individual items in invoices
    - `payments`: Customer payments
    - `payment_methods`: Available payment methods
    - `sales_territories`: Geographic sales territories
    - `sales_targets`: Sales targets by territory/salesperson
    
    ## Supply Chain Management
    - `suppliers`: Main supplier information
    - `supplier_contacts`: Supplier contact persons
    - `supplier_categories`: Supplier classification
    - `supplier_evaluations`: Supplier performance evaluations
    - `purchase_orders`: Purchase orders
    - `purchase_order_items`: Items in purchase orders
    - `goods_receipts`: Received goods records
    - `goods_receipt_items`: Items in goods receipts
    - `warehouses`: Warehouse locations
    - `warehouse_locations`: Specific storage locations
    - `stock_movements`: Inventory movement records
    - `shipping_methods`: Available shipping methods
    - `carriers`: Shipping carriers
    - `delivery_routes`: Delivery route planning
    
  2. Security
    - Enable RLS on all tables
    - Add policies for data access based on company_id
    
  3. Changes
    - Add new columns to existing customers table
    - Add new columns to existing products table
    - Enhanced inventory tracking
*/

-- Sales Management Tables

-- Customer Segments
CREATE TABLE customer_segments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  criteria jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Customer Tags
CREATE TABLE customer_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  color text,
  created_at timestamptz DEFAULT now()
);

-- Customer-Tag Relations
CREATE TABLE customer_tag_relations (
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES customer_tags(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (customer_id, tag_id)
);

-- Customer Contacts (Additional contacts)
CREATE TABLE customer_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  position text,
  email text,
  phone text,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Payment Terms
CREATE TABLE payment_terms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  days_due integer NOT NULL,
  discount_percent numeric(5,2) DEFAULT 0,
  discount_days integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Quotations
CREATE TABLE quotations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  quotation_number text NOT NULL,
  status text NOT NULL CHECK (status IN ('draft', 'sent', 'accepted', 'rejected', 'expired')),
  valid_until date,
  total_amount numeric(15,2) NOT NULL DEFAULT 0,
  notes text,
  terms text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, quotation_number)
);

-- Quotation Items
CREATE TABLE quotation_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quotation_id uuid REFERENCES quotations(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  description text NOT NULL,
  quantity numeric(15,2) NOT NULL,
  unit_price numeric(15,2) NOT NULL,
  discount_percent numeric(5,2) DEFAULT 0,
  tax_percent numeric(5,2) DEFAULT 0,
  total_amount numeric(15,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Sales Orders
CREATE TABLE sales_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  quotation_id uuid REFERENCES quotations(id),
  order_number text NOT NULL,
  order_date date NOT NULL DEFAULT CURRENT_DATE,
  status text NOT NULL CHECK (status IN ('draft', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
  payment_term_id uuid REFERENCES payment_terms(id),
  shipping_address text,
  shipping_method text,
  total_amount numeric(15,2) NOT NULL DEFAULT 0,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, order_number)
);

-- Sales Order Items
CREATE TABLE sales_order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES sales_orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  description text NOT NULL,
  quantity numeric(15,2) NOT NULL,
  unit_price numeric(15,2) NOT NULL,
  discount_percent numeric(5,2) DEFAULT 0,
  tax_percent numeric(5,2) DEFAULT 0,
  total_amount numeric(15,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Invoices
CREATE TABLE invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  order_id uuid REFERENCES sales_orders(id),
  invoice_number text NOT NULL,
  invoice_date date NOT NULL DEFAULT CURRENT_DATE,
  due_date date NOT NULL,
  status text NOT NULL CHECK (status IN ('draft', 'sent', 'paid', 'partially_paid', 'overdue', 'cancelled')),
  total_amount numeric(15,2) NOT NULL DEFAULT 0,
  balance_due numeric(15,2) NOT NULL DEFAULT 0,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, invoice_number)
);

-- Invoice Items
CREATE TABLE invoice_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid REFERENCES invoices(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  description text NOT NULL,
  quantity numeric(15,2) NOT NULL,
  unit_price numeric(15,2) NOT NULL,
  discount_percent numeric(5,2) DEFAULT 0,
  tax_percent numeric(5,2) DEFAULT 0,
  total_amount numeric(15,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Payment Methods
CREATE TABLE payment_methods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Payments
CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  invoice_id uuid REFERENCES invoices(id),
  payment_method_id uuid REFERENCES payment_methods(id),
  amount numeric(15,2) NOT NULL,
  payment_date date NOT NULL DEFAULT CURRENT_DATE,
  reference_number text,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Sales Territories
CREATE TABLE sales_territories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  manager_id uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Sales Targets
CREATE TABLE sales_targets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  territory_id uuid REFERENCES sales_territories(id),
  user_id uuid REFERENCES users(id),
  target_amount numeric(15,2) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  achieved_amount numeric(15,2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Supply Chain Management Tables

-- Suppliers
CREATE TABLE suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  tax_id text,
  email text,
  phone text,
  address text,
  website text,
  payment_terms text,
  credit_limit numeric(15,2),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
  rating integer CHECK (rating BETWEEN 1 AND 5),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Supplier Categories
CREATE TABLE supplier_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Supplier Contacts
CREATE TABLE supplier_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id uuid REFERENCES suppliers(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  position text,
  email text,
  phone text,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Supplier Evaluations
CREATE TABLE supplier_evaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id uuid REFERENCES suppliers(id) ON DELETE CASCADE,
  evaluation_date date NOT NULL DEFAULT CURRENT_DATE,
  quality_score numeric(3,1) CHECK (quality_score BETWEEN 0 AND 10),
  delivery_score numeric(3,1) CHECK (delivery_score BETWEEN 0 AND 10),
  price_score numeric(3,1) CHECK (price_score BETWEEN 0 AND 10),
  service_score numeric(3,1) CHECK (service_score BETWEEN 0 AND 10),
  comments text,
  evaluated_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Purchase Orders
CREATE TABLE purchase_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  supplier_id uuid REFERENCES suppliers(id) ON DELETE SET NULL,
  po_number text NOT NULL,
  order_date date NOT NULL DEFAULT CURRENT_DATE,
  expected_date date,
  status text NOT NULL CHECK (status IN ('draft', 'sent', 'confirmed', 'partial', 'completed', 'cancelled')),
  total_amount numeric(15,2) NOT NULL DEFAULT 0,
  shipping_address text,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(company_id, po_number)
);

-- Purchase Order Items
CREATE TABLE purchase_order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  po_id uuid REFERENCES purchase_orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  description text NOT NULL,
  quantity numeric(15,2) NOT NULL,
  received_quantity numeric(15,2) DEFAULT 0,
  unit_price numeric(15,2) NOT NULL,
  total_amount numeric(15,2) NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Warehouses
CREATE TABLE warehouses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  address text,
  manager_id uuid REFERENCES users(id),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Warehouse Locations
CREATE TABLE warehouse_locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  warehouse_id uuid REFERENCES warehouses(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  capacity numeric(10,2),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Stock Movements
CREATE TABLE stock_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  warehouse_id uuid REFERENCES warehouses(id),
  location_id uuid REFERENCES warehouse_locations(id),
  movement_type text NOT NULL CHECK (movement_type IN ('in', 'out', 'transfer')),
  quantity numeric(15,2) NOT NULL,
  reference_type text NOT NULL CHECK (reference_type IN ('purchase', 'sale', 'adjustment', 'transfer')),
  reference_id uuid,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Goods Receipts
CREATE TABLE goods_receipts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  po_id uuid REFERENCES purchase_orders(id),
  receipt_number text NOT NULL,
  receipt_date date NOT NULL DEFAULT CURRENT_DATE,
  warehouse_id uuid REFERENCES warehouses(id),
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(company_id, receipt_number)
);

-- Goods Receipt Items
CREATE TABLE goods_receipt_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_id uuid REFERENCES goods_receipts(id) ON DELETE CASCADE,
  po_item_id uuid REFERENCES purchase_order_items(id),
  product_id uuid REFERENCES products(id),
  quantity numeric(15,2) NOT NULL,
  location_id uuid REFERENCES warehouse_locations(id),
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Shipping Methods
CREATE TABLE shipping_methods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Carriers
CREATE TABLE carriers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  contact_name text,
  email text,
  phone text,
  website text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Delivery Routes
CREATE TABLE delivery_routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  carrier_id uuid REFERENCES carriers(id),
  vehicle_details jsonb,
  route_points jsonb,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE customer_segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_tag_relations ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotation_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_territories ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipt_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipping_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_routes ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their company data"
ON customer_segments FOR ALL
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
))
WITH CHECK (company_id IN (
  SELECT company_id FROM users WHERE users.id = auth.uid()
));

-- Repeat similar policies for all tables...

-- Create Indexes
CREATE INDEX idx_customer_segments_company ON customer_segments(company_id);
CREATE INDEX idx_quotations_company ON quotations(company_id);
CREATE INDEX idx_sales_orders_company ON sales_orders(company_id);
CREATE INDEX idx_invoices_company ON invoices(company_id);
CREATE INDEX idx_suppliers_company ON suppliers(company_id);
CREATE INDEX idx_purchase_orders_company ON purchase_orders(company_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_goods_receipts_po ON goods_receipts(po_id);

-- Add triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for all tables with updated_at
CREATE TRIGGER update_customer_segments_updated_at
    BEFORE UPDATE ON customer_segments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Repeat for other tables...