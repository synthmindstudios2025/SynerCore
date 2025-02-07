import React from 'react';
import { BarChart3, Users, ShoppingCart, CreditCard } from 'lucide-react';

const StatCard = ({ title, value, icon: Icon, trend }: { title: string; value: string; icon: React.ElementType; trend?: string }) => (
  <div className="bg-white rounded-lg p-6 shadow-sm">
    <div className="flex items-center justify-between">
      <div>
        <p className="text-sm text-gray-600">{title}</p>
        <h3 className="text-2xl font-semibold mt-1">{value}</h3>
        {trend && <p className="text-sm text-green-600 mt-1">{trend}</p>}
      </div>
      <div className="bg-blue-50 p-3 rounded-full">
        <Icon className="w-6 h-6 text-blue-600" />
      </div>
    </div>
  </div>
);

const Dashboard = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">Welcome to SynerCore Enterprise Management System</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Revenue"
          value="$54,239"
          icon={BarChart3}
          trend="+12.5% from last month"
        />
        <StatCard
          title="Active Customers"
          value="1,429"
          icon={Users}
          trend="+4.3% from last month"
        />
        <StatCard
          title="Products Sold"
          value="2,834"
          icon={ShoppingCart}
          trend="+8.1% from last month"
        />
        <StatCard
          title="Pending Orders"
          value="42"
          icon={CreditCard}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg p-6 shadow-sm">
          <h3 className="text-lg font-semibold mb-4">Recent Transactions</h3>
          <div className="space-y-4">
            {/* Placeholder for transactions list */}
            <p className="text-gray-600">Loading transactions...</p>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 shadow-sm">
          <h3 className="text-lg font-semibold mb-4">Top Products</h3>
          <div className="space-y-4">
            {/* Placeholder for top products list */}
            <p className="text-gray-600">Loading products...</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;