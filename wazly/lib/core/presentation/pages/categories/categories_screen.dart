import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_event.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_state.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/utils/app_icons.dart';
import 'package:wazly/core/presentation/pages/categories/add_category_screen.dart';
import 'package:wazly/l10n/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentType = 1; // 0 = income, 1 = expense (starts on expense tab)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentType = _tabController.index == 0 ? 1 : 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          AppLocalizations.of(context)!.categoriesTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.expenseTab),
                Tab(text: AppLocalizations.of(context)!.incomeTab),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                FluentIcons.add_24_regular,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCategoryScreen(type: _currentType),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(type: 1), // Expense
          _CategoryList(type: 0), // Income
        ],
      ),
    );
  }
}

class _CategoryList extends StatefulWidget {
  final int type;

  _CategoryList({required this.type});

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(LoadCategoriesEvent(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    context.read<CategoriesBloc>().add(LoadCategoriesEvent(widget.type));

    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
          );
        }

        if (state is CategoriesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.error_circle_24_regular, size: 48, color: Colors.red.shade300),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.failedToLoadCategories,
                  style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          if (state.type != widget.type) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
            );
          }

          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentIcons.grid_24_regular,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noCategoriesYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.tapToAddCategory,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final IconData icon = AppIcons.getIcon(int.parse(category.iconCode, radix: 16));
              final Color color = Color(category.colorValue);

              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: Row(
                  children: [
                    // Colored icon circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    SizedBox(width: 14),
                    // Name
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // System badge or delete
                    if (category.isSystem)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.systemBadge,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          FluentIcons.delete_24_regular,
                          color: Colors.red.shade300,
                          size: 20,
                        ),
                        onPressed: () {
                          context.read<CategoriesBloc>().add(
                            DeleteCategoryEvent(category.id),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
