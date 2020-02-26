import 'package:flutter/cupertino.dart';
import 'package:refreshable_list/src/base_footer.dart';
import 'package:refreshable_list/src/base_header.dart';

abstract class BaseRefreshList extends StatefulWidget {
  final Refresh onRefresh;
  final Refresh onLoadMore;

  BaseRefreshList({this.onRefresh,this.onLoadMore});
}

abstract class BaseRefreshListState<W extends BaseRefreshList,H extends BaseHeaderState,F extends BaseFooterState>
  extends State<W> {

  @protected
  ScrollController scrCtr;

  @protected
  double currScrolled;

  double headerHeight;

  double footerHeight;

  double maxScrollExtent;

  LoadStatus status = LoadStatus.IDLE;

  bool isFreeScrolling = false;

  GlobalKey<H> headerKey = GlobalKey<H>();

  GlobalKey<F> footerKey = GlobalKey<F>();

  @override
  Widget build(BuildContext context) =>
    Container(
      padding: EdgeInsets.fromLTRB(10,0,10,0),
      child: Listener(
        onPointerUp: onPointerUp,
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              onScrollStart(notification.metrics);
            } else if (notification is ScrollUpdateNotification) {
              onScrolling(notification.metrics);
            } else if (notification is ScrollEndNotification) {
              onScrollEnd(notification.metrics);
            }
            return true;
          },
          child: CustomScrollView(
            controller: scrCtr,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: getHeader(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  getItem,
                  childCount: getItemCount(),
                ),
              ),
              SliverToBoxAdapter(
                child: getFooter(),
              )
            ],
          ),
        )
      )
    );


  @override
  void initState() {
    super.initState();
    headerHeight = getHeader().headerHeight;
    footerHeight = getFooter().footerHeight;

    currScrolled = headerHeight;
    scrCtr = ScrollController(
      initialScrollOffset: headerHeight //初始滚动到的位置
    );

    initFields();
  }

  Widget getItem(BuildContext context,int index);

  int getItemCount();

  @mustCallSuper
  Future refreshing() {
    setState(() {
      status = LoadStatus.REFRESHING;
      headerKey.currentState.onScrollStatusChanged(status);
      footerKey.currentState.onScrollStatusChanged(status);
    });
    refreshHook();
    return widget.onRefresh();
  }

  @mustCallSuper
  Future loading() {
    setState(() {
      status = LoadStatus.LOADING;
      headerKey.currentState.onScrollStatusChanged(status);
      footerKey.currentState.onScrollStatusChanged(status);
    });
    //loadHook();
    return widget.onLoadMore();
  }

  void initFields() {
  }

  BaseHeader getHeader();

  BaseFooter getFooter();

  Future _hideHeaderSmoothly({int duration = 100}) =>
    scrCtr.animateTo(
      headerHeight,duration: Duration(milliseconds: duration),
      curve: Curves.decelerate);

  Future _hideFooterSmoothly({int duration = 100}) =>
    scrCtr.animateTo(
      maxScrollExtent - footerHeight,duration: Duration(milliseconds: duration),
      curve: Curves.decelerate);

  @mustCallSuper
  void onPointerUp(PointerUpEvent event) {
    isFreeScrolling = true;
    //释放刷新
    if (currScrolled < headerHeight && currScrolled > 0) {
      _hideHeaderSmoothly();
    } else if (currScrolled <= 0) {
      //走刷新方法
      refreshing().then((value) {
        onRefreshed();
      });
    }

    //释放加载

    if (currScrolled > maxScrollExtent - footerHeight &&
      currScrolled <= maxScrollExtent) {
      //滚动到底无论手指是否抬起都开始加载
    }
  }

  @mustCallSuper
  void onScrollStart(ScrollMetrics metrics) {
    //获取listView最大滚动距离（高度）
    maxScrollExtent = metrics.maxScrollExtent;
  }

  @mustCallSuper
  void onScrolling(ScrollMetrics metrics) {
    //当前滑动高度传给header
    currScrolled = metrics.pixels;
    headerKey.currentState.updateHeader(currScrolled);

    if (currScrolled < headerHeight && currScrolled > 0) {
      if (isFreeScrolling) { //快速滚动的时候不会露出header（释放刷新的时候不会瞬间回弹）
        scrCtr.jumpTo(headerHeight);
      }
    }

    if (currScrolled == maxScrollExtent) {
      //走加载方法
      loading().then((value) {
        onLoaded();
      });
    }
  }

  @mustCallSuper
  void onScrollEnd(ScrollMetrics metrics) {
    isFreeScrolling = false;

    print('end max -> $currScrolled');
  }

  //刷新时的钩子方法
  void refreshHook() {
  }

  //加载时的钩子方法
  void loadHook() {
  }

  @mustCallSuper
  void onRefreshed() {
    //状态设为刷新完成并通知外部
    status = LoadStatus.REFRESHED;
    headerKey.currentState.onScrollStatusChanged(status);
    footerKey.currentState.onScrollStatusChanged(status);
    //停顿一下并缩回header
    Future.delayed(Duration(milliseconds: 500))
      .then((_) => _hideHeaderSmoothly())
      .whenComplete(() { //等回弹动画执行完后再把状态更新成idle
      status = LoadStatus.IDLE;
      headerKey.currentState.onScrollStatusChanged(status);
      footerKey.currentState.onScrollStatusChanged(status);
    });
  }

  @mustCallSuper
  void onLoaded() {
    //状态设为加载完成并通知外部
    status = LoadStatus.LOADED;
    headerKey.currentState.onScrollStatusChanged(status);
    footerKey.currentState.onScrollStatusChanged(status);
    //停顿一下并缩回footer
    print('new max -> $maxScrollExtent');
    Future.delayed(Duration(milliseconds: 500))
      .then((_) {
      status = LoadStatus.IDLE;
      headerKey.currentState.onScrollStatusChanged(status);
      footerKey.currentState.onScrollStatusChanged(status);
    })
      .whenComplete(() { //等回弹动画执行完后再把状态更新成idle
      /*status = LoadStatus.IDLE;
      headerKey.currentState.onScrollStatusChanged(status);
      footerKey.currentState.onScrollStatusChanged(status);*/
    });
  }
}

enum LoadStatus {
  IDLE,
  REFRESHING,
  REFRESHED,
  LOADING,
  LOADED
}