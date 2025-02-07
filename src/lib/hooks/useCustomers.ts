import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../supabase';
import { Customer } from '../types';

export function useCustomers() {
  const queryClient = useQueryClient();

  const getCustomers = async () => {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .order('name');
    
    if (error) throw error;
    return data;
  };

  const createCustomer = async (customer: Omit<Customer, 'id'>) => {
    const { data, error } = await supabase
      .from('customers')
      .insert(customer)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  };

  const updateCustomer = async ({ id, ...customer }: Customer) => {
    const { data, error } = await supabase
      .from('customers')
      .update(customer)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  };

  const customers = useQuery({
    queryKey: ['customers'],
    queryFn: getCustomers
  });

  const createCustomerMutation = useMutation({
    mutationFn: createCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['customers'] });
    }
  });

  const updateCustomerMutation = useMutation({
    mutationFn: updateCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['customers'] });
    }
  });

  return {
    customers,
    createCustomer: createCustomerMutation.mutate,
    updateCustomer: updateCustomerMutation.mutate,
    isLoading: customers.isLoading || createCustomerMutation.isPending || updateCustomerMutation.isPending,
    error: customers.error || createCustomerMutation.error || updateCustomerMutation.error
  };
}