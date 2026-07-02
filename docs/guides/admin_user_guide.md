# Admin User Guide

Welcome to the Fresh Market Admin Panel. This guide explains how to manage catalog items, inventory, warehouses, orders, and expenses.

---

## 1. Dashboard Overview
Upon logging in, you will be presented with the **لوحة التحكم للمسؤول (Admin Dashboard)**:
* **Metrics Cards**: View total products count, active categories, and live offers.
* **Expiry Alerts**: Warnings for batches near expiration.
* **Navigation Sidebar**: Access all management sections.

---

## 2. Inventory & FIFO Batch Management
Fresh Market runs on a strict **First-In, First-Out (FIFO)** inventory strategy:
1. **Goods Receipt**: Go to **Purchase Orders** to record items received from suppliers. This automatically creates a document in **Batches & Expiry** with an expiration date.
2. **FIFO Allocation**: When customers order products, stock is locked from the oldest non-expired batch.
3. **Fulfillment**: Marking an order as *Delivered* consumes stock physically from that batch.

---

## 3. Warehouse Management & Transfers
To manage inventory across multiple hubs (e.g. Cairo Main Hub, Alex Express):
1. **View Stock**: Go to the **Warehouse** section to view inventory counts per product per warehouse location.
2. **Stock Transfer**: 
   * Tap **Transfer Stock** in the UI.
   * Select source and destination warehouses, select the product, and specify the quantity.
   * Tap Submit to run the transaction. This updates both warehouse stocks and creates outbound/inbound audit histories.

---

## 4. Treasury & Cash Control
To view cash flows and reconcile driver cash drawers:
1. Go to the **Treasury** section in the sidebar.
2. View available liquid assets breakdown (Cash in Hand, Bank, InstaPay).
3. Review driver shift cash settlements. Discrepancies (deficits/surpluses) will show up highlighted.
4. Record expenses (Salaries, Rent, Bills) or view supplier payouts.
