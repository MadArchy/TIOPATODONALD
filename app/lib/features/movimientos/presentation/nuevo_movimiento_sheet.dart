import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/categorias.dart';
import '../../../core/periodo.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dinero.dart';
import '../../../data/models/gasto_fijo.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/movimientos_repository.dart';

/// Abre la hoja "Nuevo" para registrar gasto o ingreso (máx. 3 toques).
Future<void> mostrarNuevoMovimientoSheet(
  BuildContext context, {
  GastoFijo? desdeGastoFijo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => NuevoMovimientoSheet(desdeGastoFijo: desdeGastoFijo),
  );
}

class NuevoMovimientoSheet extends ConsumerStatefulWidget {
  const NuevoMovimientoSheet({super.key, this.desdeGastoFijo});

  final GastoFijo? desdeGastoFijo;

  @override
  ConsumerState<NuevoMovimientoSheet> createState() =>
      _NuevoMovimientoSheetState();
}

class _NuevoMovimientoSheetState extends ConsumerState<NuevoMovimientoSheet> {
  String _tipo = 'gasto';
  late final TextEditingController _montoCtrl;
  String? _categoria;
  DateTime? _fecha;
  final TextEditingController _notaCtrl = TextEditingController();
  File? _foto;
  bool _masOpciones = false;
  bool _guardando = false;
  String? _error;
  bool _fechaListo = false;

  @override
  void initState() {
    super.initState();
    final fijo = widget.desdeGastoFijo;
    if (fijo != null) {
      _tipo = 'gasto';
      _categoria = fijo.categoria;
      _montoCtrl = TextEditingController(text: fijo.monto.toString());
    } else {
      _montoCtrl = TextEditingController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fechaListo) {
      final ahora = ref.read(clockProvider).now();
      _fecha = DateTime(ahora.year, ahora.month, ahora.day);
      _fechaListo = true;
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  List<String> get _categorias =>
      _tipo == 'gasto' ? CategoriasGasto.ids : CategoriasIngreso.ids;

  Future<void> _elegirFoto(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;
    setState(() => _foto = File(x.path));
  }

  Future<void> _guardar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (usuario == null || hogarId == null || hogarId.isEmpty) {
      setState(() => _error = 'No encontramos tu hogar. Vuelve a entrar.');
      return;
    }

    final monto = parseCopInput(_montoCtrl.text);
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Escribe un monto mayor a \$0.');
      return;
    }
    if (_categoria == null) {
      setState(() => _error = 'Elige una categoría.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final ahora = ref.read(clockProvider).now();
      final fecha = _fecha ?? DateTime(ahora.year, ahora.month, ahora.day);
      final fijo = widget.desdeGastoFijo;
      await ref.read(movimientosRepositoryProvider).crearMovimiento(
            hogarId: hogarId,
            uid: usuario.uid,
            diaInicioPeriodo: usuario.diaInicioPeriodo,
            tipo: _tipo,
            monto: monto,
            categoria: _categoria,
            fecha: fecha,
            ahora: ahora,
            nota: _notaCtrl.text,
            origen: fijo != null ? 'gastoFijo' : 'formulario',
            gastoFijoId: fijo?.id,
            fotoLocal: _foto,
          );
      if (mounted) Navigator.of(context).pop();
    } on MovimientosException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No pudimos guardar. Revisa los datos e intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = ref.watch(usuarioActualProvider).value;
    final ahora = ref.watch(clockProvider).now();
    final periodo = usuario == null
        ? null
        : periodoDe(ahora, usuario.diaInicioPeriodo);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.desdeGastoFijo != null
                  ? 'Registrar ${widget.desdeGastoFijo!.nombre}'
                  : 'Nuevo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              key: const Key('seg_tipo_movimiento'),
              segments: const [
                ButtonSegment(value: 'gasto', label: Text('Gasto')),
                ButtonSegment(value: 'ingreso', label: Text('Ingreso')),
              ],
              selected: {_tipo},
              onSelectionChanged: widget.desdeGastoFijo != null
                  ? null
                  : (s) {
                      setState(() {
                        _tipo = s.first;
                        _categoria = null;
                      });
                    },
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('campo_monto_movimiento'),
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '\$0',
                border: InputBorder.none,
              ),
              autofocus: widget.desdeGastoFijo == null,
            ),
            const SizedBox(height: 8),
            Text(
              'Categoría',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            GridView.builder(
              key: const Key('grid_categorias'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _categorias.length,
              itemBuilder: (context, i) {
                final id = _categorias[i];
                final seleccionada = _categoria == id;
                return InkWell(
                  key: Key('cat_$id'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _categoria = id),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: seleccionada
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: seleccionada
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconoCategoria(id), size: 28),
                        const SizedBox(height: 4),
                        Text(
                          etiquetaCategoria(id),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('btn_mas_opciones'),
              onPressed: () => setState(() => _masOpciones = !_masOpciones),
              child: Text(_masOpciones ? 'Menos opciones' : 'Más opciones'),
            ),
            if (_masOpciones) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(
                  (() {
                    final f = _fecha ?? ahora;
                    return '${f.day.toString().padLeft(2, '0')}/'
                        '${f.month.toString().padLeft(2, '0')}/'
                        '${f.year}';
                  })(),
                ),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  if (periodo == null) return;
                  final actual = _fecha ?? ahora;
                  final elegida = await showDatePicker(
                    context: context,
                    initialDate: actual.isBefore(periodo.inicio)
                        ? periodo.inicio
                        : (actual.isAfter(periodo.fin)
                            ? periodo.fin
                            : actual),
                    firstDate: periodo.inicio,
                    lastDate: ahora.isBefore(periodo.fin) ? ahora : periodo.fin,
                    helpText: 'Fecha del movimiento',
                    cancelText: 'Cancelar',
                    confirmText: 'Listo',
                  );
                  if (elegida != null) {
                    setState(() => _fecha = elegida);
                  }
                },
              ),
              TextField(
                key: const Key('campo_nota_movimiento'),
                controller: _notaCtrl,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('btn_foto_camara'),
                      onPressed: () => _elegirFoto(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: const Text('Cámara'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('btn_foto_galeria'),
                      onPressed: () => _elegirFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),
              if (_foto != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Foto lista')),
                    TextButton(
                      onPressed: () => setState(() => _foto = null),
                      child: const Text('Quitar'),
                    ),
                  ],
                ),
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('btn_guardar_movimiento'),
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
