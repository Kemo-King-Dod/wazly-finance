import 'package:flutter/widgets.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class AppIcons {
  static const List<IconData> available = [
    FluentIcons.money_24_regular,
    FluentIcons.cart_24_regular,
    FluentIcons.food_24_regular,
    FluentIcons.vehicle_car_24_regular,
    FluentIcons.building_24_regular,
    FluentIcons.briefcase_24_regular,
    FluentIcons.home_24_regular,
    FluentIcons.hat_graduation_24_regular,
    FluentIcons.payment_24_regular,
    FluentIcons.building_bank_24_regular,
    FluentIcons.store_microsoft_24_regular,
    FluentIcons.receipt_24_regular,
    FluentIcons.savings_24_regular,
    FluentIcons.gift_24_regular,
    FluentIcons.animal_dog_24_regular,
    FluentIcons.dumbbell_24_regular,
    FluentIcons.airplane_24_regular,
    FluentIcons.movies_and_tv_24_regular,
    FluentIcons.music_note_1_24_regular,
    FluentIcons.wrench_24_regular,
    FluentIcons.gas_pump_24_regular,
    FluentIcons.phone_24_regular,
    FluentIcons.shopping_bag_24_regular,
    FluentIcons.drink_coffee_24_regular,
    FluentIcons.lightbulb_24_regular,
    FluentIcons.food_pizza_24_regular,
    FluentIcons.sport_24_regular,
    FluentIcons.settings_24_regular,
    FluentIcons.grid_24_regular,
    FluentIcons.tag_24_regular,
  ];

  static final Map<int, IconData> _legacyMaterialMap = {
    0xE227: FluentIcons.money_24_regular,
    0xE8F9: FluentIcons.briefcase_24_regular,
    0xEA60: FluentIcons.food_24_regular,
    0xE531: FluentIcons.vehicle_car_24_regular,
    0xE8CB: FluentIcons.cart_24_regular,
    0xE02A: FluentIcons.lightbulb_24_regular,
    0xE43A: FluentIcons.gas_pump_24_regular,
    0xE53F: FluentIcons.building_24_regular,
    0xE54F: FluentIcons.movies_and_tv_24_regular,
    0xE558: FluentIcons.food_pizza_24_regular,
    0xE56C: FluentIcons.airplane_24_regular,
    0xEB3E: FluentIcons.home_24_regular,
    0xE8F8: FluentIcons.briefcase_24_regular,
    0xE332: FluentIcons.shopping_bag_24_regular,
    0xE8D1: FluentIcons.store_microsoft_24_regular,
    0xE60A: FluentIcons.animal_dog_24_regular,
    0xE80C: FluentIcons.hat_graduation_24_regular,
    0xE8B8: FluentIcons.settings_24_regular,
    0xe113: FluentIcons.grid_24_regular,
    0xe22a: FluentIcons.cart_24_regular,
    0xe532: FluentIcons.food_24_regular,
    0xe154: FluentIcons.vehicle_car_24_regular,
    0xe3d4: FluentIcons.building_24_regular,
    0xe24a: FluentIcons.briefcase_24_regular,
    0xe2bb: FluentIcons.home_24_regular,
    0xe571: FluentIcons.hat_graduation_24_regular,
    0xe0b0: FluentIcons.payment_24_regular,
    0xe3a1: FluentIcons.store_microsoft_24_regular,
    0xe415: FluentIcons.receipt_24_regular,
    0xe2cb: FluentIcons.savings_24_regular,
    0xe2c7: FluentIcons.money_24_regular,
    0xe19a: FluentIcons.gift_24_regular,
    0xe040: FluentIcons.animal_dog_24_regular,
    0xe1eb: FluentIcons.dumbbell_24_regular,
    0xe52f: FluentIcons.airplane_24_regular,
    0xe52d: FluentIcons.movies_and_tv_24_regular,
    0xe3e3: FluentIcons.music_note_1_24_regular,
    0xe14c: FluentIcons.wrench_24_regular,
    0xe556: FluentIcons.gas_pump_24_regular,
    0xe3f1: FluentIcons.phone_24_regular,
    0xe54d: FluentIcons.cart_24_regular,
    0xe533: FluentIcons.drink_coffee_24_regular,
  };

  static late final Map<int, IconData> _fluentCodePointMap = {
    for (final icon in available) icon.codePoint: icon,
  };

  static IconData getIcon(int codePoint) {
    return _fluentCodePointMap[codePoint] ??
        _legacyMaterialMap[codePoint] ??
        FluentIcons.grid_24_regular;
  }

  static List<String> get availableCodes =>
      available.map((i) => i.codePoint.toRadixString(16).toUpperCase()).toList();
}
