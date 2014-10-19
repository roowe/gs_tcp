##gs_tcp

这是我们游戏服务器，启动监听通用过程，由于项目之间共享通过复制粘贴，很难维护，我独立成一个App，然后添加一行gs\_tcp:listen就可以了。主要实现是通过传一个模块，然后里面实现start\_reader，然后tcp\_accepter会去调用，例子，参考test里面的几个example。

可能这个实现代码量相对没那么少，但是这样是比较OTP的做法。

##Installation

在你的`rebar.config`添加:

    {gs_tcp, ".*", {git, "https://github.com/roowe/gs_tcp", "master"}}

之后执行 `rebar get-deps`接着 `rebar compile`.

##Usage

在你的应用里面启动gs_tcp :

    application:start(gs_tcp),
    echo_example_sup:start_link(),
    gs_tcp:listen(echo_example_sup, 8001, 2, [{packet, 2}, {backlog, 1024}, {send_timeout, 5000}]),



