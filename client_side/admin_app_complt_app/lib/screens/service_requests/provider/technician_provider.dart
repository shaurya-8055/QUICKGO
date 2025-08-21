import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/api_response.dart';
import '../../../models/technician.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class TechnicianProvider extends ChangeNotifier {
  final HttpService _http = HttpService();

  List<Technician> _technicians = [];
  List<Technician> _filteredTechnicians = [];
  bool _loading = false;
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<Technician> get technicians => _filteredTechnicians;
  List<Technician> get allTechnicians => _technicians;
  bool get loading => _loading;

  List<Technician> get activeTechnicians =>
      _technicians.where((t) => t.active == true).toList();

  void filterTechnicians(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByStatus(String? status) {
    _statusFilter = status ?? 'All';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTechnicians = _technicians.where((technician) {
      // Apply status filter
      bool statusMatch = true;
      if (_statusFilter != 'All') {
        statusMatch = technician.active.toString() == _statusFilter;
      }

      // Apply search filter
      bool searchMatch = true;
      if (_searchQuery.isNotEmpty) {
        searchMatch = (technician.name?.toLowerCase().contains(_searchQuery) ??
                false) ||
            (technician.phone?.toLowerCase().contains(_searchQuery) ?? false) ||
            (technician.skills?.any(
                    (skill) => skill.toLowerCase().contains(_searchQuery)) ??
                false);
      }

      return statusMatch && searchMatch;
    }).toList();
    notifyListeners();
  }

  Future<void> getAllTechnicians({bool showSnack = false}) async {
    _loading = true;
    notifyListeners();

    try {
      final Response res = await _http.getItems(endpointUrl: 'technicians');

      if (res.isOk) {
        final api = ApiResponse<List<Technician>>.fromJson(
          res.body,
          (obj) => (obj as List)
              .map((e) => Technician.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

        if (api.success) {
          _technicians = api.data ?? [];
          _filteredTechnicians = _technicians; // Initialize filtered list
          _applyFilters(); // Apply any existing filters
          if (showSnack) {
            SnackBarHelper.showSuccessSnackBar(
                'Technicians loaded successfully');
          }
        } else {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar(api.message);
          }
        }
      } else {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Failed to load technicians');
        }
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<(bool, String)> addTechnician({
    required String name,
    required String phone,
    required List<String> skills,
    bool active = true,
  }) async {
    try {
      final payload = {
        'name': name,
        'phone': phone,
        'skills': skills,
        'active': active,
      };

      final Response res = await _http.addItem(
        endpointUrl: 'technicians',
        itemData: payload,
      );

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          await getAllTechnicians();
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg =
            res.body?['message']?.toString() ?? 'Failed to add technician';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    }
  }

  Future<(bool, String)> updateTechnician({
    required String id,
    required String name,
    required String phone,
    required List<String> skills,
    required bool active,
  }) async {
    try {
      final payload = {
        'name': name,
        'phone': phone,
        'skills': skills,
        'active': active,
      };

      final Response res = await _http.patchItem(
        endpointUrl: 'technicians',
        itemId: id,
        itemData: payload,
      );

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          await getAllTechnicians();
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg =
            res.body?['message']?.toString() ?? 'Failed to update technician';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    }
  }

  Future<(bool, String)> deleteTechnician(String id) async {
    try {
      final Response res = await _http.deleteItem(
        endpointUrl: 'technicians',
        itemId: id,
      );

      if (res.isOk) {
        final api = ApiResponse.fromJson(res.body, (obj) => obj);
        if (api.success) {
          await getAllTechnicians();
          SnackBarHelper.showSuccessSnackBar(api.message);
          return (true, api.message);
        } else {
          SnackBarHelper.showErrorSnackBar(api.message);
          return (false, api.message);
        }
      } else {
        final msg =
            res.body?['message']?.toString() ?? 'Failed to delete technician';
        SnackBarHelper.showErrorSnackBar(msg);
        return (false, msg);
      }
    } catch (e) {
      final msg = e.toString();
      SnackBarHelper.showErrorSnackBar(msg);
      return (false, msg);
    }
  }

  Technician? getTechnicianById(String id) {
    try {
      return _technicians.firstWhere((t) => t.sId == id);
    } catch (e) {
      return null;
    }
  }

  List<Technician> getTechniciansBySkill(String skill) {
    return _technicians
        .where((t) =>
            t.active == true &&
            (t.skills?.any(
                    (s) => s.toLowerCase().contains(skill.toLowerCase())) ??
                false))
        .toList();
  }
}
