import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/context_extensions.dart';
import 'legal_view_shell.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return LegalViewShell(
      title: loc.privacyViewTitle,
      backLabel: loc.genericBack,
      onBack: () => context.go('/settings'),
      sections: [
        LegalSectionData(
          title: loc.privacyViewIntroTitle,
          body: loc.privacyViewIntroBody,
        ),
        LegalSectionData(
          title: loc.privacyViewDataTitle,
          body: loc.privacyViewDataBody,
        ),
        LegalSectionData(
          title: loc.privacyViewControlTitle,
          body: loc.privacyViewControlBody,
        ),
        LegalSectionData(
          title: loc.privacyViewContactTitle,
          body: loc.privacyViewContactBody,
        ),
      ],
    );
  }
}
