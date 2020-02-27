import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'refreshable_list.dart';
import 'base_header.dart';


class SimpleRefreshHeader extends BaseHeader {

  SimpleRefreshHeader(double headerHeight,{Key key})
    : super(headerHeight,key: key);

  @override
  State<StatefulWidget> createState() => SimpleRefreshHeaderState();
}

class SimpleRefreshHeaderState extends BaseHeaderState<SimpleRefreshHeader>
  with SingleTickerProviderStateMixin {

  AnimationController _animationCtr;
  Animation _animation;
  bool isRotating = false;
  double currScrolled;
  LoadStatus status = LoadStatus.IDLE;
  String lastUpdate = '上次更新 -';

  @override
  void initFields() {
    currScrolled = widget.headerHeight;
    _animationCtr = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    _animation = Tween(begin: 0.0,end: 0.5).animate(_animationCtr)
      ..addStatusListener((status) {
        isRotating = status == AnimationStatus.forward ||
          status == AnimationStatus.reverse;
      });
  }

  @override
  Widget build(BuildContext context) =>
    Container(
      height: widget.headerHeight,
      child: Align(
        alignment: Alignment(-0.2,0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getIcon(), //计算此处使用的图标
            SizedBox(width: 15,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_getTitleText(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45
                  ),),
                Text(_getUpdateTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45
                  ),)
              ],
            ),
          ],
        ),
      )
    );

  //根据刷新状态获取图标
  Widget _getIcon() {
    if (status == LoadStatus.REFRESHING) {
      return SizedBox(
        child: CupertinoActivityIndicator(
         // valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
         // backgroundColor: Colors.white,
        ),
        height: 20,
        width: 20,
      );
    } else if (status == LoadStatus.REFRESHED) {
      return Icon(
        Icons.check,
        size: 20,
        color: Colors.black45,
      ); //隐藏进度条 返回一个空盒子
    } else {
      return RotationTransition(
        turns: _animation,
        child: Icon(
          Icons.arrow_downward,
          size: 28,
          color: Colors.black45,
        ),
      );
    }
  }

  String _getTitleText() {
    if (status == LoadStatus.REFRESHED) {
      return '刷新完成';
    } else if (status == LoadStatus.REFRESHING) {
      return '正在刷新...';
    } else {
      return currScrolled > 0 ? '下拉可以刷新' : '释放立即刷新';
    }
  }

  String _getUpdateTime() {
    if (status == LoadStatus.REFRESHED) {
      var now = DateTime.now();
      var formatter = DateFormat('MM-dd HH:mm');
      lastUpdate = '上次更新 ${formatter.format(now)}';
    }
    return lastUpdate;
  }

  @override
  void updateHeader(v) {
    setState(() {
      currScrolled = v as double;
    });
    if (currScrolled <= 0) {
      _animationCtr.forward();
    }

    if (currScrolled > widget.headerHeight / 4
      && currScrolled < widget.headerHeight) {
      if (!isRotating) { //避免动画反复执行
        _animationCtr.reverse();
      }
    }
  }

  @override
  void onScrollStatusChanged(LoadStatus status) {
    setState(() {
      this.status = status;
    });
  }
}