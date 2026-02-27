import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling referral sharing across multiple platforms
/// Provides WhatsApp/Telegram deep links and auto-generated ranking cards
class ReferralShareService {
  /// Base URL for the app (replace with actual app URL when available)
  static const String _baseAppUrl = 'https://navapeace.app';

  /// Generate deep link URL for referral code
  String _generateReferralUrl(String referralCode) {
    return '$_baseAppUrl/ref/$referralCode';
  }

  /// Generate platform-specific referral message
  String _generateReferralMessage({
    required String referralCode,
    required String referralUrl,
    required String platform,
    String? userName,
    int? userRank,
    String? userBadge,
  }) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return _generateWhatsAppMessage(
          referralCode: referralCode,
          referralUrl: referralUrl,
          userName: userName,
          userRank: userRank,
          userBadge: userBadge,
        );
      case 'telegram':
        return _generateTelegramMessage(
          referralCode: referralCode,
          referralUrl: referralUrl,
          userName: userName,
          userRank: userRank,
          userBadge: userBadge,
        );
      default:
        return _generateGenericMessage(
          referralCode: referralCode,
          referralUrl: referralUrl,
          userName: userName,
          userRank: userRank,
          userBadge: userBadge,
        );
    }
  }

  String _generateWhatsAppMessage({
    required String referralCode,
    required String referralUrl,
    String? userName,
    int? userRank,
    String? userBadge,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🕊️ *NAVA PEACE* - Join the Peace Movement! 🌍');
    buffer.writeln('');

    if (userName != null && userRank != null && userBadge != null) {
      buffer.writeln('👋 Hey! I\'m *$userName*');
      buffer.writeln('🏆 Global Rank: *#$userRank*');
      buffer.writeln('🎖️ Badge: *$userBadge*');
      buffer.writeln('');
    }

    buffer.writeln('💎 *Exclusive Benefits for You:*');
    buffer.writeln('✅ Daily token rewards');
    buffer.writeln('🔥 Streak bonuses up to 30 days');
    buffer.writeln('📈 Multipliers up to 7x');
    buffer.writeln('🎯 180-day earning challenge');
    buffer.writeln('');
    buffer.writeln('🎁 *Use my referral code:*');
    buffer.writeln('*$referralCode*');
    buffer.writeln('');
    buffer.writeln('👉 Start earning: $referralUrl');

    return buffer.toString();
  }

  String _generateTelegramMessage({
    required String referralCode,
    required String referralUrl,
    String? userName,
    int? userRank,
    String? userBadge,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🕊️ **NAVA PEACE** - Join the Peace Movement! 🌍');
    buffer.writeln('');

    if (userName != null && userRank != null && userBadge != null) {
      buffer.writeln('👋 Hey! I\'m **$userName**');
      buffer.writeln('🏆 Global Rank: **#$userRank**');
      buffer.writeln('🎖️ Badge: **$userBadge**');
      buffer.writeln('');
    }

    buffer.writeln('💎 **Exclusive Benefits:**');
    buffer.writeln('• Daily token rewards 💰');
    buffer.writeln('• Streak bonuses up to 30 days 🔥');
    buffer.writeln('• Multipliers up to 7x 📈');
    buffer.writeln('• 180-day earning challenge 🎯');
    buffer.writeln('');
    buffer.writeln('🎁 **My referral code:**');
    buffer.writeln('`$referralCode`');
    buffer.writeln('');
    buffer.writeln('👉 [Start Earning Now]($referralUrl)');

    return buffer.toString();
  }

  String _generateGenericMessage({
    required String referralCode,
    required String referralUrl,
    String? userName,
    int? userRank,
    String? userBadge,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🕊️ NAVA PEACE - Join the Peace Movement! 🌍');
    buffer.writeln('');

    if (userName != null && userRank != null && userBadge != null) {
      buffer.writeln('👋 Invited by: $userName');
      buffer.writeln('🏆 Rank #$userRank | 🎖️ $userBadge Badge');
      buffer.writeln('');
    }

    buffer.writeln('💎 Benefits:');
    buffer.writeln('✨ Daily token rewards');
    buffer.writeln('🔥 Streak bonuses (up to 30 days)');
    buffer.writeln('📈 Multipliers (up to 7x)');
    buffer.writeln('🎯 180-day earning game');
    buffer.writeln('');
    buffer.writeln('🎁 Use referral code: $referralCode');
    buffer.writeln('');
    buffer.writeln('Start earning: $referralUrl');

    return buffer.toString();
  }

  /// Share via WhatsApp with deep link
  Future<bool> shareViaWhatsApp({
    required String referralCode,
    String? userName,
    int? userRank,
    String? userBadge,
  }) async {
    try {
      final referralUrl = _generateReferralUrl(referralCode);
      final message = _generateReferralMessage(
        referralCode: referralCode,
        referralUrl: referralUrl,
        platform: 'whatsapp',
        userName: userName,
        userRank: userRank,
        userBadge: userBadge,
      );

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('whatsapp://send?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        return true;
      } else {
        // Fallback to generic share if WhatsApp is not installed
        return await _shareGeneric(referralCode, userName, userRank, userBadge);
      }
    } catch (e) {
      return false;
    }
  }

  /// Share via Telegram with deep link
  Future<bool> shareViaTelegram({
    required String referralCode,
    String? userName,
    int? userRank,
    String? userBadge,
  }) async {
    try {
      final referralUrl = _generateReferralUrl(referralCode);
      final message = _generateReferralMessage(
        referralCode: referralCode,
        referralUrl: referralUrl,
        platform: 'telegram',
        userName: userName,
        userRank: userRank,
        userBadge: userBadge,
      );

      final encodedMessage = Uri.encodeComponent(message);
      final telegramUrl = Uri.parse('tg://msg?text=$encodedMessage');

      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl);
        return true;
      } else {
        // Fallback to generic share if Telegram is not installed
        return await _shareGeneric(referralCode, userName, userRank, userBadge);
      }
    } catch (e) {
      return false;
    }
  }

  /// Generic share fallback using share_plus
  Future<bool> _shareGeneric(
    String referralCode,
    String? userName,
    int? userRank,
    String? userBadge,
  ) async {
    try {
      final referralUrl = _generateReferralUrl(referralCode);
      final message = _generateReferralMessage(
        referralCode: referralCode,
        referralUrl: referralUrl,
        platform: 'generic',
        userName: userName,
        userRank: userRank,
        userBadge: userBadge,
      );

      await Share.share(
        message,
        subject: 'Join NAVA PEACE - Token Reward System',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Share ranking card as image with referral link
  Future<bool> shareRankingCard({
    required GlobalKey cardKey,
    required String referralCode,
    String? userName,
    int? userRank,
    String? userBadge,
  }) async {
    try {
      // Capture the widget as image
      final boundary =
          cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/nava_peace_ranking_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Generate referral message
      final referralUrl = _generateReferralUrl(referralCode);
      final message = _generateReferralMessage(
        referralCode: referralCode,
        referralUrl: referralUrl,
        platform: 'generic',
        userName: userName,
        userRank: userRank,
        userBadge: userBadge,
      );

      // Share image with text
      await Share.shareXFiles(
        [XFile(filePath)],
        text: message,
        subject: 'My NAVA PEACE Ranking',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Show share options bottom sheet
  Future<void> showShareOptions({
    required BuildContext context,
    required String referralCode,
    required GlobalKey rankingCardKey,
    String? userName,
    int? userRank,
    String? userBadge,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Share Referral',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Share Ranking Card'),
                subtitle: const Text('Share as image with stats'),
                onTap: () async {
                  Navigator.pop(context);
                  await shareRankingCard(
                    cardKey: rankingCardKey,
                    referralCode: referralCode,
                    userName: userName,
                    userRank: userRank,
                    userBadge: userBadge,
                  );
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/images/no-image.jpg',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.message, color: Colors.green),
                ),
                title: const Text('Share via WhatsApp'),
                subtitle: const Text('Send to WhatsApp contacts'),
                onTap: () async {
                  Navigator.pop(context);
                  await shareViaWhatsApp(
                    referralCode: referralCode,
                    userName: userName,
                    userRank: userRank,
                    userBadge: userBadge,
                  );
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/images/no-image.jpg',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.send, color: Colors.blue),
                ),
                title: const Text('Share via Telegram'),
                subtitle: const Text('Send to Telegram contacts'),
                onTap: () async {
                  Navigator.pop(context);
                  await shareViaTelegram(
                    referralCode: referralCode,
                    userName: userName,
                    userRank: userRank,
                    userBadge: userBadge,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.grey),
                title: const Text('More Options'),
                subtitle: const Text('Share via other apps'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareGeneric(
                    referralCode,
                    userName,
                    userRank,
                    userBadge,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
