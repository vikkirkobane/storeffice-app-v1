import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'screens/add_office_space_screen.dart';
import 'screens/office_space_list_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/cart_screen.dart';
import 'providers/cart_provider.dart';
import 'models/user_model.dart';
import 'services/supabase_service.dart';
import 'services/demo_data_initializer.dart';
import 'services/demo_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initialize();
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: const TextStyle(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.deepPurple.shade200, // Fixed color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
            title: 'Storeffice',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegistrationScreen(),
              '/home': (context) => const HomePage(),
              '/add_office_space': (context) => const AddOfficeSpaceScreen(),
              '/office_space_list': (context) => const OfficeSpaceListScreen(),
              '/add_product': (context) => const AddProductScreen(),
              '/product_list': (context) => const ProductListScreen(),
              '/my_bookings': (context) => const MyBookingsScreen(),
              '/cart': (context) => const CartScreen(),
            });
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    
    if (session != null) {
      return const HomePage();
    }
    return const LoginPage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user != null) {
      final userProfile = await _supabaseService.getUserProfile(user.id);
      
      // Check if this is the demo user and initialize demo data
      if (user.email == 'demo@storeffice.com') {
        try {
          await DemoDataInitializer.initializeDemoData();
          print('Demo data initialized for demo user');
        } catch (e) {
          print('Error initializing demo data: $e');
        }
      }
      
      setState(() {
        _currentUser = AppUser(
          id: userProfile.id,
          email: userProfile.email,
          role: userProfile.roles.isNotEmpty ? userProfile.roles.first : 'Customer',
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Storeffice - ${_currentUser?.role ?? ''}'),
        actions: [
          if (_currentUser?.role == 'Customer')
            Consumer<CartProvider>(
              builder: (_, cart, ch) => Badge(
                label: Text(cart.itemCount.toString()),
                child: ch,
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
            ),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final client = Supabase.instance.client;
              await client.auth.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Welcome, ${_currentUser?.email ?? 'Guest'}!', style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 20),
                      Text('Your role: ${_currentUser?.role ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 30),
                      if (_currentUser != null)
                        _buildRoleBasedButtons(context, _currentUser!.role)
                      else
                        const Text("No user role found."),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

Widget _buildRoleBasedButtons(BuildContext context, String role) {
  List<Widget> buttons = [];

  if (role == 'Owner') {
    buttons.add(
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_office_space');
        },
        child: const Text('Add a Space'),
      ),
    );
  }

  if (role == 'Merchant') {
    buttons.add(
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_product');
        },
        child: const Text('Add a Product'),
      ),
    );
  }
  
  if (role == 'Customer') {
     buttons.addAll([
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/office_space_list');
          },
          child: const Text('Browse Spaces'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/product_list');
          },
          child: const Text('Browse Products'),
        ),
         ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/my_bookings');
          },
          child: const Text('My Bookings'),
        ),
     ]);
  }

  return Wrap(
    spacing: 10,
    runSpacing: 10,
    alignment: WrapAlignment.center,
    children: buttons,
  );
}
