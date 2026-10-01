import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/quick_split_screen.dart';
import 'views/detailed_split_screen.dart';
import 'widgets/currency_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiviCuentaApp());
}

class DiviCuentaApp extends StatefulWidget {
  const DiviCuentaApp({super.key});

  @override
  State<DiviCuentaApp> createState() => _DiviCuentaAppState();
}

class _DiviCuentaAppState extends State<DiviCuentaApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedCurrency = r'$';

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeCurrency(String newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiviCuenta - Divisor de Cuentas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        currentThemeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        currentCurrency: _selectedCurrency,
        onChangeCurrency: _changeCurrency,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final VoidCallback onToggleTheme;
  final String currentCurrency;
  final ValueChanged<String> onChangeCurrency;

  const HomeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onToggleTheme,
    required this.currentCurrency,
    required this.onChangeCurrency,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Acerca de DiviCuenta'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DiviCuenta te permite calcular pagos de restaurantes y salidas en dos modalidades:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text('⚡ 1. División Rápida: Para dividir la cuenta en partes iguales con propina e impuestos configurables.'),
              SizedBox(height: 8),
              Text('👥 2. Por Amigos: Para cuando cada quien pide cosas distintas y además comparten entradas o botellas. La propina se reparte de forma justa y proporcional.'),
              SizedBox(height: 12),
              Text('✨ Incluye botón para copiar el resumen listo para WhatsApp.'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calculate_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'DiviCuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Currency Selector Button (Compact & elegant)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => CurrencyDialog(
                    currentCurrency: widget.currentCurrency,
                    onSelected: widget.onChangeCurrency,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.currentCurrency,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Theme Toggle Button
          IconButton(
            tooltip: isDark ? 'Modo Claro' : 'Modo Oscuro',
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
            onPressed: widget.onToggleTheme,
          ),

          // Info Button
          IconButton(
            tooltip: 'Información',
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: _showInfoDialog,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.flash_on_rounded, size: 16),
                  text: 'División Rápida',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
                Tab(
                  icon: Icon(Icons.people_alt_rounded, size: 16),
                  text: 'Por Amigos',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            QuickSplitScreen(currency: widget.currentCurrency),
            DetailedSplitScreen(currency: widget.currentCurrency),
          ],
        ),
      ),
    );
  }
}
