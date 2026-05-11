import 'package:dio/dio.dart';
import 'package:ndc/models/product.dart';

import 'app_logger.dart';

// ─────────────────────────────────────────────
// SHEETS SERVICE
// ─────────────────────────────────────────────

class SheetsService {
  SheetsService._();

  // ─────────────────────────────────────────────
  // SINGLETON
  // ─────────────────────────────────────────────

  static final SheetsService instance = SheetsService._();

  // ─────────────────────────────────────────────
  // CONFIG
  // ─────────────────────────────────────────────

  static const String spreadsheetId = '1Mrrxkgc_LyHGGuFFbp54id04HGa1YxSUBey3GMveD78';

  // 🔥 YOUR PUBLIC API KEY
  static const String apiKey = 'AIzaSyBw3n4syUIBueNZFfpjxIEwP_53r8OZCOQ';

  static const String baseUrl =
      'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values';

  // ─────────────────────────────────────────────
  // CACHE
  // ─────────────────────────────────────────────

  List<Product>? _productsCache;

  DateTime? _productsCacheTime;

  // ─────────────────────────────────────────────
  // DIO
  // ─────────────────────────────────────────────

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,

            connectTimeout: const Duration(seconds: 10),

            receiveTimeout: const Duration(seconds: 10),

            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              AppLogger.d('[DIO] 🚀 ${options.method} ${options.uri}');

              return handler.next(options);
            },

            onResponse: (response, handler) {
              AppLogger.s('[DIO] ✅ ${response.statusCode}');

              return handler.next(response);
            },

            onError: (error, handler) {
              AppLogger.e('[DIO] ❌ ${error.message}', error);

              return handler.next(error);
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestBody: false,

            responseBody: false,

            requestHeader: false,
          ),
        );

  // ─────────────────────────────────────────────
  // RANGE URL
  // ─────────────────────────────────────────────

  String _rangeUrl(String tabName, String range) {
    final encodedRange = Uri.encodeComponent('$tabName!$range');

    return '/$encodedRange?key=$apiKey';
  }

  // ─────────────────────────────────────────────
  // FETCH RANGE
  // ─────────────────────────────────────────────

  Future<List<List<dynamic>>> _fetchRange(String tabName, String range) async {
    try {
      AppLogger.i('[Sheets] Fetching → $tabName!$range');

      final response = await dio.get(_rangeUrl(tabName, range));

      final data = response.data as Map<String, dynamic>;

      final values = data['values'] as List<dynamic>?;

      if (values == null || values.isEmpty) {
        AppLogger.w('[Sheets] Empty Range → $tabName!$range');

        return [];
      }

      AppLogger.s('[Sheets] ${values.length} rows fetched');

      return values.map((row) => List<dynamic>.from(row)).toList();
    } on DioException catch (e, stack) {
      AppLogger.e('[Sheets] Dio Error → $tabName!$range', e, stack);

      throw Exception(e.response?.data?['error']?['message'] ?? e.message);
    } catch (e, stack) {
      AppLogger.e('[Sheets] Unexpected Error', e, stack);

      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // FETCH SINGLE CELL
  // ─────────────────────────────────────────────

  Future<String> _fetchSingleCell(String tabName, String range) async {
    try {
      final values = await _fetchRange(tabName, range);

      if (values.isEmpty || values.first.isEmpty) {
        AppLogger.w('[Sheets] Empty Cell → $tabName!$range');

        return '';
      }

      final value = values.first.first.toString();

      AppLogger.s('[Sheets] $tabName!$range = $value');

      return value;
    } catch (e, stack) {
      AppLogger.e('[Sheets] Single Cell Fetch Failed', e, stack);

      return '';
    }
  }

  // ─────────────────────────────────────────────
  // PRODUCTS
  // ─────────────────────────────────────────────

  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    try {
      // ─────────────────────────────────────────────
      // CACHE CHECK
      // ─────────────────────────────────────────────

      final cacheValid =
          _productsCacheTime != null &&
          DateTime.now().difference(_productsCacheTime!) <
              const Duration(minutes: 10);

      if (!forceRefresh &&
          cacheValid &&
          _productsCache != null &&
          _productsCache!.isNotEmpty) {
        AppLogger.i('[Products] Using Cache');

        return _productsCache!;
      }

      AppLogger.i('[Products] Fetching Products...');

      final rows = await _fetchRange('Products', 'A1:H500');

      if (rows.isEmpty) {
        AppLogger.w('[Products] Empty Products');

        return [];
      }

      // ─────────────────────────────────────────────
      // HEADERS
      // ─────────────────────────────────────────────

      final headers = rows.first.map((e) => e.toString()).toList();

      AppLogger.d('[Products] Headers Loaded');

      final products = <Product>[];

      // ─────────────────────────────────────────────
      // PARSE PRODUCTS
      // ─────────────────────────────────────────────

      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];

          if (row.length < headers.length) {
            AppLogger.w('[Products] Skipping Incomplete Row → $i');

            continue;
          }

          final map = Map<String, dynamic>.fromIterables(headers, row);

          final product = Product.fromMap(map);

          products.add(product);
        } catch (e, stack) {
          AppLogger.e('[Products] Parse Error Row → $i', e, stack);
        }
      }

      // ─────────────────────────────────────────────
      // SORT
      // ─────────────────────────────────────────────

      products.sort((a, b) => b.id.compareTo(a.id));

      // ─────────────────────────────────────────────
      // CACHE
      // ─────────────────────────────────────────────

      _productsCache = products;

      _productsCacheTime = DateTime.now();

      AppLogger.s('[Products] ${products.length} Loaded Successfully');

      return products;
    } catch (e, stack) {
      AppLogger.e('[Products] Failed', e, stack);

      rethrow;
    }
  }



  Future<String> fetchDeveloperName() async {
    return _fetchSingleCell('Splash', 'A1:A1');
  }
  Future<String> fetchLastUpdateDate() async {
    return _fetchSingleCell('Splash', 'A2:A2');
  }
  
  Future<String> fetchMobileNumber() async {
    return _fetchSingleCell('Splash', 'A3:A3');
  }

  Future<({String qrImageUrl, String upiId})> fetchUpiData() async {
    try {
      final values = await _fetchRange('Splash', 'A4:A5');

      final qrImageUrl = values.isNotEmpty ? values[0][0].toString() : '';

      final upiId = values.length > 1 ? values[1][0].toString() : '';

      AppLogger.s('[UPI] QR + UPI Loaded');

      return (qrImageUrl: qrImageUrl, upiId: upiId);
    } catch (e, stack) {
      AppLogger.e('[UPI] Failed', e, stack);

      return (qrImageUrl: '', upiId: '');
    }
  }

  Future<String> fetchInstaLink() async {
    return _fetchSingleCell('Splash', 'A6:A6');
  }

  Future<String> fetchUpdateLogs() async {
    return _fetchSingleCell('Splash', 'A7:A7');
  }


  // ─────────────────────────────────────────────
  // CLEAR CACHE
  // ─────────────────────────────────────────────

  void clearCache() {
    AppLogger.w('[Cache] Clearing Product Cache');

    _productsCache = null;

    _productsCacheTime = null;
  }
}

// ─────────────────────────────────────────────
// GLOBAL INSTANCE
// ─────────────────────────────────────────────

final sheets = SheetsService.instance;

// ─────────────────────────────────────────────
// GLOBAL SHORTCUTS
// ─────────────────────────────────────────────

Future<List<Product>> fetchProducts({bool forceRefresh = false}) {
  return sheets.fetchProducts(forceRefresh: forceRefresh);
}

Future<String> fetchAppMetaName() {
  return sheets.fetchDeveloperName();
}

Future<String> fetchAppMetaDate() {
  return sheets.fetchLastUpdateDate();
}

Future<String> fetchMobileNumber() {
  return sheets.fetchMobileNumber();
}

Future<({String qrImageUrl, String upiId})> fetchUpiData() {
  return sheets.fetchUpiData();
}

Future<String> fetchAppMetaLink() {
  return sheets.fetchInstaLink();
}

Future<String> fetchUpdateLogs() {
  return sheets.fetchUpdateLogs();
}
