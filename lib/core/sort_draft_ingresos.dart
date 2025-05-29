import 'package:centro_de_reciclaje_sc/features/Models/model_draft_or_ingreso.dart';

int compareDraftIngreso(DraftIngreso a, DraftIngreso b) {
  if (a.confirmado == b.confirmado) {
    return -a.fechaCreado.compareTo(b.fechaCreado);
  }
  if (a.confirmado) {
    return 1;
  }
  return -1;
}
