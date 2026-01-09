import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/debtor_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Preferences", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        
        Consumer<DebtorViewModel>(
          builder: (context, viewModel, child) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Long Pending Warning (Days)", style: Theme.of(context).textTheme.bodyLarge),
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

        const SizedBox(height: 24),
        
        Consumer<ThemeViewModel>(
          builder: (context, themeVM, _) {
            return SwitchListTile(
              title: const Text("Dark Mode"),
              value: themeVM.isDarkMode,
              onChanged: (val) => themeVM.toggleTheme(),
              secondary: Icon(themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ); 
          }
        ),

        const SizedBox(height: 24),
        Text("About", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Simple Store POS"),
            subtitle: Text("Version 1.0.0"),
          ),
        ),
      ],
    );
  }
}
