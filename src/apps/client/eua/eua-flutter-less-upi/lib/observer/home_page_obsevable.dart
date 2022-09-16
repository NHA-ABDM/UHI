import 'package:uhi_flutter_app/observer/home_page_observer.dart';
import 'package:uhi_flutter_app/observer/observable.dart';

class HomeScreenObservable implements Observable<HomePageObserver> {
  static List<HomePageObserver> listHomePageObserver = <HomePageObserver>[];

  @override
  void register(HomePageObserver observer) {
    if (!listHomePageObserver.contains(observer)) {
      listHomePageObserver.add(observer);
    }
  }

  @override
  void unRegister(HomePageObserver observer) {
    if (listHomePageObserver.contains(observer)) {
      listHomePageObserver.remove(observer);
    }
  }

  void notifyUpdateAppointmentData() {
    for (HomePageObserver observer in listHomePageObserver) {
      observer.updateAppointmentData();
    }
  }
}
