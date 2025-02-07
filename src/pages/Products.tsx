import React from 'react';
import { Package, Search, Plus, Edit2, Trash2 } from 'lucide-react';

const Products = () => {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">Products</h1>
          <p className="text-gray-600 mt-1">Manage your product catalog</p>
        </div>
        <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700">
          <Plus className="h-5 w-5 mr-2" />
          Add Product
        </button>
      </div>

      <div className="bg-white shadow-sm rounded-lg">
        <div className="px-4 py-5 border-b border-gray-200 sm:px-6">
          <div className="flex items-center">
            <div className="relative flex-grow">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                placeholder="Search products..."
              />
            </div>
          </div>
        </div>
        <div className="px-4 py-5 sm:p-6">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {/* Example Product Card */}
            <div className="relative bg-white border rounded-lg shadow-sm">
              <div className="p-4">
                <div className="aspect-w-3 aspect-h-2 mb-4">
                  <img
                    src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e"
                    alt="Product"
                    className="object-cover rounded-lg"
                  />
                </div>
                <h3 className="text-lg font-medium text-gray-900">Example Product</h3>
                <p className="mt-1 text-sm text-gray-500">Product description goes here...</p>
                <div className="mt-4">
                  <span className="text-lg font-medium text-gray-900">$99.99</span>
                  <span className="ml-2 text-sm text-gray-500">In stock: 42</span>
                </div>
                <div className="mt-4 flex space-x-2">
                  <button className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                    <Edit2 className="h-4 w-4 mr-2" />
                    Edit
                  </button>
                  <button className="inline-flex items-center px-3 py-2 border border-red-300 shadow-sm text-sm leading-4 font-medium rounded-md text-red-700 bg-white hover:bg-red-50">
                    <Trash2 className="h-4 w-4 mr-2" />
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Products;