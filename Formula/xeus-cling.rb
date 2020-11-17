class XeusCling < Formula
  desc "Jupyter kernel for the C++ programming language"
  homepage "http://xeus-cling.readthedocs.io"
  url "https://github.com/jupyter-xeus/xeus-cling/archive/0.10.0.tar.gz"
  sha256 "c22d8f09d3337855d946ed19adb4837e9d3cffa9216007c9bdeb16ca284ff783"
  head "https://github.com/jupyter-xeus/xeus-cling.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "cppzmq" => :build
  depends_on "xtl" => :build
  depends_on "cxxopts" => :build
  depends_on "nlohmann_json"
  depends_on "xeus"
  depends_on "zeromq"
  depends_on "cling"
  depends_on "pugixml"

  def install
    for xkernel in ["xcpp11", "xcpp14", "xcpp17"]
      inreplace "share/jupyter/kernels/"+xkernel+"/kernel.json.in", "\"{connection_file}\",\n",
         <<-EOS
"{connection_file}",
      "-I#{HOMEBREW_PREFIX}/include/",
      "-L#{HOMEBREW_PREFIX}/lib/",
         EOS
    end
       
    mkdir "build" do
      system "cmake", "..",
             "-Dcppzmq_DIR=#{Formula["cppzmq"].lib}/cmake/cppzmq",
             "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
             "-Dnlohmann_json_DIR=#{Formula["nlohmann_json"].lib}/cmake/nlohmann_json",
             "-Dxeus_DIR=#{Formula["xeus"].lib}/cmake/xeus",
             "-DCling_DIR=#{Formula["cling"].libexec}/lib/cmake/cling",
             "-DLLVM_CONFIG=#{Formula["cling"].libexec}/bin/llvm-config",
             "-DClang_DIR=#{Formula["cling"].libexec}/lib/cmake/clang/",
             "-Dcxxopts_DIR=#{Formula["cppzmq"].lib}/cmake/cxxopts",
             #"-DXEXTRA_JUPYTER_DATA_DIR=#{etc}/jupyter",
             "-DBUILD_TESTS=OFF",
             *std_cmake_args
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      If Jupyter is not installed #{HOMEBREW_PREFIX}/bin, it will not pick up the new kernels.
      The xeus-cling kernels (for C++11, C++14 and C++17 respectively) can be registered with the following commands:
        
        jupyter kernelspec install #{share}/jupyter/kernels/xcpp11
        jupyter kernelspec install #{share}/jupyter/kernels/xcpp14
        jupyter kernelspec install #{share}/jupyter/kernels/xcpp17
        
    EOS
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
