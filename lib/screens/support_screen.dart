import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final faqItems = [
      {
        'q': 'Is my data stored on a server?',
        'a': 'No, SpendSync is a fully offline application. All your data (expenses, cards, and user credentials) is securely stored directly on your device using Hive database. We do not have servers and do not collect your financial data.'
      },
      {
        'q': 'How does the Application Fee Waiver work?',
        'a': 'When you add a credit card, you specify the annual fee, waiver target, and the card cycle dates. Expenses made on that card during the cycle count towards your target. The progress bar in the Fee Waivers tab updates automatically as you log expenses.'
      },
      {
        'q': 'Can I transfer my data to a new phone?',
        'a': 'Yes! Go to the Features tab and tap "Export Database". Save the JSON file. On your new phone, create an account, go to Features -> "Import Database", and select that file to restore all your cards and transactions.'
      },
      {
        'q': 'What happens if I forget my password?',
        'a': 'Because SpendSync is completely offline and does not collect your email address, there is no automatic password reset feature. Please keep your password safe! If you lose it, you will lose access to the local data scope on this device.'
      },
      {
        'q': 'How are my passwords secured?',
        'a': 'Your password is never stored in plain text. It is cryptographically hashed using SHA-256 before being saved to the local database, ensuring that even if someone accesses the local device storage, your password remains secure.'
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Support & FAQ',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Get help and answers to common questions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),

        // Contact Card
        Card(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Need direct help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'If you encountered a bug or have a feature request, please reach out to our team.',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'support@spendsync.app', // Placeholder email
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        // FAQ Items
        ...faqItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: Text(
                item['q']!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              collapsedIconColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              children: [
                Text(
                  item['a']!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        )),

        const SizedBox(height: 20),
        Center(
          child: Text(
            'SpendSync v1.0.0',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
