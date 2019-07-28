import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/widgets/dialogs/EditSignatureDialog.dart';


class UserPage extends StatefulWidget {
    final int uid;

    UserPage({Key key, @required this.uid}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _UserPageState();

    static Future jump(BuildContext context, int uid) {
        return Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return UserPage(uid: uid);
        })).then((dynamic) {
            ThemeUtils.setDark(ThemeUtils.isDark);
        });
    }
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
    UserInfo _user;
    List<UserTag> _tags = [];
    Widget _post;
    String _fansCount, _idolsCount;
    int userLevel;

    bool isLoading = true;
    bool showTitle = false;
    bool refreshing = false;

    PostController postController;
    ScrollController _scrollController = ScrollController();
    double expandedHeight = kToolbarHeight + Constants.suSetSp(212.0);

    @override
    void initState() {
        super.initState();

        postController = PostController(
            postType: "user",
            isFollowed: false,
            isMore: false,
            lastValue: (int id) => id,
            additionAttrs: {'uid': widget.uid},
        );
        _post = PostList(postController, needRefreshIndicator: false);

        _fetchUserInformation(widget.uid);

        Constants.eventBus
            ..on<SignatureUpdatedEvent>().listen((event) {
                Future.delayed(Duration(milliseconds: 2400), () {
                    if (this.mounted) setState(() {
                        _user.signature = event.signature;
                    });
                });
            })
            ..on<AvatarUpdatedEvent>().listen((event) {
                UserAPI.updateAvatarProvider();
                _fetchUserInformation(widget.uid);
            });
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        _scrollController
            ..removeListener(listener)
            ..addListener(listener)
        ;
    }

    @override
    void dispose() {
        super.dispose();
        _scrollController?.dispose();
    }

    void listener() {
        setState(() {
            if (_scrollController.offset >= expandedHeight && !showTitle) {
                showTitle = true;
            } else if (_scrollController.offset < expandedHeight && showTitle) {
                showTitle = false;
            }
        });
    }

    Future<Null> _fetchUserInformation(uid) async {
        if (uid == UserAPI.currentUser.uid) {
            _user = UserAPI.currentUser;
        } else {
            Map<String, dynamic> user = (await UserAPI.getUserInfo(uid: uid)).data;
            _user = UserAPI.createUserInfo(user);
        }

        Future.wait(<Future>[
            UserAPI.getLevel(uid).then((response) {
                userLevel = int.parse(response.data['score']['levelinfo']['level'].toString());
            }),
            UserAPI.getTags(uid).then((response) {
                List tags = response.data['data'];
                List<UserTag> _userTags = [];
                tags.forEach((tag) {
                    _userTags.add(UserAPI.createUserTag(tag));
                });
                _tags = _userTags;
            }),
            _getCount(uid),
        ]).then((whatever) {
            if (mounted) {
                setState(() {
                    isLoading = false;
                    refreshing = false;
                });
            }
        });
    }

    Future<Null> _getCount(id) async {
        Map data = (await UserAPI.getFansAndFollowingsCount(id)).data;
        if (this.mounted) setState(() {
            _user.isFollowing = data['is_following'] == 1;
            _fansCount = data['fans'].toString();
            _idolsCount = data['idols'].toString();
        });
    }

    Widget followButton() => Padding(
        padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(4.0)),
        child: FlatButton(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(28.0),
                vertical: Constants.suSetSp(12.0),
            ),
            onPressed: () {
                if (widget.uid == UserAPI.currentUser.uid) {
                    showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) => EditSignatureDialog(_user.signature),
                    );
                } else {
                    if (_user.isFollowing) {
                        UserAPI.unFollow(widget.uid).then((response) {
                            setState(() {
                                _user.isFollowing = false;
                            });
                        });
                    } else {
                        UserAPI.follow(widget.uid).then((response) {
                            setState(() {
                                _user.isFollowing = true;
                            });
                        });
                    }
                }
            },
            color: widget.uid == UserAPI.currentUser.uid ? Color(0x44ffffff) :
            _user.isFollowing ? Color(0x44ffffff) : Color(ThemeUtils.currentThemeColor.value - 0x33000000),
            child: Text(
                widget.uid == UserAPI.currentUser.uid ? "编辑签名" :
                _user.isFollowing ? "已关注" : "关注${_user.gender == 2 ? "她" : "他"}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(18.0),
                ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.suSetSp(32.0)),
            ),
        ),
    );

    Widget qrCode(context) => Padding(
        padding: EdgeInsets.only(
            left: Constants.suSetSp(4.0),
        ),
        child: Container(
            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
            decoration: BoxDecoration(
                color: const Color(0x44ffffff),
                shape: BoxShape.circle,
            ),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Icon(
                    AntDesign.getIconData("qrcode"),
                    size: Constants.suSetSp(26.0),
                    color: Colors.white,
                ),
                onTap: () {
                    Navigator.of(context).pushNamed("/userqrcode");
                },
            ),
        ),
    );

    List<Widget> flexSpaceWidgets(context) => [
        Padding(
            padding: EdgeInsets.only(bottom: Constants.suSetSp(12.0)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    SizedBox(
                        width: Constants.suSetSp(100.0),
                        height: Constants.suSetSp(100.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(Constants.suSetSp(50.0)),
                            child: FadeInImage(
                                fadeInDuration: const Duration(milliseconds: 100),
                                placeholder: AssetImage("assets/avatar_placeholder.png"),
                                image: UserAPI.getAvatarProvider(uid: _user.uid),
                            ),
                        ),
                    ),
                    Expanded(child: SizedBox()),
                    followButton(),
                    if (widget.uid == UserAPI.currentUser.uid) qrCode(context),
                ],
            ),
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Text(
                    _user.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.suSetSp(24.0),
                        fontWeight: FontWeight.bold,
                    ),
                ),
                Constants.emptyDivider(width: 8.0),
                DecoratedBox(
                    decoration: BoxDecoration(
                        color: _user.gender == 2 ? Colors.pinkAccent : Colors.blueAccent,
                        shape: BoxShape.circle,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(3.0)),
                        child: SvgPicture.asset(
                            "assets/icons/gender/${_user.gender == 2 ? "fe" : ""}male.svg",
                            width: Constants.suSetSp(16.0),
                            height: Constants.suSetSp(16.0),
                            color: Colors.white,
                        ),
                    ),
                ),
                Constants.emptyDivider(width: 8.0),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(8.0),
                        vertical: Constants.suSetSp(4.0),
                    ),
                    decoration: BoxDecoration(
                        color: ThemeUtils.defaultColor,
                        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                    ),
                    child: Text(
                        " Lv.$userLevel",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(14.0),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                        ),
                    ),
                ),
                if (Constants.developerList.contains(_user.uid)) Constants.emptyDivider(width: 8.0),
                if (Constants.developerList.contains(_user.uid)) Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(8.0),
                        vertical: Constants.suSetSp(4.0),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                    ),
                    child: Text(
                        "# OpenJMU Team #",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(14.0),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                        ),
                    ),
                ),
            ],
        ),
        Text(
            _user.signature ?? "这个人很懒，什么都没写",
            style: TextStyle(
                color: Colors.grey[350],
                fontSize: Constants.suSetSp(16.0),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return UserListPage(_user, 1);
                        }));
                    },
                    child: RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: _idolsCount,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Constants.suSetSp(24.0),
                                    ),
                                ),
                                TextSpan(
                                    text: " 关注",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(18.0),
                                    ),
                                ),
                            ]
                    )),
                ),
                Constants.emptyDivider(width: 12.0),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return UserListPage(_user, 2);
                        }));
                    },
                    child: RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: _fansCount,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Constants.suSetSp(24.0),
                                    ),
                                ),
                                TextSpan(
                                    text: " 粉丝",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(18.0),
                                    ),
                                ),
                            ]
                    )),
                ),
            ],
        ),
        _tags?.length != 0
                ?
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: <Widget>[
                    for (int i = 0; i < _tags.length; i++) Container(
                        margin: EdgeInsets.only(right: Constants.suSetSp(12.0)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.suSetSp(8.0),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0x44ffffff),
                                ),
                                child: Text(
                                    _tags[i].name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(16.0),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        )
                :
        Text(
            "${_user.gender == 2 ? "她" : "他"}还没有设置个性标签",
            style: TextStyle(
                color: Colors.grey[350],
                fontSize: Constants.suSetSp(16.0),
            ),
        )
        ,
    ];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: isLoading
                    ?
            Center(child: CircularProgressIndicator())
                    :
            NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
                    SliverAppBar(
                        title: showTitle ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: () {
                                _scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                );
                            },
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    SizedBox(
                                        width: Constants.suSetSp(40.0),
                                        height: Constants.suSetSp(40.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                                            child: FadeInImage(
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholder: AssetImage("assets/avatar_placeholder.png"),
                                                image: UserAPI.getAvatarProvider(uid: widget.uid),
                                            ),
                                        ),
                                    ),
                                    Constants.emptyDivider(width: 8.0),
                                    Text(
                                        _user.name,
                                        style: Theme.of(context).textTheme.title.copyWith(
                                            fontSize: Constants.suSetSp(21.0),
                                        ),
                                    ),
                                ],
                            ),
                        ) : null,
                        actions: <Widget>[
                            refreshing ? Container(
                                width: 56.0,
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        !showTitle ? Colors.white : Theme.of(context).iconTheme.color,
                                    ),
                                ),
                            ) : IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () {
                                    _scrollController.animateTo(
                                        0.0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                    );
                                    Future.delayed(Duration(milliseconds: 300), () {
                                        setState(() {
                                            refreshing = true;
                                        });
                                        postController.reload();
                                        _fetchUserInformation(widget.uid);
                                    });
                                },
                            ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                                children: <Widget>[
                                    SizedBox(
                                        width: double.infinity,
                                        child: Image(
                                            image: UserAPI.getAvatarProvider(uid: widget.uid),
                                            fit: BoxFit.fitWidth,
                                            width: MediaQuery.of(context).size.width,
                                        ),
                                    ),
                                    BackdropFilter(
                                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                        child: Container(
                                            color: Color.fromARGB(120, 50, 50, 50),
                                        ),
                                    ),
                                    SafeArea(
                                        top: true,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(20.0)),
                                            child: Column(
                                                children: <Widget>[
                                                    Constants.emptyDivider(
                                                        height: kToolbarHeight + 4.0,
                                                    ),
                                                    ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: flexSpaceWidgets(context).length,
                                                        itemBuilder: (BuildContext context, int index) => Padding(
                                                            padding: EdgeInsets.only(bottom: Constants.suSetSp(12.0)),
                                                            child: flexSpaceWidgets(context)[index],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        expandedHeight: kToolbarHeight + expandedHeight,
                        iconTheme: !showTitle
                                ?
                        Theme.of(context).iconTheme.copyWith(
                            color: Colors.white,
                        )
                                :
                        Theme.of(context).iconTheme
                        ,
                        primary: true,
                        centerTitle: true,
                        floating: true,
                        pinned: true,
                    ),
                ],
                body: _post,
            ),
        );
    }
}


class UserListPage extends StatefulWidget {
    final UserInfo user;
    final int type; // 0 is search, 1 is idols, 2 is fans.

    UserListPage(this.user, this.type, {Key key}) : super(key: key);

    @override
    State createState() => _UserListState();
}

class _UserListState extends State<UserListPage> {
    List _users = [];

    bool canLoadMore = false, isLoading = true;
    int total, pages = 1;

    @override
    void initState() {
        super.initState();
        doUpdate(false);
    }

    void doUpdate(isMore) {
        if (isMore) pages++;
        switch (widget.type) {
            case 1:
                getIdolsList(pages, isMore);
                break;
            case 2:
                getFansList(pages, isMore);
                break;
        }
    }

    void getIdolsList(page, isMore) {
        UserAPI.getIdolsList(widget.user.uid, page).then((response) {
            setUserList(response, isMore);
        });
    }

    void getFansList(page, isMore) {
        UserAPI.getFansList(widget.user.uid, page).then((response) {
            setUserList(response, isMore);
        });
    }

    void setUserList(response, isMore) {
        List data;
        switch (widget.type) {
            case 1:
                data = response.data['idols'];
                break;
            case 2:
                data = response.data['fans'];
                break;
        }
        int total = int.parse(response.data['total'].toString());
        if (_users.length + data.length < total) canLoadMore = true;
        List users = [];
        for (int i = 0; i < data.length; i++) users.add(data[i]);
        if (mounted) setState(() {
            if (isMore) {
                List _u = _users;
                _u.addAll(users);
                _users = _u;
            } else {
                _users = users;
            }
            isLoading = false;
        });
    }

    Widget renderRow(context, i) {
        int start = i * 2;
        if (_users != null && i + 1 == (_users.length / 2).ceil() && canLoadMore) doUpdate(true);
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
                for (int j = start; j < start + 2 && j < _users.length; j++) userCard(context, _users[j])
            ],
        );
    }

    Widget userCard(context, userData) {
        var _user = userData['user'];
        String name = _user['nickname'];
        if (name.length > 3) name = "${name.substring(0, 3)}...";
        TextStyle _textStyle = TextStyle(fontSize: Constants.suSetSp(16.0));
        return GestureDetector(
            onTap: () => UserPage.jump(context, int.parse(_user['uid'].toString())),
            child: Container(
                margin: EdgeInsets.fromLTRB(
                    Constants.suSetSp(12.0),
                    Constants.suSetSp(20.0),
                    Constants.suSetSp(12.0),
                    Constants.suSetSp(0.0),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.suSetSp(20.0),
                    vertical: Constants.suSetSp(12.0),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(16.0)),
                    color: Theme.of(context).canvasColor,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Container(
                            width: Constants.suSetSp(64.0),
                            height: Constants.suSetSp(64.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(Constants.suSetSp(32.0)),
                                child: FadeInImage(
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholder: AssetImage("assets/avatar_placeholder.png"),
                                    image: UserAPI.getAvatarProvider(uid: int.parse(_user['uid'].toString())),
                                ),
                            ),
                        ),
                        SizedBox(width: Constants.suSetSp(12.0)),
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Column(
                                    children: <Widget>[
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                                Text(
                                                    name,
                                                    style: TextStyle(fontSize: Constants.suSetSp(20.0)),
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                        ),
                                        Divider(height: Constants.suSetSp(6.0)),
                                        Row(
                                            children: <Widget>[
                                                Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                        Text("关注", style: _textStyle),
                                                        Divider(height: Constants.suSetSp(4.0)),
                                                        Text(userData['idols'], style: _textStyle),
                                                    ],
                                                ),
                                                SizedBox(width: Constants.suSetSp(6.0)),
                                                Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                        Text("粉丝", style: _textStyle),
                                                        Divider(height: Constants.suSetSp(4.0)),
                                                        Text(userData['fans'], style: _textStyle),
                                                    ],
                                                )
                                            ],
                                        )
                                    ],
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        String _type;
        switch (widget.type) {
            case 0:
                _type = "用户";
                break;
            case 1:
                _type = "关注";
                break;
            case 2:
                _type = "粉丝";
                break;
        }
        return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text(
                    "$_type列表",
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                ),
            ),
            body: !isLoading
                    ? _users.length != 0
                    ? ListView.builder(
                shrinkWrap: true,
                itemCount: (_users.length / 2).ceil(),
                itemBuilder: (context, i) => renderRow(context, i),
            )
                    : Center(child: Text("暂无内容", style: TextStyle(fontSize: Constants.suSetSp(20.0))))
                    : Center(
                child: CircularProgressIndicator(),
            ),
        );
    }
}
