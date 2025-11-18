import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/context_extensions.dart';
import 'legal_view_shell.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return LegalViewShell(
      title: loc.termsViewTitle,
      backLabel: loc.genericBack,
      onBack: () => context.go('/settings'),
      sections: [
        LegalSectionData(
          title: loc.termsViewIntroTitle,
          body: loc.termsViewIntroBody,
        ),
        LegalSectionData(
          title: loc.termsViewContentTitle,
          body: loc.termsViewContentBody,
        ),
        LegalSectionData(
          title: loc.termsViewWarrantyTitle,
          body: loc.termsViewWarrantyBody,
        ),
        LegalSectionData(
          title: loc.termsViewUpdatesTitle,
          body: loc.termsViewUpdatesBody,
        ),
      ],
    );
  }
}
