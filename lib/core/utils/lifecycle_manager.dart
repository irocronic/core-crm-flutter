// lib/core/utils/lifecycle_manager.dart

import 'package:flutter/material.dart';

/// Widget lifecycle yönetimi için helper mixin
///
/// Kullanım:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with LifecycleManager {
///   Future<void> loadData() async {
///     await safeAsyncOperation(() async {
///       final data = await fetchData();
///       setState(() => _data = data);
///     });
///   }
/// }
/// ```
mixin LifecycleManager<T extends StatefulWidget> on State<T> {
  /// Async işlem sırasında widget'ın mount durumunu kontrol eder
  Future<void> safeAsyncOperation(Future<void> Function() operation) async {
    if (!mounted) return;

    try {
      await operation();
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('❌ [LIFECYCLE ERROR] $e');
        debugPrint('📄 [STACK TRACE] $stackTrace');
      }
    }
  }

  /// setState'i güvenli bir şekilde çağırır (mount kontrolü ile)
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Async işlem sonrası setState yapmak için
  Future<void> asyncSetState(Future<void> Function() operation) async {
    if (!mounted) return;

    await operation();

    if (mounted) {
      setState(() {});
    }
  }

  /// Debounced setState (çok sık güncellemeyi önler)
  void debouncedSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 300)}) {
    Future.delayed(delay, () {
      if (mounted) {
        setState(fn);
      }
    });
  }
}

/// Örnek kullanım:
///
/// ```dart
/// class _CustomerDetailScreenState extends State<CustomerDetailScreen>
///     with LifecycleManager {
///
///   Future<void> _loadCustomer() async {
///     await safeAsyncOperation(() async {
///       final customer = await customerService.getCustomer(widget.id);
///       safeSetState(() {
///         _customer = customer;
///       });
///     });
///   }
/// }
/// ```