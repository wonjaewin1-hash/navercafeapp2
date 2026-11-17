#import "WebViewController.h"
#import <WebKit/WebKit.h>

// 시작 페이지 (네이버 카페 모바일 웹)
static NSString * const kHomeURL = @"https://m.cafe.naver.com/";

@interface WebViewController () <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *forwardItem;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // --- WebView 설정 ---
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore]; // 로그인 쿠키 유지
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

    // 일반 Safari와 동일한 User-Agent로 보이게 함 (웹에서 "앱으로 열기" 강요를 줄임)
    NSArray *ver = [UIDevice.currentDevice.systemVersion componentsSeparatedByString:@"."];
    NSString *safariVer = ver.count >= 2 ? [NSString stringWithFormat:@"%@.%@", ver[0], ver[1]] : ver.firstObject;
    config.applicationNameForUserAgent =
        [NSString stringWithFormat:@"Version/%@ Mobile/15E148 Safari/604.1", safariVer];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES; // 좌우 스와이프로 뒤로/앞으로
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];

    // 당겨서 새로고침
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    self.webView.scrollView.refreshControl = refresh;

    // --- 로딩 진행바 ---
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.tintColor = [UIColor colorWithRed:0.01 green:0.78 blue:0.35 alpha:1.0];
    [self.view addSubview:self.progressView];

    // --- 하단 툴바 ---
    self.backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                                     style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]
                                                        style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"house"]
                                                            style:UIBarButtonItemStylePlain target:self action:@selector(goHome)];
    UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"]
                                                              style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self action:@selector(share:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil action:nil];
    self.backItem.enabled = NO;
    self.forwardItem.enabled = NO;

    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.items = @[self.backItem, flex, self.forwardItem, flex, home, flex, reload, flex, share];
    [self.view addSubview:self.toolbar];

    // --- 레이아웃 ---
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.toolbar.topAnchor],

        [self.progressView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [self.toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.toolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.toolbar.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];

    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];

    [self goHome];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float p = (float)self.webView.estimatedProgress;
        [self.progressView setProgress:p animated:YES];
        self.progressView.hidden = (p >= 1.0f);
    } else {
        self.backItem.enabled = self.webView.canGoBack;
        self.forwardItem.enabled = self.webView.canGoForward;
    }
}

#pragma mark - 툴바 동작

- (void)goBack    { if (self.webView.canGoBack) [self.webView goBack]; }
- (void)goForward { if (self.webView.canGoForward) [self.webView goForward]; }
- (void)reload    { [self.webView reload]; }
- (void)goHome {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kHomeURL]]];
}

- (void)handleRefresh:(UIRefreshControl *)sender {
    [self.webView reload];
    [sender endRefreshing];
}

- (void)share:(UIBarButtonItem *)sender {
    NSURL *url = self.webView.URL;
    if (!url) return;
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                     applicationActivities:nil];
    vc.popoverPresentationController.barButtonItem = sender;
    [[self topViewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 내비게이션 정책

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)action
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = action.request.URL;
    NSString *scheme = url.scheme.lowercaseString ?: @"";
    NSString *host = url.host.lowercaseString ?: @"";

    if ([@[@"http", @"https", @"about", @"blob", @"data", @"javascript"] containsObject:scheme]) {
        // 앱스토어(업데이트 유도) 링크는 차단
        if ([host hasSuffix:@"apps.apple.com"] || [host hasSuffix:@"itunes.apple.com"]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    // 전화/메일/문자는 시스템으로 넘김
    if ([@[@"tel", @"mailto", @"sms"] containsObject:scheme]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }

    // navercafe://, naversearchapp://, itms-apps:// 등 앱 호출 스킴은 무시
    // (구버전 카페앱이나 앱스토어로 튕기는 것 방지)
    decisionHandler(WKNavigationActionPolicyCancel);
}

// target="_blank" / window.open 링크를 같은 화면에서 열기
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// 메모리 부족으로 웹 프로세스가 죽으면 자동 새로고침
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - JS alert / confirm / prompt

- (UIViewController *)topViewController {
    UIViewController *vc = self;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *a) { completionHandler(); }]];
    [[self topViewController] presentViewController:ac animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *a) { completionHandler(NO); }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *a) { completionHandler(YES); }]];
    [[self topViewController] presentViewController:ac animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString *))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:prompt
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.text = defaultText; }];
    __weak UIAlertController *weakAc = ac;
    [ac addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *a) { completionHandler(nil); }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *a) {
        completionHandler(weakAc.textFields.firstObject.text);
    }]];
    [[self topViewController] presentViewController:ac animated:YES completion:nil];
}

@end
