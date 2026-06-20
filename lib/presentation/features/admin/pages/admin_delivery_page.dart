import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';

class AdminDeliveryPage extends ConsumerWidget {
  const AdminDeliveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة التوصيل والشحن' : 'Delivery & Logistics Management'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats grid
            _buildDeliveryStats(context),
            const SizedBox(height: 24),

            // Active Deliveries + Active Drivers
            if (context.isMobile) ...[
              _buildActiveDeliveries(context),
              const SizedBox(height: 24),
              _buildActiveDrivers(context),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildActiveDeliveries(context),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: _buildActiveDrivers(context),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Delivery Zone Fees
            _buildDeliveryZonesSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStats(BuildContext context) {
    final isAr = context.isRtl;
    return GridView.count(
      crossAxisCount: context.isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: context.isMobile ? 1.3 : 1.7,
      children: [
        _buildStatCard(
          context,
          title: isAr ? 'الشحنات النشطة حالياً' : 'Active Shipments',
          value: '42',
          icon: Icons.local_shipping_outlined,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          title: isAr ? 'معدل وقت التوصيل' : 'Avg Delivery Time',
          value: '38 mins',
          icon: Icons.timer_outlined,
          color: Colors.teal,
        ),
        _buildStatCard(
          context,
          title: isAr ? 'السائقين المناوبين' : 'Drivers On-Duty',
          value: '12 / 15',
          icon: Icons.people_outline,
          color: Colors.purple,
        ),
        _buildStatCard(
          context,
          title: isAr ? 'نسبة التسليم الناجح' : 'Fulfillment Rate',
          value: '98.7%',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveries(BuildContext context) {
    final isAr = context.isRtl;

    final shipments = [
      _ShipmentData('#ORD-8840', isAr ? 'أحمد الشناوي' : 'Ahmed El-Shenawy', isAr ? 'مدينة نصر، القاهرة' : 'Nasr City, Cairo', 'OutForDelivery', 'Driver: Amr H.', '10 mins left', Colors.orange),
      _ShipmentData('#ORD-8835', isAr ? 'منى عبد العزيز' : 'Mona Abdel-Aziz', isAr ? 'المعادي، القاهرة' : 'Maadi, Cairo', 'Preparing', 'Warehouse A', 'Packing...', Colors.blue),
      _ShipmentData('#ORD-8822', isAr ? 'خالد صبري' : 'Khaled Sabry', isAr ? 'الدقي، الجيزة' : 'Dokki, Giza', 'Delivered', 'Driver: Karim A.', 'Completed', Colors.green),
      _ShipmentData('#ORD-8819', isAr ? 'سارة سليمان' : 'Sara Soliman', isAr ? 'مصر الجديدة، القاهرة' : 'Heliopolis, Cairo', 'Delivered', 'Driver: Amr H.', 'Completed', Colors.green),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'الشحنات النشطة والحديثة' : 'Active & Recent Shipments',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(isAr ? 'عرض الكل' : 'View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shipments.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final ship = shipments[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ship.statusColor.withOpacity(0.1),
                      child: Icon(
                        ship.status == 'Delivered'
                            ? Icons.check
                            : ship.status == 'OutForDelivery'
                                ? Icons.local_shipping
                                : Icons.inventory_2,
                        color: ship.statusColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(ship.orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ship.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ship.status,
                                  style: TextStyle(color: ship.statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${ship.customer} • ${ship.address}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(ship.assignedTo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ship.timeLeft,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ship.status == 'OutForDelivery' ? Colors.orange.shade800 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDrivers(BuildContext context) {
    final isAr = context.isRtl;

    final drivers = [
      _DriverData('Amr Hassan', isAr ? 'عمرو حسن' : 'Amr Hassan', 'Active (2 trips)', Colors.green, '0122345678'),
      _DriverData('Karim Ali', isAr ? 'كريم علي' : 'Karim Ali', 'Available', Colors.blue, '0100987654'),
      _DriverData('Tarek Fayed', isAr ? 'طارق فايد' : 'Tarek Fayed', 'Active (1 trip)', Colors.green, '0111223344'),
      _DriverData('Mostafa Nour', isAr ? 'مصطفى نور' : 'Mostafa Nour', 'Off-duty', Colors.grey, '0155556677'),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'حالة السائقين المناوبين' : 'Driver Dispatch Status',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: drivers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = drivers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(d.nameEn[0]),
                  ),
                  title: Text(
                    isAr ? d.nameAr : d.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(d.phone, style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: d.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.status,
                      style: TextStyle(color: d.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryZonesSection(BuildContext context) {
    final isAr = context.isRtl;

    final zones = [
      _ZoneFee(isAr ? 'القاهرة الجديدة والتجمع' : 'New Cairo & El Tagamoa', 20.0, '30-45 mins', true),
      _ZoneFee(isAr ? 'المعادي ومصر القديمة' : 'Maadi & Old Cairo', 15.0, '25-40 mins', true),
      _ZoneFee(isAr ? 'المهندسين والدقي' : 'Mohandessin & Dokki', 15.0, '30-50 mins', true),
      _ZoneFee(isAr ? 'الشيخ زايد وأكتوبر' : 'Sheikh Zayed & 6th of October', 30.0, '45-60 mins', true),
      _ZoneFee(isAr ? 'الإسكندرية (المندرة والمنتزه)' : 'Alexandria Central', 45.0, 'Same Day (Within 6h)', false),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'رسوم ومواعيد التوصيل للمناطق' : 'Delivery Zones & Pricing Table',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isAr ? 'إضافة منطقة' : 'Add Zone'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(isAr ? 'المنطقة / المدينة' : 'Delivery Zone')),
                  DataColumn(label: Text(isAr ? 'رسوم التوصيل' : 'Delivery Fee')),
                  DataColumn(label: Text(isAr ? 'الوقت المتوقع' : 'Estimated Time')),
                  DataColumn(label: Text(isAr ? 'خدمة سريعة (اكسبريس)' : 'Express Support')),
                  DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                ],
                rows: zones.map((zone) {
                  return DataRow(
                    cells: [
                      DataCell(Text(zone.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('EGP ${zone.fee.toStringAsFixed(2)}')),
                      DataCell(Text(zone.eta)),
                      DataCell(Icon(
                        zone.expressSupport ? Icons.check_circle : Icons.cancel,
                        color: zone.expressSupport ? Colors.green : Colors.grey,
                      )),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border: Border.all(color: Colors.green.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(isAr ? 'نشط' : 'Active', style: TextStyle(color: Colors.green.shade800, fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentData {
  final String orderId;
  final String customer;
  final String address;
  final String status;
  final String assignedTo;
  final String timeLeft;
  final Color statusColor;

  _ShipmentData(this.orderId, this.customer, this.address, this.status, this.assignedTo, this.timeLeft, this.statusColor);
}

class _DriverData {
  final String nameEn;
  final String nameAr;
  final String status;
  final Color statusColor;
  final String phone;

  _DriverData(this.nameEn, this.nameAr, this.status, this.statusColor, this.phone);
}

class _ZoneFee {
  final String name;
  final double fee;
  final String eta;
  final bool expressSupport;

  _ZoneFee(this.name, this.fee, this.eta, this.expressSupport);
}
