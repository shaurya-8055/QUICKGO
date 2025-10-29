import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class JobProvider extends ChangeNotifier {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  JobProvider() {
    // Initialize Firebase services lazily to avoid crashes
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase not initialized yet: $e');
    }
  }

  List<Map<String, dynamic>> _jobs = [];
  Map<String, dynamic>? _activeJob;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get jobs => _jobs;
  Map<String, dynamic>? get activeJob => _activeJob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveJob => _activeJob != null;

  // Statistics
  int get todayJobsCount => _jobs.where((job) {
        final jobDate = (job['createdAt'] as Timestamp?)?.toDate();
        if (jobDate == null) return false;
        final now = DateTime.now();
        return jobDate.year == now.year &&
            jobDate.month == now.month &&
            jobDate.day == now.day;
      }).length;

  int get activeJobsCount => _jobs
      .where((job) =>
          job['status'] == AppConfig.jobStatusAccepted ||
          job['status'] == AppConfig.jobStatusEnRoute ||
          job['status'] == AppConfig.jobStatusWorking)
      .length;

  int get completedJobsCount => _jobs
      .where((job) => job['status'] == AppConfig.jobStatusCompleted)
      .length;

  Future<void> loadJobs() async {
    if (_firestore == null || _auth == null) {
      debugPrint('Firebase not available');
      return;
    }

    final user = _auth!.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore!
          .collection(AppConfig.jobsCollection)
          .where('workerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _jobs = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Find active job
      _activeJob = _jobs.firstWhere(
        (job) =>
            job['status'] == AppConfig.jobStatusAccepted ||
            job['status'] == AppConfig.jobStatusEnRoute ||
            job['status'] == AppConfig.jobStatusWorking,
        orElse: () => {},
      );

      if (_activeJob?.isEmpty ?? true) {
        _activeJob = null;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptJob(String jobId) async {
    if (_firestore == null || _auth == null) return false;

    try {
      await _firestore!.collection(AppConfig.jobsCollection).doc(jobId).update({
        'status': AppConfig.jobStatusAccepted,
        'acceptedAt': FieldValue.serverTimestamp(),
        'workerId': _auth!.currentUser?.uid,
      });

      await loadJobs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJobStatus(String jobId, String status) async {
    if (_firestore == null) return false;

    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == AppConfig.jobStatusEnRoute) {
        updateData['enRouteAt'] = FieldValue.serverTimestamp();
      } else if (status == AppConfig.jobStatusWorking) {
        updateData['startedAt'] = FieldValue.serverTimestamp();
      } else if (status == AppConfig.jobStatusCompleted) {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore!
          .collection(AppConfig.jobsCollection)
          .doc(jobId)
          .update(updateData);

      await loadJobs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelJob(String jobId, String reason) async {
    if (_firestore == null) return false;

    try {
      await _firestore!.collection(AppConfig.jobsCollection).doc(jobId).update({
        'status': AppConfig.jobStatusCancelled,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'cancelledBy': 'worker',
      });

      await loadJobs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> getJobsByStatus(String status) {
    return _jobs.where((job) => job['status'] == status).toList();
  }

  List<Map<String, dynamic>> getRecentJobs({int limit = 5}) {
    return _jobs.take(limit).toList();
  }
}
