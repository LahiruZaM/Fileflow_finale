import 'package:flutter/material.dart';
import 'package:fileflow/widget/local_send_logo.dart';
import 'package:fileflow/widget/responsive_list_view.dart';
import 'package:fileflow/gen/strings.g.dart';

class AboutPage extends StatelessWidget {
  const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          // FileFlow Logo with text
          const FileFlowLogo(withText: true),
          const SizedBox(height: 20),
          // Description text
          Text(t.aboutPage.description.join('\n\n')),
        ],
      ),
    );
  }
}
