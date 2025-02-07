// Base Types
export interface BaseEntity {
  id: string;
  created_at: string;
  updated_at: string;
}

// Customer Types
export interface Customer extends BaseEntity {
  company_id: string;
  name: string;
  tax_id?: string;
  email?: string;
  phone?: string;
  address?: string;
  status: 'active' | 'inactive';
  account_balance: number;
  last_purchase_date?: string;
  salesperson_id?: string;
}

// Product Types
export interface Product extends BaseEntity {
  company_id: string;
  code: string;
  name: string;
  description?: string;
  unit_price: number;
  stock_quantity: number;
}

// Inventory Types
export interface StockMovement extends BaseEntity {
  company_id: string;
  product_id: string;
  warehouse_id: string;
  location_id?: string;
  movement_type: 'in' | 'out' | 'transfer';
  quantity: number;
  reference_type: 'purchase' | 'sale' | 'adjustment' | 'transfer';
  reference_id?: string;
  notes?: string;
  created_by: string;
}

// Sales Types
export interface SalesOrder extends BaseEntity {
  company_id: string;
  customer_id: string;
  quotation_id?: string;
  order_number: string;
  order_date: string;
  status: 'draft' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  payment_term_id?: string;
  shipping_address?: string;
  shipping_method?: string;
  total_amount: number;
  notes?: string;
  created_by: string;
}

export interface SalesOrderItem extends BaseEntity {
  order_id: string;
  product_id: string;
  description: string;
  quantity: number;
  unit_price: number;
  discount_percent: number;
  tax_percent: number;
  total_amount: number;
}

// Purchase Types
export interface PurchaseOrder extends BaseEntity {
  company_id: string;
  supplier_id: string;
  po_number: string;
  order_date: string;
  expected_date?: string;
  status: 'draft' | 'sent' | 'confirmed' | 'partial' | 'completed' | 'cancelled';
  total_amount: number;
  shipping_address?: string;
  notes?: string;
  created_by: string;
}

export interface PurchaseOrderItem extends BaseEntity {
  po_id: string;
  product_id: string;
  description: string;
  quantity: number;
  received_quantity: number;
  unit_price: number;
  total_amount: number;
}