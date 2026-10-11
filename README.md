# পত্রিকাঘর (Potrikaghor) v1.1.0

বাংলাদেশি সংবাদপত্র অ্যাগ্রিগেটর অ্যাপ — Flutter দিয়ে তৈরি।

## নতুন ফিচার (v1.1.0)

### 1. Offline Reading + Notification
- আর্টিকেল অফলাইনে সেভ করা যায় (Hive ব্যবহার)
- অফলাইন ট্যাব থেকে পড়া যায়
- পত্রিকা ফলো করে লোকাল নোটিফিকেশন পাওয়া যায়
- সেটিংস থেকে নোটিফিকেশন চালু/বন্ধ করা যায়

### 2. Category + Search
- ৭টি ক্যাটাগরি: জাতীয়, আন্তর্জাতিক, খেলা, বিনোদন, অর্থনীতি, প্রযুক্তি, মতামত
- হোম ও পত্রিকা ট্যাবে ক্যাটাগরি ফিল্টার
- রিয়েল-টাইম সার্চ (খবর + পত্রিকা)

### 3. Better Share Card
- সুন্দর প্রিভিউ কার্ডসহ শেয়ার
- পত্রিকার নাম + টাইটেল + অ্যাপ ব্র্যান্ডিং

## অন্যান্য ফিচার
- ১৫+ জনপ্রিয় বাংলাদেশি ও আন্তর্জাতিক পত্রিকা
- কাস্টম RSS পত্রিকা যোগ করা
- বুকমার্ক ও ফেভারিট
- ডার্ক/লাইট থিম
- WebView দিয়ে আর্টিকেল পড়া

## কিভাবে বিল্ড করবেন

### প্রয়োজনীয়
- Flutter SDK 3.16+ (https://flutter.dev)
- Android Studio / VS Code
- JDK 17

### ধাপ

```bash
# 1. প্রজেক্ট আনজিপ করুন
unzip potrikaghor.zip
cd potrikaghor

# 2. ডিপেন্ডেন্সি ইনস্টল
flutter pub get

# 3. রান করুন (এমুলেটর বা ডিভাইসে)
flutter run

# 4. APK বানান
flutter build apk --release

# APK পাবেন এখানে:
# build/app/outputs/flutter-apk/app-release.apk
```

### GitHub-এ আপলোড + অটো APK বিল্ড

```bash
git init
git add .
git commit -m "পত্রিকাঘর v1.1.0 - Offline, Category, Search, Share Card"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/potrikaghor.git
git push -u origin main
```

**পুশ করার পর GitHub Actions অটোমেটিক APK বিল্ড করবে।**

APK ডাউনলোড করতে:
1. GitHub রিপোজিটরিতে যান
2. **Actions** ট্যাবে ক্লিক করুন
3. সফল বিল্ডে ক্লিক করুন
4. নিচে **Artifacts** সেকশন থেকে `potrikaghor-apk` ডাউনলোড করুন

ম্যানুয়ালি বিল্ড চালাতে চাইলে Actions ট্যাব → "Build APK" → "Run workflow" বাটনে ক্লিক করুন।

## প্যাকেজ নাম
`com.potrikaghor.app`

## নোট
- কিছু পত্রিকার RSS ব্লক করতে পারে — সেক্ষেত্রে ডেমো নিউজ দেখাবে
- নোটিফিকেশনের জন্য অ্যাপে পত্রিকা ফলো করতে হবে (পত্রিকা ট্যাবে বেল আইকন)
- প্রথমবার অ্যাপ খুললে নোটিফিকেশন পারমিশন চাইবে (Android 13+)

## লাইসেন্স
এই প্রজেক্ট শিক্ষামূলক উদ্দেশ্যে তৈরি।
