import 'package:ml_2/modes.dart';
import 'package:riverpod/riverpod.dart';

final stepModeProvider = Provider<StepMode>((ref) => StepMode());

final noteModeProvider = Provider<NoteMode>((ref) => NoteMode());

final moduleModeProvider = Provider<ModuleMode>((ref) => ModuleMode());

final perfomModeProvider = Provider<PerformMode>((ref) => PerformMode());
