class Xeus < Formula
  desc "C++ implementation of the Jupyter kernel protocol"
  homepage "https://xeus.readthedocs.io/en/latest/"
  url "https://github.com/jupyter-xeus/xeus/archive/0.24.4.tar.gz"
  sha256 "8165d87ca2308909c64cf918ab698cad3a5cb8db658da10cb38d78be6d76595a"
  head "https://github.com/jupyter-xeus/xeus.git"
  license "BSD-3-Clause"
  
  depends_on "cmake" => :build
  depends_on "cppzmq" => :build
  depends_on "xtl" => :build
  depends_on "nlohmann_json" => :build
  depends_on "zeromq"
  depends_on "openssl"

  def install
    mkdir "build" do
      system "cmake", "..",
             "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
             "-Dnlohmann_json_DIR=#{Formula["nlohmann_json"].lib}/cmake/nlohmann_json",
             *std_cmake_args
      system "make", "install"
    end
  end

  test do
#    (testpath/"test.cpp").write <<~EOS
#      #include <iostream>
#      #include <memory>
#
#      #include "test_interpreter.hpp"
#      #include "xeus/xkernel.hpp"
#      #include "xeus/xkernel_configuration.hpp"
#
#      int main(int argc, char* argv[])
#      {
#          std::string file_name = (argc == 1) ? "connection.json" : argv[2];
#          xeus::xconfiguration config = xeus::load_configuration(file_name);
#
#          using interpreter_ptr = std::unique_ptr<test_kernel::test_interpreter>;
#          interpreter_ptr interpreter = interpreter_ptr(new test_kernel::test_interpreter());
#          xeus::xkernel kernel(config, xeus::get_user_name(), std::move(interpreter));
#          std::cout << "starting kernel" << std::endl;
#          kernel.start();
#
#          return 0;
#      }
#    EOS
#    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++11", "-o", "test"
#    system "./test"
  end
end
