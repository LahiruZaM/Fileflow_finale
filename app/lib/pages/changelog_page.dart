import 'package:fileflow/gen/assets.gen.dart';
import 'package:fileflow/gen/strings.g.dart';
import 'package:fileflow/util/ui/nav_bar_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.changelogPage.title),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString(Assets.changelog), // ignore: discarded_futures
        builder: (context, data) {
          if (!data.hasData) {
            return Container();
          }
          return Markdown(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 15 + getNavBarPadding(context),
            ),
            data: data.data!,
          );
        },
      ),
    );
  }
}
