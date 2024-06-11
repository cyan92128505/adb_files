import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/file_item.dart';
import '../models/app_state_manager.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateManager>();

    return state.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: state.files.length,
              itemBuilder: (context, i) => FileItem(
                file: state.files[i],
              ),
              // crossAxisSpacing: 3.0,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 136.0,
              ),
              // )
            ),
          );
  }
}
