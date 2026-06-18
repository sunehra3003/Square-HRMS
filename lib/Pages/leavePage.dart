import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/leave_provider.dart';
import 'dart:io';
import "../widget/common_appbar.dart";
import "../providers/employee_provider.dart";
import '../models/employee_data.dart';

const kNavy = Color(0xFF1B2E5E);
const kGreen = Color(0xFF2E7D32);
const kBg = Color(0xFFF5F7FA);

class LeavePage extends ConsumerStatefulWidget {
  const LeavePage({super.key});

  @override
  ConsumerState<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends ConsumerState<LeavePage> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(leaveBalanceProvider);
    final leaveTypesAsync = ref.watch(leaveTypesProvider);
    final form = ref.watch(leaveFormProvider);
    final notifier = ref.read(leaveFormProvider.notifier);
    final supervisorAsync = ref.watch(supervisorProvider);

    ref.listen(leaveFormProvider, (previous, next) {
      if (next.reason.isEmpty && _reasonController.text.isNotEmpty) {
        _reasonController.clear();
      }
    });

    return Scaffold(
      backgroundColor: kBg,
      appBar: const CommonAppBar(),

      body: RefreshIndicator(
        color: kNavy,
        onRefresh: () async {
          ref.refresh(leaveBalanceProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              balanceAsync.when(
                loading: () => _bannerSkeleton(),
                error: (_, __) => _bannerError(),
                data: (balance) => _bannerCard(balance),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                children: [
                  _sectionHeader(1, 'Leave Details'),
                  const SizedBox(height: 20),
                  _fieldLabel('Leave Type'),
                  const SizedBox(height: 8),
                  _LeaveTypeDropdown(
                    leaveTypesAsync: leaveTypesAsync,
                    balanceAsync: balanceAsync,
                    value: form.leaveTypeId,
                    onChanged: notifier.setLeaveType,
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('From / To Date'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'From Date',
                          date: form.fromDate,
                          onPicked: notifier.setFromDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'To Date',
                          date: form.toDate,
                          onPicked: notifier.setToDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _totalDurationRow(form.totalDays),
                ],
              ),

              const SizedBox(height: 16),

              _sectionCard(
                children: [
                  _sectionHeader(2, 'Supporting Info'),
                  const SizedBox(height: 20),
                  _fieldLabel('Reason for Leave'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    onChanged: notifier.setReason,
                    decoration: InputDecoration(
                      hintText: 'Please provide a brief reason...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kNavy, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('Attachments (Medical Certificates, etc.)'),
                  const SizedBox(height: 8),
                  const _AttachmentBox(),
                  const SizedBox(height: 20),
                  _fieldLabel('Approving Supervisor'),
                  const SizedBox(height: 8),
                  _SupervisorCard(supervisorAsync: supervisorAsync),
                ],
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SubmitButton(
                  isLoading: form.isSubmitting,
                  onTap: () => notifier.submit(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Leave application submitted!'),
                        backgroundColor: kGreen,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerCard(LeaveBalance b) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AVAILABLE LEAVE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${b.totalRemaining}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Total Days Remaining',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniLeaveCard('Casual', b.casualUsed, b.casualTotal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniLeaveCard(
                  'Sick',
                  b.sickUsed,
                  b.sickTotal,
                  valueColor: const Color(0xFF66BB6A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniLeaveCard(
    String label,
    int used,
    int total, {
    Color valueColor = Colors.white,
  }) {
    final displayColor = valueColor == Colors.white ? kNavy : valueColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                used.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: displayColor,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ $total',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerSkeleton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        color: kNavy.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _bannerError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Center(
        child: Text(
          'Failed to load leave balance',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionHeader(int number, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: kNavy, shape: BoxShape.circle),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _totalDurationRow(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Duration', style: TextStyle(color: Colors.grey)),
          Text(
            '$days ${days == 1 ? "Day" : "Days"}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _LeaveTypeDropdown extends StatelessWidget {
  final AsyncValue<List<LeaveType>> leaveTypesAsync;
  final AsyncValue<LeaveBalance> balanceAsync;

  final int? value;
  final ValueChanged<int> onChanged;

  const _LeaveTypeDropdown({
    required this.leaveTypesAsync,
    required this.balanceAsync,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: leaveTypesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Failed to load leave types',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (types) {
          if (types.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No leave types configured',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final balance = balanceAsync.asData?.value;

          return DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey,
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              items: types.map((t) {
                final exhausted = isLeaveExhausted(t, balance);
                return DropdownMenuItem(
                  value: t.id,
                  enabled: !exhausted,
                  child: Text(
                    exhausted ? '${t.name} (Limit reached)' : t.name,
                    style: TextStyle(
                      color: exhausted ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          );
        },
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  String _format(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: Theme.of(
              ctx,
            ).copyWith(colorScheme: const ColorScheme.light(primary: kNavy)),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(date),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBox extends ConsumerWidget {
  const _AttachmentBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leaveFormProvider.notifier);
    final form = ref.watch(leaveFormProvider);
    final hasFile = form.attachmentPath != null;

    return GestureDetector(
      onTap: () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'png'],
        );
        if (result != null && result.files.single.path != null) {
          notifier.setAttachmentPath(result.files.single.path!);
        }
      },
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: hasFile ? Colors.green.shade400 : Colors.grey.shade400,
          strokeWidth: 1.5,
          dashWidth: 6,
          dashSpace: 4,
          radius: 10,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                hasFile
                    ? Icons.check_circle_outline
                    : Icons.cloud_upload_outlined,
                size: 40,
                color: hasFile ? Colors.green.shade600 : Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                hasFile ? '✅ File attached' : 'Tap to upload or drag & drop',
                style: TextStyle(
                  color: hasFile ? Colors.green.shade700 : Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, JPG, PNG up to 5MB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

class _SupervisorCard extends StatelessWidget {
  final AsyncValue<EmployeeData?> supervisorAsync;

  const _SupervisorCard({required this.supervisorAsync});

  @override
  Widget build(BuildContext context) {
    return supervisorAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Failed to load supervisor',
          style: TextStyle(color: Colors.red),
        ),
      ),
      data: (supervisor) {
        if (supervisor == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'No supervisor assigned',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    (supervisor.image != null && supervisor.image!.isNotEmpty)
                    ? NetworkImage(supervisor.image!) as ImageProvider
                    : const AssetImage('assets/download.jpg'),
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supervisor.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      supervisor.role ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isLoading ? kNavy.withOpacity(0.7) : kNavy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Application',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }
}
