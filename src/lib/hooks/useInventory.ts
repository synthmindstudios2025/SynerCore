import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../supabase';
import { StockMovement } from '../types';

export function useInventory() {
  const queryClient = useQueryClient();

  const getStockMovements = async () => {
    const { data, error } = await supabase
      .from('stock_movements')
      .select(`
        *,
        product:products(name),
        warehouse:warehouses(name),
        location:warehouse_locations(name)
      `)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  };

  const createStockMovement = async (movement: Omit<StockMovement, 'id'>) => {
    const { data, error } = await supabase
      .from('stock_movements')
      .insert(movement)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  };

  const stockMovements = useQuery({
    queryKey: ['stock_movements'],
    queryFn: getStockMovements
  });

  const createStockMovementMutation = useMutation({
    mutationFn: createStockMovement,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stock_movements'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
    }
  });

  return {
    stockMovements,
    createStockMovement: createStockMovementMutation.mutate,
    isLoading: stockMovements.isLoading || createStockMovementMutation.isPending,
    error: stockMovements.error || createStockMovementMutation.error
  };
}