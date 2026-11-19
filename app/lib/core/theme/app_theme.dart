import 'package:material_ui/material_ui.dart';

/// Extensión de tema para los colores del semáforo presupuestal con contraste AA.
/// Siempre deben ir acompañados de texto o ícono en la UI (.agents/rules/flutter.md).
@immutable
class SemaforoColors extends ThemeExtension<SemaforoColors> {
  const SemaforoColors({
    required this.verde,
    required this.sobreVerde,
    required this.verdeFondo,
    required this.rojo,
    required this.sobreRojo,
    required this.rojoFondo,
    required this.preventivo,
    required this.preventivoFondo,
  });

  final Color verde;
  final Color sobreVerde;
  final Color verdeFondo;
  final Color rojo;
  final Color sobreRojo;
  final Color rojoFondo;
  final Color preventivo;
  final Color preventivoFondo;

  static const light = SemaforoColors(
    verde: Color(0xFF1B5E20), // Contraste > 7:1 sobre blanco (AAA/AA)
    sobreVerde: Colors.white,
    verdeFondo: Color(0xFFE8F5E9),
    rojo: Color(0xFFB71C1C), // Contraste > 7:1 sobre blanco (AAA/AA)
    sobreRojo: Colors.white,
    rojoFondo: Color(0xFFFFEBEE),
    preventivo: Color(0xFFE65100),
    preventivoFondo: Color(0xFFFFF3E0),
  );

  @override
  SemaforoColors copyWith({
    Color? verde,
    Color? sobreVerde,
    Color? verdeFondo,
    Color? rojo,
    Color? sobreRojo,
    Color? rojoFondo,
    Color? preventivo,
    Color? preventivoFondo,
  }) {
    return SemaforoColors(
      verde: verde ?? this.verde,
      sobreVerde: sobreVerde ?? this.sobreVerde,
      verdeFondo: verdeFondo ?? this.verdeFondo,
      rojo: rojo ?? this.rojo,
      sobreRojo: sobreRojo ?? this.sobreRojo,
      rojoFondo: rojoFondo ?? this.rojoFondo,
      preventivo: preventivo ?? this.preventivo,
      preventivoFondo: preventivoFondo ?? this.preventivoFondo,
    );
  }

  @override
  SemaforoColors lerp(ThemeExtension<SemaforoColors>? other, double t) {
    if (other is! SemaforoColors) {
      return this;
    }
    return SemaforoColors(
      verde: Color.lerp(verde, other.verde, t)!,
      sobreVerde: Color.lerp(sobreVerde, other.sobreVerde, t)!,
      verdeFondo: Color.lerp(verdeFondo, other.verdeFondo, t)!,
      rojo: Color.lerp(rojo, other.rojo, t)!,
      sobreRojo: Color.lerp(sobreRojo, other.sobreRojo, t)!,
      rojoFondo: Color.lerp(rojoFondo, other.rojoFondo, t)!,
      preventivo: Color.lerp(preventivo, other.preventivo, t)!,
      preventivoFondo: Color.lerp(preventivoFondo, other.preventivoFondo, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  /// Color semilla primario accesible (azul verdoso oscuro familiar).
  static const Color seedColor = Color(0xFF0D47A1);

  /// Tema Material 3 claro, pensado para usabilidad familiar:
  /// - Botones grandes (mínimo 48dp de alto, táctil cómodo).
  /// - Alto contraste AA.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      error: SemaforoColors.light.rojo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: const <ThemeExtension<dynamic>>[
        SemaforoColors.light,
      ],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(120, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
