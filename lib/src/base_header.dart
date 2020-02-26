import 'package:flutter/cupertino.dart';

import '../refreshable_list.dart';

typedef Future Refresh();

abstract class BaseHeader extends StatefulWidget {
  final double headerHeight;

  BaseHeader(this.headerHeight,{Key key}) :super(key: key);
}

abstract class BaseHeaderState<T extends BaseHeader> extends State<T> {

  @override
  void initState() {
    super.initState();
    initFields();
  }

  @protected
  void initFields();

  void updateHeader(v);
  
  void onScrollStatusChanged(LoadStatus status);

}