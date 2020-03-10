!function (global) {
    // 浏览器信息
    var __userAgent = global.navigator && global.navigator.userAgent || '';
    global.webViewHost = {
        // 当前版本号
        version: '1.0.0',
        // iOS 端
        isIOS: __userAgent.indexOf('iPhone') !== -1 || __userAgent.indexOf('Mac') !== -1,
        // 安卓端
        isAndroid: __userAgent.indexOf('Android') !== -1 || __userAgent.indexOf('Linux') !== -1,
        // 回调池
        callbackPool: {},
        // 回调 ID
        actionCallbackKey: 1,
        // 监听池
        reqs: {},
        // 对象是否是方法
        isFunction: function (p) {
            return typeof p === 'function';
        },
        // 指令通讯
        invoke: function (_action, _data, _callback) {
            var fullParam = {
                action: _action,
                param: _data
            };
            // 如果有传回调函数，则挂起到回调池
            if (this.isFunction(_callback)) {
                fullParam.callbackKey = 'cbk_' + parseInt((Math.random() * 1000), 10) + '_' + this.actionCallbackKey++;
                this.callbackPool[fullParam.callbackKey] = _callback;
            }
            this.postMessage(fullParam);
        },
        // 发送指令
        postMessage: function (fullParam) {
            return global.kWHScriptHandlerName &&
                this.isFunction(global.kWHScriptHandlerName.postMessage) &&
                global.kWHScriptHandlerName.postMessage(fullParam);
        },
        // 原生回调
        __callback: function (_callbackKey, _param) {
            this.invoke("log", {'logData': '回调：'+JSON.stringify(_param)})
            if (this.isFunction(this.callbackPool[_callbackKey])) {
                this.callbackPool[_callbackKey](_param);
                this.callbackPool[_callbackKey] = undefined;
            }
        },
        on: function (_action, _callback) {
            // 这里暂时只做了一对一回调，如果有一对多需求，可以修改此处逻辑，将 value 改为序列
            this.reqs[String(_action)] = _callback;
        },
        // 原生端触发监听
        __fire: function (_action, _data) {
            var funcCached = this.reqs[String(_action)];
            this.isFunction(funcCached) && funcCached(_data);
        }
    };
}(window);