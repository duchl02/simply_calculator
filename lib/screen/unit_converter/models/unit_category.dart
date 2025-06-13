import 'package:flutter/material.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/screen/unit_converter/models/unit_item.dart';

enum UnitCategory {
  length,
  mass,
  volume,
  area,
  temperature,
  time,
  speed,
  pressure,
  energy,
  power,
  angle,
  data;

  String get displayName {
    switch (this) {
      case UnitCategory.length:
        return t.length;
      case UnitCategory.mass:
        return t.mass;
      case UnitCategory.volume:
        return t.volume;
      case UnitCategory.area:
        return t.area;
      case UnitCategory.temperature:
        return t.temperature;
      case UnitCategory.time:
        return t.time;
      case UnitCategory.speed:
        return t.speed;
      case UnitCategory.pressure:
        return t.pressure;
      case UnitCategory.energy:
        return t.energy;
      case UnitCategory.power:
        return t.power;
      case UnitCategory.angle:
        return t.angle;
      case UnitCategory.data:
        return t.data;
    }
  }

  IconData get icon {
    switch (this) {
      case UnitCategory.length:
        return Icons.straighten;
      case UnitCategory.mass:
        return Icons.fitness_center;
      case UnitCategory.volume:
        return Icons.local_drink;
      case UnitCategory.area:
        return Icons.grid_on;
      case UnitCategory.temperature:
        return Icons.thermostat;
      case UnitCategory.time:
        return Icons.access_time;
      case UnitCategory.speed:
        return Icons.speed;
      case UnitCategory.pressure:
        return Icons.compress;
      case UnitCategory.energy:
        return Icons.bolt;
      case UnitCategory.power:
        return Icons.electric_bolt;
      case UnitCategory.angle:
        return Icons.architecture;
      case UnitCategory.data:
        return Icons.storage;
    }
  }

  List<UnitItem> get units {
    switch (this) {
      case UnitCategory.length:
        return [
          UnitItem(name: t.meter, shortName: 'm', conversionFactor: 1),
          UnitItem(name: t.kilometer, shortName: 'km', conversionFactor: 1000),
          UnitItem(name: t.centimeter, shortName: 'cm', conversionFactor: 0.01),
          UnitItem(
            name: t.millimeter,
            shortName: 'mm',
            conversionFactor: 0.001,
          ),
          UnitItem(
            name: t.mile,
            shortName: t.mile_short,
            conversionFactor: 1609.34,
          ),
          UnitItem(
            name: t.yard,
            shortName: t.yard_short,
            conversionFactor: 0.9144,
          ),
          UnitItem(
            name: t.foot,
            shortName: t.foot_short,
            conversionFactor: 0.3048,
          ),
          UnitItem(
            name: t.inch,
            shortName: t.inch_short,
            conversionFactor: 0.0254,
          ),
        ];
      case UnitCategory.mass:
        return [
          UnitItem(name: t.kilogram, shortName: 'kg', conversionFactor: 1),
          UnitItem(name: t.gram, shortName: 'g', conversionFactor: 1000),
          UnitItem(
            name: t.milligram,
            shortName: 'mg',
            conversionFactor: 1000000,
          ),
          UnitItem(name: t.metric_ton, shortName: 't', conversionFactor: 0.001),
          UnitItem(name: t.pound, shortName: 'lb', conversionFactor: 2.20462),
          UnitItem(name: t.ounce, shortName: 'oz', conversionFactor: 35.274),
        ];
      case UnitCategory.volume:
        return [
          UnitItem(name: t.liter, shortName: 'L', conversionFactor: 1),
          UnitItem(name: t.milliliter, shortName: 'mL', conversionFactor: 0.001),
          UnitItem(name: t.cubic_meter, shortName: 'm³', conversionFactor: 1000),
          UnitItem(name: t.cubic_centimeter, shortName: 'cm³', conversionFactor: 0.001),
          UnitItem(name: t.gallon_us, shortName: 'gal', conversionFactor: 3.78541),
          UnitItem(name: t.quart_us, shortName: 'qt', conversionFactor: 0.946353),
          UnitItem(name: t.pint_us, shortName: 'pt', conversionFactor: 0.473176),
          UnitItem(name: t.fluid_ounce_us, shortName: 'fl oz', conversionFactor: 0.0295735),
        ];
      case UnitCategory.area:
        return [
          UnitItem(name: t.square_meter, shortName: 'm²', conversionFactor: 1),
          UnitItem(
            name: t.square_kilometer,
            shortName: 'km²',
            conversionFactor: 0.000001,
          ),
          UnitItem(
            name: t.square_centimeter,
            shortName: 'cm²',
            conversionFactor: 10000,
          ),
          UnitItem(name: t.hectare, shortName: 'ha', conversionFactor: 0.0001),
          UnitItem(
            name: t.acre,
            shortName: 'ac',
            conversionFactor: 0.000247105,
          ),
          UnitItem(
            name: t.square_mile,
            shortName: 'mi²',
            conversionFactor: 3.861e-7,
          ),
          UnitItem(
            name: t.square_foot,
            shortName: 'ft²',
            conversionFactor: 10.7639,
          ),
          UnitItem(
            name: t.square_inch,
            shortName: 'in²',
            conversionFactor: 1550,
          ),
        ];
      case UnitCategory.temperature:
        return [
          UnitItem(
            name: t.celsius,
            shortName: '°C',
            conversionFactor: 1,
            isTemperature: true,
          ),
          UnitItem(
            name: t.fahrenheit,
            shortName: '°F',
            conversionFactor: 33.8,
            isTemperature: true,
          ),
          UnitItem(
            name: t.kelvin,
            shortName: 'K',
            conversionFactor: 274.15,
            isTemperature: true,
          ),
        ];
      case UnitCategory.time:
        return [
          UnitItem(name: t.second, shortName: 's', conversionFactor: 1),
          UnitItem(name: t.minute, shortName: 'min', conversionFactor: 1 / 60),
          UnitItem(name: t.hour, shortName: 'h', conversionFactor: 1 / 3600),
          UnitItem(name: t.day, shortName: 'd', conversionFactor: 1 / 86400),
          UnitItem(name: t.week, shortName: 'wk', conversionFactor: 1 / 604800),
          UnitItem(
            name: t.month_30,
            shortName: 'mo',
            conversionFactor: 1 / 2592000,
          ),
          UnitItem(
            name: t.year_365,
            shortName: 'yr',
            conversionFactor: 1 / 31536000,
          ),
        ];
      case UnitCategory.speed:
        return [
          UnitItem(
            name: t.meters_per_second,
            shortName: 'm/s',
            conversionFactor: 1,
          ),
          UnitItem(
            name: t.kilometers_per_hour,
            shortName: 'km/h',
            conversionFactor: 3.6,
          ),
          UnitItem(
            name: t.miles_per_hour,
            shortName: 'mph',
            conversionFactor: 2.23694,
          ),
          UnitItem(
            name: t.feet_per_second,
            shortName: 'ft/s',
            conversionFactor: 3.28084,
          ),
          UnitItem(name: t.knot, shortName: 'kn', conversionFactor: 1.94384),
        ];
      case UnitCategory.pressure:
        return [
          UnitItem(name: t.pascal, shortName: 'Pa', conversionFactor: 1),
          UnitItem(
            name: t.kilopascal,
            shortName: 'kPa',
            conversionFactor: 0.001,
          ),
          UnitItem(name: t.bar, shortName: 'bar', conversionFactor: 0.00001),
          UnitItem(
            name: t.psi,
            shortName: 'psi',
            conversionFactor: 0.000145038,
          ),
          UnitItem(
            name: t.atmosphere,
            shortName: 'atm',
            conversionFactor: 9.86923e-6,
          ),
          UnitItem(
            name: t.torr,
            shortName: 'Torr',
            conversionFactor: 0.00750062,
          ),
        ];
      case UnitCategory.energy:
        return [
          UnitItem(name: t.joule, shortName: 'J', conversionFactor: 1),
          UnitItem(name: t.kilojoule, shortName: 'kJ', conversionFactor: 0.001),
          UnitItem(
            name: t.calorie,
            shortName: 'cal',
            conversionFactor: 0.239006,
          ),
          UnitItem(
            name: t.kilocalorie,
            shortName: 'kcal',
            conversionFactor: 0.000239006,
          ),
          UnitItem(
            name: t.watt_hour,
            shortName: 'Wh',
            conversionFactor: 0.000277778,
          ),
          UnitItem(
            name: t.kilowatt_hour,
            shortName: 'kWh',
            conversionFactor: 2.77778e-7,
          ),
          UnitItem(
            name: t.electron_volt,
            shortName: 'eV',
            conversionFactor: 6.242e+18,
          ),
        ];
      case UnitCategory.power:
        return [
          UnitItem(name: t.watt, shortName: 'W', conversionFactor: 1),
          UnitItem(name: t.kilowatt, shortName: 'kW', conversionFactor: 0.001),
          UnitItem(
            name: t.megawatt,
            shortName: 'MW',
            conversionFactor: 0.000001,
          ),
          UnitItem(
            name: t.horsepower,
            shortName: 'hp',
            conversionFactor: 0.00134102,
          ),
          UnitItem(
            name: t.btu_per_hour,
            shortName: 'BTU/h',
            conversionFactor: 3.41214,
          ),
        ];
      case UnitCategory.angle:
        return [
          UnitItem(name: t.degree, shortName: '°', conversionFactor: 1),
          UnitItem(
            name: t.radian,
            shortName: 'rad',
            conversionFactor: 0.0174533,
          ),
          UnitItem(
            name: t.gradian,
            shortName: 'grad',
            conversionFactor: 1.11111,
          ),
        ];
      case UnitCategory.data:
        return [
          UnitItem(name: t.byte, shortName: 'B', conversionFactor: 1),
          UnitItem(name: t.kilobyte, shortName: 'KB', conversionFactor: 0.001),
          UnitItem(
            name: t.megabyte,
            shortName: 'MB',
            conversionFactor: 0.000001,
          ),
          UnitItem(name: t.gigabyte, shortName: 'GB', conversionFactor: 1e-9),
          UnitItem(name: t.terabyte, shortName: 'TB', conversionFactor: 1e-12),
          UnitItem(name: t.bit, shortName: 'bit', conversionFactor: 8),
          UnitItem(
            name: t.kibibyte,
            shortName: 'KiB',
            conversionFactor: 0.0009765625,
          ),
          UnitItem(
            name: t.mebibyte,
            shortName: 'MiB',
            conversionFactor: 9.5367e-7,
          ),
          UnitItem(
            name: t.gibibyte,
            shortName: 'GiB',
            conversionFactor: 9.3132e-10,
          ),
          UnitItem(
            name: t.tebibyte,
            shortName: 'TiB',
            conversionFactor: 9.0949e-13,
          ),
        ];
    }
  }
}
