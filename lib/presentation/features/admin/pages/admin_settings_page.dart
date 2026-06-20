import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../providers/admin_settings_provider.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  late final TextEditingController _storeNameController;
  late final TextEditingController _currencyCodeController;
  late final TextEditingController _currencySymbolController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _currencyCodeController = TextEditingController();
    _currencySymbolController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _currencyCodeController.dispose();
    _currencySymbolController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _syncControllers(AdminSettingsState state) {
    if (!_controllersInitialized && state.loadState == RequestState.success) {
      _storeNameController.text = state.storeName;
      _currencyCodeController.text = state.currencyCode;
      _currencySymbolController.text = state.currencySymbol;
      _phoneController.text = state.phone;
      _whatsappController.text = state.whatsapp;
      _facebookController.text = state.facebook;
      _instagramController.text = state.instagram;
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSettingsProvider);
    _syncControllers(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        actions: [
          if (state.loadState == RequestState.success)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: state.saveState == RequestState.loading ? null : _saveSettings,
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AdminSettingsState state) {
    if (state.loadState == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.loadState == RequestState.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? context.l10n.errorGeneral),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(adminSettingsProvider.notifier).loadSettings(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    const gap = SizedBox(height: 16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Store Info ──────────────────────────────────────────
          _SectionCard(
            title: context.l10n.appSettings,
            children: [
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.storeName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.store_outlined),
                ),
                onChanged: ref.read(adminSettingsProvider.notifier).setStoreName,
              ),
            ],
          ),
          gap,

          // ── Currency ────────────────────────────────────────────
          _SectionCard(
            title: context.l10n.currency,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currencyCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Currency Code',
                        hintText: 'EGP',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ref.read(adminSettingsProvider.notifier).setCurrencyCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _currencySymbolController,
                      decoration: const InputDecoration(
                        labelText: 'Currency Symbol',
                        hintText: 'E£',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ref.read(adminSettingsProvider.notifier).setCurrencySymbol,
                    ),
                  ),
                ],
              ),
            ],
          ),
          gap,

          // ── Contact Info ────────────────────────────────────────
          _SectionCard(
            title: context.l10n.contactInfo,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.l10n.contactPhone,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                onChanged: ref.read(adminSettingsProvider.notifier).setPhone,
              ),
              gap,
              TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.l10n.contactWhatsApp,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.chat_outlined),
                ),
                onChanged: ref.read(adminSettingsProvider.notifier).setWhatsapp,
              ),
              gap,
              TextField(
                controller: _facebookController,
                decoration: const InputDecoration(
                  labelText: 'Facebook URL / رابط فيسبوك',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.facebook),
                ),
                onChanged: ref.read(adminSettingsProvider.notifier).setFacebook,
              ),
              gap,
              TextField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram URL / رابط إنستغرام',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.camera_alt_outlined),
                ),
                onChanged: ref.read(adminSettingsProvider.notifier).setInstagram,
              ),
            ],
          ),
          gap,

          // ── Maintenance Mode ────────────────────────────────────
          Card(
            child: SwitchListTile(
              title: Text(context.l10n.maintenanceMode),
              subtitle: Text(context.l10n.maintenanceMessage),
              value: state.maintenanceMode,
              onChanged: ref.read(adminSettingsProvider.notifier).setMaintenanceMode,
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: state.saveState == RequestState.loading ? null : _saveSettings,
            icon: state.saveState == RequestState.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(context.l10n.save),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final error = await ref.read(adminSettingsProvider.notifier).save();
    if (mounted) {
      if (error != null) {
        context.showSnackBar(error, isError: true);
      } else {
        context.showSnackBar(context.l10n.settingsSaved);
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
