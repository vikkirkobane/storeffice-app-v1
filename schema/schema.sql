-- Storeffice Supabase Schema

-- Enable Row Level Security (RLS)
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

-- Create users table extension (we'll use this for custom user data)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  role TEXT DEFAULT 'customer',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create office_spaces table
CREATE TABLE IF NOT EXISTS office_spaces (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  capacity INTEGER DEFAULT 1,
  price_per_hour DECIMAL(10, 2) NOT NULL,
  photos TEXT[] DEFAULT '{}',
  amenities TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'active', -- 'active', 'inactive', 'maintenance'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  status TEXT DEFAULT 'active', -- 'active', 'inactive'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  office_space_id UUID REFERENCES office_spaces(id) NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'confirmed', -- 'pending', 'confirmed', 'cancelled', 'completed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user carts table (for temporary storage of cart items)
CREATE TABLE IF NOT EXISTS user_carts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id) -- Prevent duplicate items in cart
);

-- Create functions

-- Function to create a profile automatically when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (NEW.id, NEW.email, 'customer');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user role
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT AS $$
DECLARE
  user_role TEXT;
BEGIN
  SELECT role INTO user_role
  FROM public.profiles
  WHERE id = user_id;
  RETURN COALESCE(user_role, 'customer');
END;
$$ LANGUAGE plpgsql;

-- Function to check if a user is the owner of an office space
CREATE OR REPLACE FUNCTION public.is_office_space_owner(space_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  owner_id UUID;
BEGIN
  SELECT owner_id INTO owner_id
  FROM office_spaces
  WHERE id = space_id;
  RETURN owner_id = user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a user is the seller of a product
CREATE OR REPLACE FUNCTION public.is_product_seller(product_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  seller_id UUID;
BEGIN
  SELECT seller_id INTO seller_id
  FROM products
  WHERE id = product_id;
  RETURN seller_id = user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to validate booking time range
CREATE OR REPLACE FUNCTION public.validate_booking_time()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if end time is after start time
  IF NEW.end_time <= NEW.start_time THEN
    RAISE EXCEPTION 'End time must be after start time';
  END IF;
  
  -- Check for overlapping bookings for the same office space
  IF EXISTS (
    SELECT 1 FROM bookings
    WHERE office_space_id = NEW.office_space_id
    AND status != 'cancelled'
    AND (
      (NEW.start_time BETWEEN start_time AND end_time) OR
      (NEW.end_time BETWEEN start_time AND end_time) OR
      (start_time BETWEEN NEW.start_time AND NEW.end_time) OR
      (end_time BETWEEN NEW.start_time AND NEW.end_time)
    )
  ) THEN
    RAISE EXCEPTION 'The office space is already booked for the selected time period';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers

-- Trigger to create profile when a user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to validate booking time
CREATE TRIGGER validate_booking_time
  BEFORE INSERT OR UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION public.validate_booking_time();

-- Row Level Security (RLS) Policies

-- Profiles table policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id) 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Office spaces table policies
ALTER TABLE office_spaces ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all active office spaces" ON office_spaces
  FOR SELECT USING (status = 'active');

CREATE POLICY "Users can insert their own office spaces" ON office_spaces
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owner can update their own office spaces" ON office_spaces
  FOR UPDATE USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owner can delete their own office spaces" ON office_spaces
  FOR DELETE USING (owner_id = auth.uid());

-- Products table policies
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all active products" ON products
  FOR SELECT USING (status = 'active');

CREATE POLICY "Users can insert their own products" ON products
  FOR INSERT WITH CHECK (seller_id = auth.uid());

CREATE POLICY "Seller can update their own products" ON products
  FOR UPDATE USING (seller_id = auth.uid())
  WITH CHECK (seller_id = auth.uid());

CREATE POLICY "Seller can delete their own products" ON products
  FOR DELETE USING (seller_id = auth.uid());

-- Bookings table policies
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own bookings" ON bookings
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create their own bookings" ON bookings
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own bookings" ON bookings
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own bookings" ON bookings
  FOR DELETE USING (user_id = auth.uid());

-- User carts table policies
ALTER TABLE user_carts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own cart items" ON user_carts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can add to their own cart" ON user_carts
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own cart items" ON user_carts
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete from their own cart" ON user_carts
  FOR DELETE USING (user_id = auth.uid());

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_office_spaces_owner_id ON office_spaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_office_spaces_status ON office_spaces(status);
CREATE INDEX IF NOT EXISTS idx_office_spaces_location ON office_spaces USING GIST (POINT(latitude, longitude));
CREATE INDEX IF NOT EXISTS idx_products_seller_id ON products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_office_space_id ON bookings(office_space_id);
CREATE INDEX IF NOT EXISTS idx_bookings_time_range ON bookings USING GIST (TSRANGE(start_time, end_time));
CREATE INDEX IF NOT EXISTS idx_user_carts_user_id ON user_carts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_carts_product_id ON user_carts(product_id);

-- Enable real-time subscriptions
ALTER publication supabase_realtime ADD TABLE office_spaces;
ALTER publication supabase_realtime ADD TABLE products;
ALTER publication supabase_realtime ADD TABLE bookings;