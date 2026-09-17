# FB Inbox OS v3.1 FINAL - 65 files runnable

Fix lỗi chat cũ kẹt 1128 file log vượt giới hạn 1024 input files nên container.* bị chặn "Too many input files". Giải pháp: dùng client-side JSZip, không dùng python zip.

## Tổng quan kiến trúc
- Next.js 14 App Router, port 6000
- Prisma + PostgreSQL: Page, FbDataset, User, Tag, Conversation, Product, Order, CapiLog, AuditLog
- BullMQ + Redis: queue CAPI Primary FULL + Fanout LITE same event_id dedup 1 doanh số 2 tín hiệu
- AES-256-GCM encrypt access_token
- Role: OWNER, MANAGER, SALE, SHIPPER
- Mask phone *** + last 3, log VIEW_PHONE

## Cài đặt nhanh Ubuntu
```bash
chmod +x install.sh
./install.sh
# Mở http://localhost:6000/inbox
```

## Luồng CAPI quan trọng
- buildPrimary FULL: value = total_amount, contents [{id: fb_catalog_id, quantity:1, item_price: price}], content_ids, fbc, fbp, external_id, event_id = DH-123_SUCCESS
- buildFanout LITE: chỉ ph (hashed phone) + same event_id, không giá trị, order_id, để tránh duplicate revenue nhưng tăng tín hiệu
- Dedup: 1 doanh số, 2 tín hiệu nhờ same event_id

## Inbox UI
- Sidebar 60px #1c1e21
- List 360px: PageSelector truncate 20 chars, max-w 220px, row 72px, checkbox gộp trang, badge TKQC dropdown trắng, 100 chars không vỡ
- Filter Tất cả/Chưa đọc/Chưa tạo đơn/Có số điện
- 5 hội thoại mẫu LA/MT/HG/TA/PL
- Chat center bubble + phát hiện SĐT 0912345123 Lưu số + banner vàng
- Right panel 340px SĐT ***123 [Nhấn để xem] chặn + log, Thẻ 9 màu, Ghi chú nội bộ, Tín hiệu quảng cáo Đa nguồn 3 card ROAS 1.8 Dataset 123 FULL 780k ID DH-123_SUCCESS Dataset 999 LITE không giá trị, Đơn DH-123 VNPOST_123

## API
- POST /api/orders transaction Serializable FOR UPDATE, owned_by = assigned_to hoặc currentUser, is_ready=false, capi_event_id DH-xxx_SUCCESS
- GET /api/conversations filter page_id, assigned_to, has_phone, has_order, lock 5 phút
- POST /api/vnpost Idempotency-Key DH-xxx

## Stats
Tỉ lệ phát TC 72.3% hoàn 8.1% hủy 16% bom 24.1%

## License
Private - FB OS Team
