-- Storeffice Demo User Setup Script
-- This script creates a demo user and sets up initial data for demonstration purposes

-- Note: This script should be run in the Supabase SQL Editor with the 'supabase_admin' role

-- Create the demo user in Supabase Auth
-- This needs to be done via the Supabase dashboard or using the Supabase Admin API
-- The following is a helper function for creating users with the Admin API

-- First, let's ensure the demo user exists in the profiles table
INSERT INTO public.profiles (id, email, roles)
SELECT 
    -- This will be the user ID from auth.users after the demo user is created
    gen_random_uuid(), -- Replace with actual user ID after creating the user in Auth
    'demo@storeffice.com',
    '{"Customer"}'::text[] -- Default role for demo user
ON CONFLICT (email) DO NOTHING;

-- Add example office spaces for demo purposes (only if demo user exists)
DO $$
DECLARE
    demo_user_id UUID;
BEGIN
    -- Get the user ID for the demo user
    SELECT id INTO demo_user_id FROM auth.users WHERE email = 'demo@storeffice.com';
    
    IF demo_user_id IS NOT NULL THEN
        -- Insert sample office spaces for the demo user
        INSERT INTO public.office_spaces (owner_id, title, description, location, photos, amenities, capacity, pricing, is_active, is_featured, verification_status)
        VALUES 
        (
            demo_user_id,
            'Modern Co-working Space',
            'Beautiful modern co-working space with natural light, ergonomic furniture, and high-speed WiFi.',
            '{"address": "123 Business District, Downtown", "city": "Metropolis", "state": "CA", "zipCode": "90210", "coordinates": [-118.2437, 34.0522]}',
            '{"https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1497366754035-f200968a6e72?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            '{"WiFi", "Parking", "Coffee", "Printer", "Meeting Room"}',
            10,
            '{"hourly": 15.00, "daily": 75.00, "weekly": 300.00, "monthly": 1000.00}',
            true,
            true,
            'verified'
        ),
        (
            demo_user_id,
            'Executive Boardroom',
            'Professional boardroom perfect for important meetings and presentations. Includes AV equipment and catering services.',
            '{"address": "456 Corporate Plaza, Financial District", "city": "Metropolis", "state": "CA", "zipCode": "90211", "coordinates": [-118.2562, 34.0599]}',
            '{"https://images.unsplash.com/photo-1507842721694-0e5a68584ec6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1556761229-82b5ac3fb6d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            '{"AV Equipment", "Catering Available", "Video Conferencing", "WiFi"}',
            12,
            '{"hourly": 50.00, "daily": 300.00}',
            true,
            true,
            'verified'
        )
        ON CONFLICT (id) DO NOTHING;
        
        -- Insert sample products for demo
        INSERT INTO public.products (merchant_id, storage_id, title, description, category, subcategory, price, images, inventory, sku, is_active, is_featured, verification_status)
        VALUES
        (
            demo_user_id,
            NULL,
            'Wireless Bluetooth Headphones',
            'High-quality wireless headphones with noise cancellation and 30-hour battery life.',
            'Electronics',
            'Audio',
            129.99,
            '{"https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            25,
            'ELEC-BT-001',
            true,
            true,
            'verified'
        ),
        (
            demo_user_id,
            NULL,
            'Ergonomic Office Chair',
            'Premium ergonomic office chair with lumbar support and adjustable height.',
            'Furniture',
            'Office',
            249.99,
            '{"https://images.unsplash.com/photo-1519947486511-46149fa0a2d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1504672281656-e4981d70514d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            10,
            'FURN-ERG-002',
            true,
            false,
            'verified'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- Create a function to easily reset demo data
CREATE OR REPLACE FUNCTION reset_demo_data()
RETURNS void AS $$
DECLARE
    demo_user_id UUID;
BEGIN
    -- Get the user ID for the demo user
    SELECT id INTO demo_user_id FROM auth.users WHERE email = 'demo@storeffice.com';
    
    IF demo_user_id IS NOT NULL THEN
        -- Clear existing demo data
        DELETE FROM public.office_spaces WHERE owner_id = demo_user_id;
        DELETE FROM public.products WHERE merchant_id = demo_user_id;
        
        -- Insert fresh demo data
        INSERT INTO public.office_spaces (owner_id, title, description, location, photos, amenities, capacity, pricing, is_active, is_featured, verification_status)
        VALUES 
        (
            demo_user_id,
            'Modern Co-working Space',
            'Beautiful modern co-working space with natural light, ergonomic furniture, and high-speed WiFi.',
            '{"address": "123 Business District, Downtown", "city": "Metropolis", "state": "CA", "zipCode": "90210", "coordinates": [-118.2437, 34.0522]}',
            '{"https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1497366754035-f200968a6e72?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            '{"WiFi", "Parking", "Coffee", "Printer", "Meeting Room"}',
            10,
            '{"hourly": 15.00, "daily": 75.00, "weekly": 300.00, "monthly": 1000.00}',
            true,
            true,
            'verified'
        );
        
        INSERT INTO public.products (merchant_id, storage_id, title, description, category, subcategory, price, images, inventory, sku, is_active, is_featured, verification_status)
        VALUES
        (
            demo_user_id,
            NULL,
            'Wireless Bluetooth Headphones',
            'High-quality wireless headphones with noise cancellation and 30-hour battery life.',
            'Electronics',
            'Audio',
            129.99,
            '{"https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"}',
            25,
            'ELEC-BT-001',
            true,
            true,
            'verified'
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to service role
GRANT EXECUTE ON FUNCTION reset_demo_data() TO service_role;