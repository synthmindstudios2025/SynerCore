import React from 'react';
import { FileText, Search, Plus } from 'lucide-react';

const Documents = () => {
  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">Documents</h1>
          <p className="text-gray-600 mt-1">Manage your business documents</p>
        </div>
        <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700">
          <Plus className="h-5 w-5 mr-2" />
          Upload Document
        </button>
      </div>

      {/* Barra de búsqueda */}
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
                placeholder="Search documents..."
              />
            </div>
          </div>
        </div>

        {/* Lista de documentos */}
        <div className="px-4 py-5 sm:p-6">
          <div className="bg-white shadow overflow-hidden sm:rounded-lg">
            <ul className="divide-y divide-gray-200">
              <li className="px-6 py-4">
                <div className="flex items-center">
                  <FileText className="h-6 w-6 text-gray-400" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-900">Invoice_2023.pdf</p>
                    <p className="text-sm text-gray-500">Uploaded on October 10, 2023</p>
                  </div>
                </div>
              </li>
              <li className="px-6 py-4">
                <div className="flex items-center">
                  <FileText className="h-6 w-6 text-gray-400" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-900">Contract_2023.docx</p>
                    <p className="text-sm text-gray-500">Uploaded on September 25, 2023</p>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Documents;