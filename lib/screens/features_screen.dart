import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../theme/theme_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/card_repository.dart';
import '../repositories/transaction_repository.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  bool _isLoading = false;

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final cardRepo = context.read<CardRepository>();
      final txRepo = context.read<TransactionRepository>();

      final userId = auth.currentUserId;
      final data = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'cards': cardRepo.exportForUser(userId),
        'transactions': txRepo.exportForUser(userId),
      };

      final jsonStr = jsonEncode(data);
      
      ShareResult result;
      if (kIsWeb) {
        final bytes = utf8.encode(jsonStr);
        final xfile = XFile.fromData(
          Uint8List.fromList(bytes),
          mimeType: 'application/json',
          name: 'spendsync_export.json',
        );
        result = await Share.shareXFiles(
          [xfile],
          subject: 'SpendSync Database Export',
        );
      } else {
        // Save temporarily and share on mobile
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/spendsync_export.json');
        await file.writeAsString(jsonStr);
        result = await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'SpendSync Database Export',
        );
      }
      
      if (!mounted) return;
      
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export successful!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        final path = result.files.first.path;
        
        String jsonStr;
        if (bytes != null) {
          jsonStr = utf8.decode(bytes);
        } else if (path != null) {
          final file = File(path);
          jsonStr = await file.readAsString();
        } else {
          throw Exception('Could not read file contents');
        }

        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        final cardRepo = context.read<CardRepository>();
        final txRepo = context.read<TransactionRepository>();
        final userId = auth.currentUserId;

        if (data.containsKey('cards')) {
          await cardRepo.importForUser(userId, data['cards'] as List);
        }
        if (data.containsKey('transactions')) {
          await txRepo.importForUser(userId, data['transactions'] as List);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed or invalid file format'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Features',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your data and account settings.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),

        // Profile Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Text(
                    user?.username.isNotEmpty == true 
                        ? user!.username[0].toUpperCase() 
                        : 'U',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Logged in',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Data Management',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          // Theme Toggle
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: context.read<ThemeProvider>().toggleTheme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        context.watch<ThemeProvider>().isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'App Theme',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.watch<ThemeProvider>().isDark
                                ? 'Dark Mode'
                                : 'Light Mode',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: context.watch<ThemeProvider>().isDark,
                      onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Export Database Config
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _exportData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.upload_file_rounded, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Export Database',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Share or save a JSON backup of your cards and expenses',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Import Database Config
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _importData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.download_rounded, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Import Database',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Restore your data from a previously exported JSON file',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
