import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/controllers/permission_controller.dart';
import 'package:patrol_track_mobile/core/controllers/schedule_controller.dart';
import 'package:patrol_track_mobile/core/models/permission.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';

class PermissionPage extends StatefulWidget {
  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final TextEditingController reason = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _reasonNotEntered = false;
  bool _imageNotSelected = false;
  String? _selectedDate;

  // Add a flag to check if the form has been submitted
  bool _submitted = false;

  late Future<List<Schedule>> _futureSchedules;

  @override
  void initState() {
    super.initState();
    _futureSchedules = ScheduleController.getSchedules(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageNotSelected = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Izin", backButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tanggal Izin",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Schedule>>(
                future: _futureSchedules,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error loading schedules');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No schedules available');
                  } else {
                    List<Schedule> schedules = snapshot.data!;
                    List<String> availableDates = schedules
                       .where((schedule) => schedule.scheduleDate != null)
                       .map((schedule) {
                         return DateFormat('yyyy-MM-dd').format(schedule.scheduleDate!);
                    }).toSet().toList();

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        errorText: _submitted && _selectedDate == null ? 'Please select a date':null,
                      ),
                      hint: Text('Pilih Tanggal'),
                      value: _selectedDate,
                      items: availableDates.map((String date) {
                        return DropdownMenuItem<String>(
                          value: date,
                          child: Text(date),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDate = newValue;
                        });
                      },
                    );
                  }
                },
              ),
              if (_submitted && _selectedDate == null)
              Text(
                'Please select a date',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alasan",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: reason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (_) {
                  setState(() {
                    _reasonNotEntered = false;
                  });
                },
              ),
              if (_reasonNotEntered)
              Text(
                'Masukkan alasan',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Text(
                "Unggah Bukti",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text(
                    "Pilih File",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_imageNotSelected)
          Text(
            'Silahkan pilih foto',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          _imageFile != null
              ? Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF5F5C5C)),
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 25,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          const SizedBox(height: 20),
          MyButton(
            text: "Kirim",
            onPressed: () {
              setState(() {
                _submitted = true;
                _reasonNotEntered = reason.text.isEmpty;
                _imageNotSelected = _imageFile == null;
              });
              if (_selectedDate != null && !_reasonNotEntered && _imageFile != null) {
                Permission permission = Permission(
                  permissionDate: _selectedDate!,
                  reason: reason.text,
                  information: _imageFile,
                );
                PermissionController.createPermission(context, permission);
              } else {
                setState(() {
                  _reasonNotEntered = reason.text.isEmpty;
                  _imageNotSelected = _imageFile == null;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
