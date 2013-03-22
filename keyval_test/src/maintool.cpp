#include <iostream>
#include <stdlib.h>
#include <boost/asio.hpp>
namespace net = boost::asio;

std::string make_u32_field(uint32_t val)
{
  std::string retval;
  retval += (char) (val & 0xff);
  retval += (char) ((val >> 8) & 0xff);
  retval += (char) ((val >> 16) & 0xff);
  retval += (char) (val >> 24);
  return retval;
}

size_t make_sz(const char * s)
{
  printf("%d %d %d %d\r\n", s[0], s[1], s[2], s[3]);
  const uint8_t * p = (const uint8_t *)s;
  return ((size_t)s[0]) + (((size_t)s[1]) << 8) + (((size_t)s[2]) << 16) + (((size_t)s[3]) << 24); 
}

std::string construct_request(char type/*1 2 3*/, const std::string& key, const std::string& val = std::string())
{
  if (type < 1 || type > 3)
    throw std::logic_error("wrong type");
  std::string retval;
  size_t sz = sizeof(uint32_t) + 1 + key.size();
  if (type == 2) //set
    sz += sizeof(uint32_t) + val.size();
  retval += make_u32_field(sz) + type + make_u32_field(key.size());
  if (type == 2)
    retval += make_u32_field(val.size());
  retval += key;
  if (type == 2)
    retval += val;
  std::cout << "constructed: " << retval << " size: " << retval.size() << std::endl;
  return retval;
}

int main()
{
  net::ip::tcp::endpoint ep(net::ip::address::from_string("127.0.0.1"), 9090);
  net::io_service ios;
  net::ip::tcp::socket sock(ios);
  sock.connect(ep);
  char buf[1024];
  std::string b;
  b = construct_request(2, "key1", "val1");
  sock.write_some(net::buffer(b.data(), b.size()));
  b = construct_request(2, "key1", "val11");
  sock.write_some(net::buffer(b.data(), b.size()));
  b = construct_request(2, "key2", "val2");
  sock.write_some(net::buffer(b.data(), b.size()));
  b = construct_request(2, "key3", "val3");
  sock.write_some(net::buffer(b.data(), b.size()));
  b = construct_request(1, "key1");
  sock.write_some(net::buffer(b.data(), b.size()));
  net::read(sock, net::buffer(buf, sizeof(buf)), net::transfer_at_least(1));
  size_t sz = make_sz(buf);
  std::cout << sz << std::endl;
  b = std::string(&buf[sizeof(uint32_t)], sz);
  if (b != "val11")
    throw std::logic_error("test1 failed. b = " + b);
  b = construct_request(3, "key1");
  sock.write_some(net::buffer(b.data(), b.size()));
  b = construct_request(1, "key1");
  sock.write_some(net::buffer(b.data(), b.size()));
  sock.read_some(net::buffer(buf, sizeof(buf)));
  sz = make_sz(buf);
  std::cout << "sz = " << sz << std::endl;
  if (sz != 0)
    throw std::logic_error("sz != 0");

  sock.shutdown(net::ip::tcp::socket::shutdown_both);
  sock.close();
}

