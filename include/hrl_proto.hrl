%% proto协议中的协议名对应协议号宏定义

%% hello.proto 协议号宏定义
-define(c2s_hello, 59801).
-define(s2c_hello, 59801).

%% login.proto 协议号宏定义
-define(c2s_heartbeat, 10000).
-define(s2c_heartbeat, 10000).

%% test.proto 协议号宏定义
-define(c2s_test1, 59901).
-define(c2s_test2, 59902).
-define(s2c_test1, 59901).
-define(s2c_test2, 59902).
