import 'dart:math' as math;
import 'package:simply_calculator/screen/unit_converter/models/unit_category.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_item.dart';

class UnitConversionUtil {
  /// Hàm chuyển đổi chính, xử lý tất cả các loại chuyển đổi
  static double convert({
    required double value,
    required UnitItem fromUnit,
    required UnitItem toUnit,
    required UnitCategory category,
  }) {
    // Nếu đơn vị giống nhau, trả về nguyên giá trị
    if (fromUnit.shortName == toUnit.shortName) {
      return value;
    }

    // Xử lý các trường hợp đặc biệt theo category
    switch (category) {
      case UnitCategory.temperature:
        return _convertTemperature(value, fromUnit.shortName, toUnit.shortName);
      case UnitCategory.data:
        return _convertData(value, fromUnit.shortName, toUnit.shortName);
      case UnitCategory.angle:
        return _convertAngle(value, fromUnit.shortName, toUnit.shortName);
      case UnitCategory.energy:
        return _convertEnergy(value, fromUnit.shortName, toUnit.shortName);
      case UnitCategory.time:
        return _convertTime(value, fromUnit.shortName, toUnit.shortName);
      case UnitCategory.volume:
        return _convertVolume(value, fromUnit.shortName, toUnit.shortName);
      default:
        // ĐẢM BẢO CÔNG THỨC CHÍNH XÁC
        return value * fromUnit.conversionFactor / toUnit.conversionFactor;
    }
  }

  /// Chuyển đổi nhiệt độ
  static double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;

    // Chuyển tất cả về Kelvin trước
    double kelvin;

    switch (from) {
      case '°C':
        kelvin = value + 273.15;
        break;
      case '°F':
        kelvin = (value + 459.67) * 5 / 9;
        break;
      case 'K':
        kelvin = value;
        break;
      default:
        kelvin = value;
        break;
    }

    // Chuyển từ Kelvin sang đơn vị đích
    switch (to) {
      case '°C':
        return kelvin - 273.15;
      case '°F':
        return kelvin * 9 / 5 - 459.67;
      case 'K':
        return kelvin;
      default:
        return kelvin;
    }
  }

  /// Chuyển đổi dữ liệu (xử lý đặc biệt cho bit, byte và các kilobit/kilobyte)
  static double _convertData(double value, String from, String to) {
    // Chuyển tất cả về bits trước
    double bits;

    switch (from) {
      case 'bit':
        bits = value;
        break;
      case 'B':
        bits = value * 8;
        break;
      case 'KB':
        bits = value * 8 * 1000;
        break;
      case 'MB':
        bits = value * 8 * 1000 * 1000;
        break;
      case 'GB':
        bits = value * 8 * 1000 * 1000 * 1000;
        break;
      case 'TB':
        bits = value * 8 * 1000 * 1000 * 1000 * 1000;
        break;
      case 'KiB':
        bits = value * 8 * 1024;
        break;
      case 'MiB':
        bits = value * 8 * 1024 * 1024;
        break;
      case 'GiB':
        bits = value * 8 * 1024 * 1024 * 1024;
        break;
      case 'TiB':
        bits = value * 8 * 1024 * 1024 * 1024 * 1024;
        break;
      default:
        bits = value * 8;
        break;
    }

    // Chuyển từ bits sang đơn vị đích
    switch (to) {
      case 'bit':
        return bits;
      case 'B':
        return bits / 8;
      case 'KB':
        return bits / 8 / 1000;
      case 'MB':
        return bits / 8 / 1000 / 1000;
      case 'GB':
        return bits / 8 / 1000 / 1000 / 1000;
      case 'TB':
        return bits / 8 / 1000 / 1000 / 1000 / 1000;
      case 'KiB':
        return bits / 8 / 1024;
      case 'MiB':
        return bits / 8 / 1024 / 1024;
      case 'GiB':
        return bits / 8 / 1024 / 1024 / 1024;
      case 'TiB':
        return bits / 8 / 1024 / 1024 / 1024 / 1024;
      default:
        return bits / 8;
    }
  }

  /// Chuyển đổi góc
  static double _convertAngle(double value, String from, String to) {
    // Chuyển tất cả về radian trước
    double radians;

    switch (from) {
      case '°':
        radians = value * math.pi / 180;
        break;
      case 'rad':
        radians = value;
        break;
      case 'grad':
        radians = value * math.pi / 200;
        break;
      default:
        radians = value;
        break;
    }

    // Chuyển từ radian sang đơn vị đích
    switch (to) {
      case '°':
        return radians * 180 / math.pi;
      case 'rad':
        return radians;
      case 'grad':
        return radians * 200 / math.pi;
      default:
        return radians;
    }
  }

  /// Thêm chuyển đổi năng lượng với công thức chính xác hơn
  static double _convertEnergy(double value, String from, String to) {
    // Chuyển tất cả về joule trước
    double joules;

    switch (from) {
      case 'J':
        joules = value;
        break;
      case 'kJ':
        joules = value * 1000;
        break;
      case 'cal':
        joules = value * 4.184;
        break;
      case 'kcal':
        joules = value * 4184;
        break;
      case 'Wh':
        joules = value * 3600;
        break;
      case 'kWh':
        joules = value * 3600000;
        break;
      case 'eV':
        joules = value * 1.602176634e-19;
        break;
      case 'BTU':
        joules = value * 1055.06;
        break;
      default:
        joules = value;
        break;
    }

    // Chuyển từ joule sang đơn vị đích
    switch (to) {
      case 'J':
        return joules;
      case 'kJ':
        return joules / 1000;
      case 'cal':
        return joules / 4.184;
      case 'kcal':
        return joules / 4184;
      case 'Wh':
        return joules / 3600;
      case 'kWh':
        return joules / 3600000;
      case 'eV':
        return joules / 1.602176634e-19;
      case 'BTU':
        return joules / 1055.06;
      default:
        return joules;
    }
  }

  /// Thêm chuyển đổi thời gian với xử lý tháng và năm chính xác hơn
  static double _convertTime(double value, String from, String to) {
    // Chuyển tất cả về giây trước
    double seconds;

    switch (from) {
      case 's':
        seconds = value;
        break;
      case 'min':
        seconds = value * 60;
        break;
      case 'h':
        seconds = value * 3600;
        break;
      case 'd':
        seconds = value * 86400;
        break;
      case 'wk':
        seconds = value * 604800;
        break;
      case 'mo':
        seconds = value * 2592000; // 30 ngày
      case 'yr':
        seconds = value * 31536000; // 365 ngày
      default:
        seconds = value;
        break;
    }

    // Chuyển từ giây sang đơn vị đích
    switch (to) {
      case 's':
        return seconds;
      case 'min':
        return seconds / 60;
      case 'h':
        return seconds / 3600;
      case 'd':
        return seconds / 86400;
      case 'wk':
        return seconds / 604800;
      case 'mo':
        return seconds / 2592000; // 30 ngày
      case 'yr':
        return seconds / 31536000; // 365 ngày
      default:
        return seconds;
    }
  }

  /// Thêm phương thức chuyển đổi chuyên dụng cho thể tích để dễ dàng mở rộng
  static double _convertVolume(double value, String from, String to) {
    // Chuyển tất cả về liter trước
    double liters;

    switch (from) {
      case 'L':
        liters = value;
        break;
      case 'mL':
        liters = value * 0.001;
        break;
      case 'm³':
        liters = value * 1000;
        break;
      case 'cm³':
        liters = value * 0.001;
        break;
      case 'gal':
        liters = value * 3.78541;
        break;
      case 'qt':
        liters = value * 0.946353;
        break;
      case 'pt':
        liters = value * 0.473176;
        break;
      case 'fl oz':
        liters = value * 0.0295735;
        break;
      default:
        liters = value;
        break;
    }

    // Chuyển từ liter sang đơn vị đích
    switch (to) {
      case 'L':
        return liters;
      case 'mL':
        return liters * 1000;
      case 'm³':
        return liters * 0.001;
      case 'cm³':
        return liters * 1000;
      case 'gal':
        return liters * 0.264172;
      case 'qt':
        return liters * 1.05669;
      case 'pt':
        return liters * 2.11338;
      case 'fl oz':
        return liters * 33.814;
      default:
        return liters;
    }
  }

  /// Định dạng kết quả một cách phù hợp dựa trên loại đơn vị
  static String formatResult(double value, UnitCategory category) {
    // Xử lý số thập phân khác nhau cho từng category
    int decimals;

    switch (category) {
      case UnitCategory.length:
      case UnitCategory.mass:
      case UnitCategory.volume:
      case UnitCategory.area:
        decimals = 4;
        break;
      case UnitCategory.temperature:
        decimals = 2;
        break;
      case UnitCategory.time:
      case UnitCategory.angle:
        decimals = 3;
        break;
      case UnitCategory.data:
        decimals = 8; // Có thể cần nhiều số thập phân cho chuyển đổi byte nhỏ
        break;
      default:
        decimals = 5;
    }

    // Xử lý đặc biệt cho các số rất lớn hoặc rất nhỏ
    if ((value.abs() >= 1e9 || (value.abs() < 1e-5 && value != 0))) {
      return value.toStringAsExponential(4);
    }

    // Định dạng số với số lượng chữ số thập phân phù hợp
    String formatted = value.toStringAsFixed(decimals);

    // Loại bỏ các số 0 thừa ở cuối
    formatted = formatted.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");

    return formatted;
  }

  /// Tạo chuỗi công thức chuyển đổi
  static String getConversionFormula(
    UnitCategory category,
    UnitItem fromUnit,
    UnitItem toUnit,
  ) {
    // Nếu đơn vị giống nhau
    if (fromUnit.shortName == toUnit.shortName) {
      return "${fromUnit.shortName} = ${toUnit.shortName}";
    }

    // Xử lý các trường hợp đặc biệt
    switch (category) {
      case UnitCategory.temperature:
        return _getTemperatureFormula(fromUnit.shortName, toUnit.shortName);
      case UnitCategory.data:
        return _getDataFormula(fromUnit.shortName, toUnit.shortName);
      case UnitCategory.angle:
        return _getAngleFormula(fromUnit.shortName, toUnit.shortName);
      case UnitCategory.energy:
        return _getEnergyFormula(fromUnit.shortName, toUnit.shortName);
      default:
        // SỬA CÔNG THỨC HIỂN THỊ
        double factor = fromUnit.conversionFactor / toUnit.conversionFactor;
        if (factor == 1) {
          return "${fromUnit.shortName} = ${toUnit.shortName}";
        } else if (factor > 1000 || factor < 0.001) {
          return "${fromUnit.shortName} × ${factor.toStringAsExponential(3)} = ${toUnit.shortName}";
        } else {
          return "${fromUnit.shortName} × ${factor.toStringAsFixed(6).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} = ${toUnit.shortName}";
        }
    }
  }

  /// Công thức chuyển đổi nhiệt độ
  static String _getTemperatureFormula(String from, String to) {
    if (from == '°C' && to == '°F') {
      return "(°C × 9/5) + 32 = °F";
    } else if (from == '°C' && to == 'K') {
      return "°C + 273.15 = K";
    } else if (from == '°F' && to == '°C') {
      return "(°F - 32) × 5/9 = °C";
    } else if (from == '°F' && to == 'K') {
      return "(°F + 459.67) × 5/9 = K";
    } else if (from == 'K' && to == '°C') {
      return "K - 273.15 = °C";
    } else if (from == 'K' && to == '°F') {
      return "(K × 9/5) - 459.67 = °F";
    }

    return "$from = $to";
  }

  /// Công thức chuyển đổi dữ liệu
  static String _getDataFormula(String from, String to) {
    // Xác định các hệ số chuyển đổi
    Map<String, int> bitsMultiplier = {
      'bit': 1,
      'B': 8,
      'KB': 8 * 1000,
      'MB': 8 * 1000 * 1000,
      'GB': 8 * 1000 * 1000 * 1000,
      'TB': 8 * 1000 * 1000 * 1000 * 1000,
      'KiB': 8 * 1024,
      'MiB': 8 * 1024 * 1024,
      'GiB': 8 * 1024 * 1024 * 1024,
      'TiB': 8 * 1024 * 1024 * 1024 * 1024,
    };

    if (from == to) return "$from = $to";

    // Kiểm tra chuyển đổi đặc biệt
    if ((from.contains('i') && !to.contains('i')) ||
        (!from.contains('i') && to.contains('i'))) {
      // Chuyển đổi giữa thập phân và nhị phân
      return "$from ≈ $to (1024 vs 1000)";
    }

    double factor = bitsMultiplier[from]! / bitsMultiplier[to]!;
    if (factor == 1) {
      return "$from = $to";
    } else if (factor > 1000 || factor < 0.001) {
      return "$from × ${factor.toStringAsExponential(3)} = $to";
    } else {
      return "$from × ${factor.toStringAsFixed(5).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} = $to";
    }
  }

  /// Công thức chuyển đổi góc
  static String _getAngleFormula(String from, String to) {
    if (from == '°' && to == 'rad') {
      return "° × π/180 = rad";
    } else if (from == '°' && to == 'grad') {
      return "° × 10/9 = grad";
    } else if (from == 'rad' && to == '°') {
      return "rad × 180/π = °";
    } else if (from == 'rad' && to == 'grad') {
      return "rad × 200/π = grad";
    } else if (from == 'grad' && to == '°') {
      return "grad × 9/10 = °";
    } else if (from == 'grad' && to == 'rad') {
      return "grad × π/200 = rad";
    }

    return "$from = $to";
  }

  /// Công thức chuyển đổi năng lượng
  static String _getEnergyFormula(String from, String to) {
    Map<String, String> energyFormulas = {
      'J→kJ': "J ÷ 1000 = kJ",
      'J→cal': "J ÷ 4.184 = cal",
      'J→kcal': "J ÷ 4184 = kcal",
      'J→Wh': "J ÷ 3600 = Wh",
      'J→kWh': "J ÷ 3600000 = kWh",
      'J→eV': "J ÷ 1.6022e-19 = eV",

      'kJ→J': "kJ × 1000 = J",
      'kJ→cal': "kJ × 239.006 = cal",
      'kJ→kcal': "kJ × 0.239006 = kcal",
      'kJ→Wh': "kJ × 0.277778 = Wh",
      'kJ→kWh': "kJ × 0.000278 = kWh",

      'cal→J': "cal × 4.184 = J",
      'cal→kJ': "cal × 0.004184 = kJ",
      'cal→kcal': "cal × 0.001 = kcal",
      'cal→Wh': "cal × 0.001162 = Wh",

      'kcal→J': "kcal × 4184 = J",
      'kcal→kJ': "kcal × 4.184 = kJ",
      'kcal→cal': "kcal × 1000 = cal",
      'kcal→Wh': "kcal × 1.162 = Wh",
      'kcal→kWh': "kcal × 0.001162 = kWh",

      'Wh→J': "Wh × 3600 = J",
      'Wh→kJ': "Wh × 3.6 = kJ",
      'Wh→cal': "Wh × 860.421 = cal",
      'Wh→kcal': "Wh × 0.860421 = kcal",
      'Wh→kWh': "Wh × 0.001 = kWh",

      'kWh→J': "kWh × 3600000 = J",
      'kWh→kJ': "kWh × 3600 = kJ",
      'kWh→kcal': "kWh × 860.421 = kcal",
      'kWh→Wh': "kWh × 1000 = Wh",
    };

    String key = "$from→$to";
    if (energyFormulas.containsKey(key)) {
      return energyFormulas[key]!;
    }

    // Fallback to standard formula
    return "$from → $to";
  }

  /// Phương thức kiểm tra giá trị có nằm trong phạm vi hợp lệ không
  static bool isValidInput(double value, UnitCategory category, UnitItem unit) {
    // Kiểm tra giới hạn cho nhiệt độ
    if (category == UnitCategory.temperature) {
      if (unit.shortName == 'K' && value < 0) {
        return false; // Không có nhiệt độ Kelvin âm
      }
    }

    return true;
  }

  /// Tạo gợi ý cho giá trị chuyển đổi
  static List<double> getSuggestedValues(
    UnitCategory category,
    UnitItem fromUnit,
  ) {
    switch (category) {
      case UnitCategory.length:
        return [1, 5, 10, 100, 1000];

      case UnitCategory.mass:
        return [1, 10, 100, 500, 1000];

      case UnitCategory.volume:
        return [1, 10, 100, 1000];

      case UnitCategory.area:
        return [1, 10, 100, 1000, 10000];

      case UnitCategory.temperature:
        if (fromUnit.shortName == '°C') {
          return [
            0,
            20,
            37,
            100,
          ]; // Điểm đóng băng, nhiệt độ phòng, nhiệt độ cơ thể, điểm sôi
        } else if (fromUnit.shortName == '°F') {
          return [32, 68, 98.6, 212]; // Tương ứng với các giá trị Celsius
        } else {
          return [
            273.15,
            293.15,
            310.15,
            373.15,
          ]; // Tương ứng với các giá trị Celsius
        }

      case UnitCategory.time:
        return [1, 10, 60, 3600, 86400]; // 1s, 10s, 1min, 1h, 1d

      case UnitCategory.speed:
        return [1, 5, 10, 20, 100];

      case UnitCategory.pressure:
        return [1, 10, 100, 1000, 10000];

      case UnitCategory.energy:
        return [1, 10, 100, 1000, 10000];

      case UnitCategory.power:
        return [1, 10, 100, 1000, 10000];

      case UnitCategory.angle:
        if (fromUnit.shortName == '°') {
          return [45, 90, 180, 360]; // Góc phổ biến
        } else if (fromUnit.shortName == 'rad') {
          return [0.785398, 1.5708, 3.14159, 6.28319]; // π/4, π/2, π, 2π
        } else {
          return [50, 100, 200, 400]; // Tương ứng với độ
        }

      case UnitCategory.data:
        if (fromUnit.shortName.contains('i')) {
          // Đơn vị nhị phân
          return [1, 10, 1024, 1024 * 1024];
        } else {
          return [1, 10, 100, 1000, 1000000]; // Đơn vị thập phân
        }
    }
  }
}
