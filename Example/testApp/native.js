var native = {
    default: this,
    call: function(method, args, cb) {
        var ret = '';
        if (typeof args == 'function') { //无参数有回调的情况
            cb = args;
            args = null;
        }
        var arg = { data: args === undefined ? null : args };
        if (typeof cb == 'function') {
            var cbName = 'nbcb' + window.nbcb++;
            window[cbName] = cb;
            arg['_nbstub'] = cbName;
        }
        arg = JSON.stringify(arg);
        if (window._webviewx) { // android
            ret = _webviewx.call(method, arg)
        } else if (window._nativewk) { // iOS
            ret = prompt("_nbbridge=" + method, arg);
        }
        return JSON.parse(ret || "{}").data;
    },
    setItem: function(key, value) {
        var arg = { key: key, value: value };
        native.call("setItem", arg);
    },
    getItem: function(key) {
        return native.call("getItem", key);
    },
    removeItem: function(key) {
        native.call("removeItem", key);
    }
};
!function() {
    if (window._nbf) {
        return;
    }
    window._nbf = {};
    window.nbcb = 0;
    window.native = native;
}();
