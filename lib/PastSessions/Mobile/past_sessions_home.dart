import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../General/Providers/internal_app_providers.dart';
import '../../General/Variables/globalvariables.dart';
import '../../General/Widgets/widgets.dart';
import '../../HomePage/home_page.dart';

class PastSessionsHome extends StatefulWidget {
  const PastSessionsHome({super.key});

  @override
  State<PastSessionsHome> createState() => _PastSessionsHomeState();
}

class _PastSessionsHomeState extends State<PastSessionsHome> {

  // --------------------------------------------------------------
  // Reset and Navigate back
  Future<void> _resetAndNavigateBack() async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    internalStatusProvider.setRecordingSessionUID(null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context,
          automaticallyImplyLeading: true,
          onPressed: () {
            _resetAndNavigateBack();
          },
          isAdmin: false,
          isModerator: false,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              body(
                header: '© ${DateTime.now().year} seevinckserver.com',
                color: localAppTheme['anchorColors']['primaryColor'],
                context: context,
              ),
              body(
                header: appInfo['version'] != null
                    ? 'v${appInfo['version']}'
                    : '',
                color: localAppTheme['anchorColors']['primaryColor'],
                context: context,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            pageHeaderImage(
                imagePath: 'images/pastsessions.png',
                context: context,
                toolTip: '',
                userProfileToShow: {},
                pageTitle: 'PAST SESSIONS'
            ),
            Container(
              width: double.infinity,
              //height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
