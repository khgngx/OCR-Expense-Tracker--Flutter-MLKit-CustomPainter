import '../../core/utils/currency_formatter.dart';
import '../models/category.dart';
import '../models/parsed_receipt.dart';
import '../models/receipt_line_item.dart';

/// Regex/heuristic engine turning raw OCR text into a [ParsedReceipt].
/// Pure function of its input: no I/O, no database.
///
/// Keyword matching runs on a diacritic-folded copy of each line (same length
/// as the original), so "Tổng cộng", "TONG CONG" and OCR output that dropped
/// accents all match the same ASCII pattern.
class ParseReceiptTextUsecase {
  const ParseReceiptTextUsecase();

  /// 1.234.567 / 1,234 / 12000. Not preceded by a digit or separator, so
  /// zero-padded ids like 00012345 are never read as money.
  static final RegExp _amount = RegExp(
    r'(?<![\d.,])(?:[1-9]\d{0,2}(?:[.,]\d{3})+|[1-9]\d{3,})(?!\d)',
  );
  static final RegExp _dateDmy = RegExp(
    r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4}|\d{2})(?:\D+(\d{1,2}):(\d{2}))?',
  );
  static final RegExp _dateYmd = RegExp(
    r'(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})(?:\D+(\d{1,2}):(\d{2}))?',
  );
  static final RegExp _totalKeyword = RegExp(
    r'tong\s*cong|tong\s*tien|tong\s*thanh\s*toan|thanh\s*toan|thanh\s*tien|total|amount\s*due|grand\s*total',
  );
  static final RegExp _subtotalKeyword = RegExp(
    r'sub\s*total|tam\s*tinh|vat|thue|tax|giam\s*gia|discount|service|phi\s*dich\s*vu',
  );

  /// Cash tendered / change lines: money, but neither an item nor the total.
  static final RegExp _paymentKeyword = RegExp(
    r'khach\s*dua|tien\s*thua|tien\s*mat|tra\s*lai|cash|change|tendered',
  );
  static final RegExp _receiptNoKeyword = RegExp(
    r'(?:so\s*(?:hoa\s*don|hd|bill|phieu)|bill\s*(?:no|number|#)|invoice\s*(?:no|number|#)?|receipt\s*(?:no|number|#)|hd\s*(?:no|so)?)\s*[:#.]?\s*([a-z0-9\-/]{3,})',
  );

  static const Map<Category, List<String>> _categoryKeywords = {
    Category.food: [
      'cafe',
      'coffee',
      'ca phe',
      'restaurant',
      'nha hang',
      'quan',
      'bun',
      'pho',
      'tra sua',
      'pizza',
      'bakery',
      'highlands',
      'starbucks',
      'circle k',
      'winmart',
      'coopmart',
      'bach hoa xanh',
      'lotte mart',
      'big c',
      'sieu thi',
      'supermarket',
      'kitchen',
    ],
    Category.study: [
      'book',
      'sach',
      'nha sach',
      'fahasa',
      'stationery',
      'van phong pham',
      'school',
      'truong',
      'course',
      'hoc',
    ],
    Category.travel: [
      'grab',
      'gojek',
      'taxi',
      'xang',
      'petrolimex',
      'bus',
      'ticket',
      'airlines',
      'vietjet',
      'bamboo',
      'hotel',
      'khach san',
    ],
    Category.gear: [
      'phong vu',
      'the gioi di dong',
      'fpt shop',
      'electronics',
      'dien may',
      'laptop',
      'phu kien',
      'cellphones',
    ],
    Category.entertainment: [
      'cinema',
      'cgv',
      'galaxy',
      'game',
      'karaoke',
      'netflix',
      'spotify',
      'pub',
    ],
  };

  static const String _accented =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  static const String _plain =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

  ParsedReceipt call(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const ParsedReceipt();
    }
    final folded = lines.map(_fold).toList();

    final merchant = _merchant(lines);
    return ParsedReceipt(
      merchantName: merchant,
      dateTime: _dateTime(lines),
      total: _total(folded),
      receiptNumber: _receiptNumber(lines, folded),
      category: _category(merchant, lines),
      lineItems: _lineItems(lines, folded),
    );
  }

  /// Lowercases and strips Vietnamese diacritics, one char for one char.
  static String _fold(String line) {
    final buffer = StringBuffer();
    for (final rune in line.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      final i = _accented.indexOf(ch);
      buffer.write(i >= 0 && i < _plain.length ? _plain[i] : ch);
    }
    return buffer.toString();
  }

  String? _merchant(List<String> lines) {
    for (final line in lines.take(6)) {
      final letters = RegExp(r'\p{L}', unicode: true).allMatches(line).length;
      final digits = RegExp(r'\d').allMatches(line).length;
      if (letters >= 3 &&
          letters > digits &&
          !_dateDmy.hasMatch(line) &&
          !_receiptNoKeyword.hasMatch(_fold(line))) {
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
        if (d != null) {
          return d;
        }
      }
      final dmy = _dateDmy.firstMatch(line);
      if (dmy != null) {
        var year = int.parse(dmy[3]!);
        if (year < 100) {
          year += 2000;
        }
        final d = _build(
          year,
          int.parse(dmy[2]!),
          int.parse(dmy[1]!),
          dmy[4],
          dmy[5],
        );
        if (d != null) {
          return d;
        }
      }
    }
    return null;
  }

  /// Rejects impossible dates (e.g. month 13) instead of letting DateTime roll over.
  DateTime? _build(int y, int m, int d, String? hh, String? mm) {
    if (m < 1 || m > 12 || d < 1 || d > 31) {
      return null;
    }
    final dt = DateTime(
      y,
      m,
      d,
      int.tryParse(hh ?? '') ?? 0,
      int.tryParse(mm ?? '') ?? 0,
    );
    return dt.month == m ? dt : null;
  }

  double? _total(List<String> folded) {
    // Prefer the last "total" line that is not a subtotal/tax line.
    for (var i = folded.length - 1; i >= 0; i--) {
      final line = folded[i];
      if (!_totalKeyword.hasMatch(line) || _subtotalKeyword.hasMatch(line)) {
        continue;
      }
      final onLine = _amounts(line);
      if (onLine.isNotEmpty) {
        return onLine.last;
      }
      if (i + 1 < folded.length) {
        final next = _amounts(folded[i + 1]);
        if (next.isNotEmpty) {
          return next.last;
        }
      }
    }
    final all = folded
        .where((l) => !_paymentKeyword.hasMatch(l))
        .expand(_amounts)
        .toList();
    return all.isEmpty ? null : all.reduce((a, b) => a > b ? a : b);
  }

  /// Money amounts on [line]; none for date lines (the year is not money).
  List<double> _amounts(String line) {
    if (_dateDmy.hasMatch(line) || _dateYmd.hasMatch(line)) {
      return const [];
    }
    return _amount
        .allMatches(line)
        .map((m) => CurrencyFormatter.parse(m.group(0)!))
        .whereType<double>()
        .toList();
  }

  String? _receiptNumber(List<String> lines, List<String> folded) {
    for (var i = 0; i < lines.length; i++) {
      final m = _receiptNoKeyword.firstMatch(folded[i]);
      if (m != null) {
        // The id is the pattern's trailing group, and folding keeps indices
        // aligned, so slice it back out of the original-cased line.
        return lines[i].substring(m.end - m.group(1)!.length, m.end);
      }
    }
    return null;
  }

  Category _category(String? merchant, List<String> lines) {
    final haystack = _fold('${merchant ?? ''} ${lines.take(4).join(' ')}');
    for (final entry in _categoryKeywords.entries) {
      if (entry.value.any(haystack.contains)) {
        return entry.key;
      }
    }
    return Category.food;
  }

  List<ReceiptLineItem> _lineItems(List<String> lines, List<String> folded) {
    final items = <ReceiptLineItem>[];
    for (var i = 0; i < lines.length; i++) {
      final f = folded[i];
      if (_totalKeyword.hasMatch(f) ||
          _subtotalKeyword.hasMatch(f) ||
          _paymentKeyword.hasMatch(f) ||
          _receiptNoKeyword.hasMatch(f)) {
        continue;
      }
      final amounts = _amounts(lines[i]);
      if (amounts.isEmpty) {
        continue;
      }
      final firstAmount = _amount.firstMatch(lines[i])!;
      final name = lines[i]
          .substring(0, firstAmount.start)
          .replaceAll(RegExp(r'[\sxX*\d]+$'), '')
          .trim();
      if (name.length < 2 || !RegExp(r'\p{L}', unicode: true).hasMatch(name)) {
        continue;
      }
      final qty =
          int.tryParse(
            RegExp(r'(\d{1,2})\s*[xX*]').firstMatch(lines[i])?.group(1) ?? '',
          ) ??
          1;
      items.add(
        ReceiptLineItem(name: name, price: amounts.last, quantity: qty),
      );
    }
    return items;
  }
}
