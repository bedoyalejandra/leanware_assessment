import 'package:flutter/material.dart';
import 'package:leanware_assessment/models/call_history.dart';
import 'package:leanware_assessment/utils/functions/relative_time_util.dart';

class CallTile extends StatelessWidget {
  CallHistoryModel call;

  CallTile({
    super.key,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        call.incoming ? Icons.call_received : Icons.call_made,
        color: call.incoming
            ? Colors.deepPurple.shade700
            : Colors.deepPurple.shade400,
      ),
      title: Text(call.id ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Duración: ${formatSeconds(call.duration)}"),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_outlined, color: Colors.deepPurple),
          Text(getRelativeTime(call.date),
              style: TextStyle(color: Colors.grey)),
        ],
      ),
      onTap: () {},
    );
  }
}
