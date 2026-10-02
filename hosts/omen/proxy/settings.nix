# 两个客户端轮流提供同一后端；不可同时占用此监听端口。
{
  address = "169.254.0.1";
  prefixLength = 30;
  port = 7892;
  interface = "dae0";
}
