class Cppzmq < Formula
  desc "Header-only C++ binding for libzmq"
  homepage "http://www.zeromq.org/"
  url "https://github.com/zeromq/cppzmq/archive/v4.7.1.tar.gz"
  sha256 "9853e0437d834cbed5d3c223bf1d755cadee70e7c964c6e42c4c6783dee5d02c"
  head "https://github.com/zeromq/cppzmq.git"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "zeromq"

  def install
    mkdir "build" do
      system "cmake", "..", "-DCPPZMQ_BUILD_TESTS=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <zmq.hpp>

      int main()
      {
          zmq::context_t context;
          return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{Formula["zeromq"].lib}", "-lzmq", "-std=c++11", "-o", "test"
    system "./test"
  end
end
