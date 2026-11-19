import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/deudas_fecha.dart';
import '../../../core/periodo.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/deuda.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/deudas_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';
import '../../home/application/home_providers.dart';
import '../../movimientos/presentation/nuevo_movimiento_sheet.dart';
import '../domain/intencion.dart';

/// Chat Nivel 1: intérprete por reglas + confirmación antes de guardar.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _enviando = false;
  Intencion? _propuesta;
  String? _mensajePropuestaId;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  ContextoUsuario _construirContexto() {
    final usuario = ref.read(usuarioActualProvider).value!;
    final ahora = ref.read(clockProvider).now();
    final indicadores = ref.read(indicadoresPropiosProvider);
    final deudas = ref.read(deudasHogarProvider).value ?? const [];
    return ContextoUsuario(
      ahora: ahora,
      diaInicioPeriodo: usuario.diaInicioPeriodo,
      presupuesto: indicadores?.presupuesto ?? 0,
      gastado: indicadores?.gastado ?? 0,
      disponiblePorDia: indicadores?.disponiblePorDia ?? 0,
      gastadoPorCategoria: indicadores?.porCategoria ?? const {},
      deudas: deudas
          .where((d) => d.estado == 'activa')
          .map(
            (d) => DeudaContextoChat(
              id: d.id,
              entidad: d.entidad,
              saldoActual: d.saldoActual,
              diaPago: d.diaPago,
            ),
          )
          .toList(),
    );
  }

  Future<void> _enviar([String? textoFijo]) async {
    final texto = (textoFijo ?? _ctrl.text).trim();
    if (texto.isEmpty || _enviando) return;
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (usuario == null || hogarId == null) return;

    setState(() {
      _enviando = true;
      _propuesta = null;
      _mensajePropuestaId = null;
    });
    _ctrl.clear();

    final repo = ref.read(chatRepositoryProvider);
    try {
      await repo.guardarMensaje(
        hogarId: hogarId,
        uid: usuario.uid,
        rol: 'usuario',
        texto: texto,
        estado: 'confirmado',
      );

      final intencion =
          await ref.read(interpreteProvider).interpretar(texto, _construirContexto());
      final respuesta = _textoRespuesta(intencion);
      final estadoApp = intencion.accion == AccionesIntencion.proponerMovimiento
          ? 'propuesto'
          : 'confirmado';

      final idApp = await repo.guardarMensaje(
        hogarId: hogarId,
        uid: usuario.uid,
        rol: 'app',
        texto: respuesta,
        intencion: intencion,
        estado: estadoApp,
      );

      if (intencion.accion == AccionesIntencion.proponerMovimiento) {
        setState(() {
          _propuesta = intencion;
          _mensajePropuestaId = idApp;
        });
      } else if (intencion.accion == AccionesIntencion.noEntendido) {
        if (mounted) {
          await mostrarNuevoMovimientoSheet(
            context,
            prefillTipo: intencion.tipo,
            prefillMonto: intencion.monto,
            prefillCategoria: intencion.categoria,
            prefillDeudaId: intencion.deudaId,
            prefillNota: intencion.textoOriginal,
          );
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos procesar el mensaje. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  String _textoRespuesta(Intencion i) {
    final indicadores = ref.read(indicadoresPropiosProvider);
    final deudas = ref.read(deudasHogarProvider).value ?? const [];
    switch (i.accion) {
      case AccionesIntencion.consultarEstado:
        final gastado = indicadores?.gastado ?? 0;
        final prep = indicadores?.presupuesto ?? 0;
        final dia = indicadores?.disponiblePorDia ?? 0;
        return 'Llevas ${formatCop(gastado)} de ${formatCop(prep)}. '
            'Te quedan ${formatCop(dia)} por día.';
      case AccionesIntencion.consultarCategoria:
        final cat = i.categoria ?? CategoriasGasto.otros;
        final total = indicadores?.porCategoria[cat] ?? 0;
        return 'En ${etiquetaCategoria(cat)} llevas ${formatCop(total)} este período.';
      case AccionesIntencion.consultarDeuda:
        Deuda? deuda;
        for (final d in deudas) {
          if (d.id == i.deudaId) {
            deuda = d;
            break;
          }
        }
        if (deuda == null) return 'No encontré esa deuda.';
        final ahora = ref.read(clockProvider).now();
        final prox = proximaFechaPago(diaPago: deuda.diaPago, hoy: ahora);
        final proxTxt =
            '${prox.day.toString().padLeft(2, '0')}/'
            '${prox.month.toString().padLeft(2, '0')}/'
            '${prox.year}';
        return '${deuda.entidad}: saldo ${formatCop(deuda.saldoActual)}. '
            'Próximo pago el $proxTxt.';
      case AccionesIntencion.proponerMovimiento:
        final tipo = i.tipo == 'ingreso'
            ? 'Ingreso'
            : i.tipo == 'pagoCuota'
                ? 'Pago de cuota'
                : 'Gasto';
        final monto = i.monto != null ? formatCop(i.monto!) : '—';
        final cat = i.categoria != null ? etiquetaCategoria(i.categoria!) : '';
        return '¿Registro $tipo $monto${cat.isEmpty ? '' : ' · $cat'}?';
      case AccionesIntencion.noEntendido:
      default:
        return 'No te entendí del todo. Te abro el formulario para que lo completes.';
    }
  }

  Future<void> _guardarPropuesta() async {
    final intencion = _propuesta;
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (intencion == null || usuario == null || hogarId == null) return;
    if (intencion.monto == null || intencion.monto! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta el monto para guardar.')),
      );
      return;
    }

    final ahora = ref.read(clockProvider).now();
    final hoy = aHoraBogota(ahora);
    DateTime fecha = DateTime(hoy.year, hoy.month, hoy.day);
    if (intencion.fecha != null) {
      final p = intencion.fecha!.split('-');
      if (p.length == 3) {
        fecha = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      }
    }
    try {
      await ref.read(movimientosRepositoryProvider).crearMovimiento(
            hogarId: hogarId,
            uid: usuario.uid,
            tipo: intencion.tipo ?? 'gasto',
            monto: intencion.monto!,
            categoria: intencion.tipo == 'pagoCuota' ? null : intencion.categoria,
            deudaId: intencion.deudaId,
            fecha: fecha,
            nota: intencion.nota ?? '',
            origen: 'chat',
            ahora: ahora,
            diaInicioPeriodo: usuario.diaInicioPeriodo,
          );

      if (_mensajePropuestaId != null) {
        await ref.read(chatRepositoryProvider).actualizarEstadoMensaje(
              hogarId: hogarId,
              uid: usuario.uid,
              mensajeId: _mensajePropuestaId!,
              estado: 'confirmado',
            );
      }

      await ref.read(chatRepositoryProvider).guardarMensaje(
            hogarId: hogarId,
            uid: usuario.uid,
            rol: 'app',
            texto: 'Listo, quedó registrado.',
            estado: 'confirmado',
          );

      if (mounted) {
        setState(() {
          _propuesta = null;
          _mensajePropuestaId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento guardado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is MovimientosException
                  ? e.mensaje
                  : 'No pudimos guardar. Revisa los datos e intenta de nuevo.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _cambiarPropuesta() async {
    final intencion = _propuesta;
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (intencion == null || usuario == null || hogarId == null) return;

    if (_mensajePropuestaId != null) {
      await ref.read(chatRepositoryProvider).actualizarEstadoMensaje(
            hogarId: hogarId,
            uid: usuario.uid,
            mensajeId: _mensajePropuestaId!,
            estado: 'descartado',
          );
    }
    setState(() {
      _propuesta = null;
      _mensajePropuestaId = null;
    });
    if (!mounted) return;
    await mostrarNuevoMovimientoSheet(
      context,
      prefillTipo: intencion.tipo,
      prefillMonto: intencion.monto,
      prefillCategoria: intencion.categoria,
      prefillDeudaId: intencion.deudaId,
      prefillNota: intencion.nota,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mensajes = ref.watch(mensajesChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: mensajes.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No pudimos cargar el chat.'),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Escribe como le hablas a alguien de la casa.\n'
                        'Ejemplo: “gasté 85 mil en mercado”',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final m = lista[i];
                    final mio = m.rol == 'usuario';
                    return Align(
                      alignment:
                          mio ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: mio
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(m.texto),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_propuesta != null)
            Material(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _textoRespuesta(_propuesta!),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('btn_chat_cambiar'),
                            onPressed: _cambiarPropuesta,
                            child: const Text('Cambiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            key: const Key('btn_chat_guardar'),
                            onPressed: _guardarPropuesta,
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('¿Cómo voy?'),
                  onPressed: _enviando ? null : () => _enviar('¿cómo voy?'),
                ),
                ActionChip(
                  label: const Text('Gasté…'),
                  onPressed: _enviando
                      ? null
                      : () {
                          _ctrl.text = 'gasté ';
                          _ctrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: _ctrl.text.length),
                          );
                        },
                ),
                ActionChip(
                  label: const Text('¿Cuánto me queda?'),
                  onPressed:
                      _enviando ? null : () => _enviar('¿cuánto me queda?'),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('campo_chat_texto'),
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('btn_chat_enviar'),
                    onPressed: _enviando ? null : () => _enviar(),
                    icon: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
