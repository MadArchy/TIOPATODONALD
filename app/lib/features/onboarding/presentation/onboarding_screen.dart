import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kOnboardingVistoKey = 'onboarding_visto_v1';

class OnboardingVisto extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kOnboardingVistoKey) ?? false;
  }

  Future<void> marcarVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingVistoKey, true);
    state = const AsyncData(true);
  }
}

final onboardingVistoProvider =
    AsyncNotifierProvider<OnboardingVisto, bool>(OnboardingVisto.new);

/// Tres pantallas cortas la primera vez que se abre la app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _pagina = 0;

  static const _paginas = <({String titulo, String cuerpo, IconData icono})>[
    (
      titulo: 'Tu hogar, en claro',
      cuerpo:
          'Cada quien registra sus gastos e ingresos. Todos ven el mismo hogar sin misterios.',
      icono: Icons.home_rounded,
    ),
    (
      titulo: 'Tu presupuesto, tu ritmo',
      cuerpo:
          'Fijas tu tope y el día en que empieza tu período. El semáforo te dice si vas bien.',
      icono: Icons.savings_outlined,
    ),
    (
      titulo: 'Avisos a tiempo',
      cuerpo:
          'Te avisamos al 50%, 80% y 100%, si se acerca una cuota o si hay una corrección pendiente.',
      icono: Icons.notifications_active_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    await ref.read(onboardingVistoProvider.notifier).marcarVisto();
    if (!mounted) return;
    context.go('/bienvenida');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('btn_onboarding_omitir'),
                onPressed: _terminar,
                child: const Text('Omitir'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _paginas.length,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemBuilder: (context, i) {
                  final p = _paginas[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PATO DONALD',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Icon(p.icono, size: 88, color: scheme.primary),
                        const SizedBox(height: 28),
                        Text(
                          p.titulo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.cuerpo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_paginas.length, (i) {
                final activo = i == _pagina;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: activo ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activo
                        ? scheme.primary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                key: const Key('btn_onboarding_siguiente'),
                onPressed: () {
                  if (_pagina >= _paginas.length - 1) {
                    // ignore: discarded_futures
                    _terminar();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(
                  _pagina >= _paginas.length - 1 ? 'Empezar' : 'Siguiente',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
