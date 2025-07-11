import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MedicineAlert {
  final String medicineName;
  final TimeOfDay time;
  MedicineAlert({required this.medicineName, required this.time});
}

class MedicineAlertsScreen extends StatefulWidget {
  const MedicineAlertsScreen({super.key});

  @override
  _MedicineAlertsScreenState createState() => _MedicineAlertsScreenState();
}

class _MedicineAlertsScreenState extends State<MedicineAlertsScreen> {
  final List<MedicineAlert> _alerts = [];
  final TextEditingController _medicineController = TextEditingController();
  TimeOfDay? _selectedTime;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Set<String> _triggeredToday = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 30), (_) => _checkAlerts());
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addAlert() {
    final name = _medicineController.text.trim();
    if (name.isNotEmpty && _selectedTime != null) {
      setState(() {
        _alerts.add(MedicineAlert(medicineName: name, time: _selectedTime!));
        _medicineController.clear();
        _selectedTime = null;
      });
    }
  }

  Future<void> _playAlertSound() async {
    await _audioPlayer.play(AssetSource('alert.mp3'));
  }

  void _showAlertDialog(String medicineName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.yellow[50],
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 32),
            SizedBox(width: 12),
            Text('Medicine Alert', style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'It\'s time to take your medicine:',
              style: TextStyle(fontSize: 16, color: Colors.orange[900]),
            ),
            SizedBox(height: 8),
            Text(
              medicineName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[800]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _checkAlerts() {
    final now = TimeOfDay.now();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    for (final alert in _alerts) {
      final key = '${alert.medicineName}_${alert.time.hour}_${alert.time.minute}_$today';
      if (!_triggeredToday.contains(key) &&
          alert.time.hour == now.hour &&
          alert.time.minute == now.minute) {
        _triggeredToday.add(key);
        _playAlertSound();
        _showAlertDialog(alert.medicineName);
      }
    }
    // Reset triggers at midnight
    if (now.hour == 0 && now.minute == 0) {
      _triggeredToday.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Alerts'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _medicineController,
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _pickTime,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'No time selected'
                        : 'Alert Time: ${_selectedTime!.format(context)}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addAlert,
                  child: Text('Add Alert'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Your Medicine Alerts:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const SizedBox(height: 8),
            Expanded(
              child: _alerts.isEmpty
                  ? Center(child: Text('No alerts set yet.'))
                  : ListView.builder(
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.alarm, color: Colors.cyan[700]),
                            title: Text(alert.medicineName),
                            subtitle: Text('Time: ${alert.time.format(context)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _alerts.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 