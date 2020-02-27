import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'refreshable_list.dart';
import 'base_footer.dart';

class SimpleLoadFooter extends BaseFooter {
  SimpleLoadFooter(double footerHeight,{Key key}) :
      super(footerHeight,key: key);

  @override
  State<StatefulWidget> createState() => SimpleLoadFooterState();

}

class SimpleLoadFooterState extends BaseFooterState<SimpleLoadFooter> {
  LoadStatus status = LoadStatus.IDLE;

  @override
  void initFields() {
  }

  @override
  Widget build(BuildContext context) =>
    Container(
      height: widget.footerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getIcon(),
          SizedBox(width: 15,),
          Text(_getText(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.black45
          ),)
        ],
      ),
    );

  Widget _getIcon() {
    if (status == LoadStatus.LOADED) {
      return Icon(
        Icons.check,
        size: 20,
        color: Colors.black45,
      );
    } else {
      return SizedBox(
        child: CupertinoActivityIndicator(),
        height: 20,
        width: 20,
      );
    }
  }

  String _getText() {
    if(status== LoadStatus.LOADED){
      return '加载完成';
    }else {
      return '正在加载...';
    }
  }

  @override
  void onScrollStatusChanged(LoadStatus status) {
    setState(() {
      this.status=status;
    });
  }

  @override
  void updateFooter(v) {
  }
}
