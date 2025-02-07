import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../supabase';
import { Product } from '../types';

export function useProducts() {
  const queryClient = useQueryClient();

  const getProducts = async () => {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .order('name');
    
    if (error) throw error;
    return data;
  };

  const createProduct = async (product: Omit<Product, 'id'>) => {
    const { data, error } = await supabase
      .from('products')
      .insert(product)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  };

  const updateProduct = async ({ id, ...product }: Product) => {
    const { data, error } = await supabase
      .from('products')
      .update(product)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  };

  const products = useQuery({
    queryKey: ['products'],
    queryFn: getProducts
  });

  const createProductMutation = useMutation({
    mutationFn: createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    }
  });

  const updateProductMutation = useMutation({
    mutationFn: updateProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    }
  });

  return {
    products,
    createProduct: createProductMutation.mutate,
    updateProduct: updateProductMutation.mutate,
    isLoading: products.isLoading || createProductMutation.isPending || updateProductMutation.isPending,
    error: products.error || createProductMutation.error || updateProductMutation.error
  };
}