import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/data/providers/notification_repository_provider.dart';

class AdminNotificationsPage extends ConsumerStatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  ConsumerState<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends ConsumerState<AdminNotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();
  String _selectedTarget = 'all';
  String _selectedAction = 'home';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة التنبيهات والإشعارات' : 'Marketing & System Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.send_outlined),
              text: isAr ? 'إرسال إشعار' : 'Broadcast Dispatcher',
            ),
            Tab(
              icon: const Icon(Icons.history_outlined),
              text: isAr ? 'سجل الإشعارات المرسلة' : 'Sent Logs & Analytics',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendTab(),
          _buildLogsTab(),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    final isAr = context.isRtl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tips Box
            _buildBroadcastTipsCard(),
            const SizedBox(height: 16),

            // Form Layout
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'إنشاء إشعار جماعي جديد' : 'Compose Push Notification',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),

                    // English Translation Fields
                    Text(
                      isAr ? 'المحتوى بالإنجليزي (English Content)' : 'English Content',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleEnController,
                      decoration: const InputDecoration(
                        labelText: 'Notification Title (EN)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bodyEnController,
                      decoration: const InputDecoration(
                        labelText: 'Notification Body / Message (EN)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Arabic Translation Fields
                    Text(
                      isAr ? 'المحتوى بالعربي' : 'Arabic Content',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleArController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الإشعار (AR)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bodyArController,
                      decoration: const InputDecoration(
                        labelText: 'نص الرسالة المرسلة (AR)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Target & Action Parameters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTarget,
                            decoration: InputDecoration(
                              labelText: isAr ? 'الفئة المستهدفة' : 'Target Audience',
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(value: 'all', child: Text(isAr ? 'جميع المستخدمين' : 'All Users')),
                              DropdownMenuItem(value: 'active', child: Text(isAr ? 'النشطين آخر ٣٠ يوم' : 'Active last 30 days')),
                              DropdownMenuItem(value: 'cart-abandoned', child: Text(isAr ? 'سلال متروكة' : 'Abandoned Cart')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTarget = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedAction,
                            decoration: InputDecoration(
                              labelText: isAr ? 'إجراء الضغط' : 'On-Tap Action',
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(value: 'home', child: Text(isAr ? 'فتح الرئيسية' : 'Open Home')),
                              DropdownMenuItem(value: 'offers', child: Text(isAr ? 'فتح العروض' : 'Open Offers')),
                              DropdownMenuItem(value: 'cart', child: Text(isAr ? 'السلة' : 'Open Cart')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedAction = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isSending ? null : _handleSendNotification,
                        icon: _isSending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Text(_isSending 
                            ? (isAr ? 'جاري الإرسال...' : 'Sending...') 
                            : (isAr ? 'إرسال الإشعار الجماعي الآن' : 'Broadcast Notification Now')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastTipsCard() {
    final isAr = context.isRtl;
    return Card(
      color: context.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'نصيحة التسويق عبر الإشعارات' : 'Push Notification Tip',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr
                        ? 'أرسل عروضاً مخصصة في أوقات الذروة (مثل الساعة ٤-٦ مساءً) لزيادة المبيعات بنسبة تصل إلى ٢٥٪. تجنب الإفراط في الإشعارات للحفاظ على رضا عملائك.'
                        : 'Send targeted campaign alerts during peak evening hours (4:00 PM - 6:00 PM) to boost checkout conversions by up to 25%. Maintain high relevance to avoid opt-outs.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTab() {
    final isAr = context.isRtl;

    final mockLogs = [
      _NotificationLog('Title: Weekend Super Discount!', 'عنوان: خصومات نهاية الأسبوع الكبرى!', 'All Users', '1,450 sent', '22% CTR', 'Sent 2 hours ago', Colors.green),
      _NotificationLog('Title: Your cart misses you!', 'عنوان: سلتك تفتقد وجودك!', 'Abandoned Carts', '320 sent', '45% CTR', 'Sent 1 day ago', Colors.green),
      _NotificationLog('Title: New organic apples arrived!', 'عنوان: وصول تفاح عضوي طازج!', 'All Users', '1,420 sent', '15% CTR', 'Sent 3 days ago', Colors.green),
      _NotificationLog('Title: Order #4890 is out for delivery', 'عنوان: طلبك رقم 4890 في الطريق إليك', 'User ID: #903', '1 sent', '98% CTR', 'Sent 4 days ago', Colors.blue),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mockLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = mockLogs[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? log.titleAr : log.titleEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAr ? 'مكتمل' : 'Completed',
                        style: TextStyle(color: log.statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${isAr ? 'الجمهور المستهدف:' : 'Audience:'} ${log.target}  •  ${log.stats}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.sentTime,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${isAr ? 'نسبة النقر:' : 'CTR:'} ${log.ctr}',
                      style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final titleEn = _titleEnController.text.trim();
      final titleAr = _titleArController.text.trim();
      final bodyEn = _bodyEnController.text.trim();
      final bodyAr = _bodyArController.text.trim();

      final repository = ref.read(notificationRepositoryProvider);
      await repository.createNotification(
        NotificationEntity(
          id: '',
          userId: _selectedTarget == 'all' ? 'all' : 'segment_${_selectedTarget}',
          title: titleEn,
          body: bodyEn,
          type: NotificationType.system,
          createdAt: DateTime.now(),
          data: {
            'titleAr': titleAr,
            'titleEn': titleEn,
            'bodyAr': bodyAr,
            'bodyEn': bodyEn,
            'action': _selectedAction,
          },
        ),
      );

      if (mounted) {
        _titleEnController.clear();
        _titleArController.clear();
        _bodyEnController.clear();
        _bodyArController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isRtl
                  ? 'تم إرسال وجدولة التنبيه بنجاح!'
                  : 'Broadcast notification dispatched successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}

class _NotificationLog {
  final String titleEn;
  final String titleAr;
  final String target;
  final String stats;
  final String ctr;
  final String sentTime;
  final Color statusColor;

  _NotificationLog(this.titleEn, this.titleAr, this.target, this.stats, this.ctr, this.sentTime, this.statusColor);
}
