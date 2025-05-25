import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_draft_ingreso.dart';
import 'package:centro_de_reciclaje_sc/services/service_ingreso.dart';

class DraftOrIngresoService {
  static final instance = DraftOrIngresoService();

  final ingresoService = IngresoService.instance;
  final draftIngresoService = DraftIngresoService.instance;

  Future<List<DraftOrIngreso>> getDraftOrIngresos() async {
    var ingresos = await ingresoService.getIngresos();
    var draftIngresos = await draftIngresoService.getDraftIngresos();

    return List.from(draftIngresos)..addAll(ingresos);
  }
}
