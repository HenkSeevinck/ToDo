import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/appuser_provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/General/Variables/globalvariables';
import 'package:todo_list/General/Widgets/widgets.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  static const double _iconSize = 150;
  //LandingView _view = LandingView.landing;

  //------------------------------------------------------------------------------
  // Shared Grid Builder for Athlete and Coach Sections
  Widget _buildSectionGrid({required BuildContext context, required List<Map<String, dynamic>> options, required String userUid}) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        const crossAxisCount = 2;
        final tileWidth = width / crossAxisCount;
        final rowsNeeded = (options.length / crossAxisCount).ceil();
        final rowsToShow = rowsNeeded < 1 ? 1 : (rowsNeeded > 3 ? 3 : rowsNeeded);
        final tileHeight = height / rowsToShow;
        final aspectRatio = tileWidth / tileHeight;

        return SizedBox(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: aspectRatio),
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  internalStatusProvider.setUserUIDToShow(userUid);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => options[index]['navigateTo']));
                },
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10.0,
                    left: index % 2 == 0 ? 0.0 : 5.0,
                    right: index % 2 == 0 ? 5.0 : 0.0,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          options[index]['image'],
                          width: _iconSize,
                          height: _iconSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              options[index]['icon'],
                              size: _iconSize,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: localAppTheme['anchorColors']['secondaryColor'].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                        ),
                        child: Center(
                          child: header2(header: options[index]['pageName'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //------------------------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppuserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final homePageOptions = internalStatusProvider.homePageOptions;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context, 
          automaticallyImplyLeading: false, 
          onPressed: null, 
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
                context: context
              ),
              body(
                header: appInfo['version'] != null ? 'v${appInfo['version']}' : '', 
                color: localAppTheme['anchorColors']['primaryColor'], 
                context: context
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                  ),
                ),
                child: _buildSectionGrid(context: context, options: homePageOptions, userUid: appUser['id'] ?? ''),
              ),
            )
          ],
        ),
      ),
    );
  }
}
