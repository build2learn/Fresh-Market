import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';

class AdminAIAssistantPage extends ConsumerStatefulWidget {
  const AdminAIAssistantPage({super.key});

  @override
  ConsumerState<AdminAIAssistantPage> createState() => _AdminAIAssistantPageState();
}

class _AdminAIAssistantPageState extends ConsumerState<AdminAIAssistantPage> {
  final List<_ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add default greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAr = context.isRtl;
      _messages.add(_ChatMessage(
        textEn: "Hello! I am your Fresh Market Copilot. I can help you analyze stock levels, view financial logs, audit driver cash drawer reconciliations, or predict category demands. What should we look into today?",
        textAr: "مرحباً! أنا مساعدك الذكي في Fresh Market. يمكنني مساعدتك في تحليل مستويات المخزون، مراجعة السجلات المالية، تدقيق تسويات السائقين، أو توقع حجم الطلب على الفئات. ما الذي نتحقق منه اليوم؟",
        isAi: true,
        timestamp: DateTime.now(),
      ));
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(isAr ? 'المساعد الذكي (AI Copilot)' : 'AI Management Assistant'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colorScheme.surface,
              context.colorScheme.surfaceVariant.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          children: [
            // Chat history
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg);
                },
              ),
            ),

            if (_isTyping) _buildTypingIndicator(),

            // Suggestions List
            if (_messages.length == 1 && !_isTyping) _buildSuggestions(),

            // Chat input row
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isAr = context.isRtl;
    final text = isAr ? msg.textAr : msg.textEn;

    return Align(
      alignment: msg.isAi 
          ? (isAr ? Alignment.centerRight : Alignment.centerLeft)
          : (isAr ? Alignment.centerLeft : Alignment.centerRight),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: msg.isAi 
              ? context.colorScheme.surfaceContainerHighest.withOpacity(0.8)
              : context.colorScheme.primary,
          border: msg.isAi 
              ? Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.5))
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isAi ? Radius.zero : const Radius.circular(16),
            bottomRight: msg.isAi ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: msg.isAi ? context.colorScheme.onSurface : context.colorScheme.onPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            if (msg.widgetExtra != null) ...[
              const SizedBox(height: 12),
              msg.widgetExtra!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isAr = context.isRtl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              isAr ? 'المساعد يفكر ويكتب...' : 'Copilot is analyzing data...',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final isAr = context.isRtl;
    final suggestions = [
      _SuggestionItem(
        labelEn: "📊 Low Stock Warning Audit",
        labelAr: "📊 مراجعة إنذارات المنتجات منخفضة المخزون",
        onTap: () => _triggerSuggestion(
          "Generate low stock analysis",
          "تحليل المنتجات منخفضة المخزون",
          _getLowStockReplyEn(),
          _getLowStockReplyAr(),
          widgetExtra: _buildLowStockMockTable(),
        ),
      ),
      _SuggestionItem(
        labelEn: "💰 Driver Shift Settlements",
        labelAr: "💰 ملخص تسويات عهد السائقين",
        onTap: () => _triggerSuggestion(
          "Show pending shift settlements",
          "عرض تسويات ورديات السائقين المعلقة",
          "I analyzed the active logistics shifts for today. We have 3 driver cash drawer reconciliations pending confirmation:\n\n1. Amr H. (Shift #124) - EGP 8,400.00 (Balanced)\n2. Tarek F. (Shift #125) - EGP 4,150.00 (Deficit of EGP 50.00)\n3. Karim A. (Shift #126) - EGP 11,550.00 (Balanced)\n\nWould you like me to auto-approve the balanced shifts?",
          "لقد قمت بتحليل ورديات الخدمات اللوجستية النشطة لليوم. لدينا 3 تسويات نقدية معلقة بانتظار التأكيد:\n\n1. عمرو ح. (الوردية #124) - 8,400.00 ج.م (متطابقة)\n2. طارق ف. (الوردية #125) - 4,150.00 ج.م (عجز قيمته 50.00 ج.م)\n3. كريم أ. (الوردية #126) - 11,550.00 ج.م (متطابقة)\n\nهل ترغب في موافقتي التلقائية على الورديات المتطابقة؟",
        ),
      ),
      _SuggestionItem(
        labelEn: "📈 Today's Margin Summary",
        labelAr: "📈 ملخص هوامش الربح اليوم",
        onTap: () => _triggerSuggestion(
          "Show margin reports for today",
          "عرض تقارير هوامش الأرباح اليوم",
          "Today's financial metrics:\n- Net Revenue: EGP 24,150.00 (COD collected + settled cards)\n- Cost of Goods Sold (COGS): EGP 16,905.00\n- Gross Profit Margin: 30.0% (Stable target range)\n\nProduct category leading today's margins: Fresh Produce (35.2%).",
          "المقاييس المالية اليوم:\n- صافي الإيرادات: 24,150.00 ج.م (الدفع عند الاستلام + البطاقات المستقرة)\n- تكلفة البضائع المباعة (COGS): 16,905.00 ج.م\n- هامش الربح الإجمالي: 30.0٪ (في النطاق المستهدف)\n\nالفئة التي تقود أرباح اليوم: الخضروات والفواكه الطازجة (35.2٪).",
        ),
      ),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(isAr ? item.labelAr : item.labelEn),
              onPressed: item.onTap,
              backgroundColor: context.colorScheme.surface,
              side: BorderSide(color: context.colorScheme.outlineVariant),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow() {
    final isAr = context.isRtl;

    return Container(
      padding: const EdgeInsets.all(16),
      color: context.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: isAr ? 'اسأل المساعد عن المبيعات أو المخزون...' : 'Ask Copilot about sales, stock, orders...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: context.colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(
        textEn: text,
        textAr: text,
        isAi: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Mock replies depending on keywords
    Timer(const Duration(seconds: 1), () {
      final String replyEn;
      final String replyAr;

      if (text.toLowerCase().contains('stock') || text.contains('مخزون')) {
        replyEn = _getLowStockReplyEn();
        replyAr = _getLowStockReplyAr();
      } else if (text.toLowerCase().contains('sale') || text.toLowerCase().contains('revenue') || text.contains('مبيعات')) {
        replyEn = "Understood. The net revenue collected today is EGP 24,150.00. Top sales channels: 65% Cash on Delivery, 28% Credit Card, 7% InstaPay. No payment processing gateway errors detected today.";
        replyAr = "مفهوم. بلغ صافي الإيرادات اليوم 24,150.00 ج.م. قنوات المبيعات الأكثر نشاطاً: 65٪ الدفع عند الاستلام، 28٪ البطاقات الائتمانية، 7٪ انستاباي. لم يتم اكتشاف أي أخطاء في بوابات الدفع اليوم.";
      } else {
        replyEn = "Got it! I am running an background job to analyze your requested query. I will update you if I detect discrepancies or if you want to export reports.";
        replyAr = "حسناً! أقوم بتشغيل تحليل ذكي لاستعلامك في الخلفية. سأقوم بإعلامك في حال اكتشاف تعارضات أو في حال رغبت بتصدير تقارير مفصلة.";
      }

      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          textEn: replyEn,
          textAr: replyAr,
          isAi: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _triggerSuggestion(String userTextEn, String userTextAr, String replyEn, String replyAr, {Widget? widgetExtra}) {
    setState(() {
      _messages.add(_ChatMessage(
        textEn: userTextEn,
        textAr: userTextAr,
        isAi: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          textEn: replyEn,
          textAr: replyAr,
          isAi: true,
          timestamp: DateTime.now(),
          widgetExtra: widgetExtra,
        ));
      });
      _scrollToBottom();
    });
  }

  String _getLowStockReplyEn() {
    return "I found 3 products that have breached their reorder thresholds and require urgent supplier purchase orders:\n\n- Organic Red Apples: 12 packs remaining (Threshold: 50)\n- Full Cream Milk 1L: 8 cartons remaining (Threshold: 40)\n- Egyptian Rice 5kg: 0 bags remaining (Out of Stock!)\n\nI can draft a Supplier Purchase Order for these items. Shall I proceed?";
  }

  String _getLowStockReplyAr() {
    return "لقد وجدت 3 منتجات تجاوزت عتبة إعادة الطلب وتحتاج لأوامر شراء فورية من الموردين:\n\n- تفاح أحمر عضوي: متبقي 12 عبوة (الحد الأدنى: 50)\n- حليب كامل الدسم 1 لتر: متبقي 8 علب (الحد الأدنى: 40)\n- أرز مصري 5 كجم: نفد بالكامل! (0 كيس متبقي)\n\nيمكنني إعداد مسودة أمر شراء لهؤلاء الموردين. هل ترغب في المتابعة؟";
  }

  Widget _buildLowStockMockTable() {
    final isAr = context.isRtl;
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? "مسودة أمر شراء سريع" : "Suggested Purchase Orders Draft",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? "• تفاح أحمر عضوي (الكمية: 100 عبوة - المورد: FreshFarm Ltd)" : "• Organic Red Apples (Qty: 100 packs - Supplier: FreshFarm Ltd)",
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Text(
              isAr ? "• حليب كامل الدسم 1 لتر (الكمية: 200 كرتونة - المورد: Juhayna Foods)" : "• Full Cream Milk 1L (Qty: 200 ctns - Supplier: Juhayna Foods)",
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Text(
              isAr ? "• أرز مصري 5 كجم (الكمية: 150 كيس - المورد: Al-Doha Brand)" : "• Egyptian Rice 5kg (Qty: 150 bags - Supplier: Al-Doha Brand)",
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(isAr ? 'تأكيد وإرسال' : 'Approve & Send', style: const TextStyle(fontSize: 10, color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String textEn;
  final String textAr;
  final bool isAi;
  final DateTime timestamp;
  final Widget? widgetExtra;

  _ChatMessage({
    required this.textEn,
    required this.textAr,
    required this.isAi,
    required this.timestamp,
    this.widgetExtra,
  });
}

class _SuggestionItem {
  final String labelEn;
  final String labelAr;
  final VoidCallback onTap;

  _SuggestionItem({required this.labelEn, required this.labelAr, required this.onTap});
}
