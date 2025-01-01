import 'package:fileflow/provider/security_provider.dart';
import 'package:fileflow/widget/debug_entry.dart';
import 'package:fileflow/widget/responsive_list_view.dart';
import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';

// This page provides debugging tools specifically for security-related contexts.
class SecurityDebugPage extends StatelessWidget {
  const SecurityDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watching the security context from the security provider.
    final securityContext = context.ref.watch(securityProvider);
    return Scaffold(
      appBar: AppBar(
        // Title for the AppBar of the Security Debug Page.
        title: const Text('Security Debugging'),
      ),
      body: ResponsiveListView(
        // Adding padding for better layout spacing.
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        // Setting a maximum width for responsive design.
        maxWidth: 700,
        children: [
          Row(
            children: [
              // Button to reset the security context asynchronously.
              FilledButton(
                onPressed: () async => await context.ref.redux(securityProvider).dispatchAsync(ResetSecurityContextAction()),
                child: const Text('Reset'),
              ),
            ],
          ),
          // Displaying the certificate fingerprint (SHA-256 hash).
          DebugEntry(
            name: 'Certificate SHA-256 (fingerprint)',
            value: securityContext.certificateHash,
          ),
          // Displaying the full certificate details.
          DebugEntry(
            name: 'Certificate',
            value: securityContext.certificate,
          ),
          // Displaying the private key of the security context.
          DebugEntry(
            name: 'Private Key',
            value: securityContext.privateKey,
          ),
          // Displaying the public key of the security context.
          DebugEntry(
            name: 'Public Key',
            value: securityContext.publicKey,
          ),
        ],
      ),
    );
  }
}
