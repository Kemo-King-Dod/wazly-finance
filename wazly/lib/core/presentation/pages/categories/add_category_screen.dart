import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_event.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/utils/app_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:wazly/l10n/app_localizations.dart';

class AddCategoryScreen extends StatefulWidget {
  final int type; // 0 for income, 1 for expense

  AddCategoryScreen({super.key, required this.type});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _selectedIconCode = AppIcons.availableCodes.first;
  int _selectedColorValue = 0xFF2196F3;

  final List<String> _availableIconCodes = AppIcons.availableCodes;

  final List<int> _availableColorValues = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
    0xFFE91E63, // Pink
    0xFFFFEB3B, // Yellow
    0xFFF44336, // Red
    0xFF009688, // Teal
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
    0xFF00BCD4, // Cyan
    0xFF3F51B5, // Indigo
  ];

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = CategoryEntity(
        id: Uuid().v4(),
        name: _nameController.text.trim(),
        iconCode: _selectedIconCode,
        colorValue: _selectedColorValue,
        type: widget.type,
        isSystem: false,
      );

      context.read<CategoriesBloc>().add(AddCategoryEvent(category));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type == 0 ? 'New Income Category' : 'New Expense Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saveCategory,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Preview Card ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Color(_selectedColorValue).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        AppIcons.getIcon(int.parse(_selectedIconCode, radix: 16)),
                        color: Color(_selectedColorValue),
                        size: 36,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _nameController.text.isEmpty ? 'Category Name' : _nameController.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _nameController.text.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // --- Name Input ---
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}), // Update preview
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.exampleCategory,
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 28),

              // --- Icon Picker Section ---
              Text(
                'Icon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _availableIconCodes.length,
                  itemBuilder: (context, index) {
                    final code = _availableIconCodes[index];
                    final isSelected = _selectedIconCode == code;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconCode = code),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                              : AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Icon(
                          AppIcons.getIcon(int.parse(code, radix: 16)),
                          color: isSelected ? Theme.of(context).primaryColor : AppTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 28),

              // --- Color Picker Section ---
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemCount: _availableColorValues.length,
                  itemBuilder: (context, index) {
                    final colorValue = _availableColorValues[index];
                    final color = Color(colorValue);
                    final isSelected = _selectedColorValue == colorValue;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorValue = colorValue),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppTheme.textPrimary, width: 3)
                              : Border.all(color: Colors.transparent, width: 3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(FluentIcons.checkmark_24_regular, color: Colors.white, size: 22)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
