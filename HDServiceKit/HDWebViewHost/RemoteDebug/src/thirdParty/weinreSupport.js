if (window.webViewHost) {
    window.webViewHost.on('weinre.enable', function () {
        // 加载完成的页面要使用远程调试需要重新加载 webview 才行
        window.location.reload();
    });
} else {
    console.log('无 HDWebViewHost 对象');
}
