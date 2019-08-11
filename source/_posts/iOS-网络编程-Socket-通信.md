---
title: iOS 网络编程-Socket 通信
date: 2017-05-18 20:39:45
tags:
- iOS
- 网络编程
- socket
categories: 
- iOS
- 网络编程
---

## 通信三个要素
* IP 地址（主机名）
	- 网络中设备的标识
	- 可以用主机名
	- 本地主机地址：127.0.0.1 主机名：localhost

* 端口号（port）
	- 用于标识应用程序的逻辑地址，不同进程的标识
	- 有效端口号 0~65535
	- 其中 0~1024 为系统使用或者保留端口，开发中不要使用，使用 1024 以下的端口

* 传输协议
	* TCP
	* UDP
<!-- more -->
* 一些常见协议
	- HTTP：超文本传输协议，端口：80
	- HTTPS：HTTP + SSL，HTTP 的安全版，端口：443
	- FTP：文件传输协议，端口：20，21，990
	- POP3：邮局协议，端口：110
	- SMIP：简单邮件传输协议，端口：25
	- telnet：远程终端协议，端口：23
	
## 网络通信模型
* OSI 七层网络模型
	- 应用层 ：HTTP 协议
	- 表示层  
	- 会话层  
	- 传输层 ：socket（TCP/UDP）
	- 网络层 ：IP 协议 路由器（网络传输路径）
	- 数据链路层 ：交换机\网卡 将数据打包成数据帧格式，从什么时间段到什么时间段的数据。
	- 物理层 ：网线（将二进制数据转换为电信号）

`HTTP 协议`对应于`应用层`，`TCP 协议`对应于`传输层`，`IP 协议`对应于`网络层`，`HTTP 协议`是基于 `TCP 连接`的，三者本质上没有可比性。 `TCP/IP` 是`传输层协议`，主要解决数据如何在网络中传输；而 HTTP 是应用层协议，主要解决如何包装数据。`Socket 是应用层与 TCP/IP 协议族通信的中间软件抽象层，是它的一组接口`。

![](https://liangjinggege.com/1170656-fe177ff611c71d76.jpg)

## UDP 和 TCP
* UPD（用户数据报协议）
	- 只管发送，不确认对方是否收到
	- 将数据及源和目的封装成数据包，不需要简历连接
	- 每个数据包的大小限制在 64k 之内
	- 因为无需连接，所以是不可靠

	- 不需要建立连接，速度快
	- 应用场景：网络视频播放、聊天、游戏
	
* TCP（传输控制协议）
	- 建立连接，形成传输数据的通道
	- 在连接中进行大数据传输（数据大小不受限制）
	- 通过三次握手完成连接，是可靠协议，安全送达
	- 必须建立连接，效率会稍低

* TCP 连接`三次握手`

**建立起一个TCP连接需要经过“三次握手”：**

第一次握手：客户端发送 syn 包(syn=j) 到服务器，并进入 SYN_SEND 状态，等待服务器确认；

第二次握手：服务器收到 syn 包，必须确认客户的 SYN（ack=j+1），同时自己也发送一个 SYN包（syn=k），即 SYN+ACK 包，此时服务器进入 SYN_RECV 状态；

第三次握手：客户端收到服务器的 SYN＋ACK 包，向服务器发送确认包 ACK(ack=k+1)，此包发送完毕，客户端和服务器进入 ESTABLISHED 状态，完成三次握手。

`三次握手(Three-way Handshake)`即建立一个 TCP 连接时，需要客户端和服务器总共发送 3 个包。三次握手的目的是`连接服务器指定端口`，建立 TCP 连接，并同步连接双方的序列号和确认号并交换 TCP 窗口大小信息。`在 socket 编程中，客户端执行 connect() 时,将触发三次握手`。

![](https://liangjinggege.com/1170656-a3120a20b9393a94.png)



* TCP 断开连接`四次握手`

TCP 连接的拆除需要发送四个包，因此称为四次握手(four-way handshake)。`在 socket 编程中，任何一方执行 close() 操作即可产生握手（有地方称为“挥手”）操作`。

![](https://liangjinggege.com/1170656-26cc9a86da3d9a68.jpg)


## Socket
**Socket：**套接字层、插座

* Socket 是为网络服务提供的一种机制
	- 在 Unix 中，网络即是 Socket，并不局限在 TCP/UDP
	- Socket 可以用于自定义协议

* 通信的两端都是 Socket
* 网络通信其实就是 Socket 间的通信
* 数据在两个 Socket 间通过 IO 传输
* Socket 是纯 C 语言的，跨平台


* Socket 通信示意图

![](https://liangjinggege.com/1170656-6b9392fad31b711d.png) 

## Socket 库函数
1. 导入系统库 `<sys/socket.h>`、 `<netinet/in.h>`、`<arpa/inet.h>`
2. 创建 socket
3. 建立连接
4. 发送数据
5. 读取数据
6. 关闭连接

```

// 1. 创建socket
// 参数一 domin：协议域，AF_INET -> ipv4
// 参数二 Socket 类型： SOCK_STREAM(TCP)/SOCK_DGRAM(报文UDP)
// 参数三 protocol 通信协议：IPPROTO_TCP ,填 0，表示自动选择，根据 Socket 类型
// 返回值：一个 socket
self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
NSLog(@"%d", self.clientSocket);
    
// 2. 建立连接
// 参数一：客户端 socket
// 参数二：指向结构体 sockaddr 的指针，包括目的 IP 地址和端口
// 参数三：结构体数据长度
// int 类型， 0：成功；其他：错误代码
    
// 服务器地址
struct sockaddr_in severAddr;
// 端口号
severAddr.sin_port = htons(port); // 20480，高位地位互换
// IP 地址：inet_addr：将 IP 地址转成一个数字
severAddr.sin_addr.s_addr = inet_addr(address.UTF8String);
/*
 struct sockaddr_in {
 __uint8_t	sin_len;
 sa_family_t	sin_family; // IPV4 还是 IPV6
 in_port_t	sin_port; // 端口号
 struct	in_addr sin_addr; // IP 地址
 char		sin_zero[8];
 };
 */
// $ nc -lk 12345 监听本地计算机 12345 端口
// Netcat: 终端下用于调试和检查网络的工具包，可以用于创建 TCP/IP 连接
int connectResult = connect(self.clientSocket, (const struct sockaddr *)&severAddr, sizeof(severAddr));
if (0 == connectResult)
{
    NSLog(@"连接成功！");
}
else
{
    NSLog(@"连接失败 %d", connectResult);
}

// 3. 发送数据
// 参数一：客户端socket
// 参数二：发送内容地址(指针）
// 参数三：发送内容长度
// 参数四：发送方式标志
// 返回值：成功：返回发送的字节数，失败：返回 SOCKET_ERROR
//    const char *sentMessage = "GET / HTTP/1.1\n""Host:www.sinaX.com\n\n";
const char *sendMsg = msg.UTF8String;
ssize_t sendLen = send(self.clientSocket, sendMsg, strlen(sendMsg), 0);
NSLog(@"发送了 %ld 个字节", sendLen);

// 4. 读取数据
// 参数一：客户端socket
// 参数二：接收内容缓冲区地址
// 参数三：接受内容缓冲区长度
// 参数四：接收方式，0：阻塞，必须等待服务器返回数据
// 返回值：成功：返回读入的字节数，失败：返回 SOCKET_ERROR
uint8_t buffer[1024]; // 空间，准备装二进制数据
ssize_t recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
NSLog(@"接收了 %ld 个字节", recvLen);
    
// 获取到服务器数据
NSData *data = [NSData dataWithBytes:buffer length:recvLen];
NSString *recvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
NSLog(@"recvString = %@", recvString);

// 5. 关闭连接
// 长连接：建立一个连接，不断开
// 短连接：连接完毕就断开
close(self.clientSocket);
NSLog(@"关闭连接");

```