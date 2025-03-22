// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kumar_brooms/repositorys/customer_repo.dart';
import 'package:kumar_brooms/repositorys/impl/customer_repo_impl.dart';
import 'package:kumar_brooms/repositorys/impl/profile_repo_impl.dart';
import 'package:kumar_brooms/repositorys/profile_repo.dart';
import 'package:kumar_brooms/repositorys/item_repo.dart';
import 'package:kumar_brooms/repositorys/impl/item_repo_impl.dart';
import 'package:kumar_brooms/repositorys/user_repo.dart';
import 'package:kumar_brooms/repositorys/impl/user_repo_impl.dart';
import 'package:kumar_brooms/repositorys/order_repo.dart'; // Add this
import 'package:kumar_brooms/repositorys/impl/order_repo_impl.dart'; // Add this
import 'package:kumar_brooms/services/customer_service.dart';
import 'package:kumar_brooms/services/impl/customer_service_impl.dart';
import 'package:kumar_brooms/services/impl/profile_service_impl.dart';
import 'package:kumar_brooms/services/profile_service.dart';
import 'package:kumar_brooms/services/item_service.dart';
import 'package:kumar_brooms/services/impl/item_service_impl.dart';
import 'package:kumar_brooms/services/user_service.dart';
import 'package:kumar_brooms/services/impl/user_service_impl.dart';
import 'package:kumar_brooms/services/order_service.dart'; // Add this
import 'package:kumar_brooms/services/impl/order_service_impl.dart'; // Add this
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/profile_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/user_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart'; // Add this
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Profile providers
        Provider<ProfileService>(
          create: (_) => ProfileServiceImpl(),
        ),
        Provider<ProfileRepository>(
          create: (context) =>
              ProfileRepositoryImpl(context.read<ProfileService>()),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) =>
              ProfileViewModel(context.read<ProfileRepository>()),
        ),
        // Customer providers
        Provider<CustomerService>(
          create: (_) => CustomerServiceImpl(),
        ),
        Provider<CustomerRepository>(
          create: (context) =>
              CustomerRepositoryImpl(context.read<CustomerService>()),
        ),
        ChangeNotifierProvider<CustomerViewModel>(
          create: (context) => CustomerViewModel(
            context.read<CustomerRepository>(),
            'someUserId', // Replace with actual user ID
          ),
        ),
        // Item providers
        Provider<ItemService>(
          create: (_) => ItemServiceImpl(),
        ),
        Provider<ItemRepository>(
          create: (context) => ItemRepositoryImpl(context.read<ItemService>()),
        ),
        ChangeNotifierProvider<ItemViewModel>(
          create: (context) => ItemViewModel(context.read<ItemRepository>()),
        ),
        // User providers
        Provider<UserService>(
          create: (_) => UserServiceImpl(),
        ),
        Provider<UserRepository>(
          create: (context) => UserRepositoryImpl(context.read<UserService>()),
        ),
        ChangeNotifierProvider<UserViewModel>(
          create: (context) => UserViewModel(context.read<UserRepository>()),
        ),
        // Order providers
        Provider<OrderService>(
          create: (_) => OrderServiceImpl(),
        ),
        Provider<OrderRepository>(
          create: (context) =>
              OrderRepositoryImpl(context.read<OrderService>()),
        ),
        ChangeNotifierProvider<OrderViewModel>(
          create: (context) => OrderViewModel(context.read<OrderRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'IoT Control App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        home: const Wrapper(),
      ),
    );
  }
}
