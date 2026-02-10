# xray-single-user-lock
Lock V2Ray/Xray users to a single IP per port using nftables. Prevents account sharing with minimal overhead.

## 🚀 Quick Install (One-Line)

Run directly from GitHub:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/navidiii/xray-single-user-lock/main/xray-nft-manager.sh)
```

# xray-single-user-lock

## 🇬🇧 English

**xray-single-user-lock** is a lightweight nftables-based solution to enforce  
**single-user access per port** in V2Ray/Xray setups.

⚠️ This project is specifically designed for environments where:

👉 Each user has a **dedicated inbound port**  
👉 Example:
- User A → port 15234
- User B → port 16322
- User C → port 17881

If your users share a single port (UUID-based auth, panel-based auth, etc.),  
this project will NOT work for you.

---

### What it does

- Locks each user port to one IP address
- Prevents account sharing
- Allows multiple TCP connections from the same IP (normal Xray behavior)
- Ignores ephemeral outbound ports
- Ignores localhost traffic
- Automatically tracks active listening ports
- Very low CPU/RAM overhead (kernel-level filtering)

---
### Features

- Single-user enforcement
- Anti-account-sharing
- Automatic port detection
- nftables native performance
- Minimal latency impact
- Easy install/uninstall script

---

### Requirements

- Linux server (Ubuntu 22+ recommended)
- nftables enabled
- Xray/V2Ray configured with per-user ports

---

This ensures only one client IP can use each assigned port.

---

### Features

- Single-user enforcement
- Anti-account-sharing
- Automatic port detection
- nftables native performance
- Minimal latency impact
- Easy install/uninstall script

---

### Requirements

- Linux server (Ubuntu 22+ recommended)
- nftables enabled
- Xray/V2Ray configured with per-user ports

---

## 🇮🇷 فارسی

**xray-single-user-lock** یک ابزار سبک بر پایه nftables است برای اینکه:

### نصب سریع
```bash
bash <(curl -Ls https://raw.githubusercontent.com/navidiii/xray-single-user-lock/main/xray-nft-manager.sh)
```



---
👉 هر کاربر xray/Xray فقط با یک IP بتواند وصل شود  
👉 مخصوص زمانی که برای هر کاربر یک پورت جدا دارید.

⚠️ فقط در این حالت کاربرد دارد:

- هر کاربر یک پورت اختصاصی دارد  
مثلاً:

- کاربر ۱ → پورت 15234  
- کاربر ۲ → پورت 16322  
- کاربر ۳ → پورت 17881  

اگر همه کاربران روی یک پورت مشترک باشند  
(مثلاً UUID-based auth یا پنل‌هایی مثل Marzban)،  
این پروژه مناسب شما نیست.

---

### چه کاری انجام می‌دهد؟

- قفل کردن هر پورت کاربر روی یک IP
- جلوگیری از اشتراک اکانت
- اجازه چند اتصال TCP از یک IP (رفتار طبیعی Xray)
- نادیده گرفتن پورت‌های موقت خروجی
- نادیده گرفتن localhost
- تشخیص خودکار پورت‌های فعال Xray
- مصرف منابع بسیار کم (در سطح کرنل)

---

### امکانات

- جلوگیری از اشتراک اکانت
- قفل تک‌کاربر واقعی
- تشخیص خودکار پورت‌ها
- سرعت بالا با nftables
- تأخیر بسیار کم
- نصب و حذف ساده

---

### پیش‌نیازها

- سرور لینوکسی (ترجیحاً Ubuntu 22+)
- فعال بودن nftables
- تنظیم Xray/V2Ray به صورت per-user port

---
