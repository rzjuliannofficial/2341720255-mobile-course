import 'package:flutter/material.dart';

/// Screen displaying the Clean Architecture Layer Audit and SOLID Principles.
class AuditPage extends StatelessWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audit Layer & SOLID',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildSectionTitle('1. Pemetaan Layer Project Lama ke Target'),
          _buildAuditTable(),
          const SizedBox(height: 20),
          _buildSectionTitle('2. Status Tiga Pelanggaran Klasik (Grep Sterilitas)'),
          _buildSterilityCards(),
          const SizedBox(height: 20),
          _buildSectionTitle('3. Aturan Dependensi (Dependency Rule)'),
          _buildDependencyRuleCard(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(Icons.verified_outlined, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Arsitektur divalidasi dengan aturan Clean Architecture feature-first: dependensi hanya mengarah ke dalam (Presentation -> Domain <- Data).',
                style: TextStyle(fontSize: 12.5, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAuditTable() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(0.9),
            2: FlexColumnWidth(1.5),
          },
          children: const [
            TableRow(
              decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('File Lama',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Layer Asal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Refactor Target',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('pages/notes_page.dart',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Presentation (kotor)', style: TextStyle(fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Presentation steril (hanya panggil Riverpod Notifier)',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('note_repository.dart',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Data (tercampur)', style: TextStyle(fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Dipecah: Kontrak Interface di Domain, Impl di Data',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('note.dart',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Model (tercampur)', style: TextStyle(fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Dipecah: Entity murni di Domain, Model di Data',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('api_client.dart',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Data', style: TextStyle(fontSize: 11)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Data source terisolasi di data layer',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSterilityCards() {
    return Column(
      children: [
        _buildGrepStatus(
          title: 'Presentation steril dari data mentah',
          command: 'Verifikasi: bebas direct DB, client HTTP, & raw JSON',
          status: '0 Pelanggaran (Lolos)',
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildGrepStatus(
          title: 'Domain steril dari framework & package',
          command: 'Verifikasi: bebas external framework packages',
          status: '0 Pelanggaran (Lolos)',
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildGrepStatus(
          title: 'Wiring DI terpusat & bebas instansiasi manual',
          command: 'Dependency Injection via Provider Riverpod',
          status: '100% Injected (Lolos)',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildGrepStatus({
    required String title,
    required String command,
    required String status,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.check, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(command,
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                color: Colors.grey.shade700)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDependencyRuleCard() {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arah Dependensi (The Dependency Rule)',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            SizedBox(height: 10),
            Text(
              'presentation (Widget, Notifier, Router)\n'
              '      │\n'
              '      ▼  bergantung ke\n'
              'domain (Entity, Repository Interface, Use Case, Failure)\n'
              '      ▲\n'
              '      │  diimplementasikan oleh\n'
              'data (Model, Repository Impl, SQLite, Remote Source)',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
