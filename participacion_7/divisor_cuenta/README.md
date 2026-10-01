# 🧾 DiviCuenta - Divisor de Cuentas en Flutter

Una aplicación moderna, intuitiva y completa desarrollada en **Flutter** para dividir cuentas de restaurantes, salidas con amigos, comidas compartidas y viajes.

---

## ✨ Características Principales

### ⚡ 1. División Rápida (Equitativa)
- **Cálculo en tiempo real**: Ingresa el total de la cuenta y observa los resultados instantáneamente.
- **Selector interactivo de personas**: Control con botones `+` / `-`, selector rápido de comensales (2, 3, 4, 5, 6, 8, 10...) y slider.
- **Porcentajes de propina**: Botones predefinidos (0%, 5%, 10%, 15%, 18%, 20%) y opción de porcentaje personalizado.
- **Impuestos / IVA**: Configuración rápida de IVA (0%, 12%, 15%, personalizado) o toggle para indicar que ya está incluido en la factura.
- **Redondeo inteligente**: Opción de redondear al entero superior por persona para evitar lidiar con centavos en efectivo o transferencias.
- **Tarjeta Hero de Resultados**: Muestra claramente cuánto paga cada comensal y el desglose de subtotal, propina e impuesto.
- **Compartir por WhatsApp**: Botón para copiar un resumen formateado con emojis listo para pegar en el grupo de amigos.

### 👥 2. División por Amigos y Consumo (Detallada)
- **Consumos individuales**: Agrega amigos con nombres y colores personalizados. Registra lo que cada persona pidió individualmente.
- **Platos y bebidas compartidas**: Agrega entradas, pizzas o jarras y selecciona qué personas las compartieron. El costo se divide automáticamente entre ellos.
- **Propina e impuestos proporcionales**: Cada comensal asume la propina e impuesto en proporción exacta a lo que consumió, asegurando una división 100% justa.
- **Resumen individual y general**: Visualiza el total general de la mesa y el monto exacto que debe transferir cada amigo.
- **Exportación con un toque**: Genera un desglose detallado para compartir en WhatsApp o redes sociales.

### 🎨 3. Experiencia y Diseño
- **Material 3**: Diseño fintech moderno inspirado en aplicaciones bancarias y de pagos contemporáneas.
- **Modo Oscuro / Modo Claro**: Alterna entre temas visuales con un botón en la barra superior.
- **Selector de Moneda**: Soporte para `$`, `€`, `£`, `S/`, `COP`, `MXN`.
- **Feedback háptico**: Vibración suave en interacciones para una sensación táctil en dispositivos móviles.

---

## 🚀 Cómo Ejecutar la Aplicación

### Requisitos Previos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- Dispositivo móvil (Android/iOS), emulador o navegador web (Chrome/Edge).

### Comandos de Ejecución

1. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```

2. **Ejecutar en Web (Chrome):**
   ```bash
   flutter run -d chrome
   ```

3. **Ejecutar en Windows Desktop:**
   ```bash
   flutter run -d windows
   ```

4. **Ejecutar en Android o iOS:**
   ```bash
   flutter run
   ```

5. **Ejecutar Pruebas Unitarias y de Widgets:**
   ```bash
   flutter test
   ```

---

## 📁 Estructura del Proyecto

```text
lib/
├── main.dart                      # Entrada principal, temas y pestañas
├── theme/
│   └── app_theme.dart             # Paleta de colores M3 (Light & Dark)
├── models/
│   ├── expense_item.dart          # Modelo de ítem o plato individual
│   ├── shared_item.dart           # Modelo de consumo compartido
│   └── person.dart                # Modelo de comensal y sus gastos
├── views/
│   ├── quick_split_screen.dart    # Pantalla de cálculo rápido y equitativo
│   └── detailed_split_screen.dart # Pantalla de consumo personalizado por persona
└── widgets/
    ├── currency_helper.dart       # Formateador de moneda
    └── currency_dialog.dart       # Diálogo selector de divisas
```
