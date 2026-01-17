import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../../core/app_localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = Provider.of<LocalizationProvider>(context).current;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.translate('preferences'), style: Theme.of(context).textTheme.titleMedium), // Make sure to add preferences key to localization
        const SizedBox(height: 16),
        
        // Language Selection
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(loc.translate('language')),
                leading: const Icon(Icons.language),
              ),
              const Divider(height: 1),
              _buildLanguageOption(context, AppLanguage.english, "English", "🇺🇸"),
              _buildLanguageOption(context, AppLanguage.tamil, "Tamil", "🇱🇰"),
              _buildLanguageOption(context, AppLanguage.sinhala, "Sinhala", "🇱🇰"),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        Consumer<DebtorViewModel>(
          builder: (context, viewModel, child) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Overdue Threshold (Days)", style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: viewModel.longPendingDaysThreshold.toDouble(),
                            min: 15,
                            max: 90,
                            divisions: 5,
                            label: viewModel.longPendingDaysThreshold.toString(),
                            onChanged: (val) {
                              viewModel.setThreshold(val.toInt());
                            },
                          ),
                        ),
                        Text(
                          "${viewModel.longPendingDaysThreshold} days", 
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    Text(
                      "Debtors exceeding this duration will be marked red.", 
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        
        Consumer<ThemeViewModel>(
          builder: (context, themeVM, _) {
            return Card(
              child: SwitchListTile(
                title: Text(themeVM.isDarkMode ? loc.translate('dark') : loc.translate('light')),
                subtitle: const Text("Theme Mode"),
                value: themeVM.isDarkMode,
                onChanged: (val) => themeVM.toggleTheme(),
                secondary: Icon(themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              ),
            ); 
          }
        ),

        const SizedBox(height: 32),
        Text("About", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.verified),
            title: Text("Naya Potha"),
            subtitle: Text("Version 1.0.0"),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLanguageOption(BuildContext context, AppLanguage lang, String name, String flag) {
    final provider = Provider.of<LocalizationProvider>(context);
    final isSelected = provider.language == lang;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      onTap: () {
        provider.setLanguage(lang);
      },
    );
  }
}
