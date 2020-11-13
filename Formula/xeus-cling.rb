class XeusCling < Formula
  desc "Jupyter kernel for the C++ programming language"
  homepage "https://quantstack.net"
  license "BSD 3-Clause"
  url "https://github.com/jupyter-xeus/xeus-cling/archive/0.10.0.tar.gz"
  sha256 "c22d8f09d3337855d946ed19adb4837e9d3cffa9216007c9bdeb16ca284ff783"
  head "https://github.com/jupyter-xeus/xeus-cling.git"

  depends_on "cmake" => :build
  depends_on "cppzmq" => :build
  depends_on "xtl" => :build
  depends_on "cxxopts" => :build
  depends_on "nlohmann_json" => :build
  depends_on "xeus"
  depends_on "zeromq"
  depends_on "cling"
  depends_on "pugixml"

  def install
    mkdir "build" do
      system "cmake", "-Dcppzmq_DIR=#{Formula["cppzmq"].lib}/cmake/cppzmq",
                      "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
                      "-Dxtl_DIR=#{Formula["nlohmann_json"].lib}/cmake/nlohmann_json",
                      "-Dxeus_DIR=#{Formula["xeus"].lib}/cmake/xeus",
                      "-DCling_DIR=#{Formula["cling"].libexec}/lib/cmake/cling",
                      "-DLLVM_CONFIG=#{Formula["cling"].libexec}/bin/llvm-config",
                      "-DClang_DIR=#{Formula["cling"].libexec}/lib/cmake/clang/",
                      "-Dcxxopts_DIR=#{Formula["cppzmq"].lib}/cmake/cxxopts",
                      "-D DOWNLOAD_GTEST=ON",
                      *std_cmake_args, "-DCMAKE_INSTALL_PREFIX=#{libexec}", ".."
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <functional>
      #include <iostream>
      #include <list>
      #include <string>

      #include "xeus-cling/xbuffer.hpp"

      using namespace std::placeholders;

      void callback(std::string value, std::list<std::string>& outputs)
      {
          outputs.push_back(value);
      }

      int main()
      {
          std::list<std::string> outputs;
          xcpp::xoutput_buffer buffer(std::bind(callback, _1, std::ref(outputs)));
          auto cout_strbuf = std::cout.rdbuf();
          std::cout.rdbuf(&buffer);
          std::cout << "Some output" << std::endl;
          int ret = ( outputs.front() == "Some output" );
          std::cout.rdbuf(cout_strbuf);
          return ret;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{libexec}/include", "-std=c++11", "-o", "test"
    system "./test"
  end
end
