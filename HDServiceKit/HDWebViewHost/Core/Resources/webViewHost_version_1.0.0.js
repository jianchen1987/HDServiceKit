!function (global) {
    global.webViewHost = {
        /* 当前版本号 */
        version: '1.0.0',
        /* 回调池 */
        callbackPool: {},
        /* 回调 ID */
        actionCallbackKey: 1,
        /* 监听池 */
        reqs: {},
        /* 对象是否是方法 */
        isFunction: function (p) {
            return typeof p === 'function';
        },
        /* 指令通讯 */
        invoke: function (_action, _data, _callback) {
            var fullParam = {
                action: _action,
                param: _data
            };
            /* 如果有传回调函数，则挂起到回调池 */
            if (this.isFunction(_callback)) {
                fullParam.callbackKey = 'cbk_' + parseInt((Math.random() * 1000), 10) + '_' + this.actionCallbackKey++;
                this.callbackPool[fullParam.callbackKey] = _callback;
            }
            this.postMessage(fullParam);
        },
        /* 发送指令 */
        postMessage: function (fullParam) {
            global.kWHScriptHandlerName &&
                this.isFunction(global.kWHScriptHandlerName.postMessage) &&
                global.kWHScriptHandlerName.postMessage(JSON.stringify(fullParam));
        },
        /**
         * 原生回调，比如调用上传图像 uploadImage
         * success result: {  msg: 'uploadImage::ok', code: 0, data: { serverId: 111 } }
         * cancel result: {  msg: 'uploadImage::cancel', code: 0, data: {  } }
         * fail result: { msg: ' 参数不能为空等等 ', code: 40001 }
         */
        __callback: function (_callbackKey, _param) {
            if (this.isFunction(this.callbackPool[_callbackKey])) {
                this.callbackPool[_callbackKey](_param);
                this.callbackPool[_callbackKey] = undefined;
            }
        },
        on: function (_action, _callback) {
            /* 这里暂时只做了一对一回调，如果有一对多需求，可以修改此处逻辑，将 value 改为序列 */
            this.reqs[String(_action)] = _callback;
        },
        /* 原生端触发监听 */
        __fire: function (_action, _data) {
            var funcCached = this.reqs[String(_action)];
            this.isFunction(funcCached) && funcCached(_data);
        }
    };
}(window);
