import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/employee_provider.dart';

const kNavy = Color(0xFF1B2E5E);

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showLoadingBar;
  final List<Widget>? actions;

  const CommonAppBar({super.key, this.showLoadingBar = false, this.actions});

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showLoadingBar ? 3 : 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final emp = employeeState.data;

    return AppBar(
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 222, 232, 249),
      leadingWidth: 200,
      leading: Row(
        children: [
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: (emp?.image != null && emp!.image!.isNotEmpty)
                ? NetworkImage(emp.image!) as ImageProvider
                : const AssetImage('assets/download.jpg'),
          ),
          const SizedBox(width: 6),
          const Text(
            'Square HRMS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kNavy,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              iconSize: 30,
              onPressed: () {},
            ),
          ],
      bottom: showLoadingBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(kNavy),
              ),
            )
          : null,
    );
  }
}
