import 'package:flutter/cupertino.dart';

import 'refreshable_list.dart';


abstract class BaseFooter extends StatefulWidget {
  final double footerHeight;

  BaseFooter(this.footerHeight,{Key key}) :super(key: key);
}

abstract class BaseFooterState<T extends BaseFooter> extends State<T> {

  @override
  void initState() {
    super.initState();
    initFields();
  }

  @protected
  void initFields();

  void updateFooter(v);

  void onScrollStatusChanged(LoadStatus status);

}