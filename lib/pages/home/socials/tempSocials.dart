import 'dart:math';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/postModel.dart';

class TempSocials extends StatefulWidget {
  final String uid;
  const TempSocials({super.key, required this.uid});

  @override
  State<TempSocials> createState() => _TempSocialsState();
}

class _TempSocialsState extends State<TempSocials> {
  @override
  Widget build(BuildContext context) {
    List<PostModel>? friendsPosts = Provider.of<List<PostModel>?>(context);

    if (friendsPosts != null) {
      print(friendsPosts.map((e) {
        print("\n\n==== POST ====");
        print(e.caption);
        print(e.date);
        print(e.id);
        print(e.imageURL);
        print(e.isEdited);
      }));
    }

    return const Placeholder();
  }
}
