import 'package:hive/hive.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';

class WorkspaceRepository {
  final Box _box;

  WorkspaceRepository(this._box);

  List<WorkspaceModel> getAll() {
    return _box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return WorkspaceModel.fromJson(map);
    }).toList();
  }

  WorkspaceModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return WorkspaceModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> add(WorkspaceModel workspace) async {
    await _box.put(workspace.id, workspace.toJson());
  }

  Future<void> update(WorkspaceModel workspace) async {
    await _box.put(workspace.id, workspace.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
