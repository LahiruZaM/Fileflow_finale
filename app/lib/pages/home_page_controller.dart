import 'package:fileflow/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';

// ViewModel for the Home Page
class HomePageVm {
  final PageController controller; // Manages transitions between pages in the PageView
  final HomeTab currentTab; // Represents the currently selected tab
  final void Function(HomeTab) changeTab; // Function to handle tab changes

  HomePageVm({
    required this.controller,
    required this.currentTab,
    required this.changeTab,
  });
}

// Provider for HomePageController, connecting the controller to the state management system
final homePageControllerProvider = ReduxProvider<HomePageController, HomePageVm>(
  (ref) => HomePageController(),
);

// Controller for managing the logic and state of the Home Page
class HomePageController extends ReduxNotifier<HomePageVm> {
  @override
  HomePageVm init() {
    // Initialize the ViewModel with default values
    return HomePageVm(
      controller: PageController(), // Initializes the PageController for page navigation
      currentTab: HomeTab.receive, // Sets the default tab to 'receive'
      changeTab: (tab) => redux.dispatch(ChangeTabAction(tab)), // Dispatches an action to change the tab
    );
  }
}

// Action for changing the current tab on the Home Page
class ChangeTabAction extends ReduxAction<HomePageController, HomePageVm> {
  final HomeTab tab; // The tab to switch to

  ChangeTabAction(this.tab);

  @override
  HomePageVm reduce() {
    // Perform the tab change by updating the PageController's page index
    state.controller.jumpToPage(tab.index);

    // Return a new ViewModel with the updated current tab
    return HomePageVm(
      controller: state.controller,
      currentTab: tab,
      changeTab: state.changeTab,
    );
  }
}
