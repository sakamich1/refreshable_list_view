import 'package:flutter/cupertino.dart';

import 'src/base_header.dart';

abstract class BaseRefreshList extends StatefulWidget {
  final Refresh onRefresh;
  final Refresh onLoadMore;

  BaseRefreshList({this.onRefresh,this.onLoadMore});
}

abstract class BaseRefreshListState<T extends BaseRefreshList>
  extends State<T> {

  @protected
  ScrollController scrCtr;

  @protected
  double currScrolled;

  double headerHeight;

  LoadStatus status = LoadStatus.IDLE;


  @override
  void initState() {
    super.initState();
    headerHeight = getHeader().headerHeight;
    initFields();
  }

  Future refreshing() {
    refreshHook();
    return widget.onRefresh();
  }

  void initFields();


  BaseHeader getHeader();

  void hideHeaderSmoothly({int duration});

  void onPointerUp(PointerUpEvent event);

  void onScrollStart(ScrollMetrics metrics);

  void onScrolling(ScrollMetrics metrics);

  void onScrollEnd(ScrollMetrics metrics);

  //刷新时的钩子方法
  void refreshHook();
  
  void onRefreshed();
}

enum LoadStatus {
  IDLE,
  REFRESHING,
  REFRESHED,
  LOADING,
  LOADED
}