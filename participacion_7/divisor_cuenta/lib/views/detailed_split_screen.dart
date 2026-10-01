import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/person.dart';
import '../models/expense_item.dart';
import '../models/shared_item.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_helper.dart';

class DetailedSplitScreen extends StatefulWidget {
  final String currency;

  const DetailedSplitScreen({
    super.key,
    required this.currency,
  });

  @override
  State<DetailedSplitScreen> createState() => _DetailedSplitScreenState();
}

class _DetailedSplitScreenState extends State<DetailedSplitScreen> {
  final List<Person> _people = [];
  final List<SharedItem> _sharedItems = [];

  double _tipPercentage = 10.0;
  double _taxPercentage = 0.0;

  final List<double> _tipPresets = [0.0, 5.0, 10.0, 15.0, 18.0, 20.0];
  final List<double> _taxPresets = [0.0, 12.0, 15.0];

  @override
  void initState() {
    super.initState();
    // Default initial mock data for immediate preview
    _people.addAll([
      Person(
        id: '1',
        name: 'Alejandro',
        color: AppTheme.avatarColors[0],
        items: [
          ExpenseItem(id: 'a1', name: 'Hamburguesa Doble', price: 14.50),
          ExpenseItem(id: 'a2', name: 'Cerveza Artesanal', price: 5.50),
        ],
      ),
      Person(
        id: '2',
        name: 'Sofía',
        color: AppTheme.avatarColors[1],
        items: [
          ExpenseItem(id: 's1', name: 'Pasta Carbonara', price: 13.00),
          ExpenseItem(id: 's2', name: 'Limonada de Menta', price: 3.50),
        ],
      ),
    ]);

    _sharedItems.add(
      SharedItem(
        id: 'sh1',
        name: 'Papas Rústicas para picar',
        price: 8.00,
        assignedPersonIds: ['1', '2'],
      ),
    );
  }

  // Calculations
  double _getSharedShareForPerson(String personId) {
    double total = 0.0;
    for (final item in _sharedItems) {
      final participants = item.assignedPersonIds.isEmpty
          ? _people.map((p) => p.id).toList()
          : item.assignedPersonIds;
      if (participants.contains(personId) && participants.isNotEmpty) {
        total += item.price / participants.length;
      }
    }
    return total;
  }

  double _getFoodTotalForPerson(Person person) {
    return person.itemsSubtotal + _getSharedShareForPerson(person.id);
  }

  double get _totalFoodSubtotal {
    double total = 0.0;
    for (final p in _people) {
      total += p.itemsSubtotal;
    }
    for (final sh in _sharedItems) {
      total += sh.price;
    }
    return total;
  }

  double get _totalTipAmount => _totalFoodSubtotal * (_tipPercentage / 100);
  double get _totalTaxAmount => _totalFoodSubtotal * (_taxPercentage / 100);
  double get _grandTotal => _totalFoodSubtotal + _totalTipAmount + _totalTaxAmount;

  double _getFinalTotalForPerson(Person person) {
    final foodTotal = _getFoodTotalForPerson(person);
    if (foodTotal <= 0) return 0.0;
    final tipShare = foodTotal * (_tipPercentage / 100);
    final taxShare = foodTotal * (_taxPercentage / 100);
    return foodTotal + tipShare + taxShare;
  }

  // Copy Summary to Clipboard
  void _copyItemizedSummary() {
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln('🧾 *DiviCuenta - Desglose por Persona*');
    buffer.writeln('─────────────────────────────');

    for (final p in _people) {
      final personFood = _getFoodTotalForPerson(p);
      final personFinal = _getFinalTotalForPerson(p);
      final tipShare = personFood * (_tipPercentage / 100);
      final taxShare = personFood * (_taxPercentage / 100);

      buffer.writeln('👤 *${p.name}:* ${CurrencyHelper.format(personFinal, symbol: widget.currency)}');
      for (final item in p.items) {
        buffer.writeln('   • ${item.name}: ${CurrencyHelper.format(item.price, symbol: widget.currency)}');
      }
      final sharedShare = _getSharedShareForPerson(p.id);
      if (sharedShare > 0) {
        buffer.writeln('   • Parte compartida: ${CurrencyHelper.format(sharedShare, symbol: widget.currency)}');
      }
      if (tipShare > 0) {
        buffer.writeln('   • Propina (${_tipPercentage.toInt()}%): ${CurrencyHelper.format(tipShare, symbol: widget.currency)}');
      }
      if (taxShare > 0) {
        buffer.writeln('   • Impuesto (${_taxPercentage.toInt()}%): ${CurrencyHelper.format(taxShare, symbol: widget.currency)}');
      }
      buffer.writeln('');
    }

    if (_sharedItems.isNotEmpty) {
      buffer.writeln('🍟 *Platos Compartidos:*');
      for (final sh in _sharedItems) {
        buffer.writeln('   • ${sh.name}: ${CurrencyHelper.format(sh.price, symbol: widget.currency)}');
      }
      buffer.writeln('─────────────────────────────');
    }

    buffer.writeln('💵 Subtotal: ${CurrencyHelper.format(_totalFoodSubtotal, symbol: widget.currency)}');
    if (_totalTipAmount > 0) {
      buffer.writeln('🎁 Propina (${_tipPercentage.toInt()}%): ${CurrencyHelper.format(_totalTipAmount, symbol: widget.currency)}');
    }
    if (_totalTaxAmount > 0) {
      buffer.writeln('📊 Impuesto (${_taxPercentage.toInt()}%): ${CurrencyHelper.format(_totalTaxAmount, symbol: widget.currency)}');
    }
    buffer.writeln('💰 *TOTAL FACTURA:* ${CurrencyHelper.format(_grandTotal, symbol: widget.currency)}');
    buffer.writeln('─────────────────────────────');
    buffer.writeln('Calculado con DiviCuenta ✨');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('¡Desglose por amigo copiado al portapapeles!'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dialogs
  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    Color selectedColor = AppTheme.avatarColors[_people.length % AppTheme.avatarColors.length];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar Amigo / Comensal'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre o Apodo',
                        hintText: 'Ej. Juan, Camila...',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Color de identificación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppTheme.avatarColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 16,
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _people.add(
                          Person(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            color: selectedColor,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog(Person person) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Agregar consumo para ${person.name}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del plato o bebida',
                    hintText: 'Ej. Pizza, Jugo natural...',
                    prefixIcon: Icon(Icons.restaurant_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    prefixText: '${widget.currency} ',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final priceText = priceController.text.replaceAll(',', '.');
                final price = double.tryParse(priceText) ?? 0.0;
                if (price > 0) {
                  setState(() {
                    person.items.add(
                      ExpenseItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name.isEmpty ? 'Consumo' : name,
                        price: price,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSharedItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final Set<String> selectedParticipants = _people.map((p) => p.id).toSet();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Plato o Bebida Compartida'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descripción del ítem',
                        hintText: 'Ej. Jarra de Sangría, Nachos...',
                        prefixIcon: Icon(Icons.fastfood_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Precio Total',
                        prefixText: '${widget.currency} ',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Quiénes compartieron este ítem?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ..._people.map((p) {
                      final isSelected = selectedParticipants.contains(p.id);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: isSelected,
                        title: Row(
                          children: [
                            CircleAvatar(radius: 10, backgroundColor: p.color),
                            const SizedBox(width: 8),
                            Text(p.name),
                          ],
                        ),
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedParticipants.add(p.id);
                            } else {
                              if (selectedParticipants.length > 1) {
                                selectedParticipants.remove(p.id);
                              }
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final priceText = priceController.text.replaceAll(',', '.');
                    final price = double.tryParse(priceText) ?? 0.0;
                    if (price > 0 && selectedParticipants.isNotEmpty) {
                      setState(() {
                        _sharedItems.add(
                          SharedItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name.isEmpty ? 'Plato compartido' : name,
                            price: price,
                            assignedPersonIds: selectedParticipants.toList(),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Overview Card
          _buildTableOverviewCard(theme, isDark),

          const SizedBox(height: 16),

          // Tip & Tax configuration row
          _buildTipAndTaxConfigCard(theme),

          const SizedBox(height: 16),

          // People header & add person button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amigos en la mesa (${_people.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _showAddPersonDialog,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Person Cards
          if (_people.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.group_off_rounded, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 8),
                      const Text('Aún no has agregado personas'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _showAddPersonDialog,
                        child: const Text('Agregar primera persona'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._people.map((person) => _buildPersonCard(person, theme, isDark)),

          const SizedBox(height: 16),

          // Shared Items Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platos Compartidos (${_sharedItems.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_people.isNotEmpty)
                FilledButton.tonalIcon(
                  onPressed: _showAddSharedItemDialog,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Compartir'),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (_sharedItems.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: theme.colorScheme.outline, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Agrega entradas, jarras o botellas que se dividan entre todos o varios.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._sharedItems.map((sh) => _buildSharedItemCard(sh, theme)),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _people.isNotEmpty && _totalFoodSubtotal > 0
                      ? _copyItemizedSummary
                      : null,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Compartir Cuentas'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _people.clear();
                    _sharedItems.clear();
                  });
                },
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTableOverviewCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFF4338CA), const Color(0xFF6366F1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(isDark ? 50 : 80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.table_restaurant_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_people.length} personas en la mesa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Propina: ${_tipPercentage.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFE0E7FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'TOTAL GENERAL DE LA MESA',
            style: TextStyle(
              color: Color(0xFFC7D2FE),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyHelper.format(_grandTotal, symbol: widget.currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildOverviewMetric(
                  'Comida/Bebida',
                  CurrencyHelper.format(_totalFoodSubtotal, symbol: widget.currency),
                ),
                Container(width: 1, height: 26, color: Colors.white.withAlpha(40)),
                _buildOverviewMetric(
                  'Propina Total',
                  CurrencyHelper.format(_totalTipAmount, symbol: widget.currency),
                ),
                if (_taxPercentage > 0) ...[
                  Container(width: 1, height: 26, color: Colors.white.withAlpha(40)),
                  _buildOverviewMetric(
                    'Impuesto',
                    CurrencyHelper.format(_totalTaxAmount, symbol: widget.currency),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFC7D2FE),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipAndTaxConfigCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Propina para la mesa:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_tipPercentage.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tipPresets.map((pct) {
                final isSelected = _tipPercentage == pct;
                return ChoiceChip(
                  label: Text('${pct.toInt()}%'),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _tipPercentage = pct);
                  },
                );
              }).toList(),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Impuesto / IVA:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_taxPercentage.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _taxPresets.map((pct) {
                final isSelected = _taxPercentage == pct;
                return ChoiceChip(
                  label: Text('${pct.toInt()}%'),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _taxPercentage = pct);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonCard(Person person, ThemeData theme, bool isDark) {
    final sharedShare = _getSharedShareForPerson(person.id);
    final foodSubtotal = _getFoodTotalForPerson(person);
    final personFinalTotal = _getFinalTotalForPerson(person);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: person.color,
                  radius: 18,
                  child: Text(
                    person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total a pagar (con propina):',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyHelper.format(personFinalTotal, symbol: widget.currency),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (sharedShare > 0)
                      Text(
                        '+ ${CurrencyHelper.format(sharedShare, symbol: widget.currency)} comp.',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                  onPressed: () {
                    setState(() {
                      _people.removeWhere((p) => p.id == person.id);
                      // also remove from shared items
                      for (final sh in _sharedItems) {
                        sh.assignedPersonIds.remove(person.id);
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Individual Items List
            if (person.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Sin consumos individuales registrados',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else
              ...person.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.lens, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.name, style: const TextStyle(fontSize: 14)),
                      ),
                      Text(
                        CurrencyHelper.format(item.price, symbol: widget.currency),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            person.items.removeWhere((it) => it.id == item.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 8),

            // Add item button for this person
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddItemDialog(person),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar plato / bebida', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Text(
                  'Subtotal: ${CurrencyHelper.format(foodSubtotal, symbol: widget.currency)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedItemCard(SharedItem sh, ThemeData theme) {
    final participantsCount = sh.assignedPersonIds.isEmpty
        ? _people.length
        : sh.assignedPersonIds.length;
    final sharePerPerson = participantsCount > 0 ? sh.price / participantsCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.share_rounded, color: Colors.amber.shade900, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sh.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Entre $participantsCount comensales (${CurrencyHelper.format(sharePerPerson, symbol: widget.currency)} c/u)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyHelper.format(sh.price, symbol: widget.currency),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _sharedItems.removeWhere((it) => it.id == sh.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
