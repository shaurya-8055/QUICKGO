/// Consistent Spacing System for Premium UI
/// Based on 8px grid system used by top design systems
class AppSpacing {
  // Base unit - 8px
  static const double _baseUnit = 8.0;

  // Micro spacing (2px increments for fine-tuning)
  static const double micro2 = 2.0;
  static const double micro4 = 4.0;
  static const double micro6 = 6.0;

  // Standard spacing (8px increments)
  static const double xs = _baseUnit * 0.5; // 4px
  static const double sm = _baseUnit * 1; // 8px
  static const double md = _baseUnit * 2; // 16px
  static const double lg = _baseUnit * 3; // 24px
  static const double xl = _baseUnit * 4; // 32px
  static const double xxl = _baseUnit * 5; // 40px
  static const double xxxl = _baseUnit * 6; // 48px

  // Component specific spacing
  static const double cardPadding = md; // 16px
  static const double screenPadding = lg; // 24px
  static const double sectionSpacing = xl; // 32px
  static const double buttonPadding = md; // 16px
  static const double listItemSpacing = sm; // 8px

  // Vertical spacing
  static const double verticalTiny = xs; // 4px
  static const double verticalSmall = sm; // 8px
  static const double verticalMedium = md; // 16px
  static const double verticalLarge = lg; // 24px
  static const double verticalXLarge = xl; // 32px

  // Horizontal spacing
  static const double horizontalTiny = xs; // 4px
  static const double horizontalSmall = sm; // 8px
  static const double horizontalMedium = md; // 16px
  static const double horizontalLarge = lg; // 24px
  static const double horizontalXLarge = xl; // 32px

  // Icon spacing
  static const double iconTextSpacing = sm; // 8px
  static const double iconButtonSpacing = md; // 16px

  // Product card specific
  static const double productCardPadding = md; // 16px
  static const double productImageSpacing = sm; // 8px
  static const double productContentSpacing = sm; // 8px

  // Forms and inputs
  static const double inputPadding = md; // 16px
  static const double inputSpacing = md; // 16px
  static const double formSectionSpacing = lg; // 24px
}
