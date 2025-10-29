import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EarningsProvider extends ChangeNotifier {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  EarningsProvider() {
    // Initialize Firebase services lazily to avoid crashes
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase not initialized yet: $e');
    }
  }

  double _todayEarnings = 0.0;
  double _weekEarnings = 0.0;
  double _monthEarnings = 0.0;
  double _totalEarnings = 0.0;
  double _availableBalance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  double get todayEarnings => _todayEarnings;
  double get weekEarnings => _weekEarnings;
  double get monthEarnings => _monthEarnings;
  double get totalEarnings => _totalEarnings;
  double get availableBalance => _availableBalance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEarnings() async {
    if (_firestore == null || _auth == null) {
      debugPrint('Firebase not available');
      return;
    }

    final user = _auth!.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      // Load wallet data
      final walletDoc =
          await _firestore!.collection('wallets').doc(user.uid).get();

      if (walletDoc.exists) {
        final data = walletDoc.data()!;
        _availableBalance = (data['balance'] ?? 0.0).toDouble();
        _totalEarnings = (data['totalEarnings'] ?? 0.0).toDouble();
      }

      // Load transactions
      final transactionsSnapshot = await _firestore!
          .collection('wallets')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      _transactions = transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Calculate period earnings
      _todayEarnings = _calculateEarningsForPeriod(todayStart);
      _weekEarnings = _calculateEarningsForPeriod(weekStart);
      _monthEarnings = _calculateEarningsForPeriod(monthStart);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading earnings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateEarningsForPeriod(DateTime startDate) {
    return _transactions.where((transaction) {
      final transactionDate =
          (transaction['createdAt'] as Timestamp?)?.toDate();
      if (transactionDate == null) return false;
      return transactionDate.isAfter(startDate) &&
          transaction['type'] == 'credit' &&
          transaction['category'] == 'job_payment';
    }).fold(0.0,
        (sum, transaction) => sum + (transaction['amount'] ?? 0.0).toDouble());
  }

  Future<bool> requestWithdrawal(
      double amount, Map<String, dynamic> bankDetails) async {
    if (_firestore == null || _auth == null) return false;

    final user = _auth!.currentUser;
    if (user == null) return false;

    if (amount > _availableBalance) {
      _errorMessage = 'Insufficient balance';
      notifyListeners();
      return false;
    }

    try {
      await _firestore!.collection('withdrawalRequests').add({
        'workerId': user.uid,
        'amount': amount,
        'bankDetails': bankDetails,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      await loadEarnings();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }

  Map<String, double> getEarningsByCategory() {
    final Map<String, double> categoryEarnings = {};

    for (var transaction in _transactions) {
      if (transaction['type'] == 'credit') {
        final category = transaction['category'] ?? 'other';
        categoryEarnings[category] = (categoryEarnings[category] ?? 0.0) +
            (transaction['amount'] ?? 0.0).toDouble();
      }
    }

    return categoryEarnings;
  }
}
