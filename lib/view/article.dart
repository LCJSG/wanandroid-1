import 'package:flutter/material.dart';
import 'package:wanandroid/entity/home_article_entity.dart';
import 'package:wanandroid/view/article_detail.dart';
import 'package:wanandroid/viewModel/banner_viewmodel.dart';
import 'package:wanandroid/viewModel/collect_article_viewmodel.dart';
import 'package:wanandroid/viewModel/home_article_viewmodel.dart';
import 'package:wanandroid/widget/recycle_view.dart';
import 'package:wanandroid/res/constant.dart';
import 'package:wanandroid/widget/cycle_view.dart';
import 'package:wanandroid/entity/banner_entity.dart';
import 'package:wanandroid/util/utils.dart';

class ArticlePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Article();
}

class _Article extends State<ArticlePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  //初始页数从0开始.
  static const int _initPageCount = 0;

  List<HomeArticleEntity> lists = [];
  List<BannerEntity> banners = [];
  HomeArticleViewModel _viewModel = HomeArticleViewModel();
  CollectArticleViewModel _collectViewModel;
  BannerViewModel _bannerViewModel;
  int _currentPage = _initPageCount;

  ScrollController _scrollController = new ScrollController();
  bool _isPerformingRequest = false;

  Key _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLogin = false;

  @override
  void initState() {
    _collectViewModel = new CollectArticleViewModel();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isPerformingRequest) {
          setState(() {
            _isPerformingRequest = true;
          });
          _viewModel.getArticles(++_currentPage);
        }
      }
    });
    super.initState();
    _viewModel.getArticles(_currentPage);
    _bannerViewModel = BannerViewModel(
            (list) {
          _buildBanner(list);
        });
    _bannerViewModel.getBanners();

    _getLoginState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _bannerViewModel.dispose();
    _collectViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _viewModel.articles,
      builder: (context, snap) {
        lists = snap.data != null ? snap.data : [];
        return Scaffold(
          key: _scaffoldKey,
          body: RecycleView<HomeArticleEntity>(
            lists: lists,
            loadMore: () {
              _loadData(++_currentPage);
            },
            refresh: () {
              _currentPage = _initPageCount;
              _loadData(_currentPage);
            },
            itemCount: lists.length + 1,
            listBuilder: _createBuilder,
          ),
        );
      },
    );
  }

  Widget _createBuilder(BuildContext context, int index) {
    if (index == 0) {
      List<CycleImageEntity> imgs = new List();
      if (banners != null) {
        for (BannerEntity banner in banners) {
          CycleImageEntity entity = new CycleImageEntity();
          entity.cycleContent = banner.title;
          entity.imageUrl = banner.imgUrl;
          imgs.add(entity);
        }
      }
      return Container(
        height: 200.0,
        child: CycleView(imgs, onPageClicked: (index) {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (buildContext) =>
                  ArticleDetail(
                    detailUrl: banners[index].articleUrl,
                    articleTitle: banners[index].title,
                  )));
        }, autoScroll: true,),
      );
    } else {
      HomeArticleEntity article = lists[_getRealIndex(index)];
      return GestureDetector(
          onTap: () => _itemClicked(_getRealIndex(index)),
          child: Card(
            elevation: Values.card_elevation,
            child: Container(
                child: Container(
                  padding: EdgeInsets.only(left: Values.horizontal_padding,
                      right: Values.horizontal_padding),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(6.0),
                              ),
                              Text(
                                article.articleTitle,
                                softWrap: true,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Values.title_font_size),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  new Expanded(
                                    child: new RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: "作者:  ",
                                                style:
                                                DefaultTextStyle
                                                    .of(context)
                                                    .style),
                                            TextSpan(
                                                text: article.author,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15.0))
                                          ],
                                        )),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "发布时间:  ",
                                      style: DefaultTextStyle
                                          .of(context)
                                          .style,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: article.times,
                                            style: TextStyle(
                                                color: Colors.black))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5.0))
                            ],
                          )),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.favorite_border),
                          color: article.collect ? Colors.red : Colors.black,
                          onPressed: () =>
                              _collect(article.courseId, _getRealIndex(index)),
                        ),
                      )
                    ],
                  ),
                )),
          ));
    }
  }

  _buildBanner(List<BannerEntity> list) {
    setState(() {
      banners = list;
    });
  }

  _collect(int courseId, int index) {
    if (_isLogin) {
      int articleId = lists[index].id;
      int originId = lists[index].originId;
      if (!lists[index].collect) {
        _doCollect(articleId, index);
      } else {
        Utils.showSnackBar("已经收藏了", _scaffoldKey);
      }
    } else {
      Utils.showSnackBar("需要先登录", _scaffoldKey);
    }
  }

  _doCollect(int articleId, int index) {
    _collectViewModel.doCollect(articleId, () {
      setState(() {
        lists[index].collect = true;
      });
    }, () {});
  }

  _itemClicked(int index) {
    String title = lists[index].articleTitle;
    var urls = lists[index].link;
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
          return ArticleDetail(
            detailUrl: urls,
            articleTitle: title,
          );
        }));
  }

  _loadData(int currentPage) async {
    if (currentPage == _initPageCount && lists.isNotEmpty) {
      _viewModel.cleanList();
    }
    await _viewModel.getArticles(currentPage);
  }

  int _getRealIndex(int index) {
    return index - 1;
  }

  void _getLoginState() async {
    _isLogin = await Utils.get(Strings.login_state_key) == null ? false : true;
  }
}
