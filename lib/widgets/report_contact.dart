
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportContact extends StatelessWidget {
  final String contact;

  const ReportContact({
    super.key,
    required this.contact,
  });

  static const purple = Color(0xFF5946B2);

  // Mengubah nomor HP menjadi format internasional
  String formatPhoneNumber(String phone) {
    String number = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    } else if (number.startsWith('8')) {
      number = '62$number';
    }

    return number;
  }

  // Membuka percakapan WhatsApp
  Future<void> openWhatsApp(BuildContext context) async {
    final number = formatPhoneNumber(contact);

    if (!RegExp(r'^628[0-9]{7,11}$').hasMatch(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor WhatsApp tidak tersedia atau tidak valid.'),
        ),
      );
      return;
    }

    final url = Uri.https(
      'wa.me',
      '/$number',
      {
        'text': 'Halo, saya melihat laporan barang Anda '
            'di aplikasi Campus Lost & Found. '
            'Saya ingin menanyakan informasi mengenai barang tersebut.',
      },
    );

    try {
      final opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception('WhatsApp tidak dapat dibuka');
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => openWhatsApp(context),
        icon: const Icon(Icons.chat_outlined),
        label: const Text('Hubungi via WhatsApp'),
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
