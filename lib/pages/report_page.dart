import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();
  final contact = TextEditingController(
    text: 'Melalui aplikasi',
  );
  final time = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? selectedImageBytes;
  String? selectedImageName;

  String type = 'hilang';
  String category = 'Perlengkapan';

  DateTime date = DateTime.now();
  bool saving = false;
  bool pickingImage = false;

  static const categories = [
    'Elektronik',
    'Dokumen',
    'Aksesoris',
    'Perlengkapan',
    'Lainnya',
  ];

  @override
  void dispose() {
    name.dispose();
    location.dispose();
    description.dispose();
    contact.dispose();
    time.dispose();
    super.dispose();
  }

  // Memilih foto dari galeri
  Future<void> pickImage() async {
    if (pickingImage) return;

    setState(() {
      pickingImage = true;
    });

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ukuran foto maksimal 5 MB.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        selectedImageName = image.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih foto: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          pickingImage = false;
        });
      }
    }
  }

  // Menghapus foto yang dipilih
  void removeImage() {
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
    });
  }

  // Memilih tanggal kejadian
  Future<void> selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        date = selected;
      });
    }
  }

  // Menyimpan laporan ke Firestore
  Future<void> saveReport() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Foto perlu diunggah ke penyimpanan cloud
    // sebelum URL-nya dapat disimpan ke Firestore.
    if (selectedImageBytes != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto berhasil dipilih, tetapi penyimpanan '
            'foto ke cloud belum diaktifkan. '
            'Hapus foto dahulu untuk mengirim laporan '
            'tanpa foto.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await ReportService.create(
        reportType: type,
        itemName: name.text,
        category: category,
        location: location.text,
        eventDate: date,
        eventTime: time.text.trim(),
        description: description.text,
        contact: contact.text,
        imageUrl: '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil disimpan ke Firestore!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Mengosongkan formulir setelah berhasil
      name.clear();
      location.clear();
      description.clear();
      time.clear();

      contact.text = 'Melalui aplikasi';

      setState(() {
        date = DateTime.now();
        selectedImageBytes = null;
        selectedImageName = null;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      final message = e.code == 'permission-denied'
          ? 'Izin menulis Firestore belum aktif. '
              'Periksa Security Rules.'
          : 'Gagal menyimpan laporan: '
              '${e.message ?? e.code}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan laporan: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lost = type == 'hilang';

    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(
        title: Text(
          lost
              ? 'Lapor Barang Hilang'
              : 'Lapor Barang Ditemukan',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HEADER FORMULIR
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CAMPUS LOST & FOUND',
                        style: TextStyle(
                          color: campusPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lost
                            ? 'Lapor Barang Hilang'
                            : 'Lapor Barang Ditemukan',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: campusInk,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Isi data dengan jelas dan benar',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  lost
                      ? Icons.find_in_page_outlined
                      : Icons.inventory_2_outlined,
                  color: campusPurple,
                  size: 44,
                ),
              ],
            ),

            const Divider(height: 30),

            // JENIS LAPORAN
            const _FieldLabel('Jenis Laporan'),

            DropdownButtonFormField<String>(
              initialValue: type,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon:
                    Icon(Icons.assignment_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'hilang',
                  child: Text('Hilang'),
                ),
                DropdownMenuItem(
                  value: 'ditemukan',
                  child: Text('Ditemukan'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  type = value ?? 'hilang';
                });
              },
            ),

            const SizedBox(height: 16),

            // NAMA BARANG
            const _FieldLabel('Nama Barang'),

            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                hintText: 'Contoh: Tumbler hitam',
                prefixIcon:
                    Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // KATEGORI
            const _FieldLabel('Kategori'),

            DropdownButtonFormField<String>(
              initialValue: category,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value ?? 'Perlengkapan';
                });
              },
            ),

            const SizedBox(height: 16),

            // LOKASI
            _FieldLabel(
              lost
                  ? 'Lokasi Kehilangan'
                  : 'Lokasi Penemuan',
            ),

            TextFormField(
              controller: location,
              decoration: const InputDecoration(
                hintText: 'Contoh: Perpustakaan JPTK',
                prefixIcon:
                    Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Lokasi wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // TANGGAL KEJADIAN
            _FieldLabel(
              lost
                  ? 'Tanggal Kehilangan'
                  : 'Tanggal Penemuan',
            ),

            OutlinedButton.icon(
              onPressed: selectDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: campusPurple,
              ),
              label: Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  color: campusInk,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // WAKTU KEJADIAN
            const _FieldLabel(
              'Waktu Kejadian (opsional)',
            ),

            TextFormField(
              controller: time,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                hintText: 'HH:mm, contoh 09:30',
                prefixIcon:
                    Icon(Icons.access_time_outlined),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return null;
                }

                final valid = RegExp(
                  r'^([01]\d|2[0-3]):[0-5]\d$',
                ).hasMatch(value.trim());

                return valid
                    ? null
                    : 'Gunakan format HH:mm';
              },
            ),

            const SizedBox(height: 16),

            // DESKRIPSI BARANG
            _FieldLabel(
              lost
                  ? 'Ciri-ciri Barang'
                  : 'Deskripsi Barang',
            ),

            TextFormField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tuliskan ciri-ciri barang',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Deskripsi wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // KONTAK PELAPOR
            const _FieldLabel('Kontak Pelapor'),

            TextFormField(
              controller: contact,
              decoration: const InputDecoration(
                hintText:
                    'Nomor/kanal yang dapat dihubungi',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Kanal kontak wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 6),

            const Text(
              'Gunakan informasi kontak yang aman. '
              'Jangan masukkan nomor pribadi sungguhan '
              'selama masih menggunakan data percobaan.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // FITUR PILIH FOTO
            const _FieldLabel(
              'Foto Barang (opsional)',
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: pickingImage ? null : pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBBADE8),
                    width: 1.5,
                  ),
                ),
                child: pickingImage
                    ? const Column(
                        children: [
                          CircularProgressIndicator(
                            color: campusPurple,
                          ),
                          SizedBox(height: 12),
                          Text('Memilih foto...'),
                        ],
                      )
                    : selectedImageBytes == null
                        ? const Column(
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: campusPurple,
                                size: 48,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Unggah Foto Barang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: campusInk,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Klik untuk memilih foto dari perangkat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Maksimal 5 MB',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Image.memory(
                                  selectedImageBytes!,
                                  height: 190,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                selectedImageName ??
                                    'Foto dipilih',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: campusInk,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ketuk untuk mengganti foto',
                                style: TextStyle(
                                  color: campusPurple,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            if (selectedImageBytes != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: removeImage,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Hapus Foto',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            const Text(
              'Foto baru ditampilkan sebagai pratinjau. '
              'Penyimpanan foto online belum dikonfigurasi.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL KIRIM LAPORAN
            FilledButton.icon(
              onPressed: saving ? null : saveReport,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_outlined,
                    ),
              label: Text(
                saving
                    ? 'Menyimpan...'
                    : lost
                        ? 'Kirim Laporan Hilang'
                        : 'Kirim Laporan Ditemukan',
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: campusInk,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
