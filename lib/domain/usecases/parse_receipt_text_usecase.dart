import '../../core/utils/currency_formatter.dart';
import '../models/category.dart';
import '../models/parsed_receipt.dart';
import '../models/receipt_line_item.dart';

/// Regex/heuristic engine turning raw OCR text into a [ParsedReceipt].
/// Pure function of its input: no I/O, no database.
class ParseReceiptTextUsecase {
  const ParseReceiptTextUsecase();

  static final RegExp _amount = RegExp(r'\d{1,3}(?:[.,]\d{3})+|\d{4,}');
  static final RegExp _dateDmy = RegExp(
    r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4}|\d{2})(?:\D+(\d{1,2}):(\d{2}))?',
  );
  static final RegExp _dateYmd = RegExp(
    r'(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})(?:\D+(\d{1,2}):(\d{2}))?',
  );
  static final RegExp _totalKeyword = RegExp(
    r'(t[oô]ng\s*c[oộ]ng|t[oô]ng\s*ti[eê]n|t[oô]ng\s*thanh\s*to[aá]n|thanh\s*to[aá]n|th[aà]nh\s*ti[eê]n|total|amount\s*due|grand\s*total)',
    caseSensitive: false,
  );
  static final RegExp _subtotalKeyword = RegExp(
    r'(sub\s*total|t[aạ]m\s*t[ií]nh|vat|thu[eế]|tax|gi[aả]m\s*gi[aá]|discount)',
    caseSensitive: false,
  );
  static final RegExp _receiptNoKeyword = RegExp(
    r'(?:s[oố]\s*(?:h[oó]a\s*[dđ][oơ]n|h[dđ]|bill|phi[eế]u)|bill\s*(?:no|number|#)|invoice\s*(?:no|number|#)?|receipt\s*(?:no|number|#)|h[dđ]\s*(?:no|s[oố])?)\s*[:#.]?\s*([A-Za-z0-9\-/]{3,})',
    caseSensitive: false,
  );

  static const Map<Category, List<String>> _categoryKeywords = {
    Category.food: [
      'cafe',
      'coffee',
      'cà phê',
      'ca phe',
      'restaurant',
      'nhà hàng',
      'quán',
      'bún',
      'phở',
      'pho',
      'trà sữa',
      'pizza',
      'bakery',
      'highlands',
      'starbucks',
      'circle k',
      'winmart',
      'coopmart',
      'bach hoa xanh',
      'bách hóa xanh',
      'lotte mart',
      'big c',
      'siêu thị',
      'supermarket',
    ],
    Category.study: [
      'book',
      'sách',
      'nhà sách',
      'fahasa',
      'stationery',
      'văn phòng phẩm',
      'school',
      'trường',
      'course',
      'học',
    ],
    Category.travel: [
      'grab',
      'be ',
      'gojek',
      'taxi',
      'xăng',
      'petrolimex',
      'bus',
      'vé',
      'ticket',
      'airlines',
      'vietjet',
      'bamboo',
      'hotel',
      'khách sạn',
    ],
    Category.gear: [
      'phong vũ',
      'thế giới di động',
      'the gioi di dong',
      'fpt shop',
      'electronics',
      'điện máy',
      'laptop',
      'phụ kiện',
      'cellphones',
    ],
    Category.entertainment: [
      'cinema',
      'cgv',
      'lotte cinema',
      'galaxy',
      'game',
      'karaoke',
      'netflix',
      'spotify',
      'bar ',
      'pub',
    ],
  };

  ParsedReceipt call(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return const ParsedReceipt();

    final merchant = _merchant(lines);
    return ParsedReceipt(
      merchantName: merchant,
      dateTime: _dateTime(lines),
      total: _total(lines),
      receiptNumber: _receiptNumber(lines),
      category: _category(merchant, rawText),
      lineItems: _lineItems(lines),
    );
  }

  String? _merchant(List<String> lines) {
    for (final line in lines.take(6)) {
      final letters = RegExp(r'\p{L}', unicode: true).allMatches(line).length;
      final digits = RegExp(r'\d').allMatches(line).length;
      if (letters >= 3 &&
          letters > digits &&
          !_dateDmy.hasMatch(line) &&
          !_receiptNoKeyword.hasMatch(line)) {
        return line;
      }
    }
    return null;
  }

  DateTime? _dateTime(List<String> lines) {
    for (final line in lines) {
      final ymd = _dateYmd.firstMatch(line);
      if (ymd != null) {
        final d = _build(
          int.parse(ymd[1]!),
          int.parse(ymd[2]!),
          int.parse(ymd[3]!),
          ymd[4],
          ymd[5],
        );
        if (d != null) return d;
      }
      final dmy = _dateDmy.firstMatch(line);
      if (dmy != null) {
        var year = int.parse(dmy[3]!);
        if (year < 100) year += 2000;
        final d = _build(
          year,
          int.parse(dmy[2]!),
          int.parse(dmy[1]!),
          dmy[4],
          dmy[5],
        );
        if (d != null) return d;
      }
    }
    return null;
  }

  /// Rejects impossible dates (e.g. month 13) instead of letting DateTime roll over.
  DateTime? _build(int y, int m, int d, String? hh, String? mm) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(
      y,
      m,
      d,
      int.tryParse(hh ?? '') ?? 0,
      int.tryParse(mm ?? '') ?? 0,
    );
    return dt.month == m ? dt : null;
  }

  double? _total(List<String> lines) {
    // Prefer the last "total" line that is not a subtotal/tax line.
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      if (!_totalKeyword.hasMatch(line) || _subtotalKeyword.hasMatch(line)) {
        continue;
      }
      final onLine = _amounts(line);
      if (onLine.isNotEmpty) return onLine.last;
      if (i + 1 < lines.length) {
        final next = _amounts(lines[i + 1]);
        if (next.isNotEmpty) return next.last;
      }
    }
    final all = lines.expand(_amounts).toList();
    return all.isEmpty ? null : all.reduce((a, b) => a > b ? a : b);
  }

  List<double> _amounts(String line) => _amount
      .allMatches(line)
      .map((m) => CurrencyFormatter.parse(m.group(0)!))
      .whereType<double>()
      .toList();

  String? _receiptNumber(List<String> lines) {
    for (final line in lines) {
      final m = _receiptNoKeyword.firstMatch(line);
      if (m != null) return m.group(1);
    }
    return null;
  }

  Category _category(String? merchant, String rawText) {
    final haystack =
        '${merchant ?? ''} ${rawText.split('\n').take(4).join(' ')}'
            .toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      if (entry.value.any(haystack.contains)) return entry.key;
    }
    return Category.food;
  }

  List<ReceiptLineItem> _lineItems(List<String> lines) {
    final items = <ReceiptLineItem>[];
    for (final line in lines) {
      if (_totalKeyword.hasMatch(line) ||
          _subtotalKeyword.hasMatch(line) ||
          _dateDmy.hasMatch(line)) {
        continue;
      }
      final amounts = _amounts(line);
      if (amounts.isEmpty) continue;
      final firstAmount = _amount.firstMatch(line)!;
      final name = line
          .substring(0, firstAmount.start)
          .replaceAll(RegExp(r'[\sxX*\d]+$'), '')
          .trim();
      if (name.length < 2 || !RegExp(r'\p{L}', unicode: true).hasMatch(name)) {
        continue;
      }
      final qty =
          int.tryParse(
            RegExp(r'(\d{1,2})\s*[xX*]').firstMatch(line)?.group(1) ?? '',
          ) ??
          1;
      items.add(
        ReceiptLineItem(name: name, price: amounts.last, quantity: qty),
      );
    }
    return items;
  }
}
